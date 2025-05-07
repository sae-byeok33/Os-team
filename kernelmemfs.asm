
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 8a 19 80       	mov    $0x80198a80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 67 33 10 80       	mov    $0x80103367,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 e0 a4 10 80       	push   $0x8010a4e0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 e9 4a 00 00       	call   80104b67 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 e7 a4 10 80       	push   $0x8010a4e7
801000c2:	50                   	push   %eax
801000c3:	e8 42 49 00 00       	call   80104a0a <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave
801000f2:	c3                   	ret

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 83 4a 00 00       	call   80104b89 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 b2 4a 00 00       	call   80104bf7 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 ef 48 00 00       	call   80104a46 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 31 4a 00 00       	call   80104bf7 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 6e 48 00 00       	call   80104a46 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 ee a4 10 80       	push   $0x8010a4ee
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave
80100200:	c3                   	ret

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 ae a1 00 00       	call   8010a3e0 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave
80100239:	c3                   	ret

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 a9 48 00 00       	call   80104af8 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff a4 10 80       	push   $0x8010a4ff
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 63 a1 00 00       	call   8010a3e0 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave
80100282:	c3                   	ret

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 60 48 00 00       	call   80104af8 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 a5 10 80       	push   $0x8010a506
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 ef 47 00 00       	call   80104aaa <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 be 48 00 00       	call   80104b89 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 bc 48 00 00       	call   80104bf7 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave
80100340:	c3                   	ret

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8b 03 00 00       	call   8010076e <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave
801003f3:	c3                   	ret

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 74 47 00 00       	call   80104b89 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d a5 10 80       	push   $0x8010a50d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 1f 03 00 00       	call   8010076e <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 16 a5 10 80 	movl   $0x8010a516,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 43 02 00 00       	call   8010076e <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 26 02 00 00       	call   8010076e <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 17 02 00 00       	call   8010076e <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 09 02 00 00       	call   8010076e <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 54 46 00 00       	call   80104bf7 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave
801005a8:	c3                   	ret

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 39 25 00 00       	call   80102afc <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 1d a5 10 80       	push   $0x8010a51d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 31 a5 10 80       	push   $0x8010a531
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 46 46 00 00       	call   80104c49 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 a5 10 80       	push   $0x8010a533
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	90                   	nop
8010063c:	eb fd                	jmp    8010063b <panic+0x92>

8010063e <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063e:	55                   	push   %ebp
8010063f:	89 e5                	mov    %esp,%ebp
80100641:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100644:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100648:	75 64                	jne    801006ae <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010064a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100650:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100655:	89 c8                	mov    %ecx,%eax
80100657:	f7 ea                	imul   %edx
80100659:	89 d0                	mov    %edx,%eax
8010065b:	c1 f8 04             	sar    $0x4,%eax
8010065e:	89 ca                	mov    %ecx,%edx
80100660:	c1 fa 1f             	sar    $0x1f,%edx
80100663:	29 d0                	sub    %edx,%eax
80100665:	6b d0 35             	imul   $0x35,%eax,%edx
80100668:	89 c8                	mov    %ecx,%eax
8010066a:	29 d0                	sub    %edx,%eax
8010066c:	ba 35 00 00 00       	mov    $0x35,%edx
80100671:	29 c2                	sub    %eax,%edx
80100673:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100678:	01 d0                	add    %edx,%eax
8010067a:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100684:	3d 23 04 00 00       	cmp    $0x423,%eax
80100689:	0f 8e dc 00 00 00    	jle    8010076b <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100694:	83 e8 35             	sub    $0x35,%eax
80100697:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069c:	83 ec 0c             	sub    $0xc,%esp
8010069f:	6a 1e                	push   $0x1e
801006a1:	e8 a7 7c 00 00       	call   8010834d <graphic_scroll_up>
801006a6:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a9:	e9 bd 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
  }else if(c == BACKSPACE){
801006ae:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b5:	75 1f                	jne    801006d6 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bc:	85 c0                	test   %eax,%eax
801006be:	0f 8e a7 00 00 00    	jle    8010076b <graphic_putc+0x12d>
801006c4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c9:	83 e8 01             	sub    $0x1,%eax
801006cc:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d1:	e9 95 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006db:	3d 23 04 00 00       	cmp    $0x423,%eax
801006e0:	7e 1a                	jle    801006fc <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e7:	83 e8 35             	sub    $0x35,%eax
801006ea:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ef:	83 ec 0c             	sub    $0xc,%esp
801006f2:	6a 1e                	push   $0x1e
801006f4:	e8 54 7c 00 00       	call   8010834d <graphic_scroll_up>
801006f9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fc:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100702:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	f7 ea                	imul   %edx
8010070b:	89 d0                	mov    %edx,%eax
8010070d:	c1 f8 04             	sar    $0x4,%eax
80100710:	89 ca                	mov    %ecx,%edx
80100712:	c1 fa 1f             	sar    $0x1f,%edx
80100715:	29 d0                	sub    %edx,%eax
80100717:	6b d0 35             	imul   $0x35,%eax,%edx
8010071a:	89 c8                	mov    %ecx,%eax
8010071c:	29 d0                	sub    %edx,%eax
8010071e:	89 c2                	mov    %eax,%edx
80100720:	c1 e2 04             	shl    $0x4,%edx
80100723:	29 c2                	sub    %eax,%edx
80100725:	8d 42 02             	lea    0x2(%edx),%eax
80100728:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072b:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100731:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100736:	89 c8                	mov    %ecx,%eax
80100738:	f7 ea                	imul   %edx
8010073a:	c1 fa 04             	sar    $0x4,%edx
8010073d:	89 c8                	mov    %ecx,%eax
8010073f:	c1 f8 1f             	sar    $0x1f,%eax
80100742:	29 c2                	sub    %eax,%edx
80100744:	6b c2 1e             	imul   $0x1e,%edx,%eax
80100747:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074a:	83 ec 04             	sub    $0x4,%esp
8010074d:	ff 75 08             	push   0x8(%ebp)
80100750:	ff 75 f0             	push   -0x10(%ebp)
80100753:	ff 75 f4             	push   -0xc(%ebp)
80100756:	e8 5f 7c 00 00       	call   801083ba <font_render>
8010075b:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100763:	83 c0 01             	add    $0x1,%eax
80100766:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076b:	90                   	nop
8010076c:	c9                   	leave
8010076d:	c3                   	ret

8010076e <consputc>:


void
consputc(int c)
{
8010076e:	55                   	push   %ebp
8010076f:	89 e5                	mov    %esp,%ebp
80100771:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100774:	a1 ec 19 19 80       	mov    0x801919ec,%eax
80100779:	85 c0                	test   %eax,%eax
8010077b:	74 08                	je     80100785 <consputc+0x17>
    cli();
8010077d:	e8 bf fb ff ff       	call   80100341 <cli>
    for(;;)
80100782:	90                   	nop
80100783:	eb fd                	jmp    80100782 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 2e 60 00 00       	call   801067c6 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 21 60 00 00       	call   801067c6 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 14 60 00 00       	call   801067c6 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 04 60 00 00       	call   801067c6 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6e fe ff ff       	call   8010063e <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave
801007d5:	c3                   	ret

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 99 43 00 00       	call   80104b89 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 58 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 18 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1c ff ff ff       	call   8010076e <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e1 00 00 00    	je     80100949 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c6 00 00 00       	jmp    80100949 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b6 00 00 00    	je     8010094c <consoleintr+0x176>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 be fe ff ff       	call   8010076e <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 94 00 00 00       	jmp    8010094c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 8d 00 00 00    	je     8010094f <consoleintr+0x179>
801008c2:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008c8:	a1 e0 19 19 80       	mov    0x801919e0,%eax
801008cd:	29 c2                	sub    %eax,%edx
801008cf:	83 fa 7f             	cmp    $0x7f,%edx
801008d2:	77 7b                	ja     8010094f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 62 fe ff ff       	call   8010076e <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100921:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100926:	83 e8 80             	sub    $0xffffff80,%eax
80100929:	39 c2                	cmp    %eax,%edx
8010092b:	75 22                	jne    8010094f <consoleintr+0x179>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 15 3c 00 00       	call   80104559 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	eb 06                	jmp    8010094f <consoleintr+0x179>
      break;
80100949:	90                   	nop
8010094a:	eb 04                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094c:	90                   	nop
8010094d:	eb 01                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094f:	90                   	nop
  while((c = getc()) >= 0){
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	ff d0                	call   *%eax
80100955:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010095c:	0f 89 96 fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
80100962:	83 ec 0c             	sub    $0xc,%esp
80100965:	68 00 1a 19 80       	push   $0x80191a00
8010096a:	e8 88 42 00 00       	call   80104bf7 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 9a 3c 00 00       	call   80104617 <procdump>
  }
}
8010097d:	90                   	nop
8010097e:	c9                   	leave
8010097f:	c3                   	ret

80100980 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100980:	55                   	push   %ebp
80100981:	89 e5                	mov    %esp,%ebp
80100983:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100986:	83 ec 0c             	sub    $0xc,%esp
80100989:	ff 75 08             	push   0x8(%ebp)
8010098c:	e8 74 11 00 00       	call   80101b05 <iunlock>
80100991:	83 c4 10             	add    $0x10,%esp
  target = n;
80100994:	8b 45 10             	mov    0x10(%ebp),%eax
80100997:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
8010099a:	83 ec 0c             	sub    $0xc,%esp
8010099d:	68 00 1a 19 80       	push   $0x80191a00
801009a2:	e8 e2 41 00 00       	call   80104b89 <acquire>
801009a7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009aa:	e9 ab 00 00 00       	jmp    80100a5a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009af:	e8 83 30 00 00       	call   80103a37 <myproc>
801009b4:	8b 40 24             	mov    0x24(%eax),%eax
801009b7:	85 c0                	test   %eax,%eax
801009b9:	74 28                	je     801009e3 <consoleread+0x63>
        release(&cons.lock);
801009bb:	83 ec 0c             	sub    $0xc,%esp
801009be:	68 00 1a 19 80       	push   $0x80191a00
801009c3:	e8 2f 42 00 00       	call   80104bf7 <release>
801009c8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	ff 75 08             	push   0x8(%ebp)
801009d1:	e8 1c 10 00 00       	call   801019f2 <ilock>
801009d6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009de:	e9 ab 00 00 00       	jmp    80100a8e <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
801009e3:	83 ec 08             	sub    $0x8,%esp
801009e6:	68 00 1a 19 80       	push   $0x80191a00
801009eb:	68 e0 19 19 80       	push   $0x801919e0
801009f0:	e8 7a 3a 00 00       	call   8010446f <sleep>
801009f5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f8:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009fe:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100a03:	39 c2                	cmp    %eax,%edx
80100a05:	74 a8                	je     801009af <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a07:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a0c:	8d 50 01             	lea    0x1(%eax),%edx
80100a0f:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a15:	83 e0 7f             	and    $0x7f,%eax
80100a18:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a1f:	0f be c0             	movsbl %al,%eax
80100a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a25:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a29:	75 17                	jne    80100a42 <consoleread+0xc2>
      if(n < target){
80100a2b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a2e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a31:	73 2f                	jae    80100a62 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a33:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a40:	eb 20                	jmp    80100a62 <consoleread+0xe2>
    }
    *dst++ = c;
80100a42:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a45:	8d 50 01             	lea    0x1(%eax),%edx
80100a48:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a4e:	88 10                	mov    %dl,(%eax)
    --n;
80100a50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a54:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a58:	74 0b                	je     80100a65 <consoleread+0xe5>
  while(n > 0){
80100a5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a5e:	7f 98                	jg     801009f8 <consoleread+0x78>
80100a60:	eb 04                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a62:	90                   	nop
80100a63:	eb 01                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a65:	90                   	nop
  }
  release(&cons.lock);
80100a66:	83 ec 0c             	sub    $0xc,%esp
80100a69:	68 00 1a 19 80       	push   $0x80191a00
80100a6e:	e8 84 41 00 00       	call   80104bf7 <release>
80100a73:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	push   0x8(%ebp)
80100a7c:	e8 71 0f 00 00       	call   801019f2 <ilock>
80100a81:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a84:	8b 45 10             	mov    0x10(%ebp),%eax
80100a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a8a:	29 c2                	sub    %eax,%edx
80100a8c:	89 d0                	mov    %edx,%eax
}
80100a8e:	c9                   	leave
80100a8f:	c3                   	ret

80100a90 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a90:	55                   	push   %ebp
80100a91:	89 e5                	mov    %esp,%ebp
80100a93:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a96:	83 ec 0c             	sub    $0xc,%esp
80100a99:	ff 75 08             	push   0x8(%ebp)
80100a9c:	e8 64 10 00 00       	call   80101b05 <iunlock>
80100aa1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aa4:	83 ec 0c             	sub    $0xc,%esp
80100aa7:	68 00 1a 19 80       	push   $0x80191a00
80100aac:	e8 d8 40 00 00       	call   80104b89 <acquire>
80100ab1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ab4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100abb:	eb 21                	jmp    80100ade <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ac3:	01 d0                	add    %edx,%eax
80100ac5:	0f b6 00             	movzbl (%eax),%eax
80100ac8:	0f be c0             	movsbl %al,%eax
80100acb:	0f b6 c0             	movzbl %al,%eax
80100ace:	83 ec 0c             	sub    $0xc,%esp
80100ad1:	50                   	push   %eax
80100ad2:	e8 97 fc ff ff       	call   8010076e <consputc>
80100ad7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ada:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ae1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ae4:	7c d7                	jl     80100abd <consolewrite+0x2d>
  release(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 00 1a 19 80       	push   $0x80191a00
80100aee:	e8 04 41 00 00       	call   80104bf7 <release>
80100af3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	ff 75 08             	push   0x8(%ebp)
80100afc:	e8 f1 0e 00 00       	call   801019f2 <ilock>
80100b01:	83 c4 10             	add    $0x10,%esp

  return n;
80100b04:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b07:	c9                   	leave
80100b08:	c3                   	ret

80100b09 <consoleinit>:

void
consoleinit(void)
{
80100b09:	55                   	push   %ebp
80100b0a:	89 e5                	mov    %esp,%ebp
80100b0c:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b0f:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b16:	00 00 00 
  initlock(&cons.lock, "console");
80100b19:	83 ec 08             	sub    $0x8,%esp
80100b1c:	68 37 a5 10 80       	push   $0x8010a537
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 3c 40 00 00       	call   80104b67 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 3f a5 10 80 	movl   $0x8010a53f,-0xc(%ebp)
80100b49:	eb 19                	jmp    80100b64 <consoleinit+0x5b>
    graphic_putc(*p);
80100b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b4e:	0f b6 00             	movzbl (%eax),%eax
80100b51:	0f be c0             	movsbl %al,%eax
80100b54:	83 ec 0c             	sub    $0xc,%esp
80100b57:	50                   	push   %eax
80100b58:	e8 e1 fa ff ff       	call   8010063e <graphic_putc>
80100b5d:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b67:	0f b6 00             	movzbl (%eax),%eax
80100b6a:	84 c0                	test   %al,%al
80100b6c:	75 dd                	jne    80100b4b <consoleinit+0x42>
  
  cons.locking = 1;
80100b6e:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b75:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b78:	83 ec 08             	sub    $0x8,%esp
80100b7b:	6a 00                	push   $0x0
80100b7d:	6a 01                	push   $0x1
80100b7f:	e8 b2 1a 00 00       	call   80102636 <ioapicenable>
80100b84:	83 c4 10             	add    $0x10,%esp
}
80100b87:	90                   	nop
80100b88:	c9                   	leave
80100b89:	c3                   	ret

80100b8a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b8a:	55                   	push   %ebp
80100b8b:	89 e5                	mov    %esp,%ebp
80100b8d:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b93:	e8 9f 2e 00 00       	call   80103a37 <myproc>
80100b98:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b9b:	e8 9e 24 00 00       	call   8010303e <begin_op>

  if((ip = namei(path)) == 0){
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	ff 75 08             	push   0x8(%ebp)
80100ba6:	e8 7a 19 00 00       	call   80102525 <namei>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bb1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bb5:	75 1f                	jne    80100bd6 <exec+0x4c>
    end_op();
80100bb7:	e8 0e 25 00 00       	call   801030ca <end_op>
    cprintf("exec: fail\n");
80100bbc:	83 ec 0c             	sub    $0xc,%esp
80100bbf:	68 55 a5 10 80       	push   $0x8010a555
80100bc4:	e8 2b f8 ff ff       	call   801003f4 <cprintf>
80100bc9:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 f1 03 00 00       	jmp    80100fc7 <exec+0x43d>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 11 0e 00 00       	call   801019f2 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 e0 12 00 00       	call   80101ede <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 34             	cmp    $0x34,%eax
80100c04:	0f 85 66 03 00 00    	jne    80100f70 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 58 03 00 00    	jne    80100f73 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 a2 6b 00 00       	call   801077c2 <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 49 03 00 00    	je     80100f76 <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 de 00 00 00       	jmp    80100d27 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 80 12 00 00       	call   80101ede <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 0f 03 00 00    	jne    80100f79 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	0f 85 a0 00 00 00    	jne    80100d19 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c79:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c7f:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c85:	39 c2                	cmp    %eax,%edx
80100c87:	0f 82 ef 02 00 00    	jb     80100f7c <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c8d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c93:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c99:	01 c2                	add    %eax,%edx
80100c9b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ca1:	39 c2                	cmp    %eax,%edx
80100ca3:	0f 82 d6 02 00 00    	jb     80100f7f <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ca9:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100caf:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb5:	01 d0                	add    %edx,%eax
80100cb7:	83 ec 04             	sub    $0x4,%esp
80100cba:	50                   	push   %eax
80100cbb:	ff 75 e0             	push   -0x20(%ebp)
80100cbe:	ff 75 d4             	push   -0x2c(%ebp)
80100cc1:	e8 f6 6e 00 00       	call   80107bbc <allocuvm>
80100cc6:	83 c4 10             	add    $0x10,%esp
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 ac 02 00 00    	je     80100f82 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100cd6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cdc:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ce1:	85 c0                	test   %eax,%eax
80100ce3:	0f 85 9c 02 00 00    	jne    80100f85 <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ce9:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cef:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cf5:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	52                   	push   %edx
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	push   -0x28(%ebp)
80100d03:	51                   	push   %ecx
80100d04:	ff 75 d4             	push   -0x2c(%ebp)
80100d07:	e8 e3 6d 00 00       	call   80107aef <loaduvm>
80100d0c:	83 c4 20             	add    $0x20,%esp
80100d0f:	85 c0                	test   %eax,%eax
80100d11:	0f 88 71 02 00 00    	js     80100f88 <exec+0x3fe>
80100d17:	eb 01                	jmp    80100d1a <exec+0x190>
      continue;
80100d19:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d1a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d21:	83 c0 20             	add    $0x20,%eax
80100d24:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d27:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d2e:	0f b7 c0             	movzwl %ax,%eax
80100d31:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d34:	0f 8c 0f ff ff ff    	jl     80100c49 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d3a:	83 ec 0c             	sub    $0xc,%esp
80100d3d:	ff 75 d8             	push   -0x28(%ebp)
80100d40:	e8 de 0e 00 00       	call   80101c23 <iunlockput>
80100d45:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d48:	e8 7d 23 00 00       	call   801030ca <end_op>
  ip = 0;
80100d4d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d57:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d67:	05 00 20 00 00       	add    $0x2000,%eax
80100d6c:	83 ec 04             	sub    $0x4,%esp
80100d6f:	50                   	push   %eax
80100d70:	ff 75 e0             	push   -0x20(%ebp)
80100d73:	ff 75 d4             	push   -0x2c(%ebp)
80100d76:	e8 41 6e 00 00       	call   80107bbc <allocuvm>
80100d7b:	83 c4 10             	add    $0x10,%esp
80100d7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d85:	0f 84 00 02 00 00    	je     80100f8b <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d93:	83 ec 08             	sub    $0x8,%esp
80100d96:	50                   	push   %eax
80100d97:	ff 75 d4             	push   -0x2c(%ebp)
80100d9a:	e8 7f 70 00 00       	call   80107e1e <clearpteu>
80100d9f:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 96 00 00 00       	jmp    80100e4a <exec+0x2c0>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	0f 87 d0 01 00 00    	ja     80100f8e <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcb:	01 d0                	add    %edx,%eax
80100dcd:	8b 00                	mov    (%eax),%eax
80100dcf:	83 ec 0c             	sub    $0xc,%esp
80100dd2:	50                   	push   %eax
80100dd3:	e8 75 42 00 00       	call   8010504d <strlen>
80100dd8:	83 c4 10             	add    $0x10,%esp
80100ddb:	89 c2                	mov    %eax,%edx
80100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de0:	29 d0                	sub    %edx,%eax
80100de2:	83 e8 01             	sub    $0x1,%eax
80100de5:	83 e0 fc             	and    $0xfffffffc,%eax
80100de8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 d0                	add    %edx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	83 ec 0c             	sub    $0xc,%esp
80100dff:	50                   	push   %eax
80100e00:	e8 48 42 00 00       	call   8010504d <strlen>
80100e05:	83 c4 10             	add    $0x10,%esp
80100e08:	83 c0 01             	add    $0x1,%eax
80100e0b:	89 c1                	mov    %eax,%ecx
80100e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1a:	01 d0                	add    %edx,%eax
80100e1c:	8b 00                	mov    (%eax),%eax
80100e1e:	51                   	push   %ecx
80100e1f:	50                   	push   %eax
80100e20:	ff 75 dc             	push   -0x24(%ebp)
80100e23:	ff 75 d4             	push   -0x2c(%ebp)
80100e26:	e8 92 71 00 00       	call   80107fbd <copyout>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	85 c0                	test   %eax,%eax
80100e30:	0f 88 5b 01 00 00    	js     80100f91 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e39:	8d 50 03             	lea    0x3(%eax),%edx
80100e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e3f:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e46:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e57:	01 d0                	add    %edx,%eax
80100e59:	8b 00                	mov    (%eax),%eax
80100e5b:	85 c0                	test   %eax,%eax
80100e5d:	0f 85 51 ff ff ff    	jne    80100db4 <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e66:	83 c0 03             	add    $0x3,%eax
80100e69:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e70:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e74:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e7b:	ff ff ff 
  ustack[1] = argc;
80100e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e81:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8a:	83 c0 01             	add    $0x1,%eax
80100e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e94:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e97:	29 d0                	sub    %edx,%eax
80100e99:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea2:	83 c0 04             	add    $0x4,%eax
80100ea5:	c1 e0 02             	shl    $0x2,%eax
80100ea8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eae:	83 c0 04             	add    $0x4,%eax
80100eb1:	c1 e0 02             	shl    $0x2,%eax
80100eb4:	50                   	push   %eax
80100eb5:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ebb:	50                   	push   %eax
80100ebc:	ff 75 dc             	push   -0x24(%ebp)
80100ebf:	ff 75 d4             	push   -0x2c(%ebp)
80100ec2:	e8 f6 70 00 00       	call   80107fbd <copyout>
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	0f 88 c2 00 00 00    	js     80100f94 <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ede:	eb 17                	jmp    80100ef7 <exec+0x36d>
    if(*s == '/')
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	0f b6 00             	movzbl (%eax),%eax
80100ee6:	3c 2f                	cmp    $0x2f,%al
80100ee8:	75 09                	jne    80100ef3 <exec+0x369>
      last = s+1;
80100eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eed:	83 c0 01             	add    $0x1,%eax
80100ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ef3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efa:	0f b6 00             	movzbl (%eax),%eax
80100efd:	84 c0                	test   %al,%al
80100eff:	75 df                	jne    80100ee0 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	83 c0 6c             	add    $0x6c,%eax
80100f07:	83 ec 04             	sub    $0x4,%esp
80100f0a:	6a 10                	push   $0x10
80100f0c:	ff 75 f0             	push   -0x10(%ebp)
80100f0f:	50                   	push   %eax
80100f10:	e8 ed 40 00 00       	call   80105002 <safestrcpy>
80100f15:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1b:	8b 40 04             	mov    0x4(%eax),%eax
80100f1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f27:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f30:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f35:	8b 40 18             	mov    0x18(%eax),%eax
80100f38:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f3e:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f41:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f44:	8b 40 18             	mov    0x18(%eax),%eax
80100f47:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f4a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f4d:	83 ec 0c             	sub    $0xc,%esp
80100f50:	ff 75 d0             	push   -0x30(%ebp)
80100f53:	e8 88 69 00 00       	call   801078e0 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 1f 6e 00 00       	call   80107d85 <freevm>
80100f66:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f69:	b8 00 00 00 00       	mov    $0x0,%eax
80100f6e:	eb 57                	jmp    80100fc7 <exec+0x43d>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 22                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f73:	90                   	nop
80100f74:	eb 1f                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f76:	90                   	nop
80100f77:	eb 1c                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 19                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 16                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 13                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 10                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 0d                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 0a                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f8b:	90                   	nop
80100f8c:	eb 07                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f8e:	90                   	nop
80100f8f:	eb 04                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f91:	90                   	nop
80100f92:	eb 01                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f94:	90                   	nop

 bad:
  if(pgdir)
80100f95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f99:	74 0e                	je     80100fa9 <exec+0x41f>
    freevm(pgdir);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d4             	push   -0x2c(%ebp)
80100fa1:	e8 df 6d 00 00       	call   80107d85 <freevm>
80100fa6:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fad:	74 13                	je     80100fc2 <exec+0x438>
    iunlockput(ip);
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	ff 75 d8             	push   -0x28(%ebp)
80100fb5:	e8 69 0c 00 00       	call   80101c23 <iunlockput>
80100fba:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fbd:	e8 08 21 00 00       	call   801030ca <end_op>
  }
  return -1;
80100fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc7:	c9                   	leave
80100fc8:	c3                   	ret

80100fc9 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc9:	55                   	push   %ebp
80100fca:	89 e5                	mov    %esp,%ebp
80100fcc:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fcf:	83 ec 08             	sub    $0x8,%esp
80100fd2:	68 61 a5 10 80       	push   $0x8010a561
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 86 3b 00 00       	call   80104b67 <initlock>
80100fe1:	83 c4 10             	add    $0x10,%esp
}
80100fe4:	90                   	nop
80100fe5:	c9                   	leave
80100fe6:	c3                   	ret

80100fe7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fe7:	55                   	push   %ebp
80100fe8:	89 e5                	mov    %esp,%ebp
80100fea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fed:	83 ec 0c             	sub    $0xc,%esp
80100ff0:	68 a0 1a 19 80       	push   $0x80191aa0
80100ff5:	e8 8f 3b 00 00       	call   80104b89 <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80101004:	eb 2d                	jmp    80101033 <filealloc+0x4c>
    if(f->ref == 0){
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	8b 40 04             	mov    0x4(%eax),%eax
8010100c:	85 c0                	test   %eax,%eax
8010100e:	75 1f                	jne    8010102f <filealloc+0x48>
      f->ref = 1;
80101010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101013:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 a0 1a 19 80       	push   $0x80191aa0
80101022:	e8 d0 3b 00 00       	call   80104bf7 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 1a 19 80       	push   $0x80191aa0
80101045:	e8 ad 3b 00 00       	call   80104bf7 <release>
8010104a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010104d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101052:	c9                   	leave
80101053:	c3                   	ret

80101054 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101054:	55                   	push   %ebp
80101055:	89 e5                	mov    %esp,%ebp
80101057:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 a0 1a 19 80       	push   $0x80191aa0
80101062:	e8 22 3b 00 00       	call   80104b89 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 68 a5 10 80       	push   $0x8010a568
8010107c:	e8 28 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 1a 19 80       	push   $0x80191aa0
80101098:	e8 5a 3b 00 00       	call   80104bf7 <release>
8010109d:	83 c4 10             	add    $0x10,%esp
  return f;
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a3:	c9                   	leave
801010a4:	c3                   	ret

801010a5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a5:	55                   	push   %ebp
801010a6:	89 e5                	mov    %esp,%ebp
801010a8:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ab:	83 ec 0c             	sub    $0xc,%esp
801010ae:	68 a0 1a 19 80       	push   $0x80191aa0
801010b3:	e8 d1 3a 00 00       	call   80104b89 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 70 a5 10 80       	push   $0x8010a570
801010cd:	e8 d7 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 04             	mov    0x4(%eax),%eax
801010d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801010db:	8b 45 08             	mov    0x8(%ebp),%eax
801010de:	89 50 04             	mov    %edx,0x4(%eax)
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 04             	mov    0x4(%eax),%eax
801010e7:	85 c0                	test   %eax,%eax
801010e9:	7e 15                	jle    80101100 <fileclose+0x5b>
    release(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 a0 1a 19 80       	push   $0x80191aa0
801010f3:	e8 ff 3a 00 00       	call   80104bf7 <release>
801010f8:	83 c4 10             	add    $0x10,%esp
801010fb:	e9 8b 00 00 00       	jmp    8010118b <fileclose+0xe6>
    return;
  }
  ff = *f;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 10                	mov    (%eax),%edx
80101105:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101108:	8b 50 04             	mov    0x4(%eax),%edx
8010110b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010110e:	8b 50 08             	mov    0x8(%eax),%edx
80101111:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101114:	8b 50 0c             	mov    0xc(%eax),%edx
80101117:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111a:	8b 50 10             	mov    0x10(%eax),%edx
8010111d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101120:	8b 40 14             	mov    0x14(%eax),%eax
80101123:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101130:	8b 45 08             	mov    0x8(%ebp),%eax
80101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	68 a0 1a 19 80       	push   $0x80191aa0
80101141:	e8 b1 3a 00 00       	call   80104bf7 <release>
80101146:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101149:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114c:	83 f8 01             	cmp    $0x1,%eax
8010114f:	75 19                	jne    8010116a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101155:	0f be d0             	movsbl %al,%edx
80101158:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115b:	83 ec 08             	sub    $0x8,%esp
8010115e:	52                   	push   %edx
8010115f:	50                   	push   %eax
80101160:	e8 5a 25 00 00       	call   801036bf <pipeclose>
80101165:	83 c4 10             	add    $0x10,%esp
80101168:	eb 21                	jmp    8010118b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116d:	83 f8 02             	cmp    $0x2,%eax
80101170:	75 19                	jne    8010118b <fileclose+0xe6>
    begin_op();
80101172:	e8 c7 1e 00 00       	call   8010303e <begin_op>
    iput(ff.ip);
80101177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 d0 09 00 00       	call   80101b53 <iput>
80101183:	83 c4 10             	add    $0x10,%esp
    end_op();
80101186:	e8 3f 1f 00 00       	call   801030ca <end_op>
  }
}
8010118b:	c9                   	leave
8010118c:	c3                   	ret

8010118d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010118d:	55                   	push   %ebp
8010118e:	89 e5                	mov    %esp,%ebp
80101190:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 00                	mov    (%eax),%eax
80101198:	83 f8 02             	cmp    $0x2,%eax
8010119b:	75 40                	jne    801011dd <filestat+0x50>
    ilock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 46 08 00 00       	call   801019f2 <ilock>
801011ac:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 40 10             	mov    0x10(%eax),%eax
801011b5:	83 ec 08             	sub    $0x8,%esp
801011b8:	ff 75 0c             	push   0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 d7 0c 00 00       	call   80101e98 <stati>
801011c1:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	8b 40 10             	mov    0x10(%eax),%eax
801011ca:	83 ec 0c             	sub    $0xc,%esp
801011cd:	50                   	push   %eax
801011ce:	e8 32 09 00 00       	call   80101b05 <iunlock>
801011d3:	83 c4 10             	add    $0x10,%esp
    return 0;
801011d6:	b8 00 00 00 00       	mov    $0x0,%eax
801011db:	eb 05                	jmp    801011e2 <filestat+0x55>
  }
  return -1;
801011dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e2:	c9                   	leave
801011e3:	c3                   	ret

801011e4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e4:	55                   	push   %ebp
801011e5:	89 e5                	mov    %esp,%ebp
801011e7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ea:	8b 45 08             	mov    0x8(%ebp),%eax
801011ed:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f1:	84 c0                	test   %al,%al
801011f3:	75 0a                	jne    801011ff <fileread+0x1b>
    return -1;
801011f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fa:	e9 9b 00 00 00       	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 00                	mov    (%eax),%eax
80101204:	83 f8 01             	cmp    $0x1,%eax
80101207:	75 1a                	jne    80101223 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 0c             	mov    0xc(%eax),%eax
8010120f:	83 ec 04             	sub    $0x4,%esp
80101212:	ff 75 10             	push   0x10(%ebp)
80101215:	ff 75 0c             	push   0xc(%ebp)
80101218:	50                   	push   %eax
80101219:	e8 4e 26 00 00       	call   8010386c <piperead>
8010121e:	83 c4 10             	add    $0x10,%esp
80101221:	eb 77                	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_INODE){
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 00                	mov    (%eax),%eax
80101228:	83 f8 02             	cmp    $0x2,%eax
8010122b:	75 60                	jne    8010128d <fileread+0xa9>
    ilock(f->ip);
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	50                   	push   %eax
80101237:	e8 b6 07 00 00       	call   801019f2 <ilock>
8010123c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010123f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 40 10             	mov    0x10(%eax),%eax
8010124e:	51                   	push   %ecx
8010124f:	52                   	push   %edx
80101250:	ff 75 0c             	push   0xc(%ebp)
80101253:	50                   	push   %eax
80101254:	e8 85 0c 00 00       	call   80101ede <readi>
80101259:	83 c4 10             	add    $0x10,%esp
8010125c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010125f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101263:	7e 11                	jle    80101276 <fileread+0x92>
      f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	83 ec 0c             	sub    $0xc,%esp
8010127f:	50                   	push   %eax
80101280:	e8 80 08 00 00       	call   80101b05 <iunlock>
80101285:	83 c4 10             	add    $0x10,%esp
    return r;
80101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128b:	eb 0d                	jmp    8010129a <fileread+0xb6>
  }
  panic("fileread");
8010128d:	83 ec 0c             	sub    $0xc,%esp
80101290:	68 7a a5 10 80       	push   $0x8010a57a
80101295:	e8 0f f3 ff ff       	call   801005a9 <panic>
}
8010129a:	c9                   	leave
8010129b:	c3                   	ret

8010129c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010129c:	55                   	push   %ebp
8010129d:	89 e5                	mov    %esp,%ebp
8010129f:	53                   	push   %ebx
801012a0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012aa:	84 c0                	test   %al,%al
801012ac:	75 0a                	jne    801012b8 <filewrite+0x1c>
    return -1;
801012ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b3:	e9 1b 01 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 01             	cmp    $0x1,%eax
801012c0:	75 1d                	jne    801012df <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 40 0c             	mov    0xc(%eax),%eax
801012c8:	83 ec 04             	sub    $0x4,%esp
801012cb:	ff 75 10             	push   0x10(%ebp)
801012ce:	ff 75 0c             	push   0xc(%ebp)
801012d1:	50                   	push   %eax
801012d2:	e8 93 24 00 00       	call   8010376a <pipewrite>
801012d7:	83 c4 10             	add    $0x10,%esp
801012da:	e9 f4 00 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_INODE){
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 00                	mov    (%eax),%eax
801012e4:	83 f8 02             	cmp    $0x2,%eax
801012e7:	0f 85 d9 00 00 00    	jne    801013c6 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012ed:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012fb:	e9 a3 00 00 00       	jmp    801013a3 <filewrite+0x107>
      int n1 = n - i;
80101300:	8b 45 10             	mov    0x10(%ebp),%eax
80101303:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101306:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010130c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010130f:	7e 06                	jle    80101317 <filewrite+0x7b>
        n1 = max;
80101311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101314:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101317:	e8 22 1d 00 00       	call   8010303e <begin_op>
      ilock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 c7 06 00 00       	call   801019f2 <ilock>
8010132b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010132e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	01 c3                	add    %eax,%ebx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 40 10             	mov    0x10(%eax),%eax
80101345:	51                   	push   %ecx
80101346:	52                   	push   %edx
80101347:	53                   	push   %ebx
80101348:	50                   	push   %eax
80101349:	e8 e5 0c 00 00       	call   80102033 <writei>
8010134e:	83 c4 10             	add    $0x10,%esp
80101351:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101354:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101358:	7e 11                	jle    8010136b <filewrite+0xcf>
        f->off += r;
8010135a:	8b 45 08             	mov    0x8(%ebp),%eax
8010135d:	8b 50 14             	mov    0x14(%eax),%edx
80101360:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101363:	01 c2                	add    %eax,%edx
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	8b 40 10             	mov    0x10(%eax),%eax
80101371:	83 ec 0c             	sub    $0xc,%esp
80101374:	50                   	push   %eax
80101375:	e8 8b 07 00 00       	call   80101b05 <iunlock>
8010137a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010137d:	e8 48 1d 00 00       	call   801030ca <end_op>

      if(r < 0)
80101382:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101386:	78 29                	js     801013b1 <filewrite+0x115>
        break;
      if(r != n1)
80101388:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010138e:	74 0d                	je     8010139d <filewrite+0x101>
        panic("short filewrite");
80101390:	83 ec 0c             	sub    $0xc,%esp
80101393:	68 83 a5 10 80       	push   $0x8010a583
80101398:	e8 0c f2 ff ff       	call   801005a9 <panic>
      i += r;
8010139d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a0:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a9:	0f 8c 51 ff ff ff    	jl     80101300 <filewrite+0x64>
801013af:	eb 01                	jmp    801013b2 <filewrite+0x116>
        break;
801013b1:	90                   	nop
    }
    return i == n ? n : -1;
801013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013b8:	75 05                	jne    801013bf <filewrite+0x123>
801013ba:	8b 45 10             	mov    0x10(%ebp),%eax
801013bd:	eb 14                	jmp    801013d3 <filewrite+0x137>
801013bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c4:	eb 0d                	jmp    801013d3 <filewrite+0x137>
  }
  panic("filewrite");
801013c6:	83 ec 0c             	sub    $0xc,%esp
801013c9:	68 93 a5 10 80       	push   $0x8010a593
801013ce:	e8 d6 f1 ff ff       	call   801005a9 <panic>
}
801013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013d6:	c9                   	leave
801013d7:	c3                   	ret

801013d8 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013d8:	55                   	push   %ebp
801013d9:	89 e5                	mov    %esp,%ebp
801013db:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	83 ec 08             	sub    $0x8,%esp
801013e4:	6a 01                	push   $0x1
801013e6:	50                   	push   %eax
801013e7:	e8 15 ee ff ff       	call   80100201 <bread>
801013ec:	83 c4 10             	add    $0x10,%esp
801013ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f5:	83 c0 5c             	add    $0x5c,%eax
801013f8:	83 ec 04             	sub    $0x4,%esp
801013fb:	6a 1c                	push   $0x1c
801013fd:	50                   	push   %eax
801013fe:	ff 75 0c             	push   0xc(%ebp)
80101401:	e8 b8 3a 00 00       	call   80104ebe <memmove>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	push   -0xc(%ebp)
8010140f:	e8 6f ee ff ff       	call   80100283 <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave
80101419:	c3                   	ret

8010141a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101420:	8b 55 0c             	mov    0xc(%ebp),%edx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	83 ec 08             	sub    $0x8,%esp
80101429:	52                   	push   %edx
8010142a:	50                   	push   %eax
8010142b:	e8 d1 ed ff ff       	call   80100201 <bread>
80101430:	83 c4 10             	add    $0x10,%esp
80101433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101439:	83 c0 5c             	add    $0x5c,%eax
8010143c:	83 ec 04             	sub    $0x4,%esp
8010143f:	68 00 02 00 00       	push   $0x200
80101444:	6a 00                	push   $0x0
80101446:	50                   	push   %eax
80101447:	e8 b3 39 00 00       	call   80104dff <memset>
8010144c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	push   -0xc(%ebp)
80101455:	e8 1d 1e 00 00       	call   80103277 <log_write>
8010145a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010145d:	83 ec 0c             	sub    $0xc,%esp
80101460:	ff 75 f4             	push   -0xc(%ebp)
80101463:	e8 1b ee ff ff       	call   80100283 <brelse>
80101468:	83 c4 10             	add    $0x10,%esp
}
8010146b:	90                   	nop
8010146c:	c9                   	leave
8010146d:	c3                   	ret

8010146e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010146e:	55                   	push   %ebp
8010146f:	89 e5                	mov    %esp,%ebp
80101471:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101482:	e9 0b 01 00 00       	jmp    80101592 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101490:	85 c0                	test   %eax,%eax
80101492:	0f 48 c2             	cmovs  %edx,%eax
80101495:	c1 f8 0c             	sar    $0xc,%eax
80101498:	89 c2                	mov    %eax,%edx
8010149a:	a1 58 24 19 80       	mov    0x80192458,%eax
8010149f:	01 d0                	add    %edx,%eax
801014a1:	83 ec 08             	sub    $0x8,%esp
801014a4:	50                   	push   %eax
801014a5:	ff 75 08             	push   0x8(%ebp)
801014a8:	e8 54 ed ff ff       	call   80100201 <bread>
801014ad:	83 c4 10             	add    $0x10,%esp
801014b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014ba:	e9 9e 00 00 00       	jmp    8010155d <balloc+0xef>
      m = 1 << (bi % 8);
801014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c2:	83 e0 07             	and    $0x7,%eax
801014c5:	ba 01 00 00 00       	mov    $0x1,%edx
801014ca:	89 c1                	mov    %eax,%ecx
801014cc:	d3 e2                	shl    %cl,%edx
801014ce:	89 d0                	mov    %edx,%eax
801014d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	89 c2                	mov    %eax,%edx
801014e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014eb:	0f b6 c0             	movzbl %al,%eax
801014ee:	23 45 e8             	and    -0x18(%ebp),%eax
801014f1:	85 c0                	test   %eax,%eax
801014f3:	75 64                	jne    80101559 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f8:	8d 50 07             	lea    0x7(%eax),%edx
801014fb:	85 c0                	test   %eax,%eax
801014fd:	0f 48 c2             	cmovs  %edx,%eax
80101500:	c1 f8 03             	sar    $0x3,%eax
80101503:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101506:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150b:	89 d1                	mov    %edx,%ecx
8010150d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101510:	09 ca                	or     %ecx,%edx
80101512:	89 d1                	mov    %edx,%ecx
80101514:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101517:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151b:	83 ec 0c             	sub    $0xc,%esp
8010151e:	ff 75 ec             	push   -0x14(%ebp)
80101521:	e8 51 1d 00 00       	call   80103277 <log_write>
80101526:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101529:	83 ec 0c             	sub    $0xc,%esp
8010152c:	ff 75 ec             	push   -0x14(%ebp)
8010152f:	e8 4f ed ff ff       	call   80100283 <brelse>
80101534:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	01 c2                	add    %eax,%edx
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	52                   	push   %edx
80101546:	50                   	push   %eax
80101547:	e8 ce fe ff ff       	call   8010141a <bzero>
8010154c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	eb 56                	jmp    801015af <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101559:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010155d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101564:	7f 17                	jg     8010157d <balloc+0x10f>
80101566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	01 d0                	add    %edx,%eax
8010156e:	89 c2                	mov    %eax,%edx
80101570:	a1 40 24 19 80       	mov    0x80192440,%eax
80101575:	39 c2                	cmp    %eax,%edx
80101577:	0f 82 42 ff ff ff    	jb     801014bf <balloc+0x51>
      }
    }
    brelse(bp);
8010157d:	83 ec 0c             	sub    $0xc,%esp
80101580:	ff 75 ec             	push   -0x14(%ebp)
80101583:	e8 fb ec ff ff       	call   80100283 <brelse>
80101588:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010158b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101592:	a1 40 24 19 80       	mov    0x80192440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 a0 a5 10 80       	push   $0x8010a5a0
801015aa:	e8 fa ef ff ff       	call   801005a9 <panic>
}
801015af:	c9                   	leave
801015b0:	c3                   	ret

801015b1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b1:	55                   	push   %ebp
801015b2:	89 e5                	mov    %esp,%ebp
801015b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015b7:	83 ec 08             	sub    $0x8,%esp
801015ba:	68 40 24 19 80       	push   $0x80192440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 24 19 80       	mov    0x80192458,%eax
801015d7:	01 c2                	add    %eax,%edx
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	83 ec 08             	sub    $0x8,%esp
801015df:	52                   	push   %edx
801015e0:	50                   	push   %eax
801015e1:	e8 1b ec ff ff       	call   80100201 <bread>
801015e6:	83 c4 10             	add    $0x10,%esp
801015e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ef:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	83 e0 07             	and    $0x7,%eax
801015fd:	ba 01 00 00 00       	mov    $0x1,%edx
80101602:	89 c1                	mov    %eax,%ecx
80101604:	d3 e2                	shl    %cl,%edx
80101606:	89 d0                	mov    %edx,%eax
80101608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	89 c2                	mov    %eax,%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101623:	0f b6 c0             	movzbl %al,%eax
80101626:	23 45 ec             	and    -0x14(%ebp),%eax
80101629:	85 c0                	test   %eax,%eax
8010162b:	75 0d                	jne    8010163a <bfree+0x89>
    panic("freeing free block");
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	68 b6 a5 10 80       	push   $0x8010a5b6
80101635:	e8 6f ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
8010163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163d:	8d 50 07             	lea    0x7(%eax),%edx
80101640:	85 c0                	test   %eax,%eax
80101642:	0f 48 c2             	cmovs  %edx,%eax
80101645:	c1 f8 03             	sar    $0x3,%eax
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101655:	f7 d2                	not    %edx
80101657:	21 ca                	and    %ecx,%edx
80101659:	89 d1                	mov    %edx,%ecx
8010165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	ff 75 f4             	push   -0xc(%ebp)
80101668:	e8 0a 1c 00 00       	call   80103277 <log_write>
8010166d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101670:	83 ec 0c             	sub    $0xc,%esp
80101673:	ff 75 f4             	push   -0xc(%ebp)
80101676:	e8 08 ec ff ff       	call   80100283 <brelse>
8010167b:	83 c4 10             	add    $0x10,%esp
}
8010167e:	90                   	nop
8010167f:	c9                   	leave
80101680:	c3                   	ret

80101681 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101681:	55                   	push   %ebp
80101682:	89 e5                	mov    %esp,%ebp
80101684:	57                   	push   %edi
80101685:	56                   	push   %esi
80101686:	53                   	push   %ebx
80101687:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010168a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101691:	83 ec 08             	sub    $0x8,%esp
80101694:	68 c9 a5 10 80       	push   $0x8010a5c9
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 c4 34 00 00       	call   80104b67 <initlock>
801016a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016ad:	eb 2d                	jmp    801016dc <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016b2:	89 d0                	mov    %edx,%eax
801016b4:	c1 e0 03             	shl    $0x3,%eax
801016b7:	01 d0                	add    %edx,%eax
801016b9:	c1 e0 04             	shl    $0x4,%eax
801016bc:	83 c0 30             	add    $0x30,%eax
801016bf:	05 60 24 19 80       	add    $0x80192460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 d0 a5 10 80       	push   $0x8010a5d0
801016cf:	50                   	push   %eax
801016d0:	e8 35 33 00 00       	call   80104a0a <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 24 19 80       	push   $0x80192440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 24 19 80       	mov    0x80192458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
80101703:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101709:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
8010170f:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101715:	8b 15 44 24 19 80    	mov    0x80192444,%edx
8010171b:	a1 40 24 19 80       	mov    0x80192440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 d8 a5 10 80       	push   $0x8010a5d8
8010172e:	e8 c1 ec ff ff       	call   801003f4 <cprintf>
80101733:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101736:	90                   	nop
80101737:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010173a:	5b                   	pop    %ebx
8010173b:	5e                   	pop    %esi
8010173c:	5f                   	pop    %edi
8010173d:	5d                   	pop    %ebp
8010173e:	c3                   	ret

8010173f <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010173f:	55                   	push   %ebp
80101740:	89 e5                	mov    %esp,%ebp
80101742:	83 ec 28             	sub    $0x28,%esp
80101745:	8b 45 0c             	mov    0xc(%ebp),%eax
80101748:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010174c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101753:	e9 9e 00 00 00       	jmp    801017f6 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	c1 e8 03             	shr    $0x3,%eax
8010175e:	89 c2                	mov    %eax,%edx
80101760:	a1 54 24 19 80       	mov    0x80192454,%eax
80101765:	01 d0                	add    %edx,%eax
80101767:	83 ec 08             	sub    $0x8,%esp
8010176a:	50                   	push   %eax
8010176b:	ff 75 08             	push   0x8(%ebp)
8010176e:	e8 8e ea ff ff       	call   80100201 <bread>
80101773:	83 c4 10             	add    $0x10,%esp
80101776:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	83 e0 07             	and    $0x7,%eax
80101785:	c1 e0 06             	shl    $0x6,%eax
80101788:	01 d0                	add    %edx,%eax
8010178a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010178d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101790:	0f b7 00             	movzwl (%eax),%eax
80101793:	66 85 c0             	test   %ax,%ax
80101796:	75 4c                	jne    801017e4 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101798:	83 ec 04             	sub    $0x4,%esp
8010179b:	6a 40                	push   $0x40
8010179d:	6a 00                	push   $0x0
8010179f:	ff 75 ec             	push   -0x14(%ebp)
801017a2:	e8 58 36 00 00       	call   80104dff <memset>
801017a7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ad:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 b8 1a 00 00       	call   80103277 <log_write>
801017bf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f0             	push   -0x10(%ebp)
801017c8:	e8 b6 ea ff ff       	call   80100283 <brelse>
801017cd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	50                   	push   %eax
801017d7:	ff 75 08             	push   0x8(%ebp)
801017da:	e8 f7 00 00 00       	call   801018d6 <iget>
801017df:	83 c4 10             	add    $0x10,%esp
801017e2:	eb 2f                	jmp    80101813 <ialloc+0xd4>
    }
    brelse(bp);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	ff 75 f0             	push   -0x10(%ebp)
801017ea:	e8 94 ea ff ff       	call   80100283 <brelse>
801017ef:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017f6:	a1 48 24 19 80       	mov    0x80192448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 2b a6 10 80       	push   $0x8010a62b
8010180e:	e8 96 ed ff ff       	call   801005a9 <panic>
}
80101813:	c9                   	leave
80101814:	c3                   	ret

80101815 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8b 40 04             	mov    0x4(%eax),%eax
80101821:	c1 e8 03             	shr    $0x3,%eax
80101824:	89 c2                	mov    %eax,%edx
80101826:	a1 54 24 19 80       	mov    0x80192454,%eax
8010182b:	01 c2                	add    %eax,%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 00                	mov    (%eax),%eax
80101832:	83 ec 08             	sub    $0x8,%esp
80101835:	52                   	push   %edx
80101836:	50                   	push   %eax
80101837:	e8 c5 e9 ff ff       	call   80100201 <bread>
8010183c:	83 c4 10             	add    $0x10,%esp
8010183f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	8d 50 5c             	lea    0x5c(%eax),%edx
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 04             	mov    0x4(%eax),%eax
8010184e:	83 e0 07             	and    $0x7,%eax
80101851:	c1 e0 06             	shl    $0x6,%eax
80101854:	01 d0                	add    %edx,%eax
80101856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101866:	8b 45 08             	mov    0x8(%ebp),%eax
80101869:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 50 58             	mov    0x58(%eax),%edx
80101896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101899:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a5:	83 c0 0c             	add    $0xc,%eax
801018a8:	83 ec 04             	sub    $0x4,%esp
801018ab:	6a 34                	push   $0x34
801018ad:	52                   	push   %edx
801018ae:	50                   	push   %eax
801018af:	e8 0a 36 00 00       	call   80104ebe <memmove>
801018b4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f4             	push   -0xc(%ebp)
801018bd:	e8 b5 19 00 00       	call   80103277 <log_write>
801018c2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018c5:	83 ec 0c             	sub    $0xc,%esp
801018c8:	ff 75 f4             	push   -0xc(%ebp)
801018cb:	e8 b3 e9 ff ff       	call   80100283 <brelse>
801018d0:	83 c4 10             	add    $0x10,%esp
}
801018d3:	90                   	nop
801018d4:	c9                   	leave
801018d5:	c3                   	ret

801018d6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018d6:	55                   	push   %ebp
801018d7:	89 e5                	mov    %esp,%ebp
801018d9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	68 60 24 19 80       	push   $0x80192460
801018e4:	e8 a0 32 00 00       	call   80104b89 <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018fa:	eb 60                	jmp    8010195c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	8b 40 08             	mov    0x8(%eax),%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	7e 39                	jle    8010193f <iget+0x69>
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8b 00                	mov    (%eax),%eax
8010190b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010190e:	75 2f                	jne    8010193f <iget+0x69>
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101913:	8b 40 04             	mov    0x4(%eax),%eax
80101916:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101919:	75 24                	jne    8010193f <iget+0x69>
      ip->ref++;
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 40 08             	mov    0x8(%eax),%eax
80101921:	8d 50 01             	lea    0x1(%eax),%edx
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	68 60 24 19 80       	push   $0x80192460
80101932:	e8 c0 32 00 00       	call   80104bf7 <release>
80101937:	83 c4 10             	add    $0x10,%esp
      return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193d:	eb 77                	jmp    801019b6 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010193f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101943:	75 10                	jne    80101955 <iget+0x7f>
80101945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101948:	8b 40 08             	mov    0x8(%eax),%eax
8010194b:	85 c0                	test   %eax,%eax
8010194d:	75 06                	jne    80101955 <iget+0x7f>
      empty = ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101955:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010195c:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 3d a6 10 80       	push   $0x8010a63d
80101973:	e8 31 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 08             	mov    0x8(%ebp),%edx
80101984:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010198c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019a3:	83 ec 0c             	sub    $0xc,%esp
801019a6:	68 60 24 19 80       	push   $0x80192460
801019ab:	e8 47 32 00 00       	call   80104bf7 <release>
801019b0:	83 c4 10             	add    $0x10,%esp

  return ip;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019b6:	c9                   	leave
801019b7:	c3                   	ret

801019b8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b8:	55                   	push   %ebp
801019b9:	89 e5                	mov    %esp,%ebp
801019bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019be:	83 ec 0c             	sub    $0xc,%esp
801019c1:	68 60 24 19 80       	push   $0x80192460
801019c6:	e8 be 31 00 00       	call   80104b89 <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 24 19 80       	push   $0x80192460
801019e5:	e8 0d 32 00 00       	call   80104bf7 <release>
801019ea:	83 c4 10             	add    $0x10,%esp
  return ip;
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019f0:	c9                   	leave
801019f1:	c3                   	ret

801019f2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019f2:	55                   	push   %ebp
801019f3:	89 e5                	mov    %esp,%ebp
801019f5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019fc:	74 0a                	je     80101a08 <ilock+0x16>
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	8b 40 08             	mov    0x8(%eax),%eax
80101a04:	85 c0                	test   %eax,%eax
80101a06:	7f 0d                	jg     80101a15 <ilock+0x23>
    panic("ilock");
80101a08:	83 ec 0c             	sub    $0xc,%esp
80101a0b:	68 4d a6 10 80       	push   $0x8010a64d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 22 30 00 00       	call   80104a46 <acquiresleep>
80101a24:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a2d:	85 c0                	test   %eax,%eax
80101a2f:	0f 85 cd 00 00 00    	jne    80101b02 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 40 04             	mov    0x4(%eax),%eax
80101a3b:	c1 e8 03             	shr    $0x3,%eax
80101a3e:	89 c2                	mov    %eax,%edx
80101a40:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a45:	01 c2                	add    %eax,%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	8b 00                	mov    (%eax),%eax
80101a4c:	83 ec 08             	sub    $0x8,%esp
80101a4f:	52                   	push   %edx
80101a50:	50                   	push   %eax
80101a51:	e8 ab e7 ff ff       	call   80100201 <bread>
80101a56:	83 c4 10             	add    $0x10,%esp
80101a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	8b 40 04             	mov    0x4(%eax),%eax
80101a68:	83 e0 07             	and    $0x7,%eax
80101a6b:	c1 e0 06             	shl    $0x6,%eax
80101a6e:	01 d0                	add    %edx,%eax
80101a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 10             	movzwl (%eax),%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a83:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aad:	8b 50 08             	mov    0x8(%eax),%edx
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	8d 50 0c             	lea    0xc(%eax),%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	83 c0 5c             	add    $0x5c,%eax
80101ac2:	83 ec 04             	sub    $0x4,%esp
80101ac5:	6a 34                	push   $0x34
80101ac7:	52                   	push   %edx
80101ac8:	50                   	push   %eax
80101ac9:	e8 f0 33 00 00       	call   80104ebe <memmove>
80101ace:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ad1:	83 ec 0c             	sub    $0xc,%esp
80101ad4:	ff 75 f4             	push   -0xc(%ebp)
80101ad7:	e8 a7 e7 ff ff       	call   80100283 <brelse>
80101adc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101af0:	66 85 c0             	test   %ax,%ax
80101af3:	75 0d                	jne    80101b02 <ilock+0x110>
      panic("ilock: no type");
80101af5:	83 ec 0c             	sub    $0xc,%esp
80101af8:	68 53 a6 10 80       	push   $0x8010a653
80101afd:	e8 a7 ea ff ff       	call   801005a9 <panic>
  }
}
80101b02:	90                   	nop
80101b03:	c9                   	leave
80101b04:	c3                   	ret

80101b05 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b05:	55                   	push   %ebp
80101b06:	89 e5                	mov    %esp,%ebp
80101b08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b0f:	74 20                	je     80101b31 <iunlock+0x2c>
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	83 c0 0c             	add    $0xc,%eax
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	50                   	push   %eax
80101b1b:	e8 d8 2f 00 00       	call   80104af8 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 62 a6 10 80       	push   $0x8010a662
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 5d 2f 00 00       	call   80104aaa <releasesleep>
80101b4d:	83 c4 10             	add    $0x10,%esp
}
80101b50:	90                   	nop
80101b51:	c9                   	leave
80101b52:	c3                   	ret

80101b53 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b53:	55                   	push   %ebp
80101b54:	89 e5                	mov    %esp,%ebp
80101b56:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	83 c0 0c             	add    $0xc,%eax
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	50                   	push   %eax
80101b63:	e8 de 2e 00 00       	call   80104a46 <acquiresleep>
80101b68:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 6a                	je     80101bdf <iput+0x8c>
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b7c:	66 85 c0             	test   %ax,%ax
80101b7f:	75 5e                	jne    80101bdf <iput+0x8c>
    acquire(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 60 24 19 80       	push   $0x80192460
80101b89:	e8 fb 2f 00 00       	call   80104b89 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 50 30 00 00       	call   80104bf7 <release>
80101ba7:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101baa:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bae:	75 2f                	jne    80101bdf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 08             	push   0x8(%ebp)
80101bb6:	e8 ad 01 00 00       	call   80101d68 <itrunc>
80101bbb:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc7:	83 ec 0c             	sub    $0xc,%esp
80101bca:	ff 75 08             	push   0x8(%ebp)
80101bcd:	e8 43 fc ff ff       	call   80101815 <iupdate>
80101bd2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101be2:	83 c0 0c             	add    $0xc,%eax
80101be5:	83 ec 0c             	sub    $0xc,%esp
80101be8:	50                   	push   %eax
80101be9:	e8 bc 2e 00 00       	call   80104aaa <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 8b 2f 00 00       	call   80104b89 <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 24 19 80       	push   $0x80192460
80101c18:	e8 da 2f 00 00       	call   80104bf7 <release>
80101c1d:	83 c4 10             	add    $0x10,%esp
}
80101c20:	90                   	nop
80101c21:	c9                   	leave
80101c22:	c3                   	ret

80101c23 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c23:	55                   	push   %ebp
80101c24:	89 e5                	mov    %esp,%ebp
80101c26:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c29:	83 ec 0c             	sub    $0xc,%esp
80101c2c:	ff 75 08             	push   0x8(%ebp)
80101c2f:	e8 d1 fe ff ff       	call   80101b05 <iunlock>
80101c34:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	ff 75 08             	push   0x8(%ebp)
80101c3d:	e8 11 ff ff ff       	call   80101b53 <iput>
80101c42:	83 c4 10             	add    $0x10,%esp
}
80101c45:	90                   	nop
80101c46:	c9                   	leave
80101c47:	c3                   	ret

80101c48 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c48:	55                   	push   %ebp
80101c49:	89 e5                	mov    %esp,%ebp
80101c4b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c4e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c52:	77 42                	ja     80101c96 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c5a:	83 c2 14             	add    $0x14,%edx
80101c5d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c68:	75 24                	jne    80101c8e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 00                	mov    (%eax),%eax
80101c6f:	83 ec 0c             	sub    $0xc,%esp
80101c72:	50                   	push   %eax
80101c73:	e8 f6 f7 ff ff       	call   8010146e <balloc>
80101c78:	83 c4 10             	add    $0x10,%esp
80101c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c84:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c8a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c91:	e9 d0 00 00 00       	jmp    80101d66 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c96:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c9a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c9e:	0f 87 b5 00 00 00    	ja     80101d59 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb4:	75 20                	jne    80101cd6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	50                   	push   %eax
80101cbf:	e8 aa f7 ff ff       	call   8010146e <balloc>
80101cc4:	83 c4 10             	add    $0x10,%esp
80101cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 00                	mov    (%eax),%eax
80101cdb:	83 ec 08             	sub    $0x8,%esp
80101cde:	ff 75 f4             	push   -0xc(%ebp)
80101ce1:	50                   	push   %eax
80101ce2:	e8 1a e5 ff ff       	call   80100201 <bread>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf0:	83 c0 5c             	add    $0x5c,%eax
80101cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d03:	01 d0                	add    %edx,%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 36                	jne    80101d46 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	50                   	push   %eax
80101d19:	e8 50 f7 ff ff       	call   8010146e <balloc>
80101d1e:	83 c4 10             	add    $0x10,%esp
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	01 c2                	add    %eax,%edx
80101d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d36:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d38:	83 ec 0c             	sub    $0xc,%esp
80101d3b:	ff 75 f0             	push   -0x10(%ebp)
80101d3e:	e8 34 15 00 00       	call   80103277 <log_write>
80101d43:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 f0             	push   -0x10(%ebp)
80101d4c:	e8 32 e5 ff ff       	call   80100283 <brelse>
80101d51:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d57:	eb 0d                	jmp    80101d66 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	68 6a a6 10 80       	push   $0x8010a66a
80101d61:	e8 43 e8 ff ff       	call   801005a9 <panic>
}
80101d66:	c9                   	leave
80101d67:	c3                   	ret

80101d68 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d75:	eb 45                	jmp    80101dbc <itrunc+0x54>
    if(ip->addrs[i]){
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7d:	83 c2 14             	add    $0x14,%edx
80101d80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d84:	85 c0                	test   %eax,%eax
80101d86:	74 30                	je     80101db8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8e:	83 c2 14             	add    $0x14,%edx
80101d91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d95:	8b 55 08             	mov    0x8(%ebp),%edx
80101d98:	8b 12                	mov    (%edx),%edx
80101d9a:	83 ec 08             	sub    $0x8,%esp
80101d9d:	50                   	push   %eax
80101d9e:	52                   	push   %edx
80101d9f:	e8 0d f8 ff ff       	call   801015b1 <bfree>
80101da4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da7:	8b 45 08             	mov    0x8(%ebp),%eax
80101daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dad:	83 c2 14             	add    $0x14,%edx
80101db0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db7:	00 
  for(i = 0; i < NDIRECT; i++){
80101db8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dbc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc0:	7e b5                	jle    80101d77 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dcb:	85 c0                	test   %eax,%eax
80101dcd:	0f 84 aa 00 00 00    	je     80101e7d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 16 e4 ff ff       	call   80100201 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 5c             	add    $0x5c,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd7>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 79 f7 ff ff       	call   801015b1 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x9b>
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	push   -0x14(%ebp)
80101e4d:	e8 31 e4 ff ff       	call   80100283 <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e61:	8b 12                	mov    (%edx),%edx
80101e63:	83 ec 08             	sub    $0x8,%esp
80101e66:	50                   	push   %eax
80101e67:	52                   	push   %edx
80101e68:	e8 44 f7 ff ff       	call   801015b1 <bfree>
80101e6d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e7a:	00 00 00 
  }

  ip->size = 0;
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	ff 75 08             	push   0x8(%ebp)
80101e8d:	e8 83 f9 ff ff       	call   80101815 <iupdate>
80101e92:	83 c4 10             	add    $0x10,%esp
}
80101e95:	90                   	nop
80101e96:	c9                   	leave
80101e97:	c3                   	ret

80101e98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e98:	55                   	push   %ebp
80101e99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	89 c2                	mov    %eax,%edx
80101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 50 04             	mov    0x4(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 58             	mov    0x58(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	90                   	nop
80101edc:	5d                   	pop    %ebp
80101edd:	c3                   	ret

80101ede <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ede:	55                   	push   %ebp
80101edf:	89 e5                	mov    %esp,%ebp
80101ee1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101eeb:	66 83 f8 03          	cmp    $0x3,%ax
80101eef:	75 5c                	jne    80101f4d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef8:	66 85 c0             	test   %ax,%ax
80101efb:	78 20                	js     80101f1d <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f04:	66 83 f8 09          	cmp    $0x9,%ax
80101f08:	7f 13                	jg     80101f1d <readi+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f11:	98                   	cwtl
80101f12:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f36:	8b 55 14             	mov    0x14(%ebp),%edx
80101f39:	83 ec 04             	sub    $0x4,%esp
80101f3c:	52                   	push   %edx
80101f3d:	ff 75 0c             	push   0xc(%ebp)
80101f40:	ff 75 08             	push   0x8(%ebp)
80101f43:	ff d0                	call   *%eax
80101f45:	83 c4 10             	add    $0x10,%esp
80101f48:	e9 e4 00 00 00       	jmp    80102031 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 40 58             	mov    0x58(%eax),%eax
80101f53:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f56:	72 0d                	jb     80101f65 <readi+0x87>
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 d0                	add    %edx,%eax
80101f60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f63:	73 0a                	jae    80101f6f <readi+0x91>
    return -1;
80101f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6a:	e9 c2 00 00 00       	jmp    80102031 <readi+0x153>
  if(off + n > ip->size)
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	8b 45 14             	mov    0x14(%ebp),%eax
80101f75:	01 c2                	add    %eax,%edx
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 40 58             	mov    0x58(%eax),%eax
80101f7d:	39 d0                	cmp    %edx,%eax
80101f7f:	73 0c                	jae    80101f8d <readi+0xaf>
    n = ip->size - off;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 40 58             	mov    0x58(%eax),%eax
80101f87:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f94:	e9 89 00 00 00       	jmp    80102022 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	c1 e8 09             	shr    $0x9,%eax
80101f9f:	83 ec 08             	sub    $0x8,%esp
80101fa2:	50                   	push   %eax
80101fa3:	ff 75 08             	push   0x8(%ebp)
80101fa6:	e8 9d fc ff ff       	call   80101c48 <bmap>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb1:	8b 12                	mov    (%edx),%edx
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	52                   	push   %edx
80101fb8:	e8 44 e2 ff ff       	call   80100201 <bread>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcb:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd0:	29 c2                	sub    %eax,%edx
80101fd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd8:	39 c2                	cmp    %eax,%edx
80101fda:	0f 46 c2             	cmovbe %edx,%eax
80101fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fee:	01 d0                	add    %edx,%eax
80101ff0:	83 ec 04             	sub    $0x4,%esp
80101ff3:	ff 75 ec             	push   -0x14(%ebp)
80101ff6:	50                   	push   %eax
80101ff7:	ff 75 0c             	push   0xc(%ebp)
80101ffa:	e8 bf 2e 00 00       	call   80104ebe <memmove>
80101fff:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	ff 75 f0             	push   -0x10(%ebp)
80102008:	e8 76 e2 ff ff       	call   80100283 <brelse>
8010200d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 f4             	add    %eax,-0xc(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 10             	add    %eax,0x10(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 0c             	add    %eax,0xc(%ebp)
80102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102025:	3b 45 14             	cmp    0x14(%ebp),%eax
80102028:	0f 82 6b ff ff ff    	jb     80101f99 <readi+0xbb>
  }
  return n;
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102031:	c9                   	leave
80102032:	c3                   	ret

80102033 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102040:	66 83 f8 03          	cmp    $0x3,%ax
80102044:	75 5c                	jne    801020a2 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204d:	66 85 c0             	test   %ax,%ax
80102050:	78 20                	js     80102072 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102059:	66 83 f8 09          	cmp    $0x9,%ax
8010205d:	7f 13                	jg     80102072 <writei+0x3f>
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102066:	98                   	cwtl
80102067:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010208b:	8b 55 14             	mov    0x14(%ebp),%edx
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	52                   	push   %edx
80102092:	ff 75 0c             	push   0xc(%ebp)
80102095:	ff 75 08             	push   0x8(%ebp)
80102098:	ff d0                	call   *%eax
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	e9 15 01 00 00       	jmp    801021b7 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	8b 40 58             	mov    0x58(%eax),%eax
801020a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ab:	72 0d                	jb     801020ba <writei+0x87>
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b8:	73 0a                	jae    801020c4 <writei+0x91>
    return -1;
801020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bf:	e9 f3 00 00 00       	jmp    801021b7 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	01 d0                	add    %edx,%eax
801020cc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d1:	76 0a                	jbe    801020dd <writei+0xaa>
    return -1;
801020d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d8:	e9 da 00 00 00       	jmp    801021b7 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 97 00 00 00       	jmp    80102180 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	push   0x8(%ebp)
801020f6:	e8 4d fb ff ff       	call   80101c48 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	8b 12                	mov    (%edx),%edx
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	52                   	push   %edx
80102108:	e8 f4 e0 ff ff       	call   80100201 <bread>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102113:	8b 45 10             	mov    0x10(%ebp),%eax
80102116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211b:	ba 00 02 00 00       	mov    $0x200,%edx
80102120:	29 c2                	sub    %eax,%edx
80102122:	8b 45 14             	mov    0x14(%ebp),%eax
80102125:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102128:	39 c2                	cmp    %eax,%edx
8010212a:	0f 46 c2             	cmovbe %edx,%eax
8010212d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102133:	8d 50 5c             	lea    0x5c(%eax),%edx
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	01 d0                	add    %edx,%eax
80102140:	83 ec 04             	sub    $0x4,%esp
80102143:	ff 75 ec             	push   -0x14(%ebp)
80102146:	ff 75 0c             	push   0xc(%ebp)
80102149:	50                   	push   %eax
8010214a:	e8 6f 2d 00 00       	call   80104ebe <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	push   -0x10(%ebp)
80102158:	e8 1a 11 00 00       	call   80103277 <log_write>
8010215d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102160:	83 ec 0c             	sub    $0xc,%esp
80102163:	ff 75 f0             	push   -0x10(%ebp)
80102166:	e8 18 e1 ff ff       	call   80100283 <brelse>
8010216b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102171:	01 45 f4             	add    %eax,-0xc(%ebp)
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 10             	add    %eax,0x10(%ebp)
8010217a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217d:	01 45 0c             	add    %eax,0xc(%ebp)
80102180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102183:	3b 45 14             	cmp    0x14(%ebp),%eax
80102186:	0f 82 5d ff ff ff    	jb     801020e9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010218c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102190:	74 22                	je     801021b4 <writei+0x181>
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	8b 40 58             	mov    0x58(%eax),%eax
80102198:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219b:	73 17                	jae    801021b4 <writei+0x181>
    ip->size = off;
8010219d:	8b 45 08             	mov    0x8(%ebp),%eax
801021a0:	8b 55 10             	mov    0x10(%ebp),%edx
801021a3:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	ff 75 08             	push   0x8(%ebp)
801021ac:	e8 64 f6 ff ff       	call   80101815 <iupdate>
801021b1:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b7:	c9                   	leave
801021b8:	c3                   	ret

801021b9 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b9:	55                   	push   %ebp
801021ba:	89 e5                	mov    %esp,%ebp
801021bc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bf:	83 ec 04             	sub    $0x4,%esp
801021c2:	6a 0e                	push   $0xe
801021c4:	ff 75 0c             	push   0xc(%ebp)
801021c7:	ff 75 08             	push   0x8(%ebp)
801021ca:	e8 85 2d 00 00       	call   80104f54 <strncmp>
801021cf:	83 c4 10             	add    $0x10,%esp
}
801021d2:	c9                   	leave
801021d3:	c3                   	ret

801021d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d4:	55                   	push   %ebp
801021d5:	89 e5                	mov    %esp,%ebp
801021d7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e1:	66 83 f8 01          	cmp    $0x1,%ax
801021e5:	74 0d                	je     801021f4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e7:	83 ec 0c             	sub    $0xc,%esp
801021ea:	68 7d a6 10 80       	push   $0x8010a67d
801021ef:	e8 b5 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fb:	eb 7b                	jmp    80102278 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fd:	6a 10                	push   $0x10
801021ff:	ff 75 f4             	push   -0xc(%ebp)
80102202:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102205:	50                   	push   %eax
80102206:	ff 75 08             	push   0x8(%ebp)
80102209:	e8 d0 fc ff ff       	call   80101ede <readi>
8010220e:	83 c4 10             	add    $0x10,%esp
80102211:	83 f8 10             	cmp    $0x10,%eax
80102214:	74 0d                	je     80102223 <dirlookup+0x4f>
      panic("dirlookup read");
80102216:	83 ec 0c             	sub    $0xc,%esp
80102219:	68 8f a6 10 80       	push   $0x8010a68f
8010221e:	e8 86 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102223:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102227:	66 85 c0             	test   %ax,%ax
8010222a:	74 47                	je     80102273 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222c:	83 ec 08             	sub    $0x8,%esp
8010222f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102232:	83 c0 02             	add    $0x2,%eax
80102235:	50                   	push   %eax
80102236:	ff 75 0c             	push   0xc(%ebp)
80102239:	e8 7b ff ff ff       	call   801021b9 <namecmp>
8010223e:	83 c4 10             	add    $0x10,%esp
80102241:	85 c0                	test   %eax,%eax
80102243:	75 2f                	jne    80102274 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102249:	74 08                	je     80102253 <dirlookup+0x7f>
        *poff = off;
8010224b:	8b 45 10             	mov    0x10(%ebp),%eax
8010224e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102251:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102253:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102257:	0f b7 c0             	movzwl %ax,%eax
8010225a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 00                	mov    (%eax),%eax
80102262:	83 ec 08             	sub    $0x8,%esp
80102265:	ff 75 f0             	push   -0x10(%ebp)
80102268:	50                   	push   %eax
80102269:	e8 68 f6 ff ff       	call   801018d6 <iget>
8010226e:	83 c4 10             	add    $0x10,%esp
80102271:	eb 19                	jmp    8010228c <dirlookup+0xb8>
      continue;
80102273:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102274:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 40 58             	mov    0x58(%eax),%eax
8010227e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102281:	0f 82 76 ff ff ff    	jb     801021fd <dirlookup+0x29>
    }
  }

  return 0;
80102287:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228c:	c9                   	leave
8010228d:	c3                   	ret

8010228e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102294:	83 ec 04             	sub    $0x4,%esp
80102297:	6a 00                	push   $0x0
80102299:	ff 75 0c             	push   0xc(%ebp)
8010229c:	ff 75 08             	push   0x8(%ebp)
8010229f:	e8 30 ff ff ff       	call   801021d4 <dirlookup>
801022a4:	83 c4 10             	add    $0x10,%esp
801022a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ae:	74 18                	je     801022c8 <dirlink+0x3a>
    iput(ip);
801022b0:	83 ec 0c             	sub    $0xc,%esp
801022b3:	ff 75 f0             	push   -0x10(%ebp)
801022b6:	e8 98 f8 ff ff       	call   80101b53 <iput>
801022bb:	83 c4 10             	add    $0x10,%esp
    return -1;
801022be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c3:	e9 9c 00 00 00       	jmp    80102364 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cf:	eb 39                	jmp    8010230a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d4:	6a 10                	push   $0x10
801022d6:	50                   	push   %eax
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	50                   	push   %eax
801022db:	ff 75 08             	push   0x8(%ebp)
801022de:	e8 fb fb ff ff       	call   80101ede <readi>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	83 f8 10             	cmp    $0x10,%eax
801022e9:	74 0d                	je     801022f8 <dirlink+0x6a>
      panic("dirlink read");
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	68 9e a6 10 80       	push   $0x8010a69e
801022f3:	e8 b1 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fc:	66 85 c0             	test   %ax,%ax
801022ff:	74 18                	je     80102319 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	83 c0 10             	add    $0x10,%eax
80102307:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 58             	mov    0x58(%eax),%eax
80102310:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102313:	39 c2                	cmp    %eax,%edx
80102315:	72 ba                	jb     801022d1 <dirlink+0x43>
80102317:	eb 01                	jmp    8010231a <dirlink+0x8c>
      break;
80102319:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010231a:	83 ec 04             	sub    $0x4,%esp
8010231d:	6a 0e                	push   $0xe
8010231f:	ff 75 0c             	push   0xc(%ebp)
80102322:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102325:	83 c0 02             	add    $0x2,%eax
80102328:	50                   	push   %eax
80102329:	e8 7c 2c 00 00       	call   80104faa <strncpy>
8010232e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	6a 10                	push   $0x10
8010233d:	50                   	push   %eax
8010233e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102341:	50                   	push   %eax
80102342:	ff 75 08             	push   0x8(%ebp)
80102345:	e8 e9 fc ff ff       	call   80102033 <writei>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	83 f8 10             	cmp    $0x10,%eax
80102350:	74 0d                	je     8010235f <dirlink+0xd1>
    panic("dirlink");
80102352:	83 ec 0c             	sub    $0xc,%esp
80102355:	68 ab a6 10 80       	push   $0x8010a6ab
8010235a:	e8 4a e2 ff ff       	call   801005a9 <panic>

  return 0;
8010235f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102364:	c9                   	leave
80102365:	c3                   	ret

80102366 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102366:	55                   	push   %ebp
80102367:	89 e5                	mov    %esp,%ebp
80102369:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236c:	eb 04                	jmp    80102372 <skipelem+0xc>
    path++;
8010236e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b6 00             	movzbl (%eax),%eax
80102378:	3c 2f                	cmp    $0x2f,%al
8010237a:	74 f2                	je     8010236e <skipelem+0x8>
  if(*path == 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	84 c0                	test   %al,%al
80102384:	75 07                	jne    8010238d <skipelem+0x27>
    return 0;
80102386:	b8 00 00 00 00       	mov    $0x0,%eax
8010238b:	eb 77                	jmp    80102404 <skipelem+0x9e>
  s = path;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102393:	eb 04                	jmp    80102399 <skipelem+0x33>
    path++;
80102395:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	3c 2f                	cmp    $0x2f,%al
801023a1:	74 0a                	je     801023ad <skipelem+0x47>
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	0f b6 00             	movzbl (%eax),%eax
801023a9:	84 c0                	test   %al,%al
801023ab:	75 e8                	jne    80102395 <skipelem+0x2f>
  len = path - s;
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ba:	7e 15                	jle    801023d1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 0e                	push   $0xe
801023c1:	ff 75 f4             	push   -0xc(%ebp)
801023c4:	ff 75 0c             	push   0xc(%ebp)
801023c7:	e8 f2 2a 00 00       	call   80104ebe <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 db 2a 00 00       	call   80104ebe <memmove>
801023e3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ec:	01 d0                	add    %edx,%eax
801023ee:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f1:	eb 04                	jmp    801023f7 <skipelem+0x91>
    path++;
801023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	74 f2                	je     801023f3 <skipelem+0x8d>
  return path;
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102404:	c9                   	leave
80102405:	c3                   	ret

80102406 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	3c 2f                	cmp    $0x2f,%al
80102414:	75 17                	jne    8010242d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102416:	83 ec 08             	sub    $0x8,%esp
80102419:	6a 01                	push   $0x1
8010241b:	6a 01                	push   $0x1
8010241d:	e8 b4 f4 ff ff       	call   801018d6 <iget>
80102422:	83 c4 10             	add    $0x10,%esp
80102425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102428:	e9 ba 00 00 00       	jmp    801024e7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010242d:	e8 05 16 00 00       	call   80103a37 <myproc>
80102432:	8b 40 68             	mov    0x68(%eax),%eax
80102435:	83 ec 0c             	sub    $0xc,%esp
80102438:	50                   	push   %eax
80102439:	e8 7a f5 ff ff       	call   801019b8 <idup>
8010243e:	83 c4 10             	add    $0x10,%esp
80102441:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102444:	e9 9e 00 00 00       	jmp    801024e7 <namex+0xe1>
    ilock(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f4             	push   -0xc(%ebp)
8010244f:	e8 9e f5 ff ff       	call   801019f2 <ilock>
80102454:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010245e:	66 83 f8 01          	cmp    $0x1,%ax
80102462:	74 18                	je     8010247c <namex+0x76>
      iunlockput(ip);
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	ff 75 f4             	push   -0xc(%ebp)
8010246a:	e8 b4 f7 ff ff       	call   80101c23 <iunlockput>
8010246f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102472:	b8 00 00 00 00       	mov    $0x0,%eax
80102477:	e9 a7 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010247c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102480:	74 20                	je     801024a2 <namex+0x9c>
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	0f b6 00             	movzbl (%eax),%eax
80102488:	84 c0                	test   %al,%al
8010248a:	75 16                	jne    801024a2 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 6e f6 ff ff       	call   80101b05 <iunlock>
80102497:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249d:	e9 81 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 00                	push   $0x0
801024a7:	ff 75 10             	push   0x10(%ebp)
801024aa:	ff 75 f4             	push   -0xc(%ebp)
801024ad:	e8 22 fd ff ff       	call   801021d4 <dirlookup>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bc:	75 15                	jne    801024d3 <namex+0xcd>
      iunlockput(ip);
801024be:	83 ec 0c             	sub    $0xc,%esp
801024c1:	ff 75 f4             	push   -0xc(%ebp)
801024c4:	e8 5a f7 ff ff       	call   80101c23 <iunlockput>
801024c9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cc:	b8 00 00 00 00       	mov    $0x0,%eax
801024d1:	eb 50                	jmp    80102523 <namex+0x11d>
    }
    iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 45 f7 ff ff       	call   80101c23 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e7:	83 ec 08             	sub    $0x8,%esp
801024ea:	ff 75 10             	push   0x10(%ebp)
801024ed:	ff 75 08             	push   0x8(%ebp)
801024f0:	e8 71 fe ff ff       	call   80102366 <skipelem>
801024f5:	83 c4 10             	add    $0x10,%esp
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 44 ff ff ff    	jne    80102449 <namex+0x43>
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 15                	je     80102520 <namex+0x11a>
    iput(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	push   -0xc(%ebp)
80102511:	e8 3d f6 ff ff       	call   80101b53 <iput>
80102516:	83 c4 10             	add    $0x10,%esp
    return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
8010251e:	eb 03                	jmp    80102523 <namex+0x11d>
  }
  return ip;
80102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102523:	c9                   	leave
80102524:	c3                   	ret

80102525 <namei>:

struct inode*
namei(char *path)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252b:	83 ec 04             	sub    $0x4,%esp
8010252e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102531:	50                   	push   %eax
80102532:	6a 00                	push   $0x0
80102534:	ff 75 08             	push   0x8(%ebp)
80102537:	e8 ca fe ff ff       	call   80102406 <namex>
8010253c:	83 c4 10             	add    $0x10,%esp
}
8010253f:	c9                   	leave
80102540:	c3                   	ret

80102541 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102541:	55                   	push   %ebp
80102542:	89 e5                	mov    %esp,%ebp
80102544:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102547:	83 ec 04             	sub    $0x4,%esp
8010254a:	ff 75 0c             	push   0xc(%ebp)
8010254d:	6a 01                	push   $0x1
8010254f:	ff 75 08             	push   0x8(%ebp)
80102552:	e8 af fe ff ff       	call   80102406 <namex>
80102557:	83 c4 10             	add    $0x10,%esp
}
8010255a:	c9                   	leave
8010255b:	c3                   	ret

8010255c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010255f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102564:	8b 55 08             	mov    0x8(%ebp),%edx
80102567:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102569:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102571:	5d                   	pop    %ebp
80102572:	c3                   	ret

80102573 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102573:	55                   	push   %ebp
80102574:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102576:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257b:	8b 55 08             	mov    0x8(%ebp),%edx
8010257e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102580:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102585:	8b 55 0c             	mov    0xc(%ebp),%edx
80102588:	89 50 10             	mov    %edx,0x10(%eax)
}
8010258b:	90                   	nop
8010258c:	5d                   	pop    %ebp
8010258d:	c3                   	ret

8010258e <ioapicinit>:

void
ioapicinit(void)
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102594:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
8010259b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010259e:	6a 01                	push   $0x1
801025a0:	e8 b7 ff ff ff       	call   8010255c <ioapicread>
801025a5:	83 c4 04             	add    $0x4,%esp
801025a8:	c1 e8 10             	shr    $0x10,%eax
801025ab:	25 ff 00 00 00       	and    $0xff,%eax
801025b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025b3:	6a 00                	push   $0x0
801025b5:	e8 a2 ff ff ff       	call   8010255c <ioapicread>
801025ba:	83 c4 04             	add    $0x4,%esp
801025bd:	c1 e8 18             	shr    $0x18,%eax
801025c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025c3:	0f b6 05 54 77 19 80 	movzbl 0x80197754,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 b4 a6 10 80       	push   $0x8010a6b4
801025da:	e8 15 de ff ff       	call   801003f4 <cprintf>
801025df:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e9:	eb 3f                	jmp    8010262a <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	83 c0 20             	add    $0x20,%eax
801025f1:	0d 00 00 01 00       	or     $0x10000,%eax
801025f6:	89 c2                	mov    %eax,%edx
801025f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fb:	83 c0 08             	add    $0x8,%eax
801025fe:	01 c0                	add    %eax,%eax
80102600:	83 ec 08             	sub    $0x8,%esp
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 69 ff ff ff       	call   80102573 <ioapicwrite>
8010260a:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102610:	83 c0 08             	add    $0x8,%eax
80102613:	01 c0                	add    %eax,%eax
80102615:	83 c0 01             	add    $0x1,%eax
80102618:	83 ec 08             	sub    $0x8,%esp
8010261b:	6a 00                	push   $0x0
8010261d:	50                   	push   %eax
8010261e:	e8 50 ff ff ff       	call   80102573 <ioapicwrite>
80102623:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102626:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010262a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102630:	7e b9                	jle    801025eb <ioapicinit+0x5d>
  }
}
80102632:	90                   	nop
80102633:	90                   	nop
80102634:	c9                   	leave
80102635:	c3                   	ret

80102636 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102636:	55                   	push   %ebp
80102637:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 20             	add    $0x20,%eax
8010263f:	89 c2                	mov    %eax,%edx
80102641:	8b 45 08             	mov    0x8(%ebp),%eax
80102644:	83 c0 08             	add    $0x8,%eax
80102647:	01 c0                	add    %eax,%eax
80102649:	52                   	push   %edx
8010264a:	50                   	push   %eax
8010264b:	e8 23 ff ff ff       	call   80102573 <ioapicwrite>
80102650:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102653:	8b 45 0c             	mov    0xc(%ebp),%eax
80102656:	c1 e0 18             	shl    $0x18,%eax
80102659:	89 c2                	mov    %eax,%edx
8010265b:	8b 45 08             	mov    0x8(%ebp),%eax
8010265e:	83 c0 08             	add    $0x8,%eax
80102661:	01 c0                	add    %eax,%eax
80102663:	83 c0 01             	add    $0x1,%eax
80102666:	52                   	push   %edx
80102667:	50                   	push   %eax
80102668:	e8 06 ff ff ff       	call   80102573 <ioapicwrite>
8010266d:	83 c4 08             	add    $0x8,%esp
}
80102670:	90                   	nop
80102671:	c9                   	leave
80102672:	c3                   	ret

80102673 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102679:	83 ec 08             	sub    $0x8,%esp
8010267c:	68 e6 a6 10 80       	push   $0x8010a6e6
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 dc 24 00 00       	call   80104b67 <initlock>
8010268b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010268e:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102695:	00 00 00 
  freerange(vstart, vend);
80102698:	83 ec 08             	sub    $0x8,%esp
8010269b:	ff 75 0c             	push   0xc(%ebp)
8010269e:	ff 75 08             	push   0x8(%ebp)
801026a1:	e8 2a 00 00 00       	call   801026d0 <freerange>
801026a6:	83 c4 10             	add    $0x10,%esp
}
801026a9:	90                   	nop
801026aa:	c9                   	leave
801026ab:	c3                   	ret

801026ac <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026ac:	55                   	push   %ebp
801026ad:	89 e5                	mov    %esp,%ebp
801026af:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026b2:	83 ec 08             	sub    $0x8,%esp
801026b5:	ff 75 0c             	push   0xc(%ebp)
801026b8:	ff 75 08             	push   0x8(%ebp)
801026bb:	e8 10 00 00 00       	call   801026d0 <freerange>
801026c0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026c3:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026ca:	00 00 00 
}
801026cd:	90                   	nop
801026ce:	c9                   	leave
801026cf:	c3                   	ret

801026d0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026d6:	8b 45 08             	mov    0x8(%ebp),%eax
801026d9:	05 ff 0f 00 00       	add    $0xfff,%eax
801026de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e6:	eb 15                	jmp    801026fd <freerange+0x2d>
    kfree(p);
801026e8:	83 ec 0c             	sub    $0xc,%esp
801026eb:	ff 75 f4             	push   -0xc(%ebp)
801026ee:	e8 1b 00 00 00       	call   8010270e <kfree>
801026f3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026f6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102700:	05 00 10 00 00       	add    $0x1000,%eax
80102705:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102708:	73 de                	jae    801026e8 <freerange+0x18>
}
8010270a:	90                   	nop
8010270b:	90                   	nop
8010270c:	c9                   	leave
8010270d:	c3                   	ret

8010270e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010270e:	55                   	push   %ebp
8010270f:	89 e5                	mov    %esp,%ebp
80102711:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	25 ff 0f 00 00       	and    $0xfff,%eax
8010271c:	85 c0                	test   %eax,%eax
8010271e:	75 18                	jne    80102738 <kfree+0x2a>
80102720:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102727:	72 0f                	jb     80102738 <kfree+0x2a>
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	05 00 00 00 80       	add    $0x80000000,%eax
80102731:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102736:	76 0d                	jbe    80102745 <kfree+0x37>
    panic("kfree");
80102738:	83 ec 0c             	sub    $0xc,%esp
8010273b:	68 eb a6 10 80       	push   $0x8010a6eb
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 a8 26 00 00       	call   80104dff <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 19 24 00 00       	call   80104b89 <acquire>
80102770:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102779:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
8010277f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102782:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102787:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010278c:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102791:	85 c0                	test   %eax,%eax
80102793:	74 10                	je     801027a5 <kfree+0x97>
    release(&kmem.lock);
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 c0 40 19 80       	push   $0x801940c0
8010279d:	e8 55 24 00 00       	call   80104bf7 <release>
801027a2:	83 c4 10             	add    $0x10,%esp
}
801027a5:	90                   	nop
801027a6:	c9                   	leave
801027a7:	c3                   	ret

801027a8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027ae:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027b3:	85 c0                	test   %eax,%eax
801027b5:	74 10                	je     801027c7 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b7:	83 ec 0c             	sub    $0xc,%esp
801027ba:	68 c0 40 19 80       	push   $0x801940c0
801027bf:	e8 c5 23 00 00       	call   80104b89 <acquire>
801027c4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c7:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d3:	74 0a                	je     801027df <kalloc+0x37>
    kmem.freelist = r->next;
801027d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d8:	8b 00                	mov    (%eax),%eax
801027da:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027df:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027e4:	85 c0                	test   %eax,%eax
801027e6:	74 10                	je     801027f8 <kalloc+0x50>
    release(&kmem.lock);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	68 c0 40 19 80       	push   $0x801940c0
801027f0:	e8 02 24 00 00       	call   80104bf7 <release>
801027f5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027fb:	c9                   	leave
801027fc:	c3                   	ret

801027fd <inb>:
{
801027fd:	55                   	push   %ebp
801027fe:	89 e5                	mov    %esp,%ebp
80102800:	83 ec 14             	sub    $0x14,%esp
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010280a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010280e:	89 c2                	mov    %eax,%edx
80102810:	ec                   	in     (%dx),%al
80102811:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102814:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102818:	c9                   	leave
80102819:	c3                   	ret

8010281a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010281a:	55                   	push   %ebp
8010281b:	89 e5                	mov    %esp,%ebp
8010281d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102820:	6a 64                	push   $0x64
80102822:	e8 d6 ff ff ff       	call   801027fd <inb>
80102827:	83 c4 04             	add    $0x4,%esp
8010282a:	0f b6 c0             	movzbl %al,%eax
8010282d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102833:	83 e0 01             	and    $0x1,%eax
80102836:	85 c0                	test   %eax,%eax
80102838:	75 0a                	jne    80102844 <kbdgetc+0x2a>
    return -1;
8010283a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010283f:	e9 23 01 00 00       	jmp    80102967 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102844:	6a 60                	push   $0x60
80102846:	e8 b2 ff ff ff       	call   801027fd <inb>
8010284b:	83 c4 04             	add    $0x4,%esp
8010284e:	0f b6 c0             	movzbl %al,%eax
80102851:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102854:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010285b:	75 17                	jne    80102874 <kbdgetc+0x5a>
    shift |= E0ESC;
8010285d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102862:	83 c8 40             	or     $0x40,%eax
80102865:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
8010286a:	b8 00 00 00 00       	mov    $0x0,%eax
8010286f:	e9 f3 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102877:	25 80 00 00 00       	and    $0x80,%eax
8010287c:	85 c0                	test   %eax,%eax
8010287e:	74 45                	je     801028c5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102880:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102885:	83 e0 40             	and    $0x40,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 08                	jne    80102894 <kbdgetc+0x7a>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	83 e0 7f             	and    $0x7f,%eax
80102892:	eb 03                	jmp    80102897 <kbdgetc+0x7d>
80102894:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102897:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010289a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010289d:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028a2:	0f b6 00             	movzbl (%eax),%eax
801028a5:	83 c8 40             	or     $0x40,%eax
801028a8:	0f b6 c0             	movzbl %al,%eax
801028ab:	f7 d0                	not    %eax
801028ad:	89 c2                	mov    %eax,%edx
801028af:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b4:	21 d0                	and    %edx,%eax
801028b6:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028bb:	b8 00 00 00 00       	mov    $0x0,%eax
801028c0:	e9 a2 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028c5:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ca:	83 e0 40             	and    $0x40,%eax
801028cd:	85 c0                	test   %eax,%eax
801028cf:	74 14                	je     801028e5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028d1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028dd:	83 e0 bf             	and    $0xffffffbf,%eax
801028e0:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e8:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028ed:	0f b6 00             	movzbl (%eax),%eax
801028f0:	0f b6 d0             	movzbl %al,%edx
801028f3:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f8:	09 d0                	or     %edx,%eax
801028fa:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102902:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102907:	0f b6 00             	movzbl (%eax),%eax
8010290a:	0f b6 d0             	movzbl %al,%edx
8010290d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102912:	31 d0                	xor    %edx,%eax
80102914:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102919:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010291e:	83 e0 03             	and    $0x3,%eax
80102921:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102928:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010292b:	01 d0                	add    %edx,%eax
8010292d:	0f b6 00             	movzbl (%eax),%eax
80102930:	0f b6 c0             	movzbl %al,%eax
80102933:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102936:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010293b:	83 e0 08             	and    $0x8,%eax
8010293e:	85 c0                	test   %eax,%eax
80102940:	74 22                	je     80102964 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102942:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102946:	76 0c                	jbe    80102954 <kbdgetc+0x13a>
80102948:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010294c:	77 06                	ja     80102954 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010294e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102952:	eb 10                	jmp    80102964 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102954:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102958:	76 0a                	jbe    80102964 <kbdgetc+0x14a>
8010295a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010295e:	77 04                	ja     80102964 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102960:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102964:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102967:	c9                   	leave
80102968:	c3                   	ret

80102969 <kbdintr>:

void
kbdintr(void)
{
80102969:	55                   	push   %ebp
8010296a:	89 e5                	mov    %esp,%ebp
8010296c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010296f:	83 ec 0c             	sub    $0xc,%esp
80102972:	68 1a 28 10 80       	push   $0x8010281a
80102977:	e8 5a de ff ff       	call   801007d6 <consoleintr>
8010297c:	83 c4 10             	add    $0x10,%esp
}
8010297f:	90                   	nop
80102980:	c9                   	leave
80102981:	c3                   	ret

80102982 <inb>:
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 14             	sub    $0x14,%esp
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102993:	89 c2                	mov    %eax,%edx
80102995:	ec                   	in     (%dx),%al
80102996:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102999:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010299d:	c9                   	leave
8010299e:	c3                   	ret

8010299f <outb>:
{
8010299f:	55                   	push   %ebp
801029a0:	89 e5                	mov    %esp,%ebp
801029a2:	83 ec 08             	sub    $0x8,%esp
801029a5:	8b 55 08             	mov    0x8(%ebp),%edx
801029a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801029af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029ba:	ee                   	out    %al,(%dx)
}
801029bb:	90                   	nop
801029bc:	c9                   	leave
801029bd:	c3                   	ret

801029be <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029be:	55                   	push   %ebp
801029bf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029c1:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c6:	8b 55 08             	mov    0x8(%ebp),%edx
801029c9:	c1 e2 02             	shl    $0x2,%edx
801029cc:	01 c2                	add    %eax,%edx
801029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801029d1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029d3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d8:	83 c0 20             	add    $0x20,%eax
801029db:	8b 00                	mov    (%eax),%eax
}
801029dd:	90                   	nop
801029de:	5d                   	pop    %ebp
801029df:	c3                   	ret

801029e0 <lapicinit>:

void
lapicinit(void)
{
801029e0:	55                   	push   %ebp
801029e1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029e3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e8:	85 c0                	test   %eax,%eax
801029ea:	0f 84 09 01 00 00    	je     80102af9 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029f0:	68 3f 01 00 00       	push   $0x13f
801029f5:	6a 3c                	push   $0x3c
801029f7:	e8 c2 ff ff ff       	call   801029be <lapicw>
801029fc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029ff:	6a 0b                	push   $0xb
80102a01:	68 f8 00 00 00       	push   $0xf8
80102a06:	e8 b3 ff ff ff       	call   801029be <lapicw>
80102a0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0e:	68 20 00 02 00       	push   $0x20020
80102a13:	68 c8 00 00 00       	push   $0xc8
80102a18:	e8 a1 ff ff ff       	call   801029be <lapicw>
80102a1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a20:	68 80 96 98 00       	push   $0x989680
80102a25:	68 e0 00 00 00       	push   $0xe0
80102a2a:	e8 8f ff ff ff       	call   801029be <lapicw>
80102a2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a32:	68 00 00 01 00       	push   $0x10000
80102a37:	68 d4 00 00 00       	push   $0xd4
80102a3c:	e8 7d ff ff ff       	call   801029be <lapicw>
80102a41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a44:	68 00 00 01 00       	push   $0x10000
80102a49:	68 d8 00 00 00       	push   $0xd8
80102a4e:	e8 6b ff ff ff       	call   801029be <lapicw>
80102a53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a56:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a5b:	83 c0 30             	add    $0x30,%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102a65:	85 c0                	test   %eax,%eax
80102a67:	74 12                	je     80102a7b <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102a69:	68 00 00 01 00       	push   $0x10000
80102a6e:	68 d0 00 00 00       	push   $0xd0
80102a73:	e8 46 ff ff ff       	call   801029be <lapicw>
80102a78:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7b:	6a 33                	push   $0x33
80102a7d:	68 dc 00 00 00       	push   $0xdc
80102a82:	e8 37 ff ff ff       	call   801029be <lapicw>
80102a87:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a8a:	6a 00                	push   $0x0
80102a8c:	68 a0 00 00 00       	push   $0xa0
80102a91:	e8 28 ff ff ff       	call   801029be <lapicw>
80102a96:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a99:	6a 00                	push   $0x0
80102a9b:	68 a0 00 00 00       	push   $0xa0
80102aa0:	e8 19 ff ff ff       	call   801029be <lapicw>
80102aa5:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa8:	6a 00                	push   $0x0
80102aaa:	6a 2c                	push   $0x2c
80102aac:	e8 0d ff ff ff       	call   801029be <lapicw>
80102ab1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab4:	6a 00                	push   $0x0
80102ab6:	68 c4 00 00 00       	push   $0xc4
80102abb:	e8 fe fe ff ff       	call   801029be <lapicw>
80102ac0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac3:	68 00 85 08 00       	push   $0x88500
80102ac8:	68 c0 00 00 00       	push   $0xc0
80102acd:	e8 ec fe ff ff       	call   801029be <lapicw>
80102ad2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad5:	90                   	nop
80102ad6:	a1 00 41 19 80       	mov    0x80194100,%eax
80102adb:	05 00 03 00 00       	add    $0x300,%eax
80102ae0:	8b 00                	mov    (%eax),%eax
80102ae2:	25 00 10 00 00       	and    $0x1000,%eax
80102ae7:	85 c0                	test   %eax,%eax
80102ae9:	75 eb                	jne    80102ad6 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aeb:	6a 00                	push   $0x0
80102aed:	6a 20                	push   $0x20
80102aef:	e8 ca fe ff ff       	call   801029be <lapicw>
80102af4:	83 c4 08             	add    $0x8,%esp
80102af7:	eb 01                	jmp    80102afa <lapicinit+0x11a>
    return;
80102af9:	90                   	nop
}
80102afa:	c9                   	leave
80102afb:	c3                   	ret

80102afc <lapicid>:

int
lapicid(void)
{
80102afc:	55                   	push   %ebp
80102afd:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102aff:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	75 07                	jne    80102b0f <lapicid+0x13>
    return 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0d:	eb 0d                	jmp    80102b1c <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b14:	83 c0 20             	add    $0x20,%eax
80102b17:	8b 00                	mov    (%eax),%eax
80102b19:	c1 e8 18             	shr    $0x18,%eax
}
80102b1c:	5d                   	pop    %ebp
80102b1d:	c3                   	ret

80102b1e <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1e:	55                   	push   %ebp
80102b1f:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b21:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b26:	85 c0                	test   %eax,%eax
80102b28:	74 0c                	je     80102b36 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b2a:	6a 00                	push   $0x0
80102b2c:	6a 2c                	push   $0x2c
80102b2e:	e8 8b fe ff ff       	call   801029be <lapicw>
80102b33:	83 c4 08             	add    $0x8,%esp
}
80102b36:	90                   	nop
80102b37:	c9                   	leave
80102b38:	c3                   	ret

80102b39 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b39:	55                   	push   %ebp
80102b3a:	89 e5                	mov    %esp,%ebp
}
80102b3c:	90                   	nop
80102b3d:	5d                   	pop    %ebp
80102b3e:	c3                   	ret

80102b3f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 14             	sub    $0x14,%esp
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4b:	6a 0f                	push   $0xf
80102b4d:	6a 70                	push   $0x70
80102b4f:	e8 4b fe ff ff       	call   8010299f <outb>
80102b54:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b57:	6a 0a                	push   $0xa
80102b59:	6a 71                	push   $0x71
80102b5b:	e8 3f fe ff ff       	call   8010299f <outb>
80102b60:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b63:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b75:	c1 e8 04             	shr    $0x4,%eax
80102b78:	89 c2                	mov    %eax,%edx
80102b7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7d:	83 c0 02             	add    $0x2,%eax
80102b80:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b83:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b87:	c1 e0 18             	shl    $0x18,%eax
80102b8a:	50                   	push   %eax
80102b8b:	68 c4 00 00 00       	push   $0xc4
80102b90:	e8 29 fe ff ff       	call   801029be <lapicw>
80102b95:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b98:	68 00 c5 00 00       	push   $0xc500
80102b9d:	68 c0 00 00 00       	push   $0xc0
80102ba2:	e8 17 fe ff ff       	call   801029be <lapicw>
80102ba7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102baa:	68 c8 00 00 00       	push   $0xc8
80102baf:	e8 85 ff ff ff       	call   80102b39 <microdelay>
80102bb4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb7:	68 00 85 00 00       	push   $0x8500
80102bbc:	68 c0 00 00 00       	push   $0xc0
80102bc1:	e8 f8 fd ff ff       	call   801029be <lapicw>
80102bc6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc9:	6a 64                	push   $0x64
80102bcb:	e8 69 ff ff ff       	call   80102b39 <microdelay>
80102bd0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bda:	eb 3d                	jmp    80102c19 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102be0:	c1 e0 18             	shl    $0x18,%eax
80102be3:	50                   	push   %eax
80102be4:	68 c4 00 00 00       	push   $0xc4
80102be9:	e8 d0 fd ff ff       	call   801029be <lapicw>
80102bee:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf4:	c1 e8 0c             	shr    $0xc,%eax
80102bf7:	80 cc 06             	or     $0x6,%ah
80102bfa:	50                   	push   %eax
80102bfb:	68 c0 00 00 00       	push   $0xc0
80102c00:	e8 b9 fd ff ff       	call   801029be <lapicw>
80102c05:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c08:	68 c8 00 00 00       	push   $0xc8
80102c0d:	e8 27 ff ff ff       	call   80102b39 <microdelay>
80102c12:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c15:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c19:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1d:	7e bd                	jle    80102bdc <lapicstartap+0x9d>
  }
}
80102c1f:	90                   	nop
80102c20:	90                   	nop
80102c21:	c9                   	leave
80102c22:	c3                   	ret

80102c23 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c26:	8b 45 08             	mov    0x8(%ebp),%eax
80102c29:	0f b6 c0             	movzbl %al,%eax
80102c2c:	50                   	push   %eax
80102c2d:	6a 70                	push   $0x70
80102c2f:	e8 6b fd ff ff       	call   8010299f <outb>
80102c34:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c37:	68 c8 00 00 00       	push   $0xc8
80102c3c:	e8 f8 fe ff ff       	call   80102b39 <microdelay>
80102c41:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c44:	6a 71                	push   $0x71
80102c46:	e8 37 fd ff ff       	call   80102982 <inb>
80102c4b:	83 c4 04             	add    $0x4,%esp
80102c4e:	0f b6 c0             	movzbl %al,%eax
}
80102c51:	c9                   	leave
80102c52:	c3                   	ret

80102c53 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c53:	55                   	push   %ebp
80102c54:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c56:	6a 00                	push   $0x0
80102c58:	e8 c6 ff ff ff       	call   80102c23 <cmos_read>
80102c5d:	83 c4 04             	add    $0x4,%esp
80102c60:	8b 55 08             	mov    0x8(%ebp),%edx
80102c63:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c65:	6a 02                	push   $0x2
80102c67:	e8 b7 ff ff ff       	call   80102c23 <cmos_read>
80102c6c:	83 c4 04             	add    $0x4,%esp
80102c6f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c72:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c75:	6a 04                	push   $0x4
80102c77:	e8 a7 ff ff ff       	call   80102c23 <cmos_read>
80102c7c:	83 c4 04             	add    $0x4,%esp
80102c7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c82:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c85:	6a 07                	push   $0x7
80102c87:	e8 97 ff ff ff       	call   80102c23 <cmos_read>
80102c8c:	83 c4 04             	add    $0x4,%esp
80102c8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c92:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c95:	6a 08                	push   $0x8
80102c97:	e8 87 ff ff ff       	call   80102c23 <cmos_read>
80102c9c:	83 c4 04             	add    $0x4,%esp
80102c9f:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca2:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca5:	6a 09                	push   $0x9
80102ca7:	e8 77 ff ff ff       	call   80102c23 <cmos_read>
80102cac:	83 c4 04             	add    $0x4,%esp
80102caf:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb2:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb5:	90                   	nop
80102cb6:	c9                   	leave
80102cb7:	c3                   	ret

80102cb8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbe:	6a 0b                	push   $0xb
80102cc0:	e8 5e ff ff ff       	call   80102c23 <cmos_read>
80102cc5:	83 c4 04             	add    $0x4,%esp
80102cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cce:	83 e0 04             	and    $0x4,%eax
80102cd1:	85 c0                	test   %eax,%eax
80102cd3:	0f 94 c0             	sete   %al
80102cd6:	0f b6 c0             	movzbl %al,%eax
80102cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdc:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdf:	50                   	push   %eax
80102ce0:	e8 6e ff ff ff       	call   80102c53 <fill_rtcdate>
80102ce5:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce8:	6a 0a                	push   $0xa
80102cea:	e8 34 ff ff ff       	call   80102c23 <cmos_read>
80102cef:	83 c4 04             	add    $0x4,%esp
80102cf2:	25 80 00 00 00       	and    $0x80,%eax
80102cf7:	85 c0                	test   %eax,%eax
80102cf9:	75 27                	jne    80102d22 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfb:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfe:	50                   	push   %eax
80102cff:	e8 4f ff ff ff       	call   80102c53 <fill_rtcdate>
80102d04:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d07:	83 ec 04             	sub    $0x4,%esp
80102d0a:	6a 18                	push   $0x18
80102d0c:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0f:	50                   	push   %eax
80102d10:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d13:	50                   	push   %eax
80102d14:	e8 4d 21 00 00       	call   80104e66 <memcmp>
80102d19:	83 c4 10             	add    $0x10,%esp
80102d1c:	85 c0                	test   %eax,%eax
80102d1e:	74 05                	je     80102d25 <cmostime+0x6d>
80102d20:	eb ba                	jmp    80102cdc <cmostime+0x24>
        continue;
80102d22:	90                   	nop
    fill_rtcdate(&t1);
80102d23:	eb b7                	jmp    80102cdc <cmostime+0x24>
      break;
80102d25:	90                   	nop
  }

  // convert
  if(bcd) {
80102d26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d2a:	0f 84 b4 00 00 00    	je     80102de4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d33:	c1 e8 04             	shr    $0x4,%eax
80102d36:	89 c2                	mov    %eax,%edx
80102d38:	89 d0                	mov    %edx,%eax
80102d3a:	c1 e0 02             	shl    $0x2,%eax
80102d3d:	01 d0                	add    %edx,%eax
80102d3f:	01 c0                	add    %eax,%eax
80102d41:	89 c2                	mov    %eax,%edx
80102d43:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d46:	83 e0 0f             	and    $0xf,%eax
80102d49:	01 d0                	add    %edx,%eax
80102d4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d51:	c1 e8 04             	shr    $0x4,%eax
80102d54:	89 c2                	mov    %eax,%edx
80102d56:	89 d0                	mov    %edx,%eax
80102d58:	c1 e0 02             	shl    $0x2,%eax
80102d5b:	01 d0                	add    %edx,%eax
80102d5d:	01 c0                	add    %eax,%eax
80102d5f:	89 c2                	mov    %eax,%edx
80102d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d64:	83 e0 0f             	and    $0xf,%eax
80102d67:	01 d0                	add    %edx,%eax
80102d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6f:	c1 e8 04             	shr    $0x4,%eax
80102d72:	89 c2                	mov    %eax,%edx
80102d74:	89 d0                	mov    %edx,%eax
80102d76:	c1 e0 02             	shl    $0x2,%eax
80102d79:	01 d0                	add    %edx,%eax
80102d7b:	01 c0                	add    %eax,%eax
80102d7d:	89 c2                	mov    %eax,%edx
80102d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d82:	83 e0 0f             	and    $0xf,%eax
80102d85:	01 d0                	add    %edx,%eax
80102d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8d:	c1 e8 04             	shr    $0x4,%eax
80102d90:	89 c2                	mov    %eax,%edx
80102d92:	89 d0                	mov    %edx,%eax
80102d94:	c1 e0 02             	shl    $0x2,%eax
80102d97:	01 d0                	add    %edx,%eax
80102d99:	01 c0                	add    %eax,%eax
80102d9b:	89 c2                	mov    %eax,%edx
80102d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102da0:	83 e0 0f             	and    $0xf,%eax
80102da3:	01 d0                	add    %edx,%eax
80102da5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dab:	c1 e8 04             	shr    $0x4,%eax
80102dae:	89 c2                	mov    %eax,%edx
80102db0:	89 d0                	mov    %edx,%eax
80102db2:	c1 e0 02             	shl    $0x2,%eax
80102db5:	01 d0                	add    %edx,%eax
80102db7:	01 c0                	add    %eax,%eax
80102db9:	89 c2                	mov    %eax,%edx
80102dbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbe:	83 e0 0f             	and    $0xf,%eax
80102dc1:	01 d0                	add    %edx,%eax
80102dc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc9:	c1 e8 04             	shr    $0x4,%eax
80102dcc:	89 c2                	mov    %eax,%edx
80102dce:	89 d0                	mov    %edx,%eax
80102dd0:	c1 e0 02             	shl    $0x2,%eax
80102dd3:	01 d0                	add    %edx,%eax
80102dd5:	01 c0                	add    %eax,%eax
80102dd7:	89 c2                	mov    %eax,%edx
80102dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddc:	83 e0 0f             	and    $0xf,%eax
80102ddf:	01 d0                	add    %edx,%eax
80102de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de4:	8b 45 08             	mov    0x8(%ebp),%eax
80102de7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dea:	89 10                	mov    %edx,(%eax)
80102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102def:	89 50 04             	mov    %edx,0x4(%eax)
80102df2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df5:	89 50 08             	mov    %edx,0x8(%eax)
80102df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfb:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e01:	89 50 10             	mov    %edx,0x10(%eax)
80102e04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e07:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0d:	8b 40 14             	mov    0x14(%eax),%eax
80102e10:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e16:	8b 45 08             	mov    0x8(%ebp),%eax
80102e19:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1c:	90                   	nop
80102e1d:	c9                   	leave
80102e1e:	c3                   	ret

80102e1f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1f:	55                   	push   %ebp
80102e20:	89 e5                	mov    %esp,%ebp
80102e22:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e25:	83 ec 08             	sub    $0x8,%esp
80102e28:	68 f1 a6 10 80       	push   $0x8010a6f1
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 30 1d 00 00       	call   80104b67 <initlock>
80102e37:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e3a:	83 ec 08             	sub    $0x8,%esp
80102e3d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e40:	50                   	push   %eax
80102e41:	ff 75 08             	push   0x8(%ebp)
80102e44:	e8 8f e5 ff ff       	call   801013d8 <readsb>
80102e49:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4f:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e57:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5f:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e64:	e8 b3 01 00 00       	call   8010301c <recover_from_log>
}
80102e69:	90                   	nop
80102e6a:	c9                   	leave
80102e6b:	c3                   	ret

80102e6c <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6c:	55                   	push   %ebp
80102e6d:	89 e5                	mov    %esp,%ebp
80102e6f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e79:	e9 95 00 00 00       	jmp    80102f13 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	83 c0 01             	add    $0x1,%eax
80102e8c:	89 c2                	mov    %eax,%edx
80102e8e:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e93:	83 ec 08             	sub    $0x8,%esp
80102e96:	52                   	push   %edx
80102e97:	50                   	push   %eax
80102e98:	e8 64 d3 ff ff       	call   80100201 <bread>
80102e9d:	83 c4 10             	add    $0x10,%esp
80102ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea6:	83 c0 10             	add    $0x10,%eax
80102ea9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eb0:	89 c2                	mov    %eax,%edx
80102eb2:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb7:	83 ec 08             	sub    $0x8,%esp
80102eba:	52                   	push   %edx
80102ebb:	50                   	push   %eax
80102ebc:	e8 40 d3 ff ff       	call   80100201 <bread>
80102ec1:	83 c4 10             	add    $0x10,%esp
80102ec4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eca:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ed0:	83 c0 5c             	add    $0x5c,%eax
80102ed3:	83 ec 04             	sub    $0x4,%esp
80102ed6:	68 00 02 00 00       	push   $0x200
80102edb:	52                   	push   %edx
80102edc:	50                   	push   %eax
80102edd:	e8 dc 1f 00 00       	call   80104ebe <memmove>
80102ee2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee5:	83 ec 0c             	sub    $0xc,%esp
80102ee8:	ff 75 ec             	push   -0x14(%ebp)
80102eeb:	e8 4a d3 ff ff       	call   8010023a <bwrite>
80102ef0:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	ff 75 f0             	push   -0x10(%ebp)
80102ef9:	e8 85 d3 ff ff       	call   80100283 <brelse>
80102efe:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f01:	83 ec 0c             	sub    $0xc,%esp
80102f04:	ff 75 ec             	push   -0x14(%ebp)
80102f07:	e8 77 d3 ff ff       	call   80100283 <brelse>
80102f0c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f13:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f18:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1b:	0f 8c 5d ff ff ff    	jl     80102e7e <install_trans+0x12>
  }
}
80102f21:	90                   	nop
80102f22:	90                   	nop
80102f23:	c9                   	leave
80102f24:	c3                   	ret

80102f25 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f25:	55                   	push   %ebp
80102f26:	89 e5                	mov    %esp,%ebp
80102f28:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2b:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f30:	89 c2                	mov    %eax,%edx
80102f32:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f37:	83 ec 08             	sub    $0x8,%esp
80102f3a:	52                   	push   %edx
80102f3b:	50                   	push   %eax
80102f3c:	e8 c0 d2 ff ff       	call   80100201 <bread>
80102f41:	83 c4 10             	add    $0x10,%esp
80102f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f4a:	83 c0 5c             	add    $0x5c,%eax
80102f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f53:	8b 00                	mov    (%eax),%eax
80102f55:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f61:	eb 1b                	jmp    80102f7e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f69:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f70:	83 c2 10             	add    $0x10,%edx
80102f73:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7e:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f83:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f86:	7c db                	jl     80102f63 <read_head+0x3e>
  }
  brelse(buf);
80102f88:	83 ec 0c             	sub    $0xc,%esp
80102f8b:	ff 75 f0             	push   -0x10(%ebp)
80102f8e:	e8 f0 d2 ff ff       	call   80100283 <brelse>
80102f93:	83 c4 10             	add    $0x10,%esp
}
80102f96:	90                   	nop
80102f97:	c9                   	leave
80102f98:	c3                   	ret

80102f99 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f99:	55                   	push   %ebp
80102f9a:	89 e5                	mov    %esp,%ebp
80102f9c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9f:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa4:	89 c2                	mov    %eax,%edx
80102fa6:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fab:	83 ec 08             	sub    $0x8,%esp
80102fae:	52                   	push   %edx
80102faf:	50                   	push   %eax
80102fb0:	e8 4c d2 ff ff       	call   80100201 <bread>
80102fb5:	83 c4 10             	add    $0x10,%esp
80102fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbe:	83 c0 5c             	add    $0x5c,%eax
80102fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc4:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd6:	eb 1b                	jmp    80102ff3 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdb:	83 c0 10             	add    $0x10,%eax
80102fde:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102feb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff3:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffb:	7c db                	jl     80102fd8 <write_head+0x3f>
  }
  bwrite(buf);
80102ffd:	83 ec 0c             	sub    $0xc,%esp
80103000:	ff 75 f0             	push   -0x10(%ebp)
80103003:	e8 32 d2 ff ff       	call   8010023a <bwrite>
80103008:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300b:	83 ec 0c             	sub    $0xc,%esp
8010300e:	ff 75 f0             	push   -0x10(%ebp)
80103011:	e8 6d d2 ff ff       	call   80100283 <brelse>
80103016:	83 c4 10             	add    $0x10,%esp
}
80103019:	90                   	nop
8010301a:	c9                   	leave
8010301b:	c3                   	ret

8010301c <recover_from_log>:

static void
recover_from_log(void)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
8010301f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103022:	e8 fe fe ff ff       	call   80102f25 <read_head>
  install_trans(); // if committed, copy from log to disk
80103027:	e8 40 fe ff ff       	call   80102e6c <install_trans>
  log.lh.n = 0;
8010302c:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103033:	00 00 00 
  write_head(); // clear the log
80103036:	e8 5e ff ff ff       	call   80102f99 <write_head>
}
8010303b:	90                   	nop
8010303c:	c9                   	leave
8010303d:	c3                   	ret

8010303e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303e:	55                   	push   %ebp
8010303f:	89 e5                	mov    %esp,%ebp
80103041:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 20 41 19 80       	push   $0x80194120
8010304c:	e8 38 1b 00 00       	call   80104b89 <acquire>
80103051:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103054:	a1 60 41 19 80       	mov    0x80194160,%eax
80103059:	85 c0                	test   %eax,%eax
8010305b:	74 17                	je     80103074 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305d:	83 ec 08             	sub    $0x8,%esp
80103060:	68 20 41 19 80       	push   $0x80194120
80103065:	68 20 41 19 80       	push   $0x80194120
8010306a:	e8 00 14 00 00       	call   8010446f <sleep>
8010306f:	83 c4 10             	add    $0x10,%esp
80103072:	eb e0                	jmp    80103054 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103074:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
8010307a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307f:	8d 50 01             	lea    0x1(%eax),%edx
80103082:	89 d0                	mov    %edx,%eax
80103084:	c1 e0 02             	shl    $0x2,%eax
80103087:	01 d0                	add    %edx,%eax
80103089:	01 c0                	add    %eax,%eax
8010308b:	01 c8                	add    %ecx,%eax
8010308d:	83 f8 1e             	cmp    $0x1e,%eax
80103090:	7e 17                	jle    801030a9 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103092:	83 ec 08             	sub    $0x8,%esp
80103095:	68 20 41 19 80       	push   $0x80194120
8010309a:	68 20 41 19 80       	push   $0x80194120
8010309f:	e8 cb 13 00 00       	call   8010446f <sleep>
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	eb ab                	jmp    80103054 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a9:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ae:	83 c0 01             	add    $0x1,%eax
801030b1:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b6:	83 ec 0c             	sub    $0xc,%esp
801030b9:	68 20 41 19 80       	push   $0x80194120
801030be:	e8 34 1b 00 00       	call   80104bf7 <release>
801030c3:	83 c4 10             	add    $0x10,%esp
      break;
801030c6:	90                   	nop
    }
  }
}
801030c7:	90                   	nop
801030c8:	c9                   	leave
801030c9:	c3                   	ret

801030ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030ca:	55                   	push   %ebp
801030cb:	89 e5                	mov    %esp,%ebp
801030cd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d7:	83 ec 0c             	sub    $0xc,%esp
801030da:	68 20 41 19 80       	push   $0x80194120
801030df:	e8 a5 1a 00 00       	call   80104b89 <acquire>
801030e4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ec:	83 e8 01             	sub    $0x1,%eax
801030ef:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f4:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f9:	85 c0                	test   %eax,%eax
801030fb:	74 0d                	je     8010310a <end_op+0x40>
    panic("log.committing");
801030fd:	83 ec 0c             	sub    $0xc,%esp
80103100:	68 f5 a6 10 80       	push   $0x8010a6f5
80103105:	e8 9f d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
8010310a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310f:	85 c0                	test   %eax,%eax
80103111:	75 13                	jne    80103126 <end_op+0x5c>
    do_commit = 1;
80103113:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010311a:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103121:	00 00 00 
80103124:	eb 10                	jmp    80103136 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103126:	83 ec 0c             	sub    $0xc,%esp
80103129:	68 20 41 19 80       	push   $0x80194120
8010312e:	e8 26 14 00 00       	call   80104559 <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 b4 1a 00 00       	call   80104bf7 <release>
80103143:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103146:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010314a:	74 3f                	je     8010318b <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314c:	e8 f6 00 00 00       	call   80103247 <commit>
    acquire(&log.lock);
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	68 20 41 19 80       	push   $0x80194120
80103159:	e8 2b 1a 00 00       	call   80104b89 <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 e1 13 00 00       	call   80104559 <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 6f 1a 00 00       	call   80104bf7 <release>
80103188:	83 c4 10             	add    $0x10,%esp
  }
}
8010318b:	90                   	nop
8010318c:	c9                   	leave
8010318d:	c3                   	ret

8010318e <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318e:	55                   	push   %ebp
8010318f:	89 e5                	mov    %esp,%ebp
80103191:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319b:	e9 95 00 00 00       	jmp    80103235 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801031a0:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a9:	01 d0                	add    %edx,%eax
801031ab:	83 c0 01             	add    $0x1,%eax
801031ae:	89 c2                	mov    %eax,%edx
801031b0:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b5:	83 ec 08             	sub    $0x8,%esp
801031b8:	52                   	push   %edx
801031b9:	50                   	push   %eax
801031ba:	e8 42 d0 ff ff       	call   80100201 <bread>
801031bf:	83 c4 10             	add    $0x10,%esp
801031c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c8:	83 c0 10             	add    $0x10,%eax
801031cb:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d2:	89 c2                	mov    %eax,%edx
801031d4:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d9:	83 ec 08             	sub    $0x8,%esp
801031dc:	52                   	push   %edx
801031dd:	50                   	push   %eax
801031de:	e8 1e d0 ff ff       	call   80100201 <bread>
801031e3:	83 c4 10             	add    $0x10,%esp
801031e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ec:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f2:	83 c0 5c             	add    $0x5c,%eax
801031f5:	83 ec 04             	sub    $0x4,%esp
801031f8:	68 00 02 00 00       	push   $0x200
801031fd:	52                   	push   %edx
801031fe:	50                   	push   %eax
801031ff:	e8 ba 1c 00 00       	call   80104ebe <memmove>
80103204:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103207:	83 ec 0c             	sub    $0xc,%esp
8010320a:	ff 75 f0             	push   -0x10(%ebp)
8010320d:	e8 28 d0 ff ff       	call   8010023a <bwrite>
80103212:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103215:	83 ec 0c             	sub    $0xc,%esp
80103218:	ff 75 ec             	push   -0x14(%ebp)
8010321b:	e8 63 d0 ff ff       	call   80100283 <brelse>
80103220:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103223:	83 ec 0c             	sub    $0xc,%esp
80103226:	ff 75 f0             	push   -0x10(%ebp)
80103229:	e8 55 d0 ff ff       	call   80100283 <brelse>
8010322e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103235:	a1 68 41 19 80       	mov    0x80194168,%eax
8010323a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323d:	0f 8c 5d ff ff ff    	jl     801031a0 <write_log+0x12>
  }
}
80103243:	90                   	nop
80103244:	90                   	nop
80103245:	c9                   	leave
80103246:	c3                   	ret

80103247 <commit>:

static void
commit()
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103252:	85 c0                	test   %eax,%eax
80103254:	7e 1e                	jle    80103274 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103256:	e8 33 ff ff ff       	call   8010318e <write_log>
    write_head();    // Write header to disk -- the real commit
8010325b:	e8 39 fd ff ff       	call   80102f99 <write_head>
    install_trans(); // Now install writes to home locations
80103260:	e8 07 fc ff ff       	call   80102e6c <install_trans>
    log.lh.n = 0;
80103265:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326f:	e8 25 fd ff ff       	call   80102f99 <write_head>
  }
}
80103274:	90                   	nop
80103275:	c9                   	leave
80103276:	c3                   	ret

80103277 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103277:	55                   	push   %ebp
80103278:	89 e5                	mov    %esp,%ebp
8010327a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103282:	83 f8 1d             	cmp    $0x1d,%eax
80103285:	7f 12                	jg     80103299 <log_write+0x22>
80103287:	8b 15 68 41 19 80    	mov    0x80194168,%edx
8010328d:	a1 58 41 19 80       	mov    0x80194158,%eax
80103292:	83 e8 01             	sub    $0x1,%eax
80103295:	39 c2                	cmp    %eax,%edx
80103297:	7c 0d                	jl     801032a6 <log_write+0x2f>
    panic("too big a transaction");
80103299:	83 ec 0c             	sub    $0xc,%esp
8010329c:	68 04 a7 10 80       	push   $0x8010a704
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 1a a7 10 80       	push   $0x8010a71a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 c0 18 00 00       	call   80104b89 <acquire>
801032c9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d3:	eb 1d                	jmp    801032f2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d8:	83 c0 10             	add    $0x10,%eax
801032db:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 08             	mov    0x8(%ebp),%eax
801032e7:	8b 40 08             	mov    0x8(%eax),%eax
801032ea:	39 c2                	cmp    %eax,%edx
801032ec:	74 10                	je     801032fe <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f2:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032fa:	7c d9                	jl     801032d5 <log_write+0x5e>
801032fc:	eb 01                	jmp    801032ff <log_write+0x88>
      break;
801032fe:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	8b 40 08             	mov    0x8(%eax),%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330a:	83 c0 10             	add    $0x10,%eax
8010330d:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103314:	a1 68 41 19 80       	mov    0x80194168,%eax
80103319:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331c:	75 0d                	jne    8010332b <log_write+0xb4>
    log.lh.n++;
8010331e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103323:	83 c0 01             	add    $0x1,%eax
80103326:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332b:	8b 45 08             	mov    0x8(%ebp),%eax
8010332e:	8b 00                	mov    (%eax),%eax
80103330:	83 c8 04             	or     $0x4,%eax
80103333:	89 c2                	mov    %eax,%edx
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010333a:	83 ec 0c             	sub    $0xc,%esp
8010333d:	68 20 41 19 80       	push   $0x80194120
80103342:	e8 b0 18 00 00       	call   80104bf7 <release>
80103347:	83 c4 10             	add    $0x10,%esp
}
8010334a:	90                   	nop
8010334b:	c9                   	leave
8010334c:	c3                   	ret

8010334d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
80103350:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103353:	8b 55 08             	mov    0x8(%ebp),%edx
80103356:	8b 45 0c             	mov    0xc(%ebp),%eax
80103359:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335c:	f0 87 02             	lock xchg %eax,(%edx)
8010335f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103365:	c9                   	leave
80103366:	c3                   	ret

80103367 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103367:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336b:	83 e4 f0             	and    $0xfffffff0,%esp
8010336e:	ff 71 fc             	push   -0x4(%ecx)
80103371:	55                   	push   %ebp
80103372:	89 e5                	mov    %esp,%ebp
80103374:	51                   	push   %ecx
80103375:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103378:	e8 15 4f 00 00       	call   80108292 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 18 45 00 00       	call   801078af <kvmalloc>
  mpinit_uefi();
80103397:	e8 bf 4c 00 00       	call   8010805b <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 a0 3f 00 00       	call   80107346 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 25 33 00 00       	call   801066df <uartinit>
  pinit();         // process table
801033ba:	e8 c7 05 00 00       	call   80103986 <pinit>
  tvinit();        // trap vectors
801033bf:	e8 80 2e 00 00       	call   80106244 <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 ea 6f 00 00       	call   8010a3bd <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 fb 50 00 00       	call   801084ed <pci_init>
  arp_scan();
801033f2:	e8 30 5e 00 00       	call   80109227 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 ad 07 00 00       	call   80103ba9 <userinit>

  mpmain();        // finish this processor's setup
801033fc:	e8 1a 00 00 00       	call   8010341b <mpmain>

80103401 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103407:	e8 bb 44 00 00       	call   801078c7 <switchkvm>
  seginit();
8010340c:	e8 35 3f 00 00       	call   80107346 <seginit>
  lapicinit();
80103411:	e8 ca f5 ff ff       	call   801029e0 <lapicinit>
  mpmain();
80103416:	e8 00 00 00 00       	call   8010341b <mpmain>

8010341b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341b:	55                   	push   %ebp
8010341c:	89 e5                	mov    %esp,%ebp
8010341e:	53                   	push   %ebx
8010341f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103422:	e8 7d 05 00 00       	call   801039a4 <cpuid>
80103427:	89 c3                	mov    %eax,%ebx
80103429:	e8 76 05 00 00       	call   801039a4 <cpuid>
8010342e:	83 ec 04             	sub    $0x4,%esp
80103431:	53                   	push   %ebx
80103432:	50                   	push   %eax
80103433:	68 35 a7 10 80       	push   $0x8010a735
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 75 2f 00 00       	call   801063ba <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 75 05 00 00       	call   801039bf <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 d8 0c 00 00       	call   8010413a <scheduler>

80103462 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103462:	55                   	push   %ebp
80103463:	89 e5                	mov    %esp,%ebp
80103465:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103468:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346f:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103474:	83 ec 04             	sub    $0x4,%esp
80103477:	50                   	push   %eax
80103478:	68 38 f5 10 80       	push   $0x8010f538
8010347d:	ff 75 f0             	push   -0x10(%ebp)
80103480:	e8 39 1a 00 00       	call   80104ebe <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 80 74 19 80 	movl   $0x80197480,-0xc(%ebp)
8010348f:	eb 79                	jmp    8010350a <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103491:	e8 29 05 00 00       	call   801039bf <mycpu>
80103496:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103499:	74 67                	je     80103502 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349b:	e8 08 f3 ff ff       	call   801027a8 <kalloc>
801034a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	83 e8 04             	sub    $0x4,%eax
801034a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ac:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b7:	83 e8 08             	sub    $0x8,%eax
801034ba:	c7 00 01 34 10 80    	movl   $0x80103401,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034c0:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	83 e8 0c             	sub    $0xc,%eax
801034d1:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034df:	0f b6 00             	movzbl (%eax),%eax
801034e2:	0f b6 c0             	movzbl %al,%eax
801034e5:	83 ec 08             	sub    $0x8,%esp
801034e8:	52                   	push   %edx
801034e9:	50                   	push   %eax
801034ea:	e8 50 f6 ff ff       	call   80102b3f <lapicstartap>
801034ef:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f2:	90                   	nop
801034f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fc:	85 c0                	test   %eax,%eax
801034fe:	74 f3                	je     801034f3 <startothers+0x91>
80103500:	eb 01                	jmp    80103503 <startothers+0xa1>
      continue;
80103502:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103503:	81 45 f4 b4 00 00 00 	addl   $0xb4,-0xc(%ebp)
8010350a:	a1 50 77 19 80       	mov    0x80197750,%eax
8010350f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103515:	05 80 74 19 80       	add    $0x80197480,%eax
8010351a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351d:	0f 82 6e ff ff ff    	jb     80103491 <startothers+0x2f>
      ;
  }
}
80103523:	90                   	nop
80103524:	90                   	nop
80103525:	c9                   	leave
80103526:	c3                   	ret

80103527 <outb>:
{
80103527:	55                   	push   %ebp
80103528:	89 e5                	mov    %esp,%ebp
8010352a:	83 ec 08             	sub    $0x8,%esp
8010352d:	8b 55 08             	mov    0x8(%ebp),%edx
80103530:	8b 45 0c             	mov    0xc(%ebp),%eax
80103533:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave
80103545:	c3                   	ret

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d2 ff ff ff       	call   80103527 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 c0 ff ff ff       	call   80103527 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave
8010356c:	c3                   	ret

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 55 da ff ff       	call   80100fe7 <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 3e da ff ff       	call   80100fe7 <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e8 f1 ff ff       	call   801027a8 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 49 a7 10 80       	push   $0x8010a749
8010360c:	50                   	push   %eax
8010360d:	e8 55 15 00 00       	call   80104b67 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 8d f0 ff ff       	call   8010270e <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 0a da ff ff       	call   801010a5 <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 f0 d9 ff ff       	call   801010a5 <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave
801036be:	c3                   	ret

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 b8 14 00 00       	call   80104b89 <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 61 0e 00 00       	call   80104559 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 3e 0e 00 00       	call   80104559 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 b3 14 00 00       	call   80104bf7 <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 bc ef ff ff       	call   8010270e <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 94 14 00 00       	call   80104bf7 <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave
80103769:	c3                   	ret

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 0c 14 00 00       	call   80104b89 <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 99 02 00 00       	call   80103a37 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 46 14 00 00       	call   80104bf7 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 8a 0d 00 00       	call   80104559 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 87 0c 00 00       	call   8010446f <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 07 0d 00 00       	call   80104559 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 96 13 00 00       	call   80104bf7 <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave
8010386b:	c3                   	ret

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 0b 13 00 00       	call   80104b89 <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 af 01 00 00       	call   80103a37 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 5c 13 00 00       	call   80104bf7 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 b1 0b 00 00       	call   8010446f <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 08 0c 00 00       	call   80104559 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 97 12 00 00       	call   80104bf7 <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave
80103967:	c3                   	ret

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave
80103977:	c3                   	ret

80103978 <cli>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010397b:	fa                   	cli
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret

8010397f <sti>:
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103982:	fb                   	sti
}
80103983:	90                   	nop
80103984:	5d                   	pop    %ebp
80103985:	c3                   	ret

80103986 <pinit>:
static void wakeup1(void *chan);  //내부적으로 사용되는 wakeup 함수 . 조건 변수 chan을 기다리는 프로세스들을 깨움 

// ptable을 초기화하는 함수 . xv6 커널 시작시 호출된다
void
pinit(void)
{
80103986:	55                   	push   %ebp
80103987:	89 e5                	mov    %esp,%ebp
80103989:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");  //락을 초기화 한다 . 이후 ptable 접근시 이 락을 사용해 동기화 한다.
8010398c:	83 ec 08             	sub    $0x8,%esp
8010398f:	68 50 a7 10 80       	push   $0x8010a750
80103994:	68 00 42 19 80       	push   $0x80194200
80103999:	e8 c9 11 00 00       	call   80104b67 <initlock>
8010399e:	83 c4 10             	add    $0x10,%esp
}
801039a1:	90                   	nop
801039a2:	c9                   	leave
801039a3:	c3                   	ret

801039a4 <cpuid>:

// 인터럽트가 꺼진 상태에서 호출되어야 함/ (context switch중 안전하게 실행되도록 하기 위해)
// 현재 실행 중인 cpu 의 id를 반환 하는 함수
int
cpuid() {
801039a4:	55                   	push   %ebp
801039a5:	89 e5                	mov    %esp,%ebp
801039a7:	83 ec 08             	sub    $0x8,%esp
  // mycpu()는 현재 cpu의 구조체 포인터를 반환함
  // cpus는 cpu배열의 시작주소. 포인터 뺄셈을 통해 현재 cpu의 인덱스를 구함.
  return mycpu()-cpus;
801039aa:	e8 10 00 00 00       	call   801039bf <mycpu>
801039af:	2d 80 74 19 80       	sub    $0x80197480,%eax
801039b4:	c1 f8 02             	sar    $0x2,%eax
801039b7:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
801039bd:	c9                   	leave
801039be:	c3                   	ret

801039bf <mycpu>:

//현재 실행중인 cpu 구조체 포인터를 반환 하는 함수
struct cpu*
mycpu(void)
{
801039bf:	55                   	push   %ebp
801039c0:	89 e5                	mov    %esp,%ebp
801039c2:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  //인터럽트가 켜진 상태에서 이 함수를 호출하면 안됨
  //인터럽트 중단 없이 안전하게 현재 cpu를 파악하기 위해서
  if(readeflags()&FL_IF){
801039c5:	e8 9e ff ff ff       	call   80103968 <readeflags>
801039ca:	25 00 02 00 00       	and    $0x200,%eax
801039cf:	85 c0                	test   %eax,%eax
801039d1:	74 0d                	je     801039e0 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n"); //치명적인 오류가 발생
801039d3:	83 ec 0c             	sub    $0xc,%esp
801039d6:	68 58 a7 10 80       	push   $0x8010a758
801039db:	e8 c9 cb ff ff       	call   801005a9 <panic>
  }

  //현재 cpu의 로컬 APIC ID를 읽어온다
  apicid = lapicid();
801039e0:	e8 17 f1 ff ff       	call   80102afc <lapicid>
801039e5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  //APIC ID는 CPU마다 고유하지만 연속적이진 않을 수 있음
  //따라서 모든 CPU를 순회하며 apicid가 일치하는 CPU를 찾음

  for (i = 0; i < ncpu; ++i) {
801039e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039ef:	eb 2d                	jmp    80103a1e <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f4:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801039fa:	05 80 74 19 80       	add    $0x80197480,%eax
801039ff:	0f b6 00             	movzbl (%eax),%eax
80103a02:	0f b6 c0             	movzbl %al,%eax
80103a05:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a08:	75 10                	jne    80103a1a <mycpu+0x5b>
      return &cpus[i];  //일치하는 cpu 구조체 포인터 반환
80103a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a0d:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a13:	05 80 74 19 80       	add    $0x80197480,%eax
80103a18:	eb 1b                	jmp    80103a35 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a1e:	a1 50 77 19 80       	mov    0x80197750,%eax
80103a23:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a26:	7c c9                	jl     801039f1 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a28:	83 ec 0c             	sub    $0xc,%esp
80103a2b:	68 7e a7 10 80       	push   $0x8010a77e
80103a30:	e8 74 cb ff ff       	call   801005a9 <panic>
}
80103a35:	c9                   	leave
80103a36:	c3                   	ret

80103a37 <myproc>:

// 현재 실행 중인 프로세스를 반환하는 함수
// 단 인터럽트를 비활성화 하여 스케줄링 변경 방지
struct proc*
myproc(void) {
80103a37:	55                   	push   %ebp
80103a38:	89 e5                	mov    %esp,%ebp
80103a3a:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;

  pushcli();    //인터럽트를 비활성화함(nesting 지원)
80103a3d:	e8 b2 12 00 00       	call   80104cf4 <pushcli>
  c = mycpu();  //현재 cpu를 가져옴
80103a42:	e8 78 ff ff ff       	call   801039bf <mycpu>
80103a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;  //해당 cpu에서 실행 중인 프로세스를 가져옴
80103a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();     //인터럽트 상태 복원
80103a56:	e8 e6 12 00 00       	call   80104d41 <popcli>
  
  return p;     //현재 프로세스 포인터 반환
80103a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a5e:	c9                   	leave
80103a5f:	c3                   	ret

80103a60 <allocproc>:

//정적 함수 : 새로운 프로세스를 할당하고 초기화
static struct proc*
allocproc(void)
{
80103a60:	55                   	push   %ebp
80103a61:	89 e5                	mov    %esp,%ebp
80103a63:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock); //프로세스 테이블 보호를 위해 락 획득
80103a66:	83 ec 0c             	sub    $0xc,%esp
80103a69:	68 00 42 19 80       	push   $0x80194200
80103a6e:	e8 16 11 00 00       	call   80104b89 <acquire>
80103a73:	83 c4 10             	add    $0x10,%esp

  // 프로세스 테이블에서 UNUSED 상태인 빈 프로세스를 찾음
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a76:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a7d:	eb 11                	jmp    80103a90 <allocproc+0x30>
    if(p->state == UNUSED){
80103a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a82:	8b 40 0c             	mov    0xc(%eax),%eax
80103a85:	85 c0                	test   %eax,%eax
80103a87:	74 2a                	je     80103ab3 <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a89:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
80103a90:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80103a97:	72 e6                	jb     80103a7f <allocproc+0x1f>
      goto found; //UNUSED 상태 프로세스를 찾으면 found로 점프
    }

  release(&ptable.lock);  //UNUSED 상태를 찾지 못한 경우: 실패
80103a99:	83 ec 0c             	sub    $0xc,%esp
80103a9c:	68 00 42 19 80       	push   $0x80194200
80103aa1:	e8 51 11 00 00       	call   80104bf7 <release>
80103aa6:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa9:	b8 00 00 00 00       	mov    $0x0,%eax
80103aae:	e9 f4 00 00 00       	jmp    80103ba7 <allocproc+0x147>
      goto found; //UNUSED 상태 프로세스를 찾으면 found로 점프
80103ab3:	90                   	nop

found:
  p->state = EMBRYO;    //프로세스 상태를 EMBRYO
80103ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab7:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103abe:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ac3:	8d 50 01             	lea    0x1(%eax),%edx
80103ac6:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103acc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103acf:	89 42 10             	mov    %eax,0x10(%edx)

  p->priority = 3;
80103ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad5:	c7 80 84 00 00 00 03 	movl   $0x3,0x84(%eax)
80103adc:	00 00 00 
  for (int i = 0; i < 4; i++) {
80103adf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ae6:	eb 26                	jmp    80103b0e <allocproc+0xae>
    p->ticks[i] = 0;
80103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aeb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103aee:	83 c2 20             	add    $0x20,%edx
80103af1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103af8:	00 
    p->wait_ticks[i] = 0;
80103af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103aff:	83 c2 24             	add    $0x24,%edx
80103b02:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103b09:	00 
  for (int i = 0; i < 4; i++) {
80103b0a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103b0e:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80103b12:	7e d4                	jle    80103ae8 <allocproc+0x88>
  }

  release(&ptable.lock);
80103b14:	83 ec 0c             	sub    $0xc,%esp
80103b17:	68 00 42 19 80       	push   $0x80194200
80103b1c:	e8 d6 10 00 00       	call   80104bf7 <release>
80103b21:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b24:	e8 7f ec ff ff       	call   801027a8 <kalloc>
80103b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b2c:	89 42 08             	mov    %eax,0x8(%edx)
80103b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b32:	8b 40 08             	mov    0x8(%eax),%eax
80103b35:	85 c0                	test   %eax,%eax
80103b37:	75 11                	jne    80103b4a <allocproc+0xea>
    p->state = UNUSED;
80103b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b43:	b8 00 00 00 00       	mov    $0x0,%eax
80103b48:	eb 5d                	jmp    80103ba7 <allocproc+0x147>
  }
  sp = p->kstack + KSTACKSIZE;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8b 40 08             	mov    0x8(%eax),%eax
80103b50:	05 00 10 00 00       	add    $0x1000,%eax
80103b55:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b58:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80103b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b62:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b65:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80103b69:	ba fe 61 10 80       	mov    $0x801061fe,%edx
80103b6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b71:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b73:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80103b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b7d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b83:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b86:	83 ec 04             	sub    $0x4,%esp
80103b89:	6a 14                	push   $0x14
80103b8b:	6a 00                	push   $0x0
80103b8d:	50                   	push   %eax
80103b8e:	e8 6c 12 00 00       	call   80104dff <memset>
80103b93:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b99:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b9c:	ba 29 44 10 80       	mov    $0x80104429,%edx
80103ba1:	89 50 10             	mov    %edx,0x10(%eax)


  return p;
80103ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ba7:	c9                   	leave
80103ba8:	c3                   	ret

80103ba9 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103ba9:	55                   	push   %ebp
80103baa:	89 e5                	mov    %esp,%ebp
80103bac:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103baf:	e8 ac fe ff ff       	call   80103a60 <allocproc>
80103bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bba:	a3 34 6c 19 80       	mov    %eax,0x80196c34
  if((p->pgdir = setupkvm()) == 0){
80103bbf:	e8 fe 3b 00 00       	call   801077c2 <setupkvm>
80103bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bc7:	89 42 04             	mov    %eax,0x4(%edx)
80103bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcd:	8b 40 04             	mov    0x4(%eax),%eax
80103bd0:	85 c0                	test   %eax,%eax
80103bd2:	75 0d                	jne    80103be1 <userinit+0x38>
    panic("userinit: out of memory?");
80103bd4:	83 ec 0c             	sub    $0xc,%esp
80103bd7:	68 8e a7 10 80       	push   $0x8010a78e
80103bdc:	e8 c8 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103be1:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be9:	8b 40 04             	mov    0x4(%eax),%eax
80103bec:	83 ec 04             	sub    $0x4,%esp
80103bef:	52                   	push   %edx
80103bf0:	68 0c f5 10 80       	push   $0x8010f50c
80103bf5:	50                   	push   %eax
80103bf6:	e8 84 3e 00 00       	call   80107a7f <inituvm>
80103bfb:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c01:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0a:	8b 40 18             	mov    0x18(%eax),%eax
80103c0d:	83 ec 04             	sub    $0x4,%esp
80103c10:	6a 4c                	push   $0x4c
80103c12:	6a 00                	push   $0x0
80103c14:	50                   	push   %eax
80103c15:	e8 e5 11 00 00       	call   80104dff <memset>
80103c1a:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c20:	8b 40 18             	mov    0x18(%eax),%eax
80103c23:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2c:	8b 40 18             	mov    0x18(%eax),%eax
80103c2f:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c38:	8b 50 18             	mov    0x18(%eax),%edx
80103c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3e:	8b 40 18             	mov    0x18(%eax),%eax
80103c41:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c45:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4c:	8b 50 18             	mov    0x18(%eax),%edx
80103c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c52:	8b 40 18             	mov    0x18(%eax),%eax
80103c55:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c59:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c60:	8b 40 18             	mov    0x18(%eax),%eax
80103c63:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6d:	8b 40 18             	mov    0x18(%eax),%eax
80103c70:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	8b 40 18             	mov    0x18(%eax),%eax
80103c7d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c87:	83 c0 6c             	add    $0x6c,%eax
80103c8a:	83 ec 04             	sub    $0x4,%esp
80103c8d:	6a 10                	push   $0x10
80103c8f:	68 a7 a7 10 80       	push   $0x8010a7a7
80103c94:	50                   	push   %eax
80103c95:	e8 68 13 00 00       	call   80105002 <safestrcpy>
80103c9a:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c9d:	83 ec 0c             	sub    $0xc,%esp
80103ca0:	68 b0 a7 10 80       	push   $0x8010a7b0
80103ca5:	e8 7b e8 ff ff       	call   80102525 <namei>
80103caa:	83 c4 10             	add    $0x10,%esp
80103cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cb0:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103cb3:	83 ec 0c             	sub    $0xc,%esp
80103cb6:	68 00 42 19 80       	push   $0x80194200
80103cbb:	e8 c9 0e 00 00       	call   80104b89 <acquire>
80103cc0:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ccd:	83 ec 0c             	sub    $0xc,%esp
80103cd0:	68 00 42 19 80       	push   $0x80194200
80103cd5:	e8 1d 0f 00 00       	call   80104bf7 <release>
80103cda:	83 c4 10             	add    $0x10,%esp
}
80103cdd:	90                   	nop
80103cde:	c9                   	leave
80103cdf:	c3                   	ret

80103ce0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103ce0:	55                   	push   %ebp
80103ce1:	89 e5                	mov    %esp,%ebp
80103ce3:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ce6:	e8 4c fd ff ff       	call   80103a37 <myproc>
80103ceb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf1:	8b 00                	mov    (%eax),%eax
80103cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cf6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cfa:	7e 2e                	jle    80103d2a <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cfc:	8b 55 08             	mov    0x8(%ebp),%edx
80103cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d02:	01 c2                	add    %eax,%edx
80103d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d07:	8b 40 04             	mov    0x4(%eax),%eax
80103d0a:	83 ec 04             	sub    $0x4,%esp
80103d0d:	52                   	push   %edx
80103d0e:	ff 75 f4             	push   -0xc(%ebp)
80103d11:	50                   	push   %eax
80103d12:	e8 a5 3e 00 00       	call   80107bbc <allocuvm>
80103d17:	83 c4 10             	add    $0x10,%esp
80103d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d21:	75 3b                	jne    80103d5e <growproc+0x7e>
      return -1;
80103d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d28:	eb 4f                	jmp    80103d79 <growproc+0x99>
  } else if(n < 0){
80103d2a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d2e:	79 2e                	jns    80103d5e <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d30:	8b 55 08             	mov    0x8(%ebp),%edx
80103d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d36:	01 c2                	add    %eax,%edx
80103d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3b:	8b 40 04             	mov    0x4(%eax),%eax
80103d3e:	83 ec 04             	sub    $0x4,%esp
80103d41:	52                   	push   %edx
80103d42:	ff 75 f4             	push   -0xc(%ebp)
80103d45:	50                   	push   %eax
80103d46:	e8 76 3f 00 00       	call   80107cc1 <deallocuvm>
80103d4b:	83 c4 10             	add    $0x10,%esp
80103d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d55:	75 07                	jne    80103d5e <growproc+0x7e>
      return -1;
80103d57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d5c:	eb 1b                	jmp    80103d79 <growproc+0x99>
  }
  curproc->sz = sz;
80103d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d64:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d66:	83 ec 0c             	sub    $0xc,%esp
80103d69:	ff 75 f0             	push   -0x10(%ebp)
80103d6c:	e8 6f 3b 00 00       	call   801078e0 <switchuvm>
80103d71:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d74:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d79:	c9                   	leave
80103d7a:	c3                   	ret

80103d7b <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d7b:	55                   	push   %ebp
80103d7c:	89 e5                	mov    %esp,%ebp
80103d7e:	57                   	push   %edi
80103d7f:	56                   	push   %esi
80103d80:	53                   	push   %ebx
80103d81:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d84:	e8 ae fc ff ff       	call   80103a37 <myproc>
80103d89:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d8c:	e8 cf fc ff ff       	call   80103a60 <allocproc>
80103d91:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d94:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d98:	75 0a                	jne    80103da4 <fork+0x29>
    return -1;
80103d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d9f:	e9 48 01 00 00       	jmp    80103eec <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103da4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103da7:	8b 10                	mov    (%eax),%edx
80103da9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dac:	8b 40 04             	mov    0x4(%eax),%eax
80103daf:	83 ec 08             	sub    $0x8,%esp
80103db2:	52                   	push   %edx
80103db3:	50                   	push   %eax
80103db4:	e8 a6 40 00 00       	call   80107e5f <copyuvm>
80103db9:	83 c4 10             	add    $0x10,%esp
80103dbc:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103dbf:	89 42 04             	mov    %eax,0x4(%edx)
80103dc2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc5:	8b 40 04             	mov    0x4(%eax),%eax
80103dc8:	85 c0                	test   %eax,%eax
80103dca:	75 30                	jne    80103dfc <fork+0x81>
    kfree(np->kstack);
80103dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcf:	8b 40 08             	mov    0x8(%eax),%eax
80103dd2:	83 ec 0c             	sub    $0xc,%esp
80103dd5:	50                   	push   %eax
80103dd6:	e8 33 e9 ff ff       	call   8010270e <kfree>
80103ddb:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103dde:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103de8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103deb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103df2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103df7:	e9 f0 00 00 00       	jmp    80103eec <fork+0x171>
  }
  np->sz = curproc->sz;
80103dfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dff:	8b 10                	mov    (%eax),%edx
80103e01:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e04:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e06:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e09:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e0c:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e12:	8b 48 18             	mov    0x18(%eax),%ecx
80103e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e18:	8b 40 18             	mov    0x18(%eax),%eax
80103e1b:	89 c2                	mov    %eax,%edx
80103e1d:	89 cb                	mov    %ecx,%ebx
80103e1f:	b8 13 00 00 00       	mov    $0x13,%eax
80103e24:	89 d7                	mov    %edx,%edi
80103e26:	89 de                	mov    %ebx,%esi
80103e28:	89 c1                	mov    %eax,%ecx
80103e2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e2f:	8b 40 18             	mov    0x18(%eax),%eax
80103e32:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103e39:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e40:	eb 3b                	jmp    80103e7d <fork+0x102>
    if(curproc->ofile[i])
80103e42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e48:	83 c2 08             	add    $0x8,%edx
80103e4b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e4f:	85 c0                	test   %eax,%eax
80103e51:	74 26                	je     80103e79 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e59:	83 c2 08             	add    $0x8,%edx
80103e5c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e60:	83 ec 0c             	sub    $0xc,%esp
80103e63:	50                   	push   %eax
80103e64:	e8 eb d1 ff ff       	call   80101054 <filedup>
80103e69:	83 c4 10             	add    $0x10,%esp
80103e6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e6f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e72:	83 c1 08             	add    $0x8,%ecx
80103e75:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e79:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e7d:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e81:	7e bf                	jle    80103e42 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e86:	8b 40 68             	mov    0x68(%eax),%eax
80103e89:	83 ec 0c             	sub    $0xc,%esp
80103e8c:	50                   	push   %eax
80103e8d:	e8 26 db ff ff       	call   801019b8 <idup>
80103e92:	83 c4 10             	add    $0x10,%esp
80103e95:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e98:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e9e:	8d 50 6c             	lea    0x6c(%eax),%edx
80103ea1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea4:	83 c0 6c             	add    $0x6c,%eax
80103ea7:	83 ec 04             	sub    $0x4,%esp
80103eaa:	6a 10                	push   $0x10
80103eac:	52                   	push   %edx
80103ead:	50                   	push   %eax
80103eae:	e8 4f 11 00 00       	call   80105002 <safestrcpy>
80103eb3:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103eb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eb9:	8b 40 10             	mov    0x10(%eax),%eax
80103ebc:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103ebf:	83 ec 0c             	sub    $0xc,%esp
80103ec2:	68 00 42 19 80       	push   $0x80194200
80103ec7:	e8 bd 0c 00 00       	call   80104b89 <acquire>
80103ecc:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ecf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ed2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ed9:	83 ec 0c             	sub    $0xc,%esp
80103edc:	68 00 42 19 80       	push   $0x80194200
80103ee1:	e8 11 0d 00 00       	call   80104bf7 <release>
80103ee6:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ee9:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103eef:	5b                   	pop    %ebx
80103ef0:	5e                   	pop    %esi
80103ef1:	5f                   	pop    %edi
80103ef2:	5d                   	pop    %ebp
80103ef3:	c3                   	ret

80103ef4 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ef4:	55                   	push   %ebp
80103ef5:	89 e5                	mov    %esp,%ebp
80103ef7:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103efa:	e8 38 fb ff ff       	call   80103a37 <myproc>
80103eff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103f02:	a1 34 6c 19 80       	mov    0x80196c34,%eax
80103f07:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f0a:	75 0d                	jne    80103f19 <exit+0x25>
    panic("init exiting");
80103f0c:	83 ec 0c             	sub    $0xc,%esp
80103f0f:	68 b2 a7 10 80       	push   $0x8010a7b2
80103f14:	e8 90 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103f19:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f20:	eb 3f                	jmp    80103f61 <exit+0x6d>
    if(curproc->ofile[fd]){
80103f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f28:	83 c2 08             	add    $0x8,%edx
80103f2b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f2f:	85 c0                	test   %eax,%eax
80103f31:	74 2a                	je     80103f5d <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103f33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f36:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f39:	83 c2 08             	add    $0x8,%edx
80103f3c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f40:	83 ec 0c             	sub    $0xc,%esp
80103f43:	50                   	push   %eax
80103f44:	e8 5c d1 ff ff       	call   801010a5 <fileclose>
80103f49:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f52:	83 c2 08             	add    $0x8,%edx
80103f55:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f5c:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f5d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f61:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f65:	7e bb                	jle    80103f22 <exit+0x2e>
    }
  }

  begin_op();
80103f67:	e8 d2 f0 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
80103f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f6f:	8b 40 68             	mov    0x68(%eax),%eax
80103f72:	83 ec 0c             	sub    $0xc,%esp
80103f75:	50                   	push   %eax
80103f76:	e8 d8 db ff ff       	call   80101b53 <iput>
80103f7b:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f7e:	e8 47 f1 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80103f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f86:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f8d:	83 ec 0c             	sub    $0xc,%esp
80103f90:	68 00 42 19 80       	push   $0x80194200
80103f95:	e8 ef 0b 00 00       	call   80104b89 <acquire>
80103f9a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa0:	8b 40 14             	mov    0x14(%eax),%eax
80103fa3:	83 ec 0c             	sub    $0xc,%esp
80103fa6:	50                   	push   %eax
80103fa7:	e8 6a 05 00 00       	call   80104516 <wakeup1>
80103fac:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103faf:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fb6:	eb 3a                	jmp    80103ff2 <exit+0xfe>
    if(p->parent == curproc){
80103fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fbb:	8b 40 14             	mov    0x14(%eax),%eax
80103fbe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fc1:	75 28                	jne    80103feb <exit+0xf7>
      p->parent = initproc;
80103fc3:	8b 15 34 6c 19 80    	mov    0x80196c34,%edx
80103fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcc:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd2:	8b 40 0c             	mov    0xc(%eax),%eax
80103fd5:	83 f8 05             	cmp    $0x5,%eax
80103fd8:	75 11                	jne    80103feb <exit+0xf7>
        wakeup1(initproc);
80103fda:	a1 34 6c 19 80       	mov    0x80196c34,%eax
80103fdf:	83 ec 0c             	sub    $0xc,%esp
80103fe2:	50                   	push   %eax
80103fe3:	e8 2e 05 00 00       	call   80104516 <wakeup1>
80103fe8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103feb:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
80103ff2:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
80103ff9:	72 bd                	jb     80103fb8 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103ffb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ffe:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104005:	e8 2c 03 00 00       	call   80104336 <sched>
  panic("zombie exit");
8010400a:	83 ec 0c             	sub    $0xc,%esp
8010400d:	68 bf a7 10 80       	push   $0x8010a7bf
80104012:	e8 92 c5 ff ff       	call   801005a9 <panic>

80104017 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104017:	55                   	push   %ebp
80104018:	89 e5                	mov    %esp,%ebp
8010401a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010401d:	e8 15 fa ff ff       	call   80103a37 <myproc>
80104022:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104025:	83 ec 0c             	sub    $0xc,%esp
80104028:	68 00 42 19 80       	push   $0x80194200
8010402d:	e8 57 0b 00 00       	call   80104b89 <acquire>
80104032:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104035:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010403c:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104043:	e9 a4 00 00 00       	jmp    801040ec <wait+0xd5>
      if(p->parent != curproc)
80104048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404b:	8b 40 14             	mov    0x14(%eax),%eax
8010404e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104051:	0f 85 8d 00 00 00    	jne    801040e4 <wait+0xcd>
        continue;
      havekids = 1;
80104057:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010405e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104061:	8b 40 0c             	mov    0xc(%eax),%eax
80104064:	83 f8 05             	cmp    $0x5,%eax
80104067:	75 7c                	jne    801040e5 <wait+0xce>
        // Found one.
        pid = p->pid;
80104069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406c:	8b 40 10             	mov    0x10(%eax),%eax
8010406f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104075:	8b 40 08             	mov    0x8(%eax),%eax
80104078:	83 ec 0c             	sub    $0xc,%esp
8010407b:	50                   	push   %eax
8010407c:	e8 8d e6 ff ff       	call   8010270e <kfree>
80104081:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104087:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010408e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104091:	8b 40 04             	mov    0x4(%eax),%eax
80104094:	83 ec 0c             	sub    $0xc,%esp
80104097:	50                   	push   %eax
80104098:	e8 e8 3c 00 00       	call   80107d85 <freevm>
8010409d:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801040a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ad:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801040b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b7:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801040bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040be:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801040c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801040cf:	83 ec 0c             	sub    $0xc,%esp
801040d2:	68 00 42 19 80       	push   $0x80194200
801040d7:	e8 1b 0b 00 00       	call   80104bf7 <release>
801040dc:	83 c4 10             	add    $0x10,%esp
        return pid;
801040df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040e2:	eb 54                	jmp    80104138 <wait+0x121>
        continue;
801040e4:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040e5:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
801040ec:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
801040f3:	0f 82 4f ff ff ff    	jb     80104048 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040fd:	74 0a                	je     80104109 <wait+0xf2>
801040ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104102:	8b 40 24             	mov    0x24(%eax),%eax
80104105:	85 c0                	test   %eax,%eax
80104107:	74 17                	je     80104120 <wait+0x109>
      release(&ptable.lock);
80104109:	83 ec 0c             	sub    $0xc,%esp
8010410c:	68 00 42 19 80       	push   $0x80194200
80104111:	e8 e1 0a 00 00       	call   80104bf7 <release>
80104116:	83 c4 10             	add    $0x10,%esp
      return -1;
80104119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010411e:	eb 18                	jmp    80104138 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104120:	83 ec 08             	sub    $0x8,%esp
80104123:	68 00 42 19 80       	push   $0x80194200
80104128:	ff 75 ec             	push   -0x14(%ebp)
8010412b:	e8 3f 03 00 00       	call   8010446f <sleep>
80104130:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104133:	e9 fd fe ff ff       	jmp    80104035 <wait+0x1e>
  }
}
80104138:	c9                   	leave
80104139:	c3                   	ret

8010413a <scheduler>:
//  - eventually that process transfers control
//      via swtch back to the scheduler.

void
scheduler(void)
{
8010413a:	55                   	push   %ebp
8010413b:	89 e5                	mov    %esp,%ebp
8010413d:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104140:	e8 7a f8 ff ff       	call   801039bf <mycpu>
80104145:	89 45 e8             	mov    %eax,-0x18(%ebp)
  c->proc = 0;
80104148:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010414b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104152:	00 00 00 

  for(;;){
    sti();
80104155:	e8 25 f8 ff ff       	call   8010397f <sti>
    acquire(&ptable.lock);
8010415a:	83 ec 0c             	sub    $0xc,%esp
8010415d:	68 00 42 19 80       	push   $0x80194200
80104162:	e8 22 0a 00 00       	call   80104b89 <acquire>
80104167:	83 c4 10             	add    $0x10,%esp

    if (c->sched_policy == 1) {
8010416a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010416d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104173:	83 f8 01             	cmp    $0x1,%eax
80104176:	0f 85 2f 01 00 00    	jne    801042ab <scheduler+0x171>
      // MLFQ: 높은 우선순위부터 RUNNABLE 프로세스 탐색
      struct proc *selected = 0;
8010417c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      for (int prio = 3; prio >= 0; prio--) {
80104183:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
8010418a:	eb 3e                	jmp    801041ca <scheduler+0x90>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010418c:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104193:	eb 28                	jmp    801041bd <scheduler+0x83>
          if (p->state == RUNNABLE && p->priority == prio) {
80104195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104198:	8b 40 0c             	mov    0xc(%eax),%eax
8010419b:	83 f8 03             	cmp    $0x3,%eax
8010419e:	75 16                	jne    801041b6 <scheduler+0x7c>
801041a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a3:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801041a9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041ac:	75 08                	jne    801041b6 <scheduler+0x7c>
            selected = p;
801041ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
            goto found;
801041b4:	eb 1b                	jmp    801041d1 <scheduler+0x97>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041b6:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
801041bd:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
801041c4:	72 cf                	jb     80104195 <scheduler+0x5b>
      for (int prio = 3; prio >= 0; prio--) {
801041c6:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801041ca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801041ce:	79 bc                	jns    8010418c <scheduler+0x52>
          }
        }
      }
    found:
801041d0:	90                   	nop
      if (selected) {
801041d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041d5:	0f 84 46 01 00 00    	je     80104321 <scheduler+0x1e7>
        c->proc = selected;
801041db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041e1:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(selected);
801041e7:	83 ec 0c             	sub    $0xc,%esp
801041ea:	ff 75 f0             	push   -0x10(%ebp)
801041ed:	e8 ee 36 00 00       	call   801078e0 <switchuvm>
801041f2:	83 c4 10             	add    $0x10,%esp
        selected->state = RUNNING;
801041f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041f8:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        // 한 번만 swtch, 실제 시간은 타이머 인터럽트에서 틱 관리
        swtch(&(c->scheduler), selected->context);
801041ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104202:	8b 40 1c             	mov    0x1c(%eax),%eax
80104205:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104208:	83 c2 04             	add    $0x4,%edx
8010420b:	83 ec 08             	sub    $0x8,%esp
8010420e:	50                   	push   %eax
8010420f:	52                   	push   %edx
80104210:	e8 5f 0e 00 00       	call   80105074 <swtch>
80104215:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104218:	e8 aa 36 00 00       	call   801078c7 <switchkvm>

        // 타임슬라이스 다 썼으면 demote
        int slice[4] = {0, 32, 16, 8};
8010421d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
80104224:	c7 45 d8 20 00 00 00 	movl   $0x20,-0x28(%ebp)
8010422b:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
80104232:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
        int prio = selected->priority;
80104239:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010423c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104242:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (prio > 0 && selected->ticks[prio] >= slice[prio]) {
80104245:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104249:	7e 3e                	jle    80104289 <scheduler+0x14f>
8010424b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010424e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104251:	83 c2 20             	add    $0x20,%edx
80104254:	8b 54 90 08          	mov    0x8(%eax,%edx,4),%edx
80104258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010425b:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
8010425f:	39 c2                	cmp    %eax,%edx
80104261:	7c 26                	jl     80104289 <scheduler+0x14f>
          selected->priority--;
80104263:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104266:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010426c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010426f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104272:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
          selected->ticks[prio] = 0;
80104278:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010427b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010427e:	83 c2 20             	add    $0x20,%edx
80104281:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104288:	00 
        }

        // 다른 프로세스 대기 시간 증가 + boost 체크
        update_wait_ticks(selected);
80104289:	83 ec 0c             	sub    $0xc,%esp
8010428c:	ff 75 f0             	push   -0x10(%ebp)
8010428f:	e8 15 06 00 00       	call   801048a9 <update_wait_ticks>
80104294:	83 c4 10             	add    $0x10,%esp
        priority_boost();
80104297:	e8 84 06 00 00       	call   80104920 <priority_boost>

        c->proc = 0;
8010429c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010429f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042a6:	00 00 00 
801042a9:	eb 76                	jmp    80104321 <scheduler+0x1e7>
      }

    } else {
      // 기본 Round-Robin 스케줄링
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042ab:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801042b2:	eb 64                	jmp    80104318 <scheduler+0x1de>
        if(p->state != RUNNABLE)
801042b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b7:	8b 40 0c             	mov    0xc(%eax),%eax
801042ba:	83 f8 03             	cmp    $0x3,%eax
801042bd:	75 51                	jne    80104310 <scheduler+0x1d6>
          continue;

        c->proc = p;
801042bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042c5:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801042cb:	83 ec 0c             	sub    $0xc,%esp
801042ce:	ff 75 f4             	push   -0xc(%ebp)
801042d1:	e8 0a 36 00 00       	call   801078e0 <switchuvm>
801042d6:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801042d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042dc:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
801042e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e6:	8b 40 1c             	mov    0x1c(%eax),%eax
801042e9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801042ec:	83 c2 04             	add    $0x4,%edx
801042ef:	83 ec 08             	sub    $0x8,%esp
801042f2:	50                   	push   %eax
801042f3:	52                   	push   %edx
801042f4:	e8 7b 0d 00 00       	call   80105074 <swtch>
801042f9:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801042fc:	e8 c6 35 00 00       	call   801078c7 <switchkvm>

        c->proc = 0;
80104301:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104304:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010430b:	00 00 00 
8010430e:	eb 01                	jmp    80104311 <scheduler+0x1d7>
          continue;
80104310:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104311:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
80104318:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
8010431f:	72 93                	jb     801042b4 <scheduler+0x17a>
      }
    }

    release(&ptable.lock);
80104321:	83 ec 0c             	sub    $0xc,%esp
80104324:	68 00 42 19 80       	push   $0x80194200
80104329:	e8 c9 08 00 00       	call   80104bf7 <release>
8010432e:	83 c4 10             	add    $0x10,%esp
    sti();
80104331:	e9 1f fe ff ff       	jmp    80104155 <scheduler+0x1b>

80104336 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104336:	55                   	push   %ebp
80104337:	89 e5                	mov    %esp,%ebp
80104339:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();    //현재 CPU에서 실행중인 프로세스를 얻음
8010433c:	e8 f6 f6 ff ff       	call   80103a37 <myproc>
80104341:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //ptable.lock이 잡혀있지 않을때
  if(!holding(&ptable.lock))
80104344:	83 ec 0c             	sub    $0xc,%esp
80104347:	68 00 42 19 80       	push   $0x80194200
8010434c:	e8 73 09 00 00       	call   80104cc4 <holding>
80104351:	83 c4 10             	add    $0x10,%esp
80104354:	85 c0                	test   %eax,%eax
80104356:	75 0d                	jne    80104365 <sched+0x2f>
    panic("sched ptable.lock");
80104358:	83 ec 0c             	sub    $0xc,%esp
8010435b:	68 cb a7 10 80       	push   $0x8010a7cb
80104360:	e8 44 c2 ff ff       	call   801005a9 <panic>

  //현재 cpu의 인터럽트 차단회수가 1이 아니면 에러
  if(mycpu()->ncli != 1)
80104365:	e8 55 f6 ff ff       	call   801039bf <mycpu>
8010436a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104370:	83 f8 01             	cmp    $0x1,%eax
80104373:	74 0d                	je     80104382 <sched+0x4c>
    panic("sched locks");
80104375:	83 ec 0c             	sub    $0xc,%esp
80104378:	68 dd a7 10 80       	push   $0x8010a7dd
8010437d:	e8 27 c2 ff ff       	call   801005a9 <panic>

  //현재 프로세스 상태가 RUNNING이면 에러
  //RUNNABLE , SLEEPING , ZOMBIE 의 상태어야 전환이 가능
  if(p->state == RUNNING)
80104382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104385:	8b 40 0c             	mov    0xc(%eax),%eax
80104388:	83 f8 04             	cmp    $0x4,%eax
8010438b:	75 0d                	jne    8010439a <sched+0x64>
    panic("sched running");
8010438d:	83 ec 0c             	sub    $0xc,%esp
80104390:	68 e9 a7 10 80       	push   $0x8010a7e9
80104395:	e8 0f c2 ff ff       	call   801005a9 <panic>

  //인터럽트가 활성화 된 상태일 경우 에러
  //전환중에는 인터럽트가 꺼져있어야함
  if(readeflags()&FL_IF)
8010439a:	e8 c9 f5 ff ff       	call   80103968 <readeflags>
8010439f:	25 00 02 00 00       	and    $0x200,%eax
801043a4:	85 c0                	test   %eax,%eax
801043a6:	74 0d                	je     801043b5 <sched+0x7f>
    panic("sched interruptible");
801043a8:	83 ec 0c             	sub    $0xc,%esp
801043ab:	68 f7 a7 10 80       	push   $0x8010a7f7
801043b0:	e8 f4 c1 ff ff       	call   801005a9 <panic>

  intena = mycpu()->intena; //현재 CPU의 언터럽트  활성화 상태를 저장해둔다
801043b5:	e8 05 f6 ff ff       	call   801039bf <mycpu>
801043ba:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  swtch(&p->context, mycpu()->scheduler); //전환을 수행 , 현재 프로세스의 context를 저장하고 CPU가 가진 scheduler context로 전환
801043c3:	e8 f7 f5 ff ff       	call   801039bf <mycpu>
801043c8:	8b 40 04             	mov    0x4(%eax),%eax
801043cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ce:	83 c2 1c             	add    $0x1c,%edx
801043d1:	83 ec 08             	sub    $0x8,%esp
801043d4:	50                   	push   %eax
801043d5:	52                   	push   %edx
801043d6:	e8 99 0c 00 00       	call   80105074 <swtch>
801043db:	83 c4 10             	add    $0x10,%esp

  mycpu()->intena = intena; //스케줄링이 끝난뒤 원래 인터럽트 상태로 복원
801043de:	e8 dc f5 ff ff       	call   801039bf <mycpu>
801043e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043e6:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801043ec:	90                   	nop
801043ed:	c9                   	leave
801043ee:	c3                   	ret

801043ef <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801043ef:	55                   	push   %ebp
801043f0:	89 e5                	mov    %esp,%ebp
801043f2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801043f5:	83 ec 0c             	sub    $0xc,%esp
801043f8:	68 00 42 19 80       	push   $0x80194200
801043fd:	e8 87 07 00 00       	call   80104b89 <acquire>
80104402:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104405:	e8 2d f6 ff ff       	call   80103a37 <myproc>
8010440a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104411:	e8 20 ff ff ff       	call   80104336 <sched>
  release(&ptable.lock);
80104416:	83 ec 0c             	sub    $0xc,%esp
80104419:	68 00 42 19 80       	push   $0x80194200
8010441e:	e8 d4 07 00 00       	call   80104bf7 <release>
80104423:	83 c4 10             	add    $0x10,%esp
}
80104426:	90                   	nop
80104427:	c9                   	leave
80104428:	c3                   	ret

80104429 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104429:	55                   	push   %ebp
8010442a:	89 e5                	mov    %esp,%ebp
8010442c:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010442f:	83 ec 0c             	sub    $0xc,%esp
80104432:	68 00 42 19 80       	push   $0x80194200
80104437:	e8 bb 07 00 00       	call   80104bf7 <release>
8010443c:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010443f:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104444:	85 c0                	test   %eax,%eax
80104446:	74 24                	je     8010446c <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104448:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010444f:	00 00 00 
    iinit(ROOTDEV);
80104452:	83 ec 0c             	sub    $0xc,%esp
80104455:	6a 01                	push   $0x1
80104457:	e8 25 d2 ff ff       	call   80101681 <iinit>
8010445c:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010445f:	83 ec 0c             	sub    $0xc,%esp
80104462:	6a 01                	push   $0x1
80104464:	e8 b6 e9 ff ff       	call   80102e1f <initlog>
80104469:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010446c:	90                   	nop
8010446d:	c9                   	leave
8010446e:	c3                   	ret

8010446f <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010446f:	55                   	push   %ebp
80104470:	89 e5                	mov    %esp,%ebp
80104472:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104475:	e8 bd f5 ff ff       	call   80103a37 <myproc>
8010447a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010447d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104481:	75 0d                	jne    80104490 <sleep+0x21>
    panic("sleep");
80104483:	83 ec 0c             	sub    $0xc,%esp
80104486:	68 0b a8 10 80       	push   $0x8010a80b
8010448b:	e8 19 c1 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104490:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104494:	75 0d                	jne    801044a3 <sleep+0x34>
    panic("sleep without lk");
80104496:	83 ec 0c             	sub    $0xc,%esp
80104499:	68 11 a8 10 80       	push   $0x8010a811
8010449e:	e8 06 c1 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044a3:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801044aa:	74 1e                	je     801044ca <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801044ac:	83 ec 0c             	sub    $0xc,%esp
801044af:	68 00 42 19 80       	push   $0x80194200
801044b4:	e8 d0 06 00 00       	call   80104b89 <acquire>
801044b9:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044bc:	83 ec 0c             	sub    $0xc,%esp
801044bf:	ff 75 0c             	push   0xc(%ebp)
801044c2:	e8 30 07 00 00       	call   80104bf7 <release>
801044c7:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801044ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cd:	8b 55 08             	mov    0x8(%ebp),%edx
801044d0:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801044dd:	e8 54 fe ff ff       	call   80104336 <sched>

  // Tidy up.
  p->chan = 0;
801044e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e5:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801044ec:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801044f3:	74 1e                	je     80104513 <sleep+0xa4>
    release(&ptable.lock);
801044f5:	83 ec 0c             	sub    $0xc,%esp
801044f8:	68 00 42 19 80       	push   $0x80194200
801044fd:	e8 f5 06 00 00       	call   80104bf7 <release>
80104502:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104505:	83 ec 0c             	sub    $0xc,%esp
80104508:	ff 75 0c             	push   0xc(%ebp)
8010450b:	e8 79 06 00 00       	call   80104b89 <acquire>
80104510:	83 c4 10             	add    $0x10,%esp
  }
}
80104513:	90                   	nop
80104514:	c9                   	leave
80104515:	c3                   	ret

80104516 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104516:	55                   	push   %ebp
80104517:	89 e5                	mov    %esp,%ebp
80104519:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010451c:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104523:	eb 27                	jmp    8010454c <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104525:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104528:	8b 40 0c             	mov    0xc(%eax),%eax
8010452b:	83 f8 02             	cmp    $0x2,%eax
8010452e:	75 15                	jne    80104545 <wakeup1+0x2f>
80104530:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104533:	8b 40 20             	mov    0x20(%eax),%eax
80104536:	39 45 08             	cmp    %eax,0x8(%ebp)
80104539:	75 0a                	jne    80104545 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010453b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010453e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104545:	81 45 fc a8 00 00 00 	addl   $0xa8,-0x4(%ebp)
8010454c:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
80104553:	72 d0                	jb     80104525 <wakeup1+0xf>
}
80104555:	90                   	nop
80104556:	90                   	nop
80104557:	c9                   	leave
80104558:	c3                   	ret

80104559 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104559:	55                   	push   %ebp
8010455a:	89 e5                	mov    %esp,%ebp
8010455c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010455f:	83 ec 0c             	sub    $0xc,%esp
80104562:	68 00 42 19 80       	push   $0x80194200
80104567:	e8 1d 06 00 00       	call   80104b89 <acquire>
8010456c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010456f:	83 ec 0c             	sub    $0xc,%esp
80104572:	ff 75 08             	push   0x8(%ebp)
80104575:	e8 9c ff ff ff       	call   80104516 <wakeup1>
8010457a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010457d:	83 ec 0c             	sub    $0xc,%esp
80104580:	68 00 42 19 80       	push   $0x80194200
80104585:	e8 6d 06 00 00       	call   80104bf7 <release>
8010458a:	83 c4 10             	add    $0x10,%esp
}
8010458d:	90                   	nop
8010458e:	c9                   	leave
8010458f:	c3                   	ret

80104590 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104590:	55                   	push   %ebp
80104591:	89 e5                	mov    %esp,%ebp
80104593:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104596:	83 ec 0c             	sub    $0xc,%esp
80104599:	68 00 42 19 80       	push   $0x80194200
8010459e:	e8 e6 05 00 00       	call   80104b89 <acquire>
801045a3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045a6:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801045ad:	eb 48                	jmp    801045f7 <kill+0x67>
    if(p->pid == pid){
801045af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b2:	8b 40 10             	mov    0x10(%eax),%eax
801045b5:	39 45 08             	cmp    %eax,0x8(%ebp)
801045b8:	75 36                	jne    801045f0 <kill+0x60>
      p->killed = 1;
801045ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c7:	8b 40 0c             	mov    0xc(%eax),%eax
801045ca:	83 f8 02             	cmp    $0x2,%eax
801045cd:	75 0a                	jne    801045d9 <kill+0x49>
        p->state = RUNNABLE;
801045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801045d9:	83 ec 0c             	sub    $0xc,%esp
801045dc:	68 00 42 19 80       	push   $0x80194200
801045e1:	e8 11 06 00 00       	call   80104bf7 <release>
801045e6:	83 c4 10             	add    $0x10,%esp
      return 0;
801045e9:	b8 00 00 00 00       	mov    $0x0,%eax
801045ee:	eb 25                	jmp    80104615 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045f0:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
801045f7:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
801045fe:	72 af                	jb     801045af <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104600:	83 ec 0c             	sub    $0xc,%esp
80104603:	68 00 42 19 80       	push   $0x80194200
80104608:	e8 ea 05 00 00       	call   80104bf7 <release>
8010460d:	83 c4 10             	add    $0x10,%esp
  return -1;
80104610:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104615:	c9                   	leave
80104616:	c3                   	ret

80104617 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104617:	55                   	push   %ebp
80104618:	89 e5                	mov    %esp,%ebp
8010461a:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010461d:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104624:	e9 da 00 00 00       	jmp    80104703 <procdump+0xec>
    if(p->state == UNUSED)
80104629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010462c:	8b 40 0c             	mov    0xc(%eax),%eax
8010462f:	85 c0                	test   %eax,%eax
80104631:	0f 84 c4 00 00 00    	je     801046fb <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010463a:	8b 40 0c             	mov    0xc(%eax),%eax
8010463d:	83 f8 05             	cmp    $0x5,%eax
80104640:	77 23                	ja     80104665 <procdump+0x4e>
80104642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104645:	8b 40 0c             	mov    0xc(%eax),%eax
80104648:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010464f:	85 c0                	test   %eax,%eax
80104651:	74 12                	je     80104665 <procdump+0x4e>
      state = states[p->state];
80104653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104656:	8b 40 0c             	mov    0xc(%eax),%eax
80104659:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104660:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104663:	eb 07                	jmp    8010466c <procdump+0x55>
    else
      state = "???";
80104665:	c7 45 ec 22 a8 10 80 	movl   $0x8010a822,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010466c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010466f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104675:	8b 40 10             	mov    0x10(%eax),%eax
80104678:	52                   	push   %edx
80104679:	ff 75 ec             	push   -0x14(%ebp)
8010467c:	50                   	push   %eax
8010467d:	68 26 a8 10 80       	push   $0x8010a826
80104682:	e8 6d bd ff ff       	call   801003f4 <cprintf>
80104687:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010468a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010468d:	8b 40 0c             	mov    0xc(%eax),%eax
80104690:	83 f8 02             	cmp    $0x2,%eax
80104693:	75 54                	jne    801046e9 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104695:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104698:	8b 40 1c             	mov    0x1c(%eax),%eax
8010469b:	8b 40 0c             	mov    0xc(%eax),%eax
8010469e:	83 c0 08             	add    $0x8,%eax
801046a1:	89 c2                	mov    %eax,%edx
801046a3:	83 ec 08             	sub    $0x8,%esp
801046a6:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046a9:	50                   	push   %eax
801046aa:	52                   	push   %edx
801046ab:	e8 99 05 00 00       	call   80104c49 <getcallerpcs>
801046b0:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046ba:	eb 1c                	jmp    801046d8 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bf:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046c3:	83 ec 08             	sub    $0x8,%esp
801046c6:	50                   	push   %eax
801046c7:	68 2f a8 10 80       	push   $0x8010a82f
801046cc:	e8 23 bd ff ff       	call   801003f4 <cprintf>
801046d1:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046d8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801046dc:	7f 0b                	jg     801046e9 <procdump+0xd2>
801046de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046e5:	85 c0                	test   %eax,%eax
801046e7:	75 d3                	jne    801046bc <procdump+0xa5>
    }
    cprintf("\n");
801046e9:	83 ec 0c             	sub    $0xc,%esp
801046ec:	68 33 a8 10 80       	push   $0x8010a833
801046f1:	e8 fe bc ff ff       	call   801003f4 <cprintf>
801046f6:	83 c4 10             	add    $0x10,%esp
801046f9:	eb 01                	jmp    801046fc <procdump+0xe5>
      continue;
801046fb:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046fc:	81 45 f0 a8 00 00 00 	addl   $0xa8,-0x10(%ebp)
80104703:	81 7d f0 34 6c 19 80 	cmpl   $0x80196c34,-0x10(%ebp)
8010470a:	0f 82 19 ff ff ff    	jb     80104629 <procdump+0x12>
  }
}
80104710:	90                   	nop
80104711:	90                   	nop
80104712:	c9                   	leave
80104713:	c3                   	ret

80104714 <sys_getpinfo>:

#include "pstat.h"

int
sys_getpinfo(void)
{
80104714:	55                   	push   %ebp
80104715:	89 e5                	mov    %esp,%ebp
80104717:	53                   	push   %ebx
80104718:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;

  // 유저 포인터를 커널에서 접근 가능하도록 변환
  if (argptr(0, (void*)&ps, sizeof(*ps)) < 0)
8010471b:	83 ec 04             	sub    $0x4,%esp
8010471e:	68 00 0c 00 00       	push   $0xc00
80104723:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104726:	50                   	push   %eax
80104727:	6a 00                	push   $0x0
80104729:	e8 29 0a 00 00       	call   80105157 <argptr>
8010472e:	83 c4 10             	add    $0x10,%esp
80104731:	85 c0                	test   %eax,%eax
80104733:	79 0a                	jns    8010473f <sys_getpinfo+0x2b>
    return -1;
80104735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010473a:	e9 0e 01 00 00       	jmp    8010484d <sys_getpinfo+0x139>

  acquire(&ptable.lock);
8010473f:	83 ec 0c             	sub    $0xc,%esp
80104742:	68 00 42 19 80       	push   $0x80194200
80104747:	e8 3d 04 00 00       	call   80104b89 <acquire>
8010474c:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
8010474f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104756:	e9 d3 00 00 00       	jmp    8010482e <sys_getpinfo+0x11a>
    struct proc *p = &ptable.proc[i];
8010475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475e:	69 c0 a8 00 00 00    	imul   $0xa8,%eax,%eax
80104764:	83 c0 30             	add    $0x30,%eax
80104767:	05 00 42 19 80       	add    $0x80194200,%eax
8010476c:	83 c0 04             	add    $0x4,%eax
8010476f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ps->inuse[i] = (p->state != UNUSED);
80104772:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104775:	8b 40 0c             	mov    0xc(%eax),%eax
80104778:	85 c0                	test   %eax,%eax
8010477a:	0f 95 c2             	setne  %dl
8010477d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104780:	0f b6 ca             	movzbl %dl,%ecx
80104783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104786:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    ps->pid[i] = p->pid;
80104789:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010478c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010478f:	8b 52 10             	mov    0x10(%edx),%edx
80104792:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104795:	83 c1 40             	add    $0x40,%ecx
80104798:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->priority[i] = p->priority;
8010479b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010479e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047a1:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
801047a7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047aa:	83 e9 80             	sub    $0xffffff80,%ecx
801047ad:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    ps->state[i] = p->state;
801047b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047b3:	8b 50 0c             	mov    0xc(%eax),%edx
801047b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047b9:	89 d1                	mov    %edx,%ecx
801047bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047be:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801047c4:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    for (int j = 0; j < 4; j++) {
801047c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047ce:	eb 54                	jmp    80104824 <sys_getpinfo+0x110>
      ps->ticks[i][j] = p->ticks[j];
801047d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047d6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801047d9:	83 c1 20             	add    $0x20,%ecx
801047dc:	8b 54 8a 08          	mov    0x8(%edx,%ecx,4),%edx
801047e0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047e3:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801047ea:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801047ed:	01 d9                	add    %ebx,%ecx
801047ef:	81 c1 00 01 00 00    	add    $0x100,%ecx
801047f5:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j];
801047f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104801:	83 c1 24             	add    $0x24,%ecx
80104804:	8b 54 8a 08          	mov    0x8(%edx,%ecx,4),%edx
80104808:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010480b:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104812:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104815:	01 d9                	add    %ebx,%ecx
80104817:	81 c1 00 02 00 00    	add    $0x200,%ecx
8010481d:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104820:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104824:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104828:	7e a6                	jle    801047d0 <sys_getpinfo+0xbc>
  for (int i = 0; i < NPROC; i++) {
8010482a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010482e:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104832:	0f 8e 23 ff ff ff    	jle    8010475b <sys_getpinfo+0x47>
    }
  }
  release(&ptable.lock);
80104838:	83 ec 0c             	sub    $0xc,%esp
8010483b:	68 00 42 19 80       	push   $0x80194200
80104840:	e8 b2 03 00 00       	call   80104bf7 <release>
80104845:	83 c4 10             	add    $0x10,%esp
  return 0;
80104848:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010484d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104850:	c9                   	leave
80104851:	c3                   	ret

80104852 <sys_setSchedPolicy>:

int
sys_setSchedPolicy(void)
{
80104852:	55                   	push   %ebp
80104853:	89 e5                	mov    %esp,%ebp
80104855:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if (argint(0, &policy) < 0)
80104858:	83 ec 08             	sub    $0x8,%esp
8010485b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010485e:	50                   	push   %eax
8010485f:	6a 00                	push   $0x0
80104861:	e8 c4 08 00 00       	call   8010512a <argint>
80104866:	83 c4 10             	add    $0x10,%esp
80104869:	85 c0                	test   %eax,%eax
8010486b:	79 07                	jns    80104874 <sys_setSchedPolicy+0x22>
    return -1;
8010486d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104872:	eb 33                	jmp    801048a7 <sys_setSchedPolicy+0x55>
  if (policy < 0 || policy > 3)
80104874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104877:	85 c0                	test   %eax,%eax
80104879:	78 08                	js     80104883 <sys_setSchedPolicy+0x31>
8010487b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487e:	83 f8 03             	cmp    $0x3,%eax
80104881:	7e 07                	jle    8010488a <sys_setSchedPolicy+0x38>
    return -1;
80104883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104888:	eb 1d                	jmp    801048a7 <sys_setSchedPolicy+0x55>

  cli();  // 인터럽트 끄기
8010488a:	e8 e9 f0 ff ff       	call   80103978 <cli>
  mycpu()->sched_policy = policy;
8010488f:	e8 2b f1 ff ff       	call   801039bf <mycpu>
80104894:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104897:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  sti();  // 다시 켜기
8010489d:	e8 dd f0 ff ff       	call   8010397f <sti>

  return 0;
801048a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048a7:	c9                   	leave
801048a8:	c3                   	ret

801048a9 <update_wait_ticks>:


void
update_wait_ticks(struct proc *running)
{
801048a9:	55                   	push   %ebp
801048aa:	89 e5                	mov    %esp,%ebp
801048ac:	83 ec 10             	sub    $0x10,%esp
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801048af:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801048b6:	eb 5b                	jmp    80104913 <update_wait_ticks+0x6a>
    if (p == running) continue;
801048b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048bb:	3b 45 08             	cmp    0x8(%ebp),%eax
801048be:	74 48                	je     80104908 <update_wait_ticks+0x5f>
    if (p->state == RUNNABLE) {
801048c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048c3:	8b 40 0c             	mov    0xc(%eax),%eax
801048c6:	83 f8 03             	cmp    $0x3,%eax
801048c9:	75 41                	jne    8010490c <update_wait_ticks+0x63>
      if (p->priority < 0 || p->priority > 3)
801048cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048ce:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801048d4:	85 c0                	test   %eax,%eax
801048d6:	78 33                	js     8010490b <update_wait_ticks+0x62>
801048d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048db:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801048e1:	83 f8 03             	cmp    $0x3,%eax
801048e4:	7f 25                	jg     8010490b <update_wait_ticks+0x62>
         continue; // 잘못된 priority 값이면 무시
      p->wait_ticks[p->priority]++;
801048e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048e9:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801048ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801048f2:	8d 48 24             	lea    0x24(%eax),%ecx
801048f5:	8b 54 8a 08          	mov    0x8(%edx,%ecx,4),%edx
801048f9:	8d 4a 01             	lea    0x1(%edx),%ecx
801048fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801048ff:	83 c0 24             	add    $0x24,%eax
80104902:	89 4c 82 08          	mov    %ecx,0x8(%edx,%eax,4)
80104906:	eb 04                	jmp    8010490c <update_wait_ticks+0x63>
    if (p == running) continue;
80104908:	90                   	nop
80104909:	eb 01                	jmp    8010490c <update_wait_ticks+0x63>
         continue; // 잘못된 priority 값이면 무시
8010490b:	90                   	nop
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010490c:	81 45 fc a8 00 00 00 	addl   $0xa8,-0x4(%ebp)
80104913:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
8010491a:	72 9c                	jb     801048b8 <update_wait_ticks+0xf>
    }
  }
}
8010491c:	90                   	nop
8010491d:	90                   	nop
8010491e:	c9                   	leave
8010491f:	c3                   	ret

80104920 <priority_boost>:

void
priority_boost(void)
{
80104920:	55                   	push   %ebp
80104921:	89 e5                	mov    %esp,%ebp
80104923:	83 ec 20             	sub    $0x20,%esp
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104926:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010492d:	e9 c7 00 00 00       	jmp    801049f9 <priority_boost+0xd9>
    if (p->state == UNUSED)
80104932:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104935:	8b 40 0c             	mov    0xc(%eax),%eax
80104938:	85 c0                	test   %eax,%eax
8010493a:	0f 84 b1 00 00 00    	je     801049f1 <priority_boost+0xd1>
      continue;

    int prio = p->priority;
80104940:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104943:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104949:	89 45 f8             	mov    %eax,-0x8(%ebp)

    if (prio == 2 || prio == 1) {
8010494c:	83 7d f8 02          	cmpl   $0x2,-0x8(%ebp)
80104950:	74 06                	je     80104958 <priority_boost+0x38>
80104952:	83 7d f8 01          	cmpl   $0x1,-0x8(%ebp)
80104956:	75 67                	jne    801049bf <priority_boost+0x9f>
      // slice: Q2 = 16, Q1 = 32
      int slice[4] = {0, 32, 16, 8};
80104958:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010495f:	c7 45 e8 20 00 00 00 	movl   $0x20,-0x18(%ebp)
80104966:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
8010496d:	c7 45 f0 08 00 00 00 	movl   $0x8,-0x10(%ebp)
      int limit = 10 * slice[prio];
80104974:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104977:	8b 54 85 e4          	mov    -0x1c(%ebp,%eax,4),%edx
8010497b:	89 d0                	mov    %edx,%eax
8010497d:	c1 e0 02             	shl    $0x2,%eax
80104980:	01 d0                	add    %edx,%eax
80104982:	01 c0                	add    %eax,%eax
80104984:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if (p->wait_ticks[prio] >= limit) {
80104987:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010498a:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010498d:	83 c2 24             	add    $0x24,%edx
80104990:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104994:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104997:	7f 26                	jg     801049bf <priority_boost+0x9f>
        p->priority++;
80104999:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010499c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801049a2:	8d 50 01             	lea    0x1(%eax),%edx
801049a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049a8:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
        p->wait_ticks[prio] = 0;
801049ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049b1:	8b 55 f8             	mov    -0x8(%ebp),%edx
801049b4:	83 c2 24             	add    $0x24,%edx
801049b7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801049be:	00 
      }
    }

    if (prio == 0) {
801049bf:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801049c3:	75 2d                	jne    801049f2 <priority_boost+0xd2>
      if (p->wait_ticks[0] >= 500) {
801049c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049c8:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801049ce:	3d f3 01 00 00       	cmp    $0x1f3,%eax
801049d3:	7e 1d                	jle    801049f2 <priority_boost+0xd2>
        p->priority = 1;
801049d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049d8:	c7 80 84 00 00 00 01 	movl   $0x1,0x84(%eax)
801049df:	00 00 00 
        p->wait_ticks[0] = 0;
801049e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049e5:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
801049ec:	00 00 00 
801049ef:	eb 01                	jmp    801049f2 <priority_boost+0xd2>
      continue;
801049f1:	90                   	nop
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801049f2:	81 45 fc a8 00 00 00 	addl   $0xa8,-0x4(%ebp)
801049f9:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
80104a00:	0f 82 2c ff ff ff    	jb     80104932 <priority_boost+0x12>
      }
    }
  }
}
80104a06:	90                   	nop
80104a07:	90                   	nop
80104a08:	c9                   	leave
80104a09:	c3                   	ret

80104a0a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a0a:	55                   	push   %ebp
80104a0b:	89 e5                	mov    %esp,%ebp
80104a0d:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a10:	8b 45 08             	mov    0x8(%ebp),%eax
80104a13:	83 c0 04             	add    $0x4,%eax
80104a16:	83 ec 08             	sub    $0x8,%esp
80104a19:	68 5f a8 10 80       	push   $0x8010a85f
80104a1e:	50                   	push   %eax
80104a1f:	e8 43 01 00 00       	call   80104b67 <initlock>
80104a24:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a27:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a2d:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a30:	8b 45 08             	mov    0x8(%ebp),%eax
80104a33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a39:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104a43:	90                   	nop
80104a44:	c9                   	leave
80104a45:	c3                   	ret

80104a46 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104a46:	55                   	push   %ebp
80104a47:	89 e5                	mov    %esp,%ebp
80104a49:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4f:	83 c0 04             	add    $0x4,%eax
80104a52:	83 ec 0c             	sub    $0xc,%esp
80104a55:	50                   	push   %eax
80104a56:	e8 2e 01 00 00       	call   80104b89 <acquire>
80104a5b:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a5e:	eb 15                	jmp    80104a75 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104a60:	8b 45 08             	mov    0x8(%ebp),%eax
80104a63:	83 c0 04             	add    $0x4,%eax
80104a66:	83 ec 08             	sub    $0x8,%esp
80104a69:	50                   	push   %eax
80104a6a:	ff 75 08             	push   0x8(%ebp)
80104a6d:	e8 fd f9 ff ff       	call   8010446f <sleep>
80104a72:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a75:	8b 45 08             	mov    0x8(%ebp),%eax
80104a78:	8b 00                	mov    (%eax),%eax
80104a7a:	85 c0                	test   %eax,%eax
80104a7c:	75 e2                	jne    80104a60 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a81:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a87:	e8 ab ef ff ff       	call   80103a37 <myproc>
80104a8c:	8b 50 10             	mov    0x10(%eax),%edx
80104a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a92:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104a95:	8b 45 08             	mov    0x8(%ebp),%eax
80104a98:	83 c0 04             	add    $0x4,%eax
80104a9b:	83 ec 0c             	sub    $0xc,%esp
80104a9e:	50                   	push   %eax
80104a9f:	e8 53 01 00 00       	call   80104bf7 <release>
80104aa4:	83 c4 10             	add    $0x10,%esp
}
80104aa7:	90                   	nop
80104aa8:	c9                   	leave
80104aa9:	c3                   	ret

80104aaa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104aaa:	55                   	push   %ebp
80104aab:	89 e5                	mov    %esp,%ebp
80104aad:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab3:	83 c0 04             	add    $0x4,%eax
80104ab6:	83 ec 0c             	sub    $0xc,%esp
80104ab9:	50                   	push   %eax
80104aba:	e8 ca 00 00 00       	call   80104b89 <acquire>
80104abf:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104acb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ace:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104ad5:	83 ec 0c             	sub    $0xc,%esp
80104ad8:	ff 75 08             	push   0x8(%ebp)
80104adb:	e8 79 fa ff ff       	call   80104559 <wakeup>
80104ae0:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae6:	83 c0 04             	add    $0x4,%eax
80104ae9:	83 ec 0c             	sub    $0xc,%esp
80104aec:	50                   	push   %eax
80104aed:	e8 05 01 00 00       	call   80104bf7 <release>
80104af2:	83 c4 10             	add    $0x10,%esp
}
80104af5:	90                   	nop
80104af6:	c9                   	leave
80104af7:	c3                   	ret

80104af8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104af8:	55                   	push   %ebp
80104af9:	89 e5                	mov    %esp,%ebp
80104afb:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104afe:	8b 45 08             	mov    0x8(%ebp),%eax
80104b01:	83 c0 04             	add    $0x4,%eax
80104b04:	83 ec 0c             	sub    $0xc,%esp
80104b07:	50                   	push   %eax
80104b08:	e8 7c 00 00 00       	call   80104b89 <acquire>
80104b0d:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b10:	8b 45 08             	mov    0x8(%ebp),%eax
80104b13:	8b 00                	mov    (%eax),%eax
80104b15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b18:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1b:	83 c0 04             	add    $0x4,%eax
80104b1e:	83 ec 0c             	sub    $0xc,%esp
80104b21:	50                   	push   %eax
80104b22:	e8 d0 00 00 00       	call   80104bf7 <release>
80104b27:	83 c4 10             	add    $0x10,%esp
  return r;
80104b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b2d:	c9                   	leave
80104b2e:	c3                   	ret

80104b2f <readeflags>:
{
80104b2f:	55                   	push   %ebp
80104b30:	89 e5                	mov    %esp,%ebp
80104b32:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b35:	9c                   	pushf
80104b36:	58                   	pop    %eax
80104b37:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b3d:	c9                   	leave
80104b3e:	c3                   	ret

80104b3f <cli>:
{
80104b3f:	55                   	push   %ebp
80104b40:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b42:	fa                   	cli
}
80104b43:	90                   	nop
80104b44:	5d                   	pop    %ebp
80104b45:	c3                   	ret

80104b46 <sti>:
{
80104b46:	55                   	push   %ebp
80104b47:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b49:	fb                   	sti
}
80104b4a:	90                   	nop
80104b4b:	5d                   	pop    %ebp
80104b4c:	c3                   	ret

80104b4d <xchg>:
{
80104b4d:	55                   	push   %ebp
80104b4e:	89 e5                	mov    %esp,%ebp
80104b50:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104b53:	8b 55 08             	mov    0x8(%ebp),%edx
80104b56:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b59:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b5c:	f0 87 02             	lock xchg %eax,(%edx)
80104b5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104b62:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b65:	c9                   	leave
80104b66:	c3                   	ret

80104b67 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b67:	55                   	push   %ebp
80104b68:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b70:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b73:	8b 45 08             	mov    0x8(%ebp),%eax
80104b76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b86:	90                   	nop
80104b87:	5d                   	pop    %ebp
80104b88:	c3                   	ret

80104b89 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b89:	55                   	push   %ebp
80104b8a:	89 e5                	mov    %esp,%ebp
80104b8c:	53                   	push   %ebx
80104b8d:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b90:	e8 5f 01 00 00       	call   80104cf4 <pushcli>
  if(holding(lk)){
80104b95:	8b 45 08             	mov    0x8(%ebp),%eax
80104b98:	83 ec 0c             	sub    $0xc,%esp
80104b9b:	50                   	push   %eax
80104b9c:	e8 23 01 00 00       	call   80104cc4 <holding>
80104ba1:	83 c4 10             	add    $0x10,%esp
80104ba4:	85 c0                	test   %eax,%eax
80104ba6:	74 0d                	je     80104bb5 <acquire+0x2c>
    panic("acquire");
80104ba8:	83 ec 0c             	sub    $0xc,%esp
80104bab:	68 6a a8 10 80       	push   $0x8010a86a
80104bb0:	e8 f4 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104bb5:	90                   	nop
80104bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb9:	83 ec 08             	sub    $0x8,%esp
80104bbc:	6a 01                	push   $0x1
80104bbe:	50                   	push   %eax
80104bbf:	e8 89 ff ff ff       	call   80104b4d <xchg>
80104bc4:	83 c4 10             	add    $0x10,%esp
80104bc7:	85 c0                	test   %eax,%eax
80104bc9:	75 eb                	jne    80104bb6 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104bcb:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104bd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104bd3:	e8 e7 ed ff ff       	call   801039bf <mycpu>
80104bd8:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bde:	83 c0 0c             	add    $0xc,%eax
80104be1:	83 ec 08             	sub    $0x8,%esp
80104be4:	50                   	push   %eax
80104be5:	8d 45 08             	lea    0x8(%ebp),%eax
80104be8:	50                   	push   %eax
80104be9:	e8 5b 00 00 00       	call   80104c49 <getcallerpcs>
80104bee:	83 c4 10             	add    $0x10,%esp
}
80104bf1:	90                   	nop
80104bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bf5:	c9                   	leave
80104bf6:	c3                   	ret

80104bf7 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104bf7:	55                   	push   %ebp
80104bf8:	89 e5                	mov    %esp,%ebp
80104bfa:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104bfd:	83 ec 0c             	sub    $0xc,%esp
80104c00:	ff 75 08             	push   0x8(%ebp)
80104c03:	e8 bc 00 00 00       	call   80104cc4 <holding>
80104c08:	83 c4 10             	add    $0x10,%esp
80104c0b:	85 c0                	test   %eax,%eax
80104c0d:	75 0d                	jne    80104c1c <release+0x25>
    panic("release");
80104c0f:	83 ec 0c             	sub    $0xc,%esp
80104c12:	68 72 a8 10 80       	push   $0x8010a872
80104c17:	e8 8d b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c26:	8b 45 08             	mov    0x8(%ebp),%eax
80104c29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c30:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c35:	8b 45 08             	mov    0x8(%ebp),%eax
80104c38:	8b 55 08             	mov    0x8(%ebp),%edx
80104c3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c41:	e8 fb 00 00 00       	call   80104d41 <popcli>
}
80104c46:	90                   	nop
80104c47:	c9                   	leave
80104c48:	c3                   	ret

80104c49 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c49:	55                   	push   %ebp
80104c4a:	89 e5                	mov    %esp,%ebp
80104c4c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c52:	83 e8 08             	sub    $0x8,%eax
80104c55:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c58:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c5f:	eb 38                	jmp    80104c99 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c61:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c65:	74 53                	je     80104cba <getcallerpcs+0x71>
80104c67:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c6e:	76 4a                	jbe    80104cba <getcallerpcs+0x71>
80104c70:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c74:	74 44                	je     80104cba <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c79:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c80:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c83:	01 c2                	add    %eax,%edx
80104c85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c88:	8b 40 04             	mov    0x4(%eax),%eax
80104c8b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c90:	8b 00                	mov    (%eax),%eax
80104c92:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c95:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c99:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c9d:	7e c2                	jle    80104c61 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104c9f:	eb 19                	jmp    80104cba <getcallerpcs+0x71>
    pcs[i] = 0;
80104ca1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ca4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cab:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cae:	01 d0                	add    %edx,%eax
80104cb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104cb6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cba:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cbe:	7e e1                	jle    80104ca1 <getcallerpcs+0x58>
}
80104cc0:	90                   	nop
80104cc1:	90                   	nop
80104cc2:	c9                   	leave
80104cc3:	c3                   	ret

80104cc4 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104cc4:	55                   	push   %ebp
80104cc5:	89 e5                	mov    %esp,%ebp
80104cc7:	53                   	push   %ebx
80104cc8:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cce:	8b 00                	mov    (%eax),%eax
80104cd0:	85 c0                	test   %eax,%eax
80104cd2:	74 16                	je     80104cea <holding+0x26>
80104cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd7:	8b 58 08             	mov    0x8(%eax),%ebx
80104cda:	e8 e0 ec ff ff       	call   801039bf <mycpu>
80104cdf:	39 c3                	cmp    %eax,%ebx
80104ce1:	75 07                	jne    80104cea <holding+0x26>
80104ce3:	b8 01 00 00 00       	mov    $0x1,%eax
80104ce8:	eb 05                	jmp    80104cef <holding+0x2b>
80104cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cf2:	c9                   	leave
80104cf3:	c3                   	ret

80104cf4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104cf4:	55                   	push   %ebp
80104cf5:	89 e5                	mov    %esp,%ebp
80104cf7:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104cfa:	e8 30 fe ff ff       	call   80104b2f <readeflags>
80104cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d02:	e8 38 fe ff ff       	call   80104b3f <cli>
  if(mycpu()->ncli == 0)
80104d07:	e8 b3 ec ff ff       	call   801039bf <mycpu>
80104d0c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d12:	85 c0                	test   %eax,%eax
80104d14:	75 14                	jne    80104d2a <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d16:	e8 a4 ec ff ff       	call   801039bf <mycpu>
80104d1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d1e:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d24:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d2a:	e8 90 ec ff ff       	call   801039bf <mycpu>
80104d2f:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d35:	83 c2 01             	add    $0x1,%edx
80104d38:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d3e:	90                   	nop
80104d3f:	c9                   	leave
80104d40:	c3                   	ret

80104d41 <popcli>:

void
popcli(void)
{
80104d41:	55                   	push   %ebp
80104d42:	89 e5                	mov    %esp,%ebp
80104d44:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d47:	e8 e3 fd ff ff       	call   80104b2f <readeflags>
80104d4c:	25 00 02 00 00       	and    $0x200,%eax
80104d51:	85 c0                	test   %eax,%eax
80104d53:	74 0d                	je     80104d62 <popcli+0x21>
    panic("popcli - interruptible");
80104d55:	83 ec 0c             	sub    $0xc,%esp
80104d58:	68 7a a8 10 80       	push   $0x8010a87a
80104d5d:	e8 47 b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104d62:	e8 58 ec ff ff       	call   801039bf <mycpu>
80104d67:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d6d:	83 ea 01             	sub    $0x1,%edx
80104d70:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d76:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d7c:	85 c0                	test   %eax,%eax
80104d7e:	79 0d                	jns    80104d8d <popcli+0x4c>
    panic("popcli");
80104d80:	83 ec 0c             	sub    $0xc,%esp
80104d83:	68 91 a8 10 80       	push   $0x8010a891
80104d88:	e8 1c b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104d8d:	e8 2d ec ff ff       	call   801039bf <mycpu>
80104d92:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d98:	85 c0                	test   %eax,%eax
80104d9a:	75 14                	jne    80104db0 <popcli+0x6f>
80104d9c:	e8 1e ec ff ff       	call   801039bf <mycpu>
80104da1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104da7:	85 c0                	test   %eax,%eax
80104da9:	74 05                	je     80104db0 <popcli+0x6f>
    sti();
80104dab:	e8 96 fd ff ff       	call   80104b46 <sti>
}
80104db0:	90                   	nop
80104db1:	c9                   	leave
80104db2:	c3                   	ret

80104db3 <stosb>:
{
80104db3:	55                   	push   %ebp
80104db4:	89 e5                	mov    %esp,%ebp
80104db6:	57                   	push   %edi
80104db7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104db8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104dbb:	8b 55 10             	mov    0x10(%ebp),%edx
80104dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc1:	89 cb                	mov    %ecx,%ebx
80104dc3:	89 df                	mov    %ebx,%edi
80104dc5:	89 d1                	mov    %edx,%ecx
80104dc7:	fc                   	cld
80104dc8:	f3 aa                	rep stos %al,%es:(%edi)
80104dca:	89 ca                	mov    %ecx,%edx
80104dcc:	89 fb                	mov    %edi,%ebx
80104dce:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104dd1:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104dd4:	90                   	nop
80104dd5:	5b                   	pop    %ebx
80104dd6:	5f                   	pop    %edi
80104dd7:	5d                   	pop    %ebp
80104dd8:	c3                   	ret

80104dd9 <stosl>:
{
80104dd9:	55                   	push   %ebp
80104dda:	89 e5                	mov    %esp,%ebp
80104ddc:	57                   	push   %edi
80104ddd:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104de1:	8b 55 10             	mov    0x10(%ebp),%edx
80104de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de7:	89 cb                	mov    %ecx,%ebx
80104de9:	89 df                	mov    %ebx,%edi
80104deb:	89 d1                	mov    %edx,%ecx
80104ded:	fc                   	cld
80104dee:	f3 ab                	rep stos %eax,%es:(%edi)
80104df0:	89 ca                	mov    %ecx,%edx
80104df2:	89 fb                	mov    %edi,%ebx
80104df4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104df7:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104dfa:	90                   	nop
80104dfb:	5b                   	pop    %ebx
80104dfc:	5f                   	pop    %edi
80104dfd:	5d                   	pop    %ebp
80104dfe:	c3                   	ret

80104dff <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104dff:	55                   	push   %ebp
80104e00:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e02:	8b 45 08             	mov    0x8(%ebp),%eax
80104e05:	83 e0 03             	and    $0x3,%eax
80104e08:	85 c0                	test   %eax,%eax
80104e0a:	75 43                	jne    80104e4f <memset+0x50>
80104e0c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e0f:	83 e0 03             	and    $0x3,%eax
80104e12:	85 c0                	test   %eax,%eax
80104e14:	75 39                	jne    80104e4f <memset+0x50>
    c &= 0xFF;
80104e16:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e1d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e20:	c1 e8 02             	shr    $0x2,%eax
80104e23:	89 c1                	mov    %eax,%ecx
80104e25:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e28:	c1 e0 18             	shl    $0x18,%eax
80104e2b:	89 c2                	mov    %eax,%edx
80104e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e30:	c1 e0 10             	shl    $0x10,%eax
80104e33:	09 c2                	or     %eax,%edx
80104e35:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e38:	c1 e0 08             	shl    $0x8,%eax
80104e3b:	09 d0                	or     %edx,%eax
80104e3d:	0b 45 0c             	or     0xc(%ebp),%eax
80104e40:	51                   	push   %ecx
80104e41:	50                   	push   %eax
80104e42:	ff 75 08             	push   0x8(%ebp)
80104e45:	e8 8f ff ff ff       	call   80104dd9 <stosl>
80104e4a:	83 c4 0c             	add    $0xc,%esp
80104e4d:	eb 12                	jmp    80104e61 <memset+0x62>
  } else
    stosb(dst, c, n);
80104e4f:	8b 45 10             	mov    0x10(%ebp),%eax
80104e52:	50                   	push   %eax
80104e53:	ff 75 0c             	push   0xc(%ebp)
80104e56:	ff 75 08             	push   0x8(%ebp)
80104e59:	e8 55 ff ff ff       	call   80104db3 <stosb>
80104e5e:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104e61:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e64:	c9                   	leave
80104e65:	c3                   	ret

80104e66 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e66:	55                   	push   %ebp
80104e67:	89 e5                	mov    %esp,%ebp
80104e69:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e75:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e78:	eb 2e                	jmp    80104ea8 <memcmp+0x42>
    if(*s1 != *s2)
80104e7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e7d:	0f b6 10             	movzbl (%eax),%edx
80104e80:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e83:	0f b6 00             	movzbl (%eax),%eax
80104e86:	38 c2                	cmp    %al,%dl
80104e88:	74 16                	je     80104ea0 <memcmp+0x3a>
      return *s1 - *s2;
80104e8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e8d:	0f b6 00             	movzbl (%eax),%eax
80104e90:	0f b6 d0             	movzbl %al,%edx
80104e93:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e96:	0f b6 00             	movzbl (%eax),%eax
80104e99:	0f b6 c0             	movzbl %al,%eax
80104e9c:	29 c2                	sub    %eax,%edx
80104e9e:	eb 1a                	jmp    80104eba <memcmp+0x54>
    s1++, s2++;
80104ea0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ea4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104ea8:	8b 45 10             	mov    0x10(%ebp),%eax
80104eab:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eae:	89 55 10             	mov    %edx,0x10(%ebp)
80104eb1:	85 c0                	test   %eax,%eax
80104eb3:	75 c5                	jne    80104e7a <memcmp+0x14>
  }

  return 0;
80104eb5:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104eba:	89 d0                	mov    %edx,%eax
80104ebc:	c9                   	leave
80104ebd:	c3                   	ret

80104ebe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ebe:	55                   	push   %ebp
80104ebf:	89 e5                	mov    %esp,%ebp
80104ec1:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104eca:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104ed0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ed3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ed6:	73 54                	jae    80104f2c <memmove+0x6e>
80104ed8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104edb:	8b 45 10             	mov    0x10(%ebp),%eax
80104ede:	01 d0                	add    %edx,%eax
80104ee0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104ee3:	73 47                	jae    80104f2c <memmove+0x6e>
    s += n;
80104ee5:	8b 45 10             	mov    0x10(%ebp),%eax
80104ee8:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104eeb:	8b 45 10             	mov    0x10(%ebp),%eax
80104eee:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104ef1:	eb 13                	jmp    80104f06 <memmove+0x48>
      *--d = *--s;
80104ef3:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104ef7:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104efb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104efe:	0f b6 10             	movzbl (%eax),%edx
80104f01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f04:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f06:	8b 45 10             	mov    0x10(%ebp),%eax
80104f09:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f0c:	89 55 10             	mov    %edx,0x10(%ebp)
80104f0f:	85 c0                	test   %eax,%eax
80104f11:	75 e0                	jne    80104ef3 <memmove+0x35>
  if(s < d && s + n > d){
80104f13:	eb 24                	jmp    80104f39 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f15:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f18:	8d 42 01             	lea    0x1(%edx),%eax
80104f1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f21:	8d 48 01             	lea    0x1(%eax),%ecx
80104f24:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f27:	0f b6 12             	movzbl (%edx),%edx
80104f2a:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f2c:	8b 45 10             	mov    0x10(%ebp),%eax
80104f2f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f32:	89 55 10             	mov    %edx,0x10(%ebp)
80104f35:	85 c0                	test   %eax,%eax
80104f37:	75 dc                	jne    80104f15 <memmove+0x57>

  return dst;
80104f39:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f3c:	c9                   	leave
80104f3d:	c3                   	ret

80104f3e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f3e:	55                   	push   %ebp
80104f3f:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f41:	ff 75 10             	push   0x10(%ebp)
80104f44:	ff 75 0c             	push   0xc(%ebp)
80104f47:	ff 75 08             	push   0x8(%ebp)
80104f4a:	e8 6f ff ff ff       	call   80104ebe <memmove>
80104f4f:	83 c4 0c             	add    $0xc,%esp
}
80104f52:	c9                   	leave
80104f53:	c3                   	ret

80104f54 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f54:	55                   	push   %ebp
80104f55:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f57:	eb 0c                	jmp    80104f65 <strncmp+0x11>
    n--, p++, q++;
80104f59:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f5d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f61:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f69:	74 1a                	je     80104f85 <strncmp+0x31>
80104f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6e:	0f b6 00             	movzbl (%eax),%eax
80104f71:	84 c0                	test   %al,%al
80104f73:	74 10                	je     80104f85 <strncmp+0x31>
80104f75:	8b 45 08             	mov    0x8(%ebp),%eax
80104f78:	0f b6 10             	movzbl (%eax),%edx
80104f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f7e:	0f b6 00             	movzbl (%eax),%eax
80104f81:	38 c2                	cmp    %al,%dl
80104f83:	74 d4                	je     80104f59 <strncmp+0x5>
  if(n == 0)
80104f85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f89:	75 07                	jne    80104f92 <strncmp+0x3e>
    return 0;
80104f8b:	ba 00 00 00 00       	mov    $0x0,%edx
80104f90:	eb 14                	jmp    80104fa6 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104f92:	8b 45 08             	mov    0x8(%ebp),%eax
80104f95:	0f b6 00             	movzbl (%eax),%eax
80104f98:	0f b6 d0             	movzbl %al,%edx
80104f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9e:	0f b6 00             	movzbl (%eax),%eax
80104fa1:	0f b6 c0             	movzbl %al,%eax
80104fa4:	29 c2                	sub    %eax,%edx
}
80104fa6:	89 d0                	mov    %edx,%eax
80104fa8:	5d                   	pop    %ebp
80104fa9:	c3                   	ret

80104faa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104faa:	55                   	push   %ebp
80104fab:	89 e5                	mov    %esp,%ebp
80104fad:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104fb6:	90                   	nop
80104fb7:	8b 45 10             	mov    0x10(%ebp),%eax
80104fba:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fbd:	89 55 10             	mov    %edx,0x10(%ebp)
80104fc0:	85 c0                	test   %eax,%eax
80104fc2:	7e 2c                	jle    80104ff0 <strncpy+0x46>
80104fc4:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fc7:	8d 42 01             	lea    0x1(%edx),%eax
80104fca:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd0:	8d 48 01             	lea    0x1(%eax),%ecx
80104fd3:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fd6:	0f b6 12             	movzbl (%edx),%edx
80104fd9:	88 10                	mov    %dl,(%eax)
80104fdb:	0f b6 00             	movzbl (%eax),%eax
80104fde:	84 c0                	test   %al,%al
80104fe0:	75 d5                	jne    80104fb7 <strncpy+0xd>
    ;
  while(n-- > 0)
80104fe2:	eb 0c                	jmp    80104ff0 <strncpy+0x46>
    *s++ = 0;
80104fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe7:	8d 50 01             	lea    0x1(%eax),%edx
80104fea:	89 55 08             	mov    %edx,0x8(%ebp)
80104fed:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104ff0:	8b 45 10             	mov    0x10(%ebp),%eax
80104ff3:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ff6:	89 55 10             	mov    %edx,0x10(%ebp)
80104ff9:	85 c0                	test   %eax,%eax
80104ffb:	7f e7                	jg     80104fe4 <strncpy+0x3a>
  return os;
80104ffd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105000:	c9                   	leave
80105001:	c3                   	ret

80105002 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105002:	55                   	push   %ebp
80105003:	89 e5                	mov    %esp,%ebp
80105005:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105008:	8b 45 08             	mov    0x8(%ebp),%eax
8010500b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010500e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105012:	7f 05                	jg     80105019 <safestrcpy+0x17>
    return os;
80105014:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105017:	eb 32                	jmp    8010504b <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105019:	90                   	nop
8010501a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010501e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105022:	7e 1e                	jle    80105042 <safestrcpy+0x40>
80105024:	8b 55 0c             	mov    0xc(%ebp),%edx
80105027:	8d 42 01             	lea    0x1(%edx),%eax
8010502a:	89 45 0c             	mov    %eax,0xc(%ebp)
8010502d:	8b 45 08             	mov    0x8(%ebp),%eax
80105030:	8d 48 01             	lea    0x1(%eax),%ecx
80105033:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105036:	0f b6 12             	movzbl (%edx),%edx
80105039:	88 10                	mov    %dl,(%eax)
8010503b:	0f b6 00             	movzbl (%eax),%eax
8010503e:	84 c0                	test   %al,%al
80105040:	75 d8                	jne    8010501a <safestrcpy+0x18>
    ;
  *s = 0;
80105042:	8b 45 08             	mov    0x8(%ebp),%eax
80105045:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105048:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010504b:	c9                   	leave
8010504c:	c3                   	ret

8010504d <strlen>:

int
strlen(const char *s)
{
8010504d:	55                   	push   %ebp
8010504e:	89 e5                	mov    %esp,%ebp
80105050:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105053:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010505a:	eb 04                	jmp    80105060 <strlen+0x13>
8010505c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105060:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105063:	8b 45 08             	mov    0x8(%ebp),%eax
80105066:	01 d0                	add    %edx,%eax
80105068:	0f b6 00             	movzbl (%eax),%eax
8010506b:	84 c0                	test   %al,%al
8010506d:	75 ed                	jne    8010505c <strlen+0xf>
    ;
  return n;
8010506f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105072:	c9                   	leave
80105073:	c3                   	ret

80105074 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105074:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105078:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010507c:	55                   	push   %ebp
  pushl %ebx
8010507d:	53                   	push   %ebx
  pushl %esi
8010507e:	56                   	push   %esi
  pushl %edi
8010507f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105080:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105082:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105084:	5f                   	pop    %edi
  popl %esi
80105085:	5e                   	pop    %esi
  popl %ebx
80105086:	5b                   	pop    %ebx
  popl %ebp
80105087:	5d                   	pop    %ebp
  ret
80105088:	c3                   	ret

80105089 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105089:	55                   	push   %ebp
8010508a:	89 e5                	mov    %esp,%ebp
8010508c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010508f:	e8 a3 e9 ff ff       	call   80103a37 <myproc>
80105094:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509a:	8b 00                	mov    (%eax),%eax
8010509c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010509f:	73 0f                	jae    801050b0 <fetchint+0x27>
801050a1:	8b 45 08             	mov    0x8(%ebp),%eax
801050a4:	8d 50 04             	lea    0x4(%eax),%edx
801050a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050aa:	8b 00                	mov    (%eax),%eax
801050ac:	39 d0                	cmp    %edx,%eax
801050ae:	73 07                	jae    801050b7 <fetchint+0x2e>
    return -1;
801050b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b5:	eb 0f                	jmp    801050c6 <fetchint+0x3d>
  *ip = *(int*)(addr);
801050b7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ba:	8b 10                	mov    (%eax),%edx
801050bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801050bf:	89 10                	mov    %edx,(%eax)
  return 0;
801050c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050c6:	c9                   	leave
801050c7:	c3                   	ret

801050c8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801050c8:	55                   	push   %ebp
801050c9:	89 e5                	mov    %esp,%ebp
801050cb:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801050ce:	e8 64 e9 ff ff       	call   80103a37 <myproc>
801050d3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801050d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d9:	8b 00                	mov    (%eax),%eax
801050db:	39 45 08             	cmp    %eax,0x8(%ebp)
801050de:	72 07                	jb     801050e7 <fetchstr+0x1f>
    return -1;
801050e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e5:	eb 41                	jmp    80105128 <fetchstr+0x60>
  *pp = (char*)addr;
801050e7:	8b 55 08             	mov    0x8(%ebp),%edx
801050ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ed:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801050ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f2:	8b 00                	mov    (%eax),%eax
801050f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801050f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fa:	8b 00                	mov    (%eax),%eax
801050fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050ff:	eb 1a                	jmp    8010511b <fetchstr+0x53>
    if(*s == 0)
80105101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105104:	0f b6 00             	movzbl (%eax),%eax
80105107:	84 c0                	test   %al,%al
80105109:	75 0c                	jne    80105117 <fetchstr+0x4f>
      return s - *pp;
8010510b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510e:	8b 10                	mov    (%eax),%edx
80105110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105113:	29 d0                	sub    %edx,%eax
80105115:	eb 11                	jmp    80105128 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105117:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010511b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105121:	72 de                	jb     80105101 <fetchstr+0x39>
  }
  return -1;
80105123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105128:	c9                   	leave
80105129:	c3                   	ret

8010512a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010512a:	55                   	push   %ebp
8010512b:	89 e5                	mov    %esp,%ebp
8010512d:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105130:	e8 02 e9 ff ff       	call   80103a37 <myproc>
80105135:	8b 40 18             	mov    0x18(%eax),%eax
80105138:	8b 40 44             	mov    0x44(%eax),%eax
8010513b:	8b 55 08             	mov    0x8(%ebp),%edx
8010513e:	c1 e2 02             	shl    $0x2,%edx
80105141:	01 d0                	add    %edx,%eax
80105143:	83 c0 04             	add    $0x4,%eax
80105146:	83 ec 08             	sub    $0x8,%esp
80105149:	ff 75 0c             	push   0xc(%ebp)
8010514c:	50                   	push   %eax
8010514d:	e8 37 ff ff ff       	call   80105089 <fetchint>
80105152:	83 c4 10             	add    $0x10,%esp
}
80105155:	c9                   	leave
80105156:	c3                   	ret

80105157 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105157:	55                   	push   %ebp
80105158:	89 e5                	mov    %esp,%ebp
8010515a:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010515d:	e8 d5 e8 ff ff       	call   80103a37 <myproc>
80105162:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105165:	83 ec 08             	sub    $0x8,%esp
80105168:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010516b:	50                   	push   %eax
8010516c:	ff 75 08             	push   0x8(%ebp)
8010516f:	e8 b6 ff ff ff       	call   8010512a <argint>
80105174:	83 c4 10             	add    $0x10,%esp
80105177:	85 c0                	test   %eax,%eax
80105179:	79 07                	jns    80105182 <argptr+0x2b>
    return -1;
8010517b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105180:	eb 3b                	jmp    801051bd <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105182:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105186:	78 1f                	js     801051a7 <argptr+0x50>
80105188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518b:	8b 00                	mov    (%eax),%eax
8010518d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105190:	39 c2                	cmp    %eax,%edx
80105192:	73 13                	jae    801051a7 <argptr+0x50>
80105194:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105197:	89 c2                	mov    %eax,%edx
80105199:	8b 45 10             	mov    0x10(%ebp),%eax
8010519c:	01 c2                	add    %eax,%edx
8010519e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a1:	8b 00                	mov    (%eax),%eax
801051a3:	39 d0                	cmp    %edx,%eax
801051a5:	73 07                	jae    801051ae <argptr+0x57>
    return -1;
801051a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ac:	eb 0f                	jmp    801051bd <argptr+0x66>
  *pp = (char*)i;
801051ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051b1:	89 c2                	mov    %eax,%edx
801051b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b6:	89 10                	mov    %edx,(%eax)
  return 0;
801051b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051bd:	c9                   	leave
801051be:	c3                   	ret

801051bf <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051bf:	55                   	push   %ebp
801051c0:	89 e5                	mov    %esp,%ebp
801051c2:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051c5:	83 ec 08             	sub    $0x8,%esp
801051c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051cb:	50                   	push   %eax
801051cc:	ff 75 08             	push   0x8(%ebp)
801051cf:	e8 56 ff ff ff       	call   8010512a <argint>
801051d4:	83 c4 10             	add    $0x10,%esp
801051d7:	85 c0                	test   %eax,%eax
801051d9:	79 07                	jns    801051e2 <argstr+0x23>
    return -1;
801051db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051e0:	eb 12                	jmp    801051f4 <argstr+0x35>
  return fetchstr(addr, pp);
801051e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e5:	83 ec 08             	sub    $0x8,%esp
801051e8:	ff 75 0c             	push   0xc(%ebp)
801051eb:	50                   	push   %eax
801051ec:	e8 d7 fe ff ff       	call   801050c8 <fetchstr>
801051f1:	83 c4 10             	add    $0x10,%esp
}
801051f4:	c9                   	leave
801051f5:	c3                   	ret

801051f6 <syscall>:

};

void
syscall(void)
{
801051f6:	55                   	push   %ebp
801051f7:	89 e5                	mov    %esp,%ebp
801051f9:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801051fc:	e8 36 e8 ff ff       	call   80103a37 <myproc>
80105201:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105207:	8b 40 18             	mov    0x18(%eax),%eax
8010520a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010520d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105210:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105214:	7e 2f                	jle    80105245 <syscall+0x4f>
80105216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105219:	83 f8 18             	cmp    $0x18,%eax
8010521c:	77 27                	ja     80105245 <syscall+0x4f>
8010521e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105221:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105228:	85 c0                	test   %eax,%eax
8010522a:	74 19                	je     80105245 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
8010522c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522f:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105236:	ff d0                	call   *%eax
80105238:	89 c2                	mov    %eax,%edx
8010523a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523d:	8b 40 18             	mov    0x18(%eax),%eax
80105240:	89 50 1c             	mov    %edx,0x1c(%eax)
80105243:	eb 2c                	jmp    80105271 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105248:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010524b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524e:	8b 40 10             	mov    0x10(%eax),%eax
80105251:	ff 75 f0             	push   -0x10(%ebp)
80105254:	52                   	push   %edx
80105255:	50                   	push   %eax
80105256:	68 98 a8 10 80       	push   $0x8010a898
8010525b:	e8 94 b1 ff ff       	call   801003f4 <cprintf>
80105260:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105266:	8b 40 18             	mov    0x18(%eax),%eax
80105269:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105270:	90                   	nop
80105271:	90                   	nop
80105272:	c9                   	leave
80105273:	c3                   	ret

80105274 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105274:	55                   	push   %ebp
80105275:	89 e5                	mov    %esp,%ebp
80105277:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010527a:	83 ec 08             	sub    $0x8,%esp
8010527d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105280:	50                   	push   %eax
80105281:	ff 75 08             	push   0x8(%ebp)
80105284:	e8 a1 fe ff ff       	call   8010512a <argint>
80105289:	83 c4 10             	add    $0x10,%esp
8010528c:	85 c0                	test   %eax,%eax
8010528e:	79 07                	jns    80105297 <argfd+0x23>
    return -1;
80105290:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105295:	eb 4f                	jmp    801052e6 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105297:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529a:	85 c0                	test   %eax,%eax
8010529c:	78 20                	js     801052be <argfd+0x4a>
8010529e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a1:	83 f8 0f             	cmp    $0xf,%eax
801052a4:	7f 18                	jg     801052be <argfd+0x4a>
801052a6:	e8 8c e7 ff ff       	call   80103a37 <myproc>
801052ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052ae:	83 c2 08             	add    $0x8,%edx
801052b1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052bc:	75 07                	jne    801052c5 <argfd+0x51>
    return -1;
801052be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052c3:	eb 21                	jmp    801052e6 <argfd+0x72>
  if(pfd)
801052c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052c9:	74 08                	je     801052d3 <argfd+0x5f>
    *pfd = fd;
801052cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d1:	89 10                	mov    %edx,(%eax)
  if(pf)
801052d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052d7:	74 08                	je     801052e1 <argfd+0x6d>
    *pf = f;
801052d9:	8b 45 10             	mov    0x10(%ebp),%eax
801052dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052df:	89 10                	mov    %edx,(%eax)
  return 0;
801052e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052e6:	c9                   	leave
801052e7:	c3                   	ret

801052e8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052e8:	55                   	push   %ebp
801052e9:	89 e5                	mov    %esp,%ebp
801052eb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801052ee:	e8 44 e7 ff ff       	call   80103a37 <myproc>
801052f3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801052f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052fd:	eb 2a                	jmp    80105329 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801052ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105302:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105305:	83 c2 08             	add    $0x8,%edx
80105308:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010530c:	85 c0                	test   %eax,%eax
8010530e:	75 15                	jne    80105325 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105313:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105316:	8d 4a 08             	lea    0x8(%edx),%ecx
80105319:	8b 55 08             	mov    0x8(%ebp),%edx
8010531c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105323:	eb 0f                	jmp    80105334 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105325:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105329:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010532d:	7e d0                	jle    801052ff <fdalloc+0x17>
    }
  }
  return -1;
8010532f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105334:	c9                   	leave
80105335:	c3                   	ret

80105336 <sys_dup>:

int
sys_dup(void)
{
80105336:	55                   	push   %ebp
80105337:	89 e5                	mov    %esp,%ebp
80105339:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010533c:	83 ec 04             	sub    $0x4,%esp
8010533f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105342:	50                   	push   %eax
80105343:	6a 00                	push   $0x0
80105345:	6a 00                	push   $0x0
80105347:	e8 28 ff ff ff       	call   80105274 <argfd>
8010534c:	83 c4 10             	add    $0x10,%esp
8010534f:	85 c0                	test   %eax,%eax
80105351:	79 07                	jns    8010535a <sys_dup+0x24>
    return -1;
80105353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105358:	eb 31                	jmp    8010538b <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010535a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535d:	83 ec 0c             	sub    $0xc,%esp
80105360:	50                   	push   %eax
80105361:	e8 82 ff ff ff       	call   801052e8 <fdalloc>
80105366:	83 c4 10             	add    $0x10,%esp
80105369:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010536c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105370:	79 07                	jns    80105379 <sys_dup+0x43>
    return -1;
80105372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105377:	eb 12                	jmp    8010538b <sys_dup+0x55>
  filedup(f);
80105379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537c:	83 ec 0c             	sub    $0xc,%esp
8010537f:	50                   	push   %eax
80105380:	e8 cf bc ff ff       	call   80101054 <filedup>
80105385:	83 c4 10             	add    $0x10,%esp
  return fd;
80105388:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010538b:	c9                   	leave
8010538c:	c3                   	ret

8010538d <sys_read>:

int
sys_read(void)
{
8010538d:	55                   	push   %ebp
8010538e:	89 e5                	mov    %esp,%ebp
80105390:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105393:	83 ec 04             	sub    $0x4,%esp
80105396:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105399:	50                   	push   %eax
8010539a:	6a 00                	push   $0x0
8010539c:	6a 00                	push   $0x0
8010539e:	e8 d1 fe ff ff       	call   80105274 <argfd>
801053a3:	83 c4 10             	add    $0x10,%esp
801053a6:	85 c0                	test   %eax,%eax
801053a8:	78 2e                	js     801053d8 <sys_read+0x4b>
801053aa:	83 ec 08             	sub    $0x8,%esp
801053ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053b0:	50                   	push   %eax
801053b1:	6a 02                	push   $0x2
801053b3:	e8 72 fd ff ff       	call   8010512a <argint>
801053b8:	83 c4 10             	add    $0x10,%esp
801053bb:	85 c0                	test   %eax,%eax
801053bd:	78 19                	js     801053d8 <sys_read+0x4b>
801053bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c2:	83 ec 04             	sub    $0x4,%esp
801053c5:	50                   	push   %eax
801053c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053c9:	50                   	push   %eax
801053ca:	6a 01                	push   $0x1
801053cc:	e8 86 fd ff ff       	call   80105157 <argptr>
801053d1:	83 c4 10             	add    $0x10,%esp
801053d4:	85 c0                	test   %eax,%eax
801053d6:	79 07                	jns    801053df <sys_read+0x52>
    return -1;
801053d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053dd:	eb 17                	jmp    801053f6 <sys_read+0x69>
  return fileread(f, p, n);
801053df:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053e2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e8:	83 ec 04             	sub    $0x4,%esp
801053eb:	51                   	push   %ecx
801053ec:	52                   	push   %edx
801053ed:	50                   	push   %eax
801053ee:	e8 f1 bd ff ff       	call   801011e4 <fileread>
801053f3:	83 c4 10             	add    $0x10,%esp
}
801053f6:	c9                   	leave
801053f7:	c3                   	ret

801053f8 <sys_write>:

int
sys_write(void)
{
801053f8:	55                   	push   %ebp
801053f9:	89 e5                	mov    %esp,%ebp
801053fb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053fe:	83 ec 04             	sub    $0x4,%esp
80105401:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105404:	50                   	push   %eax
80105405:	6a 00                	push   $0x0
80105407:	6a 00                	push   $0x0
80105409:	e8 66 fe ff ff       	call   80105274 <argfd>
8010540e:	83 c4 10             	add    $0x10,%esp
80105411:	85 c0                	test   %eax,%eax
80105413:	78 2e                	js     80105443 <sys_write+0x4b>
80105415:	83 ec 08             	sub    $0x8,%esp
80105418:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010541b:	50                   	push   %eax
8010541c:	6a 02                	push   $0x2
8010541e:	e8 07 fd ff ff       	call   8010512a <argint>
80105423:	83 c4 10             	add    $0x10,%esp
80105426:	85 c0                	test   %eax,%eax
80105428:	78 19                	js     80105443 <sys_write+0x4b>
8010542a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542d:	83 ec 04             	sub    $0x4,%esp
80105430:	50                   	push   %eax
80105431:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105434:	50                   	push   %eax
80105435:	6a 01                	push   $0x1
80105437:	e8 1b fd ff ff       	call   80105157 <argptr>
8010543c:	83 c4 10             	add    $0x10,%esp
8010543f:	85 c0                	test   %eax,%eax
80105441:	79 07                	jns    8010544a <sys_write+0x52>
    return -1;
80105443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105448:	eb 17                	jmp    80105461 <sys_write+0x69>
  return filewrite(f, p, n);
8010544a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010544d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105453:	83 ec 04             	sub    $0x4,%esp
80105456:	51                   	push   %ecx
80105457:	52                   	push   %edx
80105458:	50                   	push   %eax
80105459:	e8 3e be ff ff       	call   8010129c <filewrite>
8010545e:	83 c4 10             	add    $0x10,%esp
}
80105461:	c9                   	leave
80105462:	c3                   	ret

80105463 <sys_close>:

int
sys_close(void)
{
80105463:	55                   	push   %ebp
80105464:	89 e5                	mov    %esp,%ebp
80105466:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105469:	83 ec 04             	sub    $0x4,%esp
8010546c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010546f:	50                   	push   %eax
80105470:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105473:	50                   	push   %eax
80105474:	6a 00                	push   $0x0
80105476:	e8 f9 fd ff ff       	call   80105274 <argfd>
8010547b:	83 c4 10             	add    $0x10,%esp
8010547e:	85 c0                	test   %eax,%eax
80105480:	79 07                	jns    80105489 <sys_close+0x26>
    return -1;
80105482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105487:	eb 27                	jmp    801054b0 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105489:	e8 a9 e5 ff ff       	call   80103a37 <myproc>
8010548e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105491:	83 c2 08             	add    $0x8,%edx
80105494:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010549b:	00 
  fileclose(f);
8010549c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010549f:	83 ec 0c             	sub    $0xc,%esp
801054a2:	50                   	push   %eax
801054a3:	e8 fd bb ff ff       	call   801010a5 <fileclose>
801054a8:	83 c4 10             	add    $0x10,%esp
  return 0;
801054ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054b0:	c9                   	leave
801054b1:	c3                   	ret

801054b2 <sys_fstat>:

int
sys_fstat(void)
{
801054b2:	55                   	push   %ebp
801054b3:	89 e5                	mov    %esp,%ebp
801054b5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054b8:	83 ec 04             	sub    $0x4,%esp
801054bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054be:	50                   	push   %eax
801054bf:	6a 00                	push   $0x0
801054c1:	6a 00                	push   $0x0
801054c3:	e8 ac fd ff ff       	call   80105274 <argfd>
801054c8:	83 c4 10             	add    $0x10,%esp
801054cb:	85 c0                	test   %eax,%eax
801054cd:	78 17                	js     801054e6 <sys_fstat+0x34>
801054cf:	83 ec 04             	sub    $0x4,%esp
801054d2:	6a 14                	push   $0x14
801054d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054d7:	50                   	push   %eax
801054d8:	6a 01                	push   $0x1
801054da:	e8 78 fc ff ff       	call   80105157 <argptr>
801054df:	83 c4 10             	add    $0x10,%esp
801054e2:	85 c0                	test   %eax,%eax
801054e4:	79 07                	jns    801054ed <sys_fstat+0x3b>
    return -1;
801054e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054eb:	eb 13                	jmp    80105500 <sys_fstat+0x4e>
  return filestat(f, st);
801054ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f3:	83 ec 08             	sub    $0x8,%esp
801054f6:	52                   	push   %edx
801054f7:	50                   	push   %eax
801054f8:	e8 90 bc ff ff       	call   8010118d <filestat>
801054fd:	83 c4 10             	add    $0x10,%esp
}
80105500:	c9                   	leave
80105501:	c3                   	ret

80105502 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105502:	55                   	push   %ebp
80105503:	89 e5                	mov    %esp,%ebp
80105505:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105508:	83 ec 08             	sub    $0x8,%esp
8010550b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010550e:	50                   	push   %eax
8010550f:	6a 00                	push   $0x0
80105511:	e8 a9 fc ff ff       	call   801051bf <argstr>
80105516:	83 c4 10             	add    $0x10,%esp
80105519:	85 c0                	test   %eax,%eax
8010551b:	78 15                	js     80105532 <sys_link+0x30>
8010551d:	83 ec 08             	sub    $0x8,%esp
80105520:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105523:	50                   	push   %eax
80105524:	6a 01                	push   $0x1
80105526:	e8 94 fc ff ff       	call   801051bf <argstr>
8010552b:	83 c4 10             	add    $0x10,%esp
8010552e:	85 c0                	test   %eax,%eax
80105530:	79 0a                	jns    8010553c <sys_link+0x3a>
    return -1;
80105532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105537:	e9 68 01 00 00       	jmp    801056a4 <sys_link+0x1a2>

  begin_op();
8010553c:	e8 fd da ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105541:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105544:	83 ec 0c             	sub    $0xc,%esp
80105547:	50                   	push   %eax
80105548:	e8 d8 cf ff ff       	call   80102525 <namei>
8010554d:	83 c4 10             	add    $0x10,%esp
80105550:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105553:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105557:	75 0f                	jne    80105568 <sys_link+0x66>
    end_op();
80105559:	e8 6c db ff ff       	call   801030ca <end_op>
    return -1;
8010555e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105563:	e9 3c 01 00 00       	jmp    801056a4 <sys_link+0x1a2>
  }

  ilock(ip);
80105568:	83 ec 0c             	sub    $0xc,%esp
8010556b:	ff 75 f4             	push   -0xc(%ebp)
8010556e:	e8 7f c4 ff ff       	call   801019f2 <ilock>
80105573:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105579:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010557d:	66 83 f8 01          	cmp    $0x1,%ax
80105581:	75 1d                	jne    801055a0 <sys_link+0x9e>
    iunlockput(ip);
80105583:	83 ec 0c             	sub    $0xc,%esp
80105586:	ff 75 f4             	push   -0xc(%ebp)
80105589:	e8 95 c6 ff ff       	call   80101c23 <iunlockput>
8010558e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105591:	e8 34 db ff ff       	call   801030ca <end_op>
    return -1;
80105596:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010559b:	e9 04 01 00 00       	jmp    801056a4 <sys_link+0x1a2>
  }

  ip->nlink++;
801055a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055a7:	83 c0 01             	add    $0x1,%eax
801055aa:	89 c2                	mov    %eax,%edx
801055ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055af:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055b3:	83 ec 0c             	sub    $0xc,%esp
801055b6:	ff 75 f4             	push   -0xc(%ebp)
801055b9:	e8 57 c2 ff ff       	call   80101815 <iupdate>
801055be:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801055c1:	83 ec 0c             	sub    $0xc,%esp
801055c4:	ff 75 f4             	push   -0xc(%ebp)
801055c7:	e8 39 c5 ff ff       	call   80101b05 <iunlock>
801055cc:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801055cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055d2:	83 ec 08             	sub    $0x8,%esp
801055d5:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055d8:	52                   	push   %edx
801055d9:	50                   	push   %eax
801055da:	e8 62 cf ff ff       	call   80102541 <nameiparent>
801055df:	83 c4 10             	add    $0x10,%esp
801055e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055e9:	74 71                	je     8010565c <sys_link+0x15a>
    goto bad;
  ilock(dp);
801055eb:	83 ec 0c             	sub    $0xc,%esp
801055ee:	ff 75 f0             	push   -0x10(%ebp)
801055f1:	e8 fc c3 ff ff       	call   801019f2 <ilock>
801055f6:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801055f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055fc:	8b 10                	mov    (%eax),%edx
801055fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105601:	8b 00                	mov    (%eax),%eax
80105603:	39 c2                	cmp    %eax,%edx
80105605:	75 1d                	jne    80105624 <sys_link+0x122>
80105607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560a:	8b 40 04             	mov    0x4(%eax),%eax
8010560d:	83 ec 04             	sub    $0x4,%esp
80105610:	50                   	push   %eax
80105611:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105614:	50                   	push   %eax
80105615:	ff 75 f0             	push   -0x10(%ebp)
80105618:	e8 71 cc ff ff       	call   8010228e <dirlink>
8010561d:	83 c4 10             	add    $0x10,%esp
80105620:	85 c0                	test   %eax,%eax
80105622:	79 10                	jns    80105634 <sys_link+0x132>
    iunlockput(dp);
80105624:	83 ec 0c             	sub    $0xc,%esp
80105627:	ff 75 f0             	push   -0x10(%ebp)
8010562a:	e8 f4 c5 ff ff       	call   80101c23 <iunlockput>
8010562f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105632:	eb 29                	jmp    8010565d <sys_link+0x15b>
  }
  iunlockput(dp);
80105634:	83 ec 0c             	sub    $0xc,%esp
80105637:	ff 75 f0             	push   -0x10(%ebp)
8010563a:	e8 e4 c5 ff ff       	call   80101c23 <iunlockput>
8010563f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105642:	83 ec 0c             	sub    $0xc,%esp
80105645:	ff 75 f4             	push   -0xc(%ebp)
80105648:	e8 06 c5 ff ff       	call   80101b53 <iput>
8010564d:	83 c4 10             	add    $0x10,%esp

  end_op();
80105650:	e8 75 da ff ff       	call   801030ca <end_op>

  return 0;
80105655:	b8 00 00 00 00       	mov    $0x0,%eax
8010565a:	eb 48                	jmp    801056a4 <sys_link+0x1a2>
    goto bad;
8010565c:	90                   	nop

bad:
  ilock(ip);
8010565d:	83 ec 0c             	sub    $0xc,%esp
80105660:	ff 75 f4             	push   -0xc(%ebp)
80105663:	e8 8a c3 ff ff       	call   801019f2 <ilock>
80105668:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010566b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105672:	83 e8 01             	sub    $0x1,%eax
80105675:	89 c2                	mov    %eax,%edx
80105677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010567e:	83 ec 0c             	sub    $0xc,%esp
80105681:	ff 75 f4             	push   -0xc(%ebp)
80105684:	e8 8c c1 ff ff       	call   80101815 <iupdate>
80105689:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010568c:	83 ec 0c             	sub    $0xc,%esp
8010568f:	ff 75 f4             	push   -0xc(%ebp)
80105692:	e8 8c c5 ff ff       	call   80101c23 <iunlockput>
80105697:	83 c4 10             	add    $0x10,%esp
  end_op();
8010569a:	e8 2b da ff ff       	call   801030ca <end_op>
  return -1;
8010569f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056a4:	c9                   	leave
801056a5:	c3                   	ret

801056a6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056a6:	55                   	push   %ebp
801056a7:	89 e5                	mov    %esp,%ebp
801056a9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056ac:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801056b3:	eb 40                	jmp    801056f5 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b8:	6a 10                	push   $0x10
801056ba:	50                   	push   %eax
801056bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056be:	50                   	push   %eax
801056bf:	ff 75 08             	push   0x8(%ebp)
801056c2:	e8 17 c8 ff ff       	call   80101ede <readi>
801056c7:	83 c4 10             	add    $0x10,%esp
801056ca:	83 f8 10             	cmp    $0x10,%eax
801056cd:	74 0d                	je     801056dc <isdirempty+0x36>
      panic("isdirempty: readi");
801056cf:	83 ec 0c             	sub    $0xc,%esp
801056d2:	68 b4 a8 10 80       	push   $0x8010a8b4
801056d7:	e8 cd ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801056dc:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056e0:	66 85 c0             	test   %ax,%ax
801056e3:	74 07                	je     801056ec <isdirempty+0x46>
      return 0;
801056e5:	b8 00 00 00 00       	mov    $0x0,%eax
801056ea:	eb 1b                	jmp    80105707 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ef:	83 c0 10             	add    $0x10,%eax
801056f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056f5:	8b 45 08             	mov    0x8(%ebp),%eax
801056f8:	8b 40 58             	mov    0x58(%eax),%eax
801056fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056fe:	39 c2                	cmp    %eax,%edx
80105700:	72 b3                	jb     801056b5 <isdirempty+0xf>
  }
  return 1;
80105702:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105707:	c9                   	leave
80105708:	c3                   	ret

80105709 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105709:	55                   	push   %ebp
8010570a:	89 e5                	mov    %esp,%ebp
8010570c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010570f:	83 ec 08             	sub    $0x8,%esp
80105712:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105715:	50                   	push   %eax
80105716:	6a 00                	push   $0x0
80105718:	e8 a2 fa ff ff       	call   801051bf <argstr>
8010571d:	83 c4 10             	add    $0x10,%esp
80105720:	85 c0                	test   %eax,%eax
80105722:	79 0a                	jns    8010572e <sys_unlink+0x25>
    return -1;
80105724:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105729:	e9 bf 01 00 00       	jmp    801058ed <sys_unlink+0x1e4>

  begin_op();
8010572e:	e8 0b d9 ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105733:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105736:	83 ec 08             	sub    $0x8,%esp
80105739:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010573c:	52                   	push   %edx
8010573d:	50                   	push   %eax
8010573e:	e8 fe cd ff ff       	call   80102541 <nameiparent>
80105743:	83 c4 10             	add    $0x10,%esp
80105746:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105749:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010574d:	75 0f                	jne    8010575e <sys_unlink+0x55>
    end_op();
8010574f:	e8 76 d9 ff ff       	call   801030ca <end_op>
    return -1;
80105754:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105759:	e9 8f 01 00 00       	jmp    801058ed <sys_unlink+0x1e4>
  }

  ilock(dp);
8010575e:	83 ec 0c             	sub    $0xc,%esp
80105761:	ff 75 f4             	push   -0xc(%ebp)
80105764:	e8 89 c2 ff ff       	call   801019f2 <ilock>
80105769:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010576c:	83 ec 08             	sub    $0x8,%esp
8010576f:	68 c6 a8 10 80       	push   $0x8010a8c6
80105774:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105777:	50                   	push   %eax
80105778:	e8 3c ca ff ff       	call   801021b9 <namecmp>
8010577d:	83 c4 10             	add    $0x10,%esp
80105780:	85 c0                	test   %eax,%eax
80105782:	0f 84 49 01 00 00    	je     801058d1 <sys_unlink+0x1c8>
80105788:	83 ec 08             	sub    $0x8,%esp
8010578b:	68 c8 a8 10 80       	push   $0x8010a8c8
80105790:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105793:	50                   	push   %eax
80105794:	e8 20 ca ff ff       	call   801021b9 <namecmp>
80105799:	83 c4 10             	add    $0x10,%esp
8010579c:	85 c0                	test   %eax,%eax
8010579e:	0f 84 2d 01 00 00    	je     801058d1 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057a4:	83 ec 04             	sub    $0x4,%esp
801057a7:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057aa:	50                   	push   %eax
801057ab:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057ae:	50                   	push   %eax
801057af:	ff 75 f4             	push   -0xc(%ebp)
801057b2:	e8 1d ca ff ff       	call   801021d4 <dirlookup>
801057b7:	83 c4 10             	add    $0x10,%esp
801057ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057c1:	0f 84 0d 01 00 00    	je     801058d4 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801057c7:	83 ec 0c             	sub    $0xc,%esp
801057ca:	ff 75 f0             	push   -0x10(%ebp)
801057cd:	e8 20 c2 ff ff       	call   801019f2 <ilock>
801057d2:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801057d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057dc:	66 85 c0             	test   %ax,%ax
801057df:	7f 0d                	jg     801057ee <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801057e1:	83 ec 0c             	sub    $0xc,%esp
801057e4:	68 cb a8 10 80       	push   $0x8010a8cb
801057e9:	e8 bb ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801057ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057f5:	66 83 f8 01          	cmp    $0x1,%ax
801057f9:	75 25                	jne    80105820 <sys_unlink+0x117>
801057fb:	83 ec 0c             	sub    $0xc,%esp
801057fe:	ff 75 f0             	push   -0x10(%ebp)
80105801:	e8 a0 fe ff ff       	call   801056a6 <isdirempty>
80105806:	83 c4 10             	add    $0x10,%esp
80105809:	85 c0                	test   %eax,%eax
8010580b:	75 13                	jne    80105820 <sys_unlink+0x117>
    iunlockput(ip);
8010580d:	83 ec 0c             	sub    $0xc,%esp
80105810:	ff 75 f0             	push   -0x10(%ebp)
80105813:	e8 0b c4 ff ff       	call   80101c23 <iunlockput>
80105818:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010581b:	e9 b5 00 00 00       	jmp    801058d5 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105820:	83 ec 04             	sub    $0x4,%esp
80105823:	6a 10                	push   $0x10
80105825:	6a 00                	push   $0x0
80105827:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010582a:	50                   	push   %eax
8010582b:	e8 cf f5 ff ff       	call   80104dff <memset>
80105830:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105833:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105836:	6a 10                	push   $0x10
80105838:	50                   	push   %eax
80105839:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010583c:	50                   	push   %eax
8010583d:	ff 75 f4             	push   -0xc(%ebp)
80105840:	e8 ee c7 ff ff       	call   80102033 <writei>
80105845:	83 c4 10             	add    $0x10,%esp
80105848:	83 f8 10             	cmp    $0x10,%eax
8010584b:	74 0d                	je     8010585a <sys_unlink+0x151>
    panic("unlink: writei");
8010584d:	83 ec 0c             	sub    $0xc,%esp
80105850:	68 dd a8 10 80       	push   $0x8010a8dd
80105855:	e8 4f ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
8010585a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105861:	66 83 f8 01          	cmp    $0x1,%ax
80105865:	75 21                	jne    80105888 <sys_unlink+0x17f>
    dp->nlink--;
80105867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010586e:	83 e8 01             	sub    $0x1,%eax
80105871:	89 c2                	mov    %eax,%edx
80105873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105876:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010587a:	83 ec 0c             	sub    $0xc,%esp
8010587d:	ff 75 f4             	push   -0xc(%ebp)
80105880:	e8 90 bf ff ff       	call   80101815 <iupdate>
80105885:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105888:	83 ec 0c             	sub    $0xc,%esp
8010588b:	ff 75 f4             	push   -0xc(%ebp)
8010588e:	e8 90 c3 ff ff       	call   80101c23 <iunlockput>
80105893:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105899:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010589d:	83 e8 01             	sub    $0x1,%eax
801058a0:	89 c2                	mov    %eax,%edx
801058a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a5:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801058a9:	83 ec 0c             	sub    $0xc,%esp
801058ac:	ff 75 f0             	push   -0x10(%ebp)
801058af:	e8 61 bf ff ff       	call   80101815 <iupdate>
801058b4:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801058b7:	83 ec 0c             	sub    $0xc,%esp
801058ba:	ff 75 f0             	push   -0x10(%ebp)
801058bd:	e8 61 c3 ff ff       	call   80101c23 <iunlockput>
801058c2:	83 c4 10             	add    $0x10,%esp

  end_op();
801058c5:	e8 00 d8 ff ff       	call   801030ca <end_op>

  return 0;
801058ca:	b8 00 00 00 00       	mov    $0x0,%eax
801058cf:	eb 1c                	jmp    801058ed <sys_unlink+0x1e4>
    goto bad;
801058d1:	90                   	nop
801058d2:	eb 01                	jmp    801058d5 <sys_unlink+0x1cc>
    goto bad;
801058d4:	90                   	nop

bad:
  iunlockput(dp);
801058d5:	83 ec 0c             	sub    $0xc,%esp
801058d8:	ff 75 f4             	push   -0xc(%ebp)
801058db:	e8 43 c3 ff ff       	call   80101c23 <iunlockput>
801058e0:	83 c4 10             	add    $0x10,%esp
  end_op();
801058e3:	e8 e2 d7 ff ff       	call   801030ca <end_op>
  return -1;
801058e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058ed:	c9                   	leave
801058ee:	c3                   	ret

801058ef <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801058ef:	55                   	push   %ebp
801058f0:	89 e5                	mov    %esp,%ebp
801058f2:	83 ec 38             	sub    $0x38,%esp
801058f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801058f8:	8b 55 10             	mov    0x10(%ebp),%edx
801058fb:	8b 45 14             	mov    0x14(%ebp),%eax
801058fe:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105902:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105906:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010590a:	83 ec 08             	sub    $0x8,%esp
8010590d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105910:	50                   	push   %eax
80105911:	ff 75 08             	push   0x8(%ebp)
80105914:	e8 28 cc ff ff       	call   80102541 <nameiparent>
80105919:	83 c4 10             	add    $0x10,%esp
8010591c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010591f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105923:	75 0a                	jne    8010592f <create+0x40>
    return 0;
80105925:	b8 00 00 00 00       	mov    $0x0,%eax
8010592a:	e9 90 01 00 00       	jmp    80105abf <create+0x1d0>
  ilock(dp);
8010592f:	83 ec 0c             	sub    $0xc,%esp
80105932:	ff 75 f4             	push   -0xc(%ebp)
80105935:	e8 b8 c0 ff ff       	call   801019f2 <ilock>
8010593a:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010593d:	83 ec 04             	sub    $0x4,%esp
80105940:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105943:	50                   	push   %eax
80105944:	8d 45 de             	lea    -0x22(%ebp),%eax
80105947:	50                   	push   %eax
80105948:	ff 75 f4             	push   -0xc(%ebp)
8010594b:	e8 84 c8 ff ff       	call   801021d4 <dirlookup>
80105950:	83 c4 10             	add    $0x10,%esp
80105953:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105956:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010595a:	74 50                	je     801059ac <create+0xbd>
    iunlockput(dp);
8010595c:	83 ec 0c             	sub    $0xc,%esp
8010595f:	ff 75 f4             	push   -0xc(%ebp)
80105962:	e8 bc c2 ff ff       	call   80101c23 <iunlockput>
80105967:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010596a:	83 ec 0c             	sub    $0xc,%esp
8010596d:	ff 75 f0             	push   -0x10(%ebp)
80105970:	e8 7d c0 ff ff       	call   801019f2 <ilock>
80105975:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105978:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010597d:	75 15                	jne    80105994 <create+0xa5>
8010597f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105982:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105986:	66 83 f8 02          	cmp    $0x2,%ax
8010598a:	75 08                	jne    80105994 <create+0xa5>
      return ip;
8010598c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598f:	e9 2b 01 00 00       	jmp    80105abf <create+0x1d0>
    iunlockput(ip);
80105994:	83 ec 0c             	sub    $0xc,%esp
80105997:	ff 75 f0             	push   -0x10(%ebp)
8010599a:	e8 84 c2 ff ff       	call   80101c23 <iunlockput>
8010599f:	83 c4 10             	add    $0x10,%esp
    return 0;
801059a2:	b8 00 00 00 00       	mov    $0x0,%eax
801059a7:	e9 13 01 00 00       	jmp    80105abf <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801059ac:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801059b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b3:	8b 00                	mov    (%eax),%eax
801059b5:	83 ec 08             	sub    $0x8,%esp
801059b8:	52                   	push   %edx
801059b9:	50                   	push   %eax
801059ba:	e8 80 bd ff ff       	call   8010173f <ialloc>
801059bf:	83 c4 10             	add    $0x10,%esp
801059c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059c9:	75 0d                	jne    801059d8 <create+0xe9>
    panic("create: ialloc");
801059cb:	83 ec 0c             	sub    $0xc,%esp
801059ce:	68 ec a8 10 80       	push   $0x8010a8ec
801059d3:	e8 d1 ab ff ff       	call   801005a9 <panic>

  ilock(ip);
801059d8:	83 ec 0c             	sub    $0xc,%esp
801059db:	ff 75 f0             	push   -0x10(%ebp)
801059de:	e8 0f c0 ff ff       	call   801019f2 <ilock>
801059e3:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801059e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e9:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801059ed:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801059f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f4:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801059f8:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801059fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ff:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a05:	83 ec 0c             	sub    $0xc,%esp
80105a08:	ff 75 f0             	push   -0x10(%ebp)
80105a0b:	e8 05 be ff ff       	call   80101815 <iupdate>
80105a10:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a13:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a18:	75 6a                	jne    80105a84 <create+0x195>
    dp->nlink++;  // for ".."
80105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a21:	83 c0 01             	add    $0x1,%eax
80105a24:	89 c2                	mov    %eax,%edx
80105a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a29:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a2d:	83 ec 0c             	sub    $0xc,%esp
80105a30:	ff 75 f4             	push   -0xc(%ebp)
80105a33:	e8 dd bd ff ff       	call   80101815 <iupdate>
80105a38:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3e:	8b 40 04             	mov    0x4(%eax),%eax
80105a41:	83 ec 04             	sub    $0x4,%esp
80105a44:	50                   	push   %eax
80105a45:	68 c6 a8 10 80       	push   $0x8010a8c6
80105a4a:	ff 75 f0             	push   -0x10(%ebp)
80105a4d:	e8 3c c8 ff ff       	call   8010228e <dirlink>
80105a52:	83 c4 10             	add    $0x10,%esp
80105a55:	85 c0                	test   %eax,%eax
80105a57:	78 1e                	js     80105a77 <create+0x188>
80105a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5c:	8b 40 04             	mov    0x4(%eax),%eax
80105a5f:	83 ec 04             	sub    $0x4,%esp
80105a62:	50                   	push   %eax
80105a63:	68 c8 a8 10 80       	push   $0x8010a8c8
80105a68:	ff 75 f0             	push   -0x10(%ebp)
80105a6b:	e8 1e c8 ff ff       	call   8010228e <dirlink>
80105a70:	83 c4 10             	add    $0x10,%esp
80105a73:	85 c0                	test   %eax,%eax
80105a75:	79 0d                	jns    80105a84 <create+0x195>
      panic("create dots");
80105a77:	83 ec 0c             	sub    $0xc,%esp
80105a7a:	68 fb a8 10 80       	push   $0x8010a8fb
80105a7f:	e8 25 ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	8b 40 04             	mov    0x4(%eax),%eax
80105a8a:	83 ec 04             	sub    $0x4,%esp
80105a8d:	50                   	push   %eax
80105a8e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a91:	50                   	push   %eax
80105a92:	ff 75 f4             	push   -0xc(%ebp)
80105a95:	e8 f4 c7 ff ff       	call   8010228e <dirlink>
80105a9a:	83 c4 10             	add    $0x10,%esp
80105a9d:	85 c0                	test   %eax,%eax
80105a9f:	79 0d                	jns    80105aae <create+0x1bf>
    panic("create: dirlink");
80105aa1:	83 ec 0c             	sub    $0xc,%esp
80105aa4:	68 07 a9 10 80       	push   $0x8010a907
80105aa9:	e8 fb aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105aae:	83 ec 0c             	sub    $0xc,%esp
80105ab1:	ff 75 f4             	push   -0xc(%ebp)
80105ab4:	e8 6a c1 ff ff       	call   80101c23 <iunlockput>
80105ab9:	83 c4 10             	add    $0x10,%esp

  return ip;
80105abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105abf:	c9                   	leave
80105ac0:	c3                   	ret

80105ac1 <sys_open>:

int
sys_open(void)
{
80105ac1:	55                   	push   %ebp
80105ac2:	89 e5                	mov    %esp,%ebp
80105ac4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ac7:	83 ec 08             	sub    $0x8,%esp
80105aca:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105acd:	50                   	push   %eax
80105ace:	6a 00                	push   $0x0
80105ad0:	e8 ea f6 ff ff       	call   801051bf <argstr>
80105ad5:	83 c4 10             	add    $0x10,%esp
80105ad8:	85 c0                	test   %eax,%eax
80105ada:	78 15                	js     80105af1 <sys_open+0x30>
80105adc:	83 ec 08             	sub    $0x8,%esp
80105adf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ae2:	50                   	push   %eax
80105ae3:	6a 01                	push   $0x1
80105ae5:	e8 40 f6 ff ff       	call   8010512a <argint>
80105aea:	83 c4 10             	add    $0x10,%esp
80105aed:	85 c0                	test   %eax,%eax
80105aef:	79 0a                	jns    80105afb <sys_open+0x3a>
    return -1;
80105af1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af6:	e9 61 01 00 00       	jmp    80105c5c <sys_open+0x19b>

  begin_op();
80105afb:	e8 3e d5 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80105b00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b03:	25 00 02 00 00       	and    $0x200,%eax
80105b08:	85 c0                	test   %eax,%eax
80105b0a:	74 2a                	je     80105b36 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b0f:	6a 00                	push   $0x0
80105b11:	6a 00                	push   $0x0
80105b13:	6a 02                	push   $0x2
80105b15:	50                   	push   %eax
80105b16:	e8 d4 fd ff ff       	call   801058ef <create>
80105b1b:	83 c4 10             	add    $0x10,%esp
80105b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b25:	75 75                	jne    80105b9c <sys_open+0xdb>
      end_op();
80105b27:	e8 9e d5 ff ff       	call   801030ca <end_op>
      return -1;
80105b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b31:	e9 26 01 00 00       	jmp    80105c5c <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b39:	83 ec 0c             	sub    $0xc,%esp
80105b3c:	50                   	push   %eax
80105b3d:	e8 e3 c9 ff ff       	call   80102525 <namei>
80105b42:	83 c4 10             	add    $0x10,%esp
80105b45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b4c:	75 0f                	jne    80105b5d <sys_open+0x9c>
      end_op();
80105b4e:	e8 77 d5 ff ff       	call   801030ca <end_op>
      return -1;
80105b53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b58:	e9 ff 00 00 00       	jmp    80105c5c <sys_open+0x19b>
    }
    ilock(ip);
80105b5d:	83 ec 0c             	sub    $0xc,%esp
80105b60:	ff 75 f4             	push   -0xc(%ebp)
80105b63:	e8 8a be ff ff       	call   801019f2 <ilock>
80105b68:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b72:	66 83 f8 01          	cmp    $0x1,%ax
80105b76:	75 24                	jne    80105b9c <sys_open+0xdb>
80105b78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b7b:	85 c0                	test   %eax,%eax
80105b7d:	74 1d                	je     80105b9c <sys_open+0xdb>
      iunlockput(ip);
80105b7f:	83 ec 0c             	sub    $0xc,%esp
80105b82:	ff 75 f4             	push   -0xc(%ebp)
80105b85:	e8 99 c0 ff ff       	call   80101c23 <iunlockput>
80105b8a:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b8d:	e8 38 d5 ff ff       	call   801030ca <end_op>
      return -1;
80105b92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b97:	e9 c0 00 00 00       	jmp    80105c5c <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b9c:	e8 46 b4 ff ff       	call   80100fe7 <filealloc>
80105ba1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ba4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ba8:	74 17                	je     80105bc1 <sys_open+0x100>
80105baa:	83 ec 0c             	sub    $0xc,%esp
80105bad:	ff 75 f0             	push   -0x10(%ebp)
80105bb0:	e8 33 f7 ff ff       	call   801052e8 <fdalloc>
80105bb5:	83 c4 10             	add    $0x10,%esp
80105bb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105bbb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105bbf:	79 2e                	jns    80105bef <sys_open+0x12e>
    if(f)
80105bc1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bc5:	74 0e                	je     80105bd5 <sys_open+0x114>
      fileclose(f);
80105bc7:	83 ec 0c             	sub    $0xc,%esp
80105bca:	ff 75 f0             	push   -0x10(%ebp)
80105bcd:	e8 d3 b4 ff ff       	call   801010a5 <fileclose>
80105bd2:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105bd5:	83 ec 0c             	sub    $0xc,%esp
80105bd8:	ff 75 f4             	push   -0xc(%ebp)
80105bdb:	e8 43 c0 ff ff       	call   80101c23 <iunlockput>
80105be0:	83 c4 10             	add    $0x10,%esp
    end_op();
80105be3:	e8 e2 d4 ff ff       	call   801030ca <end_op>
    return -1;
80105be8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bed:	eb 6d                	jmp    80105c5c <sys_open+0x19b>
  }
  iunlock(ip);
80105bef:	83 ec 0c             	sub    $0xc,%esp
80105bf2:	ff 75 f4             	push   -0xc(%ebp)
80105bf5:	e8 0b bf ff ff       	call   80101b05 <iunlock>
80105bfa:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bfd:	e8 c8 d4 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
80105c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c05:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c11:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c17:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c21:	83 e0 01             	and    $0x1,%eax
80105c24:	85 c0                	test   %eax,%eax
80105c26:	0f 94 c0             	sete   %al
80105c29:	89 c2                	mov    %eax,%edx
80105c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2e:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c34:	83 e0 01             	and    $0x1,%eax
80105c37:	85 c0                	test   %eax,%eax
80105c39:	75 0a                	jne    80105c45 <sys_open+0x184>
80105c3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c3e:	83 e0 02             	and    $0x2,%eax
80105c41:	85 c0                	test   %eax,%eax
80105c43:	74 07                	je     80105c4c <sys_open+0x18b>
80105c45:	b8 01 00 00 00       	mov    $0x1,%eax
80105c4a:	eb 05                	jmp    80105c51 <sys_open+0x190>
80105c4c:	b8 00 00 00 00       	mov    $0x0,%eax
80105c51:	89 c2                	mov    %eax,%edx
80105c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c56:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c59:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c5c:	c9                   	leave
80105c5d:	c3                   	ret

80105c5e <sys_mkdir>:

int
sys_mkdir(void)
{
80105c5e:	55                   	push   %ebp
80105c5f:	89 e5                	mov    %esp,%ebp
80105c61:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c64:	e8 d5 d3 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c69:	83 ec 08             	sub    $0x8,%esp
80105c6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c6f:	50                   	push   %eax
80105c70:	6a 00                	push   $0x0
80105c72:	e8 48 f5 ff ff       	call   801051bf <argstr>
80105c77:	83 c4 10             	add    $0x10,%esp
80105c7a:	85 c0                	test   %eax,%eax
80105c7c:	78 1b                	js     80105c99 <sys_mkdir+0x3b>
80105c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c81:	6a 00                	push   $0x0
80105c83:	6a 00                	push   $0x0
80105c85:	6a 01                	push   $0x1
80105c87:	50                   	push   %eax
80105c88:	e8 62 fc ff ff       	call   801058ef <create>
80105c8d:	83 c4 10             	add    $0x10,%esp
80105c90:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c97:	75 0c                	jne    80105ca5 <sys_mkdir+0x47>
    end_op();
80105c99:	e8 2c d4 ff ff       	call   801030ca <end_op>
    return -1;
80105c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca3:	eb 18                	jmp    80105cbd <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105ca5:	83 ec 0c             	sub    $0xc,%esp
80105ca8:	ff 75 f4             	push   -0xc(%ebp)
80105cab:	e8 73 bf ff ff       	call   80101c23 <iunlockput>
80105cb0:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cb3:	e8 12 d4 ff ff       	call   801030ca <end_op>
  return 0;
80105cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cbd:	c9                   	leave
80105cbe:	c3                   	ret

80105cbf <sys_mknod>:

int
sys_mknod(void)
{
80105cbf:	55                   	push   %ebp
80105cc0:	89 e5                	mov    %esp,%ebp
80105cc2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105cc5:	e8 74 d3 ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
80105cca:	83 ec 08             	sub    $0x8,%esp
80105ccd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cd0:	50                   	push   %eax
80105cd1:	6a 00                	push   $0x0
80105cd3:	e8 e7 f4 ff ff       	call   801051bf <argstr>
80105cd8:	83 c4 10             	add    $0x10,%esp
80105cdb:	85 c0                	test   %eax,%eax
80105cdd:	78 4f                	js     80105d2e <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105cdf:	83 ec 08             	sub    $0x8,%esp
80105ce2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ce5:	50                   	push   %eax
80105ce6:	6a 01                	push   $0x1
80105ce8:	e8 3d f4 ff ff       	call   8010512a <argint>
80105ced:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105cf0:	85 c0                	test   %eax,%eax
80105cf2:	78 3a                	js     80105d2e <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105cf4:	83 ec 08             	sub    $0x8,%esp
80105cf7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cfa:	50                   	push   %eax
80105cfb:	6a 02                	push   $0x2
80105cfd:	e8 28 f4 ff ff       	call   8010512a <argint>
80105d02:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d05:	85 c0                	test   %eax,%eax
80105d07:	78 25                	js     80105d2e <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d0c:	0f bf c8             	movswl %ax,%ecx
80105d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d12:	0f bf d0             	movswl %ax,%edx
80105d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d18:	51                   	push   %ecx
80105d19:	52                   	push   %edx
80105d1a:	6a 03                	push   $0x3
80105d1c:	50                   	push   %eax
80105d1d:	e8 cd fb ff ff       	call   801058ef <create>
80105d22:	83 c4 10             	add    $0x10,%esp
80105d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d2c:	75 0c                	jne    80105d3a <sys_mknod+0x7b>
    end_op();
80105d2e:	e8 97 d3 ff ff       	call   801030ca <end_op>
    return -1;
80105d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d38:	eb 18                	jmp    80105d52 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	ff 75 f4             	push   -0xc(%ebp)
80105d40:	e8 de be ff ff       	call   80101c23 <iunlockput>
80105d45:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d48:	e8 7d d3 ff ff       	call   801030ca <end_op>
  return 0;
80105d4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d52:	c9                   	leave
80105d53:	c3                   	ret

80105d54 <sys_chdir>:

int
sys_chdir(void)
{
80105d54:	55                   	push   %ebp
80105d55:	89 e5                	mov    %esp,%ebp
80105d57:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105d5a:	e8 d8 dc ff ff       	call   80103a37 <myproc>
80105d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105d62:	e8 d7 d2 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d67:	83 ec 08             	sub    $0x8,%esp
80105d6a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d6d:	50                   	push   %eax
80105d6e:	6a 00                	push   $0x0
80105d70:	e8 4a f4 ff ff       	call   801051bf <argstr>
80105d75:	83 c4 10             	add    $0x10,%esp
80105d78:	85 c0                	test   %eax,%eax
80105d7a:	78 18                	js     80105d94 <sys_chdir+0x40>
80105d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d7f:	83 ec 0c             	sub    $0xc,%esp
80105d82:	50                   	push   %eax
80105d83:	e8 9d c7 ff ff       	call   80102525 <namei>
80105d88:	83 c4 10             	add    $0x10,%esp
80105d8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d92:	75 0c                	jne    80105da0 <sys_chdir+0x4c>
    end_op();
80105d94:	e8 31 d3 ff ff       	call   801030ca <end_op>
    return -1;
80105d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9e:	eb 68                	jmp    80105e08 <sys_chdir+0xb4>
  }
  ilock(ip);
80105da0:	83 ec 0c             	sub    $0xc,%esp
80105da3:	ff 75 f0             	push   -0x10(%ebp)
80105da6:	e8 47 bc ff ff       	call   801019f2 <ilock>
80105dab:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105db5:	66 83 f8 01          	cmp    $0x1,%ax
80105db9:	74 1a                	je     80105dd5 <sys_chdir+0x81>
    iunlockput(ip);
80105dbb:	83 ec 0c             	sub    $0xc,%esp
80105dbe:	ff 75 f0             	push   -0x10(%ebp)
80105dc1:	e8 5d be ff ff       	call   80101c23 <iunlockput>
80105dc6:	83 c4 10             	add    $0x10,%esp
    end_op();
80105dc9:	e8 fc d2 ff ff       	call   801030ca <end_op>
    return -1;
80105dce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd3:	eb 33                	jmp    80105e08 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105dd5:	83 ec 0c             	sub    $0xc,%esp
80105dd8:	ff 75 f0             	push   -0x10(%ebp)
80105ddb:	e8 25 bd ff ff       	call   80101b05 <iunlock>
80105de0:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de6:	8b 40 68             	mov    0x68(%eax),%eax
80105de9:	83 ec 0c             	sub    $0xc,%esp
80105dec:	50                   	push   %eax
80105ded:	e8 61 bd ff ff       	call   80101b53 <iput>
80105df2:	83 c4 10             	add    $0x10,%esp
  end_op();
80105df5:	e8 d0 d2 ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
80105dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e00:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e03:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e08:	c9                   	leave
80105e09:	c3                   	ret

80105e0a <sys_exec>:

int
sys_exec(void)
{
80105e0a:	55                   	push   %ebp
80105e0b:	89 e5                	mov    %esp,%ebp
80105e0d:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e13:	83 ec 08             	sub    $0x8,%esp
80105e16:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e19:	50                   	push   %eax
80105e1a:	6a 00                	push   $0x0
80105e1c:	e8 9e f3 ff ff       	call   801051bf <argstr>
80105e21:	83 c4 10             	add    $0x10,%esp
80105e24:	85 c0                	test   %eax,%eax
80105e26:	78 18                	js     80105e40 <sys_exec+0x36>
80105e28:	83 ec 08             	sub    $0x8,%esp
80105e2b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e31:	50                   	push   %eax
80105e32:	6a 01                	push   $0x1
80105e34:	e8 f1 f2 ff ff       	call   8010512a <argint>
80105e39:	83 c4 10             	add    $0x10,%esp
80105e3c:	85 c0                	test   %eax,%eax
80105e3e:	79 0a                	jns    80105e4a <sys_exec+0x40>
    return -1;
80105e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e45:	e9 c6 00 00 00       	jmp    80105f10 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105e4a:	83 ec 04             	sub    $0x4,%esp
80105e4d:	68 80 00 00 00       	push   $0x80
80105e52:	6a 00                	push   $0x0
80105e54:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e5a:	50                   	push   %eax
80105e5b:	e8 9f ef ff ff       	call   80104dff <memset>
80105e60:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6d:	83 f8 1f             	cmp    $0x1f,%eax
80105e70:	76 0a                	jbe    80105e7c <sys_exec+0x72>
      return -1;
80105e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e77:	e9 94 00 00 00       	jmp    80105f10 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7f:	c1 e0 02             	shl    $0x2,%eax
80105e82:	89 c2                	mov    %eax,%edx
80105e84:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e8a:	01 c2                	add    %eax,%edx
80105e8c:	83 ec 08             	sub    $0x8,%esp
80105e8f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e95:	50                   	push   %eax
80105e96:	52                   	push   %edx
80105e97:	e8 ed f1 ff ff       	call   80105089 <fetchint>
80105e9c:	83 c4 10             	add    $0x10,%esp
80105e9f:	85 c0                	test   %eax,%eax
80105ea1:	79 07                	jns    80105eaa <sys_exec+0xa0>
      return -1;
80105ea3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea8:	eb 66                	jmp    80105f10 <sys_exec+0x106>
    if(uarg == 0){
80105eaa:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105eb0:	85 c0                	test   %eax,%eax
80105eb2:	75 27                	jne    80105edb <sys_exec+0xd1>
      argv[i] = 0;
80105eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb7:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ebe:	00 00 00 00 
      break;
80105ec2:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec6:	83 ec 08             	sub    $0x8,%esp
80105ec9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ecf:	52                   	push   %edx
80105ed0:	50                   	push   %eax
80105ed1:	e8 b4 ac ff ff       	call   80100b8a <exec>
80105ed6:	83 c4 10             	add    $0x10,%esp
80105ed9:	eb 35                	jmp    80105f10 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105edb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ee1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ee4:	c1 e2 02             	shl    $0x2,%edx
80105ee7:	01 c2                	add    %eax,%edx
80105ee9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105eef:	83 ec 08             	sub    $0x8,%esp
80105ef2:	52                   	push   %edx
80105ef3:	50                   	push   %eax
80105ef4:	e8 cf f1 ff ff       	call   801050c8 <fetchstr>
80105ef9:	83 c4 10             	add    $0x10,%esp
80105efc:	85 c0                	test   %eax,%eax
80105efe:	79 07                	jns    80105f07 <sys_exec+0xfd>
      return -1;
80105f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f05:	eb 09                	jmp    80105f10 <sys_exec+0x106>
  for(i=0;; i++){
80105f07:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f0b:	e9 5a ff ff ff       	jmp    80105e6a <sys_exec+0x60>
}
80105f10:	c9                   	leave
80105f11:	c3                   	ret

80105f12 <sys_pipe>:

int
sys_pipe(void)
{
80105f12:	55                   	push   %ebp
80105f13:	89 e5                	mov    %esp,%ebp
80105f15:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f18:	83 ec 04             	sub    $0x4,%esp
80105f1b:	6a 08                	push   $0x8
80105f1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f20:	50                   	push   %eax
80105f21:	6a 00                	push   $0x0
80105f23:	e8 2f f2 ff ff       	call   80105157 <argptr>
80105f28:	83 c4 10             	add    $0x10,%esp
80105f2b:	85 c0                	test   %eax,%eax
80105f2d:	79 0a                	jns    80105f39 <sys_pipe+0x27>
    return -1;
80105f2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f34:	e9 ae 00 00 00       	jmp    80105fe7 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f39:	83 ec 08             	sub    $0x8,%esp
80105f3c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f3f:	50                   	push   %eax
80105f40:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f43:	50                   	push   %eax
80105f44:	e8 24 d6 ff ff       	call   8010356d <pipealloc>
80105f49:	83 c4 10             	add    $0x10,%esp
80105f4c:	85 c0                	test   %eax,%eax
80105f4e:	79 0a                	jns    80105f5a <sys_pipe+0x48>
    return -1;
80105f50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f55:	e9 8d 00 00 00       	jmp    80105fe7 <sys_pipe+0xd5>
  fd0 = -1;
80105f5a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f64:	83 ec 0c             	sub    $0xc,%esp
80105f67:	50                   	push   %eax
80105f68:	e8 7b f3 ff ff       	call   801052e8 <fdalloc>
80105f6d:	83 c4 10             	add    $0x10,%esp
80105f70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f77:	78 18                	js     80105f91 <sys_pipe+0x7f>
80105f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f7c:	83 ec 0c             	sub    $0xc,%esp
80105f7f:	50                   	push   %eax
80105f80:	e8 63 f3 ff ff       	call   801052e8 <fdalloc>
80105f85:	83 c4 10             	add    $0x10,%esp
80105f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f8f:	79 3e                	jns    80105fcf <sys_pipe+0xbd>
    if(fd0 >= 0)
80105f91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f95:	78 13                	js     80105faa <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105f97:	e8 9b da ff ff       	call   80103a37 <myproc>
80105f9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f9f:	83 c2 08             	add    $0x8,%edx
80105fa2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105fa9:	00 
    fileclose(rf);
80105faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fad:	83 ec 0c             	sub    $0xc,%esp
80105fb0:	50                   	push   %eax
80105fb1:	e8 ef b0 ff ff       	call   801010a5 <fileclose>
80105fb6:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105fb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fbc:	83 ec 0c             	sub    $0xc,%esp
80105fbf:	50                   	push   %eax
80105fc0:	e8 e0 b0 ff ff       	call   801010a5 <fileclose>
80105fc5:	83 c4 10             	add    $0x10,%esp
    return -1;
80105fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcd:	eb 18                	jmp    80105fe7 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105fcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fd5:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105fd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fda:	8d 50 04             	lea    0x4(%eax),%edx
80105fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe0:	89 02                	mov    %eax,(%edx)
  return 0;
80105fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fe7:	c9                   	leave
80105fe8:	c3                   	ret

80105fe9 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105fe9:	55                   	push   %ebp
80105fea:	89 e5                	mov    %esp,%ebp
80105fec:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fef:	e8 87 dd ff ff       	call   80103d7b <fork>
}
80105ff4:	c9                   	leave
80105ff5:	c3                   	ret

80105ff6 <sys_exit>:

int
sys_exit(void)
{
80105ff6:	55                   	push   %ebp
80105ff7:	89 e5                	mov    %esp,%ebp
80105ff9:	83 ec 08             	sub    $0x8,%esp
  exit();
80105ffc:	e8 f3 de ff ff       	call   80103ef4 <exit>
  return 0;  // not reached
80106001:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106006:	c9                   	leave
80106007:	c3                   	ret

80106008 <sys_wait>:

int
sys_wait(void)
{
80106008:	55                   	push   %ebp
80106009:	89 e5                	mov    %esp,%ebp
8010600b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010600e:	e8 04 e0 ff ff       	call   80104017 <wait>
}
80106013:	c9                   	leave
80106014:	c3                   	ret

80106015 <sys_kill>:

int
sys_kill(void)
{
80106015:	55                   	push   %ebp
80106016:	89 e5                	mov    %esp,%ebp
80106018:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010601b:	83 ec 08             	sub    $0x8,%esp
8010601e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106021:	50                   	push   %eax
80106022:	6a 00                	push   $0x0
80106024:	e8 01 f1 ff ff       	call   8010512a <argint>
80106029:	83 c4 10             	add    $0x10,%esp
8010602c:	85 c0                	test   %eax,%eax
8010602e:	79 07                	jns    80106037 <sys_kill+0x22>
    return -1;
80106030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106035:	eb 0f                	jmp    80106046 <sys_kill+0x31>
  return kill(pid);
80106037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603a:	83 ec 0c             	sub    $0xc,%esp
8010603d:	50                   	push   %eax
8010603e:	e8 4d e5 ff ff       	call   80104590 <kill>
80106043:	83 c4 10             	add    $0x10,%esp
}
80106046:	c9                   	leave
80106047:	c3                   	ret

80106048 <sys_getpid>:

int
sys_getpid(void)
{
80106048:	55                   	push   %ebp
80106049:	89 e5                	mov    %esp,%ebp
8010604b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010604e:	e8 e4 d9 ff ff       	call   80103a37 <myproc>
80106053:	8b 40 10             	mov    0x10(%eax),%eax
}
80106056:	c9                   	leave
80106057:	c3                   	ret

80106058 <sys_sbrk>:

int
sys_sbrk(void)
{
80106058:	55                   	push   %ebp
80106059:	89 e5                	mov    %esp,%ebp
8010605b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010605e:	83 ec 08             	sub    $0x8,%esp
80106061:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106064:	50                   	push   %eax
80106065:	6a 00                	push   $0x0
80106067:	e8 be f0 ff ff       	call   8010512a <argint>
8010606c:	83 c4 10             	add    $0x10,%esp
8010606f:	85 c0                	test   %eax,%eax
80106071:	79 07                	jns    8010607a <sys_sbrk+0x22>
    return -1;
80106073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106078:	eb 27                	jmp    801060a1 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010607a:	e8 b8 d9 ff ff       	call   80103a37 <myproc>
8010607f:	8b 00                	mov    (%eax),%eax
80106081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	83 ec 0c             	sub    $0xc,%esp
8010608a:	50                   	push   %eax
8010608b:	e8 50 dc ff ff       	call   80103ce0 <growproc>
80106090:	83 c4 10             	add    $0x10,%esp
80106093:	85 c0                	test   %eax,%eax
80106095:	79 07                	jns    8010609e <sys_sbrk+0x46>
    return -1;
80106097:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010609c:	eb 03                	jmp    801060a1 <sys_sbrk+0x49>
  return addr;
8010609e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060a1:	c9                   	leave
801060a2:	c3                   	ret

801060a3 <sys_sleep>:

int
sys_sleep(void)
{
801060a3:	55                   	push   %ebp
801060a4:	89 e5                	mov    %esp,%ebp
801060a6:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060a9:	83 ec 08             	sub    $0x8,%esp
801060ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060af:	50                   	push   %eax
801060b0:	6a 00                	push   $0x0
801060b2:	e8 73 f0 ff ff       	call   8010512a <argint>
801060b7:	83 c4 10             	add    $0x10,%esp
801060ba:	85 c0                	test   %eax,%eax
801060bc:	79 07                	jns    801060c5 <sys_sleep+0x22>
    return -1;
801060be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c3:	eb 76                	jmp    8010613b <sys_sleep+0x98>
  acquire(&tickslock);
801060c5:	83 ec 0c             	sub    $0xc,%esp
801060c8:	68 40 74 19 80       	push   $0x80197440
801060cd:	e8 b7 ea ff ff       	call   80104b89 <acquire>
801060d2:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060d5:	a1 74 74 19 80       	mov    0x80197474,%eax
801060da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801060dd:	eb 38                	jmp    80106117 <sys_sleep+0x74>
    if(myproc()->killed){
801060df:	e8 53 d9 ff ff       	call   80103a37 <myproc>
801060e4:	8b 40 24             	mov    0x24(%eax),%eax
801060e7:	85 c0                	test   %eax,%eax
801060e9:	74 17                	je     80106102 <sys_sleep+0x5f>
      release(&tickslock);
801060eb:	83 ec 0c             	sub    $0xc,%esp
801060ee:	68 40 74 19 80       	push   $0x80197440
801060f3:	e8 ff ea ff ff       	call   80104bf7 <release>
801060f8:	83 c4 10             	add    $0x10,%esp
      return -1;
801060fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106100:	eb 39                	jmp    8010613b <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106102:	83 ec 08             	sub    $0x8,%esp
80106105:	68 40 74 19 80       	push   $0x80197440
8010610a:	68 74 74 19 80       	push   $0x80197474
8010610f:	e8 5b e3 ff ff       	call   8010446f <sleep>
80106114:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106117:	a1 74 74 19 80       	mov    0x80197474,%eax
8010611c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010611f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106122:	39 d0                	cmp    %edx,%eax
80106124:	72 b9                	jb     801060df <sys_sleep+0x3c>
  }
  release(&tickslock);
80106126:	83 ec 0c             	sub    $0xc,%esp
80106129:	68 40 74 19 80       	push   $0x80197440
8010612e:	e8 c4 ea ff ff       	call   80104bf7 <release>
80106133:	83 c4 10             	add    $0x10,%esp
  return 0;
80106136:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010613b:	c9                   	leave
8010613c:	c3                   	ret

8010613d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010613d:	55                   	push   %ebp
8010613e:	89 e5                	mov    %esp,%ebp
80106140:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106143:	83 ec 0c             	sub    $0xc,%esp
80106146:	68 40 74 19 80       	push   $0x80197440
8010614b:	e8 39 ea ff ff       	call   80104b89 <acquire>
80106150:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106153:	a1 74 74 19 80       	mov    0x80197474,%eax
80106158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010615b:	83 ec 0c             	sub    $0xc,%esp
8010615e:	68 40 74 19 80       	push   $0x80197440
80106163:	e8 8f ea ff ff       	call   80104bf7 <release>
80106168:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010616b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010616e:	c9                   	leave
8010616f:	c3                   	ret

80106170 <sys_uthread_init>:

int
sys_uthread_init(void)
{
80106170:	55                   	push   %ebp
80106171:	89 e5                	mov    %esp,%ebp
80106173:	53                   	push   %ebx
80106174:	83 ec 14             	sub    $0x14,%esp
  int sched;
  //사용자로부터 전달된 첫 번째 인자 (scheduler 함수 주소)를 읽어옴
  // 실패시 -1 반환
  if (argint(0, &sched) < 0)
80106177:	83 ec 08             	sub    $0x8,%esp
8010617a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010617d:	50                   	push   %eax
8010617e:	6a 00                	push   $0x0
80106180:	e8 a5 ef ff ff       	call   8010512a <argint>
80106185:	83 c4 10             	add    $0x10,%esp
80106188:	85 c0                	test   %eax,%eax
8010618a:	79 07                	jns    80106193 <sys_uthread_init+0x23>
    return -1;
8010618c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106191:	eb 4e                	jmp    801061e1 <sys_uthread_init+0x71>

  cprintf("[kernel] sys_uthread_init 호출됨, 전달된 주소 = 0x%x\n", sched);
80106193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106196:	83 ec 08             	sub    $0x8,%esp
80106199:	50                   	push   %eax
8010619a:	68 18 a9 10 80       	push   $0x8010a918
8010619f:	e8 50 a2 ff ff       	call   801003f4 <cprintf>
801061a4:	83 c4 10             	add    $0x10,%esp
  //현재 프로세스의 pcb해당 주소를 저장(함수주소이므로 uint로 저장)
  myproc()->scheduler = (uint)sched;
801061a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801061aa:	e8 88 d8 ff ff       	call   80103a37 <myproc>
801061af:	89 da                	mov    %ebx,%edx
801061b1:	89 50 7c             	mov    %edx,0x7c(%eax)
  //사용자 수준 스레드를 사용하는 프로세스임을 나타내는 플래그 설정
  myproc()->is_threaded = 1;
801061b4:	e8 7e d8 ff ff       	call   80103a37 <myproc>
801061b9:	c7 80 80 00 00 00 01 	movl   $0x1,0x80(%eax)
801061c0:	00 00 00 
  cprintf("[kernel] 저장 완료: proc->scheduler = 0x%x\n", myproc()->scheduler);
801061c3:	e8 6f d8 ff ff       	call   80103a37 <myproc>
801061c8:	8b 40 7c             	mov    0x7c(%eax),%eax
801061cb:	83 ec 08             	sub    $0x8,%esp
801061ce:	50                   	push   %eax
801061cf:	68 58 a9 10 80       	push   $0x8010a958
801061d4:	e8 1b a2 ff ff       	call   801003f4 <cprintf>
801061d9:	83 c4 10             	add    $0x10,%esp
  //시스템 콜 정상 종료
  return 0;
801061dc:	b8 00 00 00 00       	mov    $0x0,%eax
801061e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061e4:	c9                   	leave
801061e5:	c3                   	ret

801061e6 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801061e6:	1e                   	push   %ds
  pushl %es
801061e7:	06                   	push   %es
  pushl %fs
801061e8:	0f a0                	push   %fs
  pushl %gs
801061ea:	0f a8                	push   %gs
  pushal
801061ec:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801061ed:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801061f1:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801061f3:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801061f5:	54                   	push   %esp
  call trap
801061f6:	e8 d7 01 00 00       	call   801063d2 <trap>
  addl $4, %esp
801061fb:	83 c4 04             	add    $0x4,%esp

801061fe <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801061fe:	61                   	popa
  popl %gs
801061ff:	0f a9                	pop    %gs
  popl %fs
80106201:	0f a1                	pop    %fs
  popl %es
80106203:	07                   	pop    %es
  popl %ds
80106204:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106205:	83 c4 08             	add    $0x8,%esp
  iret
80106208:	cf                   	iret

80106209 <lidt>:
{
80106209:	55                   	push   %ebp
8010620a:	89 e5                	mov    %esp,%ebp
8010620c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010620f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106212:	83 e8 01             	sub    $0x1,%eax
80106215:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106219:	8b 45 08             	mov    0x8(%ebp),%eax
8010621c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106220:	8b 45 08             	mov    0x8(%ebp),%eax
80106223:	c1 e8 10             	shr    $0x10,%eax
80106226:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010622a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010622d:	0f 01 18             	lidtl  (%eax)
}
80106230:	90                   	nop
80106231:	c9                   	leave
80106232:	c3                   	ret

80106233 <rcr2>:

static inline uint
rcr2(void)
{
80106233:	55                   	push   %ebp
80106234:	89 e5                	mov    %esp,%ebp
80106236:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106239:	0f 20 d0             	mov    %cr2,%eax
8010623c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010623f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106242:	c9                   	leave
80106243:	c3                   	ret

80106244 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106244:	55                   	push   %ebp
80106245:	89 e5                	mov    %esp,%ebp
80106247:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010624a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106251:	e9 c3 00 00 00       	jmp    80106319 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106259:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106260:	89 c2                	mov    %eax,%edx
80106262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106265:	66 89 14 c5 40 6c 19 	mov    %dx,-0x7fe693c0(,%eax,8)
8010626c:	80 
8010626d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106270:	66 c7 04 c5 42 6c 19 	movw   $0x8,-0x7fe693be(,%eax,8)
80106277:	80 08 00 
8010627a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627d:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
80106284:	80 
80106285:	83 e2 e0             	and    $0xffffffe0,%edx
80106288:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
80106299:	80 
8010629a:	83 e2 1f             	and    $0x1f,%edx
8010629d:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
801062a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a7:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801062ae:	80 
801062af:	83 e2 f0             	and    $0xfffffff0,%edx
801062b2:	83 ca 0e             	or     $0xe,%edx
801062b5:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801062bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bf:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801062c6:	80 
801062c7:	83 e2 ef             	and    $0xffffffef,%edx
801062ca:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801062d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d4:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801062db:	80 
801062dc:	83 e2 9f             	and    $0xffffff9f,%edx
801062df:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801062e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e9:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801062f0:	80 
801062f1:	83 ca 80             	or     $0xffffff80,%edx
801062f4:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801062fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062fe:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106305:	c1 e8 10             	shr    $0x10,%eax
80106308:	89 c2                	mov    %eax,%edx
8010630a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630d:	66 89 14 c5 46 6c 19 	mov    %dx,-0x7fe693ba(,%eax,8)
80106314:	80 
  for(i = 0; i < 256; i++)
80106315:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106319:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106320:	0f 8e 30 ff ff ff    	jle    80106256 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106326:	a1 84 f1 10 80       	mov    0x8010f184,%eax
8010632b:	66 a3 40 6e 19 80    	mov    %ax,0x80196e40
80106331:	66 c7 05 42 6e 19 80 	movw   $0x8,0x80196e42
80106338:	08 00 
8010633a:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
80106341:	83 e0 e0             	and    $0xffffffe0,%eax
80106344:	a2 44 6e 19 80       	mov    %al,0x80196e44
80106349:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
80106350:	83 e0 1f             	and    $0x1f,%eax
80106353:	a2 44 6e 19 80       	mov    %al,0x80196e44
80106358:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
8010635f:	83 c8 0f             	or     $0xf,%eax
80106362:	a2 45 6e 19 80       	mov    %al,0x80196e45
80106367:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
8010636e:	83 e0 ef             	and    $0xffffffef,%eax
80106371:	a2 45 6e 19 80       	mov    %al,0x80196e45
80106376:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
8010637d:	83 c8 60             	or     $0x60,%eax
80106380:	a2 45 6e 19 80       	mov    %al,0x80196e45
80106385:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
8010638c:	83 c8 80             	or     $0xffffff80,%eax
8010638f:	a2 45 6e 19 80       	mov    %al,0x80196e45
80106394:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106399:	c1 e8 10             	shr    $0x10,%eax
8010639c:	66 a3 46 6e 19 80    	mov    %ax,0x80196e46

  initlock(&tickslock, "time");
801063a2:	83 ec 08             	sub    $0x8,%esp
801063a5:	68 88 a9 10 80       	push   $0x8010a988
801063aa:	68 40 74 19 80       	push   $0x80197440
801063af:	e8 b3 e7 ff ff       	call   80104b67 <initlock>
801063b4:	83 c4 10             	add    $0x10,%esp
}
801063b7:	90                   	nop
801063b8:	c9                   	leave
801063b9:	c3                   	ret

801063ba <idtinit>:

void
idtinit(void)
{
801063ba:	55                   	push   %ebp
801063bb:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801063bd:	68 00 08 00 00       	push   $0x800
801063c2:	68 40 6c 19 80       	push   $0x80196c40
801063c7:	e8 3d fe ff ff       	call   80106209 <lidt>
801063cc:	83 c4 08             	add    $0x8,%esp
}
801063cf:	90                   	nop
801063d0:	c9                   	leave
801063d1:	c3                   	ret

801063d2 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063d2:	55                   	push   %ebp
801063d3:	89 e5                	mov    %esp,%ebp
801063d5:	57                   	push   %edi
801063d6:	56                   	push   %esi
801063d7:	53                   	push   %ebx
801063d8:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801063db:	8b 45 08             	mov    0x8(%ebp),%eax
801063de:	8b 40 30             	mov    0x30(%eax),%eax
801063e1:	83 f8 40             	cmp    $0x40,%eax
801063e4:	75 3b                	jne    80106421 <trap+0x4f>
    if(myproc()->killed)
801063e6:	e8 4c d6 ff ff       	call   80103a37 <myproc>
801063eb:	8b 40 24             	mov    0x24(%eax),%eax
801063ee:	85 c0                	test   %eax,%eax
801063f0:	74 05                	je     801063f7 <trap+0x25>
      exit();
801063f2:	e8 fd da ff ff       	call   80103ef4 <exit>
    myproc()->tf = tf;
801063f7:	e8 3b d6 ff ff       	call   80103a37 <myproc>
801063fc:	8b 55 08             	mov    0x8(%ebp),%edx
801063ff:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106402:	e8 ef ed ff ff       	call   801051f6 <syscall>
    if(myproc()->killed)
80106407:	e8 2b d6 ff ff       	call   80103a37 <myproc>
8010640c:	8b 40 24             	mov    0x24(%eax),%eax
8010640f:	85 c0                	test   %eax,%eax
80106411:	0f 84 83 02 00 00    	je     8010669a <trap+0x2c8>
      exit();
80106417:	e8 d8 da ff ff       	call   80103ef4 <exit>
    return;
8010641c:	e9 79 02 00 00       	jmp    8010669a <trap+0x2c8>
  }

  switch(tf->trapno){
80106421:	8b 45 08             	mov    0x8(%ebp),%eax
80106424:	8b 40 30             	mov    0x30(%eax),%eax
80106427:	83 e8 20             	sub    $0x20,%eax
8010642a:	83 f8 1f             	cmp    $0x1f,%eax
8010642d:	0f 87 0c 01 00 00    	ja     8010653f <trap+0x16d>
80106433:	8b 04 85 30 aa 10 80 	mov    -0x7fef55d0(,%eax,4),%eax
8010643a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:  //타이머 인터럽트가 발생했을때
    if(cpuid() == 0){   //cpu 0번만 global tick 증가 및 sleep-wakeup처리
8010643c:	e8 63 d5 ff ff       	call   801039a4 <cpuid>
80106441:	85 c0                	test   %eax,%eax
80106443:	75 3d                	jne    80106482 <trap+0xb0>
      acquire(&tickslock);  //tick 값 보호를 위한 락 획득
80106445:	83 ec 0c             	sub    $0xc,%esp
80106448:	68 40 74 19 80       	push   $0x80197440
8010644d:	e8 37 e7 ff ff       	call   80104b89 <acquire>
80106452:	83 c4 10             	add    $0x10,%esp
      ticks++;              //전역 tick 카운터 증가
80106455:	a1 74 74 19 80       	mov    0x80197474,%eax
8010645a:	83 c0 01             	add    $0x1,%eax
8010645d:	a3 74 74 19 80       	mov    %eax,0x80197474
      wakeup(&ticks);       // tick을 기다리는 프로세스 깨움
80106462:	83 ec 0c             	sub    $0xc,%esp
80106465:	68 74 74 19 80       	push   $0x80197474
8010646a:	e8 ea e0 ff ff       	call   80104559 <wakeup>
8010646f:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);    //락 해제
80106472:	83 ec 0c             	sub    $0xc,%esp
80106475:	68 40 74 19 80       	push   $0x80197440
8010647a:	e8 78 e7 ff ff       	call   80104bf7 <release>
8010647f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();     //LOCAl apic에 인터럽트 처리 완료 알림
80106482:	e8 97 c6 ff ff       	call   80102b1e <lapiceoi>
    struct proc *proc = myproc();
80106487:	e8 ab d5 ff ff       	call   80103a37 <myproc>
8010648c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (proc && proc->state == RUNNING && proc->is_threaded && proc->scheduler) {
8010648f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106493:	0f 84 5d 01 00 00    	je     801065f6 <trap+0x224>
80106499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010649c:	8b 40 0c             	mov    0xc(%eax),%eax
8010649f:	83 f8 04             	cmp    $0x4,%eax
801064a2:	0f 85 4e 01 00 00    	jne    801065f6 <trap+0x224>
801064a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ab:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801064b1:	85 c0                	test   %eax,%eax
801064b3:	0f 84 3d 01 00 00    	je     801065f6 <trap+0x224>
801064b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064bc:	8b 40 7c             	mov    0x7c(%eax),%eax
801064bf:	85 c0                	test   %eax,%eax
801064c1:	0f 84 2f 01 00 00    	je     801065f6 <trap+0x224>
      ((void (*)(void))proc->scheduler)();  // 🎯 사용자 스케줄러 함수 호출
801064c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ca:	8b 40 7c             	mov    0x7c(%eax),%eax
801064cd:	ff d0                	call   *%eax
    }

    break;
801064cf:	e9 22 01 00 00       	jmp    801065f6 <trap+0x224>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064d4:	e8 01 3f 00 00       	call   8010a3da <ideintr>
    lapiceoi();
801064d9:	e8 40 c6 ff ff       	call   80102b1e <lapiceoi>
    break;
801064de:	e9 14 01 00 00       	jmp    801065f7 <trap+0x225>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801064e3:	e8 81 c4 ff ff       	call   80102969 <kbdintr>
    lapiceoi();
801064e8:	e8 31 c6 ff ff       	call   80102b1e <lapiceoi>
    break;
801064ed:	e9 05 01 00 00       	jmp    801065f7 <trap+0x225>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801064f2:	e8 77 03 00 00       	call   8010686e <uartintr>
    lapiceoi();
801064f7:	e8 22 c6 ff ff       	call   80102b1e <lapiceoi>
    break;
801064fc:	e9 f6 00 00 00       	jmp    801065f7 <trap+0x225>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106501:	e8 9d 2b 00 00       	call   801090a3 <i8254_intr>
    lapiceoi();
80106506:	e8 13 c6 ff ff       	call   80102b1e <lapiceoi>
    break;
8010650b:	e9 e7 00 00 00       	jmp    801065f7 <trap+0x225>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106510:	8b 45 08             	mov    0x8(%ebp),%eax
80106513:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106516:	8b 45 08             	mov    0x8(%ebp),%eax
80106519:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010651d:	0f b7 d8             	movzwl %ax,%ebx
80106520:	e8 7f d4 ff ff       	call   801039a4 <cpuid>
80106525:	56                   	push   %esi
80106526:	53                   	push   %ebx
80106527:	50                   	push   %eax
80106528:	68 90 a9 10 80       	push   $0x8010a990
8010652d:	e8 c2 9e ff ff       	call   801003f4 <cprintf>
80106532:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106535:	e8 e4 c5 ff ff       	call   80102b1e <lapiceoi>
    break;
8010653a:	e9 b8 00 00 00       	jmp    801065f7 <trap+0x225>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010653f:	e8 f3 d4 ff ff       	call   80103a37 <myproc>
80106544:	85 c0                	test   %eax,%eax
80106546:	74 11                	je     80106559 <trap+0x187>
80106548:	8b 45 08             	mov    0x8(%ebp),%eax
8010654b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010654f:	0f b7 c0             	movzwl %ax,%eax
80106552:	83 e0 03             	and    $0x3,%eax
80106555:	85 c0                	test   %eax,%eax
80106557:	75 39                	jne    80106592 <trap+0x1c0>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106559:	e8 d5 fc ff ff       	call   80106233 <rcr2>
8010655e:	89 c3                	mov    %eax,%ebx
80106560:	8b 45 08             	mov    0x8(%ebp),%eax
80106563:	8b 70 38             	mov    0x38(%eax),%esi
80106566:	e8 39 d4 ff ff       	call   801039a4 <cpuid>
8010656b:	8b 55 08             	mov    0x8(%ebp),%edx
8010656e:	8b 52 30             	mov    0x30(%edx),%edx
80106571:	83 ec 0c             	sub    $0xc,%esp
80106574:	53                   	push   %ebx
80106575:	56                   	push   %esi
80106576:	50                   	push   %eax
80106577:	52                   	push   %edx
80106578:	68 b4 a9 10 80       	push   $0x8010a9b4
8010657d:	e8 72 9e ff ff       	call   801003f4 <cprintf>
80106582:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106585:	83 ec 0c             	sub    $0xc,%esp
80106588:	68 e6 a9 10 80       	push   $0x8010a9e6
8010658d:	e8 17 a0 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106592:	e8 9c fc ff ff       	call   80106233 <rcr2>
80106597:	89 c6                	mov    %eax,%esi
80106599:	8b 45 08             	mov    0x8(%ebp),%eax
8010659c:	8b 40 38             	mov    0x38(%eax),%eax
8010659f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801065a2:	e8 fd d3 ff ff       	call   801039a4 <cpuid>
801065a7:	89 c3                	mov    %eax,%ebx
801065a9:	8b 45 08             	mov    0x8(%ebp),%eax
801065ac:	8b 48 34             	mov    0x34(%eax),%ecx
801065af:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801065b2:	8b 45 08             	mov    0x8(%ebp),%eax
801065b5:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801065b8:	e8 7a d4 ff ff       	call   80103a37 <myproc>
801065bd:	8d 50 6c             	lea    0x6c(%eax),%edx
801065c0:	89 55 cc             	mov    %edx,-0x34(%ebp)
801065c3:	e8 6f d4 ff ff       	call   80103a37 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065c8:	8b 40 10             	mov    0x10(%eax),%eax
801065cb:	56                   	push   %esi
801065cc:	ff 75 d4             	push   -0x2c(%ebp)
801065cf:	53                   	push   %ebx
801065d0:	ff 75 d0             	push   -0x30(%ebp)
801065d3:	57                   	push   %edi
801065d4:	ff 75 cc             	push   -0x34(%ebp)
801065d7:	50                   	push   %eax
801065d8:	68 ec a9 10 80       	push   $0x8010a9ec
801065dd:	e8 12 9e ff ff       	call   801003f4 <cprintf>
801065e2:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801065e5:	e8 4d d4 ff ff       	call   80103a37 <myproc>
801065ea:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801065f1:	eb 04                	jmp    801065f7 <trap+0x225>
    break;
801065f3:	90                   	nop
801065f4:	eb 01                	jmp    801065f7 <trap+0x225>
    break;
801065f6:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801065f7:	e8 3b d4 ff ff       	call   80103a37 <myproc>
801065fc:	85 c0                	test   %eax,%eax
801065fe:	74 23                	je     80106623 <trap+0x251>
80106600:	e8 32 d4 ff ff       	call   80103a37 <myproc>
80106605:	8b 40 24             	mov    0x24(%eax),%eax
80106608:	85 c0                	test   %eax,%eax
8010660a:	74 17                	je     80106623 <trap+0x251>
8010660c:	8b 45 08             	mov    0x8(%ebp),%eax
8010660f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106613:	0f b7 c0             	movzwl %ax,%eax
80106616:	83 e0 03             	and    $0x3,%eax
80106619:	83 f8 03             	cmp    $0x3,%eax
8010661c:	75 05                	jne    80106623 <trap+0x251>
    exit();
8010661e:	e8 d1 d8 ff ff       	call   80103ef4 <exit>
  
  //myproc() 현재 cpu에서 실행중인 프로세스 
  //myproc()->state == RUNNING 현재 프로세스가 실행 중인지 확인
  //tf->trapno == T_IRQ0+IRQ_TIMER trap 번호가 타이머 인터럽트인지 확인
  // yield() 현재 프로세스를 RUNNABLE로 바꾸고, sched() 호출해서 다른 프로세스로 문맥을 전환
  if(myproc() && myproc()->state == RUNNING &&tf->trapno == T_IRQ0+IRQ_TIMER) 
80106623:	e8 0f d4 ff ff       	call   80103a37 <myproc>
80106628:	85 c0                	test   %eax,%eax
8010662a:	74 40                	je     8010666c <trap+0x29a>
8010662c:	e8 06 d4 ff ff       	call   80103a37 <myproc>
80106631:	8b 40 0c             	mov    0xc(%eax),%eax
80106634:	83 f8 04             	cmp    $0x4,%eax
80106637:	75 33                	jne    8010666c <trap+0x29a>
80106639:	8b 45 08             	mov    0x8(%ebp),%eax
8010663c:	8b 40 30             	mov    0x30(%eax),%eax
8010663f:	83 f8 20             	cmp    $0x20,%eax
80106642:	75 28                	jne    8010666c <trap+0x29a>
  {
    myproc()->ticks[myproc()->priority]++;
80106644:	e8 ee d3 ff ff       	call   80103a37 <myproc>
80106649:	89 c3                	mov    %eax,%ebx
8010664b:	e8 e7 d3 ff ff       	call   80103a37 <myproc>
80106650:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106656:	8d 50 20             	lea    0x20(%eax),%edx
80106659:	8b 54 93 08          	mov    0x8(%ebx,%edx,4),%edx
8010665d:	83 c2 01             	add    $0x1,%edx
80106660:	83 c0 20             	add    $0x20,%eax
80106663:	89 54 83 08          	mov    %edx,0x8(%ebx,%eax,4)
    yield();
80106667:	e8 83 dd ff ff       	call   801043ef <yield>

//myproc() 현재 CPU에서 실행 중인 프로세스
//myproc()->killed 커널에서 이 프로세스를 종료하라고 표시 했는지 확인
//(tf->cs & 3) == DPL_USER 현재 trap이 user space 에서 발생했는지 확인|
//exit() 프로세스를 종료하는 시스템 콜 
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010666c:	e8 c6 d3 ff ff       	call   80103a37 <myproc>
80106671:	85 c0                	test   %eax,%eax
80106673:	74 26                	je     8010669b <trap+0x2c9>
80106675:	e8 bd d3 ff ff       	call   80103a37 <myproc>
8010667a:	8b 40 24             	mov    0x24(%eax),%eax
8010667d:	85 c0                	test   %eax,%eax
8010667f:	74 1a                	je     8010669b <trap+0x2c9>
80106681:	8b 45 08             	mov    0x8(%ebp),%eax
80106684:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106688:	0f b7 c0             	movzwl %ax,%eax
8010668b:	83 e0 03             	and    $0x3,%eax
8010668e:	83 f8 03             	cmp    $0x3,%eax
80106691:	75 08                	jne    8010669b <trap+0x2c9>
    exit();
80106693:	e8 5c d8 ff ff       	call   80103ef4 <exit>
80106698:	eb 01                	jmp    8010669b <trap+0x2c9>
    return;
8010669a:	90                   	nop
}
8010669b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010669e:	5b                   	pop    %ebx
8010669f:	5e                   	pop    %esi
801066a0:	5f                   	pop    %edi
801066a1:	5d                   	pop    %ebp
801066a2:	c3                   	ret

801066a3 <inb>:
{
801066a3:	55                   	push   %ebp
801066a4:	89 e5                	mov    %esp,%ebp
801066a6:	83 ec 14             	sub    $0x14,%esp
801066a9:	8b 45 08             	mov    0x8(%ebp),%eax
801066ac:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066b0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066b4:	89 c2                	mov    %eax,%edx
801066b6:	ec                   	in     (%dx),%al
801066b7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066ba:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066be:	c9                   	leave
801066bf:	c3                   	ret

801066c0 <outb>:
{
801066c0:	55                   	push   %ebp
801066c1:	89 e5                	mov    %esp,%ebp
801066c3:	83 ec 08             	sub    $0x8,%esp
801066c6:	8b 55 08             	mov    0x8(%ebp),%edx
801066c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801066cc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801066d0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066d3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066d7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066db:	ee                   	out    %al,(%dx)
}
801066dc:	90                   	nop
801066dd:	c9                   	leave
801066de:	c3                   	ret

801066df <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801066df:	55                   	push   %ebp
801066e0:	89 e5                	mov    %esp,%ebp
801066e2:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801066e5:	6a 00                	push   $0x0
801066e7:	68 fa 03 00 00       	push   $0x3fa
801066ec:	e8 cf ff ff ff       	call   801066c0 <outb>
801066f1:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801066f4:	68 80 00 00 00       	push   $0x80
801066f9:	68 fb 03 00 00       	push   $0x3fb
801066fe:	e8 bd ff ff ff       	call   801066c0 <outb>
80106703:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106706:	6a 0c                	push   $0xc
80106708:	68 f8 03 00 00       	push   $0x3f8
8010670d:	e8 ae ff ff ff       	call   801066c0 <outb>
80106712:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106715:	6a 00                	push   $0x0
80106717:	68 f9 03 00 00       	push   $0x3f9
8010671c:	e8 9f ff ff ff       	call   801066c0 <outb>
80106721:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106724:	6a 03                	push   $0x3
80106726:	68 fb 03 00 00       	push   $0x3fb
8010672b:	e8 90 ff ff ff       	call   801066c0 <outb>
80106730:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106733:	6a 00                	push   $0x0
80106735:	68 fc 03 00 00       	push   $0x3fc
8010673a:	e8 81 ff ff ff       	call   801066c0 <outb>
8010673f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106742:	6a 01                	push   $0x1
80106744:	68 f9 03 00 00       	push   $0x3f9
80106749:	e8 72 ff ff ff       	call   801066c0 <outb>
8010674e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106751:	68 fd 03 00 00       	push   $0x3fd
80106756:	e8 48 ff ff ff       	call   801066a3 <inb>
8010675b:	83 c4 04             	add    $0x4,%esp
8010675e:	3c ff                	cmp    $0xff,%al
80106760:	74 61                	je     801067c3 <uartinit+0xe4>
    return;
  uart = 1;
80106762:	c7 05 78 74 19 80 01 	movl   $0x1,0x80197478
80106769:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010676c:	68 fa 03 00 00       	push   $0x3fa
80106771:	e8 2d ff ff ff       	call   801066a3 <inb>
80106776:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106779:	68 f8 03 00 00       	push   $0x3f8
8010677e:	e8 20 ff ff ff       	call   801066a3 <inb>
80106783:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106786:	83 ec 08             	sub    $0x8,%esp
80106789:	6a 00                	push   $0x0
8010678b:	6a 04                	push   $0x4
8010678d:	e8 a4 be ff ff       	call   80102636 <ioapicenable>
80106792:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106795:	c7 45 f4 b0 aa 10 80 	movl   $0x8010aab0,-0xc(%ebp)
8010679c:	eb 19                	jmp    801067b7 <uartinit+0xd8>
    uartputc(*p);
8010679e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a1:	0f b6 00             	movzbl (%eax),%eax
801067a4:	0f be c0             	movsbl %al,%eax
801067a7:	83 ec 0c             	sub    $0xc,%esp
801067aa:	50                   	push   %eax
801067ab:	e8 16 00 00 00       	call   801067c6 <uartputc>
801067b0:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801067b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ba:	0f b6 00             	movzbl (%eax),%eax
801067bd:	84 c0                	test   %al,%al
801067bf:	75 dd                	jne    8010679e <uartinit+0xbf>
801067c1:	eb 01                	jmp    801067c4 <uartinit+0xe5>
    return;
801067c3:	90                   	nop
}
801067c4:	c9                   	leave
801067c5:	c3                   	ret

801067c6 <uartputc>:

void
uartputc(int c)
{
801067c6:	55                   	push   %ebp
801067c7:	89 e5                	mov    %esp,%ebp
801067c9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067cc:	a1 78 74 19 80       	mov    0x80197478,%eax
801067d1:	85 c0                	test   %eax,%eax
801067d3:	74 53                	je     80106828 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067dc:	eb 11                	jmp    801067ef <uartputc+0x29>
    microdelay(10);
801067de:	83 ec 0c             	sub    $0xc,%esp
801067e1:	6a 0a                	push   $0xa
801067e3:	e8 51 c3 ff ff       	call   80102b39 <microdelay>
801067e8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067ef:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801067f3:	7f 1a                	jg     8010680f <uartputc+0x49>
801067f5:	83 ec 0c             	sub    $0xc,%esp
801067f8:	68 fd 03 00 00       	push   $0x3fd
801067fd:	e8 a1 fe ff ff       	call   801066a3 <inb>
80106802:	83 c4 10             	add    $0x10,%esp
80106805:	0f b6 c0             	movzbl %al,%eax
80106808:	83 e0 20             	and    $0x20,%eax
8010680b:	85 c0                	test   %eax,%eax
8010680d:	74 cf                	je     801067de <uartputc+0x18>
  outb(COM1+0, c);
8010680f:	8b 45 08             	mov    0x8(%ebp),%eax
80106812:	0f b6 c0             	movzbl %al,%eax
80106815:	83 ec 08             	sub    $0x8,%esp
80106818:	50                   	push   %eax
80106819:	68 f8 03 00 00       	push   $0x3f8
8010681e:	e8 9d fe ff ff       	call   801066c0 <outb>
80106823:	83 c4 10             	add    $0x10,%esp
80106826:	eb 01                	jmp    80106829 <uartputc+0x63>
    return;
80106828:	90                   	nop
}
80106829:	c9                   	leave
8010682a:	c3                   	ret

8010682b <uartgetc>:

static int
uartgetc(void)
{
8010682b:	55                   	push   %ebp
8010682c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010682e:	a1 78 74 19 80       	mov    0x80197478,%eax
80106833:	85 c0                	test   %eax,%eax
80106835:	75 07                	jne    8010683e <uartgetc+0x13>
    return -1;
80106837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010683c:	eb 2e                	jmp    8010686c <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010683e:	68 fd 03 00 00       	push   $0x3fd
80106843:	e8 5b fe ff ff       	call   801066a3 <inb>
80106848:	83 c4 04             	add    $0x4,%esp
8010684b:	0f b6 c0             	movzbl %al,%eax
8010684e:	83 e0 01             	and    $0x1,%eax
80106851:	85 c0                	test   %eax,%eax
80106853:	75 07                	jne    8010685c <uartgetc+0x31>
    return -1;
80106855:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685a:	eb 10                	jmp    8010686c <uartgetc+0x41>
  return inb(COM1+0);
8010685c:	68 f8 03 00 00       	push   $0x3f8
80106861:	e8 3d fe ff ff       	call   801066a3 <inb>
80106866:	83 c4 04             	add    $0x4,%esp
80106869:	0f b6 c0             	movzbl %al,%eax
}
8010686c:	c9                   	leave
8010686d:	c3                   	ret

8010686e <uartintr>:

void
uartintr(void)
{
8010686e:	55                   	push   %ebp
8010686f:	89 e5                	mov    %esp,%ebp
80106871:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106874:	83 ec 0c             	sub    $0xc,%esp
80106877:	68 2b 68 10 80       	push   $0x8010682b
8010687c:	e8 55 9f ff ff       	call   801007d6 <consoleintr>
80106881:	83 c4 10             	add    $0x10,%esp
}
80106884:	90                   	nop
80106885:	c9                   	leave
80106886:	c3                   	ret

80106887 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106887:	6a 00                	push   $0x0
  pushl $0
80106889:	6a 00                	push   $0x0
  jmp alltraps
8010688b:	e9 56 f9 ff ff       	jmp    801061e6 <alltraps>

80106890 <vector1>:
.globl vector1
vector1:
  pushl $0
80106890:	6a 00                	push   $0x0
  pushl $1
80106892:	6a 01                	push   $0x1
  jmp alltraps
80106894:	e9 4d f9 ff ff       	jmp    801061e6 <alltraps>

80106899 <vector2>:
.globl vector2
vector2:
  pushl $0
80106899:	6a 00                	push   $0x0
  pushl $2
8010689b:	6a 02                	push   $0x2
  jmp alltraps
8010689d:	e9 44 f9 ff ff       	jmp    801061e6 <alltraps>

801068a2 <vector3>:
.globl vector3
vector3:
  pushl $0
801068a2:	6a 00                	push   $0x0
  pushl $3
801068a4:	6a 03                	push   $0x3
  jmp alltraps
801068a6:	e9 3b f9 ff ff       	jmp    801061e6 <alltraps>

801068ab <vector4>:
.globl vector4
vector4:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $4
801068ad:	6a 04                	push   $0x4
  jmp alltraps
801068af:	e9 32 f9 ff ff       	jmp    801061e6 <alltraps>

801068b4 <vector5>:
.globl vector5
vector5:
  pushl $0
801068b4:	6a 00                	push   $0x0
  pushl $5
801068b6:	6a 05                	push   $0x5
  jmp alltraps
801068b8:	e9 29 f9 ff ff       	jmp    801061e6 <alltraps>

801068bd <vector6>:
.globl vector6
vector6:
  pushl $0
801068bd:	6a 00                	push   $0x0
  pushl $6
801068bf:	6a 06                	push   $0x6
  jmp alltraps
801068c1:	e9 20 f9 ff ff       	jmp    801061e6 <alltraps>

801068c6 <vector7>:
.globl vector7
vector7:
  pushl $0
801068c6:	6a 00                	push   $0x0
  pushl $7
801068c8:	6a 07                	push   $0x7
  jmp alltraps
801068ca:	e9 17 f9 ff ff       	jmp    801061e6 <alltraps>

801068cf <vector8>:
.globl vector8
vector8:
  pushl $8
801068cf:	6a 08                	push   $0x8
  jmp alltraps
801068d1:	e9 10 f9 ff ff       	jmp    801061e6 <alltraps>

801068d6 <vector9>:
.globl vector9
vector9:
  pushl $0
801068d6:	6a 00                	push   $0x0
  pushl $9
801068d8:	6a 09                	push   $0x9
  jmp alltraps
801068da:	e9 07 f9 ff ff       	jmp    801061e6 <alltraps>

801068df <vector10>:
.globl vector10
vector10:
  pushl $10
801068df:	6a 0a                	push   $0xa
  jmp alltraps
801068e1:	e9 00 f9 ff ff       	jmp    801061e6 <alltraps>

801068e6 <vector11>:
.globl vector11
vector11:
  pushl $11
801068e6:	6a 0b                	push   $0xb
  jmp alltraps
801068e8:	e9 f9 f8 ff ff       	jmp    801061e6 <alltraps>

801068ed <vector12>:
.globl vector12
vector12:
  pushl $12
801068ed:	6a 0c                	push   $0xc
  jmp alltraps
801068ef:	e9 f2 f8 ff ff       	jmp    801061e6 <alltraps>

801068f4 <vector13>:
.globl vector13
vector13:
  pushl $13
801068f4:	6a 0d                	push   $0xd
  jmp alltraps
801068f6:	e9 eb f8 ff ff       	jmp    801061e6 <alltraps>

801068fb <vector14>:
.globl vector14
vector14:
  pushl $14
801068fb:	6a 0e                	push   $0xe
  jmp alltraps
801068fd:	e9 e4 f8 ff ff       	jmp    801061e6 <alltraps>

80106902 <vector15>:
.globl vector15
vector15:
  pushl $0
80106902:	6a 00                	push   $0x0
  pushl $15
80106904:	6a 0f                	push   $0xf
  jmp alltraps
80106906:	e9 db f8 ff ff       	jmp    801061e6 <alltraps>

8010690b <vector16>:
.globl vector16
vector16:
  pushl $0
8010690b:	6a 00                	push   $0x0
  pushl $16
8010690d:	6a 10                	push   $0x10
  jmp alltraps
8010690f:	e9 d2 f8 ff ff       	jmp    801061e6 <alltraps>

80106914 <vector17>:
.globl vector17
vector17:
  pushl $17
80106914:	6a 11                	push   $0x11
  jmp alltraps
80106916:	e9 cb f8 ff ff       	jmp    801061e6 <alltraps>

8010691b <vector18>:
.globl vector18
vector18:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $18
8010691d:	6a 12                	push   $0x12
  jmp alltraps
8010691f:	e9 c2 f8 ff ff       	jmp    801061e6 <alltraps>

80106924 <vector19>:
.globl vector19
vector19:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $19
80106926:	6a 13                	push   $0x13
  jmp alltraps
80106928:	e9 b9 f8 ff ff       	jmp    801061e6 <alltraps>

8010692d <vector20>:
.globl vector20
vector20:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $20
8010692f:	6a 14                	push   $0x14
  jmp alltraps
80106931:	e9 b0 f8 ff ff       	jmp    801061e6 <alltraps>

80106936 <vector21>:
.globl vector21
vector21:
  pushl $0
80106936:	6a 00                	push   $0x0
  pushl $21
80106938:	6a 15                	push   $0x15
  jmp alltraps
8010693a:	e9 a7 f8 ff ff       	jmp    801061e6 <alltraps>

8010693f <vector22>:
.globl vector22
vector22:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $22
80106941:	6a 16                	push   $0x16
  jmp alltraps
80106943:	e9 9e f8 ff ff       	jmp    801061e6 <alltraps>

80106948 <vector23>:
.globl vector23
vector23:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $23
8010694a:	6a 17                	push   $0x17
  jmp alltraps
8010694c:	e9 95 f8 ff ff       	jmp    801061e6 <alltraps>

80106951 <vector24>:
.globl vector24
vector24:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $24
80106953:	6a 18                	push   $0x18
  jmp alltraps
80106955:	e9 8c f8 ff ff       	jmp    801061e6 <alltraps>

8010695a <vector25>:
.globl vector25
vector25:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $25
8010695c:	6a 19                	push   $0x19
  jmp alltraps
8010695e:	e9 83 f8 ff ff       	jmp    801061e6 <alltraps>

80106963 <vector26>:
.globl vector26
vector26:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $26
80106965:	6a 1a                	push   $0x1a
  jmp alltraps
80106967:	e9 7a f8 ff ff       	jmp    801061e6 <alltraps>

8010696c <vector27>:
.globl vector27
vector27:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $27
8010696e:	6a 1b                	push   $0x1b
  jmp alltraps
80106970:	e9 71 f8 ff ff       	jmp    801061e6 <alltraps>

80106975 <vector28>:
.globl vector28
vector28:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $28
80106977:	6a 1c                	push   $0x1c
  jmp alltraps
80106979:	e9 68 f8 ff ff       	jmp    801061e6 <alltraps>

8010697e <vector29>:
.globl vector29
vector29:
  pushl $0
8010697e:	6a 00                	push   $0x0
  pushl $29
80106980:	6a 1d                	push   $0x1d
  jmp alltraps
80106982:	e9 5f f8 ff ff       	jmp    801061e6 <alltraps>

80106987 <vector30>:
.globl vector30
vector30:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $30
80106989:	6a 1e                	push   $0x1e
  jmp alltraps
8010698b:	e9 56 f8 ff ff       	jmp    801061e6 <alltraps>

80106990 <vector31>:
.globl vector31
vector31:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $31
80106992:	6a 1f                	push   $0x1f
  jmp alltraps
80106994:	e9 4d f8 ff ff       	jmp    801061e6 <alltraps>

80106999 <vector32>:
.globl vector32
vector32:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $32
8010699b:	6a 20                	push   $0x20
  jmp alltraps
8010699d:	e9 44 f8 ff ff       	jmp    801061e6 <alltraps>

801069a2 <vector33>:
.globl vector33
vector33:
  pushl $0
801069a2:	6a 00                	push   $0x0
  pushl $33
801069a4:	6a 21                	push   $0x21
  jmp alltraps
801069a6:	e9 3b f8 ff ff       	jmp    801061e6 <alltraps>

801069ab <vector34>:
.globl vector34
vector34:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $34
801069ad:	6a 22                	push   $0x22
  jmp alltraps
801069af:	e9 32 f8 ff ff       	jmp    801061e6 <alltraps>

801069b4 <vector35>:
.globl vector35
vector35:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $35
801069b6:	6a 23                	push   $0x23
  jmp alltraps
801069b8:	e9 29 f8 ff ff       	jmp    801061e6 <alltraps>

801069bd <vector36>:
.globl vector36
vector36:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $36
801069bf:	6a 24                	push   $0x24
  jmp alltraps
801069c1:	e9 20 f8 ff ff       	jmp    801061e6 <alltraps>

801069c6 <vector37>:
.globl vector37
vector37:
  pushl $0
801069c6:	6a 00                	push   $0x0
  pushl $37
801069c8:	6a 25                	push   $0x25
  jmp alltraps
801069ca:	e9 17 f8 ff ff       	jmp    801061e6 <alltraps>

801069cf <vector38>:
.globl vector38
vector38:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $38
801069d1:	6a 26                	push   $0x26
  jmp alltraps
801069d3:	e9 0e f8 ff ff       	jmp    801061e6 <alltraps>

801069d8 <vector39>:
.globl vector39
vector39:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $39
801069da:	6a 27                	push   $0x27
  jmp alltraps
801069dc:	e9 05 f8 ff ff       	jmp    801061e6 <alltraps>

801069e1 <vector40>:
.globl vector40
vector40:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $40
801069e3:	6a 28                	push   $0x28
  jmp alltraps
801069e5:	e9 fc f7 ff ff       	jmp    801061e6 <alltraps>

801069ea <vector41>:
.globl vector41
vector41:
  pushl $0
801069ea:	6a 00                	push   $0x0
  pushl $41
801069ec:	6a 29                	push   $0x29
  jmp alltraps
801069ee:	e9 f3 f7 ff ff       	jmp    801061e6 <alltraps>

801069f3 <vector42>:
.globl vector42
vector42:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $42
801069f5:	6a 2a                	push   $0x2a
  jmp alltraps
801069f7:	e9 ea f7 ff ff       	jmp    801061e6 <alltraps>

801069fc <vector43>:
.globl vector43
vector43:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $43
801069fe:	6a 2b                	push   $0x2b
  jmp alltraps
80106a00:	e9 e1 f7 ff ff       	jmp    801061e6 <alltraps>

80106a05 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $44
80106a07:	6a 2c                	push   $0x2c
  jmp alltraps
80106a09:	e9 d8 f7 ff ff       	jmp    801061e6 <alltraps>

80106a0e <vector45>:
.globl vector45
vector45:
  pushl $0
80106a0e:	6a 00                	push   $0x0
  pushl $45
80106a10:	6a 2d                	push   $0x2d
  jmp alltraps
80106a12:	e9 cf f7 ff ff       	jmp    801061e6 <alltraps>

80106a17 <vector46>:
.globl vector46
vector46:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $46
80106a19:	6a 2e                	push   $0x2e
  jmp alltraps
80106a1b:	e9 c6 f7 ff ff       	jmp    801061e6 <alltraps>

80106a20 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $47
80106a22:	6a 2f                	push   $0x2f
  jmp alltraps
80106a24:	e9 bd f7 ff ff       	jmp    801061e6 <alltraps>

80106a29 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $48
80106a2b:	6a 30                	push   $0x30
  jmp alltraps
80106a2d:	e9 b4 f7 ff ff       	jmp    801061e6 <alltraps>

80106a32 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $49
80106a34:	6a 31                	push   $0x31
  jmp alltraps
80106a36:	e9 ab f7 ff ff       	jmp    801061e6 <alltraps>

80106a3b <vector50>:
.globl vector50
vector50:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $50
80106a3d:	6a 32                	push   $0x32
  jmp alltraps
80106a3f:	e9 a2 f7 ff ff       	jmp    801061e6 <alltraps>

80106a44 <vector51>:
.globl vector51
vector51:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $51
80106a46:	6a 33                	push   $0x33
  jmp alltraps
80106a48:	e9 99 f7 ff ff       	jmp    801061e6 <alltraps>

80106a4d <vector52>:
.globl vector52
vector52:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $52
80106a4f:	6a 34                	push   $0x34
  jmp alltraps
80106a51:	e9 90 f7 ff ff       	jmp    801061e6 <alltraps>

80106a56 <vector53>:
.globl vector53
vector53:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $53
80106a58:	6a 35                	push   $0x35
  jmp alltraps
80106a5a:	e9 87 f7 ff ff       	jmp    801061e6 <alltraps>

80106a5f <vector54>:
.globl vector54
vector54:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $54
80106a61:	6a 36                	push   $0x36
  jmp alltraps
80106a63:	e9 7e f7 ff ff       	jmp    801061e6 <alltraps>

80106a68 <vector55>:
.globl vector55
vector55:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $55
80106a6a:	6a 37                	push   $0x37
  jmp alltraps
80106a6c:	e9 75 f7 ff ff       	jmp    801061e6 <alltraps>

80106a71 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $56
80106a73:	6a 38                	push   $0x38
  jmp alltraps
80106a75:	e9 6c f7 ff ff       	jmp    801061e6 <alltraps>

80106a7a <vector57>:
.globl vector57
vector57:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $57
80106a7c:	6a 39                	push   $0x39
  jmp alltraps
80106a7e:	e9 63 f7 ff ff       	jmp    801061e6 <alltraps>

80106a83 <vector58>:
.globl vector58
vector58:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $58
80106a85:	6a 3a                	push   $0x3a
  jmp alltraps
80106a87:	e9 5a f7 ff ff       	jmp    801061e6 <alltraps>

80106a8c <vector59>:
.globl vector59
vector59:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $59
80106a8e:	6a 3b                	push   $0x3b
  jmp alltraps
80106a90:	e9 51 f7 ff ff       	jmp    801061e6 <alltraps>

80106a95 <vector60>:
.globl vector60
vector60:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $60
80106a97:	6a 3c                	push   $0x3c
  jmp alltraps
80106a99:	e9 48 f7 ff ff       	jmp    801061e6 <alltraps>

80106a9e <vector61>:
.globl vector61
vector61:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $61
80106aa0:	6a 3d                	push   $0x3d
  jmp alltraps
80106aa2:	e9 3f f7 ff ff       	jmp    801061e6 <alltraps>

80106aa7 <vector62>:
.globl vector62
vector62:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $62
80106aa9:	6a 3e                	push   $0x3e
  jmp alltraps
80106aab:	e9 36 f7 ff ff       	jmp    801061e6 <alltraps>

80106ab0 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $63
80106ab2:	6a 3f                	push   $0x3f
  jmp alltraps
80106ab4:	e9 2d f7 ff ff       	jmp    801061e6 <alltraps>

80106ab9 <vector64>:
.globl vector64
vector64:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $64
80106abb:	6a 40                	push   $0x40
  jmp alltraps
80106abd:	e9 24 f7 ff ff       	jmp    801061e6 <alltraps>

80106ac2 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $65
80106ac4:	6a 41                	push   $0x41
  jmp alltraps
80106ac6:	e9 1b f7 ff ff       	jmp    801061e6 <alltraps>

80106acb <vector66>:
.globl vector66
vector66:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $66
80106acd:	6a 42                	push   $0x42
  jmp alltraps
80106acf:	e9 12 f7 ff ff       	jmp    801061e6 <alltraps>

80106ad4 <vector67>:
.globl vector67
vector67:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $67
80106ad6:	6a 43                	push   $0x43
  jmp alltraps
80106ad8:	e9 09 f7 ff ff       	jmp    801061e6 <alltraps>

80106add <vector68>:
.globl vector68
vector68:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $68
80106adf:	6a 44                	push   $0x44
  jmp alltraps
80106ae1:	e9 00 f7 ff ff       	jmp    801061e6 <alltraps>

80106ae6 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $69
80106ae8:	6a 45                	push   $0x45
  jmp alltraps
80106aea:	e9 f7 f6 ff ff       	jmp    801061e6 <alltraps>

80106aef <vector70>:
.globl vector70
vector70:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $70
80106af1:	6a 46                	push   $0x46
  jmp alltraps
80106af3:	e9 ee f6 ff ff       	jmp    801061e6 <alltraps>

80106af8 <vector71>:
.globl vector71
vector71:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $71
80106afa:	6a 47                	push   $0x47
  jmp alltraps
80106afc:	e9 e5 f6 ff ff       	jmp    801061e6 <alltraps>

80106b01 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $72
80106b03:	6a 48                	push   $0x48
  jmp alltraps
80106b05:	e9 dc f6 ff ff       	jmp    801061e6 <alltraps>

80106b0a <vector73>:
.globl vector73
vector73:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $73
80106b0c:	6a 49                	push   $0x49
  jmp alltraps
80106b0e:	e9 d3 f6 ff ff       	jmp    801061e6 <alltraps>

80106b13 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $74
80106b15:	6a 4a                	push   $0x4a
  jmp alltraps
80106b17:	e9 ca f6 ff ff       	jmp    801061e6 <alltraps>

80106b1c <vector75>:
.globl vector75
vector75:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $75
80106b1e:	6a 4b                	push   $0x4b
  jmp alltraps
80106b20:	e9 c1 f6 ff ff       	jmp    801061e6 <alltraps>

80106b25 <vector76>:
.globl vector76
vector76:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $76
80106b27:	6a 4c                	push   $0x4c
  jmp alltraps
80106b29:	e9 b8 f6 ff ff       	jmp    801061e6 <alltraps>

80106b2e <vector77>:
.globl vector77
vector77:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $77
80106b30:	6a 4d                	push   $0x4d
  jmp alltraps
80106b32:	e9 af f6 ff ff       	jmp    801061e6 <alltraps>

80106b37 <vector78>:
.globl vector78
vector78:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $78
80106b39:	6a 4e                	push   $0x4e
  jmp alltraps
80106b3b:	e9 a6 f6 ff ff       	jmp    801061e6 <alltraps>

80106b40 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $79
80106b42:	6a 4f                	push   $0x4f
  jmp alltraps
80106b44:	e9 9d f6 ff ff       	jmp    801061e6 <alltraps>

80106b49 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $80
80106b4b:	6a 50                	push   $0x50
  jmp alltraps
80106b4d:	e9 94 f6 ff ff       	jmp    801061e6 <alltraps>

80106b52 <vector81>:
.globl vector81
vector81:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $81
80106b54:	6a 51                	push   $0x51
  jmp alltraps
80106b56:	e9 8b f6 ff ff       	jmp    801061e6 <alltraps>

80106b5b <vector82>:
.globl vector82
vector82:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $82
80106b5d:	6a 52                	push   $0x52
  jmp alltraps
80106b5f:	e9 82 f6 ff ff       	jmp    801061e6 <alltraps>

80106b64 <vector83>:
.globl vector83
vector83:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $83
80106b66:	6a 53                	push   $0x53
  jmp alltraps
80106b68:	e9 79 f6 ff ff       	jmp    801061e6 <alltraps>

80106b6d <vector84>:
.globl vector84
vector84:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $84
80106b6f:	6a 54                	push   $0x54
  jmp alltraps
80106b71:	e9 70 f6 ff ff       	jmp    801061e6 <alltraps>

80106b76 <vector85>:
.globl vector85
vector85:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $85
80106b78:	6a 55                	push   $0x55
  jmp alltraps
80106b7a:	e9 67 f6 ff ff       	jmp    801061e6 <alltraps>

80106b7f <vector86>:
.globl vector86
vector86:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $86
80106b81:	6a 56                	push   $0x56
  jmp alltraps
80106b83:	e9 5e f6 ff ff       	jmp    801061e6 <alltraps>

80106b88 <vector87>:
.globl vector87
vector87:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $87
80106b8a:	6a 57                	push   $0x57
  jmp alltraps
80106b8c:	e9 55 f6 ff ff       	jmp    801061e6 <alltraps>

80106b91 <vector88>:
.globl vector88
vector88:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $88
80106b93:	6a 58                	push   $0x58
  jmp alltraps
80106b95:	e9 4c f6 ff ff       	jmp    801061e6 <alltraps>

80106b9a <vector89>:
.globl vector89
vector89:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $89
80106b9c:	6a 59                	push   $0x59
  jmp alltraps
80106b9e:	e9 43 f6 ff ff       	jmp    801061e6 <alltraps>

80106ba3 <vector90>:
.globl vector90
vector90:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $90
80106ba5:	6a 5a                	push   $0x5a
  jmp alltraps
80106ba7:	e9 3a f6 ff ff       	jmp    801061e6 <alltraps>

80106bac <vector91>:
.globl vector91
vector91:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $91
80106bae:	6a 5b                	push   $0x5b
  jmp alltraps
80106bb0:	e9 31 f6 ff ff       	jmp    801061e6 <alltraps>

80106bb5 <vector92>:
.globl vector92
vector92:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $92
80106bb7:	6a 5c                	push   $0x5c
  jmp alltraps
80106bb9:	e9 28 f6 ff ff       	jmp    801061e6 <alltraps>

80106bbe <vector93>:
.globl vector93
vector93:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $93
80106bc0:	6a 5d                	push   $0x5d
  jmp alltraps
80106bc2:	e9 1f f6 ff ff       	jmp    801061e6 <alltraps>

80106bc7 <vector94>:
.globl vector94
vector94:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $94
80106bc9:	6a 5e                	push   $0x5e
  jmp alltraps
80106bcb:	e9 16 f6 ff ff       	jmp    801061e6 <alltraps>

80106bd0 <vector95>:
.globl vector95
vector95:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $95
80106bd2:	6a 5f                	push   $0x5f
  jmp alltraps
80106bd4:	e9 0d f6 ff ff       	jmp    801061e6 <alltraps>

80106bd9 <vector96>:
.globl vector96
vector96:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $96
80106bdb:	6a 60                	push   $0x60
  jmp alltraps
80106bdd:	e9 04 f6 ff ff       	jmp    801061e6 <alltraps>

80106be2 <vector97>:
.globl vector97
vector97:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $97
80106be4:	6a 61                	push   $0x61
  jmp alltraps
80106be6:	e9 fb f5 ff ff       	jmp    801061e6 <alltraps>

80106beb <vector98>:
.globl vector98
vector98:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $98
80106bed:	6a 62                	push   $0x62
  jmp alltraps
80106bef:	e9 f2 f5 ff ff       	jmp    801061e6 <alltraps>

80106bf4 <vector99>:
.globl vector99
vector99:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $99
80106bf6:	6a 63                	push   $0x63
  jmp alltraps
80106bf8:	e9 e9 f5 ff ff       	jmp    801061e6 <alltraps>

80106bfd <vector100>:
.globl vector100
vector100:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $100
80106bff:	6a 64                	push   $0x64
  jmp alltraps
80106c01:	e9 e0 f5 ff ff       	jmp    801061e6 <alltraps>

80106c06 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $101
80106c08:	6a 65                	push   $0x65
  jmp alltraps
80106c0a:	e9 d7 f5 ff ff       	jmp    801061e6 <alltraps>

80106c0f <vector102>:
.globl vector102
vector102:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $102
80106c11:	6a 66                	push   $0x66
  jmp alltraps
80106c13:	e9 ce f5 ff ff       	jmp    801061e6 <alltraps>

80106c18 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $103
80106c1a:	6a 67                	push   $0x67
  jmp alltraps
80106c1c:	e9 c5 f5 ff ff       	jmp    801061e6 <alltraps>

80106c21 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $104
80106c23:	6a 68                	push   $0x68
  jmp alltraps
80106c25:	e9 bc f5 ff ff       	jmp    801061e6 <alltraps>

80106c2a <vector105>:
.globl vector105
vector105:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $105
80106c2c:	6a 69                	push   $0x69
  jmp alltraps
80106c2e:	e9 b3 f5 ff ff       	jmp    801061e6 <alltraps>

80106c33 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $106
80106c35:	6a 6a                	push   $0x6a
  jmp alltraps
80106c37:	e9 aa f5 ff ff       	jmp    801061e6 <alltraps>

80106c3c <vector107>:
.globl vector107
vector107:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $107
80106c3e:	6a 6b                	push   $0x6b
  jmp alltraps
80106c40:	e9 a1 f5 ff ff       	jmp    801061e6 <alltraps>

80106c45 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $108
80106c47:	6a 6c                	push   $0x6c
  jmp alltraps
80106c49:	e9 98 f5 ff ff       	jmp    801061e6 <alltraps>

80106c4e <vector109>:
.globl vector109
vector109:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $109
80106c50:	6a 6d                	push   $0x6d
  jmp alltraps
80106c52:	e9 8f f5 ff ff       	jmp    801061e6 <alltraps>

80106c57 <vector110>:
.globl vector110
vector110:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $110
80106c59:	6a 6e                	push   $0x6e
  jmp alltraps
80106c5b:	e9 86 f5 ff ff       	jmp    801061e6 <alltraps>

80106c60 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $111
80106c62:	6a 6f                	push   $0x6f
  jmp alltraps
80106c64:	e9 7d f5 ff ff       	jmp    801061e6 <alltraps>

80106c69 <vector112>:
.globl vector112
vector112:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $112
80106c6b:	6a 70                	push   $0x70
  jmp alltraps
80106c6d:	e9 74 f5 ff ff       	jmp    801061e6 <alltraps>

80106c72 <vector113>:
.globl vector113
vector113:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $113
80106c74:	6a 71                	push   $0x71
  jmp alltraps
80106c76:	e9 6b f5 ff ff       	jmp    801061e6 <alltraps>

80106c7b <vector114>:
.globl vector114
vector114:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $114
80106c7d:	6a 72                	push   $0x72
  jmp alltraps
80106c7f:	e9 62 f5 ff ff       	jmp    801061e6 <alltraps>

80106c84 <vector115>:
.globl vector115
vector115:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $115
80106c86:	6a 73                	push   $0x73
  jmp alltraps
80106c88:	e9 59 f5 ff ff       	jmp    801061e6 <alltraps>

80106c8d <vector116>:
.globl vector116
vector116:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $116
80106c8f:	6a 74                	push   $0x74
  jmp alltraps
80106c91:	e9 50 f5 ff ff       	jmp    801061e6 <alltraps>

80106c96 <vector117>:
.globl vector117
vector117:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $117
80106c98:	6a 75                	push   $0x75
  jmp alltraps
80106c9a:	e9 47 f5 ff ff       	jmp    801061e6 <alltraps>

80106c9f <vector118>:
.globl vector118
vector118:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $118
80106ca1:	6a 76                	push   $0x76
  jmp alltraps
80106ca3:	e9 3e f5 ff ff       	jmp    801061e6 <alltraps>

80106ca8 <vector119>:
.globl vector119
vector119:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $119
80106caa:	6a 77                	push   $0x77
  jmp alltraps
80106cac:	e9 35 f5 ff ff       	jmp    801061e6 <alltraps>

80106cb1 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $120
80106cb3:	6a 78                	push   $0x78
  jmp alltraps
80106cb5:	e9 2c f5 ff ff       	jmp    801061e6 <alltraps>

80106cba <vector121>:
.globl vector121
vector121:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $121
80106cbc:	6a 79                	push   $0x79
  jmp alltraps
80106cbe:	e9 23 f5 ff ff       	jmp    801061e6 <alltraps>

80106cc3 <vector122>:
.globl vector122
vector122:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $122
80106cc5:	6a 7a                	push   $0x7a
  jmp alltraps
80106cc7:	e9 1a f5 ff ff       	jmp    801061e6 <alltraps>

80106ccc <vector123>:
.globl vector123
vector123:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $123
80106cce:	6a 7b                	push   $0x7b
  jmp alltraps
80106cd0:	e9 11 f5 ff ff       	jmp    801061e6 <alltraps>

80106cd5 <vector124>:
.globl vector124
vector124:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $124
80106cd7:	6a 7c                	push   $0x7c
  jmp alltraps
80106cd9:	e9 08 f5 ff ff       	jmp    801061e6 <alltraps>

80106cde <vector125>:
.globl vector125
vector125:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $125
80106ce0:	6a 7d                	push   $0x7d
  jmp alltraps
80106ce2:	e9 ff f4 ff ff       	jmp    801061e6 <alltraps>

80106ce7 <vector126>:
.globl vector126
vector126:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $126
80106ce9:	6a 7e                	push   $0x7e
  jmp alltraps
80106ceb:	e9 f6 f4 ff ff       	jmp    801061e6 <alltraps>

80106cf0 <vector127>:
.globl vector127
vector127:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $127
80106cf2:	6a 7f                	push   $0x7f
  jmp alltraps
80106cf4:	e9 ed f4 ff ff       	jmp    801061e6 <alltraps>

80106cf9 <vector128>:
.globl vector128
vector128:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $128
80106cfb:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d00:	e9 e1 f4 ff ff       	jmp    801061e6 <alltraps>

80106d05 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $129
80106d07:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d0c:	e9 d5 f4 ff ff       	jmp    801061e6 <alltraps>

80106d11 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $130
80106d13:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d18:	e9 c9 f4 ff ff       	jmp    801061e6 <alltraps>

80106d1d <vector131>:
.globl vector131
vector131:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $131
80106d1f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d24:	e9 bd f4 ff ff       	jmp    801061e6 <alltraps>

80106d29 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $132
80106d2b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d30:	e9 b1 f4 ff ff       	jmp    801061e6 <alltraps>

80106d35 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $133
80106d37:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d3c:	e9 a5 f4 ff ff       	jmp    801061e6 <alltraps>

80106d41 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $134
80106d43:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d48:	e9 99 f4 ff ff       	jmp    801061e6 <alltraps>

80106d4d <vector135>:
.globl vector135
vector135:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $135
80106d4f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d54:	e9 8d f4 ff ff       	jmp    801061e6 <alltraps>

80106d59 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $136
80106d5b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d60:	e9 81 f4 ff ff       	jmp    801061e6 <alltraps>

80106d65 <vector137>:
.globl vector137
vector137:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $137
80106d67:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d6c:	e9 75 f4 ff ff       	jmp    801061e6 <alltraps>

80106d71 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $138
80106d73:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d78:	e9 69 f4 ff ff       	jmp    801061e6 <alltraps>

80106d7d <vector139>:
.globl vector139
vector139:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $139
80106d7f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d84:	e9 5d f4 ff ff       	jmp    801061e6 <alltraps>

80106d89 <vector140>:
.globl vector140
vector140:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $140
80106d8b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d90:	e9 51 f4 ff ff       	jmp    801061e6 <alltraps>

80106d95 <vector141>:
.globl vector141
vector141:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $141
80106d97:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106d9c:	e9 45 f4 ff ff       	jmp    801061e6 <alltraps>

80106da1 <vector142>:
.globl vector142
vector142:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $142
80106da3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106da8:	e9 39 f4 ff ff       	jmp    801061e6 <alltraps>

80106dad <vector143>:
.globl vector143
vector143:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $143
80106daf:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106db4:	e9 2d f4 ff ff       	jmp    801061e6 <alltraps>

80106db9 <vector144>:
.globl vector144
vector144:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $144
80106dbb:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106dc0:	e9 21 f4 ff ff       	jmp    801061e6 <alltraps>

80106dc5 <vector145>:
.globl vector145
vector145:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $145
80106dc7:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106dcc:	e9 15 f4 ff ff       	jmp    801061e6 <alltraps>

80106dd1 <vector146>:
.globl vector146
vector146:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $146
80106dd3:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106dd8:	e9 09 f4 ff ff       	jmp    801061e6 <alltraps>

80106ddd <vector147>:
.globl vector147
vector147:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $147
80106ddf:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106de4:	e9 fd f3 ff ff       	jmp    801061e6 <alltraps>

80106de9 <vector148>:
.globl vector148
vector148:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $148
80106deb:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106df0:	e9 f1 f3 ff ff       	jmp    801061e6 <alltraps>

80106df5 <vector149>:
.globl vector149
vector149:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $149
80106df7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106dfc:	e9 e5 f3 ff ff       	jmp    801061e6 <alltraps>

80106e01 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $150
80106e03:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e08:	e9 d9 f3 ff ff       	jmp    801061e6 <alltraps>

80106e0d <vector151>:
.globl vector151
vector151:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $151
80106e0f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e14:	e9 cd f3 ff ff       	jmp    801061e6 <alltraps>

80106e19 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $152
80106e1b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e20:	e9 c1 f3 ff ff       	jmp    801061e6 <alltraps>

80106e25 <vector153>:
.globl vector153
vector153:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $153
80106e27:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e2c:	e9 b5 f3 ff ff       	jmp    801061e6 <alltraps>

80106e31 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $154
80106e33:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e38:	e9 a9 f3 ff ff       	jmp    801061e6 <alltraps>

80106e3d <vector155>:
.globl vector155
vector155:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $155
80106e3f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e44:	e9 9d f3 ff ff       	jmp    801061e6 <alltraps>

80106e49 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $156
80106e4b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e50:	e9 91 f3 ff ff       	jmp    801061e6 <alltraps>

80106e55 <vector157>:
.globl vector157
vector157:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $157
80106e57:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e5c:	e9 85 f3 ff ff       	jmp    801061e6 <alltraps>

80106e61 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $158
80106e63:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e68:	e9 79 f3 ff ff       	jmp    801061e6 <alltraps>

80106e6d <vector159>:
.globl vector159
vector159:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $159
80106e6f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e74:	e9 6d f3 ff ff       	jmp    801061e6 <alltraps>

80106e79 <vector160>:
.globl vector160
vector160:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $160
80106e7b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e80:	e9 61 f3 ff ff       	jmp    801061e6 <alltraps>

80106e85 <vector161>:
.globl vector161
vector161:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $161
80106e87:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e8c:	e9 55 f3 ff ff       	jmp    801061e6 <alltraps>

80106e91 <vector162>:
.globl vector162
vector162:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $162
80106e93:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106e98:	e9 49 f3 ff ff       	jmp    801061e6 <alltraps>

80106e9d <vector163>:
.globl vector163
vector163:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $163
80106e9f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ea4:	e9 3d f3 ff ff       	jmp    801061e6 <alltraps>

80106ea9 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $164
80106eab:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106eb0:	e9 31 f3 ff ff       	jmp    801061e6 <alltraps>

80106eb5 <vector165>:
.globl vector165
vector165:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $165
80106eb7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ebc:	e9 25 f3 ff ff       	jmp    801061e6 <alltraps>

80106ec1 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $166
80106ec3:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ec8:	e9 19 f3 ff ff       	jmp    801061e6 <alltraps>

80106ecd <vector167>:
.globl vector167
vector167:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $167
80106ecf:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ed4:	e9 0d f3 ff ff       	jmp    801061e6 <alltraps>

80106ed9 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $168
80106edb:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ee0:	e9 01 f3 ff ff       	jmp    801061e6 <alltraps>

80106ee5 <vector169>:
.globl vector169
vector169:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $169
80106ee7:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106eec:	e9 f5 f2 ff ff       	jmp    801061e6 <alltraps>

80106ef1 <vector170>:
.globl vector170
vector170:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $170
80106ef3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106ef8:	e9 e9 f2 ff ff       	jmp    801061e6 <alltraps>

80106efd <vector171>:
.globl vector171
vector171:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $171
80106eff:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f04:	e9 dd f2 ff ff       	jmp    801061e6 <alltraps>

80106f09 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $172
80106f0b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f10:	e9 d1 f2 ff ff       	jmp    801061e6 <alltraps>

80106f15 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $173
80106f17:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f1c:	e9 c5 f2 ff ff       	jmp    801061e6 <alltraps>

80106f21 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $174
80106f23:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f28:	e9 b9 f2 ff ff       	jmp    801061e6 <alltraps>

80106f2d <vector175>:
.globl vector175
vector175:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $175
80106f2f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f34:	e9 ad f2 ff ff       	jmp    801061e6 <alltraps>

80106f39 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $176
80106f3b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f40:	e9 a1 f2 ff ff       	jmp    801061e6 <alltraps>

80106f45 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $177
80106f47:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f4c:	e9 95 f2 ff ff       	jmp    801061e6 <alltraps>

80106f51 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $178
80106f53:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f58:	e9 89 f2 ff ff       	jmp    801061e6 <alltraps>

80106f5d <vector179>:
.globl vector179
vector179:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $179
80106f5f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f64:	e9 7d f2 ff ff       	jmp    801061e6 <alltraps>

80106f69 <vector180>:
.globl vector180
vector180:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $180
80106f6b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f70:	e9 71 f2 ff ff       	jmp    801061e6 <alltraps>

80106f75 <vector181>:
.globl vector181
vector181:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $181
80106f77:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f7c:	e9 65 f2 ff ff       	jmp    801061e6 <alltraps>

80106f81 <vector182>:
.globl vector182
vector182:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $182
80106f83:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f88:	e9 59 f2 ff ff       	jmp    801061e6 <alltraps>

80106f8d <vector183>:
.globl vector183
vector183:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $183
80106f8f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f94:	e9 4d f2 ff ff       	jmp    801061e6 <alltraps>

80106f99 <vector184>:
.globl vector184
vector184:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $184
80106f9b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fa0:	e9 41 f2 ff ff       	jmp    801061e6 <alltraps>

80106fa5 <vector185>:
.globl vector185
vector185:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $185
80106fa7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fac:	e9 35 f2 ff ff       	jmp    801061e6 <alltraps>

80106fb1 <vector186>:
.globl vector186
vector186:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $186
80106fb3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fb8:	e9 29 f2 ff ff       	jmp    801061e6 <alltraps>

80106fbd <vector187>:
.globl vector187
vector187:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $187
80106fbf:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fc4:	e9 1d f2 ff ff       	jmp    801061e6 <alltraps>

80106fc9 <vector188>:
.globl vector188
vector188:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $188
80106fcb:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106fd0:	e9 11 f2 ff ff       	jmp    801061e6 <alltraps>

80106fd5 <vector189>:
.globl vector189
vector189:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $189
80106fd7:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fdc:	e9 05 f2 ff ff       	jmp    801061e6 <alltraps>

80106fe1 <vector190>:
.globl vector190
vector190:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $190
80106fe3:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106fe8:	e9 f9 f1 ff ff       	jmp    801061e6 <alltraps>

80106fed <vector191>:
.globl vector191
vector191:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $191
80106fef:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106ff4:	e9 ed f1 ff ff       	jmp    801061e6 <alltraps>

80106ff9 <vector192>:
.globl vector192
vector192:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $192
80106ffb:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107000:	e9 e1 f1 ff ff       	jmp    801061e6 <alltraps>

80107005 <vector193>:
.globl vector193
vector193:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $193
80107007:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010700c:	e9 d5 f1 ff ff       	jmp    801061e6 <alltraps>

80107011 <vector194>:
.globl vector194
vector194:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $194
80107013:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107018:	e9 c9 f1 ff ff       	jmp    801061e6 <alltraps>

8010701d <vector195>:
.globl vector195
vector195:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $195
8010701f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107024:	e9 bd f1 ff ff       	jmp    801061e6 <alltraps>

80107029 <vector196>:
.globl vector196
vector196:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $196
8010702b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107030:	e9 b1 f1 ff ff       	jmp    801061e6 <alltraps>

80107035 <vector197>:
.globl vector197
vector197:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $197
80107037:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010703c:	e9 a5 f1 ff ff       	jmp    801061e6 <alltraps>

80107041 <vector198>:
.globl vector198
vector198:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $198
80107043:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107048:	e9 99 f1 ff ff       	jmp    801061e6 <alltraps>

8010704d <vector199>:
.globl vector199
vector199:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $199
8010704f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107054:	e9 8d f1 ff ff       	jmp    801061e6 <alltraps>

80107059 <vector200>:
.globl vector200
vector200:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $200
8010705b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107060:	e9 81 f1 ff ff       	jmp    801061e6 <alltraps>

80107065 <vector201>:
.globl vector201
vector201:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $201
80107067:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010706c:	e9 75 f1 ff ff       	jmp    801061e6 <alltraps>

80107071 <vector202>:
.globl vector202
vector202:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $202
80107073:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107078:	e9 69 f1 ff ff       	jmp    801061e6 <alltraps>

8010707d <vector203>:
.globl vector203
vector203:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $203
8010707f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107084:	e9 5d f1 ff ff       	jmp    801061e6 <alltraps>

80107089 <vector204>:
.globl vector204
vector204:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $204
8010708b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107090:	e9 51 f1 ff ff       	jmp    801061e6 <alltraps>

80107095 <vector205>:
.globl vector205
vector205:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $205
80107097:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010709c:	e9 45 f1 ff ff       	jmp    801061e6 <alltraps>

801070a1 <vector206>:
.globl vector206
vector206:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $206
801070a3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070a8:	e9 39 f1 ff ff       	jmp    801061e6 <alltraps>

801070ad <vector207>:
.globl vector207
vector207:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $207
801070af:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070b4:	e9 2d f1 ff ff       	jmp    801061e6 <alltraps>

801070b9 <vector208>:
.globl vector208
vector208:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $208
801070bb:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070c0:	e9 21 f1 ff ff       	jmp    801061e6 <alltraps>

801070c5 <vector209>:
.globl vector209
vector209:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $209
801070c7:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070cc:	e9 15 f1 ff ff       	jmp    801061e6 <alltraps>

801070d1 <vector210>:
.globl vector210
vector210:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $210
801070d3:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070d8:	e9 09 f1 ff ff       	jmp    801061e6 <alltraps>

801070dd <vector211>:
.globl vector211
vector211:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $211
801070df:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070e4:	e9 fd f0 ff ff       	jmp    801061e6 <alltraps>

801070e9 <vector212>:
.globl vector212
vector212:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $212
801070eb:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801070f0:	e9 f1 f0 ff ff       	jmp    801061e6 <alltraps>

801070f5 <vector213>:
.globl vector213
vector213:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $213
801070f7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801070fc:	e9 e5 f0 ff ff       	jmp    801061e6 <alltraps>

80107101 <vector214>:
.globl vector214
vector214:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $214
80107103:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107108:	e9 d9 f0 ff ff       	jmp    801061e6 <alltraps>

8010710d <vector215>:
.globl vector215
vector215:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $215
8010710f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107114:	e9 cd f0 ff ff       	jmp    801061e6 <alltraps>

80107119 <vector216>:
.globl vector216
vector216:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $216
8010711b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107120:	e9 c1 f0 ff ff       	jmp    801061e6 <alltraps>

80107125 <vector217>:
.globl vector217
vector217:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $217
80107127:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010712c:	e9 b5 f0 ff ff       	jmp    801061e6 <alltraps>

80107131 <vector218>:
.globl vector218
vector218:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $218
80107133:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107138:	e9 a9 f0 ff ff       	jmp    801061e6 <alltraps>

8010713d <vector219>:
.globl vector219
vector219:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $219
8010713f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107144:	e9 9d f0 ff ff       	jmp    801061e6 <alltraps>

80107149 <vector220>:
.globl vector220
vector220:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $220
8010714b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107150:	e9 91 f0 ff ff       	jmp    801061e6 <alltraps>

80107155 <vector221>:
.globl vector221
vector221:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $221
80107157:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010715c:	e9 85 f0 ff ff       	jmp    801061e6 <alltraps>

80107161 <vector222>:
.globl vector222
vector222:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $222
80107163:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107168:	e9 79 f0 ff ff       	jmp    801061e6 <alltraps>

8010716d <vector223>:
.globl vector223
vector223:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $223
8010716f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107174:	e9 6d f0 ff ff       	jmp    801061e6 <alltraps>

80107179 <vector224>:
.globl vector224
vector224:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $224
8010717b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107180:	e9 61 f0 ff ff       	jmp    801061e6 <alltraps>

80107185 <vector225>:
.globl vector225
vector225:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $225
80107187:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010718c:	e9 55 f0 ff ff       	jmp    801061e6 <alltraps>

80107191 <vector226>:
.globl vector226
vector226:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $226
80107193:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107198:	e9 49 f0 ff ff       	jmp    801061e6 <alltraps>

8010719d <vector227>:
.globl vector227
vector227:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $227
8010719f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071a4:	e9 3d f0 ff ff       	jmp    801061e6 <alltraps>

801071a9 <vector228>:
.globl vector228
vector228:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $228
801071ab:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071b0:	e9 31 f0 ff ff       	jmp    801061e6 <alltraps>

801071b5 <vector229>:
.globl vector229
vector229:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $229
801071b7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071bc:	e9 25 f0 ff ff       	jmp    801061e6 <alltraps>

801071c1 <vector230>:
.globl vector230
vector230:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $230
801071c3:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071c8:	e9 19 f0 ff ff       	jmp    801061e6 <alltraps>

801071cd <vector231>:
.globl vector231
vector231:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $231
801071cf:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071d4:	e9 0d f0 ff ff       	jmp    801061e6 <alltraps>

801071d9 <vector232>:
.globl vector232
vector232:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $232
801071db:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071e0:	e9 01 f0 ff ff       	jmp    801061e6 <alltraps>

801071e5 <vector233>:
.globl vector233
vector233:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $233
801071e7:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801071ec:	e9 f5 ef ff ff       	jmp    801061e6 <alltraps>

801071f1 <vector234>:
.globl vector234
vector234:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $234
801071f3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801071f8:	e9 e9 ef ff ff       	jmp    801061e6 <alltraps>

801071fd <vector235>:
.globl vector235
vector235:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $235
801071ff:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107204:	e9 dd ef ff ff       	jmp    801061e6 <alltraps>

80107209 <vector236>:
.globl vector236
vector236:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $236
8010720b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107210:	e9 d1 ef ff ff       	jmp    801061e6 <alltraps>

80107215 <vector237>:
.globl vector237
vector237:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $237
80107217:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010721c:	e9 c5 ef ff ff       	jmp    801061e6 <alltraps>

80107221 <vector238>:
.globl vector238
vector238:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $238
80107223:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107228:	e9 b9 ef ff ff       	jmp    801061e6 <alltraps>

8010722d <vector239>:
.globl vector239
vector239:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $239
8010722f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107234:	e9 ad ef ff ff       	jmp    801061e6 <alltraps>

80107239 <vector240>:
.globl vector240
vector240:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $240
8010723b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107240:	e9 a1 ef ff ff       	jmp    801061e6 <alltraps>

80107245 <vector241>:
.globl vector241
vector241:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $241
80107247:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010724c:	e9 95 ef ff ff       	jmp    801061e6 <alltraps>

80107251 <vector242>:
.globl vector242
vector242:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $242
80107253:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107258:	e9 89 ef ff ff       	jmp    801061e6 <alltraps>

8010725d <vector243>:
.globl vector243
vector243:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $243
8010725f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107264:	e9 7d ef ff ff       	jmp    801061e6 <alltraps>

80107269 <vector244>:
.globl vector244
vector244:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $244
8010726b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107270:	e9 71 ef ff ff       	jmp    801061e6 <alltraps>

80107275 <vector245>:
.globl vector245
vector245:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $245
80107277:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010727c:	e9 65 ef ff ff       	jmp    801061e6 <alltraps>

80107281 <vector246>:
.globl vector246
vector246:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $246
80107283:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107288:	e9 59 ef ff ff       	jmp    801061e6 <alltraps>

8010728d <vector247>:
.globl vector247
vector247:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $247
8010728f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107294:	e9 4d ef ff ff       	jmp    801061e6 <alltraps>

80107299 <vector248>:
.globl vector248
vector248:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $248
8010729b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072a0:	e9 41 ef ff ff       	jmp    801061e6 <alltraps>

801072a5 <vector249>:
.globl vector249
vector249:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $249
801072a7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072ac:	e9 35 ef ff ff       	jmp    801061e6 <alltraps>

801072b1 <vector250>:
.globl vector250
vector250:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $250
801072b3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072b8:	e9 29 ef ff ff       	jmp    801061e6 <alltraps>

801072bd <vector251>:
.globl vector251
vector251:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $251
801072bf:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072c4:	e9 1d ef ff ff       	jmp    801061e6 <alltraps>

801072c9 <vector252>:
.globl vector252
vector252:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $252
801072cb:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072d0:	e9 11 ef ff ff       	jmp    801061e6 <alltraps>

801072d5 <vector253>:
.globl vector253
vector253:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $253
801072d7:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072dc:	e9 05 ef ff ff       	jmp    801061e6 <alltraps>

801072e1 <vector254>:
.globl vector254
vector254:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $254
801072e3:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801072e8:	e9 f9 ee ff ff       	jmp    801061e6 <alltraps>

801072ed <vector255>:
.globl vector255
vector255:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $255
801072ef:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801072f4:	e9 ed ee ff ff       	jmp    801061e6 <alltraps>

801072f9 <lgdt>:
{
801072f9:	55                   	push   %ebp
801072fa:	89 e5                	mov    %esp,%ebp
801072fc:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801072ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107302:	83 e8 01             	sub    $0x1,%eax
80107305:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107309:	8b 45 08             	mov    0x8(%ebp),%eax
8010730c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107310:	8b 45 08             	mov    0x8(%ebp),%eax
80107313:	c1 e8 10             	shr    $0x10,%eax
80107316:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010731a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010731d:	0f 01 10             	lgdtl  (%eax)
}
80107320:	90                   	nop
80107321:	c9                   	leave
80107322:	c3                   	ret

80107323 <ltr>:
{
80107323:	55                   	push   %ebp
80107324:	89 e5                	mov    %esp,%ebp
80107326:	83 ec 04             	sub    $0x4,%esp
80107329:	8b 45 08             	mov    0x8(%ebp),%eax
8010732c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107330:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107334:	0f 00 d8             	ltr    %eax
}
80107337:	90                   	nop
80107338:	c9                   	leave
80107339:	c3                   	ret

8010733a <lcr3>:

static inline void
lcr3(uint val)
{
8010733a:	55                   	push   %ebp
8010733b:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010733d:	8b 45 08             	mov    0x8(%ebp),%eax
80107340:	0f 22 d8             	mov    %eax,%cr3
}
80107343:	90                   	nop
80107344:	5d                   	pop    %ebp
80107345:	c3                   	ret

80107346 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107346:	55                   	push   %ebp
80107347:	89 e5                	mov    %esp,%ebp
80107349:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010734c:	e8 53 c6 ff ff       	call   801039a4 <cpuid>
80107351:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107357:	05 80 74 19 80       	add    $0x80197480,%eax
8010735c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010735f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107362:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107374:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010737f:	83 e2 f0             	and    $0xfffffff0,%edx
80107382:	83 ca 0a             	or     $0xa,%edx
80107385:	88 50 7d             	mov    %dl,0x7d(%eax)
80107388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010738f:	83 ca 10             	or     $0x10,%edx
80107392:	88 50 7d             	mov    %dl,0x7d(%eax)
80107395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107398:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010739c:	83 e2 9f             	and    $0xffffff9f,%edx
8010739f:	88 50 7d             	mov    %dl,0x7d(%eax)
801073a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073a9:	83 ca 80             	or     $0xffffff80,%edx
801073ac:	88 50 7d             	mov    %dl,0x7d(%eax)
801073af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073b6:	83 ca 0f             	or     $0xf,%edx
801073b9:	88 50 7e             	mov    %dl,0x7e(%eax)
801073bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073c3:	83 e2 ef             	and    $0xffffffef,%edx
801073c6:	88 50 7e             	mov    %dl,0x7e(%eax)
801073c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073d0:	83 e2 df             	and    $0xffffffdf,%edx
801073d3:	88 50 7e             	mov    %dl,0x7e(%eax)
801073d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073dd:	83 ca 40             	or     $0x40,%edx
801073e0:	88 50 7e             	mov    %dl,0x7e(%eax)
801073e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073ea:	83 ca 80             	or     $0xffffff80,%edx
801073ed:	88 50 7e             	mov    %dl,0x7e(%eax)
801073f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fa:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107401:	ff ff 
80107403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107406:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010740d:	00 00 
8010740f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107412:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107423:	83 e2 f0             	and    $0xfffffff0,%edx
80107426:	83 ca 02             	or     $0x2,%edx
80107429:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010742f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107432:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107439:	83 ca 10             	or     $0x10,%edx
8010743c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107445:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010744c:	83 e2 9f             	and    $0xffffff9f,%edx
8010744f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107458:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010745f:	83 ca 80             	or     $0xffffff80,%edx
80107462:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107472:	83 ca 0f             	or     $0xf,%edx
80107475:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010747b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107485:	83 e2 ef             	and    $0xffffffef,%edx
80107488:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010748e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107491:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107498:	83 e2 df             	and    $0xffffffdf,%edx
8010749b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074ab:	83 ca 40             	or     $0x40,%edx
801074ae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074be:	83 ca 80             	or     $0xffffff80,%edx
801074c1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ca:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d4:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074db:	ff ff 
801074dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e0:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801074e7:	00 00 
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801074f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074fd:	83 e2 f0             	and    $0xfffffff0,%edx
80107500:	83 ca 0a             	or     $0xa,%edx
80107503:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107513:	83 ca 10             	or     $0x10,%edx
80107516:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010751c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107526:	83 ca 60             	or     $0x60,%edx
80107529:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010752f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107532:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107539:	83 ca 80             	or     $0xffffff80,%edx
8010753c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107545:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010754c:	83 ca 0f             	or     $0xf,%edx
8010754f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107558:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010755f:	83 e2 ef             	and    $0xffffffef,%edx
80107562:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107572:	83 e2 df             	and    $0xffffffdf,%edx
80107575:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010757b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107585:	83 ca 40             	or     $0x40,%edx
80107588:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010758e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107591:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107598:	83 ca 80             	or     $0xffffff80,%edx
8010759b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ae:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075b5:	ff ff 
801075b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ba:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075c1:	00 00 
801075c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075d7:	83 e2 f0             	and    $0xfffffff0,%edx
801075da:	83 ca 02             	or     $0x2,%edx
801075dd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075ed:	83 ca 10             	or     $0x10,%edx
801075f0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107600:	83 ca 60             	or     $0x60,%edx
80107603:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107613:	83 ca 80             	or     $0xffffff80,%edx
80107616:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010761c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107626:	83 ca 0f             	or     $0xf,%edx
80107629:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010762f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107632:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107639:	83 e2 ef             	and    $0xffffffef,%edx
8010763c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107645:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010764c:	83 e2 df             	and    $0xffffffdf,%edx
8010764f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107658:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010765f:	83 ca 40             	or     $0x40,%edx
80107662:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107672:	83 ca 80             	or     $0xffffff80,%edx
80107675:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010767b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107688:	83 c0 70             	add    $0x70,%eax
8010768b:	83 ec 08             	sub    $0x8,%esp
8010768e:	6a 30                	push   $0x30
80107690:	50                   	push   %eax
80107691:	e8 63 fc ff ff       	call   801072f9 <lgdt>
80107696:	83 c4 10             	add    $0x10,%esp
}
80107699:	90                   	nop
8010769a:	c9                   	leave
8010769b:	c3                   	ret

8010769c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010769c:	55                   	push   %ebp
8010769d:	89 e5                	mov    %esp,%ebp
8010769f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801076a5:	c1 e8 16             	shr    $0x16,%eax
801076a8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076af:	8b 45 08             	mov    0x8(%ebp),%eax
801076b2:	01 d0                	add    %edx,%eax
801076b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ba:	8b 00                	mov    (%eax),%eax
801076bc:	83 e0 01             	and    $0x1,%eax
801076bf:	85 c0                	test   %eax,%eax
801076c1:	74 14                	je     801076d7 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076c6:	8b 00                	mov    (%eax),%eax
801076c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076cd:	05 00 00 00 80       	add    $0x80000000,%eax
801076d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076d5:	eb 42                	jmp    80107719 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076db:	74 0e                	je     801076eb <walkpgdir+0x4f>
801076dd:	e8 c6 b0 ff ff       	call   801027a8 <kalloc>
801076e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801076e9:	75 07                	jne    801076f2 <walkpgdir+0x56>
      return 0;
801076eb:	b8 00 00 00 00       	mov    $0x0,%eax
801076f0:	eb 3e                	jmp    80107730 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801076f2:	83 ec 04             	sub    $0x4,%esp
801076f5:	68 00 10 00 00       	push   $0x1000
801076fa:	6a 00                	push   $0x0
801076fc:	ff 75 f4             	push   -0xc(%ebp)
801076ff:	e8 fb d6 ff ff       	call   80104dff <memset>
80107704:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770a:	05 00 00 00 80       	add    $0x80000000,%eax
8010770f:	83 c8 07             	or     $0x7,%eax
80107712:	89 c2                	mov    %eax,%edx
80107714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107717:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107719:	8b 45 0c             	mov    0xc(%ebp),%eax
8010771c:	c1 e8 0c             	shr    $0xc,%eax
8010771f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107724:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010772b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772e:	01 d0                	add    %edx,%eax
}
80107730:	c9                   	leave
80107731:	c3                   	ret

80107732 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107732:	55                   	push   %ebp
80107733:	89 e5                	mov    %esp,%ebp
80107735:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107738:	8b 45 0c             	mov    0xc(%ebp),%eax
8010773b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107740:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107743:	8b 55 0c             	mov    0xc(%ebp),%edx
80107746:	8b 45 10             	mov    0x10(%ebp),%eax
80107749:	01 d0                	add    %edx,%eax
8010774b:	83 e8 01             	sub    $0x1,%eax
8010774e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107753:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107756:	83 ec 04             	sub    $0x4,%esp
80107759:	6a 01                	push   $0x1
8010775b:	ff 75 f4             	push   -0xc(%ebp)
8010775e:	ff 75 08             	push   0x8(%ebp)
80107761:	e8 36 ff ff ff       	call   8010769c <walkpgdir>
80107766:	83 c4 10             	add    $0x10,%esp
80107769:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010776c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107770:	75 07                	jne    80107779 <mappages+0x47>
      return -1;
80107772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107777:	eb 47                	jmp    801077c0 <mappages+0x8e>
    if(*pte & PTE_P)
80107779:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010777c:	8b 00                	mov    (%eax),%eax
8010777e:	83 e0 01             	and    $0x1,%eax
80107781:	85 c0                	test   %eax,%eax
80107783:	74 0d                	je     80107792 <mappages+0x60>
      panic("remap");
80107785:	83 ec 0c             	sub    $0xc,%esp
80107788:	68 b8 aa 10 80       	push   $0x8010aab8
8010778d:	e8 17 8e ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107792:	8b 45 18             	mov    0x18(%ebp),%eax
80107795:	0b 45 14             	or     0x14(%ebp),%eax
80107798:	83 c8 01             	or     $0x1,%eax
8010779b:	89 c2                	mov    %eax,%edx
8010779d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077a0:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077a8:	74 10                	je     801077ba <mappages+0x88>
      break;
    a += PGSIZE;
801077aa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801077b1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077b8:	eb 9c                	jmp    80107756 <mappages+0x24>
      break;
801077ba:	90                   	nop
  }
  return 0;
801077bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077c0:	c9                   	leave
801077c1:	c3                   	ret

801077c2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077c2:	55                   	push   %ebp
801077c3:	89 e5                	mov    %esp,%ebp
801077c5:	53                   	push   %ebx
801077c6:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077c9:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077d0:	a1 60 77 19 80       	mov    0x80197760,%eax
801077d5:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801077da:	29 c2                	sub    %eax,%edx
801077dc:	89 d0                	mov    %edx,%eax
801077de:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077e1:	a1 58 77 19 80       	mov    0x80197758,%eax
801077e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077e9:	8b 15 58 77 19 80    	mov    0x80197758,%edx
801077ef:	a1 60 77 19 80       	mov    0x80197760,%eax
801077f4:	01 d0                	add    %edx,%eax
801077f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
801077f9:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107803:	83 c0 30             	add    $0x30,%eax
80107806:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107809:	89 10                	mov    %edx,(%eax)
8010780b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010780e:	89 50 04             	mov    %edx,0x4(%eax)
80107811:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107814:	89 50 08             	mov    %edx,0x8(%eax)
80107817:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010781a:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010781d:	e8 86 af ff ff       	call   801027a8 <kalloc>
80107822:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107825:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107829:	75 07                	jne    80107832 <setupkvm+0x70>
    return 0;
8010782b:	b8 00 00 00 00       	mov    $0x0,%eax
80107830:	eb 78                	jmp    801078aa <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107832:	83 ec 04             	sub    $0x4,%esp
80107835:	68 00 10 00 00       	push   $0x1000
8010783a:	6a 00                	push   $0x0
8010783c:	ff 75 f0             	push   -0x10(%ebp)
8010783f:	e8 bb d5 ff ff       	call   80104dff <memset>
80107844:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107847:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
8010784e:	eb 4e                	jmp    8010789e <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107853:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107859:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010785c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785f:	8b 58 08             	mov    0x8(%eax),%ebx
80107862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107865:	8b 40 04             	mov    0x4(%eax),%eax
80107868:	29 c3                	sub    %eax,%ebx
8010786a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786d:	8b 00                	mov    (%eax),%eax
8010786f:	83 ec 0c             	sub    $0xc,%esp
80107872:	51                   	push   %ecx
80107873:	52                   	push   %edx
80107874:	53                   	push   %ebx
80107875:	50                   	push   %eax
80107876:	ff 75 f0             	push   -0x10(%ebp)
80107879:	e8 b4 fe ff ff       	call   80107732 <mappages>
8010787e:	83 c4 20             	add    $0x20,%esp
80107881:	85 c0                	test   %eax,%eax
80107883:	79 15                	jns    8010789a <setupkvm+0xd8>
      freevm(pgdir);
80107885:	83 ec 0c             	sub    $0xc,%esp
80107888:	ff 75 f0             	push   -0x10(%ebp)
8010788b:	e8 f5 04 00 00       	call   80107d85 <freevm>
80107890:	83 c4 10             	add    $0x10,%esp
      return 0;
80107893:	b8 00 00 00 00       	mov    $0x0,%eax
80107898:	eb 10                	jmp    801078aa <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010789a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010789e:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
801078a5:	72 a9                	jb     80107850 <setupkvm+0x8e>
    }
  return pgdir;
801078a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078ad:	c9                   	leave
801078ae:	c3                   	ret

801078af <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078af:	55                   	push   %ebp
801078b0:	89 e5                	mov    %esp,%ebp
801078b2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078b5:	e8 08 ff ff ff       	call   801077c2 <setupkvm>
801078ba:	a3 7c 74 19 80       	mov    %eax,0x8019747c
  switchkvm();
801078bf:	e8 03 00 00 00       	call   801078c7 <switchkvm>
}
801078c4:	90                   	nop
801078c5:	c9                   	leave
801078c6:	c3                   	ret

801078c7 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078c7:	55                   	push   %ebp
801078c8:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078ca:	a1 7c 74 19 80       	mov    0x8019747c,%eax
801078cf:	05 00 00 00 80       	add    $0x80000000,%eax
801078d4:	50                   	push   %eax
801078d5:	e8 60 fa ff ff       	call   8010733a <lcr3>
801078da:	83 c4 04             	add    $0x4,%esp
}
801078dd:	90                   	nop
801078de:	c9                   	leave
801078df:	c3                   	ret

801078e0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801078e0:	55                   	push   %ebp
801078e1:	89 e5                	mov    %esp,%ebp
801078e3:	56                   	push   %esi
801078e4:	53                   	push   %ebx
801078e5:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801078e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078ec:	75 0d                	jne    801078fb <switchuvm+0x1b>
    panic("switchuvm: no process");
801078ee:	83 ec 0c             	sub    $0xc,%esp
801078f1:	68 be aa 10 80       	push   $0x8010aabe
801078f6:	e8 ae 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801078fb:	8b 45 08             	mov    0x8(%ebp),%eax
801078fe:	8b 40 08             	mov    0x8(%eax),%eax
80107901:	85 c0                	test   %eax,%eax
80107903:	75 0d                	jne    80107912 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107905:	83 ec 0c             	sub    $0xc,%esp
80107908:	68 d4 aa 10 80       	push   $0x8010aad4
8010790d:	e8 97 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107912:	8b 45 08             	mov    0x8(%ebp),%eax
80107915:	8b 40 04             	mov    0x4(%eax),%eax
80107918:	85 c0                	test   %eax,%eax
8010791a:	75 0d                	jne    80107929 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010791c:	83 ec 0c             	sub    $0xc,%esp
8010791f:	68 e9 aa 10 80       	push   $0x8010aae9
80107924:	e8 80 8c ff ff       	call   801005a9 <panic>

  pushcli();
80107929:	e8 c6 d3 ff ff       	call   80104cf4 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010792e:	e8 8c c0 ff ff       	call   801039bf <mycpu>
80107933:	89 c3                	mov    %eax,%ebx
80107935:	e8 85 c0 ff ff       	call   801039bf <mycpu>
8010793a:	83 c0 08             	add    $0x8,%eax
8010793d:	89 c6                	mov    %eax,%esi
8010793f:	e8 7b c0 ff ff       	call   801039bf <mycpu>
80107944:	83 c0 08             	add    $0x8,%eax
80107947:	c1 e8 10             	shr    $0x10,%eax
8010794a:	88 45 f7             	mov    %al,-0x9(%ebp)
8010794d:	e8 6d c0 ff ff       	call   801039bf <mycpu>
80107952:	83 c0 08             	add    $0x8,%eax
80107955:	c1 e8 18             	shr    $0x18,%eax
80107958:	89 c2                	mov    %eax,%edx
8010795a:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107961:	67 00 
80107963:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010796a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010796e:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107974:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010797b:	83 e0 f0             	and    $0xfffffff0,%eax
8010797e:	83 c8 09             	or     $0x9,%eax
80107981:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107987:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010798e:	83 c8 10             	or     $0x10,%eax
80107991:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107997:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010799e:	83 e0 9f             	and    $0xffffff9f,%eax
801079a1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079a7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079ae:	83 c8 80             	or     $0xffffff80,%eax
801079b1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079b7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079be:	83 e0 f0             	and    $0xfffffff0,%eax
801079c1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079c7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079ce:	83 e0 ef             	and    $0xffffffef,%eax
801079d1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079d7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079de:	83 e0 df             	and    $0xffffffdf,%eax
801079e1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079e7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079ee:	83 c8 40             	or     $0x40,%eax
801079f1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079f7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079fe:	83 e0 7f             	and    $0x7f,%eax
80107a01:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a07:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a0d:	e8 ad bf ff ff       	call   801039bf <mycpu>
80107a12:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a19:	83 e2 ef             	and    $0xffffffef,%edx
80107a1c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a22:	e8 98 bf ff ff       	call   801039bf <mycpu>
80107a27:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a30:	8b 40 08             	mov    0x8(%eax),%eax
80107a33:	89 c3                	mov    %eax,%ebx
80107a35:	e8 85 bf ff ff       	call   801039bf <mycpu>
80107a3a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a40:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a43:	e8 77 bf ff ff       	call   801039bf <mycpu>
80107a48:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a4e:	83 ec 0c             	sub    $0xc,%esp
80107a51:	6a 28                	push   $0x28
80107a53:	e8 cb f8 ff ff       	call   80107323 <ltr>
80107a58:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a5e:	8b 40 04             	mov    0x4(%eax),%eax
80107a61:	05 00 00 00 80       	add    $0x80000000,%eax
80107a66:	83 ec 0c             	sub    $0xc,%esp
80107a69:	50                   	push   %eax
80107a6a:	e8 cb f8 ff ff       	call   8010733a <lcr3>
80107a6f:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a72:	e8 ca d2 ff ff       	call   80104d41 <popcli>
}
80107a77:	90                   	nop
80107a78:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a7b:	5b                   	pop    %ebx
80107a7c:	5e                   	pop    %esi
80107a7d:	5d                   	pop    %ebp
80107a7e:	c3                   	ret

80107a7f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107a7f:	55                   	push   %ebp
80107a80:	89 e5                	mov    %esp,%ebp
80107a82:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107a85:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107a8c:	76 0d                	jbe    80107a9b <inituvm+0x1c>
    panic("inituvm: more than a page");
80107a8e:	83 ec 0c             	sub    $0xc,%esp
80107a91:	68 fd aa 10 80       	push   $0x8010aafd
80107a96:	e8 0e 8b ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107a9b:	e8 08 ad ff ff       	call   801027a8 <kalloc>
80107aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107aa3:	83 ec 04             	sub    $0x4,%esp
80107aa6:	68 00 10 00 00       	push   $0x1000
80107aab:	6a 00                	push   $0x0
80107aad:	ff 75 f4             	push   -0xc(%ebp)
80107ab0:	e8 4a d3 ff ff       	call   80104dff <memset>
80107ab5:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abb:	05 00 00 00 80       	add    $0x80000000,%eax
80107ac0:	83 ec 0c             	sub    $0xc,%esp
80107ac3:	6a 06                	push   $0x6
80107ac5:	50                   	push   %eax
80107ac6:	68 00 10 00 00       	push   $0x1000
80107acb:	6a 00                	push   $0x0
80107acd:	ff 75 08             	push   0x8(%ebp)
80107ad0:	e8 5d fc ff ff       	call   80107732 <mappages>
80107ad5:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107ad8:	83 ec 04             	sub    $0x4,%esp
80107adb:	ff 75 10             	push   0x10(%ebp)
80107ade:	ff 75 0c             	push   0xc(%ebp)
80107ae1:	ff 75 f4             	push   -0xc(%ebp)
80107ae4:	e8 d5 d3 ff ff       	call   80104ebe <memmove>
80107ae9:	83 c4 10             	add    $0x10,%esp
}
80107aec:	90                   	nop
80107aed:	c9                   	leave
80107aee:	c3                   	ret

80107aef <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107aef:	55                   	push   %ebp
80107af0:	89 e5                	mov    %esp,%ebp
80107af2:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107af5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107af8:	25 ff 0f 00 00       	and    $0xfff,%eax
80107afd:	85 c0                	test   %eax,%eax
80107aff:	74 0d                	je     80107b0e <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107b01:	83 ec 0c             	sub    $0xc,%esp
80107b04:	68 18 ab 10 80       	push   $0x8010ab18
80107b09:	e8 9b 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b15:	e9 8f 00 00 00       	jmp    80107ba9 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b20:	01 d0                	add    %edx,%eax
80107b22:	83 ec 04             	sub    $0x4,%esp
80107b25:	6a 00                	push   $0x0
80107b27:	50                   	push   %eax
80107b28:	ff 75 08             	push   0x8(%ebp)
80107b2b:	e8 6c fb ff ff       	call   8010769c <walkpgdir>
80107b30:	83 c4 10             	add    $0x10,%esp
80107b33:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b36:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b3a:	75 0d                	jne    80107b49 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107b3c:	83 ec 0c             	sub    $0xc,%esp
80107b3f:	68 3b ab 10 80       	push   $0x8010ab3b
80107b44:	e8 60 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107b49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b4c:	8b 00                	mov    (%eax),%eax
80107b4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b53:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b56:	8b 45 18             	mov    0x18(%ebp),%eax
80107b59:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b5c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b61:	77 0b                	ja     80107b6e <loaduvm+0x7f>
      n = sz - i;
80107b63:	8b 45 18             	mov    0x18(%ebp),%eax
80107b66:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b6c:	eb 07                	jmp    80107b75 <loaduvm+0x86>
    else
      n = PGSIZE;
80107b6e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b75:	8b 55 14             	mov    0x14(%ebp),%edx
80107b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7b:	01 d0                	add    %edx,%eax
80107b7d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107b80:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107b86:	ff 75 f0             	push   -0x10(%ebp)
80107b89:	50                   	push   %eax
80107b8a:	52                   	push   %edx
80107b8b:	ff 75 10             	push   0x10(%ebp)
80107b8e:	e8 4b a3 ff ff       	call   80101ede <readi>
80107b93:	83 c4 10             	add    $0x10,%esp
80107b96:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107b99:	74 07                	je     80107ba2 <loaduvm+0xb3>
      return -1;
80107b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ba0:	eb 18                	jmp    80107bba <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107ba2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bac:	3b 45 18             	cmp    0x18(%ebp),%eax
80107baf:	0f 82 65 ff ff ff    	jb     80107b1a <loaduvm+0x2b>
  }
  return 0;
80107bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bba:	c9                   	leave
80107bbb:	c3                   	ret

80107bbc <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107bbc:	55                   	push   %ebp
80107bbd:	89 e5                	mov    %esp,%ebp
80107bbf:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107bc2:	8b 45 10             	mov    0x10(%ebp),%eax
80107bc5:	85 c0                	test   %eax,%eax
80107bc7:	79 0a                	jns    80107bd3 <allocuvm+0x17>
    return 0;
80107bc9:	b8 00 00 00 00       	mov    $0x0,%eax
80107bce:	e9 ec 00 00 00       	jmp    80107cbf <allocuvm+0x103>
  if(newsz < oldsz)
80107bd3:	8b 45 10             	mov    0x10(%ebp),%eax
80107bd6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bd9:	73 08                	jae    80107be3 <allocuvm+0x27>
    return oldsz;
80107bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bde:	e9 dc 00 00 00       	jmp    80107cbf <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107be3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be6:	05 ff 0f 00 00       	add    $0xfff,%eax
80107beb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107bf3:	e9 b8 00 00 00       	jmp    80107cb0 <allocuvm+0xf4>
    mem = kalloc();
80107bf8:	e8 ab ab ff ff       	call   801027a8 <kalloc>
80107bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c04:	75 2e                	jne    80107c34 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107c06:	83 ec 0c             	sub    $0xc,%esp
80107c09:	68 59 ab 10 80       	push   $0x8010ab59
80107c0e:	e8 e1 87 ff ff       	call   801003f4 <cprintf>
80107c13:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c16:	83 ec 04             	sub    $0x4,%esp
80107c19:	ff 75 0c             	push   0xc(%ebp)
80107c1c:	ff 75 10             	push   0x10(%ebp)
80107c1f:	ff 75 08             	push   0x8(%ebp)
80107c22:	e8 9a 00 00 00       	call   80107cc1 <deallocuvm>
80107c27:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c2a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c2f:	e9 8b 00 00 00       	jmp    80107cbf <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107c34:	83 ec 04             	sub    $0x4,%esp
80107c37:	68 00 10 00 00       	push   $0x1000
80107c3c:	6a 00                	push   $0x0
80107c3e:	ff 75 f0             	push   -0x10(%ebp)
80107c41:	e8 b9 d1 ff ff       	call   80104dff <memset>
80107c46:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c4c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c55:	83 ec 0c             	sub    $0xc,%esp
80107c58:	6a 06                	push   $0x6
80107c5a:	52                   	push   %edx
80107c5b:	68 00 10 00 00       	push   $0x1000
80107c60:	50                   	push   %eax
80107c61:	ff 75 08             	push   0x8(%ebp)
80107c64:	e8 c9 fa ff ff       	call   80107732 <mappages>
80107c69:	83 c4 20             	add    $0x20,%esp
80107c6c:	85 c0                	test   %eax,%eax
80107c6e:	79 39                	jns    80107ca9 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107c70:	83 ec 0c             	sub    $0xc,%esp
80107c73:	68 71 ab 10 80       	push   $0x8010ab71
80107c78:	e8 77 87 ff ff       	call   801003f4 <cprintf>
80107c7d:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c80:	83 ec 04             	sub    $0x4,%esp
80107c83:	ff 75 0c             	push   0xc(%ebp)
80107c86:	ff 75 10             	push   0x10(%ebp)
80107c89:	ff 75 08             	push   0x8(%ebp)
80107c8c:	e8 30 00 00 00       	call   80107cc1 <deallocuvm>
80107c91:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107c94:	83 ec 0c             	sub    $0xc,%esp
80107c97:	ff 75 f0             	push   -0x10(%ebp)
80107c9a:	e8 6f aa ff ff       	call   8010270e <kfree>
80107c9f:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ca2:	b8 00 00 00 00       	mov    $0x0,%eax
80107ca7:	eb 16                	jmp    80107cbf <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107ca9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb3:	3b 45 10             	cmp    0x10(%ebp),%eax
80107cb6:	0f 82 3c ff ff ff    	jb     80107bf8 <allocuvm+0x3c>
    }
  }
  return newsz;
80107cbc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107cbf:	c9                   	leave
80107cc0:	c3                   	ret

80107cc1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107cc1:	55                   	push   %ebp
80107cc2:	89 e5                	mov    %esp,%ebp
80107cc4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cc7:	8b 45 10             	mov    0x10(%ebp),%eax
80107cca:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ccd:	72 08                	jb     80107cd7 <deallocuvm+0x16>
    return oldsz;
80107ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cd2:	e9 ac 00 00 00       	jmp    80107d83 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107cd7:	8b 45 10             	mov    0x10(%ebp),%eax
80107cda:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107ce7:	e9 88 00 00 00       	jmp    80107d74 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	83 ec 04             	sub    $0x4,%esp
80107cf2:	6a 00                	push   $0x0
80107cf4:	50                   	push   %eax
80107cf5:	ff 75 08             	push   0x8(%ebp)
80107cf8:	e8 9f f9 ff ff       	call   8010769c <walkpgdir>
80107cfd:	83 c4 10             	add    $0x10,%esp
80107d00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d07:	75 16                	jne    80107d1f <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0c:	c1 e8 16             	shr    $0x16,%eax
80107d0f:	83 c0 01             	add    $0x1,%eax
80107d12:	c1 e0 16             	shl    $0x16,%eax
80107d15:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d1d:	eb 4e                	jmp    80107d6d <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d22:	8b 00                	mov    (%eax),%eax
80107d24:	83 e0 01             	and    $0x1,%eax
80107d27:	85 c0                	test   %eax,%eax
80107d29:	74 42                	je     80107d6d <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107d2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d2e:	8b 00                	mov    (%eax),%eax
80107d30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d35:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d3c:	75 0d                	jne    80107d4b <deallocuvm+0x8a>
        panic("kfree");
80107d3e:	83 ec 0c             	sub    $0xc,%esp
80107d41:	68 8d ab 10 80       	push   $0x8010ab8d
80107d46:	e8 5e 88 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107d4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d4e:	05 00 00 00 80       	add    $0x80000000,%eax
80107d53:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d56:	83 ec 0c             	sub    $0xc,%esp
80107d59:	ff 75 e8             	push   -0x18(%ebp)
80107d5c:	e8 ad a9 ff ff       	call   8010270e <kfree>
80107d61:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107d6d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d77:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d7a:	0f 82 6c ff ff ff    	jb     80107cec <deallocuvm+0x2b>
    }
  }
  return newsz;
80107d80:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d83:	c9                   	leave
80107d84:	c3                   	ret

80107d85 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107d85:	55                   	push   %ebp
80107d86:	89 e5                	mov    %esp,%ebp
80107d88:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107d8b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d8f:	75 0d                	jne    80107d9e <freevm+0x19>
    panic("freevm: no pgdir");
80107d91:	83 ec 0c             	sub    $0xc,%esp
80107d94:	68 93 ab 10 80       	push   $0x8010ab93
80107d99:	e8 0b 88 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107d9e:	83 ec 04             	sub    $0x4,%esp
80107da1:	6a 00                	push   $0x0
80107da3:	68 00 00 00 80       	push   $0x80000000
80107da8:	ff 75 08             	push   0x8(%ebp)
80107dab:	e8 11 ff ff ff       	call   80107cc1 <deallocuvm>
80107db0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107db3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107dba:	eb 48                	jmp    80107e04 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc9:	01 d0                	add    %edx,%eax
80107dcb:	8b 00                	mov    (%eax),%eax
80107dcd:	83 e0 01             	and    $0x1,%eax
80107dd0:	85 c0                	test   %eax,%eax
80107dd2:	74 2c                	je     80107e00 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dde:	8b 45 08             	mov    0x8(%ebp),%eax
80107de1:	01 d0                	add    %edx,%eax
80107de3:	8b 00                	mov    (%eax),%eax
80107de5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107dea:	05 00 00 00 80       	add    $0x80000000,%eax
80107def:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107df2:	83 ec 0c             	sub    $0xc,%esp
80107df5:	ff 75 f0             	push   -0x10(%ebp)
80107df8:	e8 11 a9 ff ff       	call   8010270e <kfree>
80107dfd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e00:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e04:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e0b:	76 af                	jbe    80107dbc <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107e0d:	83 ec 0c             	sub    $0xc,%esp
80107e10:	ff 75 08             	push   0x8(%ebp)
80107e13:	e8 f6 a8 ff ff       	call   8010270e <kfree>
80107e18:	83 c4 10             	add    $0x10,%esp
}
80107e1b:	90                   	nop
80107e1c:	c9                   	leave
80107e1d:	c3                   	ret

80107e1e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e1e:	55                   	push   %ebp
80107e1f:	89 e5                	mov    %esp,%ebp
80107e21:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e24:	83 ec 04             	sub    $0x4,%esp
80107e27:	6a 00                	push   $0x0
80107e29:	ff 75 0c             	push   0xc(%ebp)
80107e2c:	ff 75 08             	push   0x8(%ebp)
80107e2f:	e8 68 f8 ff ff       	call   8010769c <walkpgdir>
80107e34:	83 c4 10             	add    $0x10,%esp
80107e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e3e:	75 0d                	jne    80107e4d <clearpteu+0x2f>
    panic("clearpteu");
80107e40:	83 ec 0c             	sub    $0xc,%esp
80107e43:	68 a4 ab 10 80       	push   $0x8010aba4
80107e48:	e8 5c 87 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e50:	8b 00                	mov    (%eax),%eax
80107e52:	83 e0 fb             	and    $0xfffffffb,%eax
80107e55:	89 c2                	mov    %eax,%edx
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	89 10                	mov    %edx,(%eax)
}
80107e5c:	90                   	nop
80107e5d:	c9                   	leave
80107e5e:	c3                   	ret

80107e5f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e5f:	55                   	push   %ebp
80107e60:	89 e5                	mov    %esp,%ebp
80107e62:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107e65:	e8 58 f9 ff ff       	call   801077c2 <setupkvm>
80107e6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e71:	75 0a                	jne    80107e7d <copyuvm+0x1e>
    return 0;
80107e73:	b8 00 00 00 00       	mov    $0x0,%eax
80107e78:	e9 eb 00 00 00       	jmp    80107f68 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107e7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e84:	e9 b7 00 00 00       	jmp    80107f40 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8c:	83 ec 04             	sub    $0x4,%esp
80107e8f:	6a 00                	push   $0x0
80107e91:	50                   	push   %eax
80107e92:	ff 75 08             	push   0x8(%ebp)
80107e95:	e8 02 f8 ff ff       	call   8010769c <walkpgdir>
80107e9a:	83 c4 10             	add    $0x10,%esp
80107e9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ea0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ea4:	75 0d                	jne    80107eb3 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107ea6:	83 ec 0c             	sub    $0xc,%esp
80107ea9:	68 ae ab 10 80       	push   $0x8010abae
80107eae:	e8 f6 86 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb6:	8b 00                	mov    (%eax),%eax
80107eb8:	83 e0 01             	and    $0x1,%eax
80107ebb:	85 c0                	test   %eax,%eax
80107ebd:	75 0d                	jne    80107ecc <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107ebf:	83 ec 0c             	sub    $0xc,%esp
80107ec2:	68 c8 ab 10 80       	push   $0x8010abc8
80107ec7:	e8 dd 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ecf:	8b 00                	mov    (%eax),%eax
80107ed1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ed6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107edc:	8b 00                	mov    (%eax),%eax
80107ede:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ee3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ee6:	e8 bd a8 ff ff       	call   801027a8 <kalloc>
80107eeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107eee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107ef2:	74 5d                	je     80107f51 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107ef4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ef7:	05 00 00 00 80       	add    $0x80000000,%eax
80107efc:	83 ec 04             	sub    $0x4,%esp
80107eff:	68 00 10 00 00       	push   $0x1000
80107f04:	50                   	push   %eax
80107f05:	ff 75 e0             	push   -0x20(%ebp)
80107f08:	e8 b1 cf ff ff       	call   80104ebe <memmove>
80107f0d:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f16:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	83 ec 0c             	sub    $0xc,%esp
80107f22:	52                   	push   %edx
80107f23:	51                   	push   %ecx
80107f24:	68 00 10 00 00       	push   $0x1000
80107f29:	50                   	push   %eax
80107f2a:	ff 75 f0             	push   -0x10(%ebp)
80107f2d:	e8 00 f8 ff ff       	call   80107732 <mappages>
80107f32:	83 c4 20             	add    $0x20,%esp
80107f35:	85 c0                	test   %eax,%eax
80107f37:	78 1b                	js     80107f54 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107f39:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f43:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f46:	0f 82 3d ff ff ff    	jb     80107e89 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f4f:	eb 17                	jmp    80107f68 <copyuvm+0x109>
      goto bad;
80107f51:	90                   	nop
80107f52:	eb 01                	jmp    80107f55 <copyuvm+0xf6>
      goto bad;
80107f54:	90                   	nop

bad:
  freevm(d);
80107f55:	83 ec 0c             	sub    $0xc,%esp
80107f58:	ff 75 f0             	push   -0x10(%ebp)
80107f5b:	e8 25 fe ff ff       	call   80107d85 <freevm>
80107f60:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f68:	c9                   	leave
80107f69:	c3                   	ret

80107f6a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f6a:	55                   	push   %ebp
80107f6b:	89 e5                	mov    %esp,%ebp
80107f6d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f70:	83 ec 04             	sub    $0x4,%esp
80107f73:	6a 00                	push   $0x0
80107f75:	ff 75 0c             	push   0xc(%ebp)
80107f78:	ff 75 08             	push   0x8(%ebp)
80107f7b:	e8 1c f7 ff ff       	call   8010769c <walkpgdir>
80107f80:	83 c4 10             	add    $0x10,%esp
80107f83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f89:	8b 00                	mov    (%eax),%eax
80107f8b:	83 e0 01             	and    $0x1,%eax
80107f8e:	85 c0                	test   %eax,%eax
80107f90:	75 07                	jne    80107f99 <uva2ka+0x2f>
    return 0;
80107f92:	b8 00 00 00 00       	mov    $0x0,%eax
80107f97:	eb 22                	jmp    80107fbb <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9c:	8b 00                	mov    (%eax),%eax
80107f9e:	83 e0 04             	and    $0x4,%eax
80107fa1:	85 c0                	test   %eax,%eax
80107fa3:	75 07                	jne    80107fac <uva2ka+0x42>
    return 0;
80107fa5:	b8 00 00 00 00       	mov    $0x0,%eax
80107faa:	eb 0f                	jmp    80107fbb <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	8b 00                	mov    (%eax),%eax
80107fb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fb6:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107fbb:	c9                   	leave
80107fbc:	c3                   	ret

80107fbd <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107fbd:	55                   	push   %ebp
80107fbe:	89 e5                	mov    %esp,%ebp
80107fc0:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80107fc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107fc9:	eb 7f                	jmp    8010804a <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fd9:	83 ec 08             	sub    $0x8,%esp
80107fdc:	50                   	push   %eax
80107fdd:	ff 75 08             	push   0x8(%ebp)
80107fe0:	e8 85 ff ff ff       	call   80107f6a <uva2ka>
80107fe5:	83 c4 10             	add    $0x10,%esp
80107fe8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107feb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107fef:	75 07                	jne    80107ff8 <copyout+0x3b>
      return -1;
80107ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ff6:	eb 61                	jmp    80108059 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107ff8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ffb:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ffe:	05 00 10 00 00       	add    $0x1000,%eax
80108003:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108009:	39 45 14             	cmp    %eax,0x14(%ebp)
8010800c:	73 06                	jae    80108014 <copyout+0x57>
      n = len;
8010800e:	8b 45 14             	mov    0x14(%ebp),%eax
80108011:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108014:	8b 45 0c             	mov    0xc(%ebp),%eax
80108017:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010801a:	89 c2                	mov    %eax,%edx
8010801c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010801f:	01 d0                	add    %edx,%eax
80108021:	83 ec 04             	sub    $0x4,%esp
80108024:	ff 75 f0             	push   -0x10(%ebp)
80108027:	ff 75 f4             	push   -0xc(%ebp)
8010802a:	50                   	push   %eax
8010802b:	e8 8e ce ff ff       	call   80104ebe <memmove>
80108030:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108036:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108039:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010803c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010803f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108042:	05 00 10 00 00       	add    $0x1000,%eax
80108047:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010804a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010804e:	0f 85 77 ff ff ff    	jne    80107fcb <copyout+0xe>
  }
  return 0;
80108054:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108059:	c9                   	leave
8010805a:	c3                   	ret

8010805b <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010805b:	55                   	push   %ebp
8010805c:	89 e5                	mov    %esp,%ebp
8010805e:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108061:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108068:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010806b:	8b 40 08             	mov    0x8(%eax),%eax
8010806e:	05 00 00 00 80       	add    $0x80000000,%eax
80108073:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108076:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010807d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108080:	8b 40 24             	mov    0x24(%eax),%eax
80108083:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80108088:	c7 05 50 77 19 80 00 	movl   $0x0,0x80197750
8010808f:	00 00 00 

  while(i<madt->len){
80108092:	e9 bd 00 00 00       	jmp    80108154 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
80108097:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010809a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010809d:	01 d0                	add    %edx,%eax
8010809f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801080a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080a5:	0f b6 00             	movzbl (%eax),%eax
801080a8:	0f b6 c0             	movzbl %al,%eax
801080ab:	83 f8 05             	cmp    $0x5,%eax
801080ae:	0f 87 a0 00 00 00    	ja     80108154 <mpinit_uefi+0xf9>
801080b4:	8b 04 85 e4 ab 10 80 	mov    -0x7fef541c(,%eax,4),%eax
801080bb:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801080bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801080c3:	a1 50 77 19 80       	mov    0x80197750,%eax
801080c8:	83 f8 03             	cmp    $0x3,%eax
801080cb:	7f 28                	jg     801080f5 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801080cd:	8b 15 50 77 19 80    	mov    0x80197750,%edx
801080d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080d6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801080da:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801080e0:	81 c2 80 74 19 80    	add    $0x80197480,%edx
801080e6:	88 02                	mov    %al,(%edx)
          ncpu++;
801080e8:	a1 50 77 19 80       	mov    0x80197750,%eax
801080ed:	83 c0 01             	add    $0x1,%eax
801080f0:	a3 50 77 19 80       	mov    %eax,0x80197750
        }
        i += lapic_entry->record_len;
801080f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080f8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080fc:	0f b6 c0             	movzbl %al,%eax
801080ff:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108102:	eb 50                	jmp    80108154 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108104:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108107:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010810a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010810d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108111:	a2 54 77 19 80       	mov    %al,0x80197754
        i += ioapic->record_len;
80108116:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108119:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010811d:	0f b6 c0             	movzbl %al,%eax
80108120:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108123:	eb 2f                	jmp    80108154 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108128:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010812b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010812e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108132:	0f b6 c0             	movzbl %al,%eax
80108135:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108138:	eb 1a                	jmp    80108154 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010813a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108140:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108143:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108147:	0f b6 c0             	movzbl %al,%eax
8010814a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010814d:	eb 05                	jmp    80108154 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
8010814f:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108153:	90                   	nop
  while(i<madt->len){
80108154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108157:	8b 40 04             	mov    0x4(%eax),%eax
8010815a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010815d:	0f 82 34 ff ff ff    	jb     80108097 <mpinit_uefi+0x3c>
    }
  }

}
80108163:	90                   	nop
80108164:	90                   	nop
80108165:	c9                   	leave
80108166:	c3                   	ret

80108167 <inb>:
{
80108167:	55                   	push   %ebp
80108168:	89 e5                	mov    %esp,%ebp
8010816a:	83 ec 14             	sub    $0x14,%esp
8010816d:	8b 45 08             	mov    0x8(%ebp),%eax
80108170:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108174:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108178:	89 c2                	mov    %eax,%edx
8010817a:	ec                   	in     (%dx),%al
8010817b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010817e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108182:	c9                   	leave
80108183:	c3                   	ret

80108184 <outb>:
{
80108184:	55                   	push   %ebp
80108185:	89 e5                	mov    %esp,%ebp
80108187:	83 ec 08             	sub    $0x8,%esp
8010818a:	8b 55 08             	mov    0x8(%ebp),%edx
8010818d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108190:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108194:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108197:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010819b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010819f:	ee                   	out    %al,(%dx)
}
801081a0:	90                   	nop
801081a1:	c9                   	leave
801081a2:	c3                   	ret

801081a3 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801081a3:	55                   	push   %ebp
801081a4:	89 e5                	mov    %esp,%ebp
801081a6:	83 ec 28             	sub    $0x28,%esp
801081a9:	8b 45 08             	mov    0x8(%ebp),%eax
801081ac:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801081af:	6a 00                	push   $0x0
801081b1:	68 fa 03 00 00       	push   $0x3fa
801081b6:	e8 c9 ff ff ff       	call   80108184 <outb>
801081bb:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801081be:	68 80 00 00 00       	push   $0x80
801081c3:	68 fb 03 00 00       	push   $0x3fb
801081c8:	e8 b7 ff ff ff       	call   80108184 <outb>
801081cd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801081d0:	6a 0c                	push   $0xc
801081d2:	68 f8 03 00 00       	push   $0x3f8
801081d7:	e8 a8 ff ff ff       	call   80108184 <outb>
801081dc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801081df:	6a 00                	push   $0x0
801081e1:	68 f9 03 00 00       	push   $0x3f9
801081e6:	e8 99 ff ff ff       	call   80108184 <outb>
801081eb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801081ee:	6a 03                	push   $0x3
801081f0:	68 fb 03 00 00       	push   $0x3fb
801081f5:	e8 8a ff ff ff       	call   80108184 <outb>
801081fa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801081fd:	6a 00                	push   $0x0
801081ff:	68 fc 03 00 00       	push   $0x3fc
80108204:	e8 7b ff ff ff       	call   80108184 <outb>
80108209:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010820c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108213:	eb 11                	jmp    80108226 <uart_debug+0x83>
80108215:	83 ec 0c             	sub    $0xc,%esp
80108218:	6a 0a                	push   $0xa
8010821a:	e8 1a a9 ff ff       	call   80102b39 <microdelay>
8010821f:	83 c4 10             	add    $0x10,%esp
80108222:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108226:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010822a:	7f 1a                	jg     80108246 <uart_debug+0xa3>
8010822c:	83 ec 0c             	sub    $0xc,%esp
8010822f:	68 fd 03 00 00       	push   $0x3fd
80108234:	e8 2e ff ff ff       	call   80108167 <inb>
80108239:	83 c4 10             	add    $0x10,%esp
8010823c:	0f b6 c0             	movzbl %al,%eax
8010823f:	83 e0 20             	and    $0x20,%eax
80108242:	85 c0                	test   %eax,%eax
80108244:	74 cf                	je     80108215 <uart_debug+0x72>
  outb(COM1+0, p);
80108246:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010824a:	0f b6 c0             	movzbl %al,%eax
8010824d:	83 ec 08             	sub    $0x8,%esp
80108250:	50                   	push   %eax
80108251:	68 f8 03 00 00       	push   $0x3f8
80108256:	e8 29 ff ff ff       	call   80108184 <outb>
8010825b:	83 c4 10             	add    $0x10,%esp
}
8010825e:	90                   	nop
8010825f:	c9                   	leave
80108260:	c3                   	ret

80108261 <uart_debugs>:

void uart_debugs(char *p){
80108261:	55                   	push   %ebp
80108262:	89 e5                	mov    %esp,%ebp
80108264:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108267:	eb 1b                	jmp    80108284 <uart_debugs+0x23>
    uart_debug(*p++);
80108269:	8b 45 08             	mov    0x8(%ebp),%eax
8010826c:	8d 50 01             	lea    0x1(%eax),%edx
8010826f:	89 55 08             	mov    %edx,0x8(%ebp)
80108272:	0f b6 00             	movzbl (%eax),%eax
80108275:	0f be c0             	movsbl %al,%eax
80108278:	83 ec 0c             	sub    $0xc,%esp
8010827b:	50                   	push   %eax
8010827c:	e8 22 ff ff ff       	call   801081a3 <uart_debug>
80108281:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108284:	8b 45 08             	mov    0x8(%ebp),%eax
80108287:	0f b6 00             	movzbl (%eax),%eax
8010828a:	84 c0                	test   %al,%al
8010828c:	75 db                	jne    80108269 <uart_debugs+0x8>
  }
}
8010828e:	90                   	nop
8010828f:	90                   	nop
80108290:	c9                   	leave
80108291:	c3                   	ret

80108292 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108292:	55                   	push   %ebp
80108293:	89 e5                	mov    %esp,%ebp
80108295:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108298:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010829f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082a2:	8b 50 14             	mov    0x14(%eax),%edx
801082a5:	8b 40 10             	mov    0x10(%eax),%eax
801082a8:	a3 58 77 19 80       	mov    %eax,0x80197758
  gpu.vram_size = boot_param->graphic_config.frame_size;
801082ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082b0:	8b 50 1c             	mov    0x1c(%eax),%edx
801082b3:	8b 40 18             	mov    0x18(%eax),%eax
801082b6:	a3 60 77 19 80       	mov    %eax,0x80197760
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801082bb:	a1 60 77 19 80       	mov    0x80197760,%eax
801082c0:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801082c5:	29 c2                	sub    %eax,%edx
801082c7:	89 15 5c 77 19 80    	mov    %edx,0x8019775c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801082cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082d0:	8b 50 24             	mov    0x24(%eax),%edx
801082d3:	8b 40 20             	mov    0x20(%eax),%eax
801082d6:	a3 64 77 19 80       	mov    %eax,0x80197764
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801082db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082de:	8b 50 2c             	mov    0x2c(%eax),%edx
801082e1:	8b 40 28             	mov    0x28(%eax),%eax
801082e4:	a3 68 77 19 80       	mov    %eax,0x80197768
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801082e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082ec:	8b 50 34             	mov    0x34(%eax),%edx
801082ef:	8b 40 30             	mov    0x30(%eax),%eax
801082f2:	a3 6c 77 19 80       	mov    %eax,0x8019776c
}
801082f7:	90                   	nop
801082f8:	c9                   	leave
801082f9:	c3                   	ret

801082fa <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801082fa:	55                   	push   %ebp
801082fb:	89 e5                	mov    %esp,%ebp
801082fd:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108300:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
80108306:	8b 45 0c             	mov    0xc(%ebp),%eax
80108309:	0f af d0             	imul   %eax,%edx
8010830c:	8b 45 08             	mov    0x8(%ebp),%eax
8010830f:	01 d0                	add    %edx,%eax
80108311:	c1 e0 02             	shl    $0x2,%eax
80108314:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108317:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
8010831d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108320:	01 d0                	add    %edx,%eax
80108322:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108325:	8b 45 10             	mov    0x10(%ebp),%eax
80108328:	0f b6 10             	movzbl (%eax),%edx
8010832b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010832e:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108330:	8b 45 10             	mov    0x10(%ebp),%eax
80108333:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108337:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010833a:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010833d:	8b 45 10             	mov    0x10(%ebp),%eax
80108340:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108344:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108347:	88 50 02             	mov    %dl,0x2(%eax)
}
8010834a:	90                   	nop
8010834b:	c9                   	leave
8010834c:	c3                   	ret

8010834d <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010834d:	55                   	push   %ebp
8010834e:	89 e5                	mov    %esp,%ebp
80108350:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108353:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
80108359:	8b 45 08             	mov    0x8(%ebp),%eax
8010835c:	0f af c2             	imul   %edx,%eax
8010835f:	c1 e0 02             	shl    $0x2,%eax
80108362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108365:	8b 15 60 77 19 80    	mov    0x80197760,%edx
8010836b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836e:	29 c2                	sub    %eax,%edx
80108370:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
80108376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108379:	01 c8                	add    %ecx,%eax
8010837b:	89 c1                	mov    %eax,%ecx
8010837d:	a1 5c 77 19 80       	mov    0x8019775c,%eax
80108382:	83 ec 04             	sub    $0x4,%esp
80108385:	52                   	push   %edx
80108386:	51                   	push   %ecx
80108387:	50                   	push   %eax
80108388:	e8 31 cb ff ff       	call   80104ebe <memmove>
8010838d:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108393:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
80108399:	8b 15 60 77 19 80    	mov    0x80197760,%edx
8010839f:	01 d1                	add    %edx,%ecx
801083a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083a4:	29 d1                	sub    %edx,%ecx
801083a6:	89 ca                	mov    %ecx,%edx
801083a8:	83 ec 04             	sub    $0x4,%esp
801083ab:	50                   	push   %eax
801083ac:	6a 00                	push   $0x0
801083ae:	52                   	push   %edx
801083af:	e8 4b ca ff ff       	call   80104dff <memset>
801083b4:	83 c4 10             	add    $0x10,%esp
}
801083b7:	90                   	nop
801083b8:	c9                   	leave
801083b9:	c3                   	ret

801083ba <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801083ba:	55                   	push   %ebp
801083bb:	89 e5                	mov    %esp,%ebp
801083bd:	53                   	push   %ebx
801083be:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801083c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083c8:	e9 b1 00 00 00       	jmp    8010847e <font_render+0xc4>
    for(int j=14;j>-1;j--){
801083cd:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801083d4:	e9 97 00 00 00       	jmp    80108470 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801083d9:	8b 45 10             	mov    0x10(%ebp),%eax
801083dc:	83 e8 20             	sub    $0x20,%eax
801083df:	6b d0 1e             	imul   $0x1e,%eax,%edx
801083e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e5:	01 d0                	add    %edx,%eax
801083e7:	0f b7 84 00 00 ac 10 	movzwl -0x7fef5400(%eax,%eax,1),%eax
801083ee:	80 
801083ef:	0f b7 d0             	movzwl %ax,%edx
801083f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f5:	bb 01 00 00 00       	mov    $0x1,%ebx
801083fa:	89 c1                	mov    %eax,%ecx
801083fc:	d3 e3                	shl    %cl,%ebx
801083fe:	89 d8                	mov    %ebx,%eax
80108400:	21 d0                	and    %edx,%eax
80108402:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108408:	ba 01 00 00 00       	mov    $0x1,%edx
8010840d:	89 c1                	mov    %eax,%ecx
8010840f:	d3 e2                	shl    %cl,%edx
80108411:	89 d0                	mov    %edx,%eax
80108413:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108416:	75 2b                	jne    80108443 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108418:	8b 55 0c             	mov    0xc(%ebp),%edx
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	01 c2                	add    %eax,%edx
80108420:	b8 0e 00 00 00       	mov    $0xe,%eax
80108425:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108428:	89 c1                	mov    %eax,%ecx
8010842a:	8b 45 08             	mov    0x8(%ebp),%eax
8010842d:	01 c8                	add    %ecx,%eax
8010842f:	83 ec 04             	sub    $0x4,%esp
80108432:	68 00 f5 10 80       	push   $0x8010f500
80108437:	52                   	push   %edx
80108438:	50                   	push   %eax
80108439:	e8 bc fe ff ff       	call   801082fa <graphic_draw_pixel>
8010843e:	83 c4 10             	add    $0x10,%esp
80108441:	eb 29                	jmp    8010846c <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108443:	8b 55 0c             	mov    0xc(%ebp),%edx
80108446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108449:	01 c2                	add    %eax,%edx
8010844b:	b8 0e 00 00 00       	mov    $0xe,%eax
80108450:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108453:	89 c1                	mov    %eax,%ecx
80108455:	8b 45 08             	mov    0x8(%ebp),%eax
80108458:	01 c8                	add    %ecx,%eax
8010845a:	83 ec 04             	sub    $0x4,%esp
8010845d:	68 70 77 19 80       	push   $0x80197770
80108462:	52                   	push   %edx
80108463:	50                   	push   %eax
80108464:	e8 91 fe ff ff       	call   801082fa <graphic_draw_pixel>
80108469:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010846c:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108470:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108474:	0f 89 5f ff ff ff    	jns    801083d9 <font_render+0x1f>
  for(int i=0;i<30;i++){
8010847a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010847e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108482:	0f 8e 45 ff ff ff    	jle    801083cd <font_render+0x13>
      }
    }
  }
}
80108488:	90                   	nop
80108489:	90                   	nop
8010848a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010848d:	c9                   	leave
8010848e:	c3                   	ret

8010848f <font_render_string>:

void font_render_string(char *string,int row){
8010848f:	55                   	push   %ebp
80108490:	89 e5                	mov    %esp,%ebp
80108492:	53                   	push   %ebx
80108493:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108496:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010849d:	eb 33                	jmp    801084d2 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010849f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084a2:	8b 45 08             	mov    0x8(%ebp),%eax
801084a5:	01 d0                	add    %edx,%eax
801084a7:	0f b6 00             	movzbl (%eax),%eax
801084aa:	0f be d8             	movsbl %al,%ebx
801084ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801084b0:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801084b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084b6:	89 d0                	mov    %edx,%eax
801084b8:	c1 e0 04             	shl    $0x4,%eax
801084bb:	29 d0                	sub    %edx,%eax
801084bd:	83 c0 02             	add    $0x2,%eax
801084c0:	83 ec 04             	sub    $0x4,%esp
801084c3:	53                   	push   %ebx
801084c4:	51                   	push   %ecx
801084c5:	50                   	push   %eax
801084c6:	e8 ef fe ff ff       	call   801083ba <font_render>
801084cb:	83 c4 10             	add    $0x10,%esp
    i++;
801084ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801084d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084d5:	8b 45 08             	mov    0x8(%ebp),%eax
801084d8:	01 d0                	add    %edx,%eax
801084da:	0f b6 00             	movzbl (%eax),%eax
801084dd:	84 c0                	test   %al,%al
801084df:	74 06                	je     801084e7 <font_render_string+0x58>
801084e1:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801084e5:	7e b8                	jle    8010849f <font_render_string+0x10>
  }
}
801084e7:	90                   	nop
801084e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084eb:	c9                   	leave
801084ec:	c3                   	ret

801084ed <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801084ed:	55                   	push   %ebp
801084ee:	89 e5                	mov    %esp,%ebp
801084f0:	53                   	push   %ebx
801084f1:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801084f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084fb:	eb 6b                	jmp    80108568 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801084fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108504:	eb 58                	jmp    8010855e <pci_init+0x71>
      for(int k=0;k<8;k++){
80108506:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010850d:	eb 45                	jmp    80108554 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010850f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108512:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108518:	83 ec 0c             	sub    $0xc,%esp
8010851b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010851e:	53                   	push   %ebx
8010851f:	6a 00                	push   $0x0
80108521:	51                   	push   %ecx
80108522:	52                   	push   %edx
80108523:	50                   	push   %eax
80108524:	e8 b0 00 00 00       	call   801085d9 <pci_access_config>
80108529:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010852c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010852f:	0f b7 c0             	movzwl %ax,%eax
80108532:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108537:	74 17                	je     80108550 <pci_init+0x63>
        pci_init_device(i,j,k);
80108539:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010853c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010853f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108542:	83 ec 04             	sub    $0x4,%esp
80108545:	51                   	push   %ecx
80108546:	52                   	push   %edx
80108547:	50                   	push   %eax
80108548:	e8 37 01 00 00       	call   80108684 <pci_init_device>
8010854d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108550:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108554:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108558:	7e b5                	jle    8010850f <pci_init+0x22>
    for(int j=0;j<32;j++){
8010855a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010855e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108562:	7e a2                	jle    80108506 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108564:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108568:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010856f:	7e 8c                	jle    801084fd <pci_init+0x10>
      }
      }
    }
  }
}
80108571:	90                   	nop
80108572:	90                   	nop
80108573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108576:	c9                   	leave
80108577:	c3                   	ret

80108578 <pci_write_config>:

void pci_write_config(uint config){
80108578:	55                   	push   %ebp
80108579:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010857b:	8b 45 08             	mov    0x8(%ebp),%eax
8010857e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108583:	89 c0                	mov    %eax,%eax
80108585:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108586:	90                   	nop
80108587:	5d                   	pop    %ebp
80108588:	c3                   	ret

80108589 <pci_write_data>:

void pci_write_data(uint config){
80108589:	55                   	push   %ebp
8010858a:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010858c:	8b 45 08             	mov    0x8(%ebp),%eax
8010858f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108594:	89 c0                	mov    %eax,%eax
80108596:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108597:	90                   	nop
80108598:	5d                   	pop    %ebp
80108599:	c3                   	ret

8010859a <pci_read_config>:
uint pci_read_config(){
8010859a:	55                   	push   %ebp
8010859b:	89 e5                	mov    %esp,%ebp
8010859d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801085a0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085a5:	ed                   	in     (%dx),%eax
801085a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801085a9:	83 ec 0c             	sub    $0xc,%esp
801085ac:	68 c8 00 00 00       	push   $0xc8
801085b1:	e8 83 a5 ff ff       	call   80102b39 <microdelay>
801085b6:	83 c4 10             	add    $0x10,%esp
  return data;
801085b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801085bc:	c9                   	leave
801085bd:	c3                   	ret

801085be <pci_test>:


void pci_test(){
801085be:	55                   	push   %ebp
801085bf:	89 e5                	mov    %esp,%ebp
801085c1:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801085c4:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801085cb:	ff 75 fc             	push   -0x4(%ebp)
801085ce:	e8 a5 ff ff ff       	call   80108578 <pci_write_config>
801085d3:	83 c4 04             	add    $0x4,%esp
}
801085d6:	90                   	nop
801085d7:	c9                   	leave
801085d8:	c3                   	ret

801085d9 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801085d9:	55                   	push   %ebp
801085da:	89 e5                	mov    %esp,%ebp
801085dc:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801085df:	8b 45 08             	mov    0x8(%ebp),%eax
801085e2:	c1 e0 10             	shl    $0x10,%eax
801085e5:	25 00 00 ff 00       	and    $0xff0000,%eax
801085ea:	89 c2                	mov    %eax,%edx
801085ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801085ef:	c1 e0 0b             	shl    $0xb,%eax
801085f2:	0f b7 c0             	movzwl %ax,%eax
801085f5:	09 c2                	or     %eax,%edx
801085f7:	8b 45 10             	mov    0x10(%ebp),%eax
801085fa:	c1 e0 08             	shl    $0x8,%eax
801085fd:	25 00 07 00 00       	and    $0x700,%eax
80108602:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108604:	8b 45 14             	mov    0x14(%ebp),%eax
80108607:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010860c:	09 d0                	or     %edx,%eax
8010860e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108613:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108616:	ff 75 f4             	push   -0xc(%ebp)
80108619:	e8 5a ff ff ff       	call   80108578 <pci_write_config>
8010861e:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108621:	e8 74 ff ff ff       	call   8010859a <pci_read_config>
80108626:	8b 55 18             	mov    0x18(%ebp),%edx
80108629:	89 02                	mov    %eax,(%edx)
}
8010862b:	90                   	nop
8010862c:	c9                   	leave
8010862d:	c3                   	ret

8010862e <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010862e:	55                   	push   %ebp
8010862f:	89 e5                	mov    %esp,%ebp
80108631:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108634:	8b 45 08             	mov    0x8(%ebp),%eax
80108637:	c1 e0 10             	shl    $0x10,%eax
8010863a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010863f:	89 c2                	mov    %eax,%edx
80108641:	8b 45 0c             	mov    0xc(%ebp),%eax
80108644:	c1 e0 0b             	shl    $0xb,%eax
80108647:	0f b7 c0             	movzwl %ax,%eax
8010864a:	09 c2                	or     %eax,%edx
8010864c:	8b 45 10             	mov    0x10(%ebp),%eax
8010864f:	c1 e0 08             	shl    $0x8,%eax
80108652:	25 00 07 00 00       	and    $0x700,%eax
80108657:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108659:	8b 45 14             	mov    0x14(%ebp),%eax
8010865c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108661:	09 d0                	or     %edx,%eax
80108663:	0d 00 00 00 80       	or     $0x80000000,%eax
80108668:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010866b:	ff 75 fc             	push   -0x4(%ebp)
8010866e:	e8 05 ff ff ff       	call   80108578 <pci_write_config>
80108673:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108676:	ff 75 18             	push   0x18(%ebp)
80108679:	e8 0b ff ff ff       	call   80108589 <pci_write_data>
8010867e:	83 c4 04             	add    $0x4,%esp
}
80108681:	90                   	nop
80108682:	c9                   	leave
80108683:	c3                   	ret

80108684 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108684:	55                   	push   %ebp
80108685:	89 e5                	mov    %esp,%ebp
80108687:	53                   	push   %ebx
80108688:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010868b:	8b 45 08             	mov    0x8(%ebp),%eax
8010868e:	a2 74 77 19 80       	mov    %al,0x80197774
  dev.device_num = device_num;
80108693:	8b 45 0c             	mov    0xc(%ebp),%eax
80108696:	a2 75 77 19 80       	mov    %al,0x80197775
  dev.function_num = function_num;
8010869b:	8b 45 10             	mov    0x10(%ebp),%eax
8010869e:	a2 76 77 19 80       	mov    %al,0x80197776
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801086a3:	ff 75 10             	push   0x10(%ebp)
801086a6:	ff 75 0c             	push   0xc(%ebp)
801086a9:	ff 75 08             	push   0x8(%ebp)
801086ac:	68 44 c2 10 80       	push   $0x8010c244
801086b1:	e8 3e 7d ff ff       	call   801003f4 <cprintf>
801086b6:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801086b9:	83 ec 0c             	sub    $0xc,%esp
801086bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086bf:	50                   	push   %eax
801086c0:	6a 00                	push   $0x0
801086c2:	ff 75 10             	push   0x10(%ebp)
801086c5:	ff 75 0c             	push   0xc(%ebp)
801086c8:	ff 75 08             	push   0x8(%ebp)
801086cb:	e8 09 ff ff ff       	call   801085d9 <pci_access_config>
801086d0:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801086d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d6:	c1 e8 10             	shr    $0x10,%eax
801086d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801086dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086df:	25 ff ff 00 00       	and    $0xffff,%eax
801086e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801086e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ea:	a3 78 77 19 80       	mov    %eax,0x80197778
  dev.vendor_id = vendor_id;
801086ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f2:	a3 7c 77 19 80       	mov    %eax,0x8019777c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801086f7:	83 ec 04             	sub    $0x4,%esp
801086fa:	ff 75 f0             	push   -0x10(%ebp)
801086fd:	ff 75 f4             	push   -0xc(%ebp)
80108700:	68 78 c2 10 80       	push   $0x8010c278
80108705:	e8 ea 7c ff ff       	call   801003f4 <cprintf>
8010870a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010870d:	83 ec 0c             	sub    $0xc,%esp
80108710:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108713:	50                   	push   %eax
80108714:	6a 08                	push   $0x8
80108716:	ff 75 10             	push   0x10(%ebp)
80108719:	ff 75 0c             	push   0xc(%ebp)
8010871c:	ff 75 08             	push   0x8(%ebp)
8010871f:	e8 b5 fe ff ff       	call   801085d9 <pci_access_config>
80108724:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010872a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010872d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108730:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108733:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108736:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108739:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010873c:	0f b6 c0             	movzbl %al,%eax
8010873f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108742:	c1 eb 18             	shr    $0x18,%ebx
80108745:	83 ec 0c             	sub    $0xc,%esp
80108748:	51                   	push   %ecx
80108749:	52                   	push   %edx
8010874a:	50                   	push   %eax
8010874b:	53                   	push   %ebx
8010874c:	68 9c c2 10 80       	push   $0x8010c29c
80108751:	e8 9e 7c ff ff       	call   801003f4 <cprintf>
80108756:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108759:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875c:	c1 e8 18             	shr    $0x18,%eax
8010875f:	a2 80 77 19 80       	mov    %al,0x80197780
  dev.sub_class = (data>>16)&0xFF;
80108764:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108767:	c1 e8 10             	shr    $0x10,%eax
8010876a:	a2 81 77 19 80       	mov    %al,0x80197781
  dev.interface = (data>>8)&0xFF;
8010876f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108772:	c1 e8 08             	shr    $0x8,%eax
80108775:	a2 82 77 19 80       	mov    %al,0x80197782
  dev.revision_id = data&0xFF;
8010877a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877d:	a2 83 77 19 80       	mov    %al,0x80197783
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108782:	83 ec 0c             	sub    $0xc,%esp
80108785:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108788:	50                   	push   %eax
80108789:	6a 10                	push   $0x10
8010878b:	ff 75 10             	push   0x10(%ebp)
8010878e:	ff 75 0c             	push   0xc(%ebp)
80108791:	ff 75 08             	push   0x8(%ebp)
80108794:	e8 40 fe ff ff       	call   801085d9 <pci_access_config>
80108799:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010879c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879f:	a3 84 77 19 80       	mov    %eax,0x80197784
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801087a4:	83 ec 0c             	sub    $0xc,%esp
801087a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087aa:	50                   	push   %eax
801087ab:	6a 14                	push   $0x14
801087ad:	ff 75 10             	push   0x10(%ebp)
801087b0:	ff 75 0c             	push   0xc(%ebp)
801087b3:	ff 75 08             	push   0x8(%ebp)
801087b6:	e8 1e fe ff ff       	call   801085d9 <pci_access_config>
801087bb:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801087be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c1:	a3 88 77 19 80       	mov    %eax,0x80197788
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801087c6:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801087cd:	75 5a                	jne    80108829 <pci_init_device+0x1a5>
801087cf:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801087d6:	75 51                	jne    80108829 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801087d8:	83 ec 0c             	sub    $0xc,%esp
801087db:	68 e1 c2 10 80       	push   $0x8010c2e1
801087e0:	e8 0f 7c ff ff       	call   801003f4 <cprintf>
801087e5:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801087e8:	83 ec 0c             	sub    $0xc,%esp
801087eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087ee:	50                   	push   %eax
801087ef:	68 f0 00 00 00       	push   $0xf0
801087f4:	ff 75 10             	push   0x10(%ebp)
801087f7:	ff 75 0c             	push   0xc(%ebp)
801087fa:	ff 75 08             	push   0x8(%ebp)
801087fd:	e8 d7 fd ff ff       	call   801085d9 <pci_access_config>
80108802:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108805:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108808:	83 ec 08             	sub    $0x8,%esp
8010880b:	50                   	push   %eax
8010880c:	68 fb c2 10 80       	push   $0x8010c2fb
80108811:	e8 de 7b ff ff       	call   801003f4 <cprintf>
80108816:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108819:	83 ec 0c             	sub    $0xc,%esp
8010881c:	68 74 77 19 80       	push   $0x80197774
80108821:	e8 09 00 00 00       	call   8010882f <i8254_init>
80108826:	83 c4 10             	add    $0x10,%esp
  }
}
80108829:	90                   	nop
8010882a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010882d:	c9                   	leave
8010882e:	c3                   	ret

8010882f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010882f:	55                   	push   %ebp
80108830:	89 e5                	mov    %esp,%ebp
80108832:	53                   	push   %ebx
80108833:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108836:	8b 45 08             	mov    0x8(%ebp),%eax
80108839:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010883d:	0f b6 c8             	movzbl %al,%ecx
80108840:	8b 45 08             	mov    0x8(%ebp),%eax
80108843:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108847:	0f b6 d0             	movzbl %al,%edx
8010884a:	8b 45 08             	mov    0x8(%ebp),%eax
8010884d:	0f b6 00             	movzbl (%eax),%eax
80108850:	0f b6 c0             	movzbl %al,%eax
80108853:	83 ec 0c             	sub    $0xc,%esp
80108856:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108859:	53                   	push   %ebx
8010885a:	6a 04                	push   $0x4
8010885c:	51                   	push   %ecx
8010885d:	52                   	push   %edx
8010885e:	50                   	push   %eax
8010885f:	e8 75 fd ff ff       	call   801085d9 <pci_access_config>
80108864:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108867:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010886a:	83 c8 04             	or     $0x4,%eax
8010886d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108870:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108873:	8b 45 08             	mov    0x8(%ebp),%eax
80108876:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010887a:	0f b6 c8             	movzbl %al,%ecx
8010887d:	8b 45 08             	mov    0x8(%ebp),%eax
80108880:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108884:	0f b6 d0             	movzbl %al,%edx
80108887:	8b 45 08             	mov    0x8(%ebp),%eax
8010888a:	0f b6 00             	movzbl (%eax),%eax
8010888d:	0f b6 c0             	movzbl %al,%eax
80108890:	83 ec 0c             	sub    $0xc,%esp
80108893:	53                   	push   %ebx
80108894:	6a 04                	push   $0x4
80108896:	51                   	push   %ecx
80108897:	52                   	push   %edx
80108898:	50                   	push   %eax
80108899:	e8 90 fd ff ff       	call   8010862e <pci_write_config_register>
8010889e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801088a1:	8b 45 08             	mov    0x8(%ebp),%eax
801088a4:	8b 40 10             	mov    0x10(%eax),%eax
801088a7:	05 00 00 00 40       	add    $0x40000000,%eax
801088ac:	a3 8c 77 19 80       	mov    %eax,0x8019778c
  uint *ctrl = (uint *)base_addr;
801088b1:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801088b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801088b9:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801088be:	05 d8 00 00 00       	add    $0xd8,%eax
801088c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801088c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088c9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801088cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d2:	8b 00                	mov    (%eax),%eax
801088d4:	0d 00 00 00 04       	or     $0x4000000,%eax
801088d9:	89 c2                	mov    %eax,%edx
801088db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088de:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801088e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e3:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801088e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ec:	8b 00                	mov    (%eax),%eax
801088ee:	83 c8 40             	or     $0x40,%eax
801088f1:	89 c2                	mov    %eax,%edx
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801088f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fb:	8b 10                	mov    (%eax),%edx
801088fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108900:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108902:	83 ec 0c             	sub    $0xc,%esp
80108905:	68 10 c3 10 80       	push   $0x8010c310
8010890a:	e8 e5 7a ff ff       	call   801003f4 <cprintf>
8010890f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108912:	e8 91 9e ff ff       	call   801027a8 <kalloc>
80108917:	a3 98 77 19 80       	mov    %eax,0x80197798
  *intr_addr = 0;
8010891c:	a1 98 77 19 80       	mov    0x80197798,%eax
80108921:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108927:	a1 98 77 19 80       	mov    0x80197798,%eax
8010892c:	83 ec 08             	sub    $0x8,%esp
8010892f:	50                   	push   %eax
80108930:	68 32 c3 10 80       	push   $0x8010c332
80108935:	e8 ba 7a ff ff       	call   801003f4 <cprintf>
8010893a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010893d:	e8 50 00 00 00       	call   80108992 <i8254_init_recv>
  i8254_init_send();
80108942:	e8 69 03 00 00       	call   80108cb0 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108947:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010894e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108951:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108958:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010895b:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108962:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108965:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010896c:	0f b6 c0             	movzbl %al,%eax
8010896f:	83 ec 0c             	sub    $0xc,%esp
80108972:	53                   	push   %ebx
80108973:	51                   	push   %ecx
80108974:	52                   	push   %edx
80108975:	50                   	push   %eax
80108976:	68 40 c3 10 80       	push   $0x8010c340
8010897b:	e8 74 7a ff ff       	call   801003f4 <cprintf>
80108980:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108986:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010898c:	90                   	nop
8010898d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108990:	c9                   	leave
80108991:	c3                   	ret

80108992 <i8254_init_recv>:

void i8254_init_recv(){
80108992:	55                   	push   %ebp
80108993:	89 e5                	mov    %esp,%ebp
80108995:	57                   	push   %edi
80108996:	56                   	push   %esi
80108997:	53                   	push   %ebx
80108998:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
8010899b:	83 ec 0c             	sub    $0xc,%esp
8010899e:	6a 00                	push   $0x0
801089a0:	e8 e8 04 00 00       	call   80108e8d <i8254_read_eeprom>
801089a5:	83 c4 10             	add    $0x10,%esp
801089a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801089ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089ae:	a2 90 77 19 80       	mov    %al,0x80197790
  mac_addr[1] = data_l>>8;
801089b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089b6:	c1 e8 08             	shr    $0x8,%eax
801089b9:	a2 91 77 19 80       	mov    %al,0x80197791
  uint data_m = i8254_read_eeprom(0x1);
801089be:	83 ec 0c             	sub    $0xc,%esp
801089c1:	6a 01                	push   $0x1
801089c3:	e8 c5 04 00 00       	call   80108e8d <i8254_read_eeprom>
801089c8:	83 c4 10             	add    $0x10,%esp
801089cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801089ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089d1:	a2 92 77 19 80       	mov    %al,0x80197792
  mac_addr[3] = data_m>>8;
801089d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089d9:	c1 e8 08             	shr    $0x8,%eax
801089dc:	a2 93 77 19 80       	mov    %al,0x80197793
  uint data_h = i8254_read_eeprom(0x2);
801089e1:	83 ec 0c             	sub    $0xc,%esp
801089e4:	6a 02                	push   $0x2
801089e6:	e8 a2 04 00 00       	call   80108e8d <i8254_read_eeprom>
801089eb:	83 c4 10             	add    $0x10,%esp
801089ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801089f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089f4:	a2 94 77 19 80       	mov    %al,0x80197794
  mac_addr[5] = data_h>>8;
801089f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089fc:	c1 e8 08             	shr    $0x8,%eax
801089ff:	a2 95 77 19 80       	mov    %al,0x80197795
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a04:	0f b6 05 95 77 19 80 	movzbl 0x80197795,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a0b:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108a0e:	0f b6 05 94 77 19 80 	movzbl 0x80197794,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a15:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108a18:	0f b6 05 93 77 19 80 	movzbl 0x80197793,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a1f:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108a22:	0f b6 05 92 77 19 80 	movzbl 0x80197792,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a29:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108a2c:	0f b6 05 91 77 19 80 	movzbl 0x80197791,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a33:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108a36:	0f b6 05 90 77 19 80 	movzbl 0x80197790,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a3d:	0f b6 c0             	movzbl %al,%eax
80108a40:	83 ec 04             	sub    $0x4,%esp
80108a43:	57                   	push   %edi
80108a44:	56                   	push   %esi
80108a45:	53                   	push   %ebx
80108a46:	51                   	push   %ecx
80108a47:	52                   	push   %edx
80108a48:	50                   	push   %eax
80108a49:	68 58 c3 10 80       	push   $0x8010c358
80108a4e:	e8 a1 79 ff ff       	call   801003f4 <cprintf>
80108a53:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108a56:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108a5b:	05 00 54 00 00       	add    $0x5400,%eax
80108a60:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108a63:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108a68:	05 04 54 00 00       	add    $0x5404,%eax
80108a6d:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108a70:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a73:	c1 e0 10             	shl    $0x10,%eax
80108a76:	0b 45 d8             	or     -0x28(%ebp),%eax
80108a79:	89 c2                	mov    %eax,%edx
80108a7b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108a7e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108a80:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a83:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a88:	89 c2                	mov    %eax,%edx
80108a8a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a8d:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108a8f:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108a94:	05 00 52 00 00       	add    $0x5200,%eax
80108a99:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108a9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108aa3:	eb 19                	jmp    80108abe <i8254_init_recv+0x12c>
    mta[i] = 0;
80108aa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108aa8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108aaf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ab2:	01 d0                	add    %edx,%eax
80108ab4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108aba:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108abe:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108ac2:	7e e1                	jle    80108aa5 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108ac4:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ac9:	05 d0 00 00 00       	add    $0xd0,%eax
80108ace:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ad1:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108ad4:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108ada:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108adf:	05 c8 00 00 00       	add    $0xc8,%eax
80108ae4:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ae7:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108aea:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108af0:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108af5:	05 28 28 00 00       	add    $0x2828,%eax
80108afa:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108afd:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b06:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b0b:	05 00 01 00 00       	add    $0x100,%eax
80108b10:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108b13:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b16:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108b1c:	e8 87 9c ff ff       	call   801027a8 <kalloc>
80108b21:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b24:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b29:	05 00 28 00 00       	add    $0x2800,%eax
80108b2e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108b31:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b36:	05 04 28 00 00       	add    $0x2804,%eax
80108b3b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108b3e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b43:	05 08 28 00 00       	add    $0x2808,%eax
80108b48:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b4b:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b50:	05 10 28 00 00       	add    $0x2810,%eax
80108b55:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b58:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b5d:	05 18 28 00 00       	add    $0x2818,%eax
80108b62:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108b65:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b68:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b6e:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108b71:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108b73:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108b76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108b7c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108b7f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108b85:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108b88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108b8e:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108b91:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108b97:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b9a:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108b9d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108ba4:	eb 73                	jmp    80108c19 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108ba6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ba9:	c1 e0 04             	shl    $0x4,%eax
80108bac:	89 c2                	mov    %eax,%edx
80108bae:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bb1:	01 d0                	add    %edx,%eax
80108bb3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108bba:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bbd:	c1 e0 04             	shl    $0x4,%eax
80108bc0:	89 c2                	mov    %eax,%edx
80108bc2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bc5:	01 d0                	add    %edx,%eax
80108bc7:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108bcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bd0:	c1 e0 04             	shl    $0x4,%eax
80108bd3:	89 c2                	mov    %eax,%edx
80108bd5:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bd8:	01 d0                	add    %edx,%eax
80108bda:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108be0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108be3:	c1 e0 04             	shl    $0x4,%eax
80108be6:	89 c2                	mov    %eax,%edx
80108be8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108beb:	01 d0                	add    %edx,%eax
80108bed:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108bf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bf4:	c1 e0 04             	shl    $0x4,%eax
80108bf7:	89 c2                	mov    %eax,%edx
80108bf9:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bfc:	01 d0                	add    %edx,%eax
80108bfe:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c02:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c05:	c1 e0 04             	shl    $0x4,%eax
80108c08:	89 c2                	mov    %eax,%edx
80108c0a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c0d:	01 d0                	add    %edx,%eax
80108c0f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c15:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108c19:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108c20:	7e 84                	jle    80108ba6 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c22:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108c29:	eb 57                	jmp    80108c82 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108c2b:	e8 78 9b ff ff       	call   801027a8 <kalloc>
80108c30:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108c33:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108c37:	75 12                	jne    80108c4b <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108c39:	83 ec 0c             	sub    $0xc,%esp
80108c3c:	68 78 c3 10 80       	push   $0x8010c378
80108c41:	e8 ae 77 ff ff       	call   801003f4 <cprintf>
80108c46:	83 c4 10             	add    $0x10,%esp
      break;
80108c49:	eb 3d                	jmp    80108c88 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108c4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c4e:	c1 e0 04             	shl    $0x4,%eax
80108c51:	89 c2                	mov    %eax,%edx
80108c53:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c56:	01 d0                	add    %edx,%eax
80108c58:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c5b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c61:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c66:	83 c0 01             	add    $0x1,%eax
80108c69:	c1 e0 04             	shl    $0x4,%eax
80108c6c:	89 c2                	mov    %eax,%edx
80108c6e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c71:	01 d0                	add    %edx,%eax
80108c73:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c76:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c7c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c7e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108c82:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108c86:	7e a3                	jle    80108c2b <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108c88:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c8b:	8b 00                	mov    (%eax),%eax
80108c8d:	83 c8 02             	or     $0x2,%eax
80108c90:	89 c2                	mov    %eax,%edx
80108c92:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c95:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108c97:	83 ec 0c             	sub    $0xc,%esp
80108c9a:	68 98 c3 10 80       	push   $0x8010c398
80108c9f:	e8 50 77 ff ff       	call   801003f4 <cprintf>
80108ca4:	83 c4 10             	add    $0x10,%esp
}
80108ca7:	90                   	nop
80108ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108cab:	5b                   	pop    %ebx
80108cac:	5e                   	pop    %esi
80108cad:	5f                   	pop    %edi
80108cae:	5d                   	pop    %ebp
80108caf:	c3                   	ret

80108cb0 <i8254_init_send>:

void i8254_init_send(){
80108cb0:	55                   	push   %ebp
80108cb1:	89 e5                	mov    %esp,%ebp
80108cb3:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108cb6:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108cbb:	05 28 38 00 00       	add    $0x3828,%eax
80108cc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108cc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cc6:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108ccc:	e8 d7 9a ff ff       	call   801027a8 <kalloc>
80108cd1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108cd4:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108cd9:	05 00 38 00 00       	add    $0x3800,%eax
80108cde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108ce1:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ce6:	05 04 38 00 00       	add    $0x3804,%eax
80108ceb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108cee:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108cf3:	05 08 38 00 00       	add    $0x3808,%eax
80108cf8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108cfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cfe:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d07:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108d09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108d12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d15:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d1b:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d20:	05 10 38 00 00       	add    $0x3810,%eax
80108d25:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d28:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d2d:	05 18 38 00 00       	add    $0x3818,%eax
80108d32:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108d35:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108d3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108d47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d4a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d54:	e9 82 00 00 00       	jmp    80108ddb <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5c:	c1 e0 04             	shl    $0x4,%eax
80108d5f:	89 c2                	mov    %eax,%edx
80108d61:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d64:	01 d0                	add    %edx,%eax
80108d66:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d70:	c1 e0 04             	shl    $0x4,%eax
80108d73:	89 c2                	mov    %eax,%edx
80108d75:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d78:	01 d0                	add    %edx,%eax
80108d7a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d83:	c1 e0 04             	shl    $0x4,%eax
80108d86:	89 c2                	mov    %eax,%edx
80108d88:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d8b:	01 d0                	add    %edx,%eax
80108d8d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d94:	c1 e0 04             	shl    $0x4,%eax
80108d97:	89 c2                	mov    %eax,%edx
80108d99:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d9c:	01 d0                	add    %edx,%eax
80108d9e:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da5:	c1 e0 04             	shl    $0x4,%eax
80108da8:	89 c2                	mov    %eax,%edx
80108daa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dad:	01 d0                	add    %edx,%eax
80108daf:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db6:	c1 e0 04             	shl    $0x4,%eax
80108db9:	89 c2                	mov    %eax,%edx
80108dbb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dbe:	01 d0                	add    %edx,%eax
80108dc0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc7:	c1 e0 04             	shl    $0x4,%eax
80108dca:	89 c2                	mov    %eax,%edx
80108dcc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dcf:	01 d0                	add    %edx,%eax
80108dd1:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108dd7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ddb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108de2:	0f 8e 71 ff ff ff    	jle    80108d59 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108de8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108def:	eb 57                	jmp    80108e48 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108df1:	e8 b2 99 ff ff       	call   801027a8 <kalloc>
80108df6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108df9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108dfd:	75 12                	jne    80108e11 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108dff:	83 ec 0c             	sub    $0xc,%esp
80108e02:	68 78 c3 10 80       	push   $0x8010c378
80108e07:	e8 e8 75 ff ff       	call   801003f4 <cprintf>
80108e0c:	83 c4 10             	add    $0x10,%esp
      break;
80108e0f:	eb 3d                	jmp    80108e4e <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e14:	c1 e0 04             	shl    $0x4,%eax
80108e17:	89 c2                	mov    %eax,%edx
80108e19:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e1c:	01 d0                	add    %edx,%eax
80108e1e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e21:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e27:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e2c:	83 c0 01             	add    $0x1,%eax
80108e2f:	c1 e0 04             	shl    $0x4,%eax
80108e32:	89 c2                	mov    %eax,%edx
80108e34:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e37:	01 d0                	add    %edx,%eax
80108e39:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e3c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e42:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e44:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e48:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108e4c:	7e a3                	jle    80108df1 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108e4e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e53:	05 00 04 00 00       	add    $0x400,%eax
80108e58:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108e5b:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e5e:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108e64:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e69:	05 10 04 00 00       	add    $0x410,%eax
80108e6e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108e71:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e74:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108e7a:	83 ec 0c             	sub    $0xc,%esp
80108e7d:	68 b8 c3 10 80       	push   $0x8010c3b8
80108e82:	e8 6d 75 ff ff       	call   801003f4 <cprintf>
80108e87:	83 c4 10             	add    $0x10,%esp

}
80108e8a:	90                   	nop
80108e8b:	c9                   	leave
80108e8c:	c3                   	ret

80108e8d <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108e8d:	55                   	push   %ebp
80108e8e:	89 e5                	mov    %esp,%ebp
80108e90:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108e93:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e98:	83 c0 14             	add    $0x14,%eax
80108e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea1:	c1 e0 08             	shl    $0x8,%eax
80108ea4:	0f b7 c0             	movzwl %ax,%eax
80108ea7:	83 c8 01             	or     $0x1,%eax
80108eaa:	89 c2                	mov    %eax,%edx
80108eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eaf:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108eb1:	83 ec 0c             	sub    $0xc,%esp
80108eb4:	68 d8 c3 10 80       	push   $0x8010c3d8
80108eb9:	e8 36 75 ff ff       	call   801003f4 <cprintf>
80108ebe:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec4:	8b 00                	mov    (%eax),%eax
80108ec6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ecc:	83 e0 10             	and    $0x10,%eax
80108ecf:	85 c0                	test   %eax,%eax
80108ed1:	75 02                	jne    80108ed5 <i8254_read_eeprom+0x48>
  while(1){
80108ed3:	eb dc                	jmp    80108eb1 <i8254_read_eeprom+0x24>
      break;
80108ed5:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed9:	8b 00                	mov    (%eax),%eax
80108edb:	c1 e8 10             	shr    $0x10,%eax
}
80108ede:	c9                   	leave
80108edf:	c3                   	ret

80108ee0 <i8254_recv>:
void i8254_recv(){
80108ee0:	55                   	push   %ebp
80108ee1:	89 e5                	mov    %esp,%ebp
80108ee3:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108ee6:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108eeb:	05 10 28 00 00       	add    $0x2810,%eax
80108ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108ef3:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ef8:	05 18 28 00 00       	add    $0x2818,%eax
80108efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f00:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f05:	05 00 28 00 00       	add    $0x2800,%eax
80108f0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108f0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f10:	8b 00                	mov    (%eax),%eax
80108f12:	05 00 00 00 80       	add    $0x80000000,%eax
80108f17:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1d:	8b 10                	mov    (%eax),%edx
80108f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f22:	8b 00                	mov    (%eax),%eax
80108f24:	29 c2                	sub    %eax,%edx
80108f26:	89 d0                	mov    %edx,%eax
80108f28:	25 ff 00 00 00       	and    $0xff,%eax
80108f2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108f30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f34:	7e 37                	jle    80108f6d <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f39:	8b 00                	mov    (%eax),%eax
80108f3b:	c1 e0 04             	shl    $0x4,%eax
80108f3e:	89 c2                	mov    %eax,%edx
80108f40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f43:	01 d0                	add    %edx,%eax
80108f45:	8b 00                	mov    (%eax),%eax
80108f47:	05 00 00 00 80       	add    $0x80000000,%eax
80108f4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f52:	8b 00                	mov    (%eax),%eax
80108f54:	83 c0 01             	add    $0x1,%eax
80108f57:	0f b6 d0             	movzbl %al,%edx
80108f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5d:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108f5f:	83 ec 0c             	sub    $0xc,%esp
80108f62:	ff 75 e0             	push   -0x20(%ebp)
80108f65:	e8 13 09 00 00       	call   8010987d <eth_proc>
80108f6a:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f70:	8b 10                	mov    (%eax),%edx
80108f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f75:	8b 00                	mov    (%eax),%eax
80108f77:	39 c2                	cmp    %eax,%edx
80108f79:	75 9f                	jne    80108f1a <i8254_recv+0x3a>
      (*rdt)--;
80108f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f7e:	8b 00                	mov    (%eax),%eax
80108f80:	8d 50 ff             	lea    -0x1(%eax),%edx
80108f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f86:	89 10                	mov    %edx,(%eax)
  while(1){
80108f88:	eb 90                	jmp    80108f1a <i8254_recv+0x3a>

80108f8a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108f8a:	55                   	push   %ebp
80108f8b:	89 e5                	mov    %esp,%ebp
80108f8d:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f90:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f95:	05 10 38 00 00       	add    $0x3810,%eax
80108f9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f9d:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fa2:	05 18 38 00 00       	add    $0x3818,%eax
80108fa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108faa:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108faf:	05 00 38 00 00       	add    $0x3800,%eax
80108fb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108fb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fba:	8b 00                	mov    (%eax),%eax
80108fbc:	05 00 00 00 80       	add    $0x80000000,%eax
80108fc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc7:	8b 10                	mov    (%eax),%edx
80108fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fcc:	8b 00                	mov    (%eax),%eax
80108fce:	29 c2                	sub    %eax,%edx
80108fd0:	0f b6 c2             	movzbl %dl,%eax
80108fd3:	ba 00 01 00 00       	mov    $0x100,%edx
80108fd8:	29 c2                	sub    %eax,%edx
80108fda:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe0:	8b 00                	mov    (%eax),%eax
80108fe2:	25 ff 00 00 00       	and    $0xff,%eax
80108fe7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108fea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108fee:	0f 8e a8 00 00 00    	jle    8010909c <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80108ff7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108ffa:	89 d1                	mov    %edx,%ecx
80108ffc:	c1 e1 04             	shl    $0x4,%ecx
80108fff:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109002:	01 ca                	add    %ecx,%edx
80109004:	8b 12                	mov    (%edx),%edx
80109006:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010900c:	83 ec 04             	sub    $0x4,%esp
8010900f:	ff 75 0c             	push   0xc(%ebp)
80109012:	50                   	push   %eax
80109013:	52                   	push   %edx
80109014:	e8 a5 be ff ff       	call   80104ebe <memmove>
80109019:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010901c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010901f:	c1 e0 04             	shl    $0x4,%eax
80109022:	89 c2                	mov    %eax,%edx
80109024:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109027:	01 d0                	add    %edx,%eax
80109029:	8b 55 0c             	mov    0xc(%ebp),%edx
8010902c:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109030:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109033:	c1 e0 04             	shl    $0x4,%eax
80109036:	89 c2                	mov    %eax,%edx
80109038:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010903b:	01 d0                	add    %edx,%eax
8010903d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109041:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109044:	c1 e0 04             	shl    $0x4,%eax
80109047:	89 c2                	mov    %eax,%edx
80109049:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010904c:	01 d0                	add    %edx,%eax
8010904e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109052:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109055:	c1 e0 04             	shl    $0x4,%eax
80109058:	89 c2                	mov    %eax,%edx
8010905a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010905d:	01 d0                	add    %edx,%eax
8010905f:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109063:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109066:	c1 e0 04             	shl    $0x4,%eax
80109069:	89 c2                	mov    %eax,%edx
8010906b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010906e:	01 d0                	add    %edx,%eax
80109070:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109076:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109079:	c1 e0 04             	shl    $0x4,%eax
8010907c:	89 c2                	mov    %eax,%edx
8010907e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109081:	01 d0                	add    %edx,%eax
80109083:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109087:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010908a:	8b 00                	mov    (%eax),%eax
8010908c:	83 c0 01             	add    $0x1,%eax
8010908f:	0f b6 d0             	movzbl %al,%edx
80109092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109095:	89 10                	mov    %edx,(%eax)
    return len;
80109097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010909a:	eb 05                	jmp    801090a1 <i8254_send+0x117>
  }else{
    return -1;
8010909c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801090a1:	c9                   	leave
801090a2:	c3                   	ret

801090a3 <i8254_intr>:

void i8254_intr(){
801090a3:	55                   	push   %ebp
801090a4:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801090a6:	a1 98 77 19 80       	mov    0x80197798,%eax
801090ab:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801090b1:	90                   	nop
801090b2:	5d                   	pop    %ebp
801090b3:	c3                   	ret

801090b4 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801090b4:	55                   	push   %ebp
801090b5:	89 e5                	mov    %esp,%ebp
801090b7:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801090ba:	8b 45 08             	mov    0x8(%ebp),%eax
801090bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801090c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c3:	0f b7 00             	movzwl (%eax),%eax
801090c6:	66 3d 00 01          	cmp    $0x100,%ax
801090ca:	74 0a                	je     801090d6 <arp_proc+0x22>
801090cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090d1:	e9 4f 01 00 00       	jmp    80109225 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801090d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d9:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801090dd:	66 83 f8 08          	cmp    $0x8,%ax
801090e1:	74 0a                	je     801090ed <arp_proc+0x39>
801090e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090e8:	e9 38 01 00 00       	jmp    80109225 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
801090ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801090f4:	3c 06                	cmp    $0x6,%al
801090f6:	74 0a                	je     80109102 <arp_proc+0x4e>
801090f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090fd:	e9 23 01 00 00       	jmp    80109225 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109105:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109109:	3c 04                	cmp    $0x4,%al
8010910b:	74 0a                	je     80109117 <arp_proc+0x63>
8010910d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109112:	e9 0e 01 00 00       	jmp    80109225 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911a:	83 c0 18             	add    $0x18,%eax
8010911d:	83 ec 04             	sub    $0x4,%esp
80109120:	6a 04                	push   $0x4
80109122:	50                   	push   %eax
80109123:	68 04 f5 10 80       	push   $0x8010f504
80109128:	e8 39 bd ff ff       	call   80104e66 <memcmp>
8010912d:	83 c4 10             	add    $0x10,%esp
80109130:	85 c0                	test   %eax,%eax
80109132:	74 27                	je     8010915b <arp_proc+0xa7>
80109134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109137:	83 c0 0e             	add    $0xe,%eax
8010913a:	83 ec 04             	sub    $0x4,%esp
8010913d:	6a 04                	push   $0x4
8010913f:	50                   	push   %eax
80109140:	68 04 f5 10 80       	push   $0x8010f504
80109145:	e8 1c bd ff ff       	call   80104e66 <memcmp>
8010914a:	83 c4 10             	add    $0x10,%esp
8010914d:	85 c0                	test   %eax,%eax
8010914f:	74 0a                	je     8010915b <arp_proc+0xa7>
80109151:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109156:	e9 ca 00 00 00       	jmp    80109225 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010915b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109162:	66 3d 00 01          	cmp    $0x100,%ax
80109166:	75 69                	jne    801091d1 <arp_proc+0x11d>
80109168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916b:	83 c0 18             	add    $0x18,%eax
8010916e:	83 ec 04             	sub    $0x4,%esp
80109171:	6a 04                	push   $0x4
80109173:	50                   	push   %eax
80109174:	68 04 f5 10 80       	push   $0x8010f504
80109179:	e8 e8 bc ff ff       	call   80104e66 <memcmp>
8010917e:	83 c4 10             	add    $0x10,%esp
80109181:	85 c0                	test   %eax,%eax
80109183:	75 4c                	jne    801091d1 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109185:	e8 1e 96 ff ff       	call   801027a8 <kalloc>
8010918a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010918d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109194:	83 ec 04             	sub    $0x4,%esp
80109197:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010919a:	50                   	push   %eax
8010919b:	ff 75 f0             	push   -0x10(%ebp)
8010919e:	ff 75 f4             	push   -0xc(%ebp)
801091a1:	e8 1f 04 00 00       	call   801095c5 <arp_reply_pkt_create>
801091a6:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801091a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091ac:	83 ec 08             	sub    $0x8,%esp
801091af:	50                   	push   %eax
801091b0:	ff 75 f0             	push   -0x10(%ebp)
801091b3:	e8 d2 fd ff ff       	call   80108f8a <i8254_send>
801091b8:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801091bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091be:	83 ec 0c             	sub    $0xc,%esp
801091c1:	50                   	push   %eax
801091c2:	e8 47 95 ff ff       	call   8010270e <kfree>
801091c7:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801091ca:	b8 02 00 00 00       	mov    $0x2,%eax
801091cf:	eb 54                	jmp    80109225 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091d8:	66 3d 00 02          	cmp    $0x200,%ax
801091dc:	75 42                	jne    80109220 <arp_proc+0x16c>
801091de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e1:	83 c0 18             	add    $0x18,%eax
801091e4:	83 ec 04             	sub    $0x4,%esp
801091e7:	6a 04                	push   $0x4
801091e9:	50                   	push   %eax
801091ea:	68 04 f5 10 80       	push   $0x8010f504
801091ef:	e8 72 bc ff ff       	call   80104e66 <memcmp>
801091f4:	83 c4 10             	add    $0x10,%esp
801091f7:	85 c0                	test   %eax,%eax
801091f9:	75 25                	jne    80109220 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
801091fb:	83 ec 0c             	sub    $0xc,%esp
801091fe:	68 dc c3 10 80       	push   $0x8010c3dc
80109203:	e8 ec 71 ff ff       	call   801003f4 <cprintf>
80109208:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010920b:	83 ec 0c             	sub    $0xc,%esp
8010920e:	ff 75 f4             	push   -0xc(%ebp)
80109211:	e8 af 01 00 00       	call   801093c5 <arp_table_update>
80109216:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109219:	b8 01 00 00 00       	mov    $0x1,%eax
8010921e:	eb 05                	jmp    80109225 <arp_proc+0x171>
  }else{
    return -1;
80109220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109225:	c9                   	leave
80109226:	c3                   	ret

80109227 <arp_scan>:

void arp_scan(){
80109227:	55                   	push   %ebp
80109228:	89 e5                	mov    %esp,%ebp
8010922a:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010922d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109234:	eb 6f                	jmp    801092a5 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109236:	e8 6d 95 ff ff       	call   801027a8 <kalloc>
8010923b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010923e:	83 ec 04             	sub    $0x4,%esp
80109241:	ff 75 f4             	push   -0xc(%ebp)
80109244:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109247:	50                   	push   %eax
80109248:	ff 75 ec             	push   -0x14(%ebp)
8010924b:	e8 62 00 00 00       	call   801092b2 <arp_broadcast>
80109250:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109253:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109256:	83 ec 08             	sub    $0x8,%esp
80109259:	50                   	push   %eax
8010925a:	ff 75 ec             	push   -0x14(%ebp)
8010925d:	e8 28 fd ff ff       	call   80108f8a <i8254_send>
80109262:	83 c4 10             	add    $0x10,%esp
80109265:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109268:	eb 22                	jmp    8010928c <arp_scan+0x65>
      microdelay(1);
8010926a:	83 ec 0c             	sub    $0xc,%esp
8010926d:	6a 01                	push   $0x1
8010926f:	e8 c5 98 ff ff       	call   80102b39 <microdelay>
80109274:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109277:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010927a:	83 ec 08             	sub    $0x8,%esp
8010927d:	50                   	push   %eax
8010927e:	ff 75 ec             	push   -0x14(%ebp)
80109281:	e8 04 fd ff ff       	call   80108f8a <i8254_send>
80109286:	83 c4 10             	add    $0x10,%esp
80109289:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010928c:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109290:	74 d8                	je     8010926a <arp_scan+0x43>
    }
    kfree((char *)send);
80109292:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109295:	83 ec 0c             	sub    $0xc,%esp
80109298:	50                   	push   %eax
80109299:	e8 70 94 ff ff       	call   8010270e <kfree>
8010929e:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801092a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801092a5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801092ac:	7e 88                	jle    80109236 <arp_scan+0xf>
  }
}
801092ae:	90                   	nop
801092af:	90                   	nop
801092b0:	c9                   	leave
801092b1:	c3                   	ret

801092b2 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801092b2:	55                   	push   %ebp
801092b3:	89 e5                	mov    %esp,%ebp
801092b5:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801092b8:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801092bc:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801092c0:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801092c4:	8b 45 10             	mov    0x10(%ebp),%eax
801092c7:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801092ca:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801092d1:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801092d7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801092de:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801092e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801092e7:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801092ed:	8b 45 08             	mov    0x8(%ebp),%eax
801092f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801092f3:	8b 45 08             	mov    0x8(%ebp),%eax
801092f6:	83 c0 0e             	add    $0xe,%eax
801092f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801092fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ff:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109306:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010930a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930d:	83 ec 04             	sub    $0x4,%esp
80109310:	6a 06                	push   $0x6
80109312:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109315:	52                   	push   %edx
80109316:	50                   	push   %eax
80109317:	e8 a2 bb ff ff       	call   80104ebe <memmove>
8010931c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010931f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109322:	83 c0 06             	add    $0x6,%eax
80109325:	83 ec 04             	sub    $0x4,%esp
80109328:	6a 06                	push   $0x6
8010932a:	68 90 77 19 80       	push   $0x80197790
8010932f:	50                   	push   %eax
80109330:	e8 89 bb ff ff       	call   80104ebe <memmove>
80109335:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109338:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010933b:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109340:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109343:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010934c:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109353:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010935a:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109360:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109363:	8d 50 12             	lea    0x12(%eax),%edx
80109366:	83 ec 04             	sub    $0x4,%esp
80109369:	6a 06                	push   $0x6
8010936b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010936e:	50                   	push   %eax
8010936f:	52                   	push   %edx
80109370:	e8 49 bb ff ff       	call   80104ebe <memmove>
80109375:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010937b:	8d 50 18             	lea    0x18(%eax),%edx
8010937e:	83 ec 04             	sub    $0x4,%esp
80109381:	6a 04                	push   $0x4
80109383:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109386:	50                   	push   %eax
80109387:	52                   	push   %edx
80109388:	e8 31 bb ff ff       	call   80104ebe <memmove>
8010938d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109393:	83 c0 08             	add    $0x8,%eax
80109396:	83 ec 04             	sub    $0x4,%esp
80109399:	6a 06                	push   $0x6
8010939b:	68 90 77 19 80       	push   $0x80197790
801093a0:	50                   	push   %eax
801093a1:	e8 18 bb ff ff       	call   80104ebe <memmove>
801093a6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801093a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ac:	83 c0 0e             	add    $0xe,%eax
801093af:	83 ec 04             	sub    $0x4,%esp
801093b2:	6a 04                	push   $0x4
801093b4:	68 04 f5 10 80       	push   $0x8010f504
801093b9:	50                   	push   %eax
801093ba:	e8 ff ba ff ff       	call   80104ebe <memmove>
801093bf:	83 c4 10             	add    $0x10,%esp
}
801093c2:	90                   	nop
801093c3:	c9                   	leave
801093c4:	c3                   	ret

801093c5 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801093c5:	55                   	push   %ebp
801093c6:	89 e5                	mov    %esp,%ebp
801093c8:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801093cb:	8b 45 08             	mov    0x8(%ebp),%eax
801093ce:	83 c0 0e             	add    $0xe,%eax
801093d1:	83 ec 0c             	sub    $0xc,%esp
801093d4:	50                   	push   %eax
801093d5:	e8 bc 00 00 00       	call   80109496 <arp_table_search>
801093da:	83 c4 10             	add    $0x10,%esp
801093dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801093e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801093e4:	78 2d                	js     80109413 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801093e6:	8b 45 08             	mov    0x8(%ebp),%eax
801093e9:	8d 48 08             	lea    0x8(%eax),%ecx
801093ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093ef:	89 d0                	mov    %edx,%eax
801093f1:	c1 e0 02             	shl    $0x2,%eax
801093f4:	01 d0                	add    %edx,%eax
801093f6:	01 c0                	add    %eax,%eax
801093f8:	01 d0                	add    %edx,%eax
801093fa:	05 a0 77 19 80       	add    $0x801977a0,%eax
801093ff:	83 c0 04             	add    $0x4,%eax
80109402:	83 ec 04             	sub    $0x4,%esp
80109405:	6a 06                	push   $0x6
80109407:	51                   	push   %ecx
80109408:	50                   	push   %eax
80109409:	e8 b0 ba ff ff       	call   80104ebe <memmove>
8010940e:	83 c4 10             	add    $0x10,%esp
80109411:	eb 70                	jmp    80109483 <arp_table_update+0xbe>
  }else{
    index += 1;
80109413:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109417:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010941a:	8b 45 08             	mov    0x8(%ebp),%eax
8010941d:	8d 48 08             	lea    0x8(%eax),%ecx
80109420:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109423:	89 d0                	mov    %edx,%eax
80109425:	c1 e0 02             	shl    $0x2,%eax
80109428:	01 d0                	add    %edx,%eax
8010942a:	01 c0                	add    %eax,%eax
8010942c:	01 d0                	add    %edx,%eax
8010942e:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109433:	83 c0 04             	add    $0x4,%eax
80109436:	83 ec 04             	sub    $0x4,%esp
80109439:	6a 06                	push   $0x6
8010943b:	51                   	push   %ecx
8010943c:	50                   	push   %eax
8010943d:	e8 7c ba ff ff       	call   80104ebe <memmove>
80109442:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109445:	8b 45 08             	mov    0x8(%ebp),%eax
80109448:	8d 48 0e             	lea    0xe(%eax),%ecx
8010944b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010944e:	89 d0                	mov    %edx,%eax
80109450:	c1 e0 02             	shl    $0x2,%eax
80109453:	01 d0                	add    %edx,%eax
80109455:	01 c0                	add    %eax,%eax
80109457:	01 d0                	add    %edx,%eax
80109459:	05 a0 77 19 80       	add    $0x801977a0,%eax
8010945e:	83 ec 04             	sub    $0x4,%esp
80109461:	6a 04                	push   $0x4
80109463:	51                   	push   %ecx
80109464:	50                   	push   %eax
80109465:	e8 54 ba ff ff       	call   80104ebe <memmove>
8010946a:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010946d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109470:	89 d0                	mov    %edx,%eax
80109472:	c1 e0 02             	shl    $0x2,%eax
80109475:	01 d0                	add    %edx,%eax
80109477:	01 c0                	add    %eax,%eax
80109479:	01 d0                	add    %edx,%eax
8010947b:	05 aa 77 19 80       	add    $0x801977aa,%eax
80109480:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109483:	83 ec 0c             	sub    $0xc,%esp
80109486:	68 a0 77 19 80       	push   $0x801977a0
8010948b:	e8 83 00 00 00       	call   80109513 <print_arp_table>
80109490:	83 c4 10             	add    $0x10,%esp
}
80109493:	90                   	nop
80109494:	c9                   	leave
80109495:	c3                   	ret

80109496 <arp_table_search>:

int arp_table_search(uchar *ip){
80109496:	55                   	push   %ebp
80109497:	89 e5                	mov    %esp,%ebp
80109499:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010949c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801094a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801094aa:	eb 59                	jmp    80109505 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801094ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094af:	89 d0                	mov    %edx,%eax
801094b1:	c1 e0 02             	shl    $0x2,%eax
801094b4:	01 d0                	add    %edx,%eax
801094b6:	01 c0                	add    %eax,%eax
801094b8:	01 d0                	add    %edx,%eax
801094ba:	05 a0 77 19 80       	add    $0x801977a0,%eax
801094bf:	83 ec 04             	sub    $0x4,%esp
801094c2:	6a 04                	push   $0x4
801094c4:	ff 75 08             	push   0x8(%ebp)
801094c7:	50                   	push   %eax
801094c8:	e8 99 b9 ff ff       	call   80104e66 <memcmp>
801094cd:	83 c4 10             	add    $0x10,%esp
801094d0:	85 c0                	test   %eax,%eax
801094d2:	75 05                	jne    801094d9 <arp_table_search+0x43>
      return i;
801094d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094d7:	eb 38                	jmp    80109511 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801094d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094dc:	89 d0                	mov    %edx,%eax
801094de:	c1 e0 02             	shl    $0x2,%eax
801094e1:	01 d0                	add    %edx,%eax
801094e3:	01 c0                	add    %eax,%eax
801094e5:	01 d0                	add    %edx,%eax
801094e7:	05 aa 77 19 80       	add    $0x801977aa,%eax
801094ec:	0f b6 00             	movzbl (%eax),%eax
801094ef:	84 c0                	test   %al,%al
801094f1:	75 0e                	jne    80109501 <arp_table_search+0x6b>
801094f3:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801094f7:	75 08                	jne    80109501 <arp_table_search+0x6b>
      empty = -i;
801094f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094fc:	f7 d8                	neg    %eax
801094fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109501:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109505:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109509:	7e a1                	jle    801094ac <arp_table_search+0x16>
    }
  }
  return empty-1;
8010950b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950e:	83 e8 01             	sub    $0x1,%eax
}
80109511:	c9                   	leave
80109512:	c3                   	ret

80109513 <print_arp_table>:

void print_arp_table(){
80109513:	55                   	push   %ebp
80109514:	89 e5                	mov    %esp,%ebp
80109516:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109519:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109520:	e9 92 00 00 00       	jmp    801095b7 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109525:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109528:	89 d0                	mov    %edx,%eax
8010952a:	c1 e0 02             	shl    $0x2,%eax
8010952d:	01 d0                	add    %edx,%eax
8010952f:	01 c0                	add    %eax,%eax
80109531:	01 d0                	add    %edx,%eax
80109533:	05 aa 77 19 80       	add    $0x801977aa,%eax
80109538:	0f b6 00             	movzbl (%eax),%eax
8010953b:	84 c0                	test   %al,%al
8010953d:	74 74                	je     801095b3 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010953f:	83 ec 08             	sub    $0x8,%esp
80109542:	ff 75 f4             	push   -0xc(%ebp)
80109545:	68 ef c3 10 80       	push   $0x8010c3ef
8010954a:	e8 a5 6e ff ff       	call   801003f4 <cprintf>
8010954f:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109552:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109555:	89 d0                	mov    %edx,%eax
80109557:	c1 e0 02             	shl    $0x2,%eax
8010955a:	01 d0                	add    %edx,%eax
8010955c:	01 c0                	add    %eax,%eax
8010955e:	01 d0                	add    %edx,%eax
80109560:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109565:	83 ec 0c             	sub    $0xc,%esp
80109568:	50                   	push   %eax
80109569:	e8 54 02 00 00       	call   801097c2 <print_ipv4>
8010956e:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109571:	83 ec 0c             	sub    $0xc,%esp
80109574:	68 fe c3 10 80       	push   $0x8010c3fe
80109579:	e8 76 6e ff ff       	call   801003f4 <cprintf>
8010957e:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109581:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109584:	89 d0                	mov    %edx,%eax
80109586:	c1 e0 02             	shl    $0x2,%eax
80109589:	01 d0                	add    %edx,%eax
8010958b:	01 c0                	add    %eax,%eax
8010958d:	01 d0                	add    %edx,%eax
8010958f:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109594:	83 c0 04             	add    $0x4,%eax
80109597:	83 ec 0c             	sub    $0xc,%esp
8010959a:	50                   	push   %eax
8010959b:	e8 70 02 00 00       	call   80109810 <print_mac>
801095a0:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801095a3:	83 ec 0c             	sub    $0xc,%esp
801095a6:	68 00 c4 10 80       	push   $0x8010c400
801095ab:	e8 44 6e ff ff       	call   801003f4 <cprintf>
801095b0:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801095b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801095b7:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801095bb:	0f 8e 64 ff ff ff    	jle    80109525 <print_arp_table+0x12>
    }
  }
}
801095c1:	90                   	nop
801095c2:	90                   	nop
801095c3:	c9                   	leave
801095c4:	c3                   	ret

801095c5 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801095c5:	55                   	push   %ebp
801095c6:	89 e5                	mov    %esp,%ebp
801095c8:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801095cb:	8b 45 10             	mov    0x10(%ebp),%eax
801095ce:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801095d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801095d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801095da:	8b 45 0c             	mov    0xc(%ebp),%eax
801095dd:	83 c0 0e             	add    $0xe,%eax
801095e0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801095e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801095ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ed:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801095f1:	8b 45 08             	mov    0x8(%ebp),%eax
801095f4:	8d 50 08             	lea    0x8(%eax),%edx
801095f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095fa:	83 ec 04             	sub    $0x4,%esp
801095fd:	6a 06                	push   $0x6
801095ff:	52                   	push   %edx
80109600:	50                   	push   %eax
80109601:	e8 b8 b8 ff ff       	call   80104ebe <memmove>
80109606:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010960c:	83 c0 06             	add    $0x6,%eax
8010960f:	83 ec 04             	sub    $0x4,%esp
80109612:	6a 06                	push   $0x6
80109614:	68 90 77 19 80       	push   $0x80197790
80109619:	50                   	push   %eax
8010961a:	e8 9f b8 ff ff       	call   80104ebe <memmove>
8010961f:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109625:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010962a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010962d:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109633:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109636:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010963a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010963d:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109644:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010964a:	8b 45 08             	mov    0x8(%ebp),%eax
8010964d:	8d 50 08             	lea    0x8(%eax),%edx
80109650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109653:	83 c0 12             	add    $0x12,%eax
80109656:	83 ec 04             	sub    $0x4,%esp
80109659:	6a 06                	push   $0x6
8010965b:	52                   	push   %edx
8010965c:	50                   	push   %eax
8010965d:	e8 5c b8 ff ff       	call   80104ebe <memmove>
80109662:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109665:	8b 45 08             	mov    0x8(%ebp),%eax
80109668:	8d 50 0e             	lea    0xe(%eax),%edx
8010966b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010966e:	83 c0 18             	add    $0x18,%eax
80109671:	83 ec 04             	sub    $0x4,%esp
80109674:	6a 04                	push   $0x4
80109676:	52                   	push   %edx
80109677:	50                   	push   %eax
80109678:	e8 41 b8 ff ff       	call   80104ebe <memmove>
8010967d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109683:	83 c0 08             	add    $0x8,%eax
80109686:	83 ec 04             	sub    $0x4,%esp
80109689:	6a 06                	push   $0x6
8010968b:	68 90 77 19 80       	push   $0x80197790
80109690:	50                   	push   %eax
80109691:	e8 28 b8 ff ff       	call   80104ebe <memmove>
80109696:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969c:	83 c0 0e             	add    $0xe,%eax
8010969f:	83 ec 04             	sub    $0x4,%esp
801096a2:	6a 04                	push   $0x4
801096a4:	68 04 f5 10 80       	push   $0x8010f504
801096a9:	50                   	push   %eax
801096aa:	e8 0f b8 ff ff       	call   80104ebe <memmove>
801096af:	83 c4 10             	add    $0x10,%esp
}
801096b2:	90                   	nop
801096b3:	c9                   	leave
801096b4:	c3                   	ret

801096b5 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801096b5:	55                   	push   %ebp
801096b6:	89 e5                	mov    %esp,%ebp
801096b8:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801096bb:	83 ec 0c             	sub    $0xc,%esp
801096be:	68 02 c4 10 80       	push   $0x8010c402
801096c3:	e8 2c 6d ff ff       	call   801003f4 <cprintf>
801096c8:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801096cb:	8b 45 08             	mov    0x8(%ebp),%eax
801096ce:	83 c0 0e             	add    $0xe,%eax
801096d1:	83 ec 0c             	sub    $0xc,%esp
801096d4:	50                   	push   %eax
801096d5:	e8 e8 00 00 00       	call   801097c2 <print_ipv4>
801096da:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096dd:	83 ec 0c             	sub    $0xc,%esp
801096e0:	68 00 c4 10 80       	push   $0x8010c400
801096e5:	e8 0a 6d ff ff       	call   801003f4 <cprintf>
801096ea:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801096ed:	8b 45 08             	mov    0x8(%ebp),%eax
801096f0:	83 c0 08             	add    $0x8,%eax
801096f3:	83 ec 0c             	sub    $0xc,%esp
801096f6:	50                   	push   %eax
801096f7:	e8 14 01 00 00       	call   80109810 <print_mac>
801096fc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801096ff:	83 ec 0c             	sub    $0xc,%esp
80109702:	68 00 c4 10 80       	push   $0x8010c400
80109707:	e8 e8 6c ff ff       	call   801003f4 <cprintf>
8010970c:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010970f:	83 ec 0c             	sub    $0xc,%esp
80109712:	68 19 c4 10 80       	push   $0x8010c419
80109717:	e8 d8 6c ff ff       	call   801003f4 <cprintf>
8010971c:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010971f:	8b 45 08             	mov    0x8(%ebp),%eax
80109722:	83 c0 18             	add    $0x18,%eax
80109725:	83 ec 0c             	sub    $0xc,%esp
80109728:	50                   	push   %eax
80109729:	e8 94 00 00 00       	call   801097c2 <print_ipv4>
8010972e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109731:	83 ec 0c             	sub    $0xc,%esp
80109734:	68 00 c4 10 80       	push   $0x8010c400
80109739:	e8 b6 6c ff ff       	call   801003f4 <cprintf>
8010973e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109741:	8b 45 08             	mov    0x8(%ebp),%eax
80109744:	83 c0 12             	add    $0x12,%eax
80109747:	83 ec 0c             	sub    $0xc,%esp
8010974a:	50                   	push   %eax
8010974b:	e8 c0 00 00 00       	call   80109810 <print_mac>
80109750:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109753:	83 ec 0c             	sub    $0xc,%esp
80109756:	68 00 c4 10 80       	push   $0x8010c400
8010975b:	e8 94 6c ff ff       	call   801003f4 <cprintf>
80109760:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109763:	83 ec 0c             	sub    $0xc,%esp
80109766:	68 30 c4 10 80       	push   $0x8010c430
8010976b:	e8 84 6c ff ff       	call   801003f4 <cprintf>
80109770:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109773:	8b 45 08             	mov    0x8(%ebp),%eax
80109776:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010977a:	66 3d 00 01          	cmp    $0x100,%ax
8010977e:	75 12                	jne    80109792 <print_arp_info+0xdd>
80109780:	83 ec 0c             	sub    $0xc,%esp
80109783:	68 3c c4 10 80       	push   $0x8010c43c
80109788:	e8 67 6c ff ff       	call   801003f4 <cprintf>
8010978d:	83 c4 10             	add    $0x10,%esp
80109790:	eb 1d                	jmp    801097af <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109792:	8b 45 08             	mov    0x8(%ebp),%eax
80109795:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109799:	66 3d 00 02          	cmp    $0x200,%ax
8010979d:	75 10                	jne    801097af <print_arp_info+0xfa>
    cprintf("Reply\n");
8010979f:	83 ec 0c             	sub    $0xc,%esp
801097a2:	68 45 c4 10 80       	push   $0x8010c445
801097a7:	e8 48 6c ff ff       	call   801003f4 <cprintf>
801097ac:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801097af:	83 ec 0c             	sub    $0xc,%esp
801097b2:	68 00 c4 10 80       	push   $0x8010c400
801097b7:	e8 38 6c ff ff       	call   801003f4 <cprintf>
801097bc:	83 c4 10             	add    $0x10,%esp
}
801097bf:	90                   	nop
801097c0:	c9                   	leave
801097c1:	c3                   	ret

801097c2 <print_ipv4>:

void print_ipv4(uchar *ip){
801097c2:	55                   	push   %ebp
801097c3:	89 e5                	mov    %esp,%ebp
801097c5:	53                   	push   %ebx
801097c6:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801097c9:	8b 45 08             	mov    0x8(%ebp),%eax
801097cc:	83 c0 03             	add    $0x3,%eax
801097cf:	0f b6 00             	movzbl (%eax),%eax
801097d2:	0f b6 d8             	movzbl %al,%ebx
801097d5:	8b 45 08             	mov    0x8(%ebp),%eax
801097d8:	83 c0 02             	add    $0x2,%eax
801097db:	0f b6 00             	movzbl (%eax),%eax
801097de:	0f b6 c8             	movzbl %al,%ecx
801097e1:	8b 45 08             	mov    0x8(%ebp),%eax
801097e4:	83 c0 01             	add    $0x1,%eax
801097e7:	0f b6 00             	movzbl (%eax),%eax
801097ea:	0f b6 d0             	movzbl %al,%edx
801097ed:	8b 45 08             	mov    0x8(%ebp),%eax
801097f0:	0f b6 00             	movzbl (%eax),%eax
801097f3:	0f b6 c0             	movzbl %al,%eax
801097f6:	83 ec 0c             	sub    $0xc,%esp
801097f9:	53                   	push   %ebx
801097fa:	51                   	push   %ecx
801097fb:	52                   	push   %edx
801097fc:	50                   	push   %eax
801097fd:	68 4c c4 10 80       	push   $0x8010c44c
80109802:	e8 ed 6b ff ff       	call   801003f4 <cprintf>
80109807:	83 c4 20             	add    $0x20,%esp
}
8010980a:	90                   	nop
8010980b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010980e:	c9                   	leave
8010980f:	c3                   	ret

80109810 <print_mac>:

void print_mac(uchar *mac){
80109810:	55                   	push   %ebp
80109811:	89 e5                	mov    %esp,%ebp
80109813:	57                   	push   %edi
80109814:	56                   	push   %esi
80109815:	53                   	push   %ebx
80109816:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109819:	8b 45 08             	mov    0x8(%ebp),%eax
8010981c:	83 c0 05             	add    $0x5,%eax
8010981f:	0f b6 00             	movzbl (%eax),%eax
80109822:	0f b6 f8             	movzbl %al,%edi
80109825:	8b 45 08             	mov    0x8(%ebp),%eax
80109828:	83 c0 04             	add    $0x4,%eax
8010982b:	0f b6 00             	movzbl (%eax),%eax
8010982e:	0f b6 f0             	movzbl %al,%esi
80109831:	8b 45 08             	mov    0x8(%ebp),%eax
80109834:	83 c0 03             	add    $0x3,%eax
80109837:	0f b6 00             	movzbl (%eax),%eax
8010983a:	0f b6 d8             	movzbl %al,%ebx
8010983d:	8b 45 08             	mov    0x8(%ebp),%eax
80109840:	83 c0 02             	add    $0x2,%eax
80109843:	0f b6 00             	movzbl (%eax),%eax
80109846:	0f b6 c8             	movzbl %al,%ecx
80109849:	8b 45 08             	mov    0x8(%ebp),%eax
8010984c:	83 c0 01             	add    $0x1,%eax
8010984f:	0f b6 00             	movzbl (%eax),%eax
80109852:	0f b6 d0             	movzbl %al,%edx
80109855:	8b 45 08             	mov    0x8(%ebp),%eax
80109858:	0f b6 00             	movzbl (%eax),%eax
8010985b:	0f b6 c0             	movzbl %al,%eax
8010985e:	83 ec 04             	sub    $0x4,%esp
80109861:	57                   	push   %edi
80109862:	56                   	push   %esi
80109863:	53                   	push   %ebx
80109864:	51                   	push   %ecx
80109865:	52                   	push   %edx
80109866:	50                   	push   %eax
80109867:	68 64 c4 10 80       	push   $0x8010c464
8010986c:	e8 83 6b ff ff       	call   801003f4 <cprintf>
80109871:	83 c4 20             	add    $0x20,%esp
}
80109874:	90                   	nop
80109875:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109878:	5b                   	pop    %ebx
80109879:	5e                   	pop    %esi
8010987a:	5f                   	pop    %edi
8010987b:	5d                   	pop    %ebp
8010987c:	c3                   	ret

8010987d <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010987d:	55                   	push   %ebp
8010987e:	89 e5                	mov    %esp,%ebp
80109880:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109883:	8b 45 08             	mov    0x8(%ebp),%eax
80109886:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109889:	8b 45 08             	mov    0x8(%ebp),%eax
8010988c:	83 c0 0e             	add    $0xe,%eax
8010988f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109895:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109899:	3c 08                	cmp    $0x8,%al
8010989b:	75 1b                	jne    801098b8 <eth_proc+0x3b>
8010989d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a0:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098a4:	3c 06                	cmp    $0x6,%al
801098a6:	75 10                	jne    801098b8 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801098a8:	83 ec 0c             	sub    $0xc,%esp
801098ab:	ff 75 f0             	push   -0x10(%ebp)
801098ae:	e8 01 f8 ff ff       	call   801090b4 <arp_proc>
801098b3:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801098b6:	eb 24                	jmp    801098dc <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801098b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098bb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098bf:	3c 08                	cmp    $0x8,%al
801098c1:	75 19                	jne    801098dc <eth_proc+0x5f>
801098c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098ca:	84 c0                	test   %al,%al
801098cc:	75 0e                	jne    801098dc <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801098ce:	83 ec 0c             	sub    $0xc,%esp
801098d1:	ff 75 08             	push   0x8(%ebp)
801098d4:	e8 8d 00 00 00       	call   80109966 <ipv4_proc>
801098d9:	83 c4 10             	add    $0x10,%esp
}
801098dc:	90                   	nop
801098dd:	c9                   	leave
801098de:	c3                   	ret

801098df <N2H_ushort>:

ushort N2H_ushort(ushort value){
801098df:	55                   	push   %ebp
801098e0:	89 e5                	mov    %esp,%ebp
801098e2:	83 ec 04             	sub    $0x4,%esp
801098e5:	8b 45 08             	mov    0x8(%ebp),%eax
801098e8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801098ec:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801098f0:	66 c1 c0 08          	rol    $0x8,%ax
}
801098f4:	c9                   	leave
801098f5:	c3                   	ret

801098f6 <H2N_ushort>:

ushort H2N_ushort(ushort value){
801098f6:	55                   	push   %ebp
801098f7:	89 e5                	mov    %esp,%ebp
801098f9:	83 ec 04             	sub    $0x4,%esp
801098fc:	8b 45 08             	mov    0x8(%ebp),%eax
801098ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109903:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109907:	66 c1 c0 08          	rol    $0x8,%ax
}
8010990b:	c9                   	leave
8010990c:	c3                   	ret

8010990d <H2N_uint>:

uint H2N_uint(uint value){
8010990d:	55                   	push   %ebp
8010990e:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109910:	8b 45 08             	mov    0x8(%ebp),%eax
80109913:	c1 e0 18             	shl    $0x18,%eax
80109916:	25 00 00 00 0f       	and    $0xf000000,%eax
8010991b:	89 c2                	mov    %eax,%edx
8010991d:	8b 45 08             	mov    0x8(%ebp),%eax
80109920:	c1 e0 08             	shl    $0x8,%eax
80109923:	25 00 f0 00 00       	and    $0xf000,%eax
80109928:	09 c2                	or     %eax,%edx
8010992a:	8b 45 08             	mov    0x8(%ebp),%eax
8010992d:	c1 e8 08             	shr    $0x8,%eax
80109930:	83 e0 0f             	and    $0xf,%eax
80109933:	01 d0                	add    %edx,%eax
}
80109935:	5d                   	pop    %ebp
80109936:	c3                   	ret

80109937 <N2H_uint>:

uint N2H_uint(uint value){
80109937:	55                   	push   %ebp
80109938:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010993a:	8b 45 08             	mov    0x8(%ebp),%eax
8010993d:	c1 e0 18             	shl    $0x18,%eax
80109940:	89 c2                	mov    %eax,%edx
80109942:	8b 45 08             	mov    0x8(%ebp),%eax
80109945:	c1 e0 08             	shl    $0x8,%eax
80109948:	25 00 00 ff 00       	and    $0xff0000,%eax
8010994d:	01 c2                	add    %eax,%edx
8010994f:	8b 45 08             	mov    0x8(%ebp),%eax
80109952:	c1 e8 08             	shr    $0x8,%eax
80109955:	25 00 ff 00 00       	and    $0xff00,%eax
8010995a:	01 c2                	add    %eax,%edx
8010995c:	8b 45 08             	mov    0x8(%ebp),%eax
8010995f:	c1 e8 18             	shr    $0x18,%eax
80109962:	01 d0                	add    %edx,%eax
}
80109964:	5d                   	pop    %ebp
80109965:	c3                   	ret

80109966 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109966:	55                   	push   %ebp
80109967:	89 e5                	mov    %esp,%ebp
80109969:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010996c:	8b 45 08             	mov    0x8(%ebp),%eax
8010996f:	83 c0 0e             	add    $0xe,%eax
80109972:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109978:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010997c:	0f b7 d0             	movzwl %ax,%edx
8010997f:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109984:	39 c2                	cmp    %eax,%edx
80109986:	74 60                	je     801099e8 <ipv4_proc+0x82>
80109988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010998b:	83 c0 0c             	add    $0xc,%eax
8010998e:	83 ec 04             	sub    $0x4,%esp
80109991:	6a 04                	push   $0x4
80109993:	50                   	push   %eax
80109994:	68 04 f5 10 80       	push   $0x8010f504
80109999:	e8 c8 b4 ff ff       	call   80104e66 <memcmp>
8010999e:	83 c4 10             	add    $0x10,%esp
801099a1:	85 c0                	test   %eax,%eax
801099a3:	74 43                	je     801099e8 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801099a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099ac:	0f b7 c0             	movzwl %ax,%eax
801099af:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801099b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b7:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099bb:	3c 01                	cmp    $0x1,%al
801099bd:	75 10                	jne    801099cf <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801099bf:	83 ec 0c             	sub    $0xc,%esp
801099c2:	ff 75 08             	push   0x8(%ebp)
801099c5:	e8 a3 00 00 00       	call   80109a6d <icmp_proc>
801099ca:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801099cd:	eb 19                	jmp    801099e8 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801099cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d2:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099d6:	3c 06                	cmp    $0x6,%al
801099d8:	75 0e                	jne    801099e8 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801099da:	83 ec 0c             	sub    $0xc,%esp
801099dd:	ff 75 08             	push   0x8(%ebp)
801099e0:	e8 b3 03 00 00       	call   80109d98 <tcp_proc>
801099e5:	83 c4 10             	add    $0x10,%esp
}
801099e8:	90                   	nop
801099e9:	c9                   	leave
801099ea:	c3                   	ret

801099eb <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801099eb:	55                   	push   %ebp
801099ec:	89 e5                	mov    %esp,%ebp
801099ee:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801099f1:	8b 45 08             	mov    0x8(%ebp),%eax
801099f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801099f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099fa:	0f b6 00             	movzbl (%eax),%eax
801099fd:	83 e0 0f             	and    $0xf,%eax
80109a00:	01 c0                	add    %eax,%eax
80109a02:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109a05:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a0c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109a13:	eb 48                	jmp    80109a5d <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109a15:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a18:	01 c0                	add    %eax,%eax
80109a1a:	89 c2                	mov    %eax,%edx
80109a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1f:	01 d0                	add    %edx,%eax
80109a21:	0f b6 00             	movzbl (%eax),%eax
80109a24:	0f b6 c0             	movzbl %al,%eax
80109a27:	c1 e0 08             	shl    $0x8,%eax
80109a2a:	89 c2                	mov    %eax,%edx
80109a2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a2f:	01 c0                	add    %eax,%eax
80109a31:	8d 48 01             	lea    0x1(%eax),%ecx
80109a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a37:	01 c8                	add    %ecx,%eax
80109a39:	0f b6 00             	movzbl (%eax),%eax
80109a3c:	0f b6 c0             	movzbl %al,%eax
80109a3f:	01 d0                	add    %edx,%eax
80109a41:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a44:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a4b:	76 0c                	jbe    80109a59 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a50:	0f b7 c0             	movzwl %ax,%eax
80109a53:	83 c0 01             	add    $0x1,%eax
80109a56:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a59:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a5d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109a61:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109a64:	7c af                	jl     80109a15 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a69:	f7 d0                	not    %eax
}
80109a6b:	c9                   	leave
80109a6c:	c3                   	ret

80109a6d <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109a6d:	55                   	push   %ebp
80109a6e:	89 e5                	mov    %esp,%ebp
80109a70:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109a73:	8b 45 08             	mov    0x8(%ebp),%eax
80109a76:	83 c0 0e             	add    $0xe,%eax
80109a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7f:	0f b6 00             	movzbl (%eax),%eax
80109a82:	0f b6 c0             	movzbl %al,%eax
80109a85:	83 e0 0f             	and    $0xf,%eax
80109a88:	c1 e0 02             	shl    $0x2,%eax
80109a8b:	89 c2                	mov    %eax,%edx
80109a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a90:	01 d0                	add    %edx,%eax
80109a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a98:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109a9c:	84 c0                	test   %al,%al
80109a9e:	75 4f                	jne    80109aef <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa3:	0f b6 00             	movzbl (%eax),%eax
80109aa6:	3c 08                	cmp    $0x8,%al
80109aa8:	75 45                	jne    80109aef <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109aaa:	e8 f9 8c ff ff       	call   801027a8 <kalloc>
80109aaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ab2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109ab9:	83 ec 04             	sub    $0x4,%esp
80109abc:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109abf:	50                   	push   %eax
80109ac0:	ff 75 ec             	push   -0x14(%ebp)
80109ac3:	ff 75 08             	push   0x8(%ebp)
80109ac6:	e8 78 00 00 00       	call   80109b43 <icmp_reply_pkt_create>
80109acb:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109ace:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ad1:	83 ec 08             	sub    $0x8,%esp
80109ad4:	50                   	push   %eax
80109ad5:	ff 75 ec             	push   -0x14(%ebp)
80109ad8:	e8 ad f4 ff ff       	call   80108f8a <i8254_send>
80109add:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ae3:	83 ec 0c             	sub    $0xc,%esp
80109ae6:	50                   	push   %eax
80109ae7:	e8 22 8c ff ff       	call   8010270e <kfree>
80109aec:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109aef:	90                   	nop
80109af0:	c9                   	leave
80109af1:	c3                   	ret

80109af2 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109af2:	55                   	push   %ebp
80109af3:	89 e5                	mov    %esp,%ebp
80109af5:	53                   	push   %ebx
80109af6:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109af9:	8b 45 08             	mov    0x8(%ebp),%eax
80109afc:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b00:	0f b7 c0             	movzwl %ax,%eax
80109b03:	83 ec 0c             	sub    $0xc,%esp
80109b06:	50                   	push   %eax
80109b07:	e8 d3 fd ff ff       	call   801098df <N2H_ushort>
80109b0c:	83 c4 10             	add    $0x10,%esp
80109b0f:	0f b7 d8             	movzwl %ax,%ebx
80109b12:	8b 45 08             	mov    0x8(%ebp),%eax
80109b15:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b19:	0f b7 c0             	movzwl %ax,%eax
80109b1c:	83 ec 0c             	sub    $0xc,%esp
80109b1f:	50                   	push   %eax
80109b20:	e8 ba fd ff ff       	call   801098df <N2H_ushort>
80109b25:	83 c4 10             	add    $0x10,%esp
80109b28:	0f b7 c0             	movzwl %ax,%eax
80109b2b:	83 ec 04             	sub    $0x4,%esp
80109b2e:	53                   	push   %ebx
80109b2f:	50                   	push   %eax
80109b30:	68 83 c4 10 80       	push   $0x8010c483
80109b35:	e8 ba 68 ff ff       	call   801003f4 <cprintf>
80109b3a:	83 c4 10             	add    $0x10,%esp
}
80109b3d:	90                   	nop
80109b3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b41:	c9                   	leave
80109b42:	c3                   	ret

80109b43 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b43:	55                   	push   %ebp
80109b44:	89 e5                	mov    %esp,%ebp
80109b46:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b49:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80109b52:	83 c0 0e             	add    $0xe,%eax
80109b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b5b:	0f b6 00             	movzbl (%eax),%eax
80109b5e:	0f b6 c0             	movzbl %al,%eax
80109b61:	83 e0 0f             	and    $0xf,%eax
80109b64:	c1 e0 02             	shl    $0x2,%eax
80109b67:	89 c2                	mov    %eax,%edx
80109b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b6c:	01 d0                	add    %edx,%eax
80109b6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b71:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b74:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b77:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b7a:	83 c0 0e             	add    $0xe,%eax
80109b7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109b80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b83:	83 c0 14             	add    $0x14,%eax
80109b86:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109b89:	8b 45 10             	mov    0x10(%ebp),%eax
80109b8c:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b95:	8d 50 06             	lea    0x6(%eax),%edx
80109b98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b9b:	83 ec 04             	sub    $0x4,%esp
80109b9e:	6a 06                	push   $0x6
80109ba0:	52                   	push   %edx
80109ba1:	50                   	push   %eax
80109ba2:	e8 17 b3 ff ff       	call   80104ebe <memmove>
80109ba7:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109baa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bad:	83 c0 06             	add    $0x6,%eax
80109bb0:	83 ec 04             	sub    $0x4,%esp
80109bb3:	6a 06                	push   $0x6
80109bb5:	68 90 77 19 80       	push   $0x80197790
80109bba:	50                   	push   %eax
80109bbb:	e8 fe b2 ff ff       	call   80104ebe <memmove>
80109bc0:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109bc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bc6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109bca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bcd:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd4:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109bd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bda:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109bde:	83 ec 0c             	sub    $0xc,%esp
80109be1:	6a 54                	push   $0x54
80109be3:	e8 0e fd ff ff       	call   801098f6 <H2N_ushort>
80109be8:	83 c4 10             	add    $0x10,%esp
80109beb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bee:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109bf2:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
80109bf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bfc:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c00:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
80109c07:	83 c0 01             	add    $0x1,%eax
80109c0a:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109c10:	83 ec 0c             	sub    $0xc,%esp
80109c13:	68 00 40 00 00       	push   $0x4000
80109c18:	e8 d9 fc ff ff       	call   801098f6 <H2N_ushort>
80109c1d:	83 c4 10             	add    $0x10,%esp
80109c20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c23:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109c27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2a:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c31:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c38:	83 c0 0c             	add    $0xc,%eax
80109c3b:	83 ec 04             	sub    $0x4,%esp
80109c3e:	6a 04                	push   $0x4
80109c40:	68 04 f5 10 80       	push   $0x8010f504
80109c45:	50                   	push   %eax
80109c46:	e8 73 b2 ff ff       	call   80104ebe <memmove>
80109c4b:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c51:	8d 50 0c             	lea    0xc(%eax),%edx
80109c54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c57:	83 c0 10             	add    $0x10,%eax
80109c5a:	83 ec 04             	sub    $0x4,%esp
80109c5d:	6a 04                	push   $0x4
80109c5f:	52                   	push   %edx
80109c60:	50                   	push   %eax
80109c61:	e8 58 b2 ff ff       	call   80104ebe <memmove>
80109c66:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c6c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c75:	83 ec 0c             	sub    $0xc,%esp
80109c78:	50                   	push   %eax
80109c79:	e8 6d fd ff ff       	call   801099eb <ipv4_chksum>
80109c7e:	83 c4 10             	add    $0x10,%esp
80109c81:	0f b7 c0             	movzwl %ax,%eax
80109c84:	83 ec 0c             	sub    $0xc,%esp
80109c87:	50                   	push   %eax
80109c88:	e8 69 fc ff ff       	call   801098f6 <H2N_ushort>
80109c8d:	83 c4 10             	add    $0x10,%esp
80109c90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c93:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c9a:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ca0:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ca4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ca7:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cae:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109cb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cb5:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109cb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cbc:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109cc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cc3:	8d 50 08             	lea    0x8(%eax),%edx
80109cc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cc9:	83 c0 08             	add    $0x8,%eax
80109ccc:	83 ec 04             	sub    $0x4,%esp
80109ccf:	6a 08                	push   $0x8
80109cd1:	52                   	push   %edx
80109cd2:	50                   	push   %eax
80109cd3:	e8 e6 b1 ff ff       	call   80104ebe <memmove>
80109cd8:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cde:	8d 50 10             	lea    0x10(%eax),%edx
80109ce1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ce4:	83 c0 10             	add    $0x10,%eax
80109ce7:	83 ec 04             	sub    $0x4,%esp
80109cea:	6a 30                	push   $0x30
80109cec:	52                   	push   %edx
80109ced:	50                   	push   %eax
80109cee:	e8 cb b1 ff ff       	call   80104ebe <memmove>
80109cf3:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109cf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cf9:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109cff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d02:	83 ec 0c             	sub    $0xc,%esp
80109d05:	50                   	push   %eax
80109d06:	e8 1c 00 00 00       	call   80109d27 <icmp_chksum>
80109d0b:	83 c4 10             	add    $0x10,%esp
80109d0e:	0f b7 c0             	movzwl %ax,%eax
80109d11:	83 ec 0c             	sub    $0xc,%esp
80109d14:	50                   	push   %eax
80109d15:	e8 dc fb ff ff       	call   801098f6 <H2N_ushort>
80109d1a:	83 c4 10             	add    $0x10,%esp
80109d1d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d20:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109d24:	90                   	nop
80109d25:	c9                   	leave
80109d26:	c3                   	ret

80109d27 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109d27:	55                   	push   %ebp
80109d28:	89 e5                	mov    %esp,%ebp
80109d2a:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109d33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d3a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d41:	eb 48                	jmp    80109d8b <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d46:	01 c0                	add    %eax,%eax
80109d48:	89 c2                	mov    %eax,%edx
80109d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d4d:	01 d0                	add    %edx,%eax
80109d4f:	0f b6 00             	movzbl (%eax),%eax
80109d52:	0f b6 c0             	movzbl %al,%eax
80109d55:	c1 e0 08             	shl    $0x8,%eax
80109d58:	89 c2                	mov    %eax,%edx
80109d5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d5d:	01 c0                	add    %eax,%eax
80109d5f:	8d 48 01             	lea    0x1(%eax),%ecx
80109d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d65:	01 c8                	add    %ecx,%eax
80109d67:	0f b6 00             	movzbl (%eax),%eax
80109d6a:	0f b6 c0             	movzbl %al,%eax
80109d6d:	01 d0                	add    %edx,%eax
80109d6f:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d72:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d79:	76 0c                	jbe    80109d87 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d7e:	0f b7 c0             	movzwl %ax,%eax
80109d81:	83 c0 01             	add    $0x1,%eax
80109d84:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d87:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d8b:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109d8f:	7e b2                	jle    80109d43 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109d91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d94:	f7 d0                	not    %eax
}
80109d96:	c9                   	leave
80109d97:	c3                   	ret

80109d98 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109d98:	55                   	push   %ebp
80109d99:	89 e5                	mov    %esp,%ebp
80109d9b:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80109da1:	83 c0 0e             	add    $0xe,%eax
80109da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109daa:	0f b6 00             	movzbl (%eax),%eax
80109dad:	0f b6 c0             	movzbl %al,%eax
80109db0:	83 e0 0f             	and    $0xf,%eax
80109db3:	c1 e0 02             	shl    $0x2,%eax
80109db6:	89 c2                	mov    %eax,%edx
80109db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dbb:	01 d0                	add    %edx,%eax
80109dbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc3:	83 c0 14             	add    $0x14,%eax
80109dc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109dc9:	e8 da 89 ff ff       	call   801027a8 <kalloc>
80109dce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109dd1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ddb:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ddf:	0f b6 c0             	movzbl %al,%eax
80109de2:	83 e0 02             	and    $0x2,%eax
80109de5:	85 c0                	test   %eax,%eax
80109de7:	74 3d                	je     80109e26 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109de9:	83 ec 0c             	sub    $0xc,%esp
80109dec:	6a 00                	push   $0x0
80109dee:	6a 12                	push   $0x12
80109df0:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109df3:	50                   	push   %eax
80109df4:	ff 75 e8             	push   -0x18(%ebp)
80109df7:	ff 75 08             	push   0x8(%ebp)
80109dfa:	e8 a2 01 00 00       	call   80109fa1 <tcp_pkt_create>
80109dff:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109e02:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e05:	83 ec 08             	sub    $0x8,%esp
80109e08:	50                   	push   %eax
80109e09:	ff 75 e8             	push   -0x18(%ebp)
80109e0c:	e8 79 f1 ff ff       	call   80108f8a <i8254_send>
80109e11:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e14:	a1 64 7a 19 80       	mov    0x80197a64,%eax
80109e19:	83 c0 01             	add    $0x1,%eax
80109e1c:	a3 64 7a 19 80       	mov    %eax,0x80197a64
80109e21:	e9 69 01 00 00       	jmp    80109f8f <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e29:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e2d:	3c 18                	cmp    $0x18,%al
80109e2f:	0f 85 10 01 00 00    	jne    80109f45 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109e35:	83 ec 04             	sub    $0x4,%esp
80109e38:	6a 03                	push   $0x3
80109e3a:	68 9e c4 10 80       	push   $0x8010c49e
80109e3f:	ff 75 ec             	push   -0x14(%ebp)
80109e42:	e8 1f b0 ff ff       	call   80104e66 <memcmp>
80109e47:	83 c4 10             	add    $0x10,%esp
80109e4a:	85 c0                	test   %eax,%eax
80109e4c:	74 74                	je     80109ec2 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109e4e:	83 ec 0c             	sub    $0xc,%esp
80109e51:	68 a2 c4 10 80       	push   $0x8010c4a2
80109e56:	e8 99 65 ff ff       	call   801003f4 <cprintf>
80109e5b:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e5e:	83 ec 0c             	sub    $0xc,%esp
80109e61:	6a 00                	push   $0x0
80109e63:	6a 10                	push   $0x10
80109e65:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e68:	50                   	push   %eax
80109e69:	ff 75 e8             	push   -0x18(%ebp)
80109e6c:	ff 75 08             	push   0x8(%ebp)
80109e6f:	e8 2d 01 00 00       	call   80109fa1 <tcp_pkt_create>
80109e74:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e7a:	83 ec 08             	sub    $0x8,%esp
80109e7d:	50                   	push   %eax
80109e7e:	ff 75 e8             	push   -0x18(%ebp)
80109e81:	e8 04 f1 ff ff       	call   80108f8a <i8254_send>
80109e86:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e8c:	83 c0 36             	add    $0x36,%eax
80109e8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109e92:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109e95:	50                   	push   %eax
80109e96:	ff 75 e0             	push   -0x20(%ebp)
80109e99:	6a 00                	push   $0x0
80109e9b:	6a 00                	push   $0x0
80109e9d:	e8 5a 04 00 00       	call   8010a2fc <http_proc>
80109ea2:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ea5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ea8:	83 ec 0c             	sub    $0xc,%esp
80109eab:	50                   	push   %eax
80109eac:	6a 18                	push   $0x18
80109eae:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eb1:	50                   	push   %eax
80109eb2:	ff 75 e8             	push   -0x18(%ebp)
80109eb5:	ff 75 08             	push   0x8(%ebp)
80109eb8:	e8 e4 00 00 00       	call   80109fa1 <tcp_pkt_create>
80109ebd:	83 c4 20             	add    $0x20,%esp
80109ec0:	eb 62                	jmp    80109f24 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ec2:	83 ec 0c             	sub    $0xc,%esp
80109ec5:	6a 00                	push   $0x0
80109ec7:	6a 10                	push   $0x10
80109ec9:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ecc:	50                   	push   %eax
80109ecd:	ff 75 e8             	push   -0x18(%ebp)
80109ed0:	ff 75 08             	push   0x8(%ebp)
80109ed3:	e8 c9 00 00 00       	call   80109fa1 <tcp_pkt_create>
80109ed8:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109edb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ede:	83 ec 08             	sub    $0x8,%esp
80109ee1:	50                   	push   %eax
80109ee2:	ff 75 e8             	push   -0x18(%ebp)
80109ee5:	e8 a0 f0 ff ff       	call   80108f8a <i8254_send>
80109eea:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ef0:	83 c0 36             	add    $0x36,%eax
80109ef3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ef6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109ef9:	50                   	push   %eax
80109efa:	ff 75 e4             	push   -0x1c(%ebp)
80109efd:	6a 00                	push   $0x0
80109eff:	6a 00                	push   $0x0
80109f01:	e8 f6 03 00 00       	call   8010a2fc <http_proc>
80109f06:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109f0c:	83 ec 0c             	sub    $0xc,%esp
80109f0f:	50                   	push   %eax
80109f10:	6a 18                	push   $0x18
80109f12:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f15:	50                   	push   %eax
80109f16:	ff 75 e8             	push   -0x18(%ebp)
80109f19:	ff 75 08             	push   0x8(%ebp)
80109f1c:	e8 80 00 00 00       	call   80109fa1 <tcp_pkt_create>
80109f21:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109f24:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f27:	83 ec 08             	sub    $0x8,%esp
80109f2a:	50                   	push   %eax
80109f2b:	ff 75 e8             	push   -0x18(%ebp)
80109f2e:	e8 57 f0 ff ff       	call   80108f8a <i8254_send>
80109f33:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f36:	a1 64 7a 19 80       	mov    0x80197a64,%eax
80109f3b:	83 c0 01             	add    $0x1,%eax
80109f3e:	a3 64 7a 19 80       	mov    %eax,0x80197a64
80109f43:	eb 4a                	jmp    80109f8f <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f48:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f4c:	3c 10                	cmp    $0x10,%al
80109f4e:	75 3f                	jne    80109f8f <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109f50:	a1 68 7a 19 80       	mov    0x80197a68,%eax
80109f55:	83 f8 01             	cmp    $0x1,%eax
80109f58:	75 35                	jne    80109f8f <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f5a:	83 ec 0c             	sub    $0xc,%esp
80109f5d:	6a 00                	push   $0x0
80109f5f:	6a 01                	push   $0x1
80109f61:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f64:	50                   	push   %eax
80109f65:	ff 75 e8             	push   -0x18(%ebp)
80109f68:	ff 75 08             	push   0x8(%ebp)
80109f6b:	e8 31 00 00 00       	call   80109fa1 <tcp_pkt_create>
80109f70:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f76:	83 ec 08             	sub    $0x8,%esp
80109f79:	50                   	push   %eax
80109f7a:	ff 75 e8             	push   -0x18(%ebp)
80109f7d:	e8 08 f0 ff ff       	call   80108f8a <i8254_send>
80109f82:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109f85:	c7 05 68 7a 19 80 00 	movl   $0x0,0x80197a68
80109f8c:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109f8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f92:	83 ec 0c             	sub    $0xc,%esp
80109f95:	50                   	push   %eax
80109f96:	e8 73 87 ff ff       	call   8010270e <kfree>
80109f9b:	83 c4 10             	add    $0x10,%esp
}
80109f9e:	90                   	nop
80109f9f:	c9                   	leave
80109fa0:	c3                   	ret

80109fa1 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109fa1:	55                   	push   %ebp
80109fa2:	89 e5                	mov    %esp,%ebp
80109fa4:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80109faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109fad:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb0:	83 c0 0e             	add    $0xe,%eax
80109fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fb9:	0f b6 00             	movzbl (%eax),%eax
80109fbc:	0f b6 c0             	movzbl %al,%eax
80109fbf:	83 e0 0f             	and    $0xf,%eax
80109fc2:	c1 e0 02             	shl    $0x2,%eax
80109fc5:	89 c2                	mov    %eax,%edx
80109fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fca:	01 d0                	add    %edx,%eax
80109fcc:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fd2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fd8:	83 c0 0e             	add    $0xe,%eax
80109fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fe1:	83 c0 14             	add    $0x14,%eax
80109fe4:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109fe7:	8b 45 18             	mov    0x18(%ebp),%eax
80109fea:	8d 50 36             	lea    0x36(%eax),%edx
80109fed:	8b 45 10             	mov    0x10(%ebp),%eax
80109ff0:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ff5:	8d 50 06             	lea    0x6(%eax),%edx
80109ff8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ffb:	83 ec 04             	sub    $0x4,%esp
80109ffe:	6a 06                	push   $0x6
8010a000:	52                   	push   %edx
8010a001:	50                   	push   %eax
8010a002:	e8 b7 ae ff ff       	call   80104ebe <memmove>
8010a007:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a00a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a00d:	83 c0 06             	add    $0x6,%eax
8010a010:	83 ec 04             	sub    $0x4,%esp
8010a013:	6a 06                	push   $0x6
8010a015:	68 90 77 19 80       	push   $0x80197790
8010a01a:	50                   	push   %eax
8010a01b:	e8 9e ae ff ff       	call   80104ebe <memmove>
8010a020:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a023:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a026:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a02a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a02d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a031:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a034:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a037:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a03e:	8b 45 18             	mov    0x18(%ebp),%eax
8010a041:	83 c0 28             	add    $0x28,%eax
8010a044:	0f b7 c0             	movzwl %ax,%eax
8010a047:	83 ec 0c             	sub    $0xc,%esp
8010a04a:	50                   	push   %eax
8010a04b:	e8 a6 f8 ff ff       	call   801098f6 <H2N_ushort>
8010a050:	83 c4 10             	add    $0x10,%esp
8010a053:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a056:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a05a:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
8010a061:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a064:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a068:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
8010a06f:	83 c0 01             	add    $0x1,%eax
8010a072:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a078:	83 ec 0c             	sub    $0xc,%esp
8010a07b:	6a 00                	push   $0x0
8010a07d:	e8 74 f8 ff ff       	call   801098f6 <H2N_ushort>
8010a082:	83 c4 10             	add    $0x10,%esp
8010a085:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a088:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a08c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a08f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a093:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a096:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a09a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a09d:	83 c0 0c             	add    $0xc,%eax
8010a0a0:	83 ec 04             	sub    $0x4,%esp
8010a0a3:	6a 04                	push   $0x4
8010a0a5:	68 04 f5 10 80       	push   $0x8010f504
8010a0aa:	50                   	push   %eax
8010a0ab:	e8 0e ae ff ff       	call   80104ebe <memmove>
8010a0b0:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b6:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0bc:	83 c0 10             	add    $0x10,%eax
8010a0bf:	83 ec 04             	sub    $0x4,%esp
8010a0c2:	6a 04                	push   $0x4
8010a0c4:	52                   	push   %edx
8010a0c5:	50                   	push   %eax
8010a0c6:	e8 f3 ad ff ff       	call   80104ebe <memmove>
8010a0cb:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0da:	83 ec 0c             	sub    $0xc,%esp
8010a0dd:	50                   	push   %eax
8010a0de:	e8 08 f9 ff ff       	call   801099eb <ipv4_chksum>
8010a0e3:	83 c4 10             	add    $0x10,%esp
8010a0e6:	0f b7 c0             	movzwl %ax,%eax
8010a0e9:	83 ec 0c             	sub    $0xc,%esp
8010a0ec:	50                   	push   %eax
8010a0ed:	e8 04 f8 ff ff       	call   801098f6 <H2N_ushort>
8010a0f2:	83 c4 10             	add    $0x10,%esp
8010a0f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0f8:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a0fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0ff:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a103:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a106:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a109:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a10c:	0f b7 10             	movzwl (%eax),%edx
8010a10f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a112:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a116:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a11b:	83 ec 0c             	sub    $0xc,%esp
8010a11e:	50                   	push   %eax
8010a11f:	e8 e9 f7 ff ff       	call   8010990d <H2N_uint>
8010a124:	83 c4 10             	add    $0x10,%esp
8010a127:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a12a:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a12d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a130:	8b 40 04             	mov    0x4(%eax),%eax
8010a133:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a139:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a13c:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a13f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a142:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a146:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a149:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a14d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a150:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a154:	8b 45 14             	mov    0x14(%ebp),%eax
8010a157:	89 c2                	mov    %eax,%edx
8010a159:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a15c:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a15f:	83 ec 0c             	sub    $0xc,%esp
8010a162:	68 90 38 00 00       	push   $0x3890
8010a167:	e8 8a f7 ff ff       	call   801098f6 <H2N_ushort>
8010a16c:	83 c4 10             	add    $0x10,%esp
8010a16f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a172:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a176:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a179:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a17f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a182:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18b:	83 ec 0c             	sub    $0xc,%esp
8010a18e:	50                   	push   %eax
8010a18f:	e8 1f 00 00 00       	call   8010a1b3 <tcp_chksum>
8010a194:	83 c4 10             	add    $0x10,%esp
8010a197:	83 c0 08             	add    $0x8,%eax
8010a19a:	0f b7 c0             	movzwl %ax,%eax
8010a19d:	83 ec 0c             	sub    $0xc,%esp
8010a1a0:	50                   	push   %eax
8010a1a1:	e8 50 f7 ff ff       	call   801098f6 <H2N_ushort>
8010a1a6:	83 c4 10             	add    $0x10,%esp
8010a1a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1ac:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a1b0:	90                   	nop
8010a1b1:	c9                   	leave
8010a1b2:	c3                   	ret

8010a1b3 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a1b3:	55                   	push   %ebp
8010a1b4:	89 e5                	mov    %esp,%ebp
8010a1b6:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a1b9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a1bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c2:	83 c0 14             	add    $0x14,%eax
8010a1c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a1c8:	83 ec 04             	sub    $0x4,%esp
8010a1cb:	6a 04                	push   $0x4
8010a1cd:	68 04 f5 10 80       	push   $0x8010f504
8010a1d2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1d5:	50                   	push   %eax
8010a1d6:	e8 e3 ac ff ff       	call   80104ebe <memmove>
8010a1db:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a1de:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1e1:	83 c0 0c             	add    $0xc,%eax
8010a1e4:	83 ec 04             	sub    $0x4,%esp
8010a1e7:	6a 04                	push   $0x4
8010a1e9:	50                   	push   %eax
8010a1ea:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1ed:	83 c0 04             	add    $0x4,%eax
8010a1f0:	50                   	push   %eax
8010a1f1:	e8 c8 ac ff ff       	call   80104ebe <memmove>
8010a1f6:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a1f9:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a1fd:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a201:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a204:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a208:	0f b7 c0             	movzwl %ax,%eax
8010a20b:	83 ec 0c             	sub    $0xc,%esp
8010a20e:	50                   	push   %eax
8010a20f:	e8 cb f6 ff ff       	call   801098df <N2H_ushort>
8010a214:	83 c4 10             	add    $0x10,%esp
8010a217:	83 e8 14             	sub    $0x14,%eax
8010a21a:	0f b7 c0             	movzwl %ax,%eax
8010a21d:	83 ec 0c             	sub    $0xc,%esp
8010a220:	50                   	push   %eax
8010a221:	e8 d0 f6 ff ff       	call   801098f6 <H2N_ushort>
8010a226:	83 c4 10             	add    $0x10,%esp
8010a229:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a22d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a234:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a23a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a241:	eb 33                	jmp    8010a276 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a243:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a246:	01 c0                	add    %eax,%eax
8010a248:	89 c2                	mov    %eax,%edx
8010a24a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a24d:	01 d0                	add    %edx,%eax
8010a24f:	0f b6 00             	movzbl (%eax),%eax
8010a252:	0f b6 c0             	movzbl %al,%eax
8010a255:	c1 e0 08             	shl    $0x8,%eax
8010a258:	89 c2                	mov    %eax,%edx
8010a25a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a25d:	01 c0                	add    %eax,%eax
8010a25f:	8d 48 01             	lea    0x1(%eax),%ecx
8010a262:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a265:	01 c8                	add    %ecx,%eax
8010a267:	0f b6 00             	movzbl (%eax),%eax
8010a26a:	0f b6 c0             	movzbl %al,%eax
8010a26d:	01 d0                	add    %edx,%eax
8010a26f:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a272:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a276:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a27a:	7e c7                	jle    8010a243 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a27c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a27f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a282:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a289:	eb 33                	jmp    8010a2be <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a28b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a28e:	01 c0                	add    %eax,%eax
8010a290:	89 c2                	mov    %eax,%edx
8010a292:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a295:	01 d0                	add    %edx,%eax
8010a297:	0f b6 00             	movzbl (%eax),%eax
8010a29a:	0f b6 c0             	movzbl %al,%eax
8010a29d:	c1 e0 08             	shl    $0x8,%eax
8010a2a0:	89 c2                	mov    %eax,%edx
8010a2a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2a5:	01 c0                	add    %eax,%eax
8010a2a7:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2ad:	01 c8                	add    %ecx,%eax
8010a2af:	0f b6 00             	movzbl (%eax),%eax
8010a2b2:	0f b6 c0             	movzbl %al,%eax
8010a2b5:	01 d0                	add    %edx,%eax
8010a2b7:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2ba:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a2be:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a2c2:	0f b7 c0             	movzwl %ax,%eax
8010a2c5:	83 ec 0c             	sub    $0xc,%esp
8010a2c8:	50                   	push   %eax
8010a2c9:	e8 11 f6 ff ff       	call   801098df <N2H_ushort>
8010a2ce:	83 c4 10             	add    $0x10,%esp
8010a2d1:	66 d1 e8             	shr    $1,%ax
8010a2d4:	0f b7 c0             	movzwl %ax,%eax
8010a2d7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a2da:	7c af                	jl     8010a28b <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a2dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2df:	c1 e8 10             	shr    $0x10,%eax
8010a2e2:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a2e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2e8:	f7 d0                	not    %eax
}
8010a2ea:	c9                   	leave
8010a2eb:	c3                   	ret

8010a2ec <tcp_fin>:

void tcp_fin(){
8010a2ec:	55                   	push   %ebp
8010a2ed:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a2ef:	c7 05 68 7a 19 80 01 	movl   $0x1,0x80197a68
8010a2f6:	00 00 00 
}
8010a2f9:	90                   	nop
8010a2fa:	5d                   	pop    %ebp
8010a2fb:	c3                   	ret

8010a2fc <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a2fc:	55                   	push   %ebp
8010a2fd:	89 e5                	mov    %esp,%ebp
8010a2ff:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a302:	8b 45 10             	mov    0x10(%ebp),%eax
8010a305:	83 ec 04             	sub    $0x4,%esp
8010a308:	6a 00                	push   $0x0
8010a30a:	68 ab c4 10 80       	push   $0x8010c4ab
8010a30f:	50                   	push   %eax
8010a310:	e8 65 00 00 00       	call   8010a37a <http_strcpy>
8010a315:	83 c4 10             	add    $0x10,%esp
8010a318:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a31b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a31e:	83 ec 04             	sub    $0x4,%esp
8010a321:	ff 75 f4             	push   -0xc(%ebp)
8010a324:	68 be c4 10 80       	push   $0x8010c4be
8010a329:	50                   	push   %eax
8010a32a:	e8 4b 00 00 00       	call   8010a37a <http_strcpy>
8010a32f:	83 c4 10             	add    $0x10,%esp
8010a332:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a335:	8b 45 10             	mov    0x10(%ebp),%eax
8010a338:	83 ec 04             	sub    $0x4,%esp
8010a33b:	ff 75 f4             	push   -0xc(%ebp)
8010a33e:	68 d9 c4 10 80       	push   $0x8010c4d9
8010a343:	50                   	push   %eax
8010a344:	e8 31 00 00 00       	call   8010a37a <http_strcpy>
8010a349:	83 c4 10             	add    $0x10,%esp
8010a34c:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a34f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a352:	83 e0 01             	and    $0x1,%eax
8010a355:	85 c0                	test   %eax,%eax
8010a357:	74 11                	je     8010a36a <http_proc+0x6e>
    char *payload = (char *)send;
8010a359:	8b 45 10             	mov    0x10(%ebp),%eax
8010a35c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a35f:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a362:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a365:	01 d0                	add    %edx,%eax
8010a367:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a36a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a36d:	8b 45 14             	mov    0x14(%ebp),%eax
8010a370:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a372:	e8 75 ff ff ff       	call   8010a2ec <tcp_fin>
}
8010a377:	90                   	nop
8010a378:	c9                   	leave
8010a379:	c3                   	ret

8010a37a <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a37a:	55                   	push   %ebp
8010a37b:	89 e5                	mov    %esp,%ebp
8010a37d:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a380:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a387:	eb 20                	jmp    8010a3a9 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a389:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a38c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a38f:	01 d0                	add    %edx,%eax
8010a391:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a394:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a397:	01 ca                	add    %ecx,%edx
8010a399:	89 d1                	mov    %edx,%ecx
8010a39b:	8b 55 08             	mov    0x8(%ebp),%edx
8010a39e:	01 ca                	add    %ecx,%edx
8010a3a0:	0f b6 00             	movzbl (%eax),%eax
8010a3a3:	88 02                	mov    %al,(%edx)
    i++;
8010a3a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a3a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3ac:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3af:	01 d0                	add    %edx,%eax
8010a3b1:	0f b6 00             	movzbl (%eax),%eax
8010a3b4:	84 c0                	test   %al,%al
8010a3b6:	75 d1                	jne    8010a389 <http_strcpy+0xf>
  }
  return i;
8010a3b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a3bb:	c9                   	leave
8010a3bc:	c3                   	ret

8010a3bd <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a3bd:	55                   	push   %ebp
8010a3be:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a3c0:	c7 05 70 7a 19 80 c2 	movl   $0x8010f5c2,0x80197a70
8010a3c7:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a3ca:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a3cf:	c1 e8 09             	shr    $0x9,%eax
8010a3d2:	a3 6c 7a 19 80       	mov    %eax,0x80197a6c
}
8010a3d7:	90                   	nop
8010a3d8:	5d                   	pop    %ebp
8010a3d9:	c3                   	ret

8010a3da <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a3da:	55                   	push   %ebp
8010a3db:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a3dd:	90                   	nop
8010a3de:	5d                   	pop    %ebp
8010a3df:	c3                   	ret

8010a3e0 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a3e0:	55                   	push   %ebp
8010a3e1:	89 e5                	mov    %esp,%ebp
8010a3e3:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a3e6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3e9:	83 c0 0c             	add    $0xc,%eax
8010a3ec:	83 ec 0c             	sub    $0xc,%esp
8010a3ef:	50                   	push   %eax
8010a3f0:	e8 03 a7 ff ff       	call   80104af8 <holdingsleep>
8010a3f5:	83 c4 10             	add    $0x10,%esp
8010a3f8:	85 c0                	test   %eax,%eax
8010a3fa:	75 0d                	jne    8010a409 <iderw+0x29>
    panic("iderw: buf not locked");
8010a3fc:	83 ec 0c             	sub    $0xc,%esp
8010a3ff:	68 ea c4 10 80       	push   $0x8010c4ea
8010a404:	e8 a0 61 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a409:	8b 45 08             	mov    0x8(%ebp),%eax
8010a40c:	8b 00                	mov    (%eax),%eax
8010a40e:	83 e0 06             	and    $0x6,%eax
8010a411:	83 f8 02             	cmp    $0x2,%eax
8010a414:	75 0d                	jne    8010a423 <iderw+0x43>
    panic("iderw: nothing to do");
8010a416:	83 ec 0c             	sub    $0xc,%esp
8010a419:	68 00 c5 10 80       	push   $0x8010c500
8010a41e:	e8 86 61 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a423:	8b 45 08             	mov    0x8(%ebp),%eax
8010a426:	8b 40 04             	mov    0x4(%eax),%eax
8010a429:	83 f8 01             	cmp    $0x1,%eax
8010a42c:	74 0d                	je     8010a43b <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a42e:	83 ec 0c             	sub    $0xc,%esp
8010a431:	68 15 c5 10 80       	push   $0x8010c515
8010a436:	e8 6e 61 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a43b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a43e:	8b 40 08             	mov    0x8(%eax),%eax
8010a441:	8b 15 6c 7a 19 80    	mov    0x80197a6c,%edx
8010a447:	39 d0                	cmp    %edx,%eax
8010a449:	72 0d                	jb     8010a458 <iderw+0x78>
    panic("iderw: block out of range");
8010a44b:	83 ec 0c             	sub    $0xc,%esp
8010a44e:	68 33 c5 10 80       	push   $0x8010c533
8010a453:	e8 51 61 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a458:	8b 15 70 7a 19 80    	mov    0x80197a70,%edx
8010a45e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a461:	8b 40 08             	mov    0x8(%eax),%eax
8010a464:	c1 e0 09             	shl    $0x9,%eax
8010a467:	01 d0                	add    %edx,%eax
8010a469:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a46c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a46f:	8b 00                	mov    (%eax),%eax
8010a471:	83 e0 04             	and    $0x4,%eax
8010a474:	85 c0                	test   %eax,%eax
8010a476:	74 2b                	je     8010a4a3 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a478:	8b 45 08             	mov    0x8(%ebp),%eax
8010a47b:	8b 00                	mov    (%eax),%eax
8010a47d:	83 e0 fb             	and    $0xfffffffb,%eax
8010a480:	89 c2                	mov    %eax,%edx
8010a482:	8b 45 08             	mov    0x8(%ebp),%eax
8010a485:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a487:	8b 45 08             	mov    0x8(%ebp),%eax
8010a48a:	83 c0 5c             	add    $0x5c,%eax
8010a48d:	83 ec 04             	sub    $0x4,%esp
8010a490:	68 00 02 00 00       	push   $0x200
8010a495:	50                   	push   %eax
8010a496:	ff 75 f4             	push   -0xc(%ebp)
8010a499:	e8 20 aa ff ff       	call   80104ebe <memmove>
8010a49e:	83 c4 10             	add    $0x10,%esp
8010a4a1:	eb 1a                	jmp    8010a4bd <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a4a3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4a6:	83 c0 5c             	add    $0x5c,%eax
8010a4a9:	83 ec 04             	sub    $0x4,%esp
8010a4ac:	68 00 02 00 00       	push   $0x200
8010a4b1:	ff 75 f4             	push   -0xc(%ebp)
8010a4b4:	50                   	push   %eax
8010a4b5:	e8 04 aa ff ff       	call   80104ebe <memmove>
8010a4ba:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a4bd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4c0:	8b 00                	mov    (%eax),%eax
8010a4c2:	83 c8 02             	or     $0x2,%eax
8010a4c5:	89 c2                	mov    %eax,%edx
8010a4c7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ca:	89 10                	mov    %edx,(%eax)
}
8010a4cc:	90                   	nop
8010a4cd:	c9                   	leave
8010a4ce:	c3                   	ret
