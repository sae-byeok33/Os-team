#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

int
main(void)
{
  // 스케줄링 정책을 MLFQ (1번)으로 설정
  if (setSchedPolicy(1) < 0) {
    printf(1, "setSchedPolicy() failed\n");
    exit();
  }

  printf(1, "Scheduling policy set to MLFQ (1)\n");

  struct pstat st;

  // 시스템 콜로 프로세스 상태 정보 가져오기
  if (getpinfo(&st) < 0) {
    printf(1, "getpinfo() failed\n");
    exit();
  }

  // 프로세스 정보 출력
  printf(1, "PID\tPRIO\tSTATE\tTICKS\n");
  for (int i = 0; i < NPROC; i++) {
    if (st.inuse[i]) {
      int total_ticks = 0;
      for (int j = 0; j < 4; j++)
        total_ticks += st.ticks[i][j];

      printf(1, "%d\t%d\t%d\t%d\n",
             st.pid[i],
             st.priority[i],
             st.state[i],
             total_ticks);
    }
  }

  exit();
}
