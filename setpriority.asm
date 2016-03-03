
_setpriority:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
//#include "defs.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp



   setpriority();
   6:	e8 4d 03 00 00       	call   358 <setpriority>
    exit();
   b:	e8 68 02 00 00       	call   278 <exit>

00000010 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  10:	55                   	push   %ebp
  11:	89 e5                	mov    %esp,%ebp
  13:	57                   	push   %edi
  14:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  18:	8b 55 10             	mov    0x10(%ebp),%edx
  1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  1e:	89 cb                	mov    %ecx,%ebx
  20:	89 df                	mov    %ebx,%edi
  22:	89 d1                	mov    %edx,%ecx
  24:	fc                   	cld    
  25:	f3 aa                	rep stos %al,%es:(%edi)
  27:	89 ca                	mov    %ecx,%edx
  29:	89 fb                	mov    %edi,%ebx
  2b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  2e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  31:	5b                   	pop    %ebx
  32:	5f                   	pop    %edi
  33:	5d                   	pop    %ebp
  34:	c3                   	ret    

00000035 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  35:	55                   	push   %ebp
  36:	89 e5                	mov    %esp,%ebp
  38:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  3b:	8b 45 08             	mov    0x8(%ebp),%eax
  3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  41:	90                   	nop
  42:	8b 45 08             	mov    0x8(%ebp),%eax
  45:	8d 50 01             	lea    0x1(%eax),%edx
  48:	89 55 08             	mov    %edx,0x8(%ebp)
  4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  4e:	8d 4a 01             	lea    0x1(%edx),%ecx
  51:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  54:	0f b6 12             	movzbl (%edx),%edx
  57:	88 10                	mov    %dl,(%eax)
  59:	0f b6 00             	movzbl (%eax),%eax
  5c:	84 c0                	test   %al,%al
  5e:	75 e2                	jne    42 <strcpy+0xd>
    ;
  return os;
  60:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  63:	c9                   	leave  
  64:	c3                   	ret    

00000065 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  65:	55                   	push   %ebp
  66:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  68:	eb 08                	jmp    72 <strcmp+0xd>
    p++, q++;
  6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  6e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  72:	8b 45 08             	mov    0x8(%ebp),%eax
  75:	0f b6 00             	movzbl (%eax),%eax
  78:	84 c0                	test   %al,%al
  7a:	74 10                	je     8c <strcmp+0x27>
  7c:	8b 45 08             	mov    0x8(%ebp),%eax
  7f:	0f b6 10             	movzbl (%eax),%edx
  82:	8b 45 0c             	mov    0xc(%ebp),%eax
  85:	0f b6 00             	movzbl (%eax),%eax
  88:	38 c2                	cmp    %al,%dl
  8a:	74 de                	je     6a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  8c:	8b 45 08             	mov    0x8(%ebp),%eax
  8f:	0f b6 00             	movzbl (%eax),%eax
  92:	0f b6 d0             	movzbl %al,%edx
  95:	8b 45 0c             	mov    0xc(%ebp),%eax
  98:	0f b6 00             	movzbl (%eax),%eax
  9b:	0f b6 c0             	movzbl %al,%eax
  9e:	29 c2                	sub    %eax,%edx
  a0:	89 d0                	mov    %edx,%eax
}
  a2:	5d                   	pop    %ebp
  a3:	c3                   	ret    

000000a4 <strlen>:

uint
strlen(char *s)
{
  a4:	55                   	push   %ebp
  a5:	89 e5                	mov    %esp,%ebp
  a7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  b1:	eb 04                	jmp    b7 <strlen+0x13>
  b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  ba:	8b 45 08             	mov    0x8(%ebp),%eax
  bd:	01 d0                	add    %edx,%eax
  bf:	0f b6 00             	movzbl (%eax),%eax
  c2:	84 c0                	test   %al,%al
  c4:	75 ed                	jne    b3 <strlen+0xf>
    ;
  return n;
  c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c9:	c9                   	leave  
  ca:	c3                   	ret    

000000cb <memset>:

void*
memset(void *dst, int c, uint n)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  ce:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  d1:	8b 45 10             	mov    0x10(%ebp),%eax
  d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  db:	89 44 24 04          	mov    %eax,0x4(%esp)
  df:	8b 45 08             	mov    0x8(%ebp),%eax
  e2:	89 04 24             	mov    %eax,(%esp)
  e5:	e8 26 ff ff ff       	call   10 <stosb>
  return dst;
  ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
  ed:	c9                   	leave  
  ee:	c3                   	ret    

000000ef <strchr>:

char*
strchr(const char *s, char c)
{
  ef:	55                   	push   %ebp
  f0:	89 e5                	mov    %esp,%ebp
  f2:	83 ec 04             	sub    $0x4,%esp
  f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  f8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  fb:	eb 14                	jmp    111 <strchr+0x22>
    if(*s == c)
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
 100:	0f b6 00             	movzbl (%eax),%eax
 103:	3a 45 fc             	cmp    -0x4(%ebp),%al
 106:	75 05                	jne    10d <strchr+0x1e>
      return (char*)s;
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	eb 13                	jmp    120 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 10d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	0f b6 00             	movzbl (%eax),%eax
 117:	84 c0                	test   %al,%al
 119:	75 e2                	jne    fd <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 11b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 120:	c9                   	leave  
 121:	c3                   	ret    

00000122 <gets>:

char*
gets(char *buf, int max)
{
 122:	55                   	push   %ebp
 123:	89 e5                	mov    %esp,%ebp
 125:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 12f:	eb 4c                	jmp    17d <gets+0x5b>
    cc = read(0, &c, 1);
 131:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 138:	00 
 139:	8d 45 ef             	lea    -0x11(%ebp),%eax
 13c:	89 44 24 04          	mov    %eax,0x4(%esp)
 140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 147:	e8 44 01 00 00       	call   290 <read>
 14c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 14f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 153:	7f 02                	jg     157 <gets+0x35>
      break;
 155:	eb 31                	jmp    188 <gets+0x66>
    buf[i++] = c;
 157:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15a:	8d 50 01             	lea    0x1(%eax),%edx
 15d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 160:	89 c2                	mov    %eax,%edx
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	01 c2                	add    %eax,%edx
 167:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 16b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 16d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 171:	3c 0a                	cmp    $0xa,%al
 173:	74 13                	je     188 <gets+0x66>
 175:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 179:	3c 0d                	cmp    $0xd,%al
 17b:	74 0b                	je     188 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 180:	83 c0 01             	add    $0x1,%eax
 183:	3b 45 0c             	cmp    0xc(%ebp),%eax
 186:	7c a9                	jl     131 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 188:	8b 55 f4             	mov    -0xc(%ebp),%edx
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	01 d0                	add    %edx,%eax
 190:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 193:	8b 45 08             	mov    0x8(%ebp),%eax
}
 196:	c9                   	leave  
 197:	c3                   	ret    

00000198 <stat>:

int
stat(char *n, struct stat *st)
{
 198:	55                   	push   %ebp
 199:	89 e5                	mov    %esp,%ebp
 19b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a5:	00 
 1a6:	8b 45 08             	mov    0x8(%ebp),%eax
 1a9:	89 04 24             	mov    %eax,(%esp)
 1ac:	e8 07 01 00 00       	call   2b8 <open>
 1b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1b8:	79 07                	jns    1c1 <stat+0x29>
    return -1;
 1ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1bf:	eb 23                	jmp    1e4 <stat+0x4c>
  r = fstat(fd, st);
 1c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cb:	89 04 24             	mov    %eax,(%esp)
 1ce:	e8 fd 00 00 00       	call   2d0 <fstat>
 1d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d9:	89 04 24             	mov    %eax,(%esp)
 1dc:	e8 bf 00 00 00       	call   2a0 <close>
  return r;
 1e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1e4:	c9                   	leave  
 1e5:	c3                   	ret    

000001e6 <atoi>:

int
atoi(const char *s)
{
 1e6:	55                   	push   %ebp
 1e7:	89 e5                	mov    %esp,%ebp
 1e9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f3:	eb 25                	jmp    21a <atoi+0x34>
    n = n*10 + *s++ - '0';
 1f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f8:	89 d0                	mov    %edx,%eax
 1fa:	c1 e0 02             	shl    $0x2,%eax
 1fd:	01 d0                	add    %edx,%eax
 1ff:	01 c0                	add    %eax,%eax
 201:	89 c1                	mov    %eax,%ecx
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	8d 50 01             	lea    0x1(%eax),%edx
 209:	89 55 08             	mov    %edx,0x8(%ebp)
 20c:	0f b6 00             	movzbl (%eax),%eax
 20f:	0f be c0             	movsbl %al,%eax
 212:	01 c8                	add    %ecx,%eax
 214:	83 e8 30             	sub    $0x30,%eax
 217:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	0f b6 00             	movzbl (%eax),%eax
 220:	3c 2f                	cmp    $0x2f,%al
 222:	7e 0a                	jle    22e <atoi+0x48>
 224:	8b 45 08             	mov    0x8(%ebp),%eax
 227:	0f b6 00             	movzbl (%eax),%eax
 22a:	3c 39                	cmp    $0x39,%al
 22c:	7e c7                	jle    1f5 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 22e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 231:	c9                   	leave  
 232:	c3                   	ret    

00000233 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 233:	55                   	push   %ebp
 234:	89 e5                	mov    %esp,%ebp
 236:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 23f:	8b 45 0c             	mov    0xc(%ebp),%eax
 242:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 245:	eb 17                	jmp    25e <memmove+0x2b>
    *dst++ = *src++;
 247:	8b 45 fc             	mov    -0x4(%ebp),%eax
 24a:	8d 50 01             	lea    0x1(%eax),%edx
 24d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 250:	8b 55 f8             	mov    -0x8(%ebp),%edx
 253:	8d 4a 01             	lea    0x1(%edx),%ecx
 256:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 259:	0f b6 12             	movzbl (%edx),%edx
 25c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 25e:	8b 45 10             	mov    0x10(%ebp),%eax
 261:	8d 50 ff             	lea    -0x1(%eax),%edx
 264:	89 55 10             	mov    %edx,0x10(%ebp)
 267:	85 c0                	test   %eax,%eax
 269:	7f dc                	jg     247 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26e:	c9                   	leave  
 26f:	c3                   	ret    

00000270 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 270:	b8 01 00 00 00       	mov    $0x1,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <exit>:
SYSCALL(exit)
 278:	b8 02 00 00 00       	mov    $0x2,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <wait>:
SYSCALL(wait)
 280:	b8 03 00 00 00       	mov    $0x3,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <pipe>:
SYSCALL(pipe)
 288:	b8 04 00 00 00       	mov    $0x4,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <read>:
SYSCALL(read)
 290:	b8 05 00 00 00       	mov    $0x5,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <write>:
SYSCALL(write)
 298:	b8 10 00 00 00       	mov    $0x10,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <close>:
SYSCALL(close)
 2a0:	b8 15 00 00 00       	mov    $0x15,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <kill>:
SYSCALL(kill)
 2a8:	b8 06 00 00 00       	mov    $0x6,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <exec>:
SYSCALL(exec)
 2b0:	b8 07 00 00 00       	mov    $0x7,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <open>:
SYSCALL(open)
 2b8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <mknod>:
SYSCALL(mknod)
 2c0:	b8 11 00 00 00       	mov    $0x11,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <unlink>:
SYSCALL(unlink)
 2c8:	b8 12 00 00 00       	mov    $0x12,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <fstat>:
SYSCALL(fstat)
 2d0:	b8 08 00 00 00       	mov    $0x8,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <link>:
SYSCALL(link)
 2d8:	b8 13 00 00 00       	mov    $0x13,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <mkdir>:
SYSCALL(mkdir)
 2e0:	b8 14 00 00 00       	mov    $0x14,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <chdir>:
SYSCALL(chdir)
 2e8:	b8 09 00 00 00       	mov    $0x9,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <dup>:
SYSCALL(dup)
 2f0:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <getpid>:
SYSCALL(getpid)
 2f8:	b8 0b 00 00 00       	mov    $0xb,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <sbrk>:
SYSCALL(sbrk)
 300:	b8 0c 00 00 00       	mov    $0xc,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <sleep>:
SYSCALL(sleep)
 308:	b8 0d 00 00 00       	mov    $0xd,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <uptime>:
SYSCALL(uptime)
 310:	b8 0e 00 00 00       	mov    $0xe,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <date>:
SYSCALL(date)
 318:	b8 16 00 00 00       	mov    $0x16,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <timem>:
SYSCALL(timem)
 320:	b8 17 00 00 00       	mov    $0x17,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <getuid>:
SYSCALL(getuid)
 328:	b8 18 00 00 00       	mov    $0x18,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <getgid>:
SYSCALL(getgid)
 330:	b8 19 00 00 00       	mov    $0x19,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <getppid>:
SYSCALL(getppid)
 338:	b8 1a 00 00 00       	mov    $0x1a,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <setuid>:
SYSCALL(setuid)
 340:	b8 1b 00 00 00       	mov    $0x1b,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <setgid>:
SYSCALL(setgid)
 348:	b8 1c 00 00 00       	mov    $0x1c,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <getprocs>:
SYSCALL(getprocs)
 350:	b8 1d 00 00 00       	mov    $0x1d,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <setpriority>:
SYSCALL(setpriority)
 358:	b8 1e 00 00 00       	mov    $0x1e,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 360:	55                   	push   %ebp
 361:	89 e5                	mov    %esp,%ebp
 363:	83 ec 18             	sub    $0x18,%esp
 366:	8b 45 0c             	mov    0xc(%ebp),%eax
 369:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 36c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 373:	00 
 374:	8d 45 f4             	lea    -0xc(%ebp),%eax
 377:	89 44 24 04          	mov    %eax,0x4(%esp)
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	89 04 24             	mov    %eax,(%esp)
 381:	e8 12 ff ff ff       	call   298 <write>
}
 386:	c9                   	leave  
 387:	c3                   	ret    

00000388 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
 38b:	56                   	push   %esi
 38c:	53                   	push   %ebx
 38d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 390:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 397:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 39b:	74 17                	je     3b4 <printint+0x2c>
 39d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a1:	79 11                	jns    3b4 <printint+0x2c>
    neg = 1;
 3a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	f7 d8                	neg    %eax
 3af:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b2:	eb 06                	jmp    3ba <printint+0x32>
  } else {
    x = xx;
 3b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3c4:	8d 41 01             	lea    0x1(%ecx),%eax
 3c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d0:	ba 00 00 00 00       	mov    $0x0,%edx
 3d5:	f7 f3                	div    %ebx
 3d7:	89 d0                	mov    %edx,%eax
 3d9:	0f b6 80 58 0a 00 00 	movzbl 0xa58(%eax),%eax
 3e0:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3e4:	8b 75 10             	mov    0x10(%ebp),%esi
 3e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ea:	ba 00 00 00 00       	mov    $0x0,%edx
 3ef:	f7 f6                	div    %esi
 3f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f8:	75 c7                	jne    3c1 <printint+0x39>
  if(neg)
 3fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3fe:	74 10                	je     410 <printint+0x88>
    buf[i++] = '-';
 400:	8b 45 f4             	mov    -0xc(%ebp),%eax
 403:	8d 50 01             	lea    0x1(%eax),%edx
 406:	89 55 f4             	mov    %edx,-0xc(%ebp)
 409:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 40e:	eb 1f                	jmp    42f <printint+0xa7>
 410:	eb 1d                	jmp    42f <printint+0xa7>
    putc(fd, buf[i]);
 412:	8d 55 dc             	lea    -0x24(%ebp),%edx
 415:	8b 45 f4             	mov    -0xc(%ebp),%eax
 418:	01 d0                	add    %edx,%eax
 41a:	0f b6 00             	movzbl (%eax),%eax
 41d:	0f be c0             	movsbl %al,%eax
 420:	89 44 24 04          	mov    %eax,0x4(%esp)
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	89 04 24             	mov    %eax,(%esp)
 42a:	e8 31 ff ff ff       	call   360 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 42f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 433:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 437:	79 d9                	jns    412 <printint+0x8a>
    putc(fd, buf[i]);
}
 439:	83 c4 30             	add    $0x30,%esp
 43c:	5b                   	pop    %ebx
 43d:	5e                   	pop    %esi
 43e:	5d                   	pop    %ebp
 43f:	c3                   	ret    

00000440 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 446:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 44d:	8d 45 0c             	lea    0xc(%ebp),%eax
 450:	83 c0 04             	add    $0x4,%eax
 453:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 456:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 45d:	e9 7c 01 00 00       	jmp    5de <printf+0x19e>
    c = fmt[i] & 0xff;
 462:	8b 55 0c             	mov    0xc(%ebp),%edx
 465:	8b 45 f0             	mov    -0x10(%ebp),%eax
 468:	01 d0                	add    %edx,%eax
 46a:	0f b6 00             	movzbl (%eax),%eax
 46d:	0f be c0             	movsbl %al,%eax
 470:	25 ff 00 00 00       	and    $0xff,%eax
 475:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 478:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47c:	75 2c                	jne    4aa <printf+0x6a>
      if(c == '%'){
 47e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 482:	75 0c                	jne    490 <printf+0x50>
        state = '%';
 484:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 48b:	e9 4a 01 00 00       	jmp    5da <printf+0x19a>
      } else {
        putc(fd, c);
 490:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 493:	0f be c0             	movsbl %al,%eax
 496:	89 44 24 04          	mov    %eax,0x4(%esp)
 49a:	8b 45 08             	mov    0x8(%ebp),%eax
 49d:	89 04 24             	mov    %eax,(%esp)
 4a0:	e8 bb fe ff ff       	call   360 <putc>
 4a5:	e9 30 01 00 00       	jmp    5da <printf+0x19a>
      }
    } else if(state == '%'){
 4aa:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ae:	0f 85 26 01 00 00    	jne    5da <printf+0x19a>
      if(c == 'd'){
 4b4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4b8:	75 2d                	jne    4e7 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4bd:	8b 00                	mov    (%eax),%eax
 4bf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4c6:	00 
 4c7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4ce:	00 
 4cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	89 04 24             	mov    %eax,(%esp)
 4d9:	e8 aa fe ff ff       	call   388 <printint>
        ap++;
 4de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4e2:	e9 ec 00 00 00       	jmp    5d3 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 4e7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4eb:	74 06                	je     4f3 <printf+0xb3>
 4ed:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4f1:	75 2d                	jne    520 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f6:	8b 00                	mov    (%eax),%eax
 4f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4ff:	00 
 500:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 507:	00 
 508:	89 44 24 04          	mov    %eax,0x4(%esp)
 50c:	8b 45 08             	mov    0x8(%ebp),%eax
 50f:	89 04 24             	mov    %eax,(%esp)
 512:	e8 71 fe ff ff       	call   388 <printint>
        ap++;
 517:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51b:	e9 b3 00 00 00       	jmp    5d3 <printf+0x193>
      } else if(c == 's'){
 520:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 524:	75 45                	jne    56b <printf+0x12b>
        s = (char*)*ap;
 526:	8b 45 e8             	mov    -0x18(%ebp),%eax
 529:	8b 00                	mov    (%eax),%eax
 52b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 52e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 532:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 536:	75 09                	jne    541 <printf+0x101>
          s = "(null)";
 538:	c7 45 f4 0c 08 00 00 	movl   $0x80c,-0xc(%ebp)
        while(*s != 0){
 53f:	eb 1e                	jmp    55f <printf+0x11f>
 541:	eb 1c                	jmp    55f <printf+0x11f>
          putc(fd, *s);
 543:	8b 45 f4             	mov    -0xc(%ebp),%eax
 546:	0f b6 00             	movzbl (%eax),%eax
 549:	0f be c0             	movsbl %al,%eax
 54c:	89 44 24 04          	mov    %eax,0x4(%esp)
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	89 04 24             	mov    %eax,(%esp)
 556:	e8 05 fe ff ff       	call   360 <putc>
          s++;
 55b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 55f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	84 c0                	test   %al,%al
 567:	75 da                	jne    543 <printf+0x103>
 569:	eb 68                	jmp    5d3 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 56f:	75 1d                	jne    58e <printf+0x14e>
        putc(fd, *ap);
 571:	8b 45 e8             	mov    -0x18(%ebp),%eax
 574:	8b 00                	mov    (%eax),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	89 44 24 04          	mov    %eax,0x4(%esp)
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	89 04 24             	mov    %eax,(%esp)
 583:	e8 d8 fd ff ff       	call   360 <putc>
        ap++;
 588:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58c:	eb 45                	jmp    5d3 <printf+0x193>
      } else if(c == '%'){
 58e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 592:	75 17                	jne    5ab <printf+0x16b>
        putc(fd, c);
 594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 597:	0f be c0             	movsbl %al,%eax
 59a:	89 44 24 04          	mov    %eax,0x4(%esp)
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	89 04 24             	mov    %eax,(%esp)
 5a4:	e8 b7 fd ff ff       	call   360 <putc>
 5a9:	eb 28                	jmp    5d3 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ab:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5b2:	00 
 5b3:	8b 45 08             	mov    0x8(%ebp),%eax
 5b6:	89 04 24             	mov    %eax,(%esp)
 5b9:	e8 a2 fd ff ff       	call   360 <putc>
        putc(fd, c);
 5be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c1:	0f be c0             	movsbl %al,%eax
 5c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	89 04 24             	mov    %eax,(%esp)
 5ce:	e8 8d fd ff ff       	call   360 <putc>
      }
      state = 0;
 5d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5de:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e4:	01 d0                	add    %edx,%eax
 5e6:	0f b6 00             	movzbl (%eax),%eax
 5e9:	84 c0                	test   %al,%al
 5eb:	0f 85 71 fe ff ff    	jne    462 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5f1:	c9                   	leave  
 5f2:	c3                   	ret    

000005f3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f3:	55                   	push   %ebp
 5f4:	89 e5                	mov    %esp,%ebp
 5f6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5f9:	8b 45 08             	mov    0x8(%ebp),%eax
 5fc:	83 e8 08             	sub    $0x8,%eax
 5ff:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 602:	a1 74 0a 00 00       	mov    0xa74,%eax
 607:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60a:	eb 24                	jmp    630 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 60c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60f:	8b 00                	mov    (%eax),%eax
 611:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 614:	77 12                	ja     628 <free+0x35>
 616:	8b 45 f8             	mov    -0x8(%ebp),%eax
 619:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61c:	77 24                	ja     642 <free+0x4f>
 61e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 621:	8b 00                	mov    (%eax),%eax
 623:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 626:	77 1a                	ja     642 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 628:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62b:	8b 00                	mov    (%eax),%eax
 62d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 630:	8b 45 f8             	mov    -0x8(%ebp),%eax
 633:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 636:	76 d4                	jbe    60c <free+0x19>
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 640:	76 ca                	jbe    60c <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 642:	8b 45 f8             	mov    -0x8(%ebp),%eax
 645:	8b 40 04             	mov    0x4(%eax),%eax
 648:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 64f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 652:	01 c2                	add    %eax,%edx
 654:	8b 45 fc             	mov    -0x4(%ebp),%eax
 657:	8b 00                	mov    (%eax),%eax
 659:	39 c2                	cmp    %eax,%edx
 65b:	75 24                	jne    681 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 65d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 660:	8b 50 04             	mov    0x4(%eax),%edx
 663:	8b 45 fc             	mov    -0x4(%ebp),%eax
 666:	8b 00                	mov    (%eax),%eax
 668:	8b 40 04             	mov    0x4(%eax),%eax
 66b:	01 c2                	add    %eax,%edx
 66d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 670:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 673:	8b 45 fc             	mov    -0x4(%ebp),%eax
 676:	8b 00                	mov    (%eax),%eax
 678:	8b 10                	mov    (%eax),%edx
 67a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67d:	89 10                	mov    %edx,(%eax)
 67f:	eb 0a                	jmp    68b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 10                	mov    (%eax),%edx
 686:	8b 45 f8             	mov    -0x8(%ebp),%eax
 689:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 68b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68e:	8b 40 04             	mov    0x4(%eax),%eax
 691:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 698:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69b:	01 d0                	add    %edx,%eax
 69d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a0:	75 20                	jne    6c2 <free+0xcf>
    p->s.size += bp->s.size;
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	8b 50 04             	mov    0x4(%eax),%edx
 6a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ab:	8b 40 04             	mov    0x4(%eax),%eax
 6ae:	01 c2                	add    %eax,%edx
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b9:	8b 10                	mov    (%eax),%edx
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	89 10                	mov    %edx,(%eax)
 6c0:	eb 08                	jmp    6ca <free+0xd7>
  } else
    p->s.ptr = bp;
 6c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c8:	89 10                	mov    %edx,(%eax)
  freep = p;
 6ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cd:	a3 74 0a 00 00       	mov    %eax,0xa74
}
 6d2:	c9                   	leave  
 6d3:	c3                   	ret    

000006d4 <morecore>:

static Header*
morecore(uint nu)
{
 6d4:	55                   	push   %ebp
 6d5:	89 e5                	mov    %esp,%ebp
 6d7:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6da:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e1:	77 07                	ja     6ea <morecore+0x16>
    nu = 4096;
 6e3:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6ea:	8b 45 08             	mov    0x8(%ebp),%eax
 6ed:	c1 e0 03             	shl    $0x3,%eax
 6f0:	89 04 24             	mov    %eax,(%esp)
 6f3:	e8 08 fc ff ff       	call   300 <sbrk>
 6f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6fb:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ff:	75 07                	jne    708 <morecore+0x34>
    return 0;
 701:	b8 00 00 00 00       	mov    $0x0,%eax
 706:	eb 22                	jmp    72a <morecore+0x56>
  hp = (Header*)p;
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 70e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 711:	8b 55 08             	mov    0x8(%ebp),%edx
 714:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 717:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71a:	83 c0 08             	add    $0x8,%eax
 71d:	89 04 24             	mov    %eax,(%esp)
 720:	e8 ce fe ff ff       	call   5f3 <free>
  return freep;
 725:	a1 74 0a 00 00       	mov    0xa74,%eax
}
 72a:	c9                   	leave  
 72b:	c3                   	ret    

0000072c <malloc>:

void*
malloc(uint nbytes)
{
 72c:	55                   	push   %ebp
 72d:	89 e5                	mov    %esp,%ebp
 72f:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 732:	8b 45 08             	mov    0x8(%ebp),%eax
 735:	83 c0 07             	add    $0x7,%eax
 738:	c1 e8 03             	shr    $0x3,%eax
 73b:	83 c0 01             	add    $0x1,%eax
 73e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 741:	a1 74 0a 00 00       	mov    0xa74,%eax
 746:	89 45 f0             	mov    %eax,-0x10(%ebp)
 749:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 74d:	75 23                	jne    772 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 74f:	c7 45 f0 6c 0a 00 00 	movl   $0xa6c,-0x10(%ebp)
 756:	8b 45 f0             	mov    -0x10(%ebp),%eax
 759:	a3 74 0a 00 00       	mov    %eax,0xa74
 75e:	a1 74 0a 00 00       	mov    0xa74,%eax
 763:	a3 6c 0a 00 00       	mov    %eax,0xa6c
    base.s.size = 0;
 768:	c7 05 70 0a 00 00 00 	movl   $0x0,0xa70
 76f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 772:	8b 45 f0             	mov    -0x10(%ebp),%eax
 775:	8b 00                	mov    (%eax),%eax
 777:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 77a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77d:	8b 40 04             	mov    0x4(%eax),%eax
 780:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 783:	72 4d                	jb     7d2 <malloc+0xa6>
      if(p->s.size == nunits)
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	8b 40 04             	mov    0x4(%eax),%eax
 78b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 78e:	75 0c                	jne    79c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 790:	8b 45 f4             	mov    -0xc(%ebp),%eax
 793:	8b 10                	mov    (%eax),%edx
 795:	8b 45 f0             	mov    -0x10(%ebp),%eax
 798:	89 10                	mov    %edx,(%eax)
 79a:	eb 26                	jmp    7c2 <malloc+0x96>
      else {
        p->s.size -= nunits;
 79c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79f:	8b 40 04             	mov    0x4(%eax),%eax
 7a2:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7a5:	89 c2                	mov    %eax,%edx
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b0:	8b 40 04             	mov    0x4(%eax),%eax
 7b3:	c1 e0 03             	shl    $0x3,%eax
 7b6:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7bf:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c5:	a3 74 0a 00 00       	mov    %eax,0xa74
      return (void*)(p + 1);
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	83 c0 08             	add    $0x8,%eax
 7d0:	eb 38                	jmp    80a <malloc+0xde>
    }
    if(p == freep)
 7d2:	a1 74 0a 00 00       	mov    0xa74,%eax
 7d7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7da:	75 1b                	jne    7f7 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7df:	89 04 24             	mov    %eax,(%esp)
 7e2:	e8 ed fe ff ff       	call   6d4 <morecore>
 7e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ee:	75 07                	jne    7f7 <malloc+0xcb>
        return 0;
 7f0:	b8 00 00 00 00       	mov    $0x0,%eax
 7f5:	eb 13                	jmp    80a <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 805:	e9 70 ff ff ff       	jmp    77a <malloc+0x4e>
}
 80a:	c9                   	leave  
 80b:	c3                   	ret    
