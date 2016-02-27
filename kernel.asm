
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 c3 37 10 80       	mov    $0x801037c3,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 a4 88 10 	movl   $0x801088a4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100049:	e8 3c 51 00 00       	call   8010518a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 05 11 80 84 	movl   $0x80110584,0x80110590
80100055:	05 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 05 11 80 84 	movl   $0x80110584,0x80110594
8010005f:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 05 11 80       	mov    0x80110594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 05 11 80       	mov    %eax,0x80110594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801000bd:	e8 e9 50 00 00       	call   801051ab <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 05 11 80       	mov    0x80110594,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100104:	e8 04 51 00 00       	call   8010520d <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 c6 10 	movl   $0x8010c680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 bc 4b 00 00       	call   80104ce0 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 05 11 80       	mov    0x80110590,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010017c:	e8 8c 50 00 00       	call   8010520d <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 ab 88 10 80 	movl   $0x801088ab,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 7f 26 00 00       	call   80102857 <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 bc 88 10 80 	movl   $0x801088bc,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 42 26 00 00       	call   80102857 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 c3 88 10 80 	movl   $0x801088c3,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010023c:	e8 6a 4f 00 00       	call   801051ab <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 05 11 80       	mov    0x80110594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 05 11 80       	mov    %eax,0x80110594

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 1a 4b 00 00       	call   80104dbc <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801002a9:	e8 5f 4f 00 00       	call   8010520d <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 dc 03 00 00       	call   8010076b <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801003bb:	e8 eb 4d 00 00       	call   801051ab <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 ca 88 10 80 	movl   $0x801088ca,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 75 03 00 00       	call   8010076b <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec d3 88 10 80 	movl   $0x801088d3,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 9f 02 00 00       	call   8010076b <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 83 02 00 00       	call   8010076b <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 75 02 00 00       	call   8010076b <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 6a 02 00 00       	call   8010076b <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100533:	e8 d5 4c 00 00       	call   8010520d <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 da 88 10 80 	movl   $0x801088da,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 e9 88 10 80 	movl   $0x801088e9,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 c8 4c 00 00       	call   8010525c <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 eb 88 10 80 	movl   $0x801088eb,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068e:	78 09                	js     80100699 <cgaputc+0xcf>
80100690:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100697:	7e 0c                	jle    801006a5 <cgaputc+0xdb>
    panic("pos under/overflow");
80100699:	c7 04 24 ef 88 10 80 	movl   $0x801088ef,(%esp)
801006a0:	e8 95 fe ff ff       	call   8010053a <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006a5:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ac:	7e 53                	jle    80100701 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006ae:	a1 00 90 10 80       	mov    0x80109000,%eax
801006b3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b9:	a1 00 90 10 80       	mov    0x80109000,%eax
801006be:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c5:	00 
801006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801006ca:	89 04 24             	mov    %eax,(%esp)
801006cd:	e8 fc 4d 00 00       	call   801054ce <memmove>
    pos -= 80;
801006d2:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d6:	b8 80 07 00 00       	mov    $0x780,%eax
801006db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006de:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006e9:	01 c9                	add    %ecx,%ecx
801006eb:	01 c8                	add    %ecx,%eax
801006ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801006f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f8:	00 
801006f9:	89 04 24             	mov    %eax,(%esp)
801006fc:	e8 fe 4c 00 00       	call   801053ff <memset>
  }
  
  outb(CRTPORT, 14);
80100701:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100708:	00 
80100709:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100710:	e8 b8 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100722:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100729:	e8 9f fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
8010072e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100735:	00 
80100736:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073d:	e8 8b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100745:	0f b6 c0             	movzbl %al,%eax
80100748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100753:	e8 75 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 90 10 80       	mov    0x80109000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100771:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 6c fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 26                	jne    801007b0 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100791:	e8 51 67 00 00       	call   80106ee7 <uartputc>
80100796:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079d:	e8 45 67 00 00       	call   80106ee7 <uartputc>
801007a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a9:	e8 39 67 00 00       	call   80106ee7 <uartputc>
801007ae:	eb 0b                	jmp    801007bb <consputc+0x50>
  } else
    uartputc(c);
801007b0:	8b 45 08             	mov    0x8(%ebp),%eax
801007b3:	89 04 24             	mov    %eax,(%esp)
801007b6:	e8 2c 67 00 00       	call   80106ee7 <uartputc>
  cgaputc(c);
801007bb:	8b 45 08             	mov    0x8(%ebp),%eax
801007be:	89 04 24             	mov    %eax,(%esp)
801007c1:	e8 04 fe ff ff       	call   801005ca <cgaputc>
}
801007c6:	c9                   	leave  
801007c7:	c3                   	ret    

801007c8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007c8:	55                   	push   %ebp
801007c9:	89 e5                	mov    %esp,%ebp
801007cb:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d5:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801007dc:	e8 ca 49 00 00       	call   801051ab <acquire>
  while((c = getc()) >= 0){
801007e1:	e9 39 01 00 00       	jmp    8010091f <consoleintr+0x157>
    switch(c){
801007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007e9:	83 f8 10             	cmp    $0x10,%eax
801007ec:	74 1e                	je     8010080c <consoleintr+0x44>
801007ee:	83 f8 10             	cmp    $0x10,%eax
801007f1:	7f 0a                	jg     801007fd <consoleintr+0x35>
801007f3:	83 f8 08             	cmp    $0x8,%eax
801007f6:	74 66                	je     8010085e <consoleintr+0x96>
801007f8:	e9 93 00 00 00       	jmp    80100890 <consoleintr+0xc8>
801007fd:	83 f8 15             	cmp    $0x15,%eax
80100800:	74 31                	je     80100833 <consoleintr+0x6b>
80100802:	83 f8 7f             	cmp    $0x7f,%eax
80100805:	74 57                	je     8010085e <consoleintr+0x96>
80100807:	e9 84 00 00 00       	jmp    80100890 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 07 01 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 28 08 11 80       	mov    0x80110828,%eax
8010081d:	83 e8 01             	sub    $0x1,%eax
80100820:	a3 28 08 11 80       	mov    %eax,0x80110828
        consputc(BACKSPACE);
80100825:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082c:	e8 3a ff ff ff       	call   8010076b <consputc>
80100831:	eb 01                	jmp    80100834 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100833:	90                   	nop
80100834:	8b 15 28 08 11 80    	mov    0x80110828,%edx
8010083a:	a1 24 08 11 80       	mov    0x80110824,%eax
8010083f:	39 c2                	cmp    %eax,%edx
80100841:	74 16                	je     80100859 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100843:	a1 28 08 11 80       	mov    0x80110828,%eax
80100848:	83 e8 01             	sub    $0x1,%eax
8010084b:	83 e0 7f             	and    $0x7f,%eax
8010084e:	0f b6 80 a0 07 11 80 	movzbl -0x7feef860(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100855:	3c 0a                	cmp    $0xa,%al
80100857:	75 bf                	jne    80100818 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100859:	e9 c1 00 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010085e:	8b 15 28 08 11 80    	mov    0x80110828,%edx
80100864:	a1 24 08 11 80       	mov    0x80110824,%eax
80100869:	39 c2                	cmp    %eax,%edx
8010086b:	74 1e                	je     8010088b <consoleintr+0xc3>
        input.e--;
8010086d:	a1 28 08 11 80       	mov    0x80110828,%eax
80100872:	83 e8 01             	sub    $0x1,%eax
80100875:	a3 28 08 11 80       	mov    %eax,0x80110828
        consputc(BACKSPACE);
8010087a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100881:	e8 e5 fe ff ff       	call   8010076b <consputc>
      }
      break;
80100886:	e9 94 00 00 00       	jmp    8010091f <consoleintr+0x157>
8010088b:	e9 8f 00 00 00       	jmp    8010091f <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100894:	0f 84 84 00 00 00    	je     8010091e <consoleintr+0x156>
8010089a:	8b 15 28 08 11 80    	mov    0x80110828,%edx
801008a0:	a1 20 08 11 80       	mov    0x80110820,%eax
801008a5:	29 c2                	sub    %eax,%edx
801008a7:	89 d0                	mov    %edx,%eax
801008a9:	83 f8 7f             	cmp    $0x7f,%eax
801008ac:	77 70                	ja     8010091e <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008b2:	74 05                	je     801008b9 <consoleintr+0xf1>
801008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b7:	eb 05                	jmp    801008be <consoleintr+0xf6>
801008b9:	b8 0a 00 00 00       	mov    $0xa,%eax
801008be:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c1:	a1 28 08 11 80       	mov    0x80110828,%eax
801008c6:	8d 50 01             	lea    0x1(%eax),%edx
801008c9:	89 15 28 08 11 80    	mov    %edx,0x80110828
801008cf:	83 e0 7f             	and    $0x7f,%eax
801008d2:	89 c2                	mov    %eax,%edx
801008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d7:	88 82 a0 07 11 80    	mov    %al,-0x7feef860(%edx)
        consputc(c);
801008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008e0:	89 04 24             	mov    %eax,(%esp)
801008e3:	e8 83 fe ff ff       	call   8010076b <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008ec:	74 18                	je     80100906 <consoleintr+0x13e>
801008ee:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008f2:	74 12                	je     80100906 <consoleintr+0x13e>
801008f4:	a1 28 08 11 80       	mov    0x80110828,%eax
801008f9:	8b 15 20 08 11 80    	mov    0x80110820,%edx
801008ff:	83 ea 80             	sub    $0xffffff80,%edx
80100902:	39 d0                	cmp    %edx,%eax
80100904:	75 18                	jne    8010091e <consoleintr+0x156>
          input.w = input.e;
80100906:	a1 28 08 11 80       	mov    0x80110828,%eax
8010090b:	a3 24 08 11 80       	mov    %eax,0x80110824
          wakeup(&input.r);
80100910:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100917:	e8 a0 44 00 00       	call   80104dbc <wakeup>
        }
      }
      break;
8010091c:	eb 00                	jmp    8010091e <consoleintr+0x156>
8010091e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010091f:	8b 45 08             	mov    0x8(%ebp),%eax
80100922:	ff d0                	call   *%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010092b:	0f 89 b5 fe ff ff    	jns    801007e6 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100931:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100938:	e8 d0 48 00 00       	call   8010520d <release>
  if(doprocdump) {
8010093d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100941:	74 05                	je     80100948 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100943:	e8 1a 45 00 00       	call   80104e62 <procdump>
  }
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	89 04 24             	mov    %eax,(%esp)
80100956:	e8 cd 10 00 00       	call   80101a28 <iunlock>
  target = n;
8010095b:	8b 45 10             	mov    0x10(%ebp),%eax
8010095e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100961:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100968:	e8 3e 48 00 00       	call   801051ab <acquire>
  while(n > 0){
8010096d:	e9 aa 00 00 00       	jmp    80100a1c <consoleread+0xd2>
    while(input.r == input.w){
80100972:	eb 42                	jmp    801009b6 <consoleread+0x6c>
      if(proc->killed){
80100974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010097a:	8b 40 2c             	mov    0x2c(%eax),%eax
8010097d:	85 c0                	test   %eax,%eax
8010097f:	74 21                	je     801009a2 <consoleread+0x58>
        release(&cons.lock);
80100981:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100988:	e8 80 48 00 00       	call   8010520d <release>
        ilock(ip);
8010098d:	8b 45 08             	mov    0x8(%ebp),%eax
80100990:	89 04 24             	mov    %eax,(%esp)
80100993:	e8 3c 0f 00 00       	call   801018d4 <ilock>
        return -1;
80100998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099d:	e9 a5 00 00 00       	jmp    80100a47 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
801009a2:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
801009a9:	80 
801009aa:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
801009b1:	e8 2a 43 00 00       	call   80104ce0 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009b6:	8b 15 20 08 11 80    	mov    0x80110820,%edx
801009bc:	a1 24 08 11 80       	mov    0x80110824,%eax
801009c1:	39 c2                	cmp    %eax,%edx
801009c3:	74 af                	je     80100974 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009c5:	a1 20 08 11 80       	mov    0x80110820,%eax
801009ca:	8d 50 01             	lea    0x1(%eax),%edx
801009cd:	89 15 20 08 11 80    	mov    %edx,0x80110820
801009d3:	83 e0 7f             	and    $0x7f,%eax
801009d6:	0f b6 80 a0 07 11 80 	movzbl -0x7feef860(%eax),%eax
801009dd:	0f be c0             	movsbl %al,%eax
801009e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009e3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009e7:	75 19                	jne    80100a02 <consoleread+0xb8>
      if(n < target){
801009e9:	8b 45 10             	mov    0x10(%ebp),%eax
801009ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009ef:	73 0f                	jae    80100a00 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009f1:	a1 20 08 11 80       	mov    0x80110820,%eax
801009f6:	83 e8 01             	sub    $0x1,%eax
801009f9:	a3 20 08 11 80       	mov    %eax,0x80110820
      }
      break;
801009fe:	eb 26                	jmp    80100a26 <consoleread+0xdc>
80100a00:	eb 24                	jmp    80100a26 <consoleread+0xdc>
    }
    *dst++ = c;
80100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a05:	8d 50 01             	lea    0x1(%eax),%edx
80100a08:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a0e:	88 10                	mov    %dl,(%eax)
    --n;
80100a10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a14:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a18:	75 02                	jne    80100a1c <consoleread+0xd2>
      break;
80100a1a:	eb 0a                	jmp    80100a26 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a20:	0f 8f 4c ff ff ff    	jg     80100972 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a26:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a2d:	e8 db 47 00 00       	call   8010520d <release>
  ilock(ip);
80100a32:	8b 45 08             	mov    0x8(%ebp),%eax
80100a35:	89 04 24             	mov    %eax,(%esp)
80100a38:	e8 97 0e 00 00       	call   801018d4 <ilock>

  return target - n;
80100a3d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	29 c2                	sub    %eax,%edx
80100a45:	89 d0                	mov    %edx,%eax
}
80100a47:	c9                   	leave  
80100a48:	c3                   	ret    

80100a49 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a49:	55                   	push   %ebp
80100a4a:	89 e5                	mov    %esp,%ebp
80100a4c:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a52:	89 04 24             	mov    %eax,(%esp)
80100a55:	e8 ce 0f 00 00       	call   80101a28 <iunlock>
  acquire(&cons.lock);
80100a5a:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a61:	e8 45 47 00 00       	call   801051ab <acquire>
  for(i = 0; i < n; i++)
80100a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a6d:	eb 1d                	jmp    80100a8c <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a75:	01 d0                	add    %edx,%eax
80100a77:	0f b6 00             	movzbl (%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	0f b6 c0             	movzbl %al,%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e3 fc ff ff       	call   8010076b <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a92:	7c db                	jl     80100a6f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a94:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a9b:	e8 6d 47 00 00       	call   8010520d <release>
  ilock(ip);
80100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 29 0e 00 00       	call   801018d4 <ilock>

  return n;
80100aab:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aae:	c9                   	leave  
80100aaf:	c3                   	ret    

80100ab0 <consoleinit>:

void
consoleinit(void)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ab6:	c7 44 24 04 02 89 10 	movl   $0x80108902,0x4(%esp)
80100abd:	80 
80100abe:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100ac5:	e8 c0 46 00 00       	call   8010518a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aca:	c7 05 ec 11 11 80 49 	movl   $0x80100a49,0x801111ec
80100ad1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad4:	c7 05 e8 11 11 80 4a 	movl   $0x8010094a,0x801111e8
80100adb:	09 10 80 
  cons.locking = 1;
80100ade:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100ae5:	00 00 00 

  picenable(IRQ_KBD);
80100ae8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aef:	e8 67 33 00 00       	call   80103e5b <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100afb:	00 
80100afc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b03:	e8 0b 1f 00 00       	call   80102a13 <ioapicenable>
}
80100b08:	c9                   	leave  
80100b09:	c3                   	ret    

80100b0a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b0a:	55                   	push   %ebp
80100b0b:	89 e5                	mov    %esp,%ebp
80100b0d:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b13:	e8 a4 29 00 00       	call   801034bc <begin_op>
  if((ip = namei(path)) == 0){
80100b18:	8b 45 08             	mov    0x8(%ebp),%eax
80100b1b:	89 04 24             	mov    %eax,(%esp)
80100b1e:	e8 62 19 00 00       	call   80102485 <namei>
80100b23:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b26:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b2a:	75 0f                	jne    80100b3b <exec+0x31>
    end_op();
80100b2c:	e8 0f 2a 00 00       	call   80103540 <end_op>
    return -1;
80100b31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b36:	e9 e8 03 00 00       	jmp    80100f23 <exec+0x419>
  }
  ilock(ip);
80100b3b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b3e:	89 04 24             	mov    %eax,(%esp)
80100b41:	e8 8e 0d 00 00       	call   801018d4 <ilock>
  pgdir = 0;
80100b46:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b4d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b54:	00 
80100b55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b5c:	00 
80100b5d:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b67:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b6a:	89 04 24             	mov    %eax,(%esp)
80100b6d:	e8 75 12 00 00       	call   80101de7 <readi>
80100b72:	83 f8 33             	cmp    $0x33,%eax
80100b75:	77 05                	ja     80100b7c <exec+0x72>
    goto bad;
80100b77:	e9 7b 03 00 00       	jmp    80100ef7 <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b7c:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b82:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b87:	74 05                	je     80100b8e <exec+0x84>
    goto bad;
80100b89:	e9 69 03 00 00       	jmp    80100ef7 <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b8e:	e8 a5 74 00 00       	call   80108038 <setupkvm>
80100b93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b96:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b9a:	75 05                	jne    80100ba1 <exec+0x97>
    goto bad;
80100b9c:	e9 56 03 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100ba1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ba8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100baf:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bb8:	e9 cb 00 00 00       	jmp    80100c88 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bc0:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bc7:	00 
80100bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bcc:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bd9:	89 04 24             	mov    %eax,(%esp)
80100bdc:	e8 06 12 00 00       	call   80101de7 <readi>
80100be1:	83 f8 20             	cmp    $0x20,%eax
80100be4:	74 05                	je     80100beb <exec+0xe1>
      goto bad;
80100be6:	e9 0c 03 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100beb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bf1:	83 f8 01             	cmp    $0x1,%eax
80100bf4:	74 05                	je     80100bfb <exec+0xf1>
      continue;
80100bf6:	e9 80 00 00 00       	jmp    80100c7b <exec+0x171>
    if(ph.memsz < ph.filesz)
80100bfb:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c01:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c07:	39 c2                	cmp    %eax,%edx
80100c09:	73 05                	jae    80100c10 <exec+0x106>
      goto bad;
80100c0b:	e9 e7 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c10:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c16:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c1c:	01 d0                	add    %edx,%eax
80100c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c25:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c2c:	89 04 24             	mov    %eax,(%esp)
80100c2f:	e8 d2 77 00 00       	call   80108406 <allocuvm>
80100c34:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c3b:	75 05                	jne    80100c42 <exec+0x138>
      goto bad;
80100c3d:	e9 b5 02 00 00       	jmp    80100ef7 <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c42:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c48:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c4e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c54:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c58:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c5f:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c63:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c6a:	89 04 24             	mov    %eax,(%esp)
80100c6d:	e8 a9 76 00 00       	call   8010831b <loaduvm>
80100c72:	85 c0                	test   %eax,%eax
80100c74:	79 05                	jns    80100c7b <exec+0x171>
      goto bad;
80100c76:	e9 7c 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c7b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c82:	83 c0 20             	add    $0x20,%eax
80100c85:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c88:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c8f:	0f b7 c0             	movzwl %ax,%eax
80100c92:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c95:	0f 8f 22 ff ff ff    	jg     80100bbd <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c9e:	89 04 24             	mov    %eax,(%esp)
80100ca1:	e8 b8 0e 00 00       	call   80101b5e <iunlockput>
  end_op();
80100ca6:	e8 95 28 00 00       	call   80103540 <end_op>
  ip = 0;
80100cab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb5:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc5:	05 00 20 00 00       	add    $0x2000,%eax
80100cca:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd8:	89 04 24             	mov    %eax,(%esp)
80100cdb:	e8 26 77 00 00       	call   80108406 <allocuvm>
80100ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce7:	75 05                	jne    80100cee <exec+0x1e4>
    goto bad;
80100ce9:	e9 09 02 00 00       	jmp    80100ef7 <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf1:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cfd:	89 04 24             	mov    %eax,(%esp)
80100d00:	e8 31 79 00 00       	call   80108636 <clearpteu>
  sp = sz;
80100d05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d08:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d0b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d12:	e9 9a 00 00 00       	jmp    80100db1 <exec+0x2a7>
    if(argc >= MAXARG)
80100d17:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d1b:	76 05                	jbe    80100d22 <exec+0x218>
      goto bad;
80100d1d:	e9 d5 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d2f:	01 d0                	add    %edx,%eax
80100d31:	8b 00                	mov    (%eax),%eax
80100d33:	89 04 24             	mov    %eax,(%esp)
80100d36:	e8 2e 49 00 00       	call   80105669 <strlen>
80100d3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d3e:	29 c2                	sub    %eax,%edx
80100d40:	89 d0                	mov    %edx,%eax
80100d42:	83 e8 01             	sub    $0x1,%eax
80100d45:	83 e0 fc             	and    $0xfffffffc,%eax
80100d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d58:	01 d0                	add    %edx,%eax
80100d5a:	8b 00                	mov    (%eax),%eax
80100d5c:	89 04 24             	mov    %eax,(%esp)
80100d5f:	e8 05 49 00 00       	call   80105669 <strlen>
80100d64:	83 c0 01             	add    $0x1,%eax
80100d67:	89 c2                	mov    %eax,%edx
80100d69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d73:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d76:	01 c8                	add    %ecx,%eax
80100d78:	8b 00                	mov    (%eax),%eax
80100d7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d82:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d85:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d8c:	89 04 24             	mov    %eax,(%esp)
80100d8f:	e8 67 7a 00 00       	call   801087fb <copyout>
80100d94:	85 c0                	test   %eax,%eax
80100d96:	79 05                	jns    80100d9d <exec+0x293>
      goto bad;
80100d98:	e9 5a 01 00 00       	jmp    80100ef7 <exec+0x3ed>
    ustack[3+argc] = sp;
80100d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da0:	8d 50 03             	lea    0x3(%eax),%edx
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dad:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100db1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dbe:	01 d0                	add    %edx,%eax
80100dc0:	8b 00                	mov    (%eax),%eax
80100dc2:	85 c0                	test   %eax,%eax
80100dc4:	0f 85 4d ff ff ff    	jne    80100d17 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	83 c0 03             	add    $0x3,%eax
80100dd0:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dd7:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ddb:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100de2:	ff ff ff 
  ustack[1] = argc;
80100de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de8:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df1:	83 c0 01             	add    $0x1,%eax
80100df4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dfe:	29 d0                	sub    %edx,%eax
80100e00:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e09:	83 c0 04             	add    $0x4,%eax
80100e0c:	c1 e0 02             	shl    $0x2,%eax
80100e0f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e15:	83 c0 04             	add    $0x4,%eax
80100e18:	c1 e0 02             	shl    $0x2,%eax
80100e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e1f:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e25:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e29:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e33:	89 04 24             	mov    %eax,(%esp)
80100e36:	e8 c0 79 00 00       	call   801087fb <copyout>
80100e3b:	85 c0                	test   %eax,%eax
80100e3d:	79 05                	jns    80100e44 <exec+0x33a>
    goto bad;
80100e3f:	e9 b3 00 00 00       	jmp    80100ef7 <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e44:	8b 45 08             	mov    0x8(%ebp),%eax
80100e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e50:	eb 17                	jmp    80100e69 <exec+0x35f>
    if(*s == '/')
80100e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e55:	0f b6 00             	movzbl (%eax),%eax
80100e58:	3c 2f                	cmp    $0x2f,%al
80100e5a:	75 09                	jne    80100e65 <exec+0x35b>
      last = s+1;
80100e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5f:	83 c0 01             	add    $0x1,%eax
80100e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6c:	0f b6 00             	movzbl (%eax),%eax
80100e6f:	84 c0                	test   %al,%al
80100e71:	75 df                	jne    80100e52 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	8d 50 78             	lea    0x78(%eax),%edx
80100e7c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e83:	00 
80100e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e8b:	89 14 24             	mov    %edx,(%esp)
80100e8e:	e8 8c 47 00 00       	call   8010561f <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e99:	8b 40 04             	mov    0x4(%eax),%eax
80100e9c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea8:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb4:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebc:	8b 40 20             	mov    0x20(%eax),%eax
80100ebf:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ec5:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ece:	8b 40 20             	mov    0x20(%eax),%eax
80100ed1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edd:	89 04 24             	mov    %eax,(%esp)
80100ee0:	e8 44 72 00 00       	call   80108129 <switchuvm>
  freevm(oldpgdir);
80100ee5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ee8:	89 04 24             	mov    %eax,(%esp)
80100eeb:	e8 ac 76 00 00       	call   8010859c <freevm>
  return 0;
80100ef0:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef5:	eb 2c                	jmp    80100f23 <exec+0x419>

 bad:
  if(pgdir)
80100ef7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100efb:	74 0b                	je     80100f08 <exec+0x3fe>
    freevm(pgdir);
80100efd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f00:	89 04 24             	mov    %eax,(%esp)
80100f03:	e8 94 76 00 00       	call   8010859c <freevm>
  if(ip){
80100f08:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f0c:	74 10                	je     80100f1e <exec+0x414>
    iunlockput(ip);
80100f0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f11:	89 04 24             	mov    %eax,(%esp)
80100f14:	e8 45 0c 00 00       	call   80101b5e <iunlockput>
    end_op();
80100f19:	e8 22 26 00 00       	call   80103540 <end_op>
  }
  return -1;
80100f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f23:	c9                   	leave  
80100f24:	c3                   	ret    

80100f25 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f25:	55                   	push   %ebp
80100f26:	89 e5                	mov    %esp,%ebp
80100f28:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f2b:	c7 44 24 04 0a 89 10 	movl   $0x8010890a,0x4(%esp)
80100f32:	80 
80100f33:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f3a:	e8 4b 42 00 00       	call   8010518a <initlock>
}
80100f3f:	c9                   	leave  
80100f40:	c3                   	ret    

80100f41 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f41:	55                   	push   %ebp
80100f42:	89 e5                	mov    %esp,%ebp
80100f44:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f47:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f4e:	e8 58 42 00 00       	call   801051ab <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f53:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f5a:	eb 29                	jmp    80100f85 <filealloc+0x44>
    if(f->ref == 0){
80100f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5f:	8b 40 04             	mov    0x4(%eax),%eax
80100f62:	85 c0                	test   %eax,%eax
80100f64:	75 1b                	jne    80100f81 <filealloc+0x40>
      f->ref = 1;
80100f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f69:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f70:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f77:	e8 91 42 00 00       	call   8010520d <release>
      return f;
80100f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7f:	eb 1e                	jmp    80100f9f <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f81:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f85:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f8c:	72 ce                	jb     80100f5c <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f8e:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f95:	e8 73 42 00 00       	call   8010520d <release>
  return 0;
80100f9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f9f:	c9                   	leave  
80100fa0:	c3                   	ret    

80100fa1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fa1:	55                   	push   %ebp
80100fa2:	89 e5                	mov    %esp,%ebp
80100fa4:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fa7:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fae:	e8 f8 41 00 00       	call   801051ab <acquire>
  if(f->ref < 1)
80100fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb6:	8b 40 04             	mov    0x4(%eax),%eax
80100fb9:	85 c0                	test   %eax,%eax
80100fbb:	7f 0c                	jg     80100fc9 <filedup+0x28>
    panic("filedup");
80100fbd:	c7 04 24 11 89 10 80 	movl   $0x80108911,(%esp)
80100fc4:	e8 71 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcc:	8b 40 04             	mov    0x4(%eax),%eax
80100fcf:	8d 50 01             	lea    0x1(%eax),%edx
80100fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fd8:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fdf:	e8 29 42 00 00       	call   8010520d <release>
  return f;
80100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fe7:	c9                   	leave  
80100fe8:	c3                   	ret    

80100fe9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fe9:	55                   	push   %ebp
80100fea:	89 e5                	mov    %esp,%ebp
80100fec:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fef:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100ff6:	e8 b0 41 00 00       	call   801051ab <acquire>
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0c                	jg     80101011 <fileclose+0x28>
    panic("fileclose");
80101005:	c7 04 24 19 89 10 80 	movl   $0x80108919,(%esp)
8010100c:	e8 29 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101011:	8b 45 08             	mov    0x8(%ebp),%eax
80101014:	8b 40 04             	mov    0x4(%eax),%eax
80101017:	8d 50 ff             	lea    -0x1(%eax),%edx
8010101a:	8b 45 08             	mov    0x8(%ebp),%eax
8010101d:	89 50 04             	mov    %edx,0x4(%eax)
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 40 04             	mov    0x4(%eax),%eax
80101026:	85 c0                	test   %eax,%eax
80101028:	7e 11                	jle    8010103b <fileclose+0x52>
    release(&ftable.lock);
8010102a:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101031:	e8 d7 41 00 00       	call   8010520d <release>
80101036:	e9 82 00 00 00       	jmp    801010bd <fileclose+0xd4>
    return;
  }
  ff = *f;
8010103b:	8b 45 08             	mov    0x8(%ebp),%eax
8010103e:	8b 10                	mov    (%eax),%edx
80101040:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101043:	8b 50 04             	mov    0x4(%eax),%edx
80101046:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101049:	8b 50 08             	mov    0x8(%eax),%edx
8010104c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010104f:	8b 50 0c             	mov    0xc(%eax),%edx
80101052:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101055:	8b 50 10             	mov    0x10(%eax),%edx
80101058:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010105b:	8b 40 14             	mov    0x14(%eax),%eax
8010105e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101061:	8b 45 08             	mov    0x8(%ebp),%eax
80101064:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010106b:	8b 45 08             	mov    0x8(%ebp),%eax
8010106e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101074:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010107b:	e8 8d 41 00 00       	call   8010520d <release>
  
  if(ff.type == FD_PIPE)
80101080:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101083:	83 f8 01             	cmp    $0x1,%eax
80101086:	75 18                	jne    801010a0 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101088:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010108c:	0f be d0             	movsbl %al,%edx
8010108f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101092:	89 54 24 04          	mov    %edx,0x4(%esp)
80101096:	89 04 24             	mov    %eax,(%esp)
80101099:	e8 6d 30 00 00       	call   8010410b <pipeclose>
8010109e:	eb 1d                	jmp    801010bd <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a3:	83 f8 02             	cmp    $0x2,%eax
801010a6:	75 15                	jne    801010bd <fileclose+0xd4>
    begin_op();
801010a8:	e8 0f 24 00 00       	call   801034bc <begin_op>
    iput(ff.ip);
801010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010b0:	89 04 24             	mov    %eax,(%esp)
801010b3:	e8 d5 09 00 00       	call   80101a8d <iput>
    end_op();
801010b8:	e8 83 24 00 00       	call   80103540 <end_op>
  }
}
801010bd:	c9                   	leave  
801010be:	c3                   	ret    

801010bf <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010bf:	55                   	push   %ebp
801010c0:	89 e5                	mov    %esp,%ebp
801010c2:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 00                	mov    (%eax),%eax
801010ca:	83 f8 02             	cmp    $0x2,%eax
801010cd:	75 38                	jne    80101107 <filestat+0x48>
    ilock(f->ip);
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 40 10             	mov    0x10(%eax),%eax
801010d5:	89 04 24             	mov    %eax,(%esp)
801010d8:	e8 f7 07 00 00       	call   801018d4 <ilock>
    stati(f->ip, st);
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	8b 40 10             	mov    0x10(%eax),%eax
801010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801010ea:	89 04 24             	mov    %eax,(%esp)
801010ed:	e8 b0 0c 00 00       	call   80101da2 <stati>
    iunlock(f->ip);
801010f2:	8b 45 08             	mov    0x8(%ebp),%eax
801010f5:	8b 40 10             	mov    0x10(%eax),%eax
801010f8:	89 04 24             	mov    %eax,(%esp)
801010fb:	e8 28 09 00 00       	call   80101a28 <iunlock>
    return 0;
80101100:	b8 00 00 00 00       	mov    $0x0,%eax
80101105:	eb 05                	jmp    8010110c <filestat+0x4d>
  }
  return -1;
80101107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010110c:	c9                   	leave  
8010110d:	c3                   	ret    

8010110e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010110e:	55                   	push   %ebp
8010110f:	89 e5                	mov    %esp,%ebp
80101111:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101114:	8b 45 08             	mov    0x8(%ebp),%eax
80101117:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010111b:	84 c0                	test   %al,%al
8010111d:	75 0a                	jne    80101129 <fileread+0x1b>
    return -1;
8010111f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101124:	e9 9f 00 00 00       	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_PIPE)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 00                	mov    (%eax),%eax
8010112e:	83 f8 01             	cmp    $0x1,%eax
80101131:	75 1e                	jne    80101151 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	8b 40 0c             	mov    0xc(%eax),%eax
80101139:	8b 55 10             	mov    0x10(%ebp),%edx
8010113c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101140:	8b 55 0c             	mov    0xc(%ebp),%edx
80101143:	89 54 24 04          	mov    %edx,0x4(%esp)
80101147:	89 04 24             	mov    %eax,(%esp)
8010114a:	e8 3d 31 00 00       	call   8010428c <piperead>
8010114f:	eb 77                	jmp    801011c8 <fileread+0xba>
  if(f->type == FD_INODE){
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 00                	mov    (%eax),%eax
80101156:	83 f8 02             	cmp    $0x2,%eax
80101159:	75 61                	jne    801011bc <fileread+0xae>
    ilock(f->ip);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	89 04 24             	mov    %eax,(%esp)
80101164:	e8 6b 07 00 00       	call   801018d4 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101169:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 50 14             	mov    0x14(%eax),%edx
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 10             	mov    0x10(%eax),%eax
80101178:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010117c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101180:	8b 55 0c             	mov    0xc(%ebp),%edx
80101183:	89 54 24 04          	mov    %edx,0x4(%esp)
80101187:	89 04 24             	mov    %eax,(%esp)
8010118a:	e8 58 0c 00 00       	call   80101de7 <readi>
8010118f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101192:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101196:	7e 11                	jle    801011a9 <fileread+0x9b>
      f->off += r;
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	8b 50 14             	mov    0x14(%eax),%edx
8010119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a1:	01 c2                	add    %eax,%edx
801011a3:	8b 45 08             	mov    0x8(%ebp),%eax
801011a6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011a9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ac:	8b 40 10             	mov    0x10(%eax),%eax
801011af:	89 04 24             	mov    %eax,(%esp)
801011b2:	e8 71 08 00 00       	call   80101a28 <iunlock>
    return r;
801011b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ba:	eb 0c                	jmp    801011c8 <fileread+0xba>
  }
  panic("fileread");
801011bc:	c7 04 24 23 89 10 80 	movl   $0x80108923,(%esp)
801011c3:	e8 72 f3 ff ff       	call   8010053a <panic>
}
801011c8:	c9                   	leave  
801011c9:	c3                   	ret    

801011ca <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011ca:	55                   	push   %ebp
801011cb:	89 e5                	mov    %esp,%ebp
801011cd:	53                   	push   %ebx
801011ce:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011d8:	84 c0                	test   %al,%al
801011da:	75 0a                	jne    801011e6 <filewrite+0x1c>
    return -1;
801011dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e1:	e9 20 01 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 00                	mov    (%eax),%eax
801011eb:	83 f8 01             	cmp    $0x1,%eax
801011ee:	75 21                	jne    80101211 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0c             	mov    0xc(%eax),%eax
801011f6:	8b 55 10             	mov    0x10(%ebp),%edx
801011f9:	89 54 24 08          	mov    %edx,0x8(%esp)
801011fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101200:	89 54 24 04          	mov    %edx,0x4(%esp)
80101204:	89 04 24             	mov    %eax,(%esp)
80101207:	e8 91 2f 00 00       	call   8010419d <pipewrite>
8010120c:	e9 f5 00 00 00       	jmp    80101306 <filewrite+0x13c>
  if(f->type == FD_INODE){
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 00                	mov    (%eax),%eax
80101216:	83 f8 02             	cmp    $0x2,%eax
80101219:	0f 85 db 00 00 00    	jne    801012fa <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010121f:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101226:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010122d:	e9 a8 00 00 00       	jmp    801012da <filewrite+0x110>
      int n1 = n - i;
80101232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101235:	8b 55 10             	mov    0x10(%ebp),%edx
80101238:	29 c2                	sub    %eax,%edx
8010123a:	89 d0                	mov    %edx,%eax
8010123c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101242:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101245:	7e 06                	jle    8010124d <filewrite+0x83>
        n1 = max;
80101247:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010124d:	e8 6a 22 00 00       	call   801034bc <begin_op>
      ilock(f->ip);
80101252:	8b 45 08             	mov    0x8(%ebp),%eax
80101255:	8b 40 10             	mov    0x10(%eax),%eax
80101258:	89 04 24             	mov    %eax,(%esp)
8010125b:	e8 74 06 00 00       	call   801018d4 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101260:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 50 14             	mov    0x14(%eax),%edx
80101269:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010126c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010126f:	01 c3                	add    %eax,%ebx
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 40 10             	mov    0x10(%eax),%eax
80101277:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010127b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010127f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101283:	89 04 24             	mov    %eax,(%esp)
80101286:	e8 c0 0c 00 00       	call   80101f4b <writei>
8010128b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010128e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101292:	7e 11                	jle    801012a5 <filewrite+0xdb>
        f->off += r;
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	8b 50 14             	mov    0x14(%eax),%edx
8010129a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129d:	01 c2                	add    %eax,%edx
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 40 10             	mov    0x10(%eax),%eax
801012ab:	89 04 24             	mov    %eax,(%esp)
801012ae:	e8 75 07 00 00       	call   80101a28 <iunlock>
      end_op();
801012b3:	e8 88 22 00 00       	call   80103540 <end_op>

      if(r < 0)
801012b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012bc:	79 02                	jns    801012c0 <filewrite+0xf6>
        break;
801012be:	eb 26                	jmp    801012e6 <filewrite+0x11c>
      if(r != n1)
801012c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012c6:	74 0c                	je     801012d4 <filewrite+0x10a>
        panic("short filewrite");
801012c8:	c7 04 24 2c 89 10 80 	movl   $0x8010892c,(%esp)
801012cf:	e8 66 f2 ff ff       	call   8010053a <panic>
      i += r;
801012d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d7:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012dd:	3b 45 10             	cmp    0x10(%ebp),%eax
801012e0:	0f 8c 4c ff ff ff    	jl     80101232 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e9:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ec:	75 05                	jne    801012f3 <filewrite+0x129>
801012ee:	8b 45 10             	mov    0x10(%ebp),%eax
801012f1:	eb 05                	jmp    801012f8 <filewrite+0x12e>
801012f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f8:	eb 0c                	jmp    80101306 <filewrite+0x13c>
  }
  panic("filewrite");
801012fa:	c7 04 24 3c 89 10 80 	movl   $0x8010893c,(%esp)
80101301:	e8 34 f2 ff ff       	call   8010053a <panic>
}
80101306:	83 c4 24             	add    $0x24,%esp
80101309:	5b                   	pop    %ebx
8010130a:	5d                   	pop    %ebp
8010130b:	c3                   	ret    

8010130c <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010130c:	55                   	push   %ebp
8010130d:	89 e5                	mov    %esp,%ebp
8010130f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010131c:	00 
8010131d:	89 04 24             	mov    %eax,(%esp)
80101320:	e8 81 ee ff ff       	call   801001a6 <bread>
80101325:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132b:	83 c0 18             	add    $0x18,%eax
8010132e:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101335:	00 
80101336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 89 41 00 00       	call   801054ce <memmove>
  brelse(bp);
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	89 04 24             	mov    %eax,(%esp)
8010134b:	e8 c7 ee ff ff       	call   80100217 <brelse>
}
80101350:	c9                   	leave  
80101351:	c3                   	ret    

80101352 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101352:	55                   	push   %ebp
80101353:	89 e5                	mov    %esp,%ebp
80101355:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101358:	8b 55 0c             	mov    0xc(%ebp),%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101362:	89 04 24             	mov    %eax,(%esp)
80101365:	e8 3c ee ff ff       	call   801001a6 <bread>
8010136a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010136d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101370:	83 c0 18             	add    $0x18,%eax
80101373:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010137a:	00 
8010137b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101382:	00 
80101383:	89 04 24             	mov    %eax,(%esp)
80101386:	e8 74 40 00 00       	call   801053ff <memset>
  log_write(bp);
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	89 04 24             	mov    %eax,(%esp)
80101391:	e8 31 23 00 00       	call   801036c7 <log_write>
  brelse(bp);
80101396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101399:	89 04 24             	mov    %eax,(%esp)
8010139c:	e8 76 ee ff ff       	call   80100217 <brelse>
}
801013a1:	c9                   	leave  
801013a2:	c3                   	ret    

801013a3 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013a3:	55                   	push   %ebp
801013a4:	89 e5                	mov    %esp,%ebp
801013a6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013a9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013b7:	e9 07 01 00 00       	jmp    801014c3 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
801013bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013bf:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013c5:	85 c0                	test   %eax,%eax
801013c7:	0f 48 c2             	cmovs  %edx,%eax
801013ca:	c1 f8 0c             	sar    $0xc,%eax
801013cd:	89 c2                	mov    %eax,%edx
801013cf:	a1 58 12 11 80       	mov    0x80111258,%eax
801013d4:	01 d0                	add    %edx,%eax
801013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801013da:	8b 45 08             	mov    0x8(%ebp),%eax
801013dd:	89 04 24             	mov    %eax,(%esp)
801013e0:	e8 c1 ed ff ff       	call   801001a6 <bread>
801013e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013ef:	e9 9d 00 00 00       	jmp    80101491 <balloc+0xee>
      m = 1 << (bi % 8);
801013f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f7:	99                   	cltd   
801013f8:	c1 ea 1d             	shr    $0x1d,%edx
801013fb:	01 d0                	add    %edx,%eax
801013fd:	83 e0 07             	and    $0x7,%eax
80101400:	29 d0                	sub    %edx,%eax
80101402:	ba 01 00 00 00       	mov    $0x1,%edx
80101407:	89 c1                	mov    %eax,%ecx
80101409:	d3 e2                	shl    %cl,%edx
8010140b:	89 d0                	mov    %edx,%eax
8010140d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101413:	8d 50 07             	lea    0x7(%eax),%edx
80101416:	85 c0                	test   %eax,%eax
80101418:	0f 48 c2             	cmovs  %edx,%eax
8010141b:	c1 f8 03             	sar    $0x3,%eax
8010141e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101421:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101426:	0f b6 c0             	movzbl %al,%eax
80101429:	23 45 e8             	and    -0x18(%ebp),%eax
8010142c:	85 c0                	test   %eax,%eax
8010142e:	75 5d                	jne    8010148d <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101433:	8d 50 07             	lea    0x7(%eax),%edx
80101436:	85 c0                	test   %eax,%eax
80101438:	0f 48 c2             	cmovs  %edx,%eax
8010143b:	c1 f8 03             	sar    $0x3,%eax
8010143e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101441:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101446:	89 d1                	mov    %edx,%ecx
80101448:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010144b:	09 ca                	or     %ecx,%edx
8010144d:	89 d1                	mov    %edx,%ecx
8010144f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101452:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101456:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101459:	89 04 24             	mov    %eax,(%esp)
8010145c:	e8 66 22 00 00       	call   801036c7 <log_write>
        brelse(bp);
80101461:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101464:	89 04 24             	mov    %eax,(%esp)
80101467:	e8 ab ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010146c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101472:	01 c2                	add    %eax,%edx
80101474:	8b 45 08             	mov    0x8(%ebp),%eax
80101477:	89 54 24 04          	mov    %edx,0x4(%esp)
8010147b:	89 04 24             	mov    %eax,(%esp)
8010147e:	e8 cf fe ff ff       	call   80101352 <bzero>
        return b + bi;
80101483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101486:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101489:	01 d0                	add    %edx,%eax
8010148b:	eb 52                	jmp    801014df <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010148d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101491:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101498:	7f 17                	jg     801014b1 <balloc+0x10e>
8010149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a0:	01 d0                	add    %edx,%eax
801014a2:	89 c2                	mov    %eax,%edx
801014a4:	a1 40 12 11 80       	mov    0x80111240,%eax
801014a9:	39 c2                	cmp    %eax,%edx
801014ab:	0f 82 43 ff ff ff    	jb     801013f4 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b4:	89 04 24             	mov    %eax,(%esp)
801014b7:	e8 5b ed ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014bc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c6:	a1 40 12 11 80       	mov    0x80111240,%eax
801014cb:	39 c2                	cmp    %eax,%edx
801014cd:	0f 82 e9 fe ff ff    	jb     801013bc <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014d3:	c7 04 24 48 89 10 80 	movl   $0x80108948,(%esp)
801014da:	e8 5b f0 ff ff       	call   8010053a <panic>
}
801014df:	c9                   	leave  
801014e0:	c3                   	ret    

801014e1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e1:	55                   	push   %ebp
801014e2:	89 e5                	mov    %esp,%ebp
801014e4:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801014e7:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801014ee:	80 
801014ef:	8b 45 08             	mov    0x8(%ebp),%eax
801014f2:	89 04 24             	mov    %eax,(%esp)
801014f5:	e8 12 fe ff ff       	call   8010130c <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801014fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801014fd:	c1 e8 0c             	shr    $0xc,%eax
80101500:	89 c2                	mov    %eax,%edx
80101502:	a1 58 12 11 80       	mov    0x80111258,%eax
80101507:	01 c2                	add    %eax,%edx
80101509:	8b 45 08             	mov    0x8(%ebp),%eax
8010150c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101510:	89 04 24             	mov    %eax,(%esp)
80101513:	e8 8e ec ff ff       	call   801001a6 <bread>
80101518:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010151b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010151e:	25 ff 0f 00 00       	and    $0xfff,%eax
80101523:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101529:	99                   	cltd   
8010152a:	c1 ea 1d             	shr    $0x1d,%edx
8010152d:	01 d0                	add    %edx,%eax
8010152f:	83 e0 07             	and    $0x7,%eax
80101532:	29 d0                	sub    %edx,%eax
80101534:	ba 01 00 00 00       	mov    $0x1,%edx
80101539:	89 c1                	mov    %eax,%ecx
8010153b:	d3 e2                	shl    %cl,%edx
8010153d:	89 d0                	mov    %edx,%eax
8010153f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101545:	8d 50 07             	lea    0x7(%eax),%edx
80101548:	85 c0                	test   %eax,%eax
8010154a:	0f 48 c2             	cmovs  %edx,%eax
8010154d:	c1 f8 03             	sar    $0x3,%eax
80101550:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101553:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101558:	0f b6 c0             	movzbl %al,%eax
8010155b:	23 45 ec             	and    -0x14(%ebp),%eax
8010155e:	85 c0                	test   %eax,%eax
80101560:	75 0c                	jne    8010156e <bfree+0x8d>
    panic("freeing free block");
80101562:	c7 04 24 5e 89 10 80 	movl   $0x8010895e,(%esp)
80101569:	e8 cc ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
8010156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101571:	8d 50 07             	lea    0x7(%eax),%edx
80101574:	85 c0                	test   %eax,%eax
80101576:	0f 48 c2             	cmovs  %edx,%eax
80101579:	c1 f8 03             	sar    $0x3,%eax
8010157c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157f:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101584:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101587:	f7 d1                	not    %ecx
80101589:	21 ca                	and    %ecx,%edx
8010158b:	89 d1                	mov    %edx,%ecx
8010158d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101590:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101597:	89 04 24             	mov    %eax,(%esp)
8010159a:	e8 28 21 00 00       	call   801036c7 <log_write>
  brelse(bp);
8010159f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a2:	89 04 24             	mov    %eax,(%esp)
801015a5:	e8 6d ec ff ff       	call   80100217 <brelse>
}
801015aa:	c9                   	leave  
801015ab:	c3                   	ret    

801015ac <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015ac:	55                   	push   %ebp
801015ad:	89 e5                	mov    %esp,%ebp
801015af:	57                   	push   %edi
801015b0:	56                   	push   %esi
801015b1:	53                   	push   %ebx
801015b2:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
801015b5:	c7 44 24 04 71 89 10 	movl   $0x80108971,0x4(%esp)
801015bc:	80 
801015bd:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801015c4:	e8 c1 3b 00 00       	call   8010518a <initlock>
  readsb(dev, &sb);
801015c9:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801015d0:	80 
801015d1:	8b 45 08             	mov    0x8(%ebp),%eax
801015d4:	89 04 24             	mov    %eax,(%esp)
801015d7:	e8 30 fd ff ff       	call   8010130c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
801015dc:	a1 58 12 11 80       	mov    0x80111258,%eax
801015e1:	8b 3d 54 12 11 80    	mov    0x80111254,%edi
801015e7:	8b 35 50 12 11 80    	mov    0x80111250,%esi
801015ed:	8b 1d 4c 12 11 80    	mov    0x8011124c,%ebx
801015f3:	8b 0d 48 12 11 80    	mov    0x80111248,%ecx
801015f9:	8b 15 44 12 11 80    	mov    0x80111244,%edx
801015ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101602:	8b 15 40 12 11 80    	mov    0x80111240,%edx
80101608:	89 44 24 1c          	mov    %eax,0x1c(%esp)
8010160c:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101610:	89 74 24 14          	mov    %esi,0x14(%esp)
80101614:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101618:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010161c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010161f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101623:	89 d0                	mov    %edx,%eax
80101625:	89 44 24 04          	mov    %eax,0x4(%esp)
80101629:	c7 04 24 78 89 10 80 	movl   $0x80108978,(%esp)
80101630:	e8 6b ed ff ff       	call   801003a0 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101635:	83 c4 3c             	add    $0x3c,%esp
80101638:	5b                   	pop    %ebx
80101639:	5e                   	pop    %esi
8010163a:	5f                   	pop    %edi
8010163b:	5d                   	pop    %ebp
8010163c:	c3                   	ret    

8010163d <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010163d:	55                   	push   %ebp
8010163e:	89 e5                	mov    %esp,%ebp
80101640:	83 ec 28             	sub    $0x28,%esp
80101643:	8b 45 0c             	mov    0xc(%ebp),%eax
80101646:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010164a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101651:	e9 9e 00 00 00       	jmp    801016f4 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101659:	c1 e8 03             	shr    $0x3,%eax
8010165c:	89 c2                	mov    %eax,%edx
8010165e:	a1 54 12 11 80       	mov    0x80111254,%eax
80101663:	01 d0                	add    %edx,%eax
80101665:	89 44 24 04          	mov    %eax,0x4(%esp)
80101669:	8b 45 08             	mov    0x8(%ebp),%eax
8010166c:	89 04 24             	mov    %eax,(%esp)
8010166f:	e8 32 eb ff ff       	call   801001a6 <bread>
80101674:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101677:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167a:	8d 50 18             	lea    0x18(%eax),%edx
8010167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101680:	83 e0 07             	and    $0x7,%eax
80101683:	c1 e0 06             	shl    $0x6,%eax
80101686:	01 d0                	add    %edx,%eax
80101688:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010168b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010168e:	0f b7 00             	movzwl (%eax),%eax
80101691:	66 85 c0             	test   %ax,%ax
80101694:	75 4f                	jne    801016e5 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101696:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010169d:	00 
8010169e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016a5:	00 
801016a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a9:	89 04 24             	mov    %eax,(%esp)
801016ac:	e8 4e 3d 00 00       	call   801053ff <memset>
      dip->type = type;
801016b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016b4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801016b8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016be:	89 04 24             	mov    %eax,(%esp)
801016c1:	e8 01 20 00 00       	call   801036c7 <log_write>
      brelse(bp);
801016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c9:	89 04 24             	mov    %eax,(%esp)
801016cc:	e8 46 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801016d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801016d8:	8b 45 08             	mov    0x8(%ebp),%eax
801016db:	89 04 24             	mov    %eax,(%esp)
801016de:	e8 ed 00 00 00       	call   801017d0 <iget>
801016e3:	eb 2b                	jmp    80101710 <ialloc+0xd3>
    }
    brelse(bp);
801016e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e8:	89 04 24             	mov    %eax,(%esp)
801016eb:	e8 27 eb ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f7:	a1 48 12 11 80       	mov    0x80111248,%eax
801016fc:	39 c2                	cmp    %eax,%edx
801016fe:	0f 82 52 ff ff ff    	jb     80101656 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101704:	c7 04 24 cb 89 10 80 	movl   $0x801089cb,(%esp)
8010170b:	e8 2a ee ff ff       	call   8010053a <panic>
}
80101710:	c9                   	leave  
80101711:	c3                   	ret    

80101712 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101712:	55                   	push   %ebp
80101713:	89 e5                	mov    %esp,%ebp
80101715:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101718:	8b 45 08             	mov    0x8(%ebp),%eax
8010171b:	8b 40 04             	mov    0x4(%eax),%eax
8010171e:	c1 e8 03             	shr    $0x3,%eax
80101721:	89 c2                	mov    %eax,%edx
80101723:	a1 54 12 11 80       	mov    0x80111254,%eax
80101728:	01 c2                	add    %eax,%edx
8010172a:	8b 45 08             	mov    0x8(%ebp),%eax
8010172d:	8b 00                	mov    (%eax),%eax
8010172f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101733:	89 04 24             	mov    %eax,(%esp)
80101736:	e8 6b ea ff ff       	call   801001a6 <bread>
8010173b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101741:	8d 50 18             	lea    0x18(%eax),%edx
80101744:	8b 45 08             	mov    0x8(%ebp),%eax
80101747:	8b 40 04             	mov    0x4(%eax),%eax
8010174a:	83 e0 07             	and    $0x7,%eax
8010174d:	c1 e0 06             	shl    $0x6,%eax
80101750:	01 d0                	add    %edx,%eax
80101752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101755:	8b 45 08             	mov    0x8(%ebp),%eax
80101758:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010175c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175f:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101762:	8b 45 08             	mov    0x8(%ebp),%eax
80101765:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101769:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101770:	8b 45 08             	mov    0x8(%ebp),%eax
80101773:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177a:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010177e:	8b 45 08             	mov    0x8(%ebp),%eax
80101781:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101785:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101788:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010178c:	8b 45 08             	mov    0x8(%ebp),%eax
8010178f:	8b 50 18             	mov    0x18(%eax),%edx
80101792:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101795:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101798:	8b 45 08             	mov    0x8(%ebp),%eax
8010179b:	8d 50 1c             	lea    0x1c(%eax),%edx
8010179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a1:	83 c0 0c             	add    $0xc,%eax
801017a4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801017ab:	00 
801017ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801017b0:	89 04 24             	mov    %eax,(%esp)
801017b3:	e8 16 3d 00 00       	call   801054ce <memmove>
  log_write(bp);
801017b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bb:	89 04 24             	mov    %eax,(%esp)
801017be:	e8 04 1f 00 00       	call   801036c7 <log_write>
  brelse(bp);
801017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c6:	89 04 24             	mov    %eax,(%esp)
801017c9:	e8 49 ea ff ff       	call   80100217 <brelse>
}
801017ce:	c9                   	leave  
801017cf:	c3                   	ret    

801017d0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017d0:	55                   	push   %ebp
801017d1:	89 e5                	mov    %esp,%ebp
801017d3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017d6:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801017dd:	e8 c9 39 00 00       	call   801051ab <acquire>

  // Is the inode already cached?
  empty = 0;
801017e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e9:	c7 45 f4 94 12 11 80 	movl   $0x80111294,-0xc(%ebp)
801017f0:	eb 59                	jmp    8010184b <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f5:	8b 40 08             	mov    0x8(%eax),%eax
801017f8:	85 c0                	test   %eax,%eax
801017fa:	7e 35                	jle    80101831 <iget+0x61>
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	8b 00                	mov    (%eax),%eax
80101801:	3b 45 08             	cmp    0x8(%ebp),%eax
80101804:	75 2b                	jne    80101831 <iget+0x61>
80101806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101809:	8b 40 04             	mov    0x4(%eax),%eax
8010180c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010180f:	75 20                	jne    80101831 <iget+0x61>
      ip->ref++;
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	8b 40 08             	mov    0x8(%eax),%eax
80101817:	8d 50 01             	lea    0x1(%eax),%edx
8010181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101820:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101827:	e8 e1 39 00 00       	call   8010520d <release>
      return ip;
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	eb 6f                	jmp    801018a0 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101831:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101835:	75 10                	jne    80101847 <iget+0x77>
80101837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183a:	8b 40 08             	mov    0x8(%eax),%eax
8010183d:	85 c0                	test   %eax,%eax
8010183f:	75 06                	jne    80101847 <iget+0x77>
      empty = ip;
80101841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101844:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101847:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010184b:	81 7d f4 34 22 11 80 	cmpl   $0x80112234,-0xc(%ebp)
80101852:	72 9e                	jb     801017f2 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101854:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101858:	75 0c                	jne    80101866 <iget+0x96>
    panic("iget: no inodes");
8010185a:	c7 04 24 dd 89 10 80 	movl   $0x801089dd,(%esp)
80101861:	e8 d4 ec ff ff       	call   8010053a <panic>

  ip = empty;
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010186c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186f:	8b 55 08             	mov    0x8(%ebp),%edx
80101872:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101877:	8b 55 0c             	mov    0xc(%ebp),%edx
8010187a:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101880:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101891:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101898:	e8 70 39 00 00       	call   8010520d <release>

  return ip;
8010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018a0:	c9                   	leave  
801018a1:	c3                   	ret    

801018a2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018a2:	55                   	push   %ebp
801018a3:	89 e5                	mov    %esp,%ebp
801018a5:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801018a8:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018af:	e8 f7 38 00 00       	call   801051ab <acquire>
  ip->ref++;
801018b4:	8b 45 08             	mov    0x8(%ebp),%eax
801018b7:	8b 40 08             	mov    0x8(%eax),%eax
801018ba:	8d 50 01             	lea    0x1(%eax),%edx
801018bd:	8b 45 08             	mov    0x8(%ebp),%eax
801018c0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018c3:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018ca:	e8 3e 39 00 00       	call   8010520d <release>
  return ip;
801018cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018d2:	c9                   	leave  
801018d3:	c3                   	ret    

801018d4 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018d4:	55                   	push   %ebp
801018d5:	89 e5                	mov    %esp,%ebp
801018d7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018de:	74 0a                	je     801018ea <ilock+0x16>
801018e0:	8b 45 08             	mov    0x8(%ebp),%eax
801018e3:	8b 40 08             	mov    0x8(%eax),%eax
801018e6:	85 c0                	test   %eax,%eax
801018e8:	7f 0c                	jg     801018f6 <ilock+0x22>
    panic("ilock");
801018ea:	c7 04 24 ed 89 10 80 	movl   $0x801089ed,(%esp)
801018f1:	e8 44 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801018f6:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
801018fd:	e8 a9 38 00 00       	call   801051ab <acquire>
  while(ip->flags & I_BUSY)
80101902:	eb 13                	jmp    80101917 <ilock+0x43>
    sleep(ip, &icache.lock);
80101904:	c7 44 24 04 60 12 11 	movl   $0x80111260,0x4(%esp)
8010190b:	80 
8010190c:	8b 45 08             	mov    0x8(%ebp),%eax
8010190f:	89 04 24             	mov    %eax,(%esp)
80101912:	e8 c9 33 00 00       	call   80104ce0 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	8b 40 0c             	mov    0xc(%eax),%eax
8010191d:	83 e0 01             	and    $0x1,%eax
80101920:	85 c0                	test   %eax,%eax
80101922:	75 e0                	jne    80101904 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	8b 40 0c             	mov    0xc(%eax),%eax
8010192a:	83 c8 01             	or     $0x1,%eax
8010192d:	89 c2                	mov    %eax,%edx
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101935:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
8010193c:	e8 cc 38 00 00       	call   8010520d <release>

  if(!(ip->flags & I_VALID)){
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	8b 40 0c             	mov    0xc(%eax),%eax
80101947:	83 e0 02             	and    $0x2,%eax
8010194a:	85 c0                	test   %eax,%eax
8010194c:	0f 85 d4 00 00 00    	jne    80101a26 <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	8b 40 04             	mov    0x4(%eax),%eax
80101958:	c1 e8 03             	shr    $0x3,%eax
8010195b:	89 c2                	mov    %eax,%edx
8010195d:	a1 54 12 11 80       	mov    0x80111254,%eax
80101962:	01 c2                	add    %eax,%edx
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	8b 00                	mov    (%eax),%eax
80101969:	89 54 24 04          	mov    %edx,0x4(%esp)
8010196d:	89 04 24             	mov    %eax,(%esp)
80101970:	e8 31 e8 ff ff       	call   801001a6 <bread>
80101975:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197b:	8d 50 18             	lea    0x18(%eax),%edx
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 04             	mov    0x4(%eax),%eax
80101984:	83 e0 07             	and    $0x7,%eax
80101987:	c1 e0 06             	shl    $0x6,%eax
8010198a:	01 d0                	add    %edx,%eax
8010198c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101992:	0f b7 10             	movzwl (%eax),%edx
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010199c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019a3:	8b 45 08             	mov    0x8(%ebp),%eax
801019a6:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ad:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019b1:	8b 45 08             	mov    0x8(%ebp),%eax
801019b4:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c9:	8b 50 08             	mov    0x8(%eax),%edx
801019cc:	8b 45 08             	mov    0x8(%ebp),%eax
801019cf:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d5:	8d 50 0c             	lea    0xc(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	83 c0 1c             	add    $0x1c,%eax
801019de:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019e5:	00 
801019e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801019ea:	89 04 24             	mov    %eax,(%esp)
801019ed:	e8 dc 3a 00 00       	call   801054ce <memmove>
    brelse(bp);
801019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f5:	89 04 24             	mov    %eax,(%esp)
801019f8:	e8 1a e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8b 40 0c             	mov    0xc(%eax),%eax
80101a03:	83 c8 02             	or     $0x2,%eax
80101a06:	89 c2                	mov    %eax,%edx
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a15:	66 85 c0             	test   %ax,%ax
80101a18:	75 0c                	jne    80101a26 <ilock+0x152>
      panic("ilock: no type");
80101a1a:	c7 04 24 f3 89 10 80 	movl   $0x801089f3,(%esp)
80101a21:	e8 14 eb ff ff       	call   8010053a <panic>
  }
}
80101a26:	c9                   	leave  
80101a27:	c3                   	ret    

80101a28 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a28:	55                   	push   %ebp
80101a29:	89 e5                	mov    %esp,%ebp
80101a2b:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a2e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a32:	74 17                	je     80101a4b <iunlock+0x23>
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3a:	83 e0 01             	and    $0x1,%eax
80101a3d:	85 c0                	test   %eax,%eax
80101a3f:	74 0a                	je     80101a4b <iunlock+0x23>
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
80101a44:	8b 40 08             	mov    0x8(%eax),%eax
80101a47:	85 c0                	test   %eax,%eax
80101a49:	7f 0c                	jg     80101a57 <iunlock+0x2f>
    panic("iunlock");
80101a4b:	c7 04 24 02 8a 10 80 	movl   $0x80108a02,(%esp)
80101a52:	e8 e3 ea ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101a57:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a5e:	e8 48 37 00 00       	call   801051ab <acquire>
  ip->flags &= ~I_BUSY;
80101a63:	8b 45 08             	mov    0x8(%ebp),%eax
80101a66:	8b 40 0c             	mov    0xc(%eax),%eax
80101a69:	83 e0 fe             	and    $0xfffffffe,%eax
80101a6c:	89 c2                	mov    %eax,%edx
80101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a71:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	89 04 24             	mov    %eax,(%esp)
80101a7a:	e8 3d 33 00 00       	call   80104dbc <wakeup>
  release(&icache.lock);
80101a7f:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a86:	e8 82 37 00 00       	call   8010520d <release>
}
80101a8b:	c9                   	leave  
80101a8c:	c3                   	ret    

80101a8d <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a8d:	55                   	push   %ebp
80101a8e:	89 e5                	mov    %esp,%ebp
80101a90:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a93:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101a9a:	e8 0c 37 00 00       	call   801051ab <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa2:	8b 40 08             	mov    0x8(%eax),%eax
80101aa5:	83 f8 01             	cmp    $0x1,%eax
80101aa8:	0f 85 93 00 00 00    	jne    80101b41 <iput+0xb4>
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab4:	83 e0 02             	and    $0x2,%eax
80101ab7:	85 c0                	test   %eax,%eax
80101ab9:	0f 84 82 00 00 00    	je     80101b41 <iput+0xb4>
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101ac6:	66 85 c0             	test   %ax,%ax
80101ac9:	75 76                	jne    80101b41 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad1:	83 e0 01             	and    $0x1,%eax
80101ad4:	85 c0                	test   %eax,%eax
80101ad6:	74 0c                	je     80101ae4 <iput+0x57>
      panic("iput busy");
80101ad8:	c7 04 24 0a 8a 10 80 	movl   $0x80108a0a,(%esp)
80101adf:	e8 56 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 0c             	mov    0xc(%eax),%eax
80101aea:	83 c8 01             	or     $0x1,%eax
80101aed:	89 c2                	mov    %eax,%edx
80101aef:	8b 45 08             	mov    0x8(%ebp),%eax
80101af2:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101af5:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101afc:	e8 0c 37 00 00       	call   8010520d <release>
    itrunc(ip);
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	89 04 24             	mov    %eax,(%esp)
80101b07:	e8 7d 01 00 00       	call   80101c89 <itrunc>
    ip->type = 0;
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	89 04 24             	mov    %eax,(%esp)
80101b1b:	e8 f2 fb ff ff       	call   80101712 <iupdate>
    acquire(&icache.lock);
80101b20:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101b27:	e8 7f 36 00 00       	call   801051ab <acquire>
    ip->flags = 0;
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	89 04 24             	mov    %eax,(%esp)
80101b3c:	e8 7b 32 00 00       	call   80104dbc <wakeup>
  }
  ip->ref--;
80101b41:	8b 45 08             	mov    0x8(%ebp),%eax
80101b44:	8b 40 08             	mov    0x8(%eax),%eax
80101b47:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b50:	c7 04 24 60 12 11 80 	movl   $0x80111260,(%esp)
80101b57:	e8 b1 36 00 00       	call   8010520d <release>
}
80101b5c:	c9                   	leave  
80101b5d:	c3                   	ret    

80101b5e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	89 04 24             	mov    %eax,(%esp)
80101b6a:	e8 b9 fe ff ff       	call   80101a28 <iunlock>
  iput(ip);
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	89 04 24             	mov    %eax,(%esp)
80101b75:	e8 13 ff ff ff       	call   80101a8d <iput>
}
80101b7a:	c9                   	leave  
80101b7b:	c3                   	ret    

80101b7c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b7c:	55                   	push   %ebp
80101b7d:	89 e5                	mov    %esp,%ebp
80101b7f:	53                   	push   %ebx
80101b80:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b83:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b87:	77 3e                	ja     80101bc7 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b8f:	83 c2 04             	add    $0x4,%edx
80101b92:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b9d:	75 20                	jne    80101bbf <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	8b 00                	mov    (%eax),%eax
80101ba4:	89 04 24             	mov    %eax,(%esp)
80101ba7:	e8 f7 f7 ff ff       	call   801013a3 <balloc>
80101bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bb5:	8d 4a 04             	lea    0x4(%edx),%ecx
80101bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bbb:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc2:	e9 bc 00 00 00       	jmp    80101c83 <bmap+0x107>
  }
  bn -= NDIRECT;
80101bc7:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101bcb:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bcf:	0f 87 a2 00 00 00    	ja     80101c77 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be2:	75 19                	jne    80101bfd <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	8b 00                	mov    (%eax),%eax
80101be9:	89 04 24             	mov    %eax,(%esp)
80101bec:	e8 b2 f7 ff ff       	call   801013a3 <balloc>
80101bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfa:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	8b 00                	mov    (%eax),%eax
80101c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c05:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c09:	89 04 24             	mov    %eax,(%esp)
80101c0c:	e8 95 e5 ff ff       	call   801001a6 <bread>
80101c11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c17:	83 c0 18             	add    $0x18,%eax
80101c1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c2a:	01 d0                	add    %edx,%eax
80101c2c:	8b 00                	mov    (%eax),%eax
80101c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c35:	75 30                	jne    80101c67 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101c37:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c44:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	8b 00                	mov    (%eax),%eax
80101c4c:	89 04 24             	mov    %eax,(%esp)
80101c4f:	e8 4f f7 ff ff       	call   801013a3 <balloc>
80101c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5a:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5f:	89 04 24             	mov    %eax,(%esp)
80101c62:	e8 60 1a 00 00       	call   801036c7 <log_write>
    }
    brelse(bp);
80101c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6a:	89 04 24             	mov    %eax,(%esp)
80101c6d:	e8 a5 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c75:	eb 0c                	jmp    80101c83 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c77:	c7 04 24 14 8a 10 80 	movl   $0x80108a14,(%esp)
80101c7e:	e8 b7 e8 ff ff       	call   8010053a <panic>
}
80101c83:	83 c4 24             	add    $0x24,%esp
80101c86:	5b                   	pop    %ebx
80101c87:	5d                   	pop    %ebp
80101c88:	c3                   	ret    

80101c89 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c89:	55                   	push   %ebp
80101c8a:	89 e5                	mov    %esp,%ebp
80101c8c:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c96:	eb 44                	jmp    80101cdc <itrunc+0x53>
    if(ip->addrs[i]){
80101c98:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c9e:	83 c2 04             	add    $0x4,%edx
80101ca1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ca5:	85 c0                	test   %eax,%eax
80101ca7:	74 2f                	je     80101cd8 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101caf:	83 c2 04             	add    $0x4,%edx
80101cb2:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cbf:	89 04 24             	mov    %eax,(%esp)
80101cc2:	e8 1a f8 ff ff       	call   801014e1 <bfree>
      ip->addrs[i] = 0;
80101cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ccd:	83 c2 04             	add    $0x4,%edx
80101cd0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cd7:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101cdc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ce0:	7e b6                	jle    80101c98 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ce8:	85 c0                	test   %eax,%eax
80101cea:	0f 84 9b 00 00 00    	je     80101d8b <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cff:	89 04 24             	mov    %eax,(%esp)
80101d02:	e8 9f e4 ff ff       	call   801001a6 <bread>
80101d07:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d0d:	83 c0 18             	add    $0x18,%eax
80101d10:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d1a:	eb 3b                	jmp    80101d57 <itrunc+0xce>
      if(a[j])
80101d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d29:	01 d0                	add    %edx,%eax
80101d2b:	8b 00                	mov    (%eax),%eax
80101d2d:	85 c0                	test   %eax,%eax
80101d2f:	74 22                	je     80101d53 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d3e:	01 d0                	add    %edx,%eax
80101d40:	8b 10                	mov    (%eax),%edx
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 00                	mov    (%eax),%eax
80101d47:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d4b:	89 04 24             	mov    %eax,(%esp)
80101d4e:	e8 8e f7 ff ff       	call   801014e1 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d53:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5a:	83 f8 7f             	cmp    $0x7f,%eax
80101d5d:	76 bd                	jbe    80101d1c <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d62:	89 04 24             	mov    %eax,(%esp)
80101d65:	e8 ad e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d70:	8b 45 08             	mov    0x8(%ebp),%eax
80101d73:	8b 00                	mov    (%eax),%eax
80101d75:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d79:	89 04 24             	mov    %eax,(%esp)
80101d7c:	e8 60 f7 ff ff       	call   801014e1 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	89 04 24             	mov    %eax,(%esp)
80101d9b:	e8 72 f9 ff ff       	call   80101712 <iupdate>
}
80101da0:	c9                   	leave  
80101da1:	c3                   	ret    

80101da2 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101da2:	55                   	push   %ebp
80101da3:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	8b 00                	mov    (%eax),%eax
80101daa:	89 c2                	mov    %eax,%edx
80101dac:	8b 45 0c             	mov    0xc(%ebp),%eax
80101daf:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	8b 50 04             	mov    0x4(%eax),%edx
80101db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbb:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddc:	8b 50 18             	mov    0x18(%eax),%edx
80101ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101de5:	5d                   	pop    %ebp
80101de6:	c3                   	ret    

80101de7 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101de7:	55                   	push   %ebp
80101de8:	89 e5                	mov    %esp,%ebp
80101dea:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101df4:	66 83 f8 03          	cmp    $0x3,%ax
80101df8:	75 60                	jne    80101e5a <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e01:	66 85 c0             	test   %ax,%ax
80101e04:	78 20                	js     80101e26 <readi+0x3f>
80101e06:	8b 45 08             	mov    0x8(%ebp),%eax
80101e09:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e0d:	66 83 f8 09          	cmp    $0x9,%ax
80101e11:	7f 13                	jg     80101e26 <readi+0x3f>
80101e13:	8b 45 08             	mov    0x8(%ebp),%eax
80101e16:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e1a:	98                   	cwtl   
80101e1b:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101e22:	85 c0                	test   %eax,%eax
80101e24:	75 0a                	jne    80101e30 <readi+0x49>
      return -1;
80101e26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e2b:	e9 19 01 00 00       	jmp    80101f49 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e37:	98                   	cwtl   
80101e38:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101e3f:	8b 55 14             	mov    0x14(%ebp),%edx
80101e42:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e46:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e49:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e4d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e50:	89 14 24             	mov    %edx,(%esp)
80101e53:	ff d0                	call   *%eax
80101e55:	e9 ef 00 00 00       	jmp    80101f49 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5d:	8b 40 18             	mov    0x18(%eax),%eax
80101e60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e63:	72 0d                	jb     80101e72 <readi+0x8b>
80101e65:	8b 45 14             	mov    0x14(%ebp),%eax
80101e68:	8b 55 10             	mov    0x10(%ebp),%edx
80101e6b:	01 d0                	add    %edx,%eax
80101e6d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e70:	73 0a                	jae    80101e7c <readi+0x95>
    return -1;
80101e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e77:	e9 cd 00 00 00       	jmp    80101f49 <readi+0x162>
  if(off + n > ip->size)
80101e7c:	8b 45 14             	mov    0x14(%ebp),%eax
80101e7f:	8b 55 10             	mov    0x10(%ebp),%edx
80101e82:	01 c2                	add    %eax,%edx
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 40 18             	mov    0x18(%eax),%eax
80101e8a:	39 c2                	cmp    %eax,%edx
80101e8c:	76 0c                	jbe    80101e9a <readi+0xb3>
    n = ip->size - off;
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	8b 40 18             	mov    0x18(%eax),%eax
80101e94:	2b 45 10             	sub    0x10(%ebp),%eax
80101e97:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea1:	e9 94 00 00 00       	jmp    80101f3a <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ea6:	8b 45 10             	mov    0x10(%ebp),%eax
80101ea9:	c1 e8 09             	shr    $0x9,%eax
80101eac:	89 44 24 04          	mov    %eax,0x4(%esp)
80101eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb3:	89 04 24             	mov    %eax,(%esp)
80101eb6:	e8 c1 fc ff ff       	call   80101b7c <bmap>
80101ebb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ebe:	8b 12                	mov    (%edx),%edx
80101ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ec4:	89 14 24             	mov    %edx,(%esp)
80101ec7:	e8 da e2 ff ff       	call   801001a6 <bread>
80101ecc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80101ed2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ed7:	89 c2                	mov    %eax,%edx
80101ed9:	b8 00 02 00 00       	mov    $0x200,%eax
80101ede:	29 d0                	sub    %edx,%eax
80101ee0:	89 c2                	mov    %eax,%edx
80101ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101ee8:	29 c1                	sub    %eax,%ecx
80101eea:	89 c8                	mov    %ecx,%eax
80101eec:	39 c2                	cmp    %eax,%edx
80101eee:	0f 46 c2             	cmovbe %edx,%eax
80101ef1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ef4:	8b 45 10             	mov    0x10(%ebp),%eax
80101ef7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101efc:	8d 50 10             	lea    0x10(%eax),%edx
80101eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f02:	01 d0                	add    %edx,%eax
80101f04:	8d 50 08             	lea    0x8(%eax),%edx
80101f07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f15:	89 04 24             	mov    %eax,(%esp)
80101f18:	e8 b1 35 00 00       	call   801054ce <memmove>
    brelse(bp);
80101f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f20:	89 04 24             	mov    %eax,(%esp)
80101f23:	e8 ef e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f2b:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f31:	01 45 10             	add    %eax,0x10(%ebp)
80101f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f37:	01 45 0c             	add    %eax,0xc(%ebp)
80101f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f3d:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f40:	0f 82 60 ff ff ff    	jb     80101ea6 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f46:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f49:	c9                   	leave  
80101f4a:	c3                   	ret    

80101f4b <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f4b:	55                   	push   %ebp
80101f4c:	89 e5                	mov    %esp,%ebp
80101f4e:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f58:	66 83 f8 03          	cmp    $0x3,%ax
80101f5c:	75 60                	jne    80101fbe <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f65:	66 85 c0             	test   %ax,%ax
80101f68:	78 20                	js     80101f8a <writei+0x3f>
80101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f71:	66 83 f8 09          	cmp    $0x9,%ax
80101f75:	7f 13                	jg     80101f8a <writei+0x3f>
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f7e:	98                   	cwtl   
80101f7f:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f86:	85 c0                	test   %eax,%eax
80101f88:	75 0a                	jne    80101f94 <writei+0x49>
      return -1;
80101f8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f8f:	e9 44 01 00 00       	jmp    801020d8 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f94:	8b 45 08             	mov    0x8(%ebp),%eax
80101f97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f9b:	98                   	cwtl   
80101f9c:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101fa3:	8b 55 14             	mov    0x14(%ebp),%edx
80101fa6:	89 54 24 08          	mov    %edx,0x8(%esp)
80101faa:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fad:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fb1:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb4:	89 14 24             	mov    %edx,(%esp)
80101fb7:	ff d0                	call   *%eax
80101fb9:	e9 1a 01 00 00       	jmp    801020d8 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc1:	8b 40 18             	mov    0x18(%eax),%eax
80101fc4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fc7:	72 0d                	jb     80101fd6 <writei+0x8b>
80101fc9:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcc:	8b 55 10             	mov    0x10(%ebp),%edx
80101fcf:	01 d0                	add    %edx,%eax
80101fd1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fd4:	73 0a                	jae    80101fe0 <writei+0x95>
    return -1;
80101fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fdb:	e9 f8 00 00 00       	jmp    801020d8 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101fe0:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe3:	8b 55 10             	mov    0x10(%ebp),%edx
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fed:	76 0a                	jbe    80101ff9 <writei+0xae>
    return -1;
80101fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff4:	e9 df 00 00 00       	jmp    801020d8 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ff9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102000:	e9 9f 00 00 00       	jmp    801020a4 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102005:	8b 45 10             	mov    0x10(%ebp),%eax
80102008:	c1 e8 09             	shr    $0x9,%eax
8010200b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	89 04 24             	mov    %eax,(%esp)
80102015:	e8 62 fb ff ff       	call   80101b7c <bmap>
8010201a:	8b 55 08             	mov    0x8(%ebp),%edx
8010201d:	8b 12                	mov    (%edx),%edx
8010201f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102023:	89 14 24             	mov    %edx,(%esp)
80102026:	e8 7b e1 ff ff       	call   801001a6 <bread>
8010202b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010202e:	8b 45 10             	mov    0x10(%ebp),%eax
80102031:	25 ff 01 00 00       	and    $0x1ff,%eax
80102036:	89 c2                	mov    %eax,%edx
80102038:	b8 00 02 00 00       	mov    $0x200,%eax
8010203d:	29 d0                	sub    %edx,%eax
8010203f:	89 c2                	mov    %eax,%edx
80102041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102044:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102047:	29 c1                	sub    %eax,%ecx
80102049:	89 c8                	mov    %ecx,%eax
8010204b:	39 c2                	cmp    %eax,%edx
8010204d:	0f 46 c2             	cmovbe %edx,%eax
80102050:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102053:	8b 45 10             	mov    0x10(%ebp),%eax
80102056:	25 ff 01 00 00       	and    $0x1ff,%eax
8010205b:	8d 50 10             	lea    0x10(%eax),%edx
8010205e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102061:	01 d0                	add    %edx,%eax
80102063:	8d 50 08             	lea    0x8(%eax),%edx
80102066:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102069:	89 44 24 08          	mov    %eax,0x8(%esp)
8010206d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102070:	89 44 24 04          	mov    %eax,0x4(%esp)
80102074:	89 14 24             	mov    %edx,(%esp)
80102077:	e8 52 34 00 00       	call   801054ce <memmove>
    log_write(bp);
8010207c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207f:	89 04 24             	mov    %eax,(%esp)
80102082:	e8 40 16 00 00       	call   801036c7 <log_write>
    brelse(bp);
80102087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208a:	89 04 24             	mov    %eax,(%esp)
8010208d:	e8 85 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102092:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102095:	01 45 f4             	add    %eax,-0xc(%ebp)
80102098:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209b:	01 45 10             	add    %eax,0x10(%ebp)
8010209e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a1:	01 45 0c             	add    %eax,0xc(%ebp)
801020a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020a7:	3b 45 14             	cmp    0x14(%ebp),%eax
801020aa:	0f 82 55 ff ff ff    	jb     80102005 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801020b0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020b4:	74 1f                	je     801020d5 <writei+0x18a>
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	8b 40 18             	mov    0x18(%eax),%eax
801020bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bf:	73 14                	jae    801020d5 <writei+0x18a>
    ip->size = off;
801020c1:	8b 45 08             	mov    0x8(%ebp),%eax
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801020ca:	8b 45 08             	mov    0x8(%ebp),%eax
801020cd:	89 04 24             	mov    %eax,(%esp)
801020d0:	e8 3d f6 ff ff       	call   80101712 <iupdate>
  }
  return n;
801020d5:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020d8:	c9                   	leave  
801020d9:	c3                   	ret    

801020da <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020da:	55                   	push   %ebp
801020db:	89 e5                	mov    %esp,%ebp
801020dd:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020e0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020e7:	00 
801020e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	89 04 24             	mov    %eax,(%esp)
801020f5:	e8 77 34 00 00       	call   80105571 <strncmp>
}
801020fa:	c9                   	leave  
801020fb:	c3                   	ret    

801020fc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020fc:	55                   	push   %ebp
801020fd:	89 e5                	mov    %esp,%ebp
801020ff:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102102:	8b 45 08             	mov    0x8(%ebp),%eax
80102105:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102109:	66 83 f8 01          	cmp    $0x1,%ax
8010210d:	74 0c                	je     8010211b <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010210f:	c7 04 24 27 8a 10 80 	movl   $0x80108a27,(%esp)
80102116:	e8 1f e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010211b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102122:	e9 88 00 00 00       	jmp    801021af <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102127:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010212e:	00 
8010212f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102132:	89 44 24 08          	mov    %eax,0x8(%esp)
80102136:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102139:	89 44 24 04          	mov    %eax,0x4(%esp)
8010213d:	8b 45 08             	mov    0x8(%ebp),%eax
80102140:	89 04 24             	mov    %eax,(%esp)
80102143:	e8 9f fc ff ff       	call   80101de7 <readi>
80102148:	83 f8 10             	cmp    $0x10,%eax
8010214b:	74 0c                	je     80102159 <dirlookup+0x5d>
      panic("dirlink read");
8010214d:	c7 04 24 39 8a 10 80 	movl   $0x80108a39,(%esp)
80102154:	e8 e1 e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
80102159:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010215d:	66 85 c0             	test   %ax,%ax
80102160:	75 02                	jne    80102164 <dirlookup+0x68>
      continue;
80102162:	eb 47                	jmp    801021ab <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102164:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102167:	83 c0 02             	add    $0x2,%eax
8010216a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102171:	89 04 24             	mov    %eax,(%esp)
80102174:	e8 61 ff ff ff       	call   801020da <namecmp>
80102179:	85 c0                	test   %eax,%eax
8010217b:	75 2e                	jne    801021ab <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010217d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102181:	74 08                	je     8010218b <dirlookup+0x8f>
        *poff = off;
80102183:	8b 45 10             	mov    0x10(%ebp),%eax
80102186:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102189:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010218b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010218f:	0f b7 c0             	movzwl %ax,%eax
80102192:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 00                	mov    (%eax),%eax
8010219a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010219d:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a1:	89 04 24             	mov    %eax,(%esp)
801021a4:	e8 27 f6 ff ff       	call   801017d0 <iget>
801021a9:	eb 18                	jmp    801021c3 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ab:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021af:	8b 45 08             	mov    0x8(%ebp),%eax
801021b2:	8b 40 18             	mov    0x18(%eax),%eax
801021b5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021b8:	0f 87 69 ff ff ff    	ja     80102127 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021c3:	c9                   	leave  
801021c4:	c3                   	ret    

801021c5 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021c5:	55                   	push   %ebp
801021c6:	89 e5                	mov    %esp,%ebp
801021c8:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021d2:	00 
801021d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 17 ff ff ff       	call   801020fc <dirlookup>
801021e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021ec:	74 15                	je     80102203 <dirlink+0x3e>
    iput(ip);
801021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 94 f8 ff ff       	call   80101a8d <iput>
    return -1;
801021f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021fe:	e9 b7 00 00 00       	jmp    801022ba <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102203:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220a:	eb 46                	jmp    80102252 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102216:	00 
80102217:	89 44 24 08          	mov    %eax,0x8(%esp)
8010221b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102222:	8b 45 08             	mov    0x8(%ebp),%eax
80102225:	89 04 24             	mov    %eax,(%esp)
80102228:	e8 ba fb ff ff       	call   80101de7 <readi>
8010222d:	83 f8 10             	cmp    $0x10,%eax
80102230:	74 0c                	je     8010223e <dirlink+0x79>
      panic("dirlink read");
80102232:	c7 04 24 39 8a 10 80 	movl   $0x80108a39,(%esp)
80102239:	e8 fc e2 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
8010223e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102242:	66 85 c0             	test   %ax,%ax
80102245:	75 02                	jne    80102249 <dirlink+0x84>
      break;
80102247:	eb 16                	jmp    8010225f <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010224c:	83 c0 10             	add    $0x10,%eax
8010224f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102252:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 40 18             	mov    0x18(%eax),%eax
8010225b:	39 c2                	cmp    %eax,%edx
8010225d:	72 ad                	jb     8010220c <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
8010225f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102266:	00 
80102267:	8b 45 0c             	mov    0xc(%ebp),%eax
8010226a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102271:	83 c0 02             	add    $0x2,%eax
80102274:	89 04 24             	mov    %eax,(%esp)
80102277:	e8 4b 33 00 00       	call   801055c7 <strncpy>
  de.inum = inum;
8010227c:	8b 45 10             	mov    0x10(%ebp),%eax
8010227f:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102286:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010228d:	00 
8010228e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102292:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102295:	89 44 24 04          	mov    %eax,0x4(%esp)
80102299:	8b 45 08             	mov    0x8(%ebp),%eax
8010229c:	89 04 24             	mov    %eax,(%esp)
8010229f:	e8 a7 fc ff ff       	call   80101f4b <writei>
801022a4:	83 f8 10             	cmp    $0x10,%eax
801022a7:	74 0c                	je     801022b5 <dirlink+0xf0>
    panic("dirlink");
801022a9:	c7 04 24 46 8a 10 80 	movl   $0x80108a46,(%esp)
801022b0:	e8 85 e2 ff ff       	call   8010053a <panic>
  
  return 0;
801022b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ba:	c9                   	leave  
801022bb:	c3                   	ret    

801022bc <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022bc:	55                   	push   %ebp
801022bd:	89 e5                	mov    %esp,%ebp
801022bf:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022c2:	eb 04                	jmp    801022c8 <skipelem+0xc>
    path++;
801022c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022c8:	8b 45 08             	mov    0x8(%ebp),%eax
801022cb:	0f b6 00             	movzbl (%eax),%eax
801022ce:	3c 2f                	cmp    $0x2f,%al
801022d0:	74 f2                	je     801022c4 <skipelem+0x8>
    path++;
  if(*path == 0)
801022d2:	8b 45 08             	mov    0x8(%ebp),%eax
801022d5:	0f b6 00             	movzbl (%eax),%eax
801022d8:	84 c0                	test   %al,%al
801022da:	75 0a                	jne    801022e6 <skipelem+0x2a>
    return 0;
801022dc:	b8 00 00 00 00       	mov    $0x0,%eax
801022e1:	e9 86 00 00 00       	jmp    8010236c <skipelem+0xb0>
  s = path;
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022ec:	eb 04                	jmp    801022f2 <skipelem+0x36>
    path++;
801022ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022f2:	8b 45 08             	mov    0x8(%ebp),%eax
801022f5:	0f b6 00             	movzbl (%eax),%eax
801022f8:	3c 2f                	cmp    $0x2f,%al
801022fa:	74 0a                	je     80102306 <skipelem+0x4a>
801022fc:	8b 45 08             	mov    0x8(%ebp),%eax
801022ff:	0f b6 00             	movzbl (%eax),%eax
80102302:	84 c0                	test   %al,%al
80102304:	75 e8                	jne    801022ee <skipelem+0x32>
    path++;
  len = path - s;
80102306:	8b 55 08             	mov    0x8(%ebp),%edx
80102309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230c:	29 c2                	sub    %eax,%edx
8010230e:	89 d0                	mov    %edx,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102313:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102317:	7e 1c                	jle    80102335 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102319:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102320:	00 
80102321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102324:	89 44 24 04          	mov    %eax,0x4(%esp)
80102328:	8b 45 0c             	mov    0xc(%ebp),%eax
8010232b:	89 04 24             	mov    %eax,(%esp)
8010232e:	e8 9b 31 00 00       	call   801054ce <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102333:	eb 2a                	jmp    8010235f <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102338:	89 44 24 08          	mov    %eax,0x8(%esp)
8010233c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102343:	8b 45 0c             	mov    0xc(%ebp),%eax
80102346:	89 04 24             	mov    %eax,(%esp)
80102349:	e8 80 31 00 00       	call   801054ce <memmove>
    name[len] = 0;
8010234e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102351:	8b 45 0c             	mov    0xc(%ebp),%eax
80102354:	01 d0                	add    %edx,%eax
80102356:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102359:	eb 04                	jmp    8010235f <skipelem+0xa3>
    path++;
8010235b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	0f b6 00             	movzbl (%eax),%eax
80102365:	3c 2f                	cmp    $0x2f,%al
80102367:	74 f2                	je     8010235b <skipelem+0x9f>
    path++;
  return path;
80102369:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010236c:	c9                   	leave  
8010236d:	c3                   	ret    

8010236e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010236e:	55                   	push   %ebp
8010236f:	89 e5                	mov    %esp,%ebp
80102371:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	3c 2f                	cmp    $0x2f,%al
8010237c:	75 1c                	jne    8010239a <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010237e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102385:	00 
80102386:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010238d:	e8 3e f4 ff ff       	call   801017d0 <iget>
80102392:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102395:	e9 af 00 00 00       	jmp    80102449 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010239a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023a0:	8b 40 70             	mov    0x70(%eax),%eax
801023a3:	89 04 24             	mov    %eax,(%esp)
801023a6:	e8 f7 f4 ff ff       	call   801018a2 <idup>
801023ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023ae:	e9 96 00 00 00       	jmp    80102449 <namex+0xdb>
    ilock(ip);
801023b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b6:	89 04 24             	mov    %eax,(%esp)
801023b9:	e8 16 f5 ff ff       	call   801018d4 <ilock>
    if(ip->type != T_DIR){
801023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023c5:	66 83 f8 01          	cmp    $0x1,%ax
801023c9:	74 15                	je     801023e0 <namex+0x72>
      iunlockput(ip);
801023cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ce:	89 04 24             	mov    %eax,(%esp)
801023d1:	e8 88 f7 ff ff       	call   80101b5e <iunlockput>
      return 0;
801023d6:	b8 00 00 00 00       	mov    $0x0,%eax
801023db:	e9 a3 00 00 00       	jmp    80102483 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801023e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023e4:	74 1d                	je     80102403 <namex+0x95>
801023e6:	8b 45 08             	mov    0x8(%ebp),%eax
801023e9:	0f b6 00             	movzbl (%eax),%eax
801023ec:	84 c0                	test   %al,%al
801023ee:	75 13                	jne    80102403 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801023f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f3:	89 04 24             	mov    %eax,(%esp)
801023f6:	e8 2d f6 ff ff       	call   80101a28 <iunlock>
      return ip;
801023fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fe:	e9 80 00 00 00       	jmp    80102483 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102403:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010240a:	00 
8010240b:	8b 45 10             	mov    0x10(%ebp),%eax
8010240e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102415:	89 04 24             	mov    %eax,(%esp)
80102418:	e8 df fc ff ff       	call   801020fc <dirlookup>
8010241d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102420:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102424:	75 12                	jne    80102438 <namex+0xca>
      iunlockput(ip);
80102426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102429:	89 04 24             	mov    %eax,(%esp)
8010242c:	e8 2d f7 ff ff       	call   80101b5e <iunlockput>
      return 0;
80102431:	b8 00 00 00 00       	mov    $0x0,%eax
80102436:	eb 4b                	jmp    80102483 <namex+0x115>
    }
    iunlockput(ip);
80102438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243b:	89 04 24             	mov    %eax,(%esp)
8010243e:	e8 1b f7 ff ff       	call   80101b5e <iunlockput>
    ip = next;
80102443:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102446:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102449:	8b 45 10             	mov    0x10(%ebp),%eax
8010244c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	89 04 24             	mov    %eax,(%esp)
80102456:	e8 61 fe ff ff       	call   801022bc <skipelem>
8010245b:	89 45 08             	mov    %eax,0x8(%ebp)
8010245e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102462:	0f 85 4b ff ff ff    	jne    801023b3 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102468:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010246c:	74 12                	je     80102480 <namex+0x112>
    iput(ip);
8010246e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102471:	89 04 24             	mov    %eax,(%esp)
80102474:	e8 14 f6 ff ff       	call   80101a8d <iput>
    return 0;
80102479:	b8 00 00 00 00       	mov    $0x0,%eax
8010247e:	eb 03                	jmp    80102483 <namex+0x115>
  }
  return ip;
80102480:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102483:	c9                   	leave  
80102484:	c3                   	ret    

80102485 <namei>:

struct inode*
namei(char *path)
{
80102485:	55                   	push   %ebp
80102486:	89 e5                	mov    %esp,%ebp
80102488:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010248b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010248e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102492:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102499:	00 
8010249a:	8b 45 08             	mov    0x8(%ebp),%eax
8010249d:	89 04 24             	mov    %eax,(%esp)
801024a0:	e8 c9 fe ff ff       	call   8010236e <namex>
}
801024a5:	c9                   	leave  
801024a6:	c3                   	ret    

801024a7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024a7:	55                   	push   %ebp
801024a8:	89 e5                	mov    %esp,%ebp
801024aa:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801024ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801024b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024bb:	00 
801024bc:	8b 45 08             	mov    0x8(%ebp),%eax
801024bf:	89 04 24             	mov    %eax,(%esp)
801024c2:	e8 a7 fe ff ff       	call   8010236e <namex>
}
801024c7:	c9                   	leave  
801024c8:	c3                   	ret    

801024c9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024c9:	55                   	push   %ebp
801024ca:	89 e5                	mov    %esp,%ebp
801024cc:	83 ec 14             	sub    $0x14,%esp
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
801024d2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024d6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024da:	89 c2                	mov    %eax,%edx
801024dc:	ec                   	in     (%dx),%al
801024dd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024e0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024e4:	c9                   	leave  
801024e5:	c3                   	ret    

801024e6 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024e6:	55                   	push   %ebp
801024e7:	89 e5                	mov    %esp,%ebp
801024e9:	57                   	push   %edi
801024ea:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024eb:	8b 55 08             	mov    0x8(%ebp),%edx
801024ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024f1:	8b 45 10             	mov    0x10(%ebp),%eax
801024f4:	89 cb                	mov    %ecx,%ebx
801024f6:	89 df                	mov    %ebx,%edi
801024f8:	89 c1                	mov    %eax,%ecx
801024fa:	fc                   	cld    
801024fb:	f3 6d                	rep insl (%dx),%es:(%edi)
801024fd:	89 c8                	mov    %ecx,%eax
801024ff:	89 fb                	mov    %edi,%ebx
80102501:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102504:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102507:	5b                   	pop    %ebx
80102508:	5f                   	pop    %edi
80102509:	5d                   	pop    %ebp
8010250a:	c3                   	ret    

8010250b <outb>:

static inline void
outb(ushort port, uchar data)
{
8010250b:	55                   	push   %ebp
8010250c:	89 e5                	mov    %esp,%ebp
8010250e:	83 ec 08             	sub    $0x8,%esp
80102511:	8b 55 08             	mov    0x8(%ebp),%edx
80102514:	8b 45 0c             	mov    0xc(%ebp),%eax
80102517:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010251b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102522:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102526:	ee                   	out    %al,(%dx)
}
80102527:	c9                   	leave  
80102528:	c3                   	ret    

80102529 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	56                   	push   %esi
8010252d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010252e:	8b 55 08             	mov    0x8(%ebp),%edx
80102531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102534:	8b 45 10             	mov    0x10(%ebp),%eax
80102537:	89 cb                	mov    %ecx,%ebx
80102539:	89 de                	mov    %ebx,%esi
8010253b:	89 c1                	mov    %eax,%ecx
8010253d:	fc                   	cld    
8010253e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102540:	89 c8                	mov    %ecx,%eax
80102542:	89 f3                	mov    %esi,%ebx
80102544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102547:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010254a:	5b                   	pop    %ebx
8010254b:	5e                   	pop    %esi
8010254c:	5d                   	pop    %ebp
8010254d:	c3                   	ret    

8010254e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010254e:	55                   	push   %ebp
8010254f:	89 e5                	mov    %esp,%ebp
80102551:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102554:	90                   	nop
80102555:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010255c:	e8 68 ff ff ff       	call   801024c9 <inb>
80102561:	0f b6 c0             	movzbl %al,%eax
80102564:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102567:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010256a:	25 c0 00 00 00       	and    $0xc0,%eax
8010256f:	83 f8 40             	cmp    $0x40,%eax
80102572:	75 e1                	jne    80102555 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102574:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102578:	74 11                	je     8010258b <idewait+0x3d>
8010257a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010257d:	83 e0 21             	and    $0x21,%eax
80102580:	85 c0                	test   %eax,%eax
80102582:	74 07                	je     8010258b <idewait+0x3d>
    return -1;
80102584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102589:	eb 05                	jmp    80102590 <idewait+0x42>
  return 0;
8010258b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102590:	c9                   	leave  
80102591:	c3                   	ret    

80102592 <ideinit>:

void
ideinit(void)
{
80102592:	55                   	push   %ebp
80102593:	89 e5                	mov    %esp,%ebp
80102595:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102598:	c7 44 24 04 4e 8a 10 	movl   $0x80108a4e,0x4(%esp)
8010259f:	80 
801025a0:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801025a7:	e8 de 2b 00 00       	call   8010518a <initlock>
  picenable(IRQ_IDE);
801025ac:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025b3:	e8 a3 18 00 00       	call   80103e5b <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025b8:	a1 60 29 11 80       	mov    0x80112960,%eax
801025bd:	83 e8 01             	sub    $0x1,%eax
801025c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801025c4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025cb:	e8 43 04 00 00       	call   80102a13 <ioapicenable>
  idewait(0);
801025d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d7:	e8 72 ff ff ff       	call   8010254e <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025dc:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025e3:	00 
801025e4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025eb:	e8 1b ff ff ff       	call   8010250b <outb>
  for(i=0; i<1000; i++){
801025f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025f7:	eb 20                	jmp    80102619 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025f9:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102600:	e8 c4 fe ff ff       	call   801024c9 <inb>
80102605:	84 c0                	test   %al,%al
80102607:	74 0c                	je     80102615 <ideinit+0x83>
      havedisk1 = 1;
80102609:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
80102610:	00 00 00 
      break;
80102613:	eb 0d                	jmp    80102622 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102615:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102619:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102620:	7e d7                	jle    801025f9 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102622:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102629:	00 
8010262a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102631:	e8 d5 fe ff ff       	call   8010250b <outb>
}
80102636:	c9                   	leave  
80102637:	c3                   	ret    

80102638 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102638:	55                   	push   %ebp
80102639:	89 e5                	mov    %esp,%ebp
8010263b:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010263e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102642:	75 0c                	jne    80102650 <idestart+0x18>
    panic("idestart");
80102644:	c7 04 24 52 8a 10 80 	movl   $0x80108a52,(%esp)
8010264b:	e8 ea de ff ff       	call   8010053a <panic>
  if(b->blockno >= FSSIZE)
80102650:	8b 45 08             	mov    0x8(%ebp),%eax
80102653:	8b 40 08             	mov    0x8(%eax),%eax
80102656:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010265b:	76 0c                	jbe    80102669 <idestart+0x31>
    panic("incorrect blockno");
8010265d:	c7 04 24 5b 8a 10 80 	movl   $0x80108a5b,(%esp)
80102664:	e8 d1 de ff ff       	call   8010053a <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102669:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102670:	8b 45 08             	mov    0x8(%ebp),%eax
80102673:	8b 50 08             	mov    0x8(%eax),%edx
80102676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102679:	0f af c2             	imul   %edx,%eax
8010267c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010267f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102683:	7e 0c                	jle    80102691 <idestart+0x59>
80102685:	c7 04 24 52 8a 10 80 	movl   $0x80108a52,(%esp)
8010268c:	e8 a9 de ff ff       	call   8010053a <panic>
  
  idewait(0);
80102691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102698:	e8 b1 fe ff ff       	call   8010254e <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010269d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026a4:	00 
801026a5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801026ac:	e8 5a fe ff ff       	call   8010250b <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801026b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b4:	0f b6 c0             	movzbl %al,%eax
801026b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bb:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801026c2:	e8 44 fe ff ff       	call   8010250b <outb>
  outb(0x1f3, sector & 0xff);
801026c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026ca:	0f b6 c0             	movzbl %al,%eax
801026cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d1:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026d8:	e8 2e fe ff ff       	call   8010250b <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026e0:	c1 f8 08             	sar    $0x8,%eax
801026e3:	0f b6 c0             	movzbl %al,%eax
801026e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ea:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801026f1:	e8 15 fe ff ff       	call   8010250b <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801026f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f9:	c1 f8 10             	sar    $0x10,%eax
801026fc:	0f b6 c0             	movzbl %al,%eax
801026ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102703:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010270a:	e8 fc fd ff ff       	call   8010250b <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010270f:	8b 45 08             	mov    0x8(%ebp),%eax
80102712:	8b 40 04             	mov    0x4(%eax),%eax
80102715:	83 e0 01             	and    $0x1,%eax
80102718:	c1 e0 04             	shl    $0x4,%eax
8010271b:	89 c2                	mov    %eax,%edx
8010271d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102720:	c1 f8 18             	sar    $0x18,%eax
80102723:	83 e0 0f             	and    $0xf,%eax
80102726:	09 d0                	or     %edx,%eax
80102728:	83 c8 e0             	or     $0xffffffe0,%eax
8010272b:	0f b6 c0             	movzbl %al,%eax
8010272e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102732:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102739:	e8 cd fd ff ff       	call   8010250b <outb>
  if(b->flags & B_DIRTY){
8010273e:	8b 45 08             	mov    0x8(%ebp),%eax
80102741:	8b 00                	mov    (%eax),%eax
80102743:	83 e0 04             	and    $0x4,%eax
80102746:	85 c0                	test   %eax,%eax
80102748:	74 34                	je     8010277e <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
8010274a:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102751:	00 
80102752:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102759:	e8 ad fd ff ff       	call   8010250b <outb>
    outsl(0x1f0, b->data, BSIZE/4);
8010275e:	8b 45 08             	mov    0x8(%ebp),%eax
80102761:	83 c0 18             	add    $0x18,%eax
80102764:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010276b:	00 
8010276c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102770:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102777:	e8 ad fd ff ff       	call   80102529 <outsl>
8010277c:	eb 14                	jmp    80102792 <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010277e:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102785:	00 
80102786:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010278d:	e8 79 fd ff ff       	call   8010250b <outb>
  }
}
80102792:	c9                   	leave  
80102793:	c3                   	ret    

80102794 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102794:	55                   	push   %ebp
80102795:	89 e5                	mov    %esp,%ebp
80102797:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010279a:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027a1:	e8 05 2a 00 00       	call   801051ab <acquire>
  if((b = idequeue) == 0){
801027a6:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801027ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b2:	75 11                	jne    801027c5 <ideintr+0x31>
    release(&idelock);
801027b4:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027bb:	e8 4d 2a 00 00       	call   8010520d <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801027c0:	e9 90 00 00 00       	jmp    80102855 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801027c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c8:	8b 40 14             	mov    0x14(%eax),%eax
801027cb:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d3:	8b 00                	mov    (%eax),%eax
801027d5:	83 e0 04             	and    $0x4,%eax
801027d8:	85 c0                	test   %eax,%eax
801027da:	75 2e                	jne    8010280a <ideintr+0x76>
801027dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027e3:	e8 66 fd ff ff       	call   8010254e <idewait>
801027e8:	85 c0                	test   %eax,%eax
801027ea:	78 1e                	js     8010280a <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801027ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ef:	83 c0 18             	add    $0x18,%eax
801027f2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801027f9:	00 
801027fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801027fe:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102805:	e8 dc fc ff ff       	call   801024e6 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010280a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280d:	8b 00                	mov    (%eax),%eax
8010280f:	83 c8 02             	or     $0x2,%eax
80102812:	89 c2                	mov    %eax,%edx
80102814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102817:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281c:	8b 00                	mov    (%eax),%eax
8010281e:	83 e0 fb             	and    $0xfffffffb,%eax
80102821:	89 c2                	mov    %eax,%edx
80102823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102826:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	89 04 24             	mov    %eax,(%esp)
8010282e:	e8 89 25 00 00       	call   80104dbc <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102833:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102838:	85 c0                	test   %eax,%eax
8010283a:	74 0d                	je     80102849 <ideintr+0xb5>
    idestart(idequeue);
8010283c:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102841:	89 04 24             	mov    %eax,(%esp)
80102844:	e8 ef fd ff ff       	call   80102638 <idestart>

  release(&idelock);
80102849:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102850:	e8 b8 29 00 00       	call   8010520d <release>
}
80102855:	c9                   	leave  
80102856:	c3                   	ret    

80102857 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102857:	55                   	push   %ebp
80102858:	89 e5                	mov    %esp,%ebp
8010285a:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	8b 00                	mov    (%eax),%eax
80102862:	83 e0 01             	and    $0x1,%eax
80102865:	85 c0                	test   %eax,%eax
80102867:	75 0c                	jne    80102875 <iderw+0x1e>
    panic("iderw: buf not busy");
80102869:	c7 04 24 6d 8a 10 80 	movl   $0x80108a6d,(%esp)
80102870:	e8 c5 dc ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102875:	8b 45 08             	mov    0x8(%ebp),%eax
80102878:	8b 00                	mov    (%eax),%eax
8010287a:	83 e0 06             	and    $0x6,%eax
8010287d:	83 f8 02             	cmp    $0x2,%eax
80102880:	75 0c                	jne    8010288e <iderw+0x37>
    panic("iderw: nothing to do");
80102882:	c7 04 24 81 8a 10 80 	movl   $0x80108a81,(%esp)
80102889:	e8 ac dc ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
8010288e:	8b 45 08             	mov    0x8(%ebp),%eax
80102891:	8b 40 04             	mov    0x4(%eax),%eax
80102894:	85 c0                	test   %eax,%eax
80102896:	74 15                	je     801028ad <iderw+0x56>
80102898:	a1 58 b6 10 80       	mov    0x8010b658,%eax
8010289d:	85 c0                	test   %eax,%eax
8010289f:	75 0c                	jne    801028ad <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801028a1:	c7 04 24 96 8a 10 80 	movl   $0x80108a96,(%esp)
801028a8:	e8 8d dc ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028ad:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801028b4:	e8 f2 28 00 00       	call   801051ab <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801028b9:	8b 45 08             	mov    0x8(%ebp),%eax
801028bc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028c3:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801028ca:	eb 0b                	jmp    801028d7 <iderw+0x80>
801028cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cf:	8b 00                	mov    (%eax),%eax
801028d1:	83 c0 14             	add    $0x14,%eax
801028d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028da:	8b 00                	mov    (%eax),%eax
801028dc:	85 c0                	test   %eax,%eax
801028de:	75 ec                	jne    801028cc <iderw+0x75>
    ;
  *pp = b;
801028e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e3:	8b 55 08             	mov    0x8(%ebp),%edx
801028e6:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028e8:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028ed:	3b 45 08             	cmp    0x8(%ebp),%eax
801028f0:	75 0d                	jne    801028ff <iderw+0xa8>
    idestart(b);
801028f2:	8b 45 08             	mov    0x8(%ebp),%eax
801028f5:	89 04 24             	mov    %eax,(%esp)
801028f8:	e8 3b fd ff ff       	call   80102638 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028fd:	eb 15                	jmp    80102914 <iderw+0xbd>
801028ff:	eb 13                	jmp    80102914 <iderw+0xbd>
    sleep(b, &idelock);
80102901:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
80102908:	80 
80102909:	8b 45 08             	mov    0x8(%ebp),%eax
8010290c:	89 04 24             	mov    %eax,(%esp)
8010290f:	e8 cc 23 00 00       	call   80104ce0 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	8b 00                	mov    (%eax),%eax
80102919:	83 e0 06             	and    $0x6,%eax
8010291c:	83 f8 02             	cmp    $0x2,%eax
8010291f:	75 e0                	jne    80102901 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102921:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102928:	e8 e0 28 00 00       	call   8010520d <release>
}
8010292d:	c9                   	leave  
8010292e:	c3                   	ret    

8010292f <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010292f:	55                   	push   %ebp
80102930:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102932:	a1 34 22 11 80       	mov    0x80112234,%eax
80102937:	8b 55 08             	mov    0x8(%ebp),%edx
8010293a:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010293c:	a1 34 22 11 80       	mov    0x80112234,%eax
80102941:	8b 40 10             	mov    0x10(%eax),%eax
}
80102944:	5d                   	pop    %ebp
80102945:	c3                   	ret    

80102946 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102946:	55                   	push   %ebp
80102947:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102949:	a1 34 22 11 80       	mov    0x80112234,%eax
8010294e:	8b 55 08             	mov    0x8(%ebp),%edx
80102951:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102953:	a1 34 22 11 80       	mov    0x80112234,%eax
80102958:	8b 55 0c             	mov    0xc(%ebp),%edx
8010295b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010295e:	5d                   	pop    %ebp
8010295f:	c3                   	ret    

80102960 <ioapicinit>:

void
ioapicinit(void)
{
80102960:	55                   	push   %ebp
80102961:	89 e5                	mov    %esp,%ebp
80102963:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102966:	a1 64 23 11 80       	mov    0x80112364,%eax
8010296b:	85 c0                	test   %eax,%eax
8010296d:	75 05                	jne    80102974 <ioapicinit+0x14>
    return;
8010296f:	e9 9d 00 00 00       	jmp    80102a11 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102974:	c7 05 34 22 11 80 00 	movl   $0xfec00000,0x80112234
8010297b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010297e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102985:	e8 a5 ff ff ff       	call   8010292f <ioapicread>
8010298a:	c1 e8 10             	shr    $0x10,%eax
8010298d:	25 ff 00 00 00       	and    $0xff,%eax
80102992:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102995:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010299c:	e8 8e ff ff ff       	call   8010292f <ioapicread>
801029a1:	c1 e8 18             	shr    $0x18,%eax
801029a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029a7:	0f b6 05 60 23 11 80 	movzbl 0x80112360,%eax
801029ae:	0f b6 c0             	movzbl %al,%eax
801029b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029b4:	74 0c                	je     801029c2 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029b6:	c7 04 24 b4 8a 10 80 	movl   $0x80108ab4,(%esp)
801029bd:	e8 de d9 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029c9:	eb 3e                	jmp    80102a09 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ce:	83 c0 20             	add    $0x20,%eax
801029d1:	0d 00 00 01 00       	or     $0x10000,%eax
801029d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029d9:	83 c2 08             	add    $0x8,%edx
801029dc:	01 d2                	add    %edx,%edx
801029de:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e2:	89 14 24             	mov    %edx,(%esp)
801029e5:	e8 5c ff ff ff       	call   80102946 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ed:	83 c0 08             	add    $0x8,%eax
801029f0:	01 c0                	add    %eax,%eax
801029f2:	83 c0 01             	add    $0x1,%eax
801029f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029fc:	00 
801029fd:	89 04 24             	mov    %eax,(%esp)
80102a00:	e8 41 ff ff ff       	call   80102946 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a05:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a0f:	7e ba                	jle    801029cb <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a11:	c9                   	leave  
80102a12:	c3                   	ret    

80102a13 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a13:	55                   	push   %ebp
80102a14:	89 e5                	mov    %esp,%ebp
80102a16:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102a19:	a1 64 23 11 80       	mov    0x80112364,%eax
80102a1e:	85 c0                	test   %eax,%eax
80102a20:	75 02                	jne    80102a24 <ioapicenable+0x11>
    return;
80102a22:	eb 37                	jmp    80102a5b <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a24:	8b 45 08             	mov    0x8(%ebp),%eax
80102a27:	83 c0 20             	add    $0x20,%eax
80102a2a:	8b 55 08             	mov    0x8(%ebp),%edx
80102a2d:	83 c2 08             	add    $0x8,%edx
80102a30:	01 d2                	add    %edx,%edx
80102a32:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a36:	89 14 24             	mov    %edx,(%esp)
80102a39:	e8 08 ff ff ff       	call   80102946 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a41:	c1 e0 18             	shl    $0x18,%eax
80102a44:	8b 55 08             	mov    0x8(%ebp),%edx
80102a47:	83 c2 08             	add    $0x8,%edx
80102a4a:	01 d2                	add    %edx,%edx
80102a4c:	83 c2 01             	add    $0x1,%edx
80102a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a53:	89 14 24             	mov    %edx,(%esp)
80102a56:	e8 eb fe ff ff       	call   80102946 <ioapicwrite>
}
80102a5b:	c9                   	leave  
80102a5c:	c3                   	ret    

80102a5d <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a5d:	55                   	push   %ebp
80102a5e:	89 e5                	mov    %esp,%ebp
80102a60:	8b 45 08             	mov    0x8(%ebp),%eax
80102a63:	05 00 00 00 80       	add    $0x80000000,%eax
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a70:	c7 44 24 04 e6 8a 10 	movl   $0x80108ae6,0x4(%esp)
80102a77:	80 
80102a78:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102a7f:	e8 06 27 00 00       	call   8010518a <initlock>
  kmem.use_lock = 0;
80102a84:	c7 05 74 22 11 80 00 	movl   $0x0,0x80112274
80102a8b:	00 00 00 
  freerange(vstart, vend);
80102a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a91:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a95:	8b 45 08             	mov    0x8(%ebp),%eax
80102a98:	89 04 24             	mov    %eax,(%esp)
80102a9b:	e8 26 00 00 00       	call   80102ac6 <freerange>
}
80102aa0:	c9                   	leave  
80102aa1:	c3                   	ret    

80102aa2 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102aa2:	55                   	push   %ebp
80102aa3:	89 e5                	mov    %esp,%ebp
80102aa5:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aab:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab2:	89 04 24             	mov    %eax,(%esp)
80102ab5:	e8 0c 00 00 00       	call   80102ac6 <freerange>
  kmem.use_lock = 1;
80102aba:	c7 05 74 22 11 80 01 	movl   $0x1,0x80112274
80102ac1:	00 00 00 
}
80102ac4:	c9                   	leave  
80102ac5:	c3                   	ret    

80102ac6 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ac6:	55                   	push   %ebp
80102ac7:	89 e5                	mov    %esp,%ebp
80102ac9:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102acc:	8b 45 08             	mov    0x8(%ebp),%eax
80102acf:	05 ff 0f 00 00       	add    $0xfff,%eax
80102ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102adc:	eb 12                	jmp    80102af0 <freerange+0x2a>
    kfree(p);
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	89 04 24             	mov    %eax,(%esp)
80102ae4:	e8 16 00 00 00       	call   80102aff <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ae9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af3:	05 00 10 00 00       	add    $0x1000,%eax
80102af8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102afb:	76 e1                	jbe    80102ade <freerange+0x18>
    kfree(p);
}
80102afd:	c9                   	leave  
80102afe:	c3                   	ret    

80102aff <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102aff:	55                   	push   %ebp
80102b00:	89 e5                	mov    %esp,%ebp
80102b02:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b05:	8b 45 08             	mov    0x8(%ebp),%eax
80102b08:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b0d:	85 c0                	test   %eax,%eax
80102b0f:	75 1b                	jne    80102b2c <kfree+0x2d>
80102b11:	81 7d 08 5c 54 11 80 	cmpl   $0x8011545c,0x8(%ebp)
80102b18:	72 12                	jb     80102b2c <kfree+0x2d>
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	89 04 24             	mov    %eax,(%esp)
80102b20:	e8 38 ff ff ff       	call   80102a5d <v2p>
80102b25:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b2a:	76 0c                	jbe    80102b38 <kfree+0x39>
    panic("kfree");
80102b2c:	c7 04 24 eb 8a 10 80 	movl   $0x80108aeb,(%esp)
80102b33:	e8 02 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b38:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b3f:	00 
80102b40:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b47:	00 
80102b48:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4b:	89 04 24             	mov    %eax,(%esp)
80102b4e:	e8 ac 28 00 00       	call   801053ff <memset>

  if(kmem.use_lock)
80102b53:	a1 74 22 11 80       	mov    0x80112274,%eax
80102b58:	85 c0                	test   %eax,%eax
80102b5a:	74 0c                	je     80102b68 <kfree+0x69>
    acquire(&kmem.lock);
80102b5c:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102b63:	e8 43 26 00 00       	call   801051ab <acquire>
  r = (struct run*)v;
80102b68:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b6e:	8b 15 78 22 11 80    	mov    0x80112278,%edx
80102b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b77:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7c:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102b81:	a1 74 22 11 80       	mov    0x80112274,%eax
80102b86:	85 c0                	test   %eax,%eax
80102b88:	74 0c                	je     80102b96 <kfree+0x97>
    release(&kmem.lock);
80102b8a:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102b91:	e8 77 26 00 00       	call   8010520d <release>
}
80102b96:	c9                   	leave  
80102b97:	c3                   	ret    

80102b98 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b98:	55                   	push   %ebp
80102b99:	89 e5                	mov    %esp,%ebp
80102b9b:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b9e:	a1 74 22 11 80       	mov    0x80112274,%eax
80102ba3:	85 c0                	test   %eax,%eax
80102ba5:	74 0c                	je     80102bb3 <kalloc+0x1b>
    acquire(&kmem.lock);
80102ba7:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102bae:	e8 f8 25 00 00       	call   801051ab <acquire>
  r = kmem.freelist;
80102bb3:	a1 78 22 11 80       	mov    0x80112278,%eax
80102bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bbf:	74 0a                	je     80102bcb <kalloc+0x33>
    kmem.freelist = r->next;
80102bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc4:	8b 00                	mov    (%eax),%eax
80102bc6:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102bcb:	a1 74 22 11 80       	mov    0x80112274,%eax
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	74 0c                	je     80102be0 <kalloc+0x48>
    release(&kmem.lock);
80102bd4:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80102bdb:	e8 2d 26 00 00       	call   8010520d <release>
  return (char*)r;
80102be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102be3:	c9                   	leave  
80102be4:	c3                   	ret    

80102be5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102be5:	55                   	push   %ebp
80102be6:	89 e5                	mov    %esp,%ebp
80102be8:	83 ec 14             	sub    $0x14,%esp
80102beb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bee:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bf2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102bf6:	89 c2                	mov    %eax,%edx
80102bf8:	ec                   	in     (%dx),%al
80102bf9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bfc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c00:	c9                   	leave  
80102c01:	c3                   	ret    

80102c02 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c02:	55                   	push   %ebp
80102c03:	89 e5                	mov    %esp,%ebp
80102c05:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c08:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c0f:	e8 d1 ff ff ff       	call   80102be5 <inb>
80102c14:	0f b6 c0             	movzbl %al,%eax
80102c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1d:	83 e0 01             	and    $0x1,%eax
80102c20:	85 c0                	test   %eax,%eax
80102c22:	75 0a                	jne    80102c2e <kbdgetc+0x2c>
    return -1;
80102c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c29:	e9 25 01 00 00       	jmp    80102d53 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102c2e:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c35:	e8 ab ff ff ff       	call   80102be5 <inb>
80102c3a:	0f b6 c0             	movzbl %al,%eax
80102c3d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c40:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c47:	75 17                	jne    80102c60 <kbdgetc+0x5e>
    shift |= E0ESC;
80102c49:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c4e:	83 c8 40             	or     $0x40,%eax
80102c51:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c56:	b8 00 00 00 00       	mov    $0x0,%eax
80102c5b:	e9 f3 00 00 00       	jmp    80102d53 <kbdgetc+0x151>
  } else if(data & 0x80){
80102c60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c63:	25 80 00 00 00       	and    $0x80,%eax
80102c68:	85 c0                	test   %eax,%eax
80102c6a:	74 45                	je     80102cb1 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c6c:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c71:	83 e0 40             	and    $0x40,%eax
80102c74:	85 c0                	test   %eax,%eax
80102c76:	75 08                	jne    80102c80 <kbdgetc+0x7e>
80102c78:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c7b:	83 e0 7f             	and    $0x7f,%eax
80102c7e:	eb 03                	jmp    80102c83 <kbdgetc+0x81>
80102c80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c83:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c86:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c89:	05 20 90 10 80       	add    $0x80109020,%eax
80102c8e:	0f b6 00             	movzbl (%eax),%eax
80102c91:	83 c8 40             	or     $0x40,%eax
80102c94:	0f b6 c0             	movzbl %al,%eax
80102c97:	f7 d0                	not    %eax
80102c99:	89 c2                	mov    %eax,%edx
80102c9b:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ca0:	21 d0                	and    %edx,%eax
80102ca2:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102ca7:	b8 00 00 00 00       	mov    $0x0,%eax
80102cac:	e9 a2 00 00 00       	jmp    80102d53 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102cb1:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cb6:	83 e0 40             	and    $0x40,%eax
80102cb9:	85 c0                	test   %eax,%eax
80102cbb:	74 14                	je     80102cd1 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cbd:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cc4:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cc9:	83 e0 bf             	and    $0xffffffbf,%eax
80102ccc:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102cd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cd4:	05 20 90 10 80       	add    $0x80109020,%eax
80102cd9:	0f b6 00             	movzbl (%eax),%eax
80102cdc:	0f b6 d0             	movzbl %al,%edx
80102cdf:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ce4:	09 d0                	or     %edx,%eax
80102ce6:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102ceb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cee:	05 20 91 10 80       	add    $0x80109120,%eax
80102cf3:	0f b6 00             	movzbl (%eax),%eax
80102cf6:	0f b6 d0             	movzbl %al,%edx
80102cf9:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cfe:	31 d0                	xor    %edx,%eax
80102d00:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d05:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d0a:	83 e0 03             	and    $0x3,%eax
80102d0d:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d17:	01 d0                	add    %edx,%eax
80102d19:	0f b6 00             	movzbl (%eax),%eax
80102d1c:	0f b6 c0             	movzbl %al,%eax
80102d1f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d22:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d27:	83 e0 08             	and    $0x8,%eax
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	74 22                	je     80102d50 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102d2e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d32:	76 0c                	jbe    80102d40 <kbdgetc+0x13e>
80102d34:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d38:	77 06                	ja     80102d40 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102d3a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d3e:	eb 10                	jmp    80102d50 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102d40:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d44:	76 0a                	jbe    80102d50 <kbdgetc+0x14e>
80102d46:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d4a:	77 04                	ja     80102d50 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d4c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d50:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d53:	c9                   	leave  
80102d54:	c3                   	ret    

80102d55 <kbdintr>:

void
kbdintr(void)
{
80102d55:	55                   	push   %ebp
80102d56:	89 e5                	mov    %esp,%ebp
80102d58:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d5b:	c7 04 24 02 2c 10 80 	movl   $0x80102c02,(%esp)
80102d62:	e8 61 da ff ff       	call   801007c8 <consoleintr>
}
80102d67:	c9                   	leave  
80102d68:	c3                   	ret    

80102d69 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d69:	55                   	push   %ebp
80102d6a:	89 e5                	mov    %esp,%ebp
80102d6c:	83 ec 14             	sub    $0x14,%esp
80102d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d72:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d76:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d7a:	89 c2                	mov    %eax,%edx
80102d7c:	ec                   	in     (%dx),%al
80102d7d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d80:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d84:	c9                   	leave  
80102d85:	c3                   	ret    

80102d86 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d86:	55                   	push   %ebp
80102d87:	89 e5                	mov    %esp,%ebp
80102d89:	83 ec 08             	sub    $0x8,%esp
80102d8c:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d92:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d96:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d99:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d9d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102da1:	ee                   	out    %al,(%dx)
}
80102da2:	c9                   	leave  
80102da3:	c3                   	ret    

80102da4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102da4:	55                   	push   %ebp
80102da5:	89 e5                	mov    %esp,%ebp
80102da7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102daa:	9c                   	pushf  
80102dab:	58                   	pop    %eax
80102dac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102daf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102db2:	c9                   	leave  
80102db3:	c3                   	ret    

80102db4 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102db4:	55                   	push   %ebp
80102db5:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102db7:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102dbc:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbf:	c1 e2 02             	shl    $0x2,%edx
80102dc2:	01 c2                	add    %eax,%edx
80102dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dc7:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dc9:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102dce:	83 c0 20             	add    $0x20,%eax
80102dd1:	8b 00                	mov    (%eax),%eax
}
80102dd3:	5d                   	pop    %ebp
80102dd4:	c3                   	ret    

80102dd5 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102dd5:	55                   	push   %ebp
80102dd6:	89 e5                	mov    %esp,%ebp
80102dd8:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102ddb:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102de0:	85 c0                	test   %eax,%eax
80102de2:	75 05                	jne    80102de9 <lapicinit+0x14>
    return;
80102de4:	e9 43 01 00 00       	jmp    80102f2c <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102de9:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102df0:	00 
80102df1:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102df8:	e8 b7 ff ff ff       	call   80102db4 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dfd:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102e04:	00 
80102e05:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102e0c:	e8 a3 ff ff ff       	call   80102db4 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e11:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e18:	00 
80102e19:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e20:	e8 8f ff ff ff       	call   80102db4 <lapicw>
  lapicw(TICR, 10000000); 
80102e25:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e2c:	00 
80102e2d:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e34:	e8 7b ff ff ff       	call   80102db4 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e39:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e40:	00 
80102e41:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e48:	e8 67 ff ff ff       	call   80102db4 <lapicw>
  lapicw(LINT1, MASKED);
80102e4d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e54:	00 
80102e55:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e5c:	e8 53 ff ff ff       	call   80102db4 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e61:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e66:	83 c0 30             	add    $0x30,%eax
80102e69:	8b 00                	mov    (%eax),%eax
80102e6b:	c1 e8 10             	shr    $0x10,%eax
80102e6e:	0f b6 c0             	movzbl %al,%eax
80102e71:	83 f8 03             	cmp    $0x3,%eax
80102e74:	76 14                	jbe    80102e8a <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e76:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e7d:	00 
80102e7e:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e85:	e8 2a ff ff ff       	call   80102db4 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e8a:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e91:	00 
80102e92:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e99:	e8 16 ff ff ff       	call   80102db4 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea5:	00 
80102ea6:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ead:	e8 02 ff ff ff       	call   80102db4 <lapicw>
  lapicw(ESR, 0);
80102eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb9:	00 
80102eba:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ec1:	e8 ee fe ff ff       	call   80102db4 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ec6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ecd:	00 
80102ece:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ed5:	e8 da fe ff ff       	call   80102db4 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102eda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee1:	00 
80102ee2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ee9:	e8 c6 fe ff ff       	call   80102db4 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102eee:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ef5:	00 
80102ef6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102efd:	e8 b2 fe ff ff       	call   80102db4 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f02:	90                   	nop
80102f03:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f08:	05 00 03 00 00       	add    $0x300,%eax
80102f0d:	8b 00                	mov    (%eax),%eax
80102f0f:	25 00 10 00 00       	and    $0x1000,%eax
80102f14:	85 c0                	test   %eax,%eax
80102f16:	75 eb                	jne    80102f03 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f1f:	00 
80102f20:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f27:	e8 88 fe ff ff       	call   80102db4 <lapicw>
}
80102f2c:	c9                   	leave  
80102f2d:	c3                   	ret    

80102f2e <cpunum>:

int
cpunum(void)
{
80102f2e:	55                   	push   %ebp
80102f2f:	89 e5                	mov    %esp,%ebp
80102f31:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f34:	e8 6b fe ff ff       	call   80102da4 <readeflags>
80102f39:	25 00 02 00 00       	and    $0x200,%eax
80102f3e:	85 c0                	test   %eax,%eax
80102f40:	74 25                	je     80102f67 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102f42:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102f47:	8d 50 01             	lea    0x1(%eax),%edx
80102f4a:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102f50:	85 c0                	test   %eax,%eax
80102f52:	75 13                	jne    80102f67 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f54:	8b 45 04             	mov    0x4(%ebp),%eax
80102f57:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f5b:	c7 04 24 f4 8a 10 80 	movl   $0x80108af4,(%esp)
80102f62:	e8 39 d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f67:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f6c:	85 c0                	test   %eax,%eax
80102f6e:	74 0f                	je     80102f7f <cpunum+0x51>
    return lapic[ID]>>24;
80102f70:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f75:	83 c0 20             	add    $0x20,%eax
80102f78:	8b 00                	mov    (%eax),%eax
80102f7a:	c1 e8 18             	shr    $0x18,%eax
80102f7d:	eb 05                	jmp    80102f84 <cpunum+0x56>
  return 0;
80102f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f84:	c9                   	leave  
80102f85:	c3                   	ret    

80102f86 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f86:	55                   	push   %ebp
80102f87:	89 e5                	mov    %esp,%ebp
80102f89:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f8c:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f91:	85 c0                	test   %eax,%eax
80102f93:	74 14                	je     80102fa9 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f9c:	00 
80102f9d:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102fa4:	e8 0b fe ff ff       	call   80102db4 <lapicw>
}
80102fa9:	c9                   	leave  
80102faa:	c3                   	ret    

80102fab <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fab:	55                   	push   %ebp
80102fac:	89 e5                	mov    %esp,%ebp
}
80102fae:	5d                   	pop    %ebp
80102faf:	c3                   	ret    

80102fb0 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fb0:	55                   	push   %ebp
80102fb1:	89 e5                	mov    %esp,%ebp
80102fb3:	83 ec 1c             	sub    $0x1c,%esp
80102fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb9:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fbc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fc3:	00 
80102fc4:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fcb:	e8 b6 fd ff ff       	call   80102d86 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fd0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fd7:	00 
80102fd8:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102fdf:	e8 a2 fd ff ff       	call   80102d86 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fe4:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102feb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fee:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102ff3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ff6:	8d 50 02             	lea    0x2(%eax),%edx
80102ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ffc:	c1 e8 04             	shr    $0x4,%eax
80102fff:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103002:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103006:	c1 e0 18             	shl    $0x18,%eax
80103009:	89 44 24 04          	mov    %eax,0x4(%esp)
8010300d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103014:	e8 9b fd ff ff       	call   80102db4 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103019:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103020:	00 
80103021:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103028:	e8 87 fd ff ff       	call   80102db4 <lapicw>
  microdelay(200);
8010302d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103034:	e8 72 ff ff ff       	call   80102fab <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103039:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103040:	00 
80103041:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103048:	e8 67 fd ff ff       	call   80102db4 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010304d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103054:	e8 52 ff ff ff       	call   80102fab <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103059:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103060:	eb 40                	jmp    801030a2 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103062:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103066:	c1 e0 18             	shl    $0x18,%eax
80103069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010306d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103074:	e8 3b fd ff ff       	call   80102db4 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103079:	8b 45 0c             	mov    0xc(%ebp),%eax
8010307c:	c1 e8 0c             	shr    $0xc,%eax
8010307f:	80 cc 06             	or     $0x6,%ah
80103082:	89 44 24 04          	mov    %eax,0x4(%esp)
80103086:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010308d:	e8 22 fd ff ff       	call   80102db4 <lapicw>
    microdelay(200);
80103092:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103099:	e8 0d ff ff ff       	call   80102fab <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010309e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030a2:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030a6:	7e ba                	jle    80103062 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030a8:	c9                   	leave  
801030a9:	c3                   	ret    

801030aa <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030aa:	55                   	push   %ebp
801030ab:	89 e5                	mov    %esp,%ebp
801030ad:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030b0:	8b 45 08             	mov    0x8(%ebp),%eax
801030b3:	0f b6 c0             	movzbl %al,%eax
801030b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801030ba:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030c1:	e8 c0 fc ff ff       	call   80102d86 <outb>
  microdelay(200);
801030c6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030cd:	e8 d9 fe ff ff       	call   80102fab <microdelay>

  return inb(CMOS_RETURN);
801030d2:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030d9:	e8 8b fc ff ff       	call   80102d69 <inb>
801030de:	0f b6 c0             	movzbl %al,%eax
}
801030e1:	c9                   	leave  
801030e2:	c3                   	ret    

801030e3 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030e3:	55                   	push   %ebp
801030e4:	89 e5                	mov    %esp,%ebp
801030e6:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030f0:	e8 b5 ff ff ff       	call   801030aa <cmos_read>
801030f5:	8b 55 08             	mov    0x8(%ebp),%edx
801030f8:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103101:	e8 a4 ff ff ff       	call   801030aa <cmos_read>
80103106:	8b 55 08             	mov    0x8(%ebp),%edx
80103109:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010310c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103113:	e8 92 ff ff ff       	call   801030aa <cmos_read>
80103118:	8b 55 08             	mov    0x8(%ebp),%edx
8010311b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010311e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103125:	e8 80 ff ff ff       	call   801030aa <cmos_read>
8010312a:	8b 55 08             	mov    0x8(%ebp),%edx
8010312d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103130:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103137:	e8 6e ff ff ff       	call   801030aa <cmos_read>
8010313c:	8b 55 08             	mov    0x8(%ebp),%edx
8010313f:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103142:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103149:	e8 5c ff ff ff       	call   801030aa <cmos_read>
8010314e:	8b 55 08             	mov    0x8(%ebp),%edx
80103151:	89 42 14             	mov    %eax,0x14(%edx)
}
80103154:	c9                   	leave  
80103155:	c3                   	ret    

80103156 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103156:	55                   	push   %ebp
80103157:	89 e5                	mov    %esp,%ebp
80103159:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010315c:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103163:	e8 42 ff ff ff       	call   801030aa <cmos_read>
80103168:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010316b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010316e:	83 e0 04             	and    $0x4,%eax
80103171:	85 c0                	test   %eax,%eax
80103173:	0f 94 c0             	sete   %al
80103176:	0f b6 c0             	movzbl %al,%eax
80103179:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010317c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010317f:	89 04 24             	mov    %eax,(%esp)
80103182:	e8 5c ff ff ff       	call   801030e3 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103187:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010318e:	e8 17 ff ff ff       	call   801030aa <cmos_read>
80103193:	25 80 00 00 00       	and    $0x80,%eax
80103198:	85 c0                	test   %eax,%eax
8010319a:	74 02                	je     8010319e <cmostime+0x48>
        continue;
8010319c:	eb 36                	jmp    801031d4 <cmostime+0x7e>
    fill_rtcdate(&t2);
8010319e:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031a1:	89 04 24             	mov    %eax,(%esp)
801031a4:	e8 3a ff ff ff       	call   801030e3 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031a9:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031b0:	00 
801031b1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801031b8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031bb:	89 04 24             	mov    %eax,(%esp)
801031be:	e8 b3 22 00 00       	call   80105476 <memcmp>
801031c3:	85 c0                	test   %eax,%eax
801031c5:	75 0d                	jne    801031d4 <cmostime+0x7e>
      break;
801031c7:	90                   	nop
  }

  // convert
  if (bcd) {
801031c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031cc:	0f 84 ac 00 00 00    	je     8010327e <cmostime+0x128>
801031d2:	eb 02                	jmp    801031d6 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031d4:	eb a6                	jmp    8010317c <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031d9:	c1 e8 04             	shr    $0x4,%eax
801031dc:	89 c2                	mov    %eax,%edx
801031de:	89 d0                	mov    %edx,%eax
801031e0:	c1 e0 02             	shl    $0x2,%eax
801031e3:	01 d0                	add    %edx,%eax
801031e5:	01 c0                	add    %eax,%eax
801031e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031ea:	83 e2 0f             	and    $0xf,%edx
801031ed:	01 d0                	add    %edx,%eax
801031ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031f5:	c1 e8 04             	shr    $0x4,%eax
801031f8:	89 c2                	mov    %eax,%edx
801031fa:	89 d0                	mov    %edx,%eax
801031fc:	c1 e0 02             	shl    $0x2,%eax
801031ff:	01 d0                	add    %edx,%eax
80103201:	01 c0                	add    %eax,%eax
80103203:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103206:	83 e2 0f             	and    $0xf,%edx
80103209:	01 d0                	add    %edx,%eax
8010320b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010320e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103211:	c1 e8 04             	shr    $0x4,%eax
80103214:	89 c2                	mov    %eax,%edx
80103216:	89 d0                	mov    %edx,%eax
80103218:	c1 e0 02             	shl    $0x2,%eax
8010321b:	01 d0                	add    %edx,%eax
8010321d:	01 c0                	add    %eax,%eax
8010321f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103222:	83 e2 0f             	and    $0xf,%edx
80103225:	01 d0                	add    %edx,%eax
80103227:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010322a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010322d:	c1 e8 04             	shr    $0x4,%eax
80103230:	89 c2                	mov    %eax,%edx
80103232:	89 d0                	mov    %edx,%eax
80103234:	c1 e0 02             	shl    $0x2,%eax
80103237:	01 d0                	add    %edx,%eax
80103239:	01 c0                	add    %eax,%eax
8010323b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010323e:	83 e2 0f             	and    $0xf,%edx
80103241:	01 d0                	add    %edx,%eax
80103243:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103246:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103249:	c1 e8 04             	shr    $0x4,%eax
8010324c:	89 c2                	mov    %eax,%edx
8010324e:	89 d0                	mov    %edx,%eax
80103250:	c1 e0 02             	shl    $0x2,%eax
80103253:	01 d0                	add    %edx,%eax
80103255:	01 c0                	add    %eax,%eax
80103257:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010325a:	83 e2 0f             	and    $0xf,%edx
8010325d:	01 d0                	add    %edx,%eax
8010325f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103262:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	89 d0                	mov    %edx,%eax
8010326c:	c1 e0 02             	shl    $0x2,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	01 c0                	add    %eax,%eax
80103273:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103276:	83 e2 0f             	and    $0xf,%edx
80103279:	01 d0                	add    %edx,%eax
8010327b:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010327e:	8b 45 08             	mov    0x8(%ebp),%eax
80103281:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103284:	89 10                	mov    %edx,(%eax)
80103286:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103289:	89 50 04             	mov    %edx,0x4(%eax)
8010328c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010328f:	89 50 08             	mov    %edx,0x8(%eax)
80103292:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103295:	89 50 0c             	mov    %edx,0xc(%eax)
80103298:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010329b:	89 50 10             	mov    %edx,0x10(%eax)
8010329e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032a1:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032a4:	8b 45 08             	mov    0x8(%ebp),%eax
801032a7:	8b 40 14             	mov    0x14(%eax),%eax
801032aa:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032b0:	8b 45 08             	mov    0x8(%ebp),%eax
801032b3:	89 50 14             	mov    %edx,0x14(%eax)
}
801032b6:	c9                   	leave  
801032b7:	c3                   	ret    

801032b8 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032b8:	55                   	push   %ebp
801032b9:	89 e5                	mov    %esp,%ebp
801032bb:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032be:	c7 44 24 04 20 8b 10 	movl   $0x80108b20,0x4(%esp)
801032c5:	80 
801032c6:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801032cd:	e8 b8 1e 00 00       	call   8010518a <initlock>
  readsb(dev, &sb);
801032d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d9:	8b 45 08             	mov    0x8(%ebp),%eax
801032dc:	89 04 24             	mov    %eax,(%esp)
801032df:	e8 28 e0 ff ff       	call   8010130c <readsb>
  log.start = sb.logstart;
801032e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e7:	a3 b4 22 11 80       	mov    %eax,0x801122b4
  log.size = sb.nlog;
801032ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ef:	a3 b8 22 11 80       	mov    %eax,0x801122b8
  log.dev = dev;
801032f4:	8b 45 08             	mov    0x8(%ebp),%eax
801032f7:	a3 c4 22 11 80       	mov    %eax,0x801122c4
  recover_from_log();
801032fc:	e8 9a 01 00 00       	call   8010349b <recover_from_log>
}
80103301:	c9                   	leave  
80103302:	c3                   	ret    

80103303 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103303:	55                   	push   %ebp
80103304:	89 e5                	mov    %esp,%ebp
80103306:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103309:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103310:	e9 8c 00 00 00       	jmp    801033a1 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103315:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
8010331b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331e:	01 d0                	add    %edx,%eax
80103320:	83 c0 01             	add    $0x1,%eax
80103323:	89 c2                	mov    %eax,%edx
80103325:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010332a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332e:	89 04 24             	mov    %eax,(%esp)
80103331:	e8 70 ce ff ff       	call   801001a6 <bread>
80103336:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333c:	83 c0 10             	add    $0x10,%eax
8010333f:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
80103346:	89 c2                	mov    %eax,%edx
80103348:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010334d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103351:	89 04 24             	mov    %eax,(%esp)
80103354:	e8 4d ce ff ff       	call   801001a6 <bread>
80103359:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010335c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010335f:	8d 50 18             	lea    0x18(%eax),%edx
80103362:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103365:	83 c0 18             	add    $0x18,%eax
80103368:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010336f:	00 
80103370:	89 54 24 04          	mov    %edx,0x4(%esp)
80103374:	89 04 24             	mov    %eax,(%esp)
80103377:	e8 52 21 00 00       	call   801054ce <memmove>
    bwrite(dbuf);  // write dst to disk
8010337c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337f:	89 04 24             	mov    %eax,(%esp)
80103382:	e8 56 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103387:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 85 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103395:	89 04 24             	mov    %eax,(%esp)
80103398:	e8 7a ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010339d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033a1:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801033a6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a9:	0f 8f 66 ff ff ff    	jg     80103315 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033af:	c9                   	leave  
801033b0:	c3                   	ret    

801033b1 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033b1:	55                   	push   %ebp
801033b2:	89 e5                	mov    %esp,%ebp
801033b4:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033b7:	a1 b4 22 11 80       	mov    0x801122b4,%eax
801033bc:	89 c2                	mov    %eax,%edx
801033be:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801033c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033c7:	89 04 24             	mov    %eax,(%esp)
801033ca:	e8 d7 cd ff ff       	call   801001a6 <bread>
801033cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033d5:	83 c0 18             	add    $0x18,%eax
801033d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033de:	8b 00                	mov    (%eax),%eax
801033e0:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  for (i = 0; i < log.lh.n; i++) {
801033e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033ec:	eb 1b                	jmp    80103409 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801033ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033f4:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033fb:	83 c2 10             	add    $0x10,%edx
801033fe:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103405:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103409:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010340e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103411:	7f db                	jg     801033ee <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103416:	89 04 24             	mov    %eax,(%esp)
80103419:	e8 f9 cd ff ff       	call   80100217 <brelse>
}
8010341e:	c9                   	leave  
8010341f:	c3                   	ret    

80103420 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103420:	55                   	push   %ebp
80103421:	89 e5                	mov    %esp,%ebp
80103423:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103426:	a1 b4 22 11 80       	mov    0x801122b4,%eax
8010342b:	89 c2                	mov    %eax,%edx
8010342d:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103432:	89 54 24 04          	mov    %edx,0x4(%esp)
80103436:	89 04 24             	mov    %eax,(%esp)
80103439:	e8 68 cd ff ff       	call   801001a6 <bread>
8010343e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103444:	83 c0 18             	add    $0x18,%eax
80103447:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010344a:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
80103450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103453:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103455:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010345c:	eb 1b                	jmp    80103479 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
8010345e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103461:	83 c0 10             	add    $0x10,%eax
80103464:	8b 0c 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%ecx
8010346b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103471:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103475:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103479:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010347e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103481:	7f db                	jg     8010345e <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103486:	89 04 24             	mov    %eax,(%esp)
80103489:	e8 4f cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010348e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103491:	89 04 24             	mov    %eax,(%esp)
80103494:	e8 7e cd ff ff       	call   80100217 <brelse>
}
80103499:	c9                   	leave  
8010349a:	c3                   	ret    

8010349b <recover_from_log>:

static void
recover_from_log(void)
{
8010349b:	55                   	push   %ebp
8010349c:	89 e5                	mov    %esp,%ebp
8010349e:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034a1:	e8 0b ff ff ff       	call   801033b1 <read_head>
  install_trans(); // if committed, copy from log to disk
801034a6:	e8 58 fe ff ff       	call   80103303 <install_trans>
  log.lh.n = 0;
801034ab:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
801034b2:	00 00 00 
  write_head(); // clear the log
801034b5:	e8 66 ff ff ff       	call   80103420 <write_head>
}
801034ba:	c9                   	leave  
801034bb:	c3                   	ret    

801034bc <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034c2:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801034c9:	e8 dd 1c 00 00       	call   801051ab <acquire>
  while(1){
    if(log.committing){
801034ce:	a1 c0 22 11 80       	mov    0x801122c0,%eax
801034d3:	85 c0                	test   %eax,%eax
801034d5:	74 16                	je     801034ed <begin_op+0x31>
      sleep(&log, &log.lock);
801034d7:	c7 44 24 04 80 22 11 	movl   $0x80112280,0x4(%esp)
801034de:	80 
801034df:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801034e6:	e8 f5 17 00 00       	call   80104ce0 <sleep>
801034eb:	eb 4f                	jmp    8010353c <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034ed:	8b 0d c8 22 11 80    	mov    0x801122c8,%ecx
801034f3:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801034f8:	8d 50 01             	lea    0x1(%eax),%edx
801034fb:	89 d0                	mov    %edx,%eax
801034fd:	c1 e0 02             	shl    $0x2,%eax
80103500:	01 d0                	add    %edx,%eax
80103502:	01 c0                	add    %eax,%eax
80103504:	01 c8                	add    %ecx,%eax
80103506:	83 f8 1e             	cmp    $0x1e,%eax
80103509:	7e 16                	jle    80103521 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010350b:	c7 44 24 04 80 22 11 	movl   $0x80112280,0x4(%esp)
80103512:	80 
80103513:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
8010351a:	e8 c1 17 00 00       	call   80104ce0 <sleep>
8010351f:	eb 1b                	jmp    8010353c <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103521:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103526:	83 c0 01             	add    $0x1,%eax
80103529:	a3 bc 22 11 80       	mov    %eax,0x801122bc
      release(&log.lock);
8010352e:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103535:	e8 d3 1c 00 00       	call   8010520d <release>
      break;
8010353a:	eb 02                	jmp    8010353e <begin_op+0x82>
    }
  }
8010353c:	eb 90                	jmp    801034ce <begin_op+0x12>
}
8010353e:	c9                   	leave  
8010353f:	c3                   	ret    

80103540 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103540:	55                   	push   %ebp
80103541:	89 e5                	mov    %esp,%ebp
80103543:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010354d:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103554:	e8 52 1c 00 00       	call   801051ab <acquire>
  log.outstanding -= 1;
80103559:	a1 bc 22 11 80       	mov    0x801122bc,%eax
8010355e:	83 e8 01             	sub    $0x1,%eax
80103561:	a3 bc 22 11 80       	mov    %eax,0x801122bc
  if(log.committing)
80103566:	a1 c0 22 11 80       	mov    0x801122c0,%eax
8010356b:	85 c0                	test   %eax,%eax
8010356d:	74 0c                	je     8010357b <end_op+0x3b>
    panic("log.committing");
8010356f:	c7 04 24 24 8b 10 80 	movl   $0x80108b24,(%esp)
80103576:	e8 bf cf ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
8010357b:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103580:	85 c0                	test   %eax,%eax
80103582:	75 13                	jne    80103597 <end_op+0x57>
    do_commit = 1;
80103584:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010358b:	c7 05 c0 22 11 80 01 	movl   $0x1,0x801122c0
80103592:	00 00 00 
80103595:	eb 0c                	jmp    801035a3 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103597:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
8010359e:	e8 19 18 00 00       	call   80104dbc <wakeup>
  }
  release(&log.lock);
801035a3:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035aa:	e8 5e 1c 00 00       	call   8010520d <release>

  if(do_commit){
801035af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b3:	74 33                	je     801035e8 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035b5:	e8 de 00 00 00       	call   80103698 <commit>
    acquire(&log.lock);
801035ba:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035c1:	e8 e5 1b 00 00       	call   801051ab <acquire>
    log.committing = 0;
801035c6:	c7 05 c0 22 11 80 00 	movl   $0x0,0x801122c0
801035cd:	00 00 00 
    wakeup(&log);
801035d0:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035d7:	e8 e0 17 00 00       	call   80104dbc <wakeup>
    release(&log.lock);
801035dc:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801035e3:	e8 25 1c 00 00       	call   8010520d <release>
  }
}
801035e8:	c9                   	leave  
801035e9:	c3                   	ret    

801035ea <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035ea:	55                   	push   %ebp
801035eb:	89 e5                	mov    %esp,%ebp
801035ed:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f7:	e9 8c 00 00 00       	jmp    80103688 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035fc:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
80103602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103605:	01 d0                	add    %edx,%eax
80103607:	83 c0 01             	add    $0x1,%eax
8010360a:	89 c2                	mov    %eax,%edx
8010360c:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103611:	89 54 24 04          	mov    %edx,0x4(%esp)
80103615:	89 04 24             	mov    %eax,(%esp)
80103618:	e8 89 cb ff ff       	call   801001a6 <bread>
8010361d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103623:	83 c0 10             	add    $0x10,%eax
80103626:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
8010362d:	89 c2                	mov    %eax,%edx
8010362f:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103634:	89 54 24 04          	mov    %edx,0x4(%esp)
80103638:	89 04 24             	mov    %eax,(%esp)
8010363b:	e8 66 cb ff ff       	call   801001a6 <bread>
80103640:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103643:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103646:	8d 50 18             	lea    0x18(%eax),%edx
80103649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364c:	83 c0 18             	add    $0x18,%eax
8010364f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103656:	00 
80103657:	89 54 24 04          	mov    %edx,0x4(%esp)
8010365b:	89 04 24             	mov    %eax,(%esp)
8010365e:	e8 6b 1e 00 00       	call   801054ce <memmove>
    bwrite(to);  // write the log
80103663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103666:	89 04 24             	mov    %eax,(%esp)
80103669:	e8 6f cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
8010366e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103671:	89 04 24             	mov    %eax,(%esp)
80103674:	e8 9e cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367c:	89 04 24             	mov    %eax,(%esp)
8010367f:	e8 93 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103688:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010368d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103690:	0f 8f 66 ff ff ff    	jg     801035fc <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103696:	c9                   	leave  
80103697:	c3                   	ret    

80103698 <commit>:

static void
commit()
{
80103698:	55                   	push   %ebp
80103699:	89 e5                	mov    %esp,%ebp
8010369b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010369e:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	7e 1e                	jle    801036c5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036a7:	e8 3e ff ff ff       	call   801035ea <write_log>
    write_head();    // Write header to disk -- the real commit
801036ac:	e8 6f fd ff ff       	call   80103420 <write_head>
    install_trans(); // Now install writes to home locations
801036b1:	e8 4d fc ff ff       	call   80103303 <install_trans>
    log.lh.n = 0; 
801036b6:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
801036bd:	00 00 00 
    write_head();    // Erase the transaction from the log
801036c0:	e8 5b fd ff ff       	call   80103420 <write_head>
  }
}
801036c5:	c9                   	leave  
801036c6:	c3                   	ret    

801036c7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036c7:	55                   	push   %ebp
801036c8:	89 e5                	mov    %esp,%ebp
801036ca:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036cd:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036d2:	83 f8 1d             	cmp    $0x1d,%eax
801036d5:	7f 12                	jg     801036e9 <log_write+0x22>
801036d7:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801036dc:	8b 15 b8 22 11 80    	mov    0x801122b8,%edx
801036e2:	83 ea 01             	sub    $0x1,%edx
801036e5:	39 d0                	cmp    %edx,%eax
801036e7:	7c 0c                	jl     801036f5 <log_write+0x2e>
    panic("too big a transaction");
801036e9:	c7 04 24 33 8b 10 80 	movl   $0x80108b33,(%esp)
801036f0:	e8 45 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
801036f5:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801036fa:	85 c0                	test   %eax,%eax
801036fc:	7f 0c                	jg     8010370a <log_write+0x43>
    panic("log_write outside of trans");
801036fe:	c7 04 24 49 8b 10 80 	movl   $0x80108b49,(%esp)
80103705:	e8 30 ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010370a:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103711:	e8 95 1a 00 00       	call   801051ab <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010371d:	eb 1f                	jmp    8010373e <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010371f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103722:	83 c0 10             	add    $0x10,%eax
80103725:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
8010372c:	89 c2                	mov    %eax,%edx
8010372e:	8b 45 08             	mov    0x8(%ebp),%eax
80103731:	8b 40 08             	mov    0x8(%eax),%eax
80103734:	39 c2                	cmp    %eax,%edx
80103736:	75 02                	jne    8010373a <log_write+0x73>
      break;
80103738:	eb 0e                	jmp    80103748 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010373a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010373e:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103743:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103746:	7f d7                	jg     8010371f <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103748:	8b 45 08             	mov    0x8(%ebp),%eax
8010374b:	8b 40 08             	mov    0x8(%eax),%eax
8010374e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103751:	83 c2 10             	add    $0x10,%edx
80103754:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
  if (i == log.lh.n)
8010375b:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103760:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103763:	75 0d                	jne    80103772 <log_write+0xab>
    log.lh.n++;
80103765:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010376a:	83 c0 01             	add    $0x1,%eax
8010376d:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  b->flags |= B_DIRTY; // prevent eviction
80103772:	8b 45 08             	mov    0x8(%ebp),%eax
80103775:	8b 00                	mov    (%eax),%eax
80103777:	83 c8 04             	or     $0x4,%eax
8010377a:	89 c2                	mov    %eax,%edx
8010377c:	8b 45 08             	mov    0x8(%ebp),%eax
8010377f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103781:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80103788:	e8 80 1a 00 00       	call   8010520d <release>
}
8010378d:	c9                   	leave  
8010378e:	c3                   	ret    

8010378f <v2p>:
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	8b 45 08             	mov    0x8(%ebp),%eax
80103795:	05 00 00 00 80       	add    $0x80000000,%eax
8010379a:	5d                   	pop    %ebp
8010379b:	c3                   	ret    

8010379c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010379c:	55                   	push   %ebp
8010379d:	89 e5                	mov    %esp,%ebp
8010379f:	8b 45 08             	mov    0x8(%ebp),%eax
801037a2:	05 00 00 00 80       	add    $0x80000000,%eax
801037a7:	5d                   	pop    %ebp
801037a8:	c3                   	ret    

801037a9 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037af:	8b 55 08             	mov    0x8(%ebp),%edx
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037b8:	f0 87 02             	lock xchg %eax,(%edx)
801037bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037c1:	c9                   	leave  
801037c2:	c3                   	ret    

801037c3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037c3:	55                   	push   %ebp
801037c4:	89 e5                	mov    %esp,%ebp
801037c6:	83 e4 f0             	and    $0xfffffff0,%esp
801037c9:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037cc:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037d3:	80 
801037d4:	c7 04 24 5c 54 11 80 	movl   $0x8011545c,(%esp)
801037db:	e8 8a f2 ff ff       	call   80102a6a <kinit1>
  kvmalloc();      // kernel page table
801037e0:	e8 10 49 00 00       	call   801080f5 <kvmalloc>
  mpinit();        // collect info about this machine
801037e5:	e8 41 04 00 00       	call   80103c2b <mpinit>
  lapicinit();
801037ea:	e8 e6 f5 ff ff       	call   80102dd5 <lapicinit>
  seginit();       // set up segments
801037ef:	e8 94 42 00 00       	call   80107a88 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037fa:	0f b6 00             	movzbl (%eax),%eax
801037fd:	0f b6 c0             	movzbl %al,%eax
80103800:	89 44 24 04          	mov    %eax,0x4(%esp)
80103804:	c7 04 24 64 8b 10 80 	movl   $0x80108b64,(%esp)
8010380b:	e8 90 cb ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103810:	e8 74 06 00 00       	call   80103e89 <picinit>
  ioapicinit();    // another interrupt controller
80103815:	e8 46 f1 ff ff       	call   80102960 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010381a:	e8 91 d2 ff ff       	call   80100ab0 <consoleinit>
  uartinit();      // serial port
8010381f:	e8 b3 35 00 00       	call   80106dd7 <uartinit>
  pinit();         // process table
80103824:	e8 f1 0b 00 00       	call   8010441a <pinit>
  tvinit();        // trap vectors
80103829:	e8 5b 31 00 00       	call   80106989 <tvinit>
  binit();         // buffer cache
8010382e:	e8 01 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103833:	e8 ed d6 ff ff       	call   80100f25 <fileinit>
  ideinit();       // disk
80103838:	e8 55 ed ff ff       	call   80102592 <ideinit>
  if(!ismp)
8010383d:	a1 64 23 11 80       	mov    0x80112364,%eax
80103842:	85 c0                	test   %eax,%eax
80103844:	75 05                	jne    8010384b <main+0x88>
    timerinit();   // uniprocessor timer
80103846:	e8 89 30 00 00       	call   801068d4 <timerinit>
  startothers();   // start other processors
8010384b:	e8 7f 00 00 00       	call   801038cf <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103850:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103857:	8e 
80103858:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010385f:	e8 3e f2 ff ff       	call   80102aa2 <kinit2>
  userinit();      // first user process
80103864:	e8 c6 0c 00 00       	call   8010452f <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103869:	e8 1a 00 00 00       	call   80103888 <mpmain>

8010386e <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010386e:	55                   	push   %ebp
8010386f:	89 e5                	mov    %esp,%ebp
80103871:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103874:	e8 93 48 00 00       	call   8010810c <switchkvm>
  seginit();
80103879:	e8 0a 42 00 00       	call   80107a88 <seginit>
  lapicinit();
8010387e:	e8 52 f5 ff ff       	call   80102dd5 <lapicinit>
  mpmain();
80103883:	e8 00 00 00 00       	call   80103888 <mpmain>

80103888 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103888:	55                   	push   %ebp
80103889:	89 e5                	mov    %esp,%ebp
8010388b:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010388e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103894:	0f b6 00             	movzbl (%eax),%eax
80103897:	0f b6 c0             	movzbl %al,%eax
8010389a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010389e:	c7 04 24 7b 8b 10 80 	movl   $0x80108b7b,(%esp)
801038a5:	e8 f6 ca ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801038aa:	e8 4e 32 00 00       	call   80106afd <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801038af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038b5:	05 a8 00 00 00       	add    $0xa8,%eax
801038ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038c1:	00 
801038c2:	89 04 24             	mov    %eax,(%esp)
801038c5:	e8 df fe ff ff       	call   801037a9 <xchg>
  scheduler();     // start running processes
801038ca:	e8 53 12 00 00       	call   80104b22 <scheduler>

801038cf <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038cf:	55                   	push   %ebp
801038d0:	89 e5                	mov    %esp,%ebp
801038d2:	53                   	push   %ebx
801038d3:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038d6:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038dd:	e8 ba fe ff ff       	call   8010379c <p2v>
801038e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038e5:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801038ee:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
801038f5:	80 
801038f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f9:	89 04 24             	mov    %eax,(%esp)
801038fc:	e8 cd 1b 00 00       	call   801054ce <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103901:	c7 45 f4 80 23 11 80 	movl   $0x80112380,-0xc(%ebp)
80103908:	e9 85 00 00 00       	jmp    80103992 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
8010390d:	e8 1c f6 ff ff       	call   80102f2e <cpunum>
80103912:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103918:	05 80 23 11 80       	add    $0x80112380,%eax
8010391d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103920:	75 02                	jne    80103924 <startothers+0x55>
      continue;
80103922:	eb 67                	jmp    8010398b <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103924:	e8 6f f2 ff ff       	call   80102b98 <kalloc>
80103929:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010392c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010392f:	83 e8 04             	sub    $0x4,%eax
80103932:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103935:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010393b:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010393d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103940:	83 e8 08             	sub    $0x8,%eax
80103943:	c7 00 6e 38 10 80    	movl   $0x8010386e,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394c:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010394f:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103956:	e8 34 fe ff ff       	call   8010378f <v2p>
8010395b:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010395d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103960:	89 04 24             	mov    %eax,(%esp)
80103963:	e8 27 fe ff ff       	call   8010378f <v2p>
80103968:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010396b:	0f b6 12             	movzbl (%edx),%edx
8010396e:	0f b6 d2             	movzbl %dl,%edx
80103971:	89 44 24 04          	mov    %eax,0x4(%esp)
80103975:	89 14 24             	mov    %edx,(%esp)
80103978:	e8 33 f6 ff ff       	call   80102fb0 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010397d:	90                   	nop
8010397e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103981:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103987:	85 c0                	test   %eax,%eax
80103989:	74 f3                	je     8010397e <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010398b:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103992:	a1 60 29 11 80       	mov    0x80112960,%eax
80103997:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010399d:	05 80 23 11 80       	add    $0x80112380,%eax
801039a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039a5:	0f 87 62 ff ff ff    	ja     8010390d <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039ab:	83 c4 24             	add    $0x24,%esp
801039ae:	5b                   	pop    %ebx
801039af:	5d                   	pop    %ebp
801039b0:	c3                   	ret    

801039b1 <p2v>:
801039b1:	55                   	push   %ebp
801039b2:	89 e5                	mov    %esp,%ebp
801039b4:	8b 45 08             	mov    0x8(%ebp),%eax
801039b7:	05 00 00 00 80       	add    $0x80000000,%eax
801039bc:	5d                   	pop    %ebp
801039bd:	c3                   	ret    

801039be <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	83 ec 14             	sub    $0x14,%esp
801039c4:	8b 45 08             	mov    0x8(%ebp),%eax
801039c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801039cf:	89 c2                	mov    %eax,%edx
801039d1:	ec                   	in     (%dx),%al
801039d2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039d5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801039d9:	c9                   	leave  
801039da:	c3                   	ret    

801039db <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039db:	55                   	push   %ebp
801039dc:	89 e5                	mov    %esp,%ebp
801039de:	83 ec 08             	sub    $0x8,%esp
801039e1:	8b 55 08             	mov    0x8(%ebp),%edx
801039e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039eb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ee:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039f2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039f6:	ee                   	out    %al,(%dx)
}
801039f7:	c9                   	leave  
801039f8:	c3                   	ret    

801039f9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039f9:	55                   	push   %ebp
801039fa:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039fc:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80103a01:	89 c2                	mov    %eax,%edx
80103a03:	b8 80 23 11 80       	mov    $0x80112380,%eax
80103a08:	29 c2                	sub    %eax,%edx
80103a0a:	89 d0                	mov    %edx,%eax
80103a0c:	c1 f8 02             	sar    $0x2,%eax
80103a0f:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a15:	5d                   	pop    %ebp
80103a16:	c3                   	ret    

80103a17 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a17:	55                   	push   %ebp
80103a18:	89 e5                	mov    %esp,%ebp
80103a1a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a1d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a2b:	eb 15                	jmp    80103a42 <sum+0x2b>
    sum += addr[i];
80103a2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a30:	8b 45 08             	mov    0x8(%ebp),%eax
80103a33:	01 d0                	add    %edx,%eax
80103a35:	0f b6 00             	movzbl (%eax),%eax
80103a38:	0f b6 c0             	movzbl %al,%eax
80103a3b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a3e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a45:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a48:	7c e3                	jl     80103a2d <sum+0x16>
    sum += addr[i];
  return sum;
80103a4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a4d:	c9                   	leave  
80103a4e:	c3                   	ret    

80103a4f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a4f:	55                   	push   %ebp
80103a50:	89 e5                	mov    %esp,%ebp
80103a52:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a55:	8b 45 08             	mov    0x8(%ebp),%eax
80103a58:	89 04 24             	mov    %eax,(%esp)
80103a5b:	e8 51 ff ff ff       	call   801039b1 <p2v>
80103a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a63:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a69:	01 d0                	add    %edx,%eax
80103a6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a74:	eb 3f                	jmp    80103ab5 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a76:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a7d:	00 
80103a7e:	c7 44 24 04 8c 8b 10 	movl   $0x80108b8c,0x4(%esp)
80103a85:	80 
80103a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a89:	89 04 24             	mov    %eax,(%esp)
80103a8c:	e8 e5 19 00 00       	call   80105476 <memcmp>
80103a91:	85 c0                	test   %eax,%eax
80103a93:	75 1c                	jne    80103ab1 <mpsearch1+0x62>
80103a95:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a9c:	00 
80103a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa0:	89 04 24             	mov    %eax,(%esp)
80103aa3:	e8 6f ff ff ff       	call   80103a17 <sum>
80103aa8:	84 c0                	test   %al,%al
80103aaa:	75 05                	jne    80103ab1 <mpsearch1+0x62>
      return (struct mp*)p;
80103aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaf:	eb 11                	jmp    80103ac2 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ab1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103abb:	72 b9                	jb     80103a76 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ac2:	c9                   	leave  
80103ac3:	c3                   	ret    

80103ac4 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ac4:	55                   	push   %ebp
80103ac5:	89 e5                	mov    %esp,%ebp
80103ac7:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aca:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad4:	83 c0 0f             	add    $0xf,%eax
80103ad7:	0f b6 00             	movzbl (%eax),%eax
80103ada:	0f b6 c0             	movzbl %al,%eax
80103add:	c1 e0 08             	shl    $0x8,%eax
80103ae0:	89 c2                	mov    %eax,%edx
80103ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae5:	83 c0 0e             	add    $0xe,%eax
80103ae8:	0f b6 00             	movzbl (%eax),%eax
80103aeb:	0f b6 c0             	movzbl %al,%eax
80103aee:	09 d0                	or     %edx,%eax
80103af0:	c1 e0 04             	shl    $0x4,%eax
80103af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103af6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103afa:	74 21                	je     80103b1d <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103afc:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b03:	00 
80103b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b07:	89 04 24             	mov    %eax,(%esp)
80103b0a:	e8 40 ff ff ff       	call   80103a4f <mpsearch1>
80103b0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b12:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b16:	74 50                	je     80103b68 <mpsearch+0xa4>
      return mp;
80103b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b1b:	eb 5f                	jmp    80103b7c <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b20:	83 c0 14             	add    $0x14,%eax
80103b23:	0f b6 00             	movzbl (%eax),%eax
80103b26:	0f b6 c0             	movzbl %al,%eax
80103b29:	c1 e0 08             	shl    $0x8,%eax
80103b2c:	89 c2                	mov    %eax,%edx
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	83 c0 13             	add    $0x13,%eax
80103b34:	0f b6 00             	movzbl (%eax),%eax
80103b37:	0f b6 c0             	movzbl %al,%eax
80103b3a:	09 d0                	or     %edx,%eax
80103b3c:	c1 e0 0a             	shl    $0xa,%eax
80103b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b45:	2d 00 04 00 00       	sub    $0x400,%eax
80103b4a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b51:	00 
80103b52:	89 04 24             	mov    %eax,(%esp)
80103b55:	e8 f5 fe ff ff       	call   80103a4f <mpsearch1>
80103b5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b61:	74 05                	je     80103b68 <mpsearch+0xa4>
      return mp;
80103b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b66:	eb 14                	jmp    80103b7c <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b68:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b6f:	00 
80103b70:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b77:	e8 d3 fe ff ff       	call   80103a4f <mpsearch1>
}
80103b7c:	c9                   	leave  
80103b7d:	c3                   	ret    

80103b7e <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b7e:	55                   	push   %ebp
80103b7f:	89 e5                	mov    %esp,%ebp
80103b81:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b84:	e8 3b ff ff ff       	call   80103ac4 <mpsearch>
80103b89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b90:	74 0a                	je     80103b9c <mpconfig+0x1e>
80103b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b95:	8b 40 04             	mov    0x4(%eax),%eax
80103b98:	85 c0                	test   %eax,%eax
80103b9a:	75 0a                	jne    80103ba6 <mpconfig+0x28>
    return 0;
80103b9c:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba1:	e9 83 00 00 00       	jmp    80103c29 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba9:	8b 40 04             	mov    0x4(%eax),%eax
80103bac:	89 04 24             	mov    %eax,(%esp)
80103baf:	e8 fd fd ff ff       	call   801039b1 <p2v>
80103bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bb7:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bbe:	00 
80103bbf:	c7 44 24 04 91 8b 10 	movl   $0x80108b91,0x4(%esp)
80103bc6:	80 
80103bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bca:	89 04 24             	mov    %eax,(%esp)
80103bcd:	e8 a4 18 00 00       	call   80105476 <memcmp>
80103bd2:	85 c0                	test   %eax,%eax
80103bd4:	74 07                	je     80103bdd <mpconfig+0x5f>
    return 0;
80103bd6:	b8 00 00 00 00       	mov    $0x0,%eax
80103bdb:	eb 4c                	jmp    80103c29 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103be4:	3c 01                	cmp    $0x1,%al
80103be6:	74 12                	je     80103bfa <mpconfig+0x7c>
80103be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103beb:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bef:	3c 04                	cmp    $0x4,%al
80103bf1:	74 07                	je     80103bfa <mpconfig+0x7c>
    return 0;
80103bf3:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf8:	eb 2f                	jmp    80103c29 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfd:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c01:	0f b7 c0             	movzwl %ax,%eax
80103c04:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0b:	89 04 24             	mov    %eax,(%esp)
80103c0e:	e8 04 fe ff ff       	call   80103a17 <sum>
80103c13:	84 c0                	test   %al,%al
80103c15:	74 07                	je     80103c1e <mpconfig+0xa0>
    return 0;
80103c17:	b8 00 00 00 00       	mov    $0x0,%eax
80103c1c:	eb 0b                	jmp    80103c29 <mpconfig+0xab>
  *pmp = mp;
80103c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c24:	89 10                	mov    %edx,(%eax)
  return conf;
80103c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c29:	c9                   	leave  
80103c2a:	c3                   	ret    

80103c2b <mpinit>:

void
mpinit(void)
{
80103c2b:	55                   	push   %ebp
80103c2c:	89 e5                	mov    %esp,%ebp
80103c2e:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c31:	c7 05 64 b6 10 80 80 	movl   $0x80112380,0x8010b664
80103c38:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c3b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c3e:	89 04 24             	mov    %eax,(%esp)
80103c41:	e8 38 ff ff ff       	call   80103b7e <mpconfig>
80103c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c4d:	75 05                	jne    80103c54 <mpinit+0x29>
    return;
80103c4f:	e9 9c 01 00 00       	jmp    80103df0 <mpinit+0x1c5>
  ismp = 1;
80103c54:	c7 05 64 23 11 80 01 	movl   $0x1,0x80112364
80103c5b:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c61:	8b 40 24             	mov    0x24(%eax),%eax
80103c64:	a3 7c 22 11 80       	mov    %eax,0x8011227c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6c:	83 c0 2c             	add    $0x2c,%eax
80103c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c75:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c79:	0f b7 d0             	movzwl %ax,%edx
80103c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7f:	01 d0                	add    %edx,%eax
80103c81:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c84:	e9 f4 00 00 00       	jmp    80103d7d <mpinit+0x152>
    switch(*p){
80103c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8c:	0f b6 00             	movzbl (%eax),%eax
80103c8f:	0f b6 c0             	movzbl %al,%eax
80103c92:	83 f8 04             	cmp    $0x4,%eax
80103c95:	0f 87 bf 00 00 00    	ja     80103d5a <mpinit+0x12f>
80103c9b:	8b 04 85 d4 8b 10 80 	mov    -0x7fef742c(,%eax,4),%eax
80103ca2:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103caa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cad:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cb1:	0f b6 d0             	movzbl %al,%edx
80103cb4:	a1 60 29 11 80       	mov    0x80112960,%eax
80103cb9:	39 c2                	cmp    %eax,%edx
80103cbb:	74 2d                	je     80103cea <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cc0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cc4:	0f b6 d0             	movzbl %al,%edx
80103cc7:	a1 60 29 11 80       	mov    0x80112960,%eax
80103ccc:	89 54 24 08          	mov    %edx,0x8(%esp)
80103cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cd4:	c7 04 24 96 8b 10 80 	movl   $0x80108b96,(%esp)
80103cdb:	e8 c0 c6 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103ce0:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103ce7:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ced:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cf1:	0f b6 c0             	movzbl %al,%eax
80103cf4:	83 e0 02             	and    $0x2,%eax
80103cf7:	85 c0                	test   %eax,%eax
80103cf9:	74 15                	je     80103d10 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103cfb:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d00:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d06:	05 80 23 11 80       	add    $0x80112380,%eax
80103d0b:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103d10:	8b 15 60 29 11 80    	mov    0x80112960,%edx
80103d16:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d1b:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103d21:	81 c2 80 23 11 80    	add    $0x80112380,%edx
80103d27:	88 02                	mov    %al,(%edx)
      ncpu++;
80103d29:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d2e:	83 c0 01             	add    $0x1,%eax
80103d31:	a3 60 29 11 80       	mov    %eax,0x80112960
      p += sizeof(struct mpproc);
80103d36:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d3a:	eb 41                	jmp    80103d7d <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d45:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d49:	a2 60 23 11 80       	mov    %al,0x80112360
      p += sizeof(struct mpioapic);
80103d4e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d52:	eb 29                	jmp    80103d7d <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d54:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d58:	eb 23                	jmp    80103d7d <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5d:	0f b6 00             	movzbl (%eax),%eax
80103d60:	0f b6 c0             	movzbl %al,%eax
80103d63:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d67:	c7 04 24 b4 8b 10 80 	movl   $0x80108bb4,(%esp)
80103d6e:	e8 2d c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103d73:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103d7a:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d80:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d83:	0f 82 00 ff ff ff    	jb     80103c89 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d89:	a1 64 23 11 80       	mov    0x80112364,%eax
80103d8e:	85 c0                	test   %eax,%eax
80103d90:	75 1d                	jne    80103daf <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d92:	c7 05 60 29 11 80 01 	movl   $0x1,0x80112960
80103d99:	00 00 00 
    lapic = 0;
80103d9c:	c7 05 7c 22 11 80 00 	movl   $0x0,0x8011227c
80103da3:	00 00 00 
    ioapicid = 0;
80103da6:	c6 05 60 23 11 80 00 	movb   $0x0,0x80112360
    return;
80103dad:	eb 41                	jmp    80103df0 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103daf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103db6:	84 c0                	test   %al,%al
80103db8:	74 36                	je     80103df0 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dba:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103dc1:	00 
80103dc2:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103dc9:	e8 0d fc ff ff       	call   801039db <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103dce:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dd5:	e8 e4 fb ff ff       	call   801039be <inb>
80103dda:	83 c8 01             	or     $0x1,%eax
80103ddd:	0f b6 c0             	movzbl %al,%eax
80103de0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103de4:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103deb:	e8 eb fb ff ff       	call   801039db <outb>
  }
}
80103df0:	c9                   	leave  
80103df1:	c3                   	ret    

80103df2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103df2:	55                   	push   %ebp
80103df3:	89 e5                	mov    %esp,%ebp
80103df5:	83 ec 08             	sub    $0x8,%esp
80103df8:	8b 55 08             	mov    0x8(%ebp),%edx
80103dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dfe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e02:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e05:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e09:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e0d:	ee                   	out    %al,(%dx)
}
80103e0e:	c9                   	leave  
80103e0f:	c3                   	ret    

80103e10 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e10:	55                   	push   %ebp
80103e11:	89 e5                	mov    %esp,%ebp
80103e13:	83 ec 0c             	sub    $0xc,%esp
80103e16:	8b 45 08             	mov    0x8(%ebp),%eax
80103e19:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e1d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e21:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103e27:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e2b:	0f b6 c0             	movzbl %al,%eax
80103e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e32:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e39:	e8 b4 ff ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e3e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e42:	66 c1 e8 08          	shr    $0x8,%ax
80103e46:	0f b6 c0             	movzbl %al,%eax
80103e49:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e4d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e54:	e8 99 ff ff ff       	call   80103df2 <outb>
}
80103e59:	c9                   	leave  
80103e5a:	c3                   	ret    

80103e5b <picenable>:

void
picenable(int irq)
{
80103e5b:	55                   	push   %ebp
80103e5c:	89 e5                	mov    %esp,%ebp
80103e5e:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e61:	8b 45 08             	mov    0x8(%ebp),%eax
80103e64:	ba 01 00 00 00       	mov    $0x1,%edx
80103e69:	89 c1                	mov    %eax,%ecx
80103e6b:	d3 e2                	shl    %cl,%edx
80103e6d:	89 d0                	mov    %edx,%eax
80103e6f:	f7 d0                	not    %eax
80103e71:	89 c2                	mov    %eax,%edx
80103e73:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e7a:	21 d0                	and    %edx,%eax
80103e7c:	0f b7 c0             	movzwl %ax,%eax
80103e7f:	89 04 24             	mov    %eax,(%esp)
80103e82:	e8 89 ff ff ff       	call   80103e10 <picsetmask>
}
80103e87:	c9                   	leave  
80103e88:	c3                   	ret    

80103e89 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e89:	55                   	push   %ebp
80103e8a:	89 e5                	mov    %esp,%ebp
80103e8c:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e8f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e96:	00 
80103e97:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9e:	e8 4f ff ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ea3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103eaa:	00 
80103eab:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eb2:	e8 3b ff ff ff       	call   80103df2 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103eb7:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ebe:	00 
80103ebf:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ec6:	e8 27 ff ff ff       	call   80103df2 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ecb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ed2:	00 
80103ed3:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eda:	e8 13 ff ff ff       	call   80103df2 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103edf:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ee6:	00 
80103ee7:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eee:	e8 ff fe ff ff       	call   80103df2 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ef3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103efa:	00 
80103efb:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f02:	e8 eb fe ff ff       	call   80103df2 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f07:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103f0e:	00 
80103f0f:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f16:	e8 d7 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f1b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103f22:	00 
80103f23:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f2a:	e8 c3 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f2f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f36:	00 
80103f37:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f3e:	e8 af fe ff ff       	call   80103df2 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f43:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f4a:	00 
80103f4b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f52:	e8 9b fe ff ff       	call   80103df2 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f57:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f5e:	00 
80103f5f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f66:	e8 87 fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f6b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f72:	00 
80103f73:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f7a:	e8 73 fe ff ff       	call   80103df2 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f7f:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f86:	00 
80103f87:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f8e:	e8 5f fe ff ff       	call   80103df2 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f93:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f9a:	00 
80103f9b:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103fa2:	e8 4b fe ff ff       	call   80103df2 <outb>

  if(irqmask != 0xFFFF)
80103fa7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fae:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fb2:	74 12                	je     80103fc6 <picinit+0x13d>
    picsetmask(irqmask);
80103fb4:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fbb:	0f b7 c0             	movzwl %ax,%eax
80103fbe:	89 04 24             	mov    %eax,(%esp)
80103fc1:	e8 4a fe ff ff       	call   80103e10 <picsetmask>
}
80103fc6:	c9                   	leave  
80103fc7:	c3                   	ret    

80103fc8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe1:	8b 10                	mov    (%eax),%edx
80103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fe8:	e8 54 cf ff ff       	call   80100f41 <filealloc>
80103fed:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff0:	89 02                	mov    %eax,(%edx)
80103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff5:	8b 00                	mov    (%eax),%eax
80103ff7:	85 c0                	test   %eax,%eax
80103ff9:	0f 84 c8 00 00 00    	je     801040c7 <pipealloc+0xff>
80103fff:	e8 3d cf ff ff       	call   80100f41 <filealloc>
80104004:	8b 55 0c             	mov    0xc(%ebp),%edx
80104007:	89 02                	mov    %eax,(%edx)
80104009:	8b 45 0c             	mov    0xc(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	85 c0                	test   %eax,%eax
80104010:	0f 84 b1 00 00 00    	je     801040c7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104016:	e8 7d eb ff ff       	call   80102b98 <kalloc>
8010401b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010401e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104022:	75 05                	jne    80104029 <pipealloc+0x61>
    goto bad;
80104024:	e9 9e 00 00 00       	jmp    801040c7 <pipealloc+0xff>
  p->readopen = 1;
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104033:	00 00 00 
  p->writeopen = 1;
80104036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104039:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104040:	00 00 00 
  p->nwrite = 0;
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010404d:	00 00 00 
  p->nread = 0;
80104050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104053:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010405a:	00 00 00 
  initlock(&p->lock, "pipe");
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	c7 44 24 04 e8 8b 10 	movl   $0x80108be8,0x4(%esp)
80104067:	80 
80104068:	89 04 24             	mov    %eax,(%esp)
8010406b:	e8 1a 11 00 00       	call   8010518a <initlock>
  (*f0)->type = FD_PIPE;
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	8b 00                	mov    (%eax),%eax
80104075:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	8b 00                	mov    (%eax),%eax
80104080:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104084:	8b 45 08             	mov    0x8(%ebp),%eax
80104087:	8b 00                	mov    (%eax),%eax
80104089:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	8b 00                	mov    (%eax),%eax
80104092:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104095:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104098:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409b:	8b 00                	mov    (%eax),%eax
8010409d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a6:	8b 00                	mov    (%eax),%eax
801040a8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801040af:	8b 00                	mov    (%eax),%eax
801040b1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b8:	8b 00                	mov    (%eax),%eax
801040ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040bd:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040c0:	b8 00 00 00 00       	mov    $0x0,%eax
801040c5:	eb 42                	jmp    80104109 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801040c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040cb:	74 0b                	je     801040d8 <pipealloc+0x110>
    kfree((char*)p);
801040cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d0:	89 04 24             	mov    %eax,(%esp)
801040d3:	e8 27 ea ff ff       	call   80102aff <kfree>
  if(*f0)
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	8b 00                	mov    (%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	74 0d                	je     801040ee <pipealloc+0x126>
    fileclose(*f0);
801040e1:	8b 45 08             	mov    0x8(%ebp),%eax
801040e4:	8b 00                	mov    (%eax),%eax
801040e6:	89 04 24             	mov    %eax,(%esp)
801040e9:	e8 fb ce ff ff       	call   80100fe9 <fileclose>
  if(*f1)
801040ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f1:	8b 00                	mov    (%eax),%eax
801040f3:	85 c0                	test   %eax,%eax
801040f5:	74 0d                	je     80104104 <pipealloc+0x13c>
    fileclose(*f1);
801040f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fa:	8b 00                	mov    (%eax),%eax
801040fc:	89 04 24             	mov    %eax,(%esp)
801040ff:	e8 e5 ce ff ff       	call   80100fe9 <fileclose>
  return -1;
80104104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104109:	c9                   	leave  
8010410a:	c3                   	ret    

8010410b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410b:	55                   	push   %ebp
8010410c:	89 e5                	mov    %esp,%ebp
8010410e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	89 04 24             	mov    %eax,(%esp)
80104117:	e8 8f 10 00 00       	call   801051ab <acquire>
  if(writable){
8010411c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104120:	74 1f                	je     80104141 <pipeclose+0x36>
    p->writeopen = 0;
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010412c:	00 00 00 
    wakeup(&p->nread);
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	05 34 02 00 00       	add    $0x234,%eax
80104137:	89 04 24             	mov    %eax,(%esp)
8010413a:	e8 7d 0c 00 00       	call   80104dbc <wakeup>
8010413f:	eb 1d                	jmp    8010415e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010414b:	00 00 00 
    wakeup(&p->nwrite);
8010414e:	8b 45 08             	mov    0x8(%ebp),%eax
80104151:	05 38 02 00 00       	add    $0x238,%eax
80104156:	89 04 24             	mov    %eax,(%esp)
80104159:	e8 5e 0c 00 00       	call   80104dbc <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010415e:	8b 45 08             	mov    0x8(%ebp),%eax
80104161:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104167:	85 c0                	test   %eax,%eax
80104169:	75 25                	jne    80104190 <pipeclose+0x85>
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104174:	85 c0                	test   %eax,%eax
80104176:	75 18                	jne    80104190 <pipeclose+0x85>
    release(&p->lock);
80104178:	8b 45 08             	mov    0x8(%ebp),%eax
8010417b:	89 04 24             	mov    %eax,(%esp)
8010417e:	e8 8a 10 00 00       	call   8010520d <release>
    kfree((char*)p);
80104183:	8b 45 08             	mov    0x8(%ebp),%eax
80104186:	89 04 24             	mov    %eax,(%esp)
80104189:	e8 71 e9 ff ff       	call   80102aff <kfree>
8010418e:	eb 0b                	jmp    8010419b <pipeclose+0x90>
  } else
    release(&p->lock);
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	89 04 24             	mov    %eax,(%esp)
80104196:	e8 72 10 00 00       	call   8010520d <release>
}
8010419b:	c9                   	leave  
8010419c:	c3                   	ret    

8010419d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010419d:	55                   	push   %ebp
8010419e:	89 e5                	mov    %esp,%ebp
801041a0:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	89 04 24             	mov    %eax,(%esp)
801041a9:	e8 fd 0f 00 00       	call   801051ab <acquire>
  for(i = 0; i < n; i++){
801041ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041b5:	e9 a6 00 00 00       	jmp    80104260 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ba:	eb 57                	jmp    80104213 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041c5:	85 c0                	test   %eax,%eax
801041c7:	74 0d                	je     801041d6 <pipewrite+0x39>
801041c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041cf:	8b 40 2c             	mov    0x2c(%eax),%eax
801041d2:	85 c0                	test   %eax,%eax
801041d4:	74 15                	je     801041eb <pipewrite+0x4e>
        release(&p->lock);
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	89 04 24             	mov    %eax,(%esp)
801041dc:	e8 2c 10 00 00       	call   8010520d <release>
        return -1;
801041e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e6:	e9 9f 00 00 00       	jmp    8010428a <pipewrite+0xed>
      }
      wakeup(&p->nread);
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	05 34 02 00 00       	add    $0x234,%eax
801041f3:	89 04 24             	mov    %eax,(%esp)
801041f6:	e8 c1 0b 00 00       	call   80104dbc <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104201:	81 c2 38 02 00 00    	add    $0x238,%edx
80104207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010420b:	89 14 24             	mov    %edx,(%esp)
8010420e:	e8 cd 0a 00 00       	call   80104ce0 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010421c:	8b 45 08             	mov    0x8(%ebp),%eax
8010421f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104225:	05 00 02 00 00       	add    $0x200,%eax
8010422a:	39 c2                	cmp    %eax,%edx
8010422c:	74 8e                	je     801041bc <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010422e:	8b 45 08             	mov    0x8(%ebp),%eax
80104231:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104237:	8d 48 01             	lea    0x1(%eax),%ecx
8010423a:	8b 55 08             	mov    0x8(%ebp),%edx
8010423d:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104243:	25 ff 01 00 00       	and    $0x1ff,%eax
80104248:	89 c1                	mov    %eax,%ecx
8010424a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010424d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104250:	01 d0                	add    %edx,%eax
80104252:	0f b6 10             	movzbl (%eax),%edx
80104255:	8b 45 08             	mov    0x8(%ebp),%eax
80104258:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010425c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104263:	3b 45 10             	cmp    0x10(%ebp),%eax
80104266:	0f 8c 4e ff ff ff    	jl     801041ba <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010426c:	8b 45 08             	mov    0x8(%ebp),%eax
8010426f:	05 34 02 00 00       	add    $0x234,%eax
80104274:	89 04 24             	mov    %eax,(%esp)
80104277:	e8 40 0b 00 00       	call   80104dbc <wakeup>
  release(&p->lock);
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	89 04 24             	mov    %eax,(%esp)
80104282:	e8 86 0f 00 00       	call   8010520d <release>
  return n;
80104287:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010428a:	c9                   	leave  
8010428b:	c3                   	ret    

8010428c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010428c:	55                   	push   %ebp
8010428d:	89 e5                	mov    %esp,%ebp
8010428f:	53                   	push   %ebx
80104290:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	89 04 24             	mov    %eax,(%esp)
80104299:	e8 0d 0f 00 00       	call   801051ab <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010429e:	eb 3a                	jmp    801042da <piperead+0x4e>
    if(proc->killed){
801042a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042a6:	8b 40 2c             	mov    0x2c(%eax),%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	74 15                	je     801042c2 <piperead+0x36>
      release(&p->lock);
801042ad:	8b 45 08             	mov    0x8(%ebp),%eax
801042b0:	89 04 24             	mov    %eax,(%esp)
801042b3:	e8 55 0f 00 00       	call   8010520d <release>
      return -1;
801042b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042bd:	e9 b5 00 00 00       	jmp    80104377 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	8b 55 08             	mov    0x8(%ebp),%edx
801042c8:	81 c2 34 02 00 00    	add    $0x234,%edx
801042ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801042d2:	89 14 24             	mov    %edx,(%esp)
801042d5:	e8 06 0a 00 00       	call   80104ce0 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042e3:	8b 45 08             	mov    0x8(%ebp),%eax
801042e6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042ec:	39 c2                	cmp    %eax,%edx
801042ee:	75 0d                	jne    801042fd <piperead+0x71>
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042f9:	85 c0                	test   %eax,%eax
801042fb:	75 a3                	jne    801042a0 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104304:	eb 4b                	jmp    80104351 <piperead+0xc5>
    if(p->nread == p->nwrite)
80104306:	8b 45 08             	mov    0x8(%ebp),%eax
80104309:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010430f:	8b 45 08             	mov    0x8(%ebp),%eax
80104312:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104318:	39 c2                	cmp    %eax,%edx
8010431a:	75 02                	jne    8010431e <piperead+0x92>
      break;
8010431c:	eb 3b                	jmp    80104359 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010431e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104321:	8b 45 0c             	mov    0xc(%ebp),%eax
80104324:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104327:	8b 45 08             	mov    0x8(%ebp),%eax
8010432a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104330:	8d 48 01             	lea    0x1(%eax),%ecx
80104333:	8b 55 08             	mov    0x8(%ebp),%edx
80104336:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010433c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104341:	89 c2                	mov    %eax,%edx
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010434b:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010434d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104354:	3b 45 10             	cmp    0x10(%ebp),%eax
80104357:	7c ad                	jl     80104306 <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104359:	8b 45 08             	mov    0x8(%ebp),%eax
8010435c:	05 38 02 00 00       	add    $0x238,%eax
80104361:	89 04 24             	mov    %eax,(%esp)
80104364:	e8 53 0a 00 00       	call   80104dbc <wakeup>
  release(&p->lock);
80104369:	8b 45 08             	mov    0x8(%ebp),%eax
8010436c:	89 04 24             	mov    %eax,(%esp)
8010436f:	e8 99 0e 00 00       	call   8010520d <release>
  return i;
80104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104377:	83 c4 24             	add    $0x24,%esp
8010437a:	5b                   	pop    %ebx
8010437b:	5d                   	pop    %ebp
8010437c:	c3                   	ret    

8010437d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010437d:	55                   	push   %ebp
8010437e:	89 e5                	mov    %esp,%ebp
80104380:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104383:	9c                   	pushf  
80104384:	58                   	pop    %eax
80104385:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104388:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010438b:	c9                   	leave  
8010438c:	c3                   	ret    

8010438d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010438d:	55                   	push   %ebp
8010438e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104390:	fb                   	sti    
}
80104391:	5d                   	pop    %ebp
80104392:	c3                   	ret    

80104393 <AddFreeList>:


////ADD TO FREE LIST
int
AddFreeList(struct proc * toadd)
{
80104393:	55                   	push   %ebp
80104394:	89 e5                	mov    %esp,%ebp
80104396:	83 ec 10             	sub    $0x10,%esp

//empty argument
if(toadd == 0)
80104399:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010439d:	75 07                	jne    801043a6 <AddFreeList+0x13>
return -1;
8010439f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a4:	eb 42                	jmp    801043e8 <AddFreeList+0x55>

///first free list process
if(ptable.pFreeList == 0)
801043a6:	a1 b8 4b 11 80       	mov    0x80114bb8,%eax
801043ab:	85 c0                	test   %eax,%eax
801043ad:	75 19                	jne    801043c8 <AddFreeList+0x35>
{
ptable.pFreeList=toadd;
801043af:	8b 45 08             	mov    0x8(%ebp),%eax
801043b2:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
toadd->next = 0;
801043b7:	8b 45 08             	mov    0x8(%ebp),%eax
801043ba:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
return 0;
801043c1:	b8 00 00 00 00       	mov    $0x0,%eax
801043c6:	eb 20                	jmp    801043e8 <AddFreeList+0x55>
}

///all other cases
struct proc * restoflist=ptable.pFreeList;
801043c8:	a1 b8 4b 11 80       	mov    0x80114bb8,%eax
801043cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
ptable.pFreeList=toadd;
801043d0:	8b 45 08             	mov    0x8(%ebp),%eax
801043d3:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
ptable.pFreeList->next=restoflist;
801043d8:	a1 b8 4b 11 80       	mov    0x80114bb8,%eax
801043dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
801043e0:	89 50 74             	mov    %edx,0x74(%eax)

return 0;
801043e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043e8:	c9                   	leave  
801043e9:	c3                   	ret    

801043ea <RemoveFreeList>:


////REMOVE FREE LIST
struct proc *
RemoveFreeList()
{
801043ea:	55                   	push   %ebp
801043eb:	89 e5                	mov    %esp,%ebp
801043ed:	83 ec 10             	sub    $0x10,%esp


///first free list process
if(ptable.pFreeList == 0)
801043f0:	a1 b8 4b 11 80       	mov    0x80114bb8,%eax
801043f5:	85 c0                	test   %eax,%eax
801043f7:	75 07                	jne    80104400 <RemoveFreeList+0x16>
return ptable.pFreeList;
801043f9:	a1 b8 4b 11 80       	mov    0x80114bb8,%eax
801043fe:	eb 18                	jmp    80104418 <RemoveFreeList+0x2e>

///all other cases
struct proc * p = ptable.pFreeList;
80104400:	a1 b8 4b 11 80       	mov    0x80114bb8,%eax
80104405:	89 45 fc             	mov    %eax,-0x4(%ebp)
ptable.pFreeList = ptable.pFreeList->next;//remove first process from list change pointer
80104408:	a1 b8 4b 11 80       	mov    0x80114bb8,%eax
8010440d:	8b 40 74             	mov    0x74(%eax),%eax
80104410:	a3 b8 4b 11 80       	mov    %eax,0x80114bb8
return p;
80104415:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104418:	c9                   	leave  
80104419:	c3                   	ret    

8010441a <pinit>:



void
pinit(void)
{
8010441a:	55                   	push   %ebp
8010441b:	89 e5                	mov    %esp,%ebp
8010441d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104420:	c7 44 24 04 ed 8b 10 	movl   $0x80108bed,0x4(%esp)
80104427:	80 
80104428:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010442f:	e8 56 0d 00 00       	call   8010518a <initlock>
}
80104434:	c9                   	leave  
80104435:	c3                   	ret    

80104436 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104436:	55                   	push   %ebp
80104437:	89 e5                	mov    %esp,%ebp
80104439:	83 ec 28             	sub    $0x28,%esp
  //struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010443c:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104443:	e8 63 0d 00 00       	call   801051ab <acquire>
  
  struct proc *p=RemoveFreeList();
80104448:	e8 9d ff ff ff       	call   801043ea <RemoveFreeList>
8010444d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  release(&ptable.lock);
80104450:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104457:	e8 b1 0d 00 00       	call   8010520d <release>
  
  if(p == 0)
8010445c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104460:	75 0a                	jne    8010446c <allocproc+0x36>
	return 0;
80104462:	b8 00 00 00 00       	mov    $0x0,%eax
80104467:	e9 c1 00 00 00       	jmp    8010452d <allocproc+0xf7>

  acquire(&ptable.lock);
8010446c:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104473:	e8 33 0d 00 00       	call   801051ab <acquire>

  p->state = EMBRYO;
80104478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104482:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104487:	8d 50 01             	lea    0x1(%eax),%edx
8010448a:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104493:	89 42 10             	mov    %eax,0x10(%edx)
  //p->gid = nextpid; 
  //p->uid = nextpid;

  release(&ptable.lock);
80104496:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010449d:	e8 6b 0d 00 00       	call   8010520d <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801044a2:	e8 f1 e6 ff ff       	call   80102b98 <kalloc>
801044a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044aa:	89 42 08             	mov    %eax,0x8(%edx)
801044ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b0:	8b 40 08             	mov    0x8(%eax),%eax
801044b3:	85 c0                	test   %eax,%eax
801044b5:	75 11                	jne    801044c8 <allocproc+0x92>
    p->state = UNUSED;
801044b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ba:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801044c1:	b8 00 00 00 00       	mov    $0x0,%eax
801044c6:	eb 65                	jmp    8010452d <allocproc+0xf7>
  }
  sp = p->kstack + KSTACKSIZE;
801044c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cb:	8b 40 08             	mov    0x8(%eax),%eax
801044ce:	05 00 10 00 00       	add    $0x1000,%eax
801044d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801044d6:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801044da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044e0:	89 50 20             	mov    %edx,0x20(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801044e3:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801044e7:	ba 44 69 10 80       	mov    $0x80106944,%edx
801044ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ef:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801044f1:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044fb:	89 50 24             	mov    %edx,0x24(%eax)
  memset(p->context, 0, sizeof *p->context);
801044fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104501:	8b 40 24             	mov    0x24(%eax),%eax
80104504:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010450b:	00 
8010450c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104513:	00 
80104514:	89 04 24             	mov    %eax,(%esp)
80104517:	e8 e3 0e 00 00       	call   801053ff <memset>
  p->context->eip = (uint)forkret;
8010451c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451f:	8b 40 24             	mov    0x24(%eax),%eax
80104522:	ba a1 4c 10 80       	mov    $0x80104ca1,%edx
80104527:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010452a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010452d:	c9                   	leave  
8010452e:	c3                   	ret    

8010452f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010452f:	55                   	push   %ebp
80104530:	89 e5                	mov    %esp,%ebp
80104532:	83 ec 28             	sub    $0x28,%esp
  struct proc* p;

  ptable.pFreeList=0;
80104535:	c7 05 b8 4b 11 80 00 	movl   $0x0,0x80114bb8
8010453c:	00 00 00 
  


acquire(&ptable.lock);
8010453f:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104546:	e8 60 0c 00 00       	call   801051ab <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010454b:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104552:	eb 1c                	jmp    80104570 <userinit+0x41>
    if(p->state == UNUSED)
80104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104557:	8b 40 0c             	mov    0xc(%eax),%eax
8010455a:	85 c0                	test   %eax,%eax
8010455c:	75 0b                	jne    80104569 <userinit+0x3a>
      {
	AddFreeList(p); //send unused process to free table to be added
8010455e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104561:	89 04 24             	mov    %eax,(%esp)
80104564:	e8 2a fe ff ff       	call   80104393 <AddFreeList>
  ptable.pFreeList=0;
  


acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104569:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104570:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104577:	72 db                	jb     80104554 <userinit+0x25>
    if(p->state == UNUSED)
      {
	AddFreeList(p); //send unused process to free table to be added
	}
  release(&ptable.lock);
80104579:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104580:	e8 88 0c 00 00       	call   8010520d <release>

  //struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104585:	e8 ac fe ff ff       	call   80104436 <allocproc>
8010458a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->uid=0;
8010458d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104590:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  p->gid=1;
80104597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459a:	c7 40 18 01 00 00 00 	movl   $0x1,0x18(%eax)

  initproc = p;
801045a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a4:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
801045a9:	e8 8a 3a 00 00       	call   80108038 <setupkvm>
801045ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b1:	89 42 04             	mov    %eax,0x4(%edx)
801045b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b7:	8b 40 04             	mov    0x4(%eax),%eax
801045ba:	85 c0                	test   %eax,%eax
801045bc:	75 0c                	jne    801045ca <userinit+0x9b>
    panic("userinit: out of memory?");
801045be:	c7 04 24 f4 8b 10 80 	movl   $0x80108bf4,(%esp)
801045c5:	e8 70 bf ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045ca:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d2:	8b 40 04             	mov    0x4(%eax),%eax
801045d5:	89 54 24 08          	mov    %edx,0x8(%esp)
801045d9:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
801045e0:	80 
801045e1:	89 04 24             	mov    %eax,(%esp)
801045e4:	e8 a7 3c 00 00       	call   80108290 <inituvm>
  p->sz = PGSIZE;
801045e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ec:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f5:	8b 40 20             	mov    0x20(%eax),%eax
801045f8:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801045ff:	00 
80104600:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104607:	00 
80104608:	89 04 24             	mov    %eax,(%esp)
8010460b:	e8 ef 0d 00 00       	call   801053ff <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	8b 40 20             	mov    0x20(%eax),%eax
80104616:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010461c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461f:	8b 40 20             	mov    0x20(%eax),%eax
80104622:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462b:	8b 40 20             	mov    0x20(%eax),%eax
8010462e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104631:	8b 52 20             	mov    0x20(%edx),%edx
80104634:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104638:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010463c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463f:	8b 40 20             	mov    0x20(%eax),%eax
80104642:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104645:	8b 52 20             	mov    0x20(%edx),%edx
80104648:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010464c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	8b 40 20             	mov    0x20(%eax),%eax
80104656:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010465d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104660:	8b 40 20             	mov    0x20(%eax),%eax
80104663:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010466a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466d:	8b 40 20             	mov    0x20(%eax),%eax
80104670:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467a:	83 c0 78             	add    $0x78,%eax
8010467d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104684:	00 
80104685:	c7 44 24 04 0d 8c 10 	movl   $0x80108c0d,0x4(%esp)
8010468c:	80 
8010468d:	89 04 24             	mov    %eax,(%esp)
80104690:	e8 8a 0f 00 00       	call   8010561f <safestrcpy>
  p->cwd = namei("/");
80104695:	c7 04 24 16 8c 10 80 	movl   $0x80108c16,(%esp)
8010469c:	e8 e4 dd ff ff       	call   80102485 <namei>
801046a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046a4:	89 42 70             	mov    %eax,0x70(%edx)

  p->state = RUNNABLE;
801046a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046aa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046b1:	c9                   	leave  
801046b2:	c3                   	ret    

801046b3 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046b3:	55                   	push   %ebp
801046b4:	89 e5                	mov    %esp,%ebp
801046b6:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801046b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bf:	8b 00                	mov    (%eax),%eax
801046c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046c8:	7e 34                	jle    801046fe <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046ca:	8b 55 08             	mov    0x8(%ebp),%edx
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	01 c2                	add    %eax,%edx
801046d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d8:	8b 40 04             	mov    0x4(%eax),%eax
801046db:	89 54 24 08          	mov    %edx,0x8(%esp)
801046df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801046e6:	89 04 24             	mov    %eax,(%esp)
801046e9:	e8 18 3d 00 00       	call   80108406 <allocuvm>
801046ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046f5:	75 41                	jne    80104738 <growproc+0x85>
      return -1;
801046f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046fc:	eb 58                	jmp    80104756 <growproc+0xa3>
  } else if(n < 0){
801046fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104702:	79 34                	jns    80104738 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104704:	8b 55 08             	mov    0x8(%ebp),%edx
80104707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470a:	01 c2                	add    %eax,%edx
8010470c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104712:	8b 40 04             	mov    0x4(%eax),%eax
80104715:	89 54 24 08          	mov    %edx,0x8(%esp)
80104719:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104720:	89 04 24             	mov    %eax,(%esp)
80104723:	e8 b8 3d 00 00       	call   801084e0 <deallocuvm>
80104728:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010472b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010472f:	75 07                	jne    80104738 <growproc+0x85>
      return -1;
80104731:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104736:	eb 1e                	jmp    80104756 <growproc+0xa3>
  }
  proc->sz = sz;
80104738:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104741:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104743:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104749:	89 04 24             	mov    %eax,(%esp)
8010474c:	e8 d8 39 00 00       	call   80108129 <switchuvm>
  return 0;
80104751:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104756:	c9                   	leave  
80104757:	c3                   	ret    

80104758 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104758:	55                   	push   %ebp
80104759:	89 e5                	mov    %esp,%ebp
8010475b:	57                   	push   %edi
8010475c:	56                   	push   %esi
8010475d:	53                   	push   %ebx
8010475e:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104761:	e8 d0 fc ff ff       	call   80104436 <allocproc>
80104766:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104769:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010476d:	75 0a                	jne    80104779 <fork+0x21>
    return -1;
8010476f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104774:	e9 6d 01 00 00       	jmp    801048e6 <fork+0x18e>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104779:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477f:	8b 10                	mov    (%eax),%edx
80104781:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104787:	8b 40 04             	mov    0x4(%eax),%eax
8010478a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010478e:	89 04 24             	mov    %eax,(%esp)
80104791:	e8 e6 3e 00 00       	call   8010867c <copyuvm>
80104796:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104799:	89 42 04             	mov    %eax,0x4(%edx)
8010479c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479f:	8b 40 04             	mov    0x4(%eax),%eax
801047a2:	85 c0                	test   %eax,%eax
801047a4:	75 2c                	jne    801047d2 <fork+0x7a>
    kfree(np->kstack);
801047a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a9:	8b 40 08             	mov    0x8(%eax),%eax
801047ac:	89 04 24             	mov    %eax,(%esp)
801047af:	e8 4b e3 ff ff       	call   80102aff <kfree>
    np->kstack = 0;
801047b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047cd:	e9 14 01 00 00       	jmp    801048e6 <fork+0x18e>
  }
  np->sz = proc->sz;
801047d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d8:	8b 10                	mov    (%eax),%edx
801047da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047dd:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047df:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e9:	89 50 1c             	mov    %edx,0x1c(%eax)
  *np->tf = *proc->tf;
801047ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ef:	8b 50 20             	mov    0x20(%eax),%edx
801047f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f8:	8b 40 20             	mov    0x20(%eax),%eax
801047fb:	89 c3                	mov    %eax,%ebx
801047fd:	b8 13 00 00 00       	mov    $0x13,%eax
80104802:	89 d7                	mov    %edx,%edi
80104804:	89 de                	mov    %ebx,%esi
80104806:	89 c1                	mov    %eax,%ecx
80104808:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

///allocating uid and gid
  np->uid = proc->uid;
8010480a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104810:	8b 50 14             	mov    0x14(%eax),%edx
80104813:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104816:	89 50 14             	mov    %edx,0x14(%eax)
  np->gid = proc->gid;
80104819:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481f:	8b 50 18             	mov    0x18(%eax),%edx
80104822:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104825:	89 50 18             	mov    %edx,0x18(%eax)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104828:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482b:	8b 40 20             	mov    0x20(%eax),%eax
8010482e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104835:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010483c:	eb 3a                	jmp    80104878 <fork+0x120>
    if(proc->ofile[i])
8010483e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104844:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104847:	83 c2 0c             	add    $0xc,%edx
8010484a:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010484d:	85 c0                	test   %eax,%eax
8010484f:	74 23                	je     80104874 <fork+0x11c>
      np->ofile[i] = filedup(proc->ofile[i]);
80104851:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104857:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010485a:	83 c2 0c             	add    $0xc,%edx
8010485d:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104860:	89 04 24             	mov    %eax,(%esp)
80104863:	e8 39 c7 ff ff       	call   80100fa1 <filedup>
80104868:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010486b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010486e:	83 c1 0c             	add    $0xc,%ecx
80104871:	89 04 8a             	mov    %eax,(%edx,%ecx,4)


  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104874:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104878:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010487c:	7e c0                	jle    8010483e <fork+0xe6>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010487e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104884:	8b 40 70             	mov    0x70(%eax),%eax
80104887:	89 04 24             	mov    %eax,(%esp)
8010488a:	e8 13 d0 ff ff       	call   801018a2 <idup>
8010488f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104892:	89 42 70             	mov    %eax,0x70(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104895:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489b:	8d 50 78             	lea    0x78(%eax),%edx
8010489e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a1:	83 c0 78             	add    $0x78,%eax
801048a4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801048ab:	00 
801048ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801048b0:	89 04 24             	mov    %eax,(%esp)
801048b3:	e8 67 0d 00 00       	call   8010561f <safestrcpy>
 
  pid = np->pid;
801048b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048bb:	8b 40 10             	mov    0x10(%eax),%eax
801048be:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048c1:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801048c8:	e8 de 08 00 00       	call   801051ab <acquire>
  np->state = RUNNABLE;
801048cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048d7:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
801048de:	e8 2a 09 00 00       	call   8010520d <release>
  
  return pid;
801048e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048e6:	83 c4 2c             	add    $0x2c,%esp
801048e9:	5b                   	pop    %ebx
801048ea:	5e                   	pop    %esi
801048eb:	5f                   	pop    %edi
801048ec:	5d                   	pop    %ebp
801048ed:	c3                   	ret    

801048ee <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048ee:	55                   	push   %ebp
801048ef:	89 e5                	mov    %esp,%ebp
801048f1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048f4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048fb:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104900:	39 c2                	cmp    %eax,%edx
80104902:	75 0c                	jne    80104910 <exit+0x22>
    panic("init exiting");
80104904:	c7 04 24 18 8c 10 80 	movl   $0x80108c18,(%esp)
8010490b:	e8 2a bc ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104910:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104917:	eb 41                	jmp    8010495a <exit+0x6c>
    if(proc->ofile[fd]){
80104919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104922:	83 c2 0c             	add    $0xc,%edx
80104925:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104928:	85 c0                	test   %eax,%eax
8010492a:	74 2a                	je     80104956 <exit+0x68>
      fileclose(proc->ofile[fd]);
8010492c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104932:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104935:	83 c2 0c             	add    $0xc,%edx
80104938:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010493b:	89 04 24             	mov    %eax,(%esp)
8010493e:	e8 a6 c6 ff ff       	call   80100fe9 <fileclose>
      proc->ofile[fd] = 0;
80104943:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104949:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494c:	83 c2 0c             	add    $0xc,%edx
8010494f:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104956:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010495a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010495e:	7e b9                	jle    80104919 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104960:	e8 57 eb ff ff       	call   801034bc <begin_op>
  iput(proc->cwd);
80104965:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496b:	8b 40 70             	mov    0x70(%eax),%eax
8010496e:	89 04 24             	mov    %eax,(%esp)
80104971:	e8 17 d1 ff ff       	call   80101a8d <iput>
  end_op();
80104976:	e8 c5 eb ff ff       	call   80103540 <end_op>
  proc->cwd = 0;
8010497b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104981:	c7 40 70 00 00 00 00 	movl   $0x0,0x70(%eax)

  acquire(&ptable.lock);
80104988:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
8010498f:	e8 17 08 00 00       	call   801051ab <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104994:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010499d:	89 04 24             	mov    %eax,(%esp)
801049a0:	e8 d6 03 00 00       	call   80104d7b <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049a5:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
801049ac:	eb 3b                	jmp    801049e9 <exit+0xfb>
    if(p->parent == proc){
801049ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b1:	8b 50 1c             	mov    0x1c(%eax),%edx
801049b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ba:	39 c2                	cmp    %eax,%edx
801049bc:	75 24                	jne    801049e2 <exit+0xf4>
      p->parent = initproc;
801049be:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
801049c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c7:	89 50 1c             	mov    %edx,0x1c(%eax)
      if(p->state == ZOMBIE)
801049ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049cd:	8b 40 0c             	mov    0xc(%eax),%eax
801049d0:	83 f8 05             	cmp    $0x5,%eax
801049d3:	75 0d                	jne    801049e2 <exit+0xf4>
        wakeup1(initproc);
801049d5:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801049da:	89 04 24             	mov    %eax,(%esp)
801049dd:	e8 99 03 00 00       	call   80104d7b <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e2:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801049e9:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
801049f0:	72 bc                	jb     801049ae <exit+0xc0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801049f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801049ff:	e8 b9 01 00 00       	call   80104bbd <sched>
  panic("zombie exit");
80104a04:	c7 04 24 25 8c 10 80 	movl   $0x80108c25,(%esp)
80104a0b:	e8 2a bb ff ff       	call   8010053a <panic>

80104a10 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
80104a13:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a16:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104a1d:	e8 89 07 00 00       	call   801051ab <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a29:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104a30:	e9 9d 00 00 00       	jmp    80104ad2 <wait+0xc2>
      if(p->parent != proc)
80104a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a38:	8b 50 1c             	mov    0x1c(%eax),%edx
80104a3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a41:	39 c2                	cmp    %eax,%edx
80104a43:	74 05                	je     80104a4a <wait+0x3a>
        continue;
80104a45:	e9 81 00 00 00       	jmp    80104acb <wait+0xbb>
      havekids = 1;
80104a4a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a54:	8b 40 0c             	mov    0xc(%eax),%eax
80104a57:	83 f8 05             	cmp    $0x5,%eax
80104a5a:	75 6f                	jne    80104acb <wait+0xbb>
        // Found one.
        pid = p->pid;
80104a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5f:	8b 40 10             	mov    0x10(%eax),%eax
80104a62:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a68:	8b 40 08             	mov    0x8(%eax),%eax
80104a6b:	89 04 24             	mov    %eax,(%esp)
80104a6e:	e8 8c e0 ff ff       	call   80102aff <kfree>
        p->kstack = 0;
80104a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a80:	8b 40 04             	mov    0x4(%eax),%eax
80104a83:	89 04 24             	mov    %eax,(%esp)
80104a86:	e8 11 3b 00 00       	call   8010859c <freevm>
        p->state = UNUSED;
80104a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        p->name[0] = 0;
80104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aac:	c6 40 78 00          	movb   $0x0,0x78(%eax)
        p->killed = 0;
80104ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab3:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%eax)
        release(&ptable.lock);
80104aba:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104ac1:	e8 47 07 00 00       	call   8010520d <release>
        return pid;
80104ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ac9:	eb 55                	jmp    80104b20 <wait+0x110>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104acb:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104ad2:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104ad9:	0f 82 56 ff ff ff    	jb     80104a35 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104adf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ae3:	74 0d                	je     80104af2 <wait+0xe2>
80104ae5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aeb:	8b 40 2c             	mov    0x2c(%eax),%eax
80104aee:	85 c0                	test   %eax,%eax
80104af0:	74 13                	je     80104b05 <wait+0xf5>
      release(&ptable.lock);
80104af2:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104af9:	e8 0f 07 00 00       	call   8010520d <release>
      return -1;
80104afe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b03:	eb 1b                	jmp    80104b20 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b0b:	c7 44 24 04 80 29 11 	movl   $0x80112980,0x4(%esp)
80104b12:	80 
80104b13:	89 04 24             	mov    %eax,(%esp)
80104b16:	e8 c5 01 00 00       	call   80104ce0 <sleep>
  }
80104b1b:	e9 02 ff ff ff       	jmp    80104a22 <wait+0x12>
}
80104b20:	c9                   	leave  
80104b21:	c3                   	ret    

80104b22 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b22:	55                   	push   %ebp
80104b23:	89 e5                	mov    %esp,%ebp
80104b25:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b28:	e8 60 f8 ff ff       	call   8010438d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b2d:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104b34:	e8 72 06 00 00       	call   801051ab <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b39:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104b40:	eb 61                	jmp    80104ba3 <scheduler+0x81>
      if(p->state != RUNNABLE)
80104b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b45:	8b 40 0c             	mov    0xc(%eax),%eax
80104b48:	83 f8 03             	cmp    $0x3,%eax
80104b4b:	74 02                	je     80104b4f <scheduler+0x2d>
        continue;
80104b4d:	eb 4d                	jmp    80104b9c <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b52:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5b:	89 04 24             	mov    %eax,(%esp)
80104b5e:	e8 c6 35 00 00       	call   80108129 <switchuvm>
      p->state = RUNNING;
80104b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b66:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104b6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b73:	8b 40 24             	mov    0x24(%eax),%eax
80104b76:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b7d:	83 c2 04             	add    $0x4,%edx
80104b80:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b84:	89 14 24             	mov    %edx,(%esp)
80104b87:	e8 04 0b 00 00       	call   80105690 <swtch>
      switchkvm();
80104b8c:	e8 7b 35 00 00       	call   8010810c <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104b91:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104b98:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b9c:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104ba3:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104baa:	72 96                	jb     80104b42 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104bac:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104bb3:	e8 55 06 00 00       	call   8010520d <release>

  }
80104bb8:	e9 6b ff ff ff       	jmp    80104b28 <scheduler+0x6>

80104bbd <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104bbd:	55                   	push   %ebp
80104bbe:	89 e5                	mov    %esp,%ebp
80104bc0:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104bc3:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104bca:	e8 06 07 00 00       	call   801052d5 <holding>
80104bcf:	85 c0                	test   %eax,%eax
80104bd1:	75 0c                	jne    80104bdf <sched+0x22>
    panic("sched ptable.lock");
80104bd3:	c7 04 24 31 8c 10 80 	movl   $0x80108c31,(%esp)
80104bda:	e8 5b b9 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104bdf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104be5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104beb:	83 f8 01             	cmp    $0x1,%eax
80104bee:	74 0c                	je     80104bfc <sched+0x3f>
    panic("sched locks");
80104bf0:	c7 04 24 43 8c 10 80 	movl   $0x80108c43,(%esp)
80104bf7:	e8 3e b9 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104bfc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c02:	8b 40 0c             	mov    0xc(%eax),%eax
80104c05:	83 f8 04             	cmp    $0x4,%eax
80104c08:	75 0c                	jne    80104c16 <sched+0x59>
    panic("sched running");
80104c0a:	c7 04 24 4f 8c 10 80 	movl   $0x80108c4f,(%esp)
80104c11:	e8 24 b9 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104c16:	e8 62 f7 ff ff       	call   8010437d <readeflags>
80104c1b:	25 00 02 00 00       	and    $0x200,%eax
80104c20:	85 c0                	test   %eax,%eax
80104c22:	74 0c                	je     80104c30 <sched+0x73>
    panic("sched interruptible");
80104c24:	c7 04 24 5d 8c 10 80 	movl   $0x80108c5d,(%esp)
80104c2b:	e8 0a b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104c30:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c36:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c3f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c45:	8b 40 04             	mov    0x4(%eax),%eax
80104c48:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c4f:	83 c2 24             	add    $0x24,%edx
80104c52:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c56:	89 14 24             	mov    %edx,(%esp)
80104c59:	e8 32 0a 00 00       	call   80105690 <swtch>
  cpu->intena = intena;
80104c5e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c67:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104c6d:	c9                   	leave  
80104c6e:	c3                   	ret    

80104c6f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104c6f:	55                   	push   %ebp
80104c70:	89 e5                	mov    %esp,%ebp
80104c72:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104c75:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104c7c:	e8 2a 05 00 00       	call   801051ab <acquire>
  proc->state = RUNNABLE;
80104c81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c87:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c8e:	e8 2a ff ff ff       	call   80104bbd <sched>
  release(&ptable.lock);
80104c93:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104c9a:	e8 6e 05 00 00       	call   8010520d <release>
}
80104c9f:	c9                   	leave  
80104ca0:	c3                   	ret    

80104ca1 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ca1:	55                   	push   %ebp
80104ca2:	89 e5                	mov    %esp,%ebp
80104ca4:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ca7:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104cae:	e8 5a 05 00 00       	call   8010520d <release>

  if (first) {
80104cb3:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104cb8:	85 c0                	test   %eax,%eax
80104cba:	74 22                	je     80104cde <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104cbc:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104cc3:	00 00 00 
    iinit(ROOTDEV);
80104cc6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ccd:	e8 da c8 ff ff       	call   801015ac <iinit>
    initlog(ROOTDEV);
80104cd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104cd9:	e8 da e5 ff ff       	call   801032b8 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104cde:	c9                   	leave  
80104cdf:	c3                   	ret    

80104ce0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
80104ce3:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104ce6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cec:	85 c0                	test   %eax,%eax
80104cee:	75 0c                	jne    80104cfc <sleep+0x1c>
    panic("sleep");
80104cf0:	c7 04 24 71 8c 10 80 	movl   $0x80108c71,(%esp)
80104cf7:	e8 3e b8 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104cfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d00:	75 0c                	jne    80104d0e <sleep+0x2e>
    panic("sleep without lk");
80104d02:	c7 04 24 77 8c 10 80 	movl   $0x80108c77,(%esp)
80104d09:	e8 2c b8 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d0e:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104d15:	74 17                	je     80104d2e <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d17:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d1e:	e8 88 04 00 00       	call   801051ab <acquire>
    release(lk);
80104d23:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d26:	89 04 24             	mov    %eax,(%esp)
80104d29:	e8 df 04 00 00       	call   8010520d <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104d2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d34:	8b 55 08             	mov    0x8(%ebp),%edx
80104d37:	89 50 28             	mov    %edx,0x28(%eax)
  proc->state = SLEEPING;
80104d3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d40:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104d47:	e8 71 fe ff ff       	call   80104bbd <sched>

  // Tidy up.
  proc->chan = 0;
80104d4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d52:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104d59:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104d60:	74 17                	je     80104d79 <sleep+0x99>
    release(&ptable.lock);
80104d62:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104d69:	e8 9f 04 00 00       	call   8010520d <release>
    acquire(lk);
80104d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d71:	89 04 24             	mov    %eax,(%esp)
80104d74:	e8 32 04 00 00       	call   801051ab <acquire>
  }
}
80104d79:	c9                   	leave  
80104d7a:	c3                   	ret    

80104d7b <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104d7b:	55                   	push   %ebp
80104d7c:	89 e5                	mov    %esp,%ebp
80104d7e:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d81:	c7 45 fc b4 29 11 80 	movl   $0x801129b4,-0x4(%ebp)
80104d88:	eb 27                	jmp    80104db1 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104d8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d90:	83 f8 02             	cmp    $0x2,%eax
80104d93:	75 15                	jne    80104daa <wakeup1+0x2f>
80104d95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d98:	8b 40 28             	mov    0x28(%eax),%eax
80104d9b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d9e:	75 0a                	jne    80104daa <wakeup1+0x2f>
      p->state = RUNNABLE;
80104da0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104da3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104daa:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104db1:	81 7d fc b4 4b 11 80 	cmpl   $0x80114bb4,-0x4(%ebp)
80104db8:	72 d0                	jb     80104d8a <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104dba:	c9                   	leave  
80104dbb:	c3                   	ret    

80104dbc <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104dc2:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104dc9:	e8 dd 03 00 00       	call   801051ab <acquire>
  wakeup1(chan);
80104dce:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd1:	89 04 24             	mov    %eax,(%esp)
80104dd4:	e8 a2 ff ff ff       	call   80104d7b <wakeup1>
  release(&ptable.lock);
80104dd9:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104de0:	e8 28 04 00 00       	call   8010520d <release>
}
80104de5:	c9                   	leave  
80104de6:	c3                   	ret    

80104de7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104de7:	55                   	push   %ebp
80104de8:	89 e5                	mov    %esp,%ebp
80104dea:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ded:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104df4:	e8 b2 03 00 00       	call   801051ab <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104df9:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104e00:	eb 44                	jmp    80104e46 <kill+0x5f>
    if(p->pid == pid){
80104e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e05:	8b 40 10             	mov    0x10(%eax),%eax
80104e08:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e0b:	75 32                	jne    80104e3f <kill+0x58>
      p->killed = 1;
80104e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e10:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1a:	8b 40 0c             	mov    0xc(%eax),%eax
80104e1d:	83 f8 02             	cmp    $0x2,%eax
80104e20:	75 0a                	jne    80104e2c <kill+0x45>
        p->state = RUNNABLE;
80104e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e25:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e2c:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104e33:	e8 d5 03 00 00       	call   8010520d <release>
      return 0;
80104e38:	b8 00 00 00 00       	mov    $0x0,%eax
80104e3d:	eb 21                	jmp    80104e60 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e3f:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104e46:	81 7d f4 b4 4b 11 80 	cmpl   $0x80114bb4,-0xc(%ebp)
80104e4d:	72 b3                	jb     80104e02 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104e4f:	c7 04 24 80 29 11 80 	movl   $0x80112980,(%esp)
80104e56:	e8 b2 03 00 00       	call   8010520d <release>
  return -1;
80104e5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e60:	c9                   	leave  
80104e61:	c3                   	ret    

80104e62 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104e62:	55                   	push   %ebp
80104e63:	89 e5                	mov    %esp,%ebp
80104e65:	53                   	push   %ebx
80104e66:	83 ec 64             	sub    $0x64,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e69:	c7 45 f0 b4 29 11 80 	movl   $0x801129b4,-0x10(%ebp)
80104e70:	e9 ed 00 00 00       	jmp    80104f62 <procdump+0x100>
    if(p->state == UNUSED)
80104e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e78:	8b 40 0c             	mov    0xc(%eax),%eax
80104e7b:	85 c0                	test   %eax,%eax
80104e7d:	75 05                	jne    80104e84 <procdump+0x22>
      continue;
80104e7f:	e9 d7 00 00 00       	jmp    80104f5b <procdump+0xf9>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e87:	8b 40 0c             	mov    0xc(%eax),%eax
80104e8a:	83 f8 05             	cmp    $0x5,%eax
80104e8d:	77 23                	ja     80104eb2 <procdump+0x50>
80104e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e92:	8b 40 0c             	mov    0xc(%eax),%eax
80104e95:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104e9c:	85 c0                	test   %eax,%eax
80104e9e:	74 12                	je     80104eb2 <procdump+0x50>
      state = states[p->state];
80104ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea6:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104ead:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104eb0:	eb 07                	jmp    80104eb9 <procdump+0x57>
    else
      state = "???";
80104eb2:	c7 45 ec 88 8c 10 80 	movl   $0x80108c88,-0x14(%ebp)
    cprintf("%d %d %d %s %s", p->pid, p->uid, p->gid, state, p->name);
80104eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ebc:	8d 58 78             	lea    0x78(%eax),%ebx
80104ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec2:	8b 48 18             	mov    0x18(%eax),%ecx
80104ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec8:	8b 50 14             	mov    0x14(%eax),%edx
80104ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ece:	8b 40 10             	mov    0x10(%eax),%eax
80104ed1:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80104ed5:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80104ed8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80104edc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80104ee0:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ee8:	c7 04 24 8c 8c 10 80 	movl   $0x80108c8c,(%esp)
80104eef:	e8 ac b4 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef7:	8b 40 0c             	mov    0xc(%eax),%eax
80104efa:	83 f8 02             	cmp    $0x2,%eax
80104efd:	75 50                	jne    80104f4f <procdump+0xed>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f02:	8b 40 24             	mov    0x24(%eax),%eax
80104f05:	8b 40 0c             	mov    0xc(%eax),%eax
80104f08:	83 c0 08             	add    $0x8,%eax
80104f0b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f12:	89 04 24             	mov    %eax,(%esp)
80104f15:	e8 42 03 00 00       	call   8010525c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104f1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f21:	eb 1b                	jmp    80104f3e <procdump+0xdc>
        cprintf(" %p", pc[i]);
80104f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f26:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f2e:	c7 04 24 9b 8c 10 80 	movl   $0x80108c9b,(%esp)
80104f35:	e8 66 b4 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %d %d %s %s", p->pid, p->uid, p->gid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f3e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f42:	7f 0b                	jg     80104f4f <procdump+0xed>
80104f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f47:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f4b:	85 c0                	test   %eax,%eax
80104f4d:	75 d4                	jne    80104f23 <procdump+0xc1>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f4f:	c7 04 24 9f 8c 10 80 	movl   $0x80108c9f,(%esp)
80104f56:	e8 45 b4 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f5b:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80104f62:	81 7d f0 b4 4b 11 80 	cmpl   $0x80114bb4,-0x10(%ebp)
80104f69:	0f 82 06 ff ff ff    	jb     80104e75 <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104f6f:	83 c4 64             	add    $0x64,%esp
80104f72:	5b                   	pop    %ebx
80104f73:	5d                   	pop    %ebp
80104f74:	c3                   	ret    

80104f75 <getProcInfo>:


int
getProcInfo(int max,struct uproc *table)
{
80104f75:	55                   	push   %ebp
80104f76:	89 e5                	mov    %esp,%ebp
80104f78:	83 ec 40             	sub    $0x40,%esp
struct proc *p;

int numproc=0;
80104f7b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f82:	c7 45 fc b4 29 11 80 	movl   $0x801129b4,-0x4(%ebp)
80104f89:	eb 17                	jmp    80104fa2 <getProcInfo+0x2d>
    if(p->state == UNUSED)
80104f8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f8e:	8b 40 0c             	mov    0xc(%eax),%eax
80104f91:	85 c0                	test   %eax,%eax
80104f93:	75 02                	jne    80104f97 <getProcInfo+0x22>
      continue;
80104f95:	eb 04                	jmp    80104f9b <getProcInfo+0x26>
numproc++;
80104f97:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
getProcInfo(int max,struct uproc *table)
{
struct proc *p;

int numproc=0;
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f9b:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104fa2:	81 7d fc b4 4b 11 80 	cmpl   $0x80114bb4,-0x4(%ebp)
80104fa9:	72 e0                	jb     80104f8b <getProcInfo+0x16>
numproc++;
}



int i=numproc;
80104fab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fae:	89 45 e8             	mov    %eax,-0x18(%ebp)
int l=0;
80104fb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
while(l < i)
80104fb8:	e9 86 01 00 00       	jmp    80105143 <getProcInfo+0x1ce>
{

int z=0;
80104fbd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
int sn=sizeof(ptable.proc[l].name);
80104fc4:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%ebp)
while(z < sn)
80104fcb:	eb 36                	jmp    80105003 <getProcInfo+0x8e>
{
table[l].name[z]=ptable.proc[l].name[z];
80104fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd0:	6b d0 34             	imul   $0x34,%eax,%edx
80104fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80104fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdc:	c1 e0 03             	shl    $0x3,%eax
80104fdf:	89 c2                	mov    %eax,%edx
80104fe1:	c1 e2 04             	shl    $0x4,%edx
80104fe4:	01 d0                	add    %edx,%eax
80104fe6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fe9:	01 d0                	add    %edx,%eax
80104feb:	05 20 2a 11 80       	add    $0x80112a20,%eax
80104ff0:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80104ff4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ff7:	01 ca                	add    %ecx,%edx
80104ff9:	83 c2 20             	add    $0x20,%edx
80104ffc:	88 42 04             	mov    %al,0x4(%edx)
//table[l].state[z]=ptable.proc[l].name[z];
z++;
80104fff:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
while(l < i)
{

int z=0;
int sn=sizeof(ptable.proc[l].name);
while(z < sn)
80105003:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105006:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80105009:	7c c2                	jl     80104fcd <getProcInfo+0x58>
{
table[l].name[z]=ptable.proc[l].name[z];
//table[l].state[z]=ptable.proc[l].name[z];
z++;
}
char *statelist[] = {"UNUSED  ","EMBRYO  ","SLEEPING","RUNNABLE","RUNNING ","ZOMBIE  "};
8010500b:	c7 45 c4 a1 8c 10 80 	movl   $0x80108ca1,-0x3c(%ebp)
80105012:	c7 45 c8 aa 8c 10 80 	movl   $0x80108caa,-0x38(%ebp)
80105019:	c7 45 cc b3 8c 10 80 	movl   $0x80108cb3,-0x34(%ebp)
80105020:	c7 45 d0 bc 8c 10 80 	movl   $0x80108cbc,-0x30(%ebp)
80105027:	c7 45 d4 c5 8c 10 80 	movl   $0x80108cc5,-0x2c(%ebp)
8010502e:	c7 45 d8 ce 8c 10 80 	movl   $0x80108cce,-0x28(%ebp)

int s=(int) ptable.proc[l].state;
80105035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105038:	c1 e0 03             	shl    $0x3,%eax
8010503b:	89 c2                	mov    %eax,%edx
8010503d:	c1 e2 04             	shl    $0x4,%edx
80105040:	01 d0                	add    %edx,%eax
80105042:	05 b0 29 11 80       	add    $0x801129b0,%eax
80105047:	8b 40 10             	mov    0x10(%eax),%eax
8010504a:	89 45 e0             	mov    %eax,-0x20(%ebp)
//int ssize=sizeof(*statelist[s]);
int ssize=8;
8010504d:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
int ss=0;
80105054:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
while(ss < ssize)
8010505b:	eb 29                	jmp    80105086 <getProcInfo+0x111>
{
table[l].state[ss]=statelist[s][ss];
8010505d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105060:	6b d0 34             	imul   $0x34,%eax,%edx
80105063:	8b 45 0c             	mov    0xc(%ebp),%eax
80105066:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80105069:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010506c:	8b 54 85 c4          	mov    -0x3c(%ebp,%eax,4),%edx
80105070:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105073:	01 d0                	add    %edx,%eax
80105075:	0f b6 00             	movzbl (%eax),%eax
80105078:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010507b:	01 ca                	add    %ecx,%edx
8010507d:	83 c2 10             	add    $0x10,%edx
80105080:	88 02                	mov    %al,(%edx)
ss++;
80105082:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)

int s=(int) ptable.proc[l].state;
//int ssize=sizeof(*statelist[s]);
int ssize=8;
int ss=0;
while(ss < ssize)
80105086:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105089:	3b 45 dc             	cmp    -0x24(%ebp),%eax
8010508c:	7c cf                	jl     8010505d <getProcInfo+0xe8>
table[l].state[ss]=statelist[s][ss];
ss++;
}


table[l].pid = ptable.proc[l].pid;
8010508e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105091:	6b d0 34             	imul   $0x34,%eax,%edx
80105094:	8b 45 0c             	mov    0xc(%ebp),%eax
80105097:	01 c2                	add    %eax,%edx
80105099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509c:	c1 e0 03             	shl    $0x3,%eax
8010509f:	89 c1                	mov    %eax,%ecx
801050a1:	c1 e1 04             	shl    $0x4,%ecx
801050a4:	01 c8                	add    %ecx,%eax
801050a6:	05 c0 29 11 80       	add    $0x801129c0,%eax
801050ab:	8b 40 04             	mov    0x4(%eax),%eax
801050ae:	89 02                	mov    %eax,(%edx)
table[l].uid = ptable.proc[l].uid;
801050b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b3:	6b d0 34             	imul   $0x34,%eax,%edx
801050b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b9:	01 c2                	add    %eax,%edx
801050bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050be:	c1 e0 03             	shl    $0x3,%eax
801050c1:	89 c1                	mov    %eax,%ecx
801050c3:	c1 e1 04             	shl    $0x4,%ecx
801050c6:	01 c8                	add    %ecx,%eax
801050c8:	05 c0 29 11 80       	add    $0x801129c0,%eax
801050cd:	8b 40 08             	mov    0x8(%eax),%eax
801050d0:	89 42 04             	mov    %eax,0x4(%edx)
table[l].gid = ptable.proc[l].gid;
801050d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d6:	6b d0 34             	imul   $0x34,%eax,%edx
801050d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050dc:	01 c2                	add    %eax,%edx
801050de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e1:	c1 e0 03             	shl    $0x3,%eax
801050e4:	89 c1                	mov    %eax,%ecx
801050e6:	c1 e1 04             	shl    $0x4,%ecx
801050e9:	01 c8                	add    %ecx,%eax
801050eb:	05 c0 29 11 80       	add    $0x801129c0,%eax
801050f0:	8b 40 0c             	mov    0xc(%eax),%eax
801050f3:	89 42 08             	mov    %eax,0x8(%edx)
table[l].ppid = ptable.proc[l].parent->pid;
801050f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f9:	6b d0 34             	imul   $0x34,%eax,%edx
801050fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ff:	01 c2                	add    %eax,%edx
80105101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105104:	c1 e0 03             	shl    $0x3,%eax
80105107:	89 c1                	mov    %eax,%ecx
80105109:	c1 e1 04             	shl    $0x4,%ecx
8010510c:	01 c8                	add    %ecx,%eax
8010510e:	05 c0 29 11 80       	add    $0x801129c0,%eax
80105113:	8b 40 10             	mov    0x10(%eax),%eax
80105116:	8b 40 10             	mov    0x10(%eax),%eax
80105119:	89 42 0c             	mov    %eax,0xc(%edx)
table[l].size = ptable.proc[l].sz;
8010511c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511f:	6b d0 34             	imul   $0x34,%eax,%edx
80105122:	8b 45 0c             	mov    0xc(%ebp),%eax
80105125:	01 c2                	add    %eax,%edx
80105127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512a:	c1 e0 03             	shl    $0x3,%eax
8010512d:	89 c1                	mov    %eax,%ecx
8010512f:	c1 e1 04             	shl    $0x4,%ecx
80105132:	01 c8                	add    %ecx,%eax
80105134:	05 b0 29 11 80       	add    $0x801129b0,%eax
80105139:	8b 40 04             	mov    0x4(%eax),%eax
8010513c:	89 42 20             	mov    %eax,0x20(%edx)


l++;
8010513f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)



int i=numproc;
int l=0;
while(l < i)
80105143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105146:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80105149:	0f 8c 6e fe ff ff    	jl     80104fbd <getProcInfo+0x48>


l++;
}

return i;
8010514f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105152:	c9                   	leave  
80105153:	c3                   	ret    

80105154 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105154:	55                   	push   %ebp
80105155:	89 e5                	mov    %esp,%ebp
80105157:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010515a:	9c                   	pushf  
8010515b:	58                   	pop    %eax
8010515c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010515f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105162:	c9                   	leave  
80105163:	c3                   	ret    

80105164 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105164:	55                   	push   %ebp
80105165:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105167:	fa                   	cli    
}
80105168:	5d                   	pop    %ebp
80105169:	c3                   	ret    

8010516a <sti>:

static inline void
sti(void)
{
8010516a:	55                   	push   %ebp
8010516b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010516d:	fb                   	sti    
}
8010516e:	5d                   	pop    %ebp
8010516f:	c3                   	ret    

80105170 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105170:	55                   	push   %ebp
80105171:	89 e5                	mov    %esp,%ebp
80105173:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105176:	8b 55 08             	mov    0x8(%ebp),%edx
80105179:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010517f:	f0 87 02             	lock xchg %eax,(%edx)
80105182:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105185:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105188:	c9                   	leave  
80105189:	c3                   	ret    

8010518a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010518d:	8b 45 08             	mov    0x8(%ebp),%eax
80105190:	8b 55 0c             	mov    0xc(%ebp),%edx
80105193:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105196:	8b 45 08             	mov    0x8(%ebp),%eax
80105199:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010519f:	8b 45 08             	mov    0x8(%ebp),%eax
801051a2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051a9:	5d                   	pop    %ebp
801051aa:	c3                   	ret    

801051ab <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051ab:	55                   	push   %ebp
801051ac:	89 e5                	mov    %esp,%ebp
801051ae:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051b1:	e8 49 01 00 00       	call   801052ff <pushcli>
  if(holding(lk))
801051b6:	8b 45 08             	mov    0x8(%ebp),%eax
801051b9:	89 04 24             	mov    %eax,(%esp)
801051bc:	e8 14 01 00 00       	call   801052d5 <holding>
801051c1:	85 c0                	test   %eax,%eax
801051c3:	74 0c                	je     801051d1 <acquire+0x26>
    panic("acquire");
801051c5:	c7 04 24 01 8d 10 80 	movl   $0x80108d01,(%esp)
801051cc:	e8 69 b3 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801051d1:	90                   	nop
801051d2:	8b 45 08             	mov    0x8(%ebp),%eax
801051d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051dc:	00 
801051dd:	89 04 24             	mov    %eax,(%esp)
801051e0:	e8 8b ff ff ff       	call   80105170 <xchg>
801051e5:	85 c0                	test   %eax,%eax
801051e7:	75 e9                	jne    801051d2 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801051e9:	8b 45 08             	mov    0x8(%ebp),%eax
801051ec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051f3:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801051f6:	8b 45 08             	mov    0x8(%ebp),%eax
801051f9:	83 c0 0c             	add    $0xc,%eax
801051fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105200:	8d 45 08             	lea    0x8(%ebp),%eax
80105203:	89 04 24             	mov    %eax,(%esp)
80105206:	e8 51 00 00 00       	call   8010525c <getcallerpcs>
}
8010520b:	c9                   	leave  
8010520c:	c3                   	ret    

8010520d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010520d:	55                   	push   %ebp
8010520e:	89 e5                	mov    %esp,%ebp
80105210:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105213:	8b 45 08             	mov    0x8(%ebp),%eax
80105216:	89 04 24             	mov    %eax,(%esp)
80105219:	e8 b7 00 00 00       	call   801052d5 <holding>
8010521e:	85 c0                	test   %eax,%eax
80105220:	75 0c                	jne    8010522e <release+0x21>
    panic("release");
80105222:	c7 04 24 09 8d 10 80 	movl   $0x80108d09,(%esp)
80105229:	e8 0c b3 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
8010522e:	8b 45 08             	mov    0x8(%ebp),%eax
80105231:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105238:	8b 45 08             	mov    0x8(%ebp),%eax
8010523b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105242:	8b 45 08             	mov    0x8(%ebp),%eax
80105245:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010524c:	00 
8010524d:	89 04 24             	mov    %eax,(%esp)
80105250:	e8 1b ff ff ff       	call   80105170 <xchg>

  popcli();
80105255:	e8 e9 00 00 00       	call   80105343 <popcli>
}
8010525a:	c9                   	leave  
8010525b:	c3                   	ret    

8010525c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
8010525f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105262:	8b 45 08             	mov    0x8(%ebp),%eax
80105265:	83 e8 08             	sub    $0x8,%eax
80105268:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010526b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105272:	eb 38                	jmp    801052ac <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105274:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105278:	74 38                	je     801052b2 <getcallerpcs+0x56>
8010527a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105281:	76 2f                	jbe    801052b2 <getcallerpcs+0x56>
80105283:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105287:	74 29                	je     801052b2 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105289:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010528c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105293:	8b 45 0c             	mov    0xc(%ebp),%eax
80105296:	01 c2                	add    %eax,%edx
80105298:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010529b:	8b 40 04             	mov    0x4(%eax),%eax
8010529e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052a3:	8b 00                	mov    (%eax),%eax
801052a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801052a8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052ac:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052b0:	7e c2                	jle    80105274 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052b2:	eb 19                	jmp    801052cd <getcallerpcs+0x71>
    pcs[i] = 0;
801052b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052be:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c1:	01 d0                	add    %edx,%eax
801052c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052c9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052cd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052d1:	7e e1                	jle    801052b4 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801052d3:	c9                   	leave  
801052d4:	c3                   	ret    

801052d5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052d5:	55                   	push   %ebp
801052d6:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801052d8:	8b 45 08             	mov    0x8(%ebp),%eax
801052db:	8b 00                	mov    (%eax),%eax
801052dd:	85 c0                	test   %eax,%eax
801052df:	74 17                	je     801052f8 <holding+0x23>
801052e1:	8b 45 08             	mov    0x8(%ebp),%eax
801052e4:	8b 50 08             	mov    0x8(%eax),%edx
801052e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052ed:	39 c2                	cmp    %eax,%edx
801052ef:	75 07                	jne    801052f8 <holding+0x23>
801052f1:	b8 01 00 00 00       	mov    $0x1,%eax
801052f6:	eb 05                	jmp    801052fd <holding+0x28>
801052f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052fd:	5d                   	pop    %ebp
801052fe:	c3                   	ret    

801052ff <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052ff:	55                   	push   %ebp
80105300:	89 e5                	mov    %esp,%ebp
80105302:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105305:	e8 4a fe ff ff       	call   80105154 <readeflags>
8010530a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010530d:	e8 52 fe ff ff       	call   80105164 <cli>
  if(cpu->ncli++ == 0)
80105312:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105319:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
8010531f:	8d 48 01             	lea    0x1(%eax),%ecx
80105322:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105328:	85 c0                	test   %eax,%eax
8010532a:	75 15                	jne    80105341 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010532c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105332:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105335:	81 e2 00 02 00 00    	and    $0x200,%edx
8010533b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105341:	c9                   	leave  
80105342:	c3                   	ret    

80105343 <popcli>:

void
popcli(void)
{
80105343:	55                   	push   %ebp
80105344:	89 e5                	mov    %esp,%ebp
80105346:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105349:	e8 06 fe ff ff       	call   80105154 <readeflags>
8010534e:	25 00 02 00 00       	and    $0x200,%eax
80105353:	85 c0                	test   %eax,%eax
80105355:	74 0c                	je     80105363 <popcli+0x20>
    panic("popcli - interruptible");
80105357:	c7 04 24 11 8d 10 80 	movl   $0x80108d11,(%esp)
8010535e:	e8 d7 b1 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105363:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105369:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010536f:	83 ea 01             	sub    $0x1,%edx
80105372:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105378:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010537e:	85 c0                	test   %eax,%eax
80105380:	79 0c                	jns    8010538e <popcli+0x4b>
    panic("popcli");
80105382:	c7 04 24 28 8d 10 80 	movl   $0x80108d28,(%esp)
80105389:	e8 ac b1 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010538e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105394:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010539a:	85 c0                	test   %eax,%eax
8010539c:	75 15                	jne    801053b3 <popcli+0x70>
8010539e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053a4:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053aa:	85 c0                	test   %eax,%eax
801053ac:	74 05                	je     801053b3 <popcli+0x70>
    sti();
801053ae:	e8 b7 fd ff ff       	call   8010516a <sti>
}
801053b3:	c9                   	leave  
801053b4:	c3                   	ret    

801053b5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053b5:	55                   	push   %ebp
801053b6:	89 e5                	mov    %esp,%ebp
801053b8:	57                   	push   %edi
801053b9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053bd:	8b 55 10             	mov    0x10(%ebp),%edx
801053c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c3:	89 cb                	mov    %ecx,%ebx
801053c5:	89 df                	mov    %ebx,%edi
801053c7:	89 d1                	mov    %edx,%ecx
801053c9:	fc                   	cld    
801053ca:	f3 aa                	rep stos %al,%es:(%edi)
801053cc:	89 ca                	mov    %ecx,%edx
801053ce:	89 fb                	mov    %edi,%ebx
801053d0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053d3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053d6:	5b                   	pop    %ebx
801053d7:	5f                   	pop    %edi
801053d8:	5d                   	pop    %ebp
801053d9:	c3                   	ret    

801053da <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053da:	55                   	push   %ebp
801053db:	89 e5                	mov    %esp,%ebp
801053dd:	57                   	push   %edi
801053de:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053df:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053e2:	8b 55 10             	mov    0x10(%ebp),%edx
801053e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e8:	89 cb                	mov    %ecx,%ebx
801053ea:	89 df                	mov    %ebx,%edi
801053ec:	89 d1                	mov    %edx,%ecx
801053ee:	fc                   	cld    
801053ef:	f3 ab                	rep stos %eax,%es:(%edi)
801053f1:	89 ca                	mov    %ecx,%edx
801053f3:	89 fb                	mov    %edi,%ebx
801053f5:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053f8:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053fb:	5b                   	pop    %ebx
801053fc:	5f                   	pop    %edi
801053fd:	5d                   	pop    %ebp
801053fe:	c3                   	ret    

801053ff <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801053ff:	55                   	push   %ebp
80105400:	89 e5                	mov    %esp,%ebp
80105402:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105405:	8b 45 08             	mov    0x8(%ebp),%eax
80105408:	83 e0 03             	and    $0x3,%eax
8010540b:	85 c0                	test   %eax,%eax
8010540d:	75 49                	jne    80105458 <memset+0x59>
8010540f:	8b 45 10             	mov    0x10(%ebp),%eax
80105412:	83 e0 03             	and    $0x3,%eax
80105415:	85 c0                	test   %eax,%eax
80105417:	75 3f                	jne    80105458 <memset+0x59>
    c &= 0xFF;
80105419:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105420:	8b 45 10             	mov    0x10(%ebp),%eax
80105423:	c1 e8 02             	shr    $0x2,%eax
80105426:	89 c2                	mov    %eax,%edx
80105428:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542b:	c1 e0 18             	shl    $0x18,%eax
8010542e:	89 c1                	mov    %eax,%ecx
80105430:	8b 45 0c             	mov    0xc(%ebp),%eax
80105433:	c1 e0 10             	shl    $0x10,%eax
80105436:	09 c1                	or     %eax,%ecx
80105438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543b:	c1 e0 08             	shl    $0x8,%eax
8010543e:	09 c8                	or     %ecx,%eax
80105440:	0b 45 0c             	or     0xc(%ebp),%eax
80105443:	89 54 24 08          	mov    %edx,0x8(%esp)
80105447:	89 44 24 04          	mov    %eax,0x4(%esp)
8010544b:	8b 45 08             	mov    0x8(%ebp),%eax
8010544e:	89 04 24             	mov    %eax,(%esp)
80105451:	e8 84 ff ff ff       	call   801053da <stosl>
80105456:	eb 19                	jmp    80105471 <memset+0x72>
  } else
    stosb(dst, c, n);
80105458:	8b 45 10             	mov    0x10(%ebp),%eax
8010545b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010545f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105462:	89 44 24 04          	mov    %eax,0x4(%esp)
80105466:	8b 45 08             	mov    0x8(%ebp),%eax
80105469:	89 04 24             	mov    %eax,(%esp)
8010546c:	e8 44 ff ff ff       	call   801053b5 <stosb>
  return dst;
80105471:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105474:	c9                   	leave  
80105475:	c3                   	ret    

80105476 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105476:	55                   	push   %ebp
80105477:	89 e5                	mov    %esp,%ebp
80105479:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010547c:	8b 45 08             	mov    0x8(%ebp),%eax
8010547f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105482:	8b 45 0c             	mov    0xc(%ebp),%eax
80105485:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105488:	eb 30                	jmp    801054ba <memcmp+0x44>
    if(*s1 != *s2)
8010548a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010548d:	0f b6 10             	movzbl (%eax),%edx
80105490:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105493:	0f b6 00             	movzbl (%eax),%eax
80105496:	38 c2                	cmp    %al,%dl
80105498:	74 18                	je     801054b2 <memcmp+0x3c>
      return *s1 - *s2;
8010549a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010549d:	0f b6 00             	movzbl (%eax),%eax
801054a0:	0f b6 d0             	movzbl %al,%edx
801054a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054a6:	0f b6 00             	movzbl (%eax),%eax
801054a9:	0f b6 c0             	movzbl %al,%eax
801054ac:	29 c2                	sub    %eax,%edx
801054ae:	89 d0                	mov    %edx,%eax
801054b0:	eb 1a                	jmp    801054cc <memcmp+0x56>
    s1++, s2++;
801054b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054b6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054ba:	8b 45 10             	mov    0x10(%ebp),%eax
801054bd:	8d 50 ff             	lea    -0x1(%eax),%edx
801054c0:	89 55 10             	mov    %edx,0x10(%ebp)
801054c3:	85 c0                	test   %eax,%eax
801054c5:	75 c3                	jne    8010548a <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801054c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054cc:	c9                   	leave  
801054cd:	c3                   	ret    

801054ce <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054ce:	55                   	push   %ebp
801054cf:	89 e5                	mov    %esp,%ebp
801054d1:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054da:	8b 45 08             	mov    0x8(%ebp),%eax
801054dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054e6:	73 3d                	jae    80105525 <memmove+0x57>
801054e8:	8b 45 10             	mov    0x10(%ebp),%eax
801054eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054ee:	01 d0                	add    %edx,%eax
801054f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054f3:	76 30                	jbe    80105525 <memmove+0x57>
    s += n;
801054f5:	8b 45 10             	mov    0x10(%ebp),%eax
801054f8:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054fb:	8b 45 10             	mov    0x10(%ebp),%eax
801054fe:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105501:	eb 13                	jmp    80105516 <memmove+0x48>
      *--d = *--s;
80105503:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105507:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010550b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010550e:	0f b6 10             	movzbl (%eax),%edx
80105511:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105514:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105516:	8b 45 10             	mov    0x10(%ebp),%eax
80105519:	8d 50 ff             	lea    -0x1(%eax),%edx
8010551c:	89 55 10             	mov    %edx,0x10(%ebp)
8010551f:	85 c0                	test   %eax,%eax
80105521:	75 e0                	jne    80105503 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105523:	eb 26                	jmp    8010554b <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105525:	eb 17                	jmp    8010553e <memmove+0x70>
      *d++ = *s++;
80105527:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010552a:	8d 50 01             	lea    0x1(%eax),%edx
8010552d:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105530:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105533:	8d 4a 01             	lea    0x1(%edx),%ecx
80105536:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105539:	0f b6 12             	movzbl (%edx),%edx
8010553c:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010553e:	8b 45 10             	mov    0x10(%ebp),%eax
80105541:	8d 50 ff             	lea    -0x1(%eax),%edx
80105544:	89 55 10             	mov    %edx,0x10(%ebp)
80105547:	85 c0                	test   %eax,%eax
80105549:	75 dc                	jne    80105527 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010554b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010554e:	c9                   	leave  
8010554f:	c3                   	ret    

80105550 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105550:	55                   	push   %ebp
80105551:	89 e5                	mov    %esp,%ebp
80105553:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105556:	8b 45 10             	mov    0x10(%ebp),%eax
80105559:	89 44 24 08          	mov    %eax,0x8(%esp)
8010555d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105560:	89 44 24 04          	mov    %eax,0x4(%esp)
80105564:	8b 45 08             	mov    0x8(%ebp),%eax
80105567:	89 04 24             	mov    %eax,(%esp)
8010556a:	e8 5f ff ff ff       	call   801054ce <memmove>
}
8010556f:	c9                   	leave  
80105570:	c3                   	ret    

80105571 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105571:	55                   	push   %ebp
80105572:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105574:	eb 0c                	jmp    80105582 <strncmp+0x11>
    n--, p++, q++;
80105576:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010557a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010557e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105582:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105586:	74 1a                	je     801055a2 <strncmp+0x31>
80105588:	8b 45 08             	mov    0x8(%ebp),%eax
8010558b:	0f b6 00             	movzbl (%eax),%eax
8010558e:	84 c0                	test   %al,%al
80105590:	74 10                	je     801055a2 <strncmp+0x31>
80105592:	8b 45 08             	mov    0x8(%ebp),%eax
80105595:	0f b6 10             	movzbl (%eax),%edx
80105598:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559b:	0f b6 00             	movzbl (%eax),%eax
8010559e:	38 c2                	cmp    %al,%dl
801055a0:	74 d4                	je     80105576 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801055a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055a6:	75 07                	jne    801055af <strncmp+0x3e>
    return 0;
801055a8:	b8 00 00 00 00       	mov    $0x0,%eax
801055ad:	eb 16                	jmp    801055c5 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801055af:	8b 45 08             	mov    0x8(%ebp),%eax
801055b2:	0f b6 00             	movzbl (%eax),%eax
801055b5:	0f b6 d0             	movzbl %al,%edx
801055b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055bb:	0f b6 00             	movzbl (%eax),%eax
801055be:	0f b6 c0             	movzbl %al,%eax
801055c1:	29 c2                	sub    %eax,%edx
801055c3:	89 d0                	mov    %edx,%eax
}
801055c5:	5d                   	pop    %ebp
801055c6:	c3                   	ret    

801055c7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055c7:	55                   	push   %ebp
801055c8:	89 e5                	mov    %esp,%ebp
801055ca:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055cd:	8b 45 08             	mov    0x8(%ebp),%eax
801055d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801055d3:	90                   	nop
801055d4:	8b 45 10             	mov    0x10(%ebp),%eax
801055d7:	8d 50 ff             	lea    -0x1(%eax),%edx
801055da:	89 55 10             	mov    %edx,0x10(%ebp)
801055dd:	85 c0                	test   %eax,%eax
801055df:	7e 1e                	jle    801055ff <strncpy+0x38>
801055e1:	8b 45 08             	mov    0x8(%ebp),%eax
801055e4:	8d 50 01             	lea    0x1(%eax),%edx
801055e7:	89 55 08             	mov    %edx,0x8(%ebp)
801055ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801055ed:	8d 4a 01             	lea    0x1(%edx),%ecx
801055f0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801055f3:	0f b6 12             	movzbl (%edx),%edx
801055f6:	88 10                	mov    %dl,(%eax)
801055f8:	0f b6 00             	movzbl (%eax),%eax
801055fb:	84 c0                	test   %al,%al
801055fd:	75 d5                	jne    801055d4 <strncpy+0xd>
    ;
  while(n-- > 0)
801055ff:	eb 0c                	jmp    8010560d <strncpy+0x46>
    *s++ = 0;
80105601:	8b 45 08             	mov    0x8(%ebp),%eax
80105604:	8d 50 01             	lea    0x1(%eax),%edx
80105607:	89 55 08             	mov    %edx,0x8(%ebp)
8010560a:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010560d:	8b 45 10             	mov    0x10(%ebp),%eax
80105610:	8d 50 ff             	lea    -0x1(%eax),%edx
80105613:	89 55 10             	mov    %edx,0x10(%ebp)
80105616:	85 c0                	test   %eax,%eax
80105618:	7f e7                	jg     80105601 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010561a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010561d:	c9                   	leave  
8010561e:	c3                   	ret    

8010561f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010561f:	55                   	push   %ebp
80105620:	89 e5                	mov    %esp,%ebp
80105622:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105625:	8b 45 08             	mov    0x8(%ebp),%eax
80105628:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010562b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010562f:	7f 05                	jg     80105636 <safestrcpy+0x17>
    return os;
80105631:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105634:	eb 31                	jmp    80105667 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105636:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010563a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010563e:	7e 1e                	jle    8010565e <safestrcpy+0x3f>
80105640:	8b 45 08             	mov    0x8(%ebp),%eax
80105643:	8d 50 01             	lea    0x1(%eax),%edx
80105646:	89 55 08             	mov    %edx,0x8(%ebp)
80105649:	8b 55 0c             	mov    0xc(%ebp),%edx
8010564c:	8d 4a 01             	lea    0x1(%edx),%ecx
8010564f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105652:	0f b6 12             	movzbl (%edx),%edx
80105655:	88 10                	mov    %dl,(%eax)
80105657:	0f b6 00             	movzbl (%eax),%eax
8010565a:	84 c0                	test   %al,%al
8010565c:	75 d8                	jne    80105636 <safestrcpy+0x17>
    ;
  *s = 0;
8010565e:	8b 45 08             	mov    0x8(%ebp),%eax
80105661:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105664:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105667:	c9                   	leave  
80105668:	c3                   	ret    

80105669 <strlen>:

int
strlen(const char *s)
{
80105669:	55                   	push   %ebp
8010566a:	89 e5                	mov    %esp,%ebp
8010566c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010566f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105676:	eb 04                	jmp    8010567c <strlen+0x13>
80105678:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010567c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010567f:	8b 45 08             	mov    0x8(%ebp),%eax
80105682:	01 d0                	add    %edx,%eax
80105684:	0f b6 00             	movzbl (%eax),%eax
80105687:	84 c0                	test   %al,%al
80105689:	75 ed                	jne    80105678 <strlen+0xf>
    ;
  return n;
8010568b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010568e:	c9                   	leave  
8010568f:	c3                   	ret    

80105690 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105690:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105694:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105698:	55                   	push   %ebp
  pushl %ebx
80105699:	53                   	push   %ebx
  pushl %esi
8010569a:	56                   	push   %esi
  pushl %edi
8010569b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010569c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010569e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056a0:	5f                   	pop    %edi
  popl %esi
801056a1:	5e                   	pop    %esi
  popl %ebx
801056a2:	5b                   	pop    %ebx
  popl %ebp
801056a3:	5d                   	pop    %ebp
  ret
801056a4:	c3                   	ret    

801056a5 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801056a5:	55                   	push   %ebp
801056a6:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801056a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ae:	8b 00                	mov    (%eax),%eax
801056b0:	3b 45 08             	cmp    0x8(%ebp),%eax
801056b3:	76 12                	jbe    801056c7 <fetchint+0x22>
801056b5:	8b 45 08             	mov    0x8(%ebp),%eax
801056b8:	8d 50 04             	lea    0x4(%eax),%edx
801056bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c1:	8b 00                	mov    (%eax),%eax
801056c3:	39 c2                	cmp    %eax,%edx
801056c5:	76 07                	jbe    801056ce <fetchint+0x29>
    return -1;
801056c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cc:	eb 0f                	jmp    801056dd <fetchint+0x38>
  *ip = *(int*)(addr);
801056ce:	8b 45 08             	mov    0x8(%ebp),%eax
801056d1:	8b 10                	mov    (%eax),%edx
801056d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d6:	89 10                	mov    %edx,(%eax)
  return 0;
801056d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056dd:	5d                   	pop    %ebp
801056de:	c3                   	ret    

801056df <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801056df:	55                   	push   %ebp
801056e0:	89 e5                	mov    %esp,%ebp
801056e2:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801056e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056eb:	8b 00                	mov    (%eax),%eax
801056ed:	3b 45 08             	cmp    0x8(%ebp),%eax
801056f0:	77 07                	ja     801056f9 <fetchstr+0x1a>
    return -1;
801056f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f7:	eb 46                	jmp    8010573f <fetchstr+0x60>
  *pp = (char*)addr;
801056f9:	8b 55 08             	mov    0x8(%ebp),%edx
801056fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ff:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105701:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105707:	8b 00                	mov    (%eax),%eax
80105709:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010570c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570f:	8b 00                	mov    (%eax),%eax
80105711:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105714:	eb 1c                	jmp    80105732 <fetchstr+0x53>
    if(*s == 0)
80105716:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105719:	0f b6 00             	movzbl (%eax),%eax
8010571c:	84 c0                	test   %al,%al
8010571e:	75 0e                	jne    8010572e <fetchstr+0x4f>
      return s - *pp;
80105720:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105723:	8b 45 0c             	mov    0xc(%ebp),%eax
80105726:	8b 00                	mov    (%eax),%eax
80105728:	29 c2                	sub    %eax,%edx
8010572a:	89 d0                	mov    %edx,%eax
8010572c:	eb 11                	jmp    8010573f <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010572e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105732:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105735:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105738:	72 dc                	jb     80105716 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010573a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010573f:	c9                   	leave  
80105740:	c3                   	ret    

80105741 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105741:	55                   	push   %ebp
80105742:	89 e5                	mov    %esp,%ebp
80105744:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105747:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574d:	8b 40 20             	mov    0x20(%eax),%eax
80105750:	8b 50 44             	mov    0x44(%eax),%edx
80105753:	8b 45 08             	mov    0x8(%ebp),%eax
80105756:	c1 e0 02             	shl    $0x2,%eax
80105759:	01 d0                	add    %edx,%eax
8010575b:	8d 50 04             	lea    0x4(%eax),%edx
8010575e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105761:	89 44 24 04          	mov    %eax,0x4(%esp)
80105765:	89 14 24             	mov    %edx,(%esp)
80105768:	e8 38 ff ff ff       	call   801056a5 <fetchint>
}
8010576d:	c9                   	leave  
8010576e:	c3                   	ret    

8010576f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010576f:	55                   	push   %ebp
80105770:	89 e5                	mov    %esp,%ebp
80105772:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105775:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105778:	89 44 24 04          	mov    %eax,0x4(%esp)
8010577c:	8b 45 08             	mov    0x8(%ebp),%eax
8010577f:	89 04 24             	mov    %eax,(%esp)
80105782:	e8 ba ff ff ff       	call   80105741 <argint>
80105787:	85 c0                	test   %eax,%eax
80105789:	79 07                	jns    80105792 <argptr+0x23>
    return -1;
8010578b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105790:	eb 3d                	jmp    801057cf <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105792:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105795:	89 c2                	mov    %eax,%edx
80105797:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010579d:	8b 00                	mov    (%eax),%eax
8010579f:	39 c2                	cmp    %eax,%edx
801057a1:	73 16                	jae    801057b9 <argptr+0x4a>
801057a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057a6:	89 c2                	mov    %eax,%edx
801057a8:	8b 45 10             	mov    0x10(%ebp),%eax
801057ab:	01 c2                	add    %eax,%edx
801057ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b3:	8b 00                	mov    (%eax),%eax
801057b5:	39 c2                	cmp    %eax,%edx
801057b7:	76 07                	jbe    801057c0 <argptr+0x51>
    return -1;
801057b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057be:	eb 0f                	jmp    801057cf <argptr+0x60>
  *pp = (char*)i;
801057c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c3:	89 c2                	mov    %eax,%edx
801057c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801057c8:	89 10                	mov    %edx,(%eax)
  return 0;
801057ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057cf:	c9                   	leave  
801057d0:	c3                   	ret    

801057d1 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057d1:	55                   	push   %ebp
801057d2:	89 e5                	mov    %esp,%ebp
801057d4:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057da:	89 44 24 04          	mov    %eax,0x4(%esp)
801057de:	8b 45 08             	mov    0x8(%ebp),%eax
801057e1:	89 04 24             	mov    %eax,(%esp)
801057e4:	e8 58 ff ff ff       	call   80105741 <argint>
801057e9:	85 c0                	test   %eax,%eax
801057eb:	79 07                	jns    801057f4 <argstr+0x23>
    return -1;
801057ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f2:	eb 12                	jmp    80105806 <argstr+0x35>
  return fetchstr(addr, pp);
801057f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801057fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801057fe:	89 04 24             	mov    %eax,(%esp)
80105801:	e8 d9 fe ff ff       	call   801056df <fetchstr>
}
80105806:	c9                   	leave  
80105807:	c3                   	ret    

80105808 <syscall>:
#endif


void
syscall(void)
{
80105808:	55                   	push   %ebp
80105809:	89 e5                	mov    %esp,%ebp
8010580b:	53                   	push   %ebx
8010580c:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010580f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105815:	8b 40 20             	mov    0x20(%eax),%eax
80105818:	8b 40 1c             	mov    0x1c(%eax),%eax
8010581b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010581e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105822:	7e 30                	jle    80105854 <syscall+0x4c>
80105824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105827:	83 f8 1d             	cmp    $0x1d,%eax
8010582a:	77 28                	ja     80105854 <syscall+0x4c>
8010582c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582f:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105836:	85 c0                	test   %eax,%eax
80105838:	74 1a                	je     80105854 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010583a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105840:	8b 58 20             	mov    0x20(%eax),%ebx
80105843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105846:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010584d:	ff d0                	call   *%eax
8010584f:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105852:	eb 3d                	jmp    80105891 <syscall+0x89>
#ifdef PRINT_SYSCALLS
    //cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105854:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010585a:	8d 48 78             	lea    0x78(%eax),%ecx
8010585d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
//cprintf("%d %s: -> %d\n",proc->pid, proc->name, num);
#ifdef PRINT_SYSCALLS
    //cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105863:	8b 40 10             	mov    0x10(%eax),%eax
80105866:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105869:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010586d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105871:	89 44 24 04          	mov    %eax,0x4(%esp)
80105875:	c7 04 24 2f 8d 10 80 	movl   $0x80108d2f,(%esp)
8010587c:	e8 1f ab ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105881:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105887:	8b 40 20             	mov    0x20(%eax),%eax
8010588a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105891:	83 c4 24             	add    $0x24,%esp
80105894:	5b                   	pop    %ebx
80105895:	5d                   	pop    %ebp
80105896:	c3                   	ret    

80105897 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105897:	55                   	push   %ebp
80105898:	89 e5                	mov    %esp,%ebp
8010589a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010589d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801058a4:	8b 45 08             	mov    0x8(%ebp),%eax
801058a7:	89 04 24             	mov    %eax,(%esp)
801058aa:	e8 92 fe ff ff       	call   80105741 <argint>
801058af:	85 c0                	test   %eax,%eax
801058b1:	79 07                	jns    801058ba <argfd+0x23>
    return -1;
801058b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b8:	eb 4f                	jmp    80105909 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801058ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bd:	85 c0                	test   %eax,%eax
801058bf:	78 20                	js     801058e1 <argfd+0x4a>
801058c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c4:	83 f8 0f             	cmp    $0xf,%eax
801058c7:	7f 18                	jg     801058e1 <argfd+0x4a>
801058c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058d2:	83 c2 0c             	add    $0xc,%edx
801058d5:	8b 04 90             	mov    (%eax,%edx,4),%eax
801058d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058df:	75 07                	jne    801058e8 <argfd+0x51>
    return -1;
801058e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058e6:	eb 21                	jmp    80105909 <argfd+0x72>
  if(pfd)
801058e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058ec:	74 08                	je     801058f6 <argfd+0x5f>
    *pfd = fd;
801058ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f4:	89 10                	mov    %edx,(%eax)
  if(pf)
801058f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058fa:	74 08                	je     80105904 <argfd+0x6d>
    *pf = f;
801058fc:	8b 45 10             	mov    0x10(%ebp),%eax
801058ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105902:	89 10                	mov    %edx,(%eax)
  return 0;
80105904:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105909:	c9                   	leave  
8010590a:	c3                   	ret    

8010590b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010590b:	55                   	push   %ebp
8010590c:	89 e5                	mov    %esp,%ebp
8010590e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105911:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105918:	eb 2e                	jmp    80105948 <fdalloc+0x3d>
    if(proc->ofile[fd] == 0){
8010591a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105920:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105923:	83 c2 0c             	add    $0xc,%edx
80105926:	8b 04 90             	mov    (%eax,%edx,4),%eax
80105929:	85 c0                	test   %eax,%eax
8010592b:	75 17                	jne    80105944 <fdalloc+0x39>
      proc->ofile[fd] = f;
8010592d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105933:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105936:	8d 4a 0c             	lea    0xc(%edx),%ecx
80105939:	8b 55 08             	mov    0x8(%ebp),%edx
8010593c:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      return fd;
8010593f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105942:	eb 0f                	jmp    80105953 <fdalloc+0x48>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105944:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105948:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010594c:	7e cc                	jle    8010591a <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010594e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105953:	c9                   	leave  
80105954:	c3                   	ret    

80105955 <sys_dup>:

int
sys_dup(void)
{
80105955:	55                   	push   %ebp
80105956:	89 e5                	mov    %esp,%ebp
80105958:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010595b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010595e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105962:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105969:	00 
8010596a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105971:	e8 21 ff ff ff       	call   80105897 <argfd>
80105976:	85 c0                	test   %eax,%eax
80105978:	79 07                	jns    80105981 <sys_dup+0x2c>
    return -1;
8010597a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597f:	eb 29                	jmp    801059aa <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105981:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105984:	89 04 24             	mov    %eax,(%esp)
80105987:	e8 7f ff ff ff       	call   8010590b <fdalloc>
8010598c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010598f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105993:	79 07                	jns    8010599c <sys_dup+0x47>
    return -1;
80105995:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599a:	eb 0e                	jmp    801059aa <sys_dup+0x55>
  filedup(f);
8010599c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599f:	89 04 24             	mov    %eax,(%esp)
801059a2:	e8 fa b5 ff ff       	call   80100fa1 <filedup>
  return fd;
801059a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059aa:	c9                   	leave  
801059ab:	c3                   	ret    

801059ac <sys_read>:

int
sys_read(void)
{
801059ac:	55                   	push   %ebp
801059ad:	89 e5                	mov    %esp,%ebp
801059af:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059b5:	89 44 24 08          	mov    %eax,0x8(%esp)
801059b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059c0:	00 
801059c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059c8:	e8 ca fe ff ff       	call   80105897 <argfd>
801059cd:	85 c0                	test   %eax,%eax
801059cf:	78 35                	js     80105a06 <sys_read+0x5a>
801059d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801059d8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059df:	e8 5d fd ff ff       	call   80105741 <argint>
801059e4:	85 c0                	test   %eax,%eax
801059e6:	78 1e                	js     80105a06 <sys_read+0x5a>
801059e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059eb:	89 44 24 08          	mov    %eax,0x8(%esp)
801059ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059fd:	e8 6d fd ff ff       	call   8010576f <argptr>
80105a02:	85 c0                	test   %eax,%eax
80105a04:	79 07                	jns    80105a0d <sys_read+0x61>
    return -1;
80105a06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0b:	eb 19                	jmp    80105a26 <sys_read+0x7a>
  return fileread(f, p, n);
80105a0d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a10:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a16:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a1e:	89 04 24             	mov    %eax,(%esp)
80105a21:	e8 e8 b6 ff ff       	call   8010110e <fileread>
}
80105a26:	c9                   	leave  
80105a27:	c3                   	ret    

80105a28 <sys_write>:

int
sys_write(void)
{
80105a28:	55                   	push   %ebp
80105a29:	89 e5                	mov    %esp,%ebp
80105a2b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a31:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a35:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a3c:	00 
80105a3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a44:	e8 4e fe ff ff       	call   80105897 <argfd>
80105a49:	85 c0                	test   %eax,%eax
80105a4b:	78 35                	js     80105a82 <sys_write+0x5a>
80105a4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a50:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a54:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a5b:	e8 e1 fc ff ff       	call   80105741 <argint>
80105a60:	85 c0                	test   %eax,%eax
80105a62:	78 1e                	js     80105a82 <sys_write+0x5a>
80105a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a67:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a6b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a79:	e8 f1 fc ff ff       	call   8010576f <argptr>
80105a7e:	85 c0                	test   %eax,%eax
80105a80:	79 07                	jns    80105a89 <sys_write+0x61>
    return -1;
80105a82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a87:	eb 19                	jmp    80105aa2 <sys_write+0x7a>
  return filewrite(f, p, n);
80105a89:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a92:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a96:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a9a:	89 04 24             	mov    %eax,(%esp)
80105a9d:	e8 28 b7 ff ff       	call   801011ca <filewrite>
}
80105aa2:	c9                   	leave  
80105aa3:	c3                   	ret    

80105aa4 <sys_close>:

int
sys_close(void)
{
80105aa4:	55                   	push   %ebp
80105aa5:	89 e5                	mov    %esp,%ebp
80105aa7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105aaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aad:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105abf:	e8 d3 fd ff ff       	call   80105897 <argfd>
80105ac4:	85 c0                	test   %eax,%eax
80105ac6:	79 07                	jns    80105acf <sys_close+0x2b>
    return -1;
80105ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acd:	eb 23                	jmp    80105af2 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105acf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ad5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ad8:	83 c2 0c             	add    $0xc,%edx
80105adb:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
  fileclose(f);
80105ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae5:	89 04 24             	mov    %eax,(%esp)
80105ae8:	e8 fc b4 ff ff       	call   80100fe9 <fileclose>
  return 0;
80105aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105af2:	c9                   	leave  
80105af3:	c3                   	ret    

80105af4 <sys_fstat>:

int
sys_fstat(void)
{
80105af4:	55                   	push   %ebp
80105af5:	89 e5                	mov    %esp,%ebp
80105af7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105afa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105afd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b08:	00 
80105b09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b10:	e8 82 fd ff ff       	call   80105897 <argfd>
80105b15:	85 c0                	test   %eax,%eax
80105b17:	78 1f                	js     80105b38 <sys_fstat+0x44>
80105b19:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b20:	00 
80105b21:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b24:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b2f:	e8 3b fc ff ff       	call   8010576f <argptr>
80105b34:	85 c0                	test   %eax,%eax
80105b36:	79 07                	jns    80105b3f <sys_fstat+0x4b>
    return -1;
80105b38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3d:	eb 12                	jmp    80105b51 <sys_fstat+0x5d>
  return filestat(f, st);
80105b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b45:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b49:	89 04 24             	mov    %eax,(%esp)
80105b4c:	e8 6e b5 ff ff       	call   801010bf <filestat>
}
80105b51:	c9                   	leave  
80105b52:	c3                   	ret    

80105b53 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b53:	55                   	push   %ebp
80105b54:	89 e5                	mov    %esp,%ebp
80105b56:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b59:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b67:	e8 65 fc ff ff       	call   801057d1 <argstr>
80105b6c:	85 c0                	test   %eax,%eax
80105b6e:	78 17                	js     80105b87 <sys_link+0x34>
80105b70:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b73:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b7e:	e8 4e fc ff ff       	call   801057d1 <argstr>
80105b83:	85 c0                	test   %eax,%eax
80105b85:	79 0a                	jns    80105b91 <sys_link+0x3e>
    return -1;
80105b87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8c:	e9 42 01 00 00       	jmp    80105cd3 <sys_link+0x180>

  begin_op();
80105b91:	e8 26 d9 ff ff       	call   801034bc <begin_op>
  if((ip = namei(old)) == 0){
80105b96:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b99:	89 04 24             	mov    %eax,(%esp)
80105b9c:	e8 e4 c8 ff ff       	call   80102485 <namei>
80105ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba8:	75 0f                	jne    80105bb9 <sys_link+0x66>
    end_op();
80105baa:	e8 91 d9 ff ff       	call   80103540 <end_op>
    return -1;
80105baf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb4:	e9 1a 01 00 00       	jmp    80105cd3 <sys_link+0x180>
  }

  ilock(ip);
80105bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbc:	89 04 24             	mov    %eax,(%esp)
80105bbf:	e8 10 bd ff ff       	call   801018d4 <ilock>
  if(ip->type == T_DIR){
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105bcb:	66 83 f8 01          	cmp    $0x1,%ax
80105bcf:	75 1a                	jne    80105beb <sys_link+0x98>
    iunlockput(ip);
80105bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd4:	89 04 24             	mov    %eax,(%esp)
80105bd7:	e8 82 bf ff ff       	call   80101b5e <iunlockput>
    end_op();
80105bdc:	e8 5f d9 ff ff       	call   80103540 <end_op>
    return -1;
80105be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be6:	e9 e8 00 00 00       	jmp    80105cd3 <sys_link+0x180>
  }

  ip->nlink++;
80105beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bee:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bf2:	8d 50 01             	lea    0x1(%eax),%edx
80105bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf8:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bff:	89 04 24             	mov    %eax,(%esp)
80105c02:	e8 0b bb ff ff       	call   80101712 <iupdate>
  iunlock(ip);
80105c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0a:	89 04 24             	mov    %eax,(%esp)
80105c0d:	e8 16 be ff ff       	call   80101a28 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105c12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c15:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c18:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c1c:	89 04 24             	mov    %eax,(%esp)
80105c1f:	e8 83 c8 ff ff       	call   801024a7 <nameiparent>
80105c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c2b:	75 02                	jne    80105c2f <sys_link+0xdc>
    goto bad;
80105c2d:	eb 68                	jmp    80105c97 <sys_link+0x144>
  ilock(dp);
80105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c32:	89 04 24             	mov    %eax,(%esp)
80105c35:	e8 9a bc ff ff       	call   801018d4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3d:	8b 10                	mov    (%eax),%edx
80105c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c42:	8b 00                	mov    (%eax),%eax
80105c44:	39 c2                	cmp    %eax,%edx
80105c46:	75 20                	jne    80105c68 <sys_link+0x115>
80105c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4b:	8b 40 04             	mov    0x4(%eax),%eax
80105c4e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c52:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c55:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5c:	89 04 24             	mov    %eax,(%esp)
80105c5f:	e8 61 c5 ff ff       	call   801021c5 <dirlink>
80105c64:	85 c0                	test   %eax,%eax
80105c66:	79 0d                	jns    80105c75 <sys_link+0x122>
    iunlockput(dp);
80105c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6b:	89 04 24             	mov    %eax,(%esp)
80105c6e:	e8 eb be ff ff       	call   80101b5e <iunlockput>
    goto bad;
80105c73:	eb 22                	jmp    80105c97 <sys_link+0x144>
  }
  iunlockput(dp);
80105c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c78:	89 04 24             	mov    %eax,(%esp)
80105c7b:	e8 de be ff ff       	call   80101b5e <iunlockput>
  iput(ip);
80105c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c83:	89 04 24             	mov    %eax,(%esp)
80105c86:	e8 02 be ff ff       	call   80101a8d <iput>

  end_op();
80105c8b:	e8 b0 d8 ff ff       	call   80103540 <end_op>

  return 0;
80105c90:	b8 00 00 00 00       	mov    $0x0,%eax
80105c95:	eb 3c                	jmp    80105cd3 <sys_link+0x180>

bad:
  ilock(ip);
80105c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9a:	89 04 24             	mov    %eax,(%esp)
80105c9d:	e8 32 bc ff ff       	call   801018d4 <ilock>
  ip->nlink--;
80105ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ca9:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caf:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb6:	89 04 24             	mov    %eax,(%esp)
80105cb9:	e8 54 ba ff ff       	call   80101712 <iupdate>
  iunlockput(ip);
80105cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc1:	89 04 24             	mov    %eax,(%esp)
80105cc4:	e8 95 be ff ff       	call   80101b5e <iunlockput>
  end_op();
80105cc9:	e8 72 d8 ff ff       	call   80103540 <end_op>
  return -1;
80105cce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cd3:	c9                   	leave  
80105cd4:	c3                   	ret    

80105cd5 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105cd5:	55                   	push   %ebp
80105cd6:	89 e5                	mov    %esp,%ebp
80105cd8:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cdb:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ce2:	eb 4b                	jmp    80105d2f <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105cee:	00 
80105cef:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80105cfd:	89 04 24             	mov    %eax,(%esp)
80105d00:	e8 e2 c0 ff ff       	call   80101de7 <readi>
80105d05:	83 f8 10             	cmp    $0x10,%eax
80105d08:	74 0c                	je     80105d16 <isdirempty+0x41>
      panic("isdirempty: readi");
80105d0a:	c7 04 24 4b 8d 10 80 	movl   $0x80108d4b,(%esp)
80105d11:	e8 24 a8 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105d16:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d1a:	66 85 c0             	test   %ax,%ax
80105d1d:	74 07                	je     80105d26 <isdirempty+0x51>
      return 0;
80105d1f:	b8 00 00 00 00       	mov    $0x0,%eax
80105d24:	eb 1b                	jmp    80105d41 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d29:	83 c0 10             	add    $0x10,%eax
80105d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d32:	8b 45 08             	mov    0x8(%ebp),%eax
80105d35:	8b 40 18             	mov    0x18(%eax),%eax
80105d38:	39 c2                	cmp    %eax,%edx
80105d3a:	72 a8                	jb     80105ce4 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105d3c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d41:	c9                   	leave  
80105d42:	c3                   	ret    

80105d43 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d43:	55                   	push   %ebp
80105d44:	89 e5                	mov    %esp,%ebp
80105d46:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d49:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d57:	e8 75 fa ff ff       	call   801057d1 <argstr>
80105d5c:	85 c0                	test   %eax,%eax
80105d5e:	79 0a                	jns    80105d6a <sys_unlink+0x27>
    return -1;
80105d60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d65:	e9 af 01 00 00       	jmp    80105f19 <sys_unlink+0x1d6>

  begin_op();
80105d6a:	e8 4d d7 ff ff       	call   801034bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d6f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d72:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d75:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d79:	89 04 24             	mov    %eax,(%esp)
80105d7c:	e8 26 c7 ff ff       	call   801024a7 <nameiparent>
80105d81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d88:	75 0f                	jne    80105d99 <sys_unlink+0x56>
    end_op();
80105d8a:	e8 b1 d7 ff ff       	call   80103540 <end_op>
    return -1;
80105d8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d94:	e9 80 01 00 00       	jmp    80105f19 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9c:	89 04 24             	mov    %eax,(%esp)
80105d9f:	e8 30 bb ff ff       	call   801018d4 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105da4:	c7 44 24 04 5d 8d 10 	movl   $0x80108d5d,0x4(%esp)
80105dab:	80 
80105dac:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105daf:	89 04 24             	mov    %eax,(%esp)
80105db2:	e8 23 c3 ff ff       	call   801020da <namecmp>
80105db7:	85 c0                	test   %eax,%eax
80105db9:	0f 84 45 01 00 00    	je     80105f04 <sys_unlink+0x1c1>
80105dbf:	c7 44 24 04 5f 8d 10 	movl   $0x80108d5f,0x4(%esp)
80105dc6:	80 
80105dc7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105dca:	89 04 24             	mov    %eax,(%esp)
80105dcd:	e8 08 c3 ff ff       	call   801020da <namecmp>
80105dd2:	85 c0                	test   %eax,%eax
80105dd4:	0f 84 2a 01 00 00    	je     80105f04 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105dda:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ddd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105de1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105de4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105deb:	89 04 24             	mov    %eax,(%esp)
80105dee:	e8 09 c3 ff ff       	call   801020fc <dirlookup>
80105df3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dfa:	75 05                	jne    80105e01 <sys_unlink+0xbe>
    goto bad;
80105dfc:	e9 03 01 00 00       	jmp    80105f04 <sys_unlink+0x1c1>
  ilock(ip);
80105e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e04:	89 04 24             	mov    %eax,(%esp)
80105e07:	e8 c8 ba ff ff       	call   801018d4 <ilock>

  if(ip->nlink < 1)
80105e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e13:	66 85 c0             	test   %ax,%ax
80105e16:	7f 0c                	jg     80105e24 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105e18:	c7 04 24 62 8d 10 80 	movl   $0x80108d62,(%esp)
80105e1f:	e8 16 a7 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e27:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e2b:	66 83 f8 01          	cmp    $0x1,%ax
80105e2f:	75 1f                	jne    80105e50 <sys_unlink+0x10d>
80105e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e34:	89 04 24             	mov    %eax,(%esp)
80105e37:	e8 99 fe ff ff       	call   80105cd5 <isdirempty>
80105e3c:	85 c0                	test   %eax,%eax
80105e3e:	75 10                	jne    80105e50 <sys_unlink+0x10d>
    iunlockput(ip);
80105e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e43:	89 04 24             	mov    %eax,(%esp)
80105e46:	e8 13 bd ff ff       	call   80101b5e <iunlockput>
    goto bad;
80105e4b:	e9 b4 00 00 00       	jmp    80105f04 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105e50:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e57:	00 
80105e58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e5f:	00 
80105e60:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e63:	89 04 24             	mov    %eax,(%esp)
80105e66:	e8 94 f5 ff ff       	call   801053ff <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e6b:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e6e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e75:	00 
80105e76:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e7a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e84:	89 04 24             	mov    %eax,(%esp)
80105e87:	e8 bf c0 ff ff       	call   80101f4b <writei>
80105e8c:	83 f8 10             	cmp    $0x10,%eax
80105e8f:	74 0c                	je     80105e9d <sys_unlink+0x15a>
    panic("unlink: writei");
80105e91:	c7 04 24 74 8d 10 80 	movl   $0x80108d74,(%esp)
80105e98:	e8 9d a6 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ea4:	66 83 f8 01          	cmp    $0x1,%ax
80105ea8:	75 1c                	jne    80105ec6 <sys_unlink+0x183>
    dp->nlink--;
80105eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ead:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105eb1:	8d 50 ff             	lea    -0x1(%eax),%edx
80105eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb7:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebe:	89 04 24             	mov    %eax,(%esp)
80105ec1:	e8 4c b8 ff ff       	call   80101712 <iupdate>
  }
  iunlockput(dp);
80105ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec9:	89 04 24             	mov    %eax,(%esp)
80105ecc:	e8 8d bc ff ff       	call   80101b5e <iunlockput>

  ip->nlink--;
80105ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ed8:	8d 50 ff             	lea    -0x1(%eax),%edx
80105edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ede:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee5:	89 04 24             	mov    %eax,(%esp)
80105ee8:	e8 25 b8 ff ff       	call   80101712 <iupdate>
  iunlockput(ip);
80105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef0:	89 04 24             	mov    %eax,(%esp)
80105ef3:	e8 66 bc ff ff       	call   80101b5e <iunlockput>

  end_op();
80105ef8:	e8 43 d6 ff ff       	call   80103540 <end_op>

  return 0;
80105efd:	b8 00 00 00 00       	mov    $0x0,%eax
80105f02:	eb 15                	jmp    80105f19 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f07:	89 04 24             	mov    %eax,(%esp)
80105f0a:	e8 4f bc ff ff       	call   80101b5e <iunlockput>
  end_op();
80105f0f:	e8 2c d6 ff ff       	call   80103540 <end_op>
  return -1;
80105f14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f19:	c9                   	leave  
80105f1a:	c3                   	ret    

80105f1b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f1b:	55                   	push   %ebp
80105f1c:	89 e5                	mov    %esp,%ebp
80105f1e:	83 ec 48             	sub    $0x48,%esp
80105f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f24:	8b 55 10             	mov    0x10(%ebp),%edx
80105f27:	8b 45 14             	mov    0x14(%ebp),%eax
80105f2a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f2e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f32:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f36:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f39:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f40:	89 04 24             	mov    %eax,(%esp)
80105f43:	e8 5f c5 ff ff       	call   801024a7 <nameiparent>
80105f48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f4f:	75 0a                	jne    80105f5b <create+0x40>
    return 0;
80105f51:	b8 00 00 00 00       	mov    $0x0,%eax
80105f56:	e9 7e 01 00 00       	jmp    801060d9 <create+0x1be>
  ilock(dp);
80105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5e:	89 04 24             	mov    %eax,(%esp)
80105f61:	e8 6e b9 ff ff       	call   801018d4 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f66:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f69:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f6d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f70:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f77:	89 04 24             	mov    %eax,(%esp)
80105f7a:	e8 7d c1 ff ff       	call   801020fc <dirlookup>
80105f7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f86:	74 47                	je     80105fcf <create+0xb4>
    iunlockput(dp);
80105f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8b:	89 04 24             	mov    %eax,(%esp)
80105f8e:	e8 cb bb ff ff       	call   80101b5e <iunlockput>
    ilock(ip);
80105f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f96:	89 04 24             	mov    %eax,(%esp)
80105f99:	e8 36 b9 ff ff       	call   801018d4 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105f9e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105fa3:	75 15                	jne    80105fba <create+0x9f>
80105fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fac:	66 83 f8 02          	cmp    $0x2,%ax
80105fb0:	75 08                	jne    80105fba <create+0x9f>
      return ip;
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	e9 1f 01 00 00       	jmp    801060d9 <create+0x1be>
    iunlockput(ip);
80105fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbd:	89 04 24             	mov    %eax,(%esp)
80105fc0:	e8 99 bb ff ff       	call   80101b5e <iunlockput>
    return 0;
80105fc5:	b8 00 00 00 00       	mov    $0x0,%eax
80105fca:	e9 0a 01 00 00       	jmp    801060d9 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105fcf:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd6:	8b 00                	mov    (%eax),%eax
80105fd8:	89 54 24 04          	mov    %edx,0x4(%esp)
80105fdc:	89 04 24             	mov    %eax,(%esp)
80105fdf:	e8 59 b6 ff ff       	call   8010163d <ialloc>
80105fe4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fe7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105feb:	75 0c                	jne    80105ff9 <create+0xde>
    panic("create: ialloc");
80105fed:	c7 04 24 83 8d 10 80 	movl   $0x80108d83,(%esp)
80105ff4:	e8 41 a5 ff ff       	call   8010053a <panic>

  ilock(ip);
80105ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ffc:	89 04 24             	mov    %eax,(%esp)
80105fff:	e8 d0 b8 ff ff       	call   801018d4 <ilock>
  ip->major = major;
80106004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106007:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010600b:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010600f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106012:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106016:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010601a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601d:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106023:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106026:	89 04 24             	mov    %eax,(%esp)
80106029:	e8 e4 b6 ff ff       	call   80101712 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010602e:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106033:	75 6a                	jne    8010609f <create+0x184>
    dp->nlink++;  // for ".."
80106035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106038:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010603c:	8d 50 01             	lea    0x1(%eax),%edx
8010603f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106042:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106049:	89 04 24             	mov    %eax,(%esp)
8010604c:	e8 c1 b6 ff ff       	call   80101712 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106054:	8b 40 04             	mov    0x4(%eax),%eax
80106057:	89 44 24 08          	mov    %eax,0x8(%esp)
8010605b:	c7 44 24 04 5d 8d 10 	movl   $0x80108d5d,0x4(%esp)
80106062:	80 
80106063:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106066:	89 04 24             	mov    %eax,(%esp)
80106069:	e8 57 c1 ff ff       	call   801021c5 <dirlink>
8010606e:	85 c0                	test   %eax,%eax
80106070:	78 21                	js     80106093 <create+0x178>
80106072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106075:	8b 40 04             	mov    0x4(%eax),%eax
80106078:	89 44 24 08          	mov    %eax,0x8(%esp)
8010607c:	c7 44 24 04 5f 8d 10 	movl   $0x80108d5f,0x4(%esp)
80106083:	80 
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	89 04 24             	mov    %eax,(%esp)
8010608a:	e8 36 c1 ff ff       	call   801021c5 <dirlink>
8010608f:	85 c0                	test   %eax,%eax
80106091:	79 0c                	jns    8010609f <create+0x184>
      panic("create dots");
80106093:	c7 04 24 92 8d 10 80 	movl   $0x80108d92,(%esp)
8010609a:	e8 9b a4 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010609f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a2:	8b 40 04             	mov    0x4(%eax),%eax
801060a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801060a9:	8d 45 de             	lea    -0x22(%ebp),%eax
801060ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801060b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b3:	89 04 24             	mov    %eax,(%esp)
801060b6:	e8 0a c1 ff ff       	call   801021c5 <dirlink>
801060bb:	85 c0                	test   %eax,%eax
801060bd:	79 0c                	jns    801060cb <create+0x1b0>
    panic("create: dirlink");
801060bf:	c7 04 24 9e 8d 10 80 	movl   $0x80108d9e,(%esp)
801060c6:	e8 6f a4 ff ff       	call   8010053a <panic>

  iunlockput(dp);
801060cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ce:	89 04 24             	mov    %eax,(%esp)
801060d1:	e8 88 ba ff ff       	call   80101b5e <iunlockput>

  return ip;
801060d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060d9:	c9                   	leave  
801060da:	c3                   	ret    

801060db <sys_open>:

int
sys_open(void)
{
801060db:	55                   	push   %ebp
801060dc:	89 e5                	mov    %esp,%ebp
801060de:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801060e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801060e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060ef:	e8 dd f6 ff ff       	call   801057d1 <argstr>
801060f4:	85 c0                	test   %eax,%eax
801060f6:	78 17                	js     8010610f <sys_open+0x34>
801060f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106106:	e8 36 f6 ff ff       	call   80105741 <argint>
8010610b:	85 c0                	test   %eax,%eax
8010610d:	79 0a                	jns    80106119 <sys_open+0x3e>
    return -1;
8010610f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106114:	e9 5c 01 00 00       	jmp    80106275 <sys_open+0x19a>

  begin_op();
80106119:	e8 9e d3 ff ff       	call   801034bc <begin_op>

  if(omode & O_CREATE){
8010611e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106121:	25 00 02 00 00       	and    $0x200,%eax
80106126:	85 c0                	test   %eax,%eax
80106128:	74 3b                	je     80106165 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010612a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010612d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106134:	00 
80106135:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010613c:	00 
8010613d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106144:	00 
80106145:	89 04 24             	mov    %eax,(%esp)
80106148:	e8 ce fd ff ff       	call   80105f1b <create>
8010614d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106150:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106154:	75 6b                	jne    801061c1 <sys_open+0xe6>
      end_op();
80106156:	e8 e5 d3 ff ff       	call   80103540 <end_op>
      return -1;
8010615b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106160:	e9 10 01 00 00       	jmp    80106275 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106165:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106168:	89 04 24             	mov    %eax,(%esp)
8010616b:	e8 15 c3 ff ff       	call   80102485 <namei>
80106170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106173:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106177:	75 0f                	jne    80106188 <sys_open+0xad>
      end_op();
80106179:	e8 c2 d3 ff ff       	call   80103540 <end_op>
      return -1;
8010617e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106183:	e9 ed 00 00 00       	jmp    80106275 <sys_open+0x19a>
    }
    ilock(ip);
80106188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618b:	89 04 24             	mov    %eax,(%esp)
8010618e:	e8 41 b7 ff ff       	call   801018d4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106196:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010619a:	66 83 f8 01          	cmp    $0x1,%ax
8010619e:	75 21                	jne    801061c1 <sys_open+0xe6>
801061a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a3:	85 c0                	test   %eax,%eax
801061a5:	74 1a                	je     801061c1 <sys_open+0xe6>
      iunlockput(ip);
801061a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061aa:	89 04 24             	mov    %eax,(%esp)
801061ad:	e8 ac b9 ff ff       	call   80101b5e <iunlockput>
      end_op();
801061b2:	e8 89 d3 ff ff       	call   80103540 <end_op>
      return -1;
801061b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061bc:	e9 b4 00 00 00       	jmp    80106275 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801061c1:	e8 7b ad ff ff       	call   80100f41 <filealloc>
801061c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061cd:	74 14                	je     801061e3 <sys_open+0x108>
801061cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d2:	89 04 24             	mov    %eax,(%esp)
801061d5:	e8 31 f7 ff ff       	call   8010590b <fdalloc>
801061da:	89 45 ec             	mov    %eax,-0x14(%ebp)
801061dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801061e1:	79 28                	jns    8010620b <sys_open+0x130>
    if(f)
801061e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e7:	74 0b                	je     801061f4 <sys_open+0x119>
      fileclose(f);
801061e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ec:	89 04 24             	mov    %eax,(%esp)
801061ef:	e8 f5 ad ff ff       	call   80100fe9 <fileclose>
    iunlockput(ip);
801061f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f7:	89 04 24             	mov    %eax,(%esp)
801061fa:	e8 5f b9 ff ff       	call   80101b5e <iunlockput>
    end_op();
801061ff:	e8 3c d3 ff ff       	call   80103540 <end_op>
    return -1;
80106204:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106209:	eb 6a                	jmp    80106275 <sys_open+0x19a>
  }
  iunlock(ip);
8010620b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620e:	89 04 24             	mov    %eax,(%esp)
80106211:	e8 12 b8 ff ff       	call   80101a28 <iunlock>
  end_op();
80106216:	e8 25 d3 ff ff       	call   80103540 <end_op>

  f->type = FD_INODE;
8010621b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106224:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106227:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010622a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010622d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106230:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010623a:	83 e0 01             	and    $0x1,%eax
8010623d:	85 c0                	test   %eax,%eax
8010623f:	0f 94 c0             	sete   %al
80106242:	89 c2                	mov    %eax,%edx
80106244:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106247:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010624a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010624d:	83 e0 01             	and    $0x1,%eax
80106250:	85 c0                	test   %eax,%eax
80106252:	75 0a                	jne    8010625e <sys_open+0x183>
80106254:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106257:	83 e0 02             	and    $0x2,%eax
8010625a:	85 c0                	test   %eax,%eax
8010625c:	74 07                	je     80106265 <sys_open+0x18a>
8010625e:	b8 01 00 00 00       	mov    $0x1,%eax
80106263:	eb 05                	jmp    8010626a <sys_open+0x18f>
80106265:	b8 00 00 00 00       	mov    $0x0,%eax
8010626a:	89 c2                	mov    %eax,%edx
8010626c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106272:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106275:	c9                   	leave  
80106276:	c3                   	ret    

80106277 <sys_mkdir>:

int
sys_mkdir(void)
{
80106277:	55                   	push   %ebp
80106278:	89 e5                	mov    %esp,%ebp
8010627a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010627d:	e8 3a d2 ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106282:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106285:	89 44 24 04          	mov    %eax,0x4(%esp)
80106289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106290:	e8 3c f5 ff ff       	call   801057d1 <argstr>
80106295:	85 c0                	test   %eax,%eax
80106297:	78 2c                	js     801062c5 <sys_mkdir+0x4e>
80106299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062a3:	00 
801062a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062ab:	00 
801062ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801062b3:	00 
801062b4:	89 04 24             	mov    %eax,(%esp)
801062b7:	e8 5f fc ff ff       	call   80105f1b <create>
801062bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062c3:	75 0c                	jne    801062d1 <sys_mkdir+0x5a>
    end_op();
801062c5:	e8 76 d2 ff ff       	call   80103540 <end_op>
    return -1;
801062ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062cf:	eb 15                	jmp    801062e6 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801062d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d4:	89 04 24             	mov    %eax,(%esp)
801062d7:	e8 82 b8 ff ff       	call   80101b5e <iunlockput>
  end_op();
801062dc:	e8 5f d2 ff ff       	call   80103540 <end_op>
  return 0;
801062e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062e6:	c9                   	leave  
801062e7:	c3                   	ret    

801062e8 <sys_mknod>:

int
sys_mknod(void)
{
801062e8:	55                   	push   %ebp
801062e9:	89 e5                	mov    %esp,%ebp
801062eb:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801062ee:	e8 c9 d1 ff ff       	call   801034bc <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801062f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801062fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106301:	e8 cb f4 ff ff       	call   801057d1 <argstr>
80106306:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106309:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630d:	78 5e                	js     8010636d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010630f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106312:	89 44 24 04          	mov    %eax,0x4(%esp)
80106316:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010631d:	e8 1f f4 ff ff       	call   80105741 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106322:	85 c0                	test   %eax,%eax
80106324:	78 47                	js     8010636d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106326:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106329:	89 44 24 04          	mov    %eax,0x4(%esp)
8010632d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106334:	e8 08 f4 ff ff       	call   80105741 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106339:	85 c0                	test   %eax,%eax
8010633b:	78 30                	js     8010636d <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010633d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106340:	0f bf c8             	movswl %ax,%ecx
80106343:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106346:	0f bf d0             	movswl %ax,%edx
80106349:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010634c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106350:	89 54 24 08          	mov    %edx,0x8(%esp)
80106354:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010635b:	00 
8010635c:	89 04 24             	mov    %eax,(%esp)
8010635f:	e8 b7 fb ff ff       	call   80105f1b <create>
80106364:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106367:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010636b:	75 0c                	jne    80106379 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010636d:	e8 ce d1 ff ff       	call   80103540 <end_op>
    return -1;
80106372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106377:	eb 15                	jmp    8010638e <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637c:	89 04 24             	mov    %eax,(%esp)
8010637f:	e8 da b7 ff ff       	call   80101b5e <iunlockput>
  end_op();
80106384:	e8 b7 d1 ff ff       	call   80103540 <end_op>
  return 0;
80106389:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010638e:	c9                   	leave  
8010638f:	c3                   	ret    

80106390 <sys_chdir>:

int
sys_chdir(void)
{
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106396:	e8 21 d1 ff ff       	call   801034bc <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010639b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010639e:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063a9:	e8 23 f4 ff ff       	call   801057d1 <argstr>
801063ae:	85 c0                	test   %eax,%eax
801063b0:	78 14                	js     801063c6 <sys_chdir+0x36>
801063b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b5:	89 04 24             	mov    %eax,(%esp)
801063b8:	e8 c8 c0 ff ff       	call   80102485 <namei>
801063bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063c4:	75 0c                	jne    801063d2 <sys_chdir+0x42>
    end_op();
801063c6:	e8 75 d1 ff ff       	call   80103540 <end_op>
    return -1;
801063cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d0:	eb 61                	jmp    80106433 <sys_chdir+0xa3>
  }
  ilock(ip);
801063d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d5:	89 04 24             	mov    %eax,(%esp)
801063d8:	e8 f7 b4 ff ff       	call   801018d4 <ilock>
  if(ip->type != T_DIR){
801063dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063e4:	66 83 f8 01          	cmp    $0x1,%ax
801063e8:	74 17                	je     80106401 <sys_chdir+0x71>
    iunlockput(ip);
801063ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ed:	89 04 24             	mov    %eax,(%esp)
801063f0:	e8 69 b7 ff ff       	call   80101b5e <iunlockput>
    end_op();
801063f5:	e8 46 d1 ff ff       	call   80103540 <end_op>
    return -1;
801063fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ff:	eb 32                	jmp    80106433 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106404:	89 04 24             	mov    %eax,(%esp)
80106407:	e8 1c b6 ff ff       	call   80101a28 <iunlock>
  iput(proc->cwd);
8010640c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106412:	8b 40 70             	mov    0x70(%eax),%eax
80106415:	89 04 24             	mov    %eax,(%esp)
80106418:	e8 70 b6 ff ff       	call   80101a8d <iput>
  end_op();
8010641d:	e8 1e d1 ff ff       	call   80103540 <end_op>
  proc->cwd = ip;
80106422:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106428:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010642b:	89 50 70             	mov    %edx,0x70(%eax)
  return 0;
8010642e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106433:	c9                   	leave  
80106434:	c3                   	ret    

80106435 <sys_exec>:

int
sys_exec(void)
{
80106435:	55                   	push   %ebp
80106436:	89 e5                	mov    %esp,%ebp
80106438:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010643e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106441:	89 44 24 04          	mov    %eax,0x4(%esp)
80106445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010644c:	e8 80 f3 ff ff       	call   801057d1 <argstr>
80106451:	85 c0                	test   %eax,%eax
80106453:	78 1a                	js     8010646f <sys_exec+0x3a>
80106455:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010645b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010645f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106466:	e8 d6 f2 ff ff       	call   80105741 <argint>
8010646b:	85 c0                	test   %eax,%eax
8010646d:	79 0a                	jns    80106479 <sys_exec+0x44>
    return -1;
8010646f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106474:	e9 c8 00 00 00       	jmp    80106541 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80106479:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106480:	00 
80106481:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106488:	00 
80106489:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010648f:	89 04 24             	mov    %eax,(%esp)
80106492:	e8 68 ef ff ff       	call   801053ff <memset>
  for(i=0;; i++){
80106497:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010649e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a1:	83 f8 1f             	cmp    $0x1f,%eax
801064a4:	76 0a                	jbe    801064b0 <sys_exec+0x7b>
      return -1;
801064a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ab:	e9 91 00 00 00       	jmp    80106541 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801064b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b3:	c1 e0 02             	shl    $0x2,%eax
801064b6:	89 c2                	mov    %eax,%edx
801064b8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064be:	01 c2                	add    %eax,%edx
801064c0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801064c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ca:	89 14 24             	mov    %edx,(%esp)
801064cd:	e8 d3 f1 ff ff       	call   801056a5 <fetchint>
801064d2:	85 c0                	test   %eax,%eax
801064d4:	79 07                	jns    801064dd <sys_exec+0xa8>
      return -1;
801064d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064db:	eb 64                	jmp    80106541 <sys_exec+0x10c>
    if(uarg == 0){
801064dd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064e3:	85 c0                	test   %eax,%eax
801064e5:	75 26                	jne    8010650d <sys_exec+0xd8>
      argv[i] = 0;
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801064f1:	00 00 00 00 
      break;
801064f5:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801064f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80106503:	89 04 24             	mov    %eax,(%esp)
80106506:	e8 ff a5 ff ff       	call   80100b0a <exec>
8010650b:	eb 34                	jmp    80106541 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010650d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106513:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106516:	c1 e2 02             	shl    $0x2,%edx
80106519:	01 c2                	add    %eax,%edx
8010651b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106521:	89 54 24 04          	mov    %edx,0x4(%esp)
80106525:	89 04 24             	mov    %eax,(%esp)
80106528:	e8 b2 f1 ff ff       	call   801056df <fetchstr>
8010652d:	85 c0                	test   %eax,%eax
8010652f:	79 07                	jns    80106538 <sys_exec+0x103>
      return -1;
80106531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106536:	eb 09                	jmp    80106541 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106538:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010653c:	e9 5d ff ff ff       	jmp    8010649e <sys_exec+0x69>
  return exec(path, argv);
}
80106541:	c9                   	leave  
80106542:	c3                   	ret    

80106543 <sys_pipe>:

int
sys_pipe(void)
{
80106543:	55                   	push   %ebp
80106544:	89 e5                	mov    %esp,%ebp
80106546:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106549:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106550:	00 
80106551:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106554:	89 44 24 04          	mov    %eax,0x4(%esp)
80106558:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010655f:	e8 0b f2 ff ff       	call   8010576f <argptr>
80106564:	85 c0                	test   %eax,%eax
80106566:	79 0a                	jns    80106572 <sys_pipe+0x2f>
    return -1;
80106568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656d:	e9 9a 00 00 00       	jmp    8010660c <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106572:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106575:	89 44 24 04          	mov    %eax,0x4(%esp)
80106579:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010657c:	89 04 24             	mov    %eax,(%esp)
8010657f:	e8 44 da ff ff       	call   80103fc8 <pipealloc>
80106584:	85 c0                	test   %eax,%eax
80106586:	79 07                	jns    8010658f <sys_pipe+0x4c>
    return -1;
80106588:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658d:	eb 7d                	jmp    8010660c <sys_pipe+0xc9>
  fd0 = -1;
8010658f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106596:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106599:	89 04 24             	mov    %eax,(%esp)
8010659c:	e8 6a f3 ff ff       	call   8010590b <fdalloc>
801065a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065a8:	78 14                	js     801065be <sys_pipe+0x7b>
801065aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ad:	89 04 24             	mov    %eax,(%esp)
801065b0:	e8 56 f3 ff ff       	call   8010590b <fdalloc>
801065b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065bc:	79 36                	jns    801065f4 <sys_pipe+0xb1>
    if(fd0 >= 0)
801065be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065c2:	78 13                	js     801065d7 <sys_pipe+0x94>
      proc->ofile[fd0] = 0;
801065c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065cd:	83 c2 0c             	add    $0xc,%edx
801065d0:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
    fileclose(rf);
801065d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065da:	89 04 24             	mov    %eax,(%esp)
801065dd:	e8 07 aa ff ff       	call   80100fe9 <fileclose>
    fileclose(wf);
801065e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065e5:	89 04 24             	mov    %eax,(%esp)
801065e8:	e8 fc a9 ff ff       	call   80100fe9 <fileclose>
    return -1;
801065ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f2:	eb 18                	jmp    8010660c <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801065f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065fa:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801065fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065ff:	8d 50 04             	lea    0x4(%eax),%edx
80106602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106605:	89 02                	mov    %eax,(%edx)
  return 0;
80106607:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010660c:	c9                   	leave  
8010660d:	c3                   	ret    

8010660e <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010660e:	55                   	push   %ebp
8010660f:	89 e5                	mov    %esp,%ebp
80106611:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106614:	e8 3f e1 ff ff       	call   80104758 <fork>
}
80106619:	c9                   	leave  
8010661a:	c3                   	ret    

8010661b <sys_exit>:

int
sys_exit(void)
{
8010661b:	55                   	push   %ebp
8010661c:	89 e5                	mov    %esp,%ebp
8010661e:	83 ec 08             	sub    $0x8,%esp
  exit();
80106621:	e8 c8 e2 ff ff       	call   801048ee <exit>
  return 0;  // not reached
80106626:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010662b:	c9                   	leave  
8010662c:	c3                   	ret    

8010662d <sys_wait>:

int
sys_wait(void)
{
8010662d:	55                   	push   %ebp
8010662e:	89 e5                	mov    %esp,%ebp
80106630:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106633:	e8 d8 e3 ff ff       	call   80104a10 <wait>
}
80106638:	c9                   	leave  
80106639:	c3                   	ret    

8010663a <sys_kill>:

int
sys_kill(void)
{
8010663a:	55                   	push   %ebp
8010663b:	89 e5                	mov    %esp,%ebp
8010663d:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106640:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106643:	89 44 24 04          	mov    %eax,0x4(%esp)
80106647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010664e:	e8 ee f0 ff ff       	call   80105741 <argint>
80106653:	85 c0                	test   %eax,%eax
80106655:	79 07                	jns    8010665e <sys_kill+0x24>
    return -1;
80106657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665c:	eb 0b                	jmp    80106669 <sys_kill+0x2f>
  return kill(pid);
8010665e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106661:	89 04 24             	mov    %eax,(%esp)
80106664:	e8 7e e7 ff ff       	call   80104de7 <kill>
}
80106669:	c9                   	leave  
8010666a:	c3                   	ret    

8010666b <sys_getpid>:

int
sys_getpid(void)
{
8010666b:	55                   	push   %ebp
8010666c:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010666e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106674:	8b 40 10             	mov    0x10(%eax),%eax
}
80106677:	5d                   	pop    %ebp
80106678:	c3                   	ret    

80106679 <sys_sbrk>:

int
sys_sbrk(void)
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010667f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106682:	89 44 24 04          	mov    %eax,0x4(%esp)
80106686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010668d:	e8 af f0 ff ff       	call   80105741 <argint>
80106692:	85 c0                	test   %eax,%eax
80106694:	79 07                	jns    8010669d <sys_sbrk+0x24>
    return -1;
80106696:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010669b:	eb 24                	jmp    801066c1 <sys_sbrk+0x48>
  addr = proc->sz;
8010669d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a3:	8b 00                	mov    (%eax),%eax
801066a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801066a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ab:	89 04 24             	mov    %eax,(%esp)
801066ae:	e8 00 e0 ff ff       	call   801046b3 <growproc>
801066b3:	85 c0                	test   %eax,%eax
801066b5:	79 07                	jns    801066be <sys_sbrk+0x45>
    return -1;
801066b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066bc:	eb 03                	jmp    801066c1 <sys_sbrk+0x48>
  return addr;
801066be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066c1:	c9                   	leave  
801066c2:	c3                   	ret    

801066c3 <sys_sleep>:

int
sys_sleep(void)
{
801066c3:	55                   	push   %ebp
801066c4:	89 e5                	mov    %esp,%ebp
801066c6:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801066c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801066d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066d7:	e8 65 f0 ff ff       	call   80105741 <argint>
801066dc:	85 c0                	test   %eax,%eax
801066de:	79 07                	jns    801066e7 <sys_sleep+0x24>
    return -1;
801066e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e5:	eb 6c                	jmp    80106753 <sys_sleep+0x90>
  acquire(&tickslock);
801066e7:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
801066ee:	e8 b8 ea ff ff       	call   801051ab <acquire>
  ticks0 = ticks;
801066f3:	a1 00 54 11 80       	mov    0x80115400,%eax
801066f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801066fb:	eb 34                	jmp    80106731 <sys_sleep+0x6e>
    if(proc->killed){
801066fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106703:	8b 40 2c             	mov    0x2c(%eax),%eax
80106706:	85 c0                	test   %eax,%eax
80106708:	74 13                	je     8010671d <sys_sleep+0x5a>
      release(&tickslock);
8010670a:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106711:	e8 f7 ea ff ff       	call   8010520d <release>
      return -1;
80106716:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671b:	eb 36                	jmp    80106753 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010671d:	c7 44 24 04 c0 4b 11 	movl   $0x80114bc0,0x4(%esp)
80106724:	80 
80106725:	c7 04 24 00 54 11 80 	movl   $0x80115400,(%esp)
8010672c:	e8 af e5 ff ff       	call   80104ce0 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106731:	a1 00 54 11 80       	mov    0x80115400,%eax
80106736:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106739:	89 c2                	mov    %eax,%edx
8010673b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673e:	39 c2                	cmp    %eax,%edx
80106740:	72 bb                	jb     801066fd <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106742:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106749:	e8 bf ea ff ff       	call   8010520d <release>
  return 0;
8010674e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106753:	c9                   	leave  
80106754:	c3                   	ret    

80106755 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106755:	55                   	push   %ebp
80106756:	89 e5                	mov    %esp,%ebp
80106758:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010675b:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106762:	e8 44 ea ff ff       	call   801051ab <acquire>
  xticks = ticks;
80106767:	a1 00 54 11 80       	mov    0x80115400,%eax
8010676c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010676f:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106776:	e8 92 ea ff ff       	call   8010520d <release>
  return xticks;
8010677b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010677e:	c9                   	leave  
8010677f:	c3                   	ret    

80106780 <sys_date>:
int
sys_date(rtcdate)
{
80106780:	55                   	push   %ebp
80106781:	89 e5                	mov    %esp,%ebp
80106783:	83 ec 28             	sub    $0x28,%esp

 struct rtcdate *d;
 argptr(0, (void*)&d, sizeof(*d));
80106786:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010678d:	00 
8010678e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106791:	89 44 24 04          	mov    %eax,0x4(%esp)
80106795:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010679c:	e8 ce ef ff ff       	call   8010576f <argptr>
cmostime(d);
801067a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a4:	89 04 24             	mov    %eax,(%esp)
801067a7:	e8 aa c9 ff ff       	call   80103156 <cmostime>

return 0;
801067ac:	b8 00 00 00 00       	mov    $0x0,%eax

}
801067b1:	c9                   	leave  
801067b2:	c3                   	ret    

801067b3 <sys_timem>:
int
sys_timem(void)
{
801067b3:	55                   	push   %ebp
801067b4:	89 e5                	mov    %esp,%ebp
return 0;
801067b6:	b8 00 00 00 00       	mov    $0x0,%eax

}
801067bb:	5d                   	pop    %ebp
801067bc:	c3                   	ret    

801067bd <sys_getuid>:


int
sys_getuid(void)
{
801067bd:	55                   	push   %ebp
801067be:	89 e5                	mov    %esp,%ebp
	//int newid=5;
//proc->uid=newid;
  return proc->uid;
801067c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067c6:	8b 40 14             	mov    0x14(%eax),%eax

}
801067c9:	5d                   	pop    %ebp
801067ca:	c3                   	ret    

801067cb <sys_getgid>:
int
sys_getgid(void)
{
801067cb:	55                   	push   %ebp
801067cc:	89 e5                	mov    %esp,%ebp
  return proc->gid;
801067ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067d4:	8b 40 18             	mov    0x18(%eax),%eax

}
801067d7:	5d                   	pop    %ebp
801067d8:	c3                   	ret    

801067d9 <sys_getppid>:

int
sys_getppid(void)
{
801067d9:	55                   	push   %ebp
801067da:	89 e5                	mov    %esp,%ebp
  return proc->parent->pid;
801067dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067e2:	8b 40 1c             	mov    0x1c(%eax),%eax
801067e5:	8b 40 10             	mov    0x10(%eax),%eax

}
801067e8:	5d                   	pop    %ebp
801067e9:	c3                   	ret    

801067ea <sys_setuid>:

int
sys_setuid(void)
{
801067ea:	55                   	push   %ebp
801067eb:	89 e5                	mov    %esp,%ebp
801067ed:	83 ec 28             	sub    $0x28,%esp
  int fuid;

  if(argint(0, &fuid) < 0)
801067f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801067f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067fe:	e8 3e ef ff ff       	call   80105741 <argint>
80106803:	85 c0                	test   %eax,%eax
80106805:	79 07                	jns    8010680e <sys_setuid+0x24>
    return -1;
80106807:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010680c:	eb 11                	jmp    8010681f <sys_setuid+0x35>
proc->uid=fuid;
8010680e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106814:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106817:	89 50 14             	mov    %edx,0x14(%eax)
return 0;
8010681a:	b8 00 00 00 00       	mov    $0x0,%eax

}
8010681f:	c9                   	leave  
80106820:	c3                   	ret    

80106821 <sys_setgid>:
int
sys_setgid(void)
{
80106821:	55                   	push   %ebp
80106822:	89 e5                	mov    %esp,%ebp
80106824:	83 ec 28             	sub    $0x28,%esp
  int fgid;

  if(argint(0, &fgid) < 0)
80106827:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010682a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010682e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106835:	e8 07 ef ff ff       	call   80105741 <argint>
8010683a:	85 c0                	test   %eax,%eax
8010683c:	79 07                	jns    80106845 <sys_setgid+0x24>
    return -1;
8010683e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106843:	eb 11                	jmp    80106856 <sys_setgid+0x35>
proc->gid=fgid;
80106845:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010684b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010684e:	89 50 18             	mov    %edx,0x18(%eax)
return 0;
80106851:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106856:	c9                   	leave  
80106857:	c3                   	ret    

80106858 <sys_getprocs>:

int
sys_getprocs(void)
{
80106858:	55                   	push   %ebp
80106859:	89 e5                	mov    %esp,%ebp
8010685b:	83 ec 28             	sub    $0x28,%esp
int max;
struct uproc *table;

if (argint(0, (void*)&max) < 0) {
8010685e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106861:	89 44 24 04          	mov    %eax,0x4(%esp)
80106865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010686c:	e8 d0 ee ff ff       	call   80105741 <argint>
80106871:	85 c0                	test   %eax,%eax
80106873:	79 07                	jns    8010687c <sys_getprocs+0x24>
return -1;
80106875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687a:	eb 38                	jmp    801068b4 <sys_getprocs+0x5c>
}

if (argptr(1, (void*)&table, sizeof(*table)) < 0) {
8010687c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80106883:	00 
80106884:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106887:	89 44 24 04          	mov    %eax,0x4(%esp)
8010688b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106892:	e8 d8 ee ff ff       	call   8010576f <argptr>
80106897:	85 c0                	test   %eax,%eax
80106899:	79 07                	jns    801068a2 <sys_getprocs+0x4a>
return -1;
8010689b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068a0:	eb 12                	jmp    801068b4 <sys_getprocs+0x5c>
}
//return 0;
return getProcInfo(max, table);
801068a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801068a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801068ac:	89 04 24             	mov    %eax,(%esp)
801068af:	e8 c1 e6 ff ff       	call   80104f75 <getProcInfo>
801068b4:	c9                   	leave  
801068b5:	c3                   	ret    

801068b6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801068b6:	55                   	push   %ebp
801068b7:	89 e5                	mov    %esp,%ebp
801068b9:	83 ec 08             	sub    $0x8,%esp
801068bc:	8b 55 08             	mov    0x8(%ebp),%edx
801068bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801068c2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801068c6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068c9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068cd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068d1:	ee                   	out    %al,(%dx)
}
801068d2:	c9                   	leave  
801068d3:	c3                   	ret    

801068d4 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801068d4:	55                   	push   %ebp
801068d5:	89 e5                	mov    %esp,%ebp
801068d7:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801068da:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801068e1:	00 
801068e2:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801068e9:	e8 c8 ff ff ff       	call   801068b6 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801068ee:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801068f5:	00 
801068f6:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068fd:	e8 b4 ff ff ff       	call   801068b6 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106902:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106909:	00 
8010690a:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106911:	e8 a0 ff ff ff       	call   801068b6 <outb>
  picenable(IRQ_TIMER);
80106916:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010691d:	e8 39 d5 ff ff       	call   80103e5b <picenable>
}
80106922:	c9                   	leave  
80106923:	c3                   	ret    

80106924 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106924:	1e                   	push   %ds
  pushl %es
80106925:	06                   	push   %es
  pushl %fs
80106926:	0f a0                	push   %fs
  pushl %gs
80106928:	0f a8                	push   %gs
  pushal
8010692a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010692b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010692f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106931:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106933:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106937:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106939:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010693b:	54                   	push   %esp
  call trap
8010693c:	e8 d8 01 00 00       	call   80106b19 <trap>
  addl $4, %esp
80106941:	83 c4 04             	add    $0x4,%esp

80106944 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106944:	61                   	popa   
  popl %gs
80106945:	0f a9                	pop    %gs
  popl %fs
80106947:	0f a1                	pop    %fs
  popl %es
80106949:	07                   	pop    %es
  popl %ds
8010694a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010694b:	83 c4 08             	add    $0x8,%esp
  iret
8010694e:	cf                   	iret   

8010694f <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010694f:	55                   	push   %ebp
80106950:	89 e5                	mov    %esp,%ebp
80106952:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106955:	8b 45 0c             	mov    0xc(%ebp),%eax
80106958:	83 e8 01             	sub    $0x1,%eax
8010695b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010695f:	8b 45 08             	mov    0x8(%ebp),%eax
80106962:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106966:	8b 45 08             	mov    0x8(%ebp),%eax
80106969:	c1 e8 10             	shr    $0x10,%eax
8010696c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106970:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106973:	0f 01 18             	lidtl  (%eax)
}
80106976:	c9                   	leave  
80106977:	c3                   	ret    

80106978 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106978:	55                   	push   %ebp
80106979:	89 e5                	mov    %esp,%ebp
8010697b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010697e:	0f 20 d0             	mov    %cr2,%eax
80106981:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106984:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106987:	c9                   	leave  
80106988:	c3                   	ret    

80106989 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106989:	55                   	push   %ebp
8010698a:	89 e5                	mov    %esp,%ebp
8010698c:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010698f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106996:	e9 c3 00 00 00       	jmp    80106a5e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010699b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699e:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
801069a5:	89 c2                	mov    %eax,%edx
801069a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069aa:	66 89 14 c5 00 4c 11 	mov    %dx,-0x7feeb400(,%eax,8)
801069b1:	80 
801069b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b5:	66 c7 04 c5 02 4c 11 	movw   $0x8,-0x7feeb3fe(,%eax,8)
801069bc:	80 08 00 
801069bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c2:	0f b6 14 c5 04 4c 11 	movzbl -0x7feeb3fc(,%eax,8),%edx
801069c9:	80 
801069ca:	83 e2 e0             	and    $0xffffffe0,%edx
801069cd:	88 14 c5 04 4c 11 80 	mov    %dl,-0x7feeb3fc(,%eax,8)
801069d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d7:	0f b6 14 c5 04 4c 11 	movzbl -0x7feeb3fc(,%eax,8),%edx
801069de:	80 
801069df:	83 e2 1f             	and    $0x1f,%edx
801069e2:	88 14 c5 04 4c 11 80 	mov    %dl,-0x7feeb3fc(,%eax,8)
801069e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ec:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
801069f3:	80 
801069f4:	83 e2 f0             	and    $0xfffffff0,%edx
801069f7:	83 ca 0e             	or     $0xe,%edx
801069fa:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
80106a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a04:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
80106a0b:	80 
80106a0c:	83 e2 ef             	and    $0xffffffef,%edx
80106a0f:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
80106a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a19:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
80106a20:	80 
80106a21:	83 e2 9f             	and    $0xffffff9f,%edx
80106a24:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
80106a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2e:	0f b6 14 c5 05 4c 11 	movzbl -0x7feeb3fb(,%eax,8),%edx
80106a35:	80 
80106a36:	83 ca 80             	or     $0xffffff80,%edx
80106a39:	88 14 c5 05 4c 11 80 	mov    %dl,-0x7feeb3fb(,%eax,8)
80106a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a43:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
80106a4a:	c1 e8 10             	shr    $0x10,%eax
80106a4d:	89 c2                	mov    %eax,%edx
80106a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a52:	66 89 14 c5 06 4c 11 	mov    %dx,-0x7feeb3fa(,%eax,8)
80106a59:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106a5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a5e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a65:	0f 8e 30 ff ff ff    	jle    8010699b <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a6b:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
80106a70:	66 a3 00 4e 11 80    	mov    %ax,0x80114e00
80106a76:	66 c7 05 02 4e 11 80 	movw   $0x8,0x80114e02
80106a7d:	08 00 
80106a7f:	0f b6 05 04 4e 11 80 	movzbl 0x80114e04,%eax
80106a86:	83 e0 e0             	and    $0xffffffe0,%eax
80106a89:	a2 04 4e 11 80       	mov    %al,0x80114e04
80106a8e:	0f b6 05 04 4e 11 80 	movzbl 0x80114e04,%eax
80106a95:	83 e0 1f             	and    $0x1f,%eax
80106a98:	a2 04 4e 11 80       	mov    %al,0x80114e04
80106a9d:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106aa4:	83 c8 0f             	or     $0xf,%eax
80106aa7:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106aac:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106ab3:	83 e0 ef             	and    $0xffffffef,%eax
80106ab6:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106abb:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106ac2:	83 c8 60             	or     $0x60,%eax
80106ac5:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106aca:	0f b6 05 05 4e 11 80 	movzbl 0x80114e05,%eax
80106ad1:	83 c8 80             	or     $0xffffff80,%eax
80106ad4:	a2 05 4e 11 80       	mov    %al,0x80114e05
80106ad9:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
80106ade:	c1 e8 10             	shr    $0x10,%eax
80106ae1:	66 a3 06 4e 11 80    	mov    %ax,0x80114e06
  
  initlock(&tickslock, "time");
80106ae7:	c7 44 24 04 b0 8d 10 	movl   $0x80108db0,0x4(%esp)
80106aee:	80 
80106aef:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106af6:	e8 8f e6 ff ff       	call   8010518a <initlock>
}
80106afb:	c9                   	leave  
80106afc:	c3                   	ret    

80106afd <idtinit>:

void
idtinit(void)
{
80106afd:	55                   	push   %ebp
80106afe:	89 e5                	mov    %esp,%ebp
80106b00:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106b03:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106b0a:	00 
80106b0b:	c7 04 24 00 4c 11 80 	movl   $0x80114c00,(%esp)
80106b12:	e8 38 fe ff ff       	call   8010694f <lidt>
}
80106b17:	c9                   	leave  
80106b18:	c3                   	ret    

80106b19 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106b19:	55                   	push   %ebp
80106b1a:	89 e5                	mov    %esp,%ebp
80106b1c:	57                   	push   %edi
80106b1d:	56                   	push   %esi
80106b1e:	53                   	push   %ebx
80106b1f:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106b22:	8b 45 08             	mov    0x8(%ebp),%eax
80106b25:	8b 40 30             	mov    0x30(%eax),%eax
80106b28:	83 f8 40             	cmp    $0x40,%eax
80106b2b:	75 3f                	jne    80106b6c <trap+0x53>
    if(proc->killed)
80106b2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b33:	8b 40 2c             	mov    0x2c(%eax),%eax
80106b36:	85 c0                	test   %eax,%eax
80106b38:	74 05                	je     80106b3f <trap+0x26>
      exit();
80106b3a:	e8 af dd ff ff       	call   801048ee <exit>
    proc->tf = tf;
80106b3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b45:	8b 55 08             	mov    0x8(%ebp),%edx
80106b48:	89 50 20             	mov    %edx,0x20(%eax)
    syscall();
80106b4b:	e8 b8 ec ff ff       	call   80105808 <syscall>
    if(proc->killed)
80106b50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b56:	8b 40 2c             	mov    0x2c(%eax),%eax
80106b59:	85 c0                	test   %eax,%eax
80106b5b:	74 0a                	je     80106b67 <trap+0x4e>
      exit();
80106b5d:	e8 8c dd ff ff       	call   801048ee <exit>
    return;
80106b62:	e9 2d 02 00 00       	jmp    80106d94 <trap+0x27b>
80106b67:	e9 28 02 00 00       	jmp    80106d94 <trap+0x27b>
  }

  switch(tf->trapno){
80106b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b6f:	8b 40 30             	mov    0x30(%eax),%eax
80106b72:	83 e8 20             	sub    $0x20,%eax
80106b75:	83 f8 1f             	cmp    $0x1f,%eax
80106b78:	0f 87 bc 00 00 00    	ja     80106c3a <trap+0x121>
80106b7e:	8b 04 85 58 8e 10 80 	mov    -0x7fef71a8(,%eax,4),%eax
80106b85:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b87:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b8d:	0f b6 00             	movzbl (%eax),%eax
80106b90:	84 c0                	test   %al,%al
80106b92:	75 31                	jne    80106bc5 <trap+0xac>
      acquire(&tickslock);
80106b94:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106b9b:	e8 0b e6 ff ff       	call   801051ab <acquire>
      ticks++;
80106ba0:	a1 00 54 11 80       	mov    0x80115400,%eax
80106ba5:	83 c0 01             	add    $0x1,%eax
80106ba8:	a3 00 54 11 80       	mov    %eax,0x80115400
      wakeup(&ticks);
80106bad:	c7 04 24 00 54 11 80 	movl   $0x80115400,(%esp)
80106bb4:	e8 03 e2 ff ff       	call   80104dbc <wakeup>
      release(&tickslock);
80106bb9:	c7 04 24 c0 4b 11 80 	movl   $0x80114bc0,(%esp)
80106bc0:	e8 48 e6 ff ff       	call   8010520d <release>
    }
    lapiceoi();
80106bc5:	e8 bc c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106bca:	e9 41 01 00 00       	jmp    80106d10 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106bcf:	e8 c0 bb ff ff       	call   80102794 <ideintr>
    lapiceoi();
80106bd4:	e8 ad c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106bd9:	e9 32 01 00 00       	jmp    80106d10 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bde:	e8 72 c1 ff ff       	call   80102d55 <kbdintr>
    lapiceoi();
80106be3:	e8 9e c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106be8:	e9 23 01 00 00       	jmp    80106d10 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bed:	e8 97 03 00 00       	call   80106f89 <uartintr>
    lapiceoi();
80106bf2:	e8 8f c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106bf7:	e9 14 01 00 00       	jmp    80106d10 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80106bff:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106c02:	8b 45 08             	mov    0x8(%ebp),%eax
80106c05:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c09:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106c0c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c12:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c15:	0f b6 c0             	movzbl %al,%eax
80106c18:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c1c:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c20:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c24:	c7 04 24 b8 8d 10 80 	movl   $0x80108db8,(%esp)
80106c2b:	e8 70 97 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106c30:	e8 51 c3 ff ff       	call   80102f86 <lapiceoi>
    break;
80106c35:	e9 d6 00 00 00       	jmp    80106d10 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c40:	85 c0                	test   %eax,%eax
80106c42:	74 11                	je     80106c55 <trap+0x13c>
80106c44:	8b 45 08             	mov    0x8(%ebp),%eax
80106c47:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c4b:	0f b7 c0             	movzwl %ax,%eax
80106c4e:	83 e0 03             	and    $0x3,%eax
80106c51:	85 c0                	test   %eax,%eax
80106c53:	75 46                	jne    80106c9b <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c55:	e8 1e fd ff ff       	call   80106978 <rcr2>
80106c5a:	8b 55 08             	mov    0x8(%ebp),%edx
80106c5d:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c60:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c67:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c6a:	0f b6 ca             	movzbl %dl,%ecx
80106c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80106c70:	8b 52 30             	mov    0x30(%edx),%edx
80106c73:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c77:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c7f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c83:	c7 04 24 dc 8d 10 80 	movl   $0x80108ddc,(%esp)
80106c8a:	e8 11 97 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c8f:	c7 04 24 0e 8e 10 80 	movl   $0x80108e0e,(%esp)
80106c96:	e8 9f 98 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c9b:	e8 d8 fc ff ff       	call   80106978 <rcr2>
80106ca0:	89 c2                	mov    %eax,%edx
80106ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca5:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ca8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106cae:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cb1:	0f b6 f0             	movzbl %al,%esi
80106cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb7:	8b 58 34             	mov    0x34(%eax),%ebx
80106cba:	8b 45 08             	mov    0x8(%ebp),%eax
80106cbd:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106cc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc6:	83 c0 78             	add    $0x78,%eax
80106cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ccc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cd2:	8b 40 10             	mov    0x10(%eax),%eax
80106cd5:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106cd9:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106cdd:	89 74 24 14          	mov    %esi,0x14(%esp)
80106ce1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106ce5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ce9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106cec:	89 74 24 08          	mov    %esi,0x8(%esp)
80106cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cf4:	c7 04 24 14 8e 10 80 	movl   $0x80108e14,(%esp)
80106cfb:	e8 a0 96 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106d00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d06:	c7 40 2c 01 00 00 00 	movl   $0x1,0x2c(%eax)
80106d0d:	eb 01                	jmp    80106d10 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106d0f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d16:	85 c0                	test   %eax,%eax
80106d18:	74 24                	je     80106d3e <trap+0x225>
80106d1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d20:	8b 40 2c             	mov    0x2c(%eax),%eax
80106d23:	85 c0                	test   %eax,%eax
80106d25:	74 17                	je     80106d3e <trap+0x225>
80106d27:	8b 45 08             	mov    0x8(%ebp),%eax
80106d2a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d2e:	0f b7 c0             	movzwl %ax,%eax
80106d31:	83 e0 03             	and    $0x3,%eax
80106d34:	83 f8 03             	cmp    $0x3,%eax
80106d37:	75 05                	jne    80106d3e <trap+0x225>
    exit();
80106d39:	e8 b0 db ff ff       	call   801048ee <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106d3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d44:	85 c0                	test   %eax,%eax
80106d46:	74 1e                	je     80106d66 <trap+0x24d>
80106d48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d4e:	8b 40 0c             	mov    0xc(%eax),%eax
80106d51:	83 f8 04             	cmp    $0x4,%eax
80106d54:	75 10                	jne    80106d66 <trap+0x24d>
80106d56:	8b 45 08             	mov    0x8(%ebp),%eax
80106d59:	8b 40 30             	mov    0x30(%eax),%eax
80106d5c:	83 f8 20             	cmp    $0x20,%eax
80106d5f:	75 05                	jne    80106d66 <trap+0x24d>
    yield();
80106d61:	e8 09 df ff ff       	call   80104c6f <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d6c:	85 c0                	test   %eax,%eax
80106d6e:	74 24                	je     80106d94 <trap+0x27b>
80106d70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d76:	8b 40 2c             	mov    0x2c(%eax),%eax
80106d79:	85 c0                	test   %eax,%eax
80106d7b:	74 17                	je     80106d94 <trap+0x27b>
80106d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d84:	0f b7 c0             	movzwl %ax,%eax
80106d87:	83 e0 03             	and    $0x3,%eax
80106d8a:	83 f8 03             	cmp    $0x3,%eax
80106d8d:	75 05                	jne    80106d94 <trap+0x27b>
    exit();
80106d8f:	e8 5a db ff ff       	call   801048ee <exit>
}
80106d94:	83 c4 3c             	add    $0x3c,%esp
80106d97:	5b                   	pop    %ebx
80106d98:	5e                   	pop    %esi
80106d99:	5f                   	pop    %edi
80106d9a:	5d                   	pop    %ebp
80106d9b:	c3                   	ret    

80106d9c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d9c:	55                   	push   %ebp
80106d9d:	89 e5                	mov    %esp,%ebp
80106d9f:	83 ec 14             	sub    $0x14,%esp
80106da2:	8b 45 08             	mov    0x8(%ebp),%eax
80106da5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106da9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106dad:	89 c2                	mov    %eax,%edx
80106daf:	ec                   	in     (%dx),%al
80106db0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106db3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106db7:	c9                   	leave  
80106db8:	c3                   	ret    

80106db9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106db9:	55                   	push   %ebp
80106dba:	89 e5                	mov    %esp,%ebp
80106dbc:	83 ec 08             	sub    $0x8,%esp
80106dbf:	8b 55 08             	mov    0x8(%ebp),%edx
80106dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dc5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106dc9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106dcc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106dd0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106dd4:	ee                   	out    %al,(%dx)
}
80106dd5:	c9                   	leave  
80106dd6:	c3                   	ret    

80106dd7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106dd7:	55                   	push   %ebp
80106dd8:	89 e5                	mov    %esp,%ebp
80106dda:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ddd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106de4:	00 
80106de5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106dec:	e8 c8 ff ff ff       	call   80106db9 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106df1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106df8:	00 
80106df9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e00:	e8 b4 ff ff ff       	call   80106db9 <outb>
  outb(COM1+0, 115200/9600);
80106e05:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106e0c:	00 
80106e0d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e14:	e8 a0 ff ff ff       	call   80106db9 <outb>
  outb(COM1+1, 0);
80106e19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e20:	00 
80106e21:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e28:	e8 8c ff ff ff       	call   80106db9 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e2d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106e34:	00 
80106e35:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e3c:	e8 78 ff ff ff       	call   80106db9 <outb>
  outb(COM1+4, 0);
80106e41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e48:	00 
80106e49:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e50:	e8 64 ff ff ff       	call   80106db9 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e5c:	00 
80106e5d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e64:	e8 50 ff ff ff       	call   80106db9 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e69:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e70:	e8 27 ff ff ff       	call   80106d9c <inb>
80106e75:	3c ff                	cmp    $0xff,%al
80106e77:	75 02                	jne    80106e7b <uartinit+0xa4>
    return;
80106e79:	eb 6a                	jmp    80106ee5 <uartinit+0x10e>
  uart = 1;
80106e7b:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
80106e82:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e85:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e8c:	e8 0b ff ff ff       	call   80106d9c <inb>
  inb(COM1+0);
80106e91:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e98:	e8 ff fe ff ff       	call   80106d9c <inb>
  picenable(IRQ_COM1);
80106e9d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ea4:	e8 b2 cf ff ff       	call   80103e5b <picenable>
  ioapicenable(IRQ_COM1, 0);
80106ea9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106eb0:	00 
80106eb1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106eb8:	e8 56 bb ff ff       	call   80102a13 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ebd:	c7 45 f4 d8 8e 10 80 	movl   $0x80108ed8,-0xc(%ebp)
80106ec4:	eb 15                	jmp    80106edb <uartinit+0x104>
    uartputc(*p);
80106ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec9:	0f b6 00             	movzbl (%eax),%eax
80106ecc:	0f be c0             	movsbl %al,%eax
80106ecf:	89 04 24             	mov    %eax,(%esp)
80106ed2:	e8 10 00 00 00       	call   80106ee7 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ed7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ede:	0f b6 00             	movzbl (%eax),%eax
80106ee1:	84 c0                	test   %al,%al
80106ee3:	75 e1                	jne    80106ec6 <uartinit+0xef>
    uartputc(*p);
}
80106ee5:	c9                   	leave  
80106ee6:	c3                   	ret    

80106ee7 <uartputc>:

void
uartputc(int c)
{
80106ee7:	55                   	push   %ebp
80106ee8:	89 e5                	mov    %esp,%ebp
80106eea:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106eed:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106ef2:	85 c0                	test   %eax,%eax
80106ef4:	75 02                	jne    80106ef8 <uartputc+0x11>
    return;
80106ef6:	eb 4b                	jmp    80106f43 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ef8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106eff:	eb 10                	jmp    80106f11 <uartputc+0x2a>
    microdelay(10);
80106f01:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106f08:	e8 9e c0 ff ff       	call   80102fab <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f11:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f15:	7f 16                	jg     80106f2d <uartputc+0x46>
80106f17:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f1e:	e8 79 fe ff ff       	call   80106d9c <inb>
80106f23:	0f b6 c0             	movzbl %al,%eax
80106f26:	83 e0 20             	and    $0x20,%eax
80106f29:	85 c0                	test   %eax,%eax
80106f2b:	74 d4                	je     80106f01 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f30:	0f b6 c0             	movzbl %al,%eax
80106f33:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f37:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f3e:	e8 76 fe ff ff       	call   80106db9 <outb>
}
80106f43:	c9                   	leave  
80106f44:	c3                   	ret    

80106f45 <uartgetc>:

static int
uartgetc(void)
{
80106f45:	55                   	push   %ebp
80106f46:	89 e5                	mov    %esp,%ebp
80106f48:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f4b:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106f50:	85 c0                	test   %eax,%eax
80106f52:	75 07                	jne    80106f5b <uartgetc+0x16>
    return -1;
80106f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f59:	eb 2c                	jmp    80106f87 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f5b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f62:	e8 35 fe ff ff       	call   80106d9c <inb>
80106f67:	0f b6 c0             	movzbl %al,%eax
80106f6a:	83 e0 01             	and    $0x1,%eax
80106f6d:	85 c0                	test   %eax,%eax
80106f6f:	75 07                	jne    80106f78 <uartgetc+0x33>
    return -1;
80106f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f76:	eb 0f                	jmp    80106f87 <uartgetc+0x42>
  return inb(COM1+0);
80106f78:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f7f:	e8 18 fe ff ff       	call   80106d9c <inb>
80106f84:	0f b6 c0             	movzbl %al,%eax
}
80106f87:	c9                   	leave  
80106f88:	c3                   	ret    

80106f89 <uartintr>:

void
uartintr(void)
{
80106f89:	55                   	push   %ebp
80106f8a:	89 e5                	mov    %esp,%ebp
80106f8c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f8f:	c7 04 24 45 6f 10 80 	movl   $0x80106f45,(%esp)
80106f96:	e8 2d 98 ff ff       	call   801007c8 <consoleintr>
}
80106f9b:	c9                   	leave  
80106f9c:	c3                   	ret    

80106f9d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $0
80106f9f:	6a 00                	push   $0x0
  jmp alltraps
80106fa1:	e9 7e f9 ff ff       	jmp    80106924 <alltraps>

80106fa6 <vector1>:
.globl vector1
vector1:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $1
80106fa8:	6a 01                	push   $0x1
  jmp alltraps
80106faa:	e9 75 f9 ff ff       	jmp    80106924 <alltraps>

80106faf <vector2>:
.globl vector2
vector2:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $2
80106fb1:	6a 02                	push   $0x2
  jmp alltraps
80106fb3:	e9 6c f9 ff ff       	jmp    80106924 <alltraps>

80106fb8 <vector3>:
.globl vector3
vector3:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $3
80106fba:	6a 03                	push   $0x3
  jmp alltraps
80106fbc:	e9 63 f9 ff ff       	jmp    80106924 <alltraps>

80106fc1 <vector4>:
.globl vector4
vector4:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $4
80106fc3:	6a 04                	push   $0x4
  jmp alltraps
80106fc5:	e9 5a f9 ff ff       	jmp    80106924 <alltraps>

80106fca <vector5>:
.globl vector5
vector5:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $5
80106fcc:	6a 05                	push   $0x5
  jmp alltraps
80106fce:	e9 51 f9 ff ff       	jmp    80106924 <alltraps>

80106fd3 <vector6>:
.globl vector6
vector6:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $6
80106fd5:	6a 06                	push   $0x6
  jmp alltraps
80106fd7:	e9 48 f9 ff ff       	jmp    80106924 <alltraps>

80106fdc <vector7>:
.globl vector7
vector7:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $7
80106fde:	6a 07                	push   $0x7
  jmp alltraps
80106fe0:	e9 3f f9 ff ff       	jmp    80106924 <alltraps>

80106fe5 <vector8>:
.globl vector8
vector8:
  pushl $8
80106fe5:	6a 08                	push   $0x8
  jmp alltraps
80106fe7:	e9 38 f9 ff ff       	jmp    80106924 <alltraps>

80106fec <vector9>:
.globl vector9
vector9:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $9
80106fee:	6a 09                	push   $0x9
  jmp alltraps
80106ff0:	e9 2f f9 ff ff       	jmp    80106924 <alltraps>

80106ff5 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ff5:	6a 0a                	push   $0xa
  jmp alltraps
80106ff7:	e9 28 f9 ff ff       	jmp    80106924 <alltraps>

80106ffc <vector11>:
.globl vector11
vector11:
  pushl $11
80106ffc:	6a 0b                	push   $0xb
  jmp alltraps
80106ffe:	e9 21 f9 ff ff       	jmp    80106924 <alltraps>

80107003 <vector12>:
.globl vector12
vector12:
  pushl $12
80107003:	6a 0c                	push   $0xc
  jmp alltraps
80107005:	e9 1a f9 ff ff       	jmp    80106924 <alltraps>

8010700a <vector13>:
.globl vector13
vector13:
  pushl $13
8010700a:	6a 0d                	push   $0xd
  jmp alltraps
8010700c:	e9 13 f9 ff ff       	jmp    80106924 <alltraps>

80107011 <vector14>:
.globl vector14
vector14:
  pushl $14
80107011:	6a 0e                	push   $0xe
  jmp alltraps
80107013:	e9 0c f9 ff ff       	jmp    80106924 <alltraps>

80107018 <vector15>:
.globl vector15
vector15:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $15
8010701a:	6a 0f                	push   $0xf
  jmp alltraps
8010701c:	e9 03 f9 ff ff       	jmp    80106924 <alltraps>

80107021 <vector16>:
.globl vector16
vector16:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $16
80107023:	6a 10                	push   $0x10
  jmp alltraps
80107025:	e9 fa f8 ff ff       	jmp    80106924 <alltraps>

8010702a <vector17>:
.globl vector17
vector17:
  pushl $17
8010702a:	6a 11                	push   $0x11
  jmp alltraps
8010702c:	e9 f3 f8 ff ff       	jmp    80106924 <alltraps>

80107031 <vector18>:
.globl vector18
vector18:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $18
80107033:	6a 12                	push   $0x12
  jmp alltraps
80107035:	e9 ea f8 ff ff       	jmp    80106924 <alltraps>

8010703a <vector19>:
.globl vector19
vector19:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $19
8010703c:	6a 13                	push   $0x13
  jmp alltraps
8010703e:	e9 e1 f8 ff ff       	jmp    80106924 <alltraps>

80107043 <vector20>:
.globl vector20
vector20:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $20
80107045:	6a 14                	push   $0x14
  jmp alltraps
80107047:	e9 d8 f8 ff ff       	jmp    80106924 <alltraps>

8010704c <vector21>:
.globl vector21
vector21:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $21
8010704e:	6a 15                	push   $0x15
  jmp alltraps
80107050:	e9 cf f8 ff ff       	jmp    80106924 <alltraps>

80107055 <vector22>:
.globl vector22
vector22:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $22
80107057:	6a 16                	push   $0x16
  jmp alltraps
80107059:	e9 c6 f8 ff ff       	jmp    80106924 <alltraps>

8010705e <vector23>:
.globl vector23
vector23:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $23
80107060:	6a 17                	push   $0x17
  jmp alltraps
80107062:	e9 bd f8 ff ff       	jmp    80106924 <alltraps>

80107067 <vector24>:
.globl vector24
vector24:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $24
80107069:	6a 18                	push   $0x18
  jmp alltraps
8010706b:	e9 b4 f8 ff ff       	jmp    80106924 <alltraps>

80107070 <vector25>:
.globl vector25
vector25:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $25
80107072:	6a 19                	push   $0x19
  jmp alltraps
80107074:	e9 ab f8 ff ff       	jmp    80106924 <alltraps>

80107079 <vector26>:
.globl vector26
vector26:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $26
8010707b:	6a 1a                	push   $0x1a
  jmp alltraps
8010707d:	e9 a2 f8 ff ff       	jmp    80106924 <alltraps>

80107082 <vector27>:
.globl vector27
vector27:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $27
80107084:	6a 1b                	push   $0x1b
  jmp alltraps
80107086:	e9 99 f8 ff ff       	jmp    80106924 <alltraps>

8010708b <vector28>:
.globl vector28
vector28:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $28
8010708d:	6a 1c                	push   $0x1c
  jmp alltraps
8010708f:	e9 90 f8 ff ff       	jmp    80106924 <alltraps>

80107094 <vector29>:
.globl vector29
vector29:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $29
80107096:	6a 1d                	push   $0x1d
  jmp alltraps
80107098:	e9 87 f8 ff ff       	jmp    80106924 <alltraps>

8010709d <vector30>:
.globl vector30
vector30:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $30
8010709f:	6a 1e                	push   $0x1e
  jmp alltraps
801070a1:	e9 7e f8 ff ff       	jmp    80106924 <alltraps>

801070a6 <vector31>:
.globl vector31
vector31:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $31
801070a8:	6a 1f                	push   $0x1f
  jmp alltraps
801070aa:	e9 75 f8 ff ff       	jmp    80106924 <alltraps>

801070af <vector32>:
.globl vector32
vector32:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $32
801070b1:	6a 20                	push   $0x20
  jmp alltraps
801070b3:	e9 6c f8 ff ff       	jmp    80106924 <alltraps>

801070b8 <vector33>:
.globl vector33
vector33:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $33
801070ba:	6a 21                	push   $0x21
  jmp alltraps
801070bc:	e9 63 f8 ff ff       	jmp    80106924 <alltraps>

801070c1 <vector34>:
.globl vector34
vector34:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $34
801070c3:	6a 22                	push   $0x22
  jmp alltraps
801070c5:	e9 5a f8 ff ff       	jmp    80106924 <alltraps>

801070ca <vector35>:
.globl vector35
vector35:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $35
801070cc:	6a 23                	push   $0x23
  jmp alltraps
801070ce:	e9 51 f8 ff ff       	jmp    80106924 <alltraps>

801070d3 <vector36>:
.globl vector36
vector36:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $36
801070d5:	6a 24                	push   $0x24
  jmp alltraps
801070d7:	e9 48 f8 ff ff       	jmp    80106924 <alltraps>

801070dc <vector37>:
.globl vector37
vector37:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $37
801070de:	6a 25                	push   $0x25
  jmp alltraps
801070e0:	e9 3f f8 ff ff       	jmp    80106924 <alltraps>

801070e5 <vector38>:
.globl vector38
vector38:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $38
801070e7:	6a 26                	push   $0x26
  jmp alltraps
801070e9:	e9 36 f8 ff ff       	jmp    80106924 <alltraps>

801070ee <vector39>:
.globl vector39
vector39:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $39
801070f0:	6a 27                	push   $0x27
  jmp alltraps
801070f2:	e9 2d f8 ff ff       	jmp    80106924 <alltraps>

801070f7 <vector40>:
.globl vector40
vector40:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $40
801070f9:	6a 28                	push   $0x28
  jmp alltraps
801070fb:	e9 24 f8 ff ff       	jmp    80106924 <alltraps>

80107100 <vector41>:
.globl vector41
vector41:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $41
80107102:	6a 29                	push   $0x29
  jmp alltraps
80107104:	e9 1b f8 ff ff       	jmp    80106924 <alltraps>

80107109 <vector42>:
.globl vector42
vector42:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $42
8010710b:	6a 2a                	push   $0x2a
  jmp alltraps
8010710d:	e9 12 f8 ff ff       	jmp    80106924 <alltraps>

80107112 <vector43>:
.globl vector43
vector43:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $43
80107114:	6a 2b                	push   $0x2b
  jmp alltraps
80107116:	e9 09 f8 ff ff       	jmp    80106924 <alltraps>

8010711b <vector44>:
.globl vector44
vector44:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $44
8010711d:	6a 2c                	push   $0x2c
  jmp alltraps
8010711f:	e9 00 f8 ff ff       	jmp    80106924 <alltraps>

80107124 <vector45>:
.globl vector45
vector45:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $45
80107126:	6a 2d                	push   $0x2d
  jmp alltraps
80107128:	e9 f7 f7 ff ff       	jmp    80106924 <alltraps>

8010712d <vector46>:
.globl vector46
vector46:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $46
8010712f:	6a 2e                	push   $0x2e
  jmp alltraps
80107131:	e9 ee f7 ff ff       	jmp    80106924 <alltraps>

80107136 <vector47>:
.globl vector47
vector47:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $47
80107138:	6a 2f                	push   $0x2f
  jmp alltraps
8010713a:	e9 e5 f7 ff ff       	jmp    80106924 <alltraps>

8010713f <vector48>:
.globl vector48
vector48:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $48
80107141:	6a 30                	push   $0x30
  jmp alltraps
80107143:	e9 dc f7 ff ff       	jmp    80106924 <alltraps>

80107148 <vector49>:
.globl vector49
vector49:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $49
8010714a:	6a 31                	push   $0x31
  jmp alltraps
8010714c:	e9 d3 f7 ff ff       	jmp    80106924 <alltraps>

80107151 <vector50>:
.globl vector50
vector50:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $50
80107153:	6a 32                	push   $0x32
  jmp alltraps
80107155:	e9 ca f7 ff ff       	jmp    80106924 <alltraps>

8010715a <vector51>:
.globl vector51
vector51:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $51
8010715c:	6a 33                	push   $0x33
  jmp alltraps
8010715e:	e9 c1 f7 ff ff       	jmp    80106924 <alltraps>

80107163 <vector52>:
.globl vector52
vector52:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $52
80107165:	6a 34                	push   $0x34
  jmp alltraps
80107167:	e9 b8 f7 ff ff       	jmp    80106924 <alltraps>

8010716c <vector53>:
.globl vector53
vector53:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $53
8010716e:	6a 35                	push   $0x35
  jmp alltraps
80107170:	e9 af f7 ff ff       	jmp    80106924 <alltraps>

80107175 <vector54>:
.globl vector54
vector54:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $54
80107177:	6a 36                	push   $0x36
  jmp alltraps
80107179:	e9 a6 f7 ff ff       	jmp    80106924 <alltraps>

8010717e <vector55>:
.globl vector55
vector55:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $55
80107180:	6a 37                	push   $0x37
  jmp alltraps
80107182:	e9 9d f7 ff ff       	jmp    80106924 <alltraps>

80107187 <vector56>:
.globl vector56
vector56:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $56
80107189:	6a 38                	push   $0x38
  jmp alltraps
8010718b:	e9 94 f7 ff ff       	jmp    80106924 <alltraps>

80107190 <vector57>:
.globl vector57
vector57:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $57
80107192:	6a 39                	push   $0x39
  jmp alltraps
80107194:	e9 8b f7 ff ff       	jmp    80106924 <alltraps>

80107199 <vector58>:
.globl vector58
vector58:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $58
8010719b:	6a 3a                	push   $0x3a
  jmp alltraps
8010719d:	e9 82 f7 ff ff       	jmp    80106924 <alltraps>

801071a2 <vector59>:
.globl vector59
vector59:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $59
801071a4:	6a 3b                	push   $0x3b
  jmp alltraps
801071a6:	e9 79 f7 ff ff       	jmp    80106924 <alltraps>

801071ab <vector60>:
.globl vector60
vector60:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $60
801071ad:	6a 3c                	push   $0x3c
  jmp alltraps
801071af:	e9 70 f7 ff ff       	jmp    80106924 <alltraps>

801071b4 <vector61>:
.globl vector61
vector61:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $61
801071b6:	6a 3d                	push   $0x3d
  jmp alltraps
801071b8:	e9 67 f7 ff ff       	jmp    80106924 <alltraps>

801071bd <vector62>:
.globl vector62
vector62:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $62
801071bf:	6a 3e                	push   $0x3e
  jmp alltraps
801071c1:	e9 5e f7 ff ff       	jmp    80106924 <alltraps>

801071c6 <vector63>:
.globl vector63
vector63:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $63
801071c8:	6a 3f                	push   $0x3f
  jmp alltraps
801071ca:	e9 55 f7 ff ff       	jmp    80106924 <alltraps>

801071cf <vector64>:
.globl vector64
vector64:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $64
801071d1:	6a 40                	push   $0x40
  jmp alltraps
801071d3:	e9 4c f7 ff ff       	jmp    80106924 <alltraps>

801071d8 <vector65>:
.globl vector65
vector65:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $65
801071da:	6a 41                	push   $0x41
  jmp alltraps
801071dc:	e9 43 f7 ff ff       	jmp    80106924 <alltraps>

801071e1 <vector66>:
.globl vector66
vector66:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $66
801071e3:	6a 42                	push   $0x42
  jmp alltraps
801071e5:	e9 3a f7 ff ff       	jmp    80106924 <alltraps>

801071ea <vector67>:
.globl vector67
vector67:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $67
801071ec:	6a 43                	push   $0x43
  jmp alltraps
801071ee:	e9 31 f7 ff ff       	jmp    80106924 <alltraps>

801071f3 <vector68>:
.globl vector68
vector68:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $68
801071f5:	6a 44                	push   $0x44
  jmp alltraps
801071f7:	e9 28 f7 ff ff       	jmp    80106924 <alltraps>

801071fc <vector69>:
.globl vector69
vector69:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $69
801071fe:	6a 45                	push   $0x45
  jmp alltraps
80107200:	e9 1f f7 ff ff       	jmp    80106924 <alltraps>

80107205 <vector70>:
.globl vector70
vector70:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $70
80107207:	6a 46                	push   $0x46
  jmp alltraps
80107209:	e9 16 f7 ff ff       	jmp    80106924 <alltraps>

8010720e <vector71>:
.globl vector71
vector71:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $71
80107210:	6a 47                	push   $0x47
  jmp alltraps
80107212:	e9 0d f7 ff ff       	jmp    80106924 <alltraps>

80107217 <vector72>:
.globl vector72
vector72:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $72
80107219:	6a 48                	push   $0x48
  jmp alltraps
8010721b:	e9 04 f7 ff ff       	jmp    80106924 <alltraps>

80107220 <vector73>:
.globl vector73
vector73:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $73
80107222:	6a 49                	push   $0x49
  jmp alltraps
80107224:	e9 fb f6 ff ff       	jmp    80106924 <alltraps>

80107229 <vector74>:
.globl vector74
vector74:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $74
8010722b:	6a 4a                	push   $0x4a
  jmp alltraps
8010722d:	e9 f2 f6 ff ff       	jmp    80106924 <alltraps>

80107232 <vector75>:
.globl vector75
vector75:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $75
80107234:	6a 4b                	push   $0x4b
  jmp alltraps
80107236:	e9 e9 f6 ff ff       	jmp    80106924 <alltraps>

8010723b <vector76>:
.globl vector76
vector76:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $76
8010723d:	6a 4c                	push   $0x4c
  jmp alltraps
8010723f:	e9 e0 f6 ff ff       	jmp    80106924 <alltraps>

80107244 <vector77>:
.globl vector77
vector77:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $77
80107246:	6a 4d                	push   $0x4d
  jmp alltraps
80107248:	e9 d7 f6 ff ff       	jmp    80106924 <alltraps>

8010724d <vector78>:
.globl vector78
vector78:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $78
8010724f:	6a 4e                	push   $0x4e
  jmp alltraps
80107251:	e9 ce f6 ff ff       	jmp    80106924 <alltraps>

80107256 <vector79>:
.globl vector79
vector79:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $79
80107258:	6a 4f                	push   $0x4f
  jmp alltraps
8010725a:	e9 c5 f6 ff ff       	jmp    80106924 <alltraps>

8010725f <vector80>:
.globl vector80
vector80:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $80
80107261:	6a 50                	push   $0x50
  jmp alltraps
80107263:	e9 bc f6 ff ff       	jmp    80106924 <alltraps>

80107268 <vector81>:
.globl vector81
vector81:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $81
8010726a:	6a 51                	push   $0x51
  jmp alltraps
8010726c:	e9 b3 f6 ff ff       	jmp    80106924 <alltraps>

80107271 <vector82>:
.globl vector82
vector82:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $82
80107273:	6a 52                	push   $0x52
  jmp alltraps
80107275:	e9 aa f6 ff ff       	jmp    80106924 <alltraps>

8010727a <vector83>:
.globl vector83
vector83:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $83
8010727c:	6a 53                	push   $0x53
  jmp alltraps
8010727e:	e9 a1 f6 ff ff       	jmp    80106924 <alltraps>

80107283 <vector84>:
.globl vector84
vector84:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $84
80107285:	6a 54                	push   $0x54
  jmp alltraps
80107287:	e9 98 f6 ff ff       	jmp    80106924 <alltraps>

8010728c <vector85>:
.globl vector85
vector85:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $85
8010728e:	6a 55                	push   $0x55
  jmp alltraps
80107290:	e9 8f f6 ff ff       	jmp    80106924 <alltraps>

80107295 <vector86>:
.globl vector86
vector86:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $86
80107297:	6a 56                	push   $0x56
  jmp alltraps
80107299:	e9 86 f6 ff ff       	jmp    80106924 <alltraps>

8010729e <vector87>:
.globl vector87
vector87:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $87
801072a0:	6a 57                	push   $0x57
  jmp alltraps
801072a2:	e9 7d f6 ff ff       	jmp    80106924 <alltraps>

801072a7 <vector88>:
.globl vector88
vector88:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $88
801072a9:	6a 58                	push   $0x58
  jmp alltraps
801072ab:	e9 74 f6 ff ff       	jmp    80106924 <alltraps>

801072b0 <vector89>:
.globl vector89
vector89:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $89
801072b2:	6a 59                	push   $0x59
  jmp alltraps
801072b4:	e9 6b f6 ff ff       	jmp    80106924 <alltraps>

801072b9 <vector90>:
.globl vector90
vector90:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $90
801072bb:	6a 5a                	push   $0x5a
  jmp alltraps
801072bd:	e9 62 f6 ff ff       	jmp    80106924 <alltraps>

801072c2 <vector91>:
.globl vector91
vector91:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $91
801072c4:	6a 5b                	push   $0x5b
  jmp alltraps
801072c6:	e9 59 f6 ff ff       	jmp    80106924 <alltraps>

801072cb <vector92>:
.globl vector92
vector92:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $92
801072cd:	6a 5c                	push   $0x5c
  jmp alltraps
801072cf:	e9 50 f6 ff ff       	jmp    80106924 <alltraps>

801072d4 <vector93>:
.globl vector93
vector93:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $93
801072d6:	6a 5d                	push   $0x5d
  jmp alltraps
801072d8:	e9 47 f6 ff ff       	jmp    80106924 <alltraps>

801072dd <vector94>:
.globl vector94
vector94:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $94
801072df:	6a 5e                	push   $0x5e
  jmp alltraps
801072e1:	e9 3e f6 ff ff       	jmp    80106924 <alltraps>

801072e6 <vector95>:
.globl vector95
vector95:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $95
801072e8:	6a 5f                	push   $0x5f
  jmp alltraps
801072ea:	e9 35 f6 ff ff       	jmp    80106924 <alltraps>

801072ef <vector96>:
.globl vector96
vector96:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $96
801072f1:	6a 60                	push   $0x60
  jmp alltraps
801072f3:	e9 2c f6 ff ff       	jmp    80106924 <alltraps>

801072f8 <vector97>:
.globl vector97
vector97:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $97
801072fa:	6a 61                	push   $0x61
  jmp alltraps
801072fc:	e9 23 f6 ff ff       	jmp    80106924 <alltraps>

80107301 <vector98>:
.globl vector98
vector98:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $98
80107303:	6a 62                	push   $0x62
  jmp alltraps
80107305:	e9 1a f6 ff ff       	jmp    80106924 <alltraps>

8010730a <vector99>:
.globl vector99
vector99:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $99
8010730c:	6a 63                	push   $0x63
  jmp alltraps
8010730e:	e9 11 f6 ff ff       	jmp    80106924 <alltraps>

80107313 <vector100>:
.globl vector100
vector100:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $100
80107315:	6a 64                	push   $0x64
  jmp alltraps
80107317:	e9 08 f6 ff ff       	jmp    80106924 <alltraps>

8010731c <vector101>:
.globl vector101
vector101:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $101
8010731e:	6a 65                	push   $0x65
  jmp alltraps
80107320:	e9 ff f5 ff ff       	jmp    80106924 <alltraps>

80107325 <vector102>:
.globl vector102
vector102:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $102
80107327:	6a 66                	push   $0x66
  jmp alltraps
80107329:	e9 f6 f5 ff ff       	jmp    80106924 <alltraps>

8010732e <vector103>:
.globl vector103
vector103:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $103
80107330:	6a 67                	push   $0x67
  jmp alltraps
80107332:	e9 ed f5 ff ff       	jmp    80106924 <alltraps>

80107337 <vector104>:
.globl vector104
vector104:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $104
80107339:	6a 68                	push   $0x68
  jmp alltraps
8010733b:	e9 e4 f5 ff ff       	jmp    80106924 <alltraps>

80107340 <vector105>:
.globl vector105
vector105:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $105
80107342:	6a 69                	push   $0x69
  jmp alltraps
80107344:	e9 db f5 ff ff       	jmp    80106924 <alltraps>

80107349 <vector106>:
.globl vector106
vector106:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $106
8010734b:	6a 6a                	push   $0x6a
  jmp alltraps
8010734d:	e9 d2 f5 ff ff       	jmp    80106924 <alltraps>

80107352 <vector107>:
.globl vector107
vector107:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $107
80107354:	6a 6b                	push   $0x6b
  jmp alltraps
80107356:	e9 c9 f5 ff ff       	jmp    80106924 <alltraps>

8010735b <vector108>:
.globl vector108
vector108:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $108
8010735d:	6a 6c                	push   $0x6c
  jmp alltraps
8010735f:	e9 c0 f5 ff ff       	jmp    80106924 <alltraps>

80107364 <vector109>:
.globl vector109
vector109:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $109
80107366:	6a 6d                	push   $0x6d
  jmp alltraps
80107368:	e9 b7 f5 ff ff       	jmp    80106924 <alltraps>

8010736d <vector110>:
.globl vector110
vector110:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $110
8010736f:	6a 6e                	push   $0x6e
  jmp alltraps
80107371:	e9 ae f5 ff ff       	jmp    80106924 <alltraps>

80107376 <vector111>:
.globl vector111
vector111:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $111
80107378:	6a 6f                	push   $0x6f
  jmp alltraps
8010737a:	e9 a5 f5 ff ff       	jmp    80106924 <alltraps>

8010737f <vector112>:
.globl vector112
vector112:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $112
80107381:	6a 70                	push   $0x70
  jmp alltraps
80107383:	e9 9c f5 ff ff       	jmp    80106924 <alltraps>

80107388 <vector113>:
.globl vector113
vector113:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $113
8010738a:	6a 71                	push   $0x71
  jmp alltraps
8010738c:	e9 93 f5 ff ff       	jmp    80106924 <alltraps>

80107391 <vector114>:
.globl vector114
vector114:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $114
80107393:	6a 72                	push   $0x72
  jmp alltraps
80107395:	e9 8a f5 ff ff       	jmp    80106924 <alltraps>

8010739a <vector115>:
.globl vector115
vector115:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $115
8010739c:	6a 73                	push   $0x73
  jmp alltraps
8010739e:	e9 81 f5 ff ff       	jmp    80106924 <alltraps>

801073a3 <vector116>:
.globl vector116
vector116:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $116
801073a5:	6a 74                	push   $0x74
  jmp alltraps
801073a7:	e9 78 f5 ff ff       	jmp    80106924 <alltraps>

801073ac <vector117>:
.globl vector117
vector117:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $117
801073ae:	6a 75                	push   $0x75
  jmp alltraps
801073b0:	e9 6f f5 ff ff       	jmp    80106924 <alltraps>

801073b5 <vector118>:
.globl vector118
vector118:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $118
801073b7:	6a 76                	push   $0x76
  jmp alltraps
801073b9:	e9 66 f5 ff ff       	jmp    80106924 <alltraps>

801073be <vector119>:
.globl vector119
vector119:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $119
801073c0:	6a 77                	push   $0x77
  jmp alltraps
801073c2:	e9 5d f5 ff ff       	jmp    80106924 <alltraps>

801073c7 <vector120>:
.globl vector120
vector120:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $120
801073c9:	6a 78                	push   $0x78
  jmp alltraps
801073cb:	e9 54 f5 ff ff       	jmp    80106924 <alltraps>

801073d0 <vector121>:
.globl vector121
vector121:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $121
801073d2:	6a 79                	push   $0x79
  jmp alltraps
801073d4:	e9 4b f5 ff ff       	jmp    80106924 <alltraps>

801073d9 <vector122>:
.globl vector122
vector122:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $122
801073db:	6a 7a                	push   $0x7a
  jmp alltraps
801073dd:	e9 42 f5 ff ff       	jmp    80106924 <alltraps>

801073e2 <vector123>:
.globl vector123
vector123:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $123
801073e4:	6a 7b                	push   $0x7b
  jmp alltraps
801073e6:	e9 39 f5 ff ff       	jmp    80106924 <alltraps>

801073eb <vector124>:
.globl vector124
vector124:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $124
801073ed:	6a 7c                	push   $0x7c
  jmp alltraps
801073ef:	e9 30 f5 ff ff       	jmp    80106924 <alltraps>

801073f4 <vector125>:
.globl vector125
vector125:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $125
801073f6:	6a 7d                	push   $0x7d
  jmp alltraps
801073f8:	e9 27 f5 ff ff       	jmp    80106924 <alltraps>

801073fd <vector126>:
.globl vector126
vector126:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $126
801073ff:	6a 7e                	push   $0x7e
  jmp alltraps
80107401:	e9 1e f5 ff ff       	jmp    80106924 <alltraps>

80107406 <vector127>:
.globl vector127
vector127:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $127
80107408:	6a 7f                	push   $0x7f
  jmp alltraps
8010740a:	e9 15 f5 ff ff       	jmp    80106924 <alltraps>

8010740f <vector128>:
.globl vector128
vector128:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $128
80107411:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107416:	e9 09 f5 ff ff       	jmp    80106924 <alltraps>

8010741b <vector129>:
.globl vector129
vector129:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $129
8010741d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107422:	e9 fd f4 ff ff       	jmp    80106924 <alltraps>

80107427 <vector130>:
.globl vector130
vector130:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $130
80107429:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010742e:	e9 f1 f4 ff ff       	jmp    80106924 <alltraps>

80107433 <vector131>:
.globl vector131
vector131:
  pushl $0
80107433:	6a 00                	push   $0x0
  pushl $131
80107435:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010743a:	e9 e5 f4 ff ff       	jmp    80106924 <alltraps>

8010743f <vector132>:
.globl vector132
vector132:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $132
80107441:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107446:	e9 d9 f4 ff ff       	jmp    80106924 <alltraps>

8010744b <vector133>:
.globl vector133
vector133:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $133
8010744d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107452:	e9 cd f4 ff ff       	jmp    80106924 <alltraps>

80107457 <vector134>:
.globl vector134
vector134:
  pushl $0
80107457:	6a 00                	push   $0x0
  pushl $134
80107459:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010745e:	e9 c1 f4 ff ff       	jmp    80106924 <alltraps>

80107463 <vector135>:
.globl vector135
vector135:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $135
80107465:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010746a:	e9 b5 f4 ff ff       	jmp    80106924 <alltraps>

8010746f <vector136>:
.globl vector136
vector136:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $136
80107471:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107476:	e9 a9 f4 ff ff       	jmp    80106924 <alltraps>

8010747b <vector137>:
.globl vector137
vector137:
  pushl $0
8010747b:	6a 00                	push   $0x0
  pushl $137
8010747d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107482:	e9 9d f4 ff ff       	jmp    80106924 <alltraps>

80107487 <vector138>:
.globl vector138
vector138:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $138
80107489:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010748e:	e9 91 f4 ff ff       	jmp    80106924 <alltraps>

80107493 <vector139>:
.globl vector139
vector139:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $139
80107495:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010749a:	e9 85 f4 ff ff       	jmp    80106924 <alltraps>

8010749f <vector140>:
.globl vector140
vector140:
  pushl $0
8010749f:	6a 00                	push   $0x0
  pushl $140
801074a1:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801074a6:	e9 79 f4 ff ff       	jmp    80106924 <alltraps>

801074ab <vector141>:
.globl vector141
vector141:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $141
801074ad:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801074b2:	e9 6d f4 ff ff       	jmp    80106924 <alltraps>

801074b7 <vector142>:
.globl vector142
vector142:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $142
801074b9:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801074be:	e9 61 f4 ff ff       	jmp    80106924 <alltraps>

801074c3 <vector143>:
.globl vector143
vector143:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $143
801074c5:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801074ca:	e9 55 f4 ff ff       	jmp    80106924 <alltraps>

801074cf <vector144>:
.globl vector144
vector144:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $144
801074d1:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074d6:	e9 49 f4 ff ff       	jmp    80106924 <alltraps>

801074db <vector145>:
.globl vector145
vector145:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $145
801074dd:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074e2:	e9 3d f4 ff ff       	jmp    80106924 <alltraps>

801074e7 <vector146>:
.globl vector146
vector146:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $146
801074e9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074ee:	e9 31 f4 ff ff       	jmp    80106924 <alltraps>

801074f3 <vector147>:
.globl vector147
vector147:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $147
801074f5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074fa:	e9 25 f4 ff ff       	jmp    80106924 <alltraps>

801074ff <vector148>:
.globl vector148
vector148:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $148
80107501:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107506:	e9 19 f4 ff ff       	jmp    80106924 <alltraps>

8010750b <vector149>:
.globl vector149
vector149:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $149
8010750d:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107512:	e9 0d f4 ff ff       	jmp    80106924 <alltraps>

80107517 <vector150>:
.globl vector150
vector150:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $150
80107519:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010751e:	e9 01 f4 ff ff       	jmp    80106924 <alltraps>

80107523 <vector151>:
.globl vector151
vector151:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $151
80107525:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010752a:	e9 f5 f3 ff ff       	jmp    80106924 <alltraps>

8010752f <vector152>:
.globl vector152
vector152:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $152
80107531:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107536:	e9 e9 f3 ff ff       	jmp    80106924 <alltraps>

8010753b <vector153>:
.globl vector153
vector153:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $153
8010753d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107542:	e9 dd f3 ff ff       	jmp    80106924 <alltraps>

80107547 <vector154>:
.globl vector154
vector154:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $154
80107549:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010754e:	e9 d1 f3 ff ff       	jmp    80106924 <alltraps>

80107553 <vector155>:
.globl vector155
vector155:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $155
80107555:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010755a:	e9 c5 f3 ff ff       	jmp    80106924 <alltraps>

8010755f <vector156>:
.globl vector156
vector156:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $156
80107561:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107566:	e9 b9 f3 ff ff       	jmp    80106924 <alltraps>

8010756b <vector157>:
.globl vector157
vector157:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $157
8010756d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107572:	e9 ad f3 ff ff       	jmp    80106924 <alltraps>

80107577 <vector158>:
.globl vector158
vector158:
  pushl $0
80107577:	6a 00                	push   $0x0
  pushl $158
80107579:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010757e:	e9 a1 f3 ff ff       	jmp    80106924 <alltraps>

80107583 <vector159>:
.globl vector159
vector159:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $159
80107585:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010758a:	e9 95 f3 ff ff       	jmp    80106924 <alltraps>

8010758f <vector160>:
.globl vector160
vector160:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $160
80107591:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107596:	e9 89 f3 ff ff       	jmp    80106924 <alltraps>

8010759b <vector161>:
.globl vector161
vector161:
  pushl $0
8010759b:	6a 00                	push   $0x0
  pushl $161
8010759d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801075a2:	e9 7d f3 ff ff       	jmp    80106924 <alltraps>

801075a7 <vector162>:
.globl vector162
vector162:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $162
801075a9:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801075ae:	e9 71 f3 ff ff       	jmp    80106924 <alltraps>

801075b3 <vector163>:
.globl vector163
vector163:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $163
801075b5:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801075ba:	e9 65 f3 ff ff       	jmp    80106924 <alltraps>

801075bf <vector164>:
.globl vector164
vector164:
  pushl $0
801075bf:	6a 00                	push   $0x0
  pushl $164
801075c1:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801075c6:	e9 59 f3 ff ff       	jmp    80106924 <alltraps>

801075cb <vector165>:
.globl vector165
vector165:
  pushl $0
801075cb:	6a 00                	push   $0x0
  pushl $165
801075cd:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075d2:	e9 4d f3 ff ff       	jmp    80106924 <alltraps>

801075d7 <vector166>:
.globl vector166
vector166:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $166
801075d9:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075de:	e9 41 f3 ff ff       	jmp    80106924 <alltraps>

801075e3 <vector167>:
.globl vector167
vector167:
  pushl $0
801075e3:	6a 00                	push   $0x0
  pushl $167
801075e5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075ea:	e9 35 f3 ff ff       	jmp    80106924 <alltraps>

801075ef <vector168>:
.globl vector168
vector168:
  pushl $0
801075ef:	6a 00                	push   $0x0
  pushl $168
801075f1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075f6:	e9 29 f3 ff ff       	jmp    80106924 <alltraps>

801075fb <vector169>:
.globl vector169
vector169:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $169
801075fd:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107602:	e9 1d f3 ff ff       	jmp    80106924 <alltraps>

80107607 <vector170>:
.globl vector170
vector170:
  pushl $0
80107607:	6a 00                	push   $0x0
  pushl $170
80107609:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010760e:	e9 11 f3 ff ff       	jmp    80106924 <alltraps>

80107613 <vector171>:
.globl vector171
vector171:
  pushl $0
80107613:	6a 00                	push   $0x0
  pushl $171
80107615:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010761a:	e9 05 f3 ff ff       	jmp    80106924 <alltraps>

8010761f <vector172>:
.globl vector172
vector172:
  pushl $0
8010761f:	6a 00                	push   $0x0
  pushl $172
80107621:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107626:	e9 f9 f2 ff ff       	jmp    80106924 <alltraps>

8010762b <vector173>:
.globl vector173
vector173:
  pushl $0
8010762b:	6a 00                	push   $0x0
  pushl $173
8010762d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107632:	e9 ed f2 ff ff       	jmp    80106924 <alltraps>

80107637 <vector174>:
.globl vector174
vector174:
  pushl $0
80107637:	6a 00                	push   $0x0
  pushl $174
80107639:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010763e:	e9 e1 f2 ff ff       	jmp    80106924 <alltraps>

80107643 <vector175>:
.globl vector175
vector175:
  pushl $0
80107643:	6a 00                	push   $0x0
  pushl $175
80107645:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010764a:	e9 d5 f2 ff ff       	jmp    80106924 <alltraps>

8010764f <vector176>:
.globl vector176
vector176:
  pushl $0
8010764f:	6a 00                	push   $0x0
  pushl $176
80107651:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107656:	e9 c9 f2 ff ff       	jmp    80106924 <alltraps>

8010765b <vector177>:
.globl vector177
vector177:
  pushl $0
8010765b:	6a 00                	push   $0x0
  pushl $177
8010765d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107662:	e9 bd f2 ff ff       	jmp    80106924 <alltraps>

80107667 <vector178>:
.globl vector178
vector178:
  pushl $0
80107667:	6a 00                	push   $0x0
  pushl $178
80107669:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010766e:	e9 b1 f2 ff ff       	jmp    80106924 <alltraps>

80107673 <vector179>:
.globl vector179
vector179:
  pushl $0
80107673:	6a 00                	push   $0x0
  pushl $179
80107675:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010767a:	e9 a5 f2 ff ff       	jmp    80106924 <alltraps>

8010767f <vector180>:
.globl vector180
vector180:
  pushl $0
8010767f:	6a 00                	push   $0x0
  pushl $180
80107681:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107686:	e9 99 f2 ff ff       	jmp    80106924 <alltraps>

8010768b <vector181>:
.globl vector181
vector181:
  pushl $0
8010768b:	6a 00                	push   $0x0
  pushl $181
8010768d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107692:	e9 8d f2 ff ff       	jmp    80106924 <alltraps>

80107697 <vector182>:
.globl vector182
vector182:
  pushl $0
80107697:	6a 00                	push   $0x0
  pushl $182
80107699:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010769e:	e9 81 f2 ff ff       	jmp    80106924 <alltraps>

801076a3 <vector183>:
.globl vector183
vector183:
  pushl $0
801076a3:	6a 00                	push   $0x0
  pushl $183
801076a5:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801076aa:	e9 75 f2 ff ff       	jmp    80106924 <alltraps>

801076af <vector184>:
.globl vector184
vector184:
  pushl $0
801076af:	6a 00                	push   $0x0
  pushl $184
801076b1:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801076b6:	e9 69 f2 ff ff       	jmp    80106924 <alltraps>

801076bb <vector185>:
.globl vector185
vector185:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $185
801076bd:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801076c2:	e9 5d f2 ff ff       	jmp    80106924 <alltraps>

801076c7 <vector186>:
.globl vector186
vector186:
  pushl $0
801076c7:	6a 00                	push   $0x0
  pushl $186
801076c9:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076ce:	e9 51 f2 ff ff       	jmp    80106924 <alltraps>

801076d3 <vector187>:
.globl vector187
vector187:
  pushl $0
801076d3:	6a 00                	push   $0x0
  pushl $187
801076d5:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076da:	e9 45 f2 ff ff       	jmp    80106924 <alltraps>

801076df <vector188>:
.globl vector188
vector188:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $188
801076e1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076e6:	e9 39 f2 ff ff       	jmp    80106924 <alltraps>

801076eb <vector189>:
.globl vector189
vector189:
  pushl $0
801076eb:	6a 00                	push   $0x0
  pushl $189
801076ed:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076f2:	e9 2d f2 ff ff       	jmp    80106924 <alltraps>

801076f7 <vector190>:
.globl vector190
vector190:
  pushl $0
801076f7:	6a 00                	push   $0x0
  pushl $190
801076f9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076fe:	e9 21 f2 ff ff       	jmp    80106924 <alltraps>

80107703 <vector191>:
.globl vector191
vector191:
  pushl $0
80107703:	6a 00                	push   $0x0
  pushl $191
80107705:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010770a:	e9 15 f2 ff ff       	jmp    80106924 <alltraps>

8010770f <vector192>:
.globl vector192
vector192:
  pushl $0
8010770f:	6a 00                	push   $0x0
  pushl $192
80107711:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107716:	e9 09 f2 ff ff       	jmp    80106924 <alltraps>

8010771b <vector193>:
.globl vector193
vector193:
  pushl $0
8010771b:	6a 00                	push   $0x0
  pushl $193
8010771d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107722:	e9 fd f1 ff ff       	jmp    80106924 <alltraps>

80107727 <vector194>:
.globl vector194
vector194:
  pushl $0
80107727:	6a 00                	push   $0x0
  pushl $194
80107729:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010772e:	e9 f1 f1 ff ff       	jmp    80106924 <alltraps>

80107733 <vector195>:
.globl vector195
vector195:
  pushl $0
80107733:	6a 00                	push   $0x0
  pushl $195
80107735:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010773a:	e9 e5 f1 ff ff       	jmp    80106924 <alltraps>

8010773f <vector196>:
.globl vector196
vector196:
  pushl $0
8010773f:	6a 00                	push   $0x0
  pushl $196
80107741:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107746:	e9 d9 f1 ff ff       	jmp    80106924 <alltraps>

8010774b <vector197>:
.globl vector197
vector197:
  pushl $0
8010774b:	6a 00                	push   $0x0
  pushl $197
8010774d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107752:	e9 cd f1 ff ff       	jmp    80106924 <alltraps>

80107757 <vector198>:
.globl vector198
vector198:
  pushl $0
80107757:	6a 00                	push   $0x0
  pushl $198
80107759:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010775e:	e9 c1 f1 ff ff       	jmp    80106924 <alltraps>

80107763 <vector199>:
.globl vector199
vector199:
  pushl $0
80107763:	6a 00                	push   $0x0
  pushl $199
80107765:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010776a:	e9 b5 f1 ff ff       	jmp    80106924 <alltraps>

8010776f <vector200>:
.globl vector200
vector200:
  pushl $0
8010776f:	6a 00                	push   $0x0
  pushl $200
80107771:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107776:	e9 a9 f1 ff ff       	jmp    80106924 <alltraps>

8010777b <vector201>:
.globl vector201
vector201:
  pushl $0
8010777b:	6a 00                	push   $0x0
  pushl $201
8010777d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107782:	e9 9d f1 ff ff       	jmp    80106924 <alltraps>

80107787 <vector202>:
.globl vector202
vector202:
  pushl $0
80107787:	6a 00                	push   $0x0
  pushl $202
80107789:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010778e:	e9 91 f1 ff ff       	jmp    80106924 <alltraps>

80107793 <vector203>:
.globl vector203
vector203:
  pushl $0
80107793:	6a 00                	push   $0x0
  pushl $203
80107795:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010779a:	e9 85 f1 ff ff       	jmp    80106924 <alltraps>

8010779f <vector204>:
.globl vector204
vector204:
  pushl $0
8010779f:	6a 00                	push   $0x0
  pushl $204
801077a1:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801077a6:	e9 79 f1 ff ff       	jmp    80106924 <alltraps>

801077ab <vector205>:
.globl vector205
vector205:
  pushl $0
801077ab:	6a 00                	push   $0x0
  pushl $205
801077ad:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801077b2:	e9 6d f1 ff ff       	jmp    80106924 <alltraps>

801077b7 <vector206>:
.globl vector206
vector206:
  pushl $0
801077b7:	6a 00                	push   $0x0
  pushl $206
801077b9:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801077be:	e9 61 f1 ff ff       	jmp    80106924 <alltraps>

801077c3 <vector207>:
.globl vector207
vector207:
  pushl $0
801077c3:	6a 00                	push   $0x0
  pushl $207
801077c5:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801077ca:	e9 55 f1 ff ff       	jmp    80106924 <alltraps>

801077cf <vector208>:
.globl vector208
vector208:
  pushl $0
801077cf:	6a 00                	push   $0x0
  pushl $208
801077d1:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077d6:	e9 49 f1 ff ff       	jmp    80106924 <alltraps>

801077db <vector209>:
.globl vector209
vector209:
  pushl $0
801077db:	6a 00                	push   $0x0
  pushl $209
801077dd:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077e2:	e9 3d f1 ff ff       	jmp    80106924 <alltraps>

801077e7 <vector210>:
.globl vector210
vector210:
  pushl $0
801077e7:	6a 00                	push   $0x0
  pushl $210
801077e9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077ee:	e9 31 f1 ff ff       	jmp    80106924 <alltraps>

801077f3 <vector211>:
.globl vector211
vector211:
  pushl $0
801077f3:	6a 00                	push   $0x0
  pushl $211
801077f5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077fa:	e9 25 f1 ff ff       	jmp    80106924 <alltraps>

801077ff <vector212>:
.globl vector212
vector212:
  pushl $0
801077ff:	6a 00                	push   $0x0
  pushl $212
80107801:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107806:	e9 19 f1 ff ff       	jmp    80106924 <alltraps>

8010780b <vector213>:
.globl vector213
vector213:
  pushl $0
8010780b:	6a 00                	push   $0x0
  pushl $213
8010780d:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107812:	e9 0d f1 ff ff       	jmp    80106924 <alltraps>

80107817 <vector214>:
.globl vector214
vector214:
  pushl $0
80107817:	6a 00                	push   $0x0
  pushl $214
80107819:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010781e:	e9 01 f1 ff ff       	jmp    80106924 <alltraps>

80107823 <vector215>:
.globl vector215
vector215:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $215
80107825:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010782a:	e9 f5 f0 ff ff       	jmp    80106924 <alltraps>

8010782f <vector216>:
.globl vector216
vector216:
  pushl $0
8010782f:	6a 00                	push   $0x0
  pushl $216
80107831:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107836:	e9 e9 f0 ff ff       	jmp    80106924 <alltraps>

8010783b <vector217>:
.globl vector217
vector217:
  pushl $0
8010783b:	6a 00                	push   $0x0
  pushl $217
8010783d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107842:	e9 dd f0 ff ff       	jmp    80106924 <alltraps>

80107847 <vector218>:
.globl vector218
vector218:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $218
80107849:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010784e:	e9 d1 f0 ff ff       	jmp    80106924 <alltraps>

80107853 <vector219>:
.globl vector219
vector219:
  pushl $0
80107853:	6a 00                	push   $0x0
  pushl $219
80107855:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010785a:	e9 c5 f0 ff ff       	jmp    80106924 <alltraps>

8010785f <vector220>:
.globl vector220
vector220:
  pushl $0
8010785f:	6a 00                	push   $0x0
  pushl $220
80107861:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107866:	e9 b9 f0 ff ff       	jmp    80106924 <alltraps>

8010786b <vector221>:
.globl vector221
vector221:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $221
8010786d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107872:	e9 ad f0 ff ff       	jmp    80106924 <alltraps>

80107877 <vector222>:
.globl vector222
vector222:
  pushl $0
80107877:	6a 00                	push   $0x0
  pushl $222
80107879:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010787e:	e9 a1 f0 ff ff       	jmp    80106924 <alltraps>

80107883 <vector223>:
.globl vector223
vector223:
  pushl $0
80107883:	6a 00                	push   $0x0
  pushl $223
80107885:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010788a:	e9 95 f0 ff ff       	jmp    80106924 <alltraps>

8010788f <vector224>:
.globl vector224
vector224:
  pushl $0
8010788f:	6a 00                	push   $0x0
  pushl $224
80107891:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107896:	e9 89 f0 ff ff       	jmp    80106924 <alltraps>

8010789b <vector225>:
.globl vector225
vector225:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $225
8010789d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801078a2:	e9 7d f0 ff ff       	jmp    80106924 <alltraps>

801078a7 <vector226>:
.globl vector226
vector226:
  pushl $0
801078a7:	6a 00                	push   $0x0
  pushl $226
801078a9:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801078ae:	e9 71 f0 ff ff       	jmp    80106924 <alltraps>

801078b3 <vector227>:
.globl vector227
vector227:
  pushl $0
801078b3:	6a 00                	push   $0x0
  pushl $227
801078b5:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801078ba:	e9 65 f0 ff ff       	jmp    80106924 <alltraps>

801078bf <vector228>:
.globl vector228
vector228:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $228
801078c1:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801078c6:	e9 59 f0 ff ff       	jmp    80106924 <alltraps>

801078cb <vector229>:
.globl vector229
vector229:
  pushl $0
801078cb:	6a 00                	push   $0x0
  pushl $229
801078cd:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078d2:	e9 4d f0 ff ff       	jmp    80106924 <alltraps>

801078d7 <vector230>:
.globl vector230
vector230:
  pushl $0
801078d7:	6a 00                	push   $0x0
  pushl $230
801078d9:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078de:	e9 41 f0 ff ff       	jmp    80106924 <alltraps>

801078e3 <vector231>:
.globl vector231
vector231:
  pushl $0
801078e3:	6a 00                	push   $0x0
  pushl $231
801078e5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078ea:	e9 35 f0 ff ff       	jmp    80106924 <alltraps>

801078ef <vector232>:
.globl vector232
vector232:
  pushl $0
801078ef:	6a 00                	push   $0x0
  pushl $232
801078f1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078f6:	e9 29 f0 ff ff       	jmp    80106924 <alltraps>

801078fb <vector233>:
.globl vector233
vector233:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $233
801078fd:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107902:	e9 1d f0 ff ff       	jmp    80106924 <alltraps>

80107907 <vector234>:
.globl vector234
vector234:
  pushl $0
80107907:	6a 00                	push   $0x0
  pushl $234
80107909:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010790e:	e9 11 f0 ff ff       	jmp    80106924 <alltraps>

80107913 <vector235>:
.globl vector235
vector235:
  pushl $0
80107913:	6a 00                	push   $0x0
  pushl $235
80107915:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010791a:	e9 05 f0 ff ff       	jmp    80106924 <alltraps>

8010791f <vector236>:
.globl vector236
vector236:
  pushl $0
8010791f:	6a 00                	push   $0x0
  pushl $236
80107921:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107926:	e9 f9 ef ff ff       	jmp    80106924 <alltraps>

8010792b <vector237>:
.globl vector237
vector237:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $237
8010792d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107932:	e9 ed ef ff ff       	jmp    80106924 <alltraps>

80107937 <vector238>:
.globl vector238
vector238:
  pushl $0
80107937:	6a 00                	push   $0x0
  pushl $238
80107939:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010793e:	e9 e1 ef ff ff       	jmp    80106924 <alltraps>

80107943 <vector239>:
.globl vector239
vector239:
  pushl $0
80107943:	6a 00                	push   $0x0
  pushl $239
80107945:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010794a:	e9 d5 ef ff ff       	jmp    80106924 <alltraps>

8010794f <vector240>:
.globl vector240
vector240:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $240
80107951:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107956:	e9 c9 ef ff ff       	jmp    80106924 <alltraps>

8010795b <vector241>:
.globl vector241
vector241:
  pushl $0
8010795b:	6a 00                	push   $0x0
  pushl $241
8010795d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107962:	e9 bd ef ff ff       	jmp    80106924 <alltraps>

80107967 <vector242>:
.globl vector242
vector242:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $242
80107969:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010796e:	e9 b1 ef ff ff       	jmp    80106924 <alltraps>

80107973 <vector243>:
.globl vector243
vector243:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $243
80107975:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010797a:	e9 a5 ef ff ff       	jmp    80106924 <alltraps>

8010797f <vector244>:
.globl vector244
vector244:
  pushl $0
8010797f:	6a 00                	push   $0x0
  pushl $244
80107981:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107986:	e9 99 ef ff ff       	jmp    80106924 <alltraps>

8010798b <vector245>:
.globl vector245
vector245:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $245
8010798d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107992:	e9 8d ef ff ff       	jmp    80106924 <alltraps>

80107997 <vector246>:
.globl vector246
vector246:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $246
80107999:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010799e:	e9 81 ef ff ff       	jmp    80106924 <alltraps>

801079a3 <vector247>:
.globl vector247
vector247:
  pushl $0
801079a3:	6a 00                	push   $0x0
  pushl $247
801079a5:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801079aa:	e9 75 ef ff ff       	jmp    80106924 <alltraps>

801079af <vector248>:
.globl vector248
vector248:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $248
801079b1:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801079b6:	e9 69 ef ff ff       	jmp    80106924 <alltraps>

801079bb <vector249>:
.globl vector249
vector249:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $249
801079bd:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801079c2:	e9 5d ef ff ff       	jmp    80106924 <alltraps>

801079c7 <vector250>:
.globl vector250
vector250:
  pushl $0
801079c7:	6a 00                	push   $0x0
  pushl $250
801079c9:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079ce:	e9 51 ef ff ff       	jmp    80106924 <alltraps>

801079d3 <vector251>:
.globl vector251
vector251:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $251
801079d5:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079da:	e9 45 ef ff ff       	jmp    80106924 <alltraps>

801079df <vector252>:
.globl vector252
vector252:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $252
801079e1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079e6:	e9 39 ef ff ff       	jmp    80106924 <alltraps>

801079eb <vector253>:
.globl vector253
vector253:
  pushl $0
801079eb:	6a 00                	push   $0x0
  pushl $253
801079ed:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079f2:	e9 2d ef ff ff       	jmp    80106924 <alltraps>

801079f7 <vector254>:
.globl vector254
vector254:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $254
801079f9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079fe:	e9 21 ef ff ff       	jmp    80106924 <alltraps>

80107a03 <vector255>:
.globl vector255
vector255:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $255
80107a05:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a0a:	e9 15 ef ff ff       	jmp    80106924 <alltraps>

80107a0f <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107a0f:	55                   	push   %ebp
80107a10:	89 e5                	mov    %esp,%ebp
80107a12:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a15:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a18:	83 e8 01             	sub    $0x1,%eax
80107a1b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a22:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a26:	8b 45 08             	mov    0x8(%ebp),%eax
80107a29:	c1 e8 10             	shr    $0x10,%eax
80107a2c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a30:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a33:	0f 01 10             	lgdtl  (%eax)
}
80107a36:	c9                   	leave  
80107a37:	c3                   	ret    

80107a38 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a38:	55                   	push   %ebp
80107a39:	89 e5                	mov    %esp,%ebp
80107a3b:	83 ec 04             	sub    $0x4,%esp
80107a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a41:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a45:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a49:	0f 00 d8             	ltr    %ax
}
80107a4c:	c9                   	leave  
80107a4d:	c3                   	ret    

80107a4e <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a4e:	55                   	push   %ebp
80107a4f:	89 e5                	mov    %esp,%ebp
80107a51:	83 ec 04             	sub    $0x4,%esp
80107a54:	8b 45 08             	mov    0x8(%ebp),%eax
80107a57:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a5b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a5f:	8e e8                	mov    %eax,%gs
}
80107a61:	c9                   	leave  
80107a62:	c3                   	ret    

80107a63 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a63:	55                   	push   %ebp
80107a64:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a66:	8b 45 08             	mov    0x8(%ebp),%eax
80107a69:	0f 22 d8             	mov    %eax,%cr3
}
80107a6c:	5d                   	pop    %ebp
80107a6d:	c3                   	ret    

80107a6e <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a6e:	55                   	push   %ebp
80107a6f:	89 e5                	mov    %esp,%ebp
80107a71:	8b 45 08             	mov    0x8(%ebp),%eax
80107a74:	05 00 00 00 80       	add    $0x80000000,%eax
80107a79:	5d                   	pop    %ebp
80107a7a:	c3                   	ret    

80107a7b <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a7b:	55                   	push   %ebp
80107a7c:	89 e5                	mov    %esp,%ebp
80107a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a81:	05 00 00 00 80       	add    $0x80000000,%eax
80107a86:	5d                   	pop    %ebp
80107a87:	c3                   	ret    

80107a88 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a88:	55                   	push   %ebp
80107a89:	89 e5                	mov    %esp,%ebp
80107a8b:	53                   	push   %ebx
80107a8c:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a8f:	e8 9a b4 ff ff       	call   80102f2e <cpunum>
80107a94:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a9a:	05 80 23 11 80       	add    $0x80112380,%eax
80107a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa5:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aae:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab7:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abe:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ac2:	83 e2 f0             	and    $0xfffffff0,%edx
80107ac5:	83 ca 0a             	or     $0xa,%edx
80107ac8:	88 50 7d             	mov    %dl,0x7d(%eax)
80107acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ace:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ad2:	83 ca 10             	or     $0x10,%edx
80107ad5:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107adf:	83 e2 9f             	and    $0xffffff9f,%edx
80107ae2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aec:	83 ca 80             	or     $0xffffff80,%edx
80107aef:	88 50 7d             	mov    %dl,0x7d(%eax)
80107af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107af9:	83 ca 0f             	or     $0xf,%edx
80107afc:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b02:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b06:	83 e2 ef             	and    $0xffffffef,%edx
80107b09:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b13:	83 e2 df             	and    $0xffffffdf,%edx
80107b16:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b20:	83 ca 40             	or     $0x40,%edx
80107b23:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b29:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b2d:	83 ca 80             	or     $0xffffff80,%edx
80107b30:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b36:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b44:	ff ff 
80107b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b49:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b50:	00 00 
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b66:	83 e2 f0             	and    $0xfffffff0,%edx
80107b69:	83 ca 02             	or     $0x2,%edx
80107b6c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b7c:	83 ca 10             	or     $0x10,%edx
80107b7f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b88:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b8f:	83 e2 9f             	and    $0xffffff9f,%edx
80107b92:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ba2:	83 ca 80             	or     $0xffffff80,%edx
80107ba5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bb5:	83 ca 0f             	or     $0xf,%edx
80107bb8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bc8:	83 e2 ef             	and    $0xffffffef,%edx
80107bcb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bdb:	83 e2 df             	and    $0xffffffdf,%edx
80107bde:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bee:	83 ca 40             	or     $0x40,%edx
80107bf1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c01:	83 ca 80             	or     $0xffffff80,%edx
80107c04:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0d:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c17:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c1e:	ff ff 
80107c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c23:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c2a:	00 00 
80107c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2f:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c39:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c40:	83 e2 f0             	and    $0xfffffff0,%edx
80107c43:	83 ca 0a             	or     $0xa,%edx
80107c46:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c56:	83 ca 10             	or     $0x10,%edx
80107c59:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c69:	83 ca 60             	or     $0x60,%edx
80107c6c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c7c:	83 ca 80             	or     $0xffffff80,%edx
80107c7f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c88:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c8f:	83 ca 0f             	or     $0xf,%edx
80107c92:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ca2:	83 e2 ef             	and    $0xffffffef,%edx
80107ca5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cb5:	83 e2 df             	and    $0xffffffdf,%edx
80107cb8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cc8:	83 ca 40             	or     $0x40,%edx
80107ccb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cdb:	83 ca 80             	or     $0xffffff80,%edx
80107cde:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce7:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf1:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107cf8:	ff ff 
80107cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfd:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107d04:	00 00 
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d13:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d1a:	83 e2 f0             	and    $0xfffffff0,%edx
80107d1d:	83 ca 02             	or     $0x2,%edx
80107d20:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d30:	83 ca 10             	or     $0x10,%edx
80107d33:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d43:	83 ca 60             	or     $0x60,%edx
80107d46:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d56:	83 ca 80             	or     $0xffffff80,%edx
80107d59:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d69:	83 ca 0f             	or     $0xf,%edx
80107d6c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d75:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d7c:	83 e2 ef             	and    $0xffffffef,%edx
80107d7f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d8f:	83 e2 df             	and    $0xffffffdf,%edx
80107d92:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107da2:	83 ca 40             	or     $0x40,%edx
80107da5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107db5:	83 ca 80             	or     $0xffffff80,%edx
80107db8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcb:	05 b4 00 00 00       	add    $0xb4,%eax
80107dd0:	89 c3                	mov    %eax,%ebx
80107dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd5:	05 b4 00 00 00       	add    $0xb4,%eax
80107dda:	c1 e8 10             	shr    $0x10,%eax
80107ddd:	89 c1                	mov    %eax,%ecx
80107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de2:	05 b4 00 00 00       	add    $0xb4,%eax
80107de7:	c1 e8 18             	shr    $0x18,%eax
80107dea:	89 c2                	mov    %eax,%edx
80107dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107def:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107df6:	00 00 
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e05:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e15:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e18:	83 c9 02             	or     $0x2,%ecx
80107e1b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e24:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e2b:	83 c9 10             	or     $0x10,%ecx
80107e2e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e37:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e3e:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e41:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e51:	83 c9 80             	or     $0xffffff80,%ecx
80107e54:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e64:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e67:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e77:	83 e1 ef             	and    $0xffffffef,%ecx
80107e7a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e83:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e8a:	83 e1 df             	and    $0xffffffdf,%ecx
80107e8d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e96:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e9d:	83 c9 40             	or     $0x40,%ecx
80107ea0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea9:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107eb0:	83 c9 80             	or     $0xffffff80,%ecx
80107eb3:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebc:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec5:	83 c0 70             	add    $0x70,%eax
80107ec8:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107ecf:	00 
80107ed0:	89 04 24             	mov    %eax,(%esp)
80107ed3:	e8 37 fb ff ff       	call   80107a0f <lgdt>
  loadgs(SEG_KCPU << 3);
80107ed8:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107edf:	e8 6a fb ff ff       	call   80107a4e <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107eed:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ef4:	00 00 00 00 
}
80107ef8:	83 c4 24             	add    $0x24,%esp
80107efb:	5b                   	pop    %ebx
80107efc:	5d                   	pop    %ebp
80107efd:	c3                   	ret    

80107efe <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107efe:	55                   	push   %ebp
80107eff:	89 e5                	mov    %esp,%ebp
80107f01:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f04:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f07:	c1 e8 16             	shr    $0x16,%eax
80107f0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f11:	8b 45 08             	mov    0x8(%ebp),%eax
80107f14:	01 d0                	add    %edx,%eax
80107f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f1c:	8b 00                	mov    (%eax),%eax
80107f1e:	83 e0 01             	and    $0x1,%eax
80107f21:	85 c0                	test   %eax,%eax
80107f23:	74 17                	je     80107f3c <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f28:	8b 00                	mov    (%eax),%eax
80107f2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f2f:	89 04 24             	mov    %eax,(%esp)
80107f32:	e8 44 fb ff ff       	call   80107a7b <p2v>
80107f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f3a:	eb 4b                	jmp    80107f87 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f40:	74 0e                	je     80107f50 <walkpgdir+0x52>
80107f42:	e8 51 ac ff ff       	call   80102b98 <kalloc>
80107f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f4e:	75 07                	jne    80107f57 <walkpgdir+0x59>
      return 0;
80107f50:	b8 00 00 00 00       	mov    $0x0,%eax
80107f55:	eb 47                	jmp    80107f9e <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f57:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f5e:	00 
80107f5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f66:	00 
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	89 04 24             	mov    %eax,(%esp)
80107f6d:	e8 8d d4 ff ff       	call   801053ff <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f75:	89 04 24             	mov    %eax,(%esp)
80107f78:	e8 f1 fa ff ff       	call   80107a6e <v2p>
80107f7d:	83 c8 07             	or     $0x7,%eax
80107f80:	89 c2                	mov    %eax,%edx
80107f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f85:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f87:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f8a:	c1 e8 0c             	shr    $0xc,%eax
80107f8d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f92:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9c:	01 d0                	add    %edx,%eax
}
80107f9e:	c9                   	leave  
80107f9f:	c3                   	ret    

80107fa0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fa0:	55                   	push   %ebp
80107fa1:	89 e5                	mov    %esp,%ebp
80107fa3:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107fb1:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fb4:	8b 45 10             	mov    0x10(%ebp),%eax
80107fb7:	01 d0                	add    %edx,%eax
80107fb9:	83 e8 01             	sub    $0x1,%eax
80107fbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107fc4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107fcb:	00 
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd6:	89 04 24             	mov    %eax,(%esp)
80107fd9:	e8 20 ff ff ff       	call   80107efe <walkpgdir>
80107fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fe1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fe5:	75 07                	jne    80107fee <mappages+0x4e>
      return -1;
80107fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fec:	eb 48                	jmp    80108036 <mappages+0x96>
    if(*pte & PTE_P)
80107fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ff1:	8b 00                	mov    (%eax),%eax
80107ff3:	83 e0 01             	and    $0x1,%eax
80107ff6:	85 c0                	test   %eax,%eax
80107ff8:	74 0c                	je     80108006 <mappages+0x66>
      panic("remap");
80107ffa:	c7 04 24 e0 8e 10 80 	movl   $0x80108ee0,(%esp)
80108001:	e8 34 85 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80108006:	8b 45 18             	mov    0x18(%ebp),%eax
80108009:	0b 45 14             	or     0x14(%ebp),%eax
8010800c:	83 c8 01             	or     $0x1,%eax
8010800f:	89 c2                	mov    %eax,%edx
80108011:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108014:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108019:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010801c:	75 08                	jne    80108026 <mappages+0x86>
      break;
8010801e:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010801f:	b8 00 00 00 00       	mov    $0x0,%eax
80108024:	eb 10                	jmp    80108036 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108026:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010802d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108034:	eb 8e                	jmp    80107fc4 <mappages+0x24>
  return 0;
}
80108036:	c9                   	leave  
80108037:	c3                   	ret    

80108038 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108038:	55                   	push   %ebp
80108039:	89 e5                	mov    %esp,%ebp
8010803b:	53                   	push   %ebx
8010803c:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010803f:	e8 54 ab ff ff       	call   80102b98 <kalloc>
80108044:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108047:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010804b:	75 0a                	jne    80108057 <setupkvm+0x1f>
    return 0;
8010804d:	b8 00 00 00 00       	mov    $0x0,%eax
80108052:	e9 98 00 00 00       	jmp    801080ef <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108057:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010805e:	00 
8010805f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108066:	00 
80108067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010806a:	89 04 24             	mov    %eax,(%esp)
8010806d:	e8 8d d3 ff ff       	call   801053ff <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108072:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108079:	e8 fd f9 ff ff       	call   80107a7b <p2v>
8010807e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108083:	76 0c                	jbe    80108091 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108085:	c7 04 24 e6 8e 10 80 	movl   $0x80108ee6,(%esp)
8010808c:	e8 a9 84 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108091:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80108098:	eb 49                	jmp    801080e3 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010809a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809d:	8b 48 0c             	mov    0xc(%eax),%ecx
801080a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a3:	8b 50 04             	mov    0x4(%eax),%edx
801080a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a9:	8b 58 08             	mov    0x8(%eax),%ebx
801080ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080af:	8b 40 04             	mov    0x4(%eax),%eax
801080b2:	29 c3                	sub    %eax,%ebx
801080b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b7:	8b 00                	mov    (%eax),%eax
801080b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801080bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801080c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801080c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cc:	89 04 24             	mov    %eax,(%esp)
801080cf:	e8 cc fe ff ff       	call   80107fa0 <mappages>
801080d4:	85 c0                	test   %eax,%eax
801080d6:	79 07                	jns    801080df <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801080d8:	b8 00 00 00 00       	mov    $0x0,%eax
801080dd:	eb 10                	jmp    801080ef <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080df:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080e3:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
801080ea:	72 ae                	jb     8010809a <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801080ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080ef:	83 c4 34             	add    $0x34,%esp
801080f2:	5b                   	pop    %ebx
801080f3:	5d                   	pop    %ebp
801080f4:	c3                   	ret    

801080f5 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080f5:	55                   	push   %ebp
801080f6:	89 e5                	mov    %esp,%ebp
801080f8:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080fb:	e8 38 ff ff ff       	call   80108038 <setupkvm>
80108100:	a3 58 54 11 80       	mov    %eax,0x80115458
  switchkvm();
80108105:	e8 02 00 00 00       	call   8010810c <switchkvm>
}
8010810a:	c9                   	leave  
8010810b:	c3                   	ret    

8010810c <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010810c:	55                   	push   %ebp
8010810d:	89 e5                	mov    %esp,%ebp
8010810f:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108112:	a1 58 54 11 80       	mov    0x80115458,%eax
80108117:	89 04 24             	mov    %eax,(%esp)
8010811a:	e8 4f f9 ff ff       	call   80107a6e <v2p>
8010811f:	89 04 24             	mov    %eax,(%esp)
80108122:	e8 3c f9 ff ff       	call   80107a63 <lcr3>
}
80108127:	c9                   	leave  
80108128:	c3                   	ret    

80108129 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108129:	55                   	push   %ebp
8010812a:	89 e5                	mov    %esp,%ebp
8010812c:	53                   	push   %ebx
8010812d:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108130:	e8 ca d1 ff ff       	call   801052ff <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108135:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010813b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108142:	83 c2 08             	add    $0x8,%edx
80108145:	89 d3                	mov    %edx,%ebx
80108147:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010814e:	83 c2 08             	add    $0x8,%edx
80108151:	c1 ea 10             	shr    $0x10,%edx
80108154:	89 d1                	mov    %edx,%ecx
80108156:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010815d:	83 c2 08             	add    $0x8,%edx
80108160:	c1 ea 18             	shr    $0x18,%edx
80108163:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010816a:	67 00 
8010816c:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108173:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108179:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108180:	83 e1 f0             	and    $0xfffffff0,%ecx
80108183:	83 c9 09             	or     $0x9,%ecx
80108186:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010818c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108193:	83 c9 10             	or     $0x10,%ecx
80108196:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010819c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081a3:	83 e1 9f             	and    $0xffffff9f,%ecx
801081a6:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081ac:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081b3:	83 c9 80             	or     $0xffffff80,%ecx
801081b6:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081bc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081c3:	83 e1 f0             	and    $0xfffffff0,%ecx
801081c6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081cc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081d3:	83 e1 ef             	and    $0xffffffef,%ecx
801081d6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081dc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081e3:	83 e1 df             	and    $0xffffffdf,%ecx
801081e6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081ec:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081f3:	83 c9 40             	or     $0x40,%ecx
801081f6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081fc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108203:	83 e1 7f             	and    $0x7f,%ecx
80108206:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010820c:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108212:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108218:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010821f:	83 e2 ef             	and    $0xffffffef,%edx
80108222:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108228:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010822e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108234:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010823a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108241:	8b 52 08             	mov    0x8(%edx),%edx
80108244:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010824a:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010824d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108254:	e8 df f7 ff ff       	call   80107a38 <ltr>
  if(p->pgdir == 0)
80108259:	8b 45 08             	mov    0x8(%ebp),%eax
8010825c:	8b 40 04             	mov    0x4(%eax),%eax
8010825f:	85 c0                	test   %eax,%eax
80108261:	75 0c                	jne    8010826f <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108263:	c7 04 24 f7 8e 10 80 	movl   $0x80108ef7,(%esp)
8010826a:	e8 cb 82 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010826f:	8b 45 08             	mov    0x8(%ebp),%eax
80108272:	8b 40 04             	mov    0x4(%eax),%eax
80108275:	89 04 24             	mov    %eax,(%esp)
80108278:	e8 f1 f7 ff ff       	call   80107a6e <v2p>
8010827d:	89 04 24             	mov    %eax,(%esp)
80108280:	e8 de f7 ff ff       	call   80107a63 <lcr3>
  popcli();
80108285:	e8 b9 d0 ff ff       	call   80105343 <popcli>
}
8010828a:	83 c4 14             	add    $0x14,%esp
8010828d:	5b                   	pop    %ebx
8010828e:	5d                   	pop    %ebp
8010828f:	c3                   	ret    

80108290 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108290:	55                   	push   %ebp
80108291:	89 e5                	mov    %esp,%ebp
80108293:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108296:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010829d:	76 0c                	jbe    801082ab <inituvm+0x1b>
    panic("inituvm: more than a page");
8010829f:	c7 04 24 0b 8f 10 80 	movl   $0x80108f0b,(%esp)
801082a6:	e8 8f 82 ff ff       	call   8010053a <panic>
  mem = kalloc();
801082ab:	e8 e8 a8 ff ff       	call   80102b98 <kalloc>
801082b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082b3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082ba:	00 
801082bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082c2:	00 
801082c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c6:	89 04 24             	mov    %eax,(%esp)
801082c9:	e8 31 d1 ff ff       	call   801053ff <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d1:	89 04 24             	mov    %eax,(%esp)
801082d4:	e8 95 f7 ff ff       	call   80107a6e <v2p>
801082d9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801082e0:	00 
801082e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082ec:	00 
801082ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082f4:	00 
801082f5:	8b 45 08             	mov    0x8(%ebp),%eax
801082f8:	89 04 24             	mov    %eax,(%esp)
801082fb:	e8 a0 fc ff ff       	call   80107fa0 <mappages>
  memmove(mem, init, sz);
80108300:	8b 45 10             	mov    0x10(%ebp),%eax
80108303:	89 44 24 08          	mov    %eax,0x8(%esp)
80108307:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010830e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108311:	89 04 24             	mov    %eax,(%esp)
80108314:	e8 b5 d1 ff ff       	call   801054ce <memmove>
}
80108319:	c9                   	leave  
8010831a:	c3                   	ret    

8010831b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010831b:	55                   	push   %ebp
8010831c:	89 e5                	mov    %esp,%ebp
8010831e:	53                   	push   %ebx
8010831f:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108322:	8b 45 0c             	mov    0xc(%ebp),%eax
80108325:	25 ff 0f 00 00       	and    $0xfff,%eax
8010832a:	85 c0                	test   %eax,%eax
8010832c:	74 0c                	je     8010833a <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010832e:	c7 04 24 28 8f 10 80 	movl   $0x80108f28,(%esp)
80108335:	e8 00 82 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010833a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108341:	e9 a9 00 00 00       	jmp    801083ef <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010834c:	01 d0                	add    %edx,%eax
8010834e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108355:	00 
80108356:	89 44 24 04          	mov    %eax,0x4(%esp)
8010835a:	8b 45 08             	mov    0x8(%ebp),%eax
8010835d:	89 04 24             	mov    %eax,(%esp)
80108360:	e8 99 fb ff ff       	call   80107efe <walkpgdir>
80108365:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108368:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010836c:	75 0c                	jne    8010837a <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010836e:	c7 04 24 4b 8f 10 80 	movl   $0x80108f4b,(%esp)
80108375:	e8 c0 81 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010837a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010837d:	8b 00                	mov    (%eax),%eax
8010837f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108384:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838a:	8b 55 18             	mov    0x18(%ebp),%edx
8010838d:	29 c2                	sub    %eax,%edx
8010838f:	89 d0                	mov    %edx,%eax
80108391:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108396:	77 0f                	ja     801083a7 <loaduvm+0x8c>
      n = sz - i;
80108398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839b:	8b 55 18             	mov    0x18(%ebp),%edx
8010839e:	29 c2                	sub    %eax,%edx
801083a0:	89 d0                	mov    %edx,%eax
801083a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083a5:	eb 07                	jmp    801083ae <loaduvm+0x93>
    else
      n = PGSIZE;
801083a7:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801083ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b1:	8b 55 14             	mov    0x14(%ebp),%edx
801083b4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801083b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083ba:	89 04 24             	mov    %eax,(%esp)
801083bd:	e8 b9 f6 ff ff       	call   80107a7b <p2v>
801083c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
801083c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801083cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801083d1:	8b 45 10             	mov    0x10(%ebp),%eax
801083d4:	89 04 24             	mov    %eax,(%esp)
801083d7:	e8 0b 9a ff ff       	call   80101de7 <readi>
801083dc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083df:	74 07                	je     801083e8 <loaduvm+0xcd>
      return -1;
801083e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083e6:	eb 18                	jmp    80108400 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801083e8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f2:	3b 45 18             	cmp    0x18(%ebp),%eax
801083f5:	0f 82 4b ff ff ff    	jb     80108346 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801083fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108400:	83 c4 24             	add    $0x24,%esp
80108403:	5b                   	pop    %ebx
80108404:	5d                   	pop    %ebp
80108405:	c3                   	ret    

80108406 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108406:	55                   	push   %ebp
80108407:	89 e5                	mov    %esp,%ebp
80108409:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010840c:	8b 45 10             	mov    0x10(%ebp),%eax
8010840f:	85 c0                	test   %eax,%eax
80108411:	79 0a                	jns    8010841d <allocuvm+0x17>
    return 0;
80108413:	b8 00 00 00 00       	mov    $0x0,%eax
80108418:	e9 c1 00 00 00       	jmp    801084de <allocuvm+0xd8>
  if(newsz < oldsz)
8010841d:	8b 45 10             	mov    0x10(%ebp),%eax
80108420:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108423:	73 08                	jae    8010842d <allocuvm+0x27>
    return oldsz;
80108425:	8b 45 0c             	mov    0xc(%ebp),%eax
80108428:	e9 b1 00 00 00       	jmp    801084de <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010842d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108430:	05 ff 0f 00 00       	add    $0xfff,%eax
80108435:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010843a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010843d:	e9 8d 00 00 00       	jmp    801084cf <allocuvm+0xc9>
    mem = kalloc();
80108442:	e8 51 a7 ff ff       	call   80102b98 <kalloc>
80108447:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010844a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010844e:	75 2c                	jne    8010847c <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108450:	c7 04 24 69 8f 10 80 	movl   $0x80108f69,(%esp)
80108457:	e8 44 7f ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010845c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010845f:	89 44 24 08          	mov    %eax,0x8(%esp)
80108463:	8b 45 10             	mov    0x10(%ebp),%eax
80108466:	89 44 24 04          	mov    %eax,0x4(%esp)
8010846a:	8b 45 08             	mov    0x8(%ebp),%eax
8010846d:	89 04 24             	mov    %eax,(%esp)
80108470:	e8 6b 00 00 00       	call   801084e0 <deallocuvm>
      return 0;
80108475:	b8 00 00 00 00       	mov    $0x0,%eax
8010847a:	eb 62                	jmp    801084de <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010847c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108483:	00 
80108484:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010848b:	00 
8010848c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010848f:	89 04 24             	mov    %eax,(%esp)
80108492:	e8 68 cf ff ff       	call   801053ff <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849a:	89 04 24             	mov    %eax,(%esp)
8010849d:	e8 cc f5 ff ff       	call   80107a6e <v2p>
801084a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084a5:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084ac:	00 
801084ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084b8:	00 
801084b9:	89 54 24 04          	mov    %edx,0x4(%esp)
801084bd:	8b 45 08             	mov    0x8(%ebp),%eax
801084c0:	89 04 24             	mov    %eax,(%esp)
801084c3:	e8 d8 fa ff ff       	call   80107fa0 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801084c8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801084d5:	0f 82 67 ff ff ff    	jb     80108442 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801084db:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084de:	c9                   	leave  
801084df:	c3                   	ret    

801084e0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084e0:	55                   	push   %ebp
801084e1:	89 e5                	mov    %esp,%ebp
801084e3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084e6:	8b 45 10             	mov    0x10(%ebp),%eax
801084e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084ec:	72 08                	jb     801084f6 <deallocuvm+0x16>
    return oldsz;
801084ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801084f1:	e9 a4 00 00 00       	jmp    8010859a <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801084f6:	8b 45 10             	mov    0x10(%ebp),%eax
801084f9:	05 ff 0f 00 00       	add    $0xfff,%eax
801084fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108503:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108506:	e9 80 00 00 00       	jmp    8010858b <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010850b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108515:	00 
80108516:	89 44 24 04          	mov    %eax,0x4(%esp)
8010851a:	8b 45 08             	mov    0x8(%ebp),%eax
8010851d:	89 04 24             	mov    %eax,(%esp)
80108520:	e8 d9 f9 ff ff       	call   80107efe <walkpgdir>
80108525:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108528:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010852c:	75 09                	jne    80108537 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010852e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108535:	eb 4d                	jmp    80108584 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010853a:	8b 00                	mov    (%eax),%eax
8010853c:	83 e0 01             	and    $0x1,%eax
8010853f:	85 c0                	test   %eax,%eax
80108541:	74 41                	je     80108584 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108546:	8b 00                	mov    (%eax),%eax
80108548:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010854d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108550:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108554:	75 0c                	jne    80108562 <deallocuvm+0x82>
        panic("kfree");
80108556:	c7 04 24 81 8f 10 80 	movl   $0x80108f81,(%esp)
8010855d:	e8 d8 7f ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108562:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108565:	89 04 24             	mov    %eax,(%esp)
80108568:	e8 0e f5 ff ff       	call   80107a7b <p2v>
8010856d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108570:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108573:	89 04 24             	mov    %eax,(%esp)
80108576:	e8 84 a5 ff ff       	call   80102aff <kfree>
      *pte = 0;
8010857b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108584:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010858b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108591:	0f 82 74 ff ff ff    	jb     8010850b <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108597:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010859a:	c9                   	leave  
8010859b:	c3                   	ret    

8010859c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010859c:	55                   	push   %ebp
8010859d:	89 e5                	mov    %esp,%ebp
8010859f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801085a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085a6:	75 0c                	jne    801085b4 <freevm+0x18>
    panic("freevm: no pgdir");
801085a8:	c7 04 24 87 8f 10 80 	movl   $0x80108f87,(%esp)
801085af:	e8 86 7f ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801085b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085bb:	00 
801085bc:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801085c3:	80 
801085c4:	8b 45 08             	mov    0x8(%ebp),%eax
801085c7:	89 04 24             	mov    %eax,(%esp)
801085ca:	e8 11 ff ff ff       	call   801084e0 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801085cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085d6:	eb 48                	jmp    80108620 <freevm+0x84>
    if(pgdir[i] & PTE_P){
801085d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085e2:	8b 45 08             	mov    0x8(%ebp),%eax
801085e5:	01 d0                	add    %edx,%eax
801085e7:	8b 00                	mov    (%eax),%eax
801085e9:	83 e0 01             	and    $0x1,%eax
801085ec:	85 c0                	test   %eax,%eax
801085ee:	74 2c                	je     8010861c <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801085f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085fa:	8b 45 08             	mov    0x8(%ebp),%eax
801085fd:	01 d0                	add    %edx,%eax
801085ff:	8b 00                	mov    (%eax),%eax
80108601:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108606:	89 04 24             	mov    %eax,(%esp)
80108609:	e8 6d f4 ff ff       	call   80107a7b <p2v>
8010860e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108614:	89 04 24             	mov    %eax,(%esp)
80108617:	e8 e3 a4 ff ff       	call   80102aff <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010861c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108620:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108627:	76 af                	jbe    801085d8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108629:	8b 45 08             	mov    0x8(%ebp),%eax
8010862c:	89 04 24             	mov    %eax,(%esp)
8010862f:	e8 cb a4 ff ff       	call   80102aff <kfree>
}
80108634:	c9                   	leave  
80108635:	c3                   	ret    

80108636 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108636:	55                   	push   %ebp
80108637:	89 e5                	mov    %esp,%ebp
80108639:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010863c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108643:	00 
80108644:	8b 45 0c             	mov    0xc(%ebp),%eax
80108647:	89 44 24 04          	mov    %eax,0x4(%esp)
8010864b:	8b 45 08             	mov    0x8(%ebp),%eax
8010864e:	89 04 24             	mov    %eax,(%esp)
80108651:	e8 a8 f8 ff ff       	call   80107efe <walkpgdir>
80108656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108659:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010865d:	75 0c                	jne    8010866b <clearpteu+0x35>
    panic("clearpteu");
8010865f:	c7 04 24 98 8f 10 80 	movl   $0x80108f98,(%esp)
80108666:	e8 cf 7e ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
8010866b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866e:	8b 00                	mov    (%eax),%eax
80108670:	83 e0 fb             	and    $0xfffffffb,%eax
80108673:	89 c2                	mov    %eax,%edx
80108675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108678:	89 10                	mov    %edx,(%eax)
}
8010867a:	c9                   	leave  
8010867b:	c3                   	ret    

8010867c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010867c:	55                   	push   %ebp
8010867d:	89 e5                	mov    %esp,%ebp
8010867f:	53                   	push   %ebx
80108680:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108683:	e8 b0 f9 ff ff       	call   80108038 <setupkvm>
80108688:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010868b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010868f:	75 0a                	jne    8010869b <copyuvm+0x1f>
    return 0;
80108691:	b8 00 00 00 00       	mov    $0x0,%eax
80108696:	e9 fd 00 00 00       	jmp    80108798 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010869b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086a2:	e9 d0 00 00 00       	jmp    80108777 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801086a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086b1:	00 
801086b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801086b6:	8b 45 08             	mov    0x8(%ebp),%eax
801086b9:	89 04 24             	mov    %eax,(%esp)
801086bc:	e8 3d f8 ff ff       	call   80107efe <walkpgdir>
801086c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086c8:	75 0c                	jne    801086d6 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801086ca:	c7 04 24 a2 8f 10 80 	movl   $0x80108fa2,(%esp)
801086d1:	e8 64 7e ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
801086d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d9:	8b 00                	mov    (%eax),%eax
801086db:	83 e0 01             	and    $0x1,%eax
801086de:	85 c0                	test   %eax,%eax
801086e0:	75 0c                	jne    801086ee <copyuvm+0x72>
      panic("copyuvm: page not present");
801086e2:	c7 04 24 bc 8f 10 80 	movl   $0x80108fbc,(%esp)
801086e9:	e8 4c 7e ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801086ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f1:	8b 00                	mov    (%eax),%eax
801086f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801086fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086fe:	8b 00                	mov    (%eax),%eax
80108700:	25 ff 0f 00 00       	and    $0xfff,%eax
80108705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108708:	e8 8b a4 ff ff       	call   80102b98 <kalloc>
8010870d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108710:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108714:	75 02                	jne    80108718 <copyuvm+0x9c>
      goto bad;
80108716:	eb 70                	jmp    80108788 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108718:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010871b:	89 04 24             	mov    %eax,(%esp)
8010871e:	e8 58 f3 ff ff       	call   80107a7b <p2v>
80108723:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010872a:	00 
8010872b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010872f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108732:	89 04 24             	mov    %eax,(%esp)
80108735:	e8 94 cd ff ff       	call   801054ce <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010873a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010873d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108740:	89 04 24             	mov    %eax,(%esp)
80108743:	e8 26 f3 ff ff       	call   80107a6e <v2p>
80108748:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010874b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010874f:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108753:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010875a:	00 
8010875b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010875f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108762:	89 04 24             	mov    %eax,(%esp)
80108765:	e8 36 f8 ff ff       	call   80107fa0 <mappages>
8010876a:	85 c0                	test   %eax,%eax
8010876c:	79 02                	jns    80108770 <copyuvm+0xf4>
      goto bad;
8010876e:	eb 18                	jmp    80108788 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108770:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010877d:	0f 82 24 ff ff ff    	jb     801086a7 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108786:	eb 10                	jmp    80108798 <copyuvm+0x11c>

bad:
  freevm(d);
80108788:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010878b:	89 04 24             	mov    %eax,(%esp)
8010878e:	e8 09 fe ff ff       	call   8010859c <freevm>
  return 0;
80108793:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108798:	83 c4 44             	add    $0x44,%esp
8010879b:	5b                   	pop    %ebx
8010879c:	5d                   	pop    %ebp
8010879d:	c3                   	ret    

8010879e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010879e:	55                   	push   %ebp
8010879f:	89 e5                	mov    %esp,%ebp
801087a1:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087ab:	00 
801087ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801087af:	89 44 24 04          	mov    %eax,0x4(%esp)
801087b3:	8b 45 08             	mov    0x8(%ebp),%eax
801087b6:	89 04 24             	mov    %eax,(%esp)
801087b9:	e8 40 f7 ff ff       	call   80107efe <walkpgdir>
801087be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801087c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c4:	8b 00                	mov    (%eax),%eax
801087c6:	83 e0 01             	and    $0x1,%eax
801087c9:	85 c0                	test   %eax,%eax
801087cb:	75 07                	jne    801087d4 <uva2ka+0x36>
    return 0;
801087cd:	b8 00 00 00 00       	mov    $0x0,%eax
801087d2:	eb 25                	jmp    801087f9 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801087d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d7:	8b 00                	mov    (%eax),%eax
801087d9:	83 e0 04             	and    $0x4,%eax
801087dc:	85 c0                	test   %eax,%eax
801087de:	75 07                	jne    801087e7 <uva2ka+0x49>
    return 0;
801087e0:	b8 00 00 00 00       	mov    $0x0,%eax
801087e5:	eb 12                	jmp    801087f9 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801087e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ea:	8b 00                	mov    (%eax),%eax
801087ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087f1:	89 04 24             	mov    %eax,(%esp)
801087f4:	e8 82 f2 ff ff       	call   80107a7b <p2v>
}
801087f9:	c9                   	leave  
801087fa:	c3                   	ret    

801087fb <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087fb:	55                   	push   %ebp
801087fc:	89 e5                	mov    %esp,%ebp
801087fe:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108801:	8b 45 10             	mov    0x10(%ebp),%eax
80108804:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108807:	e9 87 00 00 00       	jmp    80108893 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010880c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010880f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108814:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108817:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010881a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010881e:	8b 45 08             	mov    0x8(%ebp),%eax
80108821:	89 04 24             	mov    %eax,(%esp)
80108824:	e8 75 ff ff ff       	call   8010879e <uva2ka>
80108829:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010882c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108830:	75 07                	jne    80108839 <copyout+0x3e>
      return -1;
80108832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108837:	eb 69                	jmp    801088a2 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108839:	8b 45 0c             	mov    0xc(%ebp),%eax
8010883c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010883f:	29 c2                	sub    %eax,%edx
80108841:	89 d0                	mov    %edx,%eax
80108843:	05 00 10 00 00       	add    $0x1000,%eax
80108848:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010884b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010884e:	3b 45 14             	cmp    0x14(%ebp),%eax
80108851:	76 06                	jbe    80108859 <copyout+0x5e>
      n = len;
80108853:	8b 45 14             	mov    0x14(%ebp),%eax
80108856:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108859:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010885c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010885f:	29 c2                	sub    %eax,%edx
80108861:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108864:	01 c2                	add    %eax,%edx
80108866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108869:	89 44 24 08          	mov    %eax,0x8(%esp)
8010886d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108870:	89 44 24 04          	mov    %eax,0x4(%esp)
80108874:	89 14 24             	mov    %edx,(%esp)
80108877:	e8 52 cc ff ff       	call   801054ce <memmove>
    len -= n;
8010887c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010887f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108885:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108888:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010888b:	05 00 10 00 00       	add    $0x1000,%eax
80108890:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108893:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108897:	0f 85 6f ff ff ff    	jne    8010880c <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010889d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088a2:	c9                   	leave  
801088a3:	c3                   	ret    
