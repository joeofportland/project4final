
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <printTableEntry>:

#define MAX 10

void
printTableEntry(struct uproc* t)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 3c             	sub    $0x3c,%esp
  printf(2, "pid: %d, priority: %d, name: %s\n      uid: %d  gid: %d   ppid: %d  state: %s  size: %d\n",
   9:	8b 45 08             	mov    0x8(%ebp),%eax
   c:	8b 48 24             	mov    0x24(%eax),%ecx
        t->pid,t->priority, t->name, t->uid, t->gid, t->ppid,
        t->state, t->size);
   f:	8b 45 08             	mov    0x8(%ebp),%eax
  12:	83 c0 14             	add    $0x14,%eax
  15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#define MAX 10

void
printTableEntry(struct uproc* t)
{
  printf(2, "pid: %d, priority: %d, name: %s\n      uid: %d  gid: %d   ppid: %d  state: %s  size: %d\n",
  18:	8b 45 08             	mov    0x8(%ebp),%eax
  1b:	8b 78 0c             	mov    0xc(%eax),%edi
  1e:	8b 45 08             	mov    0x8(%ebp),%eax
  21:	8b 70 08             	mov    0x8(%eax),%esi
  24:	8b 45 08             	mov    0x8(%ebp),%eax
  27:	8b 58 04             	mov    0x4(%eax),%ebx
        t->pid,t->priority, t->name, t->uid, t->gid, t->ppid,
  2a:	8b 45 08             	mov    0x8(%ebp),%eax
  2d:	8d 50 28             	lea    0x28(%eax),%edx
  30:	89 55 e0             	mov    %edx,-0x20(%ebp)
#define MAX 10

void
printTableEntry(struct uproc* t)
{
  printf(2, "pid: %d, priority: %d, name: %s\n      uid: %d  gid: %d   ppid: %d  state: %s  size: %d\n",
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	8b 50 10             	mov    0x10(%eax),%edx
  39:	8b 45 08             	mov    0x8(%ebp),%eax
  3c:	8b 00                	mov    (%eax),%eax
  3e:	89 4c 24 24          	mov    %ecx,0x24(%esp)
  42:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  45:	89 4c 24 20          	mov    %ecx,0x20(%esp)
  49:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
  4d:	89 74 24 18          	mov    %esi,0x18(%esp)
  51:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  55:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  58:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  60:	89 44 24 08          	mov    %eax,0x8(%esp)
  64:	c7 44 24 04 24 09 00 	movl   $0x924,0x4(%esp)
  6b:	00 
  6c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  73:	e8 df 04 00 00       	call   557 <printf>
        t->pid,t->priority, t->name, t->uid, t->gid, t->ppid,
        t->state, t->size);
  return;
  78:	90                   	nop
}
  79:	83 c4 3c             	add    $0x3c,%esp
  7c:	5b                   	pop    %ebx
  7d:	5e                   	pop    %esi
  7e:	5f                   	pop    %edi
  7f:	5d                   	pop    %ebp
  80:	c3                   	ret    

00000081 <main>:

int
main(int argc, char* argv[]) {
  81:	55                   	push   %ebp
  82:	89 e5                	mov    %esp,%ebp
  84:	83 e4 f0             	and    $0xfffffff0,%esp
  87:	81 ec 50 02 00 00    	sub    $0x250,%esp
  int i, rc;
  struct uproc table[MAX];

  rc = getprocs(MAX, table);
  8d:	8d 44 24 18          	lea    0x18(%esp),%eax
  91:	89 44 24 04          	mov    %eax,0x4(%esp)
  95:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  9c:	e8 c6 03 00 00       	call   467 <getprocs>
  a1:	89 84 24 48 02 00 00 	mov    %eax,0x248(%esp)

  if (rc < 0) {
  a8:	83 bc 24 48 02 00 00 	cmpl   $0x0,0x248(%esp)
  af:	00 
  b0:	79 29                	jns    db <main+0x5a>
    printf(2, "Error: getprocs call failed. %s at line %d\n", __FILE__, __LINE__);
  b2:	c7 44 24 0c 18 00 00 	movl   $0x18,0xc(%esp)
  b9:	00 
  ba:	c7 44 24 08 7c 09 00 	movl   $0x97c,0x8(%esp)
  c1:	00 
  c2:	c7 44 24 04 84 09 00 	movl   $0x984,0x4(%esp)
  c9:	00 
  ca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  d1:	e8 81 04 00 00       	call   557 <printf>
    exit();
  d6:	e8 b4 02 00 00       	call   38f <exit>
  }

  for (i=0; i<rc; i++) {
  db:	c7 84 24 4c 02 00 00 	movl   $0x0,0x24c(%esp)
  e2:	00 00 00 00 
  e6:	eb 2a                	jmp    112 <main+0x91>
    printTableEntry(&table[i]);
  e8:	8d 4c 24 18          	lea    0x18(%esp),%ecx
  ec:	8b 84 24 4c 02 00 00 	mov    0x24c(%esp),%eax
  f3:	c1 e0 03             	shl    $0x3,%eax
  f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  fd:	29 c2                	sub    %eax,%edx
  ff:	8d 04 11             	lea    (%ecx,%edx,1),%eax
 102:	89 04 24             	mov    %eax,(%esp)
 105:	e8 f6 fe ff ff       	call   0 <printTableEntry>
  if (rc < 0) {
    printf(2, "Error: getprocs call failed. %s at line %d\n", __FILE__, __LINE__);
    exit();
  }

  for (i=0; i<rc; i++) {
 10a:	83 84 24 4c 02 00 00 	addl   $0x1,0x24c(%esp)
 111:	01 
 112:	8b 84 24 4c 02 00 00 	mov    0x24c(%esp),%eax
 119:	3b 84 24 48 02 00 00 	cmp    0x248(%esp),%eax
 120:	7c c6                	jl     e8 <main+0x67>





  exit();
 122:	e8 68 02 00 00       	call   38f <exit>

00000127 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	57                   	push   %edi
 12b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 12c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 12f:	8b 55 10             	mov    0x10(%ebp),%edx
 132:	8b 45 0c             	mov    0xc(%ebp),%eax
 135:	89 cb                	mov    %ecx,%ebx
 137:	89 df                	mov    %ebx,%edi
 139:	89 d1                	mov    %edx,%ecx
 13b:	fc                   	cld    
 13c:	f3 aa                	rep stos %al,%es:(%edi)
 13e:	89 ca                	mov    %ecx,%edx
 140:	89 fb                	mov    %edi,%ebx
 142:	89 5d 08             	mov    %ebx,0x8(%ebp)
 145:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 148:	5b                   	pop    %ebx
 149:	5f                   	pop    %edi
 14a:	5d                   	pop    %ebp
 14b:	c3                   	ret    

0000014c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 152:	8b 45 08             	mov    0x8(%ebp),%eax
 155:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 158:	90                   	nop
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	8d 50 01             	lea    0x1(%eax),%edx
 15f:	89 55 08             	mov    %edx,0x8(%ebp)
 162:	8b 55 0c             	mov    0xc(%ebp),%edx
 165:	8d 4a 01             	lea    0x1(%edx),%ecx
 168:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 16b:	0f b6 12             	movzbl (%edx),%edx
 16e:	88 10                	mov    %dl,(%eax)
 170:	0f b6 00             	movzbl (%eax),%eax
 173:	84 c0                	test   %al,%al
 175:	75 e2                	jne    159 <strcpy+0xd>
    ;
  return os;
 177:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17a:	c9                   	leave  
 17b:	c3                   	ret    

0000017c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 17f:	eb 08                	jmp    189 <strcmp+0xd>
    p++, q++;
 181:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 185:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	84 c0                	test   %al,%al
 191:	74 10                	je     1a3 <strcmp+0x27>
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	0f b6 10             	movzbl (%eax),%edx
 199:	8b 45 0c             	mov    0xc(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	38 c2                	cmp    %al,%dl
 1a1:	74 de                	je     181 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a3:	8b 45 08             	mov    0x8(%ebp),%eax
 1a6:	0f b6 00             	movzbl (%eax),%eax
 1a9:	0f b6 d0             	movzbl %al,%edx
 1ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 1af:	0f b6 00             	movzbl (%eax),%eax
 1b2:	0f b6 c0             	movzbl %al,%eax
 1b5:	29 c2                	sub    %eax,%edx
 1b7:	89 d0                	mov    %edx,%eax
}
 1b9:	5d                   	pop    %ebp
 1ba:	c3                   	ret    

000001bb <strlen>:

uint
strlen(char *s)
{
 1bb:	55                   	push   %ebp
 1bc:	89 e5                	mov    %esp,%ebp
 1be:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c8:	eb 04                	jmp    1ce <strlen+0x13>
 1ca:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
 1d4:	01 d0                	add    %edx,%eax
 1d6:	0f b6 00             	movzbl (%eax),%eax
 1d9:	84 c0                	test   %al,%al
 1db:	75 ed                	jne    1ca <strlen+0xf>
    ;
  return n;
 1dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e0:	c9                   	leave  
 1e1:	c3                   	ret    

000001e2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1e8:	8b 45 10             	mov    0x10(%ebp),%eax
 1eb:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	89 04 24             	mov    %eax,(%esp)
 1fc:	e8 26 ff ff ff       	call   127 <stosb>
  return dst;
 201:	8b 45 08             	mov    0x8(%ebp),%eax
}
 204:	c9                   	leave  
 205:	c3                   	ret    

00000206 <strchr>:

char*
strchr(const char *s, char c)
{
 206:	55                   	push   %ebp
 207:	89 e5                	mov    %esp,%ebp
 209:	83 ec 04             	sub    $0x4,%esp
 20c:	8b 45 0c             	mov    0xc(%ebp),%eax
 20f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 212:	eb 14                	jmp    228 <strchr+0x22>
    if(*s == c)
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	3a 45 fc             	cmp    -0x4(%ebp),%al
 21d:	75 05                	jne    224 <strchr+0x1e>
      return (char*)s;
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
 222:	eb 13                	jmp    237 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 224:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	0f b6 00             	movzbl (%eax),%eax
 22e:	84 c0                	test   %al,%al
 230:	75 e2                	jne    214 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 232:	b8 00 00 00 00       	mov    $0x0,%eax
}
 237:	c9                   	leave  
 238:	c3                   	ret    

00000239 <gets>:

char*
gets(char *buf, int max)
{
 239:	55                   	push   %ebp
 23a:	89 e5                	mov    %esp,%ebp
 23c:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 246:	eb 4c                	jmp    294 <gets+0x5b>
    cc = read(0, &c, 1);
 248:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 24f:	00 
 250:	8d 45 ef             	lea    -0x11(%ebp),%eax
 253:	89 44 24 04          	mov    %eax,0x4(%esp)
 257:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25e:	e8 44 01 00 00       	call   3a7 <read>
 263:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 266:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 26a:	7f 02                	jg     26e <gets+0x35>
      break;
 26c:	eb 31                	jmp    29f <gets+0x66>
    buf[i++] = c;
 26e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 271:	8d 50 01             	lea    0x1(%eax),%edx
 274:	89 55 f4             	mov    %edx,-0xc(%ebp)
 277:	89 c2                	mov    %eax,%edx
 279:	8b 45 08             	mov    0x8(%ebp),%eax
 27c:	01 c2                	add    %eax,%edx
 27e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 282:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 284:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 288:	3c 0a                	cmp    $0xa,%al
 28a:	74 13                	je     29f <gets+0x66>
 28c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 290:	3c 0d                	cmp    $0xd,%al
 292:	74 0b                	je     29f <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 294:	8b 45 f4             	mov    -0xc(%ebp),%eax
 297:	83 c0 01             	add    $0x1,%eax
 29a:	3b 45 0c             	cmp    0xc(%ebp),%eax
 29d:	7c a9                	jl     248 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 29f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
 2a5:	01 d0                	add    %edx,%eax
 2a7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ad:	c9                   	leave  
 2ae:	c3                   	ret    

000002af <stat>:

int
stat(char *n, struct stat *st)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
 2b2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2bc:	00 
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	89 04 24             	mov    %eax,(%esp)
 2c3:	e8 07 01 00 00       	call   3cf <open>
 2c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2cf:	79 07                	jns    2d8 <stat+0x29>
    return -1;
 2d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2d6:	eb 23                	jmp    2fb <stat+0x4c>
  r = fstat(fd, st);
 2d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2db:	89 44 24 04          	mov    %eax,0x4(%esp)
 2df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e2:	89 04 24             	mov    %eax,(%esp)
 2e5:	e8 fd 00 00 00       	call   3e7 <fstat>
 2ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f0:	89 04 24             	mov    %eax,(%esp)
 2f3:	e8 bf 00 00 00       	call   3b7 <close>
  return r;
 2f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2fb:	c9                   	leave  
 2fc:	c3                   	ret    

000002fd <atoi>:

int
atoi(const char *s)
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 303:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 30a:	eb 25                	jmp    331 <atoi+0x34>
    n = n*10 + *s++ - '0';
 30c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 30f:	89 d0                	mov    %edx,%eax
 311:	c1 e0 02             	shl    $0x2,%eax
 314:	01 d0                	add    %edx,%eax
 316:	01 c0                	add    %eax,%eax
 318:	89 c1                	mov    %eax,%ecx
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	8d 50 01             	lea    0x1(%eax),%edx
 320:	89 55 08             	mov    %edx,0x8(%ebp)
 323:	0f b6 00             	movzbl (%eax),%eax
 326:	0f be c0             	movsbl %al,%eax
 329:	01 c8                	add    %ecx,%eax
 32b:	83 e8 30             	sub    $0x30,%eax
 32e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	3c 2f                	cmp    $0x2f,%al
 339:	7e 0a                	jle    345 <atoi+0x48>
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
 33e:	0f b6 00             	movzbl (%eax),%eax
 341:	3c 39                	cmp    $0x39,%al
 343:	7e c7                	jle    30c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 345:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 348:	c9                   	leave  
 349:	c3                   	ret    

0000034a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 350:	8b 45 08             	mov    0x8(%ebp),%eax
 353:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 35c:	eb 17                	jmp    375 <memmove+0x2b>
    *dst++ = *src++;
 35e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 361:	8d 50 01             	lea    0x1(%eax),%edx
 364:	89 55 fc             	mov    %edx,-0x4(%ebp)
 367:	8b 55 f8             	mov    -0x8(%ebp),%edx
 36a:	8d 4a 01             	lea    0x1(%edx),%ecx
 36d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 370:	0f b6 12             	movzbl (%edx),%edx
 373:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 375:	8b 45 10             	mov    0x10(%ebp),%eax
 378:	8d 50 ff             	lea    -0x1(%eax),%edx
 37b:	89 55 10             	mov    %edx,0x10(%ebp)
 37e:	85 c0                	test   %eax,%eax
 380:	7f dc                	jg     35e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 382:	8b 45 08             	mov    0x8(%ebp),%eax
}
 385:	c9                   	leave  
 386:	c3                   	ret    

00000387 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 387:	b8 01 00 00 00       	mov    $0x1,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <exit>:
SYSCALL(exit)
 38f:	b8 02 00 00 00       	mov    $0x2,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <wait>:
SYSCALL(wait)
 397:	b8 03 00 00 00       	mov    $0x3,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <pipe>:
SYSCALL(pipe)
 39f:	b8 04 00 00 00       	mov    $0x4,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <read>:
SYSCALL(read)
 3a7:	b8 05 00 00 00       	mov    $0x5,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <write>:
SYSCALL(write)
 3af:	b8 10 00 00 00       	mov    $0x10,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <close>:
SYSCALL(close)
 3b7:	b8 15 00 00 00       	mov    $0x15,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <kill>:
SYSCALL(kill)
 3bf:	b8 06 00 00 00       	mov    $0x6,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <exec>:
SYSCALL(exec)
 3c7:	b8 07 00 00 00       	mov    $0x7,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <open>:
SYSCALL(open)
 3cf:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <mknod>:
SYSCALL(mknod)
 3d7:	b8 11 00 00 00       	mov    $0x11,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <unlink>:
SYSCALL(unlink)
 3df:	b8 12 00 00 00       	mov    $0x12,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <fstat>:
SYSCALL(fstat)
 3e7:	b8 08 00 00 00       	mov    $0x8,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <link>:
SYSCALL(link)
 3ef:	b8 13 00 00 00       	mov    $0x13,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <mkdir>:
SYSCALL(mkdir)
 3f7:	b8 14 00 00 00       	mov    $0x14,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <chdir>:
SYSCALL(chdir)
 3ff:	b8 09 00 00 00       	mov    $0x9,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <dup>:
SYSCALL(dup)
 407:	b8 0a 00 00 00       	mov    $0xa,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <getpid>:
SYSCALL(getpid)
 40f:	b8 0b 00 00 00       	mov    $0xb,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <sbrk>:
SYSCALL(sbrk)
 417:	b8 0c 00 00 00       	mov    $0xc,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <sleep>:
SYSCALL(sleep)
 41f:	b8 0d 00 00 00       	mov    $0xd,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <uptime>:
SYSCALL(uptime)
 427:	b8 0e 00 00 00       	mov    $0xe,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <date>:
SYSCALL(date)
 42f:	b8 16 00 00 00       	mov    $0x16,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <timem>:
SYSCALL(timem)
 437:	b8 17 00 00 00       	mov    $0x17,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <getuid>:
SYSCALL(getuid)
 43f:	b8 18 00 00 00       	mov    $0x18,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <getgid>:
SYSCALL(getgid)
 447:	b8 19 00 00 00       	mov    $0x19,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <getppid>:
SYSCALL(getppid)
 44f:	b8 1a 00 00 00       	mov    $0x1a,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <setuid>:
SYSCALL(setuid)
 457:	b8 1b 00 00 00       	mov    $0x1b,%eax
 45c:	cd 40                	int    $0x40
 45e:	c3                   	ret    

0000045f <setgid>:
SYSCALL(setgid)
 45f:	b8 1c 00 00 00       	mov    $0x1c,%eax
 464:	cd 40                	int    $0x40
 466:	c3                   	ret    

00000467 <getprocs>:
SYSCALL(getprocs)
 467:	b8 1d 00 00 00       	mov    $0x1d,%eax
 46c:	cd 40                	int    $0x40
 46e:	c3                   	ret    

0000046f <setpriority>:
SYSCALL(setpriority)
 46f:	b8 1e 00 00 00       	mov    $0x1e,%eax
 474:	cd 40                	int    $0x40
 476:	c3                   	ret    

00000477 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 477:	55                   	push   %ebp
 478:	89 e5                	mov    %esp,%ebp
 47a:	83 ec 18             	sub    $0x18,%esp
 47d:	8b 45 0c             	mov    0xc(%ebp),%eax
 480:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 483:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 48a:	00 
 48b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 48e:	89 44 24 04          	mov    %eax,0x4(%esp)
 492:	8b 45 08             	mov    0x8(%ebp),%eax
 495:	89 04 24             	mov    %eax,(%esp)
 498:	e8 12 ff ff ff       	call   3af <write>
}
 49d:	c9                   	leave  
 49e:	c3                   	ret    

0000049f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49f:	55                   	push   %ebp
 4a0:	89 e5                	mov    %esp,%ebp
 4a2:	56                   	push   %esi
 4a3:	53                   	push   %ebx
 4a4:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4ae:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4b2:	74 17                	je     4cb <printint+0x2c>
 4b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4b8:	79 11                	jns    4cb <printint+0x2c>
    neg = 1;
 4ba:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c4:	f7 d8                	neg    %eax
 4c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4c9:	eb 06                	jmp    4d1 <printint+0x32>
  } else {
    x = xx;
 4cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4d8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4db:	8d 41 01             	lea    0x1(%ecx),%eax
 4de:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e7:	ba 00 00 00 00       	mov    $0x0,%edx
 4ec:	f7 f3                	div    %ebx
 4ee:	89 d0                	mov    %edx,%eax
 4f0:	0f b6 80 28 0c 00 00 	movzbl 0xc28(%eax),%eax
 4f7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4fb:	8b 75 10             	mov    0x10(%ebp),%esi
 4fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
 501:	ba 00 00 00 00       	mov    $0x0,%edx
 506:	f7 f6                	div    %esi
 508:	89 45 ec             	mov    %eax,-0x14(%ebp)
 50b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 50f:	75 c7                	jne    4d8 <printint+0x39>
  if(neg)
 511:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 515:	74 10                	je     527 <printint+0x88>
    buf[i++] = '-';
 517:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51a:	8d 50 01             	lea    0x1(%eax),%edx
 51d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 520:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 525:	eb 1f                	jmp    546 <printint+0xa7>
 527:	eb 1d                	jmp    546 <printint+0xa7>
    putc(fd, buf[i]);
 529:	8d 55 dc             	lea    -0x24(%ebp),%edx
 52c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52f:	01 d0                	add    %edx,%eax
 531:	0f b6 00             	movzbl (%eax),%eax
 534:	0f be c0             	movsbl %al,%eax
 537:	89 44 24 04          	mov    %eax,0x4(%esp)
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	89 04 24             	mov    %eax,(%esp)
 541:	e8 31 ff ff ff       	call   477 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 546:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 54a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 54e:	79 d9                	jns    529 <printint+0x8a>
    putc(fd, buf[i]);
}
 550:	83 c4 30             	add    $0x30,%esp
 553:	5b                   	pop    %ebx
 554:	5e                   	pop    %esi
 555:	5d                   	pop    %ebp
 556:	c3                   	ret    

00000557 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 557:	55                   	push   %ebp
 558:	89 e5                	mov    %esp,%ebp
 55a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 55d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 564:	8d 45 0c             	lea    0xc(%ebp),%eax
 567:	83 c0 04             	add    $0x4,%eax
 56a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 56d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 574:	e9 7c 01 00 00       	jmp    6f5 <printf+0x19e>
    c = fmt[i] & 0xff;
 579:	8b 55 0c             	mov    0xc(%ebp),%edx
 57c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 57f:	01 d0                	add    %edx,%eax
 581:	0f b6 00             	movzbl (%eax),%eax
 584:	0f be c0             	movsbl %al,%eax
 587:	25 ff 00 00 00       	and    $0xff,%eax
 58c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 58f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 593:	75 2c                	jne    5c1 <printf+0x6a>
      if(c == '%'){
 595:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 599:	75 0c                	jne    5a7 <printf+0x50>
        state = '%';
 59b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5a2:	e9 4a 01 00 00       	jmp    6f1 <printf+0x19a>
      } else {
        putc(fd, c);
 5a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5aa:	0f be c0             	movsbl %al,%eax
 5ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b1:	8b 45 08             	mov    0x8(%ebp),%eax
 5b4:	89 04 24             	mov    %eax,(%esp)
 5b7:	e8 bb fe ff ff       	call   477 <putc>
 5bc:	e9 30 01 00 00       	jmp    6f1 <printf+0x19a>
      }
    } else if(state == '%'){
 5c1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5c5:	0f 85 26 01 00 00    	jne    6f1 <printf+0x19a>
      if(c == 'd'){
 5cb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5cf:	75 2d                	jne    5fe <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d4:	8b 00                	mov    (%eax),%eax
 5d6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5dd:	00 
 5de:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5e5:	00 
 5e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	89 04 24             	mov    %eax,(%esp)
 5f0:	e8 aa fe ff ff       	call   49f <printint>
        ap++;
 5f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f9:	e9 ec 00 00 00       	jmp    6ea <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5fe:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 602:	74 06                	je     60a <printf+0xb3>
 604:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 608:	75 2d                	jne    637 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 60a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60d:	8b 00                	mov    (%eax),%eax
 60f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 616:	00 
 617:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 61e:	00 
 61f:	89 44 24 04          	mov    %eax,0x4(%esp)
 623:	8b 45 08             	mov    0x8(%ebp),%eax
 626:	89 04 24             	mov    %eax,(%esp)
 629:	e8 71 fe ff ff       	call   49f <printint>
        ap++;
 62e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 632:	e9 b3 00 00 00       	jmp    6ea <printf+0x193>
      } else if(c == 's'){
 637:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 63b:	75 45                	jne    682 <printf+0x12b>
        s = (char*)*ap;
 63d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 640:	8b 00                	mov    (%eax),%eax
 642:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 645:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 649:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 64d:	75 09                	jne    658 <printf+0x101>
          s = "(null)";
 64f:	c7 45 f4 b0 09 00 00 	movl   $0x9b0,-0xc(%ebp)
        while(*s != 0){
 656:	eb 1e                	jmp    676 <printf+0x11f>
 658:	eb 1c                	jmp    676 <printf+0x11f>
          putc(fd, *s);
 65a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65d:	0f b6 00             	movzbl (%eax),%eax
 660:	0f be c0             	movsbl %al,%eax
 663:	89 44 24 04          	mov    %eax,0x4(%esp)
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	89 04 24             	mov    %eax,(%esp)
 66d:	e8 05 fe ff ff       	call   477 <putc>
          s++;
 672:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 676:	8b 45 f4             	mov    -0xc(%ebp),%eax
 679:	0f b6 00             	movzbl (%eax),%eax
 67c:	84 c0                	test   %al,%al
 67e:	75 da                	jne    65a <printf+0x103>
 680:	eb 68                	jmp    6ea <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 682:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 686:	75 1d                	jne    6a5 <printf+0x14e>
        putc(fd, *ap);
 688:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68b:	8b 00                	mov    (%eax),%eax
 68d:	0f be c0             	movsbl %al,%eax
 690:	89 44 24 04          	mov    %eax,0x4(%esp)
 694:	8b 45 08             	mov    0x8(%ebp),%eax
 697:	89 04 24             	mov    %eax,(%esp)
 69a:	e8 d8 fd ff ff       	call   477 <putc>
        ap++;
 69f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a3:	eb 45                	jmp    6ea <printf+0x193>
      } else if(c == '%'){
 6a5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a9:	75 17                	jne    6c2 <printf+0x16b>
        putc(fd, c);
 6ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ae:	0f be c0             	movsbl %al,%eax
 6b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b5:	8b 45 08             	mov    0x8(%ebp),%eax
 6b8:	89 04 24             	mov    %eax,(%esp)
 6bb:	e8 b7 fd ff ff       	call   477 <putc>
 6c0:	eb 28                	jmp    6ea <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6c2:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6c9:	00 
 6ca:	8b 45 08             	mov    0x8(%ebp),%eax
 6cd:	89 04 24             	mov    %eax,(%esp)
 6d0:	e8 a2 fd ff ff       	call   477 <putc>
        putc(fd, c);
 6d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d8:	0f be c0             	movsbl %al,%eax
 6db:	89 44 24 04          	mov    %eax,0x4(%esp)
 6df:	8b 45 08             	mov    0x8(%ebp),%eax
 6e2:	89 04 24             	mov    %eax,(%esp)
 6e5:	e8 8d fd ff ff       	call   477 <putc>
      }
      state = 0;
 6ea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6f1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6f5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fb:	01 d0                	add    %edx,%eax
 6fd:	0f b6 00             	movzbl (%eax),%eax
 700:	84 c0                	test   %al,%al
 702:	0f 85 71 fe ff ff    	jne    579 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 708:	c9                   	leave  
 709:	c3                   	ret    

0000070a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70a:	55                   	push   %ebp
 70b:	89 e5                	mov    %esp,%ebp
 70d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 710:	8b 45 08             	mov    0x8(%ebp),%eax
 713:	83 e8 08             	sub    $0x8,%eax
 716:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 719:	a1 44 0c 00 00       	mov    0xc44,%eax
 71e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 721:	eb 24                	jmp    747 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 723:	8b 45 fc             	mov    -0x4(%ebp),%eax
 726:	8b 00                	mov    (%eax),%eax
 728:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72b:	77 12                	ja     73f <free+0x35>
 72d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 730:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 733:	77 24                	ja     759 <free+0x4f>
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	8b 00                	mov    (%eax),%eax
 73a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 73d:	77 1a                	ja     759 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 742:	8b 00                	mov    (%eax),%eax
 744:	89 45 fc             	mov    %eax,-0x4(%ebp)
 747:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 74d:	76 d4                	jbe    723 <free+0x19>
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 00                	mov    (%eax),%eax
 754:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 757:	76 ca                	jbe    723 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 759:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75c:	8b 40 04             	mov    0x4(%eax),%eax
 75f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 766:	8b 45 f8             	mov    -0x8(%ebp),%eax
 769:	01 c2                	add    %eax,%edx
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	8b 00                	mov    (%eax),%eax
 770:	39 c2                	cmp    %eax,%edx
 772:	75 24                	jne    798 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 774:	8b 45 f8             	mov    -0x8(%ebp),%eax
 777:	8b 50 04             	mov    0x4(%eax),%edx
 77a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77d:	8b 00                	mov    (%eax),%eax
 77f:	8b 40 04             	mov    0x4(%eax),%eax
 782:	01 c2                	add    %eax,%edx
 784:	8b 45 f8             	mov    -0x8(%ebp),%eax
 787:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 78a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78d:	8b 00                	mov    (%eax),%eax
 78f:	8b 10                	mov    (%eax),%edx
 791:	8b 45 f8             	mov    -0x8(%ebp),%eax
 794:	89 10                	mov    %edx,(%eax)
 796:	eb 0a                	jmp    7a2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 798:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79b:	8b 10                	mov    (%eax),%edx
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a5:	8b 40 04             	mov    0x4(%eax),%eax
 7a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b2:	01 d0                	add    %edx,%eax
 7b4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b7:	75 20                	jne    7d9 <free+0xcf>
    p->s.size += bp->s.size;
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 50 04             	mov    0x4(%eax),%edx
 7bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c2:	8b 40 04             	mov    0x4(%eax),%eax
 7c5:	01 c2                	add    %eax,%edx
 7c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ca:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d0:	8b 10                	mov    (%eax),%edx
 7d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d5:	89 10                	mov    %edx,(%eax)
 7d7:	eb 08                	jmp    7e1 <free+0xd7>
  } else
    p->s.ptr = bp;
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7df:	89 10                	mov    %edx,(%eax)
  freep = p;
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	a3 44 0c 00 00       	mov    %eax,0xc44
}
 7e9:	c9                   	leave  
 7ea:	c3                   	ret    

000007eb <morecore>:

static Header*
morecore(uint nu)
{
 7eb:	55                   	push   %ebp
 7ec:	89 e5                	mov    %esp,%ebp
 7ee:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7f1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7f8:	77 07                	ja     801 <morecore+0x16>
    nu = 4096;
 7fa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 801:	8b 45 08             	mov    0x8(%ebp),%eax
 804:	c1 e0 03             	shl    $0x3,%eax
 807:	89 04 24             	mov    %eax,(%esp)
 80a:	e8 08 fc ff ff       	call   417 <sbrk>
 80f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 812:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 816:	75 07                	jne    81f <morecore+0x34>
    return 0;
 818:	b8 00 00 00 00       	mov    $0x0,%eax
 81d:	eb 22                	jmp    841 <morecore+0x56>
  hp = (Header*)p;
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 825:	8b 45 f0             	mov    -0x10(%ebp),%eax
 828:	8b 55 08             	mov    0x8(%ebp),%edx
 82b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 82e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 831:	83 c0 08             	add    $0x8,%eax
 834:	89 04 24             	mov    %eax,(%esp)
 837:	e8 ce fe ff ff       	call   70a <free>
  return freep;
 83c:	a1 44 0c 00 00       	mov    0xc44,%eax
}
 841:	c9                   	leave  
 842:	c3                   	ret    

00000843 <malloc>:

void*
malloc(uint nbytes)
{
 843:	55                   	push   %ebp
 844:	89 e5                	mov    %esp,%ebp
 846:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 849:	8b 45 08             	mov    0x8(%ebp),%eax
 84c:	83 c0 07             	add    $0x7,%eax
 84f:	c1 e8 03             	shr    $0x3,%eax
 852:	83 c0 01             	add    $0x1,%eax
 855:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 858:	a1 44 0c 00 00       	mov    0xc44,%eax
 85d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 860:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 864:	75 23                	jne    889 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 866:	c7 45 f0 3c 0c 00 00 	movl   $0xc3c,-0x10(%ebp)
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	a3 44 0c 00 00       	mov    %eax,0xc44
 875:	a1 44 0c 00 00       	mov    0xc44,%eax
 87a:	a3 3c 0c 00 00       	mov    %eax,0xc3c
    base.s.size = 0;
 87f:	c7 05 40 0c 00 00 00 	movl   $0x0,0xc40
 886:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	8b 00                	mov    (%eax),%eax
 88e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 89a:	72 4d                	jb     8e9 <malloc+0xa6>
      if(p->s.size == nunits)
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	8b 40 04             	mov    0x4(%eax),%eax
 8a2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8a5:	75 0c                	jne    8b3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8aa:	8b 10                	mov    (%eax),%edx
 8ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8af:	89 10                	mov    %edx,(%eax)
 8b1:	eb 26                	jmp    8d9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b6:	8b 40 04             	mov    0x4(%eax),%eax
 8b9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8bc:	89 c2                	mov    %eax,%edx
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	8b 40 04             	mov    0x4(%eax),%eax
 8ca:	c1 e0 03             	shl    $0x3,%eax
 8cd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8d6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8dc:	a3 44 0c 00 00       	mov    %eax,0xc44
      return (void*)(p + 1);
 8e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e4:	83 c0 08             	add    $0x8,%eax
 8e7:	eb 38                	jmp    921 <malloc+0xde>
    }
    if(p == freep)
 8e9:	a1 44 0c 00 00       	mov    0xc44,%eax
 8ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8f1:	75 1b                	jne    90e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8f6:	89 04 24             	mov    %eax,(%esp)
 8f9:	e8 ed fe ff ff       	call   7eb <morecore>
 8fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
 901:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 905:	75 07                	jne    90e <malloc+0xcb>
        return 0;
 907:	b8 00 00 00 00       	mov    $0x0,%eax
 90c:	eb 13                	jmp    921 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 911:	89 45 f0             	mov    %eax,-0x10(%ebp)
 914:	8b 45 f4             	mov    -0xc(%ebp),%eax
 917:	8b 00                	mov    (%eax),%eax
 919:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 91c:	e9 70 ff ff ff       	jmp    891 <malloc+0x4e>
}
 921:	c9                   	leave  
 922:	c3                   	ret    
