
_pinfo:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

#define NUM_PROCS 3

int workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++) {
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
    j += i * j + 1;
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++) {
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
  }
  return j;
  2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  32:	c9                   	leave
  33:	c3                   	ret

00000034 <main>:

int main(int argc, char* argv[]) {
  34:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  38:	83 e4 f0             	and    $0xfffffff0,%esp
  3b:	ff 71 fc             	push   -0x4(%ecx)
  3e:	55                   	push   %ebp
  3f:	89 e5                	mov    %esp,%ebp
  41:	57                   	push   %edi
  42:	56                   	push   %esi
  43:	53                   	push   %ebx
  44:	51                   	push   %ecx
  45:	81 ec 28 0c 00 00    	sub    $0xc28,%esp
  struct pstat s;
  int i;

  if (setSchedPolicy(2) < 0) {
  4b:	83 ec 0c             	sub    $0xc,%esp
  4e:	6a 02                	push   $0x2
  50:	e8 f0 04 00 00       	call   545 <setSchedPolicy>
  55:	83 c4 10             	add    $0x10,%esp
  58:	85 c0                	test   %eax,%eax
  5a:	79 17                	jns    73 <main+0x3f>
    printf(1, "setSchedPolicy(2) failed\n");
  5c:	83 ec 08             	sub    $0x8,%esp
  5f:	68 e0 09 00 00       	push   $0x9e0
  64:	6a 01                	push   $0x1
  66:	e8 be 05 00 00       	call   629 <printf>
  6b:	83 c4 10             	add    $0x10,%esp
    exit();
  6e:	e8 22 04 00 00       	call   495 <exit>
  }

  for (i = 0; i < NUM_PROCS; i++) {
  73:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  7a:	eb 57                	jmp    d3 <main+0x9f>
    int pid = fork();
  7c:	e8 0c 04 00 00       	call   48d <fork>
  81:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if (pid == 0) {
  84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  88:	75 45                	jne    cf <main+0x9b>
      // 0번만 cheat 시도
      if (i == 0) {
  8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8e:	75 2a                	jne    ba <main+0x86>
        int iter;
        for (iter = 0; iter < 50; iter++) {
  90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  97:	eb 19                	jmp    b2 <main+0x7e>
          workload(10000000); // 약간 일하고
  99:	83 ec 0c             	sub    $0xc,%esp
  9c:	68 80 96 98 00       	push   $0x989680
  a1:	e8 5a ff ff ff       	call   0 <workload>
  a6:	83 c4 10             	add    $0x10,%esp
          yield();            // cheat 시도
  a9:	e8 9f 04 00 00       	call   54d <yield>
        for (iter = 0; iter < 50; iter++) {
  ae:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  b2:	83 7d e0 31          	cmpl   $0x31,-0x20(%ebp)
  b6:	7e e1                	jle    99 <main+0x65>
  b8:	eb 10                	jmp    ca <main+0x96>
        }
      } else {
        workload(500000000);  //   CPU 대충 많이 점유
  ba:	83 ec 0c             	sub    $0xc,%esp
  bd:	68 00 65 cd 1d       	push   $0x1dcd6500
  c2:	e8 39 ff ff ff       	call   0 <workload>
  c7:	83 c4 10             	add    $0x10,%esp
      }
      exit();
  ca:	e8 c6 03 00 00       	call   495 <exit>
  for (i = 0; i < NUM_PROCS; i++) {
  cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  d3:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
  d7:	7e a3                	jle    7c <main+0x48>
    }
  }

  for (i = 0; i < NUM_PROCS; i++) wait();
  d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  e0:	eb 09                	jmp    eb <main+0xb7>
  e2:	e8 b6 03 00 00       	call   49d <wait>
  e7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  eb:	83 7d e4 02          	cmpl   $0x2,-0x1c(%ebp)
  ef:	7e f1                	jle    e2 <main+0xae>


  // 출력 파트
  getpinfo(&s);
  f1:	83 ec 0c             	sub    $0xc,%esp
  f4:	8d 85 dc f3 ff ff    	lea    -0xc24(%ebp),%eax
  fa:	50                   	push   %eax
  fb:	e8 3d 04 00 00       	call   53d <getpinfo>
 100:	83 c4 10             	add    $0x10,%esp
  printf(1, "PID\tPRIO\tTICKS(Q0~Q3)\tWAIT(Q0~Q3)\n");
 103:	83 ec 08             	sub    $0x8,%esp
 106:	68 fc 09 00 00       	push   $0x9fc
 10b:	6a 01                	push   $0x1
 10d:	e8 17 05 00 00       	call   629 <printf>
 112:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < NPROC; i++) {
 115:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 11c:	e9 0e 01 00 00       	jmp    22f <main+0x1fb>
    if (s.inuse[i]) {
 121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 124:	8b 84 85 dc f3 ff ff 	mov    -0xc24(%ebp,%eax,4),%eax
 12b:	85 c0                	test   %eax,%eax
 12d:	0f 84 f8 00 00 00    	je     22b <main+0x1f7>
      printf(1, "%d\t%d\t%d %d %d %d\t%d %d %d %d\n",
 133:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 136:	c1 e0 04             	shl    $0x4,%eax
 139:	8d 40 e8             	lea    -0x18(%eax),%eax
 13c:	01 e8                	add    %ebp,%eax
 13e:	2d 00 04 00 00       	sub    $0x400,%eax
 143:	8b 30                	mov    (%eax),%esi
 145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 148:	c1 e0 04             	shl    $0x4,%eax
 14b:	8d 40 e8             	lea    -0x18(%eax),%eax
 14e:	01 e8                	add    %ebp,%eax
 150:	2d 04 04 00 00       	sub    $0x404,%eax
 155:	8b 38                	mov    (%eax),%edi
 157:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 15a:	c1 e0 04             	shl    $0x4,%eax
 15d:	8d 40 e8             	lea    -0x18(%eax),%eax
 160:	01 e8                	add    %ebp,%eax
 162:	2d 08 04 00 00       	sub    $0x408,%eax
 167:	8b 00                	mov    (%eax),%eax
 169:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
 16f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 172:	83 e8 80             	sub    $0xffffff80,%eax
 175:	c1 e0 04             	shl    $0x4,%eax
 178:	8d 50 e8             	lea    -0x18(%eax),%edx
 17b:	8d 04 2a             	lea    (%edx,%ebp,1),%eax
 17e:	2d 0c 0c 00 00       	sub    $0xc0c,%eax
 183:	8b 08                	mov    (%eax),%ecx
 185:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
 18b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 18e:	c1 e0 04             	shl    $0x4,%eax
 191:	8d 58 e8             	lea    -0x18(%eax),%ebx
 194:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
 197:	2d 00 08 00 00       	sub    $0x800,%eax
 19c:	8b 10                	mov    (%eax),%edx
 19e:	89 95 cc f3 ff ff    	mov    %edx,-0xc34(%ebp)
 1a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1a7:	c1 e0 04             	shl    $0x4,%eax
 1aa:	8d 58 e8             	lea    -0x18(%eax),%ebx
 1ad:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
 1b0:	2d 04 08 00 00       	sub    $0x804,%eax
 1b5:	8b 18                	mov    (%eax),%ebx
 1b7:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
 1bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1c0:	c1 e0 04             	shl    $0x4,%eax
 1c3:	8d 40 e8             	lea    -0x18(%eax),%eax
 1c6:	01 e8                	add    %ebp,%eax
 1c8:	2d 08 08 00 00       	sub    $0x808,%eax
 1cd:	8b 18                	mov    (%eax),%ebx
 1cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1d2:	83 c0 40             	add    $0x40,%eax
 1d5:	c1 e0 04             	shl    $0x4,%eax
 1d8:	8d 40 e8             	lea    -0x18(%eax),%eax
 1db:	01 e8                	add    %ebp,%eax
 1dd:	2d 0c 0c 00 00       	sub    $0xc0c,%eax
 1e2:	8b 08                	mov    (%eax),%ecx
 1e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1e7:	83 e8 80             	sub    $0xffffff80,%eax
 1ea:	8b 94 85 dc f3 ff ff 	mov    -0xc24(%ebp,%eax,4),%edx
 1f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1f4:	83 c0 40             	add    $0x40,%eax
 1f7:	8b 84 85 dc f3 ff ff 	mov    -0xc24(%ebp,%eax,4),%eax
 1fe:	56                   	push   %esi
 1ff:	57                   	push   %edi
 200:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 206:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 20c:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 212:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 218:	53                   	push   %ebx
 219:	51                   	push   %ecx
 21a:	52                   	push   %edx
 21b:	50                   	push   %eax
 21c:	68 20 0a 00 00       	push   $0xa20
 221:	6a 01                	push   $0x1
 223:	e8 01 04 00 00       	call   629 <printf>
 228:	83 c4 30             	add    $0x30,%esp
  for (i = 0; i < NPROC; i++) {
 22b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 22f:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 233:	0f 8e e8 fe ff ff    	jle    121 <main+0xed>
             s.ticks[i][0], s.ticks[i][1], s.ticks[i][2], s.ticks[i][3],
             s.wait_ticks[i][0], s.wait_ticks[i][1], s.wait_ticks[i][2], s.wait_ticks[i][3]);
    }
  }

  exit();
 239:	e8 57 02 00 00       	call   495 <exit>

0000023e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 23e:	55                   	push   %ebp
 23f:	89 e5                	mov    %esp,%ebp
 241:	57                   	push   %edi
 242:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 243:	8b 4d 08             	mov    0x8(%ebp),%ecx
 246:	8b 55 10             	mov    0x10(%ebp),%edx
 249:	8b 45 0c             	mov    0xc(%ebp),%eax
 24c:	89 cb                	mov    %ecx,%ebx
 24e:	89 df                	mov    %ebx,%edi
 250:	89 d1                	mov    %edx,%ecx
 252:	fc                   	cld
 253:	f3 aa                	rep stos %al,%es:(%edi)
 255:	89 ca                	mov    %ecx,%edx
 257:	89 fb                	mov    %edi,%ebx
 259:	89 5d 08             	mov    %ebx,0x8(%ebp)
 25c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 25f:	90                   	nop
 260:	5b                   	pop    %ebx
 261:	5f                   	pop    %edi
 262:	5d                   	pop    %ebp
 263:	c3                   	ret

00000264 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 264:	55                   	push   %ebp
 265:	89 e5                	mov    %esp,%ebp
 267:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 26a:	8b 45 08             	mov    0x8(%ebp),%eax
 26d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 270:	90                   	nop
 271:	8b 55 0c             	mov    0xc(%ebp),%edx
 274:	8d 42 01             	lea    0x1(%edx),%eax
 277:	89 45 0c             	mov    %eax,0xc(%ebp)
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	8d 48 01             	lea    0x1(%eax),%ecx
 280:	89 4d 08             	mov    %ecx,0x8(%ebp)
 283:	0f b6 12             	movzbl (%edx),%edx
 286:	88 10                	mov    %dl,(%eax)
 288:	0f b6 00             	movzbl (%eax),%eax
 28b:	84 c0                	test   %al,%al
 28d:	75 e2                	jne    271 <strcpy+0xd>
    ;
  return os;
 28f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 292:	c9                   	leave
 293:	c3                   	ret

00000294 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 294:	55                   	push   %ebp
 295:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 297:	eb 08                	jmp    2a1 <strcmp+0xd>
    p++, q++;
 299:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 29d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	0f b6 00             	movzbl (%eax),%eax
 2a7:	84 c0                	test   %al,%al
 2a9:	74 10                	je     2bb <strcmp+0x27>
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	0f b6 10             	movzbl (%eax),%edx
 2b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	38 c2                	cmp    %al,%dl
 2b9:	74 de                	je     299 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	0f b6 d0             	movzbl %al,%edx
 2c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c7:	0f b6 00             	movzbl (%eax),%eax
 2ca:	0f b6 c0             	movzbl %al,%eax
 2cd:	29 c2                	sub    %eax,%edx
 2cf:	89 d0                	mov    %edx,%eax
}
 2d1:	5d                   	pop    %ebp
 2d2:	c3                   	ret

000002d3 <strlen>:

uint
strlen(char *s)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2e0:	eb 04                	jmp    2e6 <strlen+0x13>
 2e2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	01 d0                	add    %edx,%eax
 2ee:	0f b6 00             	movzbl (%eax),%eax
 2f1:	84 c0                	test   %al,%al
 2f3:	75 ed                	jne    2e2 <strlen+0xf>
    ;
  return n;
 2f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2f8:	c9                   	leave
 2f9:	c3                   	ret

000002fa <memset>:

void*
memset(void *dst, int c, uint n)
{
 2fa:	55                   	push   %ebp
 2fb:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2fd:	8b 45 10             	mov    0x10(%ebp),%eax
 300:	50                   	push   %eax
 301:	ff 75 0c             	push   0xc(%ebp)
 304:	ff 75 08             	push   0x8(%ebp)
 307:	e8 32 ff ff ff       	call   23e <stosb>
 30c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 312:	c9                   	leave
 313:	c3                   	ret

00000314 <strchr>:

char*
strchr(const char *s, char c)
{
 314:	55                   	push   %ebp
 315:	89 e5                	mov    %esp,%ebp
 317:	83 ec 04             	sub    $0x4,%esp
 31a:	8b 45 0c             	mov    0xc(%ebp),%eax
 31d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 320:	eb 14                	jmp    336 <strchr+0x22>
    if(*s == c)
 322:	8b 45 08             	mov    0x8(%ebp),%eax
 325:	0f b6 00             	movzbl (%eax),%eax
 328:	38 45 fc             	cmp    %al,-0x4(%ebp)
 32b:	75 05                	jne    332 <strchr+0x1e>
      return (char*)s;
 32d:	8b 45 08             	mov    0x8(%ebp),%eax
 330:	eb 13                	jmp    345 <strchr+0x31>
  for(; *s; s++)
 332:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	84 c0                	test   %al,%al
 33e:	75 e2                	jne    322 <strchr+0xe>
  return 0;
 340:	b8 00 00 00 00       	mov    $0x0,%eax
}
 345:	c9                   	leave
 346:	c3                   	ret

00000347 <gets>:

char*
gets(char *buf, int max)
{
 347:	55                   	push   %ebp
 348:	89 e5                	mov    %esp,%ebp
 34a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 354:	eb 42                	jmp    398 <gets+0x51>
    cc = read(0, &c, 1);
 356:	83 ec 04             	sub    $0x4,%esp
 359:	6a 01                	push   $0x1
 35b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 35e:	50                   	push   %eax
 35f:	6a 00                	push   $0x0
 361:	e8 47 01 00 00       	call   4ad <read>
 366:	83 c4 10             	add    $0x10,%esp
 369:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 36c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 370:	7e 33                	jle    3a5 <gets+0x5e>
      break;
    buf[i++] = c;
 372:	8b 45 f4             	mov    -0xc(%ebp),%eax
 375:	8d 50 01             	lea    0x1(%eax),%edx
 378:	89 55 f4             	mov    %edx,-0xc(%ebp)
 37b:	89 c2                	mov    %eax,%edx
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	01 c2                	add    %eax,%edx
 382:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 386:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 388:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 38c:	3c 0a                	cmp    $0xa,%al
 38e:	74 16                	je     3a6 <gets+0x5f>
 390:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 394:	3c 0d                	cmp    $0xd,%al
 396:	74 0e                	je     3a6 <gets+0x5f>
  for(i=0; i+1 < max; ){
 398:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39b:	83 c0 01             	add    $0x1,%eax
 39e:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3a1:	7f b3                	jg     356 <gets+0xf>
 3a3:	eb 01                	jmp    3a6 <gets+0x5f>
      break;
 3a5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	01 d0                	add    %edx,%eax
 3ae:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3b4:	c9                   	leave
 3b5:	c3                   	ret

000003b6 <stat>:

int
stat(char *n, struct stat *st)
{
 3b6:	55                   	push   %ebp
 3b7:	89 e5                	mov    %esp,%ebp
 3b9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3bc:	83 ec 08             	sub    $0x8,%esp
 3bf:	6a 00                	push   $0x0
 3c1:	ff 75 08             	push   0x8(%ebp)
 3c4:	e8 0c 01 00 00       	call   4d5 <open>
 3c9:	83 c4 10             	add    $0x10,%esp
 3cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3d3:	79 07                	jns    3dc <stat+0x26>
    return -1;
 3d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3da:	eb 25                	jmp    401 <stat+0x4b>
  r = fstat(fd, st);
 3dc:	83 ec 08             	sub    $0x8,%esp
 3df:	ff 75 0c             	push   0xc(%ebp)
 3e2:	ff 75 f4             	push   -0xc(%ebp)
 3e5:	e8 03 01 00 00       	call   4ed <fstat>
 3ea:	83 c4 10             	add    $0x10,%esp
 3ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3f0:	83 ec 0c             	sub    $0xc,%esp
 3f3:	ff 75 f4             	push   -0xc(%ebp)
 3f6:	e8 c2 00 00 00       	call   4bd <close>
 3fb:	83 c4 10             	add    $0x10,%esp
  return r;
 3fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 401:	c9                   	leave
 402:	c3                   	ret

00000403 <atoi>:

int
atoi(const char *s)
{
 403:	55                   	push   %ebp
 404:	89 e5                	mov    %esp,%ebp
 406:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 409:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 410:	eb 25                	jmp    437 <atoi+0x34>
    n = n*10 + *s++ - '0';
 412:	8b 55 fc             	mov    -0x4(%ebp),%edx
 415:	89 d0                	mov    %edx,%eax
 417:	c1 e0 02             	shl    $0x2,%eax
 41a:	01 d0                	add    %edx,%eax
 41c:	01 c0                	add    %eax,%eax
 41e:	89 c1                	mov    %eax,%ecx
 420:	8b 45 08             	mov    0x8(%ebp),%eax
 423:	8d 50 01             	lea    0x1(%eax),%edx
 426:	89 55 08             	mov    %edx,0x8(%ebp)
 429:	0f b6 00             	movzbl (%eax),%eax
 42c:	0f be c0             	movsbl %al,%eax
 42f:	01 c8                	add    %ecx,%eax
 431:	83 e8 30             	sub    $0x30,%eax
 434:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	0f b6 00             	movzbl (%eax),%eax
 43d:	3c 2f                	cmp    $0x2f,%al
 43f:	7e 0a                	jle    44b <atoi+0x48>
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	0f b6 00             	movzbl (%eax),%eax
 447:	3c 39                	cmp    $0x39,%al
 449:	7e c7                	jle    412 <atoi+0xf>
  return n;
 44b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 44e:	c9                   	leave
 44f:	c3                   	ret

00000450 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 45c:	8b 45 0c             	mov    0xc(%ebp),%eax
 45f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 462:	eb 17                	jmp    47b <memmove+0x2b>
    *dst++ = *src++;
 464:	8b 55 f8             	mov    -0x8(%ebp),%edx
 467:	8d 42 01             	lea    0x1(%edx),%eax
 46a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 46d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 470:	8d 48 01             	lea    0x1(%eax),%ecx
 473:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 476:	0f b6 12             	movzbl (%edx),%edx
 479:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 47b:	8b 45 10             	mov    0x10(%ebp),%eax
 47e:	8d 50 ff             	lea    -0x1(%eax),%edx
 481:	89 55 10             	mov    %edx,0x10(%ebp)
 484:	85 c0                	test   %eax,%eax
 486:	7f dc                	jg     464 <memmove+0x14>
  return vdst;
 488:	8b 45 08             	mov    0x8(%ebp),%eax
}
 48b:	c9                   	leave
 48c:	c3                   	ret

0000048d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 48d:	b8 01 00 00 00       	mov    $0x1,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret

00000495 <exit>:
SYSCALL(exit)
 495:	b8 02 00 00 00       	mov    $0x2,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret

0000049d <wait>:
SYSCALL(wait)
 49d:	b8 03 00 00 00       	mov    $0x3,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret

000004a5 <pipe>:
SYSCALL(pipe)
 4a5:	b8 04 00 00 00       	mov    $0x4,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret

000004ad <read>:
SYSCALL(read)
 4ad:	b8 05 00 00 00       	mov    $0x5,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret

000004b5 <write>:
SYSCALL(write)
 4b5:	b8 10 00 00 00       	mov    $0x10,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret

000004bd <close>:
SYSCALL(close)
 4bd:	b8 15 00 00 00       	mov    $0x15,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret

000004c5 <kill>:
SYSCALL(kill)
 4c5:	b8 06 00 00 00       	mov    $0x6,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret

000004cd <exec>:
SYSCALL(exec)
 4cd:	b8 07 00 00 00       	mov    $0x7,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret

000004d5 <open>:
SYSCALL(open)
 4d5:	b8 0f 00 00 00       	mov    $0xf,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret

000004dd <mknod>:
SYSCALL(mknod)
 4dd:	b8 11 00 00 00       	mov    $0x11,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret

000004e5 <unlink>:
SYSCALL(unlink)
 4e5:	b8 12 00 00 00       	mov    $0x12,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret

000004ed <fstat>:
SYSCALL(fstat)
 4ed:	b8 08 00 00 00       	mov    $0x8,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret

000004f5 <link>:
SYSCALL(link)
 4f5:	b8 13 00 00 00       	mov    $0x13,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret

000004fd <mkdir>:
SYSCALL(mkdir)
 4fd:	b8 14 00 00 00       	mov    $0x14,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret

00000505 <chdir>:
SYSCALL(chdir)
 505:	b8 09 00 00 00       	mov    $0x9,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret

0000050d <dup>:
SYSCALL(dup)
 50d:	b8 0a 00 00 00       	mov    $0xa,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret

00000515 <getpid>:
SYSCALL(getpid)
 515:	b8 0b 00 00 00       	mov    $0xb,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret

0000051d <sbrk>:
SYSCALL(sbrk)
 51d:	b8 0c 00 00 00       	mov    $0xc,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret

00000525 <sleep>:
SYSCALL(sleep)
 525:	b8 0d 00 00 00       	mov    $0xd,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret

0000052d <uptime>:
SYSCALL(uptime)
 52d:	b8 0e 00 00 00       	mov    $0xe,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret

00000535 <uthread_init>:
SYSCALL(uthread_init)
 535:	b8 16 00 00 00       	mov    $0x16,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret

0000053d <getpinfo>:
SYSCALL(getpinfo)
 53d:	b8 17 00 00 00       	mov    $0x17,%eax
 542:	cd 40                	int    $0x40
 544:	c3                   	ret

00000545 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 545:	b8 18 00 00 00       	mov    $0x18,%eax
 54a:	cd 40                	int    $0x40
 54c:	c3                   	ret

0000054d <yield>:
SYSCALL(yield)
 54d:	b8 19 00 00 00       	mov    $0x19,%eax
 552:	cd 40                	int    $0x40
 554:	c3                   	ret

00000555 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 555:	55                   	push   %ebp
 556:	89 e5                	mov    %esp,%ebp
 558:	83 ec 18             	sub    $0x18,%esp
 55b:	8b 45 0c             	mov    0xc(%ebp),%eax
 55e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 561:	83 ec 04             	sub    $0x4,%esp
 564:	6a 01                	push   $0x1
 566:	8d 45 f4             	lea    -0xc(%ebp),%eax
 569:	50                   	push   %eax
 56a:	ff 75 08             	push   0x8(%ebp)
 56d:	e8 43 ff ff ff       	call   4b5 <write>
 572:	83 c4 10             	add    $0x10,%esp
}
 575:	90                   	nop
 576:	c9                   	leave
 577:	c3                   	ret

00000578 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 57e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 585:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 589:	74 17                	je     5a2 <printint+0x2a>
 58b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 58f:	79 11                	jns    5a2 <printint+0x2a>
    neg = 1;
 591:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 598:	8b 45 0c             	mov    0xc(%ebp),%eax
 59b:	f7 d8                	neg    %eax
 59d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5a0:	eb 06                	jmp    5a8 <printint+0x30>
  } else {
    x = xx;
 5a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5af:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b5:	ba 00 00 00 00       	mov    $0x0,%edx
 5ba:	f7 f1                	div    %ecx
 5bc:	89 d1                	mov    %edx,%ecx
 5be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c1:	8d 50 01             	lea    0x1(%eax),%edx
 5c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5c7:	0f b6 91 b8 0c 00 00 	movzbl 0xcb8(%ecx),%edx
 5ce:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d8:	ba 00 00 00 00       	mov    $0x0,%edx
 5dd:	f7 f1                	div    %ecx
 5df:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5e2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e6:	75 c7                	jne    5af <printint+0x37>
  if(neg)
 5e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5ec:	74 2d                	je     61b <printint+0xa3>
    buf[i++] = '-';
 5ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f1:	8d 50 01             	lea    0x1(%eax),%edx
 5f4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5f7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5fc:	eb 1d                	jmp    61b <printint+0xa3>
    putc(fd, buf[i]);
 5fe:	8d 55 dc             	lea    -0x24(%ebp),%edx
 601:	8b 45 f4             	mov    -0xc(%ebp),%eax
 604:	01 d0                	add    %edx,%eax
 606:	0f b6 00             	movzbl (%eax),%eax
 609:	0f be c0             	movsbl %al,%eax
 60c:	83 ec 08             	sub    $0x8,%esp
 60f:	50                   	push   %eax
 610:	ff 75 08             	push   0x8(%ebp)
 613:	e8 3d ff ff ff       	call   555 <putc>
 618:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 61b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 61f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 623:	79 d9                	jns    5fe <printint+0x86>
}
 625:	90                   	nop
 626:	90                   	nop
 627:	c9                   	leave
 628:	c3                   	ret

00000629 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 629:	55                   	push   %ebp
 62a:	89 e5                	mov    %esp,%ebp
 62c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 62f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 636:	8d 45 0c             	lea    0xc(%ebp),%eax
 639:	83 c0 04             	add    $0x4,%eax
 63c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 63f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 646:	e9 59 01 00 00       	jmp    7a4 <printf+0x17b>
    c = fmt[i] & 0xff;
 64b:	8b 55 0c             	mov    0xc(%ebp),%edx
 64e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 651:	01 d0                	add    %edx,%eax
 653:	0f b6 00             	movzbl (%eax),%eax
 656:	0f be c0             	movsbl %al,%eax
 659:	25 ff 00 00 00       	and    $0xff,%eax
 65e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 661:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 665:	75 2c                	jne    693 <printf+0x6a>
      if(c == '%'){
 667:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 66b:	75 0c                	jne    679 <printf+0x50>
        state = '%';
 66d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 674:	e9 27 01 00 00       	jmp    7a0 <printf+0x177>
      } else {
        putc(fd, c);
 679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67c:	0f be c0             	movsbl %al,%eax
 67f:	83 ec 08             	sub    $0x8,%esp
 682:	50                   	push   %eax
 683:	ff 75 08             	push   0x8(%ebp)
 686:	e8 ca fe ff ff       	call   555 <putc>
 68b:	83 c4 10             	add    $0x10,%esp
 68e:	e9 0d 01 00 00       	jmp    7a0 <printf+0x177>
      }
    } else if(state == '%'){
 693:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 697:	0f 85 03 01 00 00    	jne    7a0 <printf+0x177>
      if(c == 'd'){
 69d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6a1:	75 1e                	jne    6c1 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a6:	8b 00                	mov    (%eax),%eax
 6a8:	6a 01                	push   $0x1
 6aa:	6a 0a                	push   $0xa
 6ac:	50                   	push   %eax
 6ad:	ff 75 08             	push   0x8(%ebp)
 6b0:	e8 c3 fe ff ff       	call   578 <printint>
 6b5:	83 c4 10             	add    $0x10,%esp
        ap++;
 6b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6bc:	e9 d8 00 00 00       	jmp    799 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6c1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6c5:	74 06                	je     6cd <printf+0xa4>
 6c7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6cb:	75 1e                	jne    6eb <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	6a 00                	push   $0x0
 6d4:	6a 10                	push   $0x10
 6d6:	50                   	push   %eax
 6d7:	ff 75 08             	push   0x8(%ebp)
 6da:	e8 99 fe ff ff       	call   578 <printint>
 6df:	83 c4 10             	add    $0x10,%esp
        ap++;
 6e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e6:	e9 ae 00 00 00       	jmp    799 <printf+0x170>
      } else if(c == 's'){
 6eb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6ef:	75 43                	jne    734 <printf+0x10b>
        s = (char*)*ap;
 6f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 701:	75 25                	jne    728 <printf+0xff>
          s = "(null)";
 703:	c7 45 f4 3f 0a 00 00 	movl   $0xa3f,-0xc(%ebp)
        while(*s != 0){
 70a:	eb 1c                	jmp    728 <printf+0xff>
          putc(fd, *s);
 70c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70f:	0f b6 00             	movzbl (%eax),%eax
 712:	0f be c0             	movsbl %al,%eax
 715:	83 ec 08             	sub    $0x8,%esp
 718:	50                   	push   %eax
 719:	ff 75 08             	push   0x8(%ebp)
 71c:	e8 34 fe ff ff       	call   555 <putc>
 721:	83 c4 10             	add    $0x10,%esp
          s++;
 724:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 728:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72b:	0f b6 00             	movzbl (%eax),%eax
 72e:	84 c0                	test   %al,%al
 730:	75 da                	jne    70c <printf+0xe3>
 732:	eb 65                	jmp    799 <printf+0x170>
        }
      } else if(c == 'c'){
 734:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 738:	75 1d                	jne    757 <printf+0x12e>
        putc(fd, *ap);
 73a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73d:	8b 00                	mov    (%eax),%eax
 73f:	0f be c0             	movsbl %al,%eax
 742:	83 ec 08             	sub    $0x8,%esp
 745:	50                   	push   %eax
 746:	ff 75 08             	push   0x8(%ebp)
 749:	e8 07 fe ff ff       	call   555 <putc>
 74e:	83 c4 10             	add    $0x10,%esp
        ap++;
 751:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 755:	eb 42                	jmp    799 <printf+0x170>
      } else if(c == '%'){
 757:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 75b:	75 17                	jne    774 <printf+0x14b>
        putc(fd, c);
 75d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 760:	0f be c0             	movsbl %al,%eax
 763:	83 ec 08             	sub    $0x8,%esp
 766:	50                   	push   %eax
 767:	ff 75 08             	push   0x8(%ebp)
 76a:	e8 e6 fd ff ff       	call   555 <putc>
 76f:	83 c4 10             	add    $0x10,%esp
 772:	eb 25                	jmp    799 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 774:	83 ec 08             	sub    $0x8,%esp
 777:	6a 25                	push   $0x25
 779:	ff 75 08             	push   0x8(%ebp)
 77c:	e8 d4 fd ff ff       	call   555 <putc>
 781:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 784:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 787:	0f be c0             	movsbl %al,%eax
 78a:	83 ec 08             	sub    $0x8,%esp
 78d:	50                   	push   %eax
 78e:	ff 75 08             	push   0x8(%ebp)
 791:	e8 bf fd ff ff       	call   555 <putc>
 796:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 799:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7a0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7a4:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7aa:	01 d0                	add    %edx,%eax
 7ac:	0f b6 00             	movzbl (%eax),%eax
 7af:	84 c0                	test   %al,%al
 7b1:	0f 85 94 fe ff ff    	jne    64b <printf+0x22>
    }
  }
}
 7b7:	90                   	nop
 7b8:	90                   	nop
 7b9:	c9                   	leave
 7ba:	c3                   	ret

000007bb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7bb:	55                   	push   %ebp
 7bc:	89 e5                	mov    %esp,%ebp
 7be:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c1:	8b 45 08             	mov    0x8(%ebp),%eax
 7c4:	83 e8 08             	sub    $0x8,%eax
 7c7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ca:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 7cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d2:	eb 24                	jmp    7f8 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d7:	8b 00                	mov    (%eax),%eax
 7d9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7dc:	72 12                	jb     7f0 <free+0x35>
 7de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7e4:	72 24                	jb     80a <free+0x4f>
 7e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e9:	8b 00                	mov    (%eax),%eax
 7eb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7ee:	72 1a                	jb     80a <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7fe:	73 d4                	jae    7d4 <free+0x19>
 800:	8b 45 fc             	mov    -0x4(%ebp),%eax
 803:	8b 00                	mov    (%eax),%eax
 805:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 808:	73 ca                	jae    7d4 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80d:	8b 40 04             	mov    0x4(%eax),%eax
 810:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	01 c2                	add    %eax,%edx
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	39 c2                	cmp    %eax,%edx
 823:	75 24                	jne    849 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 825:	8b 45 f8             	mov    -0x8(%ebp),%eax
 828:	8b 50 04             	mov    0x4(%eax),%edx
 82b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82e:	8b 00                	mov    (%eax),%eax
 830:	8b 40 04             	mov    0x4(%eax),%eax
 833:	01 c2                	add    %eax,%edx
 835:	8b 45 f8             	mov    -0x8(%ebp),%eax
 838:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 83b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83e:	8b 00                	mov    (%eax),%eax
 840:	8b 10                	mov    (%eax),%edx
 842:	8b 45 f8             	mov    -0x8(%ebp),%eax
 845:	89 10                	mov    %edx,(%eax)
 847:	eb 0a                	jmp    853 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 10                	mov    (%eax),%edx
 84e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 851:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	8b 40 04             	mov    0x4(%eax),%eax
 859:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	01 d0                	add    %edx,%eax
 865:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 868:	75 20                	jne    88a <free+0xcf>
    p->s.size += bp->s.size;
 86a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86d:	8b 50 04             	mov    0x4(%eax),%edx
 870:	8b 45 f8             	mov    -0x8(%ebp),%eax
 873:	8b 40 04             	mov    0x4(%eax),%eax
 876:	01 c2                	add    %eax,%edx
 878:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 87e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 881:	8b 10                	mov    (%eax),%edx
 883:	8b 45 fc             	mov    -0x4(%ebp),%eax
 886:	89 10                	mov    %edx,(%eax)
 888:	eb 08                	jmp    892 <free+0xd7>
  } else
    p->s.ptr = bp;
 88a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 890:	89 10                	mov    %edx,(%eax)
  freep = p;
 892:	8b 45 fc             	mov    -0x4(%ebp),%eax
 895:	a3 d4 0c 00 00       	mov    %eax,0xcd4
}
 89a:	90                   	nop
 89b:	c9                   	leave
 89c:	c3                   	ret

0000089d <morecore>:

static Header*
morecore(uint nu)
{
 89d:	55                   	push   %ebp
 89e:	89 e5                	mov    %esp,%ebp
 8a0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8a3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8aa:	77 07                	ja     8b3 <morecore+0x16>
    nu = 4096;
 8ac:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8b3:	8b 45 08             	mov    0x8(%ebp),%eax
 8b6:	c1 e0 03             	shl    $0x3,%eax
 8b9:	83 ec 0c             	sub    $0xc,%esp
 8bc:	50                   	push   %eax
 8bd:	e8 5b fc ff ff       	call   51d <sbrk>
 8c2:	83 c4 10             	add    $0x10,%esp
 8c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8c8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8cc:	75 07                	jne    8d5 <morecore+0x38>
    return 0;
 8ce:	b8 00 00 00 00       	mov    $0x0,%eax
 8d3:	eb 26                	jmp    8fb <morecore+0x5e>
  hp = (Header*)p;
 8d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8db:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8de:	8b 55 08             	mov    0x8(%ebp),%edx
 8e1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e7:	83 c0 08             	add    $0x8,%eax
 8ea:	83 ec 0c             	sub    $0xc,%esp
 8ed:	50                   	push   %eax
 8ee:	e8 c8 fe ff ff       	call   7bb <free>
 8f3:	83 c4 10             	add    $0x10,%esp
  return freep;
 8f6:	a1 d4 0c 00 00       	mov    0xcd4,%eax
}
 8fb:	c9                   	leave
 8fc:	c3                   	ret

000008fd <malloc>:

void*
malloc(uint nbytes)
{
 8fd:	55                   	push   %ebp
 8fe:	89 e5                	mov    %esp,%ebp
 900:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 903:	8b 45 08             	mov    0x8(%ebp),%eax
 906:	83 c0 07             	add    $0x7,%eax
 909:	c1 e8 03             	shr    $0x3,%eax
 90c:	83 c0 01             	add    $0x1,%eax
 90f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 912:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 917:	89 45 f0             	mov    %eax,-0x10(%ebp)
 91a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 91e:	75 23                	jne    943 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 920:	c7 45 f0 cc 0c 00 00 	movl   $0xccc,-0x10(%ebp)
 927:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92a:	a3 d4 0c 00 00       	mov    %eax,0xcd4
 92f:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 934:	a3 cc 0c 00 00       	mov    %eax,0xccc
    base.s.size = 0;
 939:	c7 05 d0 0c 00 00 00 	movl   $0x0,0xcd0
 940:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 943:	8b 45 f0             	mov    -0x10(%ebp),%eax
 946:	8b 00                	mov    (%eax),%eax
 948:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94e:	8b 40 04             	mov    0x4(%eax),%eax
 951:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 954:	72 4d                	jb     9a3 <malloc+0xa6>
      if(p->s.size == nunits)
 956:	8b 45 f4             	mov    -0xc(%ebp),%eax
 959:	8b 40 04             	mov    0x4(%eax),%eax
 95c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 95f:	75 0c                	jne    96d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	8b 10                	mov    (%eax),%edx
 966:	8b 45 f0             	mov    -0x10(%ebp),%eax
 969:	89 10                	mov    %edx,(%eax)
 96b:	eb 26                	jmp    993 <malloc+0x96>
      else {
        p->s.size -= nunits;
 96d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 970:	8b 40 04             	mov    0x4(%eax),%eax
 973:	2b 45 ec             	sub    -0x14(%ebp),%eax
 976:	89 c2                	mov    %eax,%edx
 978:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 97e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 981:	8b 40 04             	mov    0x4(%eax),%eax
 984:	c1 e0 03             	shl    $0x3,%eax
 987:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 98a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 990:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 993:	8b 45 f0             	mov    -0x10(%ebp),%eax
 996:	a3 d4 0c 00 00       	mov    %eax,0xcd4
      return (void*)(p + 1);
 99b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99e:	83 c0 08             	add    $0x8,%eax
 9a1:	eb 3b                	jmp    9de <malloc+0xe1>
    }
    if(p == freep)
 9a3:	a1 d4 0c 00 00       	mov    0xcd4,%eax
 9a8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9ab:	75 1e                	jne    9cb <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9ad:	83 ec 0c             	sub    $0xc,%esp
 9b0:	ff 75 ec             	push   -0x14(%ebp)
 9b3:	e8 e5 fe ff ff       	call   89d <morecore>
 9b8:	83 c4 10             	add    $0x10,%esp
 9bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9c2:	75 07                	jne    9cb <malloc+0xce>
        return 0;
 9c4:	b8 00 00 00 00       	mov    $0x0,%eax
 9c9:	eb 13                	jmp    9de <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	8b 00                	mov    (%eax),%eax
 9d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9d9:	e9 6d ff ff ff       	jmp    94b <malloc+0x4e>
  }
}
 9de:	c9                   	leave
 9df:	c3                   	ret
