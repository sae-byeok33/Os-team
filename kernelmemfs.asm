
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
8010006f:	68 00 a5 10 80       	push   $0x8010a500
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 fa 4a 00 00       	call   80104b78 <initlock>
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
801000bd:	68 07 a5 10 80       	push   $0x8010a507
801000c2:	50                   	push   %eax
801000c3:	e8 53 49 00 00       	call   80104a1b <initsleeplock>
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
80100101:	e8 94 4a 00 00       	call   80104b9a <acquire>
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
80100140:	e8 c3 4a 00 00       	call   80104c08 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 00 49 00 00       	call   80104a57 <acquiresleep>
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
801001c1:	e8 42 4a 00 00       	call   80104c08 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 7f 48 00 00       	call   80104a57 <acquiresleep>
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
801001f5:	68 0e a5 10 80       	push   $0x8010a50e
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
8010022d:	e8 d1 a1 00 00       	call   8010a403 <iderw>
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
8010024a:	e8 ba 48 00 00       	call   80104b09 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f a5 10 80       	push   $0x8010a51f
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
80100278:	e8 86 a1 00 00       	call   8010a403 <iderw>
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
80100293:	e8 71 48 00 00       	call   80104b09 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 a5 10 80       	push   $0x8010a526
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 00 48 00 00       	call   80104abb <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 cf 48 00 00       	call   80104b9a <acquire>
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
80100336:	e8 cd 48 00 00       	call   80104c08 <release>
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
80100410:	e8 85 47 00 00       	call   80104b9a <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d a5 10 80       	push   $0x8010a52d
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
80100510:	c7 45 ec 36 a5 10 80 	movl   $0x8010a536,-0x14(%ebp)
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
8010059e:	e8 65 46 00 00       	call   80104c08 <release>
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
801005c7:	68 3d a5 10 80       	push   $0x8010a53d
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
801005e6:	68 51 a5 10 80       	push   $0x8010a551
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 57 46 00 00       	call   80104c5a <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 a5 10 80       	push   $0x8010a553
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
801006a1:	e8 ca 7c 00 00       	call   80108370 <graphic_scroll_up>
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
801006f4:	e8 77 7c 00 00       	call   80108370 <graphic_scroll_up>
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
80100756:	e8 82 7c 00 00       	call   801083dd <font_render>
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
80100793:	e8 51 60 00 00       	call   801067e9 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 44 60 00 00       	call   801067e9 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 37 60 00 00       	call   801067e9 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 27 60 00 00       	call   801067e9 <uartputc>
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
801007eb:	e8 aa 43 00 00       	call   80104b9a <acquire>
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
8010093f:	e8 26 3c 00 00       	call   8010456a <wakeup>
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
8010096a:	e8 99 42 00 00       	call   80104c08 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 ab 3c 00 00       	call   80104628 <procdump>
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
801009a2:	e8 f3 41 00 00       	call   80104b9a <acquire>
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
801009c3:	e8 40 42 00 00       	call   80104c08 <release>
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
801009f0:	e8 8b 3a 00 00       	call   80104480 <sleep>
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
80100a6e:	e8 95 41 00 00       	call   80104c08 <release>
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
80100aac:	e8 e9 40 00 00       	call   80104b9a <acquire>
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
80100aee:	e8 15 41 00 00       	call   80104c08 <release>
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
80100b1c:	68 57 a5 10 80       	push   $0x8010a557
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 4d 40 00 00       	call   80104b78 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 5f a5 10 80 	movl   $0x8010a55f,-0xc(%ebp)
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
80100bbf:	68 75 a5 10 80       	push   $0x8010a575
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
80100c1b:	e8 c5 6b 00 00       	call   801077e5 <setupkvm>
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
80100cc1:	e8 19 6f 00 00       	call   80107bdf <allocuvm>
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
80100d07:	e8 06 6e 00 00       	call   80107b12 <loaduvm>
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
80100d76:	e8 64 6e 00 00       	call   80107bdf <allocuvm>
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
80100d9a:	e8 a2 70 00 00       	call   80107e41 <clearpteu>
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
80100dd3:	e8 86 42 00 00       	call   8010505e <strlen>
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
80100e00:	e8 59 42 00 00       	call   8010505e <strlen>
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
80100e26:	e8 b5 71 00 00       	call   80107fe0 <copyout>
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
80100ec2:	e8 19 71 00 00       	call   80107fe0 <copyout>
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
80100f10:	e8 fe 40 00 00       	call   80105013 <safestrcpy>
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
80100f53:	e8 ab 69 00 00       	call   80107903 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 42 6e 00 00       	call   80107da8 <freevm>
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
80100fa1:	e8 02 6e 00 00       	call   80107da8 <freevm>
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
80100fd2:	68 81 a5 10 80       	push   $0x8010a581
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 97 3b 00 00       	call   80104b78 <initlock>
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
80100ff5:	e8 a0 3b 00 00       	call   80104b9a <acquire>
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
80101022:	e8 e1 3b 00 00       	call   80104c08 <release>
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
80101045:	e8 be 3b 00 00       	call   80104c08 <release>
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
80101062:	e8 33 3b 00 00       	call   80104b9a <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 88 a5 10 80       	push   $0x8010a588
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
80101098:	e8 6b 3b 00 00       	call   80104c08 <release>
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
801010b3:	e8 e2 3a 00 00       	call   80104b9a <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 90 a5 10 80       	push   $0x8010a590
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
801010f3:	e8 10 3b 00 00       	call   80104c08 <release>
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
80101141:	e8 c2 3a 00 00       	call   80104c08 <release>
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
80101290:	68 9a a5 10 80       	push   $0x8010a59a
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
80101393:	68 a3 a5 10 80       	push   $0x8010a5a3
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
801013c9:	68 b3 a5 10 80       	push   $0x8010a5b3
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
80101401:	e8 c9 3a 00 00       	call   80104ecf <memmove>
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
80101447:	e8 c4 39 00 00       	call   80104e10 <memset>
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
801015a5:	68 c0 a5 10 80       	push   $0x8010a5c0
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
80101630:	68 d6 a5 10 80       	push   $0x8010a5d6
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
80101694:	68 e9 a5 10 80       	push   $0x8010a5e9
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 d5 34 00 00       	call   80104b78 <initlock>
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
801016ca:	68 f0 a5 10 80       	push   $0x8010a5f0
801016cf:	50                   	push   %eax
801016d0:	e8 46 33 00 00       	call   80104a1b <initsleeplock>
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
80101729:	68 f8 a5 10 80       	push   $0x8010a5f8
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
801017a2:	e8 69 36 00 00       	call   80104e10 <memset>
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
80101809:	68 4b a6 10 80       	push   $0x8010a64b
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
801018af:	e8 1b 36 00 00       	call   80104ecf <memmove>
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
801018e4:	e8 b1 32 00 00       	call   80104b9a <acquire>
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
80101932:	e8 d1 32 00 00       	call   80104c08 <release>
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
8010196e:	68 5d a6 10 80       	push   $0x8010a65d
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
801019ab:	e8 58 32 00 00       	call   80104c08 <release>
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
801019c6:	e8 cf 31 00 00       	call   80104b9a <acquire>
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
801019e5:	e8 1e 32 00 00       	call   80104c08 <release>
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
80101a0b:	68 6d a6 10 80       	push   $0x8010a66d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 33 30 00 00       	call   80104a57 <acquiresleep>
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
80101ac9:	e8 01 34 00 00       	call   80104ecf <memmove>
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
80101af8:	68 73 a6 10 80       	push   $0x8010a673
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
80101b1b:	e8 e9 2f 00 00       	call   80104b09 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 82 a6 10 80       	push   $0x8010a682
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 6e 2f 00 00       	call   80104abb <releasesleep>
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
80101b63:	e8 ef 2e 00 00       	call   80104a57 <acquiresleep>
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
80101b89:	e8 0c 30 00 00       	call   80104b9a <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 61 30 00 00       	call   80104c08 <release>
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
80101be9:	e8 cd 2e 00 00       	call   80104abb <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 9c 2f 00 00       	call   80104b9a <acquire>
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
80101c18:	e8 eb 2f 00 00       	call   80104c08 <release>
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
80101d5c:	68 8a a6 10 80       	push   $0x8010a68a
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
80101ffa:	e8 d0 2e 00 00       	call   80104ecf <memmove>
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
8010214a:	e8 80 2d 00 00       	call   80104ecf <memmove>
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
801021ca:	e8 96 2d 00 00       	call   80104f65 <strncmp>
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
801021ea:	68 9d a6 10 80       	push   $0x8010a69d
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
80102219:	68 af a6 10 80       	push   $0x8010a6af
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
801022ee:	68 be a6 10 80       	push   $0x8010a6be
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
80102329:	e8 8d 2c 00 00       	call   80104fbb <strncpy>
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
80102355:	68 cb a6 10 80       	push   $0x8010a6cb
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
801023c7:	e8 03 2b 00 00       	call   80104ecf <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 ec 2a 00 00       	call   80104ecf <memmove>
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
801025d5:	68 d4 a6 10 80       	push   $0x8010a6d4
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
8010267c:	68 06 a7 10 80       	push   $0x8010a706
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 ed 24 00 00       	call   80104b78 <initlock>
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
8010273b:	68 0b a7 10 80       	push   $0x8010a70b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 b9 26 00 00       	call   80104e10 <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 2a 24 00 00       	call   80104b9a <acquire>
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
8010279d:	e8 66 24 00 00       	call   80104c08 <release>
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
801027bf:	e8 d6 23 00 00       	call   80104b9a <acquire>
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
801027f0:	e8 13 24 00 00       	call   80104c08 <release>
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
80102d14:	e8 5e 21 00 00       	call   80104e77 <memcmp>
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
80102e28:	68 11 a7 10 80       	push   $0x8010a711
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 41 1d 00 00       	call   80104b78 <initlock>
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
80102edd:	e8 ed 1f 00 00       	call   80104ecf <memmove>
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
8010304c:	e8 49 1b 00 00       	call   80104b9a <acquire>
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
8010306a:	e8 11 14 00 00       	call   80104480 <sleep>
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
8010309f:	e8 dc 13 00 00       	call   80104480 <sleep>
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
801030be:	e8 45 1b 00 00       	call   80104c08 <release>
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
801030df:	e8 b6 1a 00 00       	call   80104b9a <acquire>
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
80103100:	68 15 a7 10 80       	push   $0x8010a715
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
8010312e:	e8 37 14 00 00       	call   8010456a <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 c5 1a 00 00       	call   80104c08 <release>
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
80103159:	e8 3c 1a 00 00       	call   80104b9a <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 f2 13 00 00       	call   8010456a <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 80 1a 00 00       	call   80104c08 <release>
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
801031ff:	e8 cb 1c 00 00       	call   80104ecf <memmove>
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
8010329c:	68 24 a7 10 80       	push   $0x8010a724
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 3a a7 10 80       	push   $0x8010a73a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 d1 18 00 00       	call   80104b9a <acquire>
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
80103342:	e8 c1 18 00 00       	call   80104c08 <release>
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
80103378:	e8 38 4f 00 00       	call   801082b5 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 3b 45 00 00       	call   801078d2 <kvmalloc>
  mpinit_uefi();
80103397:	e8 e2 4c 00 00       	call   8010807e <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 c3 3f 00 00       	call   80107369 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 48 33 00 00       	call   80106702 <uartinit>
  pinit();         // process table
801033ba:	e8 c7 05 00 00       	call   80103986 <pinit>
  tvinit();        // trap vectors
801033bf:	e8 a3 2e 00 00       	call   80106267 <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 0d 70 00 00       	call   8010a3e0 <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 1e 51 00 00       	call   80108510 <pci_init>
  arp_scan();
801033f2:	e8 53 5e 00 00       	call   8010924a <arp_scan>
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
80103407:	e8 de 44 00 00       	call   801078ea <switchkvm>
  seginit();
8010340c:	e8 58 3f 00 00       	call   80107369 <seginit>
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
80103433:	68 55 a7 10 80       	push   $0x8010a755
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 98 2f 00 00       	call   801063dd <idtinit>
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
80103480:	e8 4a 1a 00 00       	call   80104ecf <memmove>
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
80103607:	68 69 a7 10 80       	push   $0x8010a769
8010360c:	50                   	push   %eax
8010360d:	e8 66 15 00 00       	call   80104b78 <initlock>
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
801036cc:	e8 c9 14 00 00       	call   80104b9a <acquire>
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
801036f3:	e8 72 0e 00 00       	call   8010456a <wakeup>
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
80103716:	e8 4f 0e 00 00       	call   8010456a <wakeup>
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
8010373f:	e8 c4 14 00 00       	call   80104c08 <release>
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
8010375e:	e8 a5 14 00 00       	call   80104c08 <release>
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
80103778:	e8 1d 14 00 00       	call   80104b9a <acquire>
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
801037ac:	e8 57 14 00 00       	call   80104c08 <release>
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
801037ca:	e8 9b 0d 00 00       	call   8010456a <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 98 0c 00 00       	call   80104480 <sleep>
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
8010384d:	e8 18 0d 00 00       	call   8010456a <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 a7 13 00 00       	call   80104c08 <release>
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
80103879:	e8 1c 13 00 00       	call   80104b9a <acquire>
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
80103896:	e8 6d 13 00 00       	call   80104c08 <release>
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
801038b9:	e8 c2 0b 00 00       	call   80104480 <sleep>
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
8010394c:	e8 19 0c 00 00       	call   8010456a <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 a8 12 00 00       	call   80104c08 <release>
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
8010398f:	68 70 a7 10 80       	push   $0x8010a770
80103994:	68 00 42 19 80       	push   $0x80194200
80103999:	e8 da 11 00 00       	call   80104b78 <initlock>
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
801039d6:	68 78 a7 10 80       	push   $0x8010a778
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
80103a2b:	68 9e a7 10 80       	push   $0x8010a79e
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
80103a3d:	e8 c3 12 00 00       	call   80104d05 <pushcli>
  c = mycpu();  //현재 cpu를 가져옴
80103a42:	e8 78 ff ff ff       	call   801039bf <mycpu>
80103a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;  //해당 cpu에서 실행 중인 프로세스를 가져옴
80103a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();     //인터럽트 상태 복원
80103a56:	e8 f7 12 00 00       	call   80104d52 <popcli>
  
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
80103a6e:	e8 27 11 00 00       	call   80104b9a <acquire>
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
80103aa1:	e8 62 11 00 00       	call   80104c08 <release>
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
80103b1c:	e8 e7 10 00 00       	call   80104c08 <release>
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
80103b69:	ba 21 62 10 80       	mov    $0x80106221,%edx
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
80103b8e:	e8 7d 12 00 00       	call   80104e10 <memset>
80103b93:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b99:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b9c:	ba 3a 44 10 80       	mov    $0x8010443a,%edx
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
80103bbf:	e8 21 3c 00 00       	call   801077e5 <setupkvm>
80103bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bc7:	89 42 04             	mov    %eax,0x4(%edx)
80103bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcd:	8b 40 04             	mov    0x4(%eax),%eax
80103bd0:	85 c0                	test   %eax,%eax
80103bd2:	75 0d                	jne    80103be1 <userinit+0x38>
    panic("userinit: out of memory?");
80103bd4:	83 ec 0c             	sub    $0xc,%esp
80103bd7:	68 ae a7 10 80       	push   $0x8010a7ae
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
80103bf6:	e8 a7 3e 00 00       	call   80107aa2 <inituvm>
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
80103c15:	e8 f6 11 00 00       	call   80104e10 <memset>
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
80103c8f:	68 c7 a7 10 80       	push   $0x8010a7c7
80103c94:	50                   	push   %eax
80103c95:	e8 79 13 00 00       	call   80105013 <safestrcpy>
80103c9a:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c9d:	83 ec 0c             	sub    $0xc,%esp
80103ca0:	68 d0 a7 10 80       	push   $0x8010a7d0
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
80103cbb:	e8 da 0e 00 00       	call   80104b9a <acquire>
80103cc0:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ccd:	83 ec 0c             	sub    $0xc,%esp
80103cd0:	68 00 42 19 80       	push   $0x80194200
80103cd5:	e8 2e 0f 00 00       	call   80104c08 <release>
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
80103d12:	e8 c8 3e 00 00       	call   80107bdf <allocuvm>
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
80103d46:	e8 99 3f 00 00       	call   80107ce4 <deallocuvm>
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
80103d6c:	e8 92 3b 00 00       	call   80107903 <switchuvm>
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
80103db4:	e8 c9 40 00 00       	call   80107e82 <copyuvm>
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
80103eae:	e8 60 11 00 00       	call   80105013 <safestrcpy>
80103eb3:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103eb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eb9:	8b 40 10             	mov    0x10(%eax),%eax
80103ebc:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103ebf:	83 ec 0c             	sub    $0xc,%esp
80103ec2:	68 00 42 19 80       	push   $0x80194200
80103ec7:	e8 ce 0c 00 00       	call   80104b9a <acquire>
80103ecc:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ecf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ed2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103ed9:	83 ec 0c             	sub    $0xc,%esp
80103edc:	68 00 42 19 80       	push   $0x80194200
80103ee1:	e8 22 0d 00 00       	call   80104c08 <release>
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
80103f0f:	68 d2 a7 10 80       	push   $0x8010a7d2
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
80103f95:	e8 00 0c 00 00       	call   80104b9a <acquire>
80103f9a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa0:	8b 40 14             	mov    0x14(%eax),%eax
80103fa3:	83 ec 0c             	sub    $0xc,%esp
80103fa6:	50                   	push   %eax
80103fa7:	e8 7b 05 00 00       	call   80104527 <wakeup1>
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
80103fe3:	e8 3f 05 00 00       	call   80104527 <wakeup1>
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
80104005:	e8 3d 03 00 00       	call   80104347 <sched>
  panic("zombie exit");
8010400a:	83 ec 0c             	sub    $0xc,%esp
8010400d:	68 df a7 10 80       	push   $0x8010a7df
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
8010402d:	e8 68 0b 00 00       	call   80104b9a <acquire>
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
80104098:	e8 0b 3d 00 00       	call   80107da8 <freevm>
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
801040d7:	e8 2c 0b 00 00       	call   80104c08 <release>
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
80104111:	e8 f2 0a 00 00       	call   80104c08 <release>
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
8010412b:	e8 50 03 00 00       	call   80104480 <sleep>
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
80104162:	e8 33 0a 00 00       	call   80104b9a <acquire>
80104167:	83 c4 10             	add    $0x10,%esp

    if (c->sched_policy == 1 || c->sched_policy == 2) {
8010416a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010416d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104173:	83 f8 01             	cmp    $0x1,%eax
80104176:	74 12                	je     8010418a <scheduler+0x50>
80104178:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010417b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104181:	83 f8 02             	cmp    $0x2,%eax
80104184:	0f 85 2f 01 00 00    	jne    801042b9 <scheduler+0x17f>
      // MLFQ: 높은 우선순위부터 RUNNABLE 프로세스 탐색
      struct proc *selected = 0;
8010418a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      for (int prio = 3; prio >= 0; prio--) {
80104191:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
80104198:	eb 3e                	jmp    801041d8 <scheduler+0x9e>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010419a:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801041a1:	eb 28                	jmp    801041cb <scheduler+0x91>
          if (p->state == RUNNABLE && p->priority == prio) {
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	8b 40 0c             	mov    0xc(%eax),%eax
801041a9:	83 f8 03             	cmp    $0x3,%eax
801041ac:	75 16                	jne    801041c4 <scheduler+0x8a>
801041ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b1:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801041b7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041ba:	75 08                	jne    801041c4 <scheduler+0x8a>
            selected = p;
801041bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
            goto found;
801041c2:	eb 1b                	jmp    801041df <scheduler+0xa5>
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801041c4:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
801041cb:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
801041d2:	72 cf                	jb     801041a3 <scheduler+0x69>
      for (int prio = 3; prio >= 0; prio--) {
801041d4:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
801041d8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801041dc:	79 bc                	jns    8010419a <scheduler+0x60>
          }
        }
      }
    found:
801041de:	90                   	nop
      if (selected) {
801041df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041e3:	0f 84 48 01 00 00    	je     80104331 <scheduler+0x1f7>
        c->proc = selected;
801041e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041ef:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(selected);
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	ff 75 f0             	push   -0x10(%ebp)
801041fb:	e8 03 37 00 00       	call   80107903 <switchuvm>
80104200:	83 c4 10             	add    $0x10,%esp
        selected->state = RUNNING;
80104203:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104206:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        // 한 번만 swtch, 실제 시간은 타이머 인터럽트에서 틱 관리
        swtch(&(c->scheduler), selected->context);
8010420d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104210:	8b 40 1c             	mov    0x1c(%eax),%eax
80104213:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104216:	83 c2 04             	add    $0x4,%edx
80104219:	83 ec 08             	sub    $0x8,%esp
8010421c:	50                   	push   %eax
8010421d:	52                   	push   %edx
8010421e:	e8 62 0e 00 00       	call   80105085 <swtch>
80104223:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104226:	e8 bf 36 00 00       	call   801078ea <switchkvm>

        // 타임슬라이스 다 썼으면 demote
        int slice[4] = {1000000, 32, 16, 8};
8010422b:	c7 45 d4 40 42 0f 00 	movl   $0xf4240,-0x2c(%ebp)
80104232:	c7 45 d8 20 00 00 00 	movl   $0x20,-0x28(%ebp)
80104239:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
80104240:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
        int prio = selected->priority;
80104247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010424a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104250:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (prio > 0 && selected->ticks[prio] >= slice[prio]) {
80104253:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104257:	7e 3e                	jle    80104297 <scheduler+0x15d>
80104259:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010425c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010425f:	83 c2 20             	add    $0x20,%edx
80104262:	8b 54 90 08          	mov    0x8(%eax,%edx,4),%edx
80104266:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104269:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
8010426d:	39 c2                	cmp    %eax,%edx
8010426f:	7c 26                	jl     80104297 <scheduler+0x15d>
          selected->priority--;
80104271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104274:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010427a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010427d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104280:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
          selected->ticks[prio] = 0;
80104286:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104289:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010428c:	83 c2 20             	add    $0x20,%edx
8010428f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104296:	00 
        }

        // 다른 프로세스 대기 시간 증가 + boost 체크
        update_wait_ticks(selected);
80104297:	83 ec 0c             	sub    $0xc,%esp
8010429a:	ff 75 f0             	push   -0x10(%ebp)
8010429d:	e8 18 06 00 00       	call   801048ba <update_wait_ticks>
801042a2:	83 c4 10             	add    $0x10,%esp
        priority_boost();
801042a5:	e8 87 06 00 00       	call   80104931 <priority_boost>

        c->proc = 0;
801042aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042ad:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042b4:	00 00 00 
    if (c->sched_policy == 1 || c->sched_policy == 2) {
801042b7:	eb 78                	jmp    80104331 <scheduler+0x1f7>
      }

    } else {
      // 기본 Round-Robin 스케줄링
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042b9:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801042c0:	eb 64                	jmp    80104326 <scheduler+0x1ec>
        if(p->state != RUNNABLE)
801042c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c5:	8b 40 0c             	mov    0xc(%eax),%eax
801042c8:	83 f8 03             	cmp    $0x3,%eax
801042cb:	75 51                	jne    8010431e <scheduler+0x1e4>
          continue;

        c->proc = p;
801042cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d3:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801042d9:	83 ec 0c             	sub    $0xc,%esp
801042dc:	ff 75 f4             	push   -0xc(%ebp)
801042df:	e8 1f 36 00 00       	call   80107903 <switchuvm>
801042e4:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801042e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ea:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
801042f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f4:	8b 40 1c             	mov    0x1c(%eax),%eax
801042f7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801042fa:	83 c2 04             	add    $0x4,%edx
801042fd:	83 ec 08             	sub    $0x8,%esp
80104300:	50                   	push   %eax
80104301:	52                   	push   %edx
80104302:	e8 7e 0d 00 00       	call   80105085 <swtch>
80104307:	83 c4 10             	add    $0x10,%esp
        switchkvm();
8010430a:	e8 db 35 00 00       	call   801078ea <switchkvm>

        c->proc = 0;
8010430f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104312:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104319:	00 00 00 
8010431c:	eb 01                	jmp    8010431f <scheduler+0x1e5>
          continue;
8010431e:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010431f:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
80104326:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
8010432d:	72 93                	jb     801042c2 <scheduler+0x188>
8010432f:	eb 01                	jmp    80104332 <scheduler+0x1f8>
    if (c->sched_policy == 1 || c->sched_policy == 2) {
80104331:	90                   	nop
      }
    }

    release(&ptable.lock);
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	68 00 42 19 80       	push   $0x80194200
8010433a:	e8 c9 08 00 00       	call   80104c08 <release>
8010433f:	83 c4 10             	add    $0x10,%esp
    sti();
80104342:	e9 0e fe ff ff       	jmp    80104155 <scheduler+0x1b>

80104347 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104347:	55                   	push   %ebp
80104348:	89 e5                	mov    %esp,%ebp
8010434a:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();    //현재 CPU에서 실행중인 프로세스를 얻음
8010434d:	e8 e5 f6 ff ff       	call   80103a37 <myproc>
80104352:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //ptable.lock이 잡혀있지 않을때
  if(!holding(&ptable.lock))
80104355:	83 ec 0c             	sub    $0xc,%esp
80104358:	68 00 42 19 80       	push   $0x80194200
8010435d:	e8 73 09 00 00       	call   80104cd5 <holding>
80104362:	83 c4 10             	add    $0x10,%esp
80104365:	85 c0                	test   %eax,%eax
80104367:	75 0d                	jne    80104376 <sched+0x2f>
    panic("sched ptable.lock");
80104369:	83 ec 0c             	sub    $0xc,%esp
8010436c:	68 eb a7 10 80       	push   $0x8010a7eb
80104371:	e8 33 c2 ff ff       	call   801005a9 <panic>

  //현재 cpu의 인터럽트 차단회수가 1이 아니면 에러
  if(mycpu()->ncli != 1)
80104376:	e8 44 f6 ff ff       	call   801039bf <mycpu>
8010437b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104381:	83 f8 01             	cmp    $0x1,%eax
80104384:	74 0d                	je     80104393 <sched+0x4c>
    panic("sched locks");
80104386:	83 ec 0c             	sub    $0xc,%esp
80104389:	68 fd a7 10 80       	push   $0x8010a7fd
8010438e:	e8 16 c2 ff ff       	call   801005a9 <panic>

  //현재 프로세스 상태가 RUNNING이면 에러
  //RUNNABLE , SLEEPING , ZOMBIE 의 상태어야 전환이 가능
  if(p->state == RUNNING)
80104393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104396:	8b 40 0c             	mov    0xc(%eax),%eax
80104399:	83 f8 04             	cmp    $0x4,%eax
8010439c:	75 0d                	jne    801043ab <sched+0x64>
    panic("sched running");
8010439e:	83 ec 0c             	sub    $0xc,%esp
801043a1:	68 09 a8 10 80       	push   $0x8010a809
801043a6:	e8 fe c1 ff ff       	call   801005a9 <panic>

  //인터럽트가 활성화 된 상태일 경우 에러
  //전환중에는 인터럽트가 꺼져있어야함
  if(readeflags()&FL_IF)
801043ab:	e8 b8 f5 ff ff       	call   80103968 <readeflags>
801043b0:	25 00 02 00 00       	and    $0x200,%eax
801043b5:	85 c0                	test   %eax,%eax
801043b7:	74 0d                	je     801043c6 <sched+0x7f>
    panic("sched interruptible");
801043b9:	83 ec 0c             	sub    $0xc,%esp
801043bc:	68 17 a8 10 80       	push   $0x8010a817
801043c1:	e8 e3 c1 ff ff       	call   801005a9 <panic>

  intena = mycpu()->intena; //현재 CPU의 언터럽트  활성화 상태를 저장해둔다
801043c6:	e8 f4 f5 ff ff       	call   801039bf <mycpu>
801043cb:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043d1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  swtch(&p->context, mycpu()->scheduler); //전환을 수행 , 현재 프로세스의 context를 저장하고 CPU가 가진 scheduler context로 전환
801043d4:	e8 e6 f5 ff ff       	call   801039bf <mycpu>
801043d9:	8b 40 04             	mov    0x4(%eax),%eax
801043dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043df:	83 c2 1c             	add    $0x1c,%edx
801043e2:	83 ec 08             	sub    $0x8,%esp
801043e5:	50                   	push   %eax
801043e6:	52                   	push   %edx
801043e7:	e8 99 0c 00 00       	call   80105085 <swtch>
801043ec:	83 c4 10             	add    $0x10,%esp

  mycpu()->intena = intena; //스케줄링이 끝난뒤 원래 인터럽트 상태로 복원
801043ef:	e8 cb f5 ff ff       	call   801039bf <mycpu>
801043f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043f7:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801043fd:	90                   	nop
801043fe:	c9                   	leave
801043ff:	c3                   	ret

80104400 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104406:	83 ec 0c             	sub    $0xc,%esp
80104409:	68 00 42 19 80       	push   $0x80194200
8010440e:	e8 87 07 00 00       	call   80104b9a <acquire>
80104413:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104416:	e8 1c f6 ff ff       	call   80103a37 <myproc>
8010441b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104422:	e8 20 ff ff ff       	call   80104347 <sched>
  release(&ptable.lock);
80104427:	83 ec 0c             	sub    $0xc,%esp
8010442a:	68 00 42 19 80       	push   $0x80194200
8010442f:	e8 d4 07 00 00       	call   80104c08 <release>
80104434:	83 c4 10             	add    $0x10,%esp
}
80104437:	90                   	nop
80104438:	c9                   	leave
80104439:	c3                   	ret

8010443a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010443a:	55                   	push   %ebp
8010443b:	89 e5                	mov    %esp,%ebp
8010443d:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104440:	83 ec 0c             	sub    $0xc,%esp
80104443:	68 00 42 19 80       	push   $0x80194200
80104448:	e8 bb 07 00 00       	call   80104c08 <release>
8010444d:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104450:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104455:	85 c0                	test   %eax,%eax
80104457:	74 24                	je     8010447d <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104459:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104460:	00 00 00 
    iinit(ROOTDEV);
80104463:	83 ec 0c             	sub    $0xc,%esp
80104466:	6a 01                	push   $0x1
80104468:	e8 14 d2 ff ff       	call   80101681 <iinit>
8010446d:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104470:	83 ec 0c             	sub    $0xc,%esp
80104473:	6a 01                	push   $0x1
80104475:	e8 a5 e9 ff ff       	call   80102e1f <initlog>
8010447a:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010447d:	90                   	nop
8010447e:	c9                   	leave
8010447f:	c3                   	ret

80104480 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104480:	55                   	push   %ebp
80104481:	89 e5                	mov    %esp,%ebp
80104483:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104486:	e8 ac f5 ff ff       	call   80103a37 <myproc>
8010448b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010448e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104492:	75 0d                	jne    801044a1 <sleep+0x21>
    panic("sleep");
80104494:	83 ec 0c             	sub    $0xc,%esp
80104497:	68 2b a8 10 80       	push   $0x8010a82b
8010449c:	e8 08 c1 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801044a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044a5:	75 0d                	jne    801044b4 <sleep+0x34>
    panic("sleep without lk");
801044a7:	83 ec 0c             	sub    $0xc,%esp
801044aa:	68 31 a8 10 80       	push   $0x8010a831
801044af:	e8 f5 c0 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044b4:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801044bb:	74 1e                	je     801044db <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801044bd:	83 ec 0c             	sub    $0xc,%esp
801044c0:	68 00 42 19 80       	push   $0x80194200
801044c5:	e8 d0 06 00 00       	call   80104b9a <acquire>
801044ca:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044cd:	83 ec 0c             	sub    $0xc,%esp
801044d0:	ff 75 0c             	push   0xc(%ebp)
801044d3:	e8 30 07 00 00       	call   80104c08 <release>
801044d8:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801044db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044de:	8b 55 08             	mov    0x8(%ebp),%edx
801044e1:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801044e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801044ee:	e8 54 fe ff ff       	call   80104347 <sched>

  // Tidy up.
  p->chan = 0;
801044f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f6:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801044fd:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104504:	74 1e                	je     80104524 <sleep+0xa4>
    release(&ptable.lock);
80104506:	83 ec 0c             	sub    $0xc,%esp
80104509:	68 00 42 19 80       	push   $0x80194200
8010450e:	e8 f5 06 00 00       	call   80104c08 <release>
80104513:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104516:	83 ec 0c             	sub    $0xc,%esp
80104519:	ff 75 0c             	push   0xc(%ebp)
8010451c:	e8 79 06 00 00       	call   80104b9a <acquire>
80104521:	83 c4 10             	add    $0x10,%esp
  }
}
80104524:	90                   	nop
80104525:	c9                   	leave
80104526:	c3                   	ret

80104527 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104527:	55                   	push   %ebp
80104528:	89 e5                	mov    %esp,%ebp
8010452a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010452d:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104534:	eb 27                	jmp    8010455d <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104536:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104539:	8b 40 0c             	mov    0xc(%eax),%eax
8010453c:	83 f8 02             	cmp    $0x2,%eax
8010453f:	75 15                	jne    80104556 <wakeup1+0x2f>
80104541:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104544:	8b 40 20             	mov    0x20(%eax),%eax
80104547:	39 45 08             	cmp    %eax,0x8(%ebp)
8010454a:	75 0a                	jne    80104556 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010454c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010454f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104556:	81 45 fc a8 00 00 00 	addl   $0xa8,-0x4(%ebp)
8010455d:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
80104564:	72 d0                	jb     80104536 <wakeup1+0xf>
}
80104566:	90                   	nop
80104567:	90                   	nop
80104568:	c9                   	leave
80104569:	c3                   	ret

8010456a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010456a:	55                   	push   %ebp
8010456b:	89 e5                	mov    %esp,%ebp
8010456d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104570:	83 ec 0c             	sub    $0xc,%esp
80104573:	68 00 42 19 80       	push   $0x80194200
80104578:	e8 1d 06 00 00       	call   80104b9a <acquire>
8010457d:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104580:	83 ec 0c             	sub    $0xc,%esp
80104583:	ff 75 08             	push   0x8(%ebp)
80104586:	e8 9c ff ff ff       	call   80104527 <wakeup1>
8010458b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010458e:	83 ec 0c             	sub    $0xc,%esp
80104591:	68 00 42 19 80       	push   $0x80194200
80104596:	e8 6d 06 00 00       	call   80104c08 <release>
8010459b:	83 c4 10             	add    $0x10,%esp
}
8010459e:	90                   	nop
8010459f:	c9                   	leave
801045a0:	c3                   	ret

801045a1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045a1:	55                   	push   %ebp
801045a2:	89 e5                	mov    %esp,%ebp
801045a4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801045a7:	83 ec 0c             	sub    $0xc,%esp
801045aa:	68 00 42 19 80       	push   $0x80194200
801045af:	e8 e6 05 00 00       	call   80104b9a <acquire>
801045b4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045b7:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801045be:	eb 48                	jmp    80104608 <kill+0x67>
    if(p->pid == pid){
801045c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c3:	8b 40 10             	mov    0x10(%eax),%eax
801045c6:	39 45 08             	cmp    %eax,0x8(%ebp)
801045c9:	75 36                	jne    80104601 <kill+0x60>
      p->killed = 1;
801045cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ce:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801045d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d8:	8b 40 0c             	mov    0xc(%eax),%eax
801045db:	83 f8 02             	cmp    $0x2,%eax
801045de:	75 0a                	jne    801045ea <kill+0x49>
        p->state = RUNNABLE;
801045e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	68 00 42 19 80       	push   $0x80194200
801045f2:	e8 11 06 00 00       	call   80104c08 <release>
801045f7:	83 c4 10             	add    $0x10,%esp
      return 0;
801045fa:	b8 00 00 00 00       	mov    $0x0,%eax
801045ff:	eb 25                	jmp    80104626 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104601:	81 45 f4 a8 00 00 00 	addl   $0xa8,-0xc(%ebp)
80104608:	81 7d f4 34 6c 19 80 	cmpl   $0x80196c34,-0xc(%ebp)
8010460f:	72 af                	jb     801045c0 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104611:	83 ec 0c             	sub    $0xc,%esp
80104614:	68 00 42 19 80       	push   $0x80194200
80104619:	e8 ea 05 00 00       	call   80104c08 <release>
8010461e:	83 c4 10             	add    $0x10,%esp
  return -1;
80104621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104626:	c9                   	leave
80104627:	c3                   	ret

80104628 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104628:	55                   	push   %ebp
80104629:	89 e5                	mov    %esp,%ebp
8010462b:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462e:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104635:	e9 da 00 00 00       	jmp    80104714 <procdump+0xec>
    if(p->state == UNUSED)
8010463a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010463d:	8b 40 0c             	mov    0xc(%eax),%eax
80104640:	85 c0                	test   %eax,%eax
80104642:	0f 84 c4 00 00 00    	je     8010470c <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010464b:	8b 40 0c             	mov    0xc(%eax),%eax
8010464e:	83 f8 05             	cmp    $0x5,%eax
80104651:	77 23                	ja     80104676 <procdump+0x4e>
80104653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104656:	8b 40 0c             	mov    0xc(%eax),%eax
80104659:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104660:	85 c0                	test   %eax,%eax
80104662:	74 12                	je     80104676 <procdump+0x4e>
      state = states[p->state];
80104664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104667:	8b 40 0c             	mov    0xc(%eax),%eax
8010466a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104671:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104674:	eb 07                	jmp    8010467d <procdump+0x55>
    else
      state = "???";
80104676:	c7 45 ec 42 a8 10 80 	movl   $0x8010a842,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010467d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104680:	8d 50 6c             	lea    0x6c(%eax),%edx
80104683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104686:	8b 40 10             	mov    0x10(%eax),%eax
80104689:	52                   	push   %edx
8010468a:	ff 75 ec             	push   -0x14(%ebp)
8010468d:	50                   	push   %eax
8010468e:	68 46 a8 10 80       	push   $0x8010a846
80104693:	e8 5c bd ff ff       	call   801003f4 <cprintf>
80104698:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010469b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010469e:	8b 40 0c             	mov    0xc(%eax),%eax
801046a1:	83 f8 02             	cmp    $0x2,%eax
801046a4:	75 54                	jne    801046fa <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a9:	8b 40 1c             	mov    0x1c(%eax),%eax
801046ac:	8b 40 0c             	mov    0xc(%eax),%eax
801046af:	83 c0 08             	add    $0x8,%eax
801046b2:	89 c2                	mov    %eax,%edx
801046b4:	83 ec 08             	sub    $0x8,%esp
801046b7:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046ba:	50                   	push   %eax
801046bb:	52                   	push   %edx
801046bc:	e8 99 05 00 00       	call   80104c5a <getcallerpcs>
801046c1:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046cb:	eb 1c                	jmp    801046e9 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046d4:	83 ec 08             	sub    $0x8,%esp
801046d7:	50                   	push   %eax
801046d8:	68 4f a8 10 80       	push   $0x8010a84f
801046dd:	e8 12 bd ff ff       	call   801003f4 <cprintf>
801046e2:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046e9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801046ed:	7f 0b                	jg     801046fa <procdump+0xd2>
801046ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046f6:	85 c0                	test   %eax,%eax
801046f8:	75 d3                	jne    801046cd <procdump+0xa5>
    }
    cprintf("\n");
801046fa:	83 ec 0c             	sub    $0xc,%esp
801046fd:	68 53 a8 10 80       	push   $0x8010a853
80104702:	e8 ed bc ff ff       	call   801003f4 <cprintf>
80104707:	83 c4 10             	add    $0x10,%esp
8010470a:	eb 01                	jmp    8010470d <procdump+0xe5>
      continue;
8010470c:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010470d:	81 45 f0 a8 00 00 00 	addl   $0xa8,-0x10(%ebp)
80104714:	81 7d f0 34 6c 19 80 	cmpl   $0x80196c34,-0x10(%ebp)
8010471b:	0f 82 19 ff ff ff    	jb     8010463a <procdump+0x12>
  }
}
80104721:	90                   	nop
80104722:	90                   	nop
80104723:	c9                   	leave
80104724:	c3                   	ret

80104725 <sys_getpinfo>:

#include "pstat.h" // 구조체를 include해줌

int
sys_getpinfo(void)
{
80104725:	55                   	push   %ebp
80104726:	89 e5                	mov    %esp,%ebp
80104728:	53                   	push   %ebx
80104729:	83 ec 14             	sub    $0x14,%esp
  struct pstat *ps;

  // 유저 포인터를 커널에서 접근 가능하도록 변환
  //argprt(인자번호 결과를 저장하는 주소 , 기대하는 크기)
  if (argptr(0, (void*)&ps, sizeof(*ps)) < 0)
8010472c:	83 ec 04             	sub    $0x4,%esp
8010472f:	68 00 0c 00 00       	push   $0xc00
80104734:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104737:	50                   	push   %eax
80104738:	6a 00                	push   $0x0
8010473a:	e8 29 0a 00 00       	call   80105168 <argptr>
8010473f:	83 c4 10             	add    $0x10,%esp
80104742:	85 c0                	test   %eax,%eax
80104744:	79 0a                	jns    80104750 <sys_getpinfo+0x2b>
    return -1;  //잘못된 포인터일시 -1 반환
80104746:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010474b:	e9 0e 01 00 00       	jmp    8010485e <sys_getpinfo+0x139>

  acquire(&ptable.lock); //프로세스 테이블 락
80104750:	83 ec 0c             	sub    $0xc,%esp
80104753:	68 00 42 19 80       	push   $0x80194200
80104758:	e8 3d 04 00 00       	call   80104b9a <acquire>
8010475d:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROC; i++) {
80104760:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104767:	e9 d3 00 00 00       	jmp    8010483f <sys_getpinfo+0x11a>
    struct proc *p = &ptable.proc[i];
8010476c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476f:	69 c0 a8 00 00 00    	imul   $0xa8,%eax,%eax
80104775:	83 c0 30             	add    $0x30,%eax
80104778:	05 00 42 19 80       	add    $0x80194200,%eax
8010477d:	83 c0 04             	add    $0x4,%eax
80104780:	89 45 ec             	mov    %eax,-0x14(%ebp)

    ps->inuse[i] = (p->state != UNUSED); // 현재 프로세스가 사용중인지
80104783:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104786:	8b 40 0c             	mov    0xc(%eax),%eax
80104789:	85 c0                	test   %eax,%eax
8010478b:	0f 95 c2             	setne  %dl
8010478e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104791:	0f b6 ca             	movzbl %dl,%ecx
80104794:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104797:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    ps->pid[i] = p->pid; //프로세스 ID를 저장
8010479a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010479d:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047a0:	8b 52 10             	mov    0x10(%edx),%edx
801047a3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047a6:	83 c1 40             	add    $0x40,%ecx
801047a9:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    ps->priority[i] = p->priority; // 현재 우선순위
801047ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047af:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047b2:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
801047b8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047bb:	83 e9 80             	sub    $0xffffff80,%ecx
801047be:	89 14 88             	mov    %edx,(%eax,%ecx,4)

    ps->state[i] = p->state; // 현재 상태
801047c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047c4:	8b 50 0c             	mov    0xc(%eax),%edx
801047c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047ca:	89 d1                	mov    %edx,%ecx
801047cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047cf:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801047d5:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    // 우선순위별 실행 시간을 복사
    for (int j = 0; j < 4; j++) {
801047d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047df:	eb 54                	jmp    80104835 <sys_getpinfo+0x110>
      ps->ticks[i][j] = p->ticks[j];      //각 큐에서의 실행시간
801047e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801047e7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801047ea:	83 c1 20             	add    $0x20,%ecx
801047ed:	8b 54 8a 08          	mov    0x8(%edx,%ecx,4),%edx
801047f1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047f4:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801047fb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801047fe:	01 d9                	add    %ebx,%ecx
80104800:	81 c1 00 01 00 00    	add    $0x100,%ecx
80104806:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      ps->wait_ticks[i][j] = p->wait_ticks[j]; // 각 큐에서의 대기시간
80104809:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010480c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010480f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104812:	83 c1 24             	add    $0x24,%ecx
80104815:	8b 54 8a 08          	mov    0x8(%edx,%ecx,4),%edx
80104819:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010481c:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104823:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104826:	01 d9                	add    %ebx,%ecx
80104828:	81 c1 00 02 00 00    	add    $0x200,%ecx
8010482e:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
80104831:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104835:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104839:	7e a6                	jle    801047e1 <sys_getpinfo+0xbc>
  for (int i = 0; i < NPROC; i++) {
8010483b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010483f:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104843:	0f 8e 23 ff ff ff    	jle    8010476c <sys_getpinfo+0x47>
    }
  }
  release(&ptable.lock); //락 해제
80104849:	83 ec 0c             	sub    $0xc,%esp
8010484c:	68 00 42 19 80       	push   $0x80194200
80104851:	e8 b2 03 00 00       	call   80104c08 <release>
80104856:	83 c4 10             	add    $0x10,%esp
  return 0; 
80104859:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010485e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104861:	c9                   	leave
80104862:	c3                   	ret

80104863 <sys_setSchedPolicy>:


int
sys_setSchedPolicy(void)
{
80104863:	55                   	push   %ebp
80104864:	89 e5                	mov    %esp,%ebp
80104866:	83 ec 18             	sub    $0x18,%esp
  int policy;
  // 사용자로 부터 전달된 첫 번째 인자(policy 번호)를 읽어옴
  // 실패하면 -1 반환
  if (argint(0, &policy) < 0)
80104869:	83 ec 08             	sub    $0x8,%esp
8010486c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010486f:	50                   	push   %eax
80104870:	6a 00                	push   $0x0
80104872:	e8 c4 08 00 00       	call   8010513b <argint>
80104877:	83 c4 10             	add    $0x10,%esp
8010487a:	85 c0                	test   %eax,%eax
8010487c:	79 07                	jns    80104885 <sys_setSchedPolicy+0x22>
    return -1;
8010487e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104883:	eb 33                	jmp    801048b8 <sys_setSchedPolicy+0x55>

  // 유효한 정책 번호인지 확인 (예 0~3 사이만 허용)
  if (policy < 0 || policy > 3)
80104885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104888:	85 c0                	test   %eax,%eax
8010488a:	78 08                	js     80104894 <sys_setSchedPolicy+0x31>
8010488c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010488f:	83 f8 03             	cmp    $0x3,%eax
80104892:	7e 07                	jle    8010489b <sys_setSchedPolicy+0x38>
    return -1;
80104894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104899:	eb 1d                	jmp    801048b8 <sys_setSchedPolicy+0x55>


  cli();  // 인터럽트 끄기
8010489b:	e8 d8 f0 ff ff       	call   80103978 <cli>
  mycpu()->sched_policy = policy;
801048a0:	e8 1a f1 ff ff       	call   801039bf <mycpu>
801048a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048a8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  sti();  // 다시 켜기
801048ae:	e8 cc f0 ff ff       	call   8010397f <sti>

  return 0;
801048b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048b8:	c9                   	leave
801048b9:	c3                   	ret

801048ba <update_wait_ticks>:


//각 프로세스가 자신의 큐에서 얼마나 대기했는지 
void
update_wait_ticks(struct proc *running)
{
801048ba:	55                   	push   %ebp
801048bb:	89 e5                	mov    %esp,%ebp
801048bd:	83 ec 10             	sub    $0x10,%esp
  // ptable에 있는 모든 프로세스를 순회
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801048c0:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801048c7:	eb 5b                	jmp    80104924 <update_wait_ticks+0x6a>
    
    //현재 실행 중인 프로세스는 제외하고
    if (p == running) continue;
801048c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048cc:	3b 45 08             	cmp    0x8(%ebp),%eax
801048cf:	74 48                	je     80104919 <update_wait_ticks+0x5f>
    
    //실행 가능한 상태인 프로세스만 대상으로 한다
    if (p->state == RUNNABLE) {
801048d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048d4:	8b 40 0c             	mov    0xc(%eax),%eax
801048d7:	83 f8 03             	cmp    $0x3,%eax
801048da:	75 41                	jne    8010491d <update_wait_ticks+0x63>
      //비 정상적인 priorty값은 무시한다
      if (p->priority < 0 || p->priority > 3)
801048dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048df:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801048e5:	85 c0                	test   %eax,%eax
801048e7:	78 33                	js     8010491c <update_wait_ticks+0x62>
801048e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048ec:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801048f2:	83 f8 03             	cmp    $0x3,%eax
801048f5:	7f 25                	jg     8010491c <update_wait_ticks+0x62>
         continue; // 잘못된 priority 값이면 무시

      //현재 프로세스가 속한 우선순위 큐에서 기다린 시간을 증가시킨다   
      p->wait_ticks[p->priority]++;
801048f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048fa:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104900:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104903:	8d 48 24             	lea    0x24(%eax),%ecx
80104906:	8b 54 8a 08          	mov    0x8(%edx,%ecx,4),%edx
8010490a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010490d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104910:	83 c0 24             	add    $0x24,%eax
80104913:	89 4c 82 08          	mov    %ecx,0x8(%edx,%eax,4)
80104917:	eb 04                	jmp    8010491d <update_wait_ticks+0x63>
    if (p == running) continue;
80104919:	90                   	nop
8010491a:	eb 01                	jmp    8010491d <update_wait_ticks+0x63>
         continue; // 잘못된 priority 값이면 무시
8010491c:	90                   	nop
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010491d:	81 45 fc a8 00 00 00 	addl   $0xa8,-0x4(%ebp)
80104924:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
8010492b:	72 9c                	jb     801048c9 <update_wait_ticks+0xf>
    }
  }
}
8010492d:	90                   	nop
8010492e:	90                   	nop
8010492f:	c9                   	leave
80104930:	c3                   	ret

80104931 <priority_boost>:

//우선 순위를 자동으로 조정해주는 함수 , Starvation 방지용
void
priority_boost(void)
{
80104931:	55                   	push   %ebp
80104932:	89 e5                	mov    %esp,%ebp
80104934:	83 ec 20             	sub    $0x20,%esp
  //모든 프로세스를 순회
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104937:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010493e:	e9 c7 00 00 00       	jmp    80104a0a <priority_boost+0xd9>
    //사용하지 않을 경우에는 건너뜀
    if (p->state == UNUSED)
80104943:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104946:	8b 40 0c             	mov    0xc(%eax),%eax
80104949:	85 c0                	test   %eax,%eax
8010494b:	0f 84 b1 00 00 00    	je     80104a02 <priority_boost+0xd1>
      continue;

    int prio = p->priority; // 현재 프로세스의 우선순위를 가져옴
80104951:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104954:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010495a:	89 45 f8             	mov    %eax,-0x8(%ebp)

    //현재 우선순위가 Q1 or Q2인 경우
    if (prio == 2 || prio == 1) {
8010495d:	83 7d f8 02          	cmpl   $0x2,-0x8(%ebp)
80104961:	74 06                	je     80104969 <priority_boost+0x38>
80104963:	83 7d f8 01          	cmpl   $0x1,-0x8(%ebp)
80104967:	75 67                	jne    801049d0 <priority_boost+0x9f>
      // time slice 기준 : Q1=32 , Q2=16 , Q3 = 8
      int slice[4] = {0, 32, 16, 8}; // Q0은 사용 안 하므로 0으로 둠
80104969:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104970:	c7 45 e8 20 00 00 00 	movl   $0x20,-0x18(%ebp)
80104977:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
8010497e:	c7 45 f0 08 00 00 00 	movl   $0x8,-0x10(%ebp)

      int limit = 10 * slice[prio]; //10배 대기 시간이 되면 우선순위를 상승시킨다
80104985:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104988:	8b 54 85 e4          	mov    -0x1c(%ebp,%eax,4),%edx
8010498c:	89 d0                	mov    %edx,%eax
8010498e:	c1 e0 02             	shl    $0x2,%eax
80104991:	01 d0                	add    %edx,%eax
80104993:	01 c0                	add    %eax,%eax
80104995:	89 45 f4             	mov    %eax,-0xc(%ebp)

      // 해당 우선순위에서 대기한 틱 수가 limit 이상이면
      if (p->wait_ticks[prio] >= limit) {
80104998:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010499b:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010499e:	83 c2 24             	add    $0x24,%edx
801049a1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049a5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801049a8:	7f 26                	jg     801049d0 <priority_boost+0x9f>
        p->priority++;            //우선 순위 상승(0->1->2)
801049aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049ad:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801049b3:	8d 50 01             	lea    0x1(%eax),%edx
801049b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049b9:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
        p->wait_ticks[prio] = 0; // 대기 시간을 초기화 한다
801049bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
801049c5:	83 c2 24             	add    $0x24,%edx
801049c8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801049cf:	00 
      }
    }

    // 현재 우선순위가 Q0인 경우
    if (prio == 0) {
801049d0:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
801049d4:	75 2d                	jne    80104a03 <priority_boost+0xd2>
      //Q0에 너무 오래 머무르면 -> Q1로 이동
      if (p->wait_ticks[0] >= 500) {
801049d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049d9:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801049df:	3d f3 01 00 00       	cmp    $0x1f3,%eax
801049e4:	7e 1d                	jle    80104a03 <priority_boost+0xd2>
        p->priority = 1;    //우선순위를 상승
801049e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049e9:	c7 80 84 00 00 00 01 	movl   $0x1,0x84(%eax)
801049f0:	00 00 00 
        p->wait_ticks[0] = 0; // 초기화
801049f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049f6:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
801049fd:	00 00 00 
80104a00:	eb 01                	jmp    80104a03 <priority_boost+0xd2>
      continue;
80104a02:	90                   	nop
  for (struct proc *p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a03:	81 45 fc a8 00 00 00 	addl   $0xa8,-0x4(%ebp)
80104a0a:	81 7d fc 34 6c 19 80 	cmpl   $0x80196c34,-0x4(%ebp)
80104a11:	0f 82 2c ff ff ff    	jb     80104943 <priority_boost+0x12>
      }
    }
  }
}
80104a17:	90                   	nop
80104a18:	90                   	nop
80104a19:	c9                   	leave
80104a1a:	c3                   	ret

80104a1b <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a1b:	55                   	push   %ebp
80104a1c:	89 e5                	mov    %esp,%ebp
80104a1e:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a21:	8b 45 08             	mov    0x8(%ebp),%eax
80104a24:	83 c0 04             	add    $0x4,%eax
80104a27:	83 ec 08             	sub    $0x8,%esp
80104a2a:	68 7f a8 10 80       	push   $0x8010a87f
80104a2f:	50                   	push   %eax
80104a30:	e8 43 01 00 00       	call   80104b78 <initlock>
80104a35:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a38:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a3e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a41:	8b 45 08             	mov    0x8(%ebp),%eax
80104a44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104a54:	90                   	nop
80104a55:	c9                   	leave
80104a56:	c3                   	ret

80104a57 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104a57:	55                   	push   %ebp
80104a58:	89 e5                	mov    %esp,%ebp
80104a5a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a60:	83 c0 04             	add    $0x4,%eax
80104a63:	83 ec 0c             	sub    $0xc,%esp
80104a66:	50                   	push   %eax
80104a67:	e8 2e 01 00 00       	call   80104b9a <acquire>
80104a6c:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a6f:	eb 15                	jmp    80104a86 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104a71:	8b 45 08             	mov    0x8(%ebp),%eax
80104a74:	83 c0 04             	add    $0x4,%eax
80104a77:	83 ec 08             	sub    $0x8,%esp
80104a7a:	50                   	push   %eax
80104a7b:	ff 75 08             	push   0x8(%ebp)
80104a7e:	e8 fd f9 ff ff       	call   80104480 <sleep>
80104a83:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a86:	8b 45 08             	mov    0x8(%ebp),%eax
80104a89:	8b 00                	mov    (%eax),%eax
80104a8b:	85 c0                	test   %eax,%eax
80104a8d:	75 e2                	jne    80104a71 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a92:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a98:	e8 9a ef ff ff       	call   80103a37 <myproc>
80104a9d:	8b 50 10             	mov    0x10(%eax),%edx
80104aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa3:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa9:	83 c0 04             	add    $0x4,%eax
80104aac:	83 ec 0c             	sub    $0xc,%esp
80104aaf:	50                   	push   %eax
80104ab0:	e8 53 01 00 00       	call   80104c08 <release>
80104ab5:	83 c4 10             	add    $0x10,%esp
}
80104ab8:	90                   	nop
80104ab9:	c9                   	leave
80104aba:	c3                   	ret

80104abb <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104abb:	55                   	push   %ebp
80104abc:	89 e5                	mov    %esp,%ebp
80104abe:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac4:	83 c0 04             	add    $0x4,%eax
80104ac7:	83 ec 0c             	sub    $0xc,%esp
80104aca:	50                   	push   %eax
80104acb:	e8 ca 00 00 00       	call   80104b9a <acquire>
80104ad0:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104adc:	8b 45 08             	mov    0x8(%ebp),%eax
80104adf:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104ae6:	83 ec 0c             	sub    $0xc,%esp
80104ae9:	ff 75 08             	push   0x8(%ebp)
80104aec:	e8 79 fa ff ff       	call   8010456a <wakeup>
80104af1:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104af4:	8b 45 08             	mov    0x8(%ebp),%eax
80104af7:	83 c0 04             	add    $0x4,%eax
80104afa:	83 ec 0c             	sub    $0xc,%esp
80104afd:	50                   	push   %eax
80104afe:	e8 05 01 00 00       	call   80104c08 <release>
80104b03:	83 c4 10             	add    $0x10,%esp
}
80104b06:	90                   	nop
80104b07:	c9                   	leave
80104b08:	c3                   	ret

80104b09 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b09:	55                   	push   %ebp
80104b0a:	89 e5                	mov    %esp,%ebp
80104b0c:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b12:	83 c0 04             	add    $0x4,%eax
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	50                   	push   %eax
80104b19:	e8 7c 00 00 00       	call   80104b9a <acquire>
80104b1e:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b21:	8b 45 08             	mov    0x8(%ebp),%eax
80104b24:	8b 00                	mov    (%eax),%eax
80104b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b29:	8b 45 08             	mov    0x8(%ebp),%eax
80104b2c:	83 c0 04             	add    $0x4,%eax
80104b2f:	83 ec 0c             	sub    $0xc,%esp
80104b32:	50                   	push   %eax
80104b33:	e8 d0 00 00 00       	call   80104c08 <release>
80104b38:	83 c4 10             	add    $0x10,%esp
  return r;
80104b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b3e:	c9                   	leave
80104b3f:	c3                   	ret

80104b40 <readeflags>:
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b46:	9c                   	pushf
80104b47:	58                   	pop    %eax
80104b48:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b4e:	c9                   	leave
80104b4f:	c3                   	ret

80104b50 <cli>:
{
80104b50:	55                   	push   %ebp
80104b51:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b53:	fa                   	cli
}
80104b54:	90                   	nop
80104b55:	5d                   	pop    %ebp
80104b56:	c3                   	ret

80104b57 <sti>:
{
80104b57:	55                   	push   %ebp
80104b58:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b5a:	fb                   	sti
}
80104b5b:	90                   	nop
80104b5c:	5d                   	pop    %ebp
80104b5d:	c3                   	ret

80104b5e <xchg>:
{
80104b5e:	55                   	push   %ebp
80104b5f:	89 e5                	mov    %esp,%ebp
80104b61:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104b64:	8b 55 08             	mov    0x8(%ebp),%edx
80104b67:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b6d:	f0 87 02             	lock xchg %eax,(%edx)
80104b70:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104b73:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b76:	c9                   	leave
80104b77:	c3                   	ret

80104b78 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b78:	55                   	push   %ebp
80104b79:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b81:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b84:	8b 45 08             	mov    0x8(%ebp),%eax
80104b87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b90:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b97:	90                   	nop
80104b98:	5d                   	pop    %ebp
80104b99:	c3                   	ret

80104b9a <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b9a:	55                   	push   %ebp
80104b9b:	89 e5                	mov    %esp,%ebp
80104b9d:	53                   	push   %ebx
80104b9e:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ba1:	e8 5f 01 00 00       	call   80104d05 <pushcli>
  if(holding(lk)){
80104ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba9:	83 ec 0c             	sub    $0xc,%esp
80104bac:	50                   	push   %eax
80104bad:	e8 23 01 00 00       	call   80104cd5 <holding>
80104bb2:	83 c4 10             	add    $0x10,%esp
80104bb5:	85 c0                	test   %eax,%eax
80104bb7:	74 0d                	je     80104bc6 <acquire+0x2c>
    panic("acquire");
80104bb9:	83 ec 0c             	sub    $0xc,%esp
80104bbc:	68 8a a8 10 80       	push   $0x8010a88a
80104bc1:	e8 e3 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104bc6:	90                   	nop
80104bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bca:	83 ec 08             	sub    $0x8,%esp
80104bcd:	6a 01                	push   $0x1
80104bcf:	50                   	push   %eax
80104bd0:	e8 89 ff ff ff       	call   80104b5e <xchg>
80104bd5:	83 c4 10             	add    $0x10,%esp
80104bd8:	85 c0                	test   %eax,%eax
80104bda:	75 eb                	jne    80104bc7 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104bdc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104be1:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104be4:	e8 d6 ed ff ff       	call   801039bf <mycpu>
80104be9:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104bec:	8b 45 08             	mov    0x8(%ebp),%eax
80104bef:	83 c0 0c             	add    $0xc,%eax
80104bf2:	83 ec 08             	sub    $0x8,%esp
80104bf5:	50                   	push   %eax
80104bf6:	8d 45 08             	lea    0x8(%ebp),%eax
80104bf9:	50                   	push   %eax
80104bfa:	e8 5b 00 00 00       	call   80104c5a <getcallerpcs>
80104bff:	83 c4 10             	add    $0x10,%esp
}
80104c02:	90                   	nop
80104c03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c06:	c9                   	leave
80104c07:	c3                   	ret

80104c08 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c08:	55                   	push   %ebp
80104c09:	89 e5                	mov    %esp,%ebp
80104c0b:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c0e:	83 ec 0c             	sub    $0xc,%esp
80104c11:	ff 75 08             	push   0x8(%ebp)
80104c14:	e8 bc 00 00 00       	call   80104cd5 <holding>
80104c19:	83 c4 10             	add    $0x10,%esp
80104c1c:	85 c0                	test   %eax,%eax
80104c1e:	75 0d                	jne    80104c2d <release+0x25>
    panic("release");
80104c20:	83 ec 0c             	sub    $0xc,%esp
80104c23:	68 92 a8 10 80       	push   $0x8010a892
80104c28:	e8 7c b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c30:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c37:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c41:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c46:	8b 45 08             	mov    0x8(%ebp),%eax
80104c49:	8b 55 08             	mov    0x8(%ebp),%edx
80104c4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c52:	e8 fb 00 00 00       	call   80104d52 <popcli>
}
80104c57:	90                   	nop
80104c58:	c9                   	leave
80104c59:	c3                   	ret

80104c5a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c5a:	55                   	push   %ebp
80104c5b:	89 e5                	mov    %esp,%ebp
80104c5d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104c60:	8b 45 08             	mov    0x8(%ebp),%eax
80104c63:	83 e8 08             	sub    $0x8,%eax
80104c66:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c69:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c70:	eb 38                	jmp    80104caa <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c72:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c76:	74 53                	je     80104ccb <getcallerpcs+0x71>
80104c78:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c7f:	76 4a                	jbe    80104ccb <getcallerpcs+0x71>
80104c81:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c85:	74 44                	je     80104ccb <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c87:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c91:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c94:	01 c2                	add    %eax,%edx
80104c96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c99:	8b 40 04             	mov    0x4(%eax),%eax
80104c9c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca1:	8b 00                	mov    (%eax),%eax
80104ca3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104ca6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104caa:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cae:	7e c2                	jle    80104c72 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104cb0:	eb 19                	jmp    80104ccb <getcallerpcs+0x71>
    pcs[i] = 0;
80104cb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cbf:	01 d0                	add    %edx,%eax
80104cc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104cc7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ccb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ccf:	7e e1                	jle    80104cb2 <getcallerpcs+0x58>
}
80104cd1:	90                   	nop
80104cd2:	90                   	nop
80104cd3:	c9                   	leave
80104cd4:	c3                   	ret

80104cd5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104cd5:	55                   	push   %ebp
80104cd6:	89 e5                	mov    %esp,%ebp
80104cd8:	53                   	push   %ebx
80104cd9:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdf:	8b 00                	mov    (%eax),%eax
80104ce1:	85 c0                	test   %eax,%eax
80104ce3:	74 16                	je     80104cfb <holding+0x26>
80104ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce8:	8b 58 08             	mov    0x8(%eax),%ebx
80104ceb:	e8 cf ec ff ff       	call   801039bf <mycpu>
80104cf0:	39 c3                	cmp    %eax,%ebx
80104cf2:	75 07                	jne    80104cfb <holding+0x26>
80104cf4:	b8 01 00 00 00       	mov    $0x1,%eax
80104cf9:	eb 05                	jmp    80104d00 <holding+0x2b>
80104cfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d03:	c9                   	leave
80104d04:	c3                   	ret

80104d05 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d05:	55                   	push   %ebp
80104d06:	89 e5                	mov    %esp,%ebp
80104d08:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d0b:	e8 30 fe ff ff       	call   80104b40 <readeflags>
80104d10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d13:	e8 38 fe ff ff       	call   80104b50 <cli>
  if(mycpu()->ncli == 0)
80104d18:	e8 a2 ec ff ff       	call   801039bf <mycpu>
80104d1d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d23:	85 c0                	test   %eax,%eax
80104d25:	75 14                	jne    80104d3b <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d27:	e8 93 ec ff ff       	call   801039bf <mycpu>
80104d2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d2f:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d35:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d3b:	e8 7f ec ff ff       	call   801039bf <mycpu>
80104d40:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d46:	83 c2 01             	add    $0x1,%edx
80104d49:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d4f:	90                   	nop
80104d50:	c9                   	leave
80104d51:	c3                   	ret

80104d52 <popcli>:

void
popcli(void)
{
80104d52:	55                   	push   %ebp
80104d53:	89 e5                	mov    %esp,%ebp
80104d55:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d58:	e8 e3 fd ff ff       	call   80104b40 <readeflags>
80104d5d:	25 00 02 00 00       	and    $0x200,%eax
80104d62:	85 c0                	test   %eax,%eax
80104d64:	74 0d                	je     80104d73 <popcli+0x21>
    panic("popcli - interruptible");
80104d66:	83 ec 0c             	sub    $0xc,%esp
80104d69:	68 9a a8 10 80       	push   $0x8010a89a
80104d6e:	e8 36 b8 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104d73:	e8 47 ec ff ff       	call   801039bf <mycpu>
80104d78:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d7e:	83 ea 01             	sub    $0x1,%edx
80104d81:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d87:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d8d:	85 c0                	test   %eax,%eax
80104d8f:	79 0d                	jns    80104d9e <popcli+0x4c>
    panic("popcli");
80104d91:	83 ec 0c             	sub    $0xc,%esp
80104d94:	68 b1 a8 10 80       	push   $0x8010a8b1
80104d99:	e8 0b b8 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104d9e:	e8 1c ec ff ff       	call   801039bf <mycpu>
80104da3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104da9:	85 c0                	test   %eax,%eax
80104dab:	75 14                	jne    80104dc1 <popcli+0x6f>
80104dad:	e8 0d ec ff ff       	call   801039bf <mycpu>
80104db2:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104db8:	85 c0                	test   %eax,%eax
80104dba:	74 05                	je     80104dc1 <popcli+0x6f>
    sti();
80104dbc:	e8 96 fd ff ff       	call   80104b57 <sti>
}
80104dc1:	90                   	nop
80104dc2:	c9                   	leave
80104dc3:	c3                   	ret

80104dc4 <stosb>:
{
80104dc4:	55                   	push   %ebp
80104dc5:	89 e5                	mov    %esp,%ebp
80104dc7:	57                   	push   %edi
80104dc8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104dcc:	8b 55 10             	mov    0x10(%ebp),%edx
80104dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd2:	89 cb                	mov    %ecx,%ebx
80104dd4:	89 df                	mov    %ebx,%edi
80104dd6:	89 d1                	mov    %edx,%ecx
80104dd8:	fc                   	cld
80104dd9:	f3 aa                	rep stos %al,%es:(%edi)
80104ddb:	89 ca                	mov    %ecx,%edx
80104ddd:	89 fb                	mov    %edi,%ebx
80104ddf:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104de2:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104de5:	90                   	nop
80104de6:	5b                   	pop    %ebx
80104de7:	5f                   	pop    %edi
80104de8:	5d                   	pop    %ebp
80104de9:	c3                   	ret

80104dea <stosl>:
{
80104dea:	55                   	push   %ebp
80104deb:	89 e5                	mov    %esp,%ebp
80104ded:	57                   	push   %edi
80104dee:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104def:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104df2:	8b 55 10             	mov    0x10(%ebp),%edx
80104df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df8:	89 cb                	mov    %ecx,%ebx
80104dfa:	89 df                	mov    %ebx,%edi
80104dfc:	89 d1                	mov    %edx,%ecx
80104dfe:	fc                   	cld
80104dff:	f3 ab                	rep stos %eax,%es:(%edi)
80104e01:	89 ca                	mov    %ecx,%edx
80104e03:	89 fb                	mov    %edi,%ebx
80104e05:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e08:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e0b:	90                   	nop
80104e0c:	5b                   	pop    %ebx
80104e0d:	5f                   	pop    %edi
80104e0e:	5d                   	pop    %ebp
80104e0f:	c3                   	ret

80104e10 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e13:	8b 45 08             	mov    0x8(%ebp),%eax
80104e16:	83 e0 03             	and    $0x3,%eax
80104e19:	85 c0                	test   %eax,%eax
80104e1b:	75 43                	jne    80104e60 <memset+0x50>
80104e1d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e20:	83 e0 03             	and    $0x3,%eax
80104e23:	85 c0                	test   %eax,%eax
80104e25:	75 39                	jne    80104e60 <memset+0x50>
    c &= 0xFF;
80104e27:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e2e:	8b 45 10             	mov    0x10(%ebp),%eax
80104e31:	c1 e8 02             	shr    $0x2,%eax
80104e34:	89 c1                	mov    %eax,%ecx
80104e36:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e39:	c1 e0 18             	shl    $0x18,%eax
80104e3c:	89 c2                	mov    %eax,%edx
80104e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e41:	c1 e0 10             	shl    $0x10,%eax
80104e44:	09 c2                	or     %eax,%edx
80104e46:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e49:	c1 e0 08             	shl    $0x8,%eax
80104e4c:	09 d0                	or     %edx,%eax
80104e4e:	0b 45 0c             	or     0xc(%ebp),%eax
80104e51:	51                   	push   %ecx
80104e52:	50                   	push   %eax
80104e53:	ff 75 08             	push   0x8(%ebp)
80104e56:	e8 8f ff ff ff       	call   80104dea <stosl>
80104e5b:	83 c4 0c             	add    $0xc,%esp
80104e5e:	eb 12                	jmp    80104e72 <memset+0x62>
  } else
    stosb(dst, c, n);
80104e60:	8b 45 10             	mov    0x10(%ebp),%eax
80104e63:	50                   	push   %eax
80104e64:	ff 75 0c             	push   0xc(%ebp)
80104e67:	ff 75 08             	push   0x8(%ebp)
80104e6a:	e8 55 ff ff ff       	call   80104dc4 <stosb>
80104e6f:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104e72:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e75:	c9                   	leave
80104e76:	c3                   	ret

80104e77 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e77:	55                   	push   %ebp
80104e78:	89 e5                	mov    %esp,%ebp
80104e7a:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e80:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e83:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e86:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e89:	eb 2e                	jmp    80104eb9 <memcmp+0x42>
    if(*s1 != *s2)
80104e8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e8e:	0f b6 10             	movzbl (%eax),%edx
80104e91:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e94:	0f b6 00             	movzbl (%eax),%eax
80104e97:	38 c2                	cmp    %al,%dl
80104e99:	74 16                	je     80104eb1 <memcmp+0x3a>
      return *s1 - *s2;
80104e9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9e:	0f b6 00             	movzbl (%eax),%eax
80104ea1:	0f b6 d0             	movzbl %al,%edx
80104ea4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea7:	0f b6 00             	movzbl (%eax),%eax
80104eaa:	0f b6 c0             	movzbl %al,%eax
80104ead:	29 c2                	sub    %eax,%edx
80104eaf:	eb 1a                	jmp    80104ecb <memcmp+0x54>
    s1++, s2++;
80104eb1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104eb5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104eb9:	8b 45 10             	mov    0x10(%ebp),%eax
80104ebc:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ebf:	89 55 10             	mov    %edx,0x10(%ebp)
80104ec2:	85 c0                	test   %eax,%eax
80104ec4:	75 c5                	jne    80104e8b <memcmp+0x14>
  }

  return 0;
80104ec6:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104ecb:	89 d0                	mov    %edx,%eax
80104ecd:	c9                   	leave
80104ece:	c3                   	ret

80104ecf <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ecf:	55                   	push   %ebp
80104ed0:	89 e5                	mov    %esp,%ebp
80104ed2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104edb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ede:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104ee1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ee4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ee7:	73 54                	jae    80104f3d <memmove+0x6e>
80104ee9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104eec:	8b 45 10             	mov    0x10(%ebp),%eax
80104eef:	01 d0                	add    %edx,%eax
80104ef1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104ef4:	73 47                	jae    80104f3d <memmove+0x6e>
    s += n;
80104ef6:	8b 45 10             	mov    0x10(%ebp),%eax
80104ef9:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104efc:	8b 45 10             	mov    0x10(%ebp),%eax
80104eff:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f02:	eb 13                	jmp    80104f17 <memmove+0x48>
      *--d = *--s;
80104f04:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f08:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f0f:	0f b6 10             	movzbl (%eax),%edx
80104f12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f15:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f17:	8b 45 10             	mov    0x10(%ebp),%eax
80104f1a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f1d:	89 55 10             	mov    %edx,0x10(%ebp)
80104f20:	85 c0                	test   %eax,%eax
80104f22:	75 e0                	jne    80104f04 <memmove+0x35>
  if(s < d && s + n > d){
80104f24:	eb 24                	jmp    80104f4a <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f26:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f29:	8d 42 01             	lea    0x1(%edx),%eax
80104f2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f32:	8d 48 01             	lea    0x1(%eax),%ecx
80104f35:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f38:	0f b6 12             	movzbl (%edx),%edx
80104f3b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f3d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f40:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f43:	89 55 10             	mov    %edx,0x10(%ebp)
80104f46:	85 c0                	test   %eax,%eax
80104f48:	75 dc                	jne    80104f26 <memmove+0x57>

  return dst;
80104f4a:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f4d:	c9                   	leave
80104f4e:	c3                   	ret

80104f4f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f4f:	55                   	push   %ebp
80104f50:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f52:	ff 75 10             	push   0x10(%ebp)
80104f55:	ff 75 0c             	push   0xc(%ebp)
80104f58:	ff 75 08             	push   0x8(%ebp)
80104f5b:	e8 6f ff ff ff       	call   80104ecf <memmove>
80104f60:	83 c4 0c             	add    $0xc,%esp
}
80104f63:	c9                   	leave
80104f64:	c3                   	ret

80104f65 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f65:	55                   	push   %ebp
80104f66:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f68:	eb 0c                	jmp    80104f76 <strncmp+0x11>
    n--, p++, q++;
80104f6a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f6e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f72:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f7a:	74 1a                	je     80104f96 <strncmp+0x31>
80104f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7f:	0f b6 00             	movzbl (%eax),%eax
80104f82:	84 c0                	test   %al,%al
80104f84:	74 10                	je     80104f96 <strncmp+0x31>
80104f86:	8b 45 08             	mov    0x8(%ebp),%eax
80104f89:	0f b6 10             	movzbl (%eax),%edx
80104f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f8f:	0f b6 00             	movzbl (%eax),%eax
80104f92:	38 c2                	cmp    %al,%dl
80104f94:	74 d4                	je     80104f6a <strncmp+0x5>
  if(n == 0)
80104f96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f9a:	75 07                	jne    80104fa3 <strncmp+0x3e>
    return 0;
80104f9c:	ba 00 00 00 00       	mov    $0x0,%edx
80104fa1:	eb 14                	jmp    80104fb7 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa6:	0f b6 00             	movzbl (%eax),%eax
80104fa9:	0f b6 d0             	movzbl %al,%edx
80104fac:	8b 45 0c             	mov    0xc(%ebp),%eax
80104faf:	0f b6 00             	movzbl (%eax),%eax
80104fb2:	0f b6 c0             	movzbl %al,%eax
80104fb5:	29 c2                	sub    %eax,%edx
}
80104fb7:	89 d0                	mov    %edx,%eax
80104fb9:	5d                   	pop    %ebp
80104fba:	c3                   	ret

80104fbb <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104fbb:	55                   	push   %ebp
80104fbc:	89 e5                	mov    %esp,%ebp
80104fbe:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104fc7:	90                   	nop
80104fc8:	8b 45 10             	mov    0x10(%ebp),%eax
80104fcb:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fce:	89 55 10             	mov    %edx,0x10(%ebp)
80104fd1:	85 c0                	test   %eax,%eax
80104fd3:	7e 2c                	jle    80105001 <strncpy+0x46>
80104fd5:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fd8:	8d 42 01             	lea    0x1(%edx),%eax
80104fdb:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fde:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe1:	8d 48 01             	lea    0x1(%eax),%ecx
80104fe4:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fe7:	0f b6 12             	movzbl (%edx),%edx
80104fea:	88 10                	mov    %dl,(%eax)
80104fec:	0f b6 00             	movzbl (%eax),%eax
80104fef:	84 c0                	test   %al,%al
80104ff1:	75 d5                	jne    80104fc8 <strncpy+0xd>
    ;
  while(n-- > 0)
80104ff3:	eb 0c                	jmp    80105001 <strncpy+0x46>
    *s++ = 0;
80104ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff8:	8d 50 01             	lea    0x1(%eax),%edx
80104ffb:	89 55 08             	mov    %edx,0x8(%ebp)
80104ffe:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105001:	8b 45 10             	mov    0x10(%ebp),%eax
80105004:	8d 50 ff             	lea    -0x1(%eax),%edx
80105007:	89 55 10             	mov    %edx,0x10(%ebp)
8010500a:	85 c0                	test   %eax,%eax
8010500c:	7f e7                	jg     80104ff5 <strncpy+0x3a>
  return os;
8010500e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105011:	c9                   	leave
80105012:	c3                   	ret

80105013 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105013:	55                   	push   %ebp
80105014:	89 e5                	mov    %esp,%ebp
80105016:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105019:	8b 45 08             	mov    0x8(%ebp),%eax
8010501c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010501f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105023:	7f 05                	jg     8010502a <safestrcpy+0x17>
    return os;
80105025:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105028:	eb 32                	jmp    8010505c <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010502a:	90                   	nop
8010502b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010502f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105033:	7e 1e                	jle    80105053 <safestrcpy+0x40>
80105035:	8b 55 0c             	mov    0xc(%ebp),%edx
80105038:	8d 42 01             	lea    0x1(%edx),%eax
8010503b:	89 45 0c             	mov    %eax,0xc(%ebp)
8010503e:	8b 45 08             	mov    0x8(%ebp),%eax
80105041:	8d 48 01             	lea    0x1(%eax),%ecx
80105044:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105047:	0f b6 12             	movzbl (%edx),%edx
8010504a:	88 10                	mov    %dl,(%eax)
8010504c:	0f b6 00             	movzbl (%eax),%eax
8010504f:	84 c0                	test   %al,%al
80105051:	75 d8                	jne    8010502b <safestrcpy+0x18>
    ;
  *s = 0;
80105053:	8b 45 08             	mov    0x8(%ebp),%eax
80105056:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105059:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010505c:	c9                   	leave
8010505d:	c3                   	ret

8010505e <strlen>:

int
strlen(const char *s)
{
8010505e:	55                   	push   %ebp
8010505f:	89 e5                	mov    %esp,%ebp
80105061:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105064:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010506b:	eb 04                	jmp    80105071 <strlen+0x13>
8010506d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105071:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105074:	8b 45 08             	mov    0x8(%ebp),%eax
80105077:	01 d0                	add    %edx,%eax
80105079:	0f b6 00             	movzbl (%eax),%eax
8010507c:	84 c0                	test   %al,%al
8010507e:	75 ed                	jne    8010506d <strlen+0xf>
    ;
  return n;
80105080:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105083:	c9                   	leave
80105084:	c3                   	ret

80105085 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105085:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105089:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010508d:	55                   	push   %ebp
  pushl %ebx
8010508e:	53                   	push   %ebx
  pushl %esi
8010508f:	56                   	push   %esi
  pushl %edi
80105090:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105091:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105093:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105095:	5f                   	pop    %edi
  popl %esi
80105096:	5e                   	pop    %esi
  popl %ebx
80105097:	5b                   	pop    %ebx
  popl %ebp
80105098:	5d                   	pop    %ebp
  ret
80105099:	c3                   	ret

8010509a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010509a:	55                   	push   %ebp
8010509b:	89 e5                	mov    %esp,%ebp
8010509d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801050a0:	e8 92 e9 ff ff       	call   80103a37 <myproc>
801050a5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ab:	8b 00                	mov    (%eax),%eax
801050ad:	39 45 08             	cmp    %eax,0x8(%ebp)
801050b0:	73 0f                	jae    801050c1 <fetchint+0x27>
801050b2:	8b 45 08             	mov    0x8(%ebp),%eax
801050b5:	8d 50 04             	lea    0x4(%eax),%edx
801050b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050bb:	8b 00                	mov    (%eax),%eax
801050bd:	39 d0                	cmp    %edx,%eax
801050bf:	73 07                	jae    801050c8 <fetchint+0x2e>
    return -1;
801050c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c6:	eb 0f                	jmp    801050d7 <fetchint+0x3d>
  *ip = *(int*)(addr);
801050c8:	8b 45 08             	mov    0x8(%ebp),%eax
801050cb:	8b 10                	mov    (%eax),%edx
801050cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d0:	89 10                	mov    %edx,(%eax)
  return 0;
801050d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050d7:	c9                   	leave
801050d8:	c3                   	ret

801050d9 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801050d9:	55                   	push   %ebp
801050da:	89 e5                	mov    %esp,%ebp
801050dc:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801050df:	e8 53 e9 ff ff       	call   80103a37 <myproc>
801050e4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801050e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ea:	8b 00                	mov    (%eax),%eax
801050ec:	39 45 08             	cmp    %eax,0x8(%ebp)
801050ef:	72 07                	jb     801050f8 <fetchstr+0x1f>
    return -1;
801050f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f6:	eb 41                	jmp    80105139 <fetchstr+0x60>
  *pp = (char*)addr;
801050f8:	8b 55 08             	mov    0x8(%ebp),%edx
801050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fe:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105103:	8b 00                	mov    (%eax),%eax
80105105:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105108:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510b:	8b 00                	mov    (%eax),%eax
8010510d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105110:	eb 1a                	jmp    8010512c <fetchstr+0x53>
    if(*s == 0)
80105112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105115:	0f b6 00             	movzbl (%eax),%eax
80105118:	84 c0                	test   %al,%al
8010511a:	75 0c                	jne    80105128 <fetchstr+0x4f>
      return s - *pp;
8010511c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511f:	8b 10                	mov    (%eax),%edx
80105121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105124:	29 d0                	sub    %edx,%eax
80105126:	eb 11                	jmp    80105139 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105128:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010512c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105132:	72 de                	jb     80105112 <fetchstr+0x39>
  }
  return -1;
80105134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105139:	c9                   	leave
8010513a:	c3                   	ret

8010513b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
8010513e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105141:	e8 f1 e8 ff ff       	call   80103a37 <myproc>
80105146:	8b 40 18             	mov    0x18(%eax),%eax
80105149:	8b 40 44             	mov    0x44(%eax),%eax
8010514c:	8b 55 08             	mov    0x8(%ebp),%edx
8010514f:	c1 e2 02             	shl    $0x2,%edx
80105152:	01 d0                	add    %edx,%eax
80105154:	83 c0 04             	add    $0x4,%eax
80105157:	83 ec 08             	sub    $0x8,%esp
8010515a:	ff 75 0c             	push   0xc(%ebp)
8010515d:	50                   	push   %eax
8010515e:	e8 37 ff ff ff       	call   8010509a <fetchint>
80105163:	83 c4 10             	add    $0x10,%esp
}
80105166:	c9                   	leave
80105167:	c3                   	ret

80105168 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105168:	55                   	push   %ebp
80105169:	89 e5                	mov    %esp,%ebp
8010516b:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010516e:	e8 c4 e8 ff ff       	call   80103a37 <myproc>
80105173:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105176:	83 ec 08             	sub    $0x8,%esp
80105179:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010517c:	50                   	push   %eax
8010517d:	ff 75 08             	push   0x8(%ebp)
80105180:	e8 b6 ff ff ff       	call   8010513b <argint>
80105185:	83 c4 10             	add    $0x10,%esp
80105188:	85 c0                	test   %eax,%eax
8010518a:	79 07                	jns    80105193 <argptr+0x2b>
    return -1;
8010518c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105191:	eb 3b                	jmp    801051ce <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105193:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105197:	78 1f                	js     801051b8 <argptr+0x50>
80105199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519c:	8b 00                	mov    (%eax),%eax
8010519e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051a1:	39 c2                	cmp    %eax,%edx
801051a3:	73 13                	jae    801051b8 <argptr+0x50>
801051a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a8:	89 c2                	mov    %eax,%edx
801051aa:	8b 45 10             	mov    0x10(%ebp),%eax
801051ad:	01 c2                	add    %eax,%edx
801051af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b2:	8b 00                	mov    (%eax),%eax
801051b4:	39 d0                	cmp    %edx,%eax
801051b6:	73 07                	jae    801051bf <argptr+0x57>
    return -1;
801051b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051bd:	eb 0f                	jmp    801051ce <argptr+0x66>
  *pp = (char*)i;
801051bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051c2:	89 c2                	mov    %eax,%edx
801051c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c7:	89 10                	mov    %edx,(%eax)
  return 0;
801051c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051ce:	c9                   	leave
801051cf:	c3                   	ret

801051d0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051d0:	55                   	push   %ebp
801051d1:	89 e5                	mov    %esp,%ebp
801051d3:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051d6:	83 ec 08             	sub    $0x8,%esp
801051d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051dc:	50                   	push   %eax
801051dd:	ff 75 08             	push   0x8(%ebp)
801051e0:	e8 56 ff ff ff       	call   8010513b <argint>
801051e5:	83 c4 10             	add    $0x10,%esp
801051e8:	85 c0                	test   %eax,%eax
801051ea:	79 07                	jns    801051f3 <argstr+0x23>
    return -1;
801051ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f1:	eb 12                	jmp    80105205 <argstr+0x35>
  return fetchstr(addr, pp);
801051f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f6:	83 ec 08             	sub    $0x8,%esp
801051f9:	ff 75 0c             	push   0xc(%ebp)
801051fc:	50                   	push   %eax
801051fd:	e8 d7 fe ff ff       	call   801050d9 <fetchstr>
80105202:	83 c4 10             	add    $0x10,%esp
}
80105205:	c9                   	leave
80105206:	c3                   	ret

80105207 <syscall>:
[SYS_yield]   sys_yield,
};

void
syscall(void)
{
80105207:	55                   	push   %ebp
80105208:	89 e5                	mov    %esp,%ebp
8010520a:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010520d:	e8 25 e8 ff ff       	call   80103a37 <myproc>
80105212:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105218:	8b 40 18             	mov    0x18(%eax),%eax
8010521b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010521e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105221:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105225:	7e 2f                	jle    80105256 <syscall+0x4f>
80105227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522a:	83 f8 19             	cmp    $0x19,%eax
8010522d:	77 27                	ja     80105256 <syscall+0x4f>
8010522f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105232:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105239:	85 c0                	test   %eax,%eax
8010523b:	74 19                	je     80105256 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
8010523d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105240:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105247:	ff d0                	call   *%eax
80105249:	89 c2                	mov    %eax,%edx
8010524b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524e:	8b 40 18             	mov    0x18(%eax),%eax
80105251:	89 50 1c             	mov    %edx,0x1c(%eax)
80105254:	eb 2c                	jmp    80105282 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105259:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010525c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525f:	8b 40 10             	mov    0x10(%eax),%eax
80105262:	ff 75 f0             	push   -0x10(%ebp)
80105265:	52                   	push   %edx
80105266:	50                   	push   %eax
80105267:	68 b8 a8 10 80       	push   $0x8010a8b8
8010526c:	e8 83 b1 ff ff       	call   801003f4 <cprintf>
80105271:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105277:	8b 40 18             	mov    0x18(%eax),%eax
8010527a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105281:	90                   	nop
80105282:	90                   	nop
80105283:	c9                   	leave
80105284:	c3                   	ret

80105285 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
80105288:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010528b:	83 ec 08             	sub    $0x8,%esp
8010528e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105291:	50                   	push   %eax
80105292:	ff 75 08             	push   0x8(%ebp)
80105295:	e8 a1 fe ff ff       	call   8010513b <argint>
8010529a:	83 c4 10             	add    $0x10,%esp
8010529d:	85 c0                	test   %eax,%eax
8010529f:	79 07                	jns    801052a8 <argfd+0x23>
    return -1;
801052a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a6:	eb 4f                	jmp    801052f7 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ab:	85 c0                	test   %eax,%eax
801052ad:	78 20                	js     801052cf <argfd+0x4a>
801052af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b2:	83 f8 0f             	cmp    $0xf,%eax
801052b5:	7f 18                	jg     801052cf <argfd+0x4a>
801052b7:	e8 7b e7 ff ff       	call   80103a37 <myproc>
801052bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052bf:	83 c2 08             	add    $0x8,%edx
801052c2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052cd:	75 07                	jne    801052d6 <argfd+0x51>
    return -1;
801052cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d4:	eb 21                	jmp    801052f7 <argfd+0x72>
  if(pfd)
801052d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052da:	74 08                	je     801052e4 <argfd+0x5f>
    *pfd = fd;
801052dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052df:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e2:	89 10                	mov    %edx,(%eax)
  if(pf)
801052e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052e8:	74 08                	je     801052f2 <argfd+0x6d>
    *pf = f;
801052ea:	8b 45 10             	mov    0x10(%ebp),%eax
801052ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052f0:	89 10                	mov    %edx,(%eax)
  return 0;
801052f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052f7:	c9                   	leave
801052f8:	c3                   	ret

801052f9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052f9:	55                   	push   %ebp
801052fa:	89 e5                	mov    %esp,%ebp
801052fc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801052ff:	e8 33 e7 ff ff       	call   80103a37 <myproc>
80105304:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105307:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010530e:	eb 2a                	jmp    8010533a <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105313:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105316:	83 c2 08             	add    $0x8,%edx
80105319:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010531d:	85 c0                	test   %eax,%eax
8010531f:	75 15                	jne    80105336 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105321:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105324:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105327:	8d 4a 08             	lea    0x8(%edx),%ecx
8010532a:	8b 55 08             	mov    0x8(%ebp),%edx
8010532d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105334:	eb 0f                	jmp    80105345 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105336:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010533a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010533e:	7e d0                	jle    80105310 <fdalloc+0x17>
    }
  }
  return -1;
80105340:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105345:	c9                   	leave
80105346:	c3                   	ret

80105347 <sys_dup>:

int
sys_dup(void)
{
80105347:	55                   	push   %ebp
80105348:	89 e5                	mov    %esp,%ebp
8010534a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010534d:	83 ec 04             	sub    $0x4,%esp
80105350:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105353:	50                   	push   %eax
80105354:	6a 00                	push   $0x0
80105356:	6a 00                	push   $0x0
80105358:	e8 28 ff ff ff       	call   80105285 <argfd>
8010535d:	83 c4 10             	add    $0x10,%esp
80105360:	85 c0                	test   %eax,%eax
80105362:	79 07                	jns    8010536b <sys_dup+0x24>
    return -1;
80105364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105369:	eb 31                	jmp    8010539c <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010536b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010536e:	83 ec 0c             	sub    $0xc,%esp
80105371:	50                   	push   %eax
80105372:	e8 82 ff ff ff       	call   801052f9 <fdalloc>
80105377:	83 c4 10             	add    $0x10,%esp
8010537a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010537d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105381:	79 07                	jns    8010538a <sys_dup+0x43>
    return -1;
80105383:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105388:	eb 12                	jmp    8010539c <sys_dup+0x55>
  filedup(f);
8010538a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010538d:	83 ec 0c             	sub    $0xc,%esp
80105390:	50                   	push   %eax
80105391:	e8 be bc ff ff       	call   80101054 <filedup>
80105396:	83 c4 10             	add    $0x10,%esp
  return fd;
80105399:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010539c:	c9                   	leave
8010539d:	c3                   	ret

8010539e <sys_read>:

int
sys_read(void)
{
8010539e:	55                   	push   %ebp
8010539f:	89 e5                	mov    %esp,%ebp
801053a1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053a4:	83 ec 04             	sub    $0x4,%esp
801053a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053aa:	50                   	push   %eax
801053ab:	6a 00                	push   $0x0
801053ad:	6a 00                	push   $0x0
801053af:	e8 d1 fe ff ff       	call   80105285 <argfd>
801053b4:	83 c4 10             	add    $0x10,%esp
801053b7:	85 c0                	test   %eax,%eax
801053b9:	78 2e                	js     801053e9 <sys_read+0x4b>
801053bb:	83 ec 08             	sub    $0x8,%esp
801053be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053c1:	50                   	push   %eax
801053c2:	6a 02                	push   $0x2
801053c4:	e8 72 fd ff ff       	call   8010513b <argint>
801053c9:	83 c4 10             	add    $0x10,%esp
801053cc:	85 c0                	test   %eax,%eax
801053ce:	78 19                	js     801053e9 <sys_read+0x4b>
801053d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d3:	83 ec 04             	sub    $0x4,%esp
801053d6:	50                   	push   %eax
801053d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053da:	50                   	push   %eax
801053db:	6a 01                	push   $0x1
801053dd:	e8 86 fd ff ff       	call   80105168 <argptr>
801053e2:	83 c4 10             	add    $0x10,%esp
801053e5:	85 c0                	test   %eax,%eax
801053e7:	79 07                	jns    801053f0 <sys_read+0x52>
    return -1;
801053e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ee:	eb 17                	jmp    80105407 <sys_read+0x69>
  return fileread(f, p, n);
801053f0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f9:	83 ec 04             	sub    $0x4,%esp
801053fc:	51                   	push   %ecx
801053fd:	52                   	push   %edx
801053fe:	50                   	push   %eax
801053ff:	e8 e0 bd ff ff       	call   801011e4 <fileread>
80105404:	83 c4 10             	add    $0x10,%esp
}
80105407:	c9                   	leave
80105408:	c3                   	ret

80105409 <sys_write>:

int
sys_write(void)
{
80105409:	55                   	push   %ebp
8010540a:	89 e5                	mov    %esp,%ebp
8010540c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010540f:	83 ec 04             	sub    $0x4,%esp
80105412:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105415:	50                   	push   %eax
80105416:	6a 00                	push   $0x0
80105418:	6a 00                	push   $0x0
8010541a:	e8 66 fe ff ff       	call   80105285 <argfd>
8010541f:	83 c4 10             	add    $0x10,%esp
80105422:	85 c0                	test   %eax,%eax
80105424:	78 2e                	js     80105454 <sys_write+0x4b>
80105426:	83 ec 08             	sub    $0x8,%esp
80105429:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010542c:	50                   	push   %eax
8010542d:	6a 02                	push   $0x2
8010542f:	e8 07 fd ff ff       	call   8010513b <argint>
80105434:	83 c4 10             	add    $0x10,%esp
80105437:	85 c0                	test   %eax,%eax
80105439:	78 19                	js     80105454 <sys_write+0x4b>
8010543b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543e:	83 ec 04             	sub    $0x4,%esp
80105441:	50                   	push   %eax
80105442:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105445:	50                   	push   %eax
80105446:	6a 01                	push   $0x1
80105448:	e8 1b fd ff ff       	call   80105168 <argptr>
8010544d:	83 c4 10             	add    $0x10,%esp
80105450:	85 c0                	test   %eax,%eax
80105452:	79 07                	jns    8010545b <sys_write+0x52>
    return -1;
80105454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105459:	eb 17                	jmp    80105472 <sys_write+0x69>
  return filewrite(f, p, n);
8010545b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010545e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105464:	83 ec 04             	sub    $0x4,%esp
80105467:	51                   	push   %ecx
80105468:	52                   	push   %edx
80105469:	50                   	push   %eax
8010546a:	e8 2d be ff ff       	call   8010129c <filewrite>
8010546f:	83 c4 10             	add    $0x10,%esp
}
80105472:	c9                   	leave
80105473:	c3                   	ret

80105474 <sys_close>:

int
sys_close(void)
{
80105474:	55                   	push   %ebp
80105475:	89 e5                	mov    %esp,%ebp
80105477:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010547a:	83 ec 04             	sub    $0x4,%esp
8010547d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105480:	50                   	push   %eax
80105481:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105484:	50                   	push   %eax
80105485:	6a 00                	push   $0x0
80105487:	e8 f9 fd ff ff       	call   80105285 <argfd>
8010548c:	83 c4 10             	add    $0x10,%esp
8010548f:	85 c0                	test   %eax,%eax
80105491:	79 07                	jns    8010549a <sys_close+0x26>
    return -1;
80105493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105498:	eb 27                	jmp    801054c1 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010549a:	e8 98 e5 ff ff       	call   80103a37 <myproc>
8010549f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054a2:	83 c2 08             	add    $0x8,%edx
801054a5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054ac:	00 
  fileclose(f);
801054ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b0:	83 ec 0c             	sub    $0xc,%esp
801054b3:	50                   	push   %eax
801054b4:	e8 ec bb ff ff       	call   801010a5 <fileclose>
801054b9:	83 c4 10             	add    $0x10,%esp
  return 0;
801054bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054c1:	c9                   	leave
801054c2:	c3                   	ret

801054c3 <sys_fstat>:

int
sys_fstat(void)
{
801054c3:	55                   	push   %ebp
801054c4:	89 e5                	mov    %esp,%ebp
801054c6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054c9:	83 ec 04             	sub    $0x4,%esp
801054cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054cf:	50                   	push   %eax
801054d0:	6a 00                	push   $0x0
801054d2:	6a 00                	push   $0x0
801054d4:	e8 ac fd ff ff       	call   80105285 <argfd>
801054d9:	83 c4 10             	add    $0x10,%esp
801054dc:	85 c0                	test   %eax,%eax
801054de:	78 17                	js     801054f7 <sys_fstat+0x34>
801054e0:	83 ec 04             	sub    $0x4,%esp
801054e3:	6a 14                	push   $0x14
801054e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054e8:	50                   	push   %eax
801054e9:	6a 01                	push   $0x1
801054eb:	e8 78 fc ff ff       	call   80105168 <argptr>
801054f0:	83 c4 10             	add    $0x10,%esp
801054f3:	85 c0                	test   %eax,%eax
801054f5:	79 07                	jns    801054fe <sys_fstat+0x3b>
    return -1;
801054f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054fc:	eb 13                	jmp    80105511 <sys_fstat+0x4e>
  return filestat(f, st);
801054fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105504:	83 ec 08             	sub    $0x8,%esp
80105507:	52                   	push   %edx
80105508:	50                   	push   %eax
80105509:	e8 7f bc ff ff       	call   8010118d <filestat>
8010550e:	83 c4 10             	add    $0x10,%esp
}
80105511:	c9                   	leave
80105512:	c3                   	ret

80105513 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105513:	55                   	push   %ebp
80105514:	89 e5                	mov    %esp,%ebp
80105516:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105519:	83 ec 08             	sub    $0x8,%esp
8010551c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010551f:	50                   	push   %eax
80105520:	6a 00                	push   $0x0
80105522:	e8 a9 fc ff ff       	call   801051d0 <argstr>
80105527:	83 c4 10             	add    $0x10,%esp
8010552a:	85 c0                	test   %eax,%eax
8010552c:	78 15                	js     80105543 <sys_link+0x30>
8010552e:	83 ec 08             	sub    $0x8,%esp
80105531:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105534:	50                   	push   %eax
80105535:	6a 01                	push   $0x1
80105537:	e8 94 fc ff ff       	call   801051d0 <argstr>
8010553c:	83 c4 10             	add    $0x10,%esp
8010553f:	85 c0                	test   %eax,%eax
80105541:	79 0a                	jns    8010554d <sys_link+0x3a>
    return -1;
80105543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105548:	e9 68 01 00 00       	jmp    801056b5 <sys_link+0x1a2>

  begin_op();
8010554d:	e8 ec da ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105552:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105555:	83 ec 0c             	sub    $0xc,%esp
80105558:	50                   	push   %eax
80105559:	e8 c7 cf ff ff       	call   80102525 <namei>
8010555e:	83 c4 10             	add    $0x10,%esp
80105561:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105564:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105568:	75 0f                	jne    80105579 <sys_link+0x66>
    end_op();
8010556a:	e8 5b db ff ff       	call   801030ca <end_op>
    return -1;
8010556f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105574:	e9 3c 01 00 00       	jmp    801056b5 <sys_link+0x1a2>
  }

  ilock(ip);
80105579:	83 ec 0c             	sub    $0xc,%esp
8010557c:	ff 75 f4             	push   -0xc(%ebp)
8010557f:	e8 6e c4 ff ff       	call   801019f2 <ilock>
80105584:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010558e:	66 83 f8 01          	cmp    $0x1,%ax
80105592:	75 1d                	jne    801055b1 <sys_link+0x9e>
    iunlockput(ip);
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	ff 75 f4             	push   -0xc(%ebp)
8010559a:	e8 84 c6 ff ff       	call   80101c23 <iunlockput>
8010559f:	83 c4 10             	add    $0x10,%esp
    end_op();
801055a2:	e8 23 db ff ff       	call   801030ca <end_op>
    return -1;
801055a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ac:	e9 04 01 00 00       	jmp    801056b5 <sys_link+0x1a2>
  }

  ip->nlink++;
801055b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055b8:	83 c0 01             	add    $0x1,%eax
801055bb:	89 c2                	mov    %eax,%edx
801055bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055c4:	83 ec 0c             	sub    $0xc,%esp
801055c7:	ff 75 f4             	push   -0xc(%ebp)
801055ca:	e8 46 c2 ff ff       	call   80101815 <iupdate>
801055cf:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801055d2:	83 ec 0c             	sub    $0xc,%esp
801055d5:	ff 75 f4             	push   -0xc(%ebp)
801055d8:	e8 28 c5 ff ff       	call   80101b05 <iunlock>
801055dd:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801055e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055e3:	83 ec 08             	sub    $0x8,%esp
801055e6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055e9:	52                   	push   %edx
801055ea:	50                   	push   %eax
801055eb:	e8 51 cf ff ff       	call   80102541 <nameiparent>
801055f0:	83 c4 10             	add    $0x10,%esp
801055f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055fa:	74 71                	je     8010566d <sys_link+0x15a>
    goto bad;
  ilock(dp);
801055fc:	83 ec 0c             	sub    $0xc,%esp
801055ff:	ff 75 f0             	push   -0x10(%ebp)
80105602:	e8 eb c3 ff ff       	call   801019f2 <ilock>
80105607:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010560a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560d:	8b 10                	mov    (%eax),%edx
8010560f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105612:	8b 00                	mov    (%eax),%eax
80105614:	39 c2                	cmp    %eax,%edx
80105616:	75 1d                	jne    80105635 <sys_link+0x122>
80105618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561b:	8b 40 04             	mov    0x4(%eax),%eax
8010561e:	83 ec 04             	sub    $0x4,%esp
80105621:	50                   	push   %eax
80105622:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105625:	50                   	push   %eax
80105626:	ff 75 f0             	push   -0x10(%ebp)
80105629:	e8 60 cc ff ff       	call   8010228e <dirlink>
8010562e:	83 c4 10             	add    $0x10,%esp
80105631:	85 c0                	test   %eax,%eax
80105633:	79 10                	jns    80105645 <sys_link+0x132>
    iunlockput(dp);
80105635:	83 ec 0c             	sub    $0xc,%esp
80105638:	ff 75 f0             	push   -0x10(%ebp)
8010563b:	e8 e3 c5 ff ff       	call   80101c23 <iunlockput>
80105640:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105643:	eb 29                	jmp    8010566e <sys_link+0x15b>
  }
  iunlockput(dp);
80105645:	83 ec 0c             	sub    $0xc,%esp
80105648:	ff 75 f0             	push   -0x10(%ebp)
8010564b:	e8 d3 c5 ff ff       	call   80101c23 <iunlockput>
80105650:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105653:	83 ec 0c             	sub    $0xc,%esp
80105656:	ff 75 f4             	push   -0xc(%ebp)
80105659:	e8 f5 c4 ff ff       	call   80101b53 <iput>
8010565e:	83 c4 10             	add    $0x10,%esp

  end_op();
80105661:	e8 64 da ff ff       	call   801030ca <end_op>

  return 0;
80105666:	b8 00 00 00 00       	mov    $0x0,%eax
8010566b:	eb 48                	jmp    801056b5 <sys_link+0x1a2>
    goto bad;
8010566d:	90                   	nop

bad:
  ilock(ip);
8010566e:	83 ec 0c             	sub    $0xc,%esp
80105671:	ff 75 f4             	push   -0xc(%ebp)
80105674:	e8 79 c3 ff ff       	call   801019f2 <ilock>
80105679:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105683:	83 e8 01             	sub    $0x1,%eax
80105686:	89 c2                	mov    %eax,%edx
80105688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010568f:	83 ec 0c             	sub    $0xc,%esp
80105692:	ff 75 f4             	push   -0xc(%ebp)
80105695:	e8 7b c1 ff ff       	call   80101815 <iupdate>
8010569a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010569d:	83 ec 0c             	sub    $0xc,%esp
801056a0:	ff 75 f4             	push   -0xc(%ebp)
801056a3:	e8 7b c5 ff ff       	call   80101c23 <iunlockput>
801056a8:	83 c4 10             	add    $0x10,%esp
  end_op();
801056ab:	e8 1a da ff ff       	call   801030ca <end_op>
  return -1;
801056b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056b5:	c9                   	leave
801056b6:	c3                   	ret

801056b7 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056bd:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801056c4:	eb 40                	jmp    80105706 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c9:	6a 10                	push   $0x10
801056cb:	50                   	push   %eax
801056cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056cf:	50                   	push   %eax
801056d0:	ff 75 08             	push   0x8(%ebp)
801056d3:	e8 06 c8 ff ff       	call   80101ede <readi>
801056d8:	83 c4 10             	add    $0x10,%esp
801056db:	83 f8 10             	cmp    $0x10,%eax
801056de:	74 0d                	je     801056ed <isdirempty+0x36>
      panic("isdirempty: readi");
801056e0:	83 ec 0c             	sub    $0xc,%esp
801056e3:	68 d4 a8 10 80       	push   $0x8010a8d4
801056e8:	e8 bc ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801056ed:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056f1:	66 85 c0             	test   %ax,%ax
801056f4:	74 07                	je     801056fd <isdirempty+0x46>
      return 0;
801056f6:	b8 00 00 00 00       	mov    $0x0,%eax
801056fb:	eb 1b                	jmp    80105718 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105700:	83 c0 10             	add    $0x10,%eax
80105703:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105706:	8b 45 08             	mov    0x8(%ebp),%eax
80105709:	8b 40 58             	mov    0x58(%eax),%eax
8010570c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010570f:	39 c2                	cmp    %eax,%edx
80105711:	72 b3                	jb     801056c6 <isdirempty+0xf>
  }
  return 1;
80105713:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105718:	c9                   	leave
80105719:	c3                   	ret

8010571a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010571a:	55                   	push   %ebp
8010571b:	89 e5                	mov    %esp,%ebp
8010571d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105720:	83 ec 08             	sub    $0x8,%esp
80105723:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105726:	50                   	push   %eax
80105727:	6a 00                	push   $0x0
80105729:	e8 a2 fa ff ff       	call   801051d0 <argstr>
8010572e:	83 c4 10             	add    $0x10,%esp
80105731:	85 c0                	test   %eax,%eax
80105733:	79 0a                	jns    8010573f <sys_unlink+0x25>
    return -1;
80105735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010573a:	e9 bf 01 00 00       	jmp    801058fe <sys_unlink+0x1e4>

  begin_op();
8010573f:	e8 fa d8 ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105744:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105747:	83 ec 08             	sub    $0x8,%esp
8010574a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010574d:	52                   	push   %edx
8010574e:	50                   	push   %eax
8010574f:	e8 ed cd ff ff       	call   80102541 <nameiparent>
80105754:	83 c4 10             	add    $0x10,%esp
80105757:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010575a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010575e:	75 0f                	jne    8010576f <sys_unlink+0x55>
    end_op();
80105760:	e8 65 d9 ff ff       	call   801030ca <end_op>
    return -1;
80105765:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576a:	e9 8f 01 00 00       	jmp    801058fe <sys_unlink+0x1e4>
  }

  ilock(dp);
8010576f:	83 ec 0c             	sub    $0xc,%esp
80105772:	ff 75 f4             	push   -0xc(%ebp)
80105775:	e8 78 c2 ff ff       	call   801019f2 <ilock>
8010577a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010577d:	83 ec 08             	sub    $0x8,%esp
80105780:	68 e6 a8 10 80       	push   $0x8010a8e6
80105785:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105788:	50                   	push   %eax
80105789:	e8 2b ca ff ff       	call   801021b9 <namecmp>
8010578e:	83 c4 10             	add    $0x10,%esp
80105791:	85 c0                	test   %eax,%eax
80105793:	0f 84 49 01 00 00    	je     801058e2 <sys_unlink+0x1c8>
80105799:	83 ec 08             	sub    $0x8,%esp
8010579c:	68 e8 a8 10 80       	push   $0x8010a8e8
801057a1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057a4:	50                   	push   %eax
801057a5:	e8 0f ca ff ff       	call   801021b9 <namecmp>
801057aa:	83 c4 10             	add    $0x10,%esp
801057ad:	85 c0                	test   %eax,%eax
801057af:	0f 84 2d 01 00 00    	je     801058e2 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057b5:	83 ec 04             	sub    $0x4,%esp
801057b8:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057bb:	50                   	push   %eax
801057bc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057bf:	50                   	push   %eax
801057c0:	ff 75 f4             	push   -0xc(%ebp)
801057c3:	e8 0c ca ff ff       	call   801021d4 <dirlookup>
801057c8:	83 c4 10             	add    $0x10,%esp
801057cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057d2:	0f 84 0d 01 00 00    	je     801058e5 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801057d8:	83 ec 0c             	sub    $0xc,%esp
801057db:	ff 75 f0             	push   -0x10(%ebp)
801057de:	e8 0f c2 ff ff       	call   801019f2 <ilock>
801057e3:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801057e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057ed:	66 85 c0             	test   %ax,%ax
801057f0:	7f 0d                	jg     801057ff <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801057f2:	83 ec 0c             	sub    $0xc,%esp
801057f5:	68 eb a8 10 80       	push   $0x8010a8eb
801057fa:	e8 aa ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801057ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105802:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105806:	66 83 f8 01          	cmp    $0x1,%ax
8010580a:	75 25                	jne    80105831 <sys_unlink+0x117>
8010580c:	83 ec 0c             	sub    $0xc,%esp
8010580f:	ff 75 f0             	push   -0x10(%ebp)
80105812:	e8 a0 fe ff ff       	call   801056b7 <isdirempty>
80105817:	83 c4 10             	add    $0x10,%esp
8010581a:	85 c0                	test   %eax,%eax
8010581c:	75 13                	jne    80105831 <sys_unlink+0x117>
    iunlockput(ip);
8010581e:	83 ec 0c             	sub    $0xc,%esp
80105821:	ff 75 f0             	push   -0x10(%ebp)
80105824:	e8 fa c3 ff ff       	call   80101c23 <iunlockput>
80105829:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010582c:	e9 b5 00 00 00       	jmp    801058e6 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105831:	83 ec 04             	sub    $0x4,%esp
80105834:	6a 10                	push   $0x10
80105836:	6a 00                	push   $0x0
80105838:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010583b:	50                   	push   %eax
8010583c:	e8 cf f5 ff ff       	call   80104e10 <memset>
80105841:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105844:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105847:	6a 10                	push   $0x10
80105849:	50                   	push   %eax
8010584a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010584d:	50                   	push   %eax
8010584e:	ff 75 f4             	push   -0xc(%ebp)
80105851:	e8 dd c7 ff ff       	call   80102033 <writei>
80105856:	83 c4 10             	add    $0x10,%esp
80105859:	83 f8 10             	cmp    $0x10,%eax
8010585c:	74 0d                	je     8010586b <sys_unlink+0x151>
    panic("unlink: writei");
8010585e:	83 ec 0c             	sub    $0xc,%esp
80105861:	68 fd a8 10 80       	push   $0x8010a8fd
80105866:	e8 3e ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
8010586b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105872:	66 83 f8 01          	cmp    $0x1,%ax
80105876:	75 21                	jne    80105899 <sys_unlink+0x17f>
    dp->nlink--;
80105878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010587f:	83 e8 01             	sub    $0x1,%eax
80105882:	89 c2                	mov    %eax,%edx
80105884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105887:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010588b:	83 ec 0c             	sub    $0xc,%esp
8010588e:	ff 75 f4             	push   -0xc(%ebp)
80105891:	e8 7f bf ff ff       	call   80101815 <iupdate>
80105896:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105899:	83 ec 0c             	sub    $0xc,%esp
8010589c:	ff 75 f4             	push   -0xc(%ebp)
8010589f:	e8 7f c3 ff ff       	call   80101c23 <iunlockput>
801058a4:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058aa:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058ae:	83 e8 01             	sub    $0x1,%eax
801058b1:	89 c2                	mov    %eax,%edx
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801058ba:	83 ec 0c             	sub    $0xc,%esp
801058bd:	ff 75 f0             	push   -0x10(%ebp)
801058c0:	e8 50 bf ff ff       	call   80101815 <iupdate>
801058c5:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801058c8:	83 ec 0c             	sub    $0xc,%esp
801058cb:	ff 75 f0             	push   -0x10(%ebp)
801058ce:	e8 50 c3 ff ff       	call   80101c23 <iunlockput>
801058d3:	83 c4 10             	add    $0x10,%esp

  end_op();
801058d6:	e8 ef d7 ff ff       	call   801030ca <end_op>

  return 0;
801058db:	b8 00 00 00 00       	mov    $0x0,%eax
801058e0:	eb 1c                	jmp    801058fe <sys_unlink+0x1e4>
    goto bad;
801058e2:	90                   	nop
801058e3:	eb 01                	jmp    801058e6 <sys_unlink+0x1cc>
    goto bad;
801058e5:	90                   	nop

bad:
  iunlockput(dp);
801058e6:	83 ec 0c             	sub    $0xc,%esp
801058e9:	ff 75 f4             	push   -0xc(%ebp)
801058ec:	e8 32 c3 ff ff       	call   80101c23 <iunlockput>
801058f1:	83 c4 10             	add    $0x10,%esp
  end_op();
801058f4:	e8 d1 d7 ff ff       	call   801030ca <end_op>
  return -1;
801058f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058fe:	c9                   	leave
801058ff:	c3                   	ret

80105900 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
80105903:	83 ec 38             	sub    $0x38,%esp
80105906:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105909:	8b 55 10             	mov    0x10(%ebp),%edx
8010590c:	8b 45 14             	mov    0x14(%ebp),%eax
8010590f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105913:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105917:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010591b:	83 ec 08             	sub    $0x8,%esp
8010591e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105921:	50                   	push   %eax
80105922:	ff 75 08             	push   0x8(%ebp)
80105925:	e8 17 cc ff ff       	call   80102541 <nameiparent>
8010592a:	83 c4 10             	add    $0x10,%esp
8010592d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105930:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105934:	75 0a                	jne    80105940 <create+0x40>
    return 0;
80105936:	b8 00 00 00 00       	mov    $0x0,%eax
8010593b:	e9 90 01 00 00       	jmp    80105ad0 <create+0x1d0>
  ilock(dp);
80105940:	83 ec 0c             	sub    $0xc,%esp
80105943:	ff 75 f4             	push   -0xc(%ebp)
80105946:	e8 a7 c0 ff ff       	call   801019f2 <ilock>
8010594b:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010594e:	83 ec 04             	sub    $0x4,%esp
80105951:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105954:	50                   	push   %eax
80105955:	8d 45 de             	lea    -0x22(%ebp),%eax
80105958:	50                   	push   %eax
80105959:	ff 75 f4             	push   -0xc(%ebp)
8010595c:	e8 73 c8 ff ff       	call   801021d4 <dirlookup>
80105961:	83 c4 10             	add    $0x10,%esp
80105964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010596b:	74 50                	je     801059bd <create+0xbd>
    iunlockput(dp);
8010596d:	83 ec 0c             	sub    $0xc,%esp
80105970:	ff 75 f4             	push   -0xc(%ebp)
80105973:	e8 ab c2 ff ff       	call   80101c23 <iunlockput>
80105978:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010597b:	83 ec 0c             	sub    $0xc,%esp
8010597e:	ff 75 f0             	push   -0x10(%ebp)
80105981:	e8 6c c0 ff ff       	call   801019f2 <ilock>
80105986:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105989:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010598e:	75 15                	jne    801059a5 <create+0xa5>
80105990:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105993:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105997:	66 83 f8 02          	cmp    $0x2,%ax
8010599b:	75 08                	jne    801059a5 <create+0xa5>
      return ip;
8010599d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a0:	e9 2b 01 00 00       	jmp    80105ad0 <create+0x1d0>
    iunlockput(ip);
801059a5:	83 ec 0c             	sub    $0xc,%esp
801059a8:	ff 75 f0             	push   -0x10(%ebp)
801059ab:	e8 73 c2 ff ff       	call   80101c23 <iunlockput>
801059b0:	83 c4 10             	add    $0x10,%esp
    return 0;
801059b3:	b8 00 00 00 00       	mov    $0x0,%eax
801059b8:	e9 13 01 00 00       	jmp    80105ad0 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801059bd:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801059c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c4:	8b 00                	mov    (%eax),%eax
801059c6:	83 ec 08             	sub    $0x8,%esp
801059c9:	52                   	push   %edx
801059ca:	50                   	push   %eax
801059cb:	e8 6f bd ff ff       	call   8010173f <ialloc>
801059d0:	83 c4 10             	add    $0x10,%esp
801059d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059da:	75 0d                	jne    801059e9 <create+0xe9>
    panic("create: ialloc");
801059dc:	83 ec 0c             	sub    $0xc,%esp
801059df:	68 0c a9 10 80       	push   $0x8010a90c
801059e4:	e8 c0 ab ff ff       	call   801005a9 <panic>

  ilock(ip);
801059e9:	83 ec 0c             	sub    $0xc,%esp
801059ec:	ff 75 f0             	push   -0x10(%ebp)
801059ef:	e8 fe bf ff ff       	call   801019f2 <ilock>
801059f4:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801059f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fa:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801059fe:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a05:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a09:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a10:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a16:	83 ec 0c             	sub    $0xc,%esp
80105a19:	ff 75 f0             	push   -0x10(%ebp)
80105a1c:	e8 f4 bd ff ff       	call   80101815 <iupdate>
80105a21:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a24:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a29:	75 6a                	jne    80105a95 <create+0x195>
    dp->nlink++;  // for ".."
80105a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a32:	83 c0 01             	add    $0x1,%eax
80105a35:	89 c2                	mov    %eax,%edx
80105a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a3e:	83 ec 0c             	sub    $0xc,%esp
80105a41:	ff 75 f4             	push   -0xc(%ebp)
80105a44:	e8 cc bd ff ff       	call   80101815 <iupdate>
80105a49:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4f:	8b 40 04             	mov    0x4(%eax),%eax
80105a52:	83 ec 04             	sub    $0x4,%esp
80105a55:	50                   	push   %eax
80105a56:	68 e6 a8 10 80       	push   $0x8010a8e6
80105a5b:	ff 75 f0             	push   -0x10(%ebp)
80105a5e:	e8 2b c8 ff ff       	call   8010228e <dirlink>
80105a63:	83 c4 10             	add    $0x10,%esp
80105a66:	85 c0                	test   %eax,%eax
80105a68:	78 1e                	js     80105a88 <create+0x188>
80105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6d:	8b 40 04             	mov    0x4(%eax),%eax
80105a70:	83 ec 04             	sub    $0x4,%esp
80105a73:	50                   	push   %eax
80105a74:	68 e8 a8 10 80       	push   $0x8010a8e8
80105a79:	ff 75 f0             	push   -0x10(%ebp)
80105a7c:	e8 0d c8 ff ff       	call   8010228e <dirlink>
80105a81:	83 c4 10             	add    $0x10,%esp
80105a84:	85 c0                	test   %eax,%eax
80105a86:	79 0d                	jns    80105a95 <create+0x195>
      panic("create dots");
80105a88:	83 ec 0c             	sub    $0xc,%esp
80105a8b:	68 1b a9 10 80       	push   $0x8010a91b
80105a90:	e8 14 ab ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a98:	8b 40 04             	mov    0x4(%eax),%eax
80105a9b:	83 ec 04             	sub    $0x4,%esp
80105a9e:	50                   	push   %eax
80105a9f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105aa2:	50                   	push   %eax
80105aa3:	ff 75 f4             	push   -0xc(%ebp)
80105aa6:	e8 e3 c7 ff ff       	call   8010228e <dirlink>
80105aab:	83 c4 10             	add    $0x10,%esp
80105aae:	85 c0                	test   %eax,%eax
80105ab0:	79 0d                	jns    80105abf <create+0x1bf>
    panic("create: dirlink");
80105ab2:	83 ec 0c             	sub    $0xc,%esp
80105ab5:	68 27 a9 10 80       	push   $0x8010a927
80105aba:	e8 ea aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105abf:	83 ec 0c             	sub    $0xc,%esp
80105ac2:	ff 75 f4             	push   -0xc(%ebp)
80105ac5:	e8 59 c1 ff ff       	call   80101c23 <iunlockput>
80105aca:	83 c4 10             	add    $0x10,%esp

  return ip;
80105acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ad0:	c9                   	leave
80105ad1:	c3                   	ret

80105ad2 <sys_open>:

int
sys_open(void)
{
80105ad2:	55                   	push   %ebp
80105ad3:	89 e5                	mov    %esp,%ebp
80105ad5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ad8:	83 ec 08             	sub    $0x8,%esp
80105adb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ade:	50                   	push   %eax
80105adf:	6a 00                	push   $0x0
80105ae1:	e8 ea f6 ff ff       	call   801051d0 <argstr>
80105ae6:	83 c4 10             	add    $0x10,%esp
80105ae9:	85 c0                	test   %eax,%eax
80105aeb:	78 15                	js     80105b02 <sys_open+0x30>
80105aed:	83 ec 08             	sub    $0x8,%esp
80105af0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105af3:	50                   	push   %eax
80105af4:	6a 01                	push   $0x1
80105af6:	e8 40 f6 ff ff       	call   8010513b <argint>
80105afb:	83 c4 10             	add    $0x10,%esp
80105afe:	85 c0                	test   %eax,%eax
80105b00:	79 0a                	jns    80105b0c <sys_open+0x3a>
    return -1;
80105b02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b07:	e9 61 01 00 00       	jmp    80105c6d <sys_open+0x19b>

  begin_op();
80105b0c:	e8 2d d5 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80105b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b14:	25 00 02 00 00       	and    $0x200,%eax
80105b19:	85 c0                	test   %eax,%eax
80105b1b:	74 2a                	je     80105b47 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b20:	6a 00                	push   $0x0
80105b22:	6a 00                	push   $0x0
80105b24:	6a 02                	push   $0x2
80105b26:	50                   	push   %eax
80105b27:	e8 d4 fd ff ff       	call   80105900 <create>
80105b2c:	83 c4 10             	add    $0x10,%esp
80105b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b36:	75 75                	jne    80105bad <sys_open+0xdb>
      end_op();
80105b38:	e8 8d d5 ff ff       	call   801030ca <end_op>
      return -1;
80105b3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b42:	e9 26 01 00 00       	jmp    80105c6d <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b4a:	83 ec 0c             	sub    $0xc,%esp
80105b4d:	50                   	push   %eax
80105b4e:	e8 d2 c9 ff ff       	call   80102525 <namei>
80105b53:	83 c4 10             	add    $0x10,%esp
80105b56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b5d:	75 0f                	jne    80105b6e <sys_open+0x9c>
      end_op();
80105b5f:	e8 66 d5 ff ff       	call   801030ca <end_op>
      return -1;
80105b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b69:	e9 ff 00 00 00       	jmp    80105c6d <sys_open+0x19b>
    }
    ilock(ip);
80105b6e:	83 ec 0c             	sub    $0xc,%esp
80105b71:	ff 75 f4             	push   -0xc(%ebp)
80105b74:	e8 79 be ff ff       	call   801019f2 <ilock>
80105b79:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b83:	66 83 f8 01          	cmp    $0x1,%ax
80105b87:	75 24                	jne    80105bad <sys_open+0xdb>
80105b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b8c:	85 c0                	test   %eax,%eax
80105b8e:	74 1d                	je     80105bad <sys_open+0xdb>
      iunlockput(ip);
80105b90:	83 ec 0c             	sub    $0xc,%esp
80105b93:	ff 75 f4             	push   -0xc(%ebp)
80105b96:	e8 88 c0 ff ff       	call   80101c23 <iunlockput>
80105b9b:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b9e:	e8 27 d5 ff ff       	call   801030ca <end_op>
      return -1;
80105ba3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba8:	e9 c0 00 00 00       	jmp    80105c6d <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105bad:	e8 35 b4 ff ff       	call   80100fe7 <filealloc>
80105bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bb9:	74 17                	je     80105bd2 <sys_open+0x100>
80105bbb:	83 ec 0c             	sub    $0xc,%esp
80105bbe:	ff 75 f0             	push   -0x10(%ebp)
80105bc1:	e8 33 f7 ff ff       	call   801052f9 <fdalloc>
80105bc6:	83 c4 10             	add    $0x10,%esp
80105bc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105bcc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105bd0:	79 2e                	jns    80105c00 <sys_open+0x12e>
    if(f)
80105bd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bd6:	74 0e                	je     80105be6 <sys_open+0x114>
      fileclose(f);
80105bd8:	83 ec 0c             	sub    $0xc,%esp
80105bdb:	ff 75 f0             	push   -0x10(%ebp)
80105bde:	e8 c2 b4 ff ff       	call   801010a5 <fileclose>
80105be3:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105be6:	83 ec 0c             	sub    $0xc,%esp
80105be9:	ff 75 f4             	push   -0xc(%ebp)
80105bec:	e8 32 c0 ff ff       	call   80101c23 <iunlockput>
80105bf1:	83 c4 10             	add    $0x10,%esp
    end_op();
80105bf4:	e8 d1 d4 ff ff       	call   801030ca <end_op>
    return -1;
80105bf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfe:	eb 6d                	jmp    80105c6d <sys_open+0x19b>
  }
  iunlock(ip);
80105c00:	83 ec 0c             	sub    $0xc,%esp
80105c03:	ff 75 f4             	push   -0xc(%ebp)
80105c06:	e8 fa be ff ff       	call   80101b05 <iunlock>
80105c0b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c0e:	e8 b7 d4 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
80105c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c16:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c22:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c28:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c32:	83 e0 01             	and    $0x1,%eax
80105c35:	85 c0                	test   %eax,%eax
80105c37:	0f 94 c0             	sete   %al
80105c3a:	89 c2                	mov    %eax,%edx
80105c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c45:	83 e0 01             	and    $0x1,%eax
80105c48:	85 c0                	test   %eax,%eax
80105c4a:	75 0a                	jne    80105c56 <sys_open+0x184>
80105c4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c4f:	83 e0 02             	and    $0x2,%eax
80105c52:	85 c0                	test   %eax,%eax
80105c54:	74 07                	je     80105c5d <sys_open+0x18b>
80105c56:	b8 01 00 00 00       	mov    $0x1,%eax
80105c5b:	eb 05                	jmp    80105c62 <sys_open+0x190>
80105c5d:	b8 00 00 00 00       	mov    $0x0,%eax
80105c62:	89 c2                	mov    %eax,%edx
80105c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c67:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c6d:	c9                   	leave
80105c6e:	c3                   	ret

80105c6f <sys_mkdir>:

int
sys_mkdir(void)
{
80105c6f:	55                   	push   %ebp
80105c70:	89 e5                	mov    %esp,%ebp
80105c72:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c75:	e8 c4 d3 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c7a:	83 ec 08             	sub    $0x8,%esp
80105c7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c80:	50                   	push   %eax
80105c81:	6a 00                	push   $0x0
80105c83:	e8 48 f5 ff ff       	call   801051d0 <argstr>
80105c88:	83 c4 10             	add    $0x10,%esp
80105c8b:	85 c0                	test   %eax,%eax
80105c8d:	78 1b                	js     80105caa <sys_mkdir+0x3b>
80105c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c92:	6a 00                	push   $0x0
80105c94:	6a 00                	push   $0x0
80105c96:	6a 01                	push   $0x1
80105c98:	50                   	push   %eax
80105c99:	e8 62 fc ff ff       	call   80105900 <create>
80105c9e:	83 c4 10             	add    $0x10,%esp
80105ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ca4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ca8:	75 0c                	jne    80105cb6 <sys_mkdir+0x47>
    end_op();
80105caa:	e8 1b d4 ff ff       	call   801030ca <end_op>
    return -1;
80105caf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb4:	eb 18                	jmp    80105cce <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105cb6:	83 ec 0c             	sub    $0xc,%esp
80105cb9:	ff 75 f4             	push   -0xc(%ebp)
80105cbc:	e8 62 bf ff ff       	call   80101c23 <iunlockput>
80105cc1:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cc4:	e8 01 d4 ff ff       	call   801030ca <end_op>
  return 0;
80105cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cce:	c9                   	leave
80105ccf:	c3                   	ret

80105cd0 <sys_mknod>:

int
sys_mknod(void)
{
80105cd0:	55                   	push   %ebp
80105cd1:	89 e5                	mov    %esp,%ebp
80105cd3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105cd6:	e8 63 d3 ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
80105cdb:	83 ec 08             	sub    $0x8,%esp
80105cde:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ce1:	50                   	push   %eax
80105ce2:	6a 00                	push   $0x0
80105ce4:	e8 e7 f4 ff ff       	call   801051d0 <argstr>
80105ce9:	83 c4 10             	add    $0x10,%esp
80105cec:	85 c0                	test   %eax,%eax
80105cee:	78 4f                	js     80105d3f <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105cf0:	83 ec 08             	sub    $0x8,%esp
80105cf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cf6:	50                   	push   %eax
80105cf7:	6a 01                	push   $0x1
80105cf9:	e8 3d f4 ff ff       	call   8010513b <argint>
80105cfe:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d01:	85 c0                	test   %eax,%eax
80105d03:	78 3a                	js     80105d3f <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d05:	83 ec 08             	sub    $0x8,%esp
80105d08:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d0b:	50                   	push   %eax
80105d0c:	6a 02                	push   $0x2
80105d0e:	e8 28 f4 ff ff       	call   8010513b <argint>
80105d13:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d16:	85 c0                	test   %eax,%eax
80105d18:	78 25                	js     80105d3f <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d1d:	0f bf c8             	movswl %ax,%ecx
80105d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d23:	0f bf d0             	movswl %ax,%edx
80105d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d29:	51                   	push   %ecx
80105d2a:	52                   	push   %edx
80105d2b:	6a 03                	push   $0x3
80105d2d:	50                   	push   %eax
80105d2e:	e8 cd fb ff ff       	call   80105900 <create>
80105d33:	83 c4 10             	add    $0x10,%esp
80105d36:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d3d:	75 0c                	jne    80105d4b <sys_mknod+0x7b>
    end_op();
80105d3f:	e8 86 d3 ff ff       	call   801030ca <end_op>
    return -1;
80105d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d49:	eb 18                	jmp    80105d63 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105d4b:	83 ec 0c             	sub    $0xc,%esp
80105d4e:	ff 75 f4             	push   -0xc(%ebp)
80105d51:	e8 cd be ff ff       	call   80101c23 <iunlockput>
80105d56:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d59:	e8 6c d3 ff ff       	call   801030ca <end_op>
  return 0;
80105d5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d63:	c9                   	leave
80105d64:	c3                   	ret

80105d65 <sys_chdir>:

int
sys_chdir(void)
{
80105d65:	55                   	push   %ebp
80105d66:	89 e5                	mov    %esp,%ebp
80105d68:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105d6b:	e8 c7 dc ff ff       	call   80103a37 <myproc>
80105d70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105d73:	e8 c6 d2 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d78:	83 ec 08             	sub    $0x8,%esp
80105d7b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d7e:	50                   	push   %eax
80105d7f:	6a 00                	push   $0x0
80105d81:	e8 4a f4 ff ff       	call   801051d0 <argstr>
80105d86:	83 c4 10             	add    $0x10,%esp
80105d89:	85 c0                	test   %eax,%eax
80105d8b:	78 18                	js     80105da5 <sys_chdir+0x40>
80105d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d90:	83 ec 0c             	sub    $0xc,%esp
80105d93:	50                   	push   %eax
80105d94:	e8 8c c7 ff ff       	call   80102525 <namei>
80105d99:	83 c4 10             	add    $0x10,%esp
80105d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105da3:	75 0c                	jne    80105db1 <sys_chdir+0x4c>
    end_op();
80105da5:	e8 20 d3 ff ff       	call   801030ca <end_op>
    return -1;
80105daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105daf:	eb 68                	jmp    80105e19 <sys_chdir+0xb4>
  }
  ilock(ip);
80105db1:	83 ec 0c             	sub    $0xc,%esp
80105db4:	ff 75 f0             	push   -0x10(%ebp)
80105db7:	e8 36 bc ff ff       	call   801019f2 <ilock>
80105dbc:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dc6:	66 83 f8 01          	cmp    $0x1,%ax
80105dca:	74 1a                	je     80105de6 <sys_chdir+0x81>
    iunlockput(ip);
80105dcc:	83 ec 0c             	sub    $0xc,%esp
80105dcf:	ff 75 f0             	push   -0x10(%ebp)
80105dd2:	e8 4c be ff ff       	call   80101c23 <iunlockput>
80105dd7:	83 c4 10             	add    $0x10,%esp
    end_op();
80105dda:	e8 eb d2 ff ff       	call   801030ca <end_op>
    return -1;
80105ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de4:	eb 33                	jmp    80105e19 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105de6:	83 ec 0c             	sub    $0xc,%esp
80105de9:	ff 75 f0             	push   -0x10(%ebp)
80105dec:	e8 14 bd ff ff       	call   80101b05 <iunlock>
80105df1:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df7:	8b 40 68             	mov    0x68(%eax),%eax
80105dfa:	83 ec 0c             	sub    $0xc,%esp
80105dfd:	50                   	push   %eax
80105dfe:	e8 50 bd ff ff       	call   80101b53 <iput>
80105e03:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e06:	e8 bf d2 ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
80105e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e11:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e19:	c9                   	leave
80105e1a:	c3                   	ret

80105e1b <sys_exec>:

int
sys_exec(void)
{
80105e1b:	55                   	push   %ebp
80105e1c:	89 e5                	mov    %esp,%ebp
80105e1e:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e24:	83 ec 08             	sub    $0x8,%esp
80105e27:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e2a:	50                   	push   %eax
80105e2b:	6a 00                	push   $0x0
80105e2d:	e8 9e f3 ff ff       	call   801051d0 <argstr>
80105e32:	83 c4 10             	add    $0x10,%esp
80105e35:	85 c0                	test   %eax,%eax
80105e37:	78 18                	js     80105e51 <sys_exec+0x36>
80105e39:	83 ec 08             	sub    $0x8,%esp
80105e3c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e42:	50                   	push   %eax
80105e43:	6a 01                	push   $0x1
80105e45:	e8 f1 f2 ff ff       	call   8010513b <argint>
80105e4a:	83 c4 10             	add    $0x10,%esp
80105e4d:	85 c0                	test   %eax,%eax
80105e4f:	79 0a                	jns    80105e5b <sys_exec+0x40>
    return -1;
80105e51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e56:	e9 c6 00 00 00       	jmp    80105f21 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105e5b:	83 ec 04             	sub    $0x4,%esp
80105e5e:	68 80 00 00 00       	push   $0x80
80105e63:	6a 00                	push   $0x0
80105e65:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e6b:	50                   	push   %eax
80105e6c:	e8 9f ef ff ff       	call   80104e10 <memset>
80105e71:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7e:	83 f8 1f             	cmp    $0x1f,%eax
80105e81:	76 0a                	jbe    80105e8d <sys_exec+0x72>
      return -1;
80105e83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e88:	e9 94 00 00 00       	jmp    80105f21 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e90:	c1 e0 02             	shl    $0x2,%eax
80105e93:	89 c2                	mov    %eax,%edx
80105e95:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e9b:	01 c2                	add    %eax,%edx
80105e9d:	83 ec 08             	sub    $0x8,%esp
80105ea0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ea6:	50                   	push   %eax
80105ea7:	52                   	push   %edx
80105ea8:	e8 ed f1 ff ff       	call   8010509a <fetchint>
80105ead:	83 c4 10             	add    $0x10,%esp
80105eb0:	85 c0                	test   %eax,%eax
80105eb2:	79 07                	jns    80105ebb <sys_exec+0xa0>
      return -1;
80105eb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb9:	eb 66                	jmp    80105f21 <sys_exec+0x106>
    if(uarg == 0){
80105ebb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	75 27                	jne    80105eec <sys_exec+0xd1>
      argv[i] = 0;
80105ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ecf:	00 00 00 00 
      break;
80105ed3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed7:	83 ec 08             	sub    $0x8,%esp
80105eda:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ee0:	52                   	push   %edx
80105ee1:	50                   	push   %eax
80105ee2:	e8 a3 ac ff ff       	call   80100b8a <exec>
80105ee7:	83 c4 10             	add    $0x10,%esp
80105eea:	eb 35                	jmp    80105f21 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105eec:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ef2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ef5:	c1 e2 02             	shl    $0x2,%edx
80105ef8:	01 c2                	add    %eax,%edx
80105efa:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f00:	83 ec 08             	sub    $0x8,%esp
80105f03:	52                   	push   %edx
80105f04:	50                   	push   %eax
80105f05:	e8 cf f1 ff ff       	call   801050d9 <fetchstr>
80105f0a:	83 c4 10             	add    $0x10,%esp
80105f0d:	85 c0                	test   %eax,%eax
80105f0f:	79 07                	jns    80105f18 <sys_exec+0xfd>
      return -1;
80105f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f16:	eb 09                	jmp    80105f21 <sys_exec+0x106>
  for(i=0;; i++){
80105f18:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f1c:	e9 5a ff ff ff       	jmp    80105e7b <sys_exec+0x60>
}
80105f21:	c9                   	leave
80105f22:	c3                   	ret

80105f23 <sys_pipe>:

int
sys_pipe(void)
{
80105f23:	55                   	push   %ebp
80105f24:	89 e5                	mov    %esp,%ebp
80105f26:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f29:	83 ec 04             	sub    $0x4,%esp
80105f2c:	6a 08                	push   $0x8
80105f2e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f31:	50                   	push   %eax
80105f32:	6a 00                	push   $0x0
80105f34:	e8 2f f2 ff ff       	call   80105168 <argptr>
80105f39:	83 c4 10             	add    $0x10,%esp
80105f3c:	85 c0                	test   %eax,%eax
80105f3e:	79 0a                	jns    80105f4a <sys_pipe+0x27>
    return -1;
80105f40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f45:	e9 ae 00 00 00       	jmp    80105ff8 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105f4a:	83 ec 08             	sub    $0x8,%esp
80105f4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f50:	50                   	push   %eax
80105f51:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f54:	50                   	push   %eax
80105f55:	e8 13 d6 ff ff       	call   8010356d <pipealloc>
80105f5a:	83 c4 10             	add    $0x10,%esp
80105f5d:	85 c0                	test   %eax,%eax
80105f5f:	79 0a                	jns    80105f6b <sys_pipe+0x48>
    return -1;
80105f61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f66:	e9 8d 00 00 00       	jmp    80105ff8 <sys_pipe+0xd5>
  fd0 = -1;
80105f6b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f75:	83 ec 0c             	sub    $0xc,%esp
80105f78:	50                   	push   %eax
80105f79:	e8 7b f3 ff ff       	call   801052f9 <fdalloc>
80105f7e:	83 c4 10             	add    $0x10,%esp
80105f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f88:	78 18                	js     80105fa2 <sys_pipe+0x7f>
80105f8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f8d:	83 ec 0c             	sub    $0xc,%esp
80105f90:	50                   	push   %eax
80105f91:	e8 63 f3 ff ff       	call   801052f9 <fdalloc>
80105f96:	83 c4 10             	add    $0x10,%esp
80105f99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa0:	79 3e                	jns    80105fe0 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105fa2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fa6:	78 13                	js     80105fbb <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105fa8:	e8 8a da ff ff       	call   80103a37 <myproc>
80105fad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fb0:	83 c2 08             	add    $0x8,%edx
80105fb3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105fba:	00 
    fileclose(rf);
80105fbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fbe:	83 ec 0c             	sub    $0xc,%esp
80105fc1:	50                   	push   %eax
80105fc2:	e8 de b0 ff ff       	call   801010a5 <fileclose>
80105fc7:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105fca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fcd:	83 ec 0c             	sub    $0xc,%esp
80105fd0:	50                   	push   %eax
80105fd1:	e8 cf b0 ff ff       	call   801010a5 <fileclose>
80105fd6:	83 c4 10             	add    $0x10,%esp
    return -1;
80105fd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fde:	eb 18                	jmp    80105ff8 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105fe0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fe3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fe6:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105fe8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105feb:	8d 50 04             	lea    0x4(%eax),%edx
80105fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff1:	89 02                	mov    %eax,(%edx)
  return 0;
80105ff3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ff8:	c9                   	leave
80105ff9:	c3                   	ret

80105ffa <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105ffa:	55                   	push   %ebp
80105ffb:	89 e5                	mov    %esp,%ebp
80105ffd:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106000:	e8 76 dd ff ff       	call   80103d7b <fork>
}
80106005:	c9                   	leave
80106006:	c3                   	ret

80106007 <sys_exit>:

int
sys_exit(void)
{
80106007:	55                   	push   %ebp
80106008:	89 e5                	mov    %esp,%ebp
8010600a:	83 ec 08             	sub    $0x8,%esp
  exit();
8010600d:	e8 e2 de ff ff       	call   80103ef4 <exit>
  return 0;  // not reached
80106012:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106017:	c9                   	leave
80106018:	c3                   	ret

80106019 <sys_wait>:

int
sys_wait(void)
{
80106019:	55                   	push   %ebp
8010601a:	89 e5                	mov    %esp,%ebp
8010601c:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010601f:	e8 f3 df ff ff       	call   80104017 <wait>
}
80106024:	c9                   	leave
80106025:	c3                   	ret

80106026 <sys_kill>:

int
sys_kill(void)
{
80106026:	55                   	push   %ebp
80106027:	89 e5                	mov    %esp,%ebp
80106029:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010602c:	83 ec 08             	sub    $0x8,%esp
8010602f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106032:	50                   	push   %eax
80106033:	6a 00                	push   $0x0
80106035:	e8 01 f1 ff ff       	call   8010513b <argint>
8010603a:	83 c4 10             	add    $0x10,%esp
8010603d:	85 c0                	test   %eax,%eax
8010603f:	79 07                	jns    80106048 <sys_kill+0x22>
    return -1;
80106041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106046:	eb 0f                	jmp    80106057 <sys_kill+0x31>
  return kill(pid);
80106048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604b:	83 ec 0c             	sub    $0xc,%esp
8010604e:	50                   	push   %eax
8010604f:	e8 4d e5 ff ff       	call   801045a1 <kill>
80106054:	83 c4 10             	add    $0x10,%esp
}
80106057:	c9                   	leave
80106058:	c3                   	ret

80106059 <sys_getpid>:

int
sys_getpid(void)
{
80106059:	55                   	push   %ebp
8010605a:	89 e5                	mov    %esp,%ebp
8010605c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010605f:	e8 d3 d9 ff ff       	call   80103a37 <myproc>
80106064:	8b 40 10             	mov    0x10(%eax),%eax
}
80106067:	c9                   	leave
80106068:	c3                   	ret

80106069 <sys_sbrk>:

int
sys_sbrk(void)
{
80106069:	55                   	push   %ebp
8010606a:	89 e5                	mov    %esp,%ebp
8010606c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010606f:	83 ec 08             	sub    $0x8,%esp
80106072:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106075:	50                   	push   %eax
80106076:	6a 00                	push   $0x0
80106078:	e8 be f0 ff ff       	call   8010513b <argint>
8010607d:	83 c4 10             	add    $0x10,%esp
80106080:	85 c0                	test   %eax,%eax
80106082:	79 07                	jns    8010608b <sys_sbrk+0x22>
    return -1;
80106084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106089:	eb 27                	jmp    801060b2 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010608b:	e8 a7 d9 ff ff       	call   80103a37 <myproc>
80106090:	8b 00                	mov    (%eax),%eax
80106092:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106095:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106098:	83 ec 0c             	sub    $0xc,%esp
8010609b:	50                   	push   %eax
8010609c:	e8 3f dc ff ff       	call   80103ce0 <growproc>
801060a1:	83 c4 10             	add    $0x10,%esp
801060a4:	85 c0                	test   %eax,%eax
801060a6:	79 07                	jns    801060af <sys_sbrk+0x46>
    return -1;
801060a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ad:	eb 03                	jmp    801060b2 <sys_sbrk+0x49>
  return addr;
801060af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060b2:	c9                   	leave
801060b3:	c3                   	ret

801060b4 <sys_sleep>:

int
sys_sleep(void)
{
801060b4:	55                   	push   %ebp
801060b5:	89 e5                	mov    %esp,%ebp
801060b7:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060ba:	83 ec 08             	sub    $0x8,%esp
801060bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c0:	50                   	push   %eax
801060c1:	6a 00                	push   $0x0
801060c3:	e8 73 f0 ff ff       	call   8010513b <argint>
801060c8:	83 c4 10             	add    $0x10,%esp
801060cb:	85 c0                	test   %eax,%eax
801060cd:	79 07                	jns    801060d6 <sys_sleep+0x22>
    return -1;
801060cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d4:	eb 76                	jmp    8010614c <sys_sleep+0x98>
  acquire(&tickslock);
801060d6:	83 ec 0c             	sub    $0xc,%esp
801060d9:	68 40 74 19 80       	push   $0x80197440
801060de:	e8 b7 ea ff ff       	call   80104b9a <acquire>
801060e3:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060e6:	a1 74 74 19 80       	mov    0x80197474,%eax
801060eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801060ee:	eb 38                	jmp    80106128 <sys_sleep+0x74>
    if(myproc()->killed){
801060f0:	e8 42 d9 ff ff       	call   80103a37 <myproc>
801060f5:	8b 40 24             	mov    0x24(%eax),%eax
801060f8:	85 c0                	test   %eax,%eax
801060fa:	74 17                	je     80106113 <sys_sleep+0x5f>
      release(&tickslock);
801060fc:	83 ec 0c             	sub    $0xc,%esp
801060ff:	68 40 74 19 80       	push   $0x80197440
80106104:	e8 ff ea ff ff       	call   80104c08 <release>
80106109:	83 c4 10             	add    $0x10,%esp
      return -1;
8010610c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106111:	eb 39                	jmp    8010614c <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106113:	83 ec 08             	sub    $0x8,%esp
80106116:	68 40 74 19 80       	push   $0x80197440
8010611b:	68 74 74 19 80       	push   $0x80197474
80106120:	e8 5b e3 ff ff       	call   80104480 <sleep>
80106125:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106128:	a1 74 74 19 80       	mov    0x80197474,%eax
8010612d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106130:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106133:	39 d0                	cmp    %edx,%eax
80106135:	72 b9                	jb     801060f0 <sys_sleep+0x3c>
  }
  release(&tickslock);
80106137:	83 ec 0c             	sub    $0xc,%esp
8010613a:	68 40 74 19 80       	push   $0x80197440
8010613f:	e8 c4 ea ff ff       	call   80104c08 <release>
80106144:	83 c4 10             	add    $0x10,%esp
  return 0;
80106147:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010614c:	c9                   	leave
8010614d:	c3                   	ret

8010614e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010614e:	55                   	push   %ebp
8010614f:	89 e5                	mov    %esp,%ebp
80106151:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106154:	83 ec 0c             	sub    $0xc,%esp
80106157:	68 40 74 19 80       	push   $0x80197440
8010615c:	e8 39 ea ff ff       	call   80104b9a <acquire>
80106161:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106164:	a1 74 74 19 80       	mov    0x80197474,%eax
80106169:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010616c:	83 ec 0c             	sub    $0xc,%esp
8010616f:	68 40 74 19 80       	push   $0x80197440
80106174:	e8 8f ea ff ff       	call   80104c08 <release>
80106179:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010617c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010617f:	c9                   	leave
80106180:	c3                   	ret

80106181 <sys_uthread_init>:

int
sys_uthread_init(void)
{
80106181:	55                   	push   %ebp
80106182:	89 e5                	mov    %esp,%ebp
80106184:	53                   	push   %ebx
80106185:	83 ec 14             	sub    $0x14,%esp
  int sched;
  //사용자로부터 전달된 첫 번째 인자 (scheduler 함수 주소)를 읽어옴
  // 실패시 -1 반환
  if (argint(0, &sched) < 0)
80106188:	83 ec 08             	sub    $0x8,%esp
8010618b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010618e:	50                   	push   %eax
8010618f:	6a 00                	push   $0x0
80106191:	e8 a5 ef ff ff       	call   8010513b <argint>
80106196:	83 c4 10             	add    $0x10,%esp
80106199:	85 c0                	test   %eax,%eax
8010619b:	79 07                	jns    801061a4 <sys_uthread_init+0x23>
    return -1;
8010619d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a2:	eb 4e                	jmp    801061f2 <sys_uthread_init+0x71>

  cprintf("[kernel] sys_uthread_init 호출됨, 전달된 주소 = 0x%x\n", sched);
801061a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a7:	83 ec 08             	sub    $0x8,%esp
801061aa:	50                   	push   %eax
801061ab:	68 38 a9 10 80       	push   $0x8010a938
801061b0:	e8 3f a2 ff ff       	call   801003f4 <cprintf>
801061b5:	83 c4 10             	add    $0x10,%esp
  //현재 프로세스의 pcb해당 주소를 저장(함수주소이므로 uint로 저장)
  myproc()->scheduler = (uint)sched;
801061b8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801061bb:	e8 77 d8 ff ff       	call   80103a37 <myproc>
801061c0:	89 da                	mov    %ebx,%edx
801061c2:	89 50 7c             	mov    %edx,0x7c(%eax)
  //사용자 수준 스레드를 사용하는 프로세스임을 나타내는 플래그 설정
  myproc()->is_threaded = 1;
801061c5:	e8 6d d8 ff ff       	call   80103a37 <myproc>
801061ca:	c7 80 80 00 00 00 01 	movl   $0x1,0x80(%eax)
801061d1:	00 00 00 
  cprintf("[kernel] 저장 완료: proc->scheduler = 0x%x\n", myproc()->scheduler);
801061d4:	e8 5e d8 ff ff       	call   80103a37 <myproc>
801061d9:	8b 40 7c             	mov    0x7c(%eax),%eax
801061dc:	83 ec 08             	sub    $0x8,%esp
801061df:	50                   	push   %eax
801061e0:	68 78 a9 10 80       	push   $0x8010a978
801061e5:	e8 0a a2 ff ff       	call   801003f4 <cprintf>
801061ea:	83 c4 10             	add    $0x10,%esp
  //시스템 콜 정상 종료
  return 0;
801061ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801061f5:	c9                   	leave
801061f6:	c3                   	ret

801061f7 <sys_yield>:

int
sys_yield(void)
{
801061f7:	55                   	push   %ebp
801061f8:	89 e5                	mov    %esp,%ebp
801061fa:	83 ec 08             	sub    $0x8,%esp
  yield();  // 커널 내부의 scheduler.c 함수
801061fd:	e8 fe e1 ff ff       	call   80104400 <yield>
  return 0;
80106202:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106207:	c9                   	leave
80106208:	c3                   	ret

80106209 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106209:	1e                   	push   %ds
  pushl %es
8010620a:	06                   	push   %es
  pushl %fs
8010620b:	0f a0                	push   %fs
  pushl %gs
8010620d:	0f a8                	push   %gs
  pushal
8010620f:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106210:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106214:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106216:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106218:	54                   	push   %esp
  call trap
80106219:	e8 d7 01 00 00       	call   801063f5 <trap>
  addl $4, %esp
8010621e:	83 c4 04             	add    $0x4,%esp

80106221 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106221:	61                   	popa
  popl %gs
80106222:	0f a9                	pop    %gs
  popl %fs
80106224:	0f a1                	pop    %fs
  popl %es
80106226:	07                   	pop    %es
  popl %ds
80106227:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106228:	83 c4 08             	add    $0x8,%esp
  iret
8010622b:	cf                   	iret

8010622c <lidt>:
{
8010622c:	55                   	push   %ebp
8010622d:	89 e5                	mov    %esp,%ebp
8010622f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106232:	8b 45 0c             	mov    0xc(%ebp),%eax
80106235:	83 e8 01             	sub    $0x1,%eax
80106238:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010623c:	8b 45 08             	mov    0x8(%ebp),%eax
8010623f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106243:	8b 45 08             	mov    0x8(%ebp),%eax
80106246:	c1 e8 10             	shr    $0x10,%eax
80106249:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010624d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106250:	0f 01 18             	lidtl  (%eax)
}
80106253:	90                   	nop
80106254:	c9                   	leave
80106255:	c3                   	ret

80106256 <rcr2>:

static inline uint
rcr2(void)
{
80106256:	55                   	push   %ebp
80106257:	89 e5                	mov    %esp,%ebp
80106259:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010625c:	0f 20 d0             	mov    %cr2,%eax
8010625f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106262:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106265:	c9                   	leave
80106266:	c3                   	ret

80106267 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106267:	55                   	push   %ebp
80106268:	89 e5                	mov    %esp,%ebp
8010626a:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010626d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106274:	e9 c3 00 00 00       	jmp    8010633c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627c:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106283:	89 c2                	mov    %eax,%edx
80106285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106288:	66 89 14 c5 40 6c 19 	mov    %dx,-0x7fe693c0(,%eax,8)
8010628f:	80 
80106290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106293:	66 c7 04 c5 42 6c 19 	movw   $0x8,-0x7fe693be(,%eax,8)
8010629a:	80 08 00 
8010629d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a0:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
801062a7:	80 
801062a8:	83 e2 e0             	and    $0xffffffe0,%edx
801062ab:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
801062b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b5:	0f b6 14 c5 44 6c 19 	movzbl -0x7fe693bc(,%eax,8),%edx
801062bc:	80 
801062bd:	83 e2 1f             	and    $0x1f,%edx
801062c0:	88 14 c5 44 6c 19 80 	mov    %dl,-0x7fe693bc(,%eax,8)
801062c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ca:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801062d1:	80 
801062d2:	83 e2 f0             	and    $0xfffffff0,%edx
801062d5:	83 ca 0e             	or     $0xe,%edx
801062d8:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801062df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e2:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801062e9:	80 
801062ea:	83 e2 ef             	and    $0xffffffef,%edx
801062ed:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
801062f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f7:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
801062fe:	80 
801062ff:	83 e2 9f             	and    $0xffffff9f,%edx
80106302:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
80106309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630c:	0f b6 14 c5 45 6c 19 	movzbl -0x7fe693bb(,%eax,8),%edx
80106313:	80 
80106314:	83 ca 80             	or     $0xffffff80,%edx
80106317:	88 14 c5 45 6c 19 80 	mov    %dl,-0x7fe693bb(,%eax,8)
8010631e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106321:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106328:	c1 e8 10             	shr    $0x10,%eax
8010632b:	89 c2                	mov    %eax,%edx
8010632d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106330:	66 89 14 c5 46 6c 19 	mov    %dx,-0x7fe693ba(,%eax,8)
80106337:	80 
  for(i = 0; i < 256; i++)
80106338:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010633c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106343:	0f 8e 30 ff ff ff    	jle    80106279 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106349:	a1 88 f1 10 80       	mov    0x8010f188,%eax
8010634e:	66 a3 40 6e 19 80    	mov    %ax,0x80196e40
80106354:	66 c7 05 42 6e 19 80 	movw   $0x8,0x80196e42
8010635b:	08 00 
8010635d:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
80106364:	83 e0 e0             	and    $0xffffffe0,%eax
80106367:	a2 44 6e 19 80       	mov    %al,0x80196e44
8010636c:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
80106373:	83 e0 1f             	and    $0x1f,%eax
80106376:	a2 44 6e 19 80       	mov    %al,0x80196e44
8010637b:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106382:	83 c8 0f             	or     $0xf,%eax
80106385:	a2 45 6e 19 80       	mov    %al,0x80196e45
8010638a:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
80106391:	83 e0 ef             	and    $0xffffffef,%eax
80106394:	a2 45 6e 19 80       	mov    %al,0x80196e45
80106399:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
801063a0:	83 c8 60             	or     $0x60,%eax
801063a3:	a2 45 6e 19 80       	mov    %al,0x80196e45
801063a8:	0f b6 05 45 6e 19 80 	movzbl 0x80196e45,%eax
801063af:	83 c8 80             	or     $0xffffff80,%eax
801063b2:	a2 45 6e 19 80       	mov    %al,0x80196e45
801063b7:	a1 88 f1 10 80       	mov    0x8010f188,%eax
801063bc:	c1 e8 10             	shr    $0x10,%eax
801063bf:	66 a3 46 6e 19 80    	mov    %ax,0x80196e46

  initlock(&tickslock, "time");
801063c5:	83 ec 08             	sub    $0x8,%esp
801063c8:	68 a8 a9 10 80       	push   $0x8010a9a8
801063cd:	68 40 74 19 80       	push   $0x80197440
801063d2:	e8 a1 e7 ff ff       	call   80104b78 <initlock>
801063d7:	83 c4 10             	add    $0x10,%esp
}
801063da:	90                   	nop
801063db:	c9                   	leave
801063dc:	c3                   	ret

801063dd <idtinit>:

void
idtinit(void)
{
801063dd:	55                   	push   %ebp
801063de:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801063e0:	68 00 08 00 00       	push   $0x800
801063e5:	68 40 6c 19 80       	push   $0x80196c40
801063ea:	e8 3d fe ff ff       	call   8010622c <lidt>
801063ef:	83 c4 08             	add    $0x8,%esp
}
801063f2:	90                   	nop
801063f3:	c9                   	leave
801063f4:	c3                   	ret

801063f5 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063f5:	55                   	push   %ebp
801063f6:	89 e5                	mov    %esp,%ebp
801063f8:	57                   	push   %edi
801063f9:	56                   	push   %esi
801063fa:	53                   	push   %ebx
801063fb:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801063fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106401:	8b 40 30             	mov    0x30(%eax),%eax
80106404:	83 f8 40             	cmp    $0x40,%eax
80106407:	75 3b                	jne    80106444 <trap+0x4f>
    if(myproc()->killed)
80106409:	e8 29 d6 ff ff       	call   80103a37 <myproc>
8010640e:	8b 40 24             	mov    0x24(%eax),%eax
80106411:	85 c0                	test   %eax,%eax
80106413:	74 05                	je     8010641a <trap+0x25>
      exit();
80106415:	e8 da da ff ff       	call   80103ef4 <exit>
    myproc()->tf = tf;
8010641a:	e8 18 d6 ff ff       	call   80103a37 <myproc>
8010641f:	8b 55 08             	mov    0x8(%ebp),%edx
80106422:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106425:	e8 dd ed ff ff       	call   80105207 <syscall>
    if(myproc()->killed)
8010642a:	e8 08 d6 ff ff       	call   80103a37 <myproc>
8010642f:	8b 40 24             	mov    0x24(%eax),%eax
80106432:	85 c0                	test   %eax,%eax
80106434:	0f 84 83 02 00 00    	je     801066bd <trap+0x2c8>
      exit();
8010643a:	e8 b5 da ff ff       	call   80103ef4 <exit>
    return;
8010643f:	e9 79 02 00 00       	jmp    801066bd <trap+0x2c8>
  }

  switch(tf->trapno){
80106444:	8b 45 08             	mov    0x8(%ebp),%eax
80106447:	8b 40 30             	mov    0x30(%eax),%eax
8010644a:	83 e8 20             	sub    $0x20,%eax
8010644d:	83 f8 1f             	cmp    $0x1f,%eax
80106450:	0f 87 0c 01 00 00    	ja     80106562 <trap+0x16d>
80106456:	8b 04 85 50 aa 10 80 	mov    -0x7fef55b0(,%eax,4),%eax
8010645d:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:  //타이머 인터럽트가 발생했을때
    if(cpuid() == 0){   //cpu 0번만 global tick 증가 및 sleep-wakeup처리
8010645f:	e8 40 d5 ff ff       	call   801039a4 <cpuid>
80106464:	85 c0                	test   %eax,%eax
80106466:	75 3d                	jne    801064a5 <trap+0xb0>
      acquire(&tickslock);  //tick 값 보호를 위한 락 획득
80106468:	83 ec 0c             	sub    $0xc,%esp
8010646b:	68 40 74 19 80       	push   $0x80197440
80106470:	e8 25 e7 ff ff       	call   80104b9a <acquire>
80106475:	83 c4 10             	add    $0x10,%esp
      ticks++;              //전역 tick 카운터 증가
80106478:	a1 74 74 19 80       	mov    0x80197474,%eax
8010647d:	83 c0 01             	add    $0x1,%eax
80106480:	a3 74 74 19 80       	mov    %eax,0x80197474
      wakeup(&ticks);       // tick을 기다리는 프로세스 깨움
80106485:	83 ec 0c             	sub    $0xc,%esp
80106488:	68 74 74 19 80       	push   $0x80197474
8010648d:	e8 d8 e0 ff ff       	call   8010456a <wakeup>
80106492:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);    //락 해제
80106495:	83 ec 0c             	sub    $0xc,%esp
80106498:	68 40 74 19 80       	push   $0x80197440
8010649d:	e8 66 e7 ff ff       	call   80104c08 <release>
801064a2:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();     //LOCAl apic에 인터럽트 처리 완료 알림
801064a5:	e8 74 c6 ff ff       	call   80102b1e <lapiceoi>
    struct proc *proc = myproc();
801064aa:	e8 88 d5 ff ff       	call   80103a37 <myproc>
801064af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (proc && proc->state == RUNNING && proc->is_threaded && proc->scheduler) {
801064b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801064b6:	0f 84 5d 01 00 00    	je     80106619 <trap+0x224>
801064bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064bf:	8b 40 0c             	mov    0xc(%eax),%eax
801064c2:	83 f8 04             	cmp    $0x4,%eax
801064c5:	0f 85 4e 01 00 00    	jne    80106619 <trap+0x224>
801064cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ce:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801064d4:	85 c0                	test   %eax,%eax
801064d6:	0f 84 3d 01 00 00    	je     80106619 <trap+0x224>
801064dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064df:	8b 40 7c             	mov    0x7c(%eax),%eax
801064e2:	85 c0                	test   %eax,%eax
801064e4:	0f 84 2f 01 00 00    	je     80106619 <trap+0x224>
      ((void (*)(void))proc->scheduler)();  // 🎯 사용자 스케줄러 함수 호출
801064ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ed:	8b 40 7c             	mov    0x7c(%eax),%eax
801064f0:	ff d0                	call   *%eax
    }

    break;
801064f2:	e9 22 01 00 00       	jmp    80106619 <trap+0x224>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064f7:	e8 01 3f 00 00       	call   8010a3fd <ideintr>
    lapiceoi();
801064fc:	e8 1d c6 ff ff       	call   80102b1e <lapiceoi>
    break;
80106501:	e9 14 01 00 00       	jmp    8010661a <trap+0x225>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106506:	e8 5e c4 ff ff       	call   80102969 <kbdintr>
    lapiceoi();
8010650b:	e8 0e c6 ff ff       	call   80102b1e <lapiceoi>
    break;
80106510:	e9 05 01 00 00       	jmp    8010661a <trap+0x225>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106515:	e8 77 03 00 00       	call   80106891 <uartintr>
    lapiceoi();
8010651a:	e8 ff c5 ff ff       	call   80102b1e <lapiceoi>
    break;
8010651f:	e9 f6 00 00 00       	jmp    8010661a <trap+0x225>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106524:	e8 9d 2b 00 00       	call   801090c6 <i8254_intr>
    lapiceoi();
80106529:	e8 f0 c5 ff ff       	call   80102b1e <lapiceoi>
    break;
8010652e:	e9 e7 00 00 00       	jmp    8010661a <trap+0x225>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106533:	8b 45 08             	mov    0x8(%ebp),%eax
80106536:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106539:	8b 45 08             	mov    0x8(%ebp),%eax
8010653c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106540:	0f b7 d8             	movzwl %ax,%ebx
80106543:	e8 5c d4 ff ff       	call   801039a4 <cpuid>
80106548:	56                   	push   %esi
80106549:	53                   	push   %ebx
8010654a:	50                   	push   %eax
8010654b:	68 b0 a9 10 80       	push   $0x8010a9b0
80106550:	e8 9f 9e ff ff       	call   801003f4 <cprintf>
80106555:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106558:	e8 c1 c5 ff ff       	call   80102b1e <lapiceoi>
    break;
8010655d:	e9 b8 00 00 00       	jmp    8010661a <trap+0x225>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106562:	e8 d0 d4 ff ff       	call   80103a37 <myproc>
80106567:	85 c0                	test   %eax,%eax
80106569:	74 11                	je     8010657c <trap+0x187>
8010656b:	8b 45 08             	mov    0x8(%ebp),%eax
8010656e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106572:	0f b7 c0             	movzwl %ax,%eax
80106575:	83 e0 03             	and    $0x3,%eax
80106578:	85 c0                	test   %eax,%eax
8010657a:	75 39                	jne    801065b5 <trap+0x1c0>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010657c:	e8 d5 fc ff ff       	call   80106256 <rcr2>
80106581:	89 c3                	mov    %eax,%ebx
80106583:	8b 45 08             	mov    0x8(%ebp),%eax
80106586:	8b 70 38             	mov    0x38(%eax),%esi
80106589:	e8 16 d4 ff ff       	call   801039a4 <cpuid>
8010658e:	8b 55 08             	mov    0x8(%ebp),%edx
80106591:	8b 52 30             	mov    0x30(%edx),%edx
80106594:	83 ec 0c             	sub    $0xc,%esp
80106597:	53                   	push   %ebx
80106598:	56                   	push   %esi
80106599:	50                   	push   %eax
8010659a:	52                   	push   %edx
8010659b:	68 d4 a9 10 80       	push   $0x8010a9d4
801065a0:	e8 4f 9e ff ff       	call   801003f4 <cprintf>
801065a5:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801065a8:	83 ec 0c             	sub    $0xc,%esp
801065ab:	68 06 aa 10 80       	push   $0x8010aa06
801065b0:	e8 f4 9f ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065b5:	e8 9c fc ff ff       	call   80106256 <rcr2>
801065ba:	89 c6                	mov    %eax,%esi
801065bc:	8b 45 08             	mov    0x8(%ebp),%eax
801065bf:	8b 40 38             	mov    0x38(%eax),%eax
801065c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801065c5:	e8 da d3 ff ff       	call   801039a4 <cpuid>
801065ca:	89 c3                	mov    %eax,%ebx
801065cc:	8b 45 08             	mov    0x8(%ebp),%eax
801065cf:	8b 48 34             	mov    0x34(%eax),%ecx
801065d2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801065d5:	8b 45 08             	mov    0x8(%ebp),%eax
801065d8:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801065db:	e8 57 d4 ff ff       	call   80103a37 <myproc>
801065e0:	8d 50 6c             	lea    0x6c(%eax),%edx
801065e3:	89 55 cc             	mov    %edx,-0x34(%ebp)
801065e6:	e8 4c d4 ff ff       	call   80103a37 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065eb:	8b 40 10             	mov    0x10(%eax),%eax
801065ee:	56                   	push   %esi
801065ef:	ff 75 d4             	push   -0x2c(%ebp)
801065f2:	53                   	push   %ebx
801065f3:	ff 75 d0             	push   -0x30(%ebp)
801065f6:	57                   	push   %edi
801065f7:	ff 75 cc             	push   -0x34(%ebp)
801065fa:	50                   	push   %eax
801065fb:	68 0c aa 10 80       	push   $0x8010aa0c
80106600:	e8 ef 9d ff ff       	call   801003f4 <cprintf>
80106605:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106608:	e8 2a d4 ff ff       	call   80103a37 <myproc>
8010660d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106614:	eb 04                	jmp    8010661a <trap+0x225>
    break;
80106616:	90                   	nop
80106617:	eb 01                	jmp    8010661a <trap+0x225>
    break;
80106619:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010661a:	e8 18 d4 ff ff       	call   80103a37 <myproc>
8010661f:	85 c0                	test   %eax,%eax
80106621:	74 23                	je     80106646 <trap+0x251>
80106623:	e8 0f d4 ff ff       	call   80103a37 <myproc>
80106628:	8b 40 24             	mov    0x24(%eax),%eax
8010662b:	85 c0                	test   %eax,%eax
8010662d:	74 17                	je     80106646 <trap+0x251>
8010662f:	8b 45 08             	mov    0x8(%ebp),%eax
80106632:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106636:	0f b7 c0             	movzwl %ax,%eax
80106639:	83 e0 03             	and    $0x3,%eax
8010663c:	83 f8 03             	cmp    $0x3,%eax
8010663f:	75 05                	jne    80106646 <trap+0x251>
    exit();
80106641:	e8 ae d8 ff ff       	call   80103ef4 <exit>
  
  //myproc() 현재 cpu에서 실행중인 프로세스 
  //myproc()->state == RUNNING 현재 프로세스가 실행 중인지 확인
  //tf->trapno == T_IRQ0+IRQ_TIMER trap 번호가 타이머 인터럽트인지 확인
  // yield() 현재 프로세스를 RUNNABLE로 바꾸고, sched() 호출해서 다른 프로세스로 문맥을 전환
  if(myproc() && myproc()->state == RUNNING &&tf->trapno == T_IRQ0+IRQ_TIMER) 
80106646:	e8 ec d3 ff ff       	call   80103a37 <myproc>
8010664b:	85 c0                	test   %eax,%eax
8010664d:	74 40                	je     8010668f <trap+0x29a>
8010664f:	e8 e3 d3 ff ff       	call   80103a37 <myproc>
80106654:	8b 40 0c             	mov    0xc(%eax),%eax
80106657:	83 f8 04             	cmp    $0x4,%eax
8010665a:	75 33                	jne    8010668f <trap+0x29a>
8010665c:	8b 45 08             	mov    0x8(%ebp),%eax
8010665f:	8b 40 30             	mov    0x30(%eax),%eax
80106662:	83 f8 20             	cmp    $0x20,%eax
80106665:	75 28                	jne    8010668f <trap+0x29a>
  {
    myproc()->ticks[myproc()->priority]++; //타이머 인터럽트가 발생할때 마다 1틱이 추가됨
80106667:	e8 cb d3 ff ff       	call   80103a37 <myproc>
8010666c:	89 c3                	mov    %eax,%ebx
8010666e:	e8 c4 d3 ff ff       	call   80103a37 <myproc>
80106673:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106679:	8d 50 20             	lea    0x20(%eax),%edx
8010667c:	8b 54 93 08          	mov    0x8(%ebx,%edx,4),%edx
80106680:	83 c2 01             	add    $0x1,%edx
80106683:	83 c0 20             	add    $0x20,%eax
80106686:	89 54 83 08          	mov    %edx,0x8(%ebx,%eax,4)
    yield();
8010668a:	e8 71 dd ff ff       	call   80104400 <yield>

//myproc() 현재 CPU에서 실행 중인 프로세스
//myproc()->killed 커널에서 이 프로세스를 종료하라고 표시 했는지 확인
//(tf->cs & 3) == DPL_USER 현재 trap이 user space 에서 발생했는지 확인|
//exit() 프로세스를 종료하는 시스템 콜 
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010668f:	e8 a3 d3 ff ff       	call   80103a37 <myproc>
80106694:	85 c0                	test   %eax,%eax
80106696:	74 26                	je     801066be <trap+0x2c9>
80106698:	e8 9a d3 ff ff       	call   80103a37 <myproc>
8010669d:	8b 40 24             	mov    0x24(%eax),%eax
801066a0:	85 c0                	test   %eax,%eax
801066a2:	74 1a                	je     801066be <trap+0x2c9>
801066a4:	8b 45 08             	mov    0x8(%ebp),%eax
801066a7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066ab:	0f b7 c0             	movzwl %ax,%eax
801066ae:	83 e0 03             	and    $0x3,%eax
801066b1:	83 f8 03             	cmp    $0x3,%eax
801066b4:	75 08                	jne    801066be <trap+0x2c9>
    exit();
801066b6:	e8 39 d8 ff ff       	call   80103ef4 <exit>
801066bb:	eb 01                	jmp    801066be <trap+0x2c9>
    return;
801066bd:	90                   	nop
}
801066be:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066c1:	5b                   	pop    %ebx
801066c2:	5e                   	pop    %esi
801066c3:	5f                   	pop    %edi
801066c4:	5d                   	pop    %ebp
801066c5:	c3                   	ret

801066c6 <inb>:
{
801066c6:	55                   	push   %ebp
801066c7:	89 e5                	mov    %esp,%ebp
801066c9:	83 ec 14             	sub    $0x14,%esp
801066cc:	8b 45 08             	mov    0x8(%ebp),%eax
801066cf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066d3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066d7:	89 c2                	mov    %eax,%edx
801066d9:	ec                   	in     (%dx),%al
801066da:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066dd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066e1:	c9                   	leave
801066e2:	c3                   	ret

801066e3 <outb>:
{
801066e3:	55                   	push   %ebp
801066e4:	89 e5                	mov    %esp,%ebp
801066e6:	83 ec 08             	sub    $0x8,%esp
801066e9:	8b 55 08             	mov    0x8(%ebp),%edx
801066ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801066ef:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801066f3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066f6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066fa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066fe:	ee                   	out    %al,(%dx)
}
801066ff:	90                   	nop
80106700:	c9                   	leave
80106701:	c3                   	ret

80106702 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106702:	55                   	push   %ebp
80106703:	89 e5                	mov    %esp,%ebp
80106705:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106708:	6a 00                	push   $0x0
8010670a:	68 fa 03 00 00       	push   $0x3fa
8010670f:	e8 cf ff ff ff       	call   801066e3 <outb>
80106714:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106717:	68 80 00 00 00       	push   $0x80
8010671c:	68 fb 03 00 00       	push   $0x3fb
80106721:	e8 bd ff ff ff       	call   801066e3 <outb>
80106726:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106729:	6a 0c                	push   $0xc
8010672b:	68 f8 03 00 00       	push   $0x3f8
80106730:	e8 ae ff ff ff       	call   801066e3 <outb>
80106735:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106738:	6a 00                	push   $0x0
8010673a:	68 f9 03 00 00       	push   $0x3f9
8010673f:	e8 9f ff ff ff       	call   801066e3 <outb>
80106744:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106747:	6a 03                	push   $0x3
80106749:	68 fb 03 00 00       	push   $0x3fb
8010674e:	e8 90 ff ff ff       	call   801066e3 <outb>
80106753:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106756:	6a 00                	push   $0x0
80106758:	68 fc 03 00 00       	push   $0x3fc
8010675d:	e8 81 ff ff ff       	call   801066e3 <outb>
80106762:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106765:	6a 01                	push   $0x1
80106767:	68 f9 03 00 00       	push   $0x3f9
8010676c:	e8 72 ff ff ff       	call   801066e3 <outb>
80106771:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106774:	68 fd 03 00 00       	push   $0x3fd
80106779:	e8 48 ff ff ff       	call   801066c6 <inb>
8010677e:	83 c4 04             	add    $0x4,%esp
80106781:	3c ff                	cmp    $0xff,%al
80106783:	74 61                	je     801067e6 <uartinit+0xe4>
    return;
  uart = 1;
80106785:	c7 05 78 74 19 80 01 	movl   $0x1,0x80197478
8010678c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010678f:	68 fa 03 00 00       	push   $0x3fa
80106794:	e8 2d ff ff ff       	call   801066c6 <inb>
80106799:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010679c:	68 f8 03 00 00       	push   $0x3f8
801067a1:	e8 20 ff ff ff       	call   801066c6 <inb>
801067a6:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801067a9:	83 ec 08             	sub    $0x8,%esp
801067ac:	6a 00                	push   $0x0
801067ae:	6a 04                	push   $0x4
801067b0:	e8 81 be ff ff       	call   80102636 <ioapicenable>
801067b5:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801067b8:	c7 45 f4 d0 aa 10 80 	movl   $0x8010aad0,-0xc(%ebp)
801067bf:	eb 19                	jmp    801067da <uartinit+0xd8>
    uartputc(*p);
801067c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c4:	0f b6 00             	movzbl (%eax),%eax
801067c7:	0f be c0             	movsbl %al,%eax
801067ca:	83 ec 0c             	sub    $0xc,%esp
801067cd:	50                   	push   %eax
801067ce:	e8 16 00 00 00       	call   801067e9 <uartputc>
801067d3:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801067d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067dd:	0f b6 00             	movzbl (%eax),%eax
801067e0:	84 c0                	test   %al,%al
801067e2:	75 dd                	jne    801067c1 <uartinit+0xbf>
801067e4:	eb 01                	jmp    801067e7 <uartinit+0xe5>
    return;
801067e6:	90                   	nop
}
801067e7:	c9                   	leave
801067e8:	c3                   	ret

801067e9 <uartputc>:

void
uartputc(int c)
{
801067e9:	55                   	push   %ebp
801067ea:	89 e5                	mov    %esp,%ebp
801067ec:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067ef:	a1 78 74 19 80       	mov    0x80197478,%eax
801067f4:	85 c0                	test   %eax,%eax
801067f6:	74 53                	je     8010684b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067ff:	eb 11                	jmp    80106812 <uartputc+0x29>
    microdelay(10);
80106801:	83 ec 0c             	sub    $0xc,%esp
80106804:	6a 0a                	push   $0xa
80106806:	e8 2e c3 ff ff       	call   80102b39 <microdelay>
8010680b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010680e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106812:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106816:	7f 1a                	jg     80106832 <uartputc+0x49>
80106818:	83 ec 0c             	sub    $0xc,%esp
8010681b:	68 fd 03 00 00       	push   $0x3fd
80106820:	e8 a1 fe ff ff       	call   801066c6 <inb>
80106825:	83 c4 10             	add    $0x10,%esp
80106828:	0f b6 c0             	movzbl %al,%eax
8010682b:	83 e0 20             	and    $0x20,%eax
8010682e:	85 c0                	test   %eax,%eax
80106830:	74 cf                	je     80106801 <uartputc+0x18>
  outb(COM1+0, c);
80106832:	8b 45 08             	mov    0x8(%ebp),%eax
80106835:	0f b6 c0             	movzbl %al,%eax
80106838:	83 ec 08             	sub    $0x8,%esp
8010683b:	50                   	push   %eax
8010683c:	68 f8 03 00 00       	push   $0x3f8
80106841:	e8 9d fe ff ff       	call   801066e3 <outb>
80106846:	83 c4 10             	add    $0x10,%esp
80106849:	eb 01                	jmp    8010684c <uartputc+0x63>
    return;
8010684b:	90                   	nop
}
8010684c:	c9                   	leave
8010684d:	c3                   	ret

8010684e <uartgetc>:

static int
uartgetc(void)
{
8010684e:	55                   	push   %ebp
8010684f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106851:	a1 78 74 19 80       	mov    0x80197478,%eax
80106856:	85 c0                	test   %eax,%eax
80106858:	75 07                	jne    80106861 <uartgetc+0x13>
    return -1;
8010685a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685f:	eb 2e                	jmp    8010688f <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106861:	68 fd 03 00 00       	push   $0x3fd
80106866:	e8 5b fe ff ff       	call   801066c6 <inb>
8010686b:	83 c4 04             	add    $0x4,%esp
8010686e:	0f b6 c0             	movzbl %al,%eax
80106871:	83 e0 01             	and    $0x1,%eax
80106874:	85 c0                	test   %eax,%eax
80106876:	75 07                	jne    8010687f <uartgetc+0x31>
    return -1;
80106878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687d:	eb 10                	jmp    8010688f <uartgetc+0x41>
  return inb(COM1+0);
8010687f:	68 f8 03 00 00       	push   $0x3f8
80106884:	e8 3d fe ff ff       	call   801066c6 <inb>
80106889:	83 c4 04             	add    $0x4,%esp
8010688c:	0f b6 c0             	movzbl %al,%eax
}
8010688f:	c9                   	leave
80106890:	c3                   	ret

80106891 <uartintr>:

void
uartintr(void)
{
80106891:	55                   	push   %ebp
80106892:	89 e5                	mov    %esp,%ebp
80106894:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106897:	83 ec 0c             	sub    $0xc,%esp
8010689a:	68 4e 68 10 80       	push   $0x8010684e
8010689f:	e8 32 9f ff ff       	call   801007d6 <consoleintr>
801068a4:	83 c4 10             	add    $0x10,%esp
}
801068a7:	90                   	nop
801068a8:	c9                   	leave
801068a9:	c3                   	ret

801068aa <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801068aa:	6a 00                	push   $0x0
  pushl $0
801068ac:	6a 00                	push   $0x0
  jmp alltraps
801068ae:	e9 56 f9 ff ff       	jmp    80106209 <alltraps>

801068b3 <vector1>:
.globl vector1
vector1:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $1
801068b5:	6a 01                	push   $0x1
  jmp alltraps
801068b7:	e9 4d f9 ff ff       	jmp    80106209 <alltraps>

801068bc <vector2>:
.globl vector2
vector2:
  pushl $0
801068bc:	6a 00                	push   $0x0
  pushl $2
801068be:	6a 02                	push   $0x2
  jmp alltraps
801068c0:	e9 44 f9 ff ff       	jmp    80106209 <alltraps>

801068c5 <vector3>:
.globl vector3
vector3:
  pushl $0
801068c5:	6a 00                	push   $0x0
  pushl $3
801068c7:	6a 03                	push   $0x3
  jmp alltraps
801068c9:	e9 3b f9 ff ff       	jmp    80106209 <alltraps>

801068ce <vector4>:
.globl vector4
vector4:
  pushl $0
801068ce:	6a 00                	push   $0x0
  pushl $4
801068d0:	6a 04                	push   $0x4
  jmp alltraps
801068d2:	e9 32 f9 ff ff       	jmp    80106209 <alltraps>

801068d7 <vector5>:
.globl vector5
vector5:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $5
801068d9:	6a 05                	push   $0x5
  jmp alltraps
801068db:	e9 29 f9 ff ff       	jmp    80106209 <alltraps>

801068e0 <vector6>:
.globl vector6
vector6:
  pushl $0
801068e0:	6a 00                	push   $0x0
  pushl $6
801068e2:	6a 06                	push   $0x6
  jmp alltraps
801068e4:	e9 20 f9 ff ff       	jmp    80106209 <alltraps>

801068e9 <vector7>:
.globl vector7
vector7:
  pushl $0
801068e9:	6a 00                	push   $0x0
  pushl $7
801068eb:	6a 07                	push   $0x7
  jmp alltraps
801068ed:	e9 17 f9 ff ff       	jmp    80106209 <alltraps>

801068f2 <vector8>:
.globl vector8
vector8:
  pushl $8
801068f2:	6a 08                	push   $0x8
  jmp alltraps
801068f4:	e9 10 f9 ff ff       	jmp    80106209 <alltraps>

801068f9 <vector9>:
.globl vector9
vector9:
  pushl $0
801068f9:	6a 00                	push   $0x0
  pushl $9
801068fb:	6a 09                	push   $0x9
  jmp alltraps
801068fd:	e9 07 f9 ff ff       	jmp    80106209 <alltraps>

80106902 <vector10>:
.globl vector10
vector10:
  pushl $10
80106902:	6a 0a                	push   $0xa
  jmp alltraps
80106904:	e9 00 f9 ff ff       	jmp    80106209 <alltraps>

80106909 <vector11>:
.globl vector11
vector11:
  pushl $11
80106909:	6a 0b                	push   $0xb
  jmp alltraps
8010690b:	e9 f9 f8 ff ff       	jmp    80106209 <alltraps>

80106910 <vector12>:
.globl vector12
vector12:
  pushl $12
80106910:	6a 0c                	push   $0xc
  jmp alltraps
80106912:	e9 f2 f8 ff ff       	jmp    80106209 <alltraps>

80106917 <vector13>:
.globl vector13
vector13:
  pushl $13
80106917:	6a 0d                	push   $0xd
  jmp alltraps
80106919:	e9 eb f8 ff ff       	jmp    80106209 <alltraps>

8010691e <vector14>:
.globl vector14
vector14:
  pushl $14
8010691e:	6a 0e                	push   $0xe
  jmp alltraps
80106920:	e9 e4 f8 ff ff       	jmp    80106209 <alltraps>

80106925 <vector15>:
.globl vector15
vector15:
  pushl $0
80106925:	6a 00                	push   $0x0
  pushl $15
80106927:	6a 0f                	push   $0xf
  jmp alltraps
80106929:	e9 db f8 ff ff       	jmp    80106209 <alltraps>

8010692e <vector16>:
.globl vector16
vector16:
  pushl $0
8010692e:	6a 00                	push   $0x0
  pushl $16
80106930:	6a 10                	push   $0x10
  jmp alltraps
80106932:	e9 d2 f8 ff ff       	jmp    80106209 <alltraps>

80106937 <vector17>:
.globl vector17
vector17:
  pushl $17
80106937:	6a 11                	push   $0x11
  jmp alltraps
80106939:	e9 cb f8 ff ff       	jmp    80106209 <alltraps>

8010693e <vector18>:
.globl vector18
vector18:
  pushl $0
8010693e:	6a 00                	push   $0x0
  pushl $18
80106940:	6a 12                	push   $0x12
  jmp alltraps
80106942:	e9 c2 f8 ff ff       	jmp    80106209 <alltraps>

80106947 <vector19>:
.globl vector19
vector19:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $19
80106949:	6a 13                	push   $0x13
  jmp alltraps
8010694b:	e9 b9 f8 ff ff       	jmp    80106209 <alltraps>

80106950 <vector20>:
.globl vector20
vector20:
  pushl $0
80106950:	6a 00                	push   $0x0
  pushl $20
80106952:	6a 14                	push   $0x14
  jmp alltraps
80106954:	e9 b0 f8 ff ff       	jmp    80106209 <alltraps>

80106959 <vector21>:
.globl vector21
vector21:
  pushl $0
80106959:	6a 00                	push   $0x0
  pushl $21
8010695b:	6a 15                	push   $0x15
  jmp alltraps
8010695d:	e9 a7 f8 ff ff       	jmp    80106209 <alltraps>

80106962 <vector22>:
.globl vector22
vector22:
  pushl $0
80106962:	6a 00                	push   $0x0
  pushl $22
80106964:	6a 16                	push   $0x16
  jmp alltraps
80106966:	e9 9e f8 ff ff       	jmp    80106209 <alltraps>

8010696b <vector23>:
.globl vector23
vector23:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $23
8010696d:	6a 17                	push   $0x17
  jmp alltraps
8010696f:	e9 95 f8 ff ff       	jmp    80106209 <alltraps>

80106974 <vector24>:
.globl vector24
vector24:
  pushl $0
80106974:	6a 00                	push   $0x0
  pushl $24
80106976:	6a 18                	push   $0x18
  jmp alltraps
80106978:	e9 8c f8 ff ff       	jmp    80106209 <alltraps>

8010697d <vector25>:
.globl vector25
vector25:
  pushl $0
8010697d:	6a 00                	push   $0x0
  pushl $25
8010697f:	6a 19                	push   $0x19
  jmp alltraps
80106981:	e9 83 f8 ff ff       	jmp    80106209 <alltraps>

80106986 <vector26>:
.globl vector26
vector26:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $26
80106988:	6a 1a                	push   $0x1a
  jmp alltraps
8010698a:	e9 7a f8 ff ff       	jmp    80106209 <alltraps>

8010698f <vector27>:
.globl vector27
vector27:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $27
80106991:	6a 1b                	push   $0x1b
  jmp alltraps
80106993:	e9 71 f8 ff ff       	jmp    80106209 <alltraps>

80106998 <vector28>:
.globl vector28
vector28:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $28
8010699a:	6a 1c                	push   $0x1c
  jmp alltraps
8010699c:	e9 68 f8 ff ff       	jmp    80106209 <alltraps>

801069a1 <vector29>:
.globl vector29
vector29:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $29
801069a3:	6a 1d                	push   $0x1d
  jmp alltraps
801069a5:	e9 5f f8 ff ff       	jmp    80106209 <alltraps>

801069aa <vector30>:
.globl vector30
vector30:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $30
801069ac:	6a 1e                	push   $0x1e
  jmp alltraps
801069ae:	e9 56 f8 ff ff       	jmp    80106209 <alltraps>

801069b3 <vector31>:
.globl vector31
vector31:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $31
801069b5:	6a 1f                	push   $0x1f
  jmp alltraps
801069b7:	e9 4d f8 ff ff       	jmp    80106209 <alltraps>

801069bc <vector32>:
.globl vector32
vector32:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $32
801069be:	6a 20                	push   $0x20
  jmp alltraps
801069c0:	e9 44 f8 ff ff       	jmp    80106209 <alltraps>

801069c5 <vector33>:
.globl vector33
vector33:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $33
801069c7:	6a 21                	push   $0x21
  jmp alltraps
801069c9:	e9 3b f8 ff ff       	jmp    80106209 <alltraps>

801069ce <vector34>:
.globl vector34
vector34:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $34
801069d0:	6a 22                	push   $0x22
  jmp alltraps
801069d2:	e9 32 f8 ff ff       	jmp    80106209 <alltraps>

801069d7 <vector35>:
.globl vector35
vector35:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $35
801069d9:	6a 23                	push   $0x23
  jmp alltraps
801069db:	e9 29 f8 ff ff       	jmp    80106209 <alltraps>

801069e0 <vector36>:
.globl vector36
vector36:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $36
801069e2:	6a 24                	push   $0x24
  jmp alltraps
801069e4:	e9 20 f8 ff ff       	jmp    80106209 <alltraps>

801069e9 <vector37>:
.globl vector37
vector37:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $37
801069eb:	6a 25                	push   $0x25
  jmp alltraps
801069ed:	e9 17 f8 ff ff       	jmp    80106209 <alltraps>

801069f2 <vector38>:
.globl vector38
vector38:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $38
801069f4:	6a 26                	push   $0x26
  jmp alltraps
801069f6:	e9 0e f8 ff ff       	jmp    80106209 <alltraps>

801069fb <vector39>:
.globl vector39
vector39:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $39
801069fd:	6a 27                	push   $0x27
  jmp alltraps
801069ff:	e9 05 f8 ff ff       	jmp    80106209 <alltraps>

80106a04 <vector40>:
.globl vector40
vector40:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $40
80106a06:	6a 28                	push   $0x28
  jmp alltraps
80106a08:	e9 fc f7 ff ff       	jmp    80106209 <alltraps>

80106a0d <vector41>:
.globl vector41
vector41:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $41
80106a0f:	6a 29                	push   $0x29
  jmp alltraps
80106a11:	e9 f3 f7 ff ff       	jmp    80106209 <alltraps>

80106a16 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $42
80106a18:	6a 2a                	push   $0x2a
  jmp alltraps
80106a1a:	e9 ea f7 ff ff       	jmp    80106209 <alltraps>

80106a1f <vector43>:
.globl vector43
vector43:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $43
80106a21:	6a 2b                	push   $0x2b
  jmp alltraps
80106a23:	e9 e1 f7 ff ff       	jmp    80106209 <alltraps>

80106a28 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $44
80106a2a:	6a 2c                	push   $0x2c
  jmp alltraps
80106a2c:	e9 d8 f7 ff ff       	jmp    80106209 <alltraps>

80106a31 <vector45>:
.globl vector45
vector45:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $45
80106a33:	6a 2d                	push   $0x2d
  jmp alltraps
80106a35:	e9 cf f7 ff ff       	jmp    80106209 <alltraps>

80106a3a <vector46>:
.globl vector46
vector46:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $46
80106a3c:	6a 2e                	push   $0x2e
  jmp alltraps
80106a3e:	e9 c6 f7 ff ff       	jmp    80106209 <alltraps>

80106a43 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $47
80106a45:	6a 2f                	push   $0x2f
  jmp alltraps
80106a47:	e9 bd f7 ff ff       	jmp    80106209 <alltraps>

80106a4c <vector48>:
.globl vector48
vector48:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $48
80106a4e:	6a 30                	push   $0x30
  jmp alltraps
80106a50:	e9 b4 f7 ff ff       	jmp    80106209 <alltraps>

80106a55 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $49
80106a57:	6a 31                	push   $0x31
  jmp alltraps
80106a59:	e9 ab f7 ff ff       	jmp    80106209 <alltraps>

80106a5e <vector50>:
.globl vector50
vector50:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $50
80106a60:	6a 32                	push   $0x32
  jmp alltraps
80106a62:	e9 a2 f7 ff ff       	jmp    80106209 <alltraps>

80106a67 <vector51>:
.globl vector51
vector51:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $51
80106a69:	6a 33                	push   $0x33
  jmp alltraps
80106a6b:	e9 99 f7 ff ff       	jmp    80106209 <alltraps>

80106a70 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $52
80106a72:	6a 34                	push   $0x34
  jmp alltraps
80106a74:	e9 90 f7 ff ff       	jmp    80106209 <alltraps>

80106a79 <vector53>:
.globl vector53
vector53:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $53
80106a7b:	6a 35                	push   $0x35
  jmp alltraps
80106a7d:	e9 87 f7 ff ff       	jmp    80106209 <alltraps>

80106a82 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $54
80106a84:	6a 36                	push   $0x36
  jmp alltraps
80106a86:	e9 7e f7 ff ff       	jmp    80106209 <alltraps>

80106a8b <vector55>:
.globl vector55
vector55:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $55
80106a8d:	6a 37                	push   $0x37
  jmp alltraps
80106a8f:	e9 75 f7 ff ff       	jmp    80106209 <alltraps>

80106a94 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $56
80106a96:	6a 38                	push   $0x38
  jmp alltraps
80106a98:	e9 6c f7 ff ff       	jmp    80106209 <alltraps>

80106a9d <vector57>:
.globl vector57
vector57:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $57
80106a9f:	6a 39                	push   $0x39
  jmp alltraps
80106aa1:	e9 63 f7 ff ff       	jmp    80106209 <alltraps>

80106aa6 <vector58>:
.globl vector58
vector58:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $58
80106aa8:	6a 3a                	push   $0x3a
  jmp alltraps
80106aaa:	e9 5a f7 ff ff       	jmp    80106209 <alltraps>

80106aaf <vector59>:
.globl vector59
vector59:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $59
80106ab1:	6a 3b                	push   $0x3b
  jmp alltraps
80106ab3:	e9 51 f7 ff ff       	jmp    80106209 <alltraps>

80106ab8 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $60
80106aba:	6a 3c                	push   $0x3c
  jmp alltraps
80106abc:	e9 48 f7 ff ff       	jmp    80106209 <alltraps>

80106ac1 <vector61>:
.globl vector61
vector61:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $61
80106ac3:	6a 3d                	push   $0x3d
  jmp alltraps
80106ac5:	e9 3f f7 ff ff       	jmp    80106209 <alltraps>

80106aca <vector62>:
.globl vector62
vector62:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $62
80106acc:	6a 3e                	push   $0x3e
  jmp alltraps
80106ace:	e9 36 f7 ff ff       	jmp    80106209 <alltraps>

80106ad3 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $63
80106ad5:	6a 3f                	push   $0x3f
  jmp alltraps
80106ad7:	e9 2d f7 ff ff       	jmp    80106209 <alltraps>

80106adc <vector64>:
.globl vector64
vector64:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $64
80106ade:	6a 40                	push   $0x40
  jmp alltraps
80106ae0:	e9 24 f7 ff ff       	jmp    80106209 <alltraps>

80106ae5 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $65
80106ae7:	6a 41                	push   $0x41
  jmp alltraps
80106ae9:	e9 1b f7 ff ff       	jmp    80106209 <alltraps>

80106aee <vector66>:
.globl vector66
vector66:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $66
80106af0:	6a 42                	push   $0x42
  jmp alltraps
80106af2:	e9 12 f7 ff ff       	jmp    80106209 <alltraps>

80106af7 <vector67>:
.globl vector67
vector67:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $67
80106af9:	6a 43                	push   $0x43
  jmp alltraps
80106afb:	e9 09 f7 ff ff       	jmp    80106209 <alltraps>

80106b00 <vector68>:
.globl vector68
vector68:
  pushl $0
80106b00:	6a 00                	push   $0x0
  pushl $68
80106b02:	6a 44                	push   $0x44
  jmp alltraps
80106b04:	e9 00 f7 ff ff       	jmp    80106209 <alltraps>

80106b09 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b09:	6a 00                	push   $0x0
  pushl $69
80106b0b:	6a 45                	push   $0x45
  jmp alltraps
80106b0d:	e9 f7 f6 ff ff       	jmp    80106209 <alltraps>

80106b12 <vector70>:
.globl vector70
vector70:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $70
80106b14:	6a 46                	push   $0x46
  jmp alltraps
80106b16:	e9 ee f6 ff ff       	jmp    80106209 <alltraps>

80106b1b <vector71>:
.globl vector71
vector71:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $71
80106b1d:	6a 47                	push   $0x47
  jmp alltraps
80106b1f:	e9 e5 f6 ff ff       	jmp    80106209 <alltraps>

80106b24 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b24:	6a 00                	push   $0x0
  pushl $72
80106b26:	6a 48                	push   $0x48
  jmp alltraps
80106b28:	e9 dc f6 ff ff       	jmp    80106209 <alltraps>

80106b2d <vector73>:
.globl vector73
vector73:
  pushl $0
80106b2d:	6a 00                	push   $0x0
  pushl $73
80106b2f:	6a 49                	push   $0x49
  jmp alltraps
80106b31:	e9 d3 f6 ff ff       	jmp    80106209 <alltraps>

80106b36 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $74
80106b38:	6a 4a                	push   $0x4a
  jmp alltraps
80106b3a:	e9 ca f6 ff ff       	jmp    80106209 <alltraps>

80106b3f <vector75>:
.globl vector75
vector75:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $75
80106b41:	6a 4b                	push   $0x4b
  jmp alltraps
80106b43:	e9 c1 f6 ff ff       	jmp    80106209 <alltraps>

80106b48 <vector76>:
.globl vector76
vector76:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $76
80106b4a:	6a 4c                	push   $0x4c
  jmp alltraps
80106b4c:	e9 b8 f6 ff ff       	jmp    80106209 <alltraps>

80106b51 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $77
80106b53:	6a 4d                	push   $0x4d
  jmp alltraps
80106b55:	e9 af f6 ff ff       	jmp    80106209 <alltraps>

80106b5a <vector78>:
.globl vector78
vector78:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $78
80106b5c:	6a 4e                	push   $0x4e
  jmp alltraps
80106b5e:	e9 a6 f6 ff ff       	jmp    80106209 <alltraps>

80106b63 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $79
80106b65:	6a 4f                	push   $0x4f
  jmp alltraps
80106b67:	e9 9d f6 ff ff       	jmp    80106209 <alltraps>

80106b6c <vector80>:
.globl vector80
vector80:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $80
80106b6e:	6a 50                	push   $0x50
  jmp alltraps
80106b70:	e9 94 f6 ff ff       	jmp    80106209 <alltraps>

80106b75 <vector81>:
.globl vector81
vector81:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $81
80106b77:	6a 51                	push   $0x51
  jmp alltraps
80106b79:	e9 8b f6 ff ff       	jmp    80106209 <alltraps>

80106b7e <vector82>:
.globl vector82
vector82:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $82
80106b80:	6a 52                	push   $0x52
  jmp alltraps
80106b82:	e9 82 f6 ff ff       	jmp    80106209 <alltraps>

80106b87 <vector83>:
.globl vector83
vector83:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $83
80106b89:	6a 53                	push   $0x53
  jmp alltraps
80106b8b:	e9 79 f6 ff ff       	jmp    80106209 <alltraps>

80106b90 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $84
80106b92:	6a 54                	push   $0x54
  jmp alltraps
80106b94:	e9 70 f6 ff ff       	jmp    80106209 <alltraps>

80106b99 <vector85>:
.globl vector85
vector85:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $85
80106b9b:	6a 55                	push   $0x55
  jmp alltraps
80106b9d:	e9 67 f6 ff ff       	jmp    80106209 <alltraps>

80106ba2 <vector86>:
.globl vector86
vector86:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $86
80106ba4:	6a 56                	push   $0x56
  jmp alltraps
80106ba6:	e9 5e f6 ff ff       	jmp    80106209 <alltraps>

80106bab <vector87>:
.globl vector87
vector87:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $87
80106bad:	6a 57                	push   $0x57
  jmp alltraps
80106baf:	e9 55 f6 ff ff       	jmp    80106209 <alltraps>

80106bb4 <vector88>:
.globl vector88
vector88:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $88
80106bb6:	6a 58                	push   $0x58
  jmp alltraps
80106bb8:	e9 4c f6 ff ff       	jmp    80106209 <alltraps>

80106bbd <vector89>:
.globl vector89
vector89:
  pushl $0
80106bbd:	6a 00                	push   $0x0
  pushl $89
80106bbf:	6a 59                	push   $0x59
  jmp alltraps
80106bc1:	e9 43 f6 ff ff       	jmp    80106209 <alltraps>

80106bc6 <vector90>:
.globl vector90
vector90:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $90
80106bc8:	6a 5a                	push   $0x5a
  jmp alltraps
80106bca:	e9 3a f6 ff ff       	jmp    80106209 <alltraps>

80106bcf <vector91>:
.globl vector91
vector91:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $91
80106bd1:	6a 5b                	push   $0x5b
  jmp alltraps
80106bd3:	e9 31 f6 ff ff       	jmp    80106209 <alltraps>

80106bd8 <vector92>:
.globl vector92
vector92:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $92
80106bda:	6a 5c                	push   $0x5c
  jmp alltraps
80106bdc:	e9 28 f6 ff ff       	jmp    80106209 <alltraps>

80106be1 <vector93>:
.globl vector93
vector93:
  pushl $0
80106be1:	6a 00                	push   $0x0
  pushl $93
80106be3:	6a 5d                	push   $0x5d
  jmp alltraps
80106be5:	e9 1f f6 ff ff       	jmp    80106209 <alltraps>

80106bea <vector94>:
.globl vector94
vector94:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $94
80106bec:	6a 5e                	push   $0x5e
  jmp alltraps
80106bee:	e9 16 f6 ff ff       	jmp    80106209 <alltraps>

80106bf3 <vector95>:
.globl vector95
vector95:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $95
80106bf5:	6a 5f                	push   $0x5f
  jmp alltraps
80106bf7:	e9 0d f6 ff ff       	jmp    80106209 <alltraps>

80106bfc <vector96>:
.globl vector96
vector96:
  pushl $0
80106bfc:	6a 00                	push   $0x0
  pushl $96
80106bfe:	6a 60                	push   $0x60
  jmp alltraps
80106c00:	e9 04 f6 ff ff       	jmp    80106209 <alltraps>

80106c05 <vector97>:
.globl vector97
vector97:
  pushl $0
80106c05:	6a 00                	push   $0x0
  pushl $97
80106c07:	6a 61                	push   $0x61
  jmp alltraps
80106c09:	e9 fb f5 ff ff       	jmp    80106209 <alltraps>

80106c0e <vector98>:
.globl vector98
vector98:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $98
80106c10:	6a 62                	push   $0x62
  jmp alltraps
80106c12:	e9 f2 f5 ff ff       	jmp    80106209 <alltraps>

80106c17 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $99
80106c19:	6a 63                	push   $0x63
  jmp alltraps
80106c1b:	e9 e9 f5 ff ff       	jmp    80106209 <alltraps>

80106c20 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $100
80106c22:	6a 64                	push   $0x64
  jmp alltraps
80106c24:	e9 e0 f5 ff ff       	jmp    80106209 <alltraps>

80106c29 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $101
80106c2b:	6a 65                	push   $0x65
  jmp alltraps
80106c2d:	e9 d7 f5 ff ff       	jmp    80106209 <alltraps>

80106c32 <vector102>:
.globl vector102
vector102:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $102
80106c34:	6a 66                	push   $0x66
  jmp alltraps
80106c36:	e9 ce f5 ff ff       	jmp    80106209 <alltraps>

80106c3b <vector103>:
.globl vector103
vector103:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $103
80106c3d:	6a 67                	push   $0x67
  jmp alltraps
80106c3f:	e9 c5 f5 ff ff       	jmp    80106209 <alltraps>

80106c44 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $104
80106c46:	6a 68                	push   $0x68
  jmp alltraps
80106c48:	e9 bc f5 ff ff       	jmp    80106209 <alltraps>

80106c4d <vector105>:
.globl vector105
vector105:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $105
80106c4f:	6a 69                	push   $0x69
  jmp alltraps
80106c51:	e9 b3 f5 ff ff       	jmp    80106209 <alltraps>

80106c56 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $106
80106c58:	6a 6a                	push   $0x6a
  jmp alltraps
80106c5a:	e9 aa f5 ff ff       	jmp    80106209 <alltraps>

80106c5f <vector107>:
.globl vector107
vector107:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $107
80106c61:	6a 6b                	push   $0x6b
  jmp alltraps
80106c63:	e9 a1 f5 ff ff       	jmp    80106209 <alltraps>

80106c68 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c68:	6a 00                	push   $0x0
  pushl $108
80106c6a:	6a 6c                	push   $0x6c
  jmp alltraps
80106c6c:	e9 98 f5 ff ff       	jmp    80106209 <alltraps>

80106c71 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c71:	6a 00                	push   $0x0
  pushl $109
80106c73:	6a 6d                	push   $0x6d
  jmp alltraps
80106c75:	e9 8f f5 ff ff       	jmp    80106209 <alltraps>

80106c7a <vector110>:
.globl vector110
vector110:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $110
80106c7c:	6a 6e                	push   $0x6e
  jmp alltraps
80106c7e:	e9 86 f5 ff ff       	jmp    80106209 <alltraps>

80106c83 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $111
80106c85:	6a 6f                	push   $0x6f
  jmp alltraps
80106c87:	e9 7d f5 ff ff       	jmp    80106209 <alltraps>

80106c8c <vector112>:
.globl vector112
vector112:
  pushl $0
80106c8c:	6a 00                	push   $0x0
  pushl $112
80106c8e:	6a 70                	push   $0x70
  jmp alltraps
80106c90:	e9 74 f5 ff ff       	jmp    80106209 <alltraps>

80106c95 <vector113>:
.globl vector113
vector113:
  pushl $0
80106c95:	6a 00                	push   $0x0
  pushl $113
80106c97:	6a 71                	push   $0x71
  jmp alltraps
80106c99:	e9 6b f5 ff ff       	jmp    80106209 <alltraps>

80106c9e <vector114>:
.globl vector114
vector114:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $114
80106ca0:	6a 72                	push   $0x72
  jmp alltraps
80106ca2:	e9 62 f5 ff ff       	jmp    80106209 <alltraps>

80106ca7 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $115
80106ca9:	6a 73                	push   $0x73
  jmp alltraps
80106cab:	e9 59 f5 ff ff       	jmp    80106209 <alltraps>

80106cb0 <vector116>:
.globl vector116
vector116:
  pushl $0
80106cb0:	6a 00                	push   $0x0
  pushl $116
80106cb2:	6a 74                	push   $0x74
  jmp alltraps
80106cb4:	e9 50 f5 ff ff       	jmp    80106209 <alltraps>

80106cb9 <vector117>:
.globl vector117
vector117:
  pushl $0
80106cb9:	6a 00                	push   $0x0
  pushl $117
80106cbb:	6a 75                	push   $0x75
  jmp alltraps
80106cbd:	e9 47 f5 ff ff       	jmp    80106209 <alltraps>

80106cc2 <vector118>:
.globl vector118
vector118:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $118
80106cc4:	6a 76                	push   $0x76
  jmp alltraps
80106cc6:	e9 3e f5 ff ff       	jmp    80106209 <alltraps>

80106ccb <vector119>:
.globl vector119
vector119:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $119
80106ccd:	6a 77                	push   $0x77
  jmp alltraps
80106ccf:	e9 35 f5 ff ff       	jmp    80106209 <alltraps>

80106cd4 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $120
80106cd6:	6a 78                	push   $0x78
  jmp alltraps
80106cd8:	e9 2c f5 ff ff       	jmp    80106209 <alltraps>

80106cdd <vector121>:
.globl vector121
vector121:
  pushl $0
80106cdd:	6a 00                	push   $0x0
  pushl $121
80106cdf:	6a 79                	push   $0x79
  jmp alltraps
80106ce1:	e9 23 f5 ff ff       	jmp    80106209 <alltraps>

80106ce6 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $122
80106ce8:	6a 7a                	push   $0x7a
  jmp alltraps
80106cea:	e9 1a f5 ff ff       	jmp    80106209 <alltraps>

80106cef <vector123>:
.globl vector123
vector123:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $123
80106cf1:	6a 7b                	push   $0x7b
  jmp alltraps
80106cf3:	e9 11 f5 ff ff       	jmp    80106209 <alltraps>

80106cf8 <vector124>:
.globl vector124
vector124:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $124
80106cfa:	6a 7c                	push   $0x7c
  jmp alltraps
80106cfc:	e9 08 f5 ff ff       	jmp    80106209 <alltraps>

80106d01 <vector125>:
.globl vector125
vector125:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $125
80106d03:	6a 7d                	push   $0x7d
  jmp alltraps
80106d05:	e9 ff f4 ff ff       	jmp    80106209 <alltraps>

80106d0a <vector126>:
.globl vector126
vector126:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $126
80106d0c:	6a 7e                	push   $0x7e
  jmp alltraps
80106d0e:	e9 f6 f4 ff ff       	jmp    80106209 <alltraps>

80106d13 <vector127>:
.globl vector127
vector127:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $127
80106d15:	6a 7f                	push   $0x7f
  jmp alltraps
80106d17:	e9 ed f4 ff ff       	jmp    80106209 <alltraps>

80106d1c <vector128>:
.globl vector128
vector128:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $128
80106d1e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d23:	e9 e1 f4 ff ff       	jmp    80106209 <alltraps>

80106d28 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d28:	6a 00                	push   $0x0
  pushl $129
80106d2a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d2f:	e9 d5 f4 ff ff       	jmp    80106209 <alltraps>

80106d34 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d34:	6a 00                	push   $0x0
  pushl $130
80106d36:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d3b:	e9 c9 f4 ff ff       	jmp    80106209 <alltraps>

80106d40 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d40:	6a 00                	push   $0x0
  pushl $131
80106d42:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d47:	e9 bd f4 ff ff       	jmp    80106209 <alltraps>

80106d4c <vector132>:
.globl vector132
vector132:
  pushl $0
80106d4c:	6a 00                	push   $0x0
  pushl $132
80106d4e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d53:	e9 b1 f4 ff ff       	jmp    80106209 <alltraps>

80106d58 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d58:	6a 00                	push   $0x0
  pushl $133
80106d5a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d5f:	e9 a5 f4 ff ff       	jmp    80106209 <alltraps>

80106d64 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d64:	6a 00                	push   $0x0
  pushl $134
80106d66:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d6b:	e9 99 f4 ff ff       	jmp    80106209 <alltraps>

80106d70 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d70:	6a 00                	push   $0x0
  pushl $135
80106d72:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d77:	e9 8d f4 ff ff       	jmp    80106209 <alltraps>

80106d7c <vector136>:
.globl vector136
vector136:
  pushl $0
80106d7c:	6a 00                	push   $0x0
  pushl $136
80106d7e:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d83:	e9 81 f4 ff ff       	jmp    80106209 <alltraps>

80106d88 <vector137>:
.globl vector137
vector137:
  pushl $0
80106d88:	6a 00                	push   $0x0
  pushl $137
80106d8a:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d8f:	e9 75 f4 ff ff       	jmp    80106209 <alltraps>

80106d94 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d94:	6a 00                	push   $0x0
  pushl $138
80106d96:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d9b:	e9 69 f4 ff ff       	jmp    80106209 <alltraps>

80106da0 <vector139>:
.globl vector139
vector139:
  pushl $0
80106da0:	6a 00                	push   $0x0
  pushl $139
80106da2:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106da7:	e9 5d f4 ff ff       	jmp    80106209 <alltraps>

80106dac <vector140>:
.globl vector140
vector140:
  pushl $0
80106dac:	6a 00                	push   $0x0
  pushl $140
80106dae:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106db3:	e9 51 f4 ff ff       	jmp    80106209 <alltraps>

80106db8 <vector141>:
.globl vector141
vector141:
  pushl $0
80106db8:	6a 00                	push   $0x0
  pushl $141
80106dba:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106dbf:	e9 45 f4 ff ff       	jmp    80106209 <alltraps>

80106dc4 <vector142>:
.globl vector142
vector142:
  pushl $0
80106dc4:	6a 00                	push   $0x0
  pushl $142
80106dc6:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106dcb:	e9 39 f4 ff ff       	jmp    80106209 <alltraps>

80106dd0 <vector143>:
.globl vector143
vector143:
  pushl $0
80106dd0:	6a 00                	push   $0x0
  pushl $143
80106dd2:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106dd7:	e9 2d f4 ff ff       	jmp    80106209 <alltraps>

80106ddc <vector144>:
.globl vector144
vector144:
  pushl $0
80106ddc:	6a 00                	push   $0x0
  pushl $144
80106dde:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106de3:	e9 21 f4 ff ff       	jmp    80106209 <alltraps>

80106de8 <vector145>:
.globl vector145
vector145:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $145
80106dea:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106def:	e9 15 f4 ff ff       	jmp    80106209 <alltraps>

80106df4 <vector146>:
.globl vector146
vector146:
  pushl $0
80106df4:	6a 00                	push   $0x0
  pushl $146
80106df6:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106dfb:	e9 09 f4 ff ff       	jmp    80106209 <alltraps>

80106e00 <vector147>:
.globl vector147
vector147:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $147
80106e02:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e07:	e9 fd f3 ff ff       	jmp    80106209 <alltraps>

80106e0c <vector148>:
.globl vector148
vector148:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $148
80106e0e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e13:	e9 f1 f3 ff ff       	jmp    80106209 <alltraps>

80106e18 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e18:	6a 00                	push   $0x0
  pushl $149
80106e1a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e1f:	e9 e5 f3 ff ff       	jmp    80106209 <alltraps>

80106e24 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $150
80106e26:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e2b:	e9 d9 f3 ff ff       	jmp    80106209 <alltraps>

80106e30 <vector151>:
.globl vector151
vector151:
  pushl $0
80106e30:	6a 00                	push   $0x0
  pushl $151
80106e32:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e37:	e9 cd f3 ff ff       	jmp    80106209 <alltraps>

80106e3c <vector152>:
.globl vector152
vector152:
  pushl $0
80106e3c:	6a 00                	push   $0x0
  pushl $152
80106e3e:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e43:	e9 c1 f3 ff ff       	jmp    80106209 <alltraps>

80106e48 <vector153>:
.globl vector153
vector153:
  pushl $0
80106e48:	6a 00                	push   $0x0
  pushl $153
80106e4a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e4f:	e9 b5 f3 ff ff       	jmp    80106209 <alltraps>

80106e54 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $154
80106e56:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e5b:	e9 a9 f3 ff ff       	jmp    80106209 <alltraps>

80106e60 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e60:	6a 00                	push   $0x0
  pushl $155
80106e62:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e67:	e9 9d f3 ff ff       	jmp    80106209 <alltraps>

80106e6c <vector156>:
.globl vector156
vector156:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $156
80106e6e:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e73:	e9 91 f3 ff ff       	jmp    80106209 <alltraps>

80106e78 <vector157>:
.globl vector157
vector157:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $157
80106e7a:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e7f:	e9 85 f3 ff ff       	jmp    80106209 <alltraps>

80106e84 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e84:	6a 00                	push   $0x0
  pushl $158
80106e86:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e8b:	e9 79 f3 ff ff       	jmp    80106209 <alltraps>

80106e90 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e90:	6a 00                	push   $0x0
  pushl $159
80106e92:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e97:	e9 6d f3 ff ff       	jmp    80106209 <alltraps>

80106e9c <vector160>:
.globl vector160
vector160:
  pushl $0
80106e9c:	6a 00                	push   $0x0
  pushl $160
80106e9e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ea3:	e9 61 f3 ff ff       	jmp    80106209 <alltraps>

80106ea8 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $161
80106eaa:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106eaf:	e9 55 f3 ff ff       	jmp    80106209 <alltraps>

80106eb4 <vector162>:
.globl vector162
vector162:
  pushl $0
80106eb4:	6a 00                	push   $0x0
  pushl $162
80106eb6:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ebb:	e9 49 f3 ff ff       	jmp    80106209 <alltraps>

80106ec0 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ec0:	6a 00                	push   $0x0
  pushl $163
80106ec2:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ec7:	e9 3d f3 ff ff       	jmp    80106209 <alltraps>

80106ecc <vector164>:
.globl vector164
vector164:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $164
80106ece:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106ed3:	e9 31 f3 ff ff       	jmp    80106209 <alltraps>

80106ed8 <vector165>:
.globl vector165
vector165:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $165
80106eda:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106edf:	e9 25 f3 ff ff       	jmp    80106209 <alltraps>

80106ee4 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ee4:	6a 00                	push   $0x0
  pushl $166
80106ee6:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106eeb:	e9 19 f3 ff ff       	jmp    80106209 <alltraps>

80106ef0 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $167
80106ef2:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ef7:	e9 0d f3 ff ff       	jmp    80106209 <alltraps>

80106efc <vector168>:
.globl vector168
vector168:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $168
80106efe:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f03:	e9 01 f3 ff ff       	jmp    80106209 <alltraps>

80106f08 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f08:	6a 00                	push   $0x0
  pushl $169
80106f0a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f0f:	e9 f5 f2 ff ff       	jmp    80106209 <alltraps>

80106f14 <vector170>:
.globl vector170
vector170:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $170
80106f16:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f1b:	e9 e9 f2 ff ff       	jmp    80106209 <alltraps>

80106f20 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f20:	6a 00                	push   $0x0
  pushl $171
80106f22:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f27:	e9 dd f2 ff ff       	jmp    80106209 <alltraps>

80106f2c <vector172>:
.globl vector172
vector172:
  pushl $0
80106f2c:	6a 00                	push   $0x0
  pushl $172
80106f2e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f33:	e9 d1 f2 ff ff       	jmp    80106209 <alltraps>

80106f38 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $173
80106f3a:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f3f:	e9 c5 f2 ff ff       	jmp    80106209 <alltraps>

80106f44 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $174
80106f46:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f4b:	e9 b9 f2 ff ff       	jmp    80106209 <alltraps>

80106f50 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $175
80106f52:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f57:	e9 ad f2 ff ff       	jmp    80106209 <alltraps>

80106f5c <vector176>:
.globl vector176
vector176:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $176
80106f5e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f63:	e9 a1 f2 ff ff       	jmp    80106209 <alltraps>

80106f68 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $177
80106f6a:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f6f:	e9 95 f2 ff ff       	jmp    80106209 <alltraps>

80106f74 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f74:	6a 00                	push   $0x0
  pushl $178
80106f76:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f7b:	e9 89 f2 ff ff       	jmp    80106209 <alltraps>

80106f80 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $179
80106f82:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f87:	e9 7d f2 ff ff       	jmp    80106209 <alltraps>

80106f8c <vector180>:
.globl vector180
vector180:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $180
80106f8e:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f93:	e9 71 f2 ff ff       	jmp    80106209 <alltraps>

80106f98 <vector181>:
.globl vector181
vector181:
  pushl $0
80106f98:	6a 00                	push   $0x0
  pushl $181
80106f9a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f9f:	e9 65 f2 ff ff       	jmp    80106209 <alltraps>

80106fa4 <vector182>:
.globl vector182
vector182:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $182
80106fa6:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106fab:	e9 59 f2 ff ff       	jmp    80106209 <alltraps>

80106fb0 <vector183>:
.globl vector183
vector183:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $183
80106fb2:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106fb7:	e9 4d f2 ff ff       	jmp    80106209 <alltraps>

80106fbc <vector184>:
.globl vector184
vector184:
  pushl $0
80106fbc:	6a 00                	push   $0x0
  pushl $184
80106fbe:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fc3:	e9 41 f2 ff ff       	jmp    80106209 <alltraps>

80106fc8 <vector185>:
.globl vector185
vector185:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $185
80106fca:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fcf:	e9 35 f2 ff ff       	jmp    80106209 <alltraps>

80106fd4 <vector186>:
.globl vector186
vector186:
  pushl $0
80106fd4:	6a 00                	push   $0x0
  pushl $186
80106fd6:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fdb:	e9 29 f2 ff ff       	jmp    80106209 <alltraps>

80106fe0 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $187
80106fe2:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fe7:	e9 1d f2 ff ff       	jmp    80106209 <alltraps>

80106fec <vector188>:
.globl vector188
vector188:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $188
80106fee:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106ff3:	e9 11 f2 ff ff       	jmp    80106209 <alltraps>

80106ff8 <vector189>:
.globl vector189
vector189:
  pushl $0
80106ff8:	6a 00                	push   $0x0
  pushl $189
80106ffa:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fff:	e9 05 f2 ff ff       	jmp    80106209 <alltraps>

80107004 <vector190>:
.globl vector190
vector190:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $190
80107006:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010700b:	e9 f9 f1 ff ff       	jmp    80106209 <alltraps>

80107010 <vector191>:
.globl vector191
vector191:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $191
80107012:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107017:	e9 ed f1 ff ff       	jmp    80106209 <alltraps>

8010701c <vector192>:
.globl vector192
vector192:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $192
8010701e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107023:	e9 e1 f1 ff ff       	jmp    80106209 <alltraps>

80107028 <vector193>:
.globl vector193
vector193:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $193
8010702a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010702f:	e9 d5 f1 ff ff       	jmp    80106209 <alltraps>

80107034 <vector194>:
.globl vector194
vector194:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $194
80107036:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010703b:	e9 c9 f1 ff ff       	jmp    80106209 <alltraps>

80107040 <vector195>:
.globl vector195
vector195:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $195
80107042:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107047:	e9 bd f1 ff ff       	jmp    80106209 <alltraps>

8010704c <vector196>:
.globl vector196
vector196:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $196
8010704e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107053:	e9 b1 f1 ff ff       	jmp    80106209 <alltraps>

80107058 <vector197>:
.globl vector197
vector197:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $197
8010705a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010705f:	e9 a5 f1 ff ff       	jmp    80106209 <alltraps>

80107064 <vector198>:
.globl vector198
vector198:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $198
80107066:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010706b:	e9 99 f1 ff ff       	jmp    80106209 <alltraps>

80107070 <vector199>:
.globl vector199
vector199:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $199
80107072:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107077:	e9 8d f1 ff ff       	jmp    80106209 <alltraps>

8010707c <vector200>:
.globl vector200
vector200:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $200
8010707e:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107083:	e9 81 f1 ff ff       	jmp    80106209 <alltraps>

80107088 <vector201>:
.globl vector201
vector201:
  pushl $0
80107088:	6a 00                	push   $0x0
  pushl $201
8010708a:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010708f:	e9 75 f1 ff ff       	jmp    80106209 <alltraps>

80107094 <vector202>:
.globl vector202
vector202:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $202
80107096:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010709b:	e9 69 f1 ff ff       	jmp    80106209 <alltraps>

801070a0 <vector203>:
.globl vector203
vector203:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $203
801070a2:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801070a7:	e9 5d f1 ff ff       	jmp    80106209 <alltraps>

801070ac <vector204>:
.globl vector204
vector204:
  pushl $0
801070ac:	6a 00                	push   $0x0
  pushl $204
801070ae:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801070b3:	e9 51 f1 ff ff       	jmp    80106209 <alltraps>

801070b8 <vector205>:
.globl vector205
vector205:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $205
801070ba:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070bf:	e9 45 f1 ff ff       	jmp    80106209 <alltraps>

801070c4 <vector206>:
.globl vector206
vector206:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $206
801070c6:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070cb:	e9 39 f1 ff ff       	jmp    80106209 <alltraps>

801070d0 <vector207>:
.globl vector207
vector207:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $207
801070d2:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070d7:	e9 2d f1 ff ff       	jmp    80106209 <alltraps>

801070dc <vector208>:
.globl vector208
vector208:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $208
801070de:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070e3:	e9 21 f1 ff ff       	jmp    80106209 <alltraps>

801070e8 <vector209>:
.globl vector209
vector209:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $209
801070ea:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070ef:	e9 15 f1 ff ff       	jmp    80106209 <alltraps>

801070f4 <vector210>:
.globl vector210
vector210:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $210
801070f6:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070fb:	e9 09 f1 ff ff       	jmp    80106209 <alltraps>

80107100 <vector211>:
.globl vector211
vector211:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $211
80107102:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107107:	e9 fd f0 ff ff       	jmp    80106209 <alltraps>

8010710c <vector212>:
.globl vector212
vector212:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $212
8010710e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107113:	e9 f1 f0 ff ff       	jmp    80106209 <alltraps>

80107118 <vector213>:
.globl vector213
vector213:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $213
8010711a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010711f:	e9 e5 f0 ff ff       	jmp    80106209 <alltraps>

80107124 <vector214>:
.globl vector214
vector214:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $214
80107126:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010712b:	e9 d9 f0 ff ff       	jmp    80106209 <alltraps>

80107130 <vector215>:
.globl vector215
vector215:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $215
80107132:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107137:	e9 cd f0 ff ff       	jmp    80106209 <alltraps>

8010713c <vector216>:
.globl vector216
vector216:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $216
8010713e:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107143:	e9 c1 f0 ff ff       	jmp    80106209 <alltraps>

80107148 <vector217>:
.globl vector217
vector217:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $217
8010714a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010714f:	e9 b5 f0 ff ff       	jmp    80106209 <alltraps>

80107154 <vector218>:
.globl vector218
vector218:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $218
80107156:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010715b:	e9 a9 f0 ff ff       	jmp    80106209 <alltraps>

80107160 <vector219>:
.globl vector219
vector219:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $219
80107162:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107167:	e9 9d f0 ff ff       	jmp    80106209 <alltraps>

8010716c <vector220>:
.globl vector220
vector220:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $220
8010716e:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107173:	e9 91 f0 ff ff       	jmp    80106209 <alltraps>

80107178 <vector221>:
.globl vector221
vector221:
  pushl $0
80107178:	6a 00                	push   $0x0
  pushl $221
8010717a:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010717f:	e9 85 f0 ff ff       	jmp    80106209 <alltraps>

80107184 <vector222>:
.globl vector222
vector222:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $222
80107186:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010718b:	e9 79 f0 ff ff       	jmp    80106209 <alltraps>

80107190 <vector223>:
.globl vector223
vector223:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $223
80107192:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107197:	e9 6d f0 ff ff       	jmp    80106209 <alltraps>

8010719c <vector224>:
.globl vector224
vector224:
  pushl $0
8010719c:	6a 00                	push   $0x0
  pushl $224
8010719e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801071a3:	e9 61 f0 ff ff       	jmp    80106209 <alltraps>

801071a8 <vector225>:
.globl vector225
vector225:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $225
801071aa:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801071af:	e9 55 f0 ff ff       	jmp    80106209 <alltraps>

801071b4 <vector226>:
.globl vector226
vector226:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $226
801071b6:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071bb:	e9 49 f0 ff ff       	jmp    80106209 <alltraps>

801071c0 <vector227>:
.globl vector227
vector227:
  pushl $0
801071c0:	6a 00                	push   $0x0
  pushl $227
801071c2:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071c7:	e9 3d f0 ff ff       	jmp    80106209 <alltraps>

801071cc <vector228>:
.globl vector228
vector228:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $228
801071ce:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071d3:	e9 31 f0 ff ff       	jmp    80106209 <alltraps>

801071d8 <vector229>:
.globl vector229
vector229:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $229
801071da:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071df:	e9 25 f0 ff ff       	jmp    80106209 <alltraps>

801071e4 <vector230>:
.globl vector230
vector230:
  pushl $0
801071e4:	6a 00                	push   $0x0
  pushl $230
801071e6:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071eb:	e9 19 f0 ff ff       	jmp    80106209 <alltraps>

801071f0 <vector231>:
.globl vector231
vector231:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $231
801071f2:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071f7:	e9 0d f0 ff ff       	jmp    80106209 <alltraps>

801071fc <vector232>:
.globl vector232
vector232:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $232
801071fe:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107203:	e9 01 f0 ff ff       	jmp    80106209 <alltraps>

80107208 <vector233>:
.globl vector233
vector233:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $233
8010720a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010720f:	e9 f5 ef ff ff       	jmp    80106209 <alltraps>

80107214 <vector234>:
.globl vector234
vector234:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $234
80107216:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010721b:	e9 e9 ef ff ff       	jmp    80106209 <alltraps>

80107220 <vector235>:
.globl vector235
vector235:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $235
80107222:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107227:	e9 dd ef ff ff       	jmp    80106209 <alltraps>

8010722c <vector236>:
.globl vector236
vector236:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $236
8010722e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107233:	e9 d1 ef ff ff       	jmp    80106209 <alltraps>

80107238 <vector237>:
.globl vector237
vector237:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $237
8010723a:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010723f:	e9 c5 ef ff ff       	jmp    80106209 <alltraps>

80107244 <vector238>:
.globl vector238
vector238:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $238
80107246:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010724b:	e9 b9 ef ff ff       	jmp    80106209 <alltraps>

80107250 <vector239>:
.globl vector239
vector239:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $239
80107252:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107257:	e9 ad ef ff ff       	jmp    80106209 <alltraps>

8010725c <vector240>:
.globl vector240
vector240:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $240
8010725e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107263:	e9 a1 ef ff ff       	jmp    80106209 <alltraps>

80107268 <vector241>:
.globl vector241
vector241:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $241
8010726a:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010726f:	e9 95 ef ff ff       	jmp    80106209 <alltraps>

80107274 <vector242>:
.globl vector242
vector242:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $242
80107276:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010727b:	e9 89 ef ff ff       	jmp    80106209 <alltraps>

80107280 <vector243>:
.globl vector243
vector243:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $243
80107282:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107287:	e9 7d ef ff ff       	jmp    80106209 <alltraps>

8010728c <vector244>:
.globl vector244
vector244:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $244
8010728e:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107293:	e9 71 ef ff ff       	jmp    80106209 <alltraps>

80107298 <vector245>:
.globl vector245
vector245:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $245
8010729a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010729f:	e9 65 ef ff ff       	jmp    80106209 <alltraps>

801072a4 <vector246>:
.globl vector246
vector246:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $246
801072a6:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801072ab:	e9 59 ef ff ff       	jmp    80106209 <alltraps>

801072b0 <vector247>:
.globl vector247
vector247:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $247
801072b2:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801072b7:	e9 4d ef ff ff       	jmp    80106209 <alltraps>

801072bc <vector248>:
.globl vector248
vector248:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $248
801072be:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072c3:	e9 41 ef ff ff       	jmp    80106209 <alltraps>

801072c8 <vector249>:
.globl vector249
vector249:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $249
801072ca:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072cf:	e9 35 ef ff ff       	jmp    80106209 <alltraps>

801072d4 <vector250>:
.globl vector250
vector250:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $250
801072d6:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072db:	e9 29 ef ff ff       	jmp    80106209 <alltraps>

801072e0 <vector251>:
.globl vector251
vector251:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $251
801072e2:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072e7:	e9 1d ef ff ff       	jmp    80106209 <alltraps>

801072ec <vector252>:
.globl vector252
vector252:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $252
801072ee:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072f3:	e9 11 ef ff ff       	jmp    80106209 <alltraps>

801072f8 <vector253>:
.globl vector253
vector253:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $253
801072fa:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072ff:	e9 05 ef ff ff       	jmp    80106209 <alltraps>

80107304 <vector254>:
.globl vector254
vector254:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $254
80107306:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010730b:	e9 f9 ee ff ff       	jmp    80106209 <alltraps>

80107310 <vector255>:
.globl vector255
vector255:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $255
80107312:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107317:	e9 ed ee ff ff       	jmp    80106209 <alltraps>

8010731c <lgdt>:
{
8010731c:	55                   	push   %ebp
8010731d:	89 e5                	mov    %esp,%ebp
8010731f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107322:	8b 45 0c             	mov    0xc(%ebp),%eax
80107325:	83 e8 01             	sub    $0x1,%eax
80107328:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010732c:	8b 45 08             	mov    0x8(%ebp),%eax
8010732f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107333:	8b 45 08             	mov    0x8(%ebp),%eax
80107336:	c1 e8 10             	shr    $0x10,%eax
80107339:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010733d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107340:	0f 01 10             	lgdtl  (%eax)
}
80107343:	90                   	nop
80107344:	c9                   	leave
80107345:	c3                   	ret

80107346 <ltr>:
{
80107346:	55                   	push   %ebp
80107347:	89 e5                	mov    %esp,%ebp
80107349:	83 ec 04             	sub    $0x4,%esp
8010734c:	8b 45 08             	mov    0x8(%ebp),%eax
8010734f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107353:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107357:	0f 00 d8             	ltr    %eax
}
8010735a:	90                   	nop
8010735b:	c9                   	leave
8010735c:	c3                   	ret

8010735d <lcr3>:

static inline void
lcr3(uint val)
{
8010735d:	55                   	push   %ebp
8010735e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107360:	8b 45 08             	mov    0x8(%ebp),%eax
80107363:	0f 22 d8             	mov    %eax,%cr3
}
80107366:	90                   	nop
80107367:	5d                   	pop    %ebp
80107368:	c3                   	ret

80107369 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107369:	55                   	push   %ebp
8010736a:	89 e5                	mov    %esp,%ebp
8010736c:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010736f:	e8 30 c6 ff ff       	call   801039a4 <cpuid>
80107374:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
8010737a:	05 80 74 19 80       	add    $0x80197480,%eax
8010737f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107385:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010738b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107397:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010739b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073a2:	83 e2 f0             	and    $0xfffffff0,%edx
801073a5:	83 ca 0a             	or     $0xa,%edx
801073a8:	88 50 7d             	mov    %dl,0x7d(%eax)
801073ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ae:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073b2:	83 ca 10             	or     $0x10,%edx
801073b5:	88 50 7d             	mov    %dl,0x7d(%eax)
801073b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073bf:	83 e2 9f             	and    $0xffffff9f,%edx
801073c2:	88 50 7d             	mov    %dl,0x7d(%eax)
801073c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073cc:	83 ca 80             	or     $0xffffff80,%edx
801073cf:	88 50 7d             	mov    %dl,0x7d(%eax)
801073d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073d9:	83 ca 0f             	or     $0xf,%edx
801073dc:	88 50 7e             	mov    %dl,0x7e(%eax)
801073df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073e6:	83 e2 ef             	and    $0xffffffef,%edx
801073e9:	88 50 7e             	mov    %dl,0x7e(%eax)
801073ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073f3:	83 e2 df             	and    $0xffffffdf,%edx
801073f6:	88 50 7e             	mov    %dl,0x7e(%eax)
801073f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107400:	83 ca 40             	or     $0x40,%edx
80107403:	88 50 7e             	mov    %dl,0x7e(%eax)
80107406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107409:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010740d:	83 ca 80             	or     $0xffffff80,%edx
80107410:	88 50 7e             	mov    %dl,0x7e(%eax)
80107413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107416:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010741a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107424:	ff ff 
80107426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107429:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107430:	00 00 
80107432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107435:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010743c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107446:	83 e2 f0             	and    $0xfffffff0,%edx
80107449:	83 ca 02             	or     $0x2,%edx
8010744c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107455:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010745c:	83 ca 10             	or     $0x10,%edx
8010745f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107468:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010746f:	83 e2 9f             	and    $0xffffff9f,%edx
80107472:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107482:	83 ca 80             	or     $0xffffff80,%edx
80107485:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010748b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107495:	83 ca 0f             	or     $0xf,%edx
80107498:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010749e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074a8:	83 e2 ef             	and    $0xffffffef,%edx
801074ab:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074bb:	83 e2 df             	and    $0xffffffdf,%edx
801074be:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074ce:	83 ca 40             	or     $0x40,%edx
801074d1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074da:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074e1:	83 ca 80             	or     $0xffffff80,%edx
801074e4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ed:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f7:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074fe:	ff ff 
80107500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107503:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010750a:	00 00 
8010750c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750f:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107519:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107520:	83 e2 f0             	and    $0xfffffff0,%edx
80107523:	83 ca 0a             	or     $0xa,%edx
80107526:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010752c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107536:	83 ca 10             	or     $0x10,%edx
80107539:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010753f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107542:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107549:	83 ca 60             	or     $0x60,%edx
8010754c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010755c:	83 ca 80             	or     $0xffffff80,%edx
8010755f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107568:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010756f:	83 ca 0f             	or     $0xf,%edx
80107572:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107582:	83 e2 ef             	and    $0xffffffef,%edx
80107585:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010758b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107595:	83 e2 df             	and    $0xffffffdf,%edx
80107598:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010759e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075a8:	83 ca 40             	or     $0x40,%edx
801075ab:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075bb:	83 ca 80             	or     $0xffffff80,%edx
801075be:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c7:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075d8:	ff ff 
801075da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dd:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075e4:	00 00 
801075e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e9:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075fa:	83 e2 f0             	and    $0xfffffff0,%edx
801075fd:	83 ca 02             	or     $0x2,%edx
80107600:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107609:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107610:	83 ca 10             	or     $0x10,%edx
80107613:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107623:	83 ca 60             	or     $0x60,%edx
80107626:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010762c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107636:	83 ca 80             	or     $0xffffff80,%edx
80107639:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010763f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107642:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107649:	83 ca 0f             	or     $0xf,%edx
8010764c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107655:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010765c:	83 e2 ef             	and    $0xffffffef,%edx
8010765f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107668:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010766f:	83 e2 df             	and    $0xffffffdf,%edx
80107672:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107682:	83 ca 40             	or     $0x40,%edx
80107685:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010768b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107695:	83 ca 80             	or     $0xffffff80,%edx
80107698:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010769e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801076a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ab:	83 c0 70             	add    $0x70,%eax
801076ae:	83 ec 08             	sub    $0x8,%esp
801076b1:	6a 30                	push   $0x30
801076b3:	50                   	push   %eax
801076b4:	e8 63 fc ff ff       	call   8010731c <lgdt>
801076b9:	83 c4 10             	add    $0x10,%esp
}
801076bc:	90                   	nop
801076bd:	c9                   	leave
801076be:	c3                   	ret

801076bf <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076bf:	55                   	push   %ebp
801076c0:	89 e5                	mov    %esp,%ebp
801076c2:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801076c8:	c1 e8 16             	shr    $0x16,%eax
801076cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076d2:	8b 45 08             	mov    0x8(%ebp),%eax
801076d5:	01 d0                	add    %edx,%eax
801076d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076dd:	8b 00                	mov    (%eax),%eax
801076df:	83 e0 01             	and    $0x1,%eax
801076e2:	85 c0                	test   %eax,%eax
801076e4:	74 14                	je     801076fa <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076e9:	8b 00                	mov    (%eax),%eax
801076eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076f0:	05 00 00 00 80       	add    $0x80000000,%eax
801076f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076f8:	eb 42                	jmp    8010773c <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076fe:	74 0e                	je     8010770e <walkpgdir+0x4f>
80107700:	e8 a3 b0 ff ff       	call   801027a8 <kalloc>
80107705:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107708:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010770c:	75 07                	jne    80107715 <walkpgdir+0x56>
      return 0;
8010770e:	b8 00 00 00 00       	mov    $0x0,%eax
80107713:	eb 3e                	jmp    80107753 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107715:	83 ec 04             	sub    $0x4,%esp
80107718:	68 00 10 00 00       	push   $0x1000
8010771d:	6a 00                	push   $0x0
8010771f:	ff 75 f4             	push   -0xc(%ebp)
80107722:	e8 e9 d6 ff ff       	call   80104e10 <memset>
80107727:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010772a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772d:	05 00 00 00 80       	add    $0x80000000,%eax
80107732:	83 c8 07             	or     $0x7,%eax
80107735:	89 c2                	mov    %eax,%edx
80107737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010773a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010773c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010773f:	c1 e8 0c             	shr    $0xc,%eax
80107742:	25 ff 03 00 00       	and    $0x3ff,%eax
80107747:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010774e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107751:	01 d0                	add    %edx,%eax
}
80107753:	c9                   	leave
80107754:	c3                   	ret

80107755 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107755:	55                   	push   %ebp
80107756:	89 e5                	mov    %esp,%ebp
80107758:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010775b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010775e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107763:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107766:	8b 55 0c             	mov    0xc(%ebp),%edx
80107769:	8b 45 10             	mov    0x10(%ebp),%eax
8010776c:	01 d0                	add    %edx,%eax
8010776e:	83 e8 01             	sub    $0x1,%eax
80107771:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107776:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107779:	83 ec 04             	sub    $0x4,%esp
8010777c:	6a 01                	push   $0x1
8010777e:	ff 75 f4             	push   -0xc(%ebp)
80107781:	ff 75 08             	push   0x8(%ebp)
80107784:	e8 36 ff ff ff       	call   801076bf <walkpgdir>
80107789:	83 c4 10             	add    $0x10,%esp
8010778c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010778f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107793:	75 07                	jne    8010779c <mappages+0x47>
      return -1;
80107795:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010779a:	eb 47                	jmp    801077e3 <mappages+0x8e>
    if(*pte & PTE_P)
8010779c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010779f:	8b 00                	mov    (%eax),%eax
801077a1:	83 e0 01             	and    $0x1,%eax
801077a4:	85 c0                	test   %eax,%eax
801077a6:	74 0d                	je     801077b5 <mappages+0x60>
      panic("remap");
801077a8:	83 ec 0c             	sub    $0xc,%esp
801077ab:	68 d8 aa 10 80       	push   $0x8010aad8
801077b0:	e8 f4 8d ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801077b5:	8b 45 18             	mov    0x18(%ebp),%eax
801077b8:	0b 45 14             	or     0x14(%ebp),%eax
801077bb:	83 c8 01             	or     $0x1,%eax
801077be:	89 c2                	mov    %eax,%edx
801077c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077c3:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077cb:	74 10                	je     801077dd <mappages+0x88>
      break;
    a += PGSIZE;
801077cd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801077d4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077db:	eb 9c                	jmp    80107779 <mappages+0x24>
      break;
801077dd:	90                   	nop
  }
  return 0;
801077de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077e3:	c9                   	leave
801077e4:	c3                   	ret

801077e5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077e5:	55                   	push   %ebp
801077e6:	89 e5                	mov    %esp,%ebp
801077e8:	53                   	push   %ebx
801077e9:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077ec:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077f3:	a1 60 77 19 80       	mov    0x80197760,%eax
801077f8:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801077fd:	29 c2                	sub    %eax,%edx
801077ff:	89 d0                	mov    %edx,%eax
80107801:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107804:	a1 58 77 19 80       	mov    0x80197758,%eax
80107809:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010780c:	8b 15 58 77 19 80    	mov    0x80197758,%edx
80107812:	a1 60 77 19 80       	mov    0x80197760,%eax
80107817:	01 d0                	add    %edx,%eax
80107819:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010781c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107826:	83 c0 30             	add    $0x30,%eax
80107829:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010782c:	89 10                	mov    %edx,(%eax)
8010782e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107831:	89 50 04             	mov    %edx,0x4(%eax)
80107834:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107837:	89 50 08             	mov    %edx,0x8(%eax)
8010783a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010783d:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107840:	e8 63 af ff ff       	call   801027a8 <kalloc>
80107845:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107848:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010784c:	75 07                	jne    80107855 <setupkvm+0x70>
    return 0;
8010784e:	b8 00 00 00 00       	mov    $0x0,%eax
80107853:	eb 78                	jmp    801078cd <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107855:	83 ec 04             	sub    $0x4,%esp
80107858:	68 00 10 00 00       	push   $0x1000
8010785d:	6a 00                	push   $0x0
8010785f:	ff 75 f0             	push   -0x10(%ebp)
80107862:	e8 a9 d5 ff ff       	call   80104e10 <memset>
80107867:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010786a:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107871:	eb 4e                	jmp    801078c1 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107876:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787c:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	8b 58 08             	mov    0x8(%eax),%ebx
80107885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107888:	8b 40 04             	mov    0x4(%eax),%eax
8010788b:	29 c3                	sub    %eax,%ebx
8010788d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107890:	8b 00                	mov    (%eax),%eax
80107892:	83 ec 0c             	sub    $0xc,%esp
80107895:	51                   	push   %ecx
80107896:	52                   	push   %edx
80107897:	53                   	push   %ebx
80107898:	50                   	push   %eax
80107899:	ff 75 f0             	push   -0x10(%ebp)
8010789c:	e8 b4 fe ff ff       	call   80107755 <mappages>
801078a1:	83 c4 20             	add    $0x20,%esp
801078a4:	85 c0                	test   %eax,%eax
801078a6:	79 15                	jns    801078bd <setupkvm+0xd8>
      freevm(pgdir);
801078a8:	83 ec 0c             	sub    $0xc,%esp
801078ab:	ff 75 f0             	push   -0x10(%ebp)
801078ae:	e8 f5 04 00 00       	call   80107da8 <freevm>
801078b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801078b6:	b8 00 00 00 00       	mov    $0x0,%eax
801078bb:	eb 10                	jmp    801078cd <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078bd:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078c1:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
801078c8:	72 a9                	jb     80107873 <setupkvm+0x8e>
    }
  return pgdir;
801078ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078d0:	c9                   	leave
801078d1:	c3                   	ret

801078d2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078d2:	55                   	push   %ebp
801078d3:	89 e5                	mov    %esp,%ebp
801078d5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078d8:	e8 08 ff ff ff       	call   801077e5 <setupkvm>
801078dd:	a3 7c 74 19 80       	mov    %eax,0x8019747c
  switchkvm();
801078e2:	e8 03 00 00 00       	call   801078ea <switchkvm>
}
801078e7:	90                   	nop
801078e8:	c9                   	leave
801078e9:	c3                   	ret

801078ea <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078ea:	55                   	push   %ebp
801078eb:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078ed:	a1 7c 74 19 80       	mov    0x8019747c,%eax
801078f2:	05 00 00 00 80       	add    $0x80000000,%eax
801078f7:	50                   	push   %eax
801078f8:	e8 60 fa ff ff       	call   8010735d <lcr3>
801078fd:	83 c4 04             	add    $0x4,%esp
}
80107900:	90                   	nop
80107901:	c9                   	leave
80107902:	c3                   	ret

80107903 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107903:	55                   	push   %ebp
80107904:	89 e5                	mov    %esp,%ebp
80107906:	56                   	push   %esi
80107907:	53                   	push   %ebx
80107908:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010790b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010790f:	75 0d                	jne    8010791e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107911:	83 ec 0c             	sub    $0xc,%esp
80107914:	68 de aa 10 80       	push   $0x8010aade
80107919:	e8 8b 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010791e:	8b 45 08             	mov    0x8(%ebp),%eax
80107921:	8b 40 08             	mov    0x8(%eax),%eax
80107924:	85 c0                	test   %eax,%eax
80107926:	75 0d                	jne    80107935 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107928:	83 ec 0c             	sub    $0xc,%esp
8010792b:	68 f4 aa 10 80       	push   $0x8010aaf4
80107930:	e8 74 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107935:	8b 45 08             	mov    0x8(%ebp),%eax
80107938:	8b 40 04             	mov    0x4(%eax),%eax
8010793b:	85 c0                	test   %eax,%eax
8010793d:	75 0d                	jne    8010794c <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010793f:	83 ec 0c             	sub    $0xc,%esp
80107942:	68 09 ab 10 80       	push   $0x8010ab09
80107947:	e8 5d 8c ff ff       	call   801005a9 <panic>

  pushcli();
8010794c:	e8 b4 d3 ff ff       	call   80104d05 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107951:	e8 69 c0 ff ff       	call   801039bf <mycpu>
80107956:	89 c3                	mov    %eax,%ebx
80107958:	e8 62 c0 ff ff       	call   801039bf <mycpu>
8010795d:	83 c0 08             	add    $0x8,%eax
80107960:	89 c6                	mov    %eax,%esi
80107962:	e8 58 c0 ff ff       	call   801039bf <mycpu>
80107967:	83 c0 08             	add    $0x8,%eax
8010796a:	c1 e8 10             	shr    $0x10,%eax
8010796d:	88 45 f7             	mov    %al,-0x9(%ebp)
80107970:	e8 4a c0 ff ff       	call   801039bf <mycpu>
80107975:	83 c0 08             	add    $0x8,%eax
80107978:	c1 e8 18             	shr    $0x18,%eax
8010797b:	89 c2                	mov    %eax,%edx
8010797d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107984:	67 00 
80107986:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010798d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107991:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107997:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010799e:	83 e0 f0             	and    $0xfffffff0,%eax
801079a1:	83 c8 09             	or     $0x9,%eax
801079a4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079aa:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079b1:	83 c8 10             	or     $0x10,%eax
801079b4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079ba:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079c1:	83 e0 9f             	and    $0xffffff9f,%eax
801079c4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079ca:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079d1:	83 c8 80             	or     $0xffffff80,%eax
801079d4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079da:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079e1:	83 e0 f0             	and    $0xfffffff0,%eax
801079e4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079ea:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079f1:	83 e0 ef             	and    $0xffffffef,%eax
801079f4:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079fa:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a01:	83 e0 df             	and    $0xffffffdf,%eax
80107a04:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a0a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a11:	83 c8 40             	or     $0x40,%eax
80107a14:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a1a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a21:	83 e0 7f             	and    $0x7f,%eax
80107a24:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a2a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a30:	e8 8a bf ff ff       	call   801039bf <mycpu>
80107a35:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a3c:	83 e2 ef             	and    $0xffffffef,%edx
80107a3f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a45:	e8 75 bf ff ff       	call   801039bf <mycpu>
80107a4a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a50:	8b 45 08             	mov    0x8(%ebp),%eax
80107a53:	8b 40 08             	mov    0x8(%eax),%eax
80107a56:	89 c3                	mov    %eax,%ebx
80107a58:	e8 62 bf ff ff       	call   801039bf <mycpu>
80107a5d:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a63:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a66:	e8 54 bf ff ff       	call   801039bf <mycpu>
80107a6b:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a71:	83 ec 0c             	sub    $0xc,%esp
80107a74:	6a 28                	push   $0x28
80107a76:	e8 cb f8 ff ff       	call   80107346 <ltr>
80107a7b:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a81:	8b 40 04             	mov    0x4(%eax),%eax
80107a84:	05 00 00 00 80       	add    $0x80000000,%eax
80107a89:	83 ec 0c             	sub    $0xc,%esp
80107a8c:	50                   	push   %eax
80107a8d:	e8 cb f8 ff ff       	call   8010735d <lcr3>
80107a92:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a95:	e8 b8 d2 ff ff       	call   80104d52 <popcli>
}
80107a9a:	90                   	nop
80107a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a9e:	5b                   	pop    %ebx
80107a9f:	5e                   	pop    %esi
80107aa0:	5d                   	pop    %ebp
80107aa1:	c3                   	ret

80107aa2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107aa2:	55                   	push   %ebp
80107aa3:	89 e5                	mov    %esp,%ebp
80107aa5:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107aa8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107aaf:	76 0d                	jbe    80107abe <inituvm+0x1c>
    panic("inituvm: more than a page");
80107ab1:	83 ec 0c             	sub    $0xc,%esp
80107ab4:	68 1d ab 10 80       	push   $0x8010ab1d
80107ab9:	e8 eb 8a ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107abe:	e8 e5 ac ff ff       	call   801027a8 <kalloc>
80107ac3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ac6:	83 ec 04             	sub    $0x4,%esp
80107ac9:	68 00 10 00 00       	push   $0x1000
80107ace:	6a 00                	push   $0x0
80107ad0:	ff 75 f4             	push   -0xc(%ebp)
80107ad3:	e8 38 d3 ff ff       	call   80104e10 <memset>
80107ad8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ade:	05 00 00 00 80       	add    $0x80000000,%eax
80107ae3:	83 ec 0c             	sub    $0xc,%esp
80107ae6:	6a 06                	push   $0x6
80107ae8:	50                   	push   %eax
80107ae9:	68 00 10 00 00       	push   $0x1000
80107aee:	6a 00                	push   $0x0
80107af0:	ff 75 08             	push   0x8(%ebp)
80107af3:	e8 5d fc ff ff       	call   80107755 <mappages>
80107af8:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107afb:	83 ec 04             	sub    $0x4,%esp
80107afe:	ff 75 10             	push   0x10(%ebp)
80107b01:	ff 75 0c             	push   0xc(%ebp)
80107b04:	ff 75 f4             	push   -0xc(%ebp)
80107b07:	e8 c3 d3 ff ff       	call   80104ecf <memmove>
80107b0c:	83 c4 10             	add    $0x10,%esp
}
80107b0f:	90                   	nop
80107b10:	c9                   	leave
80107b11:	c3                   	ret

80107b12 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b12:	55                   	push   %ebp
80107b13:	89 e5                	mov    %esp,%ebp
80107b15:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b18:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b1b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b20:	85 c0                	test   %eax,%eax
80107b22:	74 0d                	je     80107b31 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107b24:	83 ec 0c             	sub    $0xc,%esp
80107b27:	68 38 ab 10 80       	push   $0x8010ab38
80107b2c:	e8 78 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b38:	e9 8f 00 00 00       	jmp    80107bcc <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	01 d0                	add    %edx,%eax
80107b45:	83 ec 04             	sub    $0x4,%esp
80107b48:	6a 00                	push   $0x0
80107b4a:	50                   	push   %eax
80107b4b:	ff 75 08             	push   0x8(%ebp)
80107b4e:	e8 6c fb ff ff       	call   801076bf <walkpgdir>
80107b53:	83 c4 10             	add    $0x10,%esp
80107b56:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b59:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b5d:	75 0d                	jne    80107b6c <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107b5f:	83 ec 0c             	sub    $0xc,%esp
80107b62:	68 5b ab 10 80       	push   $0x8010ab5b
80107b67:	e8 3d 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b6f:	8b 00                	mov    (%eax),%eax
80107b71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b76:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b79:	8b 45 18             	mov    0x18(%ebp),%eax
80107b7c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b7f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b84:	77 0b                	ja     80107b91 <loaduvm+0x7f>
      n = sz - i;
80107b86:	8b 45 18             	mov    0x18(%ebp),%eax
80107b89:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b8f:	eb 07                	jmp    80107b98 <loaduvm+0x86>
    else
      n = PGSIZE;
80107b91:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b98:	8b 55 14             	mov    0x14(%ebp),%edx
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	01 d0                	add    %edx,%eax
80107ba0:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ba3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107ba9:	ff 75 f0             	push   -0x10(%ebp)
80107bac:	50                   	push   %eax
80107bad:	52                   	push   %edx
80107bae:	ff 75 10             	push   0x10(%ebp)
80107bb1:	e8 28 a3 ff ff       	call   80101ede <readi>
80107bb6:	83 c4 10             	add    $0x10,%esp
80107bb9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107bbc:	74 07                	je     80107bc5 <loaduvm+0xb3>
      return -1;
80107bbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bc3:	eb 18                	jmp    80107bdd <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107bc5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcf:	3b 45 18             	cmp    0x18(%ebp),%eax
80107bd2:	0f 82 65 ff ff ff    	jb     80107b3d <loaduvm+0x2b>
  }
  return 0;
80107bd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bdd:	c9                   	leave
80107bde:	c3                   	ret

80107bdf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107bdf:	55                   	push   %ebp
80107be0:	89 e5                	mov    %esp,%ebp
80107be2:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107be5:	8b 45 10             	mov    0x10(%ebp),%eax
80107be8:	85 c0                	test   %eax,%eax
80107bea:	79 0a                	jns    80107bf6 <allocuvm+0x17>
    return 0;
80107bec:	b8 00 00 00 00       	mov    $0x0,%eax
80107bf1:	e9 ec 00 00 00       	jmp    80107ce2 <allocuvm+0x103>
  if(newsz < oldsz)
80107bf6:	8b 45 10             	mov    0x10(%ebp),%eax
80107bf9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bfc:	73 08                	jae    80107c06 <allocuvm+0x27>
    return oldsz;
80107bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c01:	e9 dc 00 00 00       	jmp    80107ce2 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c09:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c16:	e9 b8 00 00 00       	jmp    80107cd3 <allocuvm+0xf4>
    mem = kalloc();
80107c1b:	e8 88 ab ff ff       	call   801027a8 <kalloc>
80107c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c27:	75 2e                	jne    80107c57 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107c29:	83 ec 0c             	sub    $0xc,%esp
80107c2c:	68 79 ab 10 80       	push   $0x8010ab79
80107c31:	e8 be 87 ff ff       	call   801003f4 <cprintf>
80107c36:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c39:	83 ec 04             	sub    $0x4,%esp
80107c3c:	ff 75 0c             	push   0xc(%ebp)
80107c3f:	ff 75 10             	push   0x10(%ebp)
80107c42:	ff 75 08             	push   0x8(%ebp)
80107c45:	e8 9a 00 00 00       	call   80107ce4 <deallocuvm>
80107c4a:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c4d:	b8 00 00 00 00       	mov    $0x0,%eax
80107c52:	e9 8b 00 00 00       	jmp    80107ce2 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107c57:	83 ec 04             	sub    $0x4,%esp
80107c5a:	68 00 10 00 00       	push   $0x1000
80107c5f:	6a 00                	push   $0x0
80107c61:	ff 75 f0             	push   -0x10(%ebp)
80107c64:	e8 a7 d1 ff ff       	call   80104e10 <memset>
80107c69:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c78:	83 ec 0c             	sub    $0xc,%esp
80107c7b:	6a 06                	push   $0x6
80107c7d:	52                   	push   %edx
80107c7e:	68 00 10 00 00       	push   $0x1000
80107c83:	50                   	push   %eax
80107c84:	ff 75 08             	push   0x8(%ebp)
80107c87:	e8 c9 fa ff ff       	call   80107755 <mappages>
80107c8c:	83 c4 20             	add    $0x20,%esp
80107c8f:	85 c0                	test   %eax,%eax
80107c91:	79 39                	jns    80107ccc <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107c93:	83 ec 0c             	sub    $0xc,%esp
80107c96:	68 91 ab 10 80       	push   $0x8010ab91
80107c9b:	e8 54 87 ff ff       	call   801003f4 <cprintf>
80107ca0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ca3:	83 ec 04             	sub    $0x4,%esp
80107ca6:	ff 75 0c             	push   0xc(%ebp)
80107ca9:	ff 75 10             	push   0x10(%ebp)
80107cac:	ff 75 08             	push   0x8(%ebp)
80107caf:	e8 30 00 00 00       	call   80107ce4 <deallocuvm>
80107cb4:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107cb7:	83 ec 0c             	sub    $0xc,%esp
80107cba:	ff 75 f0             	push   -0x10(%ebp)
80107cbd:	e8 4c aa ff ff       	call   8010270e <kfree>
80107cc2:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cc5:	b8 00 00 00 00       	mov    $0x0,%eax
80107cca:	eb 16                	jmp    80107ce2 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107ccc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	3b 45 10             	cmp    0x10(%ebp),%eax
80107cd9:	0f 82 3c ff ff ff    	jb     80107c1b <allocuvm+0x3c>
    }
  }
  return newsz;
80107cdf:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ce2:	c9                   	leave
80107ce3:	c3                   	ret

80107ce4 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ce4:	55                   	push   %ebp
80107ce5:	89 e5                	mov    %esp,%ebp
80107ce7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cea:	8b 45 10             	mov    0x10(%ebp),%eax
80107ced:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cf0:	72 08                	jb     80107cfa <deallocuvm+0x16>
    return oldsz;
80107cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cf5:	e9 ac 00 00 00       	jmp    80107da6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107cfa:	8b 45 10             	mov    0x10(%ebp),%eax
80107cfd:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d0a:	e9 88 00 00 00       	jmp    80107d97 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	83 ec 04             	sub    $0x4,%esp
80107d15:	6a 00                	push   $0x0
80107d17:	50                   	push   %eax
80107d18:	ff 75 08             	push   0x8(%ebp)
80107d1b:	e8 9f f9 ff ff       	call   801076bf <walkpgdir>
80107d20:	83 c4 10             	add    $0x10,%esp
80107d23:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d2a:	75 16                	jne    80107d42 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2f:	c1 e8 16             	shr    $0x16,%eax
80107d32:	83 c0 01             	add    $0x1,%eax
80107d35:	c1 e0 16             	shl    $0x16,%eax
80107d38:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d40:	eb 4e                	jmp    80107d90 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d45:	8b 00                	mov    (%eax),%eax
80107d47:	83 e0 01             	and    $0x1,%eax
80107d4a:	85 c0                	test   %eax,%eax
80107d4c:	74 42                	je     80107d90 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d51:	8b 00                	mov    (%eax),%eax
80107d53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d58:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d5f:	75 0d                	jne    80107d6e <deallocuvm+0x8a>
        panic("kfree");
80107d61:	83 ec 0c             	sub    $0xc,%esp
80107d64:	68 ad ab 10 80       	push   $0x8010abad
80107d69:	e8 3b 88 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107d6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d71:	05 00 00 00 80       	add    $0x80000000,%eax
80107d76:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d79:	83 ec 0c             	sub    $0xc,%esp
80107d7c:	ff 75 e8             	push   -0x18(%ebp)
80107d7f:	e8 8a a9 ff ff       	call   8010270e <kfree>
80107d84:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107d90:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d9d:	0f 82 6c ff ff ff    	jb     80107d0f <deallocuvm+0x2b>
    }
  }
  return newsz;
80107da3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107da6:	c9                   	leave
80107da7:	c3                   	ret

80107da8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107da8:	55                   	push   %ebp
80107da9:	89 e5                	mov    %esp,%ebp
80107dab:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107dae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107db2:	75 0d                	jne    80107dc1 <freevm+0x19>
    panic("freevm: no pgdir");
80107db4:	83 ec 0c             	sub    $0xc,%esp
80107db7:	68 b3 ab 10 80       	push   $0x8010abb3
80107dbc:	e8 e8 87 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107dc1:	83 ec 04             	sub    $0x4,%esp
80107dc4:	6a 00                	push   $0x0
80107dc6:	68 00 00 00 80       	push   $0x80000000
80107dcb:	ff 75 08             	push   0x8(%ebp)
80107dce:	e8 11 ff ff ff       	call   80107ce4 <deallocuvm>
80107dd3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107dd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ddd:	eb 48                	jmp    80107e27 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107de9:	8b 45 08             	mov    0x8(%ebp),%eax
80107dec:	01 d0                	add    %edx,%eax
80107dee:	8b 00                	mov    (%eax),%eax
80107df0:	83 e0 01             	and    $0x1,%eax
80107df3:	85 c0                	test   %eax,%eax
80107df5:	74 2c                	je     80107e23 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e01:	8b 45 08             	mov    0x8(%ebp),%eax
80107e04:	01 d0                	add    %edx,%eax
80107e06:	8b 00                	mov    (%eax),%eax
80107e08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e0d:	05 00 00 00 80       	add    $0x80000000,%eax
80107e12:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e15:	83 ec 0c             	sub    $0xc,%esp
80107e18:	ff 75 f0             	push   -0x10(%ebp)
80107e1b:	e8 ee a8 ff ff       	call   8010270e <kfree>
80107e20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e27:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e2e:	76 af                	jbe    80107ddf <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107e30:	83 ec 0c             	sub    $0xc,%esp
80107e33:	ff 75 08             	push   0x8(%ebp)
80107e36:	e8 d3 a8 ff ff       	call   8010270e <kfree>
80107e3b:	83 c4 10             	add    $0x10,%esp
}
80107e3e:	90                   	nop
80107e3f:	c9                   	leave
80107e40:	c3                   	ret

80107e41 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e41:	55                   	push   %ebp
80107e42:	89 e5                	mov    %esp,%ebp
80107e44:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e47:	83 ec 04             	sub    $0x4,%esp
80107e4a:	6a 00                	push   $0x0
80107e4c:	ff 75 0c             	push   0xc(%ebp)
80107e4f:	ff 75 08             	push   0x8(%ebp)
80107e52:	e8 68 f8 ff ff       	call   801076bf <walkpgdir>
80107e57:	83 c4 10             	add    $0x10,%esp
80107e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e61:	75 0d                	jne    80107e70 <clearpteu+0x2f>
    panic("clearpteu");
80107e63:	83 ec 0c             	sub    $0xc,%esp
80107e66:	68 c4 ab 10 80       	push   $0x8010abc4
80107e6b:	e8 39 87 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e73:	8b 00                	mov    (%eax),%eax
80107e75:	83 e0 fb             	and    $0xfffffffb,%eax
80107e78:	89 c2                	mov    %eax,%edx
80107e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7d:	89 10                	mov    %edx,(%eax)
}
80107e7f:	90                   	nop
80107e80:	c9                   	leave
80107e81:	c3                   	ret

80107e82 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e82:	55                   	push   %ebp
80107e83:	89 e5                	mov    %esp,%ebp
80107e85:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107e88:	e8 58 f9 ff ff       	call   801077e5 <setupkvm>
80107e8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e94:	75 0a                	jne    80107ea0 <copyuvm+0x1e>
    return 0;
80107e96:	b8 00 00 00 00       	mov    $0x0,%eax
80107e9b:	e9 eb 00 00 00       	jmp    80107f8b <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107ea0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ea7:	e9 b7 00 00 00       	jmp    80107f63 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaf:	83 ec 04             	sub    $0x4,%esp
80107eb2:	6a 00                	push   $0x0
80107eb4:	50                   	push   %eax
80107eb5:	ff 75 08             	push   0x8(%ebp)
80107eb8:	e8 02 f8 ff ff       	call   801076bf <walkpgdir>
80107ebd:	83 c4 10             	add    $0x10,%esp
80107ec0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ec3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ec7:	75 0d                	jne    80107ed6 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107ec9:	83 ec 0c             	sub    $0xc,%esp
80107ecc:	68 ce ab 10 80       	push   $0x8010abce
80107ed1:	e8 d3 86 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ed9:	8b 00                	mov    (%eax),%eax
80107edb:	83 e0 01             	and    $0x1,%eax
80107ede:	85 c0                	test   %eax,%eax
80107ee0:	75 0d                	jne    80107eef <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107ee2:	83 ec 0c             	sub    $0xc,%esp
80107ee5:	68 e8 ab 10 80       	push   $0x8010abe8
80107eea:	e8 ba 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef2:	8b 00                	mov    (%eax),%eax
80107ef4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eff:	8b 00                	mov    (%eax),%eax
80107f01:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107f09:	e8 9a a8 ff ff       	call   801027a8 <kalloc>
80107f0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f15:	74 5d                	je     80107f74 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f1a:	05 00 00 00 80       	add    $0x80000000,%eax
80107f1f:	83 ec 04             	sub    $0x4,%esp
80107f22:	68 00 10 00 00       	push   $0x1000
80107f27:	50                   	push   %eax
80107f28:	ff 75 e0             	push   -0x20(%ebp)
80107f2b:	e8 9f cf ff ff       	call   80104ecf <memmove>
80107f30:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f39:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f42:	83 ec 0c             	sub    $0xc,%esp
80107f45:	52                   	push   %edx
80107f46:	51                   	push   %ecx
80107f47:	68 00 10 00 00       	push   $0x1000
80107f4c:	50                   	push   %eax
80107f4d:	ff 75 f0             	push   -0x10(%ebp)
80107f50:	e8 00 f8 ff ff       	call   80107755 <mappages>
80107f55:	83 c4 20             	add    $0x20,%esp
80107f58:	85 c0                	test   %eax,%eax
80107f5a:	78 1b                	js     80107f77 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107f5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f66:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f69:	0f 82 3d ff ff ff    	jb     80107eac <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f72:	eb 17                	jmp    80107f8b <copyuvm+0x109>
      goto bad;
80107f74:	90                   	nop
80107f75:	eb 01                	jmp    80107f78 <copyuvm+0xf6>
      goto bad;
80107f77:	90                   	nop

bad:
  freevm(d);
80107f78:	83 ec 0c             	sub    $0xc,%esp
80107f7b:	ff 75 f0             	push   -0x10(%ebp)
80107f7e:	e8 25 fe ff ff       	call   80107da8 <freevm>
80107f83:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f8b:	c9                   	leave
80107f8c:	c3                   	ret

80107f8d <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f8d:	55                   	push   %ebp
80107f8e:	89 e5                	mov    %esp,%ebp
80107f90:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f93:	83 ec 04             	sub    $0x4,%esp
80107f96:	6a 00                	push   $0x0
80107f98:	ff 75 0c             	push   0xc(%ebp)
80107f9b:	ff 75 08             	push   0x8(%ebp)
80107f9e:	e8 1c f7 ff ff       	call   801076bf <walkpgdir>
80107fa3:	83 c4 10             	add    $0x10,%esp
80107fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fac:	8b 00                	mov    (%eax),%eax
80107fae:	83 e0 01             	and    $0x1,%eax
80107fb1:	85 c0                	test   %eax,%eax
80107fb3:	75 07                	jne    80107fbc <uva2ka+0x2f>
    return 0;
80107fb5:	b8 00 00 00 00       	mov    $0x0,%eax
80107fba:	eb 22                	jmp    80107fde <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbf:	8b 00                	mov    (%eax),%eax
80107fc1:	83 e0 04             	and    $0x4,%eax
80107fc4:	85 c0                	test   %eax,%eax
80107fc6:	75 07                	jne    80107fcf <uva2ka+0x42>
    return 0;
80107fc8:	b8 00 00 00 00       	mov    $0x0,%eax
80107fcd:	eb 0f                	jmp    80107fde <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd2:	8b 00                	mov    (%eax),%eax
80107fd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fd9:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107fde:	c9                   	leave
80107fdf:	c3                   	ret

80107fe0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107fe0:	55                   	push   %ebp
80107fe1:	89 e5                	mov    %esp,%ebp
80107fe3:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80107fe9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107fec:	eb 7f                	jmp    8010806d <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ff1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ff6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ffc:	83 ec 08             	sub    $0x8,%esp
80107fff:	50                   	push   %eax
80108000:	ff 75 08             	push   0x8(%ebp)
80108003:	e8 85 ff ff ff       	call   80107f8d <uva2ka>
80108008:	83 c4 10             	add    $0x10,%esp
8010800b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010800e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108012:	75 07                	jne    8010801b <copyout+0x3b>
      return -1;
80108014:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108019:	eb 61                	jmp    8010807c <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010801b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010801e:	2b 45 0c             	sub    0xc(%ebp),%eax
80108021:	05 00 10 00 00       	add    $0x1000,%eax
80108026:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802c:	39 45 14             	cmp    %eax,0x14(%ebp)
8010802f:	73 06                	jae    80108037 <copyout+0x57>
      n = len;
80108031:	8b 45 14             	mov    0x14(%ebp),%eax
80108034:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108037:	8b 45 0c             	mov    0xc(%ebp),%eax
8010803a:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010803d:	89 c2                	mov    %eax,%edx
8010803f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108042:	01 d0                	add    %edx,%eax
80108044:	83 ec 04             	sub    $0x4,%esp
80108047:	ff 75 f0             	push   -0x10(%ebp)
8010804a:	ff 75 f4             	push   -0xc(%ebp)
8010804d:	50                   	push   %eax
8010804e:	e8 7c ce ff ff       	call   80104ecf <memmove>
80108053:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108059:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010805c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108062:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108065:	05 00 10 00 00       	add    $0x1000,%eax
8010806a:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010806d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108071:	0f 85 77 ff ff ff    	jne    80107fee <copyout+0xe>
  }
  return 0;
80108077:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010807c:	c9                   	leave
8010807d:	c3                   	ret

8010807e <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010807e:	55                   	push   %ebp
8010807f:	89 e5                	mov    %esp,%ebp
80108081:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108084:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
8010808b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010808e:	8b 40 08             	mov    0x8(%eax),%eax
80108091:	05 00 00 00 80       	add    $0x80000000,%eax
80108096:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108099:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801080a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a3:	8b 40 24             	mov    0x24(%eax),%eax
801080a6:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
801080ab:	c7 05 50 77 19 80 00 	movl   $0x0,0x80197750
801080b2:	00 00 00 

  while(i<madt->len){
801080b5:	e9 bd 00 00 00       	jmp    80108177 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
801080ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080c0:	01 d0                	add    %edx,%eax
801080c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801080c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c8:	0f b6 00             	movzbl (%eax),%eax
801080cb:	0f b6 c0             	movzbl %al,%eax
801080ce:	83 f8 05             	cmp    $0x5,%eax
801080d1:	0f 87 a0 00 00 00    	ja     80108177 <mpinit_uefi+0xf9>
801080d7:	8b 04 85 04 ac 10 80 	mov    -0x7fef53fc(,%eax,4),%eax
801080de:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801080e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801080e6:	a1 50 77 19 80       	mov    0x80197750,%eax
801080eb:	83 f8 03             	cmp    $0x3,%eax
801080ee:	7f 28                	jg     80108118 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801080f0:	8b 15 50 77 19 80    	mov    0x80197750,%edx
801080f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080f9:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801080fd:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108103:	81 c2 80 74 19 80    	add    $0x80197480,%edx
80108109:	88 02                	mov    %al,(%edx)
          ncpu++;
8010810b:	a1 50 77 19 80       	mov    0x80197750,%eax
80108110:	83 c0 01             	add    $0x1,%eax
80108113:	a3 50 77 19 80       	mov    %eax,0x80197750
        }
        i += lapic_entry->record_len;
80108118:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010811b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010811f:	0f b6 c0             	movzbl %al,%eax
80108122:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108125:	eb 50                	jmp    80108177 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010812d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108130:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108134:	a2 54 77 19 80       	mov    %al,0x80197754
        i += ioapic->record_len;
80108139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010813c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108140:	0f b6 c0             	movzbl %al,%eax
80108143:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108146:	eb 2f                	jmp    80108177 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010814b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010814e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108151:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108155:	0f b6 c0             	movzbl %al,%eax
80108158:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010815b:	eb 1a                	jmp    80108177 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010815d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108160:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108163:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108166:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010816a:	0f b6 c0             	movzbl %al,%eax
8010816d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108170:	eb 05                	jmp    80108177 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
80108172:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108176:	90                   	nop
  while(i<madt->len){
80108177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817a:	8b 40 04             	mov    0x4(%eax),%eax
8010817d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108180:	0f 82 34 ff ff ff    	jb     801080ba <mpinit_uefi+0x3c>
    }
  }

}
80108186:	90                   	nop
80108187:	90                   	nop
80108188:	c9                   	leave
80108189:	c3                   	ret

8010818a <inb>:
{
8010818a:	55                   	push   %ebp
8010818b:	89 e5                	mov    %esp,%ebp
8010818d:	83 ec 14             	sub    $0x14,%esp
80108190:	8b 45 08             	mov    0x8(%ebp),%eax
80108193:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108197:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010819b:	89 c2                	mov    %eax,%edx
8010819d:	ec                   	in     (%dx),%al
8010819e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801081a1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801081a5:	c9                   	leave
801081a6:	c3                   	ret

801081a7 <outb>:
{
801081a7:	55                   	push   %ebp
801081a8:	89 e5                	mov    %esp,%ebp
801081aa:	83 ec 08             	sub    $0x8,%esp
801081ad:	8b 55 08             	mov    0x8(%ebp),%edx
801081b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801081b7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801081ba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801081be:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801081c2:	ee                   	out    %al,(%dx)
}
801081c3:	90                   	nop
801081c4:	c9                   	leave
801081c5:	c3                   	ret

801081c6 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801081c6:	55                   	push   %ebp
801081c7:	89 e5                	mov    %esp,%ebp
801081c9:	83 ec 28             	sub    $0x28,%esp
801081cc:	8b 45 08             	mov    0x8(%ebp),%eax
801081cf:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801081d2:	6a 00                	push   $0x0
801081d4:	68 fa 03 00 00       	push   $0x3fa
801081d9:	e8 c9 ff ff ff       	call   801081a7 <outb>
801081de:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801081e1:	68 80 00 00 00       	push   $0x80
801081e6:	68 fb 03 00 00       	push   $0x3fb
801081eb:	e8 b7 ff ff ff       	call   801081a7 <outb>
801081f0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801081f3:	6a 0c                	push   $0xc
801081f5:	68 f8 03 00 00       	push   $0x3f8
801081fa:	e8 a8 ff ff ff       	call   801081a7 <outb>
801081ff:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108202:	6a 00                	push   $0x0
80108204:	68 f9 03 00 00       	push   $0x3f9
80108209:	e8 99 ff ff ff       	call   801081a7 <outb>
8010820e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108211:	6a 03                	push   $0x3
80108213:	68 fb 03 00 00       	push   $0x3fb
80108218:	e8 8a ff ff ff       	call   801081a7 <outb>
8010821d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108220:	6a 00                	push   $0x0
80108222:	68 fc 03 00 00       	push   $0x3fc
80108227:	e8 7b ff ff ff       	call   801081a7 <outb>
8010822c:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010822f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108236:	eb 11                	jmp    80108249 <uart_debug+0x83>
80108238:	83 ec 0c             	sub    $0xc,%esp
8010823b:	6a 0a                	push   $0xa
8010823d:	e8 f7 a8 ff ff       	call   80102b39 <microdelay>
80108242:	83 c4 10             	add    $0x10,%esp
80108245:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108249:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010824d:	7f 1a                	jg     80108269 <uart_debug+0xa3>
8010824f:	83 ec 0c             	sub    $0xc,%esp
80108252:	68 fd 03 00 00       	push   $0x3fd
80108257:	e8 2e ff ff ff       	call   8010818a <inb>
8010825c:	83 c4 10             	add    $0x10,%esp
8010825f:	0f b6 c0             	movzbl %al,%eax
80108262:	83 e0 20             	and    $0x20,%eax
80108265:	85 c0                	test   %eax,%eax
80108267:	74 cf                	je     80108238 <uart_debug+0x72>
  outb(COM1+0, p);
80108269:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010826d:	0f b6 c0             	movzbl %al,%eax
80108270:	83 ec 08             	sub    $0x8,%esp
80108273:	50                   	push   %eax
80108274:	68 f8 03 00 00       	push   $0x3f8
80108279:	e8 29 ff ff ff       	call   801081a7 <outb>
8010827e:	83 c4 10             	add    $0x10,%esp
}
80108281:	90                   	nop
80108282:	c9                   	leave
80108283:	c3                   	ret

80108284 <uart_debugs>:

void uart_debugs(char *p){
80108284:	55                   	push   %ebp
80108285:	89 e5                	mov    %esp,%ebp
80108287:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010828a:	eb 1b                	jmp    801082a7 <uart_debugs+0x23>
    uart_debug(*p++);
8010828c:	8b 45 08             	mov    0x8(%ebp),%eax
8010828f:	8d 50 01             	lea    0x1(%eax),%edx
80108292:	89 55 08             	mov    %edx,0x8(%ebp)
80108295:	0f b6 00             	movzbl (%eax),%eax
80108298:	0f be c0             	movsbl %al,%eax
8010829b:	83 ec 0c             	sub    $0xc,%esp
8010829e:	50                   	push   %eax
8010829f:	e8 22 ff ff ff       	call   801081c6 <uart_debug>
801082a4:	83 c4 10             	add    $0x10,%esp
  while(*p){
801082a7:	8b 45 08             	mov    0x8(%ebp),%eax
801082aa:	0f b6 00             	movzbl (%eax),%eax
801082ad:	84 c0                	test   %al,%al
801082af:	75 db                	jne    8010828c <uart_debugs+0x8>
  }
}
801082b1:	90                   	nop
801082b2:	90                   	nop
801082b3:	c9                   	leave
801082b4:	c3                   	ret

801082b5 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801082b5:	55                   	push   %ebp
801082b6:	89 e5                	mov    %esp,%ebp
801082b8:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082bb:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801082c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082c5:	8b 50 14             	mov    0x14(%eax),%edx
801082c8:	8b 40 10             	mov    0x10(%eax),%eax
801082cb:	a3 58 77 19 80       	mov    %eax,0x80197758
  gpu.vram_size = boot_param->graphic_config.frame_size;
801082d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082d3:	8b 50 1c             	mov    0x1c(%eax),%edx
801082d6:	8b 40 18             	mov    0x18(%eax),%eax
801082d9:	a3 60 77 19 80       	mov    %eax,0x80197760
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801082de:	a1 60 77 19 80       	mov    0x80197760,%eax
801082e3:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801082e8:	29 c2                	sub    %eax,%edx
801082ea:	89 15 5c 77 19 80    	mov    %edx,0x8019775c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801082f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082f3:	8b 50 24             	mov    0x24(%eax),%edx
801082f6:	8b 40 20             	mov    0x20(%eax),%eax
801082f9:	a3 64 77 19 80       	mov    %eax,0x80197764
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801082fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108301:	8b 50 2c             	mov    0x2c(%eax),%edx
80108304:	8b 40 28             	mov    0x28(%eax),%eax
80108307:	a3 68 77 19 80       	mov    %eax,0x80197768
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010830c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010830f:	8b 50 34             	mov    0x34(%eax),%edx
80108312:	8b 40 30             	mov    0x30(%eax),%eax
80108315:	a3 6c 77 19 80       	mov    %eax,0x8019776c
}
8010831a:	90                   	nop
8010831b:	c9                   	leave
8010831c:	c3                   	ret

8010831d <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010831d:	55                   	push   %ebp
8010831e:	89 e5                	mov    %esp,%ebp
80108320:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108323:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
80108329:	8b 45 0c             	mov    0xc(%ebp),%eax
8010832c:	0f af d0             	imul   %eax,%edx
8010832f:	8b 45 08             	mov    0x8(%ebp),%eax
80108332:	01 d0                	add    %edx,%eax
80108334:	c1 e0 02             	shl    $0x2,%eax
80108337:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010833a:	8b 15 5c 77 19 80    	mov    0x8019775c,%edx
80108340:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108343:	01 d0                	add    %edx,%eax
80108345:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108348:	8b 45 10             	mov    0x10(%ebp),%eax
8010834b:	0f b6 10             	movzbl (%eax),%edx
8010834e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108351:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108353:	8b 45 10             	mov    0x10(%ebp),%eax
80108356:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010835a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010835d:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108360:	8b 45 10             	mov    0x10(%ebp),%eax
80108363:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108367:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010836a:	88 50 02             	mov    %dl,0x2(%eax)
}
8010836d:	90                   	nop
8010836e:	c9                   	leave
8010836f:	c3                   	ret

80108370 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108370:	55                   	push   %ebp
80108371:	89 e5                	mov    %esp,%ebp
80108373:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108376:	8b 15 6c 77 19 80    	mov    0x8019776c,%edx
8010837c:	8b 45 08             	mov    0x8(%ebp),%eax
8010837f:	0f af c2             	imul   %edx,%eax
80108382:	c1 e0 02             	shl    $0x2,%eax
80108385:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108388:	8b 15 60 77 19 80    	mov    0x80197760,%edx
8010838e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108391:	29 c2                	sub    %eax,%edx
80108393:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
80108399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839c:	01 c8                	add    %ecx,%eax
8010839e:	89 c1                	mov    %eax,%ecx
801083a0:	a1 5c 77 19 80       	mov    0x8019775c,%eax
801083a5:	83 ec 04             	sub    $0x4,%esp
801083a8:	52                   	push   %edx
801083a9:	51                   	push   %ecx
801083aa:	50                   	push   %eax
801083ab:	e8 1f cb ff ff       	call   80104ecf <memmove>
801083b0:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801083b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b6:	8b 0d 5c 77 19 80    	mov    0x8019775c,%ecx
801083bc:	8b 15 60 77 19 80    	mov    0x80197760,%edx
801083c2:	01 d1                	add    %edx,%ecx
801083c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083c7:	29 d1                	sub    %edx,%ecx
801083c9:	89 ca                	mov    %ecx,%edx
801083cb:	83 ec 04             	sub    $0x4,%esp
801083ce:	50                   	push   %eax
801083cf:	6a 00                	push   $0x0
801083d1:	52                   	push   %edx
801083d2:	e8 39 ca ff ff       	call   80104e10 <memset>
801083d7:	83 c4 10             	add    $0x10,%esp
}
801083da:	90                   	nop
801083db:	c9                   	leave
801083dc:	c3                   	ret

801083dd <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801083dd:	55                   	push   %ebp
801083de:	89 e5                	mov    %esp,%ebp
801083e0:	53                   	push   %ebx
801083e1:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801083e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083eb:	e9 b1 00 00 00       	jmp    801084a1 <font_render+0xc4>
    for(int j=14;j>-1;j--){
801083f0:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801083f7:	e9 97 00 00 00       	jmp    80108493 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
801083fc:	8b 45 10             	mov    0x10(%ebp),%eax
801083ff:	83 e8 20             	sub    $0x20,%eax
80108402:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108408:	01 d0                	add    %edx,%eax
8010840a:	0f b7 84 00 20 ac 10 	movzwl -0x7fef53e0(%eax,%eax,1),%eax
80108411:	80 
80108412:	0f b7 d0             	movzwl %ax,%edx
80108415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108418:	bb 01 00 00 00       	mov    $0x1,%ebx
8010841d:	89 c1                	mov    %eax,%ecx
8010841f:	d3 e3                	shl    %cl,%ebx
80108421:	89 d8                	mov    %ebx,%eax
80108423:	21 d0                	and    %edx,%eax
80108425:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842b:	ba 01 00 00 00       	mov    $0x1,%edx
80108430:	89 c1                	mov    %eax,%ecx
80108432:	d3 e2                	shl    %cl,%edx
80108434:	89 d0                	mov    %edx,%eax
80108436:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108439:	75 2b                	jne    80108466 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
8010843b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010843e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108441:	01 c2                	add    %eax,%edx
80108443:	b8 0e 00 00 00       	mov    $0xe,%eax
80108448:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010844b:	89 c1                	mov    %eax,%ecx
8010844d:	8b 45 08             	mov    0x8(%ebp),%eax
80108450:	01 c8                	add    %ecx,%eax
80108452:	83 ec 04             	sub    $0x4,%esp
80108455:	68 00 f5 10 80       	push   $0x8010f500
8010845a:	52                   	push   %edx
8010845b:	50                   	push   %eax
8010845c:	e8 bc fe ff ff       	call   8010831d <graphic_draw_pixel>
80108461:	83 c4 10             	add    $0x10,%esp
80108464:	eb 29                	jmp    8010848f <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108466:	8b 55 0c             	mov    0xc(%ebp),%edx
80108469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846c:	01 c2                	add    %eax,%edx
8010846e:	b8 0e 00 00 00       	mov    $0xe,%eax
80108473:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108476:	89 c1                	mov    %eax,%ecx
80108478:	8b 45 08             	mov    0x8(%ebp),%eax
8010847b:	01 c8                	add    %ecx,%eax
8010847d:	83 ec 04             	sub    $0x4,%esp
80108480:	68 70 77 19 80       	push   $0x80197770
80108485:	52                   	push   %edx
80108486:	50                   	push   %eax
80108487:	e8 91 fe ff ff       	call   8010831d <graphic_draw_pixel>
8010848c:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010848f:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108493:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108497:	0f 89 5f ff ff ff    	jns    801083fc <font_render+0x1f>
  for(int i=0;i<30;i++){
8010849d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084a1:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801084a5:	0f 8e 45 ff ff ff    	jle    801083f0 <font_render+0x13>
      }
    }
  }
}
801084ab:	90                   	nop
801084ac:	90                   	nop
801084ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084b0:	c9                   	leave
801084b1:	c3                   	ret

801084b2 <font_render_string>:

void font_render_string(char *string,int row){
801084b2:	55                   	push   %ebp
801084b3:	89 e5                	mov    %esp,%ebp
801084b5:	53                   	push   %ebx
801084b6:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801084b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801084c0:	eb 33                	jmp    801084f5 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801084c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084c5:	8b 45 08             	mov    0x8(%ebp),%eax
801084c8:	01 d0                	add    %edx,%eax
801084ca:	0f b6 00             	movzbl (%eax),%eax
801084cd:	0f be d8             	movsbl %al,%ebx
801084d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d3:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801084d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084d9:	89 d0                	mov    %edx,%eax
801084db:	c1 e0 04             	shl    $0x4,%eax
801084de:	29 d0                	sub    %edx,%eax
801084e0:	83 c0 02             	add    $0x2,%eax
801084e3:	83 ec 04             	sub    $0x4,%esp
801084e6:	53                   	push   %ebx
801084e7:	51                   	push   %ecx
801084e8:	50                   	push   %eax
801084e9:	e8 ef fe ff ff       	call   801083dd <font_render>
801084ee:	83 c4 10             	add    $0x10,%esp
    i++;
801084f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801084f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084f8:	8b 45 08             	mov    0x8(%ebp),%eax
801084fb:	01 d0                	add    %edx,%eax
801084fd:	0f b6 00             	movzbl (%eax),%eax
80108500:	84 c0                	test   %al,%al
80108502:	74 06                	je     8010850a <font_render_string+0x58>
80108504:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108508:	7e b8                	jle    801084c2 <font_render_string+0x10>
  }
}
8010850a:	90                   	nop
8010850b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010850e:	c9                   	leave
8010850f:	c3                   	ret

80108510 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108510:	55                   	push   %ebp
80108511:	89 e5                	mov    %esp,%ebp
80108513:	53                   	push   %ebx
80108514:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010851e:	eb 6b                	jmp    8010858b <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108520:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108527:	eb 58                	jmp    80108581 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108529:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108530:	eb 45                	jmp    80108577 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108532:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108535:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853b:	83 ec 0c             	sub    $0xc,%esp
8010853e:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108541:	53                   	push   %ebx
80108542:	6a 00                	push   $0x0
80108544:	51                   	push   %ecx
80108545:	52                   	push   %edx
80108546:	50                   	push   %eax
80108547:	e8 b0 00 00 00       	call   801085fc <pci_access_config>
8010854c:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010854f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108552:	0f b7 c0             	movzwl %ax,%eax
80108555:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010855a:	74 17                	je     80108573 <pci_init+0x63>
        pci_init_device(i,j,k);
8010855c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010855f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108565:	83 ec 04             	sub    $0x4,%esp
80108568:	51                   	push   %ecx
80108569:	52                   	push   %edx
8010856a:	50                   	push   %eax
8010856b:	e8 37 01 00 00       	call   801086a7 <pci_init_device>
80108570:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108573:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108577:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010857b:	7e b5                	jle    80108532 <pci_init+0x22>
    for(int j=0;j<32;j++){
8010857d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108581:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108585:	7e a2                	jle    80108529 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108587:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010858b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108592:	7e 8c                	jle    80108520 <pci_init+0x10>
      }
      }
    }
  }
}
80108594:	90                   	nop
80108595:	90                   	nop
80108596:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108599:	c9                   	leave
8010859a:	c3                   	ret

8010859b <pci_write_config>:

void pci_write_config(uint config){
8010859b:	55                   	push   %ebp
8010859c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010859e:	8b 45 08             	mov    0x8(%ebp),%eax
801085a1:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801085a6:	89 c0                	mov    %eax,%eax
801085a8:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085a9:	90                   	nop
801085aa:	5d                   	pop    %ebp
801085ab:	c3                   	ret

801085ac <pci_write_data>:

void pci_write_data(uint config){
801085ac:	55                   	push   %ebp
801085ad:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801085af:	8b 45 08             	mov    0x8(%ebp),%eax
801085b2:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085b7:	89 c0                	mov    %eax,%eax
801085b9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085ba:	90                   	nop
801085bb:	5d                   	pop    %ebp
801085bc:	c3                   	ret

801085bd <pci_read_config>:
uint pci_read_config(){
801085bd:	55                   	push   %ebp
801085be:	89 e5                	mov    %esp,%ebp
801085c0:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801085c3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085c8:	ed                   	in     (%dx),%eax
801085c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801085cc:	83 ec 0c             	sub    $0xc,%esp
801085cf:	68 c8 00 00 00       	push   $0xc8
801085d4:	e8 60 a5 ff ff       	call   80102b39 <microdelay>
801085d9:	83 c4 10             	add    $0x10,%esp
  return data;
801085dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801085df:	c9                   	leave
801085e0:	c3                   	ret

801085e1 <pci_test>:


void pci_test(){
801085e1:	55                   	push   %ebp
801085e2:	89 e5                	mov    %esp,%ebp
801085e4:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801085e7:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801085ee:	ff 75 fc             	push   -0x4(%ebp)
801085f1:	e8 a5 ff ff ff       	call   8010859b <pci_write_config>
801085f6:	83 c4 04             	add    $0x4,%esp
}
801085f9:	90                   	nop
801085fa:	c9                   	leave
801085fb:	c3                   	ret

801085fc <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801085fc:	55                   	push   %ebp
801085fd:	89 e5                	mov    %esp,%ebp
801085ff:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108602:	8b 45 08             	mov    0x8(%ebp),%eax
80108605:	c1 e0 10             	shl    $0x10,%eax
80108608:	25 00 00 ff 00       	and    $0xff0000,%eax
8010860d:	89 c2                	mov    %eax,%edx
8010860f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108612:	c1 e0 0b             	shl    $0xb,%eax
80108615:	0f b7 c0             	movzwl %ax,%eax
80108618:	09 c2                	or     %eax,%edx
8010861a:	8b 45 10             	mov    0x10(%ebp),%eax
8010861d:	c1 e0 08             	shl    $0x8,%eax
80108620:	25 00 07 00 00       	and    $0x700,%eax
80108625:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108627:	8b 45 14             	mov    0x14(%ebp),%eax
8010862a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010862f:	09 d0                	or     %edx,%eax
80108631:	0d 00 00 00 80       	or     $0x80000000,%eax
80108636:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108639:	ff 75 f4             	push   -0xc(%ebp)
8010863c:	e8 5a ff ff ff       	call   8010859b <pci_write_config>
80108641:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108644:	e8 74 ff ff ff       	call   801085bd <pci_read_config>
80108649:	8b 55 18             	mov    0x18(%ebp),%edx
8010864c:	89 02                	mov    %eax,(%edx)
}
8010864e:	90                   	nop
8010864f:	c9                   	leave
80108650:	c3                   	ret

80108651 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108651:	55                   	push   %ebp
80108652:	89 e5                	mov    %esp,%ebp
80108654:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108657:	8b 45 08             	mov    0x8(%ebp),%eax
8010865a:	c1 e0 10             	shl    $0x10,%eax
8010865d:	25 00 00 ff 00       	and    $0xff0000,%eax
80108662:	89 c2                	mov    %eax,%edx
80108664:	8b 45 0c             	mov    0xc(%ebp),%eax
80108667:	c1 e0 0b             	shl    $0xb,%eax
8010866a:	0f b7 c0             	movzwl %ax,%eax
8010866d:	09 c2                	or     %eax,%edx
8010866f:	8b 45 10             	mov    0x10(%ebp),%eax
80108672:	c1 e0 08             	shl    $0x8,%eax
80108675:	25 00 07 00 00       	and    $0x700,%eax
8010867a:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010867c:	8b 45 14             	mov    0x14(%ebp),%eax
8010867f:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108684:	09 d0                	or     %edx,%eax
80108686:	0d 00 00 00 80       	or     $0x80000000,%eax
8010868b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010868e:	ff 75 fc             	push   -0x4(%ebp)
80108691:	e8 05 ff ff ff       	call   8010859b <pci_write_config>
80108696:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108699:	ff 75 18             	push   0x18(%ebp)
8010869c:	e8 0b ff ff ff       	call   801085ac <pci_write_data>
801086a1:	83 c4 04             	add    $0x4,%esp
}
801086a4:	90                   	nop
801086a5:	c9                   	leave
801086a6:	c3                   	ret

801086a7 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801086a7:	55                   	push   %ebp
801086a8:	89 e5                	mov    %esp,%ebp
801086aa:	53                   	push   %ebx
801086ab:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801086ae:	8b 45 08             	mov    0x8(%ebp),%eax
801086b1:	a2 74 77 19 80       	mov    %al,0x80197774
  dev.device_num = device_num;
801086b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801086b9:	a2 75 77 19 80       	mov    %al,0x80197775
  dev.function_num = function_num;
801086be:	8b 45 10             	mov    0x10(%ebp),%eax
801086c1:	a2 76 77 19 80       	mov    %al,0x80197776
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801086c6:	ff 75 10             	push   0x10(%ebp)
801086c9:	ff 75 0c             	push   0xc(%ebp)
801086cc:	ff 75 08             	push   0x8(%ebp)
801086cf:	68 64 c2 10 80       	push   $0x8010c264
801086d4:	e8 1b 7d ff ff       	call   801003f4 <cprintf>
801086d9:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801086dc:	83 ec 0c             	sub    $0xc,%esp
801086df:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086e2:	50                   	push   %eax
801086e3:	6a 00                	push   $0x0
801086e5:	ff 75 10             	push   0x10(%ebp)
801086e8:	ff 75 0c             	push   0xc(%ebp)
801086eb:	ff 75 08             	push   0x8(%ebp)
801086ee:	e8 09 ff ff ff       	call   801085fc <pci_access_config>
801086f3:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801086f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f9:	c1 e8 10             	shr    $0x10,%eax
801086fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801086ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108702:	25 ff ff 00 00       	and    $0xffff,%eax
80108707:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010870a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870d:	a3 78 77 19 80       	mov    %eax,0x80197778
  dev.vendor_id = vendor_id;
80108712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108715:	a3 7c 77 19 80       	mov    %eax,0x8019777c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010871a:	83 ec 04             	sub    $0x4,%esp
8010871d:	ff 75 f0             	push   -0x10(%ebp)
80108720:	ff 75 f4             	push   -0xc(%ebp)
80108723:	68 98 c2 10 80       	push   $0x8010c298
80108728:	e8 c7 7c ff ff       	call   801003f4 <cprintf>
8010872d:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108730:	83 ec 0c             	sub    $0xc,%esp
80108733:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108736:	50                   	push   %eax
80108737:	6a 08                	push   $0x8
80108739:	ff 75 10             	push   0x10(%ebp)
8010873c:	ff 75 0c             	push   0xc(%ebp)
8010873f:	ff 75 08             	push   0x8(%ebp)
80108742:	e8 b5 fe ff ff       	call   801085fc <pci_access_config>
80108747:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010874a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874d:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108750:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108753:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108756:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108759:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875c:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010875f:	0f b6 c0             	movzbl %al,%eax
80108762:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108765:	c1 eb 18             	shr    $0x18,%ebx
80108768:	83 ec 0c             	sub    $0xc,%esp
8010876b:	51                   	push   %ecx
8010876c:	52                   	push   %edx
8010876d:	50                   	push   %eax
8010876e:	53                   	push   %ebx
8010876f:	68 bc c2 10 80       	push   $0x8010c2bc
80108774:	e8 7b 7c ff ff       	call   801003f4 <cprintf>
80108779:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010877c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877f:	c1 e8 18             	shr    $0x18,%eax
80108782:	a2 80 77 19 80       	mov    %al,0x80197780
  dev.sub_class = (data>>16)&0xFF;
80108787:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010878a:	c1 e8 10             	shr    $0x10,%eax
8010878d:	a2 81 77 19 80       	mov    %al,0x80197781
  dev.interface = (data>>8)&0xFF;
80108792:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108795:	c1 e8 08             	shr    $0x8,%eax
80108798:	a2 82 77 19 80       	mov    %al,0x80197782
  dev.revision_id = data&0xFF;
8010879d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a0:	a2 83 77 19 80       	mov    %al,0x80197783
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801087a5:	83 ec 0c             	sub    $0xc,%esp
801087a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087ab:	50                   	push   %eax
801087ac:	6a 10                	push   $0x10
801087ae:	ff 75 10             	push   0x10(%ebp)
801087b1:	ff 75 0c             	push   0xc(%ebp)
801087b4:	ff 75 08             	push   0x8(%ebp)
801087b7:	e8 40 fe ff ff       	call   801085fc <pci_access_config>
801087bc:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801087bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c2:	a3 84 77 19 80       	mov    %eax,0x80197784
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801087c7:	83 ec 0c             	sub    $0xc,%esp
801087ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087cd:	50                   	push   %eax
801087ce:	6a 14                	push   $0x14
801087d0:	ff 75 10             	push   0x10(%ebp)
801087d3:	ff 75 0c             	push   0xc(%ebp)
801087d6:	ff 75 08             	push   0x8(%ebp)
801087d9:	e8 1e fe ff ff       	call   801085fc <pci_access_config>
801087de:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801087e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e4:	a3 88 77 19 80       	mov    %eax,0x80197788
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801087e9:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801087f0:	75 5a                	jne    8010884c <pci_init_device+0x1a5>
801087f2:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801087f9:	75 51                	jne    8010884c <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801087fb:	83 ec 0c             	sub    $0xc,%esp
801087fe:	68 01 c3 10 80       	push   $0x8010c301
80108803:	e8 ec 7b ff ff       	call   801003f4 <cprintf>
80108808:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010880b:	83 ec 0c             	sub    $0xc,%esp
8010880e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108811:	50                   	push   %eax
80108812:	68 f0 00 00 00       	push   $0xf0
80108817:	ff 75 10             	push   0x10(%ebp)
8010881a:	ff 75 0c             	push   0xc(%ebp)
8010881d:	ff 75 08             	push   0x8(%ebp)
80108820:	e8 d7 fd ff ff       	call   801085fc <pci_access_config>
80108825:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108828:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010882b:	83 ec 08             	sub    $0x8,%esp
8010882e:	50                   	push   %eax
8010882f:	68 1b c3 10 80       	push   $0x8010c31b
80108834:	e8 bb 7b ff ff       	call   801003f4 <cprintf>
80108839:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010883c:	83 ec 0c             	sub    $0xc,%esp
8010883f:	68 74 77 19 80       	push   $0x80197774
80108844:	e8 09 00 00 00       	call   80108852 <i8254_init>
80108849:	83 c4 10             	add    $0x10,%esp
  }
}
8010884c:	90                   	nop
8010884d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108850:	c9                   	leave
80108851:	c3                   	ret

80108852 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108852:	55                   	push   %ebp
80108853:	89 e5                	mov    %esp,%ebp
80108855:	53                   	push   %ebx
80108856:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108859:	8b 45 08             	mov    0x8(%ebp),%eax
8010885c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108860:	0f b6 c8             	movzbl %al,%ecx
80108863:	8b 45 08             	mov    0x8(%ebp),%eax
80108866:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010886a:	0f b6 d0             	movzbl %al,%edx
8010886d:	8b 45 08             	mov    0x8(%ebp),%eax
80108870:	0f b6 00             	movzbl (%eax),%eax
80108873:	0f b6 c0             	movzbl %al,%eax
80108876:	83 ec 0c             	sub    $0xc,%esp
80108879:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010887c:	53                   	push   %ebx
8010887d:	6a 04                	push   $0x4
8010887f:	51                   	push   %ecx
80108880:	52                   	push   %edx
80108881:	50                   	push   %eax
80108882:	e8 75 fd ff ff       	call   801085fc <pci_access_config>
80108887:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010888a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010888d:	83 c8 04             	or     $0x4,%eax
80108890:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108893:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108896:	8b 45 08             	mov    0x8(%ebp),%eax
80108899:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010889d:	0f b6 c8             	movzbl %al,%ecx
801088a0:	8b 45 08             	mov    0x8(%ebp),%eax
801088a3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088a7:	0f b6 d0             	movzbl %al,%edx
801088aa:	8b 45 08             	mov    0x8(%ebp),%eax
801088ad:	0f b6 00             	movzbl (%eax),%eax
801088b0:	0f b6 c0             	movzbl %al,%eax
801088b3:	83 ec 0c             	sub    $0xc,%esp
801088b6:	53                   	push   %ebx
801088b7:	6a 04                	push   $0x4
801088b9:	51                   	push   %ecx
801088ba:	52                   	push   %edx
801088bb:	50                   	push   %eax
801088bc:	e8 90 fd ff ff       	call   80108651 <pci_write_config_register>
801088c1:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801088c4:	8b 45 08             	mov    0x8(%ebp),%eax
801088c7:	8b 40 10             	mov    0x10(%eax),%eax
801088ca:	05 00 00 00 40       	add    $0x40000000,%eax
801088cf:	a3 8c 77 19 80       	mov    %eax,0x8019778c
  uint *ctrl = (uint *)base_addr;
801088d4:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801088d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801088dc:	a1 8c 77 19 80       	mov    0x8019778c,%eax
801088e1:	05 d8 00 00 00       	add    $0xd8,%eax
801088e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801088e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ec:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801088f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f5:	8b 00                	mov    (%eax),%eax
801088f7:	0d 00 00 00 04       	or     $0x4000000,%eax
801088fc:	89 c2                	mov    %eax,%edx
801088fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108901:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108906:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010890c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890f:	8b 00                	mov    (%eax),%eax
80108911:	83 c8 40             	or     $0x40,%eax
80108914:	89 c2                	mov    %eax,%edx
80108916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108919:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010891b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891e:	8b 10                	mov    (%eax),%edx
80108920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108923:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108925:	83 ec 0c             	sub    $0xc,%esp
80108928:	68 30 c3 10 80       	push   $0x8010c330
8010892d:	e8 c2 7a ff ff       	call   801003f4 <cprintf>
80108932:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108935:	e8 6e 9e ff ff       	call   801027a8 <kalloc>
8010893a:	a3 98 77 19 80       	mov    %eax,0x80197798
  *intr_addr = 0;
8010893f:	a1 98 77 19 80       	mov    0x80197798,%eax
80108944:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010894a:	a1 98 77 19 80       	mov    0x80197798,%eax
8010894f:	83 ec 08             	sub    $0x8,%esp
80108952:	50                   	push   %eax
80108953:	68 52 c3 10 80       	push   $0x8010c352
80108958:	e8 97 7a ff ff       	call   801003f4 <cprintf>
8010895d:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108960:	e8 50 00 00 00       	call   801089b5 <i8254_init_recv>
  i8254_init_send();
80108965:	e8 69 03 00 00       	call   80108cd3 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010896a:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108971:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108974:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010897b:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010897e:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108985:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108988:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010898f:	0f b6 c0             	movzbl %al,%eax
80108992:	83 ec 0c             	sub    $0xc,%esp
80108995:	53                   	push   %ebx
80108996:	51                   	push   %ecx
80108997:	52                   	push   %edx
80108998:	50                   	push   %eax
80108999:	68 60 c3 10 80       	push   $0x8010c360
8010899e:	e8 51 7a ff ff       	call   801003f4 <cprintf>
801089a3:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801089a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801089af:	90                   	nop
801089b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089b3:	c9                   	leave
801089b4:	c3                   	ret

801089b5 <i8254_init_recv>:

void i8254_init_recv(){
801089b5:	55                   	push   %ebp
801089b6:	89 e5                	mov    %esp,%ebp
801089b8:	57                   	push   %edi
801089b9:	56                   	push   %esi
801089ba:	53                   	push   %ebx
801089bb:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801089be:	83 ec 0c             	sub    $0xc,%esp
801089c1:	6a 00                	push   $0x0
801089c3:	e8 e8 04 00 00       	call   80108eb0 <i8254_read_eeprom>
801089c8:	83 c4 10             	add    $0x10,%esp
801089cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801089ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089d1:	a2 90 77 19 80       	mov    %al,0x80197790
  mac_addr[1] = data_l>>8;
801089d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089d9:	c1 e8 08             	shr    $0x8,%eax
801089dc:	a2 91 77 19 80       	mov    %al,0x80197791
  uint data_m = i8254_read_eeprom(0x1);
801089e1:	83 ec 0c             	sub    $0xc,%esp
801089e4:	6a 01                	push   $0x1
801089e6:	e8 c5 04 00 00       	call   80108eb0 <i8254_read_eeprom>
801089eb:	83 c4 10             	add    $0x10,%esp
801089ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801089f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089f4:	a2 92 77 19 80       	mov    %al,0x80197792
  mac_addr[3] = data_m>>8;
801089f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801089fc:	c1 e8 08             	shr    $0x8,%eax
801089ff:	a2 93 77 19 80       	mov    %al,0x80197793
  uint data_h = i8254_read_eeprom(0x2);
80108a04:	83 ec 0c             	sub    $0xc,%esp
80108a07:	6a 02                	push   $0x2
80108a09:	e8 a2 04 00 00       	call   80108eb0 <i8254_read_eeprom>
80108a0e:	83 c4 10             	add    $0x10,%esp
80108a11:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108a14:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a17:	a2 94 77 19 80       	mov    %al,0x80197794
  mac_addr[5] = data_h>>8;
80108a1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a1f:	c1 e8 08             	shr    $0x8,%eax
80108a22:	a2 95 77 19 80       	mov    %al,0x80197795
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a27:	0f b6 05 95 77 19 80 	movzbl 0x80197795,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a2e:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108a31:	0f b6 05 94 77 19 80 	movzbl 0x80197794,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a38:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108a3b:	0f b6 05 93 77 19 80 	movzbl 0x80197793,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a42:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108a45:	0f b6 05 92 77 19 80 	movzbl 0x80197792,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a4c:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108a4f:	0f b6 05 91 77 19 80 	movzbl 0x80197791,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a56:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108a59:	0f b6 05 90 77 19 80 	movzbl 0x80197790,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a60:	0f b6 c0             	movzbl %al,%eax
80108a63:	83 ec 04             	sub    $0x4,%esp
80108a66:	57                   	push   %edi
80108a67:	56                   	push   %esi
80108a68:	53                   	push   %ebx
80108a69:	51                   	push   %ecx
80108a6a:	52                   	push   %edx
80108a6b:	50                   	push   %eax
80108a6c:	68 78 c3 10 80       	push   $0x8010c378
80108a71:	e8 7e 79 ff ff       	call   801003f4 <cprintf>
80108a76:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108a79:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108a7e:	05 00 54 00 00       	add    $0x5400,%eax
80108a83:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108a86:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108a8b:	05 04 54 00 00       	add    $0x5404,%eax
80108a90:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108a93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a96:	c1 e0 10             	shl    $0x10,%eax
80108a99:	0b 45 d8             	or     -0x28(%ebp),%eax
80108a9c:	89 c2                	mov    %eax,%edx
80108a9e:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108aa1:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108aa3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108aa6:	0d 00 00 00 80       	or     $0x80000000,%eax
80108aab:	89 c2                	mov    %eax,%edx
80108aad:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ab0:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108ab2:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ab7:	05 00 52 00 00       	add    $0x5200,%eax
80108abc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108abf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108ac6:	eb 19                	jmp    80108ae1 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108ac8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108acb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ad2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ad5:	01 d0                	add    %edx,%eax
80108ad7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108add:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ae1:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108ae5:	7e e1                	jle    80108ac8 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108ae7:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108aec:	05 d0 00 00 00       	add    $0xd0,%eax
80108af1:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108af4:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108af7:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108afd:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b02:	05 c8 00 00 00       	add    $0xc8,%eax
80108b07:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b0a:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108b0d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108b13:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b18:	05 28 28 00 00       	add    $0x2828,%eax
80108b1d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108b20:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b29:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b2e:	05 00 01 00 00       	add    $0x100,%eax
80108b33:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108b36:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b39:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108b3f:	e8 64 9c ff ff       	call   801027a8 <kalloc>
80108b44:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b47:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b4c:	05 00 28 00 00       	add    $0x2800,%eax
80108b51:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108b54:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b59:	05 04 28 00 00       	add    $0x2804,%eax
80108b5e:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108b61:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b66:	05 08 28 00 00       	add    $0x2808,%eax
80108b6b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b6e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b73:	05 10 28 00 00       	add    $0x2810,%eax
80108b78:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b7b:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108b80:	05 18 28 00 00       	add    $0x2818,%eax
80108b85:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108b88:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108b8b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b91:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108b94:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108b96:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108b99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108b9f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108ba2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108ba8:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108bab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108bb1:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108bb4:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108bba:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108bbd:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108bc0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108bc7:	eb 73                	jmp    80108c3c <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108bc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bcc:	c1 e0 04             	shl    $0x4,%eax
80108bcf:	89 c2                	mov    %eax,%edx
80108bd1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bd4:	01 d0                	add    %edx,%eax
80108bd6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108bdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108be0:	c1 e0 04             	shl    $0x4,%eax
80108be3:	89 c2                	mov    %eax,%edx
80108be5:	8b 45 98             	mov    -0x68(%ebp),%eax
80108be8:	01 d0                	add    %edx,%eax
80108bea:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108bf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bf3:	c1 e0 04             	shl    $0x4,%eax
80108bf6:	89 c2                	mov    %eax,%edx
80108bf8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bfb:	01 d0                	add    %edx,%eax
80108bfd:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108c03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c06:	c1 e0 04             	shl    $0x4,%eax
80108c09:	89 c2                	mov    %eax,%edx
80108c0b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c0e:	01 d0                	add    %edx,%eax
80108c10:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108c14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c17:	c1 e0 04             	shl    $0x4,%eax
80108c1a:	89 c2                	mov    %eax,%edx
80108c1c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c1f:	01 d0                	add    %edx,%eax
80108c21:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c28:	c1 e0 04             	shl    $0x4,%eax
80108c2b:	89 c2                	mov    %eax,%edx
80108c2d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c30:	01 d0                	add    %edx,%eax
80108c32:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c38:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108c3c:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108c43:	7e 84                	jle    80108bc9 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c45:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108c4c:	eb 57                	jmp    80108ca5 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108c4e:	e8 55 9b ff ff       	call   801027a8 <kalloc>
80108c53:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108c56:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108c5a:	75 12                	jne    80108c6e <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108c5c:	83 ec 0c             	sub    $0xc,%esp
80108c5f:	68 98 c3 10 80       	push   $0x8010c398
80108c64:	e8 8b 77 ff ff       	call   801003f4 <cprintf>
80108c69:	83 c4 10             	add    $0x10,%esp
      break;
80108c6c:	eb 3d                	jmp    80108cab <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108c6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c71:	c1 e0 04             	shl    $0x4,%eax
80108c74:	89 c2                	mov    %eax,%edx
80108c76:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c79:	01 d0                	add    %edx,%eax
80108c7b:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c7e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c84:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108c86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c89:	83 c0 01             	add    $0x1,%eax
80108c8c:	c1 e0 04             	shl    $0x4,%eax
80108c8f:	89 c2                	mov    %eax,%edx
80108c91:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c94:	01 d0                	add    %edx,%eax
80108c96:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108c99:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c9f:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ca1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108ca5:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108ca9:	7e a3                	jle    80108c4e <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108cab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cae:	8b 00                	mov    (%eax),%eax
80108cb0:	83 c8 02             	or     $0x2,%eax
80108cb3:	89 c2                	mov    %eax,%edx
80108cb5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cb8:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108cba:	83 ec 0c             	sub    $0xc,%esp
80108cbd:	68 b8 c3 10 80       	push   $0x8010c3b8
80108cc2:	e8 2d 77 ff ff       	call   801003f4 <cprintf>
80108cc7:	83 c4 10             	add    $0x10,%esp
}
80108cca:	90                   	nop
80108ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108cce:	5b                   	pop    %ebx
80108ccf:	5e                   	pop    %esi
80108cd0:	5f                   	pop    %edi
80108cd1:	5d                   	pop    %ebp
80108cd2:	c3                   	ret

80108cd3 <i8254_init_send>:

void i8254_init_send(){
80108cd3:	55                   	push   %ebp
80108cd4:	89 e5                	mov    %esp,%ebp
80108cd6:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108cd9:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108cde:	05 28 38 00 00       	add    $0x3828,%eax
80108ce3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108ce6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ce9:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108cef:	e8 b4 9a ff ff       	call   801027a8 <kalloc>
80108cf4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108cf7:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108cfc:	05 00 38 00 00       	add    $0x3800,%eax
80108d01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108d04:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d09:	05 04 38 00 00       	add    $0x3804,%eax
80108d0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108d11:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d16:	05 08 38 00 00       	add    $0x3808,%eax
80108d1b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108d1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d21:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d2a:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108d2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108d35:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d38:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d3e:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d43:	05 10 38 00 00       	add    $0x3810,%eax
80108d48:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d4b:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108d50:	05 18 38 00 00       	add    $0x3818,%eax
80108d55:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108d58:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108d61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108d6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d77:	e9 82 00 00 00       	jmp    80108dfe <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7f:	c1 e0 04             	shl    $0x4,%eax
80108d82:	89 c2                	mov    %eax,%edx
80108d84:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d87:	01 d0                	add    %edx,%eax
80108d89:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d93:	c1 e0 04             	shl    $0x4,%eax
80108d96:	89 c2                	mov    %eax,%edx
80108d98:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d9b:	01 d0                	add    %edx,%eax
80108d9d:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da6:	c1 e0 04             	shl    $0x4,%eax
80108da9:	89 c2                	mov    %eax,%edx
80108dab:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dae:	01 d0                	add    %edx,%eax
80108db0:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db7:	c1 e0 04             	shl    $0x4,%eax
80108dba:	89 c2                	mov    %eax,%edx
80108dbc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dbf:	01 d0                	add    %edx,%eax
80108dc1:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc8:	c1 e0 04             	shl    $0x4,%eax
80108dcb:	89 c2                	mov    %eax,%edx
80108dcd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dd0:	01 d0                	add    %edx,%eax
80108dd2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd9:	c1 e0 04             	shl    $0x4,%eax
80108ddc:	89 c2                	mov    %eax,%edx
80108dde:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108de1:	01 d0                	add    %edx,%eax
80108de3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dea:	c1 e0 04             	shl    $0x4,%eax
80108ded:	89 c2                	mov    %eax,%edx
80108def:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108df2:	01 d0                	add    %edx,%eax
80108df4:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108dfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dfe:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e05:	0f 8e 71 ff ff ff    	jle    80108d7c <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e0b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e12:	eb 57                	jmp    80108e6b <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108e14:	e8 8f 99 ff ff       	call   801027a8 <kalloc>
80108e19:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108e1c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108e20:	75 12                	jne    80108e34 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108e22:	83 ec 0c             	sub    $0xc,%esp
80108e25:	68 98 c3 10 80       	push   $0x8010c398
80108e2a:	e8 c5 75 ff ff       	call   801003f4 <cprintf>
80108e2f:	83 c4 10             	add    $0x10,%esp
      break;
80108e32:	eb 3d                	jmp    80108e71 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e37:	c1 e0 04             	shl    $0x4,%eax
80108e3a:	89 c2                	mov    %eax,%edx
80108e3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e3f:	01 d0                	add    %edx,%eax
80108e41:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e44:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e4a:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e4f:	83 c0 01             	add    $0x1,%eax
80108e52:	c1 e0 04             	shl    $0x4,%eax
80108e55:	89 c2                	mov    %eax,%edx
80108e57:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e5a:	01 d0                	add    %edx,%eax
80108e5c:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e5f:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e65:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e67:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e6b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108e6f:	7e a3                	jle    80108e14 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108e71:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e76:	05 00 04 00 00       	add    $0x400,%eax
80108e7b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108e7e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e81:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108e87:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108e8c:	05 10 04 00 00       	add    $0x410,%eax
80108e91:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108e94:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e97:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108e9d:	83 ec 0c             	sub    $0xc,%esp
80108ea0:	68 d8 c3 10 80       	push   $0x8010c3d8
80108ea5:	e8 4a 75 ff ff       	call   801003f4 <cprintf>
80108eaa:	83 c4 10             	add    $0x10,%esp

}
80108ead:	90                   	nop
80108eae:	c9                   	leave
80108eaf:	c3                   	ret

80108eb0 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108eb0:	55                   	push   %ebp
80108eb1:	89 e5                	mov    %esp,%ebp
80108eb3:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108eb6:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108ebb:	83 c0 14             	add    $0x14,%eax
80108ebe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec4:	c1 e0 08             	shl    $0x8,%eax
80108ec7:	0f b7 c0             	movzwl %ax,%eax
80108eca:	83 c8 01             	or     $0x1,%eax
80108ecd:	89 c2                	mov    %eax,%edx
80108ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed2:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108ed4:	83 ec 0c             	sub    $0xc,%esp
80108ed7:	68 f8 c3 10 80       	push   $0x8010c3f8
80108edc:	e8 13 75 ff ff       	call   801003f4 <cprintf>
80108ee1:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee7:	8b 00                	mov    (%eax),%eax
80108ee9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eef:	83 e0 10             	and    $0x10,%eax
80108ef2:	85 c0                	test   %eax,%eax
80108ef4:	75 02                	jne    80108ef8 <i8254_read_eeprom+0x48>
  while(1){
80108ef6:	eb dc                	jmp    80108ed4 <i8254_read_eeprom+0x24>
      break;
80108ef8:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108efc:	8b 00                	mov    (%eax),%eax
80108efe:	c1 e8 10             	shr    $0x10,%eax
}
80108f01:	c9                   	leave
80108f02:	c3                   	ret

80108f03 <i8254_recv>:
void i8254_recv(){
80108f03:	55                   	push   %ebp
80108f04:	89 e5                	mov    %esp,%ebp
80108f06:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f09:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f0e:	05 10 28 00 00       	add    $0x2810,%eax
80108f13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f16:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f1b:	05 18 28 00 00       	add    $0x2818,%eax
80108f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f23:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108f28:	05 00 28 00 00       	add    $0x2800,%eax
80108f2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108f30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f33:	8b 00                	mov    (%eax),%eax
80108f35:	05 00 00 00 80       	add    $0x80000000,%eax
80108f3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f40:	8b 10                	mov    (%eax),%edx
80108f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f45:	8b 00                	mov    (%eax),%eax
80108f47:	29 c2                	sub    %eax,%edx
80108f49:	89 d0                	mov    %edx,%eax
80108f4b:	25 ff 00 00 00       	and    $0xff,%eax
80108f50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108f53:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f57:	7e 37                	jle    80108f90 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5c:	8b 00                	mov    (%eax),%eax
80108f5e:	c1 e0 04             	shl    $0x4,%eax
80108f61:	89 c2                	mov    %eax,%edx
80108f63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f66:	01 d0                	add    %edx,%eax
80108f68:	8b 00                	mov    (%eax),%eax
80108f6a:	05 00 00 00 80       	add    $0x80000000,%eax
80108f6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f75:	8b 00                	mov    (%eax),%eax
80108f77:	83 c0 01             	add    $0x1,%eax
80108f7a:	0f b6 d0             	movzbl %al,%edx
80108f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f80:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108f82:	83 ec 0c             	sub    $0xc,%esp
80108f85:	ff 75 e0             	push   -0x20(%ebp)
80108f88:	e8 13 09 00 00       	call   801098a0 <eth_proc>
80108f8d:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f93:	8b 10                	mov    (%eax),%edx
80108f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f98:	8b 00                	mov    (%eax),%eax
80108f9a:	39 c2                	cmp    %eax,%edx
80108f9c:	75 9f                	jne    80108f3d <i8254_recv+0x3a>
      (*rdt)--;
80108f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa1:	8b 00                	mov    (%eax),%eax
80108fa3:	8d 50 ff             	lea    -0x1(%eax),%edx
80108fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa9:	89 10                	mov    %edx,(%eax)
  while(1){
80108fab:	eb 90                	jmp    80108f3d <i8254_recv+0x3a>

80108fad <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108fad:	55                   	push   %ebp
80108fae:	89 e5                	mov    %esp,%ebp
80108fb0:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fb3:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fb8:	05 10 38 00 00       	add    $0x3810,%eax
80108fbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108fc0:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fc5:	05 18 38 00 00       	add    $0x3818,%eax
80108fca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108fcd:	a1 8c 77 19 80       	mov    0x8019778c,%eax
80108fd2:	05 00 38 00 00       	add    $0x3800,%eax
80108fd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108fda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fdd:	8b 00                	mov    (%eax),%eax
80108fdf:	05 00 00 00 80       	add    $0x80000000,%eax
80108fe4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fea:	8b 10                	mov    (%eax),%edx
80108fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fef:	8b 00                	mov    (%eax),%eax
80108ff1:	29 c2                	sub    %eax,%edx
80108ff3:	0f b6 c2             	movzbl %dl,%eax
80108ff6:	ba 00 01 00 00       	mov    $0x100,%edx
80108ffb:	29 c2                	sub    %eax,%edx
80108ffd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109000:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109003:	8b 00                	mov    (%eax),%eax
80109005:	25 ff 00 00 00       	and    $0xff,%eax
8010900a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010900d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109011:	0f 8e a8 00 00 00    	jle    801090bf <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109017:	8b 45 08             	mov    0x8(%ebp),%eax
8010901a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010901d:	89 d1                	mov    %edx,%ecx
8010901f:	c1 e1 04             	shl    $0x4,%ecx
80109022:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109025:	01 ca                	add    %ecx,%edx
80109027:	8b 12                	mov    (%edx),%edx
80109029:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010902f:	83 ec 04             	sub    $0x4,%esp
80109032:	ff 75 0c             	push   0xc(%ebp)
80109035:	50                   	push   %eax
80109036:	52                   	push   %edx
80109037:	e8 93 be ff ff       	call   80104ecf <memmove>
8010903c:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010903f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109042:	c1 e0 04             	shl    $0x4,%eax
80109045:	89 c2                	mov    %eax,%edx
80109047:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010904a:	01 d0                	add    %edx,%eax
8010904c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010904f:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109053:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109056:	c1 e0 04             	shl    $0x4,%eax
80109059:	89 c2                	mov    %eax,%edx
8010905b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010905e:	01 d0                	add    %edx,%eax
80109060:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109064:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109067:	c1 e0 04             	shl    $0x4,%eax
8010906a:	89 c2                	mov    %eax,%edx
8010906c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010906f:	01 d0                	add    %edx,%eax
80109071:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109075:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109078:	c1 e0 04             	shl    $0x4,%eax
8010907b:	89 c2                	mov    %eax,%edx
8010907d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109080:	01 d0                	add    %edx,%eax
80109082:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109086:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109089:	c1 e0 04             	shl    $0x4,%eax
8010908c:	89 c2                	mov    %eax,%edx
8010908e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109091:	01 d0                	add    %edx,%eax
80109093:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109099:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010909c:	c1 e0 04             	shl    $0x4,%eax
8010909f:	89 c2                	mov    %eax,%edx
801090a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090a4:	01 d0                	add    %edx,%eax
801090a6:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801090aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ad:	8b 00                	mov    (%eax),%eax
801090af:	83 c0 01             	add    $0x1,%eax
801090b2:	0f b6 d0             	movzbl %al,%edx
801090b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090b8:	89 10                	mov    %edx,(%eax)
    return len;
801090ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801090bd:	eb 05                	jmp    801090c4 <i8254_send+0x117>
  }else{
    return -1;
801090bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801090c4:	c9                   	leave
801090c5:	c3                   	ret

801090c6 <i8254_intr>:

void i8254_intr(){
801090c6:	55                   	push   %ebp
801090c7:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801090c9:	a1 98 77 19 80       	mov    0x80197798,%eax
801090ce:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801090d4:	90                   	nop
801090d5:	5d                   	pop    %ebp
801090d6:	c3                   	ret

801090d7 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801090d7:	55                   	push   %ebp
801090d8:	89 e5                	mov    %esp,%ebp
801090da:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801090dd:	8b 45 08             	mov    0x8(%ebp),%eax
801090e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801090e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e6:	0f b7 00             	movzwl (%eax),%eax
801090e9:	66 3d 00 01          	cmp    $0x100,%ax
801090ed:	74 0a                	je     801090f9 <arp_proc+0x22>
801090ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090f4:	e9 4f 01 00 00       	jmp    80109248 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801090f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090fc:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109100:	66 83 f8 08          	cmp    $0x8,%ax
80109104:	74 0a                	je     80109110 <arp_proc+0x39>
80109106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010910b:	e9 38 01 00 00       	jmp    80109248 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109113:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109117:	3c 06                	cmp    $0x6,%al
80109119:	74 0a                	je     80109125 <arp_proc+0x4e>
8010911b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109120:	e9 23 01 00 00       	jmp    80109248 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109128:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010912c:	3c 04                	cmp    $0x4,%al
8010912e:	74 0a                	je     8010913a <arp_proc+0x63>
80109130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109135:	e9 0e 01 00 00       	jmp    80109248 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010913a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913d:	83 c0 18             	add    $0x18,%eax
80109140:	83 ec 04             	sub    $0x4,%esp
80109143:	6a 04                	push   $0x4
80109145:	50                   	push   %eax
80109146:	68 04 f5 10 80       	push   $0x8010f504
8010914b:	e8 27 bd ff ff       	call   80104e77 <memcmp>
80109150:	83 c4 10             	add    $0x10,%esp
80109153:	85 c0                	test   %eax,%eax
80109155:	74 27                	je     8010917e <arp_proc+0xa7>
80109157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915a:	83 c0 0e             	add    $0xe,%eax
8010915d:	83 ec 04             	sub    $0x4,%esp
80109160:	6a 04                	push   $0x4
80109162:	50                   	push   %eax
80109163:	68 04 f5 10 80       	push   $0x8010f504
80109168:	e8 0a bd ff ff       	call   80104e77 <memcmp>
8010916d:	83 c4 10             	add    $0x10,%esp
80109170:	85 c0                	test   %eax,%eax
80109172:	74 0a                	je     8010917e <arp_proc+0xa7>
80109174:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109179:	e9 ca 00 00 00       	jmp    80109248 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010917e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109181:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109185:	66 3d 00 01          	cmp    $0x100,%ax
80109189:	75 69                	jne    801091f4 <arp_proc+0x11d>
8010918b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918e:	83 c0 18             	add    $0x18,%eax
80109191:	83 ec 04             	sub    $0x4,%esp
80109194:	6a 04                	push   $0x4
80109196:	50                   	push   %eax
80109197:	68 04 f5 10 80       	push   $0x8010f504
8010919c:	e8 d6 bc ff ff       	call   80104e77 <memcmp>
801091a1:	83 c4 10             	add    $0x10,%esp
801091a4:	85 c0                	test   %eax,%eax
801091a6:	75 4c                	jne    801091f4 <arp_proc+0x11d>
    uint send = (uint)kalloc();
801091a8:	e8 fb 95 ff ff       	call   801027a8 <kalloc>
801091ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801091b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801091b7:	83 ec 04             	sub    $0x4,%esp
801091ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091bd:	50                   	push   %eax
801091be:	ff 75 f0             	push   -0x10(%ebp)
801091c1:	ff 75 f4             	push   -0xc(%ebp)
801091c4:	e8 1f 04 00 00       	call   801095e8 <arp_reply_pkt_create>
801091c9:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801091cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091cf:	83 ec 08             	sub    $0x8,%esp
801091d2:	50                   	push   %eax
801091d3:	ff 75 f0             	push   -0x10(%ebp)
801091d6:	e8 d2 fd ff ff       	call   80108fad <i8254_send>
801091db:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801091de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e1:	83 ec 0c             	sub    $0xc,%esp
801091e4:	50                   	push   %eax
801091e5:	e8 24 95 ff ff       	call   8010270e <kfree>
801091ea:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801091ed:	b8 02 00 00 00       	mov    $0x2,%eax
801091f2:	eb 54                	jmp    80109248 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091fb:	66 3d 00 02          	cmp    $0x200,%ax
801091ff:	75 42                	jne    80109243 <arp_proc+0x16c>
80109201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109204:	83 c0 18             	add    $0x18,%eax
80109207:	83 ec 04             	sub    $0x4,%esp
8010920a:	6a 04                	push   $0x4
8010920c:	50                   	push   %eax
8010920d:	68 04 f5 10 80       	push   $0x8010f504
80109212:	e8 60 bc ff ff       	call   80104e77 <memcmp>
80109217:	83 c4 10             	add    $0x10,%esp
8010921a:	85 c0                	test   %eax,%eax
8010921c:	75 25                	jne    80109243 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010921e:	83 ec 0c             	sub    $0xc,%esp
80109221:	68 fc c3 10 80       	push   $0x8010c3fc
80109226:	e8 c9 71 ff ff       	call   801003f4 <cprintf>
8010922b:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010922e:	83 ec 0c             	sub    $0xc,%esp
80109231:	ff 75 f4             	push   -0xc(%ebp)
80109234:	e8 af 01 00 00       	call   801093e8 <arp_table_update>
80109239:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010923c:	b8 01 00 00 00       	mov    $0x1,%eax
80109241:	eb 05                	jmp    80109248 <arp_proc+0x171>
  }else{
    return -1;
80109243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109248:	c9                   	leave
80109249:	c3                   	ret

8010924a <arp_scan>:

void arp_scan(){
8010924a:	55                   	push   %ebp
8010924b:	89 e5                	mov    %esp,%ebp
8010924d:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109250:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109257:	eb 6f                	jmp    801092c8 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109259:	e8 4a 95 ff ff       	call   801027a8 <kalloc>
8010925e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109261:	83 ec 04             	sub    $0x4,%esp
80109264:	ff 75 f4             	push   -0xc(%ebp)
80109267:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010926a:	50                   	push   %eax
8010926b:	ff 75 ec             	push   -0x14(%ebp)
8010926e:	e8 62 00 00 00       	call   801092d5 <arp_broadcast>
80109273:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109276:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109279:	83 ec 08             	sub    $0x8,%esp
8010927c:	50                   	push   %eax
8010927d:	ff 75 ec             	push   -0x14(%ebp)
80109280:	e8 28 fd ff ff       	call   80108fad <i8254_send>
80109285:	83 c4 10             	add    $0x10,%esp
80109288:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010928b:	eb 22                	jmp    801092af <arp_scan+0x65>
      microdelay(1);
8010928d:	83 ec 0c             	sub    $0xc,%esp
80109290:	6a 01                	push   $0x1
80109292:	e8 a2 98 ff ff       	call   80102b39 <microdelay>
80109297:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010929a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010929d:	83 ec 08             	sub    $0x8,%esp
801092a0:	50                   	push   %eax
801092a1:	ff 75 ec             	push   -0x14(%ebp)
801092a4:	e8 04 fd ff ff       	call   80108fad <i8254_send>
801092a9:	83 c4 10             	add    $0x10,%esp
801092ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092af:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801092b3:	74 d8                	je     8010928d <arp_scan+0x43>
    }
    kfree((char *)send);
801092b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092b8:	83 ec 0c             	sub    $0xc,%esp
801092bb:	50                   	push   %eax
801092bc:	e8 4d 94 ff ff       	call   8010270e <kfree>
801092c1:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801092c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801092c8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801092cf:	7e 88                	jle    80109259 <arp_scan+0xf>
  }
}
801092d1:	90                   	nop
801092d2:	90                   	nop
801092d3:	c9                   	leave
801092d4:	c3                   	ret

801092d5 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801092d5:	55                   	push   %ebp
801092d6:	89 e5                	mov    %esp,%ebp
801092d8:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801092db:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801092df:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801092e3:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801092e7:	8b 45 10             	mov    0x10(%ebp),%eax
801092ea:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801092ed:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801092f4:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801092fa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109301:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109307:	8b 45 0c             	mov    0xc(%ebp),%eax
8010930a:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109310:	8b 45 08             	mov    0x8(%ebp),%eax
80109313:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109316:	8b 45 08             	mov    0x8(%ebp),%eax
80109319:	83 c0 0e             	add    $0xe,%eax
8010931c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010931f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109322:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109329:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010932d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109330:	83 ec 04             	sub    $0x4,%esp
80109333:	6a 06                	push   $0x6
80109335:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109338:	52                   	push   %edx
80109339:	50                   	push   %eax
8010933a:	e8 90 bb ff ff       	call   80104ecf <memmove>
8010933f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109345:	83 c0 06             	add    $0x6,%eax
80109348:	83 ec 04             	sub    $0x4,%esp
8010934b:	6a 06                	push   $0x6
8010934d:	68 90 77 19 80       	push   $0x80197790
80109352:	50                   	push   %eax
80109353:	e8 77 bb ff ff       	call   80104ecf <memmove>
80109358:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010935b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010935e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109363:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109366:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010936c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010936f:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109376:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010937a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010937d:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109383:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109386:	8d 50 12             	lea    0x12(%eax),%edx
80109389:	83 ec 04             	sub    $0x4,%esp
8010938c:	6a 06                	push   $0x6
8010938e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109391:	50                   	push   %eax
80109392:	52                   	push   %edx
80109393:	e8 37 bb ff ff       	call   80104ecf <memmove>
80109398:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010939b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939e:	8d 50 18             	lea    0x18(%eax),%edx
801093a1:	83 ec 04             	sub    $0x4,%esp
801093a4:	6a 04                	push   $0x4
801093a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093a9:	50                   	push   %eax
801093aa:	52                   	push   %edx
801093ab:	e8 1f bb ff ff       	call   80104ecf <memmove>
801093b0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801093b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b6:	83 c0 08             	add    $0x8,%eax
801093b9:	83 ec 04             	sub    $0x4,%esp
801093bc:	6a 06                	push   $0x6
801093be:	68 90 77 19 80       	push   $0x80197790
801093c3:	50                   	push   %eax
801093c4:	e8 06 bb ff ff       	call   80104ecf <memmove>
801093c9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801093cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cf:	83 c0 0e             	add    $0xe,%eax
801093d2:	83 ec 04             	sub    $0x4,%esp
801093d5:	6a 04                	push   $0x4
801093d7:	68 04 f5 10 80       	push   $0x8010f504
801093dc:	50                   	push   %eax
801093dd:	e8 ed ba ff ff       	call   80104ecf <memmove>
801093e2:	83 c4 10             	add    $0x10,%esp
}
801093e5:	90                   	nop
801093e6:	c9                   	leave
801093e7:	c3                   	ret

801093e8 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801093e8:	55                   	push   %ebp
801093e9:	89 e5                	mov    %esp,%ebp
801093eb:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801093ee:	8b 45 08             	mov    0x8(%ebp),%eax
801093f1:	83 c0 0e             	add    $0xe,%eax
801093f4:	83 ec 0c             	sub    $0xc,%esp
801093f7:	50                   	push   %eax
801093f8:	e8 bc 00 00 00       	call   801094b9 <arp_table_search>
801093fd:	83 c4 10             	add    $0x10,%esp
80109400:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109403:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109407:	78 2d                	js     80109436 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109409:	8b 45 08             	mov    0x8(%ebp),%eax
8010940c:	8d 48 08             	lea    0x8(%eax),%ecx
8010940f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109412:	89 d0                	mov    %edx,%eax
80109414:	c1 e0 02             	shl    $0x2,%eax
80109417:	01 d0                	add    %edx,%eax
80109419:	01 c0                	add    %eax,%eax
8010941b:	01 d0                	add    %edx,%eax
8010941d:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109422:	83 c0 04             	add    $0x4,%eax
80109425:	83 ec 04             	sub    $0x4,%esp
80109428:	6a 06                	push   $0x6
8010942a:	51                   	push   %ecx
8010942b:	50                   	push   %eax
8010942c:	e8 9e ba ff ff       	call   80104ecf <memmove>
80109431:	83 c4 10             	add    $0x10,%esp
80109434:	eb 70                	jmp    801094a6 <arp_table_update+0xbe>
  }else{
    index += 1;
80109436:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
8010943a:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010943d:	8b 45 08             	mov    0x8(%ebp),%eax
80109440:	8d 48 08             	lea    0x8(%eax),%ecx
80109443:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109446:	89 d0                	mov    %edx,%eax
80109448:	c1 e0 02             	shl    $0x2,%eax
8010944b:	01 d0                	add    %edx,%eax
8010944d:	01 c0                	add    %eax,%eax
8010944f:	01 d0                	add    %edx,%eax
80109451:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109456:	83 c0 04             	add    $0x4,%eax
80109459:	83 ec 04             	sub    $0x4,%esp
8010945c:	6a 06                	push   $0x6
8010945e:	51                   	push   %ecx
8010945f:	50                   	push   %eax
80109460:	e8 6a ba ff ff       	call   80104ecf <memmove>
80109465:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109468:	8b 45 08             	mov    0x8(%ebp),%eax
8010946b:	8d 48 0e             	lea    0xe(%eax),%ecx
8010946e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109471:	89 d0                	mov    %edx,%eax
80109473:	c1 e0 02             	shl    $0x2,%eax
80109476:	01 d0                	add    %edx,%eax
80109478:	01 c0                	add    %eax,%eax
8010947a:	01 d0                	add    %edx,%eax
8010947c:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109481:	83 ec 04             	sub    $0x4,%esp
80109484:	6a 04                	push   $0x4
80109486:	51                   	push   %ecx
80109487:	50                   	push   %eax
80109488:	e8 42 ba ff ff       	call   80104ecf <memmove>
8010948d:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109493:	89 d0                	mov    %edx,%eax
80109495:	c1 e0 02             	shl    $0x2,%eax
80109498:	01 d0                	add    %edx,%eax
8010949a:	01 c0                	add    %eax,%eax
8010949c:	01 d0                	add    %edx,%eax
8010949e:	05 aa 77 19 80       	add    $0x801977aa,%eax
801094a3:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801094a6:	83 ec 0c             	sub    $0xc,%esp
801094a9:	68 a0 77 19 80       	push   $0x801977a0
801094ae:	e8 83 00 00 00       	call   80109536 <print_arp_table>
801094b3:	83 c4 10             	add    $0x10,%esp
}
801094b6:	90                   	nop
801094b7:	c9                   	leave
801094b8:	c3                   	ret

801094b9 <arp_table_search>:

int arp_table_search(uchar *ip){
801094b9:	55                   	push   %ebp
801094ba:	89 e5                	mov    %esp,%ebp
801094bc:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801094bf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801094c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801094cd:	eb 59                	jmp    80109528 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801094cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094d2:	89 d0                	mov    %edx,%eax
801094d4:	c1 e0 02             	shl    $0x2,%eax
801094d7:	01 d0                	add    %edx,%eax
801094d9:	01 c0                	add    %eax,%eax
801094db:	01 d0                	add    %edx,%eax
801094dd:	05 a0 77 19 80       	add    $0x801977a0,%eax
801094e2:	83 ec 04             	sub    $0x4,%esp
801094e5:	6a 04                	push   $0x4
801094e7:	ff 75 08             	push   0x8(%ebp)
801094ea:	50                   	push   %eax
801094eb:	e8 87 b9 ff ff       	call   80104e77 <memcmp>
801094f0:	83 c4 10             	add    $0x10,%esp
801094f3:	85 c0                	test   %eax,%eax
801094f5:	75 05                	jne    801094fc <arp_table_search+0x43>
      return i;
801094f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094fa:	eb 38                	jmp    80109534 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801094fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094ff:	89 d0                	mov    %edx,%eax
80109501:	c1 e0 02             	shl    $0x2,%eax
80109504:	01 d0                	add    %edx,%eax
80109506:	01 c0                	add    %eax,%eax
80109508:	01 d0                	add    %edx,%eax
8010950a:	05 aa 77 19 80       	add    $0x801977aa,%eax
8010950f:	0f b6 00             	movzbl (%eax),%eax
80109512:	84 c0                	test   %al,%al
80109514:	75 0e                	jne    80109524 <arp_table_search+0x6b>
80109516:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010951a:	75 08                	jne    80109524 <arp_table_search+0x6b>
      empty = -i;
8010951c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010951f:	f7 d8                	neg    %eax
80109521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109524:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109528:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010952c:	7e a1                	jle    801094cf <arp_table_search+0x16>
    }
  }
  return empty-1;
8010952e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109531:	83 e8 01             	sub    $0x1,%eax
}
80109534:	c9                   	leave
80109535:	c3                   	ret

80109536 <print_arp_table>:

void print_arp_table(){
80109536:	55                   	push   %ebp
80109537:	89 e5                	mov    %esp,%ebp
80109539:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010953c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109543:	e9 92 00 00 00       	jmp    801095da <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109548:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010954b:	89 d0                	mov    %edx,%eax
8010954d:	c1 e0 02             	shl    $0x2,%eax
80109550:	01 d0                	add    %edx,%eax
80109552:	01 c0                	add    %eax,%eax
80109554:	01 d0                	add    %edx,%eax
80109556:	05 aa 77 19 80       	add    $0x801977aa,%eax
8010955b:	0f b6 00             	movzbl (%eax),%eax
8010955e:	84 c0                	test   %al,%al
80109560:	74 74                	je     801095d6 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109562:	83 ec 08             	sub    $0x8,%esp
80109565:	ff 75 f4             	push   -0xc(%ebp)
80109568:	68 0f c4 10 80       	push   $0x8010c40f
8010956d:	e8 82 6e ff ff       	call   801003f4 <cprintf>
80109572:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109575:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109578:	89 d0                	mov    %edx,%eax
8010957a:	c1 e0 02             	shl    $0x2,%eax
8010957d:	01 d0                	add    %edx,%eax
8010957f:	01 c0                	add    %eax,%eax
80109581:	01 d0                	add    %edx,%eax
80109583:	05 a0 77 19 80       	add    $0x801977a0,%eax
80109588:	83 ec 0c             	sub    $0xc,%esp
8010958b:	50                   	push   %eax
8010958c:	e8 54 02 00 00       	call   801097e5 <print_ipv4>
80109591:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109594:	83 ec 0c             	sub    $0xc,%esp
80109597:	68 1e c4 10 80       	push   $0x8010c41e
8010959c:	e8 53 6e ff ff       	call   801003f4 <cprintf>
801095a1:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801095a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095a7:	89 d0                	mov    %edx,%eax
801095a9:	c1 e0 02             	shl    $0x2,%eax
801095ac:	01 d0                	add    %edx,%eax
801095ae:	01 c0                	add    %eax,%eax
801095b0:	01 d0                	add    %edx,%eax
801095b2:	05 a0 77 19 80       	add    $0x801977a0,%eax
801095b7:	83 c0 04             	add    $0x4,%eax
801095ba:	83 ec 0c             	sub    $0xc,%esp
801095bd:	50                   	push   %eax
801095be:	e8 70 02 00 00       	call   80109833 <print_mac>
801095c3:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801095c6:	83 ec 0c             	sub    $0xc,%esp
801095c9:	68 20 c4 10 80       	push   $0x8010c420
801095ce:	e8 21 6e ff ff       	call   801003f4 <cprintf>
801095d3:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801095d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801095da:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801095de:	0f 8e 64 ff ff ff    	jle    80109548 <print_arp_table+0x12>
    }
  }
}
801095e4:	90                   	nop
801095e5:	90                   	nop
801095e6:	c9                   	leave
801095e7:	c3                   	ret

801095e8 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801095e8:	55                   	push   %ebp
801095e9:	89 e5                	mov    %esp,%ebp
801095eb:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801095ee:	8b 45 10             	mov    0x10(%ebp),%eax
801095f1:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801095f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801095fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801095fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109600:	83 c0 0e             	add    $0xe,%eax
80109603:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109609:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010960d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109610:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109614:	8b 45 08             	mov    0x8(%ebp),%eax
80109617:	8d 50 08             	lea    0x8(%eax),%edx
8010961a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010961d:	83 ec 04             	sub    $0x4,%esp
80109620:	6a 06                	push   $0x6
80109622:	52                   	push   %edx
80109623:	50                   	push   %eax
80109624:	e8 a6 b8 ff ff       	call   80104ecf <memmove>
80109629:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010962c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962f:	83 c0 06             	add    $0x6,%eax
80109632:	83 ec 04             	sub    $0x4,%esp
80109635:	6a 06                	push   $0x6
80109637:	68 90 77 19 80       	push   $0x80197790
8010963c:	50                   	push   %eax
8010963d:	e8 8d b8 ff ff       	call   80104ecf <memmove>
80109642:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109648:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010964d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109650:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109659:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010965d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109660:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109667:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010966d:	8b 45 08             	mov    0x8(%ebp),%eax
80109670:	8d 50 08             	lea    0x8(%eax),%edx
80109673:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109676:	83 c0 12             	add    $0x12,%eax
80109679:	83 ec 04             	sub    $0x4,%esp
8010967c:	6a 06                	push   $0x6
8010967e:	52                   	push   %edx
8010967f:	50                   	push   %eax
80109680:	e8 4a b8 ff ff       	call   80104ecf <memmove>
80109685:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109688:	8b 45 08             	mov    0x8(%ebp),%eax
8010968b:	8d 50 0e             	lea    0xe(%eax),%edx
8010968e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109691:	83 c0 18             	add    $0x18,%eax
80109694:	83 ec 04             	sub    $0x4,%esp
80109697:	6a 04                	push   $0x4
80109699:	52                   	push   %edx
8010969a:	50                   	push   %eax
8010969b:	e8 2f b8 ff ff       	call   80104ecf <memmove>
801096a0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801096a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a6:	83 c0 08             	add    $0x8,%eax
801096a9:	83 ec 04             	sub    $0x4,%esp
801096ac:	6a 06                	push   $0x6
801096ae:	68 90 77 19 80       	push   $0x80197790
801096b3:	50                   	push   %eax
801096b4:	e8 16 b8 ff ff       	call   80104ecf <memmove>
801096b9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801096bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096bf:	83 c0 0e             	add    $0xe,%eax
801096c2:	83 ec 04             	sub    $0x4,%esp
801096c5:	6a 04                	push   $0x4
801096c7:	68 04 f5 10 80       	push   $0x8010f504
801096cc:	50                   	push   %eax
801096cd:	e8 fd b7 ff ff       	call   80104ecf <memmove>
801096d2:	83 c4 10             	add    $0x10,%esp
}
801096d5:	90                   	nop
801096d6:	c9                   	leave
801096d7:	c3                   	ret

801096d8 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801096d8:	55                   	push   %ebp
801096d9:	89 e5                	mov    %esp,%ebp
801096db:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801096de:	83 ec 0c             	sub    $0xc,%esp
801096e1:	68 22 c4 10 80       	push   $0x8010c422
801096e6:	e8 09 6d ff ff       	call   801003f4 <cprintf>
801096eb:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801096ee:	8b 45 08             	mov    0x8(%ebp),%eax
801096f1:	83 c0 0e             	add    $0xe,%eax
801096f4:	83 ec 0c             	sub    $0xc,%esp
801096f7:	50                   	push   %eax
801096f8:	e8 e8 00 00 00       	call   801097e5 <print_ipv4>
801096fd:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109700:	83 ec 0c             	sub    $0xc,%esp
80109703:	68 20 c4 10 80       	push   $0x8010c420
80109708:	e8 e7 6c ff ff       	call   801003f4 <cprintf>
8010970d:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109710:	8b 45 08             	mov    0x8(%ebp),%eax
80109713:	83 c0 08             	add    $0x8,%eax
80109716:	83 ec 0c             	sub    $0xc,%esp
80109719:	50                   	push   %eax
8010971a:	e8 14 01 00 00       	call   80109833 <print_mac>
8010971f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109722:	83 ec 0c             	sub    $0xc,%esp
80109725:	68 20 c4 10 80       	push   $0x8010c420
8010972a:	e8 c5 6c ff ff       	call   801003f4 <cprintf>
8010972f:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109732:	83 ec 0c             	sub    $0xc,%esp
80109735:	68 39 c4 10 80       	push   $0x8010c439
8010973a:	e8 b5 6c ff ff       	call   801003f4 <cprintf>
8010973f:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109742:	8b 45 08             	mov    0x8(%ebp),%eax
80109745:	83 c0 18             	add    $0x18,%eax
80109748:	83 ec 0c             	sub    $0xc,%esp
8010974b:	50                   	push   %eax
8010974c:	e8 94 00 00 00       	call   801097e5 <print_ipv4>
80109751:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109754:	83 ec 0c             	sub    $0xc,%esp
80109757:	68 20 c4 10 80       	push   $0x8010c420
8010975c:	e8 93 6c ff ff       	call   801003f4 <cprintf>
80109761:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109764:	8b 45 08             	mov    0x8(%ebp),%eax
80109767:	83 c0 12             	add    $0x12,%eax
8010976a:	83 ec 0c             	sub    $0xc,%esp
8010976d:	50                   	push   %eax
8010976e:	e8 c0 00 00 00       	call   80109833 <print_mac>
80109773:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109776:	83 ec 0c             	sub    $0xc,%esp
80109779:	68 20 c4 10 80       	push   $0x8010c420
8010977e:	e8 71 6c ff ff       	call   801003f4 <cprintf>
80109783:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109786:	83 ec 0c             	sub    $0xc,%esp
80109789:	68 50 c4 10 80       	push   $0x8010c450
8010978e:	e8 61 6c ff ff       	call   801003f4 <cprintf>
80109793:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109796:	8b 45 08             	mov    0x8(%ebp),%eax
80109799:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010979d:	66 3d 00 01          	cmp    $0x100,%ax
801097a1:	75 12                	jne    801097b5 <print_arp_info+0xdd>
801097a3:	83 ec 0c             	sub    $0xc,%esp
801097a6:	68 5c c4 10 80       	push   $0x8010c45c
801097ab:	e8 44 6c ff ff       	call   801003f4 <cprintf>
801097b0:	83 c4 10             	add    $0x10,%esp
801097b3:	eb 1d                	jmp    801097d2 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801097b5:	8b 45 08             	mov    0x8(%ebp),%eax
801097b8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097bc:	66 3d 00 02          	cmp    $0x200,%ax
801097c0:	75 10                	jne    801097d2 <print_arp_info+0xfa>
    cprintf("Reply\n");
801097c2:	83 ec 0c             	sub    $0xc,%esp
801097c5:	68 65 c4 10 80       	push   $0x8010c465
801097ca:	e8 25 6c ff ff       	call   801003f4 <cprintf>
801097cf:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801097d2:	83 ec 0c             	sub    $0xc,%esp
801097d5:	68 20 c4 10 80       	push   $0x8010c420
801097da:	e8 15 6c ff ff       	call   801003f4 <cprintf>
801097df:	83 c4 10             	add    $0x10,%esp
}
801097e2:	90                   	nop
801097e3:	c9                   	leave
801097e4:	c3                   	ret

801097e5 <print_ipv4>:

void print_ipv4(uchar *ip){
801097e5:	55                   	push   %ebp
801097e6:	89 e5                	mov    %esp,%ebp
801097e8:	53                   	push   %ebx
801097e9:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801097ec:	8b 45 08             	mov    0x8(%ebp),%eax
801097ef:	83 c0 03             	add    $0x3,%eax
801097f2:	0f b6 00             	movzbl (%eax),%eax
801097f5:	0f b6 d8             	movzbl %al,%ebx
801097f8:	8b 45 08             	mov    0x8(%ebp),%eax
801097fb:	83 c0 02             	add    $0x2,%eax
801097fe:	0f b6 00             	movzbl (%eax),%eax
80109801:	0f b6 c8             	movzbl %al,%ecx
80109804:	8b 45 08             	mov    0x8(%ebp),%eax
80109807:	83 c0 01             	add    $0x1,%eax
8010980a:	0f b6 00             	movzbl (%eax),%eax
8010980d:	0f b6 d0             	movzbl %al,%edx
80109810:	8b 45 08             	mov    0x8(%ebp),%eax
80109813:	0f b6 00             	movzbl (%eax),%eax
80109816:	0f b6 c0             	movzbl %al,%eax
80109819:	83 ec 0c             	sub    $0xc,%esp
8010981c:	53                   	push   %ebx
8010981d:	51                   	push   %ecx
8010981e:	52                   	push   %edx
8010981f:	50                   	push   %eax
80109820:	68 6c c4 10 80       	push   $0x8010c46c
80109825:	e8 ca 6b ff ff       	call   801003f4 <cprintf>
8010982a:	83 c4 20             	add    $0x20,%esp
}
8010982d:	90                   	nop
8010982e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109831:	c9                   	leave
80109832:	c3                   	ret

80109833 <print_mac>:

void print_mac(uchar *mac){
80109833:	55                   	push   %ebp
80109834:	89 e5                	mov    %esp,%ebp
80109836:	57                   	push   %edi
80109837:	56                   	push   %esi
80109838:	53                   	push   %ebx
80109839:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010983c:	8b 45 08             	mov    0x8(%ebp),%eax
8010983f:	83 c0 05             	add    $0x5,%eax
80109842:	0f b6 00             	movzbl (%eax),%eax
80109845:	0f b6 f8             	movzbl %al,%edi
80109848:	8b 45 08             	mov    0x8(%ebp),%eax
8010984b:	83 c0 04             	add    $0x4,%eax
8010984e:	0f b6 00             	movzbl (%eax),%eax
80109851:	0f b6 f0             	movzbl %al,%esi
80109854:	8b 45 08             	mov    0x8(%ebp),%eax
80109857:	83 c0 03             	add    $0x3,%eax
8010985a:	0f b6 00             	movzbl (%eax),%eax
8010985d:	0f b6 d8             	movzbl %al,%ebx
80109860:	8b 45 08             	mov    0x8(%ebp),%eax
80109863:	83 c0 02             	add    $0x2,%eax
80109866:	0f b6 00             	movzbl (%eax),%eax
80109869:	0f b6 c8             	movzbl %al,%ecx
8010986c:	8b 45 08             	mov    0x8(%ebp),%eax
8010986f:	83 c0 01             	add    $0x1,%eax
80109872:	0f b6 00             	movzbl (%eax),%eax
80109875:	0f b6 d0             	movzbl %al,%edx
80109878:	8b 45 08             	mov    0x8(%ebp),%eax
8010987b:	0f b6 00             	movzbl (%eax),%eax
8010987e:	0f b6 c0             	movzbl %al,%eax
80109881:	83 ec 04             	sub    $0x4,%esp
80109884:	57                   	push   %edi
80109885:	56                   	push   %esi
80109886:	53                   	push   %ebx
80109887:	51                   	push   %ecx
80109888:	52                   	push   %edx
80109889:	50                   	push   %eax
8010988a:	68 84 c4 10 80       	push   $0x8010c484
8010988f:	e8 60 6b ff ff       	call   801003f4 <cprintf>
80109894:	83 c4 20             	add    $0x20,%esp
}
80109897:	90                   	nop
80109898:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010989b:	5b                   	pop    %ebx
8010989c:	5e                   	pop    %esi
8010989d:	5f                   	pop    %edi
8010989e:	5d                   	pop    %ebp
8010989f:	c3                   	ret

801098a0 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801098a0:	55                   	push   %ebp
801098a1:	89 e5                	mov    %esp,%ebp
801098a3:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801098a6:	8b 45 08             	mov    0x8(%ebp),%eax
801098a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801098ac:	8b 45 08             	mov    0x8(%ebp),%eax
801098af:	83 c0 0e             	add    $0xe,%eax
801098b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801098b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098bc:	3c 08                	cmp    $0x8,%al
801098be:	75 1b                	jne    801098db <eth_proc+0x3b>
801098c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098c7:	3c 06                	cmp    $0x6,%al
801098c9:	75 10                	jne    801098db <eth_proc+0x3b>
    arp_proc(pkt_addr);
801098cb:	83 ec 0c             	sub    $0xc,%esp
801098ce:	ff 75 f0             	push   -0x10(%ebp)
801098d1:	e8 01 f8 ff ff       	call   801090d7 <arp_proc>
801098d6:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801098d9:	eb 24                	jmp    801098ff <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801098db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098de:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098e2:	3c 08                	cmp    $0x8,%al
801098e4:	75 19                	jne    801098ff <eth_proc+0x5f>
801098e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098ed:	84 c0                	test   %al,%al
801098ef:	75 0e                	jne    801098ff <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801098f1:	83 ec 0c             	sub    $0xc,%esp
801098f4:	ff 75 08             	push   0x8(%ebp)
801098f7:	e8 8d 00 00 00       	call   80109989 <ipv4_proc>
801098fc:	83 c4 10             	add    $0x10,%esp
}
801098ff:	90                   	nop
80109900:	c9                   	leave
80109901:	c3                   	ret

80109902 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109902:	55                   	push   %ebp
80109903:	89 e5                	mov    %esp,%ebp
80109905:	83 ec 04             	sub    $0x4,%esp
80109908:	8b 45 08             	mov    0x8(%ebp),%eax
8010990b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010990f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109913:	66 c1 c0 08          	rol    $0x8,%ax
}
80109917:	c9                   	leave
80109918:	c3                   	ret

80109919 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109919:	55                   	push   %ebp
8010991a:	89 e5                	mov    %esp,%ebp
8010991c:	83 ec 04             	sub    $0x4,%esp
8010991f:	8b 45 08             	mov    0x8(%ebp),%eax
80109922:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109926:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010992a:	66 c1 c0 08          	rol    $0x8,%ax
}
8010992e:	c9                   	leave
8010992f:	c3                   	ret

80109930 <H2N_uint>:

uint H2N_uint(uint value){
80109930:	55                   	push   %ebp
80109931:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109933:	8b 45 08             	mov    0x8(%ebp),%eax
80109936:	c1 e0 18             	shl    $0x18,%eax
80109939:	25 00 00 00 0f       	and    $0xf000000,%eax
8010993e:	89 c2                	mov    %eax,%edx
80109940:	8b 45 08             	mov    0x8(%ebp),%eax
80109943:	c1 e0 08             	shl    $0x8,%eax
80109946:	25 00 f0 00 00       	and    $0xf000,%eax
8010994b:	09 c2                	or     %eax,%edx
8010994d:	8b 45 08             	mov    0x8(%ebp),%eax
80109950:	c1 e8 08             	shr    $0x8,%eax
80109953:	83 e0 0f             	and    $0xf,%eax
80109956:	01 d0                	add    %edx,%eax
}
80109958:	5d                   	pop    %ebp
80109959:	c3                   	ret

8010995a <N2H_uint>:

uint N2H_uint(uint value){
8010995a:	55                   	push   %ebp
8010995b:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010995d:	8b 45 08             	mov    0x8(%ebp),%eax
80109960:	c1 e0 18             	shl    $0x18,%eax
80109963:	89 c2                	mov    %eax,%edx
80109965:	8b 45 08             	mov    0x8(%ebp),%eax
80109968:	c1 e0 08             	shl    $0x8,%eax
8010996b:	25 00 00 ff 00       	and    $0xff0000,%eax
80109970:	01 c2                	add    %eax,%edx
80109972:	8b 45 08             	mov    0x8(%ebp),%eax
80109975:	c1 e8 08             	shr    $0x8,%eax
80109978:	25 00 ff 00 00       	and    $0xff00,%eax
8010997d:	01 c2                	add    %eax,%edx
8010997f:	8b 45 08             	mov    0x8(%ebp),%eax
80109982:	c1 e8 18             	shr    $0x18,%eax
80109985:	01 d0                	add    %edx,%eax
}
80109987:	5d                   	pop    %ebp
80109988:	c3                   	ret

80109989 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109989:	55                   	push   %ebp
8010998a:	89 e5                	mov    %esp,%ebp
8010998c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010998f:	8b 45 08             	mov    0x8(%ebp),%eax
80109992:	83 c0 0e             	add    $0xe,%eax
80109995:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010999b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010999f:	0f b7 d0             	movzwl %ax,%edx
801099a2:	a1 08 f5 10 80       	mov    0x8010f508,%eax
801099a7:	39 c2                	cmp    %eax,%edx
801099a9:	74 60                	je     80109a0b <ipv4_proc+0x82>
801099ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ae:	83 c0 0c             	add    $0xc,%eax
801099b1:	83 ec 04             	sub    $0x4,%esp
801099b4:	6a 04                	push   $0x4
801099b6:	50                   	push   %eax
801099b7:	68 04 f5 10 80       	push   $0x8010f504
801099bc:	e8 b6 b4 ff ff       	call   80104e77 <memcmp>
801099c1:	83 c4 10             	add    $0x10,%esp
801099c4:	85 c0                	test   %eax,%eax
801099c6:	74 43                	je     80109a0b <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801099c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099cb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099cf:	0f b7 c0             	movzwl %ax,%eax
801099d2:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801099d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099da:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099de:	3c 01                	cmp    $0x1,%al
801099e0:	75 10                	jne    801099f2 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801099e2:	83 ec 0c             	sub    $0xc,%esp
801099e5:	ff 75 08             	push   0x8(%ebp)
801099e8:	e8 a3 00 00 00       	call   80109a90 <icmp_proc>
801099ed:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801099f0:	eb 19                	jmp    80109a0b <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801099f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801099f9:	3c 06                	cmp    $0x6,%al
801099fb:	75 0e                	jne    80109a0b <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801099fd:	83 ec 0c             	sub    $0xc,%esp
80109a00:	ff 75 08             	push   0x8(%ebp)
80109a03:	e8 b3 03 00 00       	call   80109dbb <tcp_proc>
80109a08:	83 c4 10             	add    $0x10,%esp
}
80109a0b:	90                   	nop
80109a0c:	c9                   	leave
80109a0d:	c3                   	ret

80109a0e <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109a0e:	55                   	push   %ebp
80109a0f:	89 e5                	mov    %esp,%ebp
80109a11:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109a14:	8b 45 08             	mov    0x8(%ebp),%eax
80109a17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1d:	0f b6 00             	movzbl (%eax),%eax
80109a20:	83 e0 0f             	and    $0xf,%eax
80109a23:	01 c0                	add    %eax,%eax
80109a25:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109a28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a2f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109a36:	eb 48                	jmp    80109a80 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109a38:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a3b:	01 c0                	add    %eax,%eax
80109a3d:	89 c2                	mov    %eax,%edx
80109a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a42:	01 d0                	add    %edx,%eax
80109a44:	0f b6 00             	movzbl (%eax),%eax
80109a47:	0f b6 c0             	movzbl %al,%eax
80109a4a:	c1 e0 08             	shl    $0x8,%eax
80109a4d:	89 c2                	mov    %eax,%edx
80109a4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a52:	01 c0                	add    %eax,%eax
80109a54:	8d 48 01             	lea    0x1(%eax),%ecx
80109a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5a:	01 c8                	add    %ecx,%eax
80109a5c:	0f b6 00             	movzbl (%eax),%eax
80109a5f:	0f b6 c0             	movzbl %al,%eax
80109a62:	01 d0                	add    %edx,%eax
80109a64:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a67:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a6e:	76 0c                	jbe    80109a7c <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a73:	0f b7 c0             	movzwl %ax,%eax
80109a76:	83 c0 01             	add    $0x1,%eax
80109a79:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a7c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109a80:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109a84:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109a87:	7c af                	jl     80109a38 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109a8c:	f7 d0                	not    %eax
}
80109a8e:	c9                   	leave
80109a8f:	c3                   	ret

80109a90 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109a90:	55                   	push   %ebp
80109a91:	89 e5                	mov    %esp,%ebp
80109a93:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109a96:	8b 45 08             	mov    0x8(%ebp),%eax
80109a99:	83 c0 0e             	add    $0xe,%eax
80109a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aa2:	0f b6 00             	movzbl (%eax),%eax
80109aa5:	0f b6 c0             	movzbl %al,%eax
80109aa8:	83 e0 0f             	and    $0xf,%eax
80109aab:	c1 e0 02             	shl    $0x2,%eax
80109aae:	89 c2                	mov    %eax,%edx
80109ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab3:	01 d0                	add    %edx,%eax
80109ab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109abb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109abf:	84 c0                	test   %al,%al
80109ac1:	75 4f                	jne    80109b12 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ac6:	0f b6 00             	movzbl (%eax),%eax
80109ac9:	3c 08                	cmp    $0x8,%al
80109acb:	75 45                	jne    80109b12 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109acd:	e8 d6 8c ff ff       	call   801027a8 <kalloc>
80109ad2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ad5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109adc:	83 ec 04             	sub    $0x4,%esp
80109adf:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109ae2:	50                   	push   %eax
80109ae3:	ff 75 ec             	push   -0x14(%ebp)
80109ae6:	ff 75 08             	push   0x8(%ebp)
80109ae9:	e8 78 00 00 00       	call   80109b66 <icmp_reply_pkt_create>
80109aee:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109af1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109af4:	83 ec 08             	sub    $0x8,%esp
80109af7:	50                   	push   %eax
80109af8:	ff 75 ec             	push   -0x14(%ebp)
80109afb:	e8 ad f4 ff ff       	call   80108fad <i8254_send>
80109b00:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109b03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b06:	83 ec 0c             	sub    $0xc,%esp
80109b09:	50                   	push   %eax
80109b0a:	e8 ff 8b ff ff       	call   8010270e <kfree>
80109b0f:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109b12:	90                   	nop
80109b13:	c9                   	leave
80109b14:	c3                   	ret

80109b15 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109b15:	55                   	push   %ebp
80109b16:	89 e5                	mov    %esp,%ebp
80109b18:	53                   	push   %ebx
80109b19:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b23:	0f b7 c0             	movzwl %ax,%eax
80109b26:	83 ec 0c             	sub    $0xc,%esp
80109b29:	50                   	push   %eax
80109b2a:	e8 d3 fd ff ff       	call   80109902 <N2H_ushort>
80109b2f:	83 c4 10             	add    $0x10,%esp
80109b32:	0f b7 d8             	movzwl %ax,%ebx
80109b35:	8b 45 08             	mov    0x8(%ebp),%eax
80109b38:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b3c:	0f b7 c0             	movzwl %ax,%eax
80109b3f:	83 ec 0c             	sub    $0xc,%esp
80109b42:	50                   	push   %eax
80109b43:	e8 ba fd ff ff       	call   80109902 <N2H_ushort>
80109b48:	83 c4 10             	add    $0x10,%esp
80109b4b:	0f b7 c0             	movzwl %ax,%eax
80109b4e:	83 ec 04             	sub    $0x4,%esp
80109b51:	53                   	push   %ebx
80109b52:	50                   	push   %eax
80109b53:	68 a3 c4 10 80       	push   $0x8010c4a3
80109b58:	e8 97 68 ff ff       	call   801003f4 <cprintf>
80109b5d:	83 c4 10             	add    $0x10,%esp
}
80109b60:	90                   	nop
80109b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b64:	c9                   	leave
80109b65:	c3                   	ret

80109b66 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b66:	55                   	push   %ebp
80109b67:	89 e5                	mov    %esp,%ebp
80109b69:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b72:	8b 45 08             	mov    0x8(%ebp),%eax
80109b75:	83 c0 0e             	add    $0xe,%eax
80109b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b7e:	0f b6 00             	movzbl (%eax),%eax
80109b81:	0f b6 c0             	movzbl %al,%eax
80109b84:	83 e0 0f             	and    $0xf,%eax
80109b87:	c1 e0 02             	shl    $0x2,%eax
80109b8a:	89 c2                	mov    %eax,%edx
80109b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b8f:	01 d0                	add    %edx,%eax
80109b91:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b94:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b97:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b9d:	83 c0 0e             	add    $0xe,%eax
80109ba0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109ba3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ba6:	83 c0 14             	add    $0x14,%eax
80109ba9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109bac:	8b 45 10             	mov    0x10(%ebp),%eax
80109baf:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb8:	8d 50 06             	lea    0x6(%eax),%edx
80109bbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bbe:	83 ec 04             	sub    $0x4,%esp
80109bc1:	6a 06                	push   $0x6
80109bc3:	52                   	push   %edx
80109bc4:	50                   	push   %eax
80109bc5:	e8 05 b3 ff ff       	call   80104ecf <memmove>
80109bca:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109bcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bd0:	83 c0 06             	add    $0x6,%eax
80109bd3:	83 ec 04             	sub    $0x4,%esp
80109bd6:	6a 06                	push   $0x6
80109bd8:	68 90 77 19 80       	push   $0x80197790
80109bdd:	50                   	push   %eax
80109bde:	e8 ec b2 ff ff       	call   80104ecf <memmove>
80109be3:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109be6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109be9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109bed:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bf0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109bf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf7:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109bfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bfd:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109c01:	83 ec 0c             	sub    $0xc,%esp
80109c04:	6a 54                	push   $0x54
80109c06:	e8 0e fd ff ff       	call   80109919 <H2N_ushort>
80109c0b:	83 c4 10             	add    $0x10,%esp
80109c0e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c11:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c15:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
80109c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c1f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c23:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
80109c2a:	83 c0 01             	add    $0x1,%eax
80109c2d:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109c33:	83 ec 0c             	sub    $0xc,%esp
80109c36:	68 00 40 00 00       	push   $0x4000
80109c3b:	e8 d9 fc ff ff       	call   80109919 <H2N_ushort>
80109c40:	83 c4 10             	add    $0x10,%esp
80109c43:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c46:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109c4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c4d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109c51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c54:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c5b:	83 c0 0c             	add    $0xc,%eax
80109c5e:	83 ec 04             	sub    $0x4,%esp
80109c61:	6a 04                	push   $0x4
80109c63:	68 04 f5 10 80       	push   $0x8010f504
80109c68:	50                   	push   %eax
80109c69:	e8 61 b2 ff ff       	call   80104ecf <memmove>
80109c6e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c74:	8d 50 0c             	lea    0xc(%eax),%edx
80109c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c7a:	83 c0 10             	add    $0x10,%eax
80109c7d:	83 ec 04             	sub    $0x4,%esp
80109c80:	6a 04                	push   $0x4
80109c82:	52                   	push   %edx
80109c83:	50                   	push   %eax
80109c84:	e8 46 b2 ff ff       	call   80104ecf <memmove>
80109c89:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c8f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c98:	83 ec 0c             	sub    $0xc,%esp
80109c9b:	50                   	push   %eax
80109c9c:	e8 6d fd ff ff       	call   80109a0e <ipv4_chksum>
80109ca1:	83 c4 10             	add    $0x10,%esp
80109ca4:	0f b7 c0             	movzwl %ax,%eax
80109ca7:	83 ec 0c             	sub    $0xc,%esp
80109caa:	50                   	push   %eax
80109cab:	e8 69 fc ff ff       	call   80109919 <H2N_ushort>
80109cb0:	83 c4 10             	add    $0x10,%esp
80109cb3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cb6:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109cba:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cbd:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109cc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cc3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109cc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cca:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cd1:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109cd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cd8:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109cdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cdf:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109ce3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ce6:	8d 50 08             	lea    0x8(%eax),%edx
80109ce9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cec:	83 c0 08             	add    $0x8,%eax
80109cef:	83 ec 04             	sub    $0x4,%esp
80109cf2:	6a 08                	push   $0x8
80109cf4:	52                   	push   %edx
80109cf5:	50                   	push   %eax
80109cf6:	e8 d4 b1 ff ff       	call   80104ecf <memmove>
80109cfb:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109cfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d01:	8d 50 10             	lea    0x10(%eax),%edx
80109d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d07:	83 c0 10             	add    $0x10,%eax
80109d0a:	83 ec 04             	sub    $0x4,%esp
80109d0d:	6a 30                	push   $0x30
80109d0f:	52                   	push   %edx
80109d10:	50                   	push   %eax
80109d11:	e8 b9 b1 ff ff       	call   80104ecf <memmove>
80109d16:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109d19:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d1c:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109d22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d25:	83 ec 0c             	sub    $0xc,%esp
80109d28:	50                   	push   %eax
80109d29:	e8 1c 00 00 00       	call   80109d4a <icmp_chksum>
80109d2e:	83 c4 10             	add    $0x10,%esp
80109d31:	0f b7 c0             	movzwl %ax,%eax
80109d34:	83 ec 0c             	sub    $0xc,%esp
80109d37:	50                   	push   %eax
80109d38:	e8 dc fb ff ff       	call   80109919 <H2N_ushort>
80109d3d:	83 c4 10             	add    $0x10,%esp
80109d40:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d43:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109d47:	90                   	nop
80109d48:	c9                   	leave
80109d49:	c3                   	ret

80109d4a <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109d4a:	55                   	push   %ebp
80109d4b:	89 e5                	mov    %esp,%ebp
80109d4d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109d50:	8b 45 08             	mov    0x8(%ebp),%eax
80109d53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109d56:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d5d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d64:	eb 48                	jmp    80109dae <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d69:	01 c0                	add    %eax,%eax
80109d6b:	89 c2                	mov    %eax,%edx
80109d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d70:	01 d0                	add    %edx,%eax
80109d72:	0f b6 00             	movzbl (%eax),%eax
80109d75:	0f b6 c0             	movzbl %al,%eax
80109d78:	c1 e0 08             	shl    $0x8,%eax
80109d7b:	89 c2                	mov    %eax,%edx
80109d7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d80:	01 c0                	add    %eax,%eax
80109d82:	8d 48 01             	lea    0x1(%eax),%ecx
80109d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d88:	01 c8                	add    %ecx,%eax
80109d8a:	0f b6 00             	movzbl (%eax),%eax
80109d8d:	0f b6 c0             	movzbl %al,%eax
80109d90:	01 d0                	add    %edx,%eax
80109d92:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d95:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d9c:	76 0c                	jbe    80109daa <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109da1:	0f b7 c0             	movzwl %ax,%eax
80109da4:	83 c0 01             	add    $0x1,%eax
80109da7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109daa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109dae:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109db2:	7e b2                	jle    80109d66 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109db4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109db7:	f7 d0                	not    %eax
}
80109db9:	c9                   	leave
80109dba:	c3                   	ret

80109dbb <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109dbb:	55                   	push   %ebp
80109dbc:	89 e5                	mov    %esp,%ebp
80109dbe:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc4:	83 c0 0e             	add    $0xe,%eax
80109dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dcd:	0f b6 00             	movzbl (%eax),%eax
80109dd0:	0f b6 c0             	movzbl %al,%eax
80109dd3:	83 e0 0f             	and    $0xf,%eax
80109dd6:	c1 e0 02             	shl    $0x2,%eax
80109dd9:	89 c2                	mov    %eax,%edx
80109ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dde:	01 d0                	add    %edx,%eax
80109de0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109de6:	83 c0 14             	add    $0x14,%eax
80109de9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109dec:	e8 b7 89 ff ff       	call   801027a8 <kalloc>
80109df1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109df4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dfe:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e02:	0f b6 c0             	movzbl %al,%eax
80109e05:	83 e0 02             	and    $0x2,%eax
80109e08:	85 c0                	test   %eax,%eax
80109e0a:	74 3d                	je     80109e49 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109e0c:	83 ec 0c             	sub    $0xc,%esp
80109e0f:	6a 00                	push   $0x0
80109e11:	6a 12                	push   $0x12
80109e13:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e16:	50                   	push   %eax
80109e17:	ff 75 e8             	push   -0x18(%ebp)
80109e1a:	ff 75 08             	push   0x8(%ebp)
80109e1d:	e8 a2 01 00 00       	call   80109fc4 <tcp_pkt_create>
80109e22:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109e25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e28:	83 ec 08             	sub    $0x8,%esp
80109e2b:	50                   	push   %eax
80109e2c:	ff 75 e8             	push   -0x18(%ebp)
80109e2f:	e8 79 f1 ff ff       	call   80108fad <i8254_send>
80109e34:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e37:	a1 64 7a 19 80       	mov    0x80197a64,%eax
80109e3c:	83 c0 01             	add    $0x1,%eax
80109e3f:	a3 64 7a 19 80       	mov    %eax,0x80197a64
80109e44:	e9 69 01 00 00       	jmp    80109fb2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e4c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e50:	3c 18                	cmp    $0x18,%al
80109e52:	0f 85 10 01 00 00    	jne    80109f68 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109e58:	83 ec 04             	sub    $0x4,%esp
80109e5b:	6a 03                	push   $0x3
80109e5d:	68 be c4 10 80       	push   $0x8010c4be
80109e62:	ff 75 ec             	push   -0x14(%ebp)
80109e65:	e8 0d b0 ff ff       	call   80104e77 <memcmp>
80109e6a:	83 c4 10             	add    $0x10,%esp
80109e6d:	85 c0                	test   %eax,%eax
80109e6f:	74 74                	je     80109ee5 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109e71:	83 ec 0c             	sub    $0xc,%esp
80109e74:	68 c2 c4 10 80       	push   $0x8010c4c2
80109e79:	e8 76 65 ff ff       	call   801003f4 <cprintf>
80109e7e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109e81:	83 ec 0c             	sub    $0xc,%esp
80109e84:	6a 00                	push   $0x0
80109e86:	6a 10                	push   $0x10
80109e88:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e8b:	50                   	push   %eax
80109e8c:	ff 75 e8             	push   -0x18(%ebp)
80109e8f:	ff 75 08             	push   0x8(%ebp)
80109e92:	e8 2d 01 00 00       	call   80109fc4 <tcp_pkt_create>
80109e97:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e9d:	83 ec 08             	sub    $0x8,%esp
80109ea0:	50                   	push   %eax
80109ea1:	ff 75 e8             	push   -0x18(%ebp)
80109ea4:	e8 04 f1 ff ff       	call   80108fad <i8254_send>
80109ea9:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109eac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109eaf:	83 c0 36             	add    $0x36,%eax
80109eb2:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109eb5:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109eb8:	50                   	push   %eax
80109eb9:	ff 75 e0             	push   -0x20(%ebp)
80109ebc:	6a 00                	push   $0x0
80109ebe:	6a 00                	push   $0x0
80109ec0:	e8 5a 04 00 00       	call   8010a31f <http_proc>
80109ec5:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ec8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ecb:	83 ec 0c             	sub    $0xc,%esp
80109ece:	50                   	push   %eax
80109ecf:	6a 18                	push   $0x18
80109ed1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ed4:	50                   	push   %eax
80109ed5:	ff 75 e8             	push   -0x18(%ebp)
80109ed8:	ff 75 08             	push   0x8(%ebp)
80109edb:	e8 e4 00 00 00       	call   80109fc4 <tcp_pkt_create>
80109ee0:	83 c4 20             	add    $0x20,%esp
80109ee3:	eb 62                	jmp    80109f47 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ee5:	83 ec 0c             	sub    $0xc,%esp
80109ee8:	6a 00                	push   $0x0
80109eea:	6a 10                	push   $0x10
80109eec:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eef:	50                   	push   %eax
80109ef0:	ff 75 e8             	push   -0x18(%ebp)
80109ef3:	ff 75 08             	push   0x8(%ebp)
80109ef6:	e8 c9 00 00 00       	call   80109fc4 <tcp_pkt_create>
80109efb:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109efe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f01:	83 ec 08             	sub    $0x8,%esp
80109f04:	50                   	push   %eax
80109f05:	ff 75 e8             	push   -0x18(%ebp)
80109f08:	e8 a0 f0 ff ff       	call   80108fad <i8254_send>
80109f0d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f13:	83 c0 36             	add    $0x36,%eax
80109f16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109f19:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f1c:	50                   	push   %eax
80109f1d:	ff 75 e4             	push   -0x1c(%ebp)
80109f20:	6a 00                	push   $0x0
80109f22:	6a 00                	push   $0x0
80109f24:	e8 f6 03 00 00       	call   8010a31f <http_proc>
80109f29:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109f2f:	83 ec 0c             	sub    $0xc,%esp
80109f32:	50                   	push   %eax
80109f33:	6a 18                	push   $0x18
80109f35:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f38:	50                   	push   %eax
80109f39:	ff 75 e8             	push   -0x18(%ebp)
80109f3c:	ff 75 08             	push   0x8(%ebp)
80109f3f:	e8 80 00 00 00       	call   80109fc4 <tcp_pkt_create>
80109f44:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109f47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f4a:	83 ec 08             	sub    $0x8,%esp
80109f4d:	50                   	push   %eax
80109f4e:	ff 75 e8             	push   -0x18(%ebp)
80109f51:	e8 57 f0 ff ff       	call   80108fad <i8254_send>
80109f56:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f59:	a1 64 7a 19 80       	mov    0x80197a64,%eax
80109f5e:	83 c0 01             	add    $0x1,%eax
80109f61:	a3 64 7a 19 80       	mov    %eax,0x80197a64
80109f66:	eb 4a                	jmp    80109fb2 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f6b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f6f:	3c 10                	cmp    $0x10,%al
80109f71:	75 3f                	jne    80109fb2 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109f73:	a1 68 7a 19 80       	mov    0x80197a68,%eax
80109f78:	83 f8 01             	cmp    $0x1,%eax
80109f7b:	75 35                	jne    80109fb2 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109f7d:	83 ec 0c             	sub    $0xc,%esp
80109f80:	6a 00                	push   $0x0
80109f82:	6a 01                	push   $0x1
80109f84:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f87:	50                   	push   %eax
80109f88:	ff 75 e8             	push   -0x18(%ebp)
80109f8b:	ff 75 08             	push   0x8(%ebp)
80109f8e:	e8 31 00 00 00       	call   80109fc4 <tcp_pkt_create>
80109f93:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f96:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f99:	83 ec 08             	sub    $0x8,%esp
80109f9c:	50                   	push   %eax
80109f9d:	ff 75 e8             	push   -0x18(%ebp)
80109fa0:	e8 08 f0 ff ff       	call   80108fad <i8254_send>
80109fa5:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109fa8:	c7 05 68 7a 19 80 00 	movl   $0x0,0x80197a68
80109faf:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109fb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fb5:	83 ec 0c             	sub    $0xc,%esp
80109fb8:	50                   	push   %eax
80109fb9:	e8 50 87 ff ff       	call   8010270e <kfree>
80109fbe:	83 c4 10             	add    $0x10,%esp
}
80109fc1:	90                   	nop
80109fc2:	c9                   	leave
80109fc3:	c3                   	ret

80109fc4 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109fc4:	55                   	push   %ebp
80109fc5:	89 e5                	mov    %esp,%ebp
80109fc7:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fca:	8b 45 08             	mov    0x8(%ebp),%eax
80109fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd3:	83 c0 0e             	add    $0xe,%eax
80109fd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fdc:	0f b6 00             	movzbl (%eax),%eax
80109fdf:	0f b6 c0             	movzbl %al,%eax
80109fe2:	83 e0 0f             	and    $0xf,%eax
80109fe5:	c1 e0 02             	shl    $0x2,%eax
80109fe8:	89 c2                	mov    %eax,%edx
80109fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fed:	01 d0                	add    %edx,%eax
80109fef:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ff5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ffb:	83 c0 0e             	add    $0xe,%eax
80109ffe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a001:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a004:	83 c0 14             	add    $0x14,%eax
8010a007:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a00a:	8b 45 18             	mov    0x18(%ebp),%eax
8010a00d:	8d 50 36             	lea    0x36(%eax),%edx
8010a010:	8b 45 10             	mov    0x10(%ebp),%eax
8010a013:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a015:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a018:	8d 50 06             	lea    0x6(%eax),%edx
8010a01b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a01e:	83 ec 04             	sub    $0x4,%esp
8010a021:	6a 06                	push   $0x6
8010a023:	52                   	push   %edx
8010a024:	50                   	push   %eax
8010a025:	e8 a5 ae ff ff       	call   80104ecf <memmove>
8010a02a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a02d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a030:	83 c0 06             	add    $0x6,%eax
8010a033:	83 ec 04             	sub    $0x4,%esp
8010a036:	6a 06                	push   $0x6
8010a038:	68 90 77 19 80       	push   $0x80197790
8010a03d:	50                   	push   %eax
8010a03e:	e8 8c ae ff ff       	call   80104ecf <memmove>
8010a043:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a046:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a049:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a04d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a050:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a057:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a05a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a05d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a061:	8b 45 18             	mov    0x18(%ebp),%eax
8010a064:	83 c0 28             	add    $0x28,%eax
8010a067:	0f b7 c0             	movzwl %ax,%eax
8010a06a:	83 ec 0c             	sub    $0xc,%esp
8010a06d:	50                   	push   %eax
8010a06e:	e8 a6 f8 ff ff       	call   80109919 <H2N_ushort>
8010a073:	83 c4 10             	add    $0x10,%esp
8010a076:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a079:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a07d:	0f b7 15 60 7a 19 80 	movzwl 0x80197a60,%edx
8010a084:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a087:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a08b:	0f b7 05 60 7a 19 80 	movzwl 0x80197a60,%eax
8010a092:	83 c0 01             	add    $0x1,%eax
8010a095:	66 a3 60 7a 19 80    	mov    %ax,0x80197a60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a09b:	83 ec 0c             	sub    $0xc,%esp
8010a09e:	6a 00                	push   $0x0
8010a0a0:	e8 74 f8 ff ff       	call   80109919 <H2N_ushort>
8010a0a5:	83 c4 10             	add    $0x10,%esp
8010a0a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0ab:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a0af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0b2:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a0b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0b9:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a0bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0c0:	83 c0 0c             	add    $0xc,%eax
8010a0c3:	83 ec 04             	sub    $0x4,%esp
8010a0c6:	6a 04                	push   $0x4
8010a0c8:	68 04 f5 10 80       	push   $0x8010f504
8010a0cd:	50                   	push   %eax
8010a0ce:	e8 fc ad ff ff       	call   80104ecf <memmove>
8010a0d3:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0d9:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0df:	83 c0 10             	add    $0x10,%eax
8010a0e2:	83 ec 04             	sub    $0x4,%esp
8010a0e5:	6a 04                	push   $0x4
8010a0e7:	52                   	push   %edx
8010a0e8:	50                   	push   %eax
8010a0e9:	e8 e1 ad ff ff       	call   80104ecf <memmove>
8010a0ee:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0f4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0fd:	83 ec 0c             	sub    $0xc,%esp
8010a100:	50                   	push   %eax
8010a101:	e8 08 f9 ff ff       	call   80109a0e <ipv4_chksum>
8010a106:	83 c4 10             	add    $0x10,%esp
8010a109:	0f b7 c0             	movzwl %ax,%eax
8010a10c:	83 ec 0c             	sub    $0xc,%esp
8010a10f:	50                   	push   %eax
8010a110:	e8 04 f8 ff ff       	call   80109919 <H2N_ushort>
8010a115:	83 c4 10             	add    $0x10,%esp
8010a118:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a11b:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a11f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a122:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a126:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a129:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a12c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a12f:	0f b7 10             	movzwl (%eax),%edx
8010a132:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a135:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a139:	a1 64 7a 19 80       	mov    0x80197a64,%eax
8010a13e:	83 ec 0c             	sub    $0xc,%esp
8010a141:	50                   	push   %eax
8010a142:	e8 e9 f7 ff ff       	call   80109930 <H2N_uint>
8010a147:	83 c4 10             	add    $0x10,%esp
8010a14a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a14d:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a150:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a153:	8b 40 04             	mov    0x4(%eax),%eax
8010a156:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a15c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a15f:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a162:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a165:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a169:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a16c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a170:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a173:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a177:	8b 45 14             	mov    0x14(%ebp),%eax
8010a17a:	89 c2                	mov    %eax,%edx
8010a17c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a17f:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a182:	83 ec 0c             	sub    $0xc,%esp
8010a185:	68 90 38 00 00       	push   $0x3890
8010a18a:	e8 8a f7 ff ff       	call   80109919 <H2N_ushort>
8010a18f:	83 c4 10             	add    $0x10,%esp
8010a192:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a195:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a199:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a19c:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a1a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1a5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a1ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1ae:	83 ec 0c             	sub    $0xc,%esp
8010a1b1:	50                   	push   %eax
8010a1b2:	e8 1f 00 00 00       	call   8010a1d6 <tcp_chksum>
8010a1b7:	83 c4 10             	add    $0x10,%esp
8010a1ba:	83 c0 08             	add    $0x8,%eax
8010a1bd:	0f b7 c0             	movzwl %ax,%eax
8010a1c0:	83 ec 0c             	sub    $0xc,%esp
8010a1c3:	50                   	push   %eax
8010a1c4:	e8 50 f7 ff ff       	call   80109919 <H2N_ushort>
8010a1c9:	83 c4 10             	add    $0x10,%esp
8010a1cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1cf:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a1d3:	90                   	nop
8010a1d4:	c9                   	leave
8010a1d5:	c3                   	ret

8010a1d6 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a1d6:	55                   	push   %ebp
8010a1d7:	89 e5                	mov    %esp,%ebp
8010a1d9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a1dc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a1e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1e5:	83 c0 14             	add    $0x14,%eax
8010a1e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a1eb:	83 ec 04             	sub    $0x4,%esp
8010a1ee:	6a 04                	push   $0x4
8010a1f0:	68 04 f5 10 80       	push   $0x8010f504
8010a1f5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a1f8:	50                   	push   %eax
8010a1f9:	e8 d1 ac ff ff       	call   80104ecf <memmove>
8010a1fe:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a201:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a204:	83 c0 0c             	add    $0xc,%eax
8010a207:	83 ec 04             	sub    $0x4,%esp
8010a20a:	6a 04                	push   $0x4
8010a20c:	50                   	push   %eax
8010a20d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a210:	83 c0 04             	add    $0x4,%eax
8010a213:	50                   	push   %eax
8010a214:	e8 b6 ac ff ff       	call   80104ecf <memmove>
8010a219:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a21c:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a220:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a224:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a227:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a22b:	0f b7 c0             	movzwl %ax,%eax
8010a22e:	83 ec 0c             	sub    $0xc,%esp
8010a231:	50                   	push   %eax
8010a232:	e8 cb f6 ff ff       	call   80109902 <N2H_ushort>
8010a237:	83 c4 10             	add    $0x10,%esp
8010a23a:	83 e8 14             	sub    $0x14,%eax
8010a23d:	0f b7 c0             	movzwl %ax,%eax
8010a240:	83 ec 0c             	sub    $0xc,%esp
8010a243:	50                   	push   %eax
8010a244:	e8 d0 f6 ff ff       	call   80109919 <H2N_ushort>
8010a249:	83 c4 10             	add    $0x10,%esp
8010a24c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a250:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a257:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a25a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a25d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a264:	eb 33                	jmp    8010a299 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a266:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a269:	01 c0                	add    %eax,%eax
8010a26b:	89 c2                	mov    %eax,%edx
8010a26d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a270:	01 d0                	add    %edx,%eax
8010a272:	0f b6 00             	movzbl (%eax),%eax
8010a275:	0f b6 c0             	movzbl %al,%eax
8010a278:	c1 e0 08             	shl    $0x8,%eax
8010a27b:	89 c2                	mov    %eax,%edx
8010a27d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a280:	01 c0                	add    %eax,%eax
8010a282:	8d 48 01             	lea    0x1(%eax),%ecx
8010a285:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a288:	01 c8                	add    %ecx,%eax
8010a28a:	0f b6 00             	movzbl (%eax),%eax
8010a28d:	0f b6 c0             	movzbl %al,%eax
8010a290:	01 d0                	add    %edx,%eax
8010a292:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a295:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a299:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a29d:	7e c7                	jle    8010a266 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a29f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2a5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a2ac:	eb 33                	jmp    8010a2e1 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a2ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2b1:	01 c0                	add    %eax,%eax
8010a2b3:	89 c2                	mov    %eax,%edx
8010a2b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2b8:	01 d0                	add    %edx,%eax
8010a2ba:	0f b6 00             	movzbl (%eax),%eax
8010a2bd:	0f b6 c0             	movzbl %al,%eax
8010a2c0:	c1 e0 08             	shl    $0x8,%eax
8010a2c3:	89 c2                	mov    %eax,%edx
8010a2c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2c8:	01 c0                	add    %eax,%eax
8010a2ca:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2d0:	01 c8                	add    %ecx,%eax
8010a2d2:	0f b6 00             	movzbl (%eax),%eax
8010a2d5:	0f b6 c0             	movzbl %al,%eax
8010a2d8:	01 d0                	add    %edx,%eax
8010a2da:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2dd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a2e1:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a2e5:	0f b7 c0             	movzwl %ax,%eax
8010a2e8:	83 ec 0c             	sub    $0xc,%esp
8010a2eb:	50                   	push   %eax
8010a2ec:	e8 11 f6 ff ff       	call   80109902 <N2H_ushort>
8010a2f1:	83 c4 10             	add    $0x10,%esp
8010a2f4:	66 d1 e8             	shr    $1,%ax
8010a2f7:	0f b7 c0             	movzwl %ax,%eax
8010a2fa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a2fd:	7c af                	jl     8010a2ae <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a2ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a302:	c1 e8 10             	shr    $0x10,%eax
8010a305:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a30b:	f7 d0                	not    %eax
}
8010a30d:	c9                   	leave
8010a30e:	c3                   	ret

8010a30f <tcp_fin>:

void tcp_fin(){
8010a30f:	55                   	push   %ebp
8010a310:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a312:	c7 05 68 7a 19 80 01 	movl   $0x1,0x80197a68
8010a319:	00 00 00 
}
8010a31c:	90                   	nop
8010a31d:	5d                   	pop    %ebp
8010a31e:	c3                   	ret

8010a31f <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a31f:	55                   	push   %ebp
8010a320:	89 e5                	mov    %esp,%ebp
8010a322:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a325:	8b 45 10             	mov    0x10(%ebp),%eax
8010a328:	83 ec 04             	sub    $0x4,%esp
8010a32b:	6a 00                	push   $0x0
8010a32d:	68 cb c4 10 80       	push   $0x8010c4cb
8010a332:	50                   	push   %eax
8010a333:	e8 65 00 00 00       	call   8010a39d <http_strcpy>
8010a338:	83 c4 10             	add    $0x10,%esp
8010a33b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a33e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a341:	83 ec 04             	sub    $0x4,%esp
8010a344:	ff 75 f4             	push   -0xc(%ebp)
8010a347:	68 de c4 10 80       	push   $0x8010c4de
8010a34c:	50                   	push   %eax
8010a34d:	e8 4b 00 00 00       	call   8010a39d <http_strcpy>
8010a352:	83 c4 10             	add    $0x10,%esp
8010a355:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a358:	8b 45 10             	mov    0x10(%ebp),%eax
8010a35b:	83 ec 04             	sub    $0x4,%esp
8010a35e:	ff 75 f4             	push   -0xc(%ebp)
8010a361:	68 f9 c4 10 80       	push   $0x8010c4f9
8010a366:	50                   	push   %eax
8010a367:	e8 31 00 00 00       	call   8010a39d <http_strcpy>
8010a36c:	83 c4 10             	add    $0x10,%esp
8010a36f:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a372:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a375:	83 e0 01             	and    $0x1,%eax
8010a378:	85 c0                	test   %eax,%eax
8010a37a:	74 11                	je     8010a38d <http_proc+0x6e>
    char *payload = (char *)send;
8010a37c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a37f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a382:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a385:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a388:	01 d0                	add    %edx,%eax
8010a38a:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a38d:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a390:	8b 45 14             	mov    0x14(%ebp),%eax
8010a393:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a395:	e8 75 ff ff ff       	call   8010a30f <tcp_fin>
}
8010a39a:	90                   	nop
8010a39b:	c9                   	leave
8010a39c:	c3                   	ret

8010a39d <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a39d:	55                   	push   %ebp
8010a39e:	89 e5                	mov    %esp,%ebp
8010a3a0:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a3a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a3aa:	eb 20                	jmp    8010a3cc <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a3ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3af:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3b2:	01 d0                	add    %edx,%eax
8010a3b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a3b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3ba:	01 ca                	add    %ecx,%edx
8010a3bc:	89 d1                	mov    %edx,%ecx
8010a3be:	8b 55 08             	mov    0x8(%ebp),%edx
8010a3c1:	01 ca                	add    %ecx,%edx
8010a3c3:	0f b6 00             	movzbl (%eax),%eax
8010a3c6:	88 02                	mov    %al,(%edx)
    i++;
8010a3c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a3cc:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3cf:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3d2:	01 d0                	add    %edx,%eax
8010a3d4:	0f b6 00             	movzbl (%eax),%eax
8010a3d7:	84 c0                	test   %al,%al
8010a3d9:	75 d1                	jne    8010a3ac <http_strcpy+0xf>
  }
  return i;
8010a3db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a3de:	c9                   	leave
8010a3df:	c3                   	ret

8010a3e0 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a3e0:	55                   	push   %ebp
8010a3e1:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a3e3:	c7 05 70 7a 19 80 c2 	movl   $0x8010f5c2,0x80197a70
8010a3ea:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a3ed:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a3f2:	c1 e8 09             	shr    $0x9,%eax
8010a3f5:	a3 6c 7a 19 80       	mov    %eax,0x80197a6c
}
8010a3fa:	90                   	nop
8010a3fb:	5d                   	pop    %ebp
8010a3fc:	c3                   	ret

8010a3fd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a3fd:	55                   	push   %ebp
8010a3fe:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a400:	90                   	nop
8010a401:	5d                   	pop    %ebp
8010a402:	c3                   	ret

8010a403 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a403:	55                   	push   %ebp
8010a404:	89 e5                	mov    %esp,%ebp
8010a406:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a409:	8b 45 08             	mov    0x8(%ebp),%eax
8010a40c:	83 c0 0c             	add    $0xc,%eax
8010a40f:	83 ec 0c             	sub    $0xc,%esp
8010a412:	50                   	push   %eax
8010a413:	e8 f1 a6 ff ff       	call   80104b09 <holdingsleep>
8010a418:	83 c4 10             	add    $0x10,%esp
8010a41b:	85 c0                	test   %eax,%eax
8010a41d:	75 0d                	jne    8010a42c <iderw+0x29>
    panic("iderw: buf not locked");
8010a41f:	83 ec 0c             	sub    $0xc,%esp
8010a422:	68 0a c5 10 80       	push   $0x8010c50a
8010a427:	e8 7d 61 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a42c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a42f:	8b 00                	mov    (%eax),%eax
8010a431:	83 e0 06             	and    $0x6,%eax
8010a434:	83 f8 02             	cmp    $0x2,%eax
8010a437:	75 0d                	jne    8010a446 <iderw+0x43>
    panic("iderw: nothing to do");
8010a439:	83 ec 0c             	sub    $0xc,%esp
8010a43c:	68 20 c5 10 80       	push   $0x8010c520
8010a441:	e8 63 61 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a446:	8b 45 08             	mov    0x8(%ebp),%eax
8010a449:	8b 40 04             	mov    0x4(%eax),%eax
8010a44c:	83 f8 01             	cmp    $0x1,%eax
8010a44f:	74 0d                	je     8010a45e <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a451:	83 ec 0c             	sub    $0xc,%esp
8010a454:	68 35 c5 10 80       	push   $0x8010c535
8010a459:	e8 4b 61 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a45e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a461:	8b 40 08             	mov    0x8(%eax),%eax
8010a464:	8b 15 6c 7a 19 80    	mov    0x80197a6c,%edx
8010a46a:	39 d0                	cmp    %edx,%eax
8010a46c:	72 0d                	jb     8010a47b <iderw+0x78>
    panic("iderw: block out of range");
8010a46e:	83 ec 0c             	sub    $0xc,%esp
8010a471:	68 53 c5 10 80       	push   $0x8010c553
8010a476:	e8 2e 61 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a47b:	8b 15 70 7a 19 80    	mov    0x80197a70,%edx
8010a481:	8b 45 08             	mov    0x8(%ebp),%eax
8010a484:	8b 40 08             	mov    0x8(%eax),%eax
8010a487:	c1 e0 09             	shl    $0x9,%eax
8010a48a:	01 d0                	add    %edx,%eax
8010a48c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a48f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a492:	8b 00                	mov    (%eax),%eax
8010a494:	83 e0 04             	and    $0x4,%eax
8010a497:	85 c0                	test   %eax,%eax
8010a499:	74 2b                	je     8010a4c6 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a49b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a49e:	8b 00                	mov    (%eax),%eax
8010a4a0:	83 e0 fb             	and    $0xfffffffb,%eax
8010a4a3:	89 c2                	mov    %eax,%edx
8010a4a5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4a8:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a4aa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ad:	83 c0 5c             	add    $0x5c,%eax
8010a4b0:	83 ec 04             	sub    $0x4,%esp
8010a4b3:	68 00 02 00 00       	push   $0x200
8010a4b8:	50                   	push   %eax
8010a4b9:	ff 75 f4             	push   -0xc(%ebp)
8010a4bc:	e8 0e aa ff ff       	call   80104ecf <memmove>
8010a4c1:	83 c4 10             	add    $0x10,%esp
8010a4c4:	eb 1a                	jmp    8010a4e0 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a4c6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4c9:	83 c0 5c             	add    $0x5c,%eax
8010a4cc:	83 ec 04             	sub    $0x4,%esp
8010a4cf:	68 00 02 00 00       	push   $0x200
8010a4d4:	ff 75 f4             	push   -0xc(%ebp)
8010a4d7:	50                   	push   %eax
8010a4d8:	e8 f2 a9 ff ff       	call   80104ecf <memmove>
8010a4dd:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a4e0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4e3:	8b 00                	mov    (%eax),%eax
8010a4e5:	83 c8 02             	or     $0x2,%eax
8010a4e8:	89 c2                	mov    %eax,%edx
8010a4ea:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ed:	89 10                	mov    %edx,(%eax)
}
8010a4ef:	90                   	nop
8010a4f0:	c9                   	leave
8010a4f1:	c3                   	ret
