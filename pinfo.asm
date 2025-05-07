
_pinfo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "pstat.h"

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	81 ec 14 0c 00 00    	sub    $0xc14,%esp
  // 스케줄링 정책을 MLFQ (1번)으로 설정
  if (setSchedPolicy(1) < 0) {
  14:	83 ec 0c             	sub    $0xc,%esp
  17:	6a 01                	push   $0x1
  19:	e8 1c 04 00 00       	call   43a <setSchedPolicy>
  1e:	83 c4 10             	add    $0x10,%esp
  21:	85 c0                	test   %eax,%eax
  23:	79 17                	jns    3c <main+0x3c>
    printf(1, "setSchedPolicy() failed\n");
  25:	83 ec 08             	sub    $0x8,%esp
  28:	68 d0 08 00 00       	push   $0x8d0
  2d:	6a 01                	push   $0x1
  2f:	e8 e2 04 00 00       	call   516 <printf>
  34:	83 c4 10             	add    $0x10,%esp
    exit();
  37:	e8 4e 03 00 00       	call   38a <exit>
  }

  printf(1, "Scheduling policy set to MLFQ (1)\n");
  3c:	83 ec 08             	sub    $0x8,%esp
  3f:	68 ec 08 00 00       	push   $0x8ec
  44:	6a 01                	push   $0x1
  46:	e8 cb 04 00 00       	call   516 <printf>
  4b:	83 c4 10             	add    $0x10,%esp

  struct pstat st;

  // 시스템 콜로 프로세스 상태 정보 가져오기
  if (getpinfo(&st) < 0) {
  4e:	83 ec 0c             	sub    $0xc,%esp
  51:	8d 85 ec f3 ff ff    	lea    -0xc14(%ebp),%eax
  57:	50                   	push   %eax
  58:	e8 d5 03 00 00       	call   432 <getpinfo>
  5d:	83 c4 10             	add    $0x10,%esp
  60:	85 c0                	test   %eax,%eax
  62:	79 17                	jns    7b <main+0x7b>
    printf(1, "getpinfo() failed\n");
  64:	83 ec 08             	sub    $0x8,%esp
  67:	68 0f 09 00 00       	push   $0x90f
  6c:	6a 01                	push   $0x1
  6e:	e8 a3 04 00 00       	call   516 <printf>
  73:	83 c4 10             	add    $0x10,%esp
    exit();
  76:	e8 0f 03 00 00       	call   38a <exit>
  }

  // 프로세스 정보 출력
  printf(1, "PID\tPRIO\tSTATE\tTICKS\n");
  7b:	83 ec 08             	sub    $0x8,%esp
  7e:	68 22 09 00 00       	push   $0x922
  83:	6a 01                	push   $0x1
  85:	e8 8c 04 00 00       	call   516 <printf>
  8a:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  94:	e9 8b 00 00 00       	jmp    124 <main+0x124>
    if (st.inuse[i]) {
  99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  9c:	8b 84 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%eax
  a3:	85 c0                	test   %eax,%eax
  a5:	74 79                	je     120 <main+0x120>
      int total_ticks = 0;
  a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      for (int j = 0; j < 4; j++)
  ae:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  b5:	eb 22                	jmp    d9 <main+0xd9>
        total_ticks += st.ticks[i][j];
  b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  c4:	01 d0                	add    %edx,%eax
  c6:	05 00 01 00 00       	add    $0x100,%eax
  cb:	8b 84 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%eax
  d2:	01 45 f0             	add    %eax,-0x10(%ebp)
      for (int j = 0; j < 4; j++)
  d5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  d9:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
  dd:	7e d8                	jle    b7 <main+0xb7>

      printf(1, "%d\t%d\t%d\t%d\n",
  df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  e2:	05 c0 00 00 00       	add    $0xc0,%eax
  e7:	8b 8c 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%ecx
  ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f1:	83 e8 80             	sub    $0xffffff80,%eax
  f4:	8b 94 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%edx
  fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fe:	83 c0 40             	add    $0x40,%eax
 101:	8b 84 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%eax
 108:	83 ec 08             	sub    $0x8,%esp
 10b:	ff 75 f0             	push   -0x10(%ebp)
 10e:	51                   	push   %ecx
 10f:	52                   	push   %edx
 110:	50                   	push   %eax
 111:	68 38 09 00 00       	push   $0x938
 116:	6a 01                	push   $0x1
 118:	e8 f9 03 00 00       	call   516 <printf>
 11d:	83 c4 20             	add    $0x20,%esp
  for (int i = 0; i < NPROC; i++) {
 120:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 124:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 128:	0f 8e 6b ff ff ff    	jle    99 <main+0x99>
             st.state[i],
             total_ticks);
    }
  }

  exit();
 12e:	e8 57 02 00 00       	call   38a <exit>

00000133 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 133:	55                   	push   %ebp
 134:	89 e5                	mov    %esp,%ebp
 136:	57                   	push   %edi
 137:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 138:	8b 4d 08             	mov    0x8(%ebp),%ecx
 13b:	8b 55 10             	mov    0x10(%ebp),%edx
 13e:	8b 45 0c             	mov    0xc(%ebp),%eax
 141:	89 cb                	mov    %ecx,%ebx
 143:	89 df                	mov    %ebx,%edi
 145:	89 d1                	mov    %edx,%ecx
 147:	fc                   	cld
 148:	f3 aa                	rep stos %al,%es:(%edi)
 14a:	89 ca                	mov    %ecx,%edx
 14c:	89 fb                	mov    %edi,%ebx
 14e:	89 5d 08             	mov    %ebx,0x8(%ebp)
 151:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 154:	90                   	nop
 155:	5b                   	pop    %ebx
 156:	5f                   	pop    %edi
 157:	5d                   	pop    %ebp
 158:	c3                   	ret

00000159 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 159:	55                   	push   %ebp
 15a:	89 e5                	mov    %esp,%ebp
 15c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
 162:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 165:	90                   	nop
 166:	8b 55 0c             	mov    0xc(%ebp),%edx
 169:	8d 42 01             	lea    0x1(%edx),%eax
 16c:	89 45 0c             	mov    %eax,0xc(%ebp)
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	8d 48 01             	lea    0x1(%eax),%ecx
 175:	89 4d 08             	mov    %ecx,0x8(%ebp)
 178:	0f b6 12             	movzbl (%edx),%edx
 17b:	88 10                	mov    %dl,(%eax)
 17d:	0f b6 00             	movzbl (%eax),%eax
 180:	84 c0                	test   %al,%al
 182:	75 e2                	jne    166 <strcpy+0xd>
    ;
  return os;
 184:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 187:	c9                   	leave
 188:	c3                   	ret

00000189 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 18c:	eb 08                	jmp    196 <strcmp+0xd>
    p++, q++;
 18e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 192:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 196:	8b 45 08             	mov    0x8(%ebp),%eax
 199:	0f b6 00             	movzbl (%eax),%eax
 19c:	84 c0                	test   %al,%al
 19e:	74 10                	je     1b0 <strcmp+0x27>
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	0f b6 10             	movzbl (%eax),%edx
 1a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a9:	0f b6 00             	movzbl (%eax),%eax
 1ac:	38 c2                	cmp    %al,%dl
 1ae:	74 de                	je     18e <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1b0:	8b 45 08             	mov    0x8(%ebp),%eax
 1b3:	0f b6 00             	movzbl (%eax),%eax
 1b6:	0f b6 d0             	movzbl %al,%edx
 1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bc:	0f b6 00             	movzbl (%eax),%eax
 1bf:	0f b6 c0             	movzbl %al,%eax
 1c2:	29 c2                	sub    %eax,%edx
 1c4:	89 d0                	mov    %edx,%eax
}
 1c6:	5d                   	pop    %ebp
 1c7:	c3                   	ret

000001c8 <strlen>:

uint
strlen(char *s)
{
 1c8:	55                   	push   %ebp
 1c9:	89 e5                	mov    %esp,%ebp
 1cb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1d5:	eb 04                	jmp    1db <strlen+0x13>
 1d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1db:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	01 d0                	add    %edx,%eax
 1e3:	0f b6 00             	movzbl (%eax),%eax
 1e6:	84 c0                	test   %al,%al
 1e8:	75 ed                	jne    1d7 <strlen+0xf>
    ;
  return n;
 1ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ed:	c9                   	leave
 1ee:	c3                   	ret

000001ef <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ef:	55                   	push   %ebp
 1f0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1f2:	8b 45 10             	mov    0x10(%ebp),%eax
 1f5:	50                   	push   %eax
 1f6:	ff 75 0c             	push   0xc(%ebp)
 1f9:	ff 75 08             	push   0x8(%ebp)
 1fc:	e8 32 ff ff ff       	call   133 <stosb>
 201:	83 c4 0c             	add    $0xc,%esp
  return dst;
 204:	8b 45 08             	mov    0x8(%ebp),%eax
}
 207:	c9                   	leave
 208:	c3                   	ret

00000209 <strchr>:

char*
strchr(const char *s, char c)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
 20c:	83 ec 04             	sub    $0x4,%esp
 20f:	8b 45 0c             	mov    0xc(%ebp),%eax
 212:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 215:	eb 14                	jmp    22b <strchr+0x22>
    if(*s == c)
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	0f b6 00             	movzbl (%eax),%eax
 21d:	38 45 fc             	cmp    %al,-0x4(%ebp)
 220:	75 05                	jne    227 <strchr+0x1e>
      return (char*)s;
 222:	8b 45 08             	mov    0x8(%ebp),%eax
 225:	eb 13                	jmp    23a <strchr+0x31>
  for(; *s; s++)
 227:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
 22e:	0f b6 00             	movzbl (%eax),%eax
 231:	84 c0                	test   %al,%al
 233:	75 e2                	jne    217 <strchr+0xe>
  return 0;
 235:	b8 00 00 00 00       	mov    $0x0,%eax
}
 23a:	c9                   	leave
 23b:	c3                   	ret

0000023c <gets>:

char*
gets(char *buf, int max)
{
 23c:	55                   	push   %ebp
 23d:	89 e5                	mov    %esp,%ebp
 23f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 242:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 249:	eb 42                	jmp    28d <gets+0x51>
    cc = read(0, &c, 1);
 24b:	83 ec 04             	sub    $0x4,%esp
 24e:	6a 01                	push   $0x1
 250:	8d 45 ef             	lea    -0x11(%ebp),%eax
 253:	50                   	push   %eax
 254:	6a 00                	push   $0x0
 256:	e8 47 01 00 00       	call   3a2 <read>
 25b:	83 c4 10             	add    $0x10,%esp
 25e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 261:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 265:	7e 33                	jle    29a <gets+0x5e>
      break;
    buf[i++] = c;
 267:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26a:	8d 50 01             	lea    0x1(%eax),%edx
 26d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 270:	89 c2                	mov    %eax,%edx
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	01 c2                	add    %eax,%edx
 277:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 27d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 281:	3c 0a                	cmp    $0xa,%al
 283:	74 16                	je     29b <gets+0x5f>
 285:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 289:	3c 0d                	cmp    $0xd,%al
 28b:	74 0e                	je     29b <gets+0x5f>
  for(i=0; i+1 < max; ){
 28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 290:	83 c0 01             	add    $0x1,%eax
 293:	39 45 0c             	cmp    %eax,0xc(%ebp)
 296:	7f b3                	jg     24b <gets+0xf>
 298:	eb 01                	jmp    29b <gets+0x5f>
      break;
 29a:	90                   	nop
      break;
  }
  buf[i] = '\0';
 29b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	01 d0                	add    %edx,%eax
 2a3:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a9:	c9                   	leave
 2aa:	c3                   	ret

000002ab <stat>:

int
stat(char *n, struct stat *st)
{
 2ab:	55                   	push   %ebp
 2ac:	89 e5                	mov    %esp,%ebp
 2ae:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b1:	83 ec 08             	sub    $0x8,%esp
 2b4:	6a 00                	push   $0x0
 2b6:	ff 75 08             	push   0x8(%ebp)
 2b9:	e8 0c 01 00 00       	call   3ca <open>
 2be:	83 c4 10             	add    $0x10,%esp
 2c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c8:	79 07                	jns    2d1 <stat+0x26>
    return -1;
 2ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cf:	eb 25                	jmp    2f6 <stat+0x4b>
  r = fstat(fd, st);
 2d1:	83 ec 08             	sub    $0x8,%esp
 2d4:	ff 75 0c             	push   0xc(%ebp)
 2d7:	ff 75 f4             	push   -0xc(%ebp)
 2da:	e8 03 01 00 00       	call   3e2 <fstat>
 2df:	83 c4 10             	add    $0x10,%esp
 2e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e5:	83 ec 0c             	sub    $0xc,%esp
 2e8:	ff 75 f4             	push   -0xc(%ebp)
 2eb:	e8 c2 00 00 00       	call   3b2 <close>
 2f0:	83 c4 10             	add    $0x10,%esp
  return r;
 2f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f6:	c9                   	leave
 2f7:	c3                   	ret

000002f8 <atoi>:

int
atoi(const char *s)
{
 2f8:	55                   	push   %ebp
 2f9:	89 e5                	mov    %esp,%ebp
 2fb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 305:	eb 25                	jmp    32c <atoi+0x34>
    n = n*10 + *s++ - '0';
 307:	8b 55 fc             	mov    -0x4(%ebp),%edx
 30a:	89 d0                	mov    %edx,%eax
 30c:	c1 e0 02             	shl    $0x2,%eax
 30f:	01 d0                	add    %edx,%eax
 311:	01 c0                	add    %eax,%eax
 313:	89 c1                	mov    %eax,%ecx
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	8d 50 01             	lea    0x1(%eax),%edx
 31b:	89 55 08             	mov    %edx,0x8(%ebp)
 31e:	0f b6 00             	movzbl (%eax),%eax
 321:	0f be c0             	movsbl %al,%eax
 324:	01 c8                	add    %ecx,%eax
 326:	83 e8 30             	sub    $0x30,%eax
 329:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	0f b6 00             	movzbl (%eax),%eax
 332:	3c 2f                	cmp    $0x2f,%al
 334:	7e 0a                	jle    340 <atoi+0x48>
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	3c 39                	cmp    $0x39,%al
 33e:	7e c7                	jle    307 <atoi+0xf>
  return n;
 340:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 343:	c9                   	leave
 344:	c3                   	ret

00000345 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 345:	55                   	push   %ebp
 346:	89 e5                	mov    %esp,%ebp
 348:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 351:	8b 45 0c             	mov    0xc(%ebp),%eax
 354:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 357:	eb 17                	jmp    370 <memmove+0x2b>
    *dst++ = *src++;
 359:	8b 55 f8             	mov    -0x8(%ebp),%edx
 35c:	8d 42 01             	lea    0x1(%edx),%eax
 35f:	89 45 f8             	mov    %eax,-0x8(%ebp)
 362:	8b 45 fc             	mov    -0x4(%ebp),%eax
 365:	8d 48 01             	lea    0x1(%eax),%ecx
 368:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 36b:	0f b6 12             	movzbl (%edx),%edx
 36e:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 370:	8b 45 10             	mov    0x10(%ebp),%eax
 373:	8d 50 ff             	lea    -0x1(%eax),%edx
 376:	89 55 10             	mov    %edx,0x10(%ebp)
 379:	85 c0                	test   %eax,%eax
 37b:	7f dc                	jg     359 <memmove+0x14>
  return vdst;
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 380:	c9                   	leave
 381:	c3                   	ret

00000382 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 382:	b8 01 00 00 00       	mov    $0x1,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret

0000038a <exit>:
SYSCALL(exit)
 38a:	b8 02 00 00 00       	mov    $0x2,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret

00000392 <wait>:
SYSCALL(wait)
 392:	b8 03 00 00 00       	mov    $0x3,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret

0000039a <pipe>:
SYSCALL(pipe)
 39a:	b8 04 00 00 00       	mov    $0x4,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret

000003a2 <read>:
SYSCALL(read)
 3a2:	b8 05 00 00 00       	mov    $0x5,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret

000003aa <write>:
SYSCALL(write)
 3aa:	b8 10 00 00 00       	mov    $0x10,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret

000003b2 <close>:
SYSCALL(close)
 3b2:	b8 15 00 00 00       	mov    $0x15,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret

000003ba <kill>:
SYSCALL(kill)
 3ba:	b8 06 00 00 00       	mov    $0x6,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret

000003c2 <exec>:
SYSCALL(exec)
 3c2:	b8 07 00 00 00       	mov    $0x7,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret

000003ca <open>:
SYSCALL(open)
 3ca:	b8 0f 00 00 00       	mov    $0xf,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret

000003d2 <mknod>:
SYSCALL(mknod)
 3d2:	b8 11 00 00 00       	mov    $0x11,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret

000003da <unlink>:
SYSCALL(unlink)
 3da:	b8 12 00 00 00       	mov    $0x12,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret

000003e2 <fstat>:
SYSCALL(fstat)
 3e2:	b8 08 00 00 00       	mov    $0x8,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret

000003ea <link>:
SYSCALL(link)
 3ea:	b8 13 00 00 00       	mov    $0x13,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret

000003f2 <mkdir>:
SYSCALL(mkdir)
 3f2:	b8 14 00 00 00       	mov    $0x14,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret

000003fa <chdir>:
SYSCALL(chdir)
 3fa:	b8 09 00 00 00       	mov    $0x9,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret

00000402 <dup>:
SYSCALL(dup)
 402:	b8 0a 00 00 00       	mov    $0xa,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret

0000040a <getpid>:
SYSCALL(getpid)
 40a:	b8 0b 00 00 00       	mov    $0xb,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret

00000412 <sbrk>:
SYSCALL(sbrk)
 412:	b8 0c 00 00 00       	mov    $0xc,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret

0000041a <sleep>:
SYSCALL(sleep)
 41a:	b8 0d 00 00 00       	mov    $0xd,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret

00000422 <uptime>:
SYSCALL(uptime)
 422:	b8 0e 00 00 00       	mov    $0xe,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret

0000042a <uthread_init>:
SYSCALL(uthread_init)
 42a:	b8 16 00 00 00       	mov    $0x16,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret

00000432 <getpinfo>:
SYSCALL(getpinfo)
 432:	b8 17 00 00 00       	mov    $0x17,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret

0000043a <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 43a:	b8 18 00 00 00       	mov    $0x18,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret

00000442 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 442:	55                   	push   %ebp
 443:	89 e5                	mov    %esp,%ebp
 445:	83 ec 18             	sub    $0x18,%esp
 448:	8b 45 0c             	mov    0xc(%ebp),%eax
 44b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 44e:	83 ec 04             	sub    $0x4,%esp
 451:	6a 01                	push   $0x1
 453:	8d 45 f4             	lea    -0xc(%ebp),%eax
 456:	50                   	push   %eax
 457:	ff 75 08             	push   0x8(%ebp)
 45a:	e8 4b ff ff ff       	call   3aa <write>
 45f:	83 c4 10             	add    $0x10,%esp
}
 462:	90                   	nop
 463:	c9                   	leave
 464:	c3                   	ret

00000465 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 465:	55                   	push   %ebp
 466:	89 e5                	mov    %esp,%ebp
 468:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 46b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 472:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 476:	74 17                	je     48f <printint+0x2a>
 478:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 47c:	79 11                	jns    48f <printint+0x2a>
    neg = 1;
 47e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 485:	8b 45 0c             	mov    0xc(%ebp),%eax
 488:	f7 d8                	neg    %eax
 48a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 48d:	eb 06                	jmp    495 <printint+0x30>
  } else {
    x = xx;
 48f:	8b 45 0c             	mov    0xc(%ebp),%eax
 492:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 495:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 49c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 49f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a2:	ba 00 00 00 00       	mov    $0x0,%edx
 4a7:	f7 f1                	div    %ecx
 4a9:	89 d1                	mov    %edx,%ecx
 4ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ae:	8d 50 01             	lea    0x1(%eax),%edx
 4b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4b4:	0f b6 91 90 0b 00 00 	movzbl 0xb90(%ecx),%edx
 4bb:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ca:	f7 f1                	div    %ecx
 4cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4d3:	75 c7                	jne    49c <printint+0x37>
  if(neg)
 4d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4d9:	74 2d                	je     508 <printint+0xa3>
    buf[i++] = '-';
 4db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4de:	8d 50 01             	lea    0x1(%eax),%edx
 4e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4e4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4e9:	eb 1d                	jmp    508 <printint+0xa3>
    putc(fd, buf[i]);
 4eb:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f1:	01 d0                	add    %edx,%eax
 4f3:	0f b6 00             	movzbl (%eax),%eax
 4f6:	0f be c0             	movsbl %al,%eax
 4f9:	83 ec 08             	sub    $0x8,%esp
 4fc:	50                   	push   %eax
 4fd:	ff 75 08             	push   0x8(%ebp)
 500:	e8 3d ff ff ff       	call   442 <putc>
 505:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 508:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 50c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 510:	79 d9                	jns    4eb <printint+0x86>
}
 512:	90                   	nop
 513:	90                   	nop
 514:	c9                   	leave
 515:	c3                   	ret

00000516 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 516:	55                   	push   %ebp
 517:	89 e5                	mov    %esp,%ebp
 519:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 51c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 523:	8d 45 0c             	lea    0xc(%ebp),%eax
 526:	83 c0 04             	add    $0x4,%eax
 529:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 52c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 533:	e9 59 01 00 00       	jmp    691 <printf+0x17b>
    c = fmt[i] & 0xff;
 538:	8b 55 0c             	mov    0xc(%ebp),%edx
 53b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 53e:	01 d0                	add    %edx,%eax
 540:	0f b6 00             	movzbl (%eax),%eax
 543:	0f be c0             	movsbl %al,%eax
 546:	25 ff 00 00 00       	and    $0xff,%eax
 54b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 54e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 552:	75 2c                	jne    580 <printf+0x6a>
      if(c == '%'){
 554:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 558:	75 0c                	jne    566 <printf+0x50>
        state = '%';
 55a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 561:	e9 27 01 00 00       	jmp    68d <printf+0x177>
      } else {
        putc(fd, c);
 566:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 569:	0f be c0             	movsbl %al,%eax
 56c:	83 ec 08             	sub    $0x8,%esp
 56f:	50                   	push   %eax
 570:	ff 75 08             	push   0x8(%ebp)
 573:	e8 ca fe ff ff       	call   442 <putc>
 578:	83 c4 10             	add    $0x10,%esp
 57b:	e9 0d 01 00 00       	jmp    68d <printf+0x177>
      }
    } else if(state == '%'){
 580:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 584:	0f 85 03 01 00 00    	jne    68d <printf+0x177>
      if(c == 'd'){
 58a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 58e:	75 1e                	jne    5ae <printf+0x98>
        printint(fd, *ap, 10, 1);
 590:	8b 45 e8             	mov    -0x18(%ebp),%eax
 593:	8b 00                	mov    (%eax),%eax
 595:	6a 01                	push   $0x1
 597:	6a 0a                	push   $0xa
 599:	50                   	push   %eax
 59a:	ff 75 08             	push   0x8(%ebp)
 59d:	e8 c3 fe ff ff       	call   465 <printint>
 5a2:	83 c4 10             	add    $0x10,%esp
        ap++;
 5a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a9:	e9 d8 00 00 00       	jmp    686 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b2:	74 06                	je     5ba <printf+0xa4>
 5b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b8:	75 1e                	jne    5d8 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bd:	8b 00                	mov    (%eax),%eax
 5bf:	6a 00                	push   $0x0
 5c1:	6a 10                	push   $0x10
 5c3:	50                   	push   %eax
 5c4:	ff 75 08             	push   0x8(%ebp)
 5c7:	e8 99 fe ff ff       	call   465 <printint>
 5cc:	83 c4 10             	add    $0x10,%esp
        ap++;
 5cf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d3:	e9 ae 00 00 00       	jmp    686 <printf+0x170>
      } else if(c == 's'){
 5d8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5dc:	75 43                	jne    621 <printf+0x10b>
        s = (char*)*ap;
 5de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e1:	8b 00                	mov    (%eax),%eax
 5e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ee:	75 25                	jne    615 <printf+0xff>
          s = "(null)";
 5f0:	c7 45 f4 45 09 00 00 	movl   $0x945,-0xc(%ebp)
        while(*s != 0){
 5f7:	eb 1c                	jmp    615 <printf+0xff>
          putc(fd, *s);
 5f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fc:	0f b6 00             	movzbl (%eax),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	83 ec 08             	sub    $0x8,%esp
 605:	50                   	push   %eax
 606:	ff 75 08             	push   0x8(%ebp)
 609:	e8 34 fe ff ff       	call   442 <putc>
 60e:	83 c4 10             	add    $0x10,%esp
          s++;
 611:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 615:	8b 45 f4             	mov    -0xc(%ebp),%eax
 618:	0f b6 00             	movzbl (%eax),%eax
 61b:	84 c0                	test   %al,%al
 61d:	75 da                	jne    5f9 <printf+0xe3>
 61f:	eb 65                	jmp    686 <printf+0x170>
        }
      } else if(c == 'c'){
 621:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 625:	75 1d                	jne    644 <printf+0x12e>
        putc(fd, *ap);
 627:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62a:	8b 00                	mov    (%eax),%eax
 62c:	0f be c0             	movsbl %al,%eax
 62f:	83 ec 08             	sub    $0x8,%esp
 632:	50                   	push   %eax
 633:	ff 75 08             	push   0x8(%ebp)
 636:	e8 07 fe ff ff       	call   442 <putc>
 63b:	83 c4 10             	add    $0x10,%esp
        ap++;
 63e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 642:	eb 42                	jmp    686 <printf+0x170>
      } else if(c == '%'){
 644:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 648:	75 17                	jne    661 <printf+0x14b>
        putc(fd, c);
 64a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64d:	0f be c0             	movsbl %al,%eax
 650:	83 ec 08             	sub    $0x8,%esp
 653:	50                   	push   %eax
 654:	ff 75 08             	push   0x8(%ebp)
 657:	e8 e6 fd ff ff       	call   442 <putc>
 65c:	83 c4 10             	add    $0x10,%esp
 65f:	eb 25                	jmp    686 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 661:	83 ec 08             	sub    $0x8,%esp
 664:	6a 25                	push   $0x25
 666:	ff 75 08             	push   0x8(%ebp)
 669:	e8 d4 fd ff ff       	call   442 <putc>
 66e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 674:	0f be c0             	movsbl %al,%eax
 677:	83 ec 08             	sub    $0x8,%esp
 67a:	50                   	push   %eax
 67b:	ff 75 08             	push   0x8(%ebp)
 67e:	e8 bf fd ff ff       	call   442 <putc>
 683:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 686:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 68d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 691:	8b 55 0c             	mov    0xc(%ebp),%edx
 694:	8b 45 f0             	mov    -0x10(%ebp),%eax
 697:	01 d0                	add    %edx,%eax
 699:	0f b6 00             	movzbl (%eax),%eax
 69c:	84 c0                	test   %al,%al
 69e:	0f 85 94 fe ff ff    	jne    538 <printf+0x22>
    }
  }
}
 6a4:	90                   	nop
 6a5:	90                   	nop
 6a6:	c9                   	leave
 6a7:	c3                   	ret

000006a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a8:	55                   	push   %ebp
 6a9:	89 e5                	mov    %esp,%ebp
 6ab:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ae:	8b 45 08             	mov    0x8(%ebp),%eax
 6b1:	83 e8 08             	sub    $0x8,%eax
 6b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b7:	a1 ac 0b 00 00       	mov    0xbac,%eax
 6bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bf:	eb 24                	jmp    6e5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6c9:	72 12                	jb     6dd <free+0x35>
 6cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ce:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6d1:	72 24                	jb     6f7 <free+0x4f>
 6d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d6:	8b 00                	mov    (%eax),%eax
 6d8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6db:	72 1a                	jb     6f7 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6eb:	73 d4                	jae    6c1 <free+0x19>
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6f5:	73 ca                	jae    6c1 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fa:	8b 40 04             	mov    0x4(%eax),%eax
 6fd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 704:	8b 45 f8             	mov    -0x8(%ebp),%eax
 707:	01 c2                	add    %eax,%edx
 709:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70c:	8b 00                	mov    (%eax),%eax
 70e:	39 c2                	cmp    %eax,%edx
 710:	75 24                	jne    736 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 712:	8b 45 f8             	mov    -0x8(%ebp),%eax
 715:	8b 50 04             	mov    0x4(%eax),%edx
 718:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71b:	8b 00                	mov    (%eax),%eax
 71d:	8b 40 04             	mov    0x4(%eax),%eax
 720:	01 c2                	add    %eax,%edx
 722:	8b 45 f8             	mov    -0x8(%ebp),%eax
 725:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 728:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72b:	8b 00                	mov    (%eax),%eax
 72d:	8b 10                	mov    (%eax),%edx
 72f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 732:	89 10                	mov    %edx,(%eax)
 734:	eb 0a                	jmp    740 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 736:	8b 45 fc             	mov    -0x4(%ebp),%eax
 739:	8b 10                	mov    (%eax),%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 40 04             	mov    0x4(%eax),%eax
 746:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	01 d0                	add    %edx,%eax
 752:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 755:	75 20                	jne    777 <free+0xcf>
    p->s.size += bp->s.size;
 757:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75a:	8b 50 04             	mov    0x4(%eax),%edx
 75d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 760:	8b 40 04             	mov    0x4(%eax),%eax
 763:	01 c2                	add    %eax,%edx
 765:	8b 45 fc             	mov    -0x4(%ebp),%eax
 768:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 76b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76e:	8b 10                	mov    (%eax),%edx
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	89 10                	mov    %edx,(%eax)
 775:	eb 08                	jmp    77f <free+0xd7>
  } else
    p->s.ptr = bp;
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 77d:	89 10                	mov    %edx,(%eax)
  freep = p;
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	a3 ac 0b 00 00       	mov    %eax,0xbac
}
 787:	90                   	nop
 788:	c9                   	leave
 789:	c3                   	ret

0000078a <morecore>:

static Header*
morecore(uint nu)
{
 78a:	55                   	push   %ebp
 78b:	89 e5                	mov    %esp,%ebp
 78d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 790:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 797:	77 07                	ja     7a0 <morecore+0x16>
    nu = 4096;
 799:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7a0:	8b 45 08             	mov    0x8(%ebp),%eax
 7a3:	c1 e0 03             	shl    $0x3,%eax
 7a6:	83 ec 0c             	sub    $0xc,%esp
 7a9:	50                   	push   %eax
 7aa:	e8 63 fc ff ff       	call   412 <sbrk>
 7af:	83 c4 10             	add    $0x10,%esp
 7b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7b5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b9:	75 07                	jne    7c2 <morecore+0x38>
    return 0;
 7bb:	b8 00 00 00 00       	mov    $0x0,%eax
 7c0:	eb 26                	jmp    7e8 <morecore+0x5e>
  hp = (Header*)p;
 7c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cb:	8b 55 08             	mov    0x8(%ebp),%edx
 7ce:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	83 c0 08             	add    $0x8,%eax
 7d7:	83 ec 0c             	sub    $0xc,%esp
 7da:	50                   	push   %eax
 7db:	e8 c8 fe ff ff       	call   6a8 <free>
 7e0:	83 c4 10             	add    $0x10,%esp
  return freep;
 7e3:	a1 ac 0b 00 00       	mov    0xbac,%eax
}
 7e8:	c9                   	leave
 7e9:	c3                   	ret

000007ea <malloc>:

void*
malloc(uint nbytes)
{
 7ea:	55                   	push   %ebp
 7eb:	89 e5                	mov    %esp,%ebp
 7ed:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f0:	8b 45 08             	mov    0x8(%ebp),%eax
 7f3:	83 c0 07             	add    $0x7,%eax
 7f6:	c1 e8 03             	shr    $0x3,%eax
 7f9:	83 c0 01             	add    $0x1,%eax
 7fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ff:	a1 ac 0b 00 00       	mov    0xbac,%eax
 804:	89 45 f0             	mov    %eax,-0x10(%ebp)
 807:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 80b:	75 23                	jne    830 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 80d:	c7 45 f0 a4 0b 00 00 	movl   $0xba4,-0x10(%ebp)
 814:	8b 45 f0             	mov    -0x10(%ebp),%eax
 817:	a3 ac 0b 00 00       	mov    %eax,0xbac
 81c:	a1 ac 0b 00 00       	mov    0xbac,%eax
 821:	a3 a4 0b 00 00       	mov    %eax,0xba4
    base.s.size = 0;
 826:	c7 05 a8 0b 00 00 00 	movl   $0x0,0xba8
 82d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 830:	8b 45 f0             	mov    -0x10(%ebp),%eax
 833:	8b 00                	mov    (%eax),%eax
 835:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	8b 40 04             	mov    0x4(%eax),%eax
 83e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 841:	72 4d                	jb     890 <malloc+0xa6>
      if(p->s.size == nunits)
 843:	8b 45 f4             	mov    -0xc(%ebp),%eax
 846:	8b 40 04             	mov    0x4(%eax),%eax
 849:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 84c:	75 0c                	jne    85a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 84e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 851:	8b 10                	mov    (%eax),%edx
 853:	8b 45 f0             	mov    -0x10(%ebp),%eax
 856:	89 10                	mov    %edx,(%eax)
 858:	eb 26                	jmp    880 <malloc+0x96>
      else {
        p->s.size -= nunits;
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	8b 40 04             	mov    0x4(%eax),%eax
 860:	2b 45 ec             	sub    -0x14(%ebp),%eax
 863:	89 c2                	mov    %eax,%edx
 865:	8b 45 f4             	mov    -0xc(%ebp),%eax
 868:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	8b 40 04             	mov    0x4(%eax),%eax
 871:	c1 e0 03             	shl    $0x3,%eax
 874:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 877:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 87d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 880:	8b 45 f0             	mov    -0x10(%ebp),%eax
 883:	a3 ac 0b 00 00       	mov    %eax,0xbac
      return (void*)(p + 1);
 888:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88b:	83 c0 08             	add    $0x8,%eax
 88e:	eb 3b                	jmp    8cb <malloc+0xe1>
    }
    if(p == freep)
 890:	a1 ac 0b 00 00       	mov    0xbac,%eax
 895:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 898:	75 1e                	jne    8b8 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 89a:	83 ec 0c             	sub    $0xc,%esp
 89d:	ff 75 ec             	push   -0x14(%ebp)
 8a0:	e8 e5 fe ff ff       	call   78a <morecore>
 8a5:	83 c4 10             	add    $0x10,%esp
 8a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8af:	75 07                	jne    8b8 <malloc+0xce>
        return 0;
 8b1:	b8 00 00 00 00       	mov    $0x0,%eax
 8b6:	eb 13                	jmp    8cb <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	8b 00                	mov    (%eax),%eax
 8c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8c6:	e9 6d ff ff ff       	jmp    838 <malloc+0x4e>
  }
}
 8cb:	c9                   	leave
 8cc:	c3                   	ret
