#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

#define NUM_PROCS 3

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    j += i * j + 1;
  }
  return j;
}

int main(int argc, char* argv[]) {
  struct pstat s;
  int i;

  if (setSchedPolicy(2) < 0) {
    printf(1, "setSchedPolicy(2) failed\n");
    exit();
  }

  for (i = 0; i < NUM_PROCS; i++) {
    int pid = fork();
    if (pid == 0) {
      // 0번만 cheat 시도
      if (i == 0) {
        int iter;
        for (iter = 0; iter < 50; iter++) {
          workload(10000000); // 약간 일하고
          yield();            // cheat 시도
        }
      } else {
        workload(500000000);  //   CPU 대충 많이 점유
      }
      exit();
    }
  }

  for (i = 0; i < NUM_PROCS; i++) wait();


  // 출력 파트
  getpinfo(&s);
  printf(1, "PID\tPRIO\tTICKS(Q0~Q3)\tWAIT(Q0~Q3)\n");
  for (i = 0; i < NPROC; i++) {
    if (s.inuse[i]) {
      printf(1, "%d\t%d\t%d %d %d %d\t%d %d %d %d\n",
             s.pid[i], s.priority[i],
             s.ticks[i][0], s.ticks[i][1], s.ticks[i][2], s.ticks[i][3],
             s.wait_ticks[i][0], s.wait_ticks[i][1], s.wait_ticks[i][2], s.wait_ticks[i][3]);
    }
  }

  exit();
}
