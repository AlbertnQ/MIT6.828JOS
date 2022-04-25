
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 17 1a 00 00       	call   801a48 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 40 38 80 00       	push   $0x803840
  8000b7:	e8 c5 1a 00 00       	call   801b81 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 57 38 80 00       	push   $0x803857
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 67 38 80 00       	push   $0x803867
  8000e0:	e8 c3 19 00 00       	call   801aa8 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 70 38 80 00       	push   $0x803870
  80010b:	68 7d 38 80 00       	push   $0x80387d
  800110:	6a 44                	push   $0x44
  800112:	68 67 38 80 00       	push   $0x803867
  800117:	e8 8c 19 00 00       	call   801aa8 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 70 38 80 00       	push   $0x803870
  8001cf:	68 7d 38 80 00       	push   $0x80387d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 67 38 80 00       	push   $0x803867
  8001db:	e8 c8 18 00 00       	call   801aa8 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 94 38 80 00       	push   $0x803894
  80029f:	6a 27                	push   $0x27
  8002a1:	68 98 39 80 00       	push   $0x803998
  8002a6:	e8 fd 17 00 00       	call   801aa8 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 c4 38 80 00       	push   $0x8038c4
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 98 39 80 00       	push   $0x803998
  8002c6:	e8 dd 17 00 00       	call   801aa8 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
    addr =(void *) ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ( (r = sys_page_alloc(0, addr, PTE_P|PTE_W|PTE_U)) < 0) {
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 49 22 00 00       	call   802527 <sys_page_alloc>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
        panic("in bc_pgfault, sys_page_alloc: %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 e8 38 80 00       	push   $0x8038e8
  8002eb:	6a 35                	push   $0x35
  8002ed:	68 98 39 80 00       	push   $0x803998
  8002f2:	e8 b1 17 00 00       	call   801aa8 <_panic>
    }
    if ( (r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0) {
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	6a 08                	push   $0x8
  8002fc:	53                   	push   %ebx
  8002fd:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800304:	50                   	push   %eax
  800305:	e8 e2 fd ff ff       	call   8000ec <ide_read>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 12                	jns    800323 <bc_pgfault+0xaf>
        panic("in bc_pgfault, ide_read: %e",r);
  800311:	50                   	push   %eax
  800312:	68 a0 39 80 00       	push   $0x8039a0
  800317:	6a 38                	push   $0x38
  800319:	68 98 39 80 00       	push   $0x803998
  80031e:	e8 85 17 00 00       	call   801aa8 <_panic>
    }
    
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800323:	89 d8                	mov    %ebx,%eax
  800325:	c1 e8 0c             	shr    $0xc,%eax
  800328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	25 07 0e 00 00       	and    $0xe07,%eax
  800337:	50                   	push   %eax
  800338:	53                   	push   %ebx
  800339:	6a 00                	push   $0x0
  80033b:	53                   	push   %ebx
  80033c:	6a 00                	push   $0x0
  80033e:	e8 27 22 00 00       	call   80256a <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 0c 39 80 00       	push   $0x80390c
  800350:	6a 3e                	push   $0x3e
  800352:	68 98 39 80 00       	push   $0x803998
  800357:	e8 4c 17 00 00       	call   801aa8 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80035c:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800363:	74 22                	je     800387 <bc_pgfault+0x113>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	56                   	push   %esi
  800369:	e8 74 04 00 00       	call   8007e2 <block_is_free>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	84 c0                	test   %al,%al
  800373:	74 12                	je     800387 <bc_pgfault+0x113>
		panic("reading free block %08x\n", blockno);
  800375:	56                   	push   %esi
  800376:	68 bc 39 80 00       	push   $0x8039bc
  80037b:	6a 44                	push   $0x44
  80037d:	68 98 39 80 00       	push   $0x803998
  800382:	e8 21 17 00 00       	call   801aa8 <_panic>
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800397:	85 c0                	test   %eax,%eax
  800399:	74 0f                	je     8003aa <diskaddr+0x1c>
  80039b:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 17                	je     8003bc <diskaddr+0x2e>
  8003a5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a8:	72 12                	jb     8003bc <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003aa:	50                   	push   %eax
  8003ab:	68 2c 39 80 00       	push   $0x80392c
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 98 39 80 00       	push   $0x803998
  8003b7:	e8 ec 16 00 00       	call   801aa8 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bc:	05 00 00 01 00       	add    $0x10000,%eax
  8003c1:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cc:	89 d0                	mov    %edx,%eax
  8003ce:	c1 e8 16             	shr    $0x16,%eax
  8003d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	f6 c1 01             	test   $0x1,%cl
  8003e0:	74 0d                	je     8003ef <va_is_mapped+0x29>
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003ec:	83 e0 01             	and    $0x1,%eax
  8003ef:	83 e0 01             	and    $0x1,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	c1 e8 06             	shr    $0x6,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80041f:	76 12                	jbe    800433 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800421:	53                   	push   %ebx
  800422:	68 d5 39 80 00       	push   $0x8039d5
  800427:	6a 54                	push   $0x54
  800429:	68 98 39 80 00       	push   $0x803998
  80042e:	e8 75 16 00 00       	call   801aa8 <_panic>

	// LAB 5: Your code here.
	//panic("flush_block not implemented");
    addr = (void *)ROUNDDOWN(addr, PGSIZE);
  800433:	89 de                	mov    %ebx,%esi
  800435:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (va_is_mapped(addr) && va_is_dirty(addr)) {
  80043b:	83 ec 0c             	sub    $0xc,%esp
  80043e:	56                   	push   %esi
  80043f:	e8 82 ff ff ff       	call   8003c6 <va_is_mapped>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	84 c0                	test   %al,%al
  800449:	74 60                	je     8004ab <flush_block+0x9f>
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	56                   	push   %esi
  80044f:	e8 a0 ff ff ff       	call   8003f4 <va_is_dirty>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	84 c0                	test   %al,%al
  800459:	74 50                	je     8004ab <flush_block+0x9f>
        
        ide_write(blockno*BLKSECTS, addr , BLKSECTS);
  80045b:	83 ec 04             	sub    $0x4,%esp
  80045e:	6a 08                	push   $0x8
  800460:	56                   	push   %esi
  800461:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800467:	c1 eb 0c             	shr    $0xc,%ebx
  80046a:	c1 e3 03             	shl    $0x3,%ebx
  80046d:	53                   	push   %ebx
  80046e:	e8 3d fd ff ff       	call   8001b0 <ide_write>
        int r;
        if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800473:	89 f0                	mov    %esi,%eax
  800475:	c1 e8 0c             	shr    $0xc,%eax
  800478:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80047f:	25 07 0e 00 00       	and    $0xe07,%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	56                   	push   %esi
  800488:	6a 00                	push   $0x0
  80048a:	56                   	push   %esi
  80048b:	6a 00                	push   $0x0
  80048d:	e8 d8 20 00 00       	call   80256a <sys_page_map>
  800492:	83 c4 20             	add    $0x20,%esp
  800495:	85 c0                	test   %eax,%eax
  800497:	79 12                	jns    8004ab <flush_block+0x9f>
            panic("in flush_block, sys_page_map: %e", r);
  800499:	50                   	push   %eax
  80049a:	68 50 39 80 00       	push   $0x803950
  80049f:	6a 5e                	push   $0x5e
  8004a1:	68 98 39 80 00       	push   $0x803998
  8004a6:	e8 fd 15 00 00       	call   801aa8 <_panic>
    }
}
  8004ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ae:	5b                   	pop    %ebx
  8004af:	5e                   	pop    %esi
  8004b0:	5d                   	pop    %ebp
  8004b1:	c3                   	ret    

008004b2 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	53                   	push   %ebx
  8004b6:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004bc:	68 74 02 80 00       	push   $0x800274
  8004c1:	e8 52 22 00 00       	call   802718 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004cd:	e8 bc fe ff ff       	call   80038e <diskaddr>
  8004d2:	83 c4 0c             	add    $0xc,%esp
  8004d5:	68 08 01 00 00       	push   $0x108
  8004da:	50                   	push   %eax
  8004db:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004e1:	50                   	push   %eax
  8004e2:	e8 cf 1d 00 00       	call   8022b6 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ee:	e8 9b fe ff ff       	call   80038e <diskaddr>
  8004f3:	83 c4 08             	add    $0x8,%esp
  8004f6:	68 f0 39 80 00       	push   $0x8039f0
  8004fb:	50                   	push   %eax
  8004fc:	e8 23 1c 00 00       	call   802124 <strcpy>
	flush_block(diskaddr(1));
  800501:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800508:	e8 81 fe ff ff       	call   80038e <diskaddr>
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	e8 f7 fe ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800515:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051c:	e8 6d fe ff ff       	call   80038e <diskaddr>
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	e8 9d fe ff ff       	call   8003c6 <va_is_mapped>
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	84 c0                	test   %al,%al
  80052e:	75 16                	jne    800546 <bc_init+0x94>
  800530:	68 12 3a 80 00       	push   $0x803a12
  800535:	68 7d 38 80 00       	push   $0x80387d
  80053a:	6a 6f                	push   $0x6f
  80053c:	68 98 39 80 00       	push   $0x803998
  800541:	e8 62 15 00 00       	call   801aa8 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800546:	83 ec 0c             	sub    $0xc,%esp
  800549:	6a 01                	push   $0x1
  80054b:	e8 3e fe ff ff       	call   80038e <diskaddr>
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 9c fe ff ff       	call   8003f4 <va_is_dirty>
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	84 c0                	test   %al,%al
  80055d:	74 16                	je     800575 <bc_init+0xc3>
  80055f:	68 f7 39 80 00       	push   $0x8039f7
  800564:	68 7d 38 80 00       	push   $0x80387d
  800569:	6a 70                	push   $0x70
  80056b:	68 98 39 80 00       	push   $0x803998
  800570:	e8 33 15 00 00       	call   801aa8 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800575:	83 ec 0c             	sub    $0xc,%esp
  800578:	6a 01                	push   $0x1
  80057a:	e8 0f fe ff ff       	call   80038e <diskaddr>
  80057f:	83 c4 08             	add    $0x8,%esp
  800582:	50                   	push   %eax
  800583:	6a 00                	push   $0x0
  800585:	e8 22 20 00 00       	call   8025ac <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80058a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800591:	e8 f8 fd ff ff       	call   80038e <diskaddr>
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	e8 28 fe ff ff       	call   8003c6 <va_is_mapped>
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	84 c0                	test   %al,%al
  8005a3:	74 16                	je     8005bb <bc_init+0x109>
  8005a5:	68 11 3a 80 00       	push   $0x803a11
  8005aa:	68 7d 38 80 00       	push   $0x80387d
  8005af:	6a 74                	push   $0x74
  8005b1:	68 98 39 80 00       	push   $0x803998
  8005b6:	e8 ed 14 00 00       	call   801aa8 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005bb:	83 ec 0c             	sub    $0xc,%esp
  8005be:	6a 01                	push   $0x1
  8005c0:	e8 c9 fd ff ff       	call   80038e <diskaddr>
  8005c5:	83 c4 08             	add    $0x8,%esp
  8005c8:	68 f0 39 80 00       	push   $0x8039f0
  8005cd:	50                   	push   %eax
  8005ce:	e8 fb 1b 00 00       	call   8021ce <strcmp>
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	74 16                	je     8005f0 <bc_init+0x13e>
  8005da:	68 74 39 80 00       	push   $0x803974
  8005df:	68 7d 38 80 00       	push   $0x80387d
  8005e4:	6a 77                	push   $0x77
  8005e6:	68 98 39 80 00       	push   $0x803998
  8005eb:	e8 b8 14 00 00       	call   801aa8 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	6a 01                	push   $0x1
  8005f5:	e8 94 fd ff ff       	call   80038e <diskaddr>
  8005fa:	83 c4 0c             	add    $0xc,%esp
  8005fd:	68 08 01 00 00       	push   $0x108
  800602:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800608:	53                   	push   %ebx
  800609:	50                   	push   %eax
  80060a:	e8 a7 1c 00 00       	call   8022b6 <memmove>
	flush_block(diskaddr(1));
  80060f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800616:	e8 73 fd ff ff       	call   80038e <diskaddr>
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	e8 e9 fd ff ff       	call   80040c <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800623:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062a:	e8 5f fd ff ff       	call   80038e <diskaddr>
  80062f:	83 c4 0c             	add    $0xc,%esp
  800632:	68 08 01 00 00       	push   $0x108
  800637:	50                   	push   %eax
  800638:	53                   	push   %ebx
  800639:	e8 78 1c 00 00       	call   8022b6 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80063e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800645:	e8 44 fd ff ff       	call   80038e <diskaddr>
  80064a:	83 c4 08             	add    $0x8,%esp
  80064d:	68 f0 39 80 00       	push   $0x8039f0
  800652:	50                   	push   %eax
  800653:	e8 cc 1a 00 00       	call   802124 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800658:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80065f:	e8 2a fd ff ff       	call   80038e <diskaddr>
  800664:	83 c0 14             	add    $0x14,%eax
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	e8 9d fd ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80066f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800676:	e8 13 fd ff ff       	call   80038e <diskaddr>
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	e8 43 fd ff ff       	call   8003c6 <va_is_mapped>
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	84 c0                	test   %al,%al
  800688:	75 19                	jne    8006a3 <bc_init+0x1f1>
  80068a:	68 12 3a 80 00       	push   $0x803a12
  80068f:	68 7d 38 80 00       	push   $0x80387d
  800694:	68 88 00 00 00       	push   $0x88
  800699:	68 98 39 80 00       	push   $0x803998
  80069e:	e8 05 14 00 00       	call   801aa8 <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8006a3:	83 ec 0c             	sub    $0xc,%esp
  8006a6:	6a 01                	push   $0x1
  8006a8:	e8 e1 fc ff ff       	call   80038e <diskaddr>
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	50                   	push   %eax
  8006b1:	6a 00                	push   $0x0
  8006b3:	e8 f4 1e 00 00       	call   8025ac <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006bf:	e8 ca fc ff ff       	call   80038e <diskaddr>
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	e8 fa fc ff ff       	call   8003c6 <va_is_mapped>
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	84 c0                	test   %al,%al
  8006d1:	74 19                	je     8006ec <bc_init+0x23a>
  8006d3:	68 11 3a 80 00       	push   $0x803a11
  8006d8:	68 7d 38 80 00       	push   $0x80387d
  8006dd:	68 90 00 00 00       	push   $0x90
  8006e2:	68 98 39 80 00       	push   $0x803998
  8006e7:	e8 bc 13 00 00       	call   801aa8 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006ec:	83 ec 0c             	sub    $0xc,%esp
  8006ef:	6a 01                	push   $0x1
  8006f1:	e8 98 fc ff ff       	call   80038e <diskaddr>
  8006f6:	83 c4 08             	add    $0x8,%esp
  8006f9:	68 f0 39 80 00       	push   $0x8039f0
  8006fe:	50                   	push   %eax
  8006ff:	e8 ca 1a 00 00       	call   8021ce <strcmp>
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	85 c0                	test   %eax,%eax
  800709:	74 19                	je     800724 <bc_init+0x272>
  80070b:	68 74 39 80 00       	push   $0x803974
  800710:	68 7d 38 80 00       	push   $0x80387d
  800715:	68 93 00 00 00       	push   $0x93
  80071a:	68 98 39 80 00       	push   $0x803998
  80071f:	e8 84 13 00 00       	call   801aa8 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	6a 01                	push   $0x1
  800729:	e8 60 fc ff ff       	call   80038e <diskaddr>
  80072e:	83 c4 0c             	add    $0xc,%esp
  800731:	68 08 01 00 00       	push   $0x108
  800736:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80073c:	52                   	push   %edx
  80073d:	50                   	push   %eax
  80073e:	e8 73 1b 00 00       	call   8022b6 <memmove>
	flush_block(diskaddr(1));
  800743:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80074a:	e8 3f fc ff ff       	call   80038e <diskaddr>
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	e8 b5 fc ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800757:	c7 04 24 2c 3a 80 00 	movl   $0x803a2c,(%esp)
  80075e:	e8 1e 14 00 00       	call   801b81 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800763:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80076a:	e8 1f fc ff ff       	call   80038e <diskaddr>
  80076f:	83 c4 0c             	add    $0xc,%esp
  800772:	68 08 01 00 00       	push   $0x108
  800777:	50                   	push   %eax
  800778:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	e8 32 1b 00 00       	call   8022b6 <memmove>
}
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800792:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800797:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80079d:	74 14                	je     8007b3 <check_super+0x27>
		panic("bad file system magic number");
  80079f:	83 ec 04             	sub    $0x4,%esp
  8007a2:	68 41 3a 80 00       	push   $0x803a41
  8007a7:	6a 0f                	push   $0xf
  8007a9:	68 5e 3a 80 00       	push   $0x803a5e
  8007ae:	e8 f5 12 00 00       	call   801aa8 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007b3:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007ba:	76 14                	jbe    8007d0 <check_super+0x44>
		panic("file system is too large");
  8007bc:	83 ec 04             	sub    $0x4,%esp
  8007bf:	68 66 3a 80 00       	push   $0x803a66
  8007c4:	6a 12                	push   $0x12
  8007c6:	68 5e 3a 80 00       	push   $0x803a5e
  8007cb:	e8 d8 12 00 00       	call   801aa8 <_panic>

	cprintf("superblock is good\n");
  8007d0:	83 ec 0c             	sub    $0xc,%esp
  8007d3:	68 7f 3a 80 00       	push   $0x803a7f
  8007d8:	e8 a4 13 00 00       	call   801b81 <cprintf>
}
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8007e9:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8007ef:	85 d2                	test   %edx,%edx
  8007f1:	74 24                	je     800817 <block_is_free+0x35>
		return 0;
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8007f8:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8007fb:	76 1f                	jbe    80081c <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	c1 eb 05             	shr    $0x5,%ebx
  800802:	b8 01 00 00 00       	mov    $0x1,%eax
  800807:	d3 e0                	shl    %cl,%eax
  800809:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80080f:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800812:	0f 95 c0             	setne  %al
  800815:	eb 05                	jmp    80081c <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80081c:	5b                   	pop    %ebx
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800829:	85 c9                	test   %ecx,%ecx
  80082b:	75 14                	jne    800841 <free_block+0x22>
		panic("attempt to free zero block");
  80082d:	83 ec 04             	sub    $0x4,%esp
  800830:	68 93 3a 80 00       	push   $0x803a93
  800835:	6a 2d                	push   $0x2d
  800837:	68 5e 3a 80 00       	push   $0x803a5e
  80083c:	e8 67 12 00 00       	call   801aa8 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800841:	89 cb                	mov    %ecx,%ebx
  800843:	c1 eb 05             	shr    $0x5,%ebx
  800846:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80084c:	b8 01 00 00 00       	mov    $0x1,%eax
  800851:	d3 e0                	shl    %cl,%eax
  800853:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
    size_t i;
    for(i=1; i < super->s_nblocks; i++) {
  800860:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800865:	8b 70 04             	mov    0x4(%eax),%esi
  800868:	bb 01 00 00 00       	mov    $0x1,%ebx
  80086d:	eb 43                	jmp    8008b2 <alloc_block+0x57>
        if (block_is_free(i)) {
  80086f:	53                   	push   %ebx
  800870:	e8 6d ff ff ff       	call   8007e2 <block_is_free>
  800875:	83 c4 04             	add    $0x4,%esp
  800878:	84 c0                	test   %al,%al
  80087a:	74 33                	je     8008af <alloc_block+0x54>
          // 清零，标记已经使用。有点令人费解
            bitmap[i/32] &=  ~(1<<(i%32));
  80087c:	89 d8                	mov    %ebx,%eax
  80087e:	c1 e8 05             	shr    $0x5,%eax
  800881:	c1 e0 02             	shl    $0x2,%eax
  800884:	89 c6                	mov    %eax,%esi
  800886:	03 35 04 a0 80 00    	add    0x80a004,%esi
  80088c:	ba 01 00 00 00       	mov    $0x1,%edx
  800891:	89 d9                	mov    %ebx,%ecx
  800893:	d3 e2                	shl    %cl,%edx
  800895:	f7 d2                	not    %edx
  800897:	21 16                	and    %edx,(%esi)
            flush_block(&bitmap[i/32]);
  800899:	83 ec 0c             	sub    $0xc,%esp
  80089c:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8008a2:	50                   	push   %eax
  8008a3:	e8 64 fb ff ff       	call   80040c <flush_block>
            return i;
  8008a8:	89 d8                	mov    %ebx,%eax
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	eb 0c                	jmp    8008bb <alloc_block+0x60>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
    size_t i;
    for(i=1; i < super->s_nblocks; i++) {
  8008af:	83 c3 01             	add    $0x1,%ebx
  8008b2:	39 f3                	cmp    %esi,%ebx
  8008b4:	72 b9                	jb     80086f <alloc_block+0x14>
            bitmap[i/32] &=  ~(1<<(i%32));
            flush_block(&bitmap[i/32]);
            return i;
        }
    }
	return -E_NO_DISK;
  8008b6:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	83 ec 1c             	sub    $0x1c,%esp
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
       if (filebno >= NDIRECT + NINDIRECT)
  8008ce:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8008d4:	77 79                	ja     80094f <file_block_walk+0x8d>
                       return -E_INVAL;
    
       if (filebno < NDIRECT) {
  8008d6:	83 fa 09             	cmp    $0x9,%edx
  8008d9:	77 10                	ja     8008eb <file_block_walk+0x29>
               *ppdiskbno = f->f_direct + filebno;
  8008db:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8008e2:	89 01                	mov    %eax,(%ecx)
                               return -E_NOT_FOUND;
                       }
               }
               *ppdiskbno = (uint32_t *)diskaddr(f->f_indirect) + (filebno-NDIRECT);
       }
       return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	eb 77                	jmp    800962 <file_block_walk+0xa0>
  8008eb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8008ee:	89 d3                	mov    %edx,%ebx
  8008f0:	89 c6                	mov    %eax,%esi
                       return -E_INVAL;
    
       if (filebno < NDIRECT) {
               *ppdiskbno = f->f_direct + filebno;
       } else {
               if (!f->f_indirect) {
  8008f2:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  8008f9:	75 33                	jne    80092e <file_block_walk+0x6c>
                       if (alloc) {
  8008fb:	89 f8                	mov    %edi,%eax
  8008fd:	84 c0                	test   %al,%al
  8008ff:	74 55                	je     800956 <file_block_walk+0x94>
                               int blockno = alloc_block();
  800901:	e8 55 ff ff ff       	call   80085b <alloc_block>
  800906:	89 c7                	mov    %eax,%edi
                               if (blockno < 0)
  800908:	85 c0                	test   %eax,%eax
  80090a:	78 51                	js     80095d <file_block_walk+0x9b>
                                       return -E_NO_DISK;

                               memset(diskaddr(blockno), 0, BLKSIZE);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	50                   	push   %eax
  800910:	e8 79 fa ff ff       	call   80038e <diskaddr>
  800915:	83 c4 0c             	add    $0xc,%esp
  800918:	68 00 10 00 00       	push   $0x1000
  80091d:	6a 00                	push   $0x0
  80091f:	50                   	push   %eax
  800920:	e8 44 19 00 00       	call   802269 <memset>
                               f->f_indirect = blockno;
  800925:	89 be b0 00 00 00    	mov    %edi,0xb0(%esi)
  80092b:	83 c4 10             	add    $0x10,%esp
                       } else {
                               return -E_NOT_FOUND;
                       }
               }
               *ppdiskbno = (uint32_t *)diskaddr(f->f_indirect) + (filebno-NDIRECT);
  80092e:	83 ec 0c             	sub    $0xc,%esp
  800931:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  800937:	e8 52 fa ff ff       	call   80038e <diskaddr>
  80093c:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800940:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800943:	89 03                	mov    %eax,(%ebx)
  800945:	83 c4 10             	add    $0x10,%esp
       }
       return 0;
  800948:	b8 00 00 00 00       	mov    $0x0,%eax
  80094d:	eb 13                	jmp    800962 <file_block_walk+0xa0>
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       if (filebno >= NDIRECT + NINDIRECT)
                       return -E_INVAL;
  80094f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800954:	eb 0c                	jmp    800962 <file_block_walk+0xa0>
                                       return -E_NO_DISK;

                               memset(diskaddr(blockno), 0, BLKSIZE);
                               f->f_indirect = blockno;
                       } else {
                               return -E_NOT_FOUND;
  800956:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80095b:	eb 05                	jmp    800962 <file_block_walk+0xa0>
       } else {
               if (!f->f_indirect) {
                       if (alloc) {
                               int blockno = alloc_block();
                               if (blockno < 0)
                                       return -E_NO_DISK;
  80095d:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
               }
               *ppdiskbno = (uint32_t *)diskaddr(f->f_indirect) + (filebno-NDIRECT);
       }
       return 0;
       //panic("file_block_walk not implemented");
}
  800962:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80096f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800974:	8b 70 04             	mov    0x4(%eax),%esi
  800977:	bb 00 00 00 00       	mov    $0x0,%ebx
  80097c:	eb 29                	jmp    8009a7 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  80097e:	8d 43 02             	lea    0x2(%ebx),%eax
  800981:	50                   	push   %eax
  800982:	e8 5b fe ff ff       	call   8007e2 <block_is_free>
  800987:	83 c4 04             	add    $0x4,%esp
  80098a:	84 c0                	test   %al,%al
  80098c:	74 16                	je     8009a4 <check_bitmap+0x3a>
  80098e:	68 ae 3a 80 00       	push   $0x803aae
  800993:	68 7d 38 80 00       	push   $0x80387d
  800998:	6a 59                	push   $0x59
  80099a:	68 5e 3a 80 00       	push   $0x803a5e
  80099f:	e8 04 11 00 00       	call   801aa8 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009a4:	83 c3 01             	add    $0x1,%ebx
  8009a7:	89 d8                	mov    %ebx,%eax
  8009a9:	c1 e0 0f             	shl    $0xf,%eax
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	72 ce                	jb     80097e <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8009b0:	83 ec 0c             	sub    $0xc,%esp
  8009b3:	6a 00                	push   $0x0
  8009b5:	e8 28 fe ff ff       	call   8007e2 <block_is_free>
  8009ba:	83 c4 10             	add    $0x10,%esp
  8009bd:	84 c0                	test   %al,%al
  8009bf:	74 16                	je     8009d7 <check_bitmap+0x6d>
  8009c1:	68 c2 3a 80 00       	push   $0x803ac2
  8009c6:	68 7d 38 80 00       	push   $0x80387d
  8009cb:	6a 5c                	push   $0x5c
  8009cd:	68 5e 3a 80 00       	push   $0x803a5e
  8009d2:	e8 d1 10 00 00       	call   801aa8 <_panic>
	assert(!block_is_free(1));
  8009d7:	83 ec 0c             	sub    $0xc,%esp
  8009da:	6a 01                	push   $0x1
  8009dc:	e8 01 fe ff ff       	call   8007e2 <block_is_free>
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	84 c0                	test   %al,%al
  8009e6:	74 16                	je     8009fe <check_bitmap+0x94>
  8009e8:	68 d4 3a 80 00       	push   $0x803ad4
  8009ed:	68 7d 38 80 00       	push   $0x80387d
  8009f2:	6a 5d                	push   $0x5d
  8009f4:	68 5e 3a 80 00       	push   $0x803a5e
  8009f9:	e8 aa 10 00 00       	call   801aa8 <_panic>

	cprintf("bitmap is good\n");
  8009fe:	83 ec 0c             	sub    $0xc,%esp
  800a01:	68 e6 3a 80 00       	push   $0x803ae6
  800a06:	e8 76 11 00 00       	call   801b81 <cprintf>
}
  800a0b:	83 c4 10             	add    $0x10,%esp
  800a0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800a1b:	e8 3f f6 ff ff       	call   80005f <ide_probe_disk1>
  800a20:	84 c0                	test   %al,%al
  800a22:	74 0f                	je     800a33 <fs_init+0x1e>
		ide_set_disk(1);
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	6a 01                	push   $0x1
  800a29:	e8 95 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a2e:	83 c4 10             	add    $0x10,%esp
  800a31:	eb 0d                	jmp    800a40 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800a33:	83 ec 0c             	sub    $0xc,%esp
  800a36:	6a 00                	push   $0x0
  800a38:	e8 86 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a3d:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a40:	e8 6d fa ff ff       	call   8004b2 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800a45:	83 ec 0c             	sub    $0xc,%esp
  800a48:	6a 01                	push   $0x1
  800a4a:	e8 3f f9 ff ff       	call   80038e <diskaddr>
  800a4f:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800a54:	e8 33 fd ff ff       	call   80078c <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a59:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a60:	e8 29 f9 ff ff       	call   80038e <diskaddr>
  800a65:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800a6a:	e8 fb fe ff ff       	call   80096a <check_bitmap>
	
}
  800a6f:	83 c4 10             	add    $0x10,%esp
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	53                   	push   %ebx
  800a78:	83 ec 20             	sub    $0x20,%esp
   // LAB 5: Your code here.
   //panic("file_get_block not implemented");
   uint32_t *pdiskbno;
   int r;
   if ( (r = file_block_walk(f, filebno, &pdiskbno, 1))< 0)
  800a7b:	6a 01                	push   $0x1
  800a7d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	e8 37 fe ff ff       	call   8008c2 <file_block_walk>
  800a8b:	83 c4 10             	add    $0x10,%esp
  800a8e:	85 c0                	test   %eax,%eax
  800a90:	78 5e                	js     800af0 <file_get_block+0x7c>
       return r;

   if(*pdiskbno == 0) {
  800a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a95:	83 38 00             	cmpl   $0x0,(%eax)
  800a98:	75 3c                	jne    800ad6 <file_get_block+0x62>
   // 文件块还未分配
   if ( (r = alloc_block()) < 0)
  800a9a:	e8 bc fd ff ff       	call   80085b <alloc_block>
  800a9f:	89 c3                	mov    %eax,%ebx
  800aa1:	85 c0                	test   %eax,%eax
  800aa3:	78 4b                	js     800af0 <file_get_block+0x7c>
       return r;
   *pdiskbno = r;
  800aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa8:	89 18                	mov    %ebx,(%eax)
   memset(diskaddr(r), 0, BLKSIZE);
  800aaa:	83 ec 0c             	sub    $0xc,%esp
  800aad:	53                   	push   %ebx
  800aae:	e8 db f8 ff ff       	call   80038e <diskaddr>
  800ab3:	83 c4 0c             	add    $0xc,%esp
  800ab6:	68 00 10 00 00       	push   $0x1000
  800abb:	6a 00                	push   $0x0
  800abd:	50                   	push   %eax
  800abe:	e8 a6 17 00 00       	call   802269 <memset>
   flush_block(diskaddr(r));
  800ac3:	89 1c 24             	mov    %ebx,(%esp)
  800ac6:	e8 c3 f8 ff ff       	call   80038e <diskaddr>
  800acb:	89 04 24             	mov    %eax,(%esp)
  800ace:	e8 39 f9 ff ff       	call   80040c <flush_block>
  800ad3:	83 c4 10             	add    $0x10,%esp
   }
    
   // 最终指向块
   *blk = diskaddr(*pdiskbno);
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adc:	ff 30                	pushl  (%eax)
  800ade:	e8 ab f8 ff ff       	call   80038e <diskaddr>
  800ae3:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae6:	89 02                	mov    %eax,(%edx)
   return 0;
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax

}
  800af0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b01:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b07:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b0d:	eb 03                	jmp    800b12 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b0f:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b12:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b15:	74 f8                	je     800b0f <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b17:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800b1d:	83 c1 08             	add    $0x8,%ecx
  800b20:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b26:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b2d:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	74 06                	je     800b3d <walk_path+0x48>
		*pdir = 0;
  800b37:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b3d:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800b43:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b4e:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b54:	e9 5f 01 00 00       	jmp    800cb8 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800b59:	83 c7 01             	add    $0x1,%edi
  800b5c:	eb 02                	jmp    800b60 <walk_path+0x6b>
  800b5e:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800b60:	0f b6 17             	movzbl (%edi),%edx
  800b63:	80 fa 2f             	cmp    $0x2f,%dl
  800b66:	74 04                	je     800b6c <walk_path+0x77>
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 ed                	jne    800b59 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800b6c:	89 fb                	mov    %edi,%ebx
  800b6e:	29 c3                	sub    %eax,%ebx
  800b70:	83 fb 7f             	cmp    $0x7f,%ebx
  800b73:	0f 8f 69 01 00 00    	jg     800ce2 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b79:	83 ec 04             	sub    $0x4,%esp
  800b7c:	53                   	push   %ebx
  800b7d:	50                   	push   %eax
  800b7e:	56                   	push   %esi
  800b7f:	e8 32 17 00 00       	call   8022b6 <memmove>
		name[path - p] = '\0';
  800b84:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800b8b:	00 
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	eb 03                	jmp    800b94 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b91:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b94:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800b97:	74 f8                	je     800b91 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800b99:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800b9f:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800ba6:	0f 85 3d 01 00 00    	jne    800ce9 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800bac:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bb2:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bb7:	74 19                	je     800bd2 <walk_path+0xdd>
  800bb9:	68 f6 3a 80 00       	push   $0x803af6
  800bbe:	68 7d 38 80 00       	push   $0x80387d
  800bc3:	68 db 00 00 00       	push   $0xdb
  800bc8:	68 5e 3a 80 00       	push   $0x803a5e
  800bcd:	e8 d6 0e 00 00       	call   801aa8 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800bd2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	0f 48 c2             	cmovs  %edx,%eax
  800bdd:	c1 f8 0c             	sar    $0xc,%eax
  800be0:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800be6:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800bed:	00 00 00 
  800bf0:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800bf6:	eb 5e                	jmp    800c56 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800bf8:	83 ec 04             	sub    $0x4,%esp
  800bfb:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c01:	50                   	push   %eax
  800c02:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c08:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c0e:	e8 61 fe ff ff       	call   800a74 <file_get_block>
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	85 c0                	test   %eax,%eax
  800c18:	0f 88 ee 00 00 00    	js     800d0c <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800c1e:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c24:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c2a:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c30:	83 ec 08             	sub    $0x8,%esp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	e8 94 15 00 00       	call   8021ce <strcmp>
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	0f 84 ab 00 00 00    	je     800cf0 <walk_path+0x1fb>
  800c45:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800c4b:	39 fb                	cmp    %edi,%ebx
  800c4d:	75 db                	jne    800c2a <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c4f:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800c56:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c5c:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800c62:	75 94                	jne    800bf8 <walk_path+0x103>
  800c64:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800c6a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c6f:	80 3f 00             	cmpb   $0x0,(%edi)
  800c72:	0f 85 a3 00 00 00    	jne    800d1b <walk_path+0x226>
				if (pdir)
  800c78:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	74 08                	je     800c8a <walk_path+0x195>
					*pdir = dir;
  800c82:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800c88:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800c8a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c8e:	74 15                	je     800ca5 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800c90:	83 ec 08             	sub    $0x8,%esp
  800c93:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800c99:	50                   	push   %eax
  800c9a:	ff 75 08             	pushl  0x8(%ebp)
  800c9d:	e8 82 14 00 00       	call   802124 <strcpy>
  800ca2:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800ca5:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800cb1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cb6:	eb 63                	jmp    800d1b <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cb8:	80 38 00             	cmpb   $0x0,(%eax)
  800cbb:	0f 85 9d fe ff ff    	jne    800b5e <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800cc1:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	74 02                	je     800ccd <walk_path+0x1d8>
		*pdir = dir;
  800ccb:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800ccd:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800cd3:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800cd9:	89 08                	mov    %ecx,(%eax)
	return 0;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce0:	eb 39                	jmp    800d1b <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800ce2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800ce7:	eb 32                	jmp    800d1b <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800ce9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cee:	eb 2b                	jmp    800d1b <walk_path+0x226>
  800cf0:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800cf6:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800cfc:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d02:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800d08:	89 f8                	mov    %edi,%eax
  800d0a:	eb ac                	jmp    800cb8 <walk_path+0x1c3>
  800d0c:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d12:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d15:	0f 84 4f ff ff ff    	je     800c6a <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d29:	6a 00                	push   $0x0
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	e8 ba fd ff ff       	call   800af5 <walk_path>
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
  800d46:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d49:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d5a:	39 ca                	cmp    %ecx,%edx
  800d5c:	7e 7c                	jle    800dda <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800d5e:	29 ca                	sub    %ecx,%edx
  800d60:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d63:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800d67:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800d6a:	89 ce                	mov    %ecx,%esi
  800d6c:	01 d1                	add    %edx,%ecx
  800d6e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800d71:	eb 5d                	jmp    800dd0 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d79:	50                   	push   %eax
  800d7a:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800d80:	85 f6                	test   %esi,%esi
  800d82:	0f 49 c6             	cmovns %esi,%eax
  800d85:	c1 f8 0c             	sar    $0xc,%eax
  800d88:	50                   	push   %eax
  800d89:	ff 75 08             	pushl  0x8(%ebp)
  800d8c:	e8 e3 fc ff ff       	call   800a74 <file_get_block>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 42                	js     800dda <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	c1 fa 1f             	sar    $0x1f,%edx
  800d9d:	c1 ea 14             	shr    $0x14,%edx
  800da0:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800da3:	25 ff 0f 00 00       	and    $0xfff,%eax
  800da8:	29 d0                	sub    %edx,%eax
  800daa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800dad:	29 da                	sub    %ebx,%edx
  800daf:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800db4:	29 c3                	sub    %eax,%ebx
  800db6:	39 da                	cmp    %ebx,%edx
  800db8:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	53                   	push   %ebx
  800dbf:	03 45 e4             	add    -0x1c(%ebp),%eax
  800dc2:	50                   	push   %eax
  800dc3:	57                   	push   %edi
  800dc4:	e8 ed 14 00 00       	call   8022b6 <memmove>
		pos += bn;
  800dc9:	01 de                	add    %ebx,%esi
		buf += bn;
  800dcb:	01 df                	add    %ebx,%edi
  800dcd:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800dd0:	89 f3                	mov    %esi,%ebx
  800dd2:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800dd5:	77 9c                	ja     800d73 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800dd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 2c             	sub    $0x2c,%esp
  800deb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800dee:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800df4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800df7:	0f 8e a7 00 00 00    	jle    800ea4 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800dfd:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e03:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e08:	0f 49 f8             	cmovns %eax,%edi
  800e0b:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e11:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800e16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e19:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800e1f:	0f 49 c2             	cmovns %edx,%eax
  800e22:	c1 f8 0c             	sar    $0xc,%eax
  800e25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e28:	89 c3                	mov    %eax,%ebx
  800e2a:	eb 39                	jmp    800e65 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	6a 00                	push   $0x0
  800e31:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e34:	89 da                	mov    %ebx,%edx
  800e36:	89 f0                	mov    %esi,%eax
  800e38:	e8 85 fa ff ff       	call   8008c2 <file_block_walk>
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	85 c0                	test   %eax,%eax
  800e42:	78 4d                	js     800e91 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800e44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e47:	8b 00                	mov    (%eax),%eax
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	74 15                	je     800e62 <file_set_size+0x80>
		free_block(*ptr);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	50                   	push   %eax
  800e51:	e8 c9 f9 ff ff       	call   80081f <free_block>
		*ptr = 0;
  800e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e5f:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e62:	83 c3 01             	add    $0x1,%ebx
  800e65:	39 df                	cmp    %ebx,%edi
  800e67:	77 c3                	ja     800e2c <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800e69:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800e6d:	77 35                	ja     800ea4 <file_set_size+0xc2>
  800e6f:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e75:	85 c0                	test   %eax,%eax
  800e77:	74 2b                	je     800ea4 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	e8 9d f9 ff ff       	call   80081f <free_block>
		f->f_indirect = 0;
  800e82:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800e89:	00 00 00 
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	eb 13                	jmp    800ea4 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	50                   	push   %eax
  800e95:	68 13 3b 80 00       	push   $0x803b13
  800e9a:	e8 e2 0c 00 00       	call   801b81 <cprintf>
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	eb be                	jmp    800e62 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800ead:	83 ec 0c             	sub    $0xc,%esp
  800eb0:	56                   	push   %esi
  800eb1:	e8 56 f5 ff ff       	call   80040c <flush_block>
	return 0;
}
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
  800ecc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ecf:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800ed2:	89 f0                	mov    %esi,%eax
  800ed4:	03 45 10             	add    0x10(%ebp),%eax
  800ed7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800eda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edd:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800ee3:	76 72                	jbe    800f57 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	50                   	push   %eax
  800ee9:	51                   	push   %ecx
  800eea:	e8 f3 fe ff ff       	call   800de2 <file_set_size>
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 61                	jns    800f57 <file_write+0x94>
  800ef6:	eb 69                	jmp    800f61 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800efe:	50                   	push   %eax
  800eff:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f05:	85 f6                	test   %esi,%esi
  800f07:	0f 49 c6             	cmovns %esi,%eax
  800f0a:	c1 f8 0c             	sar    $0xc,%eax
  800f0d:	50                   	push   %eax
  800f0e:	ff 75 08             	pushl  0x8(%ebp)
  800f11:	e8 5e fb ff ff       	call   800a74 <file_get_block>
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 44                	js     800f61 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	c1 fa 1f             	sar    $0x1f,%edx
  800f22:	c1 ea 14             	shr    $0x14,%edx
  800f25:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800f28:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f2d:	29 d0                	sub    %edx,%eax
  800f2f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f32:	29 d9                	sub    %ebx,%ecx
  800f34:	89 cb                	mov    %ecx,%ebx
  800f36:	ba 00 10 00 00       	mov    $0x1000,%edx
  800f3b:	29 c2                	sub    %eax,%edx
  800f3d:	39 d1                	cmp    %edx,%ecx
  800f3f:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	53                   	push   %ebx
  800f46:	57                   	push   %edi
  800f47:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	e8 66 13 00 00       	call   8022b6 <memmove>
		pos += bn;
  800f50:	01 de                	add    %ebx,%esi
		buf += bn;
  800f52:	01 df                	add    %ebx,%edi
  800f54:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f57:	89 f3                	mov    %esi,%ebx
  800f59:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800f5c:	77 9a                	ja     800ef8 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800f5e:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 10             	sub    $0x10,%esp
  800f71:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f79:	eb 3c                	jmp    800fb7 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	6a 00                	push   $0x0
  800f80:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800f83:	89 da                	mov    %ebx,%edx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	e8 36 f9 ff ff       	call   8008c2 <file_block_walk>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 21                	js     800fb4 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f96:	85 c0                	test   %eax,%eax
  800f98:	74 1a                	je     800fb4 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f9a:	8b 00                	mov    (%eax),%eax
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	74 14                	je     800fb4 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	50                   	push   %eax
  800fa4:	e8 e5 f3 ff ff       	call   80038e <diskaddr>
  800fa9:	89 04 24             	mov    %eax,(%esp)
  800fac:	e8 5b f4 ff ff       	call   80040c <flush_block>
  800fb1:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fb4:	83 c3 01             	add    $0x1,%ebx
  800fb7:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800fbd:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800fc3:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800fc9:	85 c9                	test   %ecx,%ecx
  800fcb:	0f 49 c1             	cmovns %ecx,%eax
  800fce:	c1 f8 0c             	sar    $0xc,%eax
  800fd1:	39 c3                	cmp    %eax,%ebx
  800fd3:	7c a6                	jl     800f7b <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	56                   	push   %esi
  800fd9:	e8 2e f4 ff ff       	call   80040c <flush_block>
	if (f->f_indirect)
  800fde:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	74 14                	je     800fff <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	50                   	push   %eax
  800fef:	e8 9a f3 ff ff       	call   80038e <diskaddr>
  800ff4:	89 04 24             	mov    %eax,(%esp)
  800ff7:	e8 10 f4 ff ff       	call   80040c <flush_block>
  800ffc:	83 c4 10             	add    $0x10,%esp
}
  800fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801012:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801018:	50                   	push   %eax
  801019:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  80101f:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	e8 c8 fa ff ff       	call   800af5 <walk_path>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	0f 84 d1 00 00 00    	je     801109 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801038:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80103b:	0f 85 0c 01 00 00    	jne    80114d <file_create+0x147>
  801041:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  801047:	85 f6                	test   %esi,%esi
  801049:	0f 84 c1 00 00 00    	je     801110 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80104f:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  801055:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80105a:	74 19                	je     801075 <file_create+0x6f>
  80105c:	68 f6 3a 80 00       	push   $0x803af6
  801061:	68 7d 38 80 00       	push   $0x80387d
  801066:	68 f4 00 00 00       	push   $0xf4
  80106b:	68 5e 3a 80 00       	push   $0x803a5e
  801070:	e8 33 0a 00 00       	call   801aa8 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801075:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80107b:	85 c0                	test   %eax,%eax
  80107d:	0f 48 c2             	cmovs  %edx,%eax
  801080:	c1 f8 0c             	sar    $0xc,%eax
  801083:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801089:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80108e:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801094:	eb 3b                	jmp    8010d1 <file_create+0xcb>
  801096:	83 ec 04             	sub    $0x4,%esp
  801099:	57                   	push   %edi
  80109a:	53                   	push   %ebx
  80109b:	56                   	push   %esi
  80109c:	e8 d3 f9 ff ff       	call   800a74 <file_get_block>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	0f 88 a1 00 00 00    	js     80114d <file_create+0x147>
			return r;
		f = (struct File*) blk;
  8010ac:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8010b2:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8010b8:	80 38 00             	cmpb   $0x0,(%eax)
  8010bb:	75 08                	jne    8010c5 <file_create+0xbf>
				*file = &f[j];
  8010bd:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8010c3:	eb 52                	jmp    801117 <file_create+0x111>
  8010c5:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8010ca:	39 d0                	cmp    %edx,%eax
  8010cc:	75 ea                	jne    8010b8 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8010ce:	83 c3 01             	add    $0x1,%ebx
  8010d1:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  8010d7:	75 bd                	jne    801096 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8010d9:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  8010e0:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8010e3:	83 ec 04             	sub    $0x4,%esp
  8010e6:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	53                   	push   %ebx
  8010ee:	56                   	push   %esi
  8010ef:	e8 80 f9 ff ff       	call   800a74 <file_get_block>
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 52                	js     80114d <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8010fb:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801101:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801107:	eb 0e                	jmp    801117 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  801109:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80110e:	eb 3d                	jmp    80114d <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801110:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801115:	eb 36                	jmp    80114d <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  801117:	83 ec 08             	sub    $0x8,%esp
  80111a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  801127:	e8 f8 0f 00 00       	call   802124 <strcpy>
	*pf = f;
  80112c:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801132:	8b 45 0c             	mov    0xc(%ebp),%eax
  801135:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801137:	83 c4 04             	add    $0x4,%esp
  80113a:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801140:	e8 24 fe ff ff       	call   800f69 <file_flush>
	return 0;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	53                   	push   %ebx
  801159:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80115c:	bb 01 00 00 00       	mov    $0x1,%ebx
  801161:	eb 17                	jmp    80117a <fs_sync+0x25>
		flush_block(diskaddr(i));
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	53                   	push   %ebx
  801167:	e8 22 f2 ff ff       	call   80038e <diskaddr>
  80116c:	89 04 24             	mov    %eax,(%esp)
  80116f:	e8 98 f2 ff ff       	call   80040c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801174:	83 c3 01             	add    $0x1,%ebx
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80117f:	39 58 04             	cmp    %ebx,0x4(%eax)
  801182:	77 df                	ja     801163 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801187:	c9                   	leave  
  801188:	c3                   	ret    

00801189 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80118f:	e8 c1 ff ff ff       	call   801155 <fs_sync>
	return 0;
}
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8011a3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011ad:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011af:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011b2:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011b8:	83 c0 01             	add    $0x1,%eax
  8011bb:	83 c2 10             	add    $0x10,%edx
  8011be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c3:	75 e8                	jne    8011ad <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8011cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8011d4:	83 ec 0c             	sub    $0xc,%esp
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	c1 e0 04             	shl    $0x4,%eax
  8011dc:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8011e2:	e8 aa 1e 00 00       	call   803091 <pageref>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 07                	je     8011f5 <openfile_alloc+0x2e>
  8011ee:	83 f8 01             	cmp    $0x1,%eax
  8011f1:	74 20                	je     801213 <openfile_alloc+0x4c>
  8011f3:	eb 51                	jmp    801246 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	6a 07                	push   $0x7
  8011fa:	89 d8                	mov    %ebx,%eax
  8011fc:	c1 e0 04             	shl    $0x4,%eax
  8011ff:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801205:	6a 00                	push   $0x0
  801207:	e8 1b 13 00 00       	call   802527 <sys_page_alloc>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 43                	js     801256 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801213:	c1 e3 04             	shl    $0x4,%ebx
  801216:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  80121c:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801223:	04 00 00 
			*o = &opentab[i];
  801226:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	68 00 10 00 00       	push   $0x1000
  801230:	6a 00                	push   $0x0
  801232:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801238:	e8 2c 10 00 00       	call   802269 <memset>
			return (*o)->o_fileid;
  80123d:	8b 06                	mov    (%esi),%eax
  80123f:	8b 00                	mov    (%eax),%eax
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	eb 10                	jmp    801256 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801246:	83 c3 01             	add    $0x1,%ebx
  801249:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80124f:	75 83                	jne    8011d4 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801251:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801256:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 18             	sub    $0x18,%esp
  801266:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801269:	89 fb                	mov    %edi,%ebx
  80126b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801271:	89 de                	mov    %ebx,%esi
  801273:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801276:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80127c:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801282:	e8 0a 1e 00 00       	call   803091 <pageref>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	83 f8 01             	cmp    $0x1,%eax
  80128d:	7e 17                	jle    8012a6 <openfile_lookup+0x49>
  80128f:	c1 e3 04             	shl    $0x4,%ebx
  801292:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801298:	75 13                	jne    8012ad <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  80129a:	8b 45 10             	mov    0x10(%ebp),%eax
  80129d:	89 30                	mov    %esi,(%eax)
	return 0;
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	eb 0c                	jmp    8012b2 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8012a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ab:	eb 05                	jmp    8012b2 <openfile_lookup+0x55>
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8012b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5f                   	pop    %edi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 18             	sub    $0x18,%esp
  8012c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c7:	50                   	push   %eax
  8012c8:	ff 33                	pushl  (%ebx)
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 8b ff ff ff       	call   80125d <openfile_lookup>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 14                	js     8012ed <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 73 04             	pushl  0x4(%ebx)
  8012df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e2:	ff 70 04             	pushl  0x4(%eax)
  8012e5:	e8 f8 fa ff ff       	call   800de2 <file_set_size>
  8012ea:	83 c4 10             	add    $0x10,%esp
}
  8012ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 18             	sub    $0x18,%esp
  8012f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
    struct OpenFile *o;
    int r;
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  8012fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	ff 33                	pushl  (%ebx)
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 53 ff ff ff       	call   80125d <openfile_lookup>
  80130a:	83 c4 10             	add    $0x10,%esp
           return r;
  80130d:	89 c2                	mov    %eax,%edx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
    struct OpenFile *o;
    int r;
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 2b                	js     80133e <serve_read+0x4c>
           return r;
    }

    r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  801313:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801316:	8b 50 0c             	mov    0xc(%eax),%edx
  801319:	ff 72 04             	pushl  0x4(%edx)
  80131c:	ff 73 04             	pushl  0x4(%ebx)
  80131f:	53                   	push   %ebx
  801320:	ff 70 04             	pushl  0x4(%eax)
  801323:	e8 15 fa ff ff       	call   800d3d <file_read>
    if (r < 0)
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 0d                	js     80133c <serve_read+0x4a>
           return r;

    o->o_fd->fd_offset += r;
  80132f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801332:	8b 52 0c             	mov    0xc(%edx),%edx
  801335:	01 42 04             	add    %eax,0x4(%edx)
    return r;
  801338:	89 c2                	mov    %eax,%edx
  80133a:	eb 02                	jmp    80133e <serve_read+0x4c>
           return r;
    }

    r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
    if (r < 0)
           return r;
  80133c:	89 c2                	mov    %eax,%edx

    o->o_fd->fd_offset += r;
    return r;
}
  80133e:	89 d0                	mov    %edx,%eax
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 18             	sub    $0x18,%esp
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	//panic("serve_write not implemented");
    int r;
    struct OpenFile *of;
    if ( (r = openfile_lookup(envid, req->req_fileid, &of)) < 0)
  80134f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 33                	pushl  (%ebx)
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	e8 00 ff ff ff       	call   80125d <openfile_lookup>
  80135d:	83 c4 10             	add    $0x10,%esp
        return r;
  801360:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	//panic("serve_write not implemented");
    int r;
    struct OpenFile *of;
    if ( (r = openfile_lookup(envid, req->req_fileid, &of)) < 0)
  801362:	85 c0                	test   %eax,%eax
  801364:	78 2e                	js     801394 <serve_write+0x4f>
        return r;
    int reqn=req->req_n;
    //reqn = req->req_n > PGSIZE? PGSIZE:req->req_n;
    
    if ( (r = file_write(of->o_file, req->req_buf, reqn, of->o_fd->fd_offset)) < 0)
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	8b 50 0c             	mov    0xc(%eax),%edx
  80136c:	ff 72 04             	pushl  0x4(%edx)
  80136f:	ff 73 04             	pushl  0x4(%ebx)
  801372:	83 c3 08             	add    $0x8,%ebx
  801375:	53                   	push   %ebx
  801376:	ff 70 04             	pushl  0x4(%eax)
  801379:	e8 45 fb ff ff       	call   800ec3 <file_write>
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	78 0d                	js     801392 <serve_write+0x4d>
        return r;

    of->o_fd->fd_offset += r;
  801385:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801388:	8b 52 0c             	mov    0xc(%edx),%edx
  80138b:	01 42 04             	add    %eax,0x4(%edx)
    return r;
  80138e:	89 c2                	mov    %eax,%edx
  801390:	eb 02                	jmp    801394 <serve_write+0x4f>
        return r;
    int reqn=req->req_n;
    //reqn = req->req_n > PGSIZE? PGSIZE:req->req_n;
    
    if ( (r = file_write(of->o_file, req->req_buf, reqn, of->o_fd->fd_offset)) < 0)
        return r;
  801392:	89 c2                	mov    %eax,%edx

    of->o_fd->fd_offset += r;
    return r;
}
  801394:	89 d0                	mov    %edx,%eax
  801396:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	53                   	push   %ebx
  80139f:	83 ec 18             	sub    $0x18,%esp
  8013a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	ff 33                	pushl  (%ebx)
  8013ab:	ff 75 08             	pushl  0x8(%ebp)
  8013ae:	e8 aa fe ff ff       	call   80125d <openfile_lookup>
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 3f                	js     8013f9 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c0:	ff 70 04             	pushl  0x4(%eax)
  8013c3:	53                   	push   %ebx
  8013c4:	e8 5b 0d 00 00       	call   802124 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cc:	8b 50 04             	mov    0x4(%eax),%edx
  8013cf:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8013d5:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8013db:	8b 40 04             	mov    0x4(%eax),%eax
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8013e8:	0f 94 c0             	sete   %al
  8013eb:	0f b6 c0             	movzbl %al,%eax
  8013ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140b:	ff 30                	pushl  (%eax)
  80140d:	ff 75 08             	pushl  0x8(%ebp)
  801410:	e8 48 fe ff ff       	call   80125d <openfile_lookup>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 16                	js     801432 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801422:	ff 70 04             	pushl  0x4(%eax)
  801425:	e8 3f fb ff ff       	call   800f69 <file_flush>
	return 0;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	53                   	push   %ebx
  801438:	81 ec 18 04 00 00    	sub    $0x418,%esp
  80143e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801441:	68 00 04 00 00       	push   $0x400
  801446:	53                   	push   %ebx
  801447:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	e8 63 0e 00 00       	call   8022b6 <memmove>
	path[MAXPATHLEN-1] = 0;
  801453:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801457:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80145d:	89 04 24             	mov    %eax,(%esp)
  801460:	e8 62 fd ff ff       	call   8011c7 <openfile_alloc>
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	0f 88 f0 00 00 00    	js     801560 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801470:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801477:	74 33                	je     8014ac <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	e8 77 fb ff ff       	call   801006 <file_create>
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	79 37                	jns    8014cd <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801496:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80149d:	0f 85 bd 00 00 00    	jne    801560 <serve_open+0x12c>
  8014a3:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8014a6:	0f 85 b4 00 00 00    	jne    801560 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	e8 61 f8 ff ff       	call   800d23 <file_open>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	0f 88 93 00 00 00    	js     801560 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8014cd:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8014d4:	74 17                	je     8014ed <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	6a 00                	push   $0x0
  8014db:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8014e1:	e8 fc f8 ff ff       	call   800de2 <file_set_size>
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 73                	js     801560 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	e8 20 f8 ff ff       	call   800d23 <file_open>
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	85 c0                	test   %eax,%eax
  801508:	78 56                	js     801560 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80150a:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801510:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801516:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801519:	8b 50 0c             	mov    0xc(%eax),%edx
  80151c:	8b 08                	mov    (%eax),%ecx
  80151e:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801521:	8b 48 0c             	mov    0xc(%eax),%ecx
  801524:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80152a:	83 e2 03             	and    $0x3,%edx
  80152d:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801530:	8b 40 0c             	mov    0xc(%eax),%eax
  801533:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801539:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80153b:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801541:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801547:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80154a:	8b 50 0c             	mov    0xc(%eax),%edx
  80154d:	8b 45 10             	mov    0x10(%ebp),%eax
  801550:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801552:	8b 45 14             	mov    0x14(%ebp),%eax
  801555:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80155b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	56                   	push   %esi
  801569:	53                   	push   %ebx
  80156a:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80156d:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801570:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801573:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	53                   	push   %ebx
  80157e:	ff 35 44 50 80 00    	pushl  0x805044
  801584:	56                   	push   %esi
  801585:	e8 1a 12 00 00       	call   8027a4 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801591:	75 15                	jne    8015a8 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	ff 75 f4             	pushl  -0xc(%ebp)
  801599:	68 30 3b 80 00       	push   $0x803b30
  80159e:	e8 de 05 00 00       	call   801b81 <cprintf>
				whom);
			continue; // just leave it hanging...
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb cb                	jmp    801573 <serve+0xe>
		}

		pg = NULL;
  8015a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8015af:	83 f8 01             	cmp    $0x1,%eax
  8015b2:	75 18                	jne    8015cc <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015b4:	53                   	push   %ebx
  8015b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	ff 35 44 50 80 00    	pushl  0x805044
  8015bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c2:	e8 6d fe ff ff       	call   801434 <serve_open>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 3c                	jmp    801608 <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015cc:	83 f8 08             	cmp    $0x8,%eax
  8015cf:	77 1e                	ja     8015ef <serve+0x8a>
  8015d1:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8015d8:	85 d2                	test   %edx,%edx
  8015da:	74 13                	je     8015ef <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	ff 35 44 50 80 00    	pushl  0x805044
  8015e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e8:	ff d2                	call   *%edx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	eb 19                	jmp    801608 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015ef:	83 ec 04             	sub    $0x4,%esp
  8015f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f5:	50                   	push   %eax
  8015f6:	68 60 3b 80 00       	push   $0x803b60
  8015fb:	e8 81 05 00 00       	call   801b81 <cprintf>
  801600:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801603:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801608:	ff 75 f0             	pushl  -0x10(%ebp)
  80160b:	ff 75 ec             	pushl  -0x14(%ebp)
  80160e:	50                   	push   %eax
  80160f:	ff 75 f4             	pushl  -0xc(%ebp)
  801612:	e8 e2 11 00 00       	call   8027f9 <ipc_send>
		sys_page_unmap(0, fsreq);
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	ff 35 44 50 80 00    	pushl  0x805044
  801620:	6a 00                	push   $0x0
  801622:	e8 85 0f 00 00       	call   8025ac <sys_page_unmap>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	e9 44 ff ff ff       	jmp    801573 <serve+0xe>

0080162f <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801635:	c7 05 60 90 80 00 83 	movl   $0x803b83,0x809060
  80163c:	3b 80 00 
	cprintf("FS is running\n");
  80163f:	68 86 3b 80 00       	push   $0x803b86
  801644:	e8 38 05 00 00       	call   801b81 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801649:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80164e:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801653:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801655:	c7 04 24 95 3b 80 00 	movl   $0x803b95,(%esp)
  80165c:	e8 20 05 00 00       	call   801b81 <cprintf>

	serve_init();
  801661:	e8 35 fb ff ff       	call   80119b <serve_init>
	fs_init();
  801666:	e8 aa f3 ff ff       	call   800a15 <fs_init>
        fs_test();
  80166b:	e8 05 00 00 00       	call   801675 <fs_test>
	serve();
  801670:	e8 f0 fe ff ff       	call   801565 <serve>

00801675 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80167c:	6a 07                	push   $0x7
  80167e:	68 00 10 00 00       	push   $0x1000
  801683:	6a 00                	push   $0x0
  801685:	e8 9d 0e 00 00       	call   802527 <sys_page_alloc>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	79 12                	jns    8016a3 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801691:	50                   	push   %eax
  801692:	68 a4 3b 80 00       	push   $0x803ba4
  801697:	6a 12                	push   $0x12
  801699:	68 b7 3b 80 00       	push   $0x803bb7
  80169e:	e8 05 04 00 00       	call   801aa8 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	68 00 10 00 00       	push   $0x1000
  8016ab:	ff 35 04 a0 80 00    	pushl  0x80a004
  8016b1:	68 00 10 00 00       	push   $0x1000
  8016b6:	e8 fb 0b 00 00       	call   8022b6 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016bb:	e8 9b f1 ff ff       	call   80085b <alloc_block>
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	79 12                	jns    8016d9 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016c7:	50                   	push   %eax
  8016c8:	68 c1 3b 80 00       	push   $0x803bc1
  8016cd:	6a 17                	push   $0x17
  8016cf:	68 b7 3b 80 00       	push   $0x803bb7
  8016d4:	e8 cf 03 00 00       	call   801aa8 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016d9:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	0f 49 d0             	cmovns %eax,%edx
  8016e1:	c1 fa 05             	sar    $0x5,%edx
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	c1 fb 1f             	sar    $0x1f,%ebx
  8016e9:	c1 eb 1b             	shr    $0x1b,%ebx
  8016ec:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016ef:	83 e1 1f             	and    $0x1f,%ecx
  8016f2:	29 d9                	sub    %ebx,%ecx
  8016f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f9:	d3 e0                	shl    %cl,%eax
  8016fb:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801702:	75 16                	jne    80171a <fs_test+0xa5>
  801704:	68 d1 3b 80 00       	push   $0x803bd1
  801709:	68 7d 38 80 00       	push   $0x80387d
  80170e:	6a 19                	push   $0x19
  801710:	68 b7 3b 80 00       	push   $0x803bb7
  801715:	e8 8e 03 00 00       	call   801aa8 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80171a:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  801720:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801723:	74 16                	je     80173b <fs_test+0xc6>
  801725:	68 4c 3d 80 00       	push   $0x803d4c
  80172a:	68 7d 38 80 00       	push   $0x80387d
  80172f:	6a 1b                	push   $0x1b
  801731:	68 b7 3b 80 00       	push   $0x803bb7
  801736:	e8 6d 03 00 00       	call   801aa8 <_panic>
	cprintf("alloc_block is good\n");
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	68 ec 3b 80 00       	push   $0x803bec
  801743:	e8 39 04 00 00       	call   801b81 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174e:	50                   	push   %eax
  80174f:	68 01 3c 80 00       	push   $0x803c01
  801754:	e8 ca f5 ff ff       	call   800d23 <file_open>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80175f:	74 1b                	je     80177c <fs_test+0x107>
  801761:	89 c2                	mov    %eax,%edx
  801763:	c1 ea 1f             	shr    $0x1f,%edx
  801766:	84 d2                	test   %dl,%dl
  801768:	74 12                	je     80177c <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80176a:	50                   	push   %eax
  80176b:	68 0c 3c 80 00       	push   $0x803c0c
  801770:	6a 1f                	push   $0x1f
  801772:	68 b7 3b 80 00       	push   $0x803bb7
  801777:	e8 2c 03 00 00       	call   801aa8 <_panic>
	else if (r == 0)
  80177c:	85 c0                	test   %eax,%eax
  80177e:	75 14                	jne    801794 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	68 6c 3d 80 00       	push   $0x803d6c
  801788:	6a 21                	push   $0x21
  80178a:	68 b7 3b 80 00       	push   $0x803bb7
  80178f:	e8 14 03 00 00       	call   801aa8 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179a:	50                   	push   %eax
  80179b:	68 25 3c 80 00       	push   $0x803c25
  8017a0:	e8 7e f5 ff ff       	call   800d23 <file_open>
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	79 12                	jns    8017be <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8017ac:	50                   	push   %eax
  8017ad:	68 2e 3c 80 00       	push   $0x803c2e
  8017b2:	6a 23                	push   $0x23
  8017b4:	68 b7 3b 80 00       	push   $0x803bb7
  8017b9:	e8 ea 02 00 00       	call   801aa8 <_panic>
	cprintf("file_open is good\n");
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	68 45 3c 80 00       	push   $0x803c45
  8017c6:	e8 b6 03 00 00       	call   801b81 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017cb:	83 c4 0c             	add    $0xc,%esp
  8017ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	6a 00                	push   $0x0
  8017d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d7:	e8 98 f2 ff ff       	call   800a74 <file_get_block>
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	79 12                	jns    8017f5 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8017e3:	50                   	push   %eax
  8017e4:	68 58 3c 80 00       	push   $0x803c58
  8017e9:	6a 27                	push   $0x27
  8017eb:	68 b7 3b 80 00       	push   $0x803bb7
  8017f0:	e8 b3 02 00 00       	call   801aa8 <_panic>
	if (strcmp(blk, msg) != 0)
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	68 8c 3d 80 00       	push   $0x803d8c
  8017fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801800:	e8 c9 09 00 00       	call   8021ce <strcmp>
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	74 14                	je     801820 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	68 b4 3d 80 00       	push   $0x803db4
  801814:	6a 29                	push   $0x29
  801816:	68 b7 3b 80 00       	push   $0x803bb7
  80181b:	e8 88 02 00 00       	call   801aa8 <_panic>
	cprintf("file_get_block is good\n");
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	68 6b 3c 80 00       	push   $0x803c6b
  801828:	e8 54 03 00 00       	call   801b81 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801830:	0f b6 10             	movzbl (%eax),%edx
  801833:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801835:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801838:	c1 e8 0c             	shr    $0xc,%eax
  80183b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	a8 40                	test   $0x40,%al
  801847:	75 16                	jne    80185f <fs_test+0x1ea>
  801849:	68 84 3c 80 00       	push   $0x803c84
  80184e:	68 7d 38 80 00       	push   $0x80387d
  801853:	6a 2d                	push   $0x2d
  801855:	68 b7 3b 80 00       	push   $0x803bb7
  80185a:	e8 49 02 00 00       	call   801aa8 <_panic>
	file_flush(f);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	ff 75 f4             	pushl  -0xc(%ebp)
  801865:	e8 ff f6 ff ff       	call   800f69 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80186a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186d:	c1 e8 0c             	shr    $0xc,%eax
  801870:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	a8 40                	test   $0x40,%al
  80187c:	74 16                	je     801894 <fs_test+0x21f>
  80187e:	68 83 3c 80 00       	push   $0x803c83
  801883:	68 7d 38 80 00       	push   $0x80387d
  801888:	6a 2f                	push   $0x2f
  80188a:	68 b7 3b 80 00       	push   $0x803bb7
  80188f:	e8 14 02 00 00       	call   801aa8 <_panic>
	cprintf("file_flush is good\n");
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	68 9f 3c 80 00       	push   $0x803c9f
  80189c:	e8 e0 02 00 00       	call   801b81 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8018a1:	83 c4 08             	add    $0x8,%esp
  8018a4:	6a 00                	push   $0x0
  8018a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a9:	e8 34 f5 ff ff       	call   800de2 <file_set_size>
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	79 12                	jns    8018c7 <fs_test+0x252>
		panic("file_set_size: %e", r);
  8018b5:	50                   	push   %eax
  8018b6:	68 b3 3c 80 00       	push   $0x803cb3
  8018bb:	6a 33                	push   $0x33
  8018bd:	68 b7 3b 80 00       	push   $0x803bb7
  8018c2:	e8 e1 01 00 00       	call   801aa8 <_panic>
	assert(f->f_direct[0] == 0);
  8018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ca:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018d1:	74 16                	je     8018e9 <fs_test+0x274>
  8018d3:	68 c5 3c 80 00       	push   $0x803cc5
  8018d8:	68 7d 38 80 00       	push   $0x80387d
  8018dd:	6a 34                	push   $0x34
  8018df:	68 b7 3b 80 00       	push   $0x803bb7
  8018e4:	e8 bf 01 00 00       	call   801aa8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018e9:	c1 e8 0c             	shr    $0xc,%eax
  8018ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f3:	a8 40                	test   $0x40,%al
  8018f5:	74 16                	je     80190d <fs_test+0x298>
  8018f7:	68 d9 3c 80 00       	push   $0x803cd9
  8018fc:	68 7d 38 80 00       	push   $0x80387d
  801901:	6a 35                	push   $0x35
  801903:	68 b7 3b 80 00       	push   $0x803bb7
  801908:	e8 9b 01 00 00       	call   801aa8 <_panic>
	cprintf("file_truncate is good\n");
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	68 f3 3c 80 00       	push   $0x803cf3
  801915:	e8 67 02 00 00       	call   801b81 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80191a:	c7 04 24 8c 3d 80 00 	movl   $0x803d8c,(%esp)
  801921:	e8 c5 07 00 00       	call   8020eb <strlen>
  801926:	83 c4 08             	add    $0x8,%esp
  801929:	50                   	push   %eax
  80192a:	ff 75 f4             	pushl  -0xc(%ebp)
  80192d:	e8 b0 f4 ff ff       	call   800de2 <file_set_size>
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	79 12                	jns    80194b <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801939:	50                   	push   %eax
  80193a:	68 0a 3d 80 00       	push   $0x803d0a
  80193f:	6a 39                	push   $0x39
  801941:	68 b7 3b 80 00       	push   $0x803bb7
  801946:	e8 5d 01 00 00       	call   801aa8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194e:	89 c2                	mov    %eax,%edx
  801950:	c1 ea 0c             	shr    $0xc,%edx
  801953:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80195a:	f6 c2 40             	test   $0x40,%dl
  80195d:	74 16                	je     801975 <fs_test+0x300>
  80195f:	68 d9 3c 80 00       	push   $0x803cd9
  801964:	68 7d 38 80 00       	push   $0x80387d
  801969:	6a 3a                	push   $0x3a
  80196b:	68 b7 3b 80 00       	push   $0x803bb7
  801970:	e8 33 01 00 00       	call   801aa8 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801975:	83 ec 04             	sub    $0x4,%esp
  801978:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80197b:	52                   	push   %edx
  80197c:	6a 00                	push   $0x0
  80197e:	50                   	push   %eax
  80197f:	e8 f0 f0 ff ff       	call   800a74 <file_get_block>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	79 12                	jns    80199d <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80198b:	50                   	push   %eax
  80198c:	68 1e 3d 80 00       	push   $0x803d1e
  801991:	6a 3c                	push   $0x3c
  801993:	68 b7 3b 80 00       	push   $0x803bb7
  801998:	e8 0b 01 00 00       	call   801aa8 <_panic>
	strcpy(blk, msg);
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	68 8c 3d 80 00       	push   $0x803d8c
  8019a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a8:	e8 77 07 00 00       	call   802124 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b0:	c1 e8 0c             	shr    $0xc,%eax
  8019b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	a8 40                	test   $0x40,%al
  8019bf:	75 16                	jne    8019d7 <fs_test+0x362>
  8019c1:	68 84 3c 80 00       	push   $0x803c84
  8019c6:	68 7d 38 80 00       	push   $0x80387d
  8019cb:	6a 3e                	push   $0x3e
  8019cd:	68 b7 3b 80 00       	push   $0x803bb7
  8019d2:	e8 d1 00 00 00       	call   801aa8 <_panic>
	file_flush(f);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	e8 87 f5 ff ff       	call   800f69 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e5:	c1 e8 0c             	shr    $0xc,%eax
  8019e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	a8 40                	test   $0x40,%al
  8019f4:	74 16                	je     801a0c <fs_test+0x397>
  8019f6:	68 83 3c 80 00       	push   $0x803c83
  8019fb:	68 7d 38 80 00       	push   $0x80387d
  801a00:	6a 40                	push   $0x40
  801a02:	68 b7 3b 80 00       	push   $0x803bb7
  801a07:	e8 9c 00 00 00       	call   801aa8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0f:	c1 e8 0c             	shr    $0xc,%eax
  801a12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a19:	a8 40                	test   $0x40,%al
  801a1b:	74 16                	je     801a33 <fs_test+0x3be>
  801a1d:	68 d9 3c 80 00       	push   $0x803cd9
  801a22:	68 7d 38 80 00       	push   $0x80387d
  801a27:	6a 41                	push   $0x41
  801a29:	68 b7 3b 80 00       	push   $0x803bb7
  801a2e:	e8 75 00 00 00       	call   801aa8 <_panic>
	cprintf("file rewrite is good\n");
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	68 33 3d 80 00       	push   $0x803d33
  801a3b:	e8 41 01 00 00       	call   801b81 <cprintf>
}
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a50:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  801a53:	e8 91 0a 00 00       	call   8024e9 <sys_getenvid>
  801a58:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a5d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a65:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	7e 07                	jle    801a75 <libmain+0x2d>
		binaryname = argv[0];
  801a6e:	8b 06                	mov    (%esi),%eax
  801a70:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	e8 b0 fb ff ff       	call   80162f <umain>

	// exit gracefully
	exit();
  801a7f:	e8 0a 00 00 00       	call   801a8e <exit>
}
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801a94:	e8 b8 0f 00 00       	call   802a51 <close_all>
	sys_env_destroy(0);
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	6a 00                	push   $0x0
  801a9e:	e8 05 0a 00 00       	call   8024a8 <sys_env_destroy>
}
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aad:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ab0:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ab6:	e8 2e 0a 00 00       	call   8024e9 <sys_getenvid>
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	ff 75 0c             	pushl  0xc(%ebp)
  801ac1:	ff 75 08             	pushl  0x8(%ebp)
  801ac4:	56                   	push   %esi
  801ac5:	50                   	push   %eax
  801ac6:	68 e4 3d 80 00       	push   $0x803de4
  801acb:	e8 b1 00 00 00       	call   801b81 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ad0:	83 c4 18             	add    $0x18,%esp
  801ad3:	53                   	push   %ebx
  801ad4:	ff 75 10             	pushl  0x10(%ebp)
  801ad7:	e8 54 00 00 00       	call   801b30 <vcprintf>
	cprintf("\n");
  801adc:	c7 04 24 f5 39 80 00 	movl   $0x8039f5,(%esp)
  801ae3:	e8 99 00 00 00       	call   801b81 <cprintf>
  801ae8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aeb:	cc                   	int3   
  801aec:	eb fd                	jmp    801aeb <_panic+0x43>

00801aee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	53                   	push   %ebx
  801af2:	83 ec 04             	sub    $0x4,%esp
  801af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801af8:	8b 13                	mov    (%ebx),%edx
  801afa:	8d 42 01             	lea    0x1(%edx),%eax
  801afd:	89 03                	mov    %eax,(%ebx)
  801aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b06:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b0b:	75 1a                	jne    801b27 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b0d:	83 ec 08             	sub    $0x8,%esp
  801b10:	68 ff 00 00 00       	push   $0xff
  801b15:	8d 43 08             	lea    0x8(%ebx),%eax
  801b18:	50                   	push   %eax
  801b19:	e8 4d 09 00 00       	call   80246b <sys_cputs>
		b->idx = 0;
  801b1e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b24:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b27:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b39:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b40:	00 00 00 
	b.cnt = 0;
  801b43:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b4a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	ff 75 08             	pushl  0x8(%ebp)
  801b53:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b59:	50                   	push   %eax
  801b5a:	68 ee 1a 80 00       	push   $0x801aee
  801b5f:	e8 54 01 00 00       	call   801cb8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b64:	83 c4 08             	add    $0x8,%esp
  801b67:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b6d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b73:	50                   	push   %eax
  801b74:	e8 f2 08 00 00       	call   80246b <sys_cputs>

	return b.cnt;
}
  801b79:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b87:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b8a:	50                   	push   %eax
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	e8 9d ff ff ff       	call   801b30 <vcprintf>
	va_end(ap);

	return cnt;
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	57                   	push   %edi
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 1c             	sub    $0x1c,%esp
  801b9e:	89 c7                	mov    %eax,%edi
  801ba0:	89 d6                	mov    %edx,%esi
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bab:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801bb9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bbc:	39 d3                	cmp    %edx,%ebx
  801bbe:	72 05                	jb     801bc5 <printnum+0x30>
  801bc0:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bc3:	77 45                	ja     801c0a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 18             	pushl  0x18(%ebp)
  801bcb:	8b 45 14             	mov    0x14(%ebp),%eax
  801bce:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bd1:	53                   	push   %ebx
  801bd2:	ff 75 10             	pushl  0x10(%ebp)
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bdb:	ff 75 e0             	pushl  -0x20(%ebp)
  801bde:	ff 75 dc             	pushl  -0x24(%ebp)
  801be1:	ff 75 d8             	pushl  -0x28(%ebp)
  801be4:	e8 c7 19 00 00       	call   8035b0 <__udivdi3>
  801be9:	83 c4 18             	add    $0x18,%esp
  801bec:	52                   	push   %edx
  801bed:	50                   	push   %eax
  801bee:	89 f2                	mov    %esi,%edx
  801bf0:	89 f8                	mov    %edi,%eax
  801bf2:	e8 9e ff ff ff       	call   801b95 <printnum>
  801bf7:	83 c4 20             	add    $0x20,%esp
  801bfa:	eb 18                	jmp    801c14 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	56                   	push   %esi
  801c00:	ff 75 18             	pushl  0x18(%ebp)
  801c03:	ff d7                	call   *%edi
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	eb 03                	jmp    801c0d <printnum+0x78>
  801c0a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c0d:	83 eb 01             	sub    $0x1,%ebx
  801c10:	85 db                	test   %ebx,%ebx
  801c12:	7f e8                	jg     801bfc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c14:	83 ec 08             	sub    $0x8,%esp
  801c17:	56                   	push   %esi
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1e:	ff 75 e0             	pushl  -0x20(%ebp)
  801c21:	ff 75 dc             	pushl  -0x24(%ebp)
  801c24:	ff 75 d8             	pushl  -0x28(%ebp)
  801c27:	e8 b4 1a 00 00       	call   8036e0 <__umoddi3>
  801c2c:	83 c4 14             	add    $0x14,%esp
  801c2f:	0f be 80 07 3e 80 00 	movsbl 0x803e07(%eax),%eax
  801c36:	50                   	push   %eax
  801c37:	ff d7                	call   *%edi
}
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c47:	83 fa 01             	cmp    $0x1,%edx
  801c4a:	7e 0e                	jle    801c5a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c4c:	8b 10                	mov    (%eax),%edx
  801c4e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c51:	89 08                	mov    %ecx,(%eax)
  801c53:	8b 02                	mov    (%edx),%eax
  801c55:	8b 52 04             	mov    0x4(%edx),%edx
  801c58:	eb 22                	jmp    801c7c <getuint+0x38>
	else if (lflag)
  801c5a:	85 d2                	test   %edx,%edx
  801c5c:	74 10                	je     801c6e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c5e:	8b 10                	mov    (%eax),%edx
  801c60:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c63:	89 08                	mov    %ecx,(%eax)
  801c65:	8b 02                	mov    (%edx),%eax
  801c67:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6c:	eb 0e                	jmp    801c7c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c6e:	8b 10                	mov    (%eax),%edx
  801c70:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c73:	89 08                	mov    %ecx,(%eax)
  801c75:	8b 02                	mov    (%edx),%eax
  801c77:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c84:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c88:	8b 10                	mov    (%eax),%edx
  801c8a:	3b 50 04             	cmp    0x4(%eax),%edx
  801c8d:	73 0a                	jae    801c99 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c8f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c92:	89 08                	mov    %ecx,(%eax)
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	88 02                	mov    %al,(%edx)
}
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801ca1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801ca4:	50                   	push   %eax
  801ca5:	ff 75 10             	pushl  0x10(%ebp)
  801ca8:	ff 75 0c             	pushl  0xc(%ebp)
  801cab:	ff 75 08             	pushl  0x8(%ebp)
  801cae:	e8 05 00 00 00       	call   801cb8 <vprintfmt>
	va_end(ap);
}
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    

00801cb8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 2c             	sub    $0x2c,%esp
  801cc1:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cc7:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cca:	eb 12                	jmp    801cde <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	0f 84 a7 03 00 00    	je     80207b <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  801cd4:	83 ec 08             	sub    $0x8,%esp
  801cd7:	53                   	push   %ebx
  801cd8:	50                   	push   %eax
  801cd9:	ff d6                	call   *%esi
  801cdb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801cde:	83 c7 01             	add    $0x1,%edi
  801ce1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ce5:	83 f8 25             	cmp    $0x25,%eax
  801ce8:	75 e2                	jne    801ccc <vprintfmt+0x14>
  801cea:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801cee:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cf5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801cfc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d03:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801d0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d0f:	eb 07                	jmp    801d18 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d11:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d14:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d18:	8d 47 01             	lea    0x1(%edi),%eax
  801d1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d1e:	0f b6 07             	movzbl (%edi),%eax
  801d21:	0f b6 d0             	movzbl %al,%edx
  801d24:	83 e8 23             	sub    $0x23,%eax
  801d27:	3c 55                	cmp    $0x55,%al
  801d29:	0f 87 31 03 00 00    	ja     802060 <vprintfmt+0x3a8>
  801d2f:	0f b6 c0             	movzbl %al,%eax
  801d32:	ff 24 85 40 3f 80 00 	jmp    *0x803f40(,%eax,4)
  801d39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d3c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d40:	eb d6                	jmp    801d18 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4a:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d4d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d50:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801d54:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801d57:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d5a:	83 fe 09             	cmp    $0x9,%esi
  801d5d:	77 34                	ja     801d93 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d5f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d62:	eb e9                	jmp    801d4d <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d64:	8b 45 14             	mov    0x14(%ebp),%eax
  801d67:	8d 50 04             	lea    0x4(%eax),%edx
  801d6a:	89 55 14             	mov    %edx,0x14(%ebp)
  801d6d:	8b 00                	mov    (%eax),%eax
  801d6f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d75:	eb 22                	jmp    801d99 <vprintfmt+0xe1>
  801d77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	0f 48 c1             	cmovs  %ecx,%eax
  801d7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d85:	eb 91                	jmp    801d18 <vprintfmt+0x60>
  801d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d8a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d91:	eb 85                	jmp    801d18 <vprintfmt+0x60>
  801d93:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801d96:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  801d99:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d9d:	0f 89 75 ff ff ff    	jns    801d18 <vprintfmt+0x60>
				width = precision, precision = -1;
  801da3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801da6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801da9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801db0:	e9 63 ff ff ff       	jmp    801d18 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801db5:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801db9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801dbc:	e9 57 ff ff ff       	jmp    801d18 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801dc1:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc4:	8d 50 04             	lea    0x4(%eax),%edx
  801dc7:	89 55 14             	mov    %edx,0x14(%ebp)
  801dca:	83 ec 08             	sub    $0x8,%esp
  801dcd:	53                   	push   %ebx
  801dce:	ff 30                	pushl  (%eax)
  801dd0:	ff d6                	call   *%esi
			break;
  801dd2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801dd8:	e9 01 ff ff ff       	jmp    801cde <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ddd:	8b 45 14             	mov    0x14(%ebp),%eax
  801de0:	8d 50 04             	lea    0x4(%eax),%edx
  801de3:	89 55 14             	mov    %edx,0x14(%ebp)
  801de6:	8b 00                	mov    (%eax),%eax
  801de8:	99                   	cltd   
  801de9:	31 d0                	xor    %edx,%eax
  801deb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801ded:	83 f8 0f             	cmp    $0xf,%eax
  801df0:	7f 0b                	jg     801dfd <vprintfmt+0x145>
  801df2:	8b 14 85 a0 40 80 00 	mov    0x8040a0(,%eax,4),%edx
  801df9:	85 d2                	test   %edx,%edx
  801dfb:	75 18                	jne    801e15 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  801dfd:	50                   	push   %eax
  801dfe:	68 1f 3e 80 00       	push   $0x803e1f
  801e03:	53                   	push   %ebx
  801e04:	56                   	push   %esi
  801e05:	e8 91 fe ff ff       	call   801c9b <printfmt>
  801e0a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e10:	e9 c9 fe ff ff       	jmp    801cde <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801e15:	52                   	push   %edx
  801e16:	68 8f 38 80 00       	push   $0x80388f
  801e1b:	53                   	push   %ebx
  801e1c:	56                   	push   %esi
  801e1d:	e8 79 fe ff ff       	call   801c9b <printfmt>
  801e22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e28:	e9 b1 fe ff ff       	jmp    801cde <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e30:	8d 50 04             	lea    0x4(%eax),%edx
  801e33:	89 55 14             	mov    %edx,0x14(%ebp)
  801e36:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e38:	85 ff                	test   %edi,%edi
  801e3a:	b8 18 3e 80 00       	mov    $0x803e18,%eax
  801e3f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e46:	0f 8e 94 00 00 00    	jle    801ee0 <vprintfmt+0x228>
  801e4c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e50:	0f 84 98 00 00 00    	je     801eee <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	ff 75 cc             	pushl  -0x34(%ebp)
  801e5c:	57                   	push   %edi
  801e5d:	e8 a1 02 00 00       	call   802103 <strnlen>
  801e62:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e65:	29 c1                	sub    %eax,%ecx
  801e67:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801e6a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e6d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e74:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e77:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e79:	eb 0f                	jmp    801e8a <vprintfmt+0x1d2>
					putch(padc, putdat);
  801e7b:	83 ec 08             	sub    $0x8,%esp
  801e7e:	53                   	push   %ebx
  801e7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801e82:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e84:	83 ef 01             	sub    $0x1,%edi
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	85 ff                	test   %edi,%edi
  801e8c:	7f ed                	jg     801e7b <vprintfmt+0x1c3>
  801e8e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e91:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801e94:	85 c9                	test   %ecx,%ecx
  801e96:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9b:	0f 49 c1             	cmovns %ecx,%eax
  801e9e:	29 c1                	sub    %eax,%ecx
  801ea0:	89 75 08             	mov    %esi,0x8(%ebp)
  801ea3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801ea6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ea9:	89 cb                	mov    %ecx,%ebx
  801eab:	eb 4d                	jmp    801efa <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801ead:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801eb1:	74 1b                	je     801ece <vprintfmt+0x216>
  801eb3:	0f be c0             	movsbl %al,%eax
  801eb6:	83 e8 20             	sub    $0x20,%eax
  801eb9:	83 f8 5e             	cmp    $0x5e,%eax
  801ebc:	76 10                	jbe    801ece <vprintfmt+0x216>
					putch('?', putdat);
  801ebe:	83 ec 08             	sub    $0x8,%esp
  801ec1:	ff 75 0c             	pushl  0xc(%ebp)
  801ec4:	6a 3f                	push   $0x3f
  801ec6:	ff 55 08             	call   *0x8(%ebp)
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	eb 0d                	jmp    801edb <vprintfmt+0x223>
				else
					putch(ch, putdat);
  801ece:	83 ec 08             	sub    $0x8,%esp
  801ed1:	ff 75 0c             	pushl  0xc(%ebp)
  801ed4:	52                   	push   %edx
  801ed5:	ff 55 08             	call   *0x8(%ebp)
  801ed8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801edb:	83 eb 01             	sub    $0x1,%ebx
  801ede:	eb 1a                	jmp    801efa <vprintfmt+0x242>
  801ee0:	89 75 08             	mov    %esi,0x8(%ebp)
  801ee3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801ee6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ee9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801eec:	eb 0c                	jmp    801efa <vprintfmt+0x242>
  801eee:	89 75 08             	mov    %esi,0x8(%ebp)
  801ef1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  801ef4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ef7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801efa:	83 c7 01             	add    $0x1,%edi
  801efd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f01:	0f be d0             	movsbl %al,%edx
  801f04:	85 d2                	test   %edx,%edx
  801f06:	74 23                	je     801f2b <vprintfmt+0x273>
  801f08:	85 f6                	test   %esi,%esi
  801f0a:	78 a1                	js     801ead <vprintfmt+0x1f5>
  801f0c:	83 ee 01             	sub    $0x1,%esi
  801f0f:	79 9c                	jns    801ead <vprintfmt+0x1f5>
  801f11:	89 df                	mov    %ebx,%edi
  801f13:	8b 75 08             	mov    0x8(%ebp),%esi
  801f16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f19:	eb 18                	jmp    801f33 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f1b:	83 ec 08             	sub    $0x8,%esp
  801f1e:	53                   	push   %ebx
  801f1f:	6a 20                	push   $0x20
  801f21:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f23:	83 ef 01             	sub    $0x1,%edi
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	eb 08                	jmp    801f33 <vprintfmt+0x27b>
  801f2b:	89 df                	mov    %ebx,%edi
  801f2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f33:	85 ff                	test   %edi,%edi
  801f35:	7f e4                	jg     801f1b <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f3a:	e9 9f fd ff ff       	jmp    801cde <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f3f:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  801f43:	7e 16                	jle    801f5b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  801f45:	8b 45 14             	mov    0x14(%ebp),%eax
  801f48:	8d 50 08             	lea    0x8(%eax),%edx
  801f4b:	89 55 14             	mov    %edx,0x14(%ebp)
  801f4e:	8b 50 04             	mov    0x4(%eax),%edx
  801f51:	8b 00                	mov    (%eax),%eax
  801f53:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f56:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f59:	eb 34                	jmp    801f8f <vprintfmt+0x2d7>
	else if (lflag)
  801f5b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801f5f:	74 18                	je     801f79 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  801f61:	8b 45 14             	mov    0x14(%ebp),%eax
  801f64:	8d 50 04             	lea    0x4(%eax),%edx
  801f67:	89 55 14             	mov    %edx,0x14(%ebp)
  801f6a:	8b 00                	mov    (%eax),%eax
  801f6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f6f:	89 c1                	mov    %eax,%ecx
  801f71:	c1 f9 1f             	sar    $0x1f,%ecx
  801f74:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f77:	eb 16                	jmp    801f8f <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  801f79:	8b 45 14             	mov    0x14(%ebp),%eax
  801f7c:	8d 50 04             	lea    0x4(%eax),%edx
  801f7f:	89 55 14             	mov    %edx,0x14(%ebp)
  801f82:	8b 00                	mov    (%eax),%eax
  801f84:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f87:	89 c1                	mov    %eax,%ecx
  801f89:	c1 f9 1f             	sar    $0x1f,%ecx
  801f8c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f92:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f95:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f9a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f9e:	0f 89 88 00 00 00    	jns    80202c <vprintfmt+0x374>
				putch('-', putdat);
  801fa4:	83 ec 08             	sub    $0x8,%esp
  801fa7:	53                   	push   %ebx
  801fa8:	6a 2d                	push   $0x2d
  801faa:	ff d6                	call   *%esi
				num = -(long long) num;
  801fac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801faf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fb2:	f7 d8                	neg    %eax
  801fb4:	83 d2 00             	adc    $0x0,%edx
  801fb7:	f7 da                	neg    %edx
  801fb9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801fbc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801fc1:	eb 69                	jmp    80202c <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801fc3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801fc6:	8d 45 14             	lea    0x14(%ebp),%eax
  801fc9:	e8 76 fc ff ff       	call   801c44 <getuint>
			base = 10;
  801fce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801fd3:	eb 57                	jmp    80202c <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	53                   	push   %ebx
  801fd9:	6a 30                	push   $0x30
  801fdb:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  801fdd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801fe0:	8d 45 14             	lea    0x14(%ebp),%eax
  801fe3:	e8 5c fc ff ff       	call   801c44 <getuint>
			base = 8;
			goto number;
  801fe8:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801feb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801ff0:	eb 3a                	jmp    80202c <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801ff2:	83 ec 08             	sub    $0x8,%esp
  801ff5:	53                   	push   %ebx
  801ff6:	6a 30                	push   $0x30
  801ff8:	ff d6                	call   *%esi
			putch('x', putdat);
  801ffa:	83 c4 08             	add    $0x8,%esp
  801ffd:	53                   	push   %ebx
  801ffe:	6a 78                	push   $0x78
  802000:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802002:	8b 45 14             	mov    0x14(%ebp),%eax
  802005:	8d 50 04             	lea    0x4(%eax),%edx
  802008:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80200b:	8b 00                	mov    (%eax),%eax
  80200d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802012:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  802015:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80201a:	eb 10                	jmp    80202c <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80201c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80201f:	8d 45 14             	lea    0x14(%ebp),%eax
  802022:	e8 1d fc ff ff       	call   801c44 <getuint>
			base = 16;
  802027:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80202c:	83 ec 0c             	sub    $0xc,%esp
  80202f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802033:	57                   	push   %edi
  802034:	ff 75 e0             	pushl  -0x20(%ebp)
  802037:	51                   	push   %ecx
  802038:	52                   	push   %edx
  802039:	50                   	push   %eax
  80203a:	89 da                	mov    %ebx,%edx
  80203c:	89 f0                	mov    %esi,%eax
  80203e:	e8 52 fb ff ff       	call   801b95 <printnum>
			break;
  802043:	83 c4 20             	add    $0x20,%esp
  802046:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802049:	e9 90 fc ff ff       	jmp    801cde <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80204e:	83 ec 08             	sub    $0x8,%esp
  802051:	53                   	push   %ebx
  802052:	52                   	push   %edx
  802053:	ff d6                	call   *%esi
			break;
  802055:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802058:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80205b:	e9 7e fc ff ff       	jmp    801cde <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802060:	83 ec 08             	sub    $0x8,%esp
  802063:	53                   	push   %ebx
  802064:	6a 25                	push   $0x25
  802066:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	eb 03                	jmp    802070 <vprintfmt+0x3b8>
  80206d:	83 ef 01             	sub    $0x1,%edi
  802070:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802074:	75 f7                	jne    80206d <vprintfmt+0x3b5>
  802076:	e9 63 fc ff ff       	jmp    801cde <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80207b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207e:	5b                   	pop    %ebx
  80207f:	5e                   	pop    %esi
  802080:	5f                   	pop    %edi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    

00802083 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	83 ec 18             	sub    $0x18,%esp
  802089:	8b 45 08             	mov    0x8(%ebp),%eax
  80208c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80208f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802092:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802096:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802099:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	74 26                	je     8020ca <vsnprintf+0x47>
  8020a4:	85 d2                	test   %edx,%edx
  8020a6:	7e 22                	jle    8020ca <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8020a8:	ff 75 14             	pushl  0x14(%ebp)
  8020ab:	ff 75 10             	pushl  0x10(%ebp)
  8020ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8020b1:	50                   	push   %eax
  8020b2:	68 7e 1c 80 00       	push   $0x801c7e
  8020b7:	e8 fc fb ff ff       	call   801cb8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8020bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8020c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c5:	83 c4 10             	add    $0x10,%esp
  8020c8:	eb 05                	jmp    8020cf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8020ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8020cf:	c9                   	leave  
  8020d0:	c3                   	ret    

008020d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8020d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8020da:	50                   	push   %eax
  8020db:	ff 75 10             	pushl  0x10(%ebp)
  8020de:	ff 75 0c             	pushl  0xc(%ebp)
  8020e1:	ff 75 08             	pushl  0x8(%ebp)
  8020e4:	e8 9a ff ff ff       	call   802083 <vsnprintf>
	va_end(ap);

	return rc;
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8020f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f6:	eb 03                	jmp    8020fb <strlen+0x10>
		n++;
  8020f8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8020fb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8020ff:	75 f7                	jne    8020f8 <strlen+0xd>
		n++;
	return n;
}
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802109:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80210c:	ba 00 00 00 00       	mov    $0x0,%edx
  802111:	eb 03                	jmp    802116 <strnlen+0x13>
		n++;
  802113:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802116:	39 c2                	cmp    %eax,%edx
  802118:	74 08                	je     802122 <strnlen+0x1f>
  80211a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80211e:	75 f3                	jne    802113 <strnlen+0x10>
  802120:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	53                   	push   %ebx
  802128:	8b 45 08             	mov    0x8(%ebp),%eax
  80212b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80212e:	89 c2                	mov    %eax,%edx
  802130:	83 c2 01             	add    $0x1,%edx
  802133:	83 c1 01             	add    $0x1,%ecx
  802136:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80213a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80213d:	84 db                	test   %bl,%bl
  80213f:	75 ef                	jne    802130 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802141:	5b                   	pop    %ebx
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    

00802144 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	53                   	push   %ebx
  802148:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80214b:	53                   	push   %ebx
  80214c:	e8 9a ff ff ff       	call   8020eb <strlen>
  802151:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802154:	ff 75 0c             	pushl  0xc(%ebp)
  802157:	01 d8                	add    %ebx,%eax
  802159:	50                   	push   %eax
  80215a:	e8 c5 ff ff ff       	call   802124 <strcpy>
	return dst;
}
  80215f:	89 d8                	mov    %ebx,%eax
  802161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	56                   	push   %esi
  80216a:	53                   	push   %ebx
  80216b:	8b 75 08             	mov    0x8(%ebp),%esi
  80216e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802171:	89 f3                	mov    %esi,%ebx
  802173:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802176:	89 f2                	mov    %esi,%edx
  802178:	eb 0f                	jmp    802189 <strncpy+0x23>
		*dst++ = *src;
  80217a:	83 c2 01             	add    $0x1,%edx
  80217d:	0f b6 01             	movzbl (%ecx),%eax
  802180:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802183:	80 39 01             	cmpb   $0x1,(%ecx)
  802186:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802189:	39 da                	cmp    %ebx,%edx
  80218b:	75 ed                	jne    80217a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80218d:	89 f0                	mov    %esi,%eax
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    

00802193 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
  802198:	8b 75 08             	mov    0x8(%ebp),%esi
  80219b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80219e:	8b 55 10             	mov    0x10(%ebp),%edx
  8021a1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8021a3:	85 d2                	test   %edx,%edx
  8021a5:	74 21                	je     8021c8 <strlcpy+0x35>
  8021a7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8021ab:	89 f2                	mov    %esi,%edx
  8021ad:	eb 09                	jmp    8021b8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8021af:	83 c2 01             	add    $0x1,%edx
  8021b2:	83 c1 01             	add    $0x1,%ecx
  8021b5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8021b8:	39 c2                	cmp    %eax,%edx
  8021ba:	74 09                	je     8021c5 <strlcpy+0x32>
  8021bc:	0f b6 19             	movzbl (%ecx),%ebx
  8021bf:	84 db                	test   %bl,%bl
  8021c1:	75 ec                	jne    8021af <strlcpy+0x1c>
  8021c3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8021c5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8021c8:	29 f0                	sub    %esi,%eax
}
  8021ca:	5b                   	pop    %ebx
  8021cb:	5e                   	pop    %esi
  8021cc:	5d                   	pop    %ebp
  8021cd:	c3                   	ret    

008021ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8021d7:	eb 06                	jmp    8021df <strcmp+0x11>
		p++, q++;
  8021d9:	83 c1 01             	add    $0x1,%ecx
  8021dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8021df:	0f b6 01             	movzbl (%ecx),%eax
  8021e2:	84 c0                	test   %al,%al
  8021e4:	74 04                	je     8021ea <strcmp+0x1c>
  8021e6:	3a 02                	cmp    (%edx),%al
  8021e8:	74 ef                	je     8021d9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8021ea:	0f b6 c0             	movzbl %al,%eax
  8021ed:	0f b6 12             	movzbl (%edx),%edx
  8021f0:	29 d0                	sub    %edx,%eax
}
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    

008021f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	53                   	push   %ebx
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021fe:	89 c3                	mov    %eax,%ebx
  802200:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802203:	eb 06                	jmp    80220b <strncmp+0x17>
		n--, p++, q++;
  802205:	83 c0 01             	add    $0x1,%eax
  802208:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80220b:	39 d8                	cmp    %ebx,%eax
  80220d:	74 15                	je     802224 <strncmp+0x30>
  80220f:	0f b6 08             	movzbl (%eax),%ecx
  802212:	84 c9                	test   %cl,%cl
  802214:	74 04                	je     80221a <strncmp+0x26>
  802216:	3a 0a                	cmp    (%edx),%cl
  802218:	74 eb                	je     802205 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80221a:	0f b6 00             	movzbl (%eax),%eax
  80221d:	0f b6 12             	movzbl (%edx),%edx
  802220:	29 d0                	sub    %edx,%eax
  802222:	eb 05                	jmp    802229 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802224:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802229:	5b                   	pop    %ebx
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    

0080222c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	8b 45 08             	mov    0x8(%ebp),%eax
  802232:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802236:	eb 07                	jmp    80223f <strchr+0x13>
		if (*s == c)
  802238:	38 ca                	cmp    %cl,%dl
  80223a:	74 0f                	je     80224b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80223c:	83 c0 01             	add    $0x1,%eax
  80223f:	0f b6 10             	movzbl (%eax),%edx
  802242:	84 d2                	test   %dl,%dl
  802244:	75 f2                	jne    802238 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802246:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    

0080224d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	8b 45 08             	mov    0x8(%ebp),%eax
  802253:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802257:	eb 03                	jmp    80225c <strfind+0xf>
  802259:	83 c0 01             	add    $0x1,%eax
  80225c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80225f:	38 ca                	cmp    %cl,%dl
  802261:	74 04                	je     802267 <strfind+0x1a>
  802263:	84 d2                	test   %dl,%dl
  802265:	75 f2                	jne    802259 <strfind+0xc>
			break;
	return (char *) s;
}
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    

00802269 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	57                   	push   %edi
  80226d:	56                   	push   %esi
  80226e:	53                   	push   %ebx
  80226f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802272:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802275:	85 c9                	test   %ecx,%ecx
  802277:	74 36                	je     8022af <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802279:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80227f:	75 28                	jne    8022a9 <memset+0x40>
  802281:	f6 c1 03             	test   $0x3,%cl
  802284:	75 23                	jne    8022a9 <memset+0x40>
		c &= 0xFF;
  802286:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80228a:	89 d3                	mov    %edx,%ebx
  80228c:	c1 e3 08             	shl    $0x8,%ebx
  80228f:	89 d6                	mov    %edx,%esi
  802291:	c1 e6 18             	shl    $0x18,%esi
  802294:	89 d0                	mov    %edx,%eax
  802296:	c1 e0 10             	shl    $0x10,%eax
  802299:	09 f0                	or     %esi,%eax
  80229b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80229d:	89 d8                	mov    %ebx,%eax
  80229f:	09 d0                	or     %edx,%eax
  8022a1:	c1 e9 02             	shr    $0x2,%ecx
  8022a4:	fc                   	cld    
  8022a5:	f3 ab                	rep stos %eax,%es:(%edi)
  8022a7:	eb 06                	jmp    8022af <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ac:	fc                   	cld    
  8022ad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8022af:	89 f8                	mov    %edi,%eax
  8022b1:	5b                   	pop    %ebx
  8022b2:	5e                   	pop    %esi
  8022b3:	5f                   	pop    %edi
  8022b4:	5d                   	pop    %ebp
  8022b5:	c3                   	ret    

008022b6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	57                   	push   %edi
  8022ba:	56                   	push   %esi
  8022bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8022c4:	39 c6                	cmp    %eax,%esi
  8022c6:	73 35                	jae    8022fd <memmove+0x47>
  8022c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8022cb:	39 d0                	cmp    %edx,%eax
  8022cd:	73 2e                	jae    8022fd <memmove+0x47>
		s += n;
		d += n;
  8022cf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022d2:	89 d6                	mov    %edx,%esi
  8022d4:	09 fe                	or     %edi,%esi
  8022d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8022dc:	75 13                	jne    8022f1 <memmove+0x3b>
  8022de:	f6 c1 03             	test   $0x3,%cl
  8022e1:	75 0e                	jne    8022f1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8022e3:	83 ef 04             	sub    $0x4,%edi
  8022e6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8022e9:	c1 e9 02             	shr    $0x2,%ecx
  8022ec:	fd                   	std    
  8022ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022ef:	eb 09                	jmp    8022fa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8022f1:	83 ef 01             	sub    $0x1,%edi
  8022f4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8022f7:	fd                   	std    
  8022f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8022fa:	fc                   	cld    
  8022fb:	eb 1d                	jmp    80231a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	09 c2                	or     %eax,%edx
  802301:	f6 c2 03             	test   $0x3,%dl
  802304:	75 0f                	jne    802315 <memmove+0x5f>
  802306:	f6 c1 03             	test   $0x3,%cl
  802309:	75 0a                	jne    802315 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80230b:	c1 e9 02             	shr    $0x2,%ecx
  80230e:	89 c7                	mov    %eax,%edi
  802310:	fc                   	cld    
  802311:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802313:	eb 05                	jmp    80231a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802315:	89 c7                	mov    %eax,%edi
  802317:	fc                   	cld    
  802318:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80231a:	5e                   	pop    %esi
  80231b:	5f                   	pop    %edi
  80231c:	5d                   	pop    %ebp
  80231d:	c3                   	ret    

0080231e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802321:	ff 75 10             	pushl  0x10(%ebp)
  802324:	ff 75 0c             	pushl  0xc(%ebp)
  802327:	ff 75 08             	pushl  0x8(%ebp)
  80232a:	e8 87 ff ff ff       	call   8022b6 <memmove>
}
  80232f:	c9                   	leave  
  802330:	c3                   	ret    

00802331 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802331:	55                   	push   %ebp
  802332:	89 e5                	mov    %esp,%ebp
  802334:	56                   	push   %esi
  802335:	53                   	push   %ebx
  802336:	8b 45 08             	mov    0x8(%ebp),%eax
  802339:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233c:	89 c6                	mov    %eax,%esi
  80233e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802341:	eb 1a                	jmp    80235d <memcmp+0x2c>
		if (*s1 != *s2)
  802343:	0f b6 08             	movzbl (%eax),%ecx
  802346:	0f b6 1a             	movzbl (%edx),%ebx
  802349:	38 d9                	cmp    %bl,%cl
  80234b:	74 0a                	je     802357 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80234d:	0f b6 c1             	movzbl %cl,%eax
  802350:	0f b6 db             	movzbl %bl,%ebx
  802353:	29 d8                	sub    %ebx,%eax
  802355:	eb 0f                	jmp    802366 <memcmp+0x35>
		s1++, s2++;
  802357:	83 c0 01             	add    $0x1,%eax
  80235a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80235d:	39 f0                	cmp    %esi,%eax
  80235f:	75 e2                	jne    802343 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802361:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802366:	5b                   	pop    %ebx
  802367:	5e                   	pop    %esi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    

0080236a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	53                   	push   %ebx
  80236e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802371:	89 c1                	mov    %eax,%ecx
  802373:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802376:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80237a:	eb 0a                	jmp    802386 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80237c:	0f b6 10             	movzbl (%eax),%edx
  80237f:	39 da                	cmp    %ebx,%edx
  802381:	74 07                	je     80238a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802383:	83 c0 01             	add    $0x1,%eax
  802386:	39 c8                	cmp    %ecx,%eax
  802388:	72 f2                	jb     80237c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80238a:	5b                   	pop    %ebx
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    

0080238d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	57                   	push   %edi
  802391:	56                   	push   %esi
  802392:	53                   	push   %ebx
  802393:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802396:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802399:	eb 03                	jmp    80239e <strtol+0x11>
		s++;
  80239b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80239e:	0f b6 01             	movzbl (%ecx),%eax
  8023a1:	3c 20                	cmp    $0x20,%al
  8023a3:	74 f6                	je     80239b <strtol+0xe>
  8023a5:	3c 09                	cmp    $0x9,%al
  8023a7:	74 f2                	je     80239b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8023a9:	3c 2b                	cmp    $0x2b,%al
  8023ab:	75 0a                	jne    8023b7 <strtol+0x2a>
		s++;
  8023ad:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8023b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8023b5:	eb 11                	jmp    8023c8 <strtol+0x3b>
  8023b7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8023bc:	3c 2d                	cmp    $0x2d,%al
  8023be:	75 08                	jne    8023c8 <strtol+0x3b>
		s++, neg = 1;
  8023c0:	83 c1 01             	add    $0x1,%ecx
  8023c3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8023c8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8023ce:	75 15                	jne    8023e5 <strtol+0x58>
  8023d0:	80 39 30             	cmpb   $0x30,(%ecx)
  8023d3:	75 10                	jne    8023e5 <strtol+0x58>
  8023d5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8023d9:	75 7c                	jne    802457 <strtol+0xca>
		s += 2, base = 16;
  8023db:	83 c1 02             	add    $0x2,%ecx
  8023de:	bb 10 00 00 00       	mov    $0x10,%ebx
  8023e3:	eb 16                	jmp    8023fb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8023e5:	85 db                	test   %ebx,%ebx
  8023e7:	75 12                	jne    8023fb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8023e9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023ee:	80 39 30             	cmpb   $0x30,(%ecx)
  8023f1:	75 08                	jne    8023fb <strtol+0x6e>
		s++, base = 8;
  8023f3:	83 c1 01             	add    $0x1,%ecx
  8023f6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8023fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802400:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802403:	0f b6 11             	movzbl (%ecx),%edx
  802406:	8d 72 d0             	lea    -0x30(%edx),%esi
  802409:	89 f3                	mov    %esi,%ebx
  80240b:	80 fb 09             	cmp    $0x9,%bl
  80240e:	77 08                	ja     802418 <strtol+0x8b>
			dig = *s - '0';
  802410:	0f be d2             	movsbl %dl,%edx
  802413:	83 ea 30             	sub    $0x30,%edx
  802416:	eb 22                	jmp    80243a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802418:	8d 72 9f             	lea    -0x61(%edx),%esi
  80241b:	89 f3                	mov    %esi,%ebx
  80241d:	80 fb 19             	cmp    $0x19,%bl
  802420:	77 08                	ja     80242a <strtol+0x9d>
			dig = *s - 'a' + 10;
  802422:	0f be d2             	movsbl %dl,%edx
  802425:	83 ea 57             	sub    $0x57,%edx
  802428:	eb 10                	jmp    80243a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80242a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80242d:	89 f3                	mov    %esi,%ebx
  80242f:	80 fb 19             	cmp    $0x19,%bl
  802432:	77 16                	ja     80244a <strtol+0xbd>
			dig = *s - 'A' + 10;
  802434:	0f be d2             	movsbl %dl,%edx
  802437:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80243a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80243d:	7d 0b                	jge    80244a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80243f:	83 c1 01             	add    $0x1,%ecx
  802442:	0f af 45 10          	imul   0x10(%ebp),%eax
  802446:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802448:	eb b9                	jmp    802403 <strtol+0x76>

	if (endptr)
  80244a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80244e:	74 0d                	je     80245d <strtol+0xd0>
		*endptr = (char *) s;
  802450:	8b 75 0c             	mov    0xc(%ebp),%esi
  802453:	89 0e                	mov    %ecx,(%esi)
  802455:	eb 06                	jmp    80245d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802457:	85 db                	test   %ebx,%ebx
  802459:	74 98                	je     8023f3 <strtol+0x66>
  80245b:	eb 9e                	jmp    8023fb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80245d:	89 c2                	mov    %eax,%edx
  80245f:	f7 da                	neg    %edx
  802461:	85 ff                	test   %edi,%edi
  802463:	0f 45 c2             	cmovne %edx,%eax
}
  802466:	5b                   	pop    %ebx
  802467:	5e                   	pop    %esi
  802468:	5f                   	pop    %edi
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    

0080246b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	57                   	push   %edi
  80246f:	56                   	push   %esi
  802470:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802471:	b8 00 00 00 00       	mov    $0x0,%eax
  802476:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802479:	8b 55 08             	mov    0x8(%ebp),%edx
  80247c:	89 c3                	mov    %eax,%ebx
  80247e:	89 c7                	mov    %eax,%edi
  802480:	89 c6                	mov    %eax,%esi
  802482:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802484:	5b                   	pop    %ebx
  802485:	5e                   	pop    %esi
  802486:	5f                   	pop    %edi
  802487:	5d                   	pop    %ebp
  802488:	c3                   	ret    

00802489 <sys_cgetc>:

int
sys_cgetc(void)
{
  802489:	55                   	push   %ebp
  80248a:	89 e5                	mov    %esp,%ebp
  80248c:	57                   	push   %edi
  80248d:	56                   	push   %esi
  80248e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80248f:	ba 00 00 00 00       	mov    $0x0,%edx
  802494:	b8 01 00 00 00       	mov    $0x1,%eax
  802499:	89 d1                	mov    %edx,%ecx
  80249b:	89 d3                	mov    %edx,%ebx
  80249d:	89 d7                	mov    %edx,%edi
  80249f:	89 d6                	mov    %edx,%esi
  8024a1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    

008024a8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	57                   	push   %edi
  8024ac:	56                   	push   %esi
  8024ad:	53                   	push   %ebx
  8024ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8024b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8024bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8024be:	89 cb                	mov    %ecx,%ebx
  8024c0:	89 cf                	mov    %ecx,%edi
  8024c2:	89 ce                	mov    %ecx,%esi
  8024c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	7e 17                	jle    8024e1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024ca:	83 ec 0c             	sub    $0xc,%esp
  8024cd:	50                   	push   %eax
  8024ce:	6a 03                	push   $0x3
  8024d0:	68 ff 40 80 00       	push   $0x8040ff
  8024d5:	6a 23                	push   $0x23
  8024d7:	68 1c 41 80 00       	push   $0x80411c
  8024dc:	e8 c7 f5 ff ff       	call   801aa8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8024e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    

008024e9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	57                   	push   %edi
  8024ed:	56                   	push   %esi
  8024ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8024f9:	89 d1                	mov    %edx,%ecx
  8024fb:	89 d3                	mov    %edx,%ebx
  8024fd:	89 d7                	mov    %edx,%edi
  8024ff:	89 d6                	mov    %edx,%esi
  802501:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    

00802508 <sys_yield>:

void
sys_yield(void)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	57                   	push   %edi
  80250c:	56                   	push   %esi
  80250d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80250e:	ba 00 00 00 00       	mov    $0x0,%edx
  802513:	b8 0b 00 00 00       	mov    $0xb,%eax
  802518:	89 d1                	mov    %edx,%ecx
  80251a:	89 d3                	mov    %edx,%ebx
  80251c:	89 d7                	mov    %edx,%edi
  80251e:	89 d6                	mov    %edx,%esi
  802520:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802522:	5b                   	pop    %ebx
  802523:	5e                   	pop    %esi
  802524:	5f                   	pop    %edi
  802525:	5d                   	pop    %ebp
  802526:	c3                   	ret    

00802527 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802527:	55                   	push   %ebp
  802528:	89 e5                	mov    %esp,%ebp
  80252a:	57                   	push   %edi
  80252b:	56                   	push   %esi
  80252c:	53                   	push   %ebx
  80252d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802530:	be 00 00 00 00       	mov    $0x0,%esi
  802535:	b8 04 00 00 00       	mov    $0x4,%eax
  80253a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80253d:	8b 55 08             	mov    0x8(%ebp),%edx
  802540:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802543:	89 f7                	mov    %esi,%edi
  802545:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802547:	85 c0                	test   %eax,%eax
  802549:	7e 17                	jle    802562 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80254b:	83 ec 0c             	sub    $0xc,%esp
  80254e:	50                   	push   %eax
  80254f:	6a 04                	push   $0x4
  802551:	68 ff 40 80 00       	push   $0x8040ff
  802556:	6a 23                	push   $0x23
  802558:	68 1c 41 80 00       	push   $0x80411c
  80255d:	e8 46 f5 ff ff       	call   801aa8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802562:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802565:	5b                   	pop    %ebx
  802566:	5e                   	pop    %esi
  802567:	5f                   	pop    %edi
  802568:	5d                   	pop    %ebp
  802569:	c3                   	ret    

0080256a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	57                   	push   %edi
  80256e:	56                   	push   %esi
  80256f:	53                   	push   %ebx
  802570:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802573:	b8 05 00 00 00       	mov    $0x5,%eax
  802578:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80257b:	8b 55 08             	mov    0x8(%ebp),%edx
  80257e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802581:	8b 7d 14             	mov    0x14(%ebp),%edi
  802584:	8b 75 18             	mov    0x18(%ebp),%esi
  802587:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802589:	85 c0                	test   %eax,%eax
  80258b:	7e 17                	jle    8025a4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80258d:	83 ec 0c             	sub    $0xc,%esp
  802590:	50                   	push   %eax
  802591:	6a 05                	push   $0x5
  802593:	68 ff 40 80 00       	push   $0x8040ff
  802598:	6a 23                	push   $0x23
  80259a:	68 1c 41 80 00       	push   $0x80411c
  80259f:	e8 04 f5 ff ff       	call   801aa8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8025a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a7:	5b                   	pop    %ebx
  8025a8:	5e                   	pop    %esi
  8025a9:	5f                   	pop    %edi
  8025aa:	5d                   	pop    %ebp
  8025ab:	c3                   	ret    

008025ac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8025ac:	55                   	push   %ebp
  8025ad:	89 e5                	mov    %esp,%ebp
  8025af:	57                   	push   %edi
  8025b0:	56                   	push   %esi
  8025b1:	53                   	push   %ebx
  8025b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8025bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8025c5:	89 df                	mov    %ebx,%edi
  8025c7:	89 de                	mov    %ebx,%esi
  8025c9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025cb:	85 c0                	test   %eax,%eax
  8025cd:	7e 17                	jle    8025e6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025cf:	83 ec 0c             	sub    $0xc,%esp
  8025d2:	50                   	push   %eax
  8025d3:	6a 06                	push   $0x6
  8025d5:	68 ff 40 80 00       	push   $0x8040ff
  8025da:	6a 23                	push   $0x23
  8025dc:	68 1c 41 80 00       	push   $0x80411c
  8025e1:	e8 c2 f4 ff ff       	call   801aa8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8025e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025e9:	5b                   	pop    %ebx
  8025ea:	5e                   	pop    %esi
  8025eb:	5f                   	pop    %edi
  8025ec:	5d                   	pop    %ebp
  8025ed:	c3                   	ret    

008025ee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8025ee:	55                   	push   %ebp
  8025ef:	89 e5                	mov    %esp,%ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025fc:	b8 08 00 00 00       	mov    $0x8,%eax
  802601:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802604:	8b 55 08             	mov    0x8(%ebp),%edx
  802607:	89 df                	mov    %ebx,%edi
  802609:	89 de                	mov    %ebx,%esi
  80260b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80260d:	85 c0                	test   %eax,%eax
  80260f:	7e 17                	jle    802628 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802611:	83 ec 0c             	sub    $0xc,%esp
  802614:	50                   	push   %eax
  802615:	6a 08                	push   $0x8
  802617:	68 ff 40 80 00       	push   $0x8040ff
  80261c:	6a 23                	push   $0x23
  80261e:	68 1c 41 80 00       	push   $0x80411c
  802623:	e8 80 f4 ff ff       	call   801aa8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80262b:	5b                   	pop    %ebx
  80262c:	5e                   	pop    %esi
  80262d:	5f                   	pop    %edi
  80262e:	5d                   	pop    %ebp
  80262f:	c3                   	ret    

00802630 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802630:	55                   	push   %ebp
  802631:	89 e5                	mov    %esp,%ebp
  802633:	57                   	push   %edi
  802634:	56                   	push   %esi
  802635:	53                   	push   %ebx
  802636:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802639:	bb 00 00 00 00       	mov    $0x0,%ebx
  80263e:	b8 09 00 00 00       	mov    $0x9,%eax
  802643:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802646:	8b 55 08             	mov    0x8(%ebp),%edx
  802649:	89 df                	mov    %ebx,%edi
  80264b:	89 de                	mov    %ebx,%esi
  80264d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80264f:	85 c0                	test   %eax,%eax
  802651:	7e 17                	jle    80266a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802653:	83 ec 0c             	sub    $0xc,%esp
  802656:	50                   	push   %eax
  802657:	6a 09                	push   $0x9
  802659:	68 ff 40 80 00       	push   $0x8040ff
  80265e:	6a 23                	push   $0x23
  802660:	68 1c 41 80 00       	push   $0x80411c
  802665:	e8 3e f4 ff ff       	call   801aa8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80266a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80266d:	5b                   	pop    %ebx
  80266e:	5e                   	pop    %esi
  80266f:	5f                   	pop    %edi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    

00802672 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802672:	55                   	push   %ebp
  802673:	89 e5                	mov    %esp,%ebp
  802675:	57                   	push   %edi
  802676:	56                   	push   %esi
  802677:	53                   	push   %ebx
  802678:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80267b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802680:	b8 0a 00 00 00       	mov    $0xa,%eax
  802685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802688:	8b 55 08             	mov    0x8(%ebp),%edx
  80268b:	89 df                	mov    %ebx,%edi
  80268d:	89 de                	mov    %ebx,%esi
  80268f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802691:	85 c0                	test   %eax,%eax
  802693:	7e 17                	jle    8026ac <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802695:	83 ec 0c             	sub    $0xc,%esp
  802698:	50                   	push   %eax
  802699:	6a 0a                	push   $0xa
  80269b:	68 ff 40 80 00       	push   $0x8040ff
  8026a0:	6a 23                	push   $0x23
  8026a2:	68 1c 41 80 00       	push   $0x80411c
  8026a7:	e8 fc f3 ff ff       	call   801aa8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8026ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    

008026b4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8026b4:	55                   	push   %ebp
  8026b5:	89 e5                	mov    %esp,%ebp
  8026b7:	57                   	push   %edi
  8026b8:	56                   	push   %esi
  8026b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ba:	be 00 00 00 00       	mov    $0x0,%esi
  8026bf:	b8 0c 00 00 00       	mov    $0xc,%eax
  8026c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8026d0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8026d2:	5b                   	pop    %ebx
  8026d3:	5e                   	pop    %esi
  8026d4:	5f                   	pop    %edi
  8026d5:	5d                   	pop    %ebp
  8026d6:	c3                   	ret    

008026d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8026d7:	55                   	push   %ebp
  8026d8:	89 e5                	mov    %esp,%ebp
  8026da:	57                   	push   %edi
  8026db:	56                   	push   %esi
  8026dc:	53                   	push   %ebx
  8026dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026e5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8026ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ed:	89 cb                	mov    %ecx,%ebx
  8026ef:	89 cf                	mov    %ecx,%edi
  8026f1:	89 ce                	mov    %ecx,%esi
  8026f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026f5:	85 c0                	test   %eax,%eax
  8026f7:	7e 17                	jle    802710 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026f9:	83 ec 0c             	sub    $0xc,%esp
  8026fc:	50                   	push   %eax
  8026fd:	6a 0d                	push   $0xd
  8026ff:	68 ff 40 80 00       	push   $0x8040ff
  802704:	6a 23                	push   $0x23
  802706:	68 1c 41 80 00       	push   $0x80411c
  80270b:	e8 98 f3 ff ff       	call   801aa8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    

00802718 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802718:	55                   	push   %ebp
  802719:	89 e5                	mov    %esp,%ebp
  80271b:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  80271e:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802725:	75 36                	jne    80275d <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802727:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80272c:	8b 40 48             	mov    0x48(%eax),%eax
  80272f:	83 ec 04             	sub    $0x4,%esp
  802732:	68 07 0e 00 00       	push   $0xe07
  802737:	68 00 f0 bf ee       	push   $0xeebff000
  80273c:	50                   	push   %eax
  80273d:	e8 e5 fd ff ff       	call   802527 <sys_page_alloc>
		if (ret < 0) {
  802742:	83 c4 10             	add    $0x10,%esp
  802745:	85 c0                	test   %eax,%eax
  802747:	79 14                	jns    80275d <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  802749:	83 ec 04             	sub    $0x4,%esp
  80274c:	68 2c 41 80 00       	push   $0x80412c
  802751:	6a 23                	push   $0x23
  802753:	68 53 41 80 00       	push   $0x804153
  802758:	e8 4b f3 ff ff       	call   801aa8 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80275d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802762:	8b 40 48             	mov    0x48(%eax),%eax
  802765:	83 ec 08             	sub    $0x8,%esp
  802768:	68 80 27 80 00       	push   $0x802780
  80276d:	50                   	push   %eax
  80276e:	e8 ff fe ff ff       	call   802672 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802773:	8b 45 08             	mov    0x8(%ebp),%eax
  802776:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  80277b:	83 c4 10             	add    $0x10,%esp
  80277e:	c9                   	leave  
  80277f:	c3                   	ret    

00802780 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802780:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802781:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802786:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802788:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  80278b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  80278f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  802794:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  802798:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  80279a:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80279d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80279e:	83 c4 04             	add    $0x4,%esp
        popfl
  8027a1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8027a2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8027a3:	c3                   	ret    

008027a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027a4:	55                   	push   %ebp
  8027a5:	89 e5                	mov    %esp,%ebp
  8027a7:	56                   	push   %esi
  8027a8:	53                   	push   %ebx
  8027a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8027ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027af:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8027b2:	85 c0                	test   %eax,%eax
  8027b4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8027b9:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  8027bc:	83 ec 0c             	sub    $0xc,%esp
  8027bf:	50                   	push   %eax
  8027c0:	e8 12 ff ff ff       	call   8026d7 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  8027c5:	83 c4 10             	add    $0x10,%esp
  8027c8:	85 c0                	test   %eax,%eax
  8027ca:	75 10                	jne    8027dc <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  8027cc:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8027d1:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  8027d4:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  8027d7:	8b 40 70             	mov    0x70(%eax),%eax
  8027da:	eb 0a                	jmp    8027e6 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  8027dc:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  8027e1:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  8027e6:	85 f6                	test   %esi,%esi
  8027e8:	74 02                	je     8027ec <ipc_recv+0x48>
  8027ea:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  8027ec:	85 db                	test   %ebx,%ebx
  8027ee:	74 02                	je     8027f2 <ipc_recv+0x4e>
  8027f0:	89 13                	mov    %edx,(%ebx)

    return r;
}
  8027f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027f5:	5b                   	pop    %ebx
  8027f6:	5e                   	pop    %esi
  8027f7:	5d                   	pop    %ebp
  8027f8:	c3                   	ret    

008027f9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027f9:	55                   	push   %ebp
  8027fa:	89 e5                	mov    %esp,%ebp
  8027fc:	57                   	push   %edi
  8027fd:	56                   	push   %esi
  8027fe:	53                   	push   %ebx
  8027ff:	83 ec 0c             	sub    $0xc,%esp
  802802:	8b 7d 08             	mov    0x8(%ebp),%edi
  802805:	8b 75 0c             	mov    0xc(%ebp),%esi
  802808:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  80280b:	85 db                	test   %ebx,%ebx
  80280d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802812:	0f 44 d8             	cmove  %eax,%ebx
  802815:	eb 1c                	jmp    802833 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  802817:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80281a:	74 12                	je     80282e <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  80281c:	50                   	push   %eax
  80281d:	68 61 41 80 00       	push   $0x804161
  802822:	6a 40                	push   $0x40
  802824:	68 73 41 80 00       	push   $0x804173
  802829:	e8 7a f2 ff ff       	call   801aa8 <_panic>
        sys_yield();
  80282e:	e8 d5 fc ff ff       	call   802508 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802833:	ff 75 14             	pushl  0x14(%ebp)
  802836:	53                   	push   %ebx
  802837:	56                   	push   %esi
  802838:	57                   	push   %edi
  802839:	e8 76 fe ff ff       	call   8026b4 <sys_ipc_try_send>
  80283e:	83 c4 10             	add    $0x10,%esp
  802841:	85 c0                	test   %eax,%eax
  802843:	75 d2                	jne    802817 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  802845:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802848:	5b                   	pop    %ebx
  802849:	5e                   	pop    %esi
  80284a:	5f                   	pop    %edi
  80284b:	5d                   	pop    %ebp
  80284c:	c3                   	ret    

0080284d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80284d:	55                   	push   %ebp
  80284e:	89 e5                	mov    %esp,%ebp
  802850:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802853:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802858:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80285b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802861:	8b 52 50             	mov    0x50(%edx),%edx
  802864:	39 ca                	cmp    %ecx,%edx
  802866:	75 0d                	jne    802875 <ipc_find_env+0x28>
			return envs[i].env_id;
  802868:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80286b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802870:	8b 40 48             	mov    0x48(%eax),%eax
  802873:	eb 0f                	jmp    802884 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802875:	83 c0 01             	add    $0x1,%eax
  802878:	3d 00 04 00 00       	cmp    $0x400,%eax
  80287d:	75 d9                	jne    802858 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80287f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802884:	5d                   	pop    %ebp
  802885:	c3                   	ret    

00802886 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802886:	55                   	push   %ebp
  802887:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802889:	8b 45 08             	mov    0x8(%ebp),%eax
  80288c:	05 00 00 00 30       	add    $0x30000000,%eax
  802891:	c1 e8 0c             	shr    $0xc,%eax
}
  802894:	5d                   	pop    %ebp
  802895:	c3                   	ret    

00802896 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802896:	55                   	push   %ebp
  802897:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802899:	8b 45 08             	mov    0x8(%ebp),%eax
  80289c:	05 00 00 00 30       	add    $0x30000000,%eax
  8028a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8028a6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8028ab:	5d                   	pop    %ebp
  8028ac:	c3                   	ret    

008028ad <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8028ad:	55                   	push   %ebp
  8028ae:	89 e5                	mov    %esp,%ebp
  8028b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028b3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8028b8:	89 c2                	mov    %eax,%edx
  8028ba:	c1 ea 16             	shr    $0x16,%edx
  8028bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028c4:	f6 c2 01             	test   $0x1,%dl
  8028c7:	74 11                	je     8028da <fd_alloc+0x2d>
  8028c9:	89 c2                	mov    %eax,%edx
  8028cb:	c1 ea 0c             	shr    $0xc,%edx
  8028ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8028d5:	f6 c2 01             	test   $0x1,%dl
  8028d8:	75 09                	jne    8028e3 <fd_alloc+0x36>
			*fd_store = fd;
  8028da:	89 01                	mov    %eax,(%ecx)
			return 0;
  8028dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8028e1:	eb 17                	jmp    8028fa <fd_alloc+0x4d>
  8028e3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8028e8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8028ed:	75 c9                	jne    8028b8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8028ef:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8028f5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8028fa:	5d                   	pop    %ebp
  8028fb:	c3                   	ret    

008028fc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8028fc:	55                   	push   %ebp
  8028fd:	89 e5                	mov    %esp,%ebp
  8028ff:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802902:	83 f8 1f             	cmp    $0x1f,%eax
  802905:	77 36                	ja     80293d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802907:	c1 e0 0c             	shl    $0xc,%eax
  80290a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80290f:	89 c2                	mov    %eax,%edx
  802911:	c1 ea 16             	shr    $0x16,%edx
  802914:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80291b:	f6 c2 01             	test   $0x1,%dl
  80291e:	74 24                	je     802944 <fd_lookup+0x48>
  802920:	89 c2                	mov    %eax,%edx
  802922:	c1 ea 0c             	shr    $0xc,%edx
  802925:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80292c:	f6 c2 01             	test   $0x1,%dl
  80292f:	74 1a                	je     80294b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802931:	8b 55 0c             	mov    0xc(%ebp),%edx
  802934:	89 02                	mov    %eax,(%edx)
	return 0;
  802936:	b8 00 00 00 00       	mov    $0x0,%eax
  80293b:	eb 13                	jmp    802950 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80293d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802942:	eb 0c                	jmp    802950 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802944:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802949:	eb 05                	jmp    802950 <fd_lookup+0x54>
  80294b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802950:	5d                   	pop    %ebp
  802951:	c3                   	ret    

00802952 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802952:	55                   	push   %ebp
  802953:	89 e5                	mov    %esp,%ebp
  802955:	83 ec 08             	sub    $0x8,%esp
  802958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80295b:	ba 00 42 80 00       	mov    $0x804200,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802960:	eb 13                	jmp    802975 <dev_lookup+0x23>
  802962:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802965:	39 08                	cmp    %ecx,(%eax)
  802967:	75 0c                	jne    802975 <dev_lookup+0x23>
			*dev = devtab[i];
  802969:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80296c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80296e:	b8 00 00 00 00       	mov    $0x0,%eax
  802973:	eb 2e                	jmp    8029a3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802975:	8b 02                	mov    (%edx),%eax
  802977:	85 c0                	test   %eax,%eax
  802979:	75 e7                	jne    802962 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80297b:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802980:	8b 40 48             	mov    0x48(%eax),%eax
  802983:	83 ec 04             	sub    $0x4,%esp
  802986:	51                   	push   %ecx
  802987:	50                   	push   %eax
  802988:	68 80 41 80 00       	push   $0x804180
  80298d:	e8 ef f1 ff ff       	call   801b81 <cprintf>
	*dev = 0;
  802992:	8b 45 0c             	mov    0xc(%ebp),%eax
  802995:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80299b:	83 c4 10             	add    $0x10,%esp
  80299e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8029a3:	c9                   	leave  
  8029a4:	c3                   	ret    

008029a5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8029a5:	55                   	push   %ebp
  8029a6:	89 e5                	mov    %esp,%ebp
  8029a8:	56                   	push   %esi
  8029a9:	53                   	push   %ebx
  8029aa:	83 ec 10             	sub    $0x10,%esp
  8029ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8029b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8029b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029b6:	50                   	push   %eax
  8029b7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8029bd:	c1 e8 0c             	shr    $0xc,%eax
  8029c0:	50                   	push   %eax
  8029c1:	e8 36 ff ff ff       	call   8028fc <fd_lookup>
  8029c6:	83 c4 08             	add    $0x8,%esp
  8029c9:	85 c0                	test   %eax,%eax
  8029cb:	78 05                	js     8029d2 <fd_close+0x2d>
	    || fd != fd2)
  8029cd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8029d0:	74 0c                	je     8029de <fd_close+0x39>
		return (must_exist ? r : 0);
  8029d2:	84 db                	test   %bl,%bl
  8029d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8029d9:	0f 44 c2             	cmove  %edx,%eax
  8029dc:	eb 41                	jmp    802a1f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8029de:	83 ec 08             	sub    $0x8,%esp
  8029e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8029e4:	50                   	push   %eax
  8029e5:	ff 36                	pushl  (%esi)
  8029e7:	e8 66 ff ff ff       	call   802952 <dev_lookup>
  8029ec:	89 c3                	mov    %eax,%ebx
  8029ee:	83 c4 10             	add    $0x10,%esp
  8029f1:	85 c0                	test   %eax,%eax
  8029f3:	78 1a                	js     802a0f <fd_close+0x6a>
		if (dev->dev_close)
  8029f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029f8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8029fb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a00:	85 c0                	test   %eax,%eax
  802a02:	74 0b                	je     802a0f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a04:	83 ec 0c             	sub    $0xc,%esp
  802a07:	56                   	push   %esi
  802a08:	ff d0                	call   *%eax
  802a0a:	89 c3                	mov    %eax,%ebx
  802a0c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a0f:	83 ec 08             	sub    $0x8,%esp
  802a12:	56                   	push   %esi
  802a13:	6a 00                	push   $0x0
  802a15:	e8 92 fb ff ff       	call   8025ac <sys_page_unmap>
	return r;
  802a1a:	83 c4 10             	add    $0x10,%esp
  802a1d:	89 d8                	mov    %ebx,%eax
}
  802a1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a22:	5b                   	pop    %ebx
  802a23:	5e                   	pop    %esi
  802a24:	5d                   	pop    %ebp
  802a25:	c3                   	ret    

00802a26 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a26:	55                   	push   %ebp
  802a27:	89 e5                	mov    %esp,%ebp
  802a29:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a2f:	50                   	push   %eax
  802a30:	ff 75 08             	pushl  0x8(%ebp)
  802a33:	e8 c4 fe ff ff       	call   8028fc <fd_lookup>
  802a38:	83 c4 08             	add    $0x8,%esp
  802a3b:	85 c0                	test   %eax,%eax
  802a3d:	78 10                	js     802a4f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802a3f:	83 ec 08             	sub    $0x8,%esp
  802a42:	6a 01                	push   $0x1
  802a44:	ff 75 f4             	pushl  -0xc(%ebp)
  802a47:	e8 59 ff ff ff       	call   8029a5 <fd_close>
  802a4c:	83 c4 10             	add    $0x10,%esp
}
  802a4f:	c9                   	leave  
  802a50:	c3                   	ret    

00802a51 <close_all>:

void
close_all(void)
{
  802a51:	55                   	push   %ebp
  802a52:	89 e5                	mov    %esp,%ebp
  802a54:	53                   	push   %ebx
  802a55:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802a58:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802a5d:	83 ec 0c             	sub    $0xc,%esp
  802a60:	53                   	push   %ebx
  802a61:	e8 c0 ff ff ff       	call   802a26 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802a66:	83 c3 01             	add    $0x1,%ebx
  802a69:	83 c4 10             	add    $0x10,%esp
  802a6c:	83 fb 20             	cmp    $0x20,%ebx
  802a6f:	75 ec                	jne    802a5d <close_all+0xc>
		close(i);
}
  802a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a74:	c9                   	leave  
  802a75:	c3                   	ret    

00802a76 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802a76:	55                   	push   %ebp
  802a77:	89 e5                	mov    %esp,%ebp
  802a79:	57                   	push   %edi
  802a7a:	56                   	push   %esi
  802a7b:	53                   	push   %ebx
  802a7c:	83 ec 2c             	sub    $0x2c,%esp
  802a7f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802a82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802a85:	50                   	push   %eax
  802a86:	ff 75 08             	pushl  0x8(%ebp)
  802a89:	e8 6e fe ff ff       	call   8028fc <fd_lookup>
  802a8e:	83 c4 08             	add    $0x8,%esp
  802a91:	85 c0                	test   %eax,%eax
  802a93:	0f 88 c1 00 00 00    	js     802b5a <dup+0xe4>
		return r;
	close(newfdnum);
  802a99:	83 ec 0c             	sub    $0xc,%esp
  802a9c:	56                   	push   %esi
  802a9d:	e8 84 ff ff ff       	call   802a26 <close>

	newfd = INDEX2FD(newfdnum);
  802aa2:	89 f3                	mov    %esi,%ebx
  802aa4:	c1 e3 0c             	shl    $0xc,%ebx
  802aa7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802aad:	83 c4 04             	add    $0x4,%esp
  802ab0:	ff 75 e4             	pushl  -0x1c(%ebp)
  802ab3:	e8 de fd ff ff       	call   802896 <fd2data>
  802ab8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802aba:	89 1c 24             	mov    %ebx,(%esp)
  802abd:	e8 d4 fd ff ff       	call   802896 <fd2data>
  802ac2:	83 c4 10             	add    $0x10,%esp
  802ac5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802ac8:	89 f8                	mov    %edi,%eax
  802aca:	c1 e8 16             	shr    $0x16,%eax
  802acd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802ad4:	a8 01                	test   $0x1,%al
  802ad6:	74 37                	je     802b0f <dup+0x99>
  802ad8:	89 f8                	mov    %edi,%eax
  802ada:	c1 e8 0c             	shr    $0xc,%eax
  802add:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802ae4:	f6 c2 01             	test   $0x1,%dl
  802ae7:	74 26                	je     802b0f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802ae9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802af0:	83 ec 0c             	sub    $0xc,%esp
  802af3:	25 07 0e 00 00       	and    $0xe07,%eax
  802af8:	50                   	push   %eax
  802af9:	ff 75 d4             	pushl  -0x2c(%ebp)
  802afc:	6a 00                	push   $0x0
  802afe:	57                   	push   %edi
  802aff:	6a 00                	push   $0x0
  802b01:	e8 64 fa ff ff       	call   80256a <sys_page_map>
  802b06:	89 c7                	mov    %eax,%edi
  802b08:	83 c4 20             	add    $0x20,%esp
  802b0b:	85 c0                	test   %eax,%eax
  802b0d:	78 2e                	js     802b3d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802b12:	89 d0                	mov    %edx,%eax
  802b14:	c1 e8 0c             	shr    $0xc,%eax
  802b17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b1e:	83 ec 0c             	sub    $0xc,%esp
  802b21:	25 07 0e 00 00       	and    $0xe07,%eax
  802b26:	50                   	push   %eax
  802b27:	53                   	push   %ebx
  802b28:	6a 00                	push   $0x0
  802b2a:	52                   	push   %edx
  802b2b:	6a 00                	push   $0x0
  802b2d:	e8 38 fa ff ff       	call   80256a <sys_page_map>
  802b32:	89 c7                	mov    %eax,%edi
  802b34:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802b37:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b39:	85 ff                	test   %edi,%edi
  802b3b:	79 1d                	jns    802b5a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802b3d:	83 ec 08             	sub    $0x8,%esp
  802b40:	53                   	push   %ebx
  802b41:	6a 00                	push   $0x0
  802b43:	e8 64 fa ff ff       	call   8025ac <sys_page_unmap>
	sys_page_unmap(0, nva);
  802b48:	83 c4 08             	add    $0x8,%esp
  802b4b:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b4e:	6a 00                	push   $0x0
  802b50:	e8 57 fa ff ff       	call   8025ac <sys_page_unmap>
	return r;
  802b55:	83 c4 10             	add    $0x10,%esp
  802b58:	89 f8                	mov    %edi,%eax
}
  802b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b5d:	5b                   	pop    %ebx
  802b5e:	5e                   	pop    %esi
  802b5f:	5f                   	pop    %edi
  802b60:	5d                   	pop    %ebp
  802b61:	c3                   	ret    

00802b62 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802b62:	55                   	push   %ebp
  802b63:	89 e5                	mov    %esp,%ebp
  802b65:	53                   	push   %ebx
  802b66:	83 ec 14             	sub    $0x14,%esp
  802b69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b6f:	50                   	push   %eax
  802b70:	53                   	push   %ebx
  802b71:	e8 86 fd ff ff       	call   8028fc <fd_lookup>
  802b76:	83 c4 08             	add    $0x8,%esp
  802b79:	89 c2                	mov    %eax,%edx
  802b7b:	85 c0                	test   %eax,%eax
  802b7d:	78 6d                	js     802bec <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b7f:	83 ec 08             	sub    $0x8,%esp
  802b82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b85:	50                   	push   %eax
  802b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b89:	ff 30                	pushl  (%eax)
  802b8b:	e8 c2 fd ff ff       	call   802952 <dev_lookup>
  802b90:	83 c4 10             	add    $0x10,%esp
  802b93:	85 c0                	test   %eax,%eax
  802b95:	78 4c                	js     802be3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802b97:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b9a:	8b 42 08             	mov    0x8(%edx),%eax
  802b9d:	83 e0 03             	and    $0x3,%eax
  802ba0:	83 f8 01             	cmp    $0x1,%eax
  802ba3:	75 21                	jne    802bc6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ba5:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802baa:	8b 40 48             	mov    0x48(%eax),%eax
  802bad:	83 ec 04             	sub    $0x4,%esp
  802bb0:	53                   	push   %ebx
  802bb1:	50                   	push   %eax
  802bb2:	68 c4 41 80 00       	push   $0x8041c4
  802bb7:	e8 c5 ef ff ff       	call   801b81 <cprintf>
		return -E_INVAL;
  802bbc:	83 c4 10             	add    $0x10,%esp
  802bbf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802bc4:	eb 26                	jmp    802bec <read+0x8a>
	}
	if (!dev->dev_read)
  802bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bc9:	8b 40 08             	mov    0x8(%eax),%eax
  802bcc:	85 c0                	test   %eax,%eax
  802bce:	74 17                	je     802be7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802bd0:	83 ec 04             	sub    $0x4,%esp
  802bd3:	ff 75 10             	pushl  0x10(%ebp)
  802bd6:	ff 75 0c             	pushl  0xc(%ebp)
  802bd9:	52                   	push   %edx
  802bda:	ff d0                	call   *%eax
  802bdc:	89 c2                	mov    %eax,%edx
  802bde:	83 c4 10             	add    $0x10,%esp
  802be1:	eb 09                	jmp    802bec <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802be3:	89 c2                	mov    %eax,%edx
  802be5:	eb 05                	jmp    802bec <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802be7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802bec:	89 d0                	mov    %edx,%eax
  802bee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bf1:	c9                   	leave  
  802bf2:	c3                   	ret    

00802bf3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802bf3:	55                   	push   %ebp
  802bf4:	89 e5                	mov    %esp,%ebp
  802bf6:	57                   	push   %edi
  802bf7:	56                   	push   %esi
  802bf8:	53                   	push   %ebx
  802bf9:	83 ec 0c             	sub    $0xc,%esp
  802bfc:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c02:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c07:	eb 21                	jmp    802c2a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c09:	83 ec 04             	sub    $0x4,%esp
  802c0c:	89 f0                	mov    %esi,%eax
  802c0e:	29 d8                	sub    %ebx,%eax
  802c10:	50                   	push   %eax
  802c11:	89 d8                	mov    %ebx,%eax
  802c13:	03 45 0c             	add    0xc(%ebp),%eax
  802c16:	50                   	push   %eax
  802c17:	57                   	push   %edi
  802c18:	e8 45 ff ff ff       	call   802b62 <read>
		if (m < 0)
  802c1d:	83 c4 10             	add    $0x10,%esp
  802c20:	85 c0                	test   %eax,%eax
  802c22:	78 10                	js     802c34 <readn+0x41>
			return m;
		if (m == 0)
  802c24:	85 c0                	test   %eax,%eax
  802c26:	74 0a                	je     802c32 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c28:	01 c3                	add    %eax,%ebx
  802c2a:	39 f3                	cmp    %esi,%ebx
  802c2c:	72 db                	jb     802c09 <readn+0x16>
  802c2e:	89 d8                	mov    %ebx,%eax
  802c30:	eb 02                	jmp    802c34 <readn+0x41>
  802c32:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c37:	5b                   	pop    %ebx
  802c38:	5e                   	pop    %esi
  802c39:	5f                   	pop    %edi
  802c3a:	5d                   	pop    %ebp
  802c3b:	c3                   	ret    

00802c3c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c3c:	55                   	push   %ebp
  802c3d:	89 e5                	mov    %esp,%ebp
  802c3f:	53                   	push   %ebx
  802c40:	83 ec 14             	sub    $0x14,%esp
  802c43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c49:	50                   	push   %eax
  802c4a:	53                   	push   %ebx
  802c4b:	e8 ac fc ff ff       	call   8028fc <fd_lookup>
  802c50:	83 c4 08             	add    $0x8,%esp
  802c53:	89 c2                	mov    %eax,%edx
  802c55:	85 c0                	test   %eax,%eax
  802c57:	78 68                	js     802cc1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c59:	83 ec 08             	sub    $0x8,%esp
  802c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c5f:	50                   	push   %eax
  802c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c63:	ff 30                	pushl  (%eax)
  802c65:	e8 e8 fc ff ff       	call   802952 <dev_lookup>
  802c6a:	83 c4 10             	add    $0x10,%esp
  802c6d:	85 c0                	test   %eax,%eax
  802c6f:	78 47                	js     802cb8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c74:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c78:	75 21                	jne    802c9b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802c7a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802c7f:	8b 40 48             	mov    0x48(%eax),%eax
  802c82:	83 ec 04             	sub    $0x4,%esp
  802c85:	53                   	push   %ebx
  802c86:	50                   	push   %eax
  802c87:	68 e0 41 80 00       	push   $0x8041e0
  802c8c:	e8 f0 ee ff ff       	call   801b81 <cprintf>
		return -E_INVAL;
  802c91:	83 c4 10             	add    $0x10,%esp
  802c94:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c99:	eb 26                	jmp    802cc1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802c9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c9e:	8b 52 0c             	mov    0xc(%edx),%edx
  802ca1:	85 d2                	test   %edx,%edx
  802ca3:	74 17                	je     802cbc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802ca5:	83 ec 04             	sub    $0x4,%esp
  802ca8:	ff 75 10             	pushl  0x10(%ebp)
  802cab:	ff 75 0c             	pushl  0xc(%ebp)
  802cae:	50                   	push   %eax
  802caf:	ff d2                	call   *%edx
  802cb1:	89 c2                	mov    %eax,%edx
  802cb3:	83 c4 10             	add    $0x10,%esp
  802cb6:	eb 09                	jmp    802cc1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cb8:	89 c2                	mov    %eax,%edx
  802cba:	eb 05                	jmp    802cc1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802cbc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802cc1:	89 d0                	mov    %edx,%eax
  802cc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cc6:	c9                   	leave  
  802cc7:	c3                   	ret    

00802cc8 <seek>:

int
seek(int fdnum, off_t offset)
{
  802cc8:	55                   	push   %ebp
  802cc9:	89 e5                	mov    %esp,%ebp
  802ccb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802cce:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802cd1:	50                   	push   %eax
  802cd2:	ff 75 08             	pushl  0x8(%ebp)
  802cd5:	e8 22 fc ff ff       	call   8028fc <fd_lookup>
  802cda:	83 c4 08             	add    $0x8,%esp
  802cdd:	85 c0                	test   %eax,%eax
  802cdf:	78 0e                	js     802cef <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802ce1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802ce4:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ce7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802cef:	c9                   	leave  
  802cf0:	c3                   	ret    

00802cf1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802cf1:	55                   	push   %ebp
  802cf2:	89 e5                	mov    %esp,%ebp
  802cf4:	53                   	push   %ebx
  802cf5:	83 ec 14             	sub    $0x14,%esp
  802cf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cfe:	50                   	push   %eax
  802cff:	53                   	push   %ebx
  802d00:	e8 f7 fb ff ff       	call   8028fc <fd_lookup>
  802d05:	83 c4 08             	add    $0x8,%esp
  802d08:	89 c2                	mov    %eax,%edx
  802d0a:	85 c0                	test   %eax,%eax
  802d0c:	78 65                	js     802d73 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d0e:	83 ec 08             	sub    $0x8,%esp
  802d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d14:	50                   	push   %eax
  802d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d18:	ff 30                	pushl  (%eax)
  802d1a:	e8 33 fc ff ff       	call   802952 <dev_lookup>
  802d1f:	83 c4 10             	add    $0x10,%esp
  802d22:	85 c0                	test   %eax,%eax
  802d24:	78 44                	js     802d6a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d29:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d2d:	75 21                	jne    802d50 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d2f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d34:	8b 40 48             	mov    0x48(%eax),%eax
  802d37:	83 ec 04             	sub    $0x4,%esp
  802d3a:	53                   	push   %ebx
  802d3b:	50                   	push   %eax
  802d3c:	68 a0 41 80 00       	push   $0x8041a0
  802d41:	e8 3b ee ff ff       	call   801b81 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802d46:	83 c4 10             	add    $0x10,%esp
  802d49:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d4e:	eb 23                	jmp    802d73 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d53:	8b 52 18             	mov    0x18(%edx),%edx
  802d56:	85 d2                	test   %edx,%edx
  802d58:	74 14                	je     802d6e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802d5a:	83 ec 08             	sub    $0x8,%esp
  802d5d:	ff 75 0c             	pushl  0xc(%ebp)
  802d60:	50                   	push   %eax
  802d61:	ff d2                	call   *%edx
  802d63:	89 c2                	mov    %eax,%edx
  802d65:	83 c4 10             	add    $0x10,%esp
  802d68:	eb 09                	jmp    802d73 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d6a:	89 c2                	mov    %eax,%edx
  802d6c:	eb 05                	jmp    802d73 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802d6e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802d73:	89 d0                	mov    %edx,%eax
  802d75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d78:	c9                   	leave  
  802d79:	c3                   	ret    

00802d7a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802d7a:	55                   	push   %ebp
  802d7b:	89 e5                	mov    %esp,%ebp
  802d7d:	53                   	push   %ebx
  802d7e:	83 ec 14             	sub    $0x14,%esp
  802d81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d87:	50                   	push   %eax
  802d88:	ff 75 08             	pushl  0x8(%ebp)
  802d8b:	e8 6c fb ff ff       	call   8028fc <fd_lookup>
  802d90:	83 c4 08             	add    $0x8,%esp
  802d93:	89 c2                	mov    %eax,%edx
  802d95:	85 c0                	test   %eax,%eax
  802d97:	78 58                	js     802df1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d99:	83 ec 08             	sub    $0x8,%esp
  802d9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d9f:	50                   	push   %eax
  802da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802da3:	ff 30                	pushl  (%eax)
  802da5:	e8 a8 fb ff ff       	call   802952 <dev_lookup>
  802daa:	83 c4 10             	add    $0x10,%esp
  802dad:	85 c0                	test   %eax,%eax
  802daf:	78 37                	js     802de8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802db8:	74 32                	je     802dec <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802dba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802dbd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802dc4:	00 00 00 
	stat->st_isdir = 0;
  802dc7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802dce:	00 00 00 
	stat->st_dev = dev;
  802dd1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802dd7:	83 ec 08             	sub    $0x8,%esp
  802dda:	53                   	push   %ebx
  802ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  802dde:	ff 50 14             	call   *0x14(%eax)
  802de1:	89 c2                	mov    %eax,%edx
  802de3:	83 c4 10             	add    $0x10,%esp
  802de6:	eb 09                	jmp    802df1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802de8:	89 c2                	mov    %eax,%edx
  802dea:	eb 05                	jmp    802df1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802dec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802df1:	89 d0                	mov    %edx,%eax
  802df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802df6:	c9                   	leave  
  802df7:	c3                   	ret    

00802df8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802df8:	55                   	push   %ebp
  802df9:	89 e5                	mov    %esp,%ebp
  802dfb:	56                   	push   %esi
  802dfc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802dfd:	83 ec 08             	sub    $0x8,%esp
  802e00:	6a 00                	push   $0x0
  802e02:	ff 75 08             	pushl  0x8(%ebp)
  802e05:	e8 e3 01 00 00       	call   802fed <open>
  802e0a:	89 c3                	mov    %eax,%ebx
  802e0c:	83 c4 10             	add    $0x10,%esp
  802e0f:	85 c0                	test   %eax,%eax
  802e11:	78 1b                	js     802e2e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e13:	83 ec 08             	sub    $0x8,%esp
  802e16:	ff 75 0c             	pushl  0xc(%ebp)
  802e19:	50                   	push   %eax
  802e1a:	e8 5b ff ff ff       	call   802d7a <fstat>
  802e1f:	89 c6                	mov    %eax,%esi
	close(fd);
  802e21:	89 1c 24             	mov    %ebx,(%esp)
  802e24:	e8 fd fb ff ff       	call   802a26 <close>
	return r;
  802e29:	83 c4 10             	add    $0x10,%esp
  802e2c:	89 f0                	mov    %esi,%eax
}
  802e2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e31:	5b                   	pop    %ebx
  802e32:	5e                   	pop    %esi
  802e33:	5d                   	pop    %ebp
  802e34:	c3                   	ret    

00802e35 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802e35:	55                   	push   %ebp
  802e36:	89 e5                	mov    %esp,%ebp
  802e38:	56                   	push   %esi
  802e39:	53                   	push   %ebx
  802e3a:	89 c6                	mov    %eax,%esi
  802e3c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802e3e:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802e45:	75 12                	jne    802e59 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802e47:	83 ec 0c             	sub    $0xc,%esp
  802e4a:	6a 01                	push   $0x1
  802e4c:	e8 fc f9 ff ff       	call   80284d <ipc_find_env>
  802e51:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802e56:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802e59:	6a 07                	push   $0x7
  802e5b:	68 00 b0 80 00       	push   $0x80b000
  802e60:	56                   	push   %esi
  802e61:	ff 35 00 a0 80 00    	pushl  0x80a000
  802e67:	e8 8d f9 ff ff       	call   8027f9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802e6c:	83 c4 0c             	add    $0xc,%esp
  802e6f:	6a 00                	push   $0x0
  802e71:	53                   	push   %ebx
  802e72:	6a 00                	push   $0x0
  802e74:	e8 2b f9 ff ff       	call   8027a4 <ipc_recv>
}
  802e79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e7c:	5b                   	pop    %ebx
  802e7d:	5e                   	pop    %esi
  802e7e:	5d                   	pop    %ebp
  802e7f:	c3                   	ret    

00802e80 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802e80:	55                   	push   %ebp
  802e81:	89 e5                	mov    %esp,%ebp
  802e83:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802e86:	8b 45 08             	mov    0x8(%ebp),%eax
  802e89:	8b 40 0c             	mov    0xc(%eax),%eax
  802e8c:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e94:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802e99:	ba 00 00 00 00       	mov    $0x0,%edx
  802e9e:	b8 02 00 00 00       	mov    $0x2,%eax
  802ea3:	e8 8d ff ff ff       	call   802e35 <fsipc>
}
  802ea8:	c9                   	leave  
  802ea9:	c3                   	ret    

00802eaa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802eaa:	55                   	push   %ebp
  802eab:	89 e5                	mov    %esp,%ebp
  802ead:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb3:	8b 40 0c             	mov    0xc(%eax),%eax
  802eb6:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  802ec0:	b8 06 00 00 00       	mov    $0x6,%eax
  802ec5:	e8 6b ff ff ff       	call   802e35 <fsipc>
}
  802eca:	c9                   	leave  
  802ecb:	c3                   	ret    

00802ecc <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802ecc:	55                   	push   %ebp
  802ecd:	89 e5                	mov    %esp,%ebp
  802ecf:	53                   	push   %ebx
  802ed0:	83 ec 04             	sub    $0x4,%esp
  802ed3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  802ed9:	8b 40 0c             	mov    0xc(%eax),%eax
  802edc:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802ee1:	ba 00 00 00 00       	mov    $0x0,%edx
  802ee6:	b8 05 00 00 00       	mov    $0x5,%eax
  802eeb:	e8 45 ff ff ff       	call   802e35 <fsipc>
  802ef0:	85 c0                	test   %eax,%eax
  802ef2:	78 2c                	js     802f20 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802ef4:	83 ec 08             	sub    $0x8,%esp
  802ef7:	68 00 b0 80 00       	push   $0x80b000
  802efc:	53                   	push   %ebx
  802efd:	e8 22 f2 ff ff       	call   802124 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f02:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f0d:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f12:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f18:	83 c4 10             	add    $0x10,%esp
  802f1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f23:	c9                   	leave  
  802f24:	c3                   	ret    

00802f25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f25:	55                   	push   %ebp
  802f26:	89 e5                	mov    %esp,%ebp
  802f28:	83 ec 0c             	sub    $0xc,%esp
  802f2b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  802f2e:	8b 55 08             	mov    0x8(%ebp),%edx
  802f31:	8b 52 0c             	mov    0xc(%edx),%edx
  802f34:	89 15 00 b0 80 00    	mov    %edx,0x80b000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  802f3a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802f3f:	ba 00 10 00 00       	mov    $0x1000,%edx
  802f44:	0f 47 c2             	cmova  %edx,%eax
  802f47:	a3 04 b0 80 00       	mov    %eax,0x80b004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  802f4c:	50                   	push   %eax
  802f4d:	ff 75 0c             	pushl  0xc(%ebp)
  802f50:	68 08 b0 80 00       	push   $0x80b008
  802f55:	e8 5c f3 ff ff       	call   8022b6 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  802f5a:	ba 00 00 00 00       	mov    $0x0,%edx
  802f5f:	b8 04 00 00 00       	mov    $0x4,%eax
  802f64:	e8 cc fe ff ff       	call   802e35 <fsipc>
    return r;
}
  802f69:	c9                   	leave  
  802f6a:	c3                   	ret    

00802f6b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802f6b:	55                   	push   %ebp
  802f6c:	89 e5                	mov    %esp,%ebp
  802f6e:	56                   	push   %esi
  802f6f:	53                   	push   %ebx
  802f70:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802f73:	8b 45 08             	mov    0x8(%ebp),%eax
  802f76:	8b 40 0c             	mov    0xc(%eax),%eax
  802f79:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802f7e:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802f84:	ba 00 00 00 00       	mov    $0x0,%edx
  802f89:	b8 03 00 00 00       	mov    $0x3,%eax
  802f8e:	e8 a2 fe ff ff       	call   802e35 <fsipc>
  802f93:	89 c3                	mov    %eax,%ebx
  802f95:	85 c0                	test   %eax,%eax
  802f97:	78 4b                	js     802fe4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802f99:	39 c6                	cmp    %eax,%esi
  802f9b:	73 16                	jae    802fb3 <devfile_read+0x48>
  802f9d:	68 10 42 80 00       	push   $0x804210
  802fa2:	68 7d 38 80 00       	push   $0x80387d
  802fa7:	6a 7c                	push   $0x7c
  802fa9:	68 17 42 80 00       	push   $0x804217
  802fae:	e8 f5 ea ff ff       	call   801aa8 <_panic>
	assert(r <= PGSIZE);
  802fb3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802fb8:	7e 16                	jle    802fd0 <devfile_read+0x65>
  802fba:	68 22 42 80 00       	push   $0x804222
  802fbf:	68 7d 38 80 00       	push   $0x80387d
  802fc4:	6a 7d                	push   $0x7d
  802fc6:	68 17 42 80 00       	push   $0x804217
  802fcb:	e8 d8 ea ff ff       	call   801aa8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802fd0:	83 ec 04             	sub    $0x4,%esp
  802fd3:	50                   	push   %eax
  802fd4:	68 00 b0 80 00       	push   $0x80b000
  802fd9:	ff 75 0c             	pushl  0xc(%ebp)
  802fdc:	e8 d5 f2 ff ff       	call   8022b6 <memmove>
	return r;
  802fe1:	83 c4 10             	add    $0x10,%esp
}
  802fe4:	89 d8                	mov    %ebx,%eax
  802fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fe9:	5b                   	pop    %ebx
  802fea:	5e                   	pop    %esi
  802feb:	5d                   	pop    %ebp
  802fec:	c3                   	ret    

00802fed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802fed:	55                   	push   %ebp
  802fee:	89 e5                	mov    %esp,%ebp
  802ff0:	53                   	push   %ebx
  802ff1:	83 ec 20             	sub    $0x20,%esp
  802ff4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802ff7:	53                   	push   %ebx
  802ff8:	e8 ee f0 ff ff       	call   8020eb <strlen>
  802ffd:	83 c4 10             	add    $0x10,%esp
  803000:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803005:	7f 67                	jg     80306e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803007:	83 ec 0c             	sub    $0xc,%esp
  80300a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80300d:	50                   	push   %eax
  80300e:	e8 9a f8 ff ff       	call   8028ad <fd_alloc>
  803013:	83 c4 10             	add    $0x10,%esp
		return r;
  803016:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803018:	85 c0                	test   %eax,%eax
  80301a:	78 57                	js     803073 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80301c:	83 ec 08             	sub    $0x8,%esp
  80301f:	53                   	push   %ebx
  803020:	68 00 b0 80 00       	push   $0x80b000
  803025:	e8 fa f0 ff ff       	call   802124 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80302a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80302d:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803032:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803035:	b8 01 00 00 00       	mov    $0x1,%eax
  80303a:	e8 f6 fd ff ff       	call   802e35 <fsipc>
  80303f:	89 c3                	mov    %eax,%ebx
  803041:	83 c4 10             	add    $0x10,%esp
  803044:	85 c0                	test   %eax,%eax
  803046:	79 14                	jns    80305c <open+0x6f>
		fd_close(fd, 0);
  803048:	83 ec 08             	sub    $0x8,%esp
  80304b:	6a 00                	push   $0x0
  80304d:	ff 75 f4             	pushl  -0xc(%ebp)
  803050:	e8 50 f9 ff ff       	call   8029a5 <fd_close>
		return r;
  803055:	83 c4 10             	add    $0x10,%esp
  803058:	89 da                	mov    %ebx,%edx
  80305a:	eb 17                	jmp    803073 <open+0x86>
	}

	return fd2num(fd);
  80305c:	83 ec 0c             	sub    $0xc,%esp
  80305f:	ff 75 f4             	pushl  -0xc(%ebp)
  803062:	e8 1f f8 ff ff       	call   802886 <fd2num>
  803067:	89 c2                	mov    %eax,%edx
  803069:	83 c4 10             	add    $0x10,%esp
  80306c:	eb 05                	jmp    803073 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80306e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  803073:	89 d0                	mov    %edx,%eax
  803075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803078:	c9                   	leave  
  803079:	c3                   	ret    

0080307a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80307a:	55                   	push   %ebp
  80307b:	89 e5                	mov    %esp,%ebp
  80307d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803080:	ba 00 00 00 00       	mov    $0x0,%edx
  803085:	b8 08 00 00 00       	mov    $0x8,%eax
  80308a:	e8 a6 fd ff ff       	call   802e35 <fsipc>
}
  80308f:	c9                   	leave  
  803090:	c3                   	ret    

00803091 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803091:	55                   	push   %ebp
  803092:	89 e5                	mov    %esp,%ebp
  803094:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803097:	89 d0                	mov    %edx,%eax
  803099:	c1 e8 16             	shr    $0x16,%eax
  80309c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030a3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030a8:	f6 c1 01             	test   $0x1,%cl
  8030ab:	74 1d                	je     8030ca <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8030ad:	c1 ea 0c             	shr    $0xc,%edx
  8030b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030b7:	f6 c2 01             	test   $0x1,%dl
  8030ba:	74 0e                	je     8030ca <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030bc:	c1 ea 0c             	shr    $0xc,%edx
  8030bf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030c6:	ef 
  8030c7:	0f b7 c0             	movzwl %ax,%eax
}
  8030ca:	5d                   	pop    %ebp
  8030cb:	c3                   	ret    

008030cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8030cc:	55                   	push   %ebp
  8030cd:	89 e5                	mov    %esp,%ebp
  8030cf:	56                   	push   %esi
  8030d0:	53                   	push   %ebx
  8030d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8030d4:	83 ec 0c             	sub    $0xc,%esp
  8030d7:	ff 75 08             	pushl  0x8(%ebp)
  8030da:	e8 b7 f7 ff ff       	call   802896 <fd2data>
  8030df:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8030e1:	83 c4 08             	add    $0x8,%esp
  8030e4:	68 2e 42 80 00       	push   $0x80422e
  8030e9:	53                   	push   %ebx
  8030ea:	e8 35 f0 ff ff       	call   802124 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8030ef:	8b 46 04             	mov    0x4(%esi),%eax
  8030f2:	2b 06                	sub    (%esi),%eax
  8030f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8030fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803101:	00 00 00 
	stat->st_dev = &devpipe;
  803104:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80310b:	90 80 00 
	return 0;
}
  80310e:	b8 00 00 00 00       	mov    $0x0,%eax
  803113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803116:	5b                   	pop    %ebx
  803117:	5e                   	pop    %esi
  803118:	5d                   	pop    %ebp
  803119:	c3                   	ret    

0080311a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80311a:	55                   	push   %ebp
  80311b:	89 e5                	mov    %esp,%ebp
  80311d:	53                   	push   %ebx
  80311e:	83 ec 0c             	sub    $0xc,%esp
  803121:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803124:	53                   	push   %ebx
  803125:	6a 00                	push   $0x0
  803127:	e8 80 f4 ff ff       	call   8025ac <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80312c:	89 1c 24             	mov    %ebx,(%esp)
  80312f:	e8 62 f7 ff ff       	call   802896 <fd2data>
  803134:	83 c4 08             	add    $0x8,%esp
  803137:	50                   	push   %eax
  803138:	6a 00                	push   $0x0
  80313a:	e8 6d f4 ff ff       	call   8025ac <sys_page_unmap>
}
  80313f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803142:	c9                   	leave  
  803143:	c3                   	ret    

00803144 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803144:	55                   	push   %ebp
  803145:	89 e5                	mov    %esp,%ebp
  803147:	57                   	push   %edi
  803148:	56                   	push   %esi
  803149:	53                   	push   %ebx
  80314a:	83 ec 1c             	sub    $0x1c,%esp
  80314d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803150:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803152:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803157:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80315a:	83 ec 0c             	sub    $0xc,%esp
  80315d:	ff 75 e0             	pushl  -0x20(%ebp)
  803160:	e8 2c ff ff ff       	call   803091 <pageref>
  803165:	89 c3                	mov    %eax,%ebx
  803167:	89 3c 24             	mov    %edi,(%esp)
  80316a:	e8 22 ff ff ff       	call   803091 <pageref>
  80316f:	83 c4 10             	add    $0x10,%esp
  803172:	39 c3                	cmp    %eax,%ebx
  803174:	0f 94 c1             	sete   %cl
  803177:	0f b6 c9             	movzbl %cl,%ecx
  80317a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80317d:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803183:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803186:	39 ce                	cmp    %ecx,%esi
  803188:	74 1b                	je     8031a5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80318a:	39 c3                	cmp    %eax,%ebx
  80318c:	75 c4                	jne    803152 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80318e:	8b 42 58             	mov    0x58(%edx),%eax
  803191:	ff 75 e4             	pushl  -0x1c(%ebp)
  803194:	50                   	push   %eax
  803195:	56                   	push   %esi
  803196:	68 35 42 80 00       	push   $0x804235
  80319b:	e8 e1 e9 ff ff       	call   801b81 <cprintf>
  8031a0:	83 c4 10             	add    $0x10,%esp
  8031a3:	eb ad                	jmp    803152 <_pipeisclosed+0xe>
	}
}
  8031a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8031a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031ab:	5b                   	pop    %ebx
  8031ac:	5e                   	pop    %esi
  8031ad:	5f                   	pop    %edi
  8031ae:	5d                   	pop    %ebp
  8031af:	c3                   	ret    

008031b0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8031b0:	55                   	push   %ebp
  8031b1:	89 e5                	mov    %esp,%ebp
  8031b3:	57                   	push   %edi
  8031b4:	56                   	push   %esi
  8031b5:	53                   	push   %ebx
  8031b6:	83 ec 28             	sub    $0x28,%esp
  8031b9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8031bc:	56                   	push   %esi
  8031bd:	e8 d4 f6 ff ff       	call   802896 <fd2data>
  8031c2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8031c4:	83 c4 10             	add    $0x10,%esp
  8031c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8031cc:	eb 4b                	jmp    803219 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8031ce:	89 da                	mov    %ebx,%edx
  8031d0:	89 f0                	mov    %esi,%eax
  8031d2:	e8 6d ff ff ff       	call   803144 <_pipeisclosed>
  8031d7:	85 c0                	test   %eax,%eax
  8031d9:	75 48                	jne    803223 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8031db:	e8 28 f3 ff ff       	call   802508 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8031e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8031e3:	8b 0b                	mov    (%ebx),%ecx
  8031e5:	8d 51 20             	lea    0x20(%ecx),%edx
  8031e8:	39 d0                	cmp    %edx,%eax
  8031ea:	73 e2                	jae    8031ce <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8031ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031ef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8031f3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8031f6:	89 c2                	mov    %eax,%edx
  8031f8:	c1 fa 1f             	sar    $0x1f,%edx
  8031fb:	89 d1                	mov    %edx,%ecx
  8031fd:	c1 e9 1b             	shr    $0x1b,%ecx
  803200:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803203:	83 e2 1f             	and    $0x1f,%edx
  803206:	29 ca                	sub    %ecx,%edx
  803208:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80320c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803210:	83 c0 01             	add    $0x1,%eax
  803213:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803216:	83 c7 01             	add    $0x1,%edi
  803219:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80321c:	75 c2                	jne    8031e0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80321e:	8b 45 10             	mov    0x10(%ebp),%eax
  803221:	eb 05                	jmp    803228 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803223:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80322b:	5b                   	pop    %ebx
  80322c:	5e                   	pop    %esi
  80322d:	5f                   	pop    %edi
  80322e:	5d                   	pop    %ebp
  80322f:	c3                   	ret    

00803230 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803230:	55                   	push   %ebp
  803231:	89 e5                	mov    %esp,%ebp
  803233:	57                   	push   %edi
  803234:	56                   	push   %esi
  803235:	53                   	push   %ebx
  803236:	83 ec 18             	sub    $0x18,%esp
  803239:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80323c:	57                   	push   %edi
  80323d:	e8 54 f6 ff ff       	call   802896 <fd2data>
  803242:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803244:	83 c4 10             	add    $0x10,%esp
  803247:	bb 00 00 00 00       	mov    $0x0,%ebx
  80324c:	eb 3d                	jmp    80328b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80324e:	85 db                	test   %ebx,%ebx
  803250:	74 04                	je     803256 <devpipe_read+0x26>
				return i;
  803252:	89 d8                	mov    %ebx,%eax
  803254:	eb 44                	jmp    80329a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803256:	89 f2                	mov    %esi,%edx
  803258:	89 f8                	mov    %edi,%eax
  80325a:	e8 e5 fe ff ff       	call   803144 <_pipeisclosed>
  80325f:	85 c0                	test   %eax,%eax
  803261:	75 32                	jne    803295 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803263:	e8 a0 f2 ff ff       	call   802508 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803268:	8b 06                	mov    (%esi),%eax
  80326a:	3b 46 04             	cmp    0x4(%esi),%eax
  80326d:	74 df                	je     80324e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80326f:	99                   	cltd   
  803270:	c1 ea 1b             	shr    $0x1b,%edx
  803273:	01 d0                	add    %edx,%eax
  803275:	83 e0 1f             	and    $0x1f,%eax
  803278:	29 d0                	sub    %edx,%eax
  80327a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80327f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803282:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803285:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803288:	83 c3 01             	add    $0x1,%ebx
  80328b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80328e:	75 d8                	jne    803268 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803290:	8b 45 10             	mov    0x10(%ebp),%eax
  803293:	eb 05                	jmp    80329a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803295:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80329a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80329d:	5b                   	pop    %ebx
  80329e:	5e                   	pop    %esi
  80329f:	5f                   	pop    %edi
  8032a0:	5d                   	pop    %ebp
  8032a1:	c3                   	ret    

008032a2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8032a2:	55                   	push   %ebp
  8032a3:	89 e5                	mov    %esp,%ebp
  8032a5:	56                   	push   %esi
  8032a6:	53                   	push   %ebx
  8032a7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8032aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032ad:	50                   	push   %eax
  8032ae:	e8 fa f5 ff ff       	call   8028ad <fd_alloc>
  8032b3:	83 c4 10             	add    $0x10,%esp
  8032b6:	89 c2                	mov    %eax,%edx
  8032b8:	85 c0                	test   %eax,%eax
  8032ba:	0f 88 2c 01 00 00    	js     8033ec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032c0:	83 ec 04             	sub    $0x4,%esp
  8032c3:	68 07 04 00 00       	push   $0x407
  8032c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8032cb:	6a 00                	push   $0x0
  8032cd:	e8 55 f2 ff ff       	call   802527 <sys_page_alloc>
  8032d2:	83 c4 10             	add    $0x10,%esp
  8032d5:	89 c2                	mov    %eax,%edx
  8032d7:	85 c0                	test   %eax,%eax
  8032d9:	0f 88 0d 01 00 00    	js     8033ec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8032df:	83 ec 0c             	sub    $0xc,%esp
  8032e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8032e5:	50                   	push   %eax
  8032e6:	e8 c2 f5 ff ff       	call   8028ad <fd_alloc>
  8032eb:	89 c3                	mov    %eax,%ebx
  8032ed:	83 c4 10             	add    $0x10,%esp
  8032f0:	85 c0                	test   %eax,%eax
  8032f2:	0f 88 e2 00 00 00    	js     8033da <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032f8:	83 ec 04             	sub    $0x4,%esp
  8032fb:	68 07 04 00 00       	push   $0x407
  803300:	ff 75 f0             	pushl  -0x10(%ebp)
  803303:	6a 00                	push   $0x0
  803305:	e8 1d f2 ff ff       	call   802527 <sys_page_alloc>
  80330a:	89 c3                	mov    %eax,%ebx
  80330c:	83 c4 10             	add    $0x10,%esp
  80330f:	85 c0                	test   %eax,%eax
  803311:	0f 88 c3 00 00 00    	js     8033da <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803317:	83 ec 0c             	sub    $0xc,%esp
  80331a:	ff 75 f4             	pushl  -0xc(%ebp)
  80331d:	e8 74 f5 ff ff       	call   802896 <fd2data>
  803322:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803324:	83 c4 0c             	add    $0xc,%esp
  803327:	68 07 04 00 00       	push   $0x407
  80332c:	50                   	push   %eax
  80332d:	6a 00                	push   $0x0
  80332f:	e8 f3 f1 ff ff       	call   802527 <sys_page_alloc>
  803334:	89 c3                	mov    %eax,%ebx
  803336:	83 c4 10             	add    $0x10,%esp
  803339:	85 c0                	test   %eax,%eax
  80333b:	0f 88 89 00 00 00    	js     8033ca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803341:	83 ec 0c             	sub    $0xc,%esp
  803344:	ff 75 f0             	pushl  -0x10(%ebp)
  803347:	e8 4a f5 ff ff       	call   802896 <fd2data>
  80334c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803353:	50                   	push   %eax
  803354:	6a 00                	push   $0x0
  803356:	56                   	push   %esi
  803357:	6a 00                	push   $0x0
  803359:	e8 0c f2 ff ff       	call   80256a <sys_page_map>
  80335e:	89 c3                	mov    %eax,%ebx
  803360:	83 c4 20             	add    $0x20,%esp
  803363:	85 c0                	test   %eax,%eax
  803365:	78 55                	js     8033bc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803367:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80336d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803370:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803375:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80337c:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803385:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80338a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803391:	83 ec 0c             	sub    $0xc,%esp
  803394:	ff 75 f4             	pushl  -0xc(%ebp)
  803397:	e8 ea f4 ff ff       	call   802886 <fd2num>
  80339c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80339f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8033a1:	83 c4 04             	add    $0x4,%esp
  8033a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8033a7:	e8 da f4 ff ff       	call   802886 <fd2num>
  8033ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033af:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8033b2:	83 c4 10             	add    $0x10,%esp
  8033b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8033ba:	eb 30                	jmp    8033ec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8033bc:	83 ec 08             	sub    $0x8,%esp
  8033bf:	56                   	push   %esi
  8033c0:	6a 00                	push   $0x0
  8033c2:	e8 e5 f1 ff ff       	call   8025ac <sys_page_unmap>
  8033c7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8033ca:	83 ec 08             	sub    $0x8,%esp
  8033cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8033d0:	6a 00                	push   $0x0
  8033d2:	e8 d5 f1 ff ff       	call   8025ac <sys_page_unmap>
  8033d7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8033da:	83 ec 08             	sub    $0x8,%esp
  8033dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8033e0:	6a 00                	push   $0x0
  8033e2:	e8 c5 f1 ff ff       	call   8025ac <sys_page_unmap>
  8033e7:	83 c4 10             	add    $0x10,%esp
  8033ea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8033ec:	89 d0                	mov    %edx,%eax
  8033ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033f1:	5b                   	pop    %ebx
  8033f2:	5e                   	pop    %esi
  8033f3:	5d                   	pop    %ebp
  8033f4:	c3                   	ret    

008033f5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8033f5:	55                   	push   %ebp
  8033f6:	89 e5                	mov    %esp,%ebp
  8033f8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8033fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8033fe:	50                   	push   %eax
  8033ff:	ff 75 08             	pushl  0x8(%ebp)
  803402:	e8 f5 f4 ff ff       	call   8028fc <fd_lookup>
  803407:	83 c4 10             	add    $0x10,%esp
  80340a:	85 c0                	test   %eax,%eax
  80340c:	78 18                	js     803426 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80340e:	83 ec 0c             	sub    $0xc,%esp
  803411:	ff 75 f4             	pushl  -0xc(%ebp)
  803414:	e8 7d f4 ff ff       	call   802896 <fd2data>
	return _pipeisclosed(fd, p);
  803419:	89 c2                	mov    %eax,%edx
  80341b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80341e:	e8 21 fd ff ff       	call   803144 <_pipeisclosed>
  803423:	83 c4 10             	add    $0x10,%esp
}
  803426:	c9                   	leave  
  803427:	c3                   	ret    

00803428 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803428:	55                   	push   %ebp
  803429:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80342b:	b8 00 00 00 00       	mov    $0x0,%eax
  803430:	5d                   	pop    %ebp
  803431:	c3                   	ret    

00803432 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803432:	55                   	push   %ebp
  803433:	89 e5                	mov    %esp,%ebp
  803435:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803438:	68 4d 42 80 00       	push   $0x80424d
  80343d:	ff 75 0c             	pushl  0xc(%ebp)
  803440:	e8 df ec ff ff       	call   802124 <strcpy>
	return 0;
}
  803445:	b8 00 00 00 00       	mov    $0x0,%eax
  80344a:	c9                   	leave  
  80344b:	c3                   	ret    

0080344c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80344c:	55                   	push   %ebp
  80344d:	89 e5                	mov    %esp,%ebp
  80344f:	57                   	push   %edi
  803450:	56                   	push   %esi
  803451:	53                   	push   %ebx
  803452:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803458:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80345d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803463:	eb 2d                	jmp    803492 <devcons_write+0x46>
		m = n - tot;
  803465:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803468:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80346a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80346d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803472:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803475:	83 ec 04             	sub    $0x4,%esp
  803478:	53                   	push   %ebx
  803479:	03 45 0c             	add    0xc(%ebp),%eax
  80347c:	50                   	push   %eax
  80347d:	57                   	push   %edi
  80347e:	e8 33 ee ff ff       	call   8022b6 <memmove>
		sys_cputs(buf, m);
  803483:	83 c4 08             	add    $0x8,%esp
  803486:	53                   	push   %ebx
  803487:	57                   	push   %edi
  803488:	e8 de ef ff ff       	call   80246b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80348d:	01 de                	add    %ebx,%esi
  80348f:	83 c4 10             	add    $0x10,%esp
  803492:	89 f0                	mov    %esi,%eax
  803494:	3b 75 10             	cmp    0x10(%ebp),%esi
  803497:	72 cc                	jb     803465 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80349c:	5b                   	pop    %ebx
  80349d:	5e                   	pop    %esi
  80349e:	5f                   	pop    %edi
  80349f:	5d                   	pop    %ebp
  8034a0:	c3                   	ret    

008034a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8034a1:	55                   	push   %ebp
  8034a2:	89 e5                	mov    %esp,%ebp
  8034a4:	83 ec 08             	sub    $0x8,%esp
  8034a7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8034ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8034b0:	74 2a                	je     8034dc <devcons_read+0x3b>
  8034b2:	eb 05                	jmp    8034b9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8034b4:	e8 4f f0 ff ff       	call   802508 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8034b9:	e8 cb ef ff ff       	call   802489 <sys_cgetc>
  8034be:	85 c0                	test   %eax,%eax
  8034c0:	74 f2                	je     8034b4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8034c2:	85 c0                	test   %eax,%eax
  8034c4:	78 16                	js     8034dc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8034c6:	83 f8 04             	cmp    $0x4,%eax
  8034c9:	74 0c                	je     8034d7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8034cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8034ce:	88 02                	mov    %al,(%edx)
	return 1;
  8034d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8034d5:	eb 05                	jmp    8034dc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8034d7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8034dc:	c9                   	leave  
  8034dd:	c3                   	ret    

008034de <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8034de:	55                   	push   %ebp
  8034df:	89 e5                	mov    %esp,%ebp
  8034e1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8034e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8034e7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8034ea:	6a 01                	push   $0x1
  8034ec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8034ef:	50                   	push   %eax
  8034f0:	e8 76 ef ff ff       	call   80246b <sys_cputs>
}
  8034f5:	83 c4 10             	add    $0x10,%esp
  8034f8:	c9                   	leave  
  8034f9:	c3                   	ret    

008034fa <getchar>:

int
getchar(void)
{
  8034fa:	55                   	push   %ebp
  8034fb:	89 e5                	mov    %esp,%ebp
  8034fd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803500:	6a 01                	push   $0x1
  803502:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803505:	50                   	push   %eax
  803506:	6a 00                	push   $0x0
  803508:	e8 55 f6 ff ff       	call   802b62 <read>
	if (r < 0)
  80350d:	83 c4 10             	add    $0x10,%esp
  803510:	85 c0                	test   %eax,%eax
  803512:	78 0f                	js     803523 <getchar+0x29>
		return r;
	if (r < 1)
  803514:	85 c0                	test   %eax,%eax
  803516:	7e 06                	jle    80351e <getchar+0x24>
		return -E_EOF;
	return c;
  803518:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80351c:	eb 05                	jmp    803523 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80351e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803523:	c9                   	leave  
  803524:	c3                   	ret    

00803525 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803525:	55                   	push   %ebp
  803526:	89 e5                	mov    %esp,%ebp
  803528:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80352b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80352e:	50                   	push   %eax
  80352f:	ff 75 08             	pushl  0x8(%ebp)
  803532:	e8 c5 f3 ff ff       	call   8028fc <fd_lookup>
  803537:	83 c4 10             	add    $0x10,%esp
  80353a:	85 c0                	test   %eax,%eax
  80353c:	78 11                	js     80354f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80353e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803541:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803547:	39 10                	cmp    %edx,(%eax)
  803549:	0f 94 c0             	sete   %al
  80354c:	0f b6 c0             	movzbl %al,%eax
}
  80354f:	c9                   	leave  
  803550:	c3                   	ret    

00803551 <opencons>:

int
opencons(void)
{
  803551:	55                   	push   %ebp
  803552:	89 e5                	mov    %esp,%ebp
  803554:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80355a:	50                   	push   %eax
  80355b:	e8 4d f3 ff ff       	call   8028ad <fd_alloc>
  803560:	83 c4 10             	add    $0x10,%esp
		return r;
  803563:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803565:	85 c0                	test   %eax,%eax
  803567:	78 3e                	js     8035a7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803569:	83 ec 04             	sub    $0x4,%esp
  80356c:	68 07 04 00 00       	push   $0x407
  803571:	ff 75 f4             	pushl  -0xc(%ebp)
  803574:	6a 00                	push   $0x0
  803576:	e8 ac ef ff ff       	call   802527 <sys_page_alloc>
  80357b:	83 c4 10             	add    $0x10,%esp
		return r;
  80357e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803580:	85 c0                	test   %eax,%eax
  803582:	78 23                	js     8035a7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803584:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80358a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80358d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80358f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803592:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803599:	83 ec 0c             	sub    $0xc,%esp
  80359c:	50                   	push   %eax
  80359d:	e8 e4 f2 ff ff       	call   802886 <fd2num>
  8035a2:	89 c2                	mov    %eax,%edx
  8035a4:	83 c4 10             	add    $0x10,%esp
}
  8035a7:	89 d0                	mov    %edx,%eax
  8035a9:	c9                   	leave  
  8035aa:	c3                   	ret    
  8035ab:	66 90                	xchg   %ax,%ax
  8035ad:	66 90                	xchg   %ax,%ax
  8035af:	90                   	nop

008035b0 <__udivdi3>:
  8035b0:	55                   	push   %ebp
  8035b1:	57                   	push   %edi
  8035b2:	56                   	push   %esi
  8035b3:	53                   	push   %ebx
  8035b4:	83 ec 1c             	sub    $0x1c,%esp
  8035b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8035bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8035bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8035c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8035c7:	85 f6                	test   %esi,%esi
  8035c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8035cd:	89 ca                	mov    %ecx,%edx
  8035cf:	89 f8                	mov    %edi,%eax
  8035d1:	75 3d                	jne    803610 <__udivdi3+0x60>
  8035d3:	39 cf                	cmp    %ecx,%edi
  8035d5:	0f 87 c5 00 00 00    	ja     8036a0 <__udivdi3+0xf0>
  8035db:	85 ff                	test   %edi,%edi
  8035dd:	89 fd                	mov    %edi,%ebp
  8035df:	75 0b                	jne    8035ec <__udivdi3+0x3c>
  8035e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8035e6:	31 d2                	xor    %edx,%edx
  8035e8:	f7 f7                	div    %edi
  8035ea:	89 c5                	mov    %eax,%ebp
  8035ec:	89 c8                	mov    %ecx,%eax
  8035ee:	31 d2                	xor    %edx,%edx
  8035f0:	f7 f5                	div    %ebp
  8035f2:	89 c1                	mov    %eax,%ecx
  8035f4:	89 d8                	mov    %ebx,%eax
  8035f6:	89 cf                	mov    %ecx,%edi
  8035f8:	f7 f5                	div    %ebp
  8035fa:	89 c3                	mov    %eax,%ebx
  8035fc:	89 d8                	mov    %ebx,%eax
  8035fe:	89 fa                	mov    %edi,%edx
  803600:	83 c4 1c             	add    $0x1c,%esp
  803603:	5b                   	pop    %ebx
  803604:	5e                   	pop    %esi
  803605:	5f                   	pop    %edi
  803606:	5d                   	pop    %ebp
  803607:	c3                   	ret    
  803608:	90                   	nop
  803609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803610:	39 ce                	cmp    %ecx,%esi
  803612:	77 74                	ja     803688 <__udivdi3+0xd8>
  803614:	0f bd fe             	bsr    %esi,%edi
  803617:	83 f7 1f             	xor    $0x1f,%edi
  80361a:	0f 84 98 00 00 00    	je     8036b8 <__udivdi3+0x108>
  803620:	bb 20 00 00 00       	mov    $0x20,%ebx
  803625:	89 f9                	mov    %edi,%ecx
  803627:	89 c5                	mov    %eax,%ebp
  803629:	29 fb                	sub    %edi,%ebx
  80362b:	d3 e6                	shl    %cl,%esi
  80362d:	89 d9                	mov    %ebx,%ecx
  80362f:	d3 ed                	shr    %cl,%ebp
  803631:	89 f9                	mov    %edi,%ecx
  803633:	d3 e0                	shl    %cl,%eax
  803635:	09 ee                	or     %ebp,%esi
  803637:	89 d9                	mov    %ebx,%ecx
  803639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80363d:	89 d5                	mov    %edx,%ebp
  80363f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803643:	d3 ed                	shr    %cl,%ebp
  803645:	89 f9                	mov    %edi,%ecx
  803647:	d3 e2                	shl    %cl,%edx
  803649:	89 d9                	mov    %ebx,%ecx
  80364b:	d3 e8                	shr    %cl,%eax
  80364d:	09 c2                	or     %eax,%edx
  80364f:	89 d0                	mov    %edx,%eax
  803651:	89 ea                	mov    %ebp,%edx
  803653:	f7 f6                	div    %esi
  803655:	89 d5                	mov    %edx,%ebp
  803657:	89 c3                	mov    %eax,%ebx
  803659:	f7 64 24 0c          	mull   0xc(%esp)
  80365d:	39 d5                	cmp    %edx,%ebp
  80365f:	72 10                	jb     803671 <__udivdi3+0xc1>
  803661:	8b 74 24 08          	mov    0x8(%esp),%esi
  803665:	89 f9                	mov    %edi,%ecx
  803667:	d3 e6                	shl    %cl,%esi
  803669:	39 c6                	cmp    %eax,%esi
  80366b:	73 07                	jae    803674 <__udivdi3+0xc4>
  80366d:	39 d5                	cmp    %edx,%ebp
  80366f:	75 03                	jne    803674 <__udivdi3+0xc4>
  803671:	83 eb 01             	sub    $0x1,%ebx
  803674:	31 ff                	xor    %edi,%edi
  803676:	89 d8                	mov    %ebx,%eax
  803678:	89 fa                	mov    %edi,%edx
  80367a:	83 c4 1c             	add    $0x1c,%esp
  80367d:	5b                   	pop    %ebx
  80367e:	5e                   	pop    %esi
  80367f:	5f                   	pop    %edi
  803680:	5d                   	pop    %ebp
  803681:	c3                   	ret    
  803682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803688:	31 ff                	xor    %edi,%edi
  80368a:	31 db                	xor    %ebx,%ebx
  80368c:	89 d8                	mov    %ebx,%eax
  80368e:	89 fa                	mov    %edi,%edx
  803690:	83 c4 1c             	add    $0x1c,%esp
  803693:	5b                   	pop    %ebx
  803694:	5e                   	pop    %esi
  803695:	5f                   	pop    %edi
  803696:	5d                   	pop    %ebp
  803697:	c3                   	ret    
  803698:	90                   	nop
  803699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036a0:	89 d8                	mov    %ebx,%eax
  8036a2:	f7 f7                	div    %edi
  8036a4:	31 ff                	xor    %edi,%edi
  8036a6:	89 c3                	mov    %eax,%ebx
  8036a8:	89 d8                	mov    %ebx,%eax
  8036aa:	89 fa                	mov    %edi,%edx
  8036ac:	83 c4 1c             	add    $0x1c,%esp
  8036af:	5b                   	pop    %ebx
  8036b0:	5e                   	pop    %esi
  8036b1:	5f                   	pop    %edi
  8036b2:	5d                   	pop    %ebp
  8036b3:	c3                   	ret    
  8036b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036b8:	39 ce                	cmp    %ecx,%esi
  8036ba:	72 0c                	jb     8036c8 <__udivdi3+0x118>
  8036bc:	31 db                	xor    %ebx,%ebx
  8036be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8036c2:	0f 87 34 ff ff ff    	ja     8035fc <__udivdi3+0x4c>
  8036c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8036cd:	e9 2a ff ff ff       	jmp    8035fc <__udivdi3+0x4c>
  8036d2:	66 90                	xchg   %ax,%ax
  8036d4:	66 90                	xchg   %ax,%ax
  8036d6:	66 90                	xchg   %ax,%ax
  8036d8:	66 90                	xchg   %ax,%ax
  8036da:	66 90                	xchg   %ax,%ax
  8036dc:	66 90                	xchg   %ax,%ax
  8036de:	66 90                	xchg   %ax,%ax

008036e0 <__umoddi3>:
  8036e0:	55                   	push   %ebp
  8036e1:	57                   	push   %edi
  8036e2:	56                   	push   %esi
  8036e3:	53                   	push   %ebx
  8036e4:	83 ec 1c             	sub    $0x1c,%esp
  8036e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8036eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8036ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8036f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8036f7:	85 d2                	test   %edx,%edx
  8036f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8036fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803701:	89 f3                	mov    %esi,%ebx
  803703:	89 3c 24             	mov    %edi,(%esp)
  803706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80370a:	75 1c                	jne    803728 <__umoddi3+0x48>
  80370c:	39 f7                	cmp    %esi,%edi
  80370e:	76 50                	jbe    803760 <__umoddi3+0x80>
  803710:	89 c8                	mov    %ecx,%eax
  803712:	89 f2                	mov    %esi,%edx
  803714:	f7 f7                	div    %edi
  803716:	89 d0                	mov    %edx,%eax
  803718:	31 d2                	xor    %edx,%edx
  80371a:	83 c4 1c             	add    $0x1c,%esp
  80371d:	5b                   	pop    %ebx
  80371e:	5e                   	pop    %esi
  80371f:	5f                   	pop    %edi
  803720:	5d                   	pop    %ebp
  803721:	c3                   	ret    
  803722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803728:	39 f2                	cmp    %esi,%edx
  80372a:	89 d0                	mov    %edx,%eax
  80372c:	77 52                	ja     803780 <__umoddi3+0xa0>
  80372e:	0f bd ea             	bsr    %edx,%ebp
  803731:	83 f5 1f             	xor    $0x1f,%ebp
  803734:	75 5a                	jne    803790 <__umoddi3+0xb0>
  803736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80373a:	0f 82 e0 00 00 00    	jb     803820 <__umoddi3+0x140>
  803740:	39 0c 24             	cmp    %ecx,(%esp)
  803743:	0f 86 d7 00 00 00    	jbe    803820 <__umoddi3+0x140>
  803749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80374d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803751:	83 c4 1c             	add    $0x1c,%esp
  803754:	5b                   	pop    %ebx
  803755:	5e                   	pop    %esi
  803756:	5f                   	pop    %edi
  803757:	5d                   	pop    %ebp
  803758:	c3                   	ret    
  803759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803760:	85 ff                	test   %edi,%edi
  803762:	89 fd                	mov    %edi,%ebp
  803764:	75 0b                	jne    803771 <__umoddi3+0x91>
  803766:	b8 01 00 00 00       	mov    $0x1,%eax
  80376b:	31 d2                	xor    %edx,%edx
  80376d:	f7 f7                	div    %edi
  80376f:	89 c5                	mov    %eax,%ebp
  803771:	89 f0                	mov    %esi,%eax
  803773:	31 d2                	xor    %edx,%edx
  803775:	f7 f5                	div    %ebp
  803777:	89 c8                	mov    %ecx,%eax
  803779:	f7 f5                	div    %ebp
  80377b:	89 d0                	mov    %edx,%eax
  80377d:	eb 99                	jmp    803718 <__umoddi3+0x38>
  80377f:	90                   	nop
  803780:	89 c8                	mov    %ecx,%eax
  803782:	89 f2                	mov    %esi,%edx
  803784:	83 c4 1c             	add    $0x1c,%esp
  803787:	5b                   	pop    %ebx
  803788:	5e                   	pop    %esi
  803789:	5f                   	pop    %edi
  80378a:	5d                   	pop    %ebp
  80378b:	c3                   	ret    
  80378c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803790:	8b 34 24             	mov    (%esp),%esi
  803793:	bf 20 00 00 00       	mov    $0x20,%edi
  803798:	89 e9                	mov    %ebp,%ecx
  80379a:	29 ef                	sub    %ebp,%edi
  80379c:	d3 e0                	shl    %cl,%eax
  80379e:	89 f9                	mov    %edi,%ecx
  8037a0:	89 f2                	mov    %esi,%edx
  8037a2:	d3 ea                	shr    %cl,%edx
  8037a4:	89 e9                	mov    %ebp,%ecx
  8037a6:	09 c2                	or     %eax,%edx
  8037a8:	89 d8                	mov    %ebx,%eax
  8037aa:	89 14 24             	mov    %edx,(%esp)
  8037ad:	89 f2                	mov    %esi,%edx
  8037af:	d3 e2                	shl    %cl,%edx
  8037b1:	89 f9                	mov    %edi,%ecx
  8037b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8037b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8037bb:	d3 e8                	shr    %cl,%eax
  8037bd:	89 e9                	mov    %ebp,%ecx
  8037bf:	89 c6                	mov    %eax,%esi
  8037c1:	d3 e3                	shl    %cl,%ebx
  8037c3:	89 f9                	mov    %edi,%ecx
  8037c5:	89 d0                	mov    %edx,%eax
  8037c7:	d3 e8                	shr    %cl,%eax
  8037c9:	89 e9                	mov    %ebp,%ecx
  8037cb:	09 d8                	or     %ebx,%eax
  8037cd:	89 d3                	mov    %edx,%ebx
  8037cf:	89 f2                	mov    %esi,%edx
  8037d1:	f7 34 24             	divl   (%esp)
  8037d4:	89 d6                	mov    %edx,%esi
  8037d6:	d3 e3                	shl    %cl,%ebx
  8037d8:	f7 64 24 04          	mull   0x4(%esp)
  8037dc:	39 d6                	cmp    %edx,%esi
  8037de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8037e2:	89 d1                	mov    %edx,%ecx
  8037e4:	89 c3                	mov    %eax,%ebx
  8037e6:	72 08                	jb     8037f0 <__umoddi3+0x110>
  8037e8:	75 11                	jne    8037fb <__umoddi3+0x11b>
  8037ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8037ee:	73 0b                	jae    8037fb <__umoddi3+0x11b>
  8037f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8037f4:	1b 14 24             	sbb    (%esp),%edx
  8037f7:	89 d1                	mov    %edx,%ecx
  8037f9:	89 c3                	mov    %eax,%ebx
  8037fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8037ff:	29 da                	sub    %ebx,%edx
  803801:	19 ce                	sbb    %ecx,%esi
  803803:	89 f9                	mov    %edi,%ecx
  803805:	89 f0                	mov    %esi,%eax
  803807:	d3 e0                	shl    %cl,%eax
  803809:	89 e9                	mov    %ebp,%ecx
  80380b:	d3 ea                	shr    %cl,%edx
  80380d:	89 e9                	mov    %ebp,%ecx
  80380f:	d3 ee                	shr    %cl,%esi
  803811:	09 d0                	or     %edx,%eax
  803813:	89 f2                	mov    %esi,%edx
  803815:	83 c4 1c             	add    $0x1c,%esp
  803818:	5b                   	pop    %ebx
  803819:	5e                   	pop    %esi
  80381a:	5f                   	pop    %edi
  80381b:	5d                   	pop    %ebp
  80381c:	c3                   	ret    
  80381d:	8d 76 00             	lea    0x0(%esi),%esi
  803820:	29 f9                	sub    %edi,%ecx
  803822:	19 d6                	sbb    %edx,%esi
  803824:	89 74 24 04          	mov    %esi,0x4(%esp)
  803828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80382c:	e9 18 ff ff ff       	jmp    803749 <__umoddi3+0x69>
