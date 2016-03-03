
_testSched:     file format elf32-i386


Disassembly of section .text:

00000000 <countForever>:
#define PrioCount 3
#define numChildren 10

void
countForever(int p)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int j;
  unsigned long count = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  j = getpid();
   d:	e8 fe 03 00 00       	call   410 <getpid>
  12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  p = p%PrioCount;
  15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  18:	ba 56 55 55 55       	mov    $0x55555556,%edx
  1d:	89 c8                	mov    %ecx,%eax
  1f:	f7 ea                	imul   %edx
  21:	89 c8                	mov    %ecx,%eax
  23:	c1 f8 1f             	sar    $0x1f,%eax
  26:	29 c2                	sub    %eax,%edx
  28:	89 d0                	mov    %edx,%eax
  2a:	01 c0                	add    %eax,%eax
  2c:	01 d0                	add    %edx,%eax
  2e:	29 c1                	sub    %eax,%ecx
  30:	89 c8                	mov    %ecx,%eax
  32:	89 45 08             	mov    %eax,0x8(%ebp)
  setpriority(j, p);
  35:	8b 45 08             	mov    0x8(%ebp),%eax
  38:	89 44 24 04          	mov    %eax,0x4(%esp)
  3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  3f:	89 04 24             	mov    %eax,(%esp)
  42:	e8 29 04 00 00       	call   470 <setpriority>
  printf(1, "%d: start prio %d\n", j, p);
  47:	8b 45 08             	mov    0x8(%ebp),%eax
  4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  51:	89 44 24 08          	mov    %eax,0x8(%esp)
  55:	c7 44 24 04 24 09 00 	movl   $0x924,0x4(%esp)
  5c:	00 
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 ef 04 00 00       	call   558 <printf>

  while (1) {
    count++;
  69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if ((count & 0xFFFFFFF) == 0) {
  6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  70:	25 ff ff ff 0f       	and    $0xfffffff,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 61                	jne    da <countForever+0xda>
      p = (p+1) % PrioCount;
  79:	8b 45 08             	mov    0x8(%ebp),%eax
  7c:	8d 48 01             	lea    0x1(%eax),%ecx
  7f:	ba 56 55 55 55       	mov    $0x55555556,%edx
  84:	89 c8                	mov    %ecx,%eax
  86:	f7 ea                	imul   %edx
  88:	89 c8                	mov    %ecx,%eax
  8a:	c1 f8 1f             	sar    $0x1f,%eax
  8d:	29 c2                	sub    %eax,%edx
  8f:	89 d0                	mov    %edx,%eax
  91:	89 45 08             	mov    %eax,0x8(%ebp)
  94:	8b 55 08             	mov    0x8(%ebp),%edx
  97:	89 d0                	mov    %edx,%eax
  99:	01 c0                	add    %eax,%eax
  9b:	01 d0                	add    %edx,%eax
  9d:	29 c1                	sub    %eax,%ecx
  9f:	89 c8                	mov    %ecx,%eax
  a1:	89 45 08             	mov    %eax,0x8(%ebp)
      setpriority(j, p);
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ae:	89 04 24             	mov    %eax,(%esp)
  b1:	e8 ba 03 00 00       	call   470 <setpriority>
      printf(1, "%d: new prio %d\n", j, p);
  b6:	8b 45 08             	mov    0x8(%ebp),%eax
  b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  c4:	c7 44 24 04 37 09 00 	movl   $0x937,0x4(%esp)
  cb:	00 
  cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d3:	e8 80 04 00 00       	call   558 <printf>
    }
  }
  d8:	eb 8f                	jmp    69 <countForever+0x69>
  da:	eb 8d                	jmp    69 <countForever+0x69>

000000dc <main>:
}

int
main(void)
{
  dc:	55                   	push   %ebp
  dd:	89 e5                	mov    %esp,%ebp
  df:	83 e4 f0             	and    $0xfffffff0,%esp
  e2:	83 ec 20             	sub    $0x20,%esp
  int i, rc;

  for (i=0; i<numChildren; i++) {
  e5:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  ec:	00 
  ed:	eb 21                	jmp    110 <main+0x34>
    rc = fork();
  ef:	e8 94 02 00 00       	call   388 <fork>
  f4:	89 44 24 18          	mov    %eax,0x18(%esp)
    if (!rc) { // child
  f8:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  fd:	75 0c                	jne    10b <main+0x2f>
      countForever(i);
  ff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 103:	89 04 24             	mov    %eax,(%esp)
 106:	e8 f5 fe ff ff       	call   0 <countForever>
int
main(void)
{
  int i, rc;

  for (i=0; i<numChildren; i++) {
 10b:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 110:	83 7c 24 1c 09       	cmpl   $0x9,0x1c(%esp)
 115:	7e d8                	jle    ef <main+0x13>
    if (!rc) { // child
      countForever(i);
    }
  }
  // what the heck, let's have the parent waste time as well!
  countForever(1);
 117:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11e:	e8 dd fe ff ff       	call   0 <countForever>
  exit();
 123:	e8 68 02 00 00       	call   390 <exit>

00000128 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	57                   	push   %edi
 12c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 12d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 130:	8b 55 10             	mov    0x10(%ebp),%edx
 133:	8b 45 0c             	mov    0xc(%ebp),%eax
 136:	89 cb                	mov    %ecx,%ebx
 138:	89 df                	mov    %ebx,%edi
 13a:	89 d1                	mov    %edx,%ecx
 13c:	fc                   	cld    
 13d:	f3 aa                	rep stos %al,%es:(%edi)
 13f:	89 ca                	mov    %ecx,%edx
 141:	89 fb                	mov    %edi,%ebx
 143:	89 5d 08             	mov    %ebx,0x8(%ebp)
 146:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 149:	5b                   	pop    %ebx
 14a:	5f                   	pop    %edi
 14b:	5d                   	pop    %ebp
 14c:	c3                   	ret    

0000014d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 153:	8b 45 08             	mov    0x8(%ebp),%eax
 156:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 159:	90                   	nop
 15a:	8b 45 08             	mov    0x8(%ebp),%eax
 15d:	8d 50 01             	lea    0x1(%eax),%edx
 160:	89 55 08             	mov    %edx,0x8(%ebp)
 163:	8b 55 0c             	mov    0xc(%ebp),%edx
 166:	8d 4a 01             	lea    0x1(%edx),%ecx
 169:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 16c:	0f b6 12             	movzbl (%edx),%edx
 16f:	88 10                	mov    %dl,(%eax)
 171:	0f b6 00             	movzbl (%eax),%eax
 174:	84 c0                	test   %al,%al
 176:	75 e2                	jne    15a <strcpy+0xd>
    ;
  return os;
 178:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17b:	c9                   	leave  
 17c:	c3                   	ret    

0000017d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17d:	55                   	push   %ebp
 17e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 180:	eb 08                	jmp    18a <strcmp+0xd>
    p++, q++;
 182:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 186:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	0f b6 00             	movzbl (%eax),%eax
 190:	84 c0                	test   %al,%al
 192:	74 10                	je     1a4 <strcmp+0x27>
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 10             	movzbl (%eax),%edx
 19a:	8b 45 0c             	mov    0xc(%ebp),%eax
 19d:	0f b6 00             	movzbl (%eax),%eax
 1a0:	38 c2                	cmp    %al,%dl
 1a2:	74 de                	je     182 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	0f b6 00             	movzbl (%eax),%eax
 1aa:	0f b6 d0             	movzbl %al,%edx
 1ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	0f b6 c0             	movzbl %al,%eax
 1b6:	29 c2                	sub    %eax,%edx
 1b8:	89 d0                	mov    %edx,%eax
}
 1ba:	5d                   	pop    %ebp
 1bb:	c3                   	ret    

000001bc <strlen>:

uint
strlen(char *s)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
 1bf:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1c2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c9:	eb 04                	jmp    1cf <strlen+0x13>
 1cb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1d2:	8b 45 08             	mov    0x8(%ebp),%eax
 1d5:	01 d0                	add    %edx,%eax
 1d7:	0f b6 00             	movzbl (%eax),%eax
 1da:	84 c0                	test   %al,%al
 1dc:	75 ed                	jne    1cb <strlen+0xf>
    ;
  return n;
 1de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e1:	c9                   	leave  
 1e2:	c3                   	ret    

000001e3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e3:	55                   	push   %ebp
 1e4:	89 e5                	mov    %esp,%ebp
 1e6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1e9:	8b 45 10             	mov    0x10(%ebp),%eax
 1ec:	89 44 24 08          	mov    %eax,0x8(%esp)
 1f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	89 04 24             	mov    %eax,(%esp)
 1fd:	e8 26 ff ff ff       	call   128 <stosb>
  return dst;
 202:	8b 45 08             	mov    0x8(%ebp),%eax
}
 205:	c9                   	leave  
 206:	c3                   	ret    

00000207 <strchr>:

char*
strchr(const char *s, char c)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	83 ec 04             	sub    $0x4,%esp
 20d:	8b 45 0c             	mov    0xc(%ebp),%eax
 210:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 213:	eb 14                	jmp    229 <strchr+0x22>
    if(*s == c)
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 21e:	75 05                	jne    225 <strchr+0x1e>
      return (char*)s;
 220:	8b 45 08             	mov    0x8(%ebp),%eax
 223:	eb 13                	jmp    238 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 225:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	84 c0                	test   %al,%al
 231:	75 e2                	jne    215 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 233:	b8 00 00 00 00       	mov    $0x0,%eax
}
 238:	c9                   	leave  
 239:	c3                   	ret    

0000023a <gets>:

char*
gets(char *buf, int max)
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
 23d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 240:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 247:	eb 4c                	jmp    295 <gets+0x5b>
    cc = read(0, &c, 1);
 249:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 250:	00 
 251:	8d 45 ef             	lea    -0x11(%ebp),%eax
 254:	89 44 24 04          	mov    %eax,0x4(%esp)
 258:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25f:	e8 44 01 00 00       	call   3a8 <read>
 264:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 267:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 26b:	7f 02                	jg     26f <gets+0x35>
      break;
 26d:	eb 31                	jmp    2a0 <gets+0x66>
    buf[i++] = c;
 26f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 272:	8d 50 01             	lea    0x1(%eax),%edx
 275:	89 55 f4             	mov    %edx,-0xc(%ebp)
 278:	89 c2                	mov    %eax,%edx
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	01 c2                	add    %eax,%edx
 27f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 283:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 285:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 289:	3c 0a                	cmp    $0xa,%al
 28b:	74 13                	je     2a0 <gets+0x66>
 28d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 291:	3c 0d                	cmp    $0xd,%al
 293:	74 0b                	je     2a0 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 295:	8b 45 f4             	mov    -0xc(%ebp),%eax
 298:	83 c0 01             	add    $0x1,%eax
 29b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 29e:	7c a9                	jl     249 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	01 d0                	add    %edx,%eax
 2a8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ae:	c9                   	leave  
 2af:	c3                   	ret    

000002b0 <stat>:

int
stat(char *n, struct stat *st)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2bd:	00 
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
 2c1:	89 04 24             	mov    %eax,(%esp)
 2c4:	e8 07 01 00 00       	call   3d0 <open>
 2c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2d0:	79 07                	jns    2d9 <stat+0x29>
    return -1;
 2d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2d7:	eb 23                	jmp    2fc <stat+0x4c>
  r = fstat(fd, st);
 2d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e3:	89 04 24             	mov    %eax,(%esp)
 2e6:	e8 fd 00 00 00       	call   3e8 <fstat>
 2eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f1:	89 04 24             	mov    %eax,(%esp)
 2f4:	e8 bf 00 00 00       	call   3b8 <close>
  return r;
 2f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2fc:	c9                   	leave  
 2fd:	c3                   	ret    

000002fe <atoi>:

int
atoi(const char *s)
{
 2fe:	55                   	push   %ebp
 2ff:	89 e5                	mov    %esp,%ebp
 301:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 304:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 30b:	eb 25                	jmp    332 <atoi+0x34>
    n = n*10 + *s++ - '0';
 30d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 310:	89 d0                	mov    %edx,%eax
 312:	c1 e0 02             	shl    $0x2,%eax
 315:	01 d0                	add    %edx,%eax
 317:	01 c0                	add    %eax,%eax
 319:	89 c1                	mov    %eax,%ecx
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	8d 50 01             	lea    0x1(%eax),%edx
 321:	89 55 08             	mov    %edx,0x8(%ebp)
 324:	0f b6 00             	movzbl (%eax),%eax
 327:	0f be c0             	movsbl %al,%eax
 32a:	01 c8                	add    %ecx,%eax
 32c:	83 e8 30             	sub    $0x30,%eax
 32f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	0f b6 00             	movzbl (%eax),%eax
 338:	3c 2f                	cmp    $0x2f,%al
 33a:	7e 0a                	jle    346 <atoi+0x48>
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	0f b6 00             	movzbl (%eax),%eax
 342:	3c 39                	cmp    $0x39,%al
 344:	7e c7                	jle    30d <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 346:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 349:	c9                   	leave  
 34a:	c3                   	ret    

0000034b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 34b:	55                   	push   %ebp
 34c:	89 e5                	mov    %esp,%ebp
 34e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 357:	8b 45 0c             	mov    0xc(%ebp),%eax
 35a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 35d:	eb 17                	jmp    376 <memmove+0x2b>
    *dst++ = *src++;
 35f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 362:	8d 50 01             	lea    0x1(%eax),%edx
 365:	89 55 fc             	mov    %edx,-0x4(%ebp)
 368:	8b 55 f8             	mov    -0x8(%ebp),%edx
 36b:	8d 4a 01             	lea    0x1(%edx),%ecx
 36e:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 371:	0f b6 12             	movzbl (%edx),%edx
 374:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 376:	8b 45 10             	mov    0x10(%ebp),%eax
 379:	8d 50 ff             	lea    -0x1(%eax),%edx
 37c:	89 55 10             	mov    %edx,0x10(%ebp)
 37f:	85 c0                	test   %eax,%eax
 381:	7f dc                	jg     35f <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 383:	8b 45 08             	mov    0x8(%ebp),%eax
}
 386:	c9                   	leave  
 387:	c3                   	ret    

00000388 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 388:	b8 01 00 00 00       	mov    $0x1,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <exit>:
SYSCALL(exit)
 390:	b8 02 00 00 00       	mov    $0x2,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <wait>:
SYSCALL(wait)
 398:	b8 03 00 00 00       	mov    $0x3,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <pipe>:
SYSCALL(pipe)
 3a0:	b8 04 00 00 00       	mov    $0x4,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <read>:
SYSCALL(read)
 3a8:	b8 05 00 00 00       	mov    $0x5,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <write>:
SYSCALL(write)
 3b0:	b8 10 00 00 00       	mov    $0x10,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <close>:
SYSCALL(close)
 3b8:	b8 15 00 00 00       	mov    $0x15,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <kill>:
SYSCALL(kill)
 3c0:	b8 06 00 00 00       	mov    $0x6,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <exec>:
SYSCALL(exec)
 3c8:	b8 07 00 00 00       	mov    $0x7,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <open>:
SYSCALL(open)
 3d0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <mknod>:
SYSCALL(mknod)
 3d8:	b8 11 00 00 00       	mov    $0x11,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <unlink>:
SYSCALL(unlink)
 3e0:	b8 12 00 00 00       	mov    $0x12,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <fstat>:
SYSCALL(fstat)
 3e8:	b8 08 00 00 00       	mov    $0x8,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <link>:
SYSCALL(link)
 3f0:	b8 13 00 00 00       	mov    $0x13,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <mkdir>:
SYSCALL(mkdir)
 3f8:	b8 14 00 00 00       	mov    $0x14,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <chdir>:
SYSCALL(chdir)
 400:	b8 09 00 00 00       	mov    $0x9,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <dup>:
SYSCALL(dup)
 408:	b8 0a 00 00 00       	mov    $0xa,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <getpid>:
SYSCALL(getpid)
 410:	b8 0b 00 00 00       	mov    $0xb,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <sbrk>:
SYSCALL(sbrk)
 418:	b8 0c 00 00 00       	mov    $0xc,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <sleep>:
SYSCALL(sleep)
 420:	b8 0d 00 00 00       	mov    $0xd,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <uptime>:
SYSCALL(uptime)
 428:	b8 0e 00 00 00       	mov    $0xe,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <date>:
SYSCALL(date)
 430:	b8 16 00 00 00       	mov    $0x16,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <timem>:
SYSCALL(timem)
 438:	b8 17 00 00 00       	mov    $0x17,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <getuid>:
SYSCALL(getuid)
 440:	b8 18 00 00 00       	mov    $0x18,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <getgid>:
SYSCALL(getgid)
 448:	b8 19 00 00 00       	mov    $0x19,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <getppid>:
SYSCALL(getppid)
 450:	b8 1a 00 00 00       	mov    $0x1a,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <setuid>:
SYSCALL(setuid)
 458:	b8 1b 00 00 00       	mov    $0x1b,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <setgid>:
SYSCALL(setgid)
 460:	b8 1c 00 00 00       	mov    $0x1c,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <getprocs>:
SYSCALL(getprocs)
 468:	b8 1d 00 00 00       	mov    $0x1d,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <setpriority>:
SYSCALL(setpriority)
 470:	b8 1e 00 00 00       	mov    $0x1e,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 478:	55                   	push   %ebp
 479:	89 e5                	mov    %esp,%ebp
 47b:	83 ec 18             	sub    $0x18,%esp
 47e:	8b 45 0c             	mov    0xc(%ebp),%eax
 481:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 484:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 48b:	00 
 48c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 48f:	89 44 24 04          	mov    %eax,0x4(%esp)
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	89 04 24             	mov    %eax,(%esp)
 499:	e8 12 ff ff ff       	call   3b0 <write>
}
 49e:	c9                   	leave  
 49f:	c3                   	ret    

000004a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a0:	55                   	push   %ebp
 4a1:	89 e5                	mov    %esp,%ebp
 4a3:	56                   	push   %esi
 4a4:	53                   	push   %ebx
 4a5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4af:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4b3:	74 17                	je     4cc <printint+0x2c>
 4b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4b9:	79 11                	jns    4cc <printint+0x2c>
    neg = 1;
 4bb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c5:	f7 d8                	neg    %eax
 4c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ca:	eb 06                	jmp    4d2 <printint+0x32>
  } else {
    x = xx;
 4cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4d9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4dc:	8d 41 01             	lea    0x1(%ecx),%eax
 4df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e8:	ba 00 00 00 00       	mov    $0x0,%edx
 4ed:	f7 f3                	div    %ebx
 4ef:	89 d0                	mov    %edx,%eax
 4f1:	0f b6 80 b0 0b 00 00 	movzbl 0xbb0(%eax),%eax
 4f8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4fc:	8b 75 10             	mov    0x10(%ebp),%esi
 4ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 502:	ba 00 00 00 00       	mov    $0x0,%edx
 507:	f7 f6                	div    %esi
 509:	89 45 ec             	mov    %eax,-0x14(%ebp)
 50c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 510:	75 c7                	jne    4d9 <printint+0x39>
  if(neg)
 512:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 516:	74 10                	je     528 <printint+0x88>
    buf[i++] = '-';
 518:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51b:	8d 50 01             	lea    0x1(%eax),%edx
 51e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 521:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 526:	eb 1f                	jmp    547 <printint+0xa7>
 528:	eb 1d                	jmp    547 <printint+0xa7>
    putc(fd, buf[i]);
 52a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 52d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 530:	01 d0                	add    %edx,%eax
 532:	0f b6 00             	movzbl (%eax),%eax
 535:	0f be c0             	movsbl %al,%eax
 538:	89 44 24 04          	mov    %eax,0x4(%esp)
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	89 04 24             	mov    %eax,(%esp)
 542:	e8 31 ff ff ff       	call   478 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 547:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 54b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 54f:	79 d9                	jns    52a <printint+0x8a>
    putc(fd, buf[i]);
}
 551:	83 c4 30             	add    $0x30,%esp
 554:	5b                   	pop    %ebx
 555:	5e                   	pop    %esi
 556:	5d                   	pop    %ebp
 557:	c3                   	ret    

00000558 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 558:	55                   	push   %ebp
 559:	89 e5                	mov    %esp,%ebp
 55b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 55e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 565:	8d 45 0c             	lea    0xc(%ebp),%eax
 568:	83 c0 04             	add    $0x4,%eax
 56b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 56e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 575:	e9 7c 01 00 00       	jmp    6f6 <printf+0x19e>
    c = fmt[i] & 0xff;
 57a:	8b 55 0c             	mov    0xc(%ebp),%edx
 57d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 580:	01 d0                	add    %edx,%eax
 582:	0f b6 00             	movzbl (%eax),%eax
 585:	0f be c0             	movsbl %al,%eax
 588:	25 ff 00 00 00       	and    $0xff,%eax
 58d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 590:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 594:	75 2c                	jne    5c2 <printf+0x6a>
      if(c == '%'){
 596:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 59a:	75 0c                	jne    5a8 <printf+0x50>
        state = '%';
 59c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5a3:	e9 4a 01 00 00       	jmp    6f2 <printf+0x19a>
      } else {
        putc(fd, c);
 5a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ab:	0f be c0             	movsbl %al,%eax
 5ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b2:	8b 45 08             	mov    0x8(%ebp),%eax
 5b5:	89 04 24             	mov    %eax,(%esp)
 5b8:	e8 bb fe ff ff       	call   478 <putc>
 5bd:	e9 30 01 00 00       	jmp    6f2 <printf+0x19a>
      }
    } else if(state == '%'){
 5c2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5c6:	0f 85 26 01 00 00    	jne    6f2 <printf+0x19a>
      if(c == 'd'){
 5cc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5d0:	75 2d                	jne    5ff <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d5:	8b 00                	mov    (%eax),%eax
 5d7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5de:	00 
 5df:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5e6:	00 
 5e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5eb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ee:	89 04 24             	mov    %eax,(%esp)
 5f1:	e8 aa fe ff ff       	call   4a0 <printint>
        ap++;
 5f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5fa:	e9 ec 00 00 00       	jmp    6eb <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5ff:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 603:	74 06                	je     60b <printf+0xb3>
 605:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 609:	75 2d                	jne    638 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 60b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60e:	8b 00                	mov    (%eax),%eax
 610:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 617:	00 
 618:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 61f:	00 
 620:	89 44 24 04          	mov    %eax,0x4(%esp)
 624:	8b 45 08             	mov    0x8(%ebp),%eax
 627:	89 04 24             	mov    %eax,(%esp)
 62a:	e8 71 fe ff ff       	call   4a0 <printint>
        ap++;
 62f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 633:	e9 b3 00 00 00       	jmp    6eb <printf+0x193>
      } else if(c == 's'){
 638:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 63c:	75 45                	jne    683 <printf+0x12b>
        s = (char*)*ap;
 63e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 641:	8b 00                	mov    (%eax),%eax
 643:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 646:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 64a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 64e:	75 09                	jne    659 <printf+0x101>
          s = "(null)";
 650:	c7 45 f4 48 09 00 00 	movl   $0x948,-0xc(%ebp)
        while(*s != 0){
 657:	eb 1e                	jmp    677 <printf+0x11f>
 659:	eb 1c                	jmp    677 <printf+0x11f>
          putc(fd, *s);
 65b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65e:	0f b6 00             	movzbl (%eax),%eax
 661:	0f be c0             	movsbl %al,%eax
 664:	89 44 24 04          	mov    %eax,0x4(%esp)
 668:	8b 45 08             	mov    0x8(%ebp),%eax
 66b:	89 04 24             	mov    %eax,(%esp)
 66e:	e8 05 fe ff ff       	call   478 <putc>
          s++;
 673:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 677:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67a:	0f b6 00             	movzbl (%eax),%eax
 67d:	84 c0                	test   %al,%al
 67f:	75 da                	jne    65b <printf+0x103>
 681:	eb 68                	jmp    6eb <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 683:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 687:	75 1d                	jne    6a6 <printf+0x14e>
        putc(fd, *ap);
 689:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68c:	8b 00                	mov    (%eax),%eax
 68e:	0f be c0             	movsbl %al,%eax
 691:	89 44 24 04          	mov    %eax,0x4(%esp)
 695:	8b 45 08             	mov    0x8(%ebp),%eax
 698:	89 04 24             	mov    %eax,(%esp)
 69b:	e8 d8 fd ff ff       	call   478 <putc>
        ap++;
 6a0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a4:	eb 45                	jmp    6eb <printf+0x193>
      } else if(c == '%'){
 6a6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6aa:	75 17                	jne    6c3 <printf+0x16b>
        putc(fd, c);
 6ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6af:	0f be c0             	movsbl %al,%eax
 6b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b6:	8b 45 08             	mov    0x8(%ebp),%eax
 6b9:	89 04 24             	mov    %eax,(%esp)
 6bc:	e8 b7 fd ff ff       	call   478 <putc>
 6c1:	eb 28                	jmp    6eb <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6c3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6ca:	00 
 6cb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ce:	89 04 24             	mov    %eax,(%esp)
 6d1:	e8 a2 fd ff ff       	call   478 <putc>
        putc(fd, c);
 6d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d9:	0f be c0             	movsbl %al,%eax
 6dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e0:	8b 45 08             	mov    0x8(%ebp),%eax
 6e3:	89 04 24             	mov    %eax,(%esp)
 6e6:	e8 8d fd ff ff       	call   478 <putc>
      }
      state = 0;
 6eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6f2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6f6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fc:	01 d0                	add    %edx,%eax
 6fe:	0f b6 00             	movzbl (%eax),%eax
 701:	84 c0                	test   %al,%al
 703:	0f 85 71 fe ff ff    	jne    57a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 709:	c9                   	leave  
 70a:	c3                   	ret    

0000070b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70b:	55                   	push   %ebp
 70c:	89 e5                	mov    %esp,%ebp
 70e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 711:	8b 45 08             	mov    0x8(%ebp),%eax
 714:	83 e8 08             	sub    $0x8,%eax
 717:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71a:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 71f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 722:	eb 24                	jmp    748 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72c:	77 12                	ja     740 <free+0x35>
 72e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 731:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 734:	77 24                	ja     75a <free+0x4f>
 736:	8b 45 fc             	mov    -0x4(%ebp),%eax
 739:	8b 00                	mov    (%eax),%eax
 73b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 73e:	77 1a                	ja     75a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 00                	mov    (%eax),%eax
 745:	89 45 fc             	mov    %eax,-0x4(%ebp)
 748:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 74e:	76 d4                	jbe    724 <free+0x19>
 750:	8b 45 fc             	mov    -0x4(%ebp),%eax
 753:	8b 00                	mov    (%eax),%eax
 755:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 758:	76 ca                	jbe    724 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 75a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75d:	8b 40 04             	mov    0x4(%eax),%eax
 760:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	01 c2                	add    %eax,%edx
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	8b 00                	mov    (%eax),%eax
 771:	39 c2                	cmp    %eax,%edx
 773:	75 24                	jne    799 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 775:	8b 45 f8             	mov    -0x8(%ebp),%eax
 778:	8b 50 04             	mov    0x4(%eax),%edx
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	8b 00                	mov    (%eax),%eax
 780:	8b 40 04             	mov    0x4(%eax),%eax
 783:	01 c2                	add    %eax,%edx
 785:	8b 45 f8             	mov    -0x8(%ebp),%eax
 788:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	8b 10                	mov    (%eax),%edx
 792:	8b 45 f8             	mov    -0x8(%ebp),%eax
 795:	89 10                	mov    %edx,(%eax)
 797:	eb 0a                	jmp    7a3 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 799:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79c:	8b 10                	mov    (%eax),%edx
 79e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a1:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	8b 40 04             	mov    0x4(%eax),%eax
 7a9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b3:	01 d0                	add    %edx,%eax
 7b5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b8:	75 20                	jne    7da <free+0xcf>
    p->s.size += bp->s.size;
 7ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bd:	8b 50 04             	mov    0x4(%eax),%edx
 7c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c3:	8b 40 04             	mov    0x4(%eax),%eax
 7c6:	01 c2                	add    %eax,%edx
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d1:	8b 10                	mov    (%eax),%edx
 7d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d6:	89 10                	mov    %edx,(%eax)
 7d8:	eb 08                	jmp    7e2 <free+0xd7>
  } else
    p->s.ptr = bp;
 7da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7e0:	89 10                	mov    %edx,(%eax)
  freep = p;
 7e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e5:	a3 cc 0b 00 00       	mov    %eax,0xbcc
}
 7ea:	c9                   	leave  
 7eb:	c3                   	ret    

000007ec <morecore>:

static Header*
morecore(uint nu)
{
 7ec:	55                   	push   %ebp
 7ed:	89 e5                	mov    %esp,%ebp
 7ef:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7f2:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7f9:	77 07                	ja     802 <morecore+0x16>
    nu = 4096;
 7fb:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 802:	8b 45 08             	mov    0x8(%ebp),%eax
 805:	c1 e0 03             	shl    $0x3,%eax
 808:	89 04 24             	mov    %eax,(%esp)
 80b:	e8 08 fc ff ff       	call   418 <sbrk>
 810:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 813:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 817:	75 07                	jne    820 <morecore+0x34>
    return 0;
 819:	b8 00 00 00 00       	mov    $0x0,%eax
 81e:	eb 22                	jmp    842 <morecore+0x56>
  hp = (Header*)p;
 820:	8b 45 f4             	mov    -0xc(%ebp),%eax
 823:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 826:	8b 45 f0             	mov    -0x10(%ebp),%eax
 829:	8b 55 08             	mov    0x8(%ebp),%edx
 82c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 82f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 832:	83 c0 08             	add    $0x8,%eax
 835:	89 04 24             	mov    %eax,(%esp)
 838:	e8 ce fe ff ff       	call   70b <free>
  return freep;
 83d:	a1 cc 0b 00 00       	mov    0xbcc,%eax
}
 842:	c9                   	leave  
 843:	c3                   	ret    

00000844 <malloc>:

void*
malloc(uint nbytes)
{
 844:	55                   	push   %ebp
 845:	89 e5                	mov    %esp,%ebp
 847:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84a:	8b 45 08             	mov    0x8(%ebp),%eax
 84d:	83 c0 07             	add    $0x7,%eax
 850:	c1 e8 03             	shr    $0x3,%eax
 853:	83 c0 01             	add    $0x1,%eax
 856:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 859:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 85e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 861:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 865:	75 23                	jne    88a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 867:	c7 45 f0 c4 0b 00 00 	movl   $0xbc4,-0x10(%ebp)
 86e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 871:	a3 cc 0b 00 00       	mov    %eax,0xbcc
 876:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 87b:	a3 c4 0b 00 00       	mov    %eax,0xbc4
    base.s.size = 0;
 880:	c7 05 c8 0b 00 00 00 	movl   $0x0,0xbc8
 887:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88d:	8b 00                	mov    (%eax),%eax
 88f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	8b 40 04             	mov    0x4(%eax),%eax
 898:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 89b:	72 4d                	jb     8ea <malloc+0xa6>
      if(p->s.size == nunits)
 89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a0:	8b 40 04             	mov    0x4(%eax),%eax
 8a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8a6:	75 0c                	jne    8b4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ab:	8b 10                	mov    (%eax),%edx
 8ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b0:	89 10                	mov    %edx,(%eax)
 8b2:	eb 26                	jmp    8da <malloc+0x96>
      else {
        p->s.size -= nunits;
 8b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b7:	8b 40 04             	mov    0x4(%eax),%eax
 8ba:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8bd:	89 c2                	mov    %eax,%edx
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c8:	8b 40 04             	mov    0x4(%eax),%eax
 8cb:	c1 e0 03             	shl    $0x3,%eax
 8ce:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8d7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8dd:	a3 cc 0b 00 00       	mov    %eax,0xbcc
      return (void*)(p + 1);
 8e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e5:	83 c0 08             	add    $0x8,%eax
 8e8:	eb 38                	jmp    922 <malloc+0xde>
    }
    if(p == freep)
 8ea:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 8ef:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8f2:	75 1b                	jne    90f <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8f7:	89 04 24             	mov    %eax,(%esp)
 8fa:	e8 ed fe ff ff       	call   7ec <morecore>
 8ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
 902:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 906:	75 07                	jne    90f <malloc+0xcb>
        return 0;
 908:	b8 00 00 00 00       	mov    $0x0,%eax
 90d:	eb 13                	jmp    922 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	89 45 f0             	mov    %eax,-0x10(%ebp)
 915:	8b 45 f4             	mov    -0xc(%ebp),%eax
 918:	8b 00                	mov    (%eax),%eax
 91a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 91d:	e9 70 ff ff ff       	jmp    892 <malloc+0x4e>
}
 922:	c9                   	leave  
 923:	c3                   	ret    
