
_timem:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#define NULL_PTR ((char*)0)


int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec a0 00 00 00    	sub    $0xa0,%esp
char *p[MAX_ARGS];

static int status = 1;

//start time
date(&r1);
   c:	8d 44 24 78          	lea    0x78(%esp),%eax
  10:	89 04 24             	mov    %eax,(%esp)
  13:	e8 c2 04 00 00       	call   4da <date>

// check for args
if (argc < 2)
  18:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  1c:	7f 19                	jg     37 <main+0x37>
{
	printf(2, "minimum one command after 'timem'");
  1e:	c7 44 24 04 d0 09 00 	movl   $0x9d0,0x4(%esp)
  25:	00 
  26:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  2d:	e8 d0 05 00 00       	call   602 <printf>
  32:	e9 96 01 00 00       	jmp    1cd <main+0x1cd>
}
else if (argc > MAX_ARGS+1)
  37:	83 7d 08 15          	cmpl   $0x15,0x8(%ebp)
  3b:	7e 19                	jle    56 <main+0x56>
{
	printf(2, "Hit maximum commands.\n");
  3d:	c7 44 24 04 f2 09 00 	movl   $0x9f2,0x4(%esp)
  44:	00 
  45:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  4c:	e8 b1 05 00 00       	call   602 <printf>
  51:	e9 77 01 00 00       	jmp    1cd <main+0x1cd>
}
else
{
	int i;

	int pid = fork();
  56:	e8 d7 03 00 00       	call   432 <fork>
  5b:	89 84 24 98 00 00 00 	mov    %eax,0x98(%esp)
    
	// negative (fork failed)
	if (pid < 0)                       
  62:	83 bc 24 98 00 00 00 	cmpl   $0x0,0x98(%esp)
  69:	00 
  6a:	79 22                	jns    8e <main+0x8e>
		printf(2, "'%s' has failed.\n", argv[0]);
  6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  6f:	8b 00                	mov    (%eax),%eax
  71:	89 44 24 08          	mov    %eax,0x8(%esp)
  75:	c7 44 24 04 09 0a 00 	movl   $0xa09,0x4(%esp)
  7c:	00 
  7d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  84:	e8 79 05 00 00       	call   602 <printf>
  89:	e9 c0 00 00 00       	jmp    14e <main+0x14e>
	else if (pid > 0)                           
  8e:	83 bc 24 98 00 00 00 	cmpl   $0x0,0x98(%esp)
  95:	00 
  96:	7e 1d                	jle    b5 <main+0xb5>
	{
		//parent
      		pid = wait();
  98:	e8 a5 03 00 00       	call   442 <wait>
  9d:	89 84 24 98 00 00 00 	mov    %eax,0x98(%esp)

	//end time
	date(&r2);
  a4:	8d 44 24 60          	lea    0x60(%esp),%eax
  a8:	89 04 24             	mov    %eax,(%esp)
  ab:	e8 2a 04 00 00       	call   4da <date>
  b0:	e9 99 00 00 00       	jmp    14e <main+0x14e>
	}
	else             
	{
		for (i = 0; i < argc-1; i++)
  b5:	c7 84 24 9c 00 00 00 	movl   $0x0,0x9c(%esp)
  bc:	00 00 00 00 
  c0:	eb 2b                	jmp    ed <main+0xed>
		p[i] = argv[i+1];
  c2:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
  c9:	83 c0 01             	add    $0x1,%eax
  cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  d6:	01 d0                	add    %edx,%eax
  d8:	8b 10                	mov    (%eax),%edx
  da:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
  e1:	89 54 84 10          	mov    %edx,0x10(%esp,%eax,4)
	//end time
	date(&r2);
	}
	else             
	{
		for (i = 0; i < argc-1; i++)
  e5:	83 84 24 9c 00 00 00 	addl   $0x1,0x9c(%esp)
  ec:	01 
  ed:	8b 45 08             	mov    0x8(%ebp),%eax
  f0:	83 e8 01             	sub    $0x1,%eax
  f3:	3b 84 24 9c 00 00 00 	cmp    0x9c(%esp),%eax
  fa:	7f c6                	jg     c2 <main+0xc2>
		p[i] = argv[i+1];
		p[i] = NULL_PTR;
  fc:	8b 84 24 9c 00 00 00 	mov    0x9c(%esp),%eax
 103:	c7 44 84 10 00 00 00 	movl   $0x0,0x10(%esp,%eax,4)
 10a:	00 

		//execute command
		status = exec(p[0], p);
 10b:	8b 44 24 10          	mov    0x10(%esp),%eax
 10f:	8d 54 24 10          	lea    0x10(%esp),%edx
 113:	89 54 24 04          	mov    %edx,0x4(%esp)
 117:	89 04 24             	mov    %eax,(%esp)
 11a:	e8 53 03 00 00       	call   472 <exec>
 11f:	a3 8c 0c 00 00       	mov    %eax,0xc8c
		if (status)
 124:	a1 8c 0c 00 00       	mov    0xc8c,%eax
 129:	85 c0                	test   %eax,%eax
 12b:	74 1c                	je     149 <main+0x149>
			printf(2, "exec '%s' failed", p[0]);
 12d:	8b 44 24 10          	mov    0x10(%esp),%eax
 131:	89 44 24 08          	mov    %eax,0x8(%esp)
 135:	c7 44 24 04 1b 0a 00 	movl   $0xa1b,0x4(%esp)
 13c:	00 
 13d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 144:	e8 b9 04 00 00       	call   602 <printf>

		exit();
 149:	e8 ec 02 00 00       	call   43a <exit>
	}

	int s1 = r1.hour * 3600 + r1.minute * 60 + r1.second;
 14e:	8b 84 24 80 00 00 00 	mov    0x80(%esp),%eax
 155:	69 d0 10 0e 00 00    	imul   $0xe10,%eax,%edx
 15b:	8b 44 24 7c          	mov    0x7c(%esp),%eax
 15f:	c1 e0 02             	shl    $0x2,%eax
 162:	89 c1                	mov    %eax,%ecx
 164:	c1 e1 04             	shl    $0x4,%ecx
 167:	29 c1                	sub    %eax,%ecx
 169:	89 c8                	mov    %ecx,%eax
 16b:	01 c2                	add    %eax,%edx
 16d:	8b 44 24 78          	mov    0x78(%esp),%eax
 171:	01 d0                	add    %edx,%eax
 173:	89 84 24 94 00 00 00 	mov    %eax,0x94(%esp)
	int s2 = r2.hour * 3600 + r2.minute * 60 + r2.second;
 17a:	8b 44 24 68          	mov    0x68(%esp),%eax
 17e:	69 d0 10 0e 00 00    	imul   $0xe10,%eax,%edx
 184:	8b 44 24 64          	mov    0x64(%esp),%eax
 188:	c1 e0 02             	shl    $0x2,%eax
 18b:	89 c1                	mov    %eax,%ecx
 18d:	c1 e1 04             	shl    $0x4,%ecx
 190:	29 c1                	sub    %eax,%ecx
 192:	89 c8                	mov    %ecx,%eax
 194:	01 c2                	add    %eax,%edx
 196:	8b 44 24 60          	mov    0x60(%esp),%eax
 19a:	01 d0                	add    %edx,%eax
 19c:	89 84 24 90 00 00 00 	mov    %eax,0x90(%esp)
	printf(2, "\nTime: %d seconds\n", s2-s1);
 1a3:	8b 84 24 94 00 00 00 	mov    0x94(%esp),%eax
 1aa:	8b 94 24 90 00 00 00 	mov    0x90(%esp),%edx
 1b1:	29 c2                	sub    %eax,%edx
 1b3:	89 d0                	mov    %edx,%eax
 1b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b9:	c7 44 24 04 2c 0a 00 	movl   $0xa2c,0x4(%esp)
 1c0:	00 
 1c1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1c8:	e8 35 04 00 00       	call   602 <printf>
}
exit();
 1cd:	e8 68 02 00 00       	call   43a <exit>

000001d2 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	57                   	push   %edi
 1d6:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1da:	8b 55 10             	mov    0x10(%ebp),%edx
 1dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e0:	89 cb                	mov    %ecx,%ebx
 1e2:	89 df                	mov    %ebx,%edi
 1e4:	89 d1                	mov    %edx,%ecx
 1e6:	fc                   	cld    
 1e7:	f3 aa                	rep stos %al,%es:(%edi)
 1e9:	89 ca                	mov    %ecx,%edx
 1eb:	89 fb                	mov    %edi,%ebx
 1ed:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1f0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f3:	5b                   	pop    %ebx
 1f4:	5f                   	pop    %edi
 1f5:	5d                   	pop    %ebp
 1f6:	c3                   	ret    

000001f7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 203:	90                   	nop
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8d 50 01             	lea    0x1(%eax),%edx
 20a:	89 55 08             	mov    %edx,0x8(%ebp)
 20d:	8b 55 0c             	mov    0xc(%ebp),%edx
 210:	8d 4a 01             	lea    0x1(%edx),%ecx
 213:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 216:	0f b6 12             	movzbl (%edx),%edx
 219:	88 10                	mov    %dl,(%eax)
 21b:	0f b6 00             	movzbl (%eax),%eax
 21e:	84 c0                	test   %al,%al
 220:	75 e2                	jne    204 <strcpy+0xd>
    ;
  return os;
 222:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 225:	c9                   	leave  
 226:	c3                   	ret    

00000227 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 227:	55                   	push   %ebp
 228:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 22a:	eb 08                	jmp    234 <strcmp+0xd>
    p++, q++;
 22c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 230:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	0f b6 00             	movzbl (%eax),%eax
 23a:	84 c0                	test   %al,%al
 23c:	74 10                	je     24e <strcmp+0x27>
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	0f b6 10             	movzbl (%eax),%edx
 244:	8b 45 0c             	mov    0xc(%ebp),%eax
 247:	0f b6 00             	movzbl (%eax),%eax
 24a:	38 c2                	cmp    %al,%dl
 24c:	74 de                	je     22c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	0f b6 00             	movzbl (%eax),%eax
 254:	0f b6 d0             	movzbl %al,%edx
 257:	8b 45 0c             	mov    0xc(%ebp),%eax
 25a:	0f b6 00             	movzbl (%eax),%eax
 25d:	0f b6 c0             	movzbl %al,%eax
 260:	29 c2                	sub    %eax,%edx
 262:	89 d0                	mov    %edx,%eax
}
 264:	5d                   	pop    %ebp
 265:	c3                   	ret    

00000266 <strlen>:

uint
strlen(char *s)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 26c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 273:	eb 04                	jmp    279 <strlen+0x13>
 275:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 279:	8b 55 fc             	mov    -0x4(%ebp),%edx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	01 d0                	add    %edx,%eax
 281:	0f b6 00             	movzbl (%eax),%eax
 284:	84 c0                	test   %al,%al
 286:	75 ed                	jne    275 <strlen+0xf>
    ;
  return n;
 288:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28b:	c9                   	leave  
 28c:	c3                   	ret    

0000028d <memset>:

void*
memset(void *dst, int c, uint n)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 293:	8b 45 10             	mov    0x10(%ebp),%eax
 296:	89 44 24 08          	mov    %eax,0x8(%esp)
 29a:	8b 45 0c             	mov    0xc(%ebp),%eax
 29d:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	89 04 24             	mov    %eax,(%esp)
 2a7:	e8 26 ff ff ff       	call   1d2 <stosb>
  return dst;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2af:	c9                   	leave  
 2b0:	c3                   	ret    

000002b1 <strchr>:

char*
strchr(const char *s, char c)
{
 2b1:	55                   	push   %ebp
 2b2:	89 e5                	mov    %esp,%ebp
 2b4:	83 ec 04             	sub    $0x4,%esp
 2b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ba:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2bd:	eb 14                	jmp    2d3 <strchr+0x22>
    if(*s == c)
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	0f b6 00             	movzbl (%eax),%eax
 2c5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2c8:	75 05                	jne    2cf <strchr+0x1e>
      return (char*)s;
 2ca:	8b 45 08             	mov    0x8(%ebp),%eax
 2cd:	eb 13                	jmp    2e2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2d3:	8b 45 08             	mov    0x8(%ebp),%eax
 2d6:	0f b6 00             	movzbl (%eax),%eax
 2d9:	84 c0                	test   %al,%al
 2db:	75 e2                	jne    2bf <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2e2:	c9                   	leave  
 2e3:	c3                   	ret    

000002e4 <gets>:

char*
gets(char *buf, int max)
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2f1:	eb 4c                	jmp    33f <gets+0x5b>
    cc = read(0, &c, 1);
 2f3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2fa:	00 
 2fb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 302:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 309:	e8 44 01 00 00       	call   452 <read>
 30e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 311:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 315:	7f 02                	jg     319 <gets+0x35>
      break;
 317:	eb 31                	jmp    34a <gets+0x66>
    buf[i++] = c;
 319:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31c:	8d 50 01             	lea    0x1(%eax),%edx
 31f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 322:	89 c2                	mov    %eax,%edx
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	01 c2                	add    %eax,%edx
 329:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 32f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 333:	3c 0a                	cmp    $0xa,%al
 335:	74 13                	je     34a <gets+0x66>
 337:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33b:	3c 0d                	cmp    $0xd,%al
 33d:	74 0b                	je     34a <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 33f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 342:	83 c0 01             	add    $0x1,%eax
 345:	3b 45 0c             	cmp    0xc(%ebp),%eax
 348:	7c a9                	jl     2f3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 34a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 34d:	8b 45 08             	mov    0x8(%ebp),%eax
 350:	01 d0                	add    %edx,%eax
 352:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 355:	8b 45 08             	mov    0x8(%ebp),%eax
}
 358:	c9                   	leave  
 359:	c3                   	ret    

0000035a <stat>:

int
stat(char *n, struct stat *st)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 360:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 367:	00 
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	89 04 24             	mov    %eax,(%esp)
 36e:	e8 07 01 00 00       	call   47a <open>
 373:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 376:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 37a:	79 07                	jns    383 <stat+0x29>
    return -1;
 37c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 381:	eb 23                	jmp    3a6 <stat+0x4c>
  r = fstat(fd, st);
 383:	8b 45 0c             	mov    0xc(%ebp),%eax
 386:	89 44 24 04          	mov    %eax,0x4(%esp)
 38a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38d:	89 04 24             	mov    %eax,(%esp)
 390:	e8 fd 00 00 00       	call   492 <fstat>
 395:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 398:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39b:	89 04 24             	mov    %eax,(%esp)
 39e:	e8 bf 00 00 00       	call   462 <close>
  return r;
 3a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3a6:	c9                   	leave  
 3a7:	c3                   	ret    

000003a8 <atoi>:

int
atoi(const char *s)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b5:	eb 25                	jmp    3dc <atoi+0x34>
    n = n*10 + *s++ - '0';
 3b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3ba:	89 d0                	mov    %edx,%eax
 3bc:	c1 e0 02             	shl    $0x2,%eax
 3bf:	01 d0                	add    %edx,%eax
 3c1:	01 c0                	add    %eax,%eax
 3c3:	89 c1                	mov    %eax,%ecx
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	8d 50 01             	lea    0x1(%eax),%edx
 3cb:	89 55 08             	mov    %edx,0x8(%ebp)
 3ce:	0f b6 00             	movzbl (%eax),%eax
 3d1:	0f be c0             	movsbl %al,%eax
 3d4:	01 c8                	add    %ecx,%eax
 3d6:	83 e8 30             	sub    $0x30,%eax
 3d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	0f b6 00             	movzbl (%eax),%eax
 3e2:	3c 2f                	cmp    $0x2f,%al
 3e4:	7e 0a                	jle    3f0 <atoi+0x48>
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	3c 39                	cmp    $0x39,%al
 3ee:	7e c7                	jle    3b7 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f3:	c9                   	leave  
 3f4:	c3                   	ret    

000003f5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 401:	8b 45 0c             	mov    0xc(%ebp),%eax
 404:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 407:	eb 17                	jmp    420 <memmove+0x2b>
    *dst++ = *src++;
 409:	8b 45 fc             	mov    -0x4(%ebp),%eax
 40c:	8d 50 01             	lea    0x1(%eax),%edx
 40f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 412:	8b 55 f8             	mov    -0x8(%ebp),%edx
 415:	8d 4a 01             	lea    0x1(%edx),%ecx
 418:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 41b:	0f b6 12             	movzbl (%edx),%edx
 41e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 420:	8b 45 10             	mov    0x10(%ebp),%eax
 423:	8d 50 ff             	lea    -0x1(%eax),%edx
 426:	89 55 10             	mov    %edx,0x10(%ebp)
 429:	85 c0                	test   %eax,%eax
 42b:	7f dc                	jg     409 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 42d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 430:	c9                   	leave  
 431:	c3                   	ret    

00000432 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 432:	b8 01 00 00 00       	mov    $0x1,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <exit>:
SYSCALL(exit)
 43a:	b8 02 00 00 00       	mov    $0x2,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <wait>:
SYSCALL(wait)
 442:	b8 03 00 00 00       	mov    $0x3,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <pipe>:
SYSCALL(pipe)
 44a:	b8 04 00 00 00       	mov    $0x4,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <read>:
SYSCALL(read)
 452:	b8 05 00 00 00       	mov    $0x5,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <write>:
SYSCALL(write)
 45a:	b8 10 00 00 00       	mov    $0x10,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <close>:
SYSCALL(close)
 462:	b8 15 00 00 00       	mov    $0x15,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <kill>:
SYSCALL(kill)
 46a:	b8 06 00 00 00       	mov    $0x6,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <exec>:
SYSCALL(exec)
 472:	b8 07 00 00 00       	mov    $0x7,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <open>:
SYSCALL(open)
 47a:	b8 0f 00 00 00       	mov    $0xf,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <mknod>:
SYSCALL(mknod)
 482:	b8 11 00 00 00       	mov    $0x11,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <unlink>:
SYSCALL(unlink)
 48a:	b8 12 00 00 00       	mov    $0x12,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <fstat>:
SYSCALL(fstat)
 492:	b8 08 00 00 00       	mov    $0x8,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <link>:
SYSCALL(link)
 49a:	b8 13 00 00 00       	mov    $0x13,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <mkdir>:
SYSCALL(mkdir)
 4a2:	b8 14 00 00 00       	mov    $0x14,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <chdir>:
SYSCALL(chdir)
 4aa:	b8 09 00 00 00       	mov    $0x9,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <dup>:
SYSCALL(dup)
 4b2:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <getpid>:
SYSCALL(getpid)
 4ba:	b8 0b 00 00 00       	mov    $0xb,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret    

000004c2 <sbrk>:
SYSCALL(sbrk)
 4c2:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret    

000004ca <sleep>:
SYSCALL(sleep)
 4ca:	b8 0d 00 00 00       	mov    $0xd,%eax
 4cf:	cd 40                	int    $0x40
 4d1:	c3                   	ret    

000004d2 <uptime>:
SYSCALL(uptime)
 4d2:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d7:	cd 40                	int    $0x40
 4d9:	c3                   	ret    

000004da <date>:
SYSCALL(date)
 4da:	b8 16 00 00 00       	mov    $0x16,%eax
 4df:	cd 40                	int    $0x40
 4e1:	c3                   	ret    

000004e2 <timem>:
SYSCALL(timem)
 4e2:	b8 17 00 00 00       	mov    $0x17,%eax
 4e7:	cd 40                	int    $0x40
 4e9:	c3                   	ret    

000004ea <getuid>:
SYSCALL(getuid)
 4ea:	b8 18 00 00 00       	mov    $0x18,%eax
 4ef:	cd 40                	int    $0x40
 4f1:	c3                   	ret    

000004f2 <getgid>:
SYSCALL(getgid)
 4f2:	b8 19 00 00 00       	mov    $0x19,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret    

000004fa <getppid>:
SYSCALL(getppid)
 4fa:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret    

00000502 <setuid>:
SYSCALL(setuid)
 502:	b8 1b 00 00 00       	mov    $0x1b,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret    

0000050a <setgid>:
SYSCALL(setgid)
 50a:	b8 1c 00 00 00       	mov    $0x1c,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret    

00000512 <getprocs>:
SYSCALL(getprocs)
 512:	b8 1d 00 00 00       	mov    $0x1d,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret    

0000051a <setpriority>:
SYSCALL(setpriority)
 51a:	b8 1e 00 00 00       	mov    $0x1e,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret    

00000522 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 522:	55                   	push   %ebp
 523:	89 e5                	mov    %esp,%ebp
 525:	83 ec 18             	sub    $0x18,%esp
 528:	8b 45 0c             	mov    0xc(%ebp),%eax
 52b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 52e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 535:	00 
 536:	8d 45 f4             	lea    -0xc(%ebp),%eax
 539:	89 44 24 04          	mov    %eax,0x4(%esp)
 53d:	8b 45 08             	mov    0x8(%ebp),%eax
 540:	89 04 24             	mov    %eax,(%esp)
 543:	e8 12 ff ff ff       	call   45a <write>
}
 548:	c9                   	leave  
 549:	c3                   	ret    

0000054a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54a:	55                   	push   %ebp
 54b:	89 e5                	mov    %esp,%ebp
 54d:	56                   	push   %esi
 54e:	53                   	push   %ebx
 54f:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 552:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 559:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 55d:	74 17                	je     576 <printint+0x2c>
 55f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 563:	79 11                	jns    576 <printint+0x2c>
    neg = 1;
 565:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 56c:	8b 45 0c             	mov    0xc(%ebp),%eax
 56f:	f7 d8                	neg    %eax
 571:	89 45 ec             	mov    %eax,-0x14(%ebp)
 574:	eb 06                	jmp    57c <printint+0x32>
  } else {
    x = xx;
 576:	8b 45 0c             	mov    0xc(%ebp),%eax
 579:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 57c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 583:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 586:	8d 41 01             	lea    0x1(%ecx),%eax
 589:	89 45 f4             	mov    %eax,-0xc(%ebp)
 58c:	8b 5d 10             	mov    0x10(%ebp),%ebx
 58f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 592:	ba 00 00 00 00       	mov    $0x0,%edx
 597:	f7 f3                	div    %ebx
 599:	89 d0                	mov    %edx,%eax
 59b:	0f b6 80 90 0c 00 00 	movzbl 0xc90(%eax),%eax
 5a2:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5a6:	8b 75 10             	mov    0x10(%ebp),%esi
 5a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ac:	ba 00 00 00 00       	mov    $0x0,%edx
 5b1:	f7 f6                	div    %esi
 5b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ba:	75 c7                	jne    583 <printint+0x39>
  if(neg)
 5bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c0:	74 10                	je     5d2 <printint+0x88>
    buf[i++] = '-';
 5c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c5:	8d 50 01             	lea    0x1(%eax),%edx
 5c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5cb:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5d0:	eb 1f                	jmp    5f1 <printint+0xa7>
 5d2:	eb 1d                	jmp    5f1 <printint+0xa7>
    putc(fd, buf[i]);
 5d4:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5da:	01 d0                	add    %edx,%eax
 5dc:	0f b6 00             	movzbl (%eax),%eax
 5df:	0f be c0             	movsbl %al,%eax
 5e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e6:	8b 45 08             	mov    0x8(%ebp),%eax
 5e9:	89 04 24             	mov    %eax,(%esp)
 5ec:	e8 31 ff ff ff       	call   522 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5f1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f9:	79 d9                	jns    5d4 <printint+0x8a>
    putc(fd, buf[i]);
}
 5fb:	83 c4 30             	add    $0x30,%esp
 5fe:	5b                   	pop    %ebx
 5ff:	5e                   	pop    %esi
 600:	5d                   	pop    %ebp
 601:	c3                   	ret    

00000602 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 602:	55                   	push   %ebp
 603:	89 e5                	mov    %esp,%ebp
 605:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 608:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 60f:	8d 45 0c             	lea    0xc(%ebp),%eax
 612:	83 c0 04             	add    $0x4,%eax
 615:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 618:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 61f:	e9 7c 01 00 00       	jmp    7a0 <printf+0x19e>
    c = fmt[i] & 0xff;
 624:	8b 55 0c             	mov    0xc(%ebp),%edx
 627:	8b 45 f0             	mov    -0x10(%ebp),%eax
 62a:	01 d0                	add    %edx,%eax
 62c:	0f b6 00             	movzbl (%eax),%eax
 62f:	0f be c0             	movsbl %al,%eax
 632:	25 ff 00 00 00       	and    $0xff,%eax
 637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 63a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63e:	75 2c                	jne    66c <printf+0x6a>
      if(c == '%'){
 640:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 644:	75 0c                	jne    652 <printf+0x50>
        state = '%';
 646:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 64d:	e9 4a 01 00 00       	jmp    79c <printf+0x19a>
      } else {
        putc(fd, c);
 652:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 655:	0f be c0             	movsbl %al,%eax
 658:	89 44 24 04          	mov    %eax,0x4(%esp)
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
 65f:	89 04 24             	mov    %eax,(%esp)
 662:	e8 bb fe ff ff       	call   522 <putc>
 667:	e9 30 01 00 00       	jmp    79c <printf+0x19a>
      }
    } else if(state == '%'){
 66c:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 670:	0f 85 26 01 00 00    	jne    79c <printf+0x19a>
      if(c == 'd'){
 676:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 67a:	75 2d                	jne    6a9 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 67c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67f:	8b 00                	mov    (%eax),%eax
 681:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 688:	00 
 689:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 690:	00 
 691:	89 44 24 04          	mov    %eax,0x4(%esp)
 695:	8b 45 08             	mov    0x8(%ebp),%eax
 698:	89 04 24             	mov    %eax,(%esp)
 69b:	e8 aa fe ff ff       	call   54a <printint>
        ap++;
 6a0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a4:	e9 ec 00 00 00       	jmp    795 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 6a9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ad:	74 06                	je     6b5 <printf+0xb3>
 6af:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b3:	75 2d                	jne    6e2 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b8:	8b 00                	mov    (%eax),%eax
 6ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6c1:	00 
 6c2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6c9:	00 
 6ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ce:	8b 45 08             	mov    0x8(%ebp),%eax
 6d1:	89 04 24             	mov    %eax,(%esp)
 6d4:	e8 71 fe ff ff       	call   54a <printint>
        ap++;
 6d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6dd:	e9 b3 00 00 00       	jmp    795 <printf+0x193>
      } else if(c == 's'){
 6e2:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e6:	75 45                	jne    72d <printf+0x12b>
        s = (char*)*ap;
 6e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6eb:	8b 00                	mov    (%eax),%eax
 6ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f8:	75 09                	jne    703 <printf+0x101>
          s = "(null)";
 6fa:	c7 45 f4 3f 0a 00 00 	movl   $0xa3f,-0xc(%ebp)
        while(*s != 0){
 701:	eb 1e                	jmp    721 <printf+0x11f>
 703:	eb 1c                	jmp    721 <printf+0x11f>
          putc(fd, *s);
 705:	8b 45 f4             	mov    -0xc(%ebp),%eax
 708:	0f b6 00             	movzbl (%eax),%eax
 70b:	0f be c0             	movsbl %al,%eax
 70e:	89 44 24 04          	mov    %eax,0x4(%esp)
 712:	8b 45 08             	mov    0x8(%ebp),%eax
 715:	89 04 24             	mov    %eax,(%esp)
 718:	e8 05 fe ff ff       	call   522 <putc>
          s++;
 71d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 721:	8b 45 f4             	mov    -0xc(%ebp),%eax
 724:	0f b6 00             	movzbl (%eax),%eax
 727:	84 c0                	test   %al,%al
 729:	75 da                	jne    705 <printf+0x103>
 72b:	eb 68                	jmp    795 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 731:	75 1d                	jne    750 <printf+0x14e>
        putc(fd, *ap);
 733:	8b 45 e8             	mov    -0x18(%ebp),%eax
 736:	8b 00                	mov    (%eax),%eax
 738:	0f be c0             	movsbl %al,%eax
 73b:	89 44 24 04          	mov    %eax,0x4(%esp)
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	89 04 24             	mov    %eax,(%esp)
 745:	e8 d8 fd ff ff       	call   522 <putc>
        ap++;
 74a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74e:	eb 45                	jmp    795 <printf+0x193>
      } else if(c == '%'){
 750:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 754:	75 17                	jne    76d <printf+0x16b>
        putc(fd, c);
 756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 759:	0f be c0             	movsbl %al,%eax
 75c:	89 44 24 04          	mov    %eax,0x4(%esp)
 760:	8b 45 08             	mov    0x8(%ebp),%eax
 763:	89 04 24             	mov    %eax,(%esp)
 766:	e8 b7 fd ff ff       	call   522 <putc>
 76b:	eb 28                	jmp    795 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 774:	00 
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	89 04 24             	mov    %eax,(%esp)
 77b:	e8 a2 fd ff ff       	call   522 <putc>
        putc(fd, c);
 780:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 783:	0f be c0             	movsbl %al,%eax
 786:	89 44 24 04          	mov    %eax,0x4(%esp)
 78a:	8b 45 08             	mov    0x8(%ebp),%eax
 78d:	89 04 24             	mov    %eax,(%esp)
 790:	e8 8d fd ff ff       	call   522 <putc>
      }
      state = 0;
 795:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 79c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7a0:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a6:	01 d0                	add    %edx,%eax
 7a8:	0f b6 00             	movzbl (%eax),%eax
 7ab:	84 c0                	test   %al,%al
 7ad:	0f 85 71 fe ff ff    	jne    624 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b3:	c9                   	leave  
 7b4:	c3                   	ret    

000007b5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b5:	55                   	push   %ebp
 7b6:	89 e5                	mov    %esp,%ebp
 7b8:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7bb:	8b 45 08             	mov    0x8(%ebp),%eax
 7be:	83 e8 08             	sub    $0x8,%eax
 7c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c4:	a1 ac 0c 00 00       	mov    0xcac,%eax
 7c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cc:	eb 24                	jmp    7f2 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d6:	77 12                	ja     7ea <free+0x35>
 7d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7de:	77 24                	ja     804 <free+0x4f>
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e8:	77 1a                	ja     804 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ed:	8b 00                	mov    (%eax),%eax
 7ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f8:	76 d4                	jbe    7ce <free+0x19>
 7fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fd:	8b 00                	mov    (%eax),%eax
 7ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 802:	76 ca                	jbe    7ce <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 804:	8b 45 f8             	mov    -0x8(%ebp),%eax
 807:	8b 40 04             	mov    0x4(%eax),%eax
 80a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 811:	8b 45 f8             	mov    -0x8(%ebp),%eax
 814:	01 c2                	add    %eax,%edx
 816:	8b 45 fc             	mov    -0x4(%ebp),%eax
 819:	8b 00                	mov    (%eax),%eax
 81b:	39 c2                	cmp    %eax,%edx
 81d:	75 24                	jne    843 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 81f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 822:	8b 50 04             	mov    0x4(%eax),%edx
 825:	8b 45 fc             	mov    -0x4(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	8b 40 04             	mov    0x4(%eax),%eax
 82d:	01 c2                	add    %eax,%edx
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 835:	8b 45 fc             	mov    -0x4(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	8b 10                	mov    (%eax),%edx
 83c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83f:	89 10                	mov    %edx,(%eax)
 841:	eb 0a                	jmp    84d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 843:	8b 45 fc             	mov    -0x4(%ebp),%eax
 846:	8b 10                	mov    (%eax),%edx
 848:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 84d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 850:	8b 40 04             	mov    0x4(%eax),%eax
 853:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 85a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85d:	01 d0                	add    %edx,%eax
 85f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 862:	75 20                	jne    884 <free+0xcf>
    p->s.size += bp->s.size;
 864:	8b 45 fc             	mov    -0x4(%ebp),%eax
 867:	8b 50 04             	mov    0x4(%eax),%edx
 86a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86d:	8b 40 04             	mov    0x4(%eax),%eax
 870:	01 c2                	add    %eax,%edx
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 878:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87b:	8b 10                	mov    (%eax),%edx
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	89 10                	mov    %edx,(%eax)
 882:	eb 08                	jmp    88c <free+0xd7>
  } else
    p->s.ptr = bp;
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	8b 55 f8             	mov    -0x8(%ebp),%edx
 88a:	89 10                	mov    %edx,(%eax)
  freep = p;
 88c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88f:	a3 ac 0c 00 00       	mov    %eax,0xcac
}
 894:	c9                   	leave  
 895:	c3                   	ret    

00000896 <morecore>:

static Header*
morecore(uint nu)
{
 896:	55                   	push   %ebp
 897:	89 e5                	mov    %esp,%ebp
 899:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89c:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a3:	77 07                	ja     8ac <morecore+0x16>
    nu = 4096;
 8a5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ac:	8b 45 08             	mov    0x8(%ebp),%eax
 8af:	c1 e0 03             	shl    $0x3,%eax
 8b2:	89 04 24             	mov    %eax,(%esp)
 8b5:	e8 08 fc ff ff       	call   4c2 <sbrk>
 8ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8bd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c1:	75 07                	jne    8ca <morecore+0x34>
    return 0;
 8c3:	b8 00 00 00 00       	mov    $0x0,%eax
 8c8:	eb 22                	jmp    8ec <morecore+0x56>
  hp = (Header*)p;
 8ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d3:	8b 55 08             	mov    0x8(%ebp),%edx
 8d6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8dc:	83 c0 08             	add    $0x8,%eax
 8df:	89 04 24             	mov    %eax,(%esp)
 8e2:	e8 ce fe ff ff       	call   7b5 <free>
  return freep;
 8e7:	a1 ac 0c 00 00       	mov    0xcac,%eax
}
 8ec:	c9                   	leave  
 8ed:	c3                   	ret    

000008ee <malloc>:

void*
malloc(uint nbytes)
{
 8ee:	55                   	push   %ebp
 8ef:	89 e5                	mov    %esp,%ebp
 8f1:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f4:	8b 45 08             	mov    0x8(%ebp),%eax
 8f7:	83 c0 07             	add    $0x7,%eax
 8fa:	c1 e8 03             	shr    $0x3,%eax
 8fd:	83 c0 01             	add    $0x1,%eax
 900:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 903:	a1 ac 0c 00 00       	mov    0xcac,%eax
 908:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 90f:	75 23                	jne    934 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 911:	c7 45 f0 a4 0c 00 00 	movl   $0xca4,-0x10(%ebp)
 918:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91b:	a3 ac 0c 00 00       	mov    %eax,0xcac
 920:	a1 ac 0c 00 00       	mov    0xcac,%eax
 925:	a3 a4 0c 00 00       	mov    %eax,0xca4
    base.s.size = 0;
 92a:	c7 05 a8 0c 00 00 00 	movl   $0x0,0xca8
 931:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	8b 45 f0             	mov    -0x10(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 945:	72 4d                	jb     994 <malloc+0xa6>
      if(p->s.size == nunits)
 947:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94a:	8b 40 04             	mov    0x4(%eax),%eax
 94d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 950:	75 0c                	jne    95e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 952:	8b 45 f4             	mov    -0xc(%ebp),%eax
 955:	8b 10                	mov    (%eax),%edx
 957:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95a:	89 10                	mov    %edx,(%eax)
 95c:	eb 26                	jmp    984 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 961:	8b 40 04             	mov    0x4(%eax),%eax
 964:	2b 45 ec             	sub    -0x14(%ebp),%eax
 967:	89 c2                	mov    %eax,%edx
 969:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	8b 40 04             	mov    0x4(%eax),%eax
 975:	c1 e0 03             	shl    $0x3,%eax
 978:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 981:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 984:	8b 45 f0             	mov    -0x10(%ebp),%eax
 987:	a3 ac 0c 00 00       	mov    %eax,0xcac
      return (void*)(p + 1);
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	83 c0 08             	add    $0x8,%eax
 992:	eb 38                	jmp    9cc <malloc+0xde>
    }
    if(p == freep)
 994:	a1 ac 0c 00 00       	mov    0xcac,%eax
 999:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99c:	75 1b                	jne    9b9 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 99e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a1:	89 04 24             	mov    %eax,(%esp)
 9a4:	e8 ed fe ff ff       	call   896 <morecore>
 9a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b0:	75 07                	jne    9b9 <malloc+0xcb>
        return 0;
 9b2:	b8 00 00 00 00       	mov    $0x0,%eax
 9b7:	eb 13                	jmp    9cc <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c2:	8b 00                	mov    (%eax),%eax
 9c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9c7:	e9 70 ff ff ff       	jmp    93c <malloc+0x4e>
}
 9cc:	c9                   	leave  
 9cd:	c3                   	ret    
