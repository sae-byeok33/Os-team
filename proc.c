#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "debug.h"

//프로세스 테이블을 정의하는 전역 구조체
//ptable은 spinlock과 NPROC 개수만큼의 프로세스 배열을 포함한다.
struct {
  struct spinlock lock;   //프로세스 테이블 접근 시 동기화를 위한 락
  struct proc proc[NPROC];  //실제 프로세스 정보를 담는 배열
} ptable;


static struct proc *initproc; //초기 프로세스를 가리키는 포인터. 첫 사용자 프로세스를 만들 때 사용된다.

int nextpid = 1;  //다음에 할당된 프로세스 ID를 저장하는 전역 변수

//어셈블리로 구현된 외부 함수 . fork 후 유저 프로세스로 돌아갈 때 사용된다.
extern void forkret(void);  //프로세스 fork 이후 리턴 지점
extern void trapret(void);  //인터럽트 또는 시스템 콜에서 유저 모드로 돌아가는 지점 

static void wakeup1(void *chan);  //내부적으로 사용되는 wakeup 함수 . 조건 변수 chan을 기다리는 프로세스들을 깨움 

// ptable을 초기화하는 함수 . xv6 커널 시작시 호출된다
void
pinit(void)
{
  initlock(&ptable.lock, "ptable");  //락을 초기화 한다 . 이후 ptable 접근시 이 락을 사용해 동기화 한다.
}

// 인터럽트가 꺼진 상태에서 호출되어야 함/ (context switch중 안전하게 실행되도록 하기 위해)
// 현재 실행 중인 cpu 의 id를 반환 하는 함수
int
cpuid() {
  // mycpu()는 현재 cpu의 구조체 포인터를 반환함
  // cpus는 cpu배열의 시작주소. 포인터 뺄셈을 통해 현재 cpu의 인덱스를 구함.
  return mycpu()-cpus;
}

//현재 실행중인 cpu 구조체 포인터를 반환 하는 함수
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  //인터럽트가 켜진 상태에서 이 함수를 호출하면 안됨
  //인터럽트 중단 없이 안전하게 현재 cpu를 파악하기 위해서
  if(readeflags()&FL_IF){
    panic("mycpu called with interrupts enabled\n"); //치명적인 오류가 발생
  }

  //현재 cpu의 로컬 APIC ID를 읽어온다
  apicid = lapicid();

  //APIC ID는 CPU마다 고유하지만 연속적이진 않을 수 있음
  //따라서 모든 CPU를 순회하며 apicid가 일치하는 CPU를 찾음

  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid){
      return &cpus[i];  //일치하는 cpu 구조체 포인터 반환
    }
  }
  panic("unknown apicid\n");
}

// 현재 실행 중인 프로세스를 반환하는 함수
// 단 인터럽트를 비활성화 하여 스케줄링 변경 방지
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;

  pushcli();    //인터럽트를 비활성화함(nesting 지원)
  c = mycpu();  //현재 cpu를 가져옴
  p = c->proc;  //해당 cpu에서 실행 중인 프로세스를 가져옴
  popcli();     //인터럽트 상태 복원
  
  return p;     //현재 프로세스 포인터 반환
}

//정적 함수 : 새로운 프로세스를 할당하고 초기화
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock); //프로세스 테이블 보호를 위해 락 획득

  // 프로세스 테이블에서 UNUSED 상태인 빈 프로세스를 찾음
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED){
      goto found; //UNUSED 상태 프로세스를 찾으면 found로 점프
    }

  release(&ptable.lock);  //UNUSED 상태를 찾지 못한 경우: 실패
  return 0;

found:
  p->state = EMBRYO;    //프로세스 상태를 EMBRYO
  p->pid = nextpid++;

  p->priority = 3;
  for (int i = 0; i < 4; i++) {
    p->ticks[i] = 0;
    p->wait_ticks[i] = 0;
  }

  release(&ptable.lock);


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;


  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0){
    panic("userinit: out of memory?");
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.

void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;){
    sti();
    acquire(&ptable.lock);

    if (c->sched_policy == 1) {
      // MLFQ: 높은 우선순위부터 RUNNABLE 프로세스 탐색
      struct proc *selected = 0;
      for (int prio = 3; prio >= 0; prio--) {
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
          if (p->state == RUNNABLE && p->priority == prio) {
            selected = p;
            goto found;
          }
        }
      }
    found:
      if (selected) {
        c->proc = selected;
        switchuvm(selected);
        selected->state = RUNNING;

        // 한 번만 swtch, 실제 시간은 타이머 인터럽트에서 틱 관리
        swtch(&(c->scheduler), selected->context);
        switchkvm();

        // 타임슬라이스 다 썼으면 demote
        int slice[4] = {0, 32, 16, 8};
        int prio = selected->priority;
        if (prio > 0 && selected->ticks[prio] >= slice[prio]) {
          selected->priority--;
          selected->ticks[prio] = 0;
        }

        // 다른 프로세스 대기 시간 증가 + boost 체크
        update_wait_ticks(selected);
        priority_boost();

        c->proc = 0;
      }

    } else {
      // 기본 Round-Robin 스케줄링
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
        if(p->state != RUNNABLE)
          continue;

        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;

        swtch(&(c->scheduler), p->context);
        switchkvm();

        c->proc = 0;
      }
    }

    release(&ptable.lock);
  }
}


// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();    //현재 CPU에서 실행중인 프로세스를 얻음

  //ptable.lock이 잡혀있지 않을때
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");

  //현재 cpu의 인터럽트 차단회수가 1이 아니면 에러
  if(mycpu()->ncli != 1)
    panic("sched locks");

  //현재 프로세스 상태가 RUNNING이면 에러
  //RUNNABLE , SLEEPING , ZOMBIE 의 상태어야 전환이 가능
  if(p->state == RUNNING)
    panic("sched running");

  //인터럽트가 활성화 된 상태일 경우 에러
  //전환중에는 인터럽트가 꺼져있어야함
  if(readeflags()&FL_IF)
    panic("sched interruptible");

  intena = mycpu()->intena; //현재 CPU의 언터럽트  활성화 상태를 저장해둔다

  swtch(&p->context, mycpu()->scheduler); //전환을 수행 , 현재 프로세스의 context를 저장하고 CPU가 가진 scheduler context로 전환

  mycpu()->intena = intena; //스케줄링이 끝난뒤 원래 인터럽트 상태로 복원
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

#include "pstat.h"

int
sys_getpinfo(void)
{
  struct pstat *ps;

  // 유저 포인터를 커널에서 접근 가능하도록 변환
  if (argptr(0, (void*)&ps, sizeof(*ps)) < 0)
    return -1;

  acquire(&ptable.lock);
  for (int i = 0; i < NPROC; i++) {
    struct proc *p = &ptable.proc[i];
    ps->inuse[i] = (p->state != UNUSED);
    ps->pid[i] = p->pid;
    ps->priority[i] = p->priority;
    ps->state[i] = p->state;
    for (int j = 0; j < 4; j++) {
      ps->ticks[i][j] = p->ticks[j];
      ps->wait_ticks[i][j] = p->wait_ticks[j];
    }
  }
  release(&ptable.lock);
  return 0;
}

int
sys_setSchedPolicy(void)
{
  int policy;
  if (argint(0, &policy) < 0)
    return -1;
  if (policy < 0 || policy > 3)
    return -1;

  cli();  // 인터럽트 끄기
  mycpu()->sched_policy = policy;
  sti();  // 다시 켜기

  return 0;
}


void
update_wait_ticks(struct proc *running)
{
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    if (p == running) continue;
    if (p->state == RUNNABLE) {
      if (p->priority < 0 || p->priority > 3)
         continue; // 잘못된 priority 값이면 무시
      p->wait_ticks[p->priority]++;
    }
  }
}

void
priority_boost(void)
{
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    if (p->state == UNUSED)
      continue;

    int prio = p->priority;

    if (prio == 2 || prio == 1) {
      // slice: Q2 = 16, Q1 = 32
      int slice[4] = {0, 32, 16, 8};
      int limit = 10 * slice[prio];
      if (p->wait_ticks[prio] >= limit) {
        p->priority++;
        p->wait_ticks[prio] = 0;
      }
    }

    if (prio == 0) {
      if (p->wait_ticks[0] >= 500) {
        p->priority = 1;
        p->wait_ticks[0] = 0;
      }
    }
  }
}
