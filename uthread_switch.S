.text # 코드가 들어가는 텍스트 섹션일 지정

/*
 * save the old thread's registers,
 * restore the new thread's registers.
 */

.globl thread_switch  #  thread_switch 함수가 외부에서 참조될수 있도록 공개(global) 선언
thread_switch:
    movl current_thread, %eax      # current_thread의 주소를 eax에 저장
    movl %esp, (%eax)              # 현재 스택 포인터esp를 current_thread->sp에 저장

    # Load new thread's esp from next_thread->sp
    movl next_thread, %ebx         # next_thread의 주소를 ebx에 저장
    movl (%ebx), %esp              # next_thread->sp 값을 esp에 복사하여 스택 복원

    ret                            # 스택에 있는 리턴주소로 점프 -> next_thread 실행 재개
