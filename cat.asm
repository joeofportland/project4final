
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 1b                	jmp    23 <cat+0x23>
    write(1, buf, n);
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 e0 0b 00 	movl   $0xbe0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 82 03 00 00       	call   3a5 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 e0 0b 00 	movl   $0xbe0,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 5f 03 00 00       	call   39d <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 19 09 00 	movl   $0x919,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 ec 04 00 00       	call   54d <printf>
    exit();
  61:	e8 1f 03 00 00       	call   385 <exit>
  }
}
  66:	c9                   	leave  
  67:	c3                   	ret    

00000068 <main>:

int
main(int argc, char *argv[])
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	83 e4 f0             	and    $0xfffffff0,%esp
  6e:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  71:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  75:	7f 11                	jg     88 <main+0x20>
    cat(0);
  77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  7e:	e8 7d ff ff ff       	call   0 <cat>
    exit();
  83:	e8 fd 02 00 00       	call   385 <exit>
  }

  for(i = 1; i < argc; i++){
  88:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  8f:	00 
  90:	eb 79                	jmp    10b <main+0xa3>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	01 d0                	add    %edx,%eax
  a2:	8b 00                	mov    (%eax),%eax
  a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ab:	00 
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 11 03 00 00       	call   3c5 <open>
  b4:	89 44 24 18          	mov    %eax,0x18(%esp)
  b8:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  bd:	79 2f                	jns    ee <main+0x86>
      printf(1, "cat: cannot open %s\n", argv[i]);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  cd:	01 d0                	add    %edx,%eax
  cf:	8b 00                	mov    (%eax),%eax
  d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  d5:	c7 44 24 04 2a 09 00 	movl   $0x92a,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e4:	e8 64 04 00 00       	call   54d <printf>
      exit();
  e9:	e8 97 02 00 00       	call   385 <exit>
    }
    cat(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 06 ff ff ff       	call   0 <cat>
    close(fd);
  fa:	8b 44 24 18          	mov    0x18(%esp),%eax
  fe:	89 04 24             	mov    %eax,(%esp)
 101:	e8 a7 02 00 00       	call   3ad <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
 106:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 10b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 10f:	3b 45 08             	cmp    0x8(%ebp),%eax
 112:	0f 8c 7a ff ff ff    	jl     92 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 118:	e8 68 02 00 00       	call   385 <exit>

0000011d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	57                   	push   %edi
 121:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 122:	8b 4d 08             	mov    0x8(%ebp),%ecx
 125:	8b 55 10             	mov    0x10(%ebp),%edx
 128:	8b 45 0c             	mov    0xc(%ebp),%eax
 12b:	89 cb                	mov    %ecx,%ebx
 12d:	89 df                	mov    %ebx,%edi
 12f:	89 d1                	mov    %edx,%ecx
 131:	fc                   	cld    
 132:	f3 aa                	rep stos %al,%es:(%edi)
 134:	89 ca                	mov    %ecx,%edx
 136:	89 fb                	mov    %edi,%ebx
 138:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 13e:	5b                   	pop    %ebx
 13f:	5f                   	pop    %edi
 140:	5d                   	pop    %ebp
 141:	c3                   	ret    

00000142 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 14e:	90                   	nop
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	8d 50 01             	lea    0x1(%eax),%edx
 155:	89 55 08             	mov    %edx,0x8(%ebp)
 158:	8b 55 0c             	mov    0xc(%ebp),%edx
 15b:	8d 4a 01             	lea    0x1(%edx),%ecx
 15e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 161:	0f b6 12             	movzbl (%edx),%edx
 164:	88 10                	mov    %dl,(%eax)
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	84 c0                	test   %al,%al
 16b:	75 e2                	jne    14f <strcpy+0xd>
    ;
  return os;
 16d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 170:	c9                   	leave  
 171:	c3                   	ret    

00000172 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 175:	eb 08                	jmp    17f <strcmp+0xd>
    p++, q++;
 177:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	84 c0                	test   %al,%al
 187:	74 10                	je     199 <strcmp+0x27>
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 10             	movzbl (%eax),%edx
 18f:	8b 45 0c             	mov    0xc(%ebp),%eax
 192:	0f b6 00             	movzbl (%eax),%eax
 195:	38 c2                	cmp    %al,%dl
 197:	74 de                	je     177 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 199:	8b 45 08             	mov    0x8(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	0f b6 d0             	movzbl %al,%edx
 1a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	0f b6 c0             	movzbl %al,%eax
 1ab:	29 c2                	sub    %eax,%edx
 1ad:	89 d0                	mov    %edx,%eax
}
 1af:	5d                   	pop    %ebp
 1b0:	c3                   	ret    

000001b1 <strlen>:

uint
strlen(char *s)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1be:	eb 04                	jmp    1c4 <strlen+0x13>
 1c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ca:	01 d0                	add    %edx,%eax
 1cc:	0f b6 00             	movzbl (%eax),%eax
 1cf:	84 c0                	test   %al,%al
 1d1:	75 ed                	jne    1c0 <strlen+0xf>
    ;
  return n;
 1d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d6:	c9                   	leave  
 1d7:	c3                   	ret    

000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1de:	8b 45 10             	mov    0x10(%ebp),%eax
 1e1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	89 04 24             	mov    %eax,(%esp)
 1f2:	e8 26 ff ff ff       	call   11d <stosb>
  return dst;
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fa:	c9                   	leave  
 1fb:	c3                   	ret    

000001fc <strchr>:

char*
strchr(const char *s, char c)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	83 ec 04             	sub    $0x4,%esp
 202:	8b 45 0c             	mov    0xc(%ebp),%eax
 205:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 208:	eb 14                	jmp    21e <strchr+0x22>
    if(*s == c)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	0f b6 00             	movzbl (%eax),%eax
 210:	3a 45 fc             	cmp    -0x4(%ebp),%al
 213:	75 05                	jne    21a <strchr+0x1e>
      return (char*)s;
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	eb 13                	jmp    22d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 21a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	0f b6 00             	movzbl (%eax),%eax
 224:	84 c0                	test   %al,%al
 226:	75 e2                	jne    20a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 228:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <gets>:

char*
gets(char *buf, int max)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23c:	eb 4c                	jmp    28a <gets+0x5b>
    cc = read(0, &c, 1);
 23e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 245:	00 
 246:	8d 45 ef             	lea    -0x11(%ebp),%eax
 249:	89 44 24 04          	mov    %eax,0x4(%esp)
 24d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 254:	e8 44 01 00 00       	call   39d <read>
 259:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 25c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 260:	7f 02                	jg     264 <gets+0x35>
      break;
 262:	eb 31                	jmp    295 <gets+0x66>
    buf[i++] = c;
 264:	8b 45 f4             	mov    -0xc(%ebp),%eax
 267:	8d 50 01             	lea    0x1(%eax),%edx
 26a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 26d:	89 c2                	mov    %eax,%edx
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
 272:	01 c2                	add    %eax,%edx
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 27a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27e:	3c 0a                	cmp    $0xa,%al
 280:	74 13                	je     295 <gets+0x66>
 282:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 286:	3c 0d                	cmp    $0xd,%al
 288:	74 0b                	je     295 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28d:	83 c0 01             	add    $0x1,%eax
 290:	3b 45 0c             	cmp    0xc(%ebp),%eax
 293:	7c a9                	jl     23e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 295:	8b 55 f4             	mov    -0xc(%ebp),%edx
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	01 d0                	add    %edx,%eax
 29d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <stat>:

int
stat(char *n, struct stat *st)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b2:	00 
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
 2b6:	89 04 24             	mov    %eax,(%esp)
 2b9:	e8 07 01 00 00       	call   3c5 <open>
 2be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c5:	79 07                	jns    2ce <stat+0x29>
    return -1;
 2c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cc:	eb 23                	jmp    2f1 <stat+0x4c>
  r = fstat(fd, st);
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 fd 00 00 00       	call   3dd <fstat>
 2e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e6:	89 04 24             	mov    %eax,(%esp)
 2e9:	e8 bf 00 00 00       	call   3ad <close>
  return r;
 2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f1:	c9                   	leave  
 2f2:	c3                   	ret    

000002f3 <atoi>:

int
atoi(const char *s)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 300:	eb 25                	jmp    327 <atoi+0x34>
    n = n*10 + *s++ - '0';
 302:	8b 55 fc             	mov    -0x4(%ebp),%edx
 305:	89 d0                	mov    %edx,%eax
 307:	c1 e0 02             	shl    $0x2,%eax
 30a:	01 d0                	add    %edx,%eax
 30c:	01 c0                	add    %eax,%eax
 30e:	89 c1                	mov    %eax,%ecx
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	8d 50 01             	lea    0x1(%eax),%edx
 316:	89 55 08             	mov    %edx,0x8(%ebp)
 319:	0f b6 00             	movzbl (%eax),%eax
 31c:	0f be c0             	movsbl %al,%eax
 31f:	01 c8                	add    %ecx,%eax
 321:	83 e8 30             	sub    $0x30,%eax
 324:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	0f b6 00             	movzbl (%eax),%eax
 32d:	3c 2f                	cmp    $0x2f,%al
 32f:	7e 0a                	jle    33b <atoi+0x48>
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	3c 39                	cmp    $0x39,%al
 339:	7e c7                	jle    302 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33e:	c9                   	leave  
 33f:	c3                   	ret    

00000340 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34c:	8b 45 0c             	mov    0xc(%ebp),%eax
 34f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 352:	eb 17                	jmp    36b <memmove+0x2b>
    *dst++ = *src++;
 354:	8b 45 fc             	mov    -0x4(%ebp),%eax
 357:	8d 50 01             	lea    0x1(%eax),%edx
 35a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 35d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 360:	8d 4a 01             	lea    0x1(%edx),%ecx
 363:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 366:	0f b6 12             	movzbl (%edx),%edx
 369:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36b:	8b 45 10             	mov    0x10(%ebp),%eax
 36e:	8d 50 ff             	lea    -0x1(%eax),%edx
 371:	89 55 10             	mov    %edx,0x10(%ebp)
 374:	85 c0                	test   %eax,%eax
 376:	7f dc                	jg     354 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 378:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37b:	c9                   	leave  
 37c:	c3                   	ret    

0000037d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37d:	b8 01 00 00 00       	mov    $0x1,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <exit>:
SYSCALL(exit)
 385:	b8 02 00 00 00       	mov    $0x2,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <wait>:
SYSCALL(wait)
 38d:	b8 03 00 00 00       	mov    $0x3,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <pipe>:
SYSCALL(pipe)
 395:	b8 04 00 00 00       	mov    $0x4,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <read>:
SYSCALL(read)
 39d:	b8 05 00 00 00       	mov    $0x5,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <write>:
SYSCALL(write)
 3a5:	b8 10 00 00 00       	mov    $0x10,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <close>:
SYSCALL(close)
 3ad:	b8 15 00 00 00       	mov    $0x15,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <kill>:
SYSCALL(kill)
 3b5:	b8 06 00 00 00       	mov    $0x6,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <exec>:
SYSCALL(exec)
 3bd:	b8 07 00 00 00       	mov    $0x7,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <open>:
SYSCALL(open)
 3c5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <mknod>:
SYSCALL(mknod)
 3cd:	b8 11 00 00 00       	mov    $0x11,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <unlink>:
SYSCALL(unlink)
 3d5:	b8 12 00 00 00       	mov    $0x12,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <fstat>:
SYSCALL(fstat)
 3dd:	b8 08 00 00 00       	mov    $0x8,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <link>:
SYSCALL(link)
 3e5:	b8 13 00 00 00       	mov    $0x13,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <mkdir>:
SYSCALL(mkdir)
 3ed:	b8 14 00 00 00       	mov    $0x14,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <chdir>:
SYSCALL(chdir)
 3f5:	b8 09 00 00 00       	mov    $0x9,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <dup>:
SYSCALL(dup)
 3fd:	b8 0a 00 00 00       	mov    $0xa,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <getpid>:
SYSCALL(getpid)
 405:	b8 0b 00 00 00       	mov    $0xb,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <sbrk>:
SYSCALL(sbrk)
 40d:	b8 0c 00 00 00       	mov    $0xc,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <sleep>:
SYSCALL(sleep)
 415:	b8 0d 00 00 00       	mov    $0xd,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <uptime>:
SYSCALL(uptime)
 41d:	b8 0e 00 00 00       	mov    $0xe,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <date>:
SYSCALL(date)
 425:	b8 16 00 00 00       	mov    $0x16,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <timem>:
SYSCALL(timem)
 42d:	b8 17 00 00 00       	mov    $0x17,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <getuid>:
SYSCALL(getuid)
 435:	b8 18 00 00 00       	mov    $0x18,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <getgid>:
SYSCALL(getgid)
 43d:	b8 19 00 00 00       	mov    $0x19,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <getppid>:
SYSCALL(getppid)
 445:	b8 1a 00 00 00       	mov    $0x1a,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <setuid>:
SYSCALL(setuid)
 44d:	b8 1b 00 00 00       	mov    $0x1b,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <setgid>:
SYSCALL(setgid)
 455:	b8 1c 00 00 00       	mov    $0x1c,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <getprocs>:
SYSCALL(getprocs)
 45d:	b8 1d 00 00 00       	mov    $0x1d,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <setpriority>:
SYSCALL(setpriority)
 465:	b8 1e 00 00 00       	mov    $0x1e,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 18             	sub    $0x18,%esp
 473:	8b 45 0c             	mov    0xc(%ebp),%eax
 476:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 480:	00 
 481:	8d 45 f4             	lea    -0xc(%ebp),%eax
 484:	89 44 24 04          	mov    %eax,0x4(%esp)
 488:	8b 45 08             	mov    0x8(%ebp),%eax
 48b:	89 04 24             	mov    %eax,(%esp)
 48e:	e8 12 ff ff ff       	call   3a5 <write>
}
 493:	c9                   	leave  
 494:	c3                   	ret    

00000495 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 495:	55                   	push   %ebp
 496:	89 e5                	mov    %esp,%ebp
 498:	56                   	push   %esi
 499:	53                   	push   %ebx
 49a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 49d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4a4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4a8:	74 17                	je     4c1 <printint+0x2c>
 4aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4ae:	79 11                	jns    4c1 <printint+0x2c>
    neg = 1;
 4b0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ba:	f7 d8                	neg    %eax
 4bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4bf:	eb 06                	jmp    4c7 <printint+0x32>
  } else {
    x = xx;
 4c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4ce:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4d1:	8d 41 01             	lea    0x1(%ecx),%eax
 4d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4dd:	ba 00 00 00 00       	mov    $0x0,%edx
 4e2:	f7 f3                	div    %ebx
 4e4:	89 d0                	mov    %edx,%eax
 4e6:	0f b6 80 ac 0b 00 00 	movzbl 0xbac(%eax),%eax
 4ed:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4f1:	8b 75 10             	mov    0x10(%ebp),%esi
 4f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4f7:	ba 00 00 00 00       	mov    $0x0,%edx
 4fc:	f7 f6                	div    %esi
 4fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
 501:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 505:	75 c7                	jne    4ce <printint+0x39>
  if(neg)
 507:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 50b:	74 10                	je     51d <printint+0x88>
    buf[i++] = '-';
 50d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 510:	8d 50 01             	lea    0x1(%eax),%edx
 513:	89 55 f4             	mov    %edx,-0xc(%ebp)
 516:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 51b:	eb 1f                	jmp    53c <printint+0xa7>
 51d:	eb 1d                	jmp    53c <printint+0xa7>
    putc(fd, buf[i]);
 51f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 522:	8b 45 f4             	mov    -0xc(%ebp),%eax
 525:	01 d0                	add    %edx,%eax
 527:	0f b6 00             	movzbl (%eax),%eax
 52a:	0f be c0             	movsbl %al,%eax
 52d:	89 44 24 04          	mov    %eax,0x4(%esp)
 531:	8b 45 08             	mov    0x8(%ebp),%eax
 534:	89 04 24             	mov    %eax,(%esp)
 537:	e8 31 ff ff ff       	call   46d <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 53c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 540:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 544:	79 d9                	jns    51f <printint+0x8a>
    putc(fd, buf[i]);
}
 546:	83 c4 30             	add    $0x30,%esp
 549:	5b                   	pop    %ebx
 54a:	5e                   	pop    %esi
 54b:	5d                   	pop    %ebp
 54c:	c3                   	ret    

0000054d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 54d:	55                   	push   %ebp
 54e:	89 e5                	mov    %esp,%ebp
 550:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 553:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 55a:	8d 45 0c             	lea    0xc(%ebp),%eax
 55d:	83 c0 04             	add    $0x4,%eax
 560:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 563:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 56a:	e9 7c 01 00 00       	jmp    6eb <printf+0x19e>
    c = fmt[i] & 0xff;
 56f:	8b 55 0c             	mov    0xc(%ebp),%edx
 572:	8b 45 f0             	mov    -0x10(%ebp),%eax
 575:	01 d0                	add    %edx,%eax
 577:	0f b6 00             	movzbl (%eax),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	25 ff 00 00 00       	and    $0xff,%eax
 582:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 585:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 589:	75 2c                	jne    5b7 <printf+0x6a>
      if(c == '%'){
 58b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 58f:	75 0c                	jne    59d <printf+0x50>
        state = '%';
 591:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 598:	e9 4a 01 00 00       	jmp    6e7 <printf+0x19a>
      } else {
        putc(fd, c);
 59d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a0:	0f be c0             	movsbl %al,%eax
 5a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a7:	8b 45 08             	mov    0x8(%ebp),%eax
 5aa:	89 04 24             	mov    %eax,(%esp)
 5ad:	e8 bb fe ff ff       	call   46d <putc>
 5b2:	e9 30 01 00 00       	jmp    6e7 <printf+0x19a>
      }
    } else if(state == '%'){
 5b7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5bb:	0f 85 26 01 00 00    	jne    6e7 <printf+0x19a>
      if(c == 'd'){
 5c1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5c5:	75 2d                	jne    5f4 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ca:	8b 00                	mov    (%eax),%eax
 5cc:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5d3:	00 
 5d4:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5db:	00 
 5dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e0:	8b 45 08             	mov    0x8(%ebp),%eax
 5e3:	89 04 24             	mov    %eax,(%esp)
 5e6:	e8 aa fe ff ff       	call   495 <printint>
        ap++;
 5eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ef:	e9 ec 00 00 00       	jmp    6e0 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5f4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5f8:	74 06                	je     600 <printf+0xb3>
 5fa:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5fe:	75 2d                	jne    62d <printf+0xe0>
        printint(fd, *ap, 16, 0);
 600:	8b 45 e8             	mov    -0x18(%ebp),%eax
 603:	8b 00                	mov    (%eax),%eax
 605:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 60c:	00 
 60d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 614:	00 
 615:	89 44 24 04          	mov    %eax,0x4(%esp)
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	89 04 24             	mov    %eax,(%esp)
 61f:	e8 71 fe ff ff       	call   495 <printint>
        ap++;
 624:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 628:	e9 b3 00 00 00       	jmp    6e0 <printf+0x193>
      } else if(c == 's'){
 62d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 631:	75 45                	jne    678 <printf+0x12b>
        s = (char*)*ap;
 633:	8b 45 e8             	mov    -0x18(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 63b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 63f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 643:	75 09                	jne    64e <printf+0x101>
          s = "(null)";
 645:	c7 45 f4 3f 09 00 00 	movl   $0x93f,-0xc(%ebp)
        while(*s != 0){
 64c:	eb 1e                	jmp    66c <printf+0x11f>
 64e:	eb 1c                	jmp    66c <printf+0x11f>
          putc(fd, *s);
 650:	8b 45 f4             	mov    -0xc(%ebp),%eax
 653:	0f b6 00             	movzbl (%eax),%eax
 656:	0f be c0             	movsbl %al,%eax
 659:	89 44 24 04          	mov    %eax,0x4(%esp)
 65d:	8b 45 08             	mov    0x8(%ebp),%eax
 660:	89 04 24             	mov    %eax,(%esp)
 663:	e8 05 fe ff ff       	call   46d <putc>
          s++;
 668:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 66c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66f:	0f b6 00             	movzbl (%eax),%eax
 672:	84 c0                	test   %al,%al
 674:	75 da                	jne    650 <printf+0x103>
 676:	eb 68                	jmp    6e0 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 678:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 67c:	75 1d                	jne    69b <printf+0x14e>
        putc(fd, *ap);
 67e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 681:	8b 00                	mov    (%eax),%eax
 683:	0f be c0             	movsbl %al,%eax
 686:	89 44 24 04          	mov    %eax,0x4(%esp)
 68a:	8b 45 08             	mov    0x8(%ebp),%eax
 68d:	89 04 24             	mov    %eax,(%esp)
 690:	e8 d8 fd ff ff       	call   46d <putc>
        ap++;
 695:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 699:	eb 45                	jmp    6e0 <printf+0x193>
      } else if(c == '%'){
 69b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 69f:	75 17                	jne    6b8 <printf+0x16b>
        putc(fd, c);
 6a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a4:	0f be c0             	movsbl %al,%eax
 6a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	89 04 24             	mov    %eax,(%esp)
 6b1:	e8 b7 fd ff ff       	call   46d <putc>
 6b6:	eb 28                	jmp    6e0 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6b8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6bf:	00 
 6c0:	8b 45 08             	mov    0x8(%ebp),%eax
 6c3:	89 04 24             	mov    %eax,(%esp)
 6c6:	e8 a2 fd ff ff       	call   46d <putc>
        putc(fd, c);
 6cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ce:	0f be c0             	movsbl %al,%eax
 6d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d5:	8b 45 08             	mov    0x8(%ebp),%eax
 6d8:	89 04 24             	mov    %eax,(%esp)
 6db:	e8 8d fd ff ff       	call   46d <putc>
      }
      state = 0;
 6e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6e7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6eb:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f1:	01 d0                	add    %edx,%eax
 6f3:	0f b6 00             	movzbl (%eax),%eax
 6f6:	84 c0                	test   %al,%al
 6f8:	0f 85 71 fe ff ff    	jne    56f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6fe:	c9                   	leave  
 6ff:	c3                   	ret    

00000700 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 700:	55                   	push   %ebp
 701:	89 e5                	mov    %esp,%ebp
 703:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	83 e8 08             	sub    $0x8,%eax
 70c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70f:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 714:	89 45 fc             	mov    %eax,-0x4(%ebp)
 717:	eb 24                	jmp    73d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 719:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71c:	8b 00                	mov    (%eax),%eax
 71e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 721:	77 12                	ja     735 <free+0x35>
 723:	8b 45 f8             	mov    -0x8(%ebp),%eax
 726:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 729:	77 24                	ja     74f <free+0x4f>
 72b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72e:	8b 00                	mov    (%eax),%eax
 730:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 733:	77 1a                	ja     74f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	8b 00                	mov    (%eax),%eax
 73a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 73d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 740:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 743:	76 d4                	jbe    719 <free+0x19>
 745:	8b 45 fc             	mov    -0x4(%ebp),%eax
 748:	8b 00                	mov    (%eax),%eax
 74a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 74d:	76 ca                	jbe    719 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 74f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 752:	8b 40 04             	mov    0x4(%eax),%eax
 755:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 75c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75f:	01 c2                	add    %eax,%edx
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	8b 00                	mov    (%eax),%eax
 766:	39 c2                	cmp    %eax,%edx
 768:	75 24                	jne    78e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 76a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76d:	8b 50 04             	mov    0x4(%eax),%edx
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	8b 00                	mov    (%eax),%eax
 775:	8b 40 04             	mov    0x4(%eax),%eax
 778:	01 c2                	add    %eax,%edx
 77a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	8b 45 fc             	mov    -0x4(%ebp),%eax
 783:	8b 00                	mov    (%eax),%eax
 785:	8b 10                	mov    (%eax),%edx
 787:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78a:	89 10                	mov    %edx,(%eax)
 78c:	eb 0a                	jmp    798 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 78e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 791:	8b 10                	mov    (%eax),%edx
 793:	8b 45 f8             	mov    -0x8(%ebp),%eax
 796:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 798:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79b:	8b 40 04             	mov    0x4(%eax),%eax
 79e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	01 d0                	add    %edx,%eax
 7aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ad:	75 20                	jne    7cf <free+0xcf>
    p->s.size += bp->s.size;
 7af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b2:	8b 50 04             	mov    0x4(%eax),%edx
 7b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b8:	8b 40 04             	mov    0x4(%eax),%eax
 7bb:	01 c2                	add    %eax,%edx
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c6:	8b 10                	mov    (%eax),%edx
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	89 10                	mov    %edx,(%eax)
 7cd:	eb 08                	jmp    7d7 <free+0xd7>
  } else
    p->s.ptr = bp;
 7cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7d5:	89 10                	mov    %edx,(%eax)
  freep = p;
 7d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7da:	a3 c8 0b 00 00       	mov    %eax,0xbc8
}
 7df:	c9                   	leave  
 7e0:	c3                   	ret    

000007e1 <morecore>:

static Header*
morecore(uint nu)
{
 7e1:	55                   	push   %ebp
 7e2:	89 e5                	mov    %esp,%ebp
 7e4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7e7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ee:	77 07                	ja     7f7 <morecore+0x16>
    nu = 4096;
 7f0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7f7:	8b 45 08             	mov    0x8(%ebp),%eax
 7fa:	c1 e0 03             	shl    $0x3,%eax
 7fd:	89 04 24             	mov    %eax,(%esp)
 800:	e8 08 fc ff ff       	call   40d <sbrk>
 805:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 808:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 80c:	75 07                	jne    815 <morecore+0x34>
    return 0;
 80e:	b8 00 00 00 00       	mov    $0x0,%eax
 813:	eb 22                	jmp    837 <morecore+0x56>
  hp = (Header*)p;
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 81b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81e:	8b 55 08             	mov    0x8(%ebp),%edx
 821:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 824:	8b 45 f0             	mov    -0x10(%ebp),%eax
 827:	83 c0 08             	add    $0x8,%eax
 82a:	89 04 24             	mov    %eax,(%esp)
 82d:	e8 ce fe ff ff       	call   700 <free>
  return freep;
 832:	a1 c8 0b 00 00       	mov    0xbc8,%eax
}
 837:	c9                   	leave  
 838:	c3                   	ret    

00000839 <malloc>:

void*
malloc(uint nbytes)
{
 839:	55                   	push   %ebp
 83a:	89 e5                	mov    %esp,%ebp
 83c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83f:	8b 45 08             	mov    0x8(%ebp),%eax
 842:	83 c0 07             	add    $0x7,%eax
 845:	c1 e8 03             	shr    $0x3,%eax
 848:	83 c0 01             	add    $0x1,%eax
 84b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 84e:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 853:	89 45 f0             	mov    %eax,-0x10(%ebp)
 856:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 85a:	75 23                	jne    87f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 85c:	c7 45 f0 c0 0b 00 00 	movl   $0xbc0,-0x10(%ebp)
 863:	8b 45 f0             	mov    -0x10(%ebp),%eax
 866:	a3 c8 0b 00 00       	mov    %eax,0xbc8
 86b:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 870:	a3 c0 0b 00 00       	mov    %eax,0xbc0
    base.s.size = 0;
 875:	c7 05 c4 0b 00 00 00 	movl   $0x0,0xbc4
 87c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 882:	8b 00                	mov    (%eax),%eax
 884:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 887:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88a:	8b 40 04             	mov    0x4(%eax),%eax
 88d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 890:	72 4d                	jb     8df <malloc+0xa6>
      if(p->s.size == nunits)
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	8b 40 04             	mov    0x4(%eax),%eax
 898:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 89b:	75 0c                	jne    8a9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a0:	8b 10                	mov    (%eax),%edx
 8a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a5:	89 10                	mov    %edx,(%eax)
 8a7:	eb 26                	jmp    8cf <malloc+0x96>
      else {
        p->s.size -= nunits;
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	8b 40 04             	mov    0x4(%eax),%eax
 8af:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8b2:	89 c2                	mov    %eax,%edx
 8b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bd:	8b 40 04             	mov    0x4(%eax),%eax
 8c0:	c1 e0 03             	shl    $0x3,%eax
 8c3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8cc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d2:	a3 c8 0b 00 00       	mov    %eax,0xbc8
      return (void*)(p + 1);
 8d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8da:	83 c0 08             	add    $0x8,%eax
 8dd:	eb 38                	jmp    917 <malloc+0xde>
    }
    if(p == freep)
 8df:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 8e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8e7:	75 1b                	jne    904 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8ec:	89 04 24             	mov    %eax,(%esp)
 8ef:	e8 ed fe ff ff       	call   7e1 <morecore>
 8f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8fb:	75 07                	jne    904 <malloc+0xcb>
        return 0;
 8fd:	b8 00 00 00 00       	mov    $0x0,%eax
 902:	eb 13                	jmp    917 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	8b 45 f4             	mov    -0xc(%ebp),%eax
 907:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90d:	8b 00                	mov    (%eax),%eax
 90f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 912:	e9 70 ff ff ff       	jmp    887 <malloc+0x4e>
}
 917:	c9                   	leave  
 918:	c3                   	ret    
