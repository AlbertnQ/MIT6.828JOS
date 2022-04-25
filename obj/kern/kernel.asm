
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 1e 21 f0    	mov    %esi,0xf0211e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 1d 5b 00 00       	call   f0105b7e <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 62 10 f0       	push   $0xf0106220
f010006d:	e8 6f 37 00 00       	call   f01037e1 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 3f 37 00 00       	call   f01037bb <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 ca 73 10 f0 	movl   $0xf01073ca,(%esp)
f0100083:	e8 59 37 00 00       	call   f01037e1 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 99 08 00 00       	call   f010092e <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 04             	sub    $0x4,%esp
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000a1:	e8 99 05 00 00       	call   f010063f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 8c 62 10 f0       	push   $0xf010628c
f01000b3:	e8 29 37 00 00       	call   f01037e1 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 19 13 00 00       	call   f01013d6 <mem_init>


	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 37 2f 00 00       	call   f0102ff9 <env_init>
	trap_init();
f01000c2:	e8 e5 37 00 00       	call   f01038ac <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 a8 57 00 00       	call   f0105874 <mp_init>
	lapic_init();
f01000cc:	e8 c8 5a 00 00       	call   f0105b99 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 32 36 00 00       	call   f0103708 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 0a 5d 00 00       	call   f0105dec <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 1e 21 f0 07 	cmpl   $0x7,0xf0211e88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 44 62 10 f0       	push   $0xf0106244
f01000f8:	6a 79                	push   $0x79
f01000fa:	68 a7 62 10 f0       	push   $0xf01062a7
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 da 57 10 f0       	mov    $0xf01057da,%eax
f010010c:	2d 60 57 10 f0       	sub    $0xf0105760,%eax
f0100111:	50                   	push   %eax
f0100112:	68 60 57 10 f0       	push   $0xf0105760
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 8a 54 00 00       	call   f01055ab <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 20 21 f0       	mov    $0xf0212020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 4e 5a 00 00       	call   f0105b7e <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 20 21 f0       	sub    $0xf0212020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 b0 21 f0       	add    $0xf021b000,%eax
f0100154:	a3 84 1e 21 f0       	mov    %eax,0xf0211e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 7d 5b 00 00       	call   f0105ce7 <lapic_startap>
f010016a:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010016d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100170:	83 f8 01             	cmp    $0x1,%eax
f0100173:	75 f8                	jne    f010016d <i386_init+0xd3>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100175:	83 c3 74             	add    $0x74,%ebx
f0100178:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f010017f:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>
    	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 01                	push   $0x1
f010018d:	68 b0 0c 1d f0       	push   $0xf01d0cb0
f0100192:	e8 53 30 00 00       	call   f01031ea <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100197:	83 c4 08             	add    $0x8,%esp
f010019a:	6a 00                	push   $0x0
f010019c:	68 60 0d 20 f0       	push   $0xf0200d60
f01001a1:	e8 44 30 00 00       	call   f01031ea <env_create>
    //ENV_CREATE(user_yield, ENV_TYPE_USER);

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001a6:	e8 38 04 00 00       	call   f01005e3 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001ab:	e8 2c 42 00 00       	call   f01043dc <sched_yield>

f01001b0 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b0:	55                   	push   %ebp
f01001b1:	89 e5                	mov    %esp,%ebp
f01001b3:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c0:	77 15                	ja     f01001d7 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c2:	50                   	push   %eax
f01001c3:	68 68 62 10 f0       	push   $0xf0106268
f01001c8:	68 90 00 00 00       	push   $0x90
f01001cd:	68 a7 62 10 f0       	push   $0xf01062a7
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 9a 59 00 00       	call   f0105b7e <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 b3 62 10 f0       	push   $0xf01062b3
f01001ed:	e8 ef 35 00 00       	call   f01037e1 <cprintf>

	lapic_init();
f01001f2:	e8 a2 59 00 00       	call   f0105b99 <lapic_init>
	env_init_percpu();
f01001f7:	e8 cd 2d 00 00       	call   f0102fc9 <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 f4 35 00 00       	call   f01037f5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 78 59 00 00       	call   f0105b7e <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021f:	e8 c8 5b 00 00       	call   f0105dec <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
    lock_kernel();
    sched_yield();
f0100224:	e8 b3 41 00 00       	call   f01043dc <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 c9 62 10 f0       	push   $0xf01062c9
f010023e:	e8 9e 35 00 00       	call   f01037e1 <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 6c 35 00 00       	call   f01037bb <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 ca 73 10 f0 	movl   $0xf01073ca,(%esp)
f0100256:	e8 86 35 00 00       	call   f01037e1 <cprintf>
	va_end(ap);
}
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 12 21 f0    	mov    0xf0211224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 12 21 f0    	mov    %edx,0xf0211224
f01002a0:	88 81 20 10 21 f0    	mov    %al,-0xfdeefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 12 21 f0 00 	movl   $0x0,0xf0211224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f8 00 00 00    	je     f01003cb <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002d3:	a8 20                	test   $0x20,%al
f01002d5:	0f 85 f6 00 00 00    	jne    f01003d1 <kbd_proc_data+0x10c>
f01002db:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e3:	3c e0                	cmp    $0xe0,%al
f01002e5:	75 0d                	jne    f01002f4 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002e7:	83 0d 00 10 21 f0 40 	orl    $0x40,0xf0211000
		return 0;
f01002ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f4:	55                   	push   %ebp
f01002f5:	89 e5                	mov    %esp,%ebp
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 36                	jns    f0100335 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100305:	89 cb                	mov    %ecx,%ebx
f0100307:	83 e3 40             	and    $0x40,%ebx
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 db                	test   %ebx,%ebx
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 82 40 64 10 f0 	movzbl -0xfef9bc0(%edx),%eax
f010031c:	83 c8 40             	or     $0x40,%eax
f010031f:	0f b6 c0             	movzbl %al,%eax
f0100322:	f7 d0                	not    %eax
f0100324:	21 c8                	and    %ecx,%eax
f0100326:	a3 00 10 21 f0       	mov    %eax,0xf0211000
		return 0;
f010032b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100330:	e9 a4 00 00 00       	jmp    f01003d9 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100335:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f010033b:	f6 c1 40             	test   $0x40,%cl
f010033e:	74 0e                	je     f010034e <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100340:	83 c8 80             	or     $0xffffff80,%eax
f0100343:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100345:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100348:	89 0d 00 10 21 f0    	mov    %ecx,0xf0211000
	}

	shift |= shiftcode[data];
f010034e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100351:	0f b6 82 40 64 10 f0 	movzbl -0xfef9bc0(%edx),%eax
f0100358:	0b 05 00 10 21 f0    	or     0xf0211000,%eax
f010035e:	0f b6 8a 40 63 10 f0 	movzbl -0xfef9cc0(%edx),%ecx
f0100365:	31 c8                	xor    %ecx,%eax
f0100367:	a3 00 10 21 f0       	mov    %eax,0xf0211000

	c = charcode[shift & (CTL | SHIFT)][data];
f010036c:	89 c1                	mov    %eax,%ecx
f010036e:	83 e1 03             	and    $0x3,%ecx
f0100371:	8b 0c 8d 20 63 10 f0 	mov    -0xfef9ce0(,%ecx,4),%ecx
f0100378:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010037c:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037f:	a8 08                	test   $0x8,%al
f0100381:	74 1b                	je     f010039e <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100383:	89 da                	mov    %ebx,%edx
f0100385:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100388:	83 f9 19             	cmp    $0x19,%ecx
f010038b:	77 05                	ja     f0100392 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010038d:	83 eb 20             	sub    $0x20,%ebx
f0100390:	eb 0c                	jmp    f010039e <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100392:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100395:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100398:	83 fa 19             	cmp    $0x19,%edx
f010039b:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039e:	f7 d0                	not    %eax
f01003a0:	a8 06                	test   $0x6,%al
f01003a2:	75 33                	jne    f01003d7 <kbd_proc_data+0x112>
f01003a4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003aa:	75 2b                	jne    f01003d7 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003ac:	83 ec 0c             	sub    $0xc,%esp
f01003af:	68 e3 62 10 f0       	push   $0xf01062e3
f01003b4:	e8 28 34 00 00       	call   f01037e1 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	ba 92 00 00 00       	mov    $0x92,%edx
f01003be:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c3:	ee                   	out    %al,(%dx)
f01003c4:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c7:	89 d8                	mov    %ebx,%eax
f01003c9:	eb 0e                	jmp    f01003d9 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003d0:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003d6:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d7:	89 d8                	mov    %ebx,%eax
}
f01003d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003dc:	c9                   	leave  
f01003dd:	c3                   	ret    

f01003de <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003de:	55                   	push   %ebp
f01003df:	89 e5                	mov    %esp,%ebp
f01003e1:	57                   	push   %edi
f01003e2:	56                   	push   %esi
f01003e3:	53                   	push   %ebx
f01003e4:	83 ec 1c             	sub    $0x1c,%esp
f01003e7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e9:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ee:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f8:	eb 09                	jmp    f0100403 <cons_putc+0x25>
f01003fa:	89 ca                	mov    %ecx,%edx
f01003fc:	ec                   	in     (%dx),%al
f01003fd:	ec                   	in     (%dx),%al
f01003fe:	ec                   	in     (%dx),%al
f01003ff:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100400:	83 c3 01             	add    $0x1,%ebx
f0100403:	89 f2                	mov    %esi,%edx
f0100405:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100406:	a8 20                	test   $0x20,%al
f0100408:	75 08                	jne    f0100412 <cons_putc+0x34>
f010040a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100410:	7e e8                	jle    f01003fa <cons_putc+0x1c>
f0100412:	89 f8                	mov    %edi,%eax
f0100414:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100417:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010041c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100422:	be 79 03 00 00       	mov    $0x379,%esi
f0100427:	b9 84 00 00 00       	mov    $0x84,%ecx
f010042c:	eb 09                	jmp    f0100437 <cons_putc+0x59>
f010042e:	89 ca                	mov    %ecx,%edx
f0100430:	ec                   	in     (%dx),%al
f0100431:	ec                   	in     (%dx),%al
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	83 c3 01             	add    $0x1,%ebx
f0100437:	89 f2                	mov    %esi,%edx
f0100439:	ec                   	in     (%dx),%al
f010043a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100440:	7f 04                	jg     f0100446 <cons_putc+0x68>
f0100442:	84 c0                	test   %al,%al
f0100444:	79 e8                	jns    f010042e <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100446:	ba 78 03 00 00       	mov    $0x378,%edx
f010044b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044f:	ee                   	out    %al,(%dx)
f0100450:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100455:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045a:	ee                   	out    %al,(%dx)
f010045b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100460:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100461:	89 fa                	mov    %edi,%edx
f0100463:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100469:	89 f8                	mov    %edi,%eax
f010046b:	80 cc 07             	or     $0x7,%ah
f010046e:	85 d2                	test   %edx,%edx
f0100470:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100473:	89 f8                	mov    %edi,%eax
f0100475:	0f b6 c0             	movzbl %al,%eax
f0100478:	83 f8 09             	cmp    $0x9,%eax
f010047b:	74 74                	je     f01004f1 <cons_putc+0x113>
f010047d:	83 f8 09             	cmp    $0x9,%eax
f0100480:	7f 0a                	jg     f010048c <cons_putc+0xae>
f0100482:	83 f8 08             	cmp    $0x8,%eax
f0100485:	74 14                	je     f010049b <cons_putc+0xbd>
f0100487:	e9 99 00 00 00       	jmp    f0100525 <cons_putc+0x147>
f010048c:	83 f8 0a             	cmp    $0xa,%eax
f010048f:	74 3a                	je     f01004cb <cons_putc+0xed>
f0100491:	83 f8 0d             	cmp    $0xd,%eax
f0100494:	74 3d                	je     f01004d3 <cons_putc+0xf5>
f0100496:	e9 8a 00 00 00       	jmp    f0100525 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010049b:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004a2:	66 85 c0             	test   %ax,%ax
f01004a5:	0f 84 e6 00 00 00    	je     f0100591 <cons_putc+0x1b3>
			crt_pos--;
f01004ab:	83 e8 01             	sub    $0x1,%eax
f01004ae:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b4:	0f b7 c0             	movzwl %ax,%eax
f01004b7:	66 81 e7 00 ff       	and    $0xff00,%di
f01004bc:	83 cf 20             	or     $0x20,%edi
f01004bf:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	eb 78                	jmp    f0100543 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004cb:	66 83 05 28 12 21 f0 	addw   $0x50,0xf0211228
f01004d2:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d3:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004da:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e0:	c1 e8 16             	shr    $0x16,%eax
f01004e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e6:	c1 e0 04             	shl    $0x4,%eax
f01004e9:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
f01004ef:	eb 52                	jmp    f0100543 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f6:	e8 e3 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f01004fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0100500:	e8 d9 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100505:	b8 20 00 00 00       	mov    $0x20,%eax
f010050a:	e8 cf fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f010050f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100514:	e8 c5 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100519:	b8 20 00 00 00       	mov    $0x20,%eax
f010051e:	e8 bb fe ff ff       	call   f01003de <cons_putc>
f0100523:	eb 1e                	jmp    f0100543 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100525:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f010052c:	8d 50 01             	lea    0x1(%eax),%edx
f010052f:	66 89 15 28 12 21 f0 	mov    %dx,0xf0211228
f0100536:	0f b7 c0             	movzwl %ax,%eax
f0100539:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f010053f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100543:	66 81 3d 28 12 21 f0 	cmpw   $0x7cf,0xf0211228
f010054a:	cf 07 
f010054c:	76 43                	jbe    f0100591 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054e:	a1 2c 12 21 f0       	mov    0xf021122c,%eax
f0100553:	83 ec 04             	sub    $0x4,%esp
f0100556:	68 00 0f 00 00       	push   $0xf00
f010055b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100561:	52                   	push   %edx
f0100562:	50                   	push   %eax
f0100563:	e8 43 50 00 00       	call   f01055ab <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100568:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f010056e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100574:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010057a:	83 c4 10             	add    $0x10,%esp
f010057d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100582:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100585:	39 d0                	cmp    %edx,%eax
f0100587:	75 f4                	jne    f010057d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100589:	66 83 2d 28 12 21 f0 	subw   $0x50,0xf0211228
f0100590:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100591:	8b 0d 30 12 21 f0    	mov    0xf0211230,%ecx
f0100597:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059c:	89 ca                	mov    %ecx,%edx
f010059e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059f:	0f b7 1d 28 12 21 f0 	movzwl 0xf0211228,%ebx
f01005a6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a9:	89 d8                	mov    %ebx,%eax
f01005ab:	66 c1 e8 08          	shr    $0x8,%ax
f01005af:	89 f2                	mov    %esi,%edx
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b7:	89 ca                	mov    %ecx,%edx
f01005b9:	ee                   	out    %al,(%dx)
f01005ba:	89 d8                	mov    %ebx,%eax
f01005bc:	89 f2                	mov    %esi,%edx
f01005be:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c2:	5b                   	pop    %ebx
f01005c3:	5e                   	pop    %esi
f01005c4:	5f                   	pop    %edi
f01005c5:	5d                   	pop    %ebp
f01005c6:	c3                   	ret    

f01005c7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005c7:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f01005ce:	74 11                	je     f01005e1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d0:	55                   	push   %ebp
f01005d1:	89 e5                	mov    %esp,%ebp
f01005d3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005d6:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005db:	e8 a2 fc ff ff       	call   f0100282 <cons_intr>
}
f01005e0:	c9                   	leave  
f01005e1:	f3 c3                	repz ret 

f01005e3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e3:	55                   	push   %ebp
f01005e4:	89 e5                	mov    %esp,%ebp
f01005e6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e9:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005ee:	e8 8f fc ff ff       	call   f0100282 <cons_intr>
}
f01005f3:	c9                   	leave  
f01005f4:	c3                   	ret    

f01005f5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005fb:	e8 c7 ff ff ff       	call   f01005c7 <serial_intr>
	kbd_intr();
f0100600:	e8 de ff ff ff       	call   f01005e3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100605:	a1 20 12 21 f0       	mov    0xf0211220,%eax
f010060a:	3b 05 24 12 21 f0    	cmp    0xf0211224,%eax
f0100610:	74 26                	je     f0100638 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100612:	8d 50 01             	lea    0x1(%eax),%edx
f0100615:	89 15 20 12 21 f0    	mov    %edx,0xf0211220
f010061b:	0f b6 88 20 10 21 f0 	movzbl -0xfdeefe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100622:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100624:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010062a:	75 11                	jne    f010063d <cons_getc+0x48>
			cons.rpos = 0;
f010062c:	c7 05 20 12 21 f0 00 	movl   $0x0,0xf0211220
f0100633:	00 00 00 
f0100636:	eb 05                	jmp    f010063d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100638:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010063d:	c9                   	leave  
f010063e:	c3                   	ret    

f010063f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010063f:	55                   	push   %ebp
f0100640:	89 e5                	mov    %esp,%ebp
f0100642:	57                   	push   %edi
f0100643:	56                   	push   %esi
f0100644:	53                   	push   %ebx
f0100645:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100648:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100656:	5a a5 
	if (*cp != 0xA55A) {
f0100658:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100663:	74 11                	je     f0100676 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100665:	c7 05 30 12 21 f0 b4 	movl   $0x3b4,0xf0211230
f010066c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100674:	eb 16                	jmp    f010068c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100676:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010067d:	c7 05 30 12 21 f0 d4 	movl   $0x3d4,0xf0211230
f0100684:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100687:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010068c:	8b 3d 30 12 21 f0    	mov    0xf0211230,%edi
f0100692:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100697:	89 fa                	mov    %edi,%edx
f0100699:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069a:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069d:	89 da                	mov    %ebx,%edx
f010069f:	ec                   	in     (%dx),%al
f01006a0:	0f b6 c8             	movzbl %al,%ecx
f01006a3:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ae:	89 da                	mov    %ebx,%edx
f01006b0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b1:	89 35 2c 12 21 f0    	mov    %esi,0xf021122c
	crt_pos = pos;
f01006b7:	0f b6 c0             	movzbl %al,%eax
f01006ba:	09 c8                	or     %ecx,%eax
f01006bc:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c2:	e8 1c ff ff ff       	call   f01005e3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c7:	83 ec 0c             	sub    $0xc,%esp
f01006ca:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006d1:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d6:	50                   	push   %eax
f01006d7:	e8 b4 2f 00 00       	call   f0103690 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006dc:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e6:	89 f2                	mov    %esi,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006ee:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f3:	ee                   	out    %al,(%dx)
f01006f4:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100706:	b8 00 00 00 00       	mov    $0x0,%eax
f010070b:	ee                   	out    %al,(%dx)
f010070c:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100711:	b8 03 00 00 00       	mov    $0x3,%eax
f0100716:	ee                   	out    %al,(%dx)
f0100717:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010071c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100721:	ee                   	out    %al,(%dx)
f0100722:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100727:	b8 01 00 00 00       	mov    $0x1,%eax
f010072c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100732:	ec                   	in     (%dx),%al
f0100733:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100735:	83 c4 10             	add    $0x10,%esp
f0100738:	3c ff                	cmp    $0xff,%al
f010073a:	0f 95 05 34 12 21 f0 	setne  0xf0211234
f0100741:	89 f2                	mov    %esi,%edx
f0100743:	ec                   	in     (%dx),%al
f0100744:	89 da                	mov    %ebx,%edx
f0100746:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100747:	80 f9 ff             	cmp    $0xff,%cl
f010074a:	74 21                	je     f010076d <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f010074c:	83 ec 0c             	sub    $0xc,%esp
f010074f:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0100756:	25 ef ff 00 00       	and    $0xffef,%eax
f010075b:	50                   	push   %eax
f010075c:	e8 2f 2f 00 00       	call   f0103690 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100761:	83 c4 10             	add    $0x10,%esp
f0100764:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f010076b:	75 10                	jne    f010077d <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010076d:	83 ec 0c             	sub    $0xc,%esp
f0100770:	68 ef 62 10 f0       	push   $0xf01062ef
f0100775:	e8 67 30 00 00       	call   f01037e1 <cprintf>
f010077a:	83 c4 10             	add    $0x10,%esp
}
f010077d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100780:	5b                   	pop    %ebx
f0100781:	5e                   	pop    %esi
f0100782:	5f                   	pop    %edi
f0100783:	5d                   	pop    %ebp
f0100784:	c3                   	ret    

f0100785 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
f0100788:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010078b:	8b 45 08             	mov    0x8(%ebp),%eax
f010078e:	e8 4b fc ff ff       	call   f01003de <cons_putc>
}
f0100793:	c9                   	leave  
f0100794:	c3                   	ret    

f0100795 <getchar>:

int
getchar(void)
{
f0100795:	55                   	push   %ebp
f0100796:	89 e5                	mov    %esp,%ebp
f0100798:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010079b:	e8 55 fe ff ff       	call   f01005f5 <cons_getc>
f01007a0:	85 c0                	test   %eax,%eax
f01007a2:	74 f7                	je     f010079b <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a4:	c9                   	leave  
f01007a5:	c3                   	ret    

f01007a6 <iscons>:

int
iscons(int fdnum)
{
f01007a6:	55                   	push   %ebp
f01007a7:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ae:	5d                   	pop    %ebp
f01007af:	c3                   	ret    

f01007b0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007b0:	55                   	push   %ebp
f01007b1:	89 e5                	mov    %esp,%ebp
f01007b3:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b6:	68 40 65 10 f0       	push   $0xf0106540
f01007bb:	68 5e 65 10 f0       	push   $0xf010655e
f01007c0:	68 63 65 10 f0       	push   $0xf0106563
f01007c5:	e8 17 30 00 00       	call   f01037e1 <cprintf>
f01007ca:	83 c4 0c             	add    $0xc,%esp
f01007cd:	68 f0 65 10 f0       	push   $0xf01065f0
f01007d2:	68 6c 65 10 f0       	push   $0xf010656c
f01007d7:	68 63 65 10 f0       	push   $0xf0106563
f01007dc:	e8 00 30 00 00       	call   f01037e1 <cprintf>
	return 0;
}
f01007e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e6:	c9                   	leave  
f01007e7:	c3                   	ret    

f01007e8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007e8:	55                   	push   %ebp
f01007e9:	89 e5                	mov    %esp,%ebp
f01007eb:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ee:	68 75 65 10 f0       	push   $0xf0106575
f01007f3:	e8 e9 2f 00 00       	call   f01037e1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007f8:	83 c4 08             	add    $0x8,%esp
f01007fb:	68 0c 00 10 00       	push   $0x10000c
f0100800:	68 18 66 10 f0       	push   $0xf0106618
f0100805:	e8 d7 2f 00 00       	call   f01037e1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010080a:	83 c4 0c             	add    $0xc,%esp
f010080d:	68 0c 00 10 00       	push   $0x10000c
f0100812:	68 0c 00 10 f0       	push   $0xf010000c
f0100817:	68 40 66 10 f0       	push   $0xf0106640
f010081c:	e8 c0 2f 00 00       	call   f01037e1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	68 01 62 10 00       	push   $0x106201
f0100829:	68 01 62 10 f0       	push   $0xf0106201
f010082e:	68 64 66 10 f0       	push   $0xf0106664
f0100833:	e8 a9 2f 00 00       	call   f01037e1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100838:	83 c4 0c             	add    $0xc,%esp
f010083b:	68 00 10 21 00       	push   $0x211000
f0100840:	68 00 10 21 f0       	push   $0xf0211000
f0100845:	68 88 66 10 f0       	push   $0xf0106688
f010084a:	e8 92 2f 00 00       	call   f01037e1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084f:	83 c4 0c             	add    $0xc,%esp
f0100852:	68 08 30 25 00       	push   $0x253008
f0100857:	68 08 30 25 f0       	push   $0xf0253008
f010085c:	68 ac 66 10 f0       	push   $0xf01066ac
f0100861:	e8 7b 2f 00 00       	call   f01037e1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100866:	b8 07 34 25 f0       	mov    $0xf0253407,%eax
f010086b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100870:	83 c4 08             	add    $0x8,%esp
f0100873:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100878:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010087e:	85 c0                	test   %eax,%eax
f0100880:	0f 48 c2             	cmovs  %edx,%eax
f0100883:	c1 f8 0a             	sar    $0xa,%eax
f0100886:	50                   	push   %eax
f0100887:	68 d0 66 10 f0       	push   $0xf01066d0
f010088c:	e8 50 2f 00 00       	call   f01037e1 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100891:	b8 00 00 00 00       	mov    $0x0,%eax
f0100896:	c9                   	leave  
f0100897:	c3                   	ret    

f0100898 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100898:	55                   	push   %ebp
f0100899:	89 e5                	mov    %esp,%ebp
f010089b:	57                   	push   %edi
f010089c:	56                   	push   %esi
f010089d:	53                   	push   %ebx
f010089e:	83 ec 3c             	sub    $0x3c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a1:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t  eip;
	uint32_t* ebp;
	ebp=(uint32_t*)read_ebp();
	
	while(ebp){
f01008a3:	eb 78                	jmp    f010091d <mon_backtrace+0x85>
		eip=*(ebp+1);
f01008a5:	8b 46 04             	mov    0x4(%esi),%eax
f01008a8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("ebp %x eip %x",(int)ebp,eip);
f01008ab:	83 ec 04             	sub    $0x4,%esp
f01008ae:	50                   	push   %eax
f01008af:	56                   	push   %esi
f01008b0:	68 8e 65 10 f0       	push   $0xf010658e
f01008b5:	e8 27 2f 00 00       	call   f01037e1 <cprintf>
f01008ba:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008bd:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008c0:	83 c4 10             	add    $0x10,%esp
		uint32_t* args=ebp+2;
		for(int i=0;i<5;i++){
			uint32_t argi=args[i];
			cprintf(" %08x ",argi);
f01008c3:	83 ec 08             	sub    $0x8,%esp
f01008c6:	ff 33                	pushl  (%ebx)
f01008c8:	68 9c 65 10 f0       	push   $0xf010659c
f01008cd:	e8 0f 2f 00 00       	call   f01037e1 <cprintf>
f01008d2:	83 c3 04             	add    $0x4,%ebx
	
	while(ebp){
		eip=*(ebp+1);
		cprintf("ebp %x eip %x",(int)ebp,eip);
		uint32_t* args=ebp+2;
		for(int i=0;i<5;i++){
f01008d5:	83 c4 10             	add    $0x10,%esp
f01008d8:	39 fb                	cmp    %edi,%ebx
f01008da:	75 e7                	jne    f01008c3 <mon_backtrace+0x2b>
			uint32_t argi=args[i];
			cprintf(" %08x ",argi);
		}
		cprintf("\n");
f01008dc:	83 ec 0c             	sub    $0xc,%esp
f01008df:	68 ca 73 10 f0       	push   $0xf01073ca
f01008e4:	e8 f8 2e 00 00       	call   f01037e1 <cprintf>
		struct Eipdebuginfo debug_info;
		debuginfo_eip(eip, &debug_info);
f01008e9:	83 c4 08             	add    $0x8,%esp
f01008ec:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008ef:	50                   	push   %eax
f01008f0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01008f3:	57                   	push   %edi
f01008f4:	e8 c2 41 00 00       	call   f0104abb <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f01008f9:	83 c4 08             	add    $0x8,%esp
f01008fc:	89 f8                	mov    %edi,%eax
f01008fe:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100901:	50                   	push   %eax
f0100902:	ff 75 d8             	pushl  -0x28(%ebp)
f0100905:	ff 75 dc             	pushl  -0x24(%ebp)
f0100908:	ff 75 d4             	pushl  -0x2c(%ebp)
f010090b:	ff 75 d0             	pushl  -0x30(%ebp)
f010090e:	68 a3 65 10 f0       	push   $0xf01065a3
f0100913:	e8 c9 2e 00 00       	call   f01037e1 <cprintf>
			debug_info.eip_file, debug_info.eip_line, debug_info.eip_fn_namelen,
			debug_info.eip_fn_name, eip - debug_info.eip_fn_addr);
		ebp=(uint32_t*) *ebp;
f0100918:	8b 36                	mov    (%esi),%esi
f010091a:	83 c4 20             	add    $0x20,%esp
	// Your code here.
	uint32_t  eip;
	uint32_t* ebp;
	ebp=(uint32_t*)read_ebp();
	
	while(ebp){
f010091d:	85 f6                	test   %esi,%esi
f010091f:	75 84                	jne    f01008a5 <mon_backtrace+0xd>

	}


	return 0;
}
f0100921:	b8 00 00 00 00       	mov    $0x0,%eax
f0100926:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100929:	5b                   	pop    %ebx
f010092a:	5e                   	pop    %esi
f010092b:	5f                   	pop    %edi
f010092c:	5d                   	pop    %ebp
f010092d:	c3                   	ret    

f010092e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010092e:	55                   	push   %ebp
f010092f:	89 e5                	mov    %esp,%ebp
f0100931:	57                   	push   %edi
f0100932:	56                   	push   %esi
f0100933:	53                   	push   %ebx
f0100934:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100937:	68 fc 66 10 f0       	push   $0xf01066fc
f010093c:	e8 a0 2e 00 00       	call   f01037e1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100941:	c7 04 24 20 67 10 f0 	movl   $0xf0106720,(%esp)
f0100948:	e8 94 2e 00 00       	call   f01037e1 <cprintf>

	if (tf != NULL)
f010094d:	83 c4 10             	add    $0x10,%esp
f0100950:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100954:	74 0e                	je     f0100964 <monitor+0x36>
		print_trapframe(tf);
f0100956:	83 ec 0c             	sub    $0xc,%esp
f0100959:	ff 75 08             	pushl  0x8(%ebp)
f010095c:	e8 19 34 00 00       	call   f0103d7a <print_trapframe>
f0100961:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100964:	83 ec 0c             	sub    $0xc,%esp
f0100967:	68 b4 65 10 f0       	push   $0xf01065b4
f010096c:	e8 7e 49 00 00       	call   f01052ef <readline>
f0100971:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100973:	83 c4 10             	add    $0x10,%esp
f0100976:	85 c0                	test   %eax,%eax
f0100978:	74 ea                	je     f0100964 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010097a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100981:	be 00 00 00 00       	mov    $0x0,%esi
f0100986:	eb 0a                	jmp    f0100992 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100988:	c6 03 00             	movb   $0x0,(%ebx)
f010098b:	89 f7                	mov    %esi,%edi
f010098d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100990:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100992:	0f b6 03             	movzbl (%ebx),%eax
f0100995:	84 c0                	test   %al,%al
f0100997:	74 63                	je     f01009fc <monitor+0xce>
f0100999:	83 ec 08             	sub    $0x8,%esp
f010099c:	0f be c0             	movsbl %al,%eax
f010099f:	50                   	push   %eax
f01009a0:	68 b8 65 10 f0       	push   $0xf01065b8
f01009a5:	e8 77 4b 00 00       	call   f0105521 <strchr>
f01009aa:	83 c4 10             	add    $0x10,%esp
f01009ad:	85 c0                	test   %eax,%eax
f01009af:	75 d7                	jne    f0100988 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009b1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009b4:	74 46                	je     f01009fc <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009b6:	83 fe 0f             	cmp    $0xf,%esi
f01009b9:	75 14                	jne    f01009cf <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009bb:	83 ec 08             	sub    $0x8,%esp
f01009be:	6a 10                	push   $0x10
f01009c0:	68 bd 65 10 f0       	push   $0xf01065bd
f01009c5:	e8 17 2e 00 00       	call   f01037e1 <cprintf>
f01009ca:	83 c4 10             	add    $0x10,%esp
f01009cd:	eb 95                	jmp    f0100964 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009cf:	8d 7e 01             	lea    0x1(%esi),%edi
f01009d2:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009d6:	eb 03                	jmp    f01009db <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009d8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009db:	0f b6 03             	movzbl (%ebx),%eax
f01009de:	84 c0                	test   %al,%al
f01009e0:	74 ae                	je     f0100990 <monitor+0x62>
f01009e2:	83 ec 08             	sub    $0x8,%esp
f01009e5:	0f be c0             	movsbl %al,%eax
f01009e8:	50                   	push   %eax
f01009e9:	68 b8 65 10 f0       	push   $0xf01065b8
f01009ee:	e8 2e 4b 00 00       	call   f0105521 <strchr>
f01009f3:	83 c4 10             	add    $0x10,%esp
f01009f6:	85 c0                	test   %eax,%eax
f01009f8:	74 de                	je     f01009d8 <monitor+0xaa>
f01009fa:	eb 94                	jmp    f0100990 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009fc:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a03:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a04:	85 f6                	test   %esi,%esi
f0100a06:	0f 84 58 ff ff ff    	je     f0100964 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a0c:	83 ec 08             	sub    $0x8,%esp
f0100a0f:	68 5e 65 10 f0       	push   $0xf010655e
f0100a14:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a17:	e8 a7 4a 00 00       	call   f01054c3 <strcmp>
f0100a1c:	83 c4 10             	add    $0x10,%esp
f0100a1f:	85 c0                	test   %eax,%eax
f0100a21:	74 1e                	je     f0100a41 <monitor+0x113>
f0100a23:	83 ec 08             	sub    $0x8,%esp
f0100a26:	68 6c 65 10 f0       	push   $0xf010656c
f0100a2b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a2e:	e8 90 4a 00 00       	call   f01054c3 <strcmp>
f0100a33:	83 c4 10             	add    $0x10,%esp
f0100a36:	85 c0                	test   %eax,%eax
f0100a38:	75 2f                	jne    f0100a69 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a3a:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a3f:	eb 05                	jmp    f0100a46 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a41:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100a46:	83 ec 04             	sub    $0x4,%esp
f0100a49:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a4c:	01 d0                	add    %edx,%eax
f0100a4e:	ff 75 08             	pushl  0x8(%ebp)
f0100a51:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a54:	51                   	push   %ecx
f0100a55:	56                   	push   %esi
f0100a56:	ff 14 85 50 67 10 f0 	call   *-0xfef98b0(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a5d:	83 c4 10             	add    $0x10,%esp
f0100a60:	85 c0                	test   %eax,%eax
f0100a62:	78 1d                	js     f0100a81 <monitor+0x153>
f0100a64:	e9 fb fe ff ff       	jmp    f0100964 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a69:	83 ec 08             	sub    $0x8,%esp
f0100a6c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6f:	68 da 65 10 f0       	push   $0xf01065da
f0100a74:	e8 68 2d 00 00       	call   f01037e1 <cprintf>
f0100a79:	83 c4 10             	add    $0x10,%esp
f0100a7c:	e9 e3 fe ff ff       	jmp    f0100964 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a81:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a84:	5b                   	pop    %ebx
f0100a85:	5e                   	pop    %esi
f0100a86:	5f                   	pop    %edi
f0100a87:	5d                   	pop    %ebp
f0100a88:	c3                   	ret    

f0100a89 <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100a89:	55                   	push   %ebp
f0100a8a:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a8c:	83 3d 38 12 21 f0 00 	cmpl   $0x0,0xf0211238
f0100a93:	75 11                	jne    f0100aa6 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a95:	ba 07 40 25 f0       	mov    $0xf0254007,%edx
f0100a9a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aa0:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result= nextfree;
f0100aa6:	8b 0d 38 12 21 f0    	mov    0xf0211238,%ecx
	nextfree=ROUNDUP(nextfree+n,PGSIZE);
f0100aac:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100ab3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ab9:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
	return result;
}
f0100abf:	89 c8                	mov    %ecx,%eax
f0100ac1:	5d                   	pop    %ebp
f0100ac2:	c3                   	ret    

f0100ac3 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ac3:	55                   	push   %ebp
f0100ac4:	89 e5                	mov    %esp,%ebp
f0100ac6:	56                   	push   %esi
f0100ac7:	53                   	push   %ebx
f0100ac8:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aca:	83 ec 0c             	sub    $0xc,%esp
f0100acd:	50                   	push   %eax
f0100ace:	e8 8f 2b 00 00       	call   f0103662 <mc146818_read>
f0100ad3:	89 c6                	mov    %eax,%esi
f0100ad5:	83 c3 01             	add    $0x1,%ebx
f0100ad8:	89 1c 24             	mov    %ebx,(%esp)
f0100adb:	e8 82 2b 00 00       	call   f0103662 <mc146818_read>
f0100ae0:	c1 e0 08             	shl    $0x8,%eax
f0100ae3:	09 f0                	or     %esi,%eax
}
f0100ae5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ae8:	5b                   	pop    %ebx
f0100ae9:	5e                   	pop    %esi
f0100aea:	5d                   	pop    %ebp
f0100aeb:	c3                   	ret    

f0100aec <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100aec:	89 d1                	mov    %edx,%ecx
f0100aee:	c1 e9 16             	shr    $0x16,%ecx
f0100af1:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100af4:	a8 01                	test   $0x1,%al
f0100af6:	74 52                	je     f0100b4a <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100af8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100afd:	89 c1                	mov    %eax,%ecx
f0100aff:	c1 e9 0c             	shr    $0xc,%ecx
f0100b02:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0100b08:	72 1b                	jb     f0100b25 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b0a:	55                   	push   %ebp
f0100b0b:	89 e5                	mov    %esp,%ebp
f0100b0d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b10:	50                   	push   %eax
f0100b11:	68 44 62 10 f0       	push   $0xf0106244
f0100b16:	68 de 03 00 00       	push   $0x3de
f0100b1b:	68 d9 70 10 f0       	push   $0xf01070d9
f0100b20:	e8 1b f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b25:	c1 ea 0c             	shr    $0xc,%edx
f0100b28:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b2e:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b35:	89 c2                	mov    %eax,%edx
f0100b37:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3f:	85 d2                	test   %edx,%edx
f0100b41:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b46:	0f 44 c2             	cmove  %edx,%eax
f0100b49:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b4f:	c3                   	ret    

f0100b50 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b50:	55                   	push   %ebp
f0100b51:	89 e5                	mov    %esp,%ebp
f0100b53:	57                   	push   %edi
f0100b54:	56                   	push   %esi
f0100b55:	53                   	push   %ebx
f0100b56:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b59:	84 c0                	test   %al,%al
f0100b5b:	0f 85 a0 02 00 00    	jne    f0100e01 <check_page_free_list+0x2b1>
f0100b61:	e9 ad 02 00 00       	jmp    f0100e13 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b66:	83 ec 04             	sub    $0x4,%esp
f0100b69:	68 60 67 10 f0       	push   $0xf0106760
f0100b6e:	68 11 03 00 00       	push   $0x311
f0100b73:	68 d9 70 10 f0       	push   $0xf01070d9
f0100b78:	e8 c3 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b7d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b80:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b83:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b86:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b89:	89 c2                	mov    %eax,%edx
f0100b8b:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0100b91:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b97:	0f 95 c2             	setne  %dl
f0100b9a:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b9d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ba1:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ba3:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ba7:	8b 00                	mov    (%eax),%eax
f0100ba9:	85 c0                	test   %eax,%eax
f0100bab:	75 dc                	jne    f0100b89 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bb9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bbc:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bc1:	a3 40 12 21 f0       	mov    %eax,0xf0211240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bc6:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bcb:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100bd1:	eb 53                	jmp    f0100c26 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bd3:	89 d8                	mov    %ebx,%eax
f0100bd5:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100bdb:	c1 f8 03             	sar    $0x3,%eax
f0100bde:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100be1:	89 c2                	mov    %eax,%edx
f0100be3:	c1 ea 16             	shr    $0x16,%edx
f0100be6:	39 f2                	cmp    %esi,%edx
f0100be8:	73 3a                	jae    f0100c24 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bea:	89 c2                	mov    %eax,%edx
f0100bec:	c1 ea 0c             	shr    $0xc,%edx
f0100bef:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100bf5:	72 12                	jb     f0100c09 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bf7:	50                   	push   %eax
f0100bf8:	68 44 62 10 f0       	push   $0xf0106244
f0100bfd:	6a 58                	push   $0x58
f0100bff:	68 e5 70 10 f0       	push   $0xf01070e5
f0100c04:	e8 37 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c09:	83 ec 04             	sub    $0x4,%esp
f0100c0c:	68 80 00 00 00       	push   $0x80
f0100c11:	68 97 00 00 00       	push   $0x97
f0100c16:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c1b:	50                   	push   %eax
f0100c1c:	e8 3d 49 00 00       	call   f010555e <memset>
f0100c21:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c24:	8b 1b                	mov    (%ebx),%ebx
f0100c26:	85 db                	test   %ebx,%ebx
f0100c28:	75 a9                	jne    f0100bd3 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c2f:	e8 55 fe ff ff       	call   f0100a89 <boot_alloc>
f0100c34:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c37:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c3d:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
		assert(pp < pages + npages);
f0100c43:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0100c48:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c4b:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c4e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c51:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c54:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c59:	e9 52 01 00 00       	jmp    f0100db0 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c5e:	39 ca                	cmp    %ecx,%edx
f0100c60:	73 19                	jae    f0100c7b <check_page_free_list+0x12b>
f0100c62:	68 f3 70 10 f0       	push   $0xf01070f3
f0100c67:	68 ff 70 10 f0       	push   $0xf01070ff
f0100c6c:	68 2b 03 00 00       	push   $0x32b
f0100c71:	68 d9 70 10 f0       	push   $0xf01070d9
f0100c76:	e8 c5 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c7b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c7e:	72 19                	jb     f0100c99 <check_page_free_list+0x149>
f0100c80:	68 14 71 10 f0       	push   $0xf0107114
f0100c85:	68 ff 70 10 f0       	push   $0xf01070ff
f0100c8a:	68 2c 03 00 00       	push   $0x32c
f0100c8f:	68 d9 70 10 f0       	push   $0xf01070d9
f0100c94:	e8 a7 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c99:	89 d0                	mov    %edx,%eax
f0100c9b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c9e:	a8 07                	test   $0x7,%al
f0100ca0:	74 19                	je     f0100cbb <check_page_free_list+0x16b>
f0100ca2:	68 84 67 10 f0       	push   $0xf0106784
f0100ca7:	68 ff 70 10 f0       	push   $0xf01070ff
f0100cac:	68 2d 03 00 00       	push   $0x32d
f0100cb1:	68 d9 70 10 f0       	push   $0xf01070d9
f0100cb6:	e8 85 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cbb:	c1 f8 03             	sar    $0x3,%eax
f0100cbe:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cc1:	85 c0                	test   %eax,%eax
f0100cc3:	75 19                	jne    f0100cde <check_page_free_list+0x18e>
f0100cc5:	68 28 71 10 f0       	push   $0xf0107128
f0100cca:	68 ff 70 10 f0       	push   $0xf01070ff
f0100ccf:	68 30 03 00 00       	push   $0x330
f0100cd4:	68 d9 70 10 f0       	push   $0xf01070d9
f0100cd9:	e8 62 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cde:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ce3:	75 19                	jne    f0100cfe <check_page_free_list+0x1ae>
f0100ce5:	68 39 71 10 f0       	push   $0xf0107139
f0100cea:	68 ff 70 10 f0       	push   $0xf01070ff
f0100cef:	68 31 03 00 00       	push   $0x331
f0100cf4:	68 d9 70 10 f0       	push   $0xf01070d9
f0100cf9:	e8 42 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cfe:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d03:	75 19                	jne    f0100d1e <check_page_free_list+0x1ce>
f0100d05:	68 b8 67 10 f0       	push   $0xf01067b8
f0100d0a:	68 ff 70 10 f0       	push   $0xf01070ff
f0100d0f:	68 32 03 00 00       	push   $0x332
f0100d14:	68 d9 70 10 f0       	push   $0xf01070d9
f0100d19:	e8 22 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d1e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d23:	75 19                	jne    f0100d3e <check_page_free_list+0x1ee>
f0100d25:	68 52 71 10 f0       	push   $0xf0107152
f0100d2a:	68 ff 70 10 f0       	push   $0xf01070ff
f0100d2f:	68 33 03 00 00       	push   $0x333
f0100d34:	68 d9 70 10 f0       	push   $0xf01070d9
f0100d39:	e8 02 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d3e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d43:	0f 86 f1 00 00 00    	jbe    f0100e3a <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d49:	89 c7                	mov    %eax,%edi
f0100d4b:	c1 ef 0c             	shr    $0xc,%edi
f0100d4e:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d51:	77 12                	ja     f0100d65 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d53:	50                   	push   %eax
f0100d54:	68 44 62 10 f0       	push   $0xf0106244
f0100d59:	6a 58                	push   $0x58
f0100d5b:	68 e5 70 10 f0       	push   $0xf01070e5
f0100d60:	e8 db f2 ff ff       	call   f0100040 <_panic>
f0100d65:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d6b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d6e:	0f 86 b6 00 00 00    	jbe    f0100e2a <check_page_free_list+0x2da>
f0100d74:	68 dc 67 10 f0       	push   $0xf01067dc
f0100d79:	68 ff 70 10 f0       	push   $0xf01070ff
f0100d7e:	68 34 03 00 00       	push   $0x334
f0100d83:	68 d9 70 10 f0       	push   $0xf01070d9
f0100d88:	e8 b3 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d8d:	68 6c 71 10 f0       	push   $0xf010716c
f0100d92:	68 ff 70 10 f0       	push   $0xf01070ff
f0100d97:	68 36 03 00 00       	push   $0x336
f0100d9c:	68 d9 70 10 f0       	push   $0xf01070d9
f0100da1:	e8 9a f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100da6:	83 c6 01             	add    $0x1,%esi
f0100da9:	eb 03                	jmp    f0100dae <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100dab:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dae:	8b 12                	mov    (%edx),%edx
f0100db0:	85 d2                	test   %edx,%edx
f0100db2:	0f 85 a6 fe ff ff    	jne    f0100c5e <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100db8:	85 f6                	test   %esi,%esi
f0100dba:	7f 19                	jg     f0100dd5 <check_page_free_list+0x285>
f0100dbc:	68 89 71 10 f0       	push   $0xf0107189
f0100dc1:	68 ff 70 10 f0       	push   $0xf01070ff
f0100dc6:	68 3e 03 00 00       	push   $0x33e
f0100dcb:	68 d9 70 10 f0       	push   $0xf01070d9
f0100dd0:	e8 6b f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dd5:	85 db                	test   %ebx,%ebx
f0100dd7:	7f 19                	jg     f0100df2 <check_page_free_list+0x2a2>
f0100dd9:	68 9b 71 10 f0       	push   $0xf010719b
f0100dde:	68 ff 70 10 f0       	push   $0xf01070ff
f0100de3:	68 3f 03 00 00       	push   $0x33f
f0100de8:	68 d9 70 10 f0       	push   $0xf01070d9
f0100ded:	e8 4e f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100df2:	83 ec 0c             	sub    $0xc,%esp
f0100df5:	68 24 68 10 f0       	push   $0xf0106824
f0100dfa:	e8 e2 29 00 00       	call   f01037e1 <cprintf>
}
f0100dff:	eb 49                	jmp    f0100e4a <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e01:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0100e06:	85 c0                	test   %eax,%eax
f0100e08:	0f 85 6f fd ff ff    	jne    f0100b7d <check_page_free_list+0x2d>
f0100e0e:	e9 53 fd ff ff       	jmp    f0100b66 <check_page_free_list+0x16>
f0100e13:	83 3d 40 12 21 f0 00 	cmpl   $0x0,0xf0211240
f0100e1a:	0f 84 46 fd ff ff    	je     f0100b66 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e20:	be 00 04 00 00       	mov    $0x400,%esi
f0100e25:	e9 a1 fd ff ff       	jmp    f0100bcb <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e2a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e2f:	0f 85 76 ff ff ff    	jne    f0100dab <check_page_free_list+0x25b>
f0100e35:	e9 53 ff ff ff       	jmp    f0100d8d <check_page_free_list+0x23d>
f0100e3a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e3f:	0f 85 61 ff ff ff    	jne    f0100da6 <check_page_free_list+0x256>
f0100e45:	e9 43 ff ff ff       	jmp    f0100d8d <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e4d:	5b                   	pop    %ebx
f0100e4e:	5e                   	pop    %esi
f0100e4f:	5f                   	pop    %edi
f0100e50:	5d                   	pop    %ebp
f0100e51:	c3                   	ret    

f0100e52 <page_init>:
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	// 1.mark page 0 as in use
    	// 这样我们就可以保留实模式IDT和BIOS结构，以备不时之需。
    	pages[0].pp_ref = 1;
f0100e52:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100e57:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0100e5d:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
f0100e63:	b8 08 00 00 00       	mov    $0x8,%eax

    	// 2. -------lab4 change-----
    	size_t i;
    
        for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
            pages[i].pp_ref = 0;
f0100e68:	89 c1                	mov    %eax,%ecx
f0100e6a:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
f0100e70:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0100e76:	89 11                	mov    %edx,(%ecx)
            page_free_list = &pages[i];
f0100e78:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
f0100e7e:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f0100e81:	83 c0 08             	add    $0x8,%eax
    	pages[0].pp_ref = 1;

    	// 2. -------lab4 change-----
    	size_t i;
    
        for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
f0100e84:	83 f8 38             	cmp    $0x38,%eax
f0100e87:	75 df                	jne    f0100e68 <page_init+0x16>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e89:	55                   	push   %ebp
f0100e8a:	89 e5                	mov    %esp,%ebp
f0100e8c:	56                   	push   %esi
f0100e8d:	53                   	push   %ebx
f0100e8e:	89 15 40 12 21 f0    	mov    %edx,0xf0211240
            page_free_list = &pages[i];
        }
    
        // boot APs entry code
        extern unsigned char mpentry_start[], mpentry_end[];
        size_t size = mpentry_end - mpentry_start;
f0100e94:	b8 da 57 10 f0       	mov    $0xf01057da,%eax
f0100e99:	2d 60 57 10 f0       	sub    $0xf0105760,%eax
        size = ROUNDUP(size, PGSIZE);
        for(;i<(MPENTRY_PADDR+size)/PGSIZE; i++) {
f0100e9e:	8d 98 ff 7f 00 00    	lea    0x7fff(%eax),%ebx
f0100ea4:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100ea9:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100eae:	29 c3                	sub    %eax,%ebx
f0100eb0:	c1 eb 0c             	shr    $0xc,%ebx
    	pages[0].pp_ref = 1;

    	// 2. -------lab4 change-----
    	size_t i;
    
        for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
f0100eb3:	b8 07 00 00 00       	mov    $0x7,%eax
    
        // boot APs entry code
        extern unsigned char mpentry_start[], mpentry_end[];
        size_t size = mpentry_end - mpentry_start;
        size = ROUNDUP(size, PGSIZE);
        for(;i<(MPENTRY_PADDR+size)/PGSIZE; i++) {
f0100eb8:	eb 0a                	jmp    f0100ec4 <page_init+0x72>
            pages[i].pp_ref = 1;
f0100eba:	66 c7 44 c1 04 01 00 	movw   $0x1,0x4(%ecx,%eax,8)
    
        // boot APs entry code
        extern unsigned char mpentry_start[], mpentry_end[];
        size_t size = mpentry_end - mpentry_start;
        size = ROUNDUP(size, PGSIZE);
        for(;i<(MPENTRY_PADDR+size)/PGSIZE; i++) {
f0100ec1:	83 c0 01             	add    $0x1,%eax
f0100ec4:	39 d8                	cmp    %ebx,%eax
f0100ec6:	72 f2                	jb     f0100eba <page_init+0x68>
f0100ec8:	83 fb 07             	cmp    $0x7,%ebx
f0100ecb:	b8 07 00 00 00       	mov    $0x7,%eax
f0100ed0:	0f 42 d8             	cmovb  %eax,%ebx
            pages[i].pp_ref = 1;
        }
    
    
        //----lab4 end-----
    	for (; i < npages_basemem; i++) {
f0100ed3:	8b 35 44 12 21 f0    	mov    0xf0211244,%esi
f0100ed9:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100ee0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ee5:	eb 23                	jmp    f0100f0a <page_init+0xb8>
        	pages[i].pp_ref = 0;
f0100ee7:	89 c1                	mov    %eax,%ecx
f0100ee9:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
f0100eef:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        	pages[i].pp_link = page_free_list;
f0100ef5:	89 11                	mov    %edx,(%ecx)
        	page_free_list = &pages[i];
f0100ef7:	89 c2                	mov    %eax,%edx
f0100ef9:	03 15 90 1e 21 f0    	add    0xf0211e90,%edx
            pages[i].pp_ref = 1;
        }
    
    
        //----lab4 end-----
    	for (; i < npages_basemem; i++) {
f0100eff:	83 c3 01             	add    $0x1,%ebx
f0100f02:	83 c0 08             	add    $0x8,%eax
f0100f05:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100f0a:	39 f3                	cmp    %esi,%ebx
f0100f0c:	72 d9                	jb     f0100ee7 <page_init+0x95>
f0100f0e:	84 c9                	test   %cl,%cl
f0100f10:	74 06                	je     f0100f18 <page_init+0xc6>
f0100f12:	89 15 40 12 21 f0    	mov    %edx,0xf0211240
    	}

    	// 3.[IOPHYSMEM, EXTPHYSMEM)
    	// mark I/O hole
    	for (;i<EXTPHYSMEM/PGSIZE;i++) {	
        	pages[i].pp_ref = 1;
f0100f18:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100f1d:	eb 0a                	jmp    f0100f29 <page_init+0xd7>
f0100f1f:	66 c7 44 d8 04 01 00 	movw   $0x1,0x4(%eax,%ebx,8)
        	page_free_list = &pages[i];
    	}

    	// 3.[IOPHYSMEM, EXTPHYSMEM)
    	// mark I/O hole
    	for (;i<EXTPHYSMEM/PGSIZE;i++) {	
f0100f26:	83 c3 01             	add    $0x1,%ebx
f0100f29:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100f2f:	76 ee                	jbe    f0100f1f <page_init+0xcd>

    	// 4. Extended memory 
    	// 还要注意哪些内存已经被内核、页表使用了！
    	// first需要向上取整对齐。同时此时已经工作在虚拟地址模式（entry.S对内存进行了映射）下，
    	// 需要求得first的物理地址
    	physaddr_t first_free_addr = PADDR(boot_alloc(0));
f0100f31:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f36:	e8 4e fb ff ff       	call   f0100a89 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f3b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f40:	77 15                	ja     f0100f57 <page_init+0x105>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f42:	50                   	push   %eax
f0100f43:	68 68 62 10 f0       	push   $0xf0106268
f0100f48:	68 6f 01 00 00       	push   $0x16f
f0100f4d:	68 d9 70 10 f0       	push   $0xf01070d9
f0100f52:	e8 e9 f0 ff ff       	call   f0100040 <_panic>
    	size_t first_free_page = first_free_addr/PGSIZE;
f0100f57:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f5c:	c1 e8 0c             	shr    $0xc,%eax
    	for(;i<first_free_page;i++) {
    	    pages[i].pp_ref = 1;
f0100f5f:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
    	// 还要注意哪些内存已经被内核、页表使用了！
    	// first需要向上取整对齐。同时此时已经工作在虚拟地址模式（entry.S对内存进行了映射）下，
    	// 需要求得first的物理地址
    	physaddr_t first_free_addr = PADDR(boot_alloc(0));
    	size_t first_free_page = first_free_addr/PGSIZE;
    	for(;i<first_free_page;i++) {
f0100f65:	eb 0a                	jmp    f0100f71 <page_init+0x11f>
    	    pages[i].pp_ref = 1;
f0100f67:	66 c7 44 da 04 01 00 	movw   $0x1,0x4(%edx,%ebx,8)
    	// 还要注意哪些内存已经被内核、页表使用了！
    	// first需要向上取整对齐。同时此时已经工作在虚拟地址模式（entry.S对内存进行了映射）下，
    	// 需要求得first的物理地址
    	physaddr_t first_free_addr = PADDR(boot_alloc(0));
    	size_t first_free_page = first_free_addr/PGSIZE;
    	for(;i<first_free_page;i++) {
f0100f6e:	83 c3 01             	add    $0x1,%ebx
f0100f71:	39 c3                	cmp    %eax,%ebx
f0100f73:	72 f2                	jb     f0100f67 <page_init+0x115>
f0100f75:	8b 0d 40 12 21 f0    	mov    0xf0211240,%ecx
f0100f7b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f82:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f87:	eb 23                	jmp    f0100fac <page_init+0x15a>
    	    pages[i].pp_ref = 1;
    	}
    // mark other pages as free
    	for(;i<npages;i++) {
		pages[i].pp_ref = 0;
f0100f89:	89 c2                	mov    %eax,%edx
f0100f8b:	03 15 90 1e 21 f0    	add    0xf0211e90,%edx
f0100f91:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100f97:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100f99:	89 c1                	mov    %eax,%ecx
f0100f9b:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
    	size_t first_free_page = first_free_addr/PGSIZE;
    	for(;i<first_free_page;i++) {
    	    pages[i].pp_ref = 1;
    	}
    // mark other pages as free
    	for(;i<npages;i++) {
f0100fa1:	83 c3 01             	add    $0x1,%ebx
f0100fa4:	83 c0 08             	add    $0x8,%eax
f0100fa7:	ba 01 00 00 00       	mov    $0x1,%edx
f0100fac:	3b 1d 88 1e 21 f0    	cmp    0xf0211e88,%ebx
f0100fb2:	72 d5                	jb     f0100f89 <page_init+0x137>
f0100fb4:	84 d2                	test   %dl,%dl
f0100fb6:	74 06                	je     f0100fbe <page_init+0x16c>
f0100fb8:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240
	//for (i = 0; i < npages; i++) {
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
}
f0100fbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fc1:	5b                   	pop    %ebx
f0100fc2:	5e                   	pop    %esi
f0100fc3:	5d                   	pop    %ebp
f0100fc4:	c3                   	ret    

f0100fc5 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fc5:	55                   	push   %ebp
f0100fc6:	89 e5                	mov    %esp,%ebp
f0100fc8:	53                   	push   %ebx
f0100fc9:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo* pp;
    	if (!page_free_list) {
f0100fcc:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100fd2:	85 db                	test   %ebx,%ebx
f0100fd4:	74 58                	je     f010102e <page_alloc+0x69>
        	return NULL;
   	 }
    	pp = page_free_list;
    	page_free_list = page_free_list->pp_link;
f0100fd6:	8b 03                	mov    (%ebx),%eax
f0100fd8:	a3 40 12 21 f0       	mov    %eax,0xf0211240
    	pp->pp_link = NULL;
f0100fdd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    
    	//page2kva 返回值 KernelBase + 物理页号<<PGSHIFT,  虚拟地址
    
    	if (alloc_flags & ALLOC_ZERO) {
f0100fe3:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fe7:	74 45                	je     f010102e <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fe9:	89 d8                	mov    %ebx,%eax
f0100feb:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100ff1:	c1 f8 03             	sar    $0x3,%eax
f0100ff4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff7:	89 c2                	mov    %eax,%edx
f0100ff9:	c1 ea 0c             	shr    $0xc,%edx
f0100ffc:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101002:	72 12                	jb     f0101016 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101004:	50                   	push   %eax
f0101005:	68 44 62 10 f0       	push   $0xf0106244
f010100a:	6a 58                	push   $0x58
f010100c:	68 e5 70 10 f0       	push   $0xf01070e5
f0101011:	e8 2a f0 ff ff       	call   f0100040 <_panic>

        	void * va = page2kva(pp);
        	memset(va, '\0', PGSIZE);
f0101016:	83 ec 04             	sub    $0x4,%esp
f0101019:	68 00 10 00 00       	push   $0x1000
f010101e:	6a 00                	push   $0x0
f0101020:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101025:	50                   	push   %eax
f0101026:	e8 33 45 00 00       	call   f010555e <memset>
f010102b:	83 c4 10             	add    $0x10,%esp
    	}
   	return pp;
	//return 0;
}
f010102e:	89 d8                	mov    %ebx,%eax
f0101030:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101033:	c9                   	leave  
f0101034:	c3                   	ret    

f0101035 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101035:	55                   	push   %ebp
f0101036:	89 e5                	mov    %esp,%ebp
f0101038:	83 ec 08             	sub    $0x8,%esp
f010103b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link || pp->pp_ref) {
f010103e:	83 38 00             	cmpl   $0x0,(%eax)
f0101041:	75 07                	jne    f010104a <page_free+0x15>
f0101043:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101048:	74 17                	je     f0101061 <page_free+0x2c>
        	panic("pp->pp_ref is nonzero or pp->pp_link is not NULL\n");
f010104a:	83 ec 04             	sub    $0x4,%esp
f010104d:	68 48 68 10 f0       	push   $0xf0106848
f0101052:	68 b2 01 00 00       	push   $0x1b2
f0101057:	68 d9 70 10 f0       	push   $0xf01070d9
f010105c:	e8 df ef ff ff       	call   f0100040 <_panic>
    	}
    	pp->pp_link = page_free_list;
f0101061:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
f0101067:	89 10                	mov    %edx,(%eax)
    	page_free_list = pp;
f0101069:	a3 40 12 21 f0       	mov    %eax,0xf0211240
}
f010106e:	c9                   	leave  
f010106f:	c3                   	ret    

f0101070 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101070:	55                   	push   %ebp
f0101071:	89 e5                	mov    %esp,%ebp
f0101073:	83 ec 08             	sub    $0x8,%esp
f0101076:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101079:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010107d:	83 e8 01             	sub    $0x1,%eax
f0101080:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101084:	66 85 c0             	test   %ax,%ax
f0101087:	75 0c                	jne    f0101095 <page_decref+0x25>
		page_free(pp);
f0101089:	83 ec 0c             	sub    $0xc,%esp
f010108c:	52                   	push   %edx
f010108d:	e8 a3 ff ff ff       	call   f0101035 <page_free>
f0101092:	83 c4 10             	add    $0x10,%esp
}
f0101095:	c9                   	leave  
f0101096:	c3                   	ret    

f0101097 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create) // 返回页表项的虚拟地址
{
f0101097:	55                   	push   %ebp
f0101098:	89 e5                	mov    %esp,%ebp
f010109a:	57                   	push   %edi
f010109b:	56                   	push   %esi
f010109c:	53                   	push   %ebx
f010109d:	83 ec 0c             	sub    $0xc,%esp
f01010a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function in
	//return NULL;
	uint32_t pdx = PDX(va);   // 页目录项索引
    	uint32_t ptx = PTX(va);   // 页表项索引
f01010a3:	89 c6                	mov    %eax,%esi
f01010a5:	c1 ee 0c             	shr    $0xc,%esi
f01010a8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    	pte_t   *pde;             // 页目录项指针
    	pte_t   *pte;             // 页表项指针
    	struct PageInfo *pp;
    
    	pde = &pgdir[pdx];        //获取页目录项
f01010ae:	c1 e8 16             	shr    $0x16,%eax
f01010b1:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f01010b8:	03 5d 08             	add    0x8(%ebp),%ebx
    
    	if (*pde & PTE_P) {
f01010bb:	8b 03                	mov    (%ebx),%eax
f01010bd:	a8 01                	test   $0x1,%al
f01010bf:	74 2f                	je     f01010f0 <pgdir_walk+0x59>
        // 二级页表有效
        // PTE_ADDR得到物理地址，KADDR转为虚拟地址
        	pte = (KADDR(PTE_ADDR(*pde)));
f01010c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010c6:	89 c2                	mov    %eax,%edx
f01010c8:	c1 ea 0c             	shr    $0xc,%edx
f01010cb:	39 15 88 1e 21 f0    	cmp    %edx,0xf0211e88
f01010d1:	77 15                	ja     f01010e8 <pgdir_walk+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010d3:	50                   	push   %eax
f01010d4:	68 44 62 10 f0       	push   $0xf0106244
f01010d9:	68 e9 01 00 00       	push   $0x1e9
f01010de:	68 d9 70 10 f0       	push   $0xf01070d9
f01010e3:	e8 58 ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01010e8:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f01010ee:	eb 73                	jmp    f0101163 <pgdir_walk+0xcc>
    	}
    	else {
        	// 二级页表不存在，
        	if (!create) {
f01010f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010f4:	74 72                	je     f0101168 <pgdir_walk+0xd1>
            		return NULL;
        	}
        	// 获取一页的内存，创建一个新的页表，来存放页表项
        	if(!(pp = page_alloc(ALLOC_ZERO))) {  
f01010f6:	83 ec 0c             	sub    $0xc,%esp
f01010f9:	6a 01                	push   $0x1
f01010fb:	e8 c5 fe ff ff       	call   f0100fc5 <page_alloc>
f0101100:	83 c4 10             	add    $0x10,%esp
f0101103:	85 c0                	test   %eax,%eax
f0101105:	74 68                	je     f010116f <pgdir_walk+0xd8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101107:	89 c1                	mov    %eax,%ecx
f0101109:	2b 0d 90 1e 21 f0    	sub    0xf0211e90,%ecx
f010110f:	c1 f9 03             	sar    $0x3,%ecx
f0101112:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101115:	89 ca                	mov    %ecx,%edx
f0101117:	c1 ea 0c             	shr    $0xc,%edx
f010111a:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101120:	72 12                	jb     f0101134 <pgdir_walk+0x9d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101122:	51                   	push   %ecx
f0101123:	68 44 62 10 f0       	push   $0xf0106244
f0101128:	6a 58                	push   $0x58
f010112a:	68 e5 70 10 f0       	push   $0xf01070e5
f010112f:	e8 0c ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101134:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f010113a:	89 fa                	mov    %edi,%edx
            		return NULL;
        	}
        	pte = (pte_t *)page2kva(pp);
        	pp->pp_ref++; 
f010113c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101141:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0101147:	77 15                	ja     f010115e <pgdir_walk+0xc7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101149:	57                   	push   %edi
f010114a:	68 68 62 10 f0       	push   $0xf0106268
f010114f:	68 f6 01 00 00       	push   $0x1f6
f0101154:	68 d9 70 10 f0       	push   $0xf01070d9
f0101159:	e8 e2 ee ff ff       	call   f0100040 <_panic>
        	*pde = PADDR(pte) | (PTE_P | PTE_W | PTE_U);  // 设置页目录项
f010115e:	83 c9 07             	or     $0x7,%ecx
f0101161:	89 0b                	mov    %ecx,(%ebx)
    		}
     	// 返回页表项的虚拟地址
    	return &pte[ptx];
f0101163:	8d 04 b2             	lea    (%edx,%esi,4),%eax
f0101166:	eb 0c                	jmp    f0101174 <pgdir_walk+0xdd>
        	pte = (KADDR(PTE_ADDR(*pde)));
    	}
    	else {
        	// 二级页表不存在，
        	if (!create) {
            		return NULL;
f0101168:	b8 00 00 00 00       	mov    $0x0,%eax
f010116d:	eb 05                	jmp    f0101174 <pgdir_walk+0xdd>
        	}
        	// 获取一页的内存，创建一个新的页表，来存放页表项
        	if(!(pp = page_alloc(ALLOC_ZERO))) {  
            		return NULL;
f010116f:	b8 00 00 00 00       	mov    $0x0,%eax
        	pp->pp_ref++; 
        	*pde = PADDR(pte) | (PTE_P | PTE_W | PTE_U);  // 设置页目录项
    		}
     	// 返回页表项的虚拟地址
    	return &pte[ptx];
}
f0101174:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101177:	5b                   	pop    %ebx
f0101178:	5e                   	pop    %esi
f0101179:	5f                   	pop    %edi
f010117a:	5d                   	pop    %ebp
f010117b:	c3                   	ret    

f010117c <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010117c:	55                   	push   %ebp
f010117d:	89 e5                	mov    %esp,%ebp
f010117f:	57                   	push   %edi
f0101180:	56                   	push   %esi
f0101181:	53                   	push   %ebx
f0101182:	83 ec 1c             	sub    $0x1c,%esp
f0101185:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101188:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	size_t pgs = size / PGSIZE;    
f010118b:	89 cb                	mov    %ecx,%ebx
f010118d:	c1 eb 0c             	shr    $0xc,%ebx
    	if (size % PGSIZE != 0) {
f0101190:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
        	pgs++;
f0101196:	83 f9 01             	cmp    $0x1,%ecx
f0101199:	83 db ff             	sbb    $0xffffffff,%ebx
f010119c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
    	}                            //计算总共有多少页
    	for (int i = 0; i < pgs; i++) {
f010119f:	89 c3                	mov    %eax,%ebx
f01011a1:	be 00 00 00 00       	mov    $0x0,%esi
        	pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);//获取va对应的PTE的地址
f01011a6:	89 d7                	mov    %edx,%edi
f01011a8:	29 c7                	sub    %eax,%edi
        	if (pte == NULL) {
            		panic("boot_map_region(): out of memory\n");
        	}
        	*pte = pa | PTE_P | perm; //修改va对应的PTE的值
f01011aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011ad:	83 c8 01             	or     $0x1,%eax
f01011b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	size_t pgs = size / PGSIZE;    
    	if (size % PGSIZE != 0) {
        	pgs++;
    	}                            //计算总共有多少页
    	for (int i = 0; i < pgs; i++) {
f01011b3:	eb 3f                	jmp    f01011f4 <boot_map_region+0x78>
        	pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);//获取va对应的PTE的地址
f01011b5:	83 ec 04             	sub    $0x4,%esp
f01011b8:	6a 01                	push   $0x1
f01011ba:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01011bd:	50                   	push   %eax
f01011be:	ff 75 e0             	pushl  -0x20(%ebp)
f01011c1:	e8 d1 fe ff ff       	call   f0101097 <pgdir_walk>
        	if (pte == NULL) {
f01011c6:	83 c4 10             	add    $0x10,%esp
f01011c9:	85 c0                	test   %eax,%eax
f01011cb:	75 17                	jne    f01011e4 <boot_map_region+0x68>
            		panic("boot_map_region(): out of memory\n");
f01011cd:	83 ec 04             	sub    $0x4,%esp
f01011d0:	68 7c 68 10 f0       	push   $0xf010687c
f01011d5:	68 12 02 00 00       	push   $0x212
f01011da:	68 d9 70 10 f0       	push   $0xf01070d9
f01011df:	e8 5c ee ff ff       	call   f0100040 <_panic>
        	}
        	*pte = pa | PTE_P | perm; //修改va对应的PTE的值
f01011e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011e7:	09 da                	or     %ebx,%edx
f01011e9:	89 10                	mov    %edx,(%eax)
        	pa += PGSIZE;             //更新pa和va，进行下一轮循环
f01011eb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// Fill this function in
	size_t pgs = size / PGSIZE;    
    	if (size % PGSIZE != 0) {
        	pgs++;
    	}                            //计算总共有多少页
    	for (int i = 0; i < pgs; i++) {
f01011f1:	83 c6 01             	add    $0x1,%esi
f01011f4:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01011f7:	75 bc                	jne    f01011b5 <boot_map_region+0x39>
        	}
        	*pte = pa | PTE_P | perm; //修改va对应的PTE的值
        	pa += PGSIZE;             //更新pa和va，进行下一轮循环
        	va += PGSIZE;
   	}
}
f01011f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011fc:	5b                   	pop    %ebx
f01011fd:	5e                   	pop    %esi
f01011fe:	5f                   	pop    %edi
f01011ff:	5d                   	pop    %ebp
f0101200:	c3                   	ret    

f0101201 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101201:	55                   	push   %ebp
f0101202:	89 e5                	mov    %esp,%ebp
f0101204:	53                   	push   %ebx
f0101205:	83 ec 08             	sub    $0x8,%esp
f0101208:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010120b:	6a 00                	push   $0x0
f010120d:	ff 75 0c             	pushl  0xc(%ebp)
f0101210:	ff 75 08             	pushl  0x8(%ebp)
f0101213:	e8 7f fe ff ff       	call   f0101097 <pgdir_walk>
    	if (!pte) {
f0101218:	83 c4 10             	add    $0x10,%esp
f010121b:	85 c0                	test   %eax,%eax
f010121d:	74 36                	je     f0101255 <page_lookup+0x54>

        	return NULL;
    	}
    	if (pte_store) {
f010121f:	85 db                	test   %ebx,%ebx
f0101221:	74 02                	je     f0101225 <page_lookup+0x24>
        	*pte_store = pte;  // 通过指针的指针返回指针给调用者
f0101223:	89 03                	mov    %eax,(%ebx)
    	}
    
   	 // 难道不用考虑页表项是否存在
    
    	if (*pte & PTE_P) {
f0101225:	8b 00                	mov    (%eax),%eax
f0101227:	a8 01                	test   $0x1,%al
f0101229:	74 31                	je     f010125c <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010122b:	c1 e8 0c             	shr    $0xc,%eax
f010122e:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0101234:	72 14                	jb     f010124a <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f0101236:	83 ec 04             	sub    $0x4,%esp
f0101239:	68 a0 68 10 f0       	push   $0xf01068a0
f010123e:	6a 51                	push   $0x51
f0101240:	68 e5 70 10 f0       	push   $0xf01070e5
f0101245:	e8 f6 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010124a:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f0101250:	8d 04 c2             	lea    (%edx,%eax,8),%eax

        	return (pa2page(PTE_ADDR(*pte)));
f0101253:	eb 0c                	jmp    f0101261 <page_lookup+0x60>
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
    	if (!pte) {

        	return NULL;
f0101255:	b8 00 00 00 00       	mov    $0x0,%eax
f010125a:	eb 05                	jmp    f0101261 <page_lookup+0x60>
    	if (*pte & PTE_P) {

        	return (pa2page(PTE_ADDR(*pte)));
    	}
    
    	return NULL;
f010125c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101264:	c9                   	leave  
f0101265:	c3                   	ret    

f0101266 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101266:	55                   	push   %ebp
f0101267:	89 e5                	mov    %esp,%ebp
f0101269:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010126c:	e8 0d 49 00 00       	call   f0105b7e <cpunum>
f0101271:	6b c0 74             	imul   $0x74,%eax,%eax
f0101274:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f010127b:	74 16                	je     f0101293 <tlb_invalidate+0x2d>
f010127d:	e8 fc 48 00 00       	call   f0105b7e <cpunum>
f0101282:	6b c0 74             	imul   $0x74,%eax,%eax
f0101285:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010128b:	8b 55 08             	mov    0x8(%ebp),%edx
f010128e:	39 50 60             	cmp    %edx,0x60(%eax)
f0101291:	75 06                	jne    f0101299 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101293:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101296:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101299:	c9                   	leave  
f010129a:	c3                   	ret    

f010129b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010129b:	55                   	push   %ebp
f010129c:	89 e5                	mov    %esp,%ebp
f010129e:	56                   	push   %esi
f010129f:	53                   	push   %ebx
f01012a0:	83 ec 14             	sub    $0x14,%esp
f01012a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *pte;
    	pte_t **pte_store = &pte;
    
    	struct PageInfo *pi = page_lookup(pgdir, va, pte_store);
f01012a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012ac:	50                   	push   %eax
f01012ad:	56                   	push   %esi
f01012ae:	53                   	push   %ebx
f01012af:	e8 4d ff ff ff       	call   f0101201 <page_lookup>
    	if (!pi) {
f01012b4:	83 c4 10             	add    $0x10,%esp
f01012b7:	85 c0                	test   %eax,%eax
f01012b9:	74 1f                	je     f01012da <page_remove+0x3f>
        	return ;
   	}
    
    	page_decref(pi);     // 减引用
f01012bb:	83 ec 0c             	sub    $0xc,%esp
f01012be:	50                   	push   %eax
f01012bf:	e8 ac fd ff ff       	call   f0101070 <page_decref>
    
   	**pte_store = 0;     // 取消映射
f01012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    	tlb_invalidate(pgdir, va);
f01012cd:	83 c4 08             	add    $0x8,%esp
f01012d0:	56                   	push   %esi
f01012d1:	53                   	push   %ebx
f01012d2:	e8 8f ff ff ff       	call   f0101266 <tlb_invalidate>
f01012d7:	83 c4 10             	add    $0x10,%esp
}
f01012da:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012dd:	5b                   	pop    %ebx
f01012de:	5e                   	pop    %esi
f01012df:	5d                   	pop    %ebp
f01012e0:	c3                   	ret    

f01012e1 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012e1:	55                   	push   %ebp
f01012e2:	89 e5                	mov    %esp,%ebp
f01012e4:	57                   	push   %edi
f01012e5:	56                   	push   %esi
f01012e6:	53                   	push   %ebx
f01012e7:	83 ec 10             	sub    $0x10,%esp
f01012ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012ed:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01012f0:	6a 01                	push   $0x1
f01012f2:	57                   	push   %edi
f01012f3:	ff 75 08             	pushl  0x8(%ebp)
f01012f6:	e8 9c fd ff ff       	call   f0101097 <pgdir_walk>
    	if (!pte) {
f01012fb:	83 c4 10             	add    $0x10,%esp
f01012fe:	85 c0                	test   %eax,%eax
f0101300:	74 57                	je     f0101359 <page_insert+0x78>
f0101302:	89 c6                	mov    %eax,%esi
        	return -E_NO_MEM;
    	}

    	if (*pte & PTE_P) {
f0101304:	8b 00                	mov    (%eax),%eax
f0101306:	a8 01                	test   $0x1,%al
f0101308:	74 2d                	je     f0101337 <page_insert+0x56>
		if (PTE_ADDR(*pte) == page2pa(pp)) {
f010130a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010130f:	89 da                	mov    %ebx,%edx
f0101311:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101317:	c1 fa 03             	sar    $0x3,%edx
f010131a:	c1 e2 0c             	shl    $0xc,%edx
f010131d:	39 d0                	cmp    %edx,%eax
f010131f:	75 07                	jne    f0101328 <page_insert+0x47>

			// 插入的是同一个页面，只需要修改权限等即可
			pp->pp_ref--;
f0101321:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101326:	eb 0f                	jmp    f0101337 <page_insert+0x56>
		}
		else {

			page_remove(pgdir, va);
f0101328:	83 ec 08             	sub    $0x8,%esp
f010132b:	57                   	push   %edi
f010132c:	ff 75 08             	pushl  0x8(%ebp)
f010132f:	e8 67 ff ff ff       	call   f010129b <page_remove>
f0101334:	83 c4 10             	add    $0x10,%esp
		}
		
	}
	
	pp->pp_ref++;
f0101337:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	*pte = page2pa(pp)| perm | PTE_P;
f010133c:	2b 1d 90 1e 21 f0    	sub    0xf0211e90,%ebx
f0101342:	c1 fb 03             	sar    $0x3,%ebx
f0101345:	c1 e3 0c             	shl    $0xc,%ebx
f0101348:	8b 45 14             	mov    0x14(%ebp),%eax
f010134b:	83 c8 01             	or     $0x1,%eax
f010134e:	09 c3                	or     %eax,%ebx
f0101350:	89 1e                	mov    %ebx,(%esi)
	
	return 0;
f0101352:	b8 00 00 00 00       	mov    $0x0,%eax
f0101357:	eb 05                	jmp    f010135e <page_insert+0x7d>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
    	if (!pte) {
        	return -E_NO_MEM;
f0101359:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	
	pp->pp_ref++;
	*pte = page2pa(pp)| perm | PTE_P;
	
	return 0;
}
f010135e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101361:	5b                   	pop    %ebx
f0101362:	5e                   	pop    %esi
f0101363:	5f                   	pop    %edi
f0101364:	5d                   	pop    %ebp
f0101365:	c3                   	ret    

f0101366 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101366:	55                   	push   %ebp
f0101367:	89 e5                	mov    %esp,%ebp
f0101369:	53                   	push   %ebx
f010136a:	83 ec 04             	sub    $0x4,%esp
f010136d:	8b 45 08             	mov    0x8(%ebp),%eax
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
    // ret -> MMIOBASE 暂存
    	size_t begin = ROUNDDOWN(pa, PGSIZE), end = ROUNDUP(pa + size, PGSIZE);
f0101370:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101373:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
	size_t map_size = end - begin;
f010137a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101380:	89 c2                	mov    %eax,%edx
f0101382:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101388:	29 d3                	sub    %edx,%ebx
	if (base + map_size >= MMIOLIM) {
f010138a:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101390:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0101393:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101399:	76 17                	jbe    f01013b2 <mmio_map_region+0x4c>
		panic("Overflow MMIOLIM");
f010139b:	83 ec 04             	sub    $0x4,%esp
f010139e:	68 ac 71 10 f0       	push   $0xf01071ac
f01013a3:	68 c2 02 00 00       	push   $0x2c2
f01013a8:	68 d9 70 10 f0       	push   $0xf01070d9
f01013ad:	e8 8e ec ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, map_size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01013b2:	83 ec 08             	sub    $0x8,%esp
f01013b5:	6a 1a                	push   $0x1a
f01013b7:	50                   	push   %eax
f01013b8:	89 d9                	mov    %ebx,%ecx
f01013ba:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01013bf:	e8 b8 fd ff ff       	call   f010117c <boot_map_region>
	uintptr_t result = base;
f01013c4:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base += map_size;
f01013c9:	01 c3                	add    %eax,%ebx
f01013cb:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void *)result;
	//panic("mmio_map_region not implemented");
}
f01013d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013d4:	c9                   	leave  
f01013d5:	c3                   	ret    

f01013d6 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01013d6:	55                   	push   %ebp
f01013d7:	89 e5                	mov    %esp,%ebp
f01013d9:	57                   	push   %edi
f01013da:	56                   	push   %esi
f01013db:	53                   	push   %ebx
f01013dc:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01013df:	b8 15 00 00 00       	mov    $0x15,%eax
f01013e4:	e8 da f6 ff ff       	call   f0100ac3 <nvram_read>
f01013e9:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013eb:	b8 17 00 00 00       	mov    $0x17,%eax
f01013f0:	e8 ce f6 ff ff       	call   f0100ac3 <nvram_read>
f01013f5:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013f7:	b8 34 00 00 00       	mov    $0x34,%eax
f01013fc:	e8 c2 f6 ff ff       	call   f0100ac3 <nvram_read>
f0101401:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101404:	85 c0                	test   %eax,%eax
f0101406:	74 07                	je     f010140f <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101408:	05 00 40 00 00       	add    $0x4000,%eax
f010140d:	eb 0b                	jmp    f010141a <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010140f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101415:	85 f6                	test   %esi,%esi
f0101417:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010141a:	89 c2                	mov    %eax,%edx
f010141c:	c1 ea 02             	shr    $0x2,%edx
f010141f:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101425:	89 da                	mov    %ebx,%edx
f0101427:	c1 ea 02             	shr    $0x2,%edx
f010142a:	89 15 44 12 21 f0    	mov    %edx,0xf0211244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101430:	89 c2                	mov    %eax,%edx
f0101432:	29 da                	sub    %ebx,%edx
f0101434:	52                   	push   %edx
f0101435:	53                   	push   %ebx
f0101436:	50                   	push   %eax
f0101437:	68 c0 68 10 f0       	push   $0xf01068c0
f010143c:	e8 a0 23 00 00       	call   f01037e1 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101441:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101446:	e8 3e f6 ff ff       	call   f0100a89 <boot_alloc>
f010144b:	a3 8c 1e 21 f0       	mov    %eax,0xf0211e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101450:	83 c4 0c             	add    $0xc,%esp
f0101453:	68 00 10 00 00       	push   $0x1000
f0101458:	6a 00                	push   $0x0
f010145a:	50                   	push   %eax
f010145b:	e8 fe 40 00 00       	call   f010555e <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101460:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101465:	83 c4 10             	add    $0x10,%esp
f0101468:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010146d:	77 15                	ja     f0101484 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010146f:	50                   	push   %eax
f0101470:	68 68 62 10 f0       	push   $0xf0106268
f0101475:	68 94 00 00 00       	push   $0x94
f010147a:	68 d9 70 10 f0       	push   $0xf01070d9
f010147f:	e8 bc eb ff ff       	call   f0100040 <_panic>
f0101484:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010148a:	83 ca 05             	or     $0x5,%edx
f010148d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages=(struct PageInfo*) boot_alloc(sizeof(struct PageInfo)*npages);
f0101493:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0101498:	c1 e0 03             	shl    $0x3,%eax
f010149b:	e8 e9 f5 ff ff       	call   f0100a89 <boot_alloc>
f01014a0:	a3 90 1e 21 f0       	mov    %eax,0xf0211e90
	memset(pages,0,sizeof(struct PageInfo)*npages);
f01014a5:	83 ec 04             	sub    $0x4,%esp
f01014a8:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f01014ae:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01014b5:	52                   	push   %edx
f01014b6:	6a 00                	push   $0x0
f01014b8:	50                   	push   %eax
f01014b9:	e8 a0 40 00 00       	call   f010555e <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f01014be:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01014c3:	e8 c1 f5 ff ff       	call   f0100a89 <boot_alloc>
f01014c8:	a3 48 12 21 f0       	mov    %eax,0xf0211248
	memset(envs, 0, NENV * sizeof(struct Env));
f01014cd:	83 c4 0c             	add    $0xc,%esp
f01014d0:	68 00 f0 01 00       	push   $0x1f000
f01014d5:	6a 00                	push   $0x0
f01014d7:	50                   	push   %eax
f01014d8:	e8 81 40 00 00       	call   f010555e <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01014dd:	e8 70 f9 ff ff       	call   f0100e52 <page_init>

	check_page_free_list(1);
f01014e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01014e7:	e8 64 f6 ff ff       	call   f0100b50 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01014ec:	83 c4 10             	add    $0x10,%esp
f01014ef:	83 3d 90 1e 21 f0 00 	cmpl   $0x0,0xf0211e90
f01014f6:	75 17                	jne    f010150f <mem_init+0x139>
		panic("'pages' is a null pointer!");
f01014f8:	83 ec 04             	sub    $0x4,%esp
f01014fb:	68 bd 71 10 f0       	push   $0xf01071bd
f0101500:	68 52 03 00 00       	push   $0x352
f0101505:	68 d9 70 10 f0       	push   $0xf01070d9
f010150a:	e8 31 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010150f:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101514:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101519:	eb 05                	jmp    f0101520 <mem_init+0x14a>
		++nfree;
f010151b:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010151e:	8b 00                	mov    (%eax),%eax
f0101520:	85 c0                	test   %eax,%eax
f0101522:	75 f7                	jne    f010151b <mem_init+0x145>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101524:	83 ec 0c             	sub    $0xc,%esp
f0101527:	6a 00                	push   $0x0
f0101529:	e8 97 fa ff ff       	call   f0100fc5 <page_alloc>
f010152e:	89 c7                	mov    %eax,%edi
f0101530:	83 c4 10             	add    $0x10,%esp
f0101533:	85 c0                	test   %eax,%eax
f0101535:	75 19                	jne    f0101550 <mem_init+0x17a>
f0101537:	68 d8 71 10 f0       	push   $0xf01071d8
f010153c:	68 ff 70 10 f0       	push   $0xf01070ff
f0101541:	68 5a 03 00 00       	push   $0x35a
f0101546:	68 d9 70 10 f0       	push   $0xf01070d9
f010154b:	e8 f0 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101550:	83 ec 0c             	sub    $0xc,%esp
f0101553:	6a 00                	push   $0x0
f0101555:	e8 6b fa ff ff       	call   f0100fc5 <page_alloc>
f010155a:	89 c6                	mov    %eax,%esi
f010155c:	83 c4 10             	add    $0x10,%esp
f010155f:	85 c0                	test   %eax,%eax
f0101561:	75 19                	jne    f010157c <mem_init+0x1a6>
f0101563:	68 ee 71 10 f0       	push   $0xf01071ee
f0101568:	68 ff 70 10 f0       	push   $0xf01070ff
f010156d:	68 5b 03 00 00       	push   $0x35b
f0101572:	68 d9 70 10 f0       	push   $0xf01070d9
f0101577:	e8 c4 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010157c:	83 ec 0c             	sub    $0xc,%esp
f010157f:	6a 00                	push   $0x0
f0101581:	e8 3f fa ff ff       	call   f0100fc5 <page_alloc>
f0101586:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101589:	83 c4 10             	add    $0x10,%esp
f010158c:	85 c0                	test   %eax,%eax
f010158e:	75 19                	jne    f01015a9 <mem_init+0x1d3>
f0101590:	68 04 72 10 f0       	push   $0xf0107204
f0101595:	68 ff 70 10 f0       	push   $0xf01070ff
f010159a:	68 5c 03 00 00       	push   $0x35c
f010159f:	68 d9 70 10 f0       	push   $0xf01070d9
f01015a4:	e8 97 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015a9:	39 f7                	cmp    %esi,%edi
f01015ab:	75 19                	jne    f01015c6 <mem_init+0x1f0>
f01015ad:	68 1a 72 10 f0       	push   $0xf010721a
f01015b2:	68 ff 70 10 f0       	push   $0xf01070ff
f01015b7:	68 5f 03 00 00       	push   $0x35f
f01015bc:	68 d9 70 10 f0       	push   $0xf01070d9
f01015c1:	e8 7a ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015c9:	39 c6                	cmp    %eax,%esi
f01015cb:	74 04                	je     f01015d1 <mem_init+0x1fb>
f01015cd:	39 c7                	cmp    %eax,%edi
f01015cf:	75 19                	jne    f01015ea <mem_init+0x214>
f01015d1:	68 fc 68 10 f0       	push   $0xf01068fc
f01015d6:	68 ff 70 10 f0       	push   $0xf01070ff
f01015db:	68 60 03 00 00       	push   $0x360
f01015e0:	68 d9 70 10 f0       	push   $0xf01070d9
f01015e5:	e8 56 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015ea:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015f0:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f01015f6:	c1 e2 0c             	shl    $0xc,%edx
f01015f9:	89 f8                	mov    %edi,%eax
f01015fb:	29 c8                	sub    %ecx,%eax
f01015fd:	c1 f8 03             	sar    $0x3,%eax
f0101600:	c1 e0 0c             	shl    $0xc,%eax
f0101603:	39 d0                	cmp    %edx,%eax
f0101605:	72 19                	jb     f0101620 <mem_init+0x24a>
f0101607:	68 2c 72 10 f0       	push   $0xf010722c
f010160c:	68 ff 70 10 f0       	push   $0xf01070ff
f0101611:	68 61 03 00 00       	push   $0x361
f0101616:	68 d9 70 10 f0       	push   $0xf01070d9
f010161b:	e8 20 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101620:	89 f0                	mov    %esi,%eax
f0101622:	29 c8                	sub    %ecx,%eax
f0101624:	c1 f8 03             	sar    $0x3,%eax
f0101627:	c1 e0 0c             	shl    $0xc,%eax
f010162a:	39 c2                	cmp    %eax,%edx
f010162c:	77 19                	ja     f0101647 <mem_init+0x271>
f010162e:	68 49 72 10 f0       	push   $0xf0107249
f0101633:	68 ff 70 10 f0       	push   $0xf01070ff
f0101638:	68 62 03 00 00       	push   $0x362
f010163d:	68 d9 70 10 f0       	push   $0xf01070d9
f0101642:	e8 f9 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101647:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010164a:	29 c8                	sub    %ecx,%eax
f010164c:	c1 f8 03             	sar    $0x3,%eax
f010164f:	c1 e0 0c             	shl    $0xc,%eax
f0101652:	39 c2                	cmp    %eax,%edx
f0101654:	77 19                	ja     f010166f <mem_init+0x299>
f0101656:	68 66 72 10 f0       	push   $0xf0107266
f010165b:	68 ff 70 10 f0       	push   $0xf01070ff
f0101660:	68 63 03 00 00       	push   $0x363
f0101665:	68 d9 70 10 f0       	push   $0xf01070d9
f010166a:	e8 d1 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010166f:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101674:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101677:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f010167e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101681:	83 ec 0c             	sub    $0xc,%esp
f0101684:	6a 00                	push   $0x0
f0101686:	e8 3a f9 ff ff       	call   f0100fc5 <page_alloc>
f010168b:	83 c4 10             	add    $0x10,%esp
f010168e:	85 c0                	test   %eax,%eax
f0101690:	74 19                	je     f01016ab <mem_init+0x2d5>
f0101692:	68 83 72 10 f0       	push   $0xf0107283
f0101697:	68 ff 70 10 f0       	push   $0xf01070ff
f010169c:	68 6a 03 00 00       	push   $0x36a
f01016a1:	68 d9 70 10 f0       	push   $0xf01070d9
f01016a6:	e8 95 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016ab:	83 ec 0c             	sub    $0xc,%esp
f01016ae:	57                   	push   %edi
f01016af:	e8 81 f9 ff ff       	call   f0101035 <page_free>
	page_free(pp1);
f01016b4:	89 34 24             	mov    %esi,(%esp)
f01016b7:	e8 79 f9 ff ff       	call   f0101035 <page_free>
	page_free(pp2);
f01016bc:	83 c4 04             	add    $0x4,%esp
f01016bf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016c2:	e8 6e f9 ff ff       	call   f0101035 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016ce:	e8 f2 f8 ff ff       	call   f0100fc5 <page_alloc>
f01016d3:	89 c6                	mov    %eax,%esi
f01016d5:	83 c4 10             	add    $0x10,%esp
f01016d8:	85 c0                	test   %eax,%eax
f01016da:	75 19                	jne    f01016f5 <mem_init+0x31f>
f01016dc:	68 d8 71 10 f0       	push   $0xf01071d8
f01016e1:	68 ff 70 10 f0       	push   $0xf01070ff
f01016e6:	68 71 03 00 00       	push   $0x371
f01016eb:	68 d9 70 10 f0       	push   $0xf01070d9
f01016f0:	e8 4b e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016f5:	83 ec 0c             	sub    $0xc,%esp
f01016f8:	6a 00                	push   $0x0
f01016fa:	e8 c6 f8 ff ff       	call   f0100fc5 <page_alloc>
f01016ff:	89 c7                	mov    %eax,%edi
f0101701:	83 c4 10             	add    $0x10,%esp
f0101704:	85 c0                	test   %eax,%eax
f0101706:	75 19                	jne    f0101721 <mem_init+0x34b>
f0101708:	68 ee 71 10 f0       	push   $0xf01071ee
f010170d:	68 ff 70 10 f0       	push   $0xf01070ff
f0101712:	68 72 03 00 00       	push   $0x372
f0101717:	68 d9 70 10 f0       	push   $0xf01070d9
f010171c:	e8 1f e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101721:	83 ec 0c             	sub    $0xc,%esp
f0101724:	6a 00                	push   $0x0
f0101726:	e8 9a f8 ff ff       	call   f0100fc5 <page_alloc>
f010172b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010172e:	83 c4 10             	add    $0x10,%esp
f0101731:	85 c0                	test   %eax,%eax
f0101733:	75 19                	jne    f010174e <mem_init+0x378>
f0101735:	68 04 72 10 f0       	push   $0xf0107204
f010173a:	68 ff 70 10 f0       	push   $0xf01070ff
f010173f:	68 73 03 00 00       	push   $0x373
f0101744:	68 d9 70 10 f0       	push   $0xf01070d9
f0101749:	e8 f2 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010174e:	39 fe                	cmp    %edi,%esi
f0101750:	75 19                	jne    f010176b <mem_init+0x395>
f0101752:	68 1a 72 10 f0       	push   $0xf010721a
f0101757:	68 ff 70 10 f0       	push   $0xf01070ff
f010175c:	68 75 03 00 00       	push   $0x375
f0101761:	68 d9 70 10 f0       	push   $0xf01070d9
f0101766:	e8 d5 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010176b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010176e:	39 c7                	cmp    %eax,%edi
f0101770:	74 04                	je     f0101776 <mem_init+0x3a0>
f0101772:	39 c6                	cmp    %eax,%esi
f0101774:	75 19                	jne    f010178f <mem_init+0x3b9>
f0101776:	68 fc 68 10 f0       	push   $0xf01068fc
f010177b:	68 ff 70 10 f0       	push   $0xf01070ff
f0101780:	68 76 03 00 00       	push   $0x376
f0101785:	68 d9 70 10 f0       	push   $0xf01070d9
f010178a:	e8 b1 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010178f:	83 ec 0c             	sub    $0xc,%esp
f0101792:	6a 00                	push   $0x0
f0101794:	e8 2c f8 ff ff       	call   f0100fc5 <page_alloc>
f0101799:	83 c4 10             	add    $0x10,%esp
f010179c:	85 c0                	test   %eax,%eax
f010179e:	74 19                	je     f01017b9 <mem_init+0x3e3>
f01017a0:	68 83 72 10 f0       	push   $0xf0107283
f01017a5:	68 ff 70 10 f0       	push   $0xf01070ff
f01017aa:	68 77 03 00 00       	push   $0x377
f01017af:	68 d9 70 10 f0       	push   $0xf01070d9
f01017b4:	e8 87 e8 ff ff       	call   f0100040 <_panic>
f01017b9:	89 f0                	mov    %esi,%eax
f01017bb:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01017c1:	c1 f8 03             	sar    $0x3,%eax
f01017c4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017c7:	89 c2                	mov    %eax,%edx
f01017c9:	c1 ea 0c             	shr    $0xc,%edx
f01017cc:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01017d2:	72 12                	jb     f01017e6 <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017d4:	50                   	push   %eax
f01017d5:	68 44 62 10 f0       	push   $0xf0106244
f01017da:	6a 58                	push   $0x58
f01017dc:	68 e5 70 10 f0       	push   $0xf01070e5
f01017e1:	e8 5a e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01017e6:	83 ec 04             	sub    $0x4,%esp
f01017e9:	68 00 10 00 00       	push   $0x1000
f01017ee:	6a 01                	push   $0x1
f01017f0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017f5:	50                   	push   %eax
f01017f6:	e8 63 3d 00 00       	call   f010555e <memset>
	page_free(pp0);
f01017fb:	89 34 24             	mov    %esi,(%esp)
f01017fe:	e8 32 f8 ff ff       	call   f0101035 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101803:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010180a:	e8 b6 f7 ff ff       	call   f0100fc5 <page_alloc>
f010180f:	83 c4 10             	add    $0x10,%esp
f0101812:	85 c0                	test   %eax,%eax
f0101814:	75 19                	jne    f010182f <mem_init+0x459>
f0101816:	68 92 72 10 f0       	push   $0xf0107292
f010181b:	68 ff 70 10 f0       	push   $0xf01070ff
f0101820:	68 7c 03 00 00       	push   $0x37c
f0101825:	68 d9 70 10 f0       	push   $0xf01070d9
f010182a:	e8 11 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010182f:	39 c6                	cmp    %eax,%esi
f0101831:	74 19                	je     f010184c <mem_init+0x476>
f0101833:	68 b0 72 10 f0       	push   $0xf01072b0
f0101838:	68 ff 70 10 f0       	push   $0xf01070ff
f010183d:	68 7d 03 00 00       	push   $0x37d
f0101842:	68 d9 70 10 f0       	push   $0xf01070d9
f0101847:	e8 f4 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010184c:	89 f0                	mov    %esi,%eax
f010184e:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101854:	c1 f8 03             	sar    $0x3,%eax
f0101857:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010185a:	89 c2                	mov    %eax,%edx
f010185c:	c1 ea 0c             	shr    $0xc,%edx
f010185f:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101865:	72 12                	jb     f0101879 <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101867:	50                   	push   %eax
f0101868:	68 44 62 10 f0       	push   $0xf0106244
f010186d:	6a 58                	push   $0x58
f010186f:	68 e5 70 10 f0       	push   $0xf01070e5
f0101874:	e8 c7 e7 ff ff       	call   f0100040 <_panic>
f0101879:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010187f:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101885:	80 38 00             	cmpb   $0x0,(%eax)
f0101888:	74 19                	je     f01018a3 <mem_init+0x4cd>
f010188a:	68 c0 72 10 f0       	push   $0xf01072c0
f010188f:	68 ff 70 10 f0       	push   $0xf01070ff
f0101894:	68 80 03 00 00       	push   $0x380
f0101899:	68 d9 70 10 f0       	push   $0xf01070d9
f010189e:	e8 9d e7 ff ff       	call   f0100040 <_panic>
f01018a3:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018a6:	39 d0                	cmp    %edx,%eax
f01018a8:	75 db                	jne    f0101885 <mem_init+0x4af>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018ad:	a3 40 12 21 f0       	mov    %eax,0xf0211240

	// free the pages we took
	page_free(pp0);
f01018b2:	83 ec 0c             	sub    $0xc,%esp
f01018b5:	56                   	push   %esi
f01018b6:	e8 7a f7 ff ff       	call   f0101035 <page_free>
	page_free(pp1);
f01018bb:	89 3c 24             	mov    %edi,(%esp)
f01018be:	e8 72 f7 ff ff       	call   f0101035 <page_free>
	page_free(pp2);
f01018c3:	83 c4 04             	add    $0x4,%esp
f01018c6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018c9:	e8 67 f7 ff ff       	call   f0101035 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018ce:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f01018d3:	83 c4 10             	add    $0x10,%esp
f01018d6:	eb 05                	jmp    f01018dd <mem_init+0x507>
		--nfree;
f01018d8:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018db:	8b 00                	mov    (%eax),%eax
f01018dd:	85 c0                	test   %eax,%eax
f01018df:	75 f7                	jne    f01018d8 <mem_init+0x502>
		--nfree;
	assert(nfree == 0);
f01018e1:	85 db                	test   %ebx,%ebx
f01018e3:	74 19                	je     f01018fe <mem_init+0x528>
f01018e5:	68 ca 72 10 f0       	push   $0xf01072ca
f01018ea:	68 ff 70 10 f0       	push   $0xf01070ff
f01018ef:	68 8d 03 00 00       	push   $0x38d
f01018f4:	68 d9 70 10 f0       	push   $0xf01070d9
f01018f9:	e8 42 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01018fe:	83 ec 0c             	sub    $0xc,%esp
f0101901:	68 1c 69 10 f0       	push   $0xf010691c
f0101906:	e8 d6 1e 00 00       	call   f01037e1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010190b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101912:	e8 ae f6 ff ff       	call   f0100fc5 <page_alloc>
f0101917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010191a:	83 c4 10             	add    $0x10,%esp
f010191d:	85 c0                	test   %eax,%eax
f010191f:	75 19                	jne    f010193a <mem_init+0x564>
f0101921:	68 d8 71 10 f0       	push   $0xf01071d8
f0101926:	68 ff 70 10 f0       	push   $0xf01070ff
f010192b:	68 f3 03 00 00       	push   $0x3f3
f0101930:	68 d9 70 10 f0       	push   $0xf01070d9
f0101935:	e8 06 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010193a:	83 ec 0c             	sub    $0xc,%esp
f010193d:	6a 00                	push   $0x0
f010193f:	e8 81 f6 ff ff       	call   f0100fc5 <page_alloc>
f0101944:	89 c3                	mov    %eax,%ebx
f0101946:	83 c4 10             	add    $0x10,%esp
f0101949:	85 c0                	test   %eax,%eax
f010194b:	75 19                	jne    f0101966 <mem_init+0x590>
f010194d:	68 ee 71 10 f0       	push   $0xf01071ee
f0101952:	68 ff 70 10 f0       	push   $0xf01070ff
f0101957:	68 f4 03 00 00       	push   $0x3f4
f010195c:	68 d9 70 10 f0       	push   $0xf01070d9
f0101961:	e8 da e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101966:	83 ec 0c             	sub    $0xc,%esp
f0101969:	6a 00                	push   $0x0
f010196b:	e8 55 f6 ff ff       	call   f0100fc5 <page_alloc>
f0101970:	89 c6                	mov    %eax,%esi
f0101972:	83 c4 10             	add    $0x10,%esp
f0101975:	85 c0                	test   %eax,%eax
f0101977:	75 19                	jne    f0101992 <mem_init+0x5bc>
f0101979:	68 04 72 10 f0       	push   $0xf0107204
f010197e:	68 ff 70 10 f0       	push   $0xf01070ff
f0101983:	68 f5 03 00 00       	push   $0x3f5
f0101988:	68 d9 70 10 f0       	push   $0xf01070d9
f010198d:	e8 ae e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101992:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101995:	75 19                	jne    f01019b0 <mem_init+0x5da>
f0101997:	68 1a 72 10 f0       	push   $0xf010721a
f010199c:	68 ff 70 10 f0       	push   $0xf01070ff
f01019a1:	68 f8 03 00 00       	push   $0x3f8
f01019a6:	68 d9 70 10 f0       	push   $0xf01070d9
f01019ab:	e8 90 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019b0:	39 c3                	cmp    %eax,%ebx
f01019b2:	74 05                	je     f01019b9 <mem_init+0x5e3>
f01019b4:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01019b7:	75 19                	jne    f01019d2 <mem_init+0x5fc>
f01019b9:	68 fc 68 10 f0       	push   $0xf01068fc
f01019be:	68 ff 70 10 f0       	push   $0xf01070ff
f01019c3:	68 f9 03 00 00       	push   $0x3f9
f01019c8:	68 d9 70 10 f0       	push   $0xf01070d9
f01019cd:	e8 6e e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019d2:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f01019d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019da:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f01019e1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019e4:	83 ec 0c             	sub    $0xc,%esp
f01019e7:	6a 00                	push   $0x0
f01019e9:	e8 d7 f5 ff ff       	call   f0100fc5 <page_alloc>
f01019ee:	83 c4 10             	add    $0x10,%esp
f01019f1:	85 c0                	test   %eax,%eax
f01019f3:	74 19                	je     f0101a0e <mem_init+0x638>
f01019f5:	68 83 72 10 f0       	push   $0xf0107283
f01019fa:	68 ff 70 10 f0       	push   $0xf01070ff
f01019ff:	68 00 04 00 00       	push   $0x400
f0101a04:	68 d9 70 10 f0       	push   $0xf01070d9
f0101a09:	e8 32 e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a0e:	83 ec 04             	sub    $0x4,%esp
f0101a11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a14:	50                   	push   %eax
f0101a15:	6a 00                	push   $0x0
f0101a17:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101a1d:	e8 df f7 ff ff       	call   f0101201 <page_lookup>
f0101a22:	83 c4 10             	add    $0x10,%esp
f0101a25:	85 c0                	test   %eax,%eax
f0101a27:	74 19                	je     f0101a42 <mem_init+0x66c>
f0101a29:	68 3c 69 10 f0       	push   $0xf010693c
f0101a2e:	68 ff 70 10 f0       	push   $0xf01070ff
f0101a33:	68 03 04 00 00       	push   $0x403
f0101a38:	68 d9 70 10 f0       	push   $0xf01070d9
f0101a3d:	e8 fe e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a42:	6a 02                	push   $0x2
f0101a44:	6a 00                	push   $0x0
f0101a46:	53                   	push   %ebx
f0101a47:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101a4d:	e8 8f f8 ff ff       	call   f01012e1 <page_insert>
f0101a52:	83 c4 10             	add    $0x10,%esp
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	78 19                	js     f0101a72 <mem_init+0x69c>
f0101a59:	68 74 69 10 f0       	push   $0xf0106974
f0101a5e:	68 ff 70 10 f0       	push   $0xf01070ff
f0101a63:	68 06 04 00 00       	push   $0x406
f0101a68:	68 d9 70 10 f0       	push   $0xf01070d9
f0101a6d:	e8 ce e5 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a72:	83 ec 0c             	sub    $0xc,%esp
f0101a75:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a78:	e8 b8 f5 ff ff       	call   f0101035 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a7d:	6a 02                	push   $0x2
f0101a7f:	6a 00                	push   $0x0
f0101a81:	53                   	push   %ebx
f0101a82:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101a88:	e8 54 f8 ff ff       	call   f01012e1 <page_insert>
f0101a8d:	83 c4 20             	add    $0x20,%esp
f0101a90:	85 c0                	test   %eax,%eax
f0101a92:	74 19                	je     f0101aad <mem_init+0x6d7>
f0101a94:	68 a4 69 10 f0       	push   $0xf01069a4
f0101a99:	68 ff 70 10 f0       	push   $0xf01070ff
f0101a9e:	68 0a 04 00 00       	push   $0x40a
f0101aa3:	68 d9 70 10 f0       	push   $0xf01070d9
f0101aa8:	e8 93 e5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101aad:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ab3:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0101ab8:	89 c1                	mov    %eax,%ecx
f0101aba:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101abd:	8b 17                	mov    (%edi),%edx
f0101abf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ac5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ac8:	29 c8                	sub    %ecx,%eax
f0101aca:	c1 f8 03             	sar    $0x3,%eax
f0101acd:	c1 e0 0c             	shl    $0xc,%eax
f0101ad0:	39 c2                	cmp    %eax,%edx
f0101ad2:	74 19                	je     f0101aed <mem_init+0x717>
f0101ad4:	68 d4 69 10 f0       	push   $0xf01069d4
f0101ad9:	68 ff 70 10 f0       	push   $0xf01070ff
f0101ade:	68 0b 04 00 00       	push   $0x40b
f0101ae3:	68 d9 70 10 f0       	push   $0xf01070d9
f0101ae8:	e8 53 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101aed:	ba 00 00 00 00       	mov    $0x0,%edx
f0101af2:	89 f8                	mov    %edi,%eax
f0101af4:	e8 f3 ef ff ff       	call   f0100aec <check_va2pa>
f0101af9:	89 da                	mov    %ebx,%edx
f0101afb:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101afe:	c1 fa 03             	sar    $0x3,%edx
f0101b01:	c1 e2 0c             	shl    $0xc,%edx
f0101b04:	39 d0                	cmp    %edx,%eax
f0101b06:	74 19                	je     f0101b21 <mem_init+0x74b>
f0101b08:	68 fc 69 10 f0       	push   $0xf01069fc
f0101b0d:	68 ff 70 10 f0       	push   $0xf01070ff
f0101b12:	68 0c 04 00 00       	push   $0x40c
f0101b17:	68 d9 70 10 f0       	push   $0xf01070d9
f0101b1c:	e8 1f e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101b21:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b26:	74 19                	je     f0101b41 <mem_init+0x76b>
f0101b28:	68 d5 72 10 f0       	push   $0xf01072d5
f0101b2d:	68 ff 70 10 f0       	push   $0xf01070ff
f0101b32:	68 0d 04 00 00       	push   $0x40d
f0101b37:	68 d9 70 10 f0       	push   $0xf01070d9
f0101b3c:	e8 ff e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101b41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b44:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b49:	74 19                	je     f0101b64 <mem_init+0x78e>
f0101b4b:	68 e6 72 10 f0       	push   $0xf01072e6
f0101b50:	68 ff 70 10 f0       	push   $0xf01070ff
f0101b55:	68 0e 04 00 00       	push   $0x40e
f0101b5a:	68 d9 70 10 f0       	push   $0xf01070d9
f0101b5f:	e8 dc e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b64:	6a 02                	push   $0x2
f0101b66:	68 00 10 00 00       	push   $0x1000
f0101b6b:	56                   	push   %esi
f0101b6c:	57                   	push   %edi
f0101b6d:	e8 6f f7 ff ff       	call   f01012e1 <page_insert>
f0101b72:	83 c4 10             	add    $0x10,%esp
f0101b75:	85 c0                	test   %eax,%eax
f0101b77:	74 19                	je     f0101b92 <mem_init+0x7bc>
f0101b79:	68 2c 6a 10 f0       	push   $0xf0106a2c
f0101b7e:	68 ff 70 10 f0       	push   $0xf01070ff
f0101b83:	68 11 04 00 00       	push   $0x411
f0101b88:	68 d9 70 10 f0       	push   $0xf01070d9
f0101b8d:	e8 ae e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b92:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b97:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101b9c:	e8 4b ef ff ff       	call   f0100aec <check_va2pa>
f0101ba1:	89 f2                	mov    %esi,%edx
f0101ba3:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101ba9:	c1 fa 03             	sar    $0x3,%edx
f0101bac:	c1 e2 0c             	shl    $0xc,%edx
f0101baf:	39 d0                	cmp    %edx,%eax
f0101bb1:	74 19                	je     f0101bcc <mem_init+0x7f6>
f0101bb3:	68 68 6a 10 f0       	push   $0xf0106a68
f0101bb8:	68 ff 70 10 f0       	push   $0xf01070ff
f0101bbd:	68 12 04 00 00       	push   $0x412
f0101bc2:	68 d9 70 10 f0       	push   $0xf01070d9
f0101bc7:	e8 74 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bcc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bd1:	74 19                	je     f0101bec <mem_init+0x816>
f0101bd3:	68 f7 72 10 f0       	push   $0xf01072f7
f0101bd8:	68 ff 70 10 f0       	push   $0xf01070ff
f0101bdd:	68 13 04 00 00       	push   $0x413
f0101be2:	68 d9 70 10 f0       	push   $0xf01070d9
f0101be7:	e8 54 e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101bec:	83 ec 0c             	sub    $0xc,%esp
f0101bef:	6a 00                	push   $0x0
f0101bf1:	e8 cf f3 ff ff       	call   f0100fc5 <page_alloc>
f0101bf6:	83 c4 10             	add    $0x10,%esp
f0101bf9:	85 c0                	test   %eax,%eax
f0101bfb:	74 19                	je     f0101c16 <mem_init+0x840>
f0101bfd:	68 83 72 10 f0       	push   $0xf0107283
f0101c02:	68 ff 70 10 f0       	push   $0xf01070ff
f0101c07:	68 16 04 00 00       	push   $0x416
f0101c0c:	68 d9 70 10 f0       	push   $0xf01070d9
f0101c11:	e8 2a e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c16:	6a 02                	push   $0x2
f0101c18:	68 00 10 00 00       	push   $0x1000
f0101c1d:	56                   	push   %esi
f0101c1e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101c24:	e8 b8 f6 ff ff       	call   f01012e1 <page_insert>
f0101c29:	83 c4 10             	add    $0x10,%esp
f0101c2c:	85 c0                	test   %eax,%eax
f0101c2e:	74 19                	je     f0101c49 <mem_init+0x873>
f0101c30:	68 2c 6a 10 f0       	push   $0xf0106a2c
f0101c35:	68 ff 70 10 f0       	push   $0xf01070ff
f0101c3a:	68 19 04 00 00       	push   $0x419
f0101c3f:	68 d9 70 10 f0       	push   $0xf01070d9
f0101c44:	e8 f7 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c49:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c4e:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101c53:	e8 94 ee ff ff       	call   f0100aec <check_va2pa>
f0101c58:	89 f2                	mov    %esi,%edx
f0101c5a:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101c60:	c1 fa 03             	sar    $0x3,%edx
f0101c63:	c1 e2 0c             	shl    $0xc,%edx
f0101c66:	39 d0                	cmp    %edx,%eax
f0101c68:	74 19                	je     f0101c83 <mem_init+0x8ad>
f0101c6a:	68 68 6a 10 f0       	push   $0xf0106a68
f0101c6f:	68 ff 70 10 f0       	push   $0xf01070ff
f0101c74:	68 1a 04 00 00       	push   $0x41a
f0101c79:	68 d9 70 10 f0       	push   $0xf01070d9
f0101c7e:	e8 bd e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c83:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c88:	74 19                	je     f0101ca3 <mem_init+0x8cd>
f0101c8a:	68 f7 72 10 f0       	push   $0xf01072f7
f0101c8f:	68 ff 70 10 f0       	push   $0xf01070ff
f0101c94:	68 1b 04 00 00       	push   $0x41b
f0101c99:	68 d9 70 10 f0       	push   $0xf01070d9
f0101c9e:	e8 9d e3 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ca3:	83 ec 0c             	sub    $0xc,%esp
f0101ca6:	6a 00                	push   $0x0
f0101ca8:	e8 18 f3 ff ff       	call   f0100fc5 <page_alloc>
f0101cad:	83 c4 10             	add    $0x10,%esp
f0101cb0:	85 c0                	test   %eax,%eax
f0101cb2:	74 19                	je     f0101ccd <mem_init+0x8f7>
f0101cb4:	68 83 72 10 f0       	push   $0xf0107283
f0101cb9:	68 ff 70 10 f0       	push   $0xf01070ff
f0101cbe:	68 1f 04 00 00       	push   $0x41f
f0101cc3:	68 d9 70 10 f0       	push   $0xf01070d9
f0101cc8:	e8 73 e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ccd:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0101cd3:	8b 02                	mov    (%edx),%eax
f0101cd5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cda:	89 c1                	mov    %eax,%ecx
f0101cdc:	c1 e9 0c             	shr    $0xc,%ecx
f0101cdf:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0101ce5:	72 15                	jb     f0101cfc <mem_init+0x926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ce7:	50                   	push   %eax
f0101ce8:	68 44 62 10 f0       	push   $0xf0106244
f0101ced:	68 22 04 00 00       	push   $0x422
f0101cf2:	68 d9 70 10 f0       	push   $0xf01070d9
f0101cf7:	e8 44 e3 ff ff       	call   f0100040 <_panic>
f0101cfc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d04:	83 ec 04             	sub    $0x4,%esp
f0101d07:	6a 00                	push   $0x0
f0101d09:	68 00 10 00 00       	push   $0x1000
f0101d0e:	52                   	push   %edx
f0101d0f:	e8 83 f3 ff ff       	call   f0101097 <pgdir_walk>
f0101d14:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d17:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d1a:	83 c4 10             	add    $0x10,%esp
f0101d1d:	39 d0                	cmp    %edx,%eax
f0101d1f:	74 19                	je     f0101d3a <mem_init+0x964>
f0101d21:	68 98 6a 10 f0       	push   $0xf0106a98
f0101d26:	68 ff 70 10 f0       	push   $0xf01070ff
f0101d2b:	68 23 04 00 00       	push   $0x423
f0101d30:	68 d9 70 10 f0       	push   $0xf01070d9
f0101d35:	e8 06 e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d3a:	6a 06                	push   $0x6
f0101d3c:	68 00 10 00 00       	push   $0x1000
f0101d41:	56                   	push   %esi
f0101d42:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101d48:	e8 94 f5 ff ff       	call   f01012e1 <page_insert>
f0101d4d:	83 c4 10             	add    $0x10,%esp
f0101d50:	85 c0                	test   %eax,%eax
f0101d52:	74 19                	je     f0101d6d <mem_init+0x997>
f0101d54:	68 d8 6a 10 f0       	push   $0xf0106ad8
f0101d59:	68 ff 70 10 f0       	push   $0xf01070ff
f0101d5e:	68 26 04 00 00       	push   $0x426
f0101d63:	68 d9 70 10 f0       	push   $0xf01070d9
f0101d68:	e8 d3 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d6d:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101d73:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d78:	89 f8                	mov    %edi,%eax
f0101d7a:	e8 6d ed ff ff       	call   f0100aec <check_va2pa>
f0101d7f:	89 f2                	mov    %esi,%edx
f0101d81:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101d87:	c1 fa 03             	sar    $0x3,%edx
f0101d8a:	c1 e2 0c             	shl    $0xc,%edx
f0101d8d:	39 d0                	cmp    %edx,%eax
f0101d8f:	74 19                	je     f0101daa <mem_init+0x9d4>
f0101d91:	68 68 6a 10 f0       	push   $0xf0106a68
f0101d96:	68 ff 70 10 f0       	push   $0xf01070ff
f0101d9b:	68 27 04 00 00       	push   $0x427
f0101da0:	68 d9 70 10 f0       	push   $0xf01070d9
f0101da5:	e8 96 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101daa:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101daf:	74 19                	je     f0101dca <mem_init+0x9f4>
f0101db1:	68 f7 72 10 f0       	push   $0xf01072f7
f0101db6:	68 ff 70 10 f0       	push   $0xf01070ff
f0101dbb:	68 28 04 00 00       	push   $0x428
f0101dc0:	68 d9 70 10 f0       	push   $0xf01070d9
f0101dc5:	e8 76 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101dca:	83 ec 04             	sub    $0x4,%esp
f0101dcd:	6a 00                	push   $0x0
f0101dcf:	68 00 10 00 00       	push   $0x1000
f0101dd4:	57                   	push   %edi
f0101dd5:	e8 bd f2 ff ff       	call   f0101097 <pgdir_walk>
f0101dda:	83 c4 10             	add    $0x10,%esp
f0101ddd:	f6 00 04             	testb  $0x4,(%eax)
f0101de0:	75 19                	jne    f0101dfb <mem_init+0xa25>
f0101de2:	68 18 6b 10 f0       	push   $0xf0106b18
f0101de7:	68 ff 70 10 f0       	push   $0xf01070ff
f0101dec:	68 29 04 00 00       	push   $0x429
f0101df1:	68 d9 70 10 f0       	push   $0xf01070d9
f0101df6:	e8 45 e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101dfb:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101e00:	f6 00 04             	testb  $0x4,(%eax)
f0101e03:	75 19                	jne    f0101e1e <mem_init+0xa48>
f0101e05:	68 08 73 10 f0       	push   $0xf0107308
f0101e0a:	68 ff 70 10 f0       	push   $0xf01070ff
f0101e0f:	68 2a 04 00 00       	push   $0x42a
f0101e14:	68 d9 70 10 f0       	push   $0xf01070d9
f0101e19:	e8 22 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e1e:	6a 02                	push   $0x2
f0101e20:	68 00 10 00 00       	push   $0x1000
f0101e25:	56                   	push   %esi
f0101e26:	50                   	push   %eax
f0101e27:	e8 b5 f4 ff ff       	call   f01012e1 <page_insert>
f0101e2c:	83 c4 10             	add    $0x10,%esp
f0101e2f:	85 c0                	test   %eax,%eax
f0101e31:	74 19                	je     f0101e4c <mem_init+0xa76>
f0101e33:	68 2c 6a 10 f0       	push   $0xf0106a2c
f0101e38:	68 ff 70 10 f0       	push   $0xf01070ff
f0101e3d:	68 2d 04 00 00       	push   $0x42d
f0101e42:	68 d9 70 10 f0       	push   $0xf01070d9
f0101e47:	e8 f4 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e4c:	83 ec 04             	sub    $0x4,%esp
f0101e4f:	6a 00                	push   $0x0
f0101e51:	68 00 10 00 00       	push   $0x1000
f0101e56:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e5c:	e8 36 f2 ff ff       	call   f0101097 <pgdir_walk>
f0101e61:	83 c4 10             	add    $0x10,%esp
f0101e64:	f6 00 02             	testb  $0x2,(%eax)
f0101e67:	75 19                	jne    f0101e82 <mem_init+0xaac>
f0101e69:	68 4c 6b 10 f0       	push   $0xf0106b4c
f0101e6e:	68 ff 70 10 f0       	push   $0xf01070ff
f0101e73:	68 2e 04 00 00       	push   $0x42e
f0101e78:	68 d9 70 10 f0       	push   $0xf01070d9
f0101e7d:	e8 be e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e82:	83 ec 04             	sub    $0x4,%esp
f0101e85:	6a 00                	push   $0x0
f0101e87:	68 00 10 00 00       	push   $0x1000
f0101e8c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e92:	e8 00 f2 ff ff       	call   f0101097 <pgdir_walk>
f0101e97:	83 c4 10             	add    $0x10,%esp
f0101e9a:	f6 00 04             	testb  $0x4,(%eax)
f0101e9d:	74 19                	je     f0101eb8 <mem_init+0xae2>
f0101e9f:	68 80 6b 10 f0       	push   $0xf0106b80
f0101ea4:	68 ff 70 10 f0       	push   $0xf01070ff
f0101ea9:	68 2f 04 00 00       	push   $0x42f
f0101eae:	68 d9 70 10 f0       	push   $0xf01070d9
f0101eb3:	e8 88 e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101eb8:	6a 02                	push   $0x2
f0101eba:	68 00 00 40 00       	push   $0x400000
f0101ebf:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ec2:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101ec8:	e8 14 f4 ff ff       	call   f01012e1 <page_insert>
f0101ecd:	83 c4 10             	add    $0x10,%esp
f0101ed0:	85 c0                	test   %eax,%eax
f0101ed2:	78 19                	js     f0101eed <mem_init+0xb17>
f0101ed4:	68 b8 6b 10 f0       	push   $0xf0106bb8
f0101ed9:	68 ff 70 10 f0       	push   $0xf01070ff
f0101ede:	68 32 04 00 00       	push   $0x432
f0101ee3:	68 d9 70 10 f0       	push   $0xf01070d9
f0101ee8:	e8 53 e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101eed:	6a 02                	push   $0x2
f0101eef:	68 00 10 00 00       	push   $0x1000
f0101ef4:	53                   	push   %ebx
f0101ef5:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101efb:	e8 e1 f3 ff ff       	call   f01012e1 <page_insert>
f0101f00:	83 c4 10             	add    $0x10,%esp
f0101f03:	85 c0                	test   %eax,%eax
f0101f05:	74 19                	je     f0101f20 <mem_init+0xb4a>
f0101f07:	68 f0 6b 10 f0       	push   $0xf0106bf0
f0101f0c:	68 ff 70 10 f0       	push   $0xf01070ff
f0101f11:	68 35 04 00 00       	push   $0x435
f0101f16:	68 d9 70 10 f0       	push   $0xf01070d9
f0101f1b:	e8 20 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f20:	83 ec 04             	sub    $0x4,%esp
f0101f23:	6a 00                	push   $0x0
f0101f25:	68 00 10 00 00       	push   $0x1000
f0101f2a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101f30:	e8 62 f1 ff ff       	call   f0101097 <pgdir_walk>
f0101f35:	83 c4 10             	add    $0x10,%esp
f0101f38:	f6 00 04             	testb  $0x4,(%eax)
f0101f3b:	74 19                	je     f0101f56 <mem_init+0xb80>
f0101f3d:	68 80 6b 10 f0       	push   $0xf0106b80
f0101f42:	68 ff 70 10 f0       	push   $0xf01070ff
f0101f47:	68 36 04 00 00       	push   $0x436
f0101f4c:	68 d9 70 10 f0       	push   $0xf01070d9
f0101f51:	e8 ea e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f56:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101f5c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f61:	89 f8                	mov    %edi,%eax
f0101f63:	e8 84 eb ff ff       	call   f0100aec <check_va2pa>
f0101f68:	89 c1                	mov    %eax,%ecx
f0101f6a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f6d:	89 d8                	mov    %ebx,%eax
f0101f6f:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101f75:	c1 f8 03             	sar    $0x3,%eax
f0101f78:	c1 e0 0c             	shl    $0xc,%eax
f0101f7b:	39 c1                	cmp    %eax,%ecx
f0101f7d:	74 19                	je     f0101f98 <mem_init+0xbc2>
f0101f7f:	68 2c 6c 10 f0       	push   $0xf0106c2c
f0101f84:	68 ff 70 10 f0       	push   $0xf01070ff
f0101f89:	68 39 04 00 00       	push   $0x439
f0101f8e:	68 d9 70 10 f0       	push   $0xf01070d9
f0101f93:	e8 a8 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f98:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f9d:	89 f8                	mov    %edi,%eax
f0101f9f:	e8 48 eb ff ff       	call   f0100aec <check_va2pa>
f0101fa4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fa7:	74 19                	je     f0101fc2 <mem_init+0xbec>
f0101fa9:	68 58 6c 10 f0       	push   $0xf0106c58
f0101fae:	68 ff 70 10 f0       	push   $0xf01070ff
f0101fb3:	68 3a 04 00 00       	push   $0x43a
f0101fb8:	68 d9 70 10 f0       	push   $0xf01070d9
f0101fbd:	e8 7e e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fc2:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fc7:	74 19                	je     f0101fe2 <mem_init+0xc0c>
f0101fc9:	68 1e 73 10 f0       	push   $0xf010731e
f0101fce:	68 ff 70 10 f0       	push   $0xf01070ff
f0101fd3:	68 3c 04 00 00       	push   $0x43c
f0101fd8:	68 d9 70 10 f0       	push   $0xf01070d9
f0101fdd:	e8 5e e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fe2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fe7:	74 19                	je     f0102002 <mem_init+0xc2c>
f0101fe9:	68 2f 73 10 f0       	push   $0xf010732f
f0101fee:	68 ff 70 10 f0       	push   $0xf01070ff
f0101ff3:	68 3d 04 00 00       	push   $0x43d
f0101ff8:	68 d9 70 10 f0       	push   $0xf01070d9
f0101ffd:	e8 3e e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102002:	83 ec 0c             	sub    $0xc,%esp
f0102005:	6a 00                	push   $0x0
f0102007:	e8 b9 ef ff ff       	call   f0100fc5 <page_alloc>
f010200c:	83 c4 10             	add    $0x10,%esp
f010200f:	85 c0                	test   %eax,%eax
f0102011:	74 04                	je     f0102017 <mem_init+0xc41>
f0102013:	39 c6                	cmp    %eax,%esi
f0102015:	74 19                	je     f0102030 <mem_init+0xc5a>
f0102017:	68 88 6c 10 f0       	push   $0xf0106c88
f010201c:	68 ff 70 10 f0       	push   $0xf01070ff
f0102021:	68 40 04 00 00       	push   $0x440
f0102026:	68 d9 70 10 f0       	push   $0xf01070d9
f010202b:	e8 10 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102030:	83 ec 08             	sub    $0x8,%esp
f0102033:	6a 00                	push   $0x0
f0102035:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010203b:	e8 5b f2 ff ff       	call   f010129b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102040:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0102046:	ba 00 00 00 00       	mov    $0x0,%edx
f010204b:	89 f8                	mov    %edi,%eax
f010204d:	e8 9a ea ff ff       	call   f0100aec <check_va2pa>
f0102052:	83 c4 10             	add    $0x10,%esp
f0102055:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102058:	74 19                	je     f0102073 <mem_init+0xc9d>
f010205a:	68 ac 6c 10 f0       	push   $0xf0106cac
f010205f:	68 ff 70 10 f0       	push   $0xf01070ff
f0102064:	68 44 04 00 00       	push   $0x444
f0102069:	68 d9 70 10 f0       	push   $0xf01070d9
f010206e:	e8 cd df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102073:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102078:	89 f8                	mov    %edi,%eax
f010207a:	e8 6d ea ff ff       	call   f0100aec <check_va2pa>
f010207f:	89 da                	mov    %ebx,%edx
f0102081:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102087:	c1 fa 03             	sar    $0x3,%edx
f010208a:	c1 e2 0c             	shl    $0xc,%edx
f010208d:	39 d0                	cmp    %edx,%eax
f010208f:	74 19                	je     f01020aa <mem_init+0xcd4>
f0102091:	68 58 6c 10 f0       	push   $0xf0106c58
f0102096:	68 ff 70 10 f0       	push   $0xf01070ff
f010209b:	68 45 04 00 00       	push   $0x445
f01020a0:	68 d9 70 10 f0       	push   $0xf01070d9
f01020a5:	e8 96 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01020aa:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020af:	74 19                	je     f01020ca <mem_init+0xcf4>
f01020b1:	68 d5 72 10 f0       	push   $0xf01072d5
f01020b6:	68 ff 70 10 f0       	push   $0xf01070ff
f01020bb:	68 46 04 00 00       	push   $0x446
f01020c0:	68 d9 70 10 f0       	push   $0xf01070d9
f01020c5:	e8 76 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020ca:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020cf:	74 19                	je     f01020ea <mem_init+0xd14>
f01020d1:	68 2f 73 10 f0       	push   $0xf010732f
f01020d6:	68 ff 70 10 f0       	push   $0xf01070ff
f01020db:	68 47 04 00 00       	push   $0x447
f01020e0:	68 d9 70 10 f0       	push   $0xf01070d9
f01020e5:	e8 56 df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020ea:	6a 00                	push   $0x0
f01020ec:	68 00 10 00 00       	push   $0x1000
f01020f1:	53                   	push   %ebx
f01020f2:	57                   	push   %edi
f01020f3:	e8 e9 f1 ff ff       	call   f01012e1 <page_insert>
f01020f8:	83 c4 10             	add    $0x10,%esp
f01020fb:	85 c0                	test   %eax,%eax
f01020fd:	74 19                	je     f0102118 <mem_init+0xd42>
f01020ff:	68 d0 6c 10 f0       	push   $0xf0106cd0
f0102104:	68 ff 70 10 f0       	push   $0xf01070ff
f0102109:	68 4a 04 00 00       	push   $0x44a
f010210e:	68 d9 70 10 f0       	push   $0xf01070d9
f0102113:	e8 28 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102118:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010211d:	75 19                	jne    f0102138 <mem_init+0xd62>
f010211f:	68 40 73 10 f0       	push   $0xf0107340
f0102124:	68 ff 70 10 f0       	push   $0xf01070ff
f0102129:	68 4b 04 00 00       	push   $0x44b
f010212e:	68 d9 70 10 f0       	push   $0xf01070d9
f0102133:	e8 08 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102138:	83 3b 00             	cmpl   $0x0,(%ebx)
f010213b:	74 19                	je     f0102156 <mem_init+0xd80>
f010213d:	68 4c 73 10 f0       	push   $0xf010734c
f0102142:	68 ff 70 10 f0       	push   $0xf01070ff
f0102147:	68 4c 04 00 00       	push   $0x44c
f010214c:	68 d9 70 10 f0       	push   $0xf01070d9
f0102151:	e8 ea de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102156:	83 ec 08             	sub    $0x8,%esp
f0102159:	68 00 10 00 00       	push   $0x1000
f010215e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102164:	e8 32 f1 ff ff       	call   f010129b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102169:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f010216f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102174:	89 f8                	mov    %edi,%eax
f0102176:	e8 71 e9 ff ff       	call   f0100aec <check_va2pa>
f010217b:	83 c4 10             	add    $0x10,%esp
f010217e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102181:	74 19                	je     f010219c <mem_init+0xdc6>
f0102183:	68 ac 6c 10 f0       	push   $0xf0106cac
f0102188:	68 ff 70 10 f0       	push   $0xf01070ff
f010218d:	68 50 04 00 00       	push   $0x450
f0102192:	68 d9 70 10 f0       	push   $0xf01070d9
f0102197:	e8 a4 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010219c:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021a1:	89 f8                	mov    %edi,%eax
f01021a3:	e8 44 e9 ff ff       	call   f0100aec <check_va2pa>
f01021a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021ab:	74 19                	je     f01021c6 <mem_init+0xdf0>
f01021ad:	68 08 6d 10 f0       	push   $0xf0106d08
f01021b2:	68 ff 70 10 f0       	push   $0xf01070ff
f01021b7:	68 51 04 00 00       	push   $0x451
f01021bc:	68 d9 70 10 f0       	push   $0xf01070d9
f01021c1:	e8 7a de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01021c6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021cb:	74 19                	je     f01021e6 <mem_init+0xe10>
f01021cd:	68 61 73 10 f0       	push   $0xf0107361
f01021d2:	68 ff 70 10 f0       	push   $0xf01070ff
f01021d7:	68 52 04 00 00       	push   $0x452
f01021dc:	68 d9 70 10 f0       	push   $0xf01070d9
f01021e1:	e8 5a de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01021e6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021eb:	74 19                	je     f0102206 <mem_init+0xe30>
f01021ed:	68 2f 73 10 f0       	push   $0xf010732f
f01021f2:	68 ff 70 10 f0       	push   $0xf01070ff
f01021f7:	68 53 04 00 00       	push   $0x453
f01021fc:	68 d9 70 10 f0       	push   $0xf01070d9
f0102201:	e8 3a de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102206:	83 ec 0c             	sub    $0xc,%esp
f0102209:	6a 00                	push   $0x0
f010220b:	e8 b5 ed ff ff       	call   f0100fc5 <page_alloc>
f0102210:	83 c4 10             	add    $0x10,%esp
f0102213:	39 c3                	cmp    %eax,%ebx
f0102215:	75 04                	jne    f010221b <mem_init+0xe45>
f0102217:	85 c0                	test   %eax,%eax
f0102219:	75 19                	jne    f0102234 <mem_init+0xe5e>
f010221b:	68 30 6d 10 f0       	push   $0xf0106d30
f0102220:	68 ff 70 10 f0       	push   $0xf01070ff
f0102225:	68 56 04 00 00       	push   $0x456
f010222a:	68 d9 70 10 f0       	push   $0xf01070d9
f010222f:	e8 0c de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102234:	83 ec 0c             	sub    $0xc,%esp
f0102237:	6a 00                	push   $0x0
f0102239:	e8 87 ed ff ff       	call   f0100fc5 <page_alloc>
f010223e:	83 c4 10             	add    $0x10,%esp
f0102241:	85 c0                	test   %eax,%eax
f0102243:	74 19                	je     f010225e <mem_init+0xe88>
f0102245:	68 83 72 10 f0       	push   $0xf0107283
f010224a:	68 ff 70 10 f0       	push   $0xf01070ff
f010224f:	68 59 04 00 00       	push   $0x459
f0102254:	68 d9 70 10 f0       	push   $0xf01070d9
f0102259:	e8 e2 dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010225e:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102264:	8b 11                	mov    (%ecx),%edx
f0102266:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010226c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010226f:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102275:	c1 f8 03             	sar    $0x3,%eax
f0102278:	c1 e0 0c             	shl    $0xc,%eax
f010227b:	39 c2                	cmp    %eax,%edx
f010227d:	74 19                	je     f0102298 <mem_init+0xec2>
f010227f:	68 d4 69 10 f0       	push   $0xf01069d4
f0102284:	68 ff 70 10 f0       	push   $0xf01070ff
f0102289:	68 5c 04 00 00       	push   $0x45c
f010228e:	68 d9 70 10 f0       	push   $0xf01070d9
f0102293:	e8 a8 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102298:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010229e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022a1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01022a6:	74 19                	je     f01022c1 <mem_init+0xeeb>
f01022a8:	68 e6 72 10 f0       	push   $0xf01072e6
f01022ad:	68 ff 70 10 f0       	push   $0xf01070ff
f01022b2:	68 5e 04 00 00       	push   $0x45e
f01022b7:	68 d9 70 10 f0       	push   $0xf01070d9
f01022bc:	e8 7f dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01022c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022ca:	83 ec 0c             	sub    $0xc,%esp
f01022cd:	50                   	push   %eax
f01022ce:	e8 62 ed ff ff       	call   f0101035 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022d3:	83 c4 0c             	add    $0xc,%esp
f01022d6:	6a 01                	push   $0x1
f01022d8:	68 00 10 40 00       	push   $0x401000
f01022dd:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01022e3:	e8 af ed ff ff       	call   f0101097 <pgdir_walk>
f01022e8:	89 c7                	mov    %eax,%edi
f01022ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022ed:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01022f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022f5:	8b 40 04             	mov    0x4(%eax),%eax
f01022f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022fd:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0102303:	89 c2                	mov    %eax,%edx
f0102305:	c1 ea 0c             	shr    $0xc,%edx
f0102308:	83 c4 10             	add    $0x10,%esp
f010230b:	39 ca                	cmp    %ecx,%edx
f010230d:	72 15                	jb     f0102324 <mem_init+0xf4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010230f:	50                   	push   %eax
f0102310:	68 44 62 10 f0       	push   $0xf0106244
f0102315:	68 65 04 00 00       	push   $0x465
f010231a:	68 d9 70 10 f0       	push   $0xf01070d9
f010231f:	e8 1c dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102324:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102329:	39 c7                	cmp    %eax,%edi
f010232b:	74 19                	je     f0102346 <mem_init+0xf70>
f010232d:	68 72 73 10 f0       	push   $0xf0107372
f0102332:	68 ff 70 10 f0       	push   $0xf01070ff
f0102337:	68 66 04 00 00       	push   $0x466
f010233c:	68 d9 70 10 f0       	push   $0xf01070d9
f0102341:	e8 fa dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102346:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102349:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102350:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102353:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102359:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010235f:	c1 f8 03             	sar    $0x3,%eax
f0102362:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102365:	89 c2                	mov    %eax,%edx
f0102367:	c1 ea 0c             	shr    $0xc,%edx
f010236a:	39 d1                	cmp    %edx,%ecx
f010236c:	77 12                	ja     f0102380 <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010236e:	50                   	push   %eax
f010236f:	68 44 62 10 f0       	push   $0xf0106244
f0102374:	6a 58                	push   $0x58
f0102376:	68 e5 70 10 f0       	push   $0xf01070e5
f010237b:	e8 c0 dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102380:	83 ec 04             	sub    $0x4,%esp
f0102383:	68 00 10 00 00       	push   $0x1000
f0102388:	68 ff 00 00 00       	push   $0xff
f010238d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102392:	50                   	push   %eax
f0102393:	e8 c6 31 00 00       	call   f010555e <memset>
	page_free(pp0);
f0102398:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010239b:	89 3c 24             	mov    %edi,(%esp)
f010239e:	e8 92 ec ff ff       	call   f0101035 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023a3:	83 c4 0c             	add    $0xc,%esp
f01023a6:	6a 01                	push   $0x1
f01023a8:	6a 00                	push   $0x0
f01023aa:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01023b0:	e8 e2 ec ff ff       	call   f0101097 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023b5:	89 fa                	mov    %edi,%edx
f01023b7:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01023bd:	c1 fa 03             	sar    $0x3,%edx
f01023c0:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023c3:	89 d0                	mov    %edx,%eax
f01023c5:	c1 e8 0c             	shr    $0xc,%eax
f01023c8:	83 c4 10             	add    $0x10,%esp
f01023cb:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01023d1:	72 12                	jb     f01023e5 <mem_init+0x100f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023d3:	52                   	push   %edx
f01023d4:	68 44 62 10 f0       	push   $0xf0106244
f01023d9:	6a 58                	push   $0x58
f01023db:	68 e5 70 10 f0       	push   $0xf01070e5
f01023e0:	e8 5b dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01023e5:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023ee:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01023f4:	f6 00 01             	testb  $0x1,(%eax)
f01023f7:	74 19                	je     f0102412 <mem_init+0x103c>
f01023f9:	68 8a 73 10 f0       	push   $0xf010738a
f01023fe:	68 ff 70 10 f0       	push   $0xf01070ff
f0102403:	68 70 04 00 00       	push   $0x470
f0102408:	68 d9 70 10 f0       	push   $0xf01070d9
f010240d:	e8 2e dc ff ff       	call   f0100040 <_panic>
f0102412:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102415:	39 d0                	cmp    %edx,%eax
f0102417:	75 db                	jne    f01023f4 <mem_init+0x101e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102419:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010241e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102424:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102427:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010242d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102430:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240

	// free the pages we took
	page_free(pp0);
f0102436:	83 ec 0c             	sub    $0xc,%esp
f0102439:	50                   	push   %eax
f010243a:	e8 f6 eb ff ff       	call   f0101035 <page_free>
	page_free(pp1);
f010243f:	89 1c 24             	mov    %ebx,(%esp)
f0102442:	e8 ee eb ff ff       	call   f0101035 <page_free>
	page_free(pp2);
f0102447:	89 34 24             	mov    %esi,(%esp)
f010244a:	e8 e6 eb ff ff       	call   f0101035 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010244f:	83 c4 08             	add    $0x8,%esp
f0102452:	68 01 10 00 00       	push   $0x1001
f0102457:	6a 00                	push   $0x0
f0102459:	e8 08 ef ff ff       	call   f0101366 <mmio_map_region>
f010245e:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102460:	83 c4 08             	add    $0x8,%esp
f0102463:	68 00 10 00 00       	push   $0x1000
f0102468:	6a 00                	push   $0x0
f010246a:	e8 f7 ee ff ff       	call   f0101366 <mmio_map_region>
f010246f:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102471:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102477:	83 c4 10             	add    $0x10,%esp
f010247a:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102480:	76 07                	jbe    f0102489 <mem_init+0x10b3>
f0102482:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102487:	76 19                	jbe    f01024a2 <mem_init+0x10cc>
f0102489:	68 54 6d 10 f0       	push   $0xf0106d54
f010248e:	68 ff 70 10 f0       	push   $0xf01070ff
f0102493:	68 80 04 00 00       	push   $0x480
f0102498:	68 d9 70 10 f0       	push   $0xf01070d9
f010249d:	e8 9e db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01024a2:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f01024a8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024ae:	77 08                	ja     f01024b8 <mem_init+0x10e2>
f01024b0:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024b6:	77 19                	ja     f01024d1 <mem_init+0x10fb>
f01024b8:	68 7c 6d 10 f0       	push   $0xf0106d7c
f01024bd:	68 ff 70 10 f0       	push   $0xf01070ff
f01024c2:	68 81 04 00 00       	push   $0x481
f01024c7:	68 d9 70 10 f0       	push   $0xf01070d9
f01024cc:	e8 6f db ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024d1:	89 da                	mov    %ebx,%edx
f01024d3:	09 f2                	or     %esi,%edx
f01024d5:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024db:	74 19                	je     f01024f6 <mem_init+0x1120>
f01024dd:	68 a4 6d 10 f0       	push   $0xf0106da4
f01024e2:	68 ff 70 10 f0       	push   $0xf01070ff
f01024e7:	68 83 04 00 00       	push   $0x483
f01024ec:	68 d9 70 10 f0       	push   $0xf01070d9
f01024f1:	e8 4a db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f01024f6:	39 c6                	cmp    %eax,%esi
f01024f8:	73 19                	jae    f0102513 <mem_init+0x113d>
f01024fa:	68 a1 73 10 f0       	push   $0xf01073a1
f01024ff:	68 ff 70 10 f0       	push   $0xf01070ff
f0102504:	68 85 04 00 00       	push   $0x485
f0102509:	68 d9 70 10 f0       	push   $0xf01070d9
f010250e:	e8 2d db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102513:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0102519:	89 da                	mov    %ebx,%edx
f010251b:	89 f8                	mov    %edi,%eax
f010251d:	e8 ca e5 ff ff       	call   f0100aec <check_va2pa>
f0102522:	85 c0                	test   %eax,%eax
f0102524:	74 19                	je     f010253f <mem_init+0x1169>
f0102526:	68 cc 6d 10 f0       	push   $0xf0106dcc
f010252b:	68 ff 70 10 f0       	push   $0xf01070ff
f0102530:	68 87 04 00 00       	push   $0x487
f0102535:	68 d9 70 10 f0       	push   $0xf01070d9
f010253a:	e8 01 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010253f:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102545:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102548:	89 c2                	mov    %eax,%edx
f010254a:	89 f8                	mov    %edi,%eax
f010254c:	e8 9b e5 ff ff       	call   f0100aec <check_va2pa>
f0102551:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102556:	74 19                	je     f0102571 <mem_init+0x119b>
f0102558:	68 f0 6d 10 f0       	push   $0xf0106df0
f010255d:	68 ff 70 10 f0       	push   $0xf01070ff
f0102562:	68 88 04 00 00       	push   $0x488
f0102567:	68 d9 70 10 f0       	push   $0xf01070d9
f010256c:	e8 cf da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102571:	89 f2                	mov    %esi,%edx
f0102573:	89 f8                	mov    %edi,%eax
f0102575:	e8 72 e5 ff ff       	call   f0100aec <check_va2pa>
f010257a:	85 c0                	test   %eax,%eax
f010257c:	74 19                	je     f0102597 <mem_init+0x11c1>
f010257e:	68 20 6e 10 f0       	push   $0xf0106e20
f0102583:	68 ff 70 10 f0       	push   $0xf01070ff
f0102588:	68 89 04 00 00       	push   $0x489
f010258d:	68 d9 70 10 f0       	push   $0xf01070d9
f0102592:	e8 a9 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102597:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010259d:	89 f8                	mov    %edi,%eax
f010259f:	e8 48 e5 ff ff       	call   f0100aec <check_va2pa>
f01025a4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025a7:	74 19                	je     f01025c2 <mem_init+0x11ec>
f01025a9:	68 44 6e 10 f0       	push   $0xf0106e44
f01025ae:	68 ff 70 10 f0       	push   $0xf01070ff
f01025b3:	68 8a 04 00 00       	push   $0x48a
f01025b8:	68 d9 70 10 f0       	push   $0xf01070d9
f01025bd:	e8 7e da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01025c2:	83 ec 04             	sub    $0x4,%esp
f01025c5:	6a 00                	push   $0x0
f01025c7:	53                   	push   %ebx
f01025c8:	57                   	push   %edi
f01025c9:	e8 c9 ea ff ff       	call   f0101097 <pgdir_walk>
f01025ce:	83 c4 10             	add    $0x10,%esp
f01025d1:	f6 00 1a             	testb  $0x1a,(%eax)
f01025d4:	75 19                	jne    f01025ef <mem_init+0x1219>
f01025d6:	68 70 6e 10 f0       	push   $0xf0106e70
f01025db:	68 ff 70 10 f0       	push   $0xf01070ff
f01025e0:	68 8c 04 00 00       	push   $0x48c
f01025e5:	68 d9 70 10 f0       	push   $0xf01070d9
f01025ea:	e8 51 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01025ef:	83 ec 04             	sub    $0x4,%esp
f01025f2:	6a 00                	push   $0x0
f01025f4:	53                   	push   %ebx
f01025f5:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01025fb:	e8 97 ea ff ff       	call   f0101097 <pgdir_walk>
f0102600:	8b 00                	mov    (%eax),%eax
f0102602:	83 c4 10             	add    $0x10,%esp
f0102605:	83 e0 04             	and    $0x4,%eax
f0102608:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010260b:	74 19                	je     f0102626 <mem_init+0x1250>
f010260d:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0102612:	68 ff 70 10 f0       	push   $0xf01070ff
f0102617:	68 8d 04 00 00       	push   $0x48d
f010261c:	68 d9 70 10 f0       	push   $0xf01070d9
f0102621:	e8 1a da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102626:	83 ec 04             	sub    $0x4,%esp
f0102629:	6a 00                	push   $0x0
f010262b:	53                   	push   %ebx
f010262c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102632:	e8 60 ea ff ff       	call   f0101097 <pgdir_walk>
f0102637:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010263d:	83 c4 0c             	add    $0xc,%esp
f0102640:	6a 00                	push   $0x0
f0102642:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102645:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010264b:	e8 47 ea ff ff       	call   f0101097 <pgdir_walk>
f0102650:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102656:	83 c4 0c             	add    $0xc,%esp
f0102659:	6a 00                	push   $0x0
f010265b:	56                   	push   %esi
f010265c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102662:	e8 30 ea ff ff       	call   f0101097 <pgdir_walk>
f0102667:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010266d:	c7 04 24 b3 73 10 f0 	movl   $0xf01073b3,(%esp)
f0102674:	e8 68 11 00 00       	call   f01037e1 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102679:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010267e:	83 c4 10             	add    $0x10,%esp
f0102681:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102686:	77 15                	ja     f010269d <mem_init+0x12c7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102688:	50                   	push   %eax
f0102689:	68 68 62 10 f0       	push   $0xf0106268
f010268e:	68 be 00 00 00       	push   $0xbe
f0102693:	68 d9 70 10 f0       	push   $0xf01070d9
f0102698:	e8 a3 d9 ff ff       	call   f0100040 <_panic>
                    UPAGES, 
                    ROUNDUP((sizeof(struct PageInfo)*npages), PGSIZE),
f010269d:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f01026a3:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f01026aa:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026b0:	83 ec 08             	sub    $0x8,%esp
f01026b3:	6a 04                	push   $0x4
f01026b5:	05 00 00 00 10       	add    $0x10000000,%eax
f01026ba:	50                   	push   %eax
f01026bb:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026c0:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01026c5:	e8 b2 ea ff ff       	call   f010117c <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01026ca:	a1 48 12 21 f0       	mov    0xf0211248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026cf:	83 c4 10             	add    $0x10,%esp
f01026d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d7:	77 15                	ja     f01026ee <mem_init+0x1318>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d9:	50                   	push   %eax
f01026da:	68 68 62 10 f0       	push   $0xf0106268
f01026df:	68 c7 00 00 00       	push   $0xc7
f01026e4:	68 d9 70 10 f0       	push   $0xf01070d9
f01026e9:	e8 52 d9 ff ff       	call   f0100040 <_panic>
f01026ee:	83 ec 08             	sub    $0x8,%esp
f01026f1:	6a 04                	push   $0x4
f01026f3:	05 00 00 00 10       	add    $0x10000000,%eax
f01026f8:	50                   	push   %eax
f01026f9:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026fe:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102703:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102708:	e8 6f ea ff ff       	call   f010117c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270d:	83 c4 10             	add    $0x10,%esp
f0102710:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102715:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010271a:	77 15                	ja     f0102731 <mem_init+0x135b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010271c:	50                   	push   %eax
f010271d:	68 68 62 10 f0       	push   $0xf0106268
f0102722:	68 d6 00 00 00       	push   $0xd6
f0102727:	68 d9 70 10 f0       	push   $0xf01070d9
f010272c:	e8 0f d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102731:	83 ec 08             	sub    $0x8,%esp
f0102734:	6a 02                	push   $0x2
f0102736:	68 00 60 11 00       	push   $0x116000
f010273b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102740:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102745:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010274a:	e8 2d ea ff ff       	call   f010117c <boot_map_region>
f010274f:	c7 45 c4 00 30 21 f0 	movl   $0xf0213000,-0x3c(%ebp)
f0102756:	83 c4 10             	add    $0x10,%esp
f0102759:	bb 00 30 21 f0       	mov    $0xf0213000,%ebx
f010275e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102763:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102769:	77 15                	ja     f0102780 <mem_init+0x13aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010276b:	53                   	push   %ebx
f010276c:	68 68 62 10 f0       	push   $0xf0106268
f0102771:	68 1d 01 00 00       	push   $0x11d
f0102776:	68 d9 70 10 f0       	push   $0xf01070d9
f010277b:	e8 c0 d8 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
    size_t i;
    size_t kstacktop_i;
    for(i = 0; i < NCPU; i++) {
        kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
        boot_map_region(kern_pgdir,
f0102780:	83 ec 08             	sub    $0x8,%esp
f0102783:	6a 02                	push   $0x2
f0102785:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010278b:	50                   	push   %eax
f010278c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102791:	89 f2                	mov    %esi,%edx
f0102793:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102798:	e8 df e9 ff ff       	call   f010117c <boot_map_region>
f010279d:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01027a3:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
    size_t i;
    size_t kstacktop_i;
    for(i = 0; i < NCPU; i++) {
f01027a9:	83 c4 10             	add    $0x10,%esp
f01027ac:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f01027b1:	39 d8                	cmp    %ebx,%eax
f01027b3:	75 ae                	jne    f0102763 <mem_init+0x138d>


	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f01027b5:	83 ec 08             	sub    $0x8,%esp
f01027b8:	6a 02                	push   $0x2
f01027ba:	6a 00                	push   $0x0
f01027bc:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01027c1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027c6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01027cb:	e8 ac e9 ff ff       	call   f010117c <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027d0:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027d6:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01027db:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027de:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01027e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027ed:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027f3:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01027f6:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027f9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027fe:	eb 55                	jmp    f0102855 <mem_init+0x147f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102800:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102806:	89 f8                	mov    %edi,%eax
f0102808:	e8 df e2 ff ff       	call   f0100aec <check_va2pa>
f010280d:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102814:	77 15                	ja     f010282b <mem_init+0x1455>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102816:	56                   	push   %esi
f0102817:	68 68 62 10 f0       	push   $0xf0106268
f010281c:	68 a5 03 00 00       	push   $0x3a5
f0102821:	68 d9 70 10 f0       	push   $0xf01070d9
f0102826:	e8 15 d8 ff ff       	call   f0100040 <_panic>
f010282b:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102832:	39 c2                	cmp    %eax,%edx
f0102834:	74 19                	je     f010284f <mem_init+0x1479>
f0102836:	68 e8 6e 10 f0       	push   $0xf0106ee8
f010283b:	68 ff 70 10 f0       	push   $0xf01070ff
f0102840:	68 a5 03 00 00       	push   $0x3a5
f0102845:	68 d9 70 10 f0       	push   $0xf01070d9
f010284a:	e8 f1 d7 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010284f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102855:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102858:	77 a6                	ja     f0102800 <mem_init+0x142a>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010285a:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102860:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102863:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102868:	89 da                	mov    %ebx,%edx
f010286a:	89 f8                	mov    %edi,%eax
f010286c:	e8 7b e2 ff ff       	call   f0100aec <check_va2pa>
f0102871:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102878:	77 15                	ja     f010288f <mem_init+0x14b9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010287a:	56                   	push   %esi
f010287b:	68 68 62 10 f0       	push   $0xf0106268
f0102880:	68 aa 03 00 00       	push   $0x3aa
f0102885:	68 d9 70 10 f0       	push   $0xf01070d9
f010288a:	e8 b1 d7 ff ff       	call   f0100040 <_panic>
f010288f:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102896:	39 d0                	cmp    %edx,%eax
f0102898:	74 19                	je     f01028b3 <mem_init+0x14dd>
f010289a:	68 1c 6f 10 f0       	push   $0xf0106f1c
f010289f:	68 ff 70 10 f0       	push   $0xf01070ff
f01028a4:	68 aa 03 00 00       	push   $0x3aa
f01028a9:	68 d9 70 10 f0       	push   $0xf01070d9
f01028ae:	e8 8d d7 ff ff       	call   f0100040 <_panic>
f01028b3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028b9:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028bf:	75 a7                	jne    f0102868 <mem_init+0x1492>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028c1:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01028c4:	c1 e6 0c             	shl    $0xc,%esi
f01028c7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028cc:	eb 30                	jmp    f01028fe <mem_init+0x1528>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028ce:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028d4:	89 f8                	mov    %edi,%eax
f01028d6:	e8 11 e2 ff ff       	call   f0100aec <check_va2pa>
f01028db:	39 c3                	cmp    %eax,%ebx
f01028dd:	74 19                	je     f01028f8 <mem_init+0x1522>
f01028df:	68 50 6f 10 f0       	push   $0xf0106f50
f01028e4:	68 ff 70 10 f0       	push   $0xf01070ff
f01028e9:	68 ae 03 00 00       	push   $0x3ae
f01028ee:	68 d9 70 10 f0       	push   $0xf01070d9
f01028f3:	e8 48 d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028fe:	39 f3                	cmp    %esi,%ebx
f0102900:	72 cc                	jb     f01028ce <mem_init+0x14f8>
f0102902:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102907:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010290a:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010290d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102910:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102916:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102919:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010291b:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010291e:	05 00 80 00 20       	add    $0x20008000,%eax
f0102923:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102926:	89 da                	mov    %ebx,%edx
f0102928:	89 f8                	mov    %edi,%eax
f010292a:	e8 bd e1 ff ff       	call   f0100aec <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010292f:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102935:	77 15                	ja     f010294c <mem_init+0x1576>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102937:	56                   	push   %esi
f0102938:	68 68 62 10 f0       	push   $0xf0106268
f010293d:	68 b6 03 00 00       	push   $0x3b6
f0102942:	68 d9 70 10 f0       	push   $0xf01070d9
f0102947:	e8 f4 d6 ff ff       	call   f0100040 <_panic>
f010294c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010294f:	8d 94 0b 00 30 21 f0 	lea    -0xfded000(%ebx,%ecx,1),%edx
f0102956:	39 d0                	cmp    %edx,%eax
f0102958:	74 19                	je     f0102973 <mem_init+0x159d>
f010295a:	68 78 6f 10 f0       	push   $0xf0106f78
f010295f:	68 ff 70 10 f0       	push   $0xf01070ff
f0102964:	68 b6 03 00 00       	push   $0x3b6
f0102969:	68 d9 70 10 f0       	push   $0xf01070d9
f010296e:	e8 cd d6 ff ff       	call   f0100040 <_panic>
f0102973:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102979:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f010297c:	75 a8                	jne    f0102926 <mem_init+0x1550>
f010297e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102981:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102987:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010298a:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010298c:	89 da                	mov    %ebx,%edx
f010298e:	89 f8                	mov    %edi,%eax
f0102990:	e8 57 e1 ff ff       	call   f0100aec <check_va2pa>
f0102995:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102998:	74 19                	je     f01029b3 <mem_init+0x15dd>
f010299a:	68 c0 6f 10 f0       	push   $0xf0106fc0
f010299f:	68 ff 70 10 f0       	push   $0xf01070ff
f01029a4:	68 b8 03 00 00       	push   $0x3b8
f01029a9:	68 d9 70 10 f0       	push   $0xf01070d9
f01029ae:	e8 8d d6 ff ff       	call   f0100040 <_panic>
f01029b3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029b9:	39 f3                	cmp    %esi,%ebx
f01029bb:	75 cf                	jne    f010298c <mem_init+0x15b6>
f01029bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01029c0:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01029c7:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01029ce:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01029d4:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f01029d9:	39 f0                	cmp    %esi,%eax
f01029db:	0f 85 2c ff ff ff    	jne    f010290d <mem_init+0x1537>
f01029e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01029e6:	eb 2a                	jmp    f0102a12 <mem_init+0x163c>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029e8:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01029ee:	83 fa 04             	cmp    $0x4,%edx
f01029f1:	77 1f                	ja     f0102a12 <mem_init+0x163c>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01029f3:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01029f7:	75 7e                	jne    f0102a77 <mem_init+0x16a1>
f01029f9:	68 cc 73 10 f0       	push   $0xf01073cc
f01029fe:	68 ff 70 10 f0       	push   $0xf01070ff
f0102a03:	68 c3 03 00 00       	push   $0x3c3
f0102a08:	68 d9 70 10 f0       	push   $0xf01070d9
f0102a0d:	e8 2e d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a12:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a17:	76 3f                	jbe    f0102a58 <mem_init+0x1682>
				assert(pgdir[i] & PTE_P);
f0102a19:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a1c:	f6 c2 01             	test   $0x1,%dl
f0102a1f:	75 19                	jne    f0102a3a <mem_init+0x1664>
f0102a21:	68 cc 73 10 f0       	push   $0xf01073cc
f0102a26:	68 ff 70 10 f0       	push   $0xf01070ff
f0102a2b:	68 c7 03 00 00       	push   $0x3c7
f0102a30:	68 d9 70 10 f0       	push   $0xf01070d9
f0102a35:	e8 06 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a3a:	f6 c2 02             	test   $0x2,%dl
f0102a3d:	75 38                	jne    f0102a77 <mem_init+0x16a1>
f0102a3f:	68 dd 73 10 f0       	push   $0xf01073dd
f0102a44:	68 ff 70 10 f0       	push   $0xf01070ff
f0102a49:	68 c8 03 00 00       	push   $0x3c8
f0102a4e:	68 d9 70 10 f0       	push   $0xf01070d9
f0102a53:	e8 e8 d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a58:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a5c:	74 19                	je     f0102a77 <mem_init+0x16a1>
f0102a5e:	68 ee 73 10 f0       	push   $0xf01073ee
f0102a63:	68 ff 70 10 f0       	push   $0xf01070ff
f0102a68:	68 ca 03 00 00       	push   $0x3ca
f0102a6d:	68 d9 70 10 f0       	push   $0xf01070d9
f0102a72:	e8 c9 d5 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a77:	83 c0 01             	add    $0x1,%eax
f0102a7a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a7f:	0f 86 63 ff ff ff    	jbe    f01029e8 <mem_init+0x1612>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a85:	83 ec 0c             	sub    $0xc,%esp
f0102a88:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102a8d:	e8 4f 0d 00 00       	call   f01037e1 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a92:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a97:	83 c4 10             	add    $0x10,%esp
f0102a9a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a9f:	77 15                	ja     f0102ab6 <mem_init+0x16e0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aa1:	50                   	push   %eax
f0102aa2:	68 68 62 10 f0       	push   $0xf0106268
f0102aa7:	68 f1 00 00 00       	push   $0xf1
f0102aac:	68 d9 70 10 f0       	push   $0xf01070d9
f0102ab1:	e8 8a d5 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ab6:	05 00 00 00 10       	add    $0x10000000,%eax
f0102abb:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102abe:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ac3:	e8 88 e0 ff ff       	call   f0100b50 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102ac8:	0f 20 c0             	mov    %cr0,%eax
f0102acb:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102ace:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102ad3:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ad6:	83 ec 0c             	sub    $0xc,%esp
f0102ad9:	6a 00                	push   $0x0
f0102adb:	e8 e5 e4 ff ff       	call   f0100fc5 <page_alloc>
f0102ae0:	89 c3                	mov    %eax,%ebx
f0102ae2:	83 c4 10             	add    $0x10,%esp
f0102ae5:	85 c0                	test   %eax,%eax
f0102ae7:	75 19                	jne    f0102b02 <mem_init+0x172c>
f0102ae9:	68 d8 71 10 f0       	push   $0xf01071d8
f0102aee:	68 ff 70 10 f0       	push   $0xf01070ff
f0102af3:	68 a2 04 00 00       	push   $0x4a2
f0102af8:	68 d9 70 10 f0       	push   $0xf01070d9
f0102afd:	e8 3e d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b02:	83 ec 0c             	sub    $0xc,%esp
f0102b05:	6a 00                	push   $0x0
f0102b07:	e8 b9 e4 ff ff       	call   f0100fc5 <page_alloc>
f0102b0c:	89 c7                	mov    %eax,%edi
f0102b0e:	83 c4 10             	add    $0x10,%esp
f0102b11:	85 c0                	test   %eax,%eax
f0102b13:	75 19                	jne    f0102b2e <mem_init+0x1758>
f0102b15:	68 ee 71 10 f0       	push   $0xf01071ee
f0102b1a:	68 ff 70 10 f0       	push   $0xf01070ff
f0102b1f:	68 a3 04 00 00       	push   $0x4a3
f0102b24:	68 d9 70 10 f0       	push   $0xf01070d9
f0102b29:	e8 12 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b2e:	83 ec 0c             	sub    $0xc,%esp
f0102b31:	6a 00                	push   $0x0
f0102b33:	e8 8d e4 ff ff       	call   f0100fc5 <page_alloc>
f0102b38:	89 c6                	mov    %eax,%esi
f0102b3a:	83 c4 10             	add    $0x10,%esp
f0102b3d:	85 c0                	test   %eax,%eax
f0102b3f:	75 19                	jne    f0102b5a <mem_init+0x1784>
f0102b41:	68 04 72 10 f0       	push   $0xf0107204
f0102b46:	68 ff 70 10 f0       	push   $0xf01070ff
f0102b4b:	68 a4 04 00 00       	push   $0x4a4
f0102b50:	68 d9 70 10 f0       	push   $0xf01070d9
f0102b55:	e8 e6 d4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102b5a:	83 ec 0c             	sub    $0xc,%esp
f0102b5d:	53                   	push   %ebx
f0102b5e:	e8 d2 e4 ff ff       	call   f0101035 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b63:	89 f8                	mov    %edi,%eax
f0102b65:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102b6b:	c1 f8 03             	sar    $0x3,%eax
f0102b6e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b71:	89 c2                	mov    %eax,%edx
f0102b73:	c1 ea 0c             	shr    $0xc,%edx
f0102b76:	83 c4 10             	add    $0x10,%esp
f0102b79:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102b7f:	72 12                	jb     f0102b93 <mem_init+0x17bd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b81:	50                   	push   %eax
f0102b82:	68 44 62 10 f0       	push   $0xf0106244
f0102b87:	6a 58                	push   $0x58
f0102b89:	68 e5 70 10 f0       	push   $0xf01070e5
f0102b8e:	e8 ad d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b93:	83 ec 04             	sub    $0x4,%esp
f0102b96:	68 00 10 00 00       	push   $0x1000
f0102b9b:	6a 01                	push   $0x1
f0102b9d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ba2:	50                   	push   %eax
f0102ba3:	e8 b6 29 00 00       	call   f010555e <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ba8:	89 f0                	mov    %esi,%eax
f0102baa:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102bb0:	c1 f8 03             	sar    $0x3,%eax
f0102bb3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb6:	89 c2                	mov    %eax,%edx
f0102bb8:	c1 ea 0c             	shr    $0xc,%edx
f0102bbb:	83 c4 10             	add    $0x10,%esp
f0102bbe:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102bc4:	72 12                	jb     f0102bd8 <mem_init+0x1802>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bc6:	50                   	push   %eax
f0102bc7:	68 44 62 10 f0       	push   $0xf0106244
f0102bcc:	6a 58                	push   $0x58
f0102bce:	68 e5 70 10 f0       	push   $0xf01070e5
f0102bd3:	e8 68 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102bd8:	83 ec 04             	sub    $0x4,%esp
f0102bdb:	68 00 10 00 00       	push   $0x1000
f0102be0:	6a 02                	push   $0x2
f0102be2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102be7:	50                   	push   %eax
f0102be8:	e8 71 29 00 00       	call   f010555e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bed:	6a 02                	push   $0x2
f0102bef:	68 00 10 00 00       	push   $0x1000
f0102bf4:	57                   	push   %edi
f0102bf5:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102bfb:	e8 e1 e6 ff ff       	call   f01012e1 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c00:	83 c4 20             	add    $0x20,%esp
f0102c03:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c08:	74 19                	je     f0102c23 <mem_init+0x184d>
f0102c0a:	68 d5 72 10 f0       	push   $0xf01072d5
f0102c0f:	68 ff 70 10 f0       	push   $0xf01070ff
f0102c14:	68 a9 04 00 00       	push   $0x4a9
f0102c19:	68 d9 70 10 f0       	push   $0xf01070d9
f0102c1e:	e8 1d d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c23:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c2a:	01 01 01 
f0102c2d:	74 19                	je     f0102c48 <mem_init+0x1872>
f0102c2f:	68 04 70 10 f0       	push   $0xf0107004
f0102c34:	68 ff 70 10 f0       	push   $0xf01070ff
f0102c39:	68 aa 04 00 00       	push   $0x4aa
f0102c3e:	68 d9 70 10 f0       	push   $0xf01070d9
f0102c43:	e8 f8 d3 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c48:	6a 02                	push   $0x2
f0102c4a:	68 00 10 00 00       	push   $0x1000
f0102c4f:	56                   	push   %esi
f0102c50:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102c56:	e8 86 e6 ff ff       	call   f01012e1 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c5b:	83 c4 10             	add    $0x10,%esp
f0102c5e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c65:	02 02 02 
f0102c68:	74 19                	je     f0102c83 <mem_init+0x18ad>
f0102c6a:	68 28 70 10 f0       	push   $0xf0107028
f0102c6f:	68 ff 70 10 f0       	push   $0xf01070ff
f0102c74:	68 ac 04 00 00       	push   $0x4ac
f0102c79:	68 d9 70 10 f0       	push   $0xf01070d9
f0102c7e:	e8 bd d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c83:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c88:	74 19                	je     f0102ca3 <mem_init+0x18cd>
f0102c8a:	68 f7 72 10 f0       	push   $0xf01072f7
f0102c8f:	68 ff 70 10 f0       	push   $0xf01070ff
f0102c94:	68 ad 04 00 00       	push   $0x4ad
f0102c99:	68 d9 70 10 f0       	push   $0xf01070d9
f0102c9e:	e8 9d d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102ca3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ca8:	74 19                	je     f0102cc3 <mem_init+0x18ed>
f0102caa:	68 61 73 10 f0       	push   $0xf0107361
f0102caf:	68 ff 70 10 f0       	push   $0xf01070ff
f0102cb4:	68 ae 04 00 00       	push   $0x4ae
f0102cb9:	68 d9 70 10 f0       	push   $0xf01070d9
f0102cbe:	e8 7d d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cc3:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cca:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ccd:	89 f0                	mov    %esi,%eax
f0102ccf:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102cd5:	c1 f8 03             	sar    $0x3,%eax
f0102cd8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cdb:	89 c2                	mov    %eax,%edx
f0102cdd:	c1 ea 0c             	shr    $0xc,%edx
f0102ce0:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102ce6:	72 12                	jb     f0102cfa <mem_init+0x1924>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ce8:	50                   	push   %eax
f0102ce9:	68 44 62 10 f0       	push   $0xf0106244
f0102cee:	6a 58                	push   $0x58
f0102cf0:	68 e5 70 10 f0       	push   $0xf01070e5
f0102cf5:	e8 46 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cfa:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d01:	03 03 03 
f0102d04:	74 19                	je     f0102d1f <mem_init+0x1949>
f0102d06:	68 4c 70 10 f0       	push   $0xf010704c
f0102d0b:	68 ff 70 10 f0       	push   $0xf01070ff
f0102d10:	68 b0 04 00 00       	push   $0x4b0
f0102d15:	68 d9 70 10 f0       	push   $0xf01070d9
f0102d1a:	e8 21 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d1f:	83 ec 08             	sub    $0x8,%esp
f0102d22:	68 00 10 00 00       	push   $0x1000
f0102d27:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102d2d:	e8 69 e5 ff ff       	call   f010129b <page_remove>
	assert(pp2->pp_ref == 0);
f0102d32:	83 c4 10             	add    $0x10,%esp
f0102d35:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d3a:	74 19                	je     f0102d55 <mem_init+0x197f>
f0102d3c:	68 2f 73 10 f0       	push   $0xf010732f
f0102d41:	68 ff 70 10 f0       	push   $0xf01070ff
f0102d46:	68 b2 04 00 00       	push   $0x4b2
f0102d4b:	68 d9 70 10 f0       	push   $0xf01070d9
f0102d50:	e8 eb d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d55:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102d5b:	8b 11                	mov    (%ecx),%edx
f0102d5d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d63:	89 d8                	mov    %ebx,%eax
f0102d65:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102d6b:	c1 f8 03             	sar    $0x3,%eax
f0102d6e:	c1 e0 0c             	shl    $0xc,%eax
f0102d71:	39 c2                	cmp    %eax,%edx
f0102d73:	74 19                	je     f0102d8e <mem_init+0x19b8>
f0102d75:	68 d4 69 10 f0       	push   $0xf01069d4
f0102d7a:	68 ff 70 10 f0       	push   $0xf01070ff
f0102d7f:	68 b5 04 00 00       	push   $0x4b5
f0102d84:	68 d9 70 10 f0       	push   $0xf01070d9
f0102d89:	e8 b2 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d8e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d94:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d99:	74 19                	je     f0102db4 <mem_init+0x19de>
f0102d9b:	68 e6 72 10 f0       	push   $0xf01072e6
f0102da0:	68 ff 70 10 f0       	push   $0xf01070ff
f0102da5:	68 b7 04 00 00       	push   $0x4b7
f0102daa:	68 d9 70 10 f0       	push   $0xf01070d9
f0102daf:	e8 8c d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102db4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102dba:	83 ec 0c             	sub    $0xc,%esp
f0102dbd:	53                   	push   %ebx
f0102dbe:	e8 72 e2 ff ff       	call   f0101035 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dc3:	c7 04 24 78 70 10 f0 	movl   $0xf0107078,(%esp)
f0102dca:	e8 12 0a 00 00       	call   f01037e1 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102dcf:	83 c4 10             	add    $0x10,%esp
f0102dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dd5:	5b                   	pop    %ebx
f0102dd6:	5e                   	pop    %esi
f0102dd7:	5f                   	pop    %edi
f0102dd8:	5d                   	pop    %ebp
f0102dd9:	c3                   	ret    

f0102dda <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102dda:	55                   	push   %ebp
f0102ddb:	89 e5                	mov    %esp,%ebp
f0102ddd:	57                   	push   %edi
f0102dde:	56                   	push   %esi
f0102ddf:	53                   	push   %ebx
f0102de0:	83 ec 1c             	sub    $0x1c,%esp
f0102de3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102de6:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
    uint32_t start = (uint32_t)ROUNDDOWN((char *)va, PGSIZE);
f0102de9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102dec:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end = (uint32_t)ROUNDUP((char *)va+len, PGSIZE);
f0102df2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102df5:	03 45 10             	add    0x10(%ebp),%eax
f0102df8:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102dfd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(; start < end; start += PGSIZE) {
f0102e05:	eb 43                	jmp    f0102e4a <user_mem_check+0x70>
       	pte_t *pte = pgdir_walk(env->env_pgdir, (void*)start, 0);
f0102e07:	83 ec 04             	sub    $0x4,%esp
f0102e0a:	6a 00                	push   $0x0
f0102e0c:	53                   	push   %ebx
f0102e0d:	ff 77 60             	pushl  0x60(%edi)
f0102e10:	e8 82 e2 ff ff       	call   f0101097 <pgdir_walk>
        if((start >= ULIM) || (pte == NULL) || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102e15:	83 c4 10             	add    $0x10,%esp
f0102e18:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e1e:	77 10                	ja     f0102e30 <user_mem_check+0x56>
f0102e20:	85 c0                	test   %eax,%eax
f0102e22:	74 0c                	je     f0102e30 <user_mem_check+0x56>
f0102e24:	8b 00                	mov    (%eax),%eax
f0102e26:	a8 01                	test   $0x1,%al
f0102e28:	74 06                	je     f0102e30 <user_mem_check+0x56>
f0102e2a:	21 f0                	and    %esi,%eax
f0102e2c:	39 c6                	cmp    %eax,%esi
f0102e2e:	74 14                	je     f0102e44 <user_mem_check+0x6a>
            user_mem_check_addr = (start < (uint32_t)va ? (uint32_t)va : start);
f0102e30:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e33:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102e37:	89 1d 3c 12 21 f0    	mov    %ebx,0xf021123c
            return -E_FAULT;
f0102e3d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e42:	eb 10                	jmp    f0102e54 <user_mem_check+0x7a>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
    uint32_t start = (uint32_t)ROUNDDOWN((char *)va, PGSIZE);
    uint32_t end = (uint32_t)ROUNDUP((char *)va+len, PGSIZE);
    for(; start < end; start += PGSIZE) {
f0102e44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e4a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e4d:	72 b8                	jb     f0102e07 <user_mem_check+0x2d>
        if((start >= ULIM) || (pte == NULL) || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
            user_mem_check_addr = (start < (uint32_t)va ? (uint32_t)va : start);
            return -E_FAULT;
        }
    }
	return 0;
f0102e4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e57:	5b                   	pop    %ebx
f0102e58:	5e                   	pop    %esi
f0102e59:	5f                   	pop    %edi
f0102e5a:	5d                   	pop    %ebp
f0102e5b:	c3                   	ret    

f0102e5c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e5c:	55                   	push   %ebp
f0102e5d:	89 e5                	mov    %esp,%ebp
f0102e5f:	53                   	push   %ebx
f0102e60:	83 ec 04             	sub    $0x4,%esp
f0102e63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e66:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e69:	83 c8 04             	or     $0x4,%eax
f0102e6c:	50                   	push   %eax
f0102e6d:	ff 75 10             	pushl  0x10(%ebp)
f0102e70:	ff 75 0c             	pushl  0xc(%ebp)
f0102e73:	53                   	push   %ebx
f0102e74:	e8 61 ff ff ff       	call   f0102dda <user_mem_check>
f0102e79:	83 c4 10             	add    $0x10,%esp
f0102e7c:	85 c0                	test   %eax,%eax
f0102e7e:	79 21                	jns    f0102ea1 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e80:	83 ec 04             	sub    $0x4,%esp
f0102e83:	ff 35 3c 12 21 f0    	pushl  0xf021123c
f0102e89:	ff 73 48             	pushl  0x48(%ebx)
f0102e8c:	68 a4 70 10 f0       	push   $0xf01070a4
f0102e91:	e8 4b 09 00 00       	call   f01037e1 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e96:	89 1c 24             	mov    %ebx,(%esp)
f0102e99:	e8 53 06 00 00       	call   f01034f1 <env_destroy>
f0102e9e:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ea4:	c9                   	leave  
f0102ea5:	c3                   	ret    

f0102ea6 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ea6:	55                   	push   %ebp
f0102ea7:	89 e5                	mov    %esp,%ebp
f0102ea9:	57                   	push   %edi
f0102eaa:	56                   	push   %esi
f0102eab:	53                   	push   %ebx
f0102eac:	83 ec 0c             	sub    $0xc,%esp
f0102eaf:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	    void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
f0102eb1:	89 d3                	mov    %edx,%ebx
f0102eb3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	    void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0102eb9:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102ec0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	    struct PageInfo *p = NULL;
	    void* i;
	    int r;

	    for(i = start; i < end; i += PGSIZE){
f0102ec6:	eb 58                	jmp    f0102f20 <region_alloc+0x7a>
		p = page_alloc(0);
f0102ec8:	83 ec 0c             	sub    $0xc,%esp
f0102ecb:	6a 00                	push   $0x0
f0102ecd:	e8 f3 e0 ff ff       	call   f0100fc5 <page_alloc>
		if(p == NULL)
f0102ed2:	83 c4 10             	add    $0x10,%esp
f0102ed5:	85 c0                	test   %eax,%eax
f0102ed7:	75 17                	jne    f0102ef0 <region_alloc+0x4a>
		   panic(" region alloc failed: allocation failed.\n");
f0102ed9:	83 ec 04             	sub    $0x4,%esp
f0102edc:	68 fc 73 10 f0       	push   $0xf01073fc
f0102ee1:	68 34 01 00 00       	push   $0x134
f0102ee6:	68 b8 74 10 f0       	push   $0xf01074b8
f0102eeb:	e8 50 d1 ff ff       	call   f0100040 <_panic>

		r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0102ef0:	6a 06                	push   $0x6
f0102ef2:	53                   	push   %ebx
f0102ef3:	50                   	push   %eax
f0102ef4:	ff 77 60             	pushl  0x60(%edi)
f0102ef7:	e8 e5 e3 ff ff       	call   f01012e1 <page_insert>
		if(r != 0)
f0102efc:	83 c4 10             	add    $0x10,%esp
f0102eff:	85 c0                	test   %eax,%eax
f0102f01:	74 17                	je     f0102f1a <region_alloc+0x74>
		    panic("region alloc failed.\n");
f0102f03:	83 ec 04             	sub    $0x4,%esp
f0102f06:	68 c3 74 10 f0       	push   $0xf01074c3
f0102f0b:	68 38 01 00 00       	push   $0x138
f0102f10:	68 b8 74 10 f0       	push   $0xf01074b8
f0102f15:	e8 26 d1 ff ff       	call   f0100040 <_panic>
	    void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
	    struct PageInfo *p = NULL;
	    void* i;
	    int r;

	    for(i = start; i < end; i += PGSIZE){
f0102f1a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f20:	39 f3                	cmp    %esi,%ebx
f0102f22:	72 a4                	jb     f0102ec8 <region_alloc+0x22>

		r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
		if(r != 0)
		    panic("region alloc failed.\n");
	    }
}
f0102f24:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f27:	5b                   	pop    %ebx
f0102f28:	5e                   	pop    %esi
f0102f29:	5f                   	pop    %edi
f0102f2a:	5d                   	pop    %ebp
f0102f2b:	c3                   	ret    

f0102f2c <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f2c:	55                   	push   %ebp
f0102f2d:	89 e5                	mov    %esp,%ebp
f0102f2f:	56                   	push   %esi
f0102f30:	53                   	push   %ebx
f0102f31:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f34:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f37:	85 c0                	test   %eax,%eax
f0102f39:	75 1a                	jne    f0102f55 <envid2env+0x29>
		*env_store = curenv;
f0102f3b:	e8 3e 2c 00 00       	call   f0105b7e <cpunum>
f0102f40:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f43:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102f49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f4c:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f53:	eb 70                	jmp    f0102fc5 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f55:	89 c3                	mov    %eax,%ebx
f0102f57:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102f5d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102f60:	03 1d 48 12 21 f0    	add    0xf0211248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f66:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f6a:	74 05                	je     f0102f71 <envid2env+0x45>
f0102f6c:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102f6f:	74 10                	je     f0102f81 <envid2env+0x55>
		*env_store = 0;
f0102f71:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f7a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f7f:	eb 44                	jmp    f0102fc5 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f81:	84 d2                	test   %dl,%dl
f0102f83:	74 36                	je     f0102fbb <envid2env+0x8f>
f0102f85:	e8 f4 2b 00 00       	call   f0105b7e <cpunum>
f0102f8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f8d:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f0102f93:	74 26                	je     f0102fbb <envid2env+0x8f>
f0102f95:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f98:	e8 e1 2b 00 00       	call   f0105b7e <cpunum>
f0102f9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fa0:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102fa6:	3b 70 48             	cmp    0x48(%eax),%esi
f0102fa9:	74 10                	je     f0102fbb <envid2env+0x8f>
		*env_store = 0;
f0102fab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fb4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fb9:	eb 0a                	jmp    f0102fc5 <envid2env+0x99>
	}

	*env_store = e;
f0102fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fbe:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102fc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fc5:	5b                   	pop    %ebx
f0102fc6:	5e                   	pop    %esi
f0102fc7:	5d                   	pop    %ebp
f0102fc8:	c3                   	ret    

f0102fc9 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102fc9:	55                   	push   %ebp
f0102fca:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102fcc:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102fd1:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102fd4:	b8 23 00 00 00       	mov    $0x23,%eax
f0102fd9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102fdb:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102fdd:	b8 10 00 00 00       	mov    $0x10,%eax
f0102fe2:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102fe4:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102fe6:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102fe8:	ea ef 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102fef
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102fef:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ff4:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102ff7:	5d                   	pop    %ebp
f0102ff8:	c3                   	ret    

f0102ff9 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102ff9:	55                   	push   %ebp
f0102ffa:	89 e5                	mov    %esp,%ebp
f0102ffc:	56                   	push   %esi
f0102ffd:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for (i=NENV-1; i>=0; i--){
		envs[i].env_id = 0;
f0102ffe:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
f0103004:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010300a:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010300d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103012:	89 c1                	mov    %eax,%ecx
f0103014:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f010301b:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103022:	89 50 44             	mov    %edx,0x44(%eax)
f0103025:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103028:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for (i=NENV-1; i>=0; i--){
f010302a:	39 d8                	cmp    %ebx,%eax
f010302c:	75 e4                	jne    f0103012 <env_init+0x19>
f010302e:	89 35 4c 12 21 f0    	mov    %esi,0xf021124c
		envs[i].env_status = ENV_FREE;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103034:	e8 90 ff ff ff       	call   f0102fc9 <env_init_percpu>
}
f0103039:	5b                   	pop    %ebx
f010303a:	5e                   	pop    %esi
f010303b:	5d                   	pop    %ebp
f010303c:	c3                   	ret    

f010303d <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010303d:	55                   	push   %ebp
f010303e:	89 e5                	mov    %esp,%ebp
f0103040:	53                   	push   %ebx
f0103041:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103044:	8b 1d 4c 12 21 f0    	mov    0xf021124c,%ebx
f010304a:	85 db                	test   %ebx,%ebx
f010304c:	0f 84 87 01 00 00    	je     f01031d9 <env_alloc+0x19c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103052:	83 ec 0c             	sub    $0xc,%esp
f0103055:	6a 01                	push   $0x1
f0103057:	e8 69 df ff ff       	call   f0100fc5 <page_alloc>
f010305c:	83 c4 10             	add    $0x10,%esp
f010305f:	85 c0                	test   %eax,%eax
f0103061:	0f 84 79 01 00 00    	je     f01031e0 <env_alloc+0x1a3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103067:	89 c2                	mov    %eax,%edx
f0103069:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010306f:	c1 fa 03             	sar    $0x3,%edx
f0103072:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103075:	89 d1                	mov    %edx,%ecx
f0103077:	c1 e9 0c             	shr    $0xc,%ecx
f010307a:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0103080:	72 12                	jb     f0103094 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103082:	52                   	push   %edx
f0103083:	68 44 62 10 f0       	push   $0xf0106244
f0103088:	6a 58                	push   $0x58
f010308a:	68 e5 70 10 f0       	push   $0xf01070e5
f010308f:	e8 ac cf ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
f0103094:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010309a:	89 53 60             	mov    %edx,0x60(%ebx)
     	p->pp_ref++;
f010309d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01030a2:	b8 00 00 00 00       	mov    $0x0,%eax

     	//Map the directory below UTOP.
    	 for (i = 0; i < PDX(UTOP); i++)
         	e->env_pgdir[i] = 0;        
f01030a7:	8b 53 60             	mov    0x60(%ebx),%edx
f01030aa:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01030b1:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
     	p->pp_ref++;

     	//Map the directory below UTOP.
    	 for (i = 0; i < PDX(UTOP); i++)
f01030b4:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01030b9:	75 ec                	jne    f01030a7 <env_alloc+0x6a>
         	e->env_pgdir[i] = 0;        

     	//Map the directory above UTOP
     	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
     	    e->env_pgdir[i] = kern_pgdir[i];
f01030bb:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f01030c1:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01030c4:	8b 53 60             	mov    0x60(%ebx),%edx
f01030c7:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01030ca:	83 c0 04             	add    $0x4,%eax
     	//Map the directory below UTOP.
    	 for (i = 0; i < PDX(UTOP); i++)
         	e->env_pgdir[i] = 0;        

     	//Map the directory above UTOP
     	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f01030cd:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01030d2:	75 e7                	jne    f01030bb <env_alloc+0x7e>
     	    e->env_pgdir[i] = kern_pgdir[i];
   	}
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01030d4:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030d7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030dc:	77 15                	ja     f01030f3 <env_alloc+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030de:	50                   	push   %eax
f01030df:	68 68 62 10 f0       	push   $0xf0106268
f01030e4:	68 cd 00 00 00       	push   $0xcd
f01030e9:	68 b8 74 10 f0       	push   $0xf01074b8
f01030ee:	e8 4d cf ff ff       	call   f0100040 <_panic>
f01030f3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030f9:	83 ca 05             	or     $0x5,%edx
f01030fc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103102:	8b 43 48             	mov    0x48(%ebx),%eax
f0103105:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010310a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010310f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103114:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103117:	89 da                	mov    %ebx,%edx
f0103119:	2b 15 48 12 21 f0    	sub    0xf0211248,%edx
f010311f:	c1 fa 02             	sar    $0x2,%edx
f0103122:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103128:	09 d0                	or     %edx,%eax
f010312a:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010312d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103130:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103133:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010313a:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103141:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103148:	83 ec 04             	sub    $0x4,%esp
f010314b:	6a 44                	push   $0x44
f010314d:	6a 00                	push   $0x0
f010314f:	53                   	push   %ebx
f0103150:	e8 09 24 00 00       	call   f010555e <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103155:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010315b:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103161:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103167:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010316e:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103174:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010317b:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103182:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103186:	8b 43 44             	mov    0x44(%ebx),%eax
f0103189:	a3 4c 12 21 f0       	mov    %eax,0xf021124c
	*newenv_store = e;
f010318e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103191:	89 18                	mov    %ebx,(%eax)

    cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103193:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103196:	e8 e3 29 00 00       	call   f0105b7e <cpunum>
f010319b:	6b c0 74             	imul   $0x74,%eax,%eax
f010319e:	83 c4 10             	add    $0x10,%esp
f01031a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01031a6:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01031ad:	74 11                	je     f01031c0 <env_alloc+0x183>
f01031af:	e8 ca 29 00 00       	call   f0105b7e <cpunum>
f01031b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01031b7:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01031bd:	8b 50 48             	mov    0x48(%eax),%edx
f01031c0:	83 ec 04             	sub    $0x4,%esp
f01031c3:	53                   	push   %ebx
f01031c4:	52                   	push   %edx
f01031c5:	68 d9 74 10 f0       	push   $0xf01074d9
f01031ca:	e8 12 06 00 00       	call   f01037e1 <cprintf>
	return 0;
f01031cf:	83 c4 10             	add    $0x10,%esp
f01031d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01031d7:	eb 0c                	jmp    f01031e5 <env_alloc+0x1a8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01031d9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01031de:	eb 05                	jmp    f01031e5 <env_alloc+0x1a8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01031e0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

    cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01031e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031e8:	c9                   	leave  
f01031e9:	c3                   	ret    

f01031ea <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01031ea:	55                   	push   %ebp
f01031eb:	89 e5                	mov    %esp,%ebp
f01031ed:	57                   	push   %edi
f01031ee:	56                   	push   %esi
f01031ef:	53                   	push   %ebx
f01031f0:	83 ec 34             	sub    $0x34,%esp
f01031f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
    struct Env *e;
    int rc;
    if ((rc = env_alloc(&e, 0)) != 0)
f01031f6:	6a 00                	push   $0x0
f01031f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01031fb:	50                   	push   %eax
f01031fc:	e8 3c fe ff ff       	call   f010303d <env_alloc>
f0103201:	83 c4 10             	add    $0x10,%esp
f0103204:	85 c0                	test   %eax,%eax
f0103206:	74 17                	je     f010321f <env_create+0x35>
      panic("env_create failed: env_alloc failed.\n");
f0103208:	83 ec 04             	sub    $0x4,%esp
f010320b:	68 28 74 10 f0       	push   $0xf0107428
f0103210:	68 9f 01 00 00       	push   $0x19f
f0103215:	68 b8 74 10 f0       	push   $0xf01074b8
f010321a:	e8 21 ce ff ff       	call   f0100040 <_panic>

     load_icode(e, binary);
f010321f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103222:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf* header = (struct Elf*)binary;

	if (header->e_magic != ELF_MAGIC) 
f0103225:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010322b:	74 17                	je     f0103244 <env_create+0x5a>
		panic("load_icode failed: The binary we load is not elf.\n");
f010322d:	83 ec 04             	sub    $0x4,%esp
f0103230:	68 50 74 10 f0       	push   $0xf0107450
f0103235:	68 75 01 00 00       	push   $0x175
f010323a:	68 b8 74 10 f0       	push   $0xf01074b8
f010323f:	e8 fc cd ff ff       	call   f0100040 <_panic>

	if (header->e_entry == 0)
f0103244:	8b 47 18             	mov    0x18(%edi),%eax
f0103247:	85 c0                	test   %eax,%eax
f0103249:	75 17                	jne    f0103262 <env_create+0x78>
		panic("load_icode failed: The elf file can't be excuterd.\n");
f010324b:	83 ec 04             	sub    $0x4,%esp
f010324e:	68 84 74 10 f0       	push   $0xf0107484
f0103253:	68 78 01 00 00       	push   $0x178
f0103258:	68 b8 74 10 f0       	push   $0xf01074b8
f010325d:	e8 de cd ff ff       	call   f0100040 <_panic>

	e->env_tf.tf_eip = header->e_entry;
f0103262:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103265:	89 41 30             	mov    %eax,0x30(%ecx)

	lcr3(PADDR(e->env_pgdir));   //load user pgdir
f0103268:	8b 41 60             	mov    0x60(%ecx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010326b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103270:	77 15                	ja     f0103287 <env_create+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103272:	50                   	push   %eax
f0103273:	68 68 62 10 f0       	push   $0xf0106268
f0103278:	68 7c 01 00 00       	push   $0x17c
f010327d:	68 b8 74 10 f0       	push   $0xf01074b8
f0103282:	e8 b9 cd ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103287:	05 00 00 00 10       	add    $0x10000000,%eax
f010328c:	0f 22 d8             	mov    %eax,%cr3

	struct Proghdr *ph, *eph;
	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f010328f:	89 fb                	mov    %edi,%ebx
f0103291:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + header->e_phnum;
f0103294:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103298:	c1 e6 05             	shl    $0x5,%esi
f010329b:	01 de                	add    %ebx,%esi
f010329d:	eb 44                	jmp    f01032e3 <env_create+0xf9>
	for(; ph < eph; ph++) {
		if(ph->p_type == ELF_PROG_LOAD) {
f010329f:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032a2:	75 3c                	jne    f01032e0 <env_create+0xf6>
		    if(ph->p_memsz - ph->p_filesz < 0) 
		        panic("load icode failed : p_memsz < p_filesz.\n");

		    region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01032a4:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032a7:	8b 53 08             	mov    0x8(%ebx),%edx
f01032aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032ad:	e8 f4 fb ff ff       	call   f0102ea6 <region_alloc>
		    memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01032b2:	83 ec 04             	sub    $0x4,%esp
f01032b5:	ff 73 10             	pushl  0x10(%ebx)
f01032b8:	89 f8                	mov    %edi,%eax
f01032ba:	03 43 04             	add    0x4(%ebx),%eax
f01032bd:	50                   	push   %eax
f01032be:	ff 73 08             	pushl  0x8(%ebx)
f01032c1:	e8 e5 22 00 00       	call   f01055ab <memmove>
		    memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01032c6:	8b 43 10             	mov    0x10(%ebx),%eax
f01032c9:	83 c4 0c             	add    $0xc,%esp
f01032cc:	8b 53 14             	mov    0x14(%ebx),%edx
f01032cf:	29 c2                	sub    %eax,%edx
f01032d1:	52                   	push   %edx
f01032d2:	6a 00                	push   $0x0
f01032d4:	03 43 08             	add    0x8(%ebx),%eax
f01032d7:	50                   	push   %eax
f01032d8:	e8 81 22 00 00       	call   f010555e <memset>
f01032dd:	83 c4 10             	add    $0x10,%esp
	lcr3(PADDR(e->env_pgdir));   //load user pgdir

	struct Proghdr *ph, *eph;
	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
	eph = ph + header->e_phnum;
	for(; ph < eph; ph++) {
f01032e0:	83 c3 20             	add    $0x20,%ebx
f01032e3:	39 de                	cmp    %ebx,%esi
f01032e5:	77 b8                	ja     f010329f <env_create+0xb5>
		    memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
		}
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f01032e7:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01032ec:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01032f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032f4:	e8 ad fb ff ff       	call   f0102ea6 <region_alloc>
    int rc;
    if ((rc = env_alloc(&e, 0)) != 0)
      panic("env_create failed: env_alloc failed.\n");

     load_icode(e, binary);
     e->env_type = type;
f01032f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01032ff:	89 78 50             	mov    %edi,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    if (type == ENV_TYPE_FS) {
f0103302:	83 ff 01             	cmp    $0x1,%edi
f0103305:	75 07                	jne    f010330e <env_create+0x124>
            e->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103307:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    }

}
f010330e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103311:	5b                   	pop    %ebx
f0103312:	5e                   	pop    %esi
f0103313:	5f                   	pop    %edi
f0103314:	5d                   	pop    %ebp
f0103315:	c3                   	ret    

f0103316 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103316:	55                   	push   %ebp
f0103317:	89 e5                	mov    %esp,%ebp
f0103319:	57                   	push   %edi
f010331a:	56                   	push   %esi
f010331b:	53                   	push   %ebx
f010331c:	83 ec 1c             	sub    $0x1c,%esp
f010331f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103322:	e8 57 28 00 00       	call   f0105b7e <cpunum>
f0103327:	6b c0 74             	imul   $0x74,%eax,%eax
f010332a:	39 b8 28 20 21 f0    	cmp    %edi,-0xfdedfd8(%eax)
f0103330:	75 29                	jne    f010335b <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103332:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103337:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010333c:	77 15                	ja     f0103353 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010333e:	50                   	push   %eax
f010333f:	68 68 62 10 f0       	push   $0xf0106268
f0103344:	68 ba 01 00 00       	push   $0x1ba
f0103349:	68 b8 74 10 f0       	push   $0xf01074b8
f010334e:	e8 ed cc ff ff       	call   f0100040 <_panic>
f0103353:	05 00 00 00 10       	add    $0x10000000,%eax
f0103358:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010335b:	8b 5f 48             	mov    0x48(%edi),%ebx
f010335e:	e8 1b 28 00 00       	call   f0105b7e <cpunum>
f0103363:	6b c0 74             	imul   $0x74,%eax,%eax
f0103366:	ba 00 00 00 00       	mov    $0x0,%edx
f010336b:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103372:	74 11                	je     f0103385 <env_free+0x6f>
f0103374:	e8 05 28 00 00       	call   f0105b7e <cpunum>
f0103379:	6b c0 74             	imul   $0x74,%eax,%eax
f010337c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103382:	8b 50 48             	mov    0x48(%eax),%edx
f0103385:	83 ec 04             	sub    $0x4,%esp
f0103388:	53                   	push   %ebx
f0103389:	52                   	push   %edx
f010338a:	68 ee 74 10 f0       	push   $0xf01074ee
f010338f:	e8 4d 04 00 00       	call   f01037e1 <cprintf>
f0103394:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103397:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010339e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01033a1:	89 d0                	mov    %edx,%eax
f01033a3:	c1 e0 02             	shl    $0x2,%eax
f01033a6:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01033a9:	8b 47 60             	mov    0x60(%edi),%eax
f01033ac:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01033af:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01033b5:	0f 84 a8 00 00 00    	je     f0103463 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01033bb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033c1:	89 f0                	mov    %esi,%eax
f01033c3:	c1 e8 0c             	shr    $0xc,%eax
f01033c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01033c9:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f01033cf:	77 15                	ja     f01033e6 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033d1:	56                   	push   %esi
f01033d2:	68 44 62 10 f0       	push   $0xf0106244
f01033d7:	68 c9 01 00 00       	push   $0x1c9
f01033dc:	68 b8 74 10 f0       	push   $0xf01074b8
f01033e1:	e8 5a cc ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033e9:	c1 e0 16             	shl    $0x16,%eax
f01033ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033ef:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01033f4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01033fb:	01 
f01033fc:	74 17                	je     f0103415 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033fe:	83 ec 08             	sub    $0x8,%esp
f0103401:	89 d8                	mov    %ebx,%eax
f0103403:	c1 e0 0c             	shl    $0xc,%eax
f0103406:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103409:	50                   	push   %eax
f010340a:	ff 77 60             	pushl  0x60(%edi)
f010340d:	e8 89 de ff ff       	call   f010129b <page_remove>
f0103412:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103415:	83 c3 01             	add    $0x1,%ebx
f0103418:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010341e:	75 d4                	jne    f01033f4 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103420:	8b 47 60             	mov    0x60(%edi),%eax
f0103423:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103426:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010342d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103430:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0103436:	72 14                	jb     f010344c <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103438:	83 ec 04             	sub    $0x4,%esp
f010343b:	68 a0 68 10 f0       	push   $0xf01068a0
f0103440:	6a 51                	push   $0x51
f0103442:	68 e5 70 10 f0       	push   $0xf01070e5
f0103447:	e8 f4 cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010344c:	83 ec 0c             	sub    $0xc,%esp
f010344f:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0103454:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103457:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010345a:	50                   	push   %eax
f010345b:	e8 10 dc ff ff       	call   f0101070 <page_decref>
f0103460:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103463:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103467:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010346a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010346f:	0f 85 29 ff ff ff    	jne    f010339e <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103475:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103478:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010347d:	77 15                	ja     f0103494 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010347f:	50                   	push   %eax
f0103480:	68 68 62 10 f0       	push   $0xf0106268
f0103485:	68 d7 01 00 00       	push   $0x1d7
f010348a:	68 b8 74 10 f0       	push   $0xf01074b8
f010348f:	e8 ac cb ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103494:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010349b:	05 00 00 00 10       	add    $0x10000000,%eax
f01034a0:	c1 e8 0c             	shr    $0xc,%eax
f01034a3:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01034a9:	72 14                	jb     f01034bf <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01034ab:	83 ec 04             	sub    $0x4,%esp
f01034ae:	68 a0 68 10 f0       	push   $0xf01068a0
f01034b3:	6a 51                	push   $0x51
f01034b5:	68 e5 70 10 f0       	push   $0xf01070e5
f01034ba:	e8 81 cb ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01034bf:	83 ec 0c             	sub    $0xc,%esp
f01034c2:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f01034c8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01034cb:	50                   	push   %eax
f01034cc:	e8 9f db ff ff       	call   f0101070 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01034d1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01034d8:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
f01034dd:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01034e0:	89 3d 4c 12 21 f0    	mov    %edi,0xf021124c
}
f01034e6:	83 c4 10             	add    $0x10,%esp
f01034e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034ec:	5b                   	pop    %ebx
f01034ed:	5e                   	pop    %esi
f01034ee:	5f                   	pop    %edi
f01034ef:	5d                   	pop    %ebp
f01034f0:	c3                   	ret    

f01034f1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01034f1:	55                   	push   %ebp
f01034f2:	89 e5                	mov    %esp,%ebp
f01034f4:	53                   	push   %ebx
f01034f5:	83 ec 04             	sub    $0x4,%esp
f01034f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01034fb:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01034ff:	75 19                	jne    f010351a <env_destroy+0x29>
f0103501:	e8 78 26 00 00       	call   f0105b7e <cpunum>
f0103506:	6b c0 74             	imul   $0x74,%eax,%eax
f0103509:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f010350f:	74 09                	je     f010351a <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103511:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103518:	eb 33                	jmp    f010354d <env_destroy+0x5c>
	}

	env_free(e);
f010351a:	83 ec 0c             	sub    $0xc,%esp
f010351d:	53                   	push   %ebx
f010351e:	e8 f3 fd ff ff       	call   f0103316 <env_free>

	if (curenv == e) {
f0103523:	e8 56 26 00 00       	call   f0105b7e <cpunum>
f0103528:	6b c0 74             	imul   $0x74,%eax,%eax
f010352b:	83 c4 10             	add    $0x10,%esp
f010352e:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f0103534:	75 17                	jne    f010354d <env_destroy+0x5c>
		curenv = NULL;
f0103536:	e8 43 26 00 00       	call   f0105b7e <cpunum>
f010353b:	6b c0 74             	imul   $0x74,%eax,%eax
f010353e:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f0103545:	00 00 00 
		sched_yield();
f0103548:	e8 8f 0e 00 00       	call   f01043dc <sched_yield>
	}
}
f010354d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103550:	c9                   	leave  
f0103551:	c3                   	ret    

f0103552 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103552:	55                   	push   %ebp
f0103553:	89 e5                	mov    %esp,%ebp
f0103555:	53                   	push   %ebx
f0103556:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103559:	e8 20 26 00 00       	call   f0105b7e <cpunum>
f010355e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103561:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f0103567:	e8 12 26 00 00       	call   f0105b7e <cpunum>
f010356c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010356f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103572:	61                   	popa   
f0103573:	07                   	pop    %es
f0103574:	1f                   	pop    %ds
f0103575:	83 c4 08             	add    $0x8,%esp
f0103578:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103579:	83 ec 04             	sub    $0x4,%esp
f010357c:	68 04 75 10 f0       	push   $0xf0107504
f0103581:	68 0e 02 00 00       	push   $0x20e
f0103586:	68 b8 74 10 f0       	push   $0xf01074b8
f010358b:	e8 b0 ca ff ff       	call   f0100040 <_panic>

f0103590 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103590:	55                   	push   %ebp
f0103591:	89 e5                	mov    %esp,%ebp
f0103593:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103596:	e8 e3 25 00 00       	call   f0105b7e <cpunum>
f010359b:	6b c0 74             	imul   $0x74,%eax,%eax
f010359e:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01035a5:	74 29                	je     f01035d0 <env_run+0x40>
f01035a7:	e8 d2 25 00 00       	call   f0105b7e <cpunum>
f01035ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01035af:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01035b5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01035b9:	75 15                	jne    f01035d0 <env_run+0x40>
        	curenv->env_status = ENV_RUNNABLE;
f01035bb:	e8 be 25 00 00       	call   f0105b7e <cpunum>
f01035c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c3:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01035c9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

    	curenv = e;
f01035d0:	e8 a9 25 00 00       	call   f0105b7e <cpunum>
f01035d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035d8:	8b 55 08             	mov    0x8(%ebp),%edx
f01035db:	89 90 28 20 21 f0    	mov    %edx,-0xfdedfd8(%eax)
    	curenv->env_status = ENV_RUNNING;
f01035e1:	e8 98 25 00 00       	call   f0105b7e <cpunum>
f01035e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e9:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01035ef:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    	curenv->env_runs++;
f01035f6:	e8 83 25 00 00       	call   f0105b7e <cpunum>
f01035fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fe:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103604:	83 40 58 01          	addl   $0x1,0x58(%eax)
    	lcr3(PADDR(curenv->env_pgdir));
f0103608:	e8 71 25 00 00       	call   f0105b7e <cpunum>
f010360d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103610:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103616:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103619:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010361e:	77 15                	ja     f0103635 <env_run+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103620:	50                   	push   %eax
f0103621:	68 68 62 10 f0       	push   $0xf0106268
f0103626:	68 32 02 00 00       	push   $0x232
f010362b:	68 b8 74 10 f0       	push   $0xf01074b8
f0103630:	e8 0b ca ff ff       	call   f0100040 <_panic>
f0103635:	05 00 00 00 10       	add    $0x10000000,%eax
f010363a:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010363d:	83 ec 0c             	sub    $0xc,%esp
f0103640:	68 c0 03 12 f0       	push   $0xf01203c0
f0103645:	e8 3f 28 00 00       	call   f0105e89 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010364a:	f3 90                	pause  
        
        unlock_kernel();
    	env_pop_tf(&curenv->env_tf);
f010364c:	e8 2d 25 00 00       	call   f0105b7e <cpunum>
f0103651:	83 c4 04             	add    $0x4,%esp
f0103654:	6b c0 74             	imul   $0x74,%eax,%eax
f0103657:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f010365d:	e8 f0 fe ff ff       	call   f0103552 <env_pop_tf>

f0103662 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103662:	55                   	push   %ebp
f0103663:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103665:	ba 70 00 00 00       	mov    $0x70,%edx
f010366a:	8b 45 08             	mov    0x8(%ebp),%eax
f010366d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010366e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103673:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103674:	0f b6 c0             	movzbl %al,%eax
}
f0103677:	5d                   	pop    %ebp
f0103678:	c3                   	ret    

f0103679 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103679:	55                   	push   %ebp
f010367a:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010367c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103681:	8b 45 08             	mov    0x8(%ebp),%eax
f0103684:	ee                   	out    %al,(%dx)
f0103685:	ba 71 00 00 00       	mov    $0x71,%edx
f010368a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010368d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010368e:	5d                   	pop    %ebp
f010368f:	c3                   	ret    

f0103690 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103690:	55                   	push   %ebp
f0103691:	89 e5                	mov    %esp,%ebp
f0103693:	56                   	push   %esi
f0103694:	53                   	push   %ebx
f0103695:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103698:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f010369e:	80 3d 50 12 21 f0 00 	cmpb   $0x0,0xf0211250
f01036a5:	74 5a                	je     f0103701 <irq_setmask_8259A+0x71>
f01036a7:	89 c6                	mov    %eax,%esi
f01036a9:	ba 21 00 00 00       	mov    $0x21,%edx
f01036ae:	ee                   	out    %al,(%dx)
f01036af:	66 c1 e8 08          	shr    $0x8,%ax
f01036b3:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036b8:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01036b9:	83 ec 0c             	sub    $0xc,%esp
f01036bc:	68 10 75 10 f0       	push   $0xf0107510
f01036c1:	e8 1b 01 00 00       	call   f01037e1 <cprintf>
f01036c6:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01036ce:	0f b7 f6             	movzwl %si,%esi
f01036d1:	f7 d6                	not    %esi
f01036d3:	0f a3 de             	bt     %ebx,%esi
f01036d6:	73 11                	jae    f01036e9 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01036d8:	83 ec 08             	sub    $0x8,%esp
f01036db:	53                   	push   %ebx
f01036dc:	68 ab 79 10 f0       	push   $0xf01079ab
f01036e1:	e8 fb 00 00 00       	call   f01037e1 <cprintf>
f01036e6:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01036e9:	83 c3 01             	add    $0x1,%ebx
f01036ec:	83 fb 10             	cmp    $0x10,%ebx
f01036ef:	75 e2                	jne    f01036d3 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01036f1:	83 ec 0c             	sub    $0xc,%esp
f01036f4:	68 ca 73 10 f0       	push   $0xf01073ca
f01036f9:	e8 e3 00 00 00       	call   f01037e1 <cprintf>
f01036fe:	83 c4 10             	add    $0x10,%esp
}
f0103701:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103704:	5b                   	pop    %ebx
f0103705:	5e                   	pop    %esi
f0103706:	5d                   	pop    %ebp
f0103707:	c3                   	ret    

f0103708 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103708:	c6 05 50 12 21 f0 01 	movb   $0x1,0xf0211250
f010370f:	ba 21 00 00 00       	mov    $0x21,%edx
f0103714:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103719:	ee                   	out    %al,(%dx)
f010371a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010371f:	ee                   	out    %al,(%dx)
f0103720:	ba 20 00 00 00       	mov    $0x20,%edx
f0103725:	b8 11 00 00 00       	mov    $0x11,%eax
f010372a:	ee                   	out    %al,(%dx)
f010372b:	ba 21 00 00 00       	mov    $0x21,%edx
f0103730:	b8 20 00 00 00       	mov    $0x20,%eax
f0103735:	ee                   	out    %al,(%dx)
f0103736:	b8 04 00 00 00       	mov    $0x4,%eax
f010373b:	ee                   	out    %al,(%dx)
f010373c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103741:	ee                   	out    %al,(%dx)
f0103742:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103747:	b8 11 00 00 00       	mov    $0x11,%eax
f010374c:	ee                   	out    %al,(%dx)
f010374d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103752:	b8 28 00 00 00       	mov    $0x28,%eax
f0103757:	ee                   	out    %al,(%dx)
f0103758:	b8 02 00 00 00       	mov    $0x2,%eax
f010375d:	ee                   	out    %al,(%dx)
f010375e:	b8 01 00 00 00       	mov    $0x1,%eax
f0103763:	ee                   	out    %al,(%dx)
f0103764:	ba 20 00 00 00       	mov    $0x20,%edx
f0103769:	b8 68 00 00 00       	mov    $0x68,%eax
f010376e:	ee                   	out    %al,(%dx)
f010376f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103774:	ee                   	out    %al,(%dx)
f0103775:	ba a0 00 00 00       	mov    $0xa0,%edx
f010377a:	b8 68 00 00 00       	mov    $0x68,%eax
f010377f:	ee                   	out    %al,(%dx)
f0103780:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103785:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103786:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010378d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103791:	74 13                	je     f01037a6 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103793:	55                   	push   %ebp
f0103794:	89 e5                	mov    %esp,%ebp
f0103796:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103799:	0f b7 c0             	movzwl %ax,%eax
f010379c:	50                   	push   %eax
f010379d:	e8 ee fe ff ff       	call   f0103690 <irq_setmask_8259A>
f01037a2:	83 c4 10             	add    $0x10,%esp
}
f01037a5:	c9                   	leave  
f01037a6:	f3 c3                	repz ret 

f01037a8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037a8:	55                   	push   %ebp
f01037a9:	89 e5                	mov    %esp,%ebp
f01037ab:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01037ae:	ff 75 08             	pushl  0x8(%ebp)
f01037b1:	e8 cf cf ff ff       	call   f0100785 <cputchar>
	*cnt++;
}
f01037b6:	83 c4 10             	add    $0x10,%esp
f01037b9:	c9                   	leave  
f01037ba:	c3                   	ret    

f01037bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037bb:	55                   	push   %ebp
f01037bc:	89 e5                	mov    %esp,%ebp
f01037be:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01037c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01037c8:	ff 75 0c             	pushl  0xc(%ebp)
f01037cb:	ff 75 08             	pushl  0x8(%ebp)
f01037ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037d1:	50                   	push   %eax
f01037d2:	68 a8 37 10 f0       	push   $0xf01037a8
f01037d7:	e8 e0 16 00 00       	call   f0104ebc <vprintfmt>
	return cnt;
}
f01037dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037df:	c9                   	leave  
f01037e0:	c3                   	ret    

f01037e1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01037e1:	55                   	push   %ebp
f01037e2:	89 e5                	mov    %esp,%ebp
f01037e4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01037e7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01037ea:	50                   	push   %eax
f01037eb:	ff 75 08             	pushl  0x8(%ebp)
f01037ee:	e8 c8 ff ff ff       	call   f01037bb <vcprintf>
	va_end(ap);

	return cnt;
}
f01037f3:	c9                   	leave  
f01037f4:	c3                   	ret    

f01037f5 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01037f5:	55                   	push   %ebp
f01037f6:	89 e5                	mov    %esp,%ebp
f01037f8:	56                   	push   %esi
f01037f9:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    size_t i = cpunum();
f01037fa:	e8 7f 23 00 00       	call   f0105b7e <cpunum>
f01037ff:	89 c3                	mov    %eax,%ebx
     
     // Setup a TSS so that we get the right stack
     // when we trap to the kernel.
     thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
f0103801:	e8 78 23 00 00       	call   f0105b7e <cpunum>
f0103806:	6b c0 74             	imul   $0x74,%eax,%eax
f0103809:	f7 db                	neg    %ebx
f010380b:	c1 e3 10             	shl    $0x10,%ebx
f010380e:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0103814:	89 98 30 20 21 f0    	mov    %ebx,-0xfdedfd0(%eax)
     thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010381a:	e8 5f 23 00 00       	call   f0105b7e <cpunum>
f010381f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103822:	66 c7 80 34 20 21 f0 	movw   $0x10,-0xfdedfcc(%eax)
f0103829:	10 00 
     thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f010382b:	e8 4e 23 00 00       	call   f0105b7e <cpunum>
f0103830:	6b c0 74             	imul   $0x74,%eax,%eax
f0103833:	66 c7 80 92 20 21 f0 	movw   $0x68,-0xfdedf6e(%eax)
f010383a:	68 00 
     // Initialize the TSS slot of the gdt.
     gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f010383c:	e8 3d 23 00 00       	call   f0105b7e <cpunum>
f0103841:	89 c6                	mov    %eax,%esi
f0103843:	e8 36 23 00 00       	call   f0105b7e <cpunum>
f0103848:	89 c3                	mov    %eax,%ebx
f010384a:	e8 2f 23 00 00       	call   f0105b7e <cpunum>
f010384f:	66 c7 05 68 03 12 f0 	movw   $0x67,0xf0120368
f0103856:	67 00 
f0103858:	6b f6 74             	imul   $0x74,%esi,%esi
f010385b:	81 c6 2c 20 21 f0    	add    $0xf021202c,%esi
f0103861:	66 89 35 6a 03 12 f0 	mov    %si,0xf012036a
f0103868:	6b db 74             	imul   $0x74,%ebx,%ebx
f010386b:	81 c3 2c 20 21 f0    	add    $0xf021202c,%ebx
f0103871:	c1 eb 10             	shr    $0x10,%ebx
f0103874:	88 1d 6c 03 12 f0    	mov    %bl,0xf012036c
f010387a:	c6 05 6e 03 12 f0 40 	movb   $0x40,0xf012036e
f0103881:	6b c0 74             	imul   $0x74,%eax,%eax
f0103884:	05 2c 20 21 f0       	add    $0xf021202c,%eax
f0103889:	c1 e8 18             	shr    $0x18,%eax
f010388c:	a2 6f 03 12 f0       	mov    %al,0xf012036f
                             sizeof(struct Taskstate) - 1, 0);
     gdt[GD_TSS0 >> 3].sd_s = 0;
f0103891:	c6 05 6d 03 12 f0 89 	movb   $0x89,0xf012036d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103898:	b8 28 00 00 00       	mov    $0x28,%eax
f010389d:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f01038a0:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f01038a5:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01038a8:	5b                   	pop    %ebx
f01038a9:	5e                   	pop    %esi
f01038aa:	5d                   	pop    %ebp
f01038ab:	c3                   	ret    

f01038ac <trap_init>:
}


void
trap_init(void)
{
f01038ac:	55                   	push   %ebp
f01038ad:	89 e5                	mov    %esp,%ebp
f01038af:	83 ec 08             	sub    $0x8,%esp
    void serial_handler();
    void spurious_handler();
    void ide_handler();
    void error_handler();

        SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_entry, 0);
f01038b2:	b8 6a 42 10 f0       	mov    $0xf010426a,%eax
f01038b7:	66 a3 60 12 21 f0    	mov    %ax,0xf0211260
f01038bd:	66 c7 05 62 12 21 f0 	movw   $0x8,0xf0211262
f01038c4:	08 00 
f01038c6:	c6 05 64 12 21 f0 00 	movb   $0x0,0xf0211264
f01038cd:	c6 05 65 12 21 f0 8e 	movb   $0x8e,0xf0211265
f01038d4:	c1 e8 10             	shr    $0x10,%eax
f01038d7:	66 a3 66 12 21 f0    	mov    %ax,0xf0211266
        SETGATE(idt[T_DEBUG], 0, GD_KT, debug_entry, 0);
f01038dd:	b8 74 42 10 f0       	mov    $0xf0104274,%eax
f01038e2:	66 a3 68 12 21 f0    	mov    %ax,0xf0211268
f01038e8:	66 c7 05 6a 12 21 f0 	movw   $0x8,0xf021126a
f01038ef:	08 00 
f01038f1:	c6 05 6c 12 21 f0 00 	movb   $0x0,0xf021126c
f01038f8:	c6 05 6d 12 21 f0 8e 	movb   $0x8e,0xf021126d
f01038ff:	c1 e8 10             	shr    $0x10,%eax
f0103902:	66 a3 6e 12 21 f0    	mov    %ax,0xf021126e
        SETGATE(idt[T_NMI], 0, GD_KT, nmi_entry, 0);
f0103908:	b8 7a 42 10 f0       	mov    $0xf010427a,%eax
f010390d:	66 a3 70 12 21 f0    	mov    %ax,0xf0211270
f0103913:	66 c7 05 72 12 21 f0 	movw   $0x8,0xf0211272
f010391a:	08 00 
f010391c:	c6 05 74 12 21 f0 00 	movb   $0x0,0xf0211274
f0103923:	c6 05 75 12 21 f0 8e 	movb   $0x8e,0xf0211275
f010392a:	c1 e8 10             	shr    $0x10,%eax
f010392d:	66 a3 76 12 21 f0    	mov    %ax,0xf0211276
        SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt_entry, 3);
f0103933:	b8 80 42 10 f0       	mov    $0xf0104280,%eax
f0103938:	66 a3 78 12 21 f0    	mov    %ax,0xf0211278
f010393e:	66 c7 05 7a 12 21 f0 	movw   $0x8,0xf021127a
f0103945:	08 00 
f0103947:	c6 05 7c 12 21 f0 00 	movb   $0x0,0xf021127c
f010394e:	c6 05 7d 12 21 f0 ee 	movb   $0xee,0xf021127d
f0103955:	c1 e8 10             	shr    $0x10,%eax
f0103958:	66 a3 7e 12 21 f0    	mov    %ax,0xf021127e
        SETGATE(idt[T_OFLOW], 0, GD_KT, oflow_entry, 0);
f010395e:	b8 86 42 10 f0       	mov    $0xf0104286,%eax
f0103963:	66 a3 80 12 21 f0    	mov    %ax,0xf0211280
f0103969:	66 c7 05 82 12 21 f0 	movw   $0x8,0xf0211282
f0103970:	08 00 
f0103972:	c6 05 84 12 21 f0 00 	movb   $0x0,0xf0211284
f0103979:	c6 05 85 12 21 f0 8e 	movb   $0x8e,0xf0211285
f0103980:	c1 e8 10             	shr    $0x10,%eax
f0103983:	66 a3 86 12 21 f0    	mov    %ax,0xf0211286
        SETGATE(idt[T_BOUND], 0, GD_KT, bound_entry, 0);
f0103989:	b8 8c 42 10 f0       	mov    $0xf010428c,%eax
f010398e:	66 a3 88 12 21 f0    	mov    %ax,0xf0211288
f0103994:	66 c7 05 8a 12 21 f0 	movw   $0x8,0xf021128a
f010399b:	08 00 
f010399d:	c6 05 8c 12 21 f0 00 	movb   $0x0,0xf021128c
f01039a4:	c6 05 8d 12 21 f0 8e 	movb   $0x8e,0xf021128d
f01039ab:	c1 e8 10             	shr    $0x10,%eax
f01039ae:	66 a3 8e 12 21 f0    	mov    %ax,0xf021128e
        SETGATE(idt[T_ILLOP], 0, GD_KT, illop_entry, 0);
f01039b4:	b8 92 42 10 f0       	mov    $0xf0104292,%eax
f01039b9:	66 a3 90 12 21 f0    	mov    %ax,0xf0211290
f01039bf:	66 c7 05 92 12 21 f0 	movw   $0x8,0xf0211292
f01039c6:	08 00 
f01039c8:	c6 05 94 12 21 f0 00 	movb   $0x0,0xf0211294
f01039cf:	c6 05 95 12 21 f0 8e 	movb   $0x8e,0xf0211295
f01039d6:	c1 e8 10             	shr    $0x10,%eax
f01039d9:	66 a3 96 12 21 f0    	mov    %ax,0xf0211296
        SETGATE(idt[T_DEVICE], 0, GD_KT, device_entry, 0);
f01039df:	b8 98 42 10 f0       	mov    $0xf0104298,%eax
f01039e4:	66 a3 98 12 21 f0    	mov    %ax,0xf0211298
f01039ea:	66 c7 05 9a 12 21 f0 	movw   $0x8,0xf021129a
f01039f1:	08 00 
f01039f3:	c6 05 9c 12 21 f0 00 	movb   $0x0,0xf021129c
f01039fa:	c6 05 9d 12 21 f0 8e 	movb   $0x8e,0xf021129d
f0103a01:	c1 e8 10             	shr    $0x10,%eax
f0103a04:	66 a3 9e 12 21 f0    	mov    %ax,0xf021129e
        SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt_entry, 0);
f0103a0a:	b8 9e 42 10 f0       	mov    $0xf010429e,%eax
f0103a0f:	66 a3 a0 12 21 f0    	mov    %ax,0xf02112a0
f0103a15:	66 c7 05 a2 12 21 f0 	movw   $0x8,0xf02112a2
f0103a1c:	08 00 
f0103a1e:	c6 05 a4 12 21 f0 00 	movb   $0x0,0xf02112a4
f0103a25:	c6 05 a5 12 21 f0 8e 	movb   $0x8e,0xf02112a5
f0103a2c:	c1 e8 10             	shr    $0x10,%eax
f0103a2f:	66 a3 a6 12 21 f0    	mov    %ax,0xf02112a6
        SETGATE(idt[T_TSS], 0, GD_KT, tss_entry, 0);
f0103a35:	b8 a2 42 10 f0       	mov    $0xf01042a2,%eax
f0103a3a:	66 a3 b0 12 21 f0    	mov    %ax,0xf02112b0
f0103a40:	66 c7 05 b2 12 21 f0 	movw   $0x8,0xf02112b2
f0103a47:	08 00 
f0103a49:	c6 05 b4 12 21 f0 00 	movb   $0x0,0xf02112b4
f0103a50:	c6 05 b5 12 21 f0 8e 	movb   $0x8e,0xf02112b5
f0103a57:	c1 e8 10             	shr    $0x10,%eax
f0103a5a:	66 a3 b6 12 21 f0    	mov    %ax,0xf02112b6
        SETGATE(idt[T_SEGNP], 0, GD_KT, segnp_entry, 0);
f0103a60:	b8 a6 42 10 f0       	mov    $0xf01042a6,%eax
f0103a65:	66 a3 b8 12 21 f0    	mov    %ax,0xf02112b8
f0103a6b:	66 c7 05 ba 12 21 f0 	movw   $0x8,0xf02112ba
f0103a72:	08 00 
f0103a74:	c6 05 bc 12 21 f0 00 	movb   $0x0,0xf02112bc
f0103a7b:	c6 05 bd 12 21 f0 8e 	movb   $0x8e,0xf02112bd
f0103a82:	c1 e8 10             	shr    $0x10,%eax
f0103a85:	66 a3 be 12 21 f0    	mov    %ax,0xf02112be
        SETGATE(idt[T_STACK], 0, GD_KT, stack_entry, 0);
f0103a8b:	b8 aa 42 10 f0       	mov    $0xf01042aa,%eax
f0103a90:	66 a3 c0 12 21 f0    	mov    %ax,0xf02112c0
f0103a96:	66 c7 05 c2 12 21 f0 	movw   $0x8,0xf02112c2
f0103a9d:	08 00 
f0103a9f:	c6 05 c4 12 21 f0 00 	movb   $0x0,0xf02112c4
f0103aa6:	c6 05 c5 12 21 f0 8e 	movb   $0x8e,0xf02112c5
f0103aad:	c1 e8 10             	shr    $0x10,%eax
f0103ab0:	66 a3 c6 12 21 f0    	mov    %ax,0xf02112c6
        SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt_entry, 0);
f0103ab6:	b8 ae 42 10 f0       	mov    $0xf01042ae,%eax
f0103abb:	66 a3 c8 12 21 f0    	mov    %ax,0xf02112c8
f0103ac1:	66 c7 05 ca 12 21 f0 	movw   $0x8,0xf02112ca
f0103ac8:	08 00 
f0103aca:	c6 05 cc 12 21 f0 00 	movb   $0x0,0xf02112cc
f0103ad1:	c6 05 cd 12 21 f0 8e 	movb   $0x8e,0xf02112cd
f0103ad8:	c1 e8 10             	shr    $0x10,%eax
f0103adb:	66 a3 ce 12 21 f0    	mov    %ax,0xf02112ce
        SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt_entry, 0);
f0103ae1:	b8 b2 42 10 f0       	mov    $0xf01042b2,%eax
f0103ae6:	66 a3 d0 12 21 f0    	mov    %ax,0xf02112d0
f0103aec:	66 c7 05 d2 12 21 f0 	movw   $0x8,0xf02112d2
f0103af3:	08 00 
f0103af5:	c6 05 d4 12 21 f0 00 	movb   $0x0,0xf02112d4
f0103afc:	c6 05 d5 12 21 f0 8e 	movb   $0x8e,0xf02112d5
f0103b03:	c1 e8 10             	shr    $0x10,%eax
f0103b06:	66 a3 d6 12 21 f0    	mov    %ax,0xf02112d6
        SETGATE(idt[T_FPERR], 0, GD_KT, fperr_entry, 0);
f0103b0c:	b8 b6 42 10 f0       	mov    $0xf01042b6,%eax
f0103b11:	66 a3 e0 12 21 f0    	mov    %ax,0xf02112e0
f0103b17:	66 c7 05 e2 12 21 f0 	movw   $0x8,0xf02112e2
f0103b1e:	08 00 
f0103b20:	c6 05 e4 12 21 f0 00 	movb   $0x0,0xf02112e4
f0103b27:	c6 05 e5 12 21 f0 8e 	movb   $0x8e,0xf02112e5
f0103b2e:	c1 e8 10             	shr    $0x10,%eax
f0103b31:	66 a3 e6 12 21 f0    	mov    %ax,0xf02112e6
        SETGATE(idt[T_ALIGN], 0, GD_KT, align_entry, 0);
f0103b37:	b8 bc 42 10 f0       	mov    $0xf01042bc,%eax
f0103b3c:	66 a3 e8 12 21 f0    	mov    %ax,0xf02112e8
f0103b42:	66 c7 05 ea 12 21 f0 	movw   $0x8,0xf02112ea
f0103b49:	08 00 
f0103b4b:	c6 05 ec 12 21 f0 00 	movb   $0x0,0xf02112ec
f0103b52:	c6 05 ed 12 21 f0 8e 	movb   $0x8e,0xf02112ed
f0103b59:	c1 e8 10             	shr    $0x10,%eax
f0103b5c:	66 a3 ee 12 21 f0    	mov    %ax,0xf02112ee
        SETGATE(idt[T_MCHK], 0, GD_KT, mchk_entry, 0);
f0103b62:	b8 c0 42 10 f0       	mov    $0xf01042c0,%eax
f0103b67:	66 a3 f0 12 21 f0    	mov    %ax,0xf02112f0
f0103b6d:	66 c7 05 f2 12 21 f0 	movw   $0x8,0xf02112f2
f0103b74:	08 00 
f0103b76:	c6 05 f4 12 21 f0 00 	movb   $0x0,0xf02112f4
f0103b7d:	c6 05 f5 12 21 f0 8e 	movb   $0x8e,0xf02112f5
f0103b84:	c1 e8 10             	shr    $0x10,%eax
f0103b87:	66 a3 f6 12 21 f0    	mov    %ax,0xf02112f6
        SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr_entry, 0);
f0103b8d:	b8 c6 42 10 f0       	mov    $0xf01042c6,%eax
f0103b92:	66 a3 f8 12 21 f0    	mov    %ax,0xf02112f8
f0103b98:	66 c7 05 fa 12 21 f0 	movw   $0x8,0xf02112fa
f0103b9f:	08 00 
f0103ba1:	c6 05 fc 12 21 f0 00 	movb   $0x0,0xf02112fc
f0103ba8:	c6 05 fd 12 21 f0 8e 	movb   $0x8e,0xf02112fd
f0103baf:	c1 e8 10             	shr    $0x10,%eax
f0103bb2:	66 a3 fe 12 21 f0    	mov    %ax,0xf02112fe
        SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_entry, 3);
f0103bb8:	b8 cc 42 10 f0       	mov    $0xf01042cc,%eax
f0103bbd:	66 a3 e0 13 21 f0    	mov    %ax,0xf02113e0
f0103bc3:	66 c7 05 e2 13 21 f0 	movw   $0x8,0xf02113e2
f0103bca:	08 00 
f0103bcc:	c6 05 e4 13 21 f0 00 	movb   $0x0,0xf02113e4
f0103bd3:	c6 05 e5 13 21 f0 ee 	movb   $0xee,0xf02113e5
f0103bda:	c1 e8 10             	shr    $0x10,%eax
f0103bdd:	66 a3 e6 13 21 f0    	mov    %ax,0xf02113e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, timer_handler, 0);
f0103be3:	b8 d2 42 10 f0       	mov    $0xf01042d2,%eax
f0103be8:	66 a3 60 13 21 f0    	mov    %ax,0xf0211360
f0103bee:	66 c7 05 62 13 21 f0 	movw   $0x8,0xf0211362
f0103bf5:	08 00 
f0103bf7:	c6 05 64 13 21 f0 00 	movb   $0x0,0xf0211364
f0103bfe:	c6 05 65 13 21 f0 8e 	movb   $0x8e,0xf0211365
f0103c05:	c1 e8 10             	shr    $0x10,%eax
f0103c08:	66 a3 66 13 21 f0    	mov    %ax,0xf0211366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, kbd_handler,     0);
f0103c0e:	b8 d8 42 10 f0       	mov    $0xf01042d8,%eax
f0103c13:	66 a3 68 13 21 f0    	mov    %ax,0xf0211368
f0103c19:	66 c7 05 6a 13 21 f0 	movw   $0x8,0xf021136a
f0103c20:	08 00 
f0103c22:	c6 05 6c 13 21 f0 00 	movb   $0x0,0xf021136c
f0103c29:	c6 05 6d 13 21 f0 8e 	movb   $0x8e,0xf021136d
f0103c30:	c1 e8 10             	shr    $0x10,%eax
f0103c33:	66 a3 6e 13 21 f0    	mov    %ax,0xf021136e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, serial_handler,  0);
f0103c39:	b8 de 42 10 f0       	mov    $0xf01042de,%eax
f0103c3e:	66 a3 80 13 21 f0    	mov    %ax,0xf0211380
f0103c44:	66 c7 05 82 13 21 f0 	movw   $0x8,0xf0211382
f0103c4b:	08 00 
f0103c4d:	c6 05 84 13 21 f0 00 	movb   $0x0,0xf0211384
f0103c54:	c6 05 85 13 21 f0 8e 	movb   $0x8e,0xf0211385
f0103c5b:	c1 e8 10             	shr    $0x10,%eax
f0103c5e:	66 a3 86 13 21 f0    	mov    %ax,0xf0211386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, spurious_handler, 0);
f0103c64:	b8 e4 42 10 f0       	mov    $0xf01042e4,%eax
f0103c69:	66 a3 98 13 21 f0    	mov    %ax,0xf0211398
f0103c6f:	66 c7 05 9a 13 21 f0 	movw   $0x8,0xf021139a
f0103c76:	08 00 
f0103c78:	c6 05 9c 13 21 f0 00 	movb   $0x0,0xf021139c
f0103c7f:	c6 05 9d 13 21 f0 8e 	movb   $0x8e,0xf021139d
f0103c86:	c1 e8 10             	shr    $0x10,%eax
f0103c89:	66 a3 9e 13 21 f0    	mov    %ax,0xf021139e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, ide_handler,     0);
f0103c8f:	b8 ea 42 10 f0       	mov    $0xf01042ea,%eax
f0103c94:	66 a3 d0 13 21 f0    	mov    %ax,0xf02113d0
f0103c9a:	66 c7 05 d2 13 21 f0 	movw   $0x8,0xf02113d2
f0103ca1:	08 00 
f0103ca3:	c6 05 d4 13 21 f0 00 	movb   $0x0,0xf02113d4
f0103caa:	c6 05 d5 13 21 f0 8e 	movb   $0x8e,0xf02113d5
f0103cb1:	c1 e8 10             	shr    $0x10,%eax
f0103cb4:	66 a3 d6 13 21 f0    	mov    %ax,0xf02113d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],    0, GD_KT, error_handler,   0);
f0103cba:	b8 f0 42 10 f0       	mov    $0xf01042f0,%eax
f0103cbf:	66 a3 f8 13 21 f0    	mov    %ax,0xf02113f8
f0103cc5:	66 c7 05 fa 13 21 f0 	movw   $0x8,0xf02113fa
f0103ccc:	08 00 
f0103cce:	c6 05 fc 13 21 f0 00 	movb   $0x0,0xf02113fc
f0103cd5:	c6 05 fd 13 21 f0 8e 	movb   $0x8e,0xf02113fd
f0103cdc:	c1 e8 10             	shr    $0x10,%eax
f0103cdf:	66 a3 fe 13 21 f0    	mov    %ax,0xf02113fe


	// Per-CPU setup 
	trap_init_percpu();
f0103ce5:	e8 0b fb ff ff       	call   f01037f5 <trap_init_percpu>
}
f0103cea:	c9                   	leave  
f0103ceb:	c3                   	ret    

f0103cec <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103cec:	55                   	push   %ebp
f0103ced:	89 e5                	mov    %esp,%ebp
f0103cef:	53                   	push   %ebx
f0103cf0:	83 ec 0c             	sub    $0xc,%esp
f0103cf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103cf6:	ff 33                	pushl  (%ebx)
f0103cf8:	68 24 75 10 f0       	push   $0xf0107524
f0103cfd:	e8 df fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d02:	83 c4 08             	add    $0x8,%esp
f0103d05:	ff 73 04             	pushl  0x4(%ebx)
f0103d08:	68 33 75 10 f0       	push   $0xf0107533
f0103d0d:	e8 cf fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d12:	83 c4 08             	add    $0x8,%esp
f0103d15:	ff 73 08             	pushl  0x8(%ebx)
f0103d18:	68 42 75 10 f0       	push   $0xf0107542
f0103d1d:	e8 bf fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d22:	83 c4 08             	add    $0x8,%esp
f0103d25:	ff 73 0c             	pushl  0xc(%ebx)
f0103d28:	68 51 75 10 f0       	push   $0xf0107551
f0103d2d:	e8 af fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d32:	83 c4 08             	add    $0x8,%esp
f0103d35:	ff 73 10             	pushl  0x10(%ebx)
f0103d38:	68 60 75 10 f0       	push   $0xf0107560
f0103d3d:	e8 9f fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d42:	83 c4 08             	add    $0x8,%esp
f0103d45:	ff 73 14             	pushl  0x14(%ebx)
f0103d48:	68 6f 75 10 f0       	push   $0xf010756f
f0103d4d:	e8 8f fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d52:	83 c4 08             	add    $0x8,%esp
f0103d55:	ff 73 18             	pushl  0x18(%ebx)
f0103d58:	68 7e 75 10 f0       	push   $0xf010757e
f0103d5d:	e8 7f fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d62:	83 c4 08             	add    $0x8,%esp
f0103d65:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d68:	68 8d 75 10 f0       	push   $0xf010758d
f0103d6d:	e8 6f fa ff ff       	call   f01037e1 <cprintf>
}
f0103d72:	83 c4 10             	add    $0x10,%esp
f0103d75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d78:	c9                   	leave  
f0103d79:	c3                   	ret    

f0103d7a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d7a:	55                   	push   %ebp
f0103d7b:	89 e5                	mov    %esp,%ebp
f0103d7d:	56                   	push   %esi
f0103d7e:	53                   	push   %ebx
f0103d7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d82:	e8 f7 1d 00 00       	call   f0105b7e <cpunum>
f0103d87:	83 ec 04             	sub    $0x4,%esp
f0103d8a:	50                   	push   %eax
f0103d8b:	53                   	push   %ebx
f0103d8c:	68 f1 75 10 f0       	push   $0xf01075f1
f0103d91:	e8 4b fa ff ff       	call   f01037e1 <cprintf>
	print_regs(&tf->tf_regs);
f0103d96:	89 1c 24             	mov    %ebx,(%esp)
f0103d99:	e8 4e ff ff ff       	call   f0103cec <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d9e:	83 c4 08             	add    $0x8,%esp
f0103da1:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103da5:	50                   	push   %eax
f0103da6:	68 0f 76 10 f0       	push   $0xf010760f
f0103dab:	e8 31 fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103db0:	83 c4 08             	add    $0x8,%esp
f0103db3:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103db7:	50                   	push   %eax
f0103db8:	68 22 76 10 f0       	push   $0xf0107622
f0103dbd:	e8 1f fa ff ff       	call   f01037e1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103dc2:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103dc5:	83 c4 10             	add    $0x10,%esp
f0103dc8:	83 f8 13             	cmp    $0x13,%eax
f0103dcb:	77 09                	ja     f0103dd6 <print_trapframe+0x5c>
		return excnames[trapno];
f0103dcd:	8b 14 85 c0 78 10 f0 	mov    -0xfef8740(,%eax,4),%edx
f0103dd4:	eb 1f                	jmp    f0103df5 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103dd6:	83 f8 30             	cmp    $0x30,%eax
f0103dd9:	74 15                	je     f0103df0 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ddb:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103dde:	83 fa 10             	cmp    $0x10,%edx
f0103de1:	b9 bb 75 10 f0       	mov    $0xf01075bb,%ecx
f0103de6:	ba a8 75 10 f0       	mov    $0xf01075a8,%edx
f0103deb:	0f 43 d1             	cmovae %ecx,%edx
f0103dee:	eb 05                	jmp    f0103df5 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103df0:	ba 9c 75 10 f0       	mov    $0xf010759c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103df5:	83 ec 04             	sub    $0x4,%esp
f0103df8:	52                   	push   %edx
f0103df9:	50                   	push   %eax
f0103dfa:	68 35 76 10 f0       	push   $0xf0107635
f0103dff:	e8 dd f9 ff ff       	call   f01037e1 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e04:	83 c4 10             	add    $0x10,%esp
f0103e07:	3b 1d 60 1a 21 f0    	cmp    0xf0211a60,%ebx
f0103e0d:	75 1a                	jne    f0103e29 <print_trapframe+0xaf>
f0103e0f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e13:	75 14                	jne    f0103e29 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e15:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e18:	83 ec 08             	sub    $0x8,%esp
f0103e1b:	50                   	push   %eax
f0103e1c:	68 47 76 10 f0       	push   $0xf0107647
f0103e21:	e8 bb f9 ff ff       	call   f01037e1 <cprintf>
f0103e26:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103e29:	83 ec 08             	sub    $0x8,%esp
f0103e2c:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e2f:	68 56 76 10 f0       	push   $0xf0107656
f0103e34:	e8 a8 f9 ff ff       	call   f01037e1 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e39:	83 c4 10             	add    $0x10,%esp
f0103e3c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e40:	75 49                	jne    f0103e8b <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e42:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e45:	89 c2                	mov    %eax,%edx
f0103e47:	83 e2 01             	and    $0x1,%edx
f0103e4a:	ba d5 75 10 f0       	mov    $0xf01075d5,%edx
f0103e4f:	b9 ca 75 10 f0       	mov    $0xf01075ca,%ecx
f0103e54:	0f 44 ca             	cmove  %edx,%ecx
f0103e57:	89 c2                	mov    %eax,%edx
f0103e59:	83 e2 02             	and    $0x2,%edx
f0103e5c:	ba e7 75 10 f0       	mov    $0xf01075e7,%edx
f0103e61:	be e1 75 10 f0       	mov    $0xf01075e1,%esi
f0103e66:	0f 45 d6             	cmovne %esi,%edx
f0103e69:	83 e0 04             	and    $0x4,%eax
f0103e6c:	be 21 77 10 f0       	mov    $0xf0107721,%esi
f0103e71:	b8 ec 75 10 f0       	mov    $0xf01075ec,%eax
f0103e76:	0f 44 c6             	cmove  %esi,%eax
f0103e79:	51                   	push   %ecx
f0103e7a:	52                   	push   %edx
f0103e7b:	50                   	push   %eax
f0103e7c:	68 64 76 10 f0       	push   $0xf0107664
f0103e81:	e8 5b f9 ff ff       	call   f01037e1 <cprintf>
f0103e86:	83 c4 10             	add    $0x10,%esp
f0103e89:	eb 10                	jmp    f0103e9b <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e8b:	83 ec 0c             	sub    $0xc,%esp
f0103e8e:	68 ca 73 10 f0       	push   $0xf01073ca
f0103e93:	e8 49 f9 ff ff       	call   f01037e1 <cprintf>
f0103e98:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e9b:	83 ec 08             	sub    $0x8,%esp
f0103e9e:	ff 73 30             	pushl  0x30(%ebx)
f0103ea1:	68 73 76 10 f0       	push   $0xf0107673
f0103ea6:	e8 36 f9 ff ff       	call   f01037e1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103eab:	83 c4 08             	add    $0x8,%esp
f0103eae:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103eb2:	50                   	push   %eax
f0103eb3:	68 82 76 10 f0       	push   $0xf0107682
f0103eb8:	e8 24 f9 ff ff       	call   f01037e1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ebd:	83 c4 08             	add    $0x8,%esp
f0103ec0:	ff 73 38             	pushl  0x38(%ebx)
f0103ec3:	68 95 76 10 f0       	push   $0xf0107695
f0103ec8:	e8 14 f9 ff ff       	call   f01037e1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ecd:	83 c4 10             	add    $0x10,%esp
f0103ed0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ed4:	74 25                	je     f0103efb <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ed6:	83 ec 08             	sub    $0x8,%esp
f0103ed9:	ff 73 3c             	pushl  0x3c(%ebx)
f0103edc:	68 a4 76 10 f0       	push   $0xf01076a4
f0103ee1:	e8 fb f8 ff ff       	call   f01037e1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ee6:	83 c4 08             	add    $0x8,%esp
f0103ee9:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103eed:	50                   	push   %eax
f0103eee:	68 b3 76 10 f0       	push   $0xf01076b3
f0103ef3:	e8 e9 f8 ff ff       	call   f01037e1 <cprintf>
f0103ef8:	83 c4 10             	add    $0x10,%esp
	}
}
f0103efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103efe:	5b                   	pop    %ebx
f0103eff:	5e                   	pop    %esi
f0103f00:	5d                   	pop    %ebp
f0103f01:	c3                   	ret    

f0103f02 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f02:	55                   	push   %ebp
f0103f03:	89 e5                	mov    %esp,%ebp
f0103f05:	57                   	push   %edi
f0103f06:	56                   	push   %esi
f0103f07:	53                   	push   %ebx
f0103f08:	83 ec 0c             	sub    $0xc,%esp
f0103f0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f0e:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0) {
f0103f11:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f15:	75 15                	jne    f0103f2c <page_fault_handler+0x2a>
        	panic("page_fault in kernel mode, fault address %d\n", fault_va);
f0103f17:	56                   	push   %esi
f0103f18:	68 6c 78 10 f0       	push   $0xf010786c
f0103f1d:	68 86 01 00 00       	push   $0x186
f0103f22:	68 c6 76 10 f0       	push   $0xf01076c6
f0103f27:	e8 14 c1 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
     	struct UTrapframe *utf;
	// cprintf("I'M in page_fault_handler [%08x] user fault va %08x \n",curenv->env_id, fault_va);
	if (curenv->env_pgfault_upcall) {
f0103f2c:	e8 4d 1c 00 00       	call   f0105b7e <cpunum>
f0103f31:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f34:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103f3a:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103f3e:	0f 84 a7 00 00 00    	je     f0103feb <page_fault_handler+0xe9>
		
		if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP) {
f0103f44:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f47:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			// 异常模式下陷入
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0103f4d:	83 e8 38             	sub    $0x38,%eax
f0103f50:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103f56:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103f5b:	0f 46 d0             	cmovbe %eax,%edx
f0103f5e:	89 d7                	mov    %edx,%edi
		else {
			// 非异常模式下陷入
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));	
		}
		// 检查异常栈是否溢出
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);
f0103f60:	e8 19 1c 00 00       	call   f0105b7e <cpunum>
f0103f65:	6a 03                	push   $0x3
f0103f67:	6a 34                	push   $0x34
f0103f69:	57                   	push   %edi
f0103f6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f6d:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103f73:	e8 e4 ee ff ff       	call   f0102e5c <user_mem_assert>
			
		utf->utf_fault_va = fault_va;
f0103f78:	89 fa                	mov    %edi,%edx
f0103f7a:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_trapno;
f0103f7c:	8b 43 28             	mov    0x28(%ebx),%eax
f0103f7f:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f0103f82:	8d 7f 08             	lea    0x8(%edi),%edi
f0103f85:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f8a:	89 de                	mov    %ebx,%esi
f0103f8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eflags   = tf->tf_eflags;
f0103f8e:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f91:	89 42 2c             	mov    %eax,0x2c(%edx)
		// 保存陷入时现场，用于返回
		utf->utf_eip      = tf->tf_eip;
f0103f94:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f97:	89 d7                	mov    %edx,%edi
f0103f99:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_esp      = tf->tf_esp;
f0103f9c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f9f:	89 42 30             	mov    %eax,0x30(%edx)
		// 再次转向执行
		curenv->env_tf.tf_eip        = (uint32_t) curenv->env_pgfault_upcall;
f0103fa2:	e8 d7 1b 00 00       	call   f0105b7e <cpunum>
f0103fa7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103faa:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f0103fb0:	e8 c9 1b 00 00       	call   f0105b7e <cpunum>
f0103fb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb8:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103fbe:	8b 40 64             	mov    0x64(%eax),%eax
f0103fc1:	89 43 30             	mov    %eax,0x30(%ebx)
		// 异常栈
		curenv->env_tf.tf_esp        = (uint32_t) utf;
f0103fc4:	e8 b5 1b 00 00       	call   f0105b7e <cpunum>
f0103fc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fcc:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103fd2:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0103fd5:	e8 a4 1b 00 00       	call   f0105b7e <cpunum>
f0103fda:	83 c4 04             	add    $0x4,%esp
f0103fdd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe0:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103fe6:	e8 a5 f5 ff ff       	call   f0103590 <env_run>
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103feb:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0103fee:	e8 8b 1b 00 00       	call   f0105b7e <cpunum>
		curenv->env_tf.tf_esp        = (uint32_t) utf;
		env_run(curenv);
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ff3:	57                   	push   %edi
f0103ff4:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0103ff5:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp        = (uint32_t) utf;
		env_run(curenv);
	}
	else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ff8:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103ffe:	ff 70 48             	pushl  0x48(%eax)
f0104001:	68 9c 78 10 f0       	push   $0xf010789c
f0104006:	e8 d6 f7 ff ff       	call   f01037e1 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f010400b:	89 1c 24             	mov    %ebx,(%esp)
f010400e:	e8 67 fd ff ff       	call   f0103d7a <print_trapframe>
		env_destroy(curenv);
f0104013:	e8 66 1b 00 00       	call   f0105b7e <cpunum>
f0104018:	83 c4 04             	add    $0x4,%esp
f010401b:	6b c0 74             	imul   $0x74,%eax,%eax
f010401e:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104024:	e8 c8 f4 ff ff       	call   f01034f1 <env_destroy>
	}
	// Destroy the environment that caused the fault.
	//cprintf("[%08x] user fault va %08x ip %08x\n",curenv->env_id, fault_va, tf->tf_eip);
	//print_trapframe(tf);
	//env_destroy(curenv);
}
f0104029:	83 c4 10             	add    $0x10,%esp
f010402c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010402f:	5b                   	pop    %ebx
f0104030:	5e                   	pop    %esi
f0104031:	5f                   	pop    %edi
f0104032:	5d                   	pop    %ebp
f0104033:	c3                   	ret    

f0104034 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104034:	55                   	push   %ebp
f0104035:	89 e5                	mov    %esp,%ebp
f0104037:	57                   	push   %edi
f0104038:	56                   	push   %esi
f0104039:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010403c:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010403d:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f0104044:	74 01                	je     f0104047 <trap+0x13>
		asm volatile("hlt");
f0104046:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104047:	e8 32 1b 00 00       	call   f0105b7e <cpunum>
f010404c:	6b d0 74             	imul   $0x74,%eax,%edx
f010404f:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104055:	b8 01 00 00 00       	mov    $0x1,%eax
f010405a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010405e:	83 f8 02             	cmp    $0x2,%eax
f0104061:	75 10                	jne    f0104073 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104063:	83 ec 0c             	sub    $0xc,%esp
f0104066:	68 c0 03 12 f0       	push   $0xf01203c0
f010406b:	e8 7c 1d 00 00       	call   f0105dec <spin_lock>
f0104070:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104073:	9c                   	pushf  
f0104074:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104075:	f6 c4 02             	test   $0x2,%ah
f0104078:	74 19                	je     f0104093 <trap+0x5f>
f010407a:	68 d2 76 10 f0       	push   $0xf01076d2
f010407f:	68 ff 70 10 f0       	push   $0xf01070ff
f0104084:	68 4d 01 00 00       	push   $0x14d
f0104089:	68 c6 76 10 f0       	push   $0xf01076c6
f010408e:	e8 ad bf ff ff       	call   f0100040 <_panic>



	if ((tf->tf_cs&3) == 3) {
f0104093:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104097:	83 e0 03             	and    $0x3,%eax
f010409a:	66 83 f8 03          	cmp    $0x3,%ax
f010409e:	0f 85 a0 00 00 00    	jne    f0104144 <trap+0x110>
f01040a4:	83 ec 0c             	sub    $0xc,%esp
f01040a7:	68 c0 03 12 f0       	push   $0xf01203c0
f01040ac:	e8 3b 1d 00 00       	call   f0105dec <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
        	lock_kernel();
		assert(curenv);
f01040b1:	e8 c8 1a 00 00       	call   f0105b7e <cpunum>
f01040b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b9:	83 c4 10             	add    $0x10,%esp
f01040bc:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01040c3:	75 19                	jne    f01040de <trap+0xaa>
f01040c5:	68 eb 76 10 f0       	push   $0xf01076eb
f01040ca:	68 ff 70 10 f0       	push   $0xf01070ff
f01040cf:	68 58 01 00 00       	push   $0x158
f01040d4:	68 c6 76 10 f0       	push   $0xf01076c6
f01040d9:	e8 62 bf ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01040de:	e8 9b 1a 00 00       	call   f0105b7e <cpunum>
f01040e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e6:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01040ec:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01040f0:	75 2d                	jne    f010411f <trap+0xeb>
			env_free(curenv);
f01040f2:	e8 87 1a 00 00       	call   f0105b7e <cpunum>
f01040f7:	83 ec 0c             	sub    $0xc,%esp
f01040fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fd:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104103:	e8 0e f2 ff ff       	call   f0103316 <env_free>
			curenv = NULL;
f0104108:	e8 71 1a 00 00       	call   f0105b7e <cpunum>
f010410d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104110:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f0104117:	00 00 00 
			sched_yield();
f010411a:	e8 bd 02 00 00       	call   f01043dc <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010411f:	e8 5a 1a 00 00       	call   f0105b7e <cpunum>
f0104124:	6b c0 74             	imul   $0x74,%eax,%eax
f0104127:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010412d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104132:	89 c7                	mov    %eax,%edi
f0104134:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104136:	e8 43 1a 00 00       	call   f0105b7e <cpunum>
f010413b:	6b c0 74             	imul   $0x74,%eax,%eax
f010413e:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104144:	89 35 60 1a 21 f0    	mov    %esi,0xf0211a60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010414a:	8b 46 28             	mov    0x28(%esi),%eax
f010414d:	83 f8 27             	cmp    $0x27,%eax
f0104150:	75 1d                	jne    f010416f <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0104152:	83 ec 0c             	sub    $0xc,%esp
f0104155:	68 f2 76 10 f0       	push   $0xf01076f2
f010415a:	e8 82 f6 ff ff       	call   f01037e1 <cprintf>
		print_trapframe(tf);
f010415f:	89 34 24             	mov    %esi,(%esp)
f0104162:	e8 13 fc ff ff       	call   f0103d7a <print_trapframe>
f0104167:	83 c4 10             	add    $0x10,%esp
f010416a:	e9 ba 00 00 00       	jmp    f0104229 <trap+0x1f5>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010416f:	83 f8 20             	cmp    $0x20,%eax
f0104172:	75 0a                	jne    f010417e <trap+0x14a>
           lapic_eoi();
f0104174:	e8 50 1b 00 00       	call   f0105cc9 <lapic_eoi>
           sched_yield();
f0104179:	e8 5e 02 00 00       	call   f01043dc <sched_yield>
           return;
    	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f010417e:	83 f8 21             	cmp    $0x21,%eax
f0104181:	75 0f                	jne    f0104192 <trap+0x15e>
	    lapic_eoi();
f0104183:	e8 41 1b 00 00       	call   f0105cc9 <lapic_eoi>
	    kbd_intr();
f0104188:	e8 56 c4 ff ff       	call   f01005e3 <kbd_intr>
f010418d:	e9 97 00 00 00       	jmp    f0104229 <trap+0x1f5>
	    return;
	}
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0104192:	83 f8 24             	cmp    $0x24,%eax
f0104195:	75 0f                	jne    f01041a6 <trap+0x172>

	    lapic_eoi();
f0104197:	e8 2d 1b 00 00       	call   f0105cc9 <lapic_eoi>
	    serial_intr();
f010419c:	e8 26 c4 ff ff       	call   f01005c7 <serial_intr>
f01041a1:	e9 83 00 00 00       	jmp    f0104229 <trap+0x1f5>
	    return;
	}
	//---------------------------------

	if (tf->tf_trapno == T_PGFLT) {
f01041a6:	83 f8 0e             	cmp    $0xe,%eax
f01041a9:	75 0e                	jne    f01041b9 <trap+0x185>
        	return page_fault_handler(tf);
f01041ab:	83 ec 0c             	sub    $0xc,%esp
f01041ae:	56                   	push   %esi
f01041af:	e8 4e fd ff ff       	call   f0103f02 <page_fault_handler>
f01041b4:	83 c4 10             	add    $0x10,%esp
f01041b7:	eb 70                	jmp    f0104229 <trap+0x1f5>
    	}   

    	if (tf->tf_trapno == T_BRKPT) {
f01041b9:	83 f8 03             	cmp    $0x3,%eax
f01041bc:	75 0e                	jne    f01041cc <trap+0x198>
        	return monitor(tf);
f01041be:	83 ec 0c             	sub    $0xc,%esp
f01041c1:	56                   	push   %esi
f01041c2:	e8 67 c7 ff ff       	call   f010092e <monitor>
f01041c7:	83 c4 10             	add    $0x10,%esp
f01041ca:	eb 5d                	jmp    f0104229 <trap+0x1f5>
    	} 
	if (tf->tf_trapno == T_SYSCALL) {
f01041cc:	83 f8 30             	cmp    $0x30,%eax
f01041cf:	75 21                	jne    f01041f2 <trap+0x1be>
		tf->tf_regs.reg_eax = syscall(
f01041d1:	83 ec 08             	sub    $0x8,%esp
f01041d4:	ff 76 04             	pushl  0x4(%esi)
f01041d7:	ff 36                	pushl  (%esi)
f01041d9:	ff 76 10             	pushl  0x10(%esi)
f01041dc:	ff 76 18             	pushl  0x18(%esi)
f01041df:	ff 76 14             	pushl  0x14(%esi)
f01041e2:	ff 76 1c             	pushl  0x1c(%esi)
f01041e5:	e8 7b 02 00 00       	call   f0104465 <syscall>
f01041ea:	89 46 1c             	mov    %eax,0x1c(%esi)
f01041ed:	83 c4 20             	add    $0x20,%esp
f01041f0:	eb 37                	jmp    f0104229 <trap+0x1f5>
    
    

	// Unexpected trap: The user process or the kernel has a bug.
	//print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
f01041f2:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01041f7:	75 17                	jne    f0104210 <trap+0x1dc>
		panic("unhandled trap in kernel");
f01041f9:	83 ec 04             	sub    $0x4,%esp
f01041fc:	68 0f 77 10 f0       	push   $0xf010770f
f0104201:	68 32 01 00 00       	push   $0x132
f0104206:	68 c6 76 10 f0       	push   $0xf01076c6
f010420b:	e8 30 be ff ff       	call   f0100040 <_panic>
	
	else {
		env_destroy(curenv);
f0104210:	e8 69 19 00 00       	call   f0105b7e <cpunum>
f0104215:	83 ec 0c             	sub    $0xc,%esp
f0104218:	6b c0 74             	imul   $0x74,%eax,%eax
f010421b:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104221:	e8 cb f2 ff ff       	call   f01034f1 <env_destroy>
f0104226:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104229:	e8 50 19 00 00       	call   f0105b7e <cpunum>
f010422e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104231:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0104238:	74 2a                	je     f0104264 <trap+0x230>
f010423a:	e8 3f 19 00 00       	call   f0105b7e <cpunum>
f010423f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104242:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104248:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010424c:	75 16                	jne    f0104264 <trap+0x230>
		env_run(curenv);
f010424e:	e8 2b 19 00 00       	call   f0105b7e <cpunum>
f0104253:	83 ec 0c             	sub    $0xc,%esp
f0104256:	6b c0 74             	imul   $0x74,%eax,%eax
f0104259:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f010425f:	e8 2c f3 ff ff       	call   f0103590 <env_run>
	else
		sched_yield();
f0104264:	e8 73 01 00 00       	call   f01043dc <sched_yield>
f0104269:	90                   	nop

f010426a <divide_entry>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(divide_entry, T_DIVIDE);
f010426a:	6a 00                	push   $0x0
f010426c:	6a 00                	push   $0x0
f010426e:	e9 83 00 00 00       	jmp    f01042f6 <_alltraps>
f0104273:	90                   	nop

f0104274 <debug_entry>:
TRAPHANDLER_NOEC(debug_entry, T_DEBUG);
f0104274:	6a 00                	push   $0x0
f0104276:	6a 01                	push   $0x1
f0104278:	eb 7c                	jmp    f01042f6 <_alltraps>

f010427a <nmi_entry>:
TRAPHANDLER_NOEC(nmi_entry, T_NMI);
f010427a:	6a 00                	push   $0x0
f010427c:	6a 02                	push   $0x2
f010427e:	eb 76                	jmp    f01042f6 <_alltraps>

f0104280 <brkpt_entry>:
TRAPHANDLER_NOEC(brkpt_entry, T_BRKPT);
f0104280:	6a 00                	push   $0x0
f0104282:	6a 03                	push   $0x3
f0104284:	eb 70                	jmp    f01042f6 <_alltraps>

f0104286 <oflow_entry>:
TRAPHANDLER_NOEC(oflow_entry, T_OFLOW);
f0104286:	6a 00                	push   $0x0
f0104288:	6a 04                	push   $0x4
f010428a:	eb 6a                	jmp    f01042f6 <_alltraps>

f010428c <bound_entry>:
TRAPHANDLER_NOEC(bound_entry, T_BOUND);
f010428c:	6a 00                	push   $0x0
f010428e:	6a 05                	push   $0x5
f0104290:	eb 64                	jmp    f01042f6 <_alltraps>

f0104292 <illop_entry>:
TRAPHANDLER_NOEC(illop_entry, T_ILLOP);
f0104292:	6a 00                	push   $0x0
f0104294:	6a 06                	push   $0x6
f0104296:	eb 5e                	jmp    f01042f6 <_alltraps>

f0104298 <device_entry>:
TRAPHANDLER_NOEC(device_entry, T_DEVICE);
f0104298:	6a 00                	push   $0x0
f010429a:	6a 07                	push   $0x7
f010429c:	eb 58                	jmp    f01042f6 <_alltraps>

f010429e <dblflt_entry>:
TRAPHANDLER(dblflt_entry, T_DBLFLT);
f010429e:	6a 08                	push   $0x8
f01042a0:	eb 54                	jmp    f01042f6 <_alltraps>

f01042a2 <tss_entry>:
TRAPHANDLER(tss_entry, T_TSS);
f01042a2:	6a 0a                	push   $0xa
f01042a4:	eb 50                	jmp    f01042f6 <_alltraps>

f01042a6 <segnp_entry>:
TRAPHANDLER(segnp_entry, T_SEGNP);
f01042a6:	6a 0b                	push   $0xb
f01042a8:	eb 4c                	jmp    f01042f6 <_alltraps>

f01042aa <stack_entry>:
TRAPHANDLER(stack_entry, T_STACK);
f01042aa:	6a 0c                	push   $0xc
f01042ac:	eb 48                	jmp    f01042f6 <_alltraps>

f01042ae <gpflt_entry>:
TRAPHANDLER(gpflt_entry, T_GPFLT);
f01042ae:	6a 0d                	push   $0xd
f01042b0:	eb 44                	jmp    f01042f6 <_alltraps>

f01042b2 <pgflt_entry>:
TRAPHANDLER(pgflt_entry, T_PGFLT);
f01042b2:	6a 0e                	push   $0xe
f01042b4:	eb 40                	jmp    f01042f6 <_alltraps>

f01042b6 <fperr_entry>:
TRAPHANDLER_NOEC(fperr_entry, T_FPERR);
f01042b6:	6a 00                	push   $0x0
f01042b8:	6a 10                	push   $0x10
f01042ba:	eb 3a                	jmp    f01042f6 <_alltraps>

f01042bc <align_entry>:
TRAPHANDLER(align_entry, T_ALIGN);
f01042bc:	6a 11                	push   $0x11
f01042be:	eb 36                	jmp    f01042f6 <_alltraps>

f01042c0 <mchk_entry>:
TRAPHANDLER_NOEC(mchk_entry, T_MCHK);
f01042c0:	6a 00                	push   $0x0
f01042c2:	6a 12                	push   $0x12
f01042c4:	eb 30                	jmp    f01042f6 <_alltraps>

f01042c6 <simderr_entry>:
TRAPHANDLER_NOEC(simderr_entry, T_SIMDERR);
f01042c6:	6a 00                	push   $0x0
f01042c8:	6a 13                	push   $0x13
f01042ca:	eb 2a                	jmp    f01042f6 <_alltraps>

f01042cc <syscall_entry>:
TRAPHANDLER_NOEC(syscall_entry, T_SYSCALL);
f01042cc:	6a 00                	push   $0x0
f01042ce:	6a 30                	push   $0x30
f01042d0:	eb 24                	jmp    f01042f6 <_alltraps>

f01042d2 <timer_handler>:


TRAPHANDLER_NOEC(timer_handler, IRQ_OFFSET + IRQ_TIMER);
f01042d2:	6a 00                	push   $0x0
f01042d4:	6a 20                	push   $0x20
f01042d6:	eb 1e                	jmp    f01042f6 <_alltraps>

f01042d8 <kbd_handler>:
TRAPHANDLER_NOEC(kbd_handler, IRQ_OFFSET + IRQ_KBD);
f01042d8:	6a 00                	push   $0x0
f01042da:	6a 21                	push   $0x21
f01042dc:	eb 18                	jmp    f01042f6 <_alltraps>

f01042de <serial_handler>:
TRAPHANDLER_NOEC(serial_handler, IRQ_OFFSET + IRQ_SERIAL);
f01042de:	6a 00                	push   $0x0
f01042e0:	6a 24                	push   $0x24
f01042e2:	eb 12                	jmp    f01042f6 <_alltraps>

f01042e4 <spurious_handler>:
TRAPHANDLER_NOEC(spurious_handler, IRQ_OFFSET + IRQ_SPURIOUS);
f01042e4:	6a 00                	push   $0x0
f01042e6:	6a 27                	push   $0x27
f01042e8:	eb 0c                	jmp    f01042f6 <_alltraps>

f01042ea <ide_handler>:
TRAPHANDLER_NOEC(ide_handler, IRQ_OFFSET + IRQ_IDE);
f01042ea:	6a 00                	push   $0x0
f01042ec:	6a 2e                	push   $0x2e
f01042ee:	eb 06                	jmp    f01042f6 <_alltraps>

f01042f0 <error_handler>:
TRAPHANDLER_NOEC(error_handler, IRQ_OFFSET + IRQ_ERROR);
f01042f0:	6a 00                	push   $0x0
f01042f2:	6a 33                	push   $0x33
f01042f4:	eb 00                	jmp    f01042f6 <_alltraps>

f01042f6 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds
f01042f6:	1e                   	push   %ds
        pushl %es
f01042f7:	06                   	push   %es
        pushal
f01042f8:	60                   	pusha  

        movl $GD_KD, %eax
f01042f9:	b8 10 00 00 00       	mov    $0x10,%eax
        movl %eax, %ds
f01042fe:	8e d8                	mov    %eax,%ds
        movl %eax, %es
f0104300:	8e c0                	mov    %eax,%es

        push %esp
f0104302:	54                   	push   %esp
        call trap
f0104303:	e8 2c fd ff ff       	call   f0104034 <trap>

f0104308 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104308:	55                   	push   %ebp
f0104309:	89 e5                	mov    %esp,%ebp
f010430b:	83 ec 08             	sub    $0x8,%esp
f010430e:	a1 48 12 21 f0       	mov    0xf0211248,%eax
f0104313:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104316:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010431b:	8b 02                	mov    (%edx),%eax
f010431d:	83 e8 01             	sub    $0x1,%eax
f0104320:	83 f8 02             	cmp    $0x2,%eax
f0104323:	76 10                	jbe    f0104335 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104325:	83 c1 01             	add    $0x1,%ecx
f0104328:	83 c2 7c             	add    $0x7c,%edx
f010432b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104331:	75 e8                	jne    f010431b <sched_halt+0x13>
f0104333:	eb 08                	jmp    f010433d <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104335:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010433b:	75 1f                	jne    f010435c <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f010433d:	83 ec 0c             	sub    $0xc,%esp
f0104340:	68 10 79 10 f0       	push   $0xf0107910
f0104345:	e8 97 f4 ff ff       	call   f01037e1 <cprintf>
f010434a:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010434d:	83 ec 0c             	sub    $0xc,%esp
f0104350:	6a 00                	push   $0x0
f0104352:	e8 d7 c5 ff ff       	call   f010092e <monitor>
f0104357:	83 c4 10             	add    $0x10,%esp
f010435a:	eb f1                	jmp    f010434d <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010435c:	e8 1d 18 00 00       	call   f0105b7e <cpunum>
f0104361:	6b c0 74             	imul   $0x74,%eax,%eax
f0104364:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f010436b:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010436e:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104373:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104378:	77 12                	ja     f010438c <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010437a:	50                   	push   %eax
f010437b:	68 68 62 10 f0       	push   $0xf0106268
f0104380:	6a 4e                	push   $0x4e
f0104382:	68 39 79 10 f0       	push   $0xf0107939
f0104387:	e8 b4 bc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010438c:	05 00 00 00 10       	add    $0x10000000,%eax
f0104391:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104394:	e8 e5 17 00 00       	call   f0105b7e <cpunum>
f0104399:	6b d0 74             	imul   $0x74,%eax,%edx
f010439c:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01043a2:	b8 02 00 00 00       	mov    $0x2,%eax
f01043a7:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01043ab:	83 ec 0c             	sub    $0xc,%esp
f01043ae:	68 c0 03 12 f0       	push   $0xf01203c0
f01043b3:	e8 d1 1a 00 00       	call   f0105e89 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01043b8:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01043ba:	e8 bf 17 00 00       	call   f0105b7e <cpunum>
f01043bf:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01043c2:	8b 80 30 20 21 f0    	mov    -0xfdedfd0(%eax),%eax
f01043c8:	bd 00 00 00 00       	mov    $0x0,%ebp
f01043cd:	89 c4                	mov    %eax,%esp
f01043cf:	6a 00                	push   $0x0
f01043d1:	6a 00                	push   $0x0
f01043d3:	fb                   	sti    
f01043d4:	f4                   	hlt    
f01043d5:	eb fd                	jmp    f01043d4 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01043d7:	83 c4 10             	add    $0x10,%esp
f01043da:	c9                   	leave  
f01043db:	c3                   	ret    

f01043dc <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01043dc:	55                   	push   %ebp
f01043dd:	89 e5                	mov    %esp,%ebp
f01043df:	56                   	push   %esi
f01043e0:	53                   	push   %ebx
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
    struct Env *now = thiscpu->cpu_env;
f01043e1:	e8 98 17 00 00       	call   f0105b7e <cpunum>
f01043e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e9:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f01043ef:	85 c0                	test   %eax,%eax
f01043f1:	74 0b                	je     f01043fe <sched_yield+0x22>
f01043f3:	8b 50 48             	mov    0x48(%eax),%edx
f01043f6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01043fc:	eb 05                	jmp    f0104403 <sched_yield+0x27>
f01043fe:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;
    // 当前没有任何环境执行,应该从0开始查找
    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f0104403:	8b 0d 48 12 21 f0    	mov    0xf0211248,%ecx
f0104409:	89 d6                	mov    %edx,%esi
f010440b:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f0104411:	89 d0                	mov    %edx,%eax
f0104413:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104418:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010441b:	01 c8                	add    %ecx,%eax
f010441d:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104421:	75 09                	jne    f010442c <sched_yield+0x50>
                env_run(&envs[nextid]);
f0104423:	83 ec 0c             	sub    $0xc,%esp
f0104426:	50                   	push   %eax
f0104427:	e8 64 f1 ff ff       	call   f0103590 <env_run>
f010442c:	83 c2 01             	add    $0x1,%edx
    struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;
    // 当前没有任何环境执行,应该从0开始查找
    for(i = 0; i < NENV; i++) {
f010442f:	39 da                	cmp    %ebx,%edx
f0104431:	75 de                	jne    f0104411 <sched_yield+0x35>
                return;
            }
    }
    
    // 循环一圈后，没有可执行的环境
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f0104433:	6b f6 7c             	imul   $0x7c,%esi,%esi
f0104436:	01 f1                	add    %esi,%ecx
f0104438:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f010443c:	75 1b                	jne    f0104459 <sched_yield+0x7d>
f010443e:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f0104441:	e8 38 17 00 00       	call   f0105b7e <cpunum>
f0104446:	39 c3                	cmp    %eax,%ebx
f0104448:	75 0f                	jne    f0104459 <sched_yield+0x7d>
        env_run(&envs[startid]);
f010444a:	83 ec 0c             	sub    $0xc,%esp
f010444d:	03 35 48 12 21 f0    	add    0xf0211248,%esi
f0104453:	56                   	push   %esi
f0104454:	e8 37 f1 ff ff       	call   f0103590 <env_run>
    }
	// sched_halt never returns
	sched_halt();
f0104459:	e8 aa fe ff ff       	call   f0104308 <sched_halt>
}
f010445e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104461:	5b                   	pop    %ebx
f0104462:	5e                   	pop    %esi
f0104463:	5d                   	pop    %ebp
f0104464:	c3                   	ret    

f0104465 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104465:	55                   	push   %ebp
f0104466:	89 e5                	mov    %esp,%ebp
f0104468:	57                   	push   %edi
f0104469:	56                   	push   %esi
f010446a:	53                   	push   %ebx
f010446b:	83 ec 1c             	sub    $0x1c,%esp
f010446e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104471:	83 f8 0d             	cmp    $0xd,%eax
f0104474:	0f 87 35 05 00 00    	ja     f01049af <syscall+0x54a>
f010447a:	ff 24 85 4c 79 10 f0 	jmp    *-0xfef86b4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104481:	e8 f8 16 00 00       	call   f0105b7e <cpunum>
f0104486:	6a 00                	push   $0x0
f0104488:	ff 75 10             	pushl  0x10(%ebp)
f010448b:	ff 75 0c             	pushl  0xc(%ebp)
f010448e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104491:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104497:	e8 c0 e9 ff ff       	call   f0102e5c <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010449c:	83 c4 0c             	add    $0xc,%esp
f010449f:	ff 75 0c             	pushl  0xc(%ebp)
f01044a2:	ff 75 10             	pushl  0x10(%ebp)
f01044a5:	68 46 79 10 f0       	push   $0xf0107946
f01044aa:	e8 32 f3 ff ff       	call   f01037e1 <cprintf>
f01044af:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");

	switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, a2);
            return 0;
f01044b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044b7:	e9 ff 04 00 00       	jmp    f01049bb <syscall+0x556>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01044bc:	e8 34 c1 ff ff       	call   f01005f5 <cons_getc>
f01044c1:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, a2);
            return 0;
        case SYS_cgetc:
            return sys_cgetc();
f01044c3:	e9 f3 04 00 00       	jmp    f01049bb <syscall+0x556>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01044c8:	e8 b1 16 00 00       	call   f0105b7e <cpunum>
f01044cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d0:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01044d6:	8b 58 48             	mov    0x48(%eax),%ebx
            sys_cputs((char *)a1, a2);
            return 0;
        case SYS_cgetc:
            return sys_cgetc();
        case SYS_getenvid:
            return sys_getenvid();
f01044d9:	e9 dd 04 00 00       	jmp    f01049bb <syscall+0x556>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01044de:	83 ec 04             	sub    $0x4,%esp
f01044e1:	6a 01                	push   $0x1
f01044e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044e6:	50                   	push   %eax
f01044e7:	ff 75 0c             	pushl  0xc(%ebp)
f01044ea:	e8 3d ea ff ff       	call   f0102f2c <envid2env>
f01044ef:	83 c4 10             	add    $0x10,%esp
		return r;
f01044f2:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01044f4:	85 c0                	test   %eax,%eax
f01044f6:	0f 88 bf 04 00 00    	js     f01049bb <syscall+0x556>
		return r;
	env_destroy(e);
f01044fc:	83 ec 0c             	sub    $0xc,%esp
f01044ff:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104502:	e8 ea ef ff ff       	call   f01034f1 <env_destroy>
f0104507:	83 c4 10             	add    $0x10,%esp
	return 0;
f010450a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010450f:	e9 a7 04 00 00       	jmp    f01049bb <syscall+0x556>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104514:	e8 c3 fe ff ff       	call   f01043dc <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
    struct Env *newenv;
    int32_t ret = 0;
    if ((ret = env_alloc(&newenv, curenv->env_id)) < 0) {
f0104519:	e8 60 16 00 00       	call   f0105b7e <cpunum>
f010451e:	83 ec 08             	sub    $0x8,%esp
f0104521:	6b c0 74             	imul   $0x74,%eax,%eax
f0104524:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010452a:	ff 70 48             	pushl  0x48(%eax)
f010452d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104530:	50                   	push   %eax
f0104531:	e8 07 eb ff ff       	call   f010303d <env_alloc>
f0104536:	83 c4 10             	add    $0x10,%esp
        // 两个函数的返回值是一样的
        return ret;
f0104539:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
    struct Env *newenv;
    int32_t ret = 0;
    if ((ret = env_alloc(&newenv, curenv->env_id)) < 0) {
f010453b:	85 c0                	test   %eax,%eax
f010453d:	0f 88 78 04 00 00    	js     f01049bb <syscall+0x556>
        // 两个函数的返回值是一样的
        return ret;
    }
    newenv->env_status = ENV_NOT_RUNNABLE;
f0104543:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104546:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
    newenv->env_tf = curenv->env_tf;
f010454d:	e8 2c 16 00 00       	call   f0105b7e <cpunum>
f0104552:	6b c0 74             	imul   $0x74,%eax,%eax
f0104555:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f010455b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104560:	89 df                	mov    %ebx,%edi
f0104562:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    // newenv的返回值为0
    newenv->env_tf.tf_regs.reg_eax = 0;
f0104564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104567:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    
    return newenv->env_id;
f010456e:	8b 58 48             	mov    0x48(%eax),%ebx
f0104571:	e9 45 04 00 00       	jmp    f01049bb <syscall+0x556>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
    struct Env *e;
    if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f0104576:	83 ec 04             	sub    $0x4,%esp
f0104579:	6a 01                	push   $0x1
f010457b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010457e:	50                   	push   %eax
f010457f:	ff 75 0c             	pushl  0xc(%ebp)
f0104582:	e8 a5 e9 ff ff       	call   f0102f2c <envid2env>
f0104587:	89 c3                	mov    %eax,%ebx
f0104589:	83 c4 10             	add    $0x10,%esp
f010458c:	85 c0                	test   %eax,%eax
f010458e:	75 1b                	jne    f01045ab <syscall+0x146>
    
    if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f0104590:	8b 45 10             	mov    0x10(%ebp),%eax
f0104593:	83 e8 02             	sub    $0x2,%eax
f0104596:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010459b:	75 18                	jne    f01045b5 <syscall+0x150>
    
    e->env_status = status;
f010459d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01045a3:	89 48 54             	mov    %ecx,0x54(%eax)
f01045a6:	e9 10 04 00 00       	jmp    f01049bb <syscall+0x556>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
    struct Env *e;
    if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f01045ab:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01045b0:	e9 06 04 00 00       	jmp    f01049bb <syscall+0x556>
    
    if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f01045b5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
                return 0;
       
        case SYS_exofork:
            return sys_exofork();
        case SYS_env_set_status:
            return sys_env_set_status(a1, a2);
f01045ba:	e9 fc 03 00 00       	jmp    f01049bb <syscall+0x556>
    }
    return ret;*/
	int ret = 0;
	struct Env *env;
	
	if ((ret = envid2env(envid, &env, 1)) < 0) 
f01045bf:	83 ec 04             	sub    $0x4,%esp
f01045c2:	6a 01                	push   $0x1
f01045c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045c7:	50                   	push   %eax
f01045c8:	ff 75 0c             	pushl  0xc(%ebp)
f01045cb:	e8 5c e9 ff ff       	call   f0102f2c <envid2env>
f01045d0:	83 c4 10             	add    $0x10,%esp
f01045d3:	85 c0                	test   %eax,%eax
f01045d5:	78 5d                	js     f0104634 <syscall+0x1cf>
		return -E_BAD_ENV;
	
	if((uintptr_t)va >= UTOP || PGOFF(va))
f01045d7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01045de:	77 5e                	ja     f010463e <syscall+0x1d9>
f01045e0:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01045e7:	75 5f                	jne    f0104648 <syscall+0x1e3>
		return -E_INVAL;
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f01045e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01045ec:	83 e0 05             	and    $0x5,%eax
f01045ef:	83 f8 05             	cmp    $0x5,%eax
f01045f2:	75 5e                	jne    f0104652 <syscall+0x1ed>
        return -E_INVAL;
	if (perm & ~PTE_SYSCALL)
f01045f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01045f7:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01045fd:	75 5d                	jne    f010465c <syscall+0x1f7>
		return -E_INVAL;
	
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01045ff:	83 ec 0c             	sub    $0xc,%esp
f0104602:	6a 01                	push   $0x1
f0104604:	e8 bc c9 ff ff       	call   f0100fc5 <page_alloc>
	if(!pp) 
f0104609:	83 c4 10             	add    $0x10,%esp
f010460c:	85 c0                	test   %eax,%eax
f010460e:	74 56                	je     f0104666 <syscall+0x201>
		return -E_NO_MEM;
	
	if (page_insert(env->env_pgdir, pp, va, perm) < 0)
f0104610:	ff 75 14             	pushl  0x14(%ebp)
f0104613:	ff 75 10             	pushl  0x10(%ebp)
f0104616:	50                   	push   %eax
f0104617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010461a:	ff 70 60             	pushl  0x60(%eax)
f010461d:	e8 bf cc ff ff       	call   f01012e1 <page_insert>
f0104622:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104625:	85 c0                	test   %eax,%eax
f0104627:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010462c:	0f 48 d8             	cmovs  %eax,%ebx
f010462f:	e9 87 03 00 00       	jmp    f01049bb <syscall+0x556>
    return ret;*/
	int ret = 0;
	struct Env *env;
	
	if ((ret = envid2env(envid, &env, 1)) < 0) 
		return -E_BAD_ENV;
f0104634:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104639:	e9 7d 03 00 00       	jmp    f01049bb <syscall+0x556>
	
	if((uintptr_t)va >= UTOP || PGOFF(va))
		return -E_INVAL;
f010463e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104643:	e9 73 03 00 00       	jmp    f01049bb <syscall+0x556>
f0104648:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010464d:	e9 69 03 00 00       	jmp    f01049bb <syscall+0x556>
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
        return -E_INVAL;
f0104652:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104657:	e9 5f 03 00 00       	jmp    f01049bb <syscall+0x556>
	if (perm & ~PTE_SYSCALL)
		return -E_INVAL;
f010465c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104661:	e9 55 03 00 00       	jmp    f01049bb <syscall+0x556>
	
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if(!pp) 
		return -E_NO_MEM;
f0104666:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010466b:	e9 4b 03 00 00       	jmp    f01049bb <syscall+0x556>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
    struct Env *srcenv, *dstenv;
    if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &dstenv, 1)) {
f0104670:	83 ec 04             	sub    $0x4,%esp
f0104673:	6a 01                	push   $0x1
f0104675:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104678:	50                   	push   %eax
f0104679:	ff 75 0c             	pushl  0xc(%ebp)
f010467c:	e8 ab e8 ff ff       	call   f0102f2c <envid2env>
f0104681:	83 c4 10             	add    $0x10,%esp
f0104684:	85 c0                	test   %eax,%eax
f0104686:	0f 85 88 00 00 00    	jne    f0104714 <syscall+0x2af>
f010468c:	83 ec 04             	sub    $0x4,%esp
f010468f:	6a 01                	push   $0x1
f0104691:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104694:	50                   	push   %eax
f0104695:	ff 75 14             	pushl  0x14(%ebp)
f0104698:	e8 8f e8 ff ff       	call   f0102f2c <envid2env>
f010469d:	83 c4 10             	add    $0x10,%esp
f01046a0:	85 c0                	test   %eax,%eax
f01046a2:	75 7a                	jne    f010471e <syscall+0x2b9>
        return -E_BAD_ENV;
    }

    if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || PGOFF(srcva) || PGOFF(dstva)) {
f01046a4:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046ab:	77 7b                	ja     f0104728 <syscall+0x2c3>
f01046ad:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01046b4:	77 72                	ja     f0104728 <syscall+0x2c3>
f01046b6:	8b 45 10             	mov    0x10(%ebp),%eax
f01046b9:	0b 45 18             	or     0x18(%ebp),%eax
f01046bc:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01046c1:	75 6f                	jne    f0104732 <syscall+0x2cd>
        return -E_INVAL;
    }

    pte_t *pte;
    struct PageInfo *p = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01046c3:	83 ec 04             	sub    $0x4,%esp
f01046c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046c9:	50                   	push   %eax
f01046ca:	ff 75 10             	pushl  0x10(%ebp)
f01046cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046d0:	ff 70 60             	pushl  0x60(%eax)
f01046d3:	e8 29 cb ff ff       	call   f0101201 <page_lookup>
    if (!p) return -E_INVAL;
f01046d8:	83 c4 10             	add    $0x10,%esp
f01046db:	85 c0                	test   %eax,%eax
f01046dd:	74 5d                	je     f010473c <syscall+0x2d7>

    int valid_perm = (PTE_U|PTE_P);
    if ((perm&valid_perm) != valid_perm) return -E_INVAL;
f01046df:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01046e2:	83 e2 05             	and    $0x5,%edx
f01046e5:	83 fa 05             	cmp    $0x5,%edx
f01046e8:	75 5c                	jne    f0104746 <syscall+0x2e1>

    if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f01046ea:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01046ee:	74 08                	je     f01046f8 <syscall+0x293>
f01046f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046f3:	f6 02 02             	testb  $0x2,(%edx)
f01046f6:	74 58                	je     f0104750 <syscall+0x2eb>

    int ret = page_insert(dstenv->env_pgdir, p, dstva, perm);
f01046f8:	ff 75 1c             	pushl  0x1c(%ebp)
f01046fb:	ff 75 18             	pushl  0x18(%ebp)
f01046fe:	50                   	push   %eax
f01046ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104702:	ff 70 60             	pushl  0x60(%eax)
f0104705:	e8 d7 cb ff ff       	call   f01012e1 <page_insert>
f010470a:	83 c4 10             	add    $0x10,%esp
    return ret;
f010470d:	89 c3                	mov    %eax,%ebx
f010470f:	e9 a7 02 00 00       	jmp    f01049bb <syscall+0x556>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
    struct Env *srcenv, *dstenv;
    if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &dstenv, 1)) {
        return -E_BAD_ENV;
f0104714:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104719:	e9 9d 02 00 00       	jmp    f01049bb <syscall+0x556>
f010471e:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104723:	e9 93 02 00 00       	jmp    f01049bb <syscall+0x556>
    }

    if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || PGOFF(srcva) || PGOFF(dstva)) {
        return -E_INVAL;
f0104728:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010472d:	e9 89 02 00 00       	jmp    f01049bb <syscall+0x556>
f0104732:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104737:	e9 7f 02 00 00       	jmp    f01049bb <syscall+0x556>
    }

    pte_t *pte;
    struct PageInfo *p = page_lookup(srcenv->env_pgdir, srcva, &pte);
    if (!p) return -E_INVAL;
f010473c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104741:	e9 75 02 00 00       	jmp    f01049bb <syscall+0x556>

    int valid_perm = (PTE_U|PTE_P);
    if ((perm&valid_perm) != valid_perm) return -E_INVAL;
f0104746:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010474b:	e9 6b 02 00 00       	jmp    f01049bb <syscall+0x556>

    if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0104750:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_env_set_status:
            return sys_env_set_status(a1, a2);
        case SYS_page_alloc:
            return sys_page_alloc(a1, (void *)a2, a3);
        case SYS_page_map:
            return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104755:	e9 61 02 00 00       	jmp    f01049bb <syscall+0x556>

	// LAB 4: Your code here.
    int ret = 0;
    struct Env *env;
    
    if ((ret = envid2env(envid, &env, 1)) < 0)
f010475a:	83 ec 04             	sub    $0x4,%esp
f010475d:	6a 01                	push   $0x1
f010475f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104762:	50                   	push   %eax
f0104763:	ff 75 0c             	pushl  0xc(%ebp)
f0104766:	e8 c1 e7 ff ff       	call   f0102f2c <envid2env>
f010476b:	83 c4 10             	add    $0x10,%esp
f010476e:	85 c0                	test   %eax,%eax
f0104770:	78 30                	js     f01047a2 <syscall+0x33d>
        return -E_BAD_ENV;
    if ((uintptr_t)va >= UTOP || PGOFF(va))
f0104772:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104779:	77 31                	ja     f01047ac <syscall+0x347>
f010477b:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104782:	75 32                	jne    f01047b6 <syscall+0x351>
        return -E_INVAL;
    page_remove(env->env_pgdir, va);
f0104784:	83 ec 08             	sub    $0x8,%esp
f0104787:	ff 75 10             	pushl  0x10(%ebp)
f010478a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010478d:	ff 70 60             	pushl  0x60(%eax)
f0104790:	e8 06 cb ff ff       	call   f010129b <page_remove>
f0104795:	83 c4 10             	add    $0x10,%esp
    return 0;
f0104798:	bb 00 00 00 00       	mov    $0x0,%ebx
f010479d:	e9 19 02 00 00       	jmp    f01049bb <syscall+0x556>
	// LAB 4: Your code here.
    int ret = 0;
    struct Env *env;
    
    if ((ret = envid2env(envid, &env, 1)) < 0)
        return -E_BAD_ENV;
f01047a2:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01047a7:	e9 0f 02 00 00       	jmp    f01049bb <syscall+0x556>
    if ((uintptr_t)va >= UTOP || PGOFF(va))
        return -E_INVAL;
f01047ac:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047b1:	e9 05 02 00 00       	jmp    f01049bb <syscall+0x556>
f01047b6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_page_alloc:
            return sys_page_alloc(a1, (void *)a2, a3);
        case SYS_page_map:
            return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
        case SYS_page_unmap:
            return sys_page_unmap(a1, (void *)a2);
f01047bb:	e9 fb 01 00 00       	jmp    f01049bb <syscall+0x556>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
    struct Env *e;
    if (envid2env(envid, &e, 1))
f01047c0:	83 ec 04             	sub    $0x4,%esp
f01047c3:	6a 01                	push   $0x1
f01047c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047c8:	50                   	push   %eax
f01047c9:	ff 75 0c             	pushl  0xc(%ebp)
f01047cc:	e8 5b e7 ff ff       	call   f0102f2c <envid2env>
f01047d1:	89 c3                	mov    %eax,%ebx
f01047d3:	83 c4 10             	add    $0x10,%esp
f01047d6:	85 c0                	test   %eax,%eax
f01047d8:	75 0e                	jne    f01047e8 <syscall+0x383>
        return -E_BAD_ENV;

    e->env_pgfault_upcall = func;
f01047da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047dd:	8b 7d 10             	mov    0x10(%ebp),%edi
f01047e0:	89 78 64             	mov    %edi,0x64(%eax)
f01047e3:	e9 d3 01 00 00       	jmp    f01049bb <syscall+0x556>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
    struct Env *e;
    if (envid2env(envid, &e, 1))
        return -E_BAD_ENV;
f01047e8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
        case SYS_page_map:
            return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
        case SYS_page_unmap:
            return sys_page_unmap(a1, (void *)a2);
        case SYS_env_set_pgfault_upcall:
            return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
f01047ed:	e9 c9 01 00 00       	jmp    f01049bb <syscall+0x556>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
    // LAB 4: Your code here.
    struct Env *e;
    if (envid2env(envid, &e, 0)) return -E_BAD_ENV;
f01047f2:	83 ec 04             	sub    $0x4,%esp
f01047f5:	6a 00                	push   $0x0
f01047f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01047fa:	50                   	push   %eax
f01047fb:	ff 75 0c             	pushl  0xc(%ebp)
f01047fe:	e8 29 e7 ff ff       	call   f0102f2c <envid2env>
f0104803:	89 c3                	mov    %eax,%ebx
f0104805:	83 c4 10             	add    $0x10,%esp
f0104808:	85 c0                	test   %eax,%eax
f010480a:	0f 85 f6 00 00 00    	jne    f0104906 <syscall+0x4a1>

    if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104810:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104813:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104817:	0f 84 f3 00 00 00    	je     f0104910 <syscall+0x4ab>

    if (srcva < (void *) UTOP) {
f010481d:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104824:	0f 87 a5 00 00 00    	ja     f01048cf <syscall+0x46a>
        if(PGOFF(srcva)) return -E_INVAL;
f010482a:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104831:	75 6d                	jne    f01048a0 <syscall+0x43b>

        pte_t *pte;
        struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104833:	e8 46 13 00 00       	call   f0105b7e <cpunum>
f0104838:	83 ec 04             	sub    $0x4,%esp
f010483b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010483e:	52                   	push   %edx
f010483f:	ff 75 14             	pushl  0x14(%ebp)
f0104842:	6b c0 74             	imul   $0x74,%eax,%eax
f0104845:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010484b:	ff 70 60             	pushl  0x60(%eax)
f010484e:	e8 ae c9 ff ff       	call   f0101201 <page_lookup>
        if (!p) return -E_INVAL;
f0104853:	83 c4 10             	add    $0x10,%esp
f0104856:	85 c0                	test   %eax,%eax
f0104858:	74 50                	je     f01048aa <syscall+0x445>

        // if ((*pte & perm) != perm) return -E_INVAL;--------------
	int valid_perm = (PTE_U|PTE_P);
	if ((perm & valid_perm) != valid_perm) {
f010485a:	8b 55 18             	mov    0x18(%ebp),%edx
f010485d:	83 e2 05             	and    $0x5,%edx
f0104860:	83 fa 05             	cmp    $0x5,%edx
f0104863:	75 4f                	jne    f01048b4 <syscall+0x44f>
		return -E_INVAL;
	}
	//------------------------------------------

        if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0104865:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104869:	74 08                	je     f0104873 <syscall+0x40e>
f010486b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010486e:	f6 02 02             	testb  $0x2,(%edx)
f0104871:	74 4b                	je     f01048be <syscall+0x459>

        if (e->env_ipc_dstva < (void *)UTOP) {
f0104873:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104876:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104879:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010487f:	77 4e                	ja     f01048cf <syscall+0x46a>
            int ret = page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm);
f0104881:	ff 75 18             	pushl  0x18(%ebp)
f0104884:	51                   	push   %ecx
f0104885:	50                   	push   %eax
f0104886:	ff 72 60             	pushl  0x60(%edx)
f0104889:	e8 53 ca ff ff       	call   f01012e1 <page_insert>
            if (ret) return ret;
f010488e:	83 c4 10             	add    $0x10,%esp
f0104891:	85 c0                	test   %eax,%eax
f0104893:	75 33                	jne    f01048c8 <syscall+0x463>
            e->env_ipc_perm = perm;
f0104895:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104898:	8b 4d 18             	mov    0x18(%ebp),%ecx
f010489b:	89 48 78             	mov    %ecx,0x78(%eax)
f010489e:	eb 2f                	jmp    f01048cf <syscall+0x46a>
    if (envid2env(envid, &e, 0)) return -E_BAD_ENV;

    if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;

    if (srcva < (void *) UTOP) {
        if(PGOFF(srcva)) return -E_INVAL;
f01048a0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048a5:	e9 11 01 00 00       	jmp    f01049bb <syscall+0x556>

        pte_t *pte;
        struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, &pte);
        if (!p) return -E_INVAL;
f01048aa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048af:	e9 07 01 00 00       	jmp    f01049bb <syscall+0x556>

        // if ((*pte & perm) != perm) return -E_INVAL;--------------
	int valid_perm = (PTE_U|PTE_P);
	if ((perm & valid_perm) != valid_perm) {
		return -E_INVAL;
f01048b4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048b9:	e9 fd 00 00 00       	jmp    f01049bb <syscall+0x556>
	}
	//------------------------------------------

        if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f01048be:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048c3:	e9 f3 00 00 00       	jmp    f01049bb <syscall+0x556>

        if (e->env_ipc_dstva < (void *)UTOP) {
            int ret = page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm);
            if (ret) return ret;
f01048c8:	89 c3                	mov    %eax,%ebx
f01048ca:	e9 ec 00 00 00       	jmp    f01049bb <syscall+0x556>
            e->env_ipc_perm = perm;
        }
    }

    e->env_ipc_recving = 0;
f01048cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048d2:	c6 46 68 00          	movb   $0x0,0x68(%esi)
    e->env_ipc_from = curenv->env_id;
f01048d6:	e8 a3 12 00 00       	call   f0105b7e <cpunum>
f01048db:	6b c0 74             	imul   $0x74,%eax,%eax
f01048de:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01048e4:	8b 40 48             	mov    0x48(%eax),%eax
f01048e7:	89 46 74             	mov    %eax,0x74(%esi)
    e->env_ipc_value = value;
f01048ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048ed:	8b 7d 10             	mov    0x10(%ebp),%edi
f01048f0:	89 78 70             	mov    %edi,0x70(%eax)
    e->env_status = ENV_RUNNABLE;
f01048f3:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    e->env_tf.tf_regs.reg_eax = 0;
f01048fa:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104901:	e9 b5 00 00 00       	jmp    f01049bb <syscall+0x556>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
    // LAB 4: Your code here.
    struct Env *e;
    if (envid2env(envid, &e, 0)) return -E_BAD_ENV;
f0104906:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010490b:	e9 ab 00 00 00       	jmp    f01049bb <syscall+0x556>

    if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104910:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
            return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
        
            
        // ipc
        case SYS_ipc_try_send:
                return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104915:	e9 a1 00 00 00       	jmp    f01049bb <syscall+0x556>
static int
sys_ipc_recv(void *dstva)
{
    // LAB 4: Your code here.
    //panic("sys_ipc_recv not implemented");
    if ((dstva < (void *)UTOP) && PGOFF(dstva))
f010491a:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104921:	77 0d                	ja     f0104930 <syscall+0x4cb>
f0104923:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010492a:	0f 85 86 00 00 00    	jne    f01049b6 <syscall+0x551>
            return -E_INVAL;

    curenv->env_ipc_recving = 1;
f0104930:	e8 49 12 00 00       	call   f0105b7e <cpunum>
f0104935:	6b c0 74             	imul   $0x74,%eax,%eax
f0104938:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010493e:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0104942:	e8 37 12 00 00       	call   f0105b7e <cpunum>
f0104947:	6b c0 74             	imul   $0x74,%eax,%eax
f010494a:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104950:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    curenv->env_ipc_dstva = dstva;
f0104957:	e8 22 12 00 00       	call   f0105b7e <cpunum>
f010495c:	6b c0 74             	imul   $0x74,%eax,%eax
f010495f:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104965:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104968:	89 48 6c             	mov    %ecx,0x6c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010496b:	e8 6c fa ff ff       	call   f01043dc <sched_yield>
                return sys_ipc_try_send(a1, a2, (void *)a3, a4);
        case SYS_ipc_recv:
                return sys_ipc_recv((void *)a1);
	//fs
	case SYS_env_set_trapframe:
            return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f0104970:	8b 75 10             	mov    0x10(%ebp),%esi
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
    	struct Env *e;
	if (envid2env(envid, &e, 1)) {
f0104973:	83 ec 04             	sub    $0x4,%esp
f0104976:	6a 01                	push   $0x1
f0104978:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010497b:	50                   	push   %eax
f010497c:	ff 75 0c             	pushl  0xc(%ebp)
f010497f:	e8 a8 e5 ff ff       	call   f0102f2c <envid2env>
f0104984:	89 c3                	mov    %eax,%ebx
f0104986:	83 c4 10             	add    $0x10,%esp
f0104989:	85 c0                	test   %eax,%eax
f010498b:	75 1b                	jne    f01049a8 <syscall+0x543>
		return -E_BAD_ENV;
	}

	e->env_tf = *tf;
f010498d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104992:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
f0104997:	8b 55 e4             	mov    -0x1c(%ebp),%edx
	e->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f010499a:	8b 42 38             	mov    0x38(%edx),%eax
f010499d:	80 e4 cf             	and    $0xcf,%ah
f01049a0:	80 cc 02             	or     $0x2,%ah
f01049a3:	89 42 38             	mov    %eax,0x38(%edx)
f01049a6:	eb 13                	jmp    f01049bb <syscall+0x556>
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
    	struct Env *e;
	if (envid2env(envid, &e, 1)) {
		return -E_BAD_ENV;
f01049a8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
                return sys_ipc_try_send(a1, a2, (void *)a3, a4);
        case SYS_ipc_recv:
                return sys_ipc_recv((void *)a1);
	//fs
	case SYS_env_set_trapframe:
            return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f01049ad:	eb 0c                	jmp    f01049bb <syscall+0x556>
        
	default:
            return -E_INVAL;
f01049af:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049b4:	eb 05                	jmp    f01049bb <syscall+0x556>
            
        // ipc
        case SYS_ipc_try_send:
                return sys_ipc_try_send(a1, a2, (void *)a3, a4);
        case SYS_ipc_recv:
                return sys_ipc_recv((void *)a1);
f01049b6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
            return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
        
	default:
            return -E_INVAL;
	}
}
f01049bb:	89 d8                	mov    %ebx,%eax
f01049bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049c0:	5b                   	pop    %ebx
f01049c1:	5e                   	pop    %esi
f01049c2:	5f                   	pop    %edi
f01049c3:	5d                   	pop    %ebp
f01049c4:	c3                   	ret    

f01049c5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01049c5:	55                   	push   %ebp
f01049c6:	89 e5                	mov    %esp,%ebp
f01049c8:	57                   	push   %edi
f01049c9:	56                   	push   %esi
f01049ca:	53                   	push   %ebx
f01049cb:	83 ec 14             	sub    $0x14,%esp
f01049ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01049d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01049d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01049d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01049da:	8b 1a                	mov    (%edx),%ebx
f01049dc:	8b 01                	mov    (%ecx),%eax
f01049de:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01049e1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01049e8:	eb 7f                	jmp    f0104a69 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01049ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01049ed:	01 d8                	add    %ebx,%eax
f01049ef:	89 c6                	mov    %eax,%esi
f01049f1:	c1 ee 1f             	shr    $0x1f,%esi
f01049f4:	01 c6                	add    %eax,%esi
f01049f6:	d1 fe                	sar    %esi
f01049f8:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01049fb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01049fe:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104a01:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a03:	eb 03                	jmp    f0104a08 <stab_binsearch+0x43>
			m--;
f0104a05:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a08:	39 c3                	cmp    %eax,%ebx
f0104a0a:	7f 0d                	jg     f0104a19 <stab_binsearch+0x54>
f0104a0c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104a10:	83 ea 0c             	sub    $0xc,%edx
f0104a13:	39 f9                	cmp    %edi,%ecx
f0104a15:	75 ee                	jne    f0104a05 <stab_binsearch+0x40>
f0104a17:	eb 05                	jmp    f0104a1e <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104a19:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104a1c:	eb 4b                	jmp    f0104a69 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104a1e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a21:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a24:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104a28:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104a2b:	76 11                	jbe    f0104a3e <stab_binsearch+0x79>
			*region_left = m;
f0104a2d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104a30:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104a32:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a35:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a3c:	eb 2b                	jmp    f0104a69 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104a3e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104a41:	73 14                	jae    f0104a57 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104a43:	83 e8 01             	sub    $0x1,%eax
f0104a46:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a49:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104a4c:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a4e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a55:	eb 12                	jmp    f0104a69 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104a57:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a5a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104a5c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104a60:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a62:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104a69:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104a6c:	0f 8e 78 ff ff ff    	jle    f01049ea <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104a72:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104a76:	75 0f                	jne    f0104a87 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104a78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a7b:	8b 00                	mov    (%eax),%eax
f0104a7d:	83 e8 01             	sub    $0x1,%eax
f0104a80:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104a83:	89 06                	mov    %eax,(%esi)
f0104a85:	eb 2c                	jmp    f0104ab3 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104a87:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a8a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104a8c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a8f:	8b 0e                	mov    (%esi),%ecx
f0104a91:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a94:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104a97:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104a9a:	eb 03                	jmp    f0104a9f <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104a9c:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104a9f:	39 c8                	cmp    %ecx,%eax
f0104aa1:	7e 0b                	jle    f0104aae <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104aa3:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104aa7:	83 ea 0c             	sub    $0xc,%edx
f0104aaa:	39 df                	cmp    %ebx,%edi
f0104aac:	75 ee                	jne    f0104a9c <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104aae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ab1:	89 06                	mov    %eax,(%esi)
	}
}
f0104ab3:	83 c4 14             	add    $0x14,%esp
f0104ab6:	5b                   	pop    %ebx
f0104ab7:	5e                   	pop    %esi
f0104ab8:	5f                   	pop    %edi
f0104ab9:	5d                   	pop    %ebp
f0104aba:	c3                   	ret    

f0104abb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104abb:	55                   	push   %ebp
f0104abc:	89 e5                	mov    %esp,%ebp
f0104abe:	57                   	push   %edi
f0104abf:	56                   	push   %esi
f0104ac0:	53                   	push   %ebx
f0104ac1:	83 ec 3c             	sub    $0x3c,%esp
f0104ac4:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ac7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104aca:	c7 03 84 79 10 f0    	movl   $0xf0107984,(%ebx)
	info->eip_line = 0;
f0104ad0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104ad7:	c7 43 08 84 79 10 f0 	movl   $0xf0107984,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104ade:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104ae5:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104ae8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104aef:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104af5:	0f 87 96 00 00 00    	ja     f0104b91 <debuginfo_eip+0xd6>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
   		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104afb:	e8 7e 10 00 00       	call   f0105b7e <cpunum>
f0104b00:	6a 04                	push   $0x4
f0104b02:	6a 10                	push   $0x10
f0104b04:	68 00 00 20 00       	push   $0x200000
f0104b09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0c:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104b12:	e8 c3 e2 ff ff       	call   f0102dda <user_mem_check>
f0104b17:	83 c4 10             	add    $0x10,%esp
f0104b1a:	85 c0                	test   %eax,%eax
f0104b1c:	0f 85 39 02 00 00    	jne    f0104d5b <debuginfo_eip+0x2a0>
        		return -1;
		stabs = usd->stabs;
f0104b22:	a1 00 00 20 00       	mov    0x200000,%eax
f0104b27:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104b2a:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104b30:	a1 08 00 20 00       	mov    0x200008,%eax
f0104b35:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104b38:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104b3e:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	        if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104b41:	e8 38 10 00 00       	call   f0105b7e <cpunum>
f0104b46:	6a 04                	push   $0x4
f0104b48:	6a 0c                	push   $0xc
f0104b4a:	ff 75 c0             	pushl  -0x40(%ebp)
f0104b4d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b50:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104b56:	e8 7f e2 ff ff       	call   f0102dda <user_mem_check>
f0104b5b:	83 c4 10             	add    $0x10,%esp
f0104b5e:	85 c0                	test   %eax,%eax
f0104b60:	0f 85 fc 01 00 00    	jne    f0104d62 <debuginfo_eip+0x2a7>
			return -1;

	        if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104b66:	e8 13 10 00 00       	call   f0105b7e <cpunum>
f0104b6b:	6a 04                	push   $0x4
f0104b6d:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104b70:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104b73:	29 ca                	sub    %ecx,%edx
f0104b75:	52                   	push   %edx
f0104b76:	51                   	push   %ecx
f0104b77:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7a:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104b80:	e8 55 e2 ff ff       	call   f0102dda <user_mem_check>
f0104b85:	83 c4 10             	add    $0x10,%esp
f0104b88:	85 c0                	test   %eax,%eax
f0104b8a:	74 1f                	je     f0104bab <debuginfo_eip+0xf0>
f0104b8c:	e9 d8 01 00 00       	jmp    f0104d69 <debuginfo_eip+0x2ae>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104b91:	c7 45 bc 84 59 11 f0 	movl   $0xf0115984,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104b98:	c7 45 b8 2d 22 11 f0 	movl   $0xf011222d,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104b9f:	bf 2c 22 11 f0       	mov    $0xf011222c,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104ba4:	c7 45 c0 30 7f 10 f0 	movl   $0xf0107f30,-0x40(%ebp)
	        if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
		}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104bab:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104bae:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104bb1:	0f 83 b9 01 00 00    	jae    f0104d70 <debuginfo_eip+0x2b5>
f0104bb7:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104bbb:	0f 85 b6 01 00 00    	jne    f0104d77 <debuginfo_eip+0x2bc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104bc1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104bc8:	2b 7d c0             	sub    -0x40(%ebp),%edi
f0104bcb:	c1 ff 02             	sar    $0x2,%edi
f0104bce:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104bd4:	83 e8 01             	sub    $0x1,%eax
f0104bd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104bda:	83 ec 08             	sub    $0x8,%esp
f0104bdd:	56                   	push   %esi
f0104bde:	6a 64                	push   $0x64
f0104be0:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104be3:	89 d1                	mov    %edx,%ecx
f0104be5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104be8:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104beb:	89 f8                	mov    %edi,%eax
f0104bed:	e8 d3 fd ff ff       	call   f01049c5 <stab_binsearch>
	if (lfile == 0)
f0104bf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bf5:	83 c4 10             	add    $0x10,%esp
f0104bf8:	85 c0                	test   %eax,%eax
f0104bfa:	0f 84 7e 01 00 00    	je     f0104d7e <debuginfo_eip+0x2c3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c00:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c06:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c09:	83 ec 08             	sub    $0x8,%esp
f0104c0c:	56                   	push   %esi
f0104c0d:	6a 24                	push   $0x24
f0104c0f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104c12:	89 d1                	mov    %edx,%ecx
f0104c14:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c17:	89 f8                	mov    %edi,%eax
f0104c19:	e8 a7 fd ff ff       	call   f01049c5 <stab_binsearch>

	if (lfun <= rfun) {
f0104c1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c21:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c24:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104c27:	83 c4 10             	add    $0x10,%esp
f0104c2a:	39 d0                	cmp    %edx,%eax
f0104c2c:	7f 2b                	jg     f0104c59 <debuginfo_eip+0x19e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104c2e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c31:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104c34:	8b 11                	mov    (%ecx),%edx
f0104c36:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104c39:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0104c3c:	39 fa                	cmp    %edi,%edx
f0104c3e:	73 06                	jae    f0104c46 <debuginfo_eip+0x18b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104c40:	03 55 b8             	add    -0x48(%ebp),%edx
f0104c43:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104c46:	8b 51 08             	mov    0x8(%ecx),%edx
f0104c49:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104c4c:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104c4e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104c51:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104c54:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104c57:	eb 0f                	jmp    f0104c68 <debuginfo_eip+0x1ad>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104c59:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104c5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c65:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104c68:	83 ec 08             	sub    $0x8,%esp
f0104c6b:	6a 3a                	push   $0x3a
f0104c6d:	ff 73 08             	pushl  0x8(%ebx)
f0104c70:	e8 cd 08 00 00       	call   f0105542 <strfind>
f0104c75:	2b 43 08             	sub    0x8(%ebx),%eax
f0104c78:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104c7b:	83 c4 08             	add    $0x8,%esp
f0104c7e:	56                   	push   %esi
f0104c7f:	6a 44                	push   $0x44
f0104c81:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104c84:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104c87:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104c8a:	89 f0                	mov    %esi,%eax
f0104c8c:	e8 34 fd ff ff       	call   f01049c5 <stab_binsearch>
	if (lline <= rline) {
f0104c91:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104c94:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104c97:	83 c4 10             	add    $0x10,%esp
f0104c9a:	39 c2                	cmp    %eax,%edx
f0104c9c:	0f 8f e3 00 00 00    	jg     f0104d85 <debuginfo_eip+0x2ca>
   	 info->eip_line = stabs[rline].n_desc;
f0104ca2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104ca5:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104caa:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104cad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cb0:	89 d0                	mov    %edx,%eax
f0104cb2:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104cb5:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104cb8:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104cbc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104cbf:	eb 0a                	jmp    f0104ccb <debuginfo_eip+0x210>
f0104cc1:	83 e8 01             	sub    $0x1,%eax
f0104cc4:	83 ea 0c             	sub    $0xc,%edx
f0104cc7:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ccb:	39 c7                	cmp    %eax,%edi
f0104ccd:	7e 05                	jle    f0104cd4 <debuginfo_eip+0x219>
f0104ccf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cd2:	eb 47                	jmp    f0104d1b <debuginfo_eip+0x260>
	       && stabs[lline].n_type != N_SOL
f0104cd4:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104cd8:	80 f9 84             	cmp    $0x84,%cl
f0104cdb:	75 0e                	jne    f0104ceb <debuginfo_eip+0x230>
f0104cdd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ce0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ce4:	74 1c                	je     f0104d02 <debuginfo_eip+0x247>
f0104ce6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ce9:	eb 17                	jmp    f0104d02 <debuginfo_eip+0x247>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ceb:	80 f9 64             	cmp    $0x64,%cl
f0104cee:	75 d1                	jne    f0104cc1 <debuginfo_eip+0x206>
f0104cf0:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104cf4:	74 cb                	je     f0104cc1 <debuginfo_eip+0x206>
f0104cf6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cf9:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104cfd:	74 03                	je     f0104d02 <debuginfo_eip+0x247>
f0104cff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d02:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d05:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d08:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104d0b:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d0e:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104d11:	29 f8                	sub    %edi,%eax
f0104d13:	39 c2                	cmp    %eax,%edx
f0104d15:	73 04                	jae    f0104d1b <debuginfo_eip+0x260>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104d17:	01 fa                	add    %edi,%edx
f0104d19:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d1e:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d21:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d26:	39 f2                	cmp    %esi,%edx
f0104d28:	7d 67                	jge    f0104d91 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
f0104d2a:	83 c2 01             	add    $0x1,%edx
f0104d2d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104d30:	89 d0                	mov    %edx,%eax
f0104d32:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104d35:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d38:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104d3b:	eb 04                	jmp    f0104d41 <debuginfo_eip+0x286>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104d3d:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104d41:	39 c6                	cmp    %eax,%esi
f0104d43:	7e 47                	jle    f0104d8c <debuginfo_eip+0x2d1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104d45:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d49:	83 c0 01             	add    $0x1,%eax
f0104d4c:	83 c2 0c             	add    $0xc,%edx
f0104d4f:	80 f9 a0             	cmp    $0xa0,%cl
f0104d52:	74 e9                	je     f0104d3d <debuginfo_eip+0x282>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d54:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d59:	eb 36                	jmp    f0104d91 <debuginfo_eip+0x2d6>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
   		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
        		return -1;
f0104d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d60:	eb 2f                	jmp    f0104d91 <debuginfo_eip+0x2d6>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	        if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0104d62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d67:	eb 28                	jmp    f0104d91 <debuginfo_eip+0x2d6>

	        if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0104d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d6e:	eb 21                	jmp    f0104d91 <debuginfo_eip+0x2d6>
		}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d75:	eb 1a                	jmp    f0104d91 <debuginfo_eip+0x2d6>
f0104d77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d7c:	eb 13                	jmp    f0104d91 <debuginfo_eip+0x2d6>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104d7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d83:	eb 0c                	jmp    f0104d91 <debuginfo_eip+0x2d6>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
   	 info->eip_line = stabs[rline].n_desc;
	} else {
   	 return -1;
f0104d85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d8a:	eb 05                	jmp    f0104d91 <debuginfo_eip+0x2d6>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d94:	5b                   	pop    %ebx
f0104d95:	5e                   	pop    %esi
f0104d96:	5f                   	pop    %edi
f0104d97:	5d                   	pop    %ebp
f0104d98:	c3                   	ret    

f0104d99 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104d99:	55                   	push   %ebp
f0104d9a:	89 e5                	mov    %esp,%ebp
f0104d9c:	57                   	push   %edi
f0104d9d:	56                   	push   %esi
f0104d9e:	53                   	push   %ebx
f0104d9f:	83 ec 1c             	sub    $0x1c,%esp
f0104da2:	89 c7                	mov    %eax,%edi
f0104da4:	89 d6                	mov    %edx,%esi
f0104da6:	8b 45 08             	mov    0x8(%ebp),%eax
f0104da9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104dac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104daf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104db2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104db5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104dba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104dbd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104dc0:	39 d3                	cmp    %edx,%ebx
f0104dc2:	72 05                	jb     f0104dc9 <printnum+0x30>
f0104dc4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104dc7:	77 45                	ja     f0104e0e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104dc9:	83 ec 0c             	sub    $0xc,%esp
f0104dcc:	ff 75 18             	pushl  0x18(%ebp)
f0104dcf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dd2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104dd5:	53                   	push   %ebx
f0104dd6:	ff 75 10             	pushl  0x10(%ebp)
f0104dd9:	83 ec 08             	sub    $0x8,%esp
f0104ddc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ddf:	ff 75 e0             	pushl  -0x20(%ebp)
f0104de2:	ff 75 dc             	pushl  -0x24(%ebp)
f0104de5:	ff 75 d8             	pushl  -0x28(%ebp)
f0104de8:	e8 93 11 00 00       	call   f0105f80 <__udivdi3>
f0104ded:	83 c4 18             	add    $0x18,%esp
f0104df0:	52                   	push   %edx
f0104df1:	50                   	push   %eax
f0104df2:	89 f2                	mov    %esi,%edx
f0104df4:	89 f8                	mov    %edi,%eax
f0104df6:	e8 9e ff ff ff       	call   f0104d99 <printnum>
f0104dfb:	83 c4 20             	add    $0x20,%esp
f0104dfe:	eb 18                	jmp    f0104e18 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e00:	83 ec 08             	sub    $0x8,%esp
f0104e03:	56                   	push   %esi
f0104e04:	ff 75 18             	pushl  0x18(%ebp)
f0104e07:	ff d7                	call   *%edi
f0104e09:	83 c4 10             	add    $0x10,%esp
f0104e0c:	eb 03                	jmp    f0104e11 <printnum+0x78>
f0104e0e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104e11:	83 eb 01             	sub    $0x1,%ebx
f0104e14:	85 db                	test   %ebx,%ebx
f0104e16:	7f e8                	jg     f0104e00 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e18:	83 ec 08             	sub    $0x8,%esp
f0104e1b:	56                   	push   %esi
f0104e1c:	83 ec 04             	sub    $0x4,%esp
f0104e1f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e22:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e25:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e28:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e2b:	e8 80 12 00 00       	call   f01060b0 <__umoddi3>
f0104e30:	83 c4 14             	add    $0x14,%esp
f0104e33:	0f be 80 8e 79 10 f0 	movsbl -0xfef8672(%eax),%eax
f0104e3a:	50                   	push   %eax
f0104e3b:	ff d7                	call   *%edi
}
f0104e3d:	83 c4 10             	add    $0x10,%esp
f0104e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e43:	5b                   	pop    %ebx
f0104e44:	5e                   	pop    %esi
f0104e45:	5f                   	pop    %edi
f0104e46:	5d                   	pop    %ebp
f0104e47:	c3                   	ret    

f0104e48 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104e48:	55                   	push   %ebp
f0104e49:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104e4b:	83 fa 01             	cmp    $0x1,%edx
f0104e4e:	7e 0e                	jle    f0104e5e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104e50:	8b 10                	mov    (%eax),%edx
f0104e52:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104e55:	89 08                	mov    %ecx,(%eax)
f0104e57:	8b 02                	mov    (%edx),%eax
f0104e59:	8b 52 04             	mov    0x4(%edx),%edx
f0104e5c:	eb 22                	jmp    f0104e80 <getuint+0x38>
	else if (lflag)
f0104e5e:	85 d2                	test   %edx,%edx
f0104e60:	74 10                	je     f0104e72 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104e62:	8b 10                	mov    (%eax),%edx
f0104e64:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104e67:	89 08                	mov    %ecx,(%eax)
f0104e69:	8b 02                	mov    (%edx),%eax
f0104e6b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e70:	eb 0e                	jmp    f0104e80 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104e72:	8b 10                	mov    (%eax),%edx
f0104e74:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104e77:	89 08                	mov    %ecx,(%eax)
f0104e79:	8b 02                	mov    (%edx),%eax
f0104e7b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104e80:	5d                   	pop    %ebp
f0104e81:	c3                   	ret    

f0104e82 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104e82:	55                   	push   %ebp
f0104e83:	89 e5                	mov    %esp,%ebp
f0104e85:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104e88:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104e8c:	8b 10                	mov    (%eax),%edx
f0104e8e:	3b 50 04             	cmp    0x4(%eax),%edx
f0104e91:	73 0a                	jae    f0104e9d <sprintputch+0x1b>
		*b->buf++ = ch;
f0104e93:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104e96:	89 08                	mov    %ecx,(%eax)
f0104e98:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e9b:	88 02                	mov    %al,(%edx)
}
f0104e9d:	5d                   	pop    %ebp
f0104e9e:	c3                   	ret    

f0104e9f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104e9f:	55                   	push   %ebp
f0104ea0:	89 e5                	mov    %esp,%ebp
f0104ea2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104ea5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104ea8:	50                   	push   %eax
f0104ea9:	ff 75 10             	pushl  0x10(%ebp)
f0104eac:	ff 75 0c             	pushl  0xc(%ebp)
f0104eaf:	ff 75 08             	pushl  0x8(%ebp)
f0104eb2:	e8 05 00 00 00       	call   f0104ebc <vprintfmt>
	va_end(ap);
}
f0104eb7:	83 c4 10             	add    $0x10,%esp
f0104eba:	c9                   	leave  
f0104ebb:	c3                   	ret    

f0104ebc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104ebc:	55                   	push   %ebp
f0104ebd:	89 e5                	mov    %esp,%ebp
f0104ebf:	57                   	push   %edi
f0104ec0:	56                   	push   %esi
f0104ec1:	53                   	push   %ebx
f0104ec2:	83 ec 2c             	sub    $0x2c,%esp
f0104ec5:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ec8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ecb:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104ece:	eb 12                	jmp    f0104ee2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104ed0:	85 c0                	test   %eax,%eax
f0104ed2:	0f 84 a7 03 00 00    	je     f010527f <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
f0104ed8:	83 ec 08             	sub    $0x8,%esp
f0104edb:	53                   	push   %ebx
f0104edc:	50                   	push   %eax
f0104edd:	ff d6                	call   *%esi
f0104edf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104ee2:	83 c7 01             	add    $0x1,%edi
f0104ee5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104ee9:	83 f8 25             	cmp    $0x25,%eax
f0104eec:	75 e2                	jne    f0104ed0 <vprintfmt+0x14>
f0104eee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104ef2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104ef9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104f00:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104f07:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0104f0e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f13:	eb 07                	jmp    f0104f1c <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f15:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104f18:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f1c:	8d 47 01             	lea    0x1(%edi),%eax
f0104f1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f22:	0f b6 07             	movzbl (%edi),%eax
f0104f25:	0f b6 d0             	movzbl %al,%edx
f0104f28:	83 e8 23             	sub    $0x23,%eax
f0104f2b:	3c 55                	cmp    $0x55,%al
f0104f2d:	0f 87 31 03 00 00    	ja     f0105264 <vprintfmt+0x3a8>
f0104f33:	0f b6 c0             	movzbl %al,%eax
f0104f36:	ff 24 85 e0 7a 10 f0 	jmp    *-0xfef8520(,%eax,4)
f0104f3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104f40:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f44:	eb d6                	jmp    f0104f1c <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f49:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f4e:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104f51:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104f54:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104f58:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104f5b:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104f5e:	83 fe 09             	cmp    $0x9,%esi
f0104f61:	77 34                	ja     f0104f97 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104f63:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104f66:	eb e9                	jmp    f0104f51 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104f68:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f6b:	8d 50 04             	lea    0x4(%eax),%edx
f0104f6e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f71:	8b 00                	mov    (%eax),%eax
f0104f73:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104f79:	eb 22                	jmp    f0104f9d <vprintfmt+0xe1>
f0104f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f7e:	85 c0                	test   %eax,%eax
f0104f80:	0f 48 c1             	cmovs  %ecx,%eax
f0104f83:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f89:	eb 91                	jmp    f0104f1c <vprintfmt+0x60>
f0104f8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104f8e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104f95:	eb 85                	jmp    f0104f1c <vprintfmt+0x60>
f0104f97:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104f9a:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
f0104f9d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104fa1:	0f 89 75 ff ff ff    	jns    f0104f1c <vprintfmt+0x60>
				width = precision, precision = -1;
f0104fa7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104faa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104fad:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104fb4:	e9 63 ff ff ff       	jmp    f0104f1c <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104fb9:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fbd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104fc0:	e9 57 ff ff ff       	jmp    f0104f1c <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104fc5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fc8:	8d 50 04             	lea    0x4(%eax),%edx
f0104fcb:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fce:	83 ec 08             	sub    $0x8,%esp
f0104fd1:	53                   	push   %ebx
f0104fd2:	ff 30                	pushl  (%eax)
f0104fd4:	ff d6                	call   *%esi
			break;
f0104fd6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fd9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104fdc:	e9 01 ff ff ff       	jmp    f0104ee2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104fe1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fe4:	8d 50 04             	lea    0x4(%eax),%edx
f0104fe7:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fea:	8b 00                	mov    (%eax),%eax
f0104fec:	99                   	cltd   
f0104fed:	31 d0                	xor    %edx,%eax
f0104fef:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104ff1:	83 f8 0f             	cmp    $0xf,%eax
f0104ff4:	7f 0b                	jg     f0105001 <vprintfmt+0x145>
f0104ff6:	8b 14 85 40 7c 10 f0 	mov    -0xfef83c0(,%eax,4),%edx
f0104ffd:	85 d2                	test   %edx,%edx
f0104fff:	75 18                	jne    f0105019 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
f0105001:	50                   	push   %eax
f0105002:	68 a6 79 10 f0       	push   $0xf01079a6
f0105007:	53                   	push   %ebx
f0105008:	56                   	push   %esi
f0105009:	e8 91 fe ff ff       	call   f0104e9f <printfmt>
f010500e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105011:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105014:	e9 c9 fe ff ff       	jmp    f0104ee2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105019:	52                   	push   %edx
f010501a:	68 11 71 10 f0       	push   $0xf0107111
f010501f:	53                   	push   %ebx
f0105020:	56                   	push   %esi
f0105021:	e8 79 fe ff ff       	call   f0104e9f <printfmt>
f0105026:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105029:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010502c:	e9 b1 fe ff ff       	jmp    f0104ee2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105031:	8b 45 14             	mov    0x14(%ebp),%eax
f0105034:	8d 50 04             	lea    0x4(%eax),%edx
f0105037:	89 55 14             	mov    %edx,0x14(%ebp)
f010503a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010503c:	85 ff                	test   %edi,%edi
f010503e:	b8 9f 79 10 f0       	mov    $0xf010799f,%eax
f0105043:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105046:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010504a:	0f 8e 94 00 00 00    	jle    f01050e4 <vprintfmt+0x228>
f0105050:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105054:	0f 84 98 00 00 00    	je     f01050f2 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
f010505a:	83 ec 08             	sub    $0x8,%esp
f010505d:	ff 75 cc             	pushl  -0x34(%ebp)
f0105060:	57                   	push   %edi
f0105061:	e8 92 03 00 00       	call   f01053f8 <strnlen>
f0105066:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105069:	29 c1                	sub    %eax,%ecx
f010506b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010506e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105071:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105075:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105078:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010507b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010507d:	eb 0f                	jmp    f010508e <vprintfmt+0x1d2>
					putch(padc, putdat);
f010507f:	83 ec 08             	sub    $0x8,%esp
f0105082:	53                   	push   %ebx
f0105083:	ff 75 e0             	pushl  -0x20(%ebp)
f0105086:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105088:	83 ef 01             	sub    $0x1,%edi
f010508b:	83 c4 10             	add    $0x10,%esp
f010508e:	85 ff                	test   %edi,%edi
f0105090:	7f ed                	jg     f010507f <vprintfmt+0x1c3>
f0105092:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105095:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105098:	85 c9                	test   %ecx,%ecx
f010509a:	b8 00 00 00 00       	mov    $0x0,%eax
f010509f:	0f 49 c1             	cmovns %ecx,%eax
f01050a2:	29 c1                	sub    %eax,%ecx
f01050a4:	89 75 08             	mov    %esi,0x8(%ebp)
f01050a7:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01050aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050ad:	89 cb                	mov    %ecx,%ebx
f01050af:	eb 4d                	jmp    f01050fe <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01050b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01050b5:	74 1b                	je     f01050d2 <vprintfmt+0x216>
f01050b7:	0f be c0             	movsbl %al,%eax
f01050ba:	83 e8 20             	sub    $0x20,%eax
f01050bd:	83 f8 5e             	cmp    $0x5e,%eax
f01050c0:	76 10                	jbe    f01050d2 <vprintfmt+0x216>
					putch('?', putdat);
f01050c2:	83 ec 08             	sub    $0x8,%esp
f01050c5:	ff 75 0c             	pushl  0xc(%ebp)
f01050c8:	6a 3f                	push   $0x3f
f01050ca:	ff 55 08             	call   *0x8(%ebp)
f01050cd:	83 c4 10             	add    $0x10,%esp
f01050d0:	eb 0d                	jmp    f01050df <vprintfmt+0x223>
				else
					putch(ch, putdat);
f01050d2:	83 ec 08             	sub    $0x8,%esp
f01050d5:	ff 75 0c             	pushl  0xc(%ebp)
f01050d8:	52                   	push   %edx
f01050d9:	ff 55 08             	call   *0x8(%ebp)
f01050dc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01050df:	83 eb 01             	sub    $0x1,%ebx
f01050e2:	eb 1a                	jmp    f01050fe <vprintfmt+0x242>
f01050e4:	89 75 08             	mov    %esi,0x8(%ebp)
f01050e7:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01050ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050f0:	eb 0c                	jmp    f01050fe <vprintfmt+0x242>
f01050f2:	89 75 08             	mov    %esi,0x8(%ebp)
f01050f5:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01050f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050fe:	83 c7 01             	add    $0x1,%edi
f0105101:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105105:	0f be d0             	movsbl %al,%edx
f0105108:	85 d2                	test   %edx,%edx
f010510a:	74 23                	je     f010512f <vprintfmt+0x273>
f010510c:	85 f6                	test   %esi,%esi
f010510e:	78 a1                	js     f01050b1 <vprintfmt+0x1f5>
f0105110:	83 ee 01             	sub    $0x1,%esi
f0105113:	79 9c                	jns    f01050b1 <vprintfmt+0x1f5>
f0105115:	89 df                	mov    %ebx,%edi
f0105117:	8b 75 08             	mov    0x8(%ebp),%esi
f010511a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010511d:	eb 18                	jmp    f0105137 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010511f:	83 ec 08             	sub    $0x8,%esp
f0105122:	53                   	push   %ebx
f0105123:	6a 20                	push   $0x20
f0105125:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105127:	83 ef 01             	sub    $0x1,%edi
f010512a:	83 c4 10             	add    $0x10,%esp
f010512d:	eb 08                	jmp    f0105137 <vprintfmt+0x27b>
f010512f:	89 df                	mov    %ebx,%edi
f0105131:	8b 75 08             	mov    0x8(%ebp),%esi
f0105134:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105137:	85 ff                	test   %edi,%edi
f0105139:	7f e4                	jg     f010511f <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010513b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010513e:	e9 9f fd ff ff       	jmp    f0104ee2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105143:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
f0105147:	7e 16                	jle    f010515f <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
f0105149:	8b 45 14             	mov    0x14(%ebp),%eax
f010514c:	8d 50 08             	lea    0x8(%eax),%edx
f010514f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105152:	8b 50 04             	mov    0x4(%eax),%edx
f0105155:	8b 00                	mov    (%eax),%eax
f0105157:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010515a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010515d:	eb 34                	jmp    f0105193 <vprintfmt+0x2d7>
	else if (lflag)
f010515f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105163:	74 18                	je     f010517d <vprintfmt+0x2c1>
		return va_arg(*ap, long);
f0105165:	8b 45 14             	mov    0x14(%ebp),%eax
f0105168:	8d 50 04             	lea    0x4(%eax),%edx
f010516b:	89 55 14             	mov    %edx,0x14(%ebp)
f010516e:	8b 00                	mov    (%eax),%eax
f0105170:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105173:	89 c1                	mov    %eax,%ecx
f0105175:	c1 f9 1f             	sar    $0x1f,%ecx
f0105178:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010517b:	eb 16                	jmp    f0105193 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
f010517d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105180:	8d 50 04             	lea    0x4(%eax),%edx
f0105183:	89 55 14             	mov    %edx,0x14(%ebp)
f0105186:	8b 00                	mov    (%eax),%eax
f0105188:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010518b:	89 c1                	mov    %eax,%ecx
f010518d:	c1 f9 1f             	sar    $0x1f,%ecx
f0105190:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105193:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105196:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105199:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010519e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01051a2:	0f 89 88 00 00 00    	jns    f0105230 <vprintfmt+0x374>
				putch('-', putdat);
f01051a8:	83 ec 08             	sub    $0x8,%esp
f01051ab:	53                   	push   %ebx
f01051ac:	6a 2d                	push   $0x2d
f01051ae:	ff d6                	call   *%esi
				num = -(long long) num;
f01051b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01051b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01051b6:	f7 d8                	neg    %eax
f01051b8:	83 d2 00             	adc    $0x0,%edx
f01051bb:	f7 da                	neg    %edx
f01051bd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01051c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01051c5:	eb 69                	jmp    f0105230 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01051c7:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01051ca:	8d 45 14             	lea    0x14(%ebp),%eax
f01051cd:	e8 76 fc ff ff       	call   f0104e48 <getuint>
			base = 10;
f01051d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01051d7:	eb 57                	jmp    f0105230 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
f01051d9:	83 ec 08             	sub    $0x8,%esp
f01051dc:	53                   	push   %ebx
f01051dd:	6a 30                	push   $0x30
f01051df:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
f01051e1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01051e4:	8d 45 14             	lea    0x14(%ebp),%eax
f01051e7:	e8 5c fc ff ff       	call   f0104e48 <getuint>
			base = 8;
			goto number;
f01051ec:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f01051ef:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01051f4:	eb 3a                	jmp    f0105230 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
f01051f6:	83 ec 08             	sub    $0x8,%esp
f01051f9:	53                   	push   %ebx
f01051fa:	6a 30                	push   $0x30
f01051fc:	ff d6                	call   *%esi
			putch('x', putdat);
f01051fe:	83 c4 08             	add    $0x8,%esp
f0105201:	53                   	push   %ebx
f0105202:	6a 78                	push   $0x78
f0105204:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105206:	8b 45 14             	mov    0x14(%ebp),%eax
f0105209:	8d 50 04             	lea    0x4(%eax),%edx
f010520c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010520f:	8b 00                	mov    (%eax),%eax
f0105211:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105216:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105219:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010521e:	eb 10                	jmp    f0105230 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105220:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105223:	8d 45 14             	lea    0x14(%ebp),%eax
f0105226:	e8 1d fc ff ff       	call   f0104e48 <getuint>
			base = 16;
f010522b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105230:	83 ec 0c             	sub    $0xc,%esp
f0105233:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105237:	57                   	push   %edi
f0105238:	ff 75 e0             	pushl  -0x20(%ebp)
f010523b:	51                   	push   %ecx
f010523c:	52                   	push   %edx
f010523d:	50                   	push   %eax
f010523e:	89 da                	mov    %ebx,%edx
f0105240:	89 f0                	mov    %esi,%eax
f0105242:	e8 52 fb ff ff       	call   f0104d99 <printnum>
			break;
f0105247:	83 c4 20             	add    $0x20,%esp
f010524a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010524d:	e9 90 fc ff ff       	jmp    f0104ee2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105252:	83 ec 08             	sub    $0x8,%esp
f0105255:	53                   	push   %ebx
f0105256:	52                   	push   %edx
f0105257:	ff d6                	call   *%esi
			break;
f0105259:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010525c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010525f:	e9 7e fc ff ff       	jmp    f0104ee2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105264:	83 ec 08             	sub    $0x8,%esp
f0105267:	53                   	push   %ebx
f0105268:	6a 25                	push   $0x25
f010526a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010526c:	83 c4 10             	add    $0x10,%esp
f010526f:	eb 03                	jmp    f0105274 <vprintfmt+0x3b8>
f0105271:	83 ef 01             	sub    $0x1,%edi
f0105274:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105278:	75 f7                	jne    f0105271 <vprintfmt+0x3b5>
f010527a:	e9 63 fc ff ff       	jmp    f0104ee2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010527f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105282:	5b                   	pop    %ebx
f0105283:	5e                   	pop    %esi
f0105284:	5f                   	pop    %edi
f0105285:	5d                   	pop    %ebp
f0105286:	c3                   	ret    

f0105287 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105287:	55                   	push   %ebp
f0105288:	89 e5                	mov    %esp,%ebp
f010528a:	83 ec 18             	sub    $0x18,%esp
f010528d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105290:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105293:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105296:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010529a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010529d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01052a4:	85 c0                	test   %eax,%eax
f01052a6:	74 26                	je     f01052ce <vsnprintf+0x47>
f01052a8:	85 d2                	test   %edx,%edx
f01052aa:	7e 22                	jle    f01052ce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01052ac:	ff 75 14             	pushl  0x14(%ebp)
f01052af:	ff 75 10             	pushl  0x10(%ebp)
f01052b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01052b5:	50                   	push   %eax
f01052b6:	68 82 4e 10 f0       	push   $0xf0104e82
f01052bb:	e8 fc fb ff ff       	call   f0104ebc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01052c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01052c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01052c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052c9:	83 c4 10             	add    $0x10,%esp
f01052cc:	eb 05                	jmp    f01052d3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01052ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01052d3:	c9                   	leave  
f01052d4:	c3                   	ret    

f01052d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01052d5:	55                   	push   %ebp
f01052d6:	89 e5                	mov    %esp,%ebp
f01052d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01052db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01052de:	50                   	push   %eax
f01052df:	ff 75 10             	pushl  0x10(%ebp)
f01052e2:	ff 75 0c             	pushl  0xc(%ebp)
f01052e5:	ff 75 08             	pushl  0x8(%ebp)
f01052e8:	e8 9a ff ff ff       	call   f0105287 <vsnprintf>
	va_end(ap);

	return rc;
}
f01052ed:	c9                   	leave  
f01052ee:	c3                   	ret    

f01052ef <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01052ef:	55                   	push   %ebp
f01052f0:	89 e5                	mov    %esp,%ebp
f01052f2:	57                   	push   %edi
f01052f3:	56                   	push   %esi
f01052f4:	53                   	push   %ebx
f01052f5:	83 ec 0c             	sub    $0xc,%esp
f01052f8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01052fb:	85 c0                	test   %eax,%eax
f01052fd:	74 11                	je     f0105310 <readline+0x21>
		cprintf("%s", prompt);
f01052ff:	83 ec 08             	sub    $0x8,%esp
f0105302:	50                   	push   %eax
f0105303:	68 11 71 10 f0       	push   $0xf0107111
f0105308:	e8 d4 e4 ff ff       	call   f01037e1 <cprintf>
f010530d:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105310:	83 ec 0c             	sub    $0xc,%esp
f0105313:	6a 00                	push   $0x0
f0105315:	e8 8c b4 ff ff       	call   f01007a6 <iscons>
f010531a:	89 c7                	mov    %eax,%edi
f010531c:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010531f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105324:	e8 6c b4 ff ff       	call   f0100795 <getchar>
f0105329:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010532b:	85 c0                	test   %eax,%eax
f010532d:	79 29                	jns    f0105358 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010532f:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105334:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105337:	0f 84 9b 00 00 00    	je     f01053d8 <readline+0xe9>
				cprintf("read error: %e\n", c);
f010533d:	83 ec 08             	sub    $0x8,%esp
f0105340:	53                   	push   %ebx
f0105341:	68 9f 7c 10 f0       	push   $0xf0107c9f
f0105346:	e8 96 e4 ff ff       	call   f01037e1 <cprintf>
f010534b:	83 c4 10             	add    $0x10,%esp
			return NULL;
f010534e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105353:	e9 80 00 00 00       	jmp    f01053d8 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105358:	83 f8 08             	cmp    $0x8,%eax
f010535b:	0f 94 c2             	sete   %dl
f010535e:	83 f8 7f             	cmp    $0x7f,%eax
f0105361:	0f 94 c0             	sete   %al
f0105364:	08 c2                	or     %al,%dl
f0105366:	74 1a                	je     f0105382 <readline+0x93>
f0105368:	85 f6                	test   %esi,%esi
f010536a:	7e 16                	jle    f0105382 <readline+0x93>
			if (echoing)
f010536c:	85 ff                	test   %edi,%edi
f010536e:	74 0d                	je     f010537d <readline+0x8e>
				cputchar('\b');
f0105370:	83 ec 0c             	sub    $0xc,%esp
f0105373:	6a 08                	push   $0x8
f0105375:	e8 0b b4 ff ff       	call   f0100785 <cputchar>
f010537a:	83 c4 10             	add    $0x10,%esp
			i--;
f010537d:	83 ee 01             	sub    $0x1,%esi
f0105380:	eb a2                	jmp    f0105324 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105382:	83 fb 1f             	cmp    $0x1f,%ebx
f0105385:	7e 26                	jle    f01053ad <readline+0xbe>
f0105387:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010538d:	7f 1e                	jg     f01053ad <readline+0xbe>
			if (echoing)
f010538f:	85 ff                	test   %edi,%edi
f0105391:	74 0c                	je     f010539f <readline+0xb0>
				cputchar(c);
f0105393:	83 ec 0c             	sub    $0xc,%esp
f0105396:	53                   	push   %ebx
f0105397:	e8 e9 b3 ff ff       	call   f0100785 <cputchar>
f010539c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010539f:	88 9e 80 1a 21 f0    	mov    %bl,-0xfdee580(%esi)
f01053a5:	8d 76 01             	lea    0x1(%esi),%esi
f01053a8:	e9 77 ff ff ff       	jmp    f0105324 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01053ad:	83 fb 0a             	cmp    $0xa,%ebx
f01053b0:	74 09                	je     f01053bb <readline+0xcc>
f01053b2:	83 fb 0d             	cmp    $0xd,%ebx
f01053b5:	0f 85 69 ff ff ff    	jne    f0105324 <readline+0x35>
			if (echoing)
f01053bb:	85 ff                	test   %edi,%edi
f01053bd:	74 0d                	je     f01053cc <readline+0xdd>
				cputchar('\n');
f01053bf:	83 ec 0c             	sub    $0xc,%esp
f01053c2:	6a 0a                	push   $0xa
f01053c4:	e8 bc b3 ff ff       	call   f0100785 <cputchar>
f01053c9:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01053cc:	c6 86 80 1a 21 f0 00 	movb   $0x0,-0xfdee580(%esi)
			return buf;
f01053d3:	b8 80 1a 21 f0       	mov    $0xf0211a80,%eax
		}
	}
}
f01053d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053db:	5b                   	pop    %ebx
f01053dc:	5e                   	pop    %esi
f01053dd:	5f                   	pop    %edi
f01053de:	5d                   	pop    %ebp
f01053df:	c3                   	ret    

f01053e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01053e0:	55                   	push   %ebp
f01053e1:	89 e5                	mov    %esp,%ebp
f01053e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01053e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01053eb:	eb 03                	jmp    f01053f0 <strlen+0x10>
		n++;
f01053ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01053f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01053f4:	75 f7                	jne    f01053ed <strlen+0xd>
		n++;
	return n;
}
f01053f6:	5d                   	pop    %ebp
f01053f7:	c3                   	ret    

f01053f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01053f8:	55                   	push   %ebp
f01053f9:	89 e5                	mov    %esp,%ebp
f01053fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105401:	ba 00 00 00 00       	mov    $0x0,%edx
f0105406:	eb 03                	jmp    f010540b <strnlen+0x13>
		n++;
f0105408:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010540b:	39 c2                	cmp    %eax,%edx
f010540d:	74 08                	je     f0105417 <strnlen+0x1f>
f010540f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105413:	75 f3                	jne    f0105408 <strnlen+0x10>
f0105415:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105417:	5d                   	pop    %ebp
f0105418:	c3                   	ret    

f0105419 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105419:	55                   	push   %ebp
f010541a:	89 e5                	mov    %esp,%ebp
f010541c:	53                   	push   %ebx
f010541d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105420:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105423:	89 c2                	mov    %eax,%edx
f0105425:	83 c2 01             	add    $0x1,%edx
f0105428:	83 c1 01             	add    $0x1,%ecx
f010542b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010542f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105432:	84 db                	test   %bl,%bl
f0105434:	75 ef                	jne    f0105425 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105436:	5b                   	pop    %ebx
f0105437:	5d                   	pop    %ebp
f0105438:	c3                   	ret    

f0105439 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105439:	55                   	push   %ebp
f010543a:	89 e5                	mov    %esp,%ebp
f010543c:	53                   	push   %ebx
f010543d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105440:	53                   	push   %ebx
f0105441:	e8 9a ff ff ff       	call   f01053e0 <strlen>
f0105446:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105449:	ff 75 0c             	pushl  0xc(%ebp)
f010544c:	01 d8                	add    %ebx,%eax
f010544e:	50                   	push   %eax
f010544f:	e8 c5 ff ff ff       	call   f0105419 <strcpy>
	return dst;
}
f0105454:	89 d8                	mov    %ebx,%eax
f0105456:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105459:	c9                   	leave  
f010545a:	c3                   	ret    

f010545b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010545b:	55                   	push   %ebp
f010545c:	89 e5                	mov    %esp,%ebp
f010545e:	56                   	push   %esi
f010545f:	53                   	push   %ebx
f0105460:	8b 75 08             	mov    0x8(%ebp),%esi
f0105463:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105466:	89 f3                	mov    %esi,%ebx
f0105468:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010546b:	89 f2                	mov    %esi,%edx
f010546d:	eb 0f                	jmp    f010547e <strncpy+0x23>
		*dst++ = *src;
f010546f:	83 c2 01             	add    $0x1,%edx
f0105472:	0f b6 01             	movzbl (%ecx),%eax
f0105475:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105478:	80 39 01             	cmpb   $0x1,(%ecx)
f010547b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010547e:	39 da                	cmp    %ebx,%edx
f0105480:	75 ed                	jne    f010546f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105482:	89 f0                	mov    %esi,%eax
f0105484:	5b                   	pop    %ebx
f0105485:	5e                   	pop    %esi
f0105486:	5d                   	pop    %ebp
f0105487:	c3                   	ret    

f0105488 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105488:	55                   	push   %ebp
f0105489:	89 e5                	mov    %esp,%ebp
f010548b:	56                   	push   %esi
f010548c:	53                   	push   %ebx
f010548d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105490:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105493:	8b 55 10             	mov    0x10(%ebp),%edx
f0105496:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105498:	85 d2                	test   %edx,%edx
f010549a:	74 21                	je     f01054bd <strlcpy+0x35>
f010549c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01054a0:	89 f2                	mov    %esi,%edx
f01054a2:	eb 09                	jmp    f01054ad <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01054a4:	83 c2 01             	add    $0x1,%edx
f01054a7:	83 c1 01             	add    $0x1,%ecx
f01054aa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01054ad:	39 c2                	cmp    %eax,%edx
f01054af:	74 09                	je     f01054ba <strlcpy+0x32>
f01054b1:	0f b6 19             	movzbl (%ecx),%ebx
f01054b4:	84 db                	test   %bl,%bl
f01054b6:	75 ec                	jne    f01054a4 <strlcpy+0x1c>
f01054b8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01054ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01054bd:	29 f0                	sub    %esi,%eax
}
f01054bf:	5b                   	pop    %ebx
f01054c0:	5e                   	pop    %esi
f01054c1:	5d                   	pop    %ebp
f01054c2:	c3                   	ret    

f01054c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01054c3:	55                   	push   %ebp
f01054c4:	89 e5                	mov    %esp,%ebp
f01054c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01054cc:	eb 06                	jmp    f01054d4 <strcmp+0x11>
		p++, q++;
f01054ce:	83 c1 01             	add    $0x1,%ecx
f01054d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01054d4:	0f b6 01             	movzbl (%ecx),%eax
f01054d7:	84 c0                	test   %al,%al
f01054d9:	74 04                	je     f01054df <strcmp+0x1c>
f01054db:	3a 02                	cmp    (%edx),%al
f01054dd:	74 ef                	je     f01054ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01054df:	0f b6 c0             	movzbl %al,%eax
f01054e2:	0f b6 12             	movzbl (%edx),%edx
f01054e5:	29 d0                	sub    %edx,%eax
}
f01054e7:	5d                   	pop    %ebp
f01054e8:	c3                   	ret    

f01054e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01054e9:	55                   	push   %ebp
f01054ea:	89 e5                	mov    %esp,%ebp
f01054ec:	53                   	push   %ebx
f01054ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01054f0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054f3:	89 c3                	mov    %eax,%ebx
f01054f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01054f8:	eb 06                	jmp    f0105500 <strncmp+0x17>
		n--, p++, q++;
f01054fa:	83 c0 01             	add    $0x1,%eax
f01054fd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105500:	39 d8                	cmp    %ebx,%eax
f0105502:	74 15                	je     f0105519 <strncmp+0x30>
f0105504:	0f b6 08             	movzbl (%eax),%ecx
f0105507:	84 c9                	test   %cl,%cl
f0105509:	74 04                	je     f010550f <strncmp+0x26>
f010550b:	3a 0a                	cmp    (%edx),%cl
f010550d:	74 eb                	je     f01054fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010550f:	0f b6 00             	movzbl (%eax),%eax
f0105512:	0f b6 12             	movzbl (%edx),%edx
f0105515:	29 d0                	sub    %edx,%eax
f0105517:	eb 05                	jmp    f010551e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105519:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010551e:	5b                   	pop    %ebx
f010551f:	5d                   	pop    %ebp
f0105520:	c3                   	ret    

f0105521 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105521:	55                   	push   %ebp
f0105522:	89 e5                	mov    %esp,%ebp
f0105524:	8b 45 08             	mov    0x8(%ebp),%eax
f0105527:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010552b:	eb 07                	jmp    f0105534 <strchr+0x13>
		if (*s == c)
f010552d:	38 ca                	cmp    %cl,%dl
f010552f:	74 0f                	je     f0105540 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105531:	83 c0 01             	add    $0x1,%eax
f0105534:	0f b6 10             	movzbl (%eax),%edx
f0105537:	84 d2                	test   %dl,%dl
f0105539:	75 f2                	jne    f010552d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010553b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105540:	5d                   	pop    %ebp
f0105541:	c3                   	ret    

f0105542 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105542:	55                   	push   %ebp
f0105543:	89 e5                	mov    %esp,%ebp
f0105545:	8b 45 08             	mov    0x8(%ebp),%eax
f0105548:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010554c:	eb 03                	jmp    f0105551 <strfind+0xf>
f010554e:	83 c0 01             	add    $0x1,%eax
f0105551:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105554:	38 ca                	cmp    %cl,%dl
f0105556:	74 04                	je     f010555c <strfind+0x1a>
f0105558:	84 d2                	test   %dl,%dl
f010555a:	75 f2                	jne    f010554e <strfind+0xc>
			break;
	return (char *) s;
}
f010555c:	5d                   	pop    %ebp
f010555d:	c3                   	ret    

f010555e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010555e:	55                   	push   %ebp
f010555f:	89 e5                	mov    %esp,%ebp
f0105561:	57                   	push   %edi
f0105562:	56                   	push   %esi
f0105563:	53                   	push   %ebx
f0105564:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105567:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010556a:	85 c9                	test   %ecx,%ecx
f010556c:	74 36                	je     f01055a4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010556e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105574:	75 28                	jne    f010559e <memset+0x40>
f0105576:	f6 c1 03             	test   $0x3,%cl
f0105579:	75 23                	jne    f010559e <memset+0x40>
		c &= 0xFF;
f010557b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010557f:	89 d3                	mov    %edx,%ebx
f0105581:	c1 e3 08             	shl    $0x8,%ebx
f0105584:	89 d6                	mov    %edx,%esi
f0105586:	c1 e6 18             	shl    $0x18,%esi
f0105589:	89 d0                	mov    %edx,%eax
f010558b:	c1 e0 10             	shl    $0x10,%eax
f010558e:	09 f0                	or     %esi,%eax
f0105590:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105592:	89 d8                	mov    %ebx,%eax
f0105594:	09 d0                	or     %edx,%eax
f0105596:	c1 e9 02             	shr    $0x2,%ecx
f0105599:	fc                   	cld    
f010559a:	f3 ab                	rep stos %eax,%es:(%edi)
f010559c:	eb 06                	jmp    f01055a4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010559e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01055a1:	fc                   	cld    
f01055a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01055a4:	89 f8                	mov    %edi,%eax
f01055a6:	5b                   	pop    %ebx
f01055a7:	5e                   	pop    %esi
f01055a8:	5f                   	pop    %edi
f01055a9:	5d                   	pop    %ebp
f01055aa:	c3                   	ret    

f01055ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01055ab:	55                   	push   %ebp
f01055ac:	89 e5                	mov    %esp,%ebp
f01055ae:	57                   	push   %edi
f01055af:	56                   	push   %esi
f01055b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01055b3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01055b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01055b9:	39 c6                	cmp    %eax,%esi
f01055bb:	73 35                	jae    f01055f2 <memmove+0x47>
f01055bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01055c0:	39 d0                	cmp    %edx,%eax
f01055c2:	73 2e                	jae    f01055f2 <memmove+0x47>
		s += n;
		d += n;
f01055c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055c7:	89 d6                	mov    %edx,%esi
f01055c9:	09 fe                	or     %edi,%esi
f01055cb:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01055d1:	75 13                	jne    f01055e6 <memmove+0x3b>
f01055d3:	f6 c1 03             	test   $0x3,%cl
f01055d6:	75 0e                	jne    f01055e6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01055d8:	83 ef 04             	sub    $0x4,%edi
f01055db:	8d 72 fc             	lea    -0x4(%edx),%esi
f01055de:	c1 e9 02             	shr    $0x2,%ecx
f01055e1:	fd                   	std    
f01055e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055e4:	eb 09                	jmp    f01055ef <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01055e6:	83 ef 01             	sub    $0x1,%edi
f01055e9:	8d 72 ff             	lea    -0x1(%edx),%esi
f01055ec:	fd                   	std    
f01055ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01055ef:	fc                   	cld    
f01055f0:	eb 1d                	jmp    f010560f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055f2:	89 f2                	mov    %esi,%edx
f01055f4:	09 c2                	or     %eax,%edx
f01055f6:	f6 c2 03             	test   $0x3,%dl
f01055f9:	75 0f                	jne    f010560a <memmove+0x5f>
f01055fb:	f6 c1 03             	test   $0x3,%cl
f01055fe:	75 0a                	jne    f010560a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105600:	c1 e9 02             	shr    $0x2,%ecx
f0105603:	89 c7                	mov    %eax,%edi
f0105605:	fc                   	cld    
f0105606:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105608:	eb 05                	jmp    f010560f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010560a:	89 c7                	mov    %eax,%edi
f010560c:	fc                   	cld    
f010560d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010560f:	5e                   	pop    %esi
f0105610:	5f                   	pop    %edi
f0105611:	5d                   	pop    %ebp
f0105612:	c3                   	ret    

f0105613 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105613:	55                   	push   %ebp
f0105614:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105616:	ff 75 10             	pushl  0x10(%ebp)
f0105619:	ff 75 0c             	pushl  0xc(%ebp)
f010561c:	ff 75 08             	pushl  0x8(%ebp)
f010561f:	e8 87 ff ff ff       	call   f01055ab <memmove>
}
f0105624:	c9                   	leave  
f0105625:	c3                   	ret    

f0105626 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105626:	55                   	push   %ebp
f0105627:	89 e5                	mov    %esp,%ebp
f0105629:	56                   	push   %esi
f010562a:	53                   	push   %ebx
f010562b:	8b 45 08             	mov    0x8(%ebp),%eax
f010562e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105631:	89 c6                	mov    %eax,%esi
f0105633:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105636:	eb 1a                	jmp    f0105652 <memcmp+0x2c>
		if (*s1 != *s2)
f0105638:	0f b6 08             	movzbl (%eax),%ecx
f010563b:	0f b6 1a             	movzbl (%edx),%ebx
f010563e:	38 d9                	cmp    %bl,%cl
f0105640:	74 0a                	je     f010564c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105642:	0f b6 c1             	movzbl %cl,%eax
f0105645:	0f b6 db             	movzbl %bl,%ebx
f0105648:	29 d8                	sub    %ebx,%eax
f010564a:	eb 0f                	jmp    f010565b <memcmp+0x35>
		s1++, s2++;
f010564c:	83 c0 01             	add    $0x1,%eax
f010564f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105652:	39 f0                	cmp    %esi,%eax
f0105654:	75 e2                	jne    f0105638 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105656:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010565b:	5b                   	pop    %ebx
f010565c:	5e                   	pop    %esi
f010565d:	5d                   	pop    %ebp
f010565e:	c3                   	ret    

f010565f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010565f:	55                   	push   %ebp
f0105660:	89 e5                	mov    %esp,%ebp
f0105662:	53                   	push   %ebx
f0105663:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105666:	89 c1                	mov    %eax,%ecx
f0105668:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010566b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010566f:	eb 0a                	jmp    f010567b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105671:	0f b6 10             	movzbl (%eax),%edx
f0105674:	39 da                	cmp    %ebx,%edx
f0105676:	74 07                	je     f010567f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105678:	83 c0 01             	add    $0x1,%eax
f010567b:	39 c8                	cmp    %ecx,%eax
f010567d:	72 f2                	jb     f0105671 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010567f:	5b                   	pop    %ebx
f0105680:	5d                   	pop    %ebp
f0105681:	c3                   	ret    

f0105682 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105682:	55                   	push   %ebp
f0105683:	89 e5                	mov    %esp,%ebp
f0105685:	57                   	push   %edi
f0105686:	56                   	push   %esi
f0105687:	53                   	push   %ebx
f0105688:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010568b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010568e:	eb 03                	jmp    f0105693 <strtol+0x11>
		s++;
f0105690:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105693:	0f b6 01             	movzbl (%ecx),%eax
f0105696:	3c 20                	cmp    $0x20,%al
f0105698:	74 f6                	je     f0105690 <strtol+0xe>
f010569a:	3c 09                	cmp    $0x9,%al
f010569c:	74 f2                	je     f0105690 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010569e:	3c 2b                	cmp    $0x2b,%al
f01056a0:	75 0a                	jne    f01056ac <strtol+0x2a>
		s++;
f01056a2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01056a5:	bf 00 00 00 00       	mov    $0x0,%edi
f01056aa:	eb 11                	jmp    f01056bd <strtol+0x3b>
f01056ac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01056b1:	3c 2d                	cmp    $0x2d,%al
f01056b3:	75 08                	jne    f01056bd <strtol+0x3b>
		s++, neg = 1;
f01056b5:	83 c1 01             	add    $0x1,%ecx
f01056b8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01056bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01056c3:	75 15                	jne    f01056da <strtol+0x58>
f01056c5:	80 39 30             	cmpb   $0x30,(%ecx)
f01056c8:	75 10                	jne    f01056da <strtol+0x58>
f01056ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01056ce:	75 7c                	jne    f010574c <strtol+0xca>
		s += 2, base = 16;
f01056d0:	83 c1 02             	add    $0x2,%ecx
f01056d3:	bb 10 00 00 00       	mov    $0x10,%ebx
f01056d8:	eb 16                	jmp    f01056f0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01056da:	85 db                	test   %ebx,%ebx
f01056dc:	75 12                	jne    f01056f0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01056de:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01056e3:	80 39 30             	cmpb   $0x30,(%ecx)
f01056e6:	75 08                	jne    f01056f0 <strtol+0x6e>
		s++, base = 8;
f01056e8:	83 c1 01             	add    $0x1,%ecx
f01056eb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01056f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01056f5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01056f8:	0f b6 11             	movzbl (%ecx),%edx
f01056fb:	8d 72 d0             	lea    -0x30(%edx),%esi
f01056fe:	89 f3                	mov    %esi,%ebx
f0105700:	80 fb 09             	cmp    $0x9,%bl
f0105703:	77 08                	ja     f010570d <strtol+0x8b>
			dig = *s - '0';
f0105705:	0f be d2             	movsbl %dl,%edx
f0105708:	83 ea 30             	sub    $0x30,%edx
f010570b:	eb 22                	jmp    f010572f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010570d:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105710:	89 f3                	mov    %esi,%ebx
f0105712:	80 fb 19             	cmp    $0x19,%bl
f0105715:	77 08                	ja     f010571f <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105717:	0f be d2             	movsbl %dl,%edx
f010571a:	83 ea 57             	sub    $0x57,%edx
f010571d:	eb 10                	jmp    f010572f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010571f:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105722:	89 f3                	mov    %esi,%ebx
f0105724:	80 fb 19             	cmp    $0x19,%bl
f0105727:	77 16                	ja     f010573f <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105729:	0f be d2             	movsbl %dl,%edx
f010572c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010572f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105732:	7d 0b                	jge    f010573f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105734:	83 c1 01             	add    $0x1,%ecx
f0105737:	0f af 45 10          	imul   0x10(%ebp),%eax
f010573b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010573d:	eb b9                	jmp    f01056f8 <strtol+0x76>

	if (endptr)
f010573f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105743:	74 0d                	je     f0105752 <strtol+0xd0>
		*endptr = (char *) s;
f0105745:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105748:	89 0e                	mov    %ecx,(%esi)
f010574a:	eb 06                	jmp    f0105752 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010574c:	85 db                	test   %ebx,%ebx
f010574e:	74 98                	je     f01056e8 <strtol+0x66>
f0105750:	eb 9e                	jmp    f01056f0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105752:	89 c2                	mov    %eax,%edx
f0105754:	f7 da                	neg    %edx
f0105756:	85 ff                	test   %edi,%edi
f0105758:	0f 45 c2             	cmovne %edx,%eax
}
f010575b:	5b                   	pop    %ebx
f010575c:	5e                   	pop    %esi
f010575d:	5f                   	pop    %edi
f010575e:	5d                   	pop    %ebp
f010575f:	c3                   	ret    

f0105760 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105760:	fa                   	cli    

	xorw    %ax, %ax
f0105761:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105763:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105765:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105767:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105769:	0f 01 16             	lgdtl  (%esi)
f010576c:	74 70                	je     f01057de <mpsearch1+0x3>
	movl    %cr0, %eax
f010576e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105771:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105775:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105778:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010577e:	08 00                	or     %al,(%eax)

f0105780 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105780:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105784:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105786:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105788:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010578a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010578e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105790:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105792:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105797:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010579a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010579d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01057a2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01057a5:	8b 25 84 1e 21 f0    	mov    0xf0211e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01057ab:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01057b0:	b8 b0 01 10 f0       	mov    $0xf01001b0,%eax
	call    *%eax
f01057b5:	ff d0                	call   *%eax

f01057b7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01057b7:	eb fe                	jmp    f01057b7 <spin>
f01057b9:	8d 76 00             	lea    0x0(%esi),%esi

f01057bc <gdt>:
	...
f01057c4:	ff                   	(bad)  
f01057c5:	ff 00                	incl   (%eax)
f01057c7:	00 00                	add    %al,(%eax)
f01057c9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01057d0:	00                   	.byte 0x0
f01057d1:	92                   	xchg   %eax,%edx
f01057d2:	cf                   	iret   
	...

f01057d4 <gdtdesc>:
f01057d4:	17                   	pop    %ss
f01057d5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01057da <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01057da:	90                   	nop

f01057db <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01057db:	55                   	push   %ebp
f01057dc:	89 e5                	mov    %esp,%ebp
f01057de:	57                   	push   %edi
f01057df:	56                   	push   %esi
f01057e0:	53                   	push   %ebx
f01057e1:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057e4:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f01057ea:	89 c3                	mov    %eax,%ebx
f01057ec:	c1 eb 0c             	shr    $0xc,%ebx
f01057ef:	39 cb                	cmp    %ecx,%ebx
f01057f1:	72 12                	jb     f0105805 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057f3:	50                   	push   %eax
f01057f4:	68 44 62 10 f0       	push   $0xf0106244
f01057f9:	6a 57                	push   $0x57
f01057fb:	68 3d 7e 10 f0       	push   $0xf0107e3d
f0105800:	e8 3b a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105805:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010580b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010580d:	89 c2                	mov    %eax,%edx
f010580f:	c1 ea 0c             	shr    $0xc,%edx
f0105812:	39 ca                	cmp    %ecx,%edx
f0105814:	72 12                	jb     f0105828 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105816:	50                   	push   %eax
f0105817:	68 44 62 10 f0       	push   $0xf0106244
f010581c:	6a 57                	push   $0x57
f010581e:	68 3d 7e 10 f0       	push   $0xf0107e3d
f0105823:	e8 18 a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105828:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010582e:	eb 2f                	jmp    f010585f <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105830:	83 ec 04             	sub    $0x4,%esp
f0105833:	6a 04                	push   $0x4
f0105835:	68 4d 7e 10 f0       	push   $0xf0107e4d
f010583a:	53                   	push   %ebx
f010583b:	e8 e6 fd ff ff       	call   f0105626 <memcmp>
f0105840:	83 c4 10             	add    $0x10,%esp
f0105843:	85 c0                	test   %eax,%eax
f0105845:	75 15                	jne    f010585c <mpsearch1+0x81>
f0105847:	89 da                	mov    %ebx,%edx
f0105849:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f010584c:	0f b6 0a             	movzbl (%edx),%ecx
f010584f:	01 c8                	add    %ecx,%eax
f0105851:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105854:	39 d7                	cmp    %edx,%edi
f0105856:	75 f4                	jne    f010584c <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105858:	84 c0                	test   %al,%al
f010585a:	74 0e                	je     f010586a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f010585c:	83 c3 10             	add    $0x10,%ebx
f010585f:	39 f3                	cmp    %esi,%ebx
f0105861:	72 cd                	jb     f0105830 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105863:	b8 00 00 00 00       	mov    $0x0,%eax
f0105868:	eb 02                	jmp    f010586c <mpsearch1+0x91>
f010586a:	89 d8                	mov    %ebx,%eax
}
f010586c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010586f:	5b                   	pop    %ebx
f0105870:	5e                   	pop    %esi
f0105871:	5f                   	pop    %edi
f0105872:	5d                   	pop    %ebp
f0105873:	c3                   	ret    

f0105874 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105874:	55                   	push   %ebp
f0105875:	89 e5                	mov    %esp,%ebp
f0105877:	57                   	push   %edi
f0105878:	56                   	push   %esi
f0105879:	53                   	push   %ebx
f010587a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010587d:	c7 05 c0 23 21 f0 20 	movl   $0xf0212020,0xf02123c0
f0105884:	20 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105887:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f010588e:	75 16                	jne    f01058a6 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105890:	68 00 04 00 00       	push   $0x400
f0105895:	68 44 62 10 f0       	push   $0xf0106244
f010589a:	6a 6f                	push   $0x6f
f010589c:	68 3d 7e 10 f0       	push   $0xf0107e3d
f01058a1:	e8 9a a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01058a6:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01058ad:	85 c0                	test   %eax,%eax
f01058af:	74 16                	je     f01058c7 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01058b1:	c1 e0 04             	shl    $0x4,%eax
f01058b4:	ba 00 04 00 00       	mov    $0x400,%edx
f01058b9:	e8 1d ff ff ff       	call   f01057db <mpsearch1>
f01058be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058c1:	85 c0                	test   %eax,%eax
f01058c3:	75 3c                	jne    f0105901 <mp_init+0x8d>
f01058c5:	eb 20                	jmp    f01058e7 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01058c7:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01058ce:	c1 e0 0a             	shl    $0xa,%eax
f01058d1:	2d 00 04 00 00       	sub    $0x400,%eax
f01058d6:	ba 00 04 00 00       	mov    $0x400,%edx
f01058db:	e8 fb fe ff ff       	call   f01057db <mpsearch1>
f01058e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058e3:	85 c0                	test   %eax,%eax
f01058e5:	75 1a                	jne    f0105901 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01058e7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058ec:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01058f1:	e8 e5 fe ff ff       	call   f01057db <mpsearch1>
f01058f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01058f9:	85 c0                	test   %eax,%eax
f01058fb:	0f 84 5d 02 00 00    	je     f0105b5e <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105901:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105904:	8b 70 04             	mov    0x4(%eax),%esi
f0105907:	85 f6                	test   %esi,%esi
f0105909:	74 06                	je     f0105911 <mp_init+0x9d>
f010590b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010590f:	74 15                	je     f0105926 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105911:	83 ec 0c             	sub    $0xc,%esp
f0105914:	68 b0 7c 10 f0       	push   $0xf0107cb0
f0105919:	e8 c3 de ff ff       	call   f01037e1 <cprintf>
f010591e:	83 c4 10             	add    $0x10,%esp
f0105921:	e9 38 02 00 00       	jmp    f0105b5e <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105926:	89 f0                	mov    %esi,%eax
f0105928:	c1 e8 0c             	shr    $0xc,%eax
f010592b:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0105931:	72 15                	jb     f0105948 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105933:	56                   	push   %esi
f0105934:	68 44 62 10 f0       	push   $0xf0106244
f0105939:	68 90 00 00 00       	push   $0x90
f010593e:	68 3d 7e 10 f0       	push   $0xf0107e3d
f0105943:	e8 f8 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105948:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010594e:	83 ec 04             	sub    $0x4,%esp
f0105951:	6a 04                	push   $0x4
f0105953:	68 52 7e 10 f0       	push   $0xf0107e52
f0105958:	53                   	push   %ebx
f0105959:	e8 c8 fc ff ff       	call   f0105626 <memcmp>
f010595e:	83 c4 10             	add    $0x10,%esp
f0105961:	85 c0                	test   %eax,%eax
f0105963:	74 15                	je     f010597a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105965:	83 ec 0c             	sub    $0xc,%esp
f0105968:	68 e0 7c 10 f0       	push   $0xf0107ce0
f010596d:	e8 6f de ff ff       	call   f01037e1 <cprintf>
f0105972:	83 c4 10             	add    $0x10,%esp
f0105975:	e9 e4 01 00 00       	jmp    f0105b5e <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010597a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010597e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105982:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105985:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010598a:	b8 00 00 00 00       	mov    $0x0,%eax
f010598f:	eb 0d                	jmp    f010599e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105991:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105998:	f0 
f0105999:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010599b:	83 c0 01             	add    $0x1,%eax
f010599e:	39 c7                	cmp    %eax,%edi
f01059a0:	75 ef                	jne    f0105991 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01059a2:	84 d2                	test   %dl,%dl
f01059a4:	74 15                	je     f01059bb <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01059a6:	83 ec 0c             	sub    $0xc,%esp
f01059a9:	68 14 7d 10 f0       	push   $0xf0107d14
f01059ae:	e8 2e de ff ff       	call   f01037e1 <cprintf>
f01059b3:	83 c4 10             	add    $0x10,%esp
f01059b6:	e9 a3 01 00 00       	jmp    f0105b5e <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01059bb:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01059bf:	3c 01                	cmp    $0x1,%al
f01059c1:	74 1d                	je     f01059e0 <mp_init+0x16c>
f01059c3:	3c 04                	cmp    $0x4,%al
f01059c5:	74 19                	je     f01059e0 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01059c7:	83 ec 08             	sub    $0x8,%esp
f01059ca:	0f b6 c0             	movzbl %al,%eax
f01059cd:	50                   	push   %eax
f01059ce:	68 38 7d 10 f0       	push   $0xf0107d38
f01059d3:	e8 09 de ff ff       	call   f01037e1 <cprintf>
f01059d8:	83 c4 10             	add    $0x10,%esp
f01059db:	e9 7e 01 00 00       	jmp    f0105b5e <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01059e0:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01059e4:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059e8:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059ed:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01059f2:	01 ce                	add    %ecx,%esi
f01059f4:	eb 0d                	jmp    f0105a03 <mp_init+0x18f>
f01059f6:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01059fd:	f0 
f01059fe:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a00:	83 c0 01             	add    $0x1,%eax
f0105a03:	39 c7                	cmp    %eax,%edi
f0105a05:	75 ef                	jne    f01059f6 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a07:	89 d0                	mov    %edx,%eax
f0105a09:	02 43 2a             	add    0x2a(%ebx),%al
f0105a0c:	74 15                	je     f0105a23 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105a0e:	83 ec 0c             	sub    $0xc,%esp
f0105a11:	68 58 7d 10 f0       	push   $0xf0107d58
f0105a16:	e8 c6 dd ff ff       	call   f01037e1 <cprintf>
f0105a1b:	83 c4 10             	add    $0x10,%esp
f0105a1e:	e9 3b 01 00 00       	jmp    f0105b5e <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a23:	85 db                	test   %ebx,%ebx
f0105a25:	0f 84 33 01 00 00    	je     f0105b5e <mp_init+0x2ea>
		return;
	ismp = 1;
f0105a2b:	c7 05 00 20 21 f0 01 	movl   $0x1,0xf0212000
f0105a32:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105a35:	8b 43 24             	mov    0x24(%ebx),%eax
f0105a38:	a3 00 30 25 f0       	mov    %eax,0xf0253000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105a3d:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105a40:	be 00 00 00 00       	mov    $0x0,%esi
f0105a45:	e9 85 00 00 00       	jmp    f0105acf <mp_init+0x25b>
		switch (*p) {
f0105a4a:	0f b6 07             	movzbl (%edi),%eax
f0105a4d:	84 c0                	test   %al,%al
f0105a4f:	74 06                	je     f0105a57 <mp_init+0x1e3>
f0105a51:	3c 04                	cmp    $0x4,%al
f0105a53:	77 55                	ja     f0105aaa <mp_init+0x236>
f0105a55:	eb 4e                	jmp    f0105aa5 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105a57:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105a5b:	74 11                	je     f0105a6e <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105a5d:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0105a64:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105a69:	a3 c0 23 21 f0       	mov    %eax,0xf02123c0
			if (ncpu < NCPU) {
f0105a6e:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f0105a73:	83 f8 07             	cmp    $0x7,%eax
f0105a76:	7f 13                	jg     f0105a8b <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105a78:	6b d0 74             	imul   $0x74,%eax,%edx
f0105a7b:	88 82 20 20 21 f0    	mov    %al,-0xfdedfe0(%edx)
				ncpu++;
f0105a81:	83 c0 01             	add    $0x1,%eax
f0105a84:	a3 c4 23 21 f0       	mov    %eax,0xf02123c4
f0105a89:	eb 15                	jmp    f0105aa0 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105a8b:	83 ec 08             	sub    $0x8,%esp
f0105a8e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105a92:	50                   	push   %eax
f0105a93:	68 88 7d 10 f0       	push   $0xf0107d88
f0105a98:	e8 44 dd ff ff       	call   f01037e1 <cprintf>
f0105a9d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105aa0:	83 c7 14             	add    $0x14,%edi
			continue;
f0105aa3:	eb 27                	jmp    f0105acc <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105aa5:	83 c7 08             	add    $0x8,%edi
			continue;
f0105aa8:	eb 22                	jmp    f0105acc <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105aaa:	83 ec 08             	sub    $0x8,%esp
f0105aad:	0f b6 c0             	movzbl %al,%eax
f0105ab0:	50                   	push   %eax
f0105ab1:	68 b0 7d 10 f0       	push   $0xf0107db0
f0105ab6:	e8 26 dd ff ff       	call   f01037e1 <cprintf>
			ismp = 0;
f0105abb:	c7 05 00 20 21 f0 00 	movl   $0x0,0xf0212000
f0105ac2:	00 00 00 
			i = conf->entry;
f0105ac5:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105ac9:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105acc:	83 c6 01             	add    $0x1,%esi
f0105acf:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105ad3:	39 c6                	cmp    %eax,%esi
f0105ad5:	0f 82 6f ff ff ff    	jb     f0105a4a <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105adb:	a1 c0 23 21 f0       	mov    0xf02123c0,%eax
f0105ae0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105ae7:	83 3d 00 20 21 f0 00 	cmpl   $0x0,0xf0212000
f0105aee:	75 26                	jne    f0105b16 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105af0:	c7 05 c4 23 21 f0 01 	movl   $0x1,0xf02123c4
f0105af7:	00 00 00 
		lapicaddr = 0;
f0105afa:	c7 05 00 30 25 f0 00 	movl   $0x0,0xf0253000
f0105b01:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105b04:	83 ec 0c             	sub    $0xc,%esp
f0105b07:	68 d0 7d 10 f0       	push   $0xf0107dd0
f0105b0c:	e8 d0 dc ff ff       	call   f01037e1 <cprintf>
		return;
f0105b11:	83 c4 10             	add    $0x10,%esp
f0105b14:	eb 48                	jmp    f0105b5e <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105b16:	83 ec 04             	sub    $0x4,%esp
f0105b19:	ff 35 c4 23 21 f0    	pushl  0xf02123c4
f0105b1f:	0f b6 00             	movzbl (%eax),%eax
f0105b22:	50                   	push   %eax
f0105b23:	68 57 7e 10 f0       	push   $0xf0107e57
f0105b28:	e8 b4 dc ff ff       	call   f01037e1 <cprintf>

	if (mp->imcrp) {
f0105b2d:	83 c4 10             	add    $0x10,%esp
f0105b30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b33:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105b37:	74 25                	je     f0105b5e <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105b39:	83 ec 0c             	sub    $0xc,%esp
f0105b3c:	68 fc 7d 10 f0       	push   $0xf0107dfc
f0105b41:	e8 9b dc ff ff       	call   f01037e1 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b46:	ba 22 00 00 00       	mov    $0x22,%edx
f0105b4b:	b8 70 00 00 00       	mov    $0x70,%eax
f0105b50:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105b51:	ba 23 00 00 00       	mov    $0x23,%edx
f0105b56:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b57:	83 c8 01             	or     $0x1,%eax
f0105b5a:	ee                   	out    %al,(%dx)
f0105b5b:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b61:	5b                   	pop    %ebx
f0105b62:	5e                   	pop    %esi
f0105b63:	5f                   	pop    %edi
f0105b64:	5d                   	pop    %ebp
f0105b65:	c3                   	ret    

f0105b66 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105b66:	55                   	push   %ebp
f0105b67:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105b69:	8b 0d 04 30 25 f0    	mov    0xf0253004,%ecx
f0105b6f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105b72:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105b74:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105b79:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105b7c:	5d                   	pop    %ebp
f0105b7d:	c3                   	ret    

f0105b7e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105b7e:	55                   	push   %ebp
f0105b7f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105b81:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105b86:	85 c0                	test   %eax,%eax
f0105b88:	74 08                	je     f0105b92 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105b8a:	8b 40 20             	mov    0x20(%eax),%eax
f0105b8d:	c1 e8 18             	shr    $0x18,%eax
f0105b90:	eb 05                	jmp    f0105b97 <cpunum+0x19>
	return 0;
f0105b92:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b97:	5d                   	pop    %ebp
f0105b98:	c3                   	ret    

f0105b99 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105b99:	a1 00 30 25 f0       	mov    0xf0253000,%eax
f0105b9e:	85 c0                	test   %eax,%eax
f0105ba0:	0f 84 21 01 00 00    	je     f0105cc7 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105ba6:	55                   	push   %ebp
f0105ba7:	89 e5                	mov    %esp,%ebp
f0105ba9:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105bac:	68 00 10 00 00       	push   $0x1000
f0105bb1:	50                   	push   %eax
f0105bb2:	e8 af b7 ff ff       	call   f0101366 <mmio_map_region>
f0105bb7:	a3 04 30 25 f0       	mov    %eax,0xf0253004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105bbc:	ba 27 01 00 00       	mov    $0x127,%edx
f0105bc1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105bc6:	e8 9b ff ff ff       	call   f0105b66 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105bcb:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105bd0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105bd5:	e8 8c ff ff ff       	call   f0105b66 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105bda:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105bdf:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105be4:	e8 7d ff ff ff       	call   f0105b66 <lapicw>
	lapicw(TICR, 10000000); 
f0105be9:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105bee:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105bf3:	e8 6e ff ff ff       	call   f0105b66 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105bf8:	e8 81 ff ff ff       	call   f0105b7e <cpunum>
f0105bfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c00:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105c05:	83 c4 10             	add    $0x10,%esp
f0105c08:	39 05 c0 23 21 f0    	cmp    %eax,0xf02123c0
f0105c0e:	74 0f                	je     f0105c1f <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105c10:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c15:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105c1a:	e8 47 ff ff ff       	call   f0105b66 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c1f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c24:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105c29:	e8 38 ff ff ff       	call   f0105b66 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105c2e:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105c33:	8b 40 30             	mov    0x30(%eax),%eax
f0105c36:	c1 e8 10             	shr    $0x10,%eax
f0105c39:	3c 03                	cmp    $0x3,%al
f0105c3b:	76 0f                	jbe    f0105c4c <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105c3d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c42:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105c47:	e8 1a ff ff ff       	call   f0105b66 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105c4c:	ba 33 00 00 00       	mov    $0x33,%edx
f0105c51:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105c56:	e8 0b ff ff ff       	call   f0105b66 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105c5b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c60:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c65:	e8 fc fe ff ff       	call   f0105b66 <lapicw>
	lapicw(ESR, 0);
f0105c6a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c6f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c74:	e8 ed fe ff ff       	call   f0105b66 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105c79:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c7e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105c83:	e8 de fe ff ff       	call   f0105b66 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105c88:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c8d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c92:	e8 cf fe ff ff       	call   f0105b66 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105c97:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105c9c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ca1:	e8 c0 fe ff ff       	call   f0105b66 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105ca6:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105cac:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105cb2:	f6 c4 10             	test   $0x10,%ah
f0105cb5:	75 f5                	jne    f0105cac <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105cb7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cbc:	b8 20 00 00 00       	mov    $0x20,%eax
f0105cc1:	e8 a0 fe ff ff       	call   f0105b66 <lapicw>
}
f0105cc6:	c9                   	leave  
f0105cc7:	f3 c3                	repz ret 

f0105cc9 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105cc9:	83 3d 04 30 25 f0 00 	cmpl   $0x0,0xf0253004
f0105cd0:	74 13                	je     f0105ce5 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105cd2:	55                   	push   %ebp
f0105cd3:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105cd5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cda:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105cdf:	e8 82 fe ff ff       	call   f0105b66 <lapicw>
}
f0105ce4:	5d                   	pop    %ebp
f0105ce5:	f3 c3                	repz ret 

f0105ce7 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ce7:	55                   	push   %ebp
f0105ce8:	89 e5                	mov    %esp,%ebp
f0105cea:	56                   	push   %esi
f0105ceb:	53                   	push   %ebx
f0105cec:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105cf2:	ba 70 00 00 00       	mov    $0x70,%edx
f0105cf7:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105cfc:	ee                   	out    %al,(%dx)
f0105cfd:	ba 71 00 00 00       	mov    $0x71,%edx
f0105d02:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d07:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d08:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105d0f:	75 19                	jne    f0105d2a <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d11:	68 67 04 00 00       	push   $0x467
f0105d16:	68 44 62 10 f0       	push   $0xf0106244
f0105d1b:	68 98 00 00 00       	push   $0x98
f0105d20:	68 74 7e 10 f0       	push   $0xf0107e74
f0105d25:	e8 16 a3 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105d2a:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105d31:	00 00 
	wrv[1] = addr >> 4;
f0105d33:	89 d8                	mov    %ebx,%eax
f0105d35:	c1 e8 04             	shr    $0x4,%eax
f0105d38:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105d3e:	c1 e6 18             	shl    $0x18,%esi
f0105d41:	89 f2                	mov    %esi,%edx
f0105d43:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d48:	e8 19 fe ff ff       	call   f0105b66 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105d4d:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105d52:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d57:	e8 0a fe ff ff       	call   f0105b66 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105d5c:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105d61:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d66:	e8 fb fd ff ff       	call   f0105b66 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d6b:	c1 eb 0c             	shr    $0xc,%ebx
f0105d6e:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d71:	89 f2                	mov    %esi,%edx
f0105d73:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d78:	e8 e9 fd ff ff       	call   f0105b66 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d7d:	89 da                	mov    %ebx,%edx
f0105d7f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d84:	e8 dd fd ff ff       	call   f0105b66 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d89:	89 f2                	mov    %esi,%edx
f0105d8b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d90:	e8 d1 fd ff ff       	call   f0105b66 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d95:	89 da                	mov    %ebx,%edx
f0105d97:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d9c:	e8 c5 fd ff ff       	call   f0105b66 <lapicw>
		microdelay(200);
	}
}
f0105da1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105da4:	5b                   	pop    %ebx
f0105da5:	5e                   	pop    %esi
f0105da6:	5d                   	pop    %ebp
f0105da7:	c3                   	ret    

f0105da8 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105da8:	55                   	push   %ebp
f0105da9:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105dab:	8b 55 08             	mov    0x8(%ebp),%edx
f0105dae:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105db4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105db9:	e8 a8 fd ff ff       	call   f0105b66 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105dbe:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105dc4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105dca:	f6 c4 10             	test   $0x10,%ah
f0105dcd:	75 f5                	jne    f0105dc4 <lapic_ipi+0x1c>
		;
}
f0105dcf:	5d                   	pop    %ebp
f0105dd0:	c3                   	ret    

f0105dd1 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105dd1:	55                   	push   %ebp
f0105dd2:	89 e5                	mov    %esp,%ebp
f0105dd4:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105dd7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105de0:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105de3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105dea:	5d                   	pop    %ebp
f0105deb:	c3                   	ret    

f0105dec <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105dec:	55                   	push   %ebp
f0105ded:	89 e5                	mov    %esp,%ebp
f0105def:	56                   	push   %esi
f0105df0:	53                   	push   %ebx
f0105df1:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105df4:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105df7:	74 14                	je     f0105e0d <spin_lock+0x21>
f0105df9:	8b 73 08             	mov    0x8(%ebx),%esi
f0105dfc:	e8 7d fd ff ff       	call   f0105b7e <cpunum>
f0105e01:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e04:	05 20 20 21 f0       	add    $0xf0212020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105e09:	39 c6                	cmp    %eax,%esi
f0105e0b:	74 07                	je     f0105e14 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105e0d:	ba 01 00 00 00       	mov    $0x1,%edx
f0105e12:	eb 20                	jmp    f0105e34 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105e14:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105e17:	e8 62 fd ff ff       	call   f0105b7e <cpunum>
f0105e1c:	83 ec 0c             	sub    $0xc,%esp
f0105e1f:	53                   	push   %ebx
f0105e20:	50                   	push   %eax
f0105e21:	68 84 7e 10 f0       	push   $0xf0107e84
f0105e26:	6a 41                	push   $0x41
f0105e28:	68 e8 7e 10 f0       	push   $0xf0107ee8
f0105e2d:	e8 0e a2 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105e32:	f3 90                	pause  
f0105e34:	89 d0                	mov    %edx,%eax
f0105e36:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105e39:	85 c0                	test   %eax,%eax
f0105e3b:	75 f5                	jne    f0105e32 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105e3d:	e8 3c fd ff ff       	call   f0105b7e <cpunum>
f0105e42:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e45:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105e4a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105e4d:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105e50:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e52:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e57:	eb 0b                	jmp    f0105e64 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105e59:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105e5c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105e5f:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e61:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105e64:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105e6a:	76 11                	jbe    f0105e7d <spin_lock+0x91>
f0105e6c:	83 f8 09             	cmp    $0x9,%eax
f0105e6f:	7e e8                	jle    f0105e59 <spin_lock+0x6d>
f0105e71:	eb 0a                	jmp    f0105e7d <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105e73:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105e7a:	83 c0 01             	add    $0x1,%eax
f0105e7d:	83 f8 09             	cmp    $0x9,%eax
f0105e80:	7e f1                	jle    f0105e73 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105e82:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e85:	5b                   	pop    %ebx
f0105e86:	5e                   	pop    %esi
f0105e87:	5d                   	pop    %ebp
f0105e88:	c3                   	ret    

f0105e89 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105e89:	55                   	push   %ebp
f0105e8a:	89 e5                	mov    %esp,%ebp
f0105e8c:	57                   	push   %edi
f0105e8d:	56                   	push   %esi
f0105e8e:	53                   	push   %ebx
f0105e8f:	83 ec 4c             	sub    $0x4c,%esp
f0105e92:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e95:	83 3e 00             	cmpl   $0x0,(%esi)
f0105e98:	74 18                	je     f0105eb2 <spin_unlock+0x29>
f0105e9a:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105e9d:	e8 dc fc ff ff       	call   f0105b7e <cpunum>
f0105ea2:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ea5:	05 20 20 21 f0       	add    $0xf0212020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105eaa:	39 c3                	cmp    %eax,%ebx
f0105eac:	0f 84 a5 00 00 00    	je     f0105f57 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105eb2:	83 ec 04             	sub    $0x4,%esp
f0105eb5:	6a 28                	push   $0x28
f0105eb7:	8d 46 0c             	lea    0xc(%esi),%eax
f0105eba:	50                   	push   %eax
f0105ebb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105ebe:	53                   	push   %ebx
f0105ebf:	e8 e7 f6 ff ff       	call   f01055ab <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105ec4:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105ec7:	0f b6 38             	movzbl (%eax),%edi
f0105eca:	8b 76 04             	mov    0x4(%esi),%esi
f0105ecd:	e8 ac fc ff ff       	call   f0105b7e <cpunum>
f0105ed2:	57                   	push   %edi
f0105ed3:	56                   	push   %esi
f0105ed4:	50                   	push   %eax
f0105ed5:	68 b0 7e 10 f0       	push   $0xf0107eb0
f0105eda:	e8 02 d9 ff ff       	call   f01037e1 <cprintf>
f0105edf:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105ee2:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105ee5:	eb 54                	jmp    f0105f3b <spin_unlock+0xb2>
f0105ee7:	83 ec 08             	sub    $0x8,%esp
f0105eea:	57                   	push   %edi
f0105eeb:	50                   	push   %eax
f0105eec:	e8 ca eb ff ff       	call   f0104abb <debuginfo_eip>
f0105ef1:	83 c4 10             	add    $0x10,%esp
f0105ef4:	85 c0                	test   %eax,%eax
f0105ef6:	78 27                	js     f0105f1f <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105ef8:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105efa:	83 ec 04             	sub    $0x4,%esp
f0105efd:	89 c2                	mov    %eax,%edx
f0105eff:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105f02:	52                   	push   %edx
f0105f03:	ff 75 b0             	pushl  -0x50(%ebp)
f0105f06:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105f09:	ff 75 ac             	pushl  -0x54(%ebp)
f0105f0c:	ff 75 a8             	pushl  -0x58(%ebp)
f0105f0f:	50                   	push   %eax
f0105f10:	68 f8 7e 10 f0       	push   $0xf0107ef8
f0105f15:	e8 c7 d8 ff ff       	call   f01037e1 <cprintf>
f0105f1a:	83 c4 20             	add    $0x20,%esp
f0105f1d:	eb 12                	jmp    f0105f31 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f1f:	83 ec 08             	sub    $0x8,%esp
f0105f22:	ff 36                	pushl  (%esi)
f0105f24:	68 0f 7f 10 f0       	push   $0xf0107f0f
f0105f29:	e8 b3 d8 ff ff       	call   f01037e1 <cprintf>
f0105f2e:	83 c4 10             	add    $0x10,%esp
f0105f31:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105f34:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105f37:	39 c3                	cmp    %eax,%ebx
f0105f39:	74 08                	je     f0105f43 <spin_unlock+0xba>
f0105f3b:	89 de                	mov    %ebx,%esi
f0105f3d:	8b 03                	mov    (%ebx),%eax
f0105f3f:	85 c0                	test   %eax,%eax
f0105f41:	75 a4                	jne    f0105ee7 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105f43:	83 ec 04             	sub    $0x4,%esp
f0105f46:	68 17 7f 10 f0       	push   $0xf0107f17
f0105f4b:	6a 67                	push   $0x67
f0105f4d:	68 e8 7e 10 f0       	push   $0xf0107ee8
f0105f52:	e8 e9 a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105f57:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105f5e:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105f65:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f6a:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f70:	5b                   	pop    %ebx
f0105f71:	5e                   	pop    %esi
f0105f72:	5f                   	pop    %edi
f0105f73:	5d                   	pop    %ebp
f0105f74:	c3                   	ret    
f0105f75:	66 90                	xchg   %ax,%ax
f0105f77:	66 90                	xchg   %ax,%ax
f0105f79:	66 90                	xchg   %ax,%ax
f0105f7b:	66 90                	xchg   %ax,%ax
f0105f7d:	66 90                	xchg   %ax,%ax
f0105f7f:	90                   	nop

f0105f80 <__udivdi3>:
f0105f80:	55                   	push   %ebp
f0105f81:	57                   	push   %edi
f0105f82:	56                   	push   %esi
f0105f83:	53                   	push   %ebx
f0105f84:	83 ec 1c             	sub    $0x1c,%esp
f0105f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105f97:	85 f6                	test   %esi,%esi
f0105f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f9d:	89 ca                	mov    %ecx,%edx
f0105f9f:	89 f8                	mov    %edi,%eax
f0105fa1:	75 3d                	jne    f0105fe0 <__udivdi3+0x60>
f0105fa3:	39 cf                	cmp    %ecx,%edi
f0105fa5:	0f 87 c5 00 00 00    	ja     f0106070 <__udivdi3+0xf0>
f0105fab:	85 ff                	test   %edi,%edi
f0105fad:	89 fd                	mov    %edi,%ebp
f0105faf:	75 0b                	jne    f0105fbc <__udivdi3+0x3c>
f0105fb1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105fb6:	31 d2                	xor    %edx,%edx
f0105fb8:	f7 f7                	div    %edi
f0105fba:	89 c5                	mov    %eax,%ebp
f0105fbc:	89 c8                	mov    %ecx,%eax
f0105fbe:	31 d2                	xor    %edx,%edx
f0105fc0:	f7 f5                	div    %ebp
f0105fc2:	89 c1                	mov    %eax,%ecx
f0105fc4:	89 d8                	mov    %ebx,%eax
f0105fc6:	89 cf                	mov    %ecx,%edi
f0105fc8:	f7 f5                	div    %ebp
f0105fca:	89 c3                	mov    %eax,%ebx
f0105fcc:	89 d8                	mov    %ebx,%eax
f0105fce:	89 fa                	mov    %edi,%edx
f0105fd0:	83 c4 1c             	add    $0x1c,%esp
f0105fd3:	5b                   	pop    %ebx
f0105fd4:	5e                   	pop    %esi
f0105fd5:	5f                   	pop    %edi
f0105fd6:	5d                   	pop    %ebp
f0105fd7:	c3                   	ret    
f0105fd8:	90                   	nop
f0105fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105fe0:	39 ce                	cmp    %ecx,%esi
f0105fe2:	77 74                	ja     f0106058 <__udivdi3+0xd8>
f0105fe4:	0f bd fe             	bsr    %esi,%edi
f0105fe7:	83 f7 1f             	xor    $0x1f,%edi
f0105fea:	0f 84 98 00 00 00    	je     f0106088 <__udivdi3+0x108>
f0105ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105ff5:	89 f9                	mov    %edi,%ecx
f0105ff7:	89 c5                	mov    %eax,%ebp
f0105ff9:	29 fb                	sub    %edi,%ebx
f0105ffb:	d3 e6                	shl    %cl,%esi
f0105ffd:	89 d9                	mov    %ebx,%ecx
f0105fff:	d3 ed                	shr    %cl,%ebp
f0106001:	89 f9                	mov    %edi,%ecx
f0106003:	d3 e0                	shl    %cl,%eax
f0106005:	09 ee                	or     %ebp,%esi
f0106007:	89 d9                	mov    %ebx,%ecx
f0106009:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010600d:	89 d5                	mov    %edx,%ebp
f010600f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106013:	d3 ed                	shr    %cl,%ebp
f0106015:	89 f9                	mov    %edi,%ecx
f0106017:	d3 e2                	shl    %cl,%edx
f0106019:	89 d9                	mov    %ebx,%ecx
f010601b:	d3 e8                	shr    %cl,%eax
f010601d:	09 c2                	or     %eax,%edx
f010601f:	89 d0                	mov    %edx,%eax
f0106021:	89 ea                	mov    %ebp,%edx
f0106023:	f7 f6                	div    %esi
f0106025:	89 d5                	mov    %edx,%ebp
f0106027:	89 c3                	mov    %eax,%ebx
f0106029:	f7 64 24 0c          	mull   0xc(%esp)
f010602d:	39 d5                	cmp    %edx,%ebp
f010602f:	72 10                	jb     f0106041 <__udivdi3+0xc1>
f0106031:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106035:	89 f9                	mov    %edi,%ecx
f0106037:	d3 e6                	shl    %cl,%esi
f0106039:	39 c6                	cmp    %eax,%esi
f010603b:	73 07                	jae    f0106044 <__udivdi3+0xc4>
f010603d:	39 d5                	cmp    %edx,%ebp
f010603f:	75 03                	jne    f0106044 <__udivdi3+0xc4>
f0106041:	83 eb 01             	sub    $0x1,%ebx
f0106044:	31 ff                	xor    %edi,%edi
f0106046:	89 d8                	mov    %ebx,%eax
f0106048:	89 fa                	mov    %edi,%edx
f010604a:	83 c4 1c             	add    $0x1c,%esp
f010604d:	5b                   	pop    %ebx
f010604e:	5e                   	pop    %esi
f010604f:	5f                   	pop    %edi
f0106050:	5d                   	pop    %ebp
f0106051:	c3                   	ret    
f0106052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106058:	31 ff                	xor    %edi,%edi
f010605a:	31 db                	xor    %ebx,%ebx
f010605c:	89 d8                	mov    %ebx,%eax
f010605e:	89 fa                	mov    %edi,%edx
f0106060:	83 c4 1c             	add    $0x1c,%esp
f0106063:	5b                   	pop    %ebx
f0106064:	5e                   	pop    %esi
f0106065:	5f                   	pop    %edi
f0106066:	5d                   	pop    %ebp
f0106067:	c3                   	ret    
f0106068:	90                   	nop
f0106069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106070:	89 d8                	mov    %ebx,%eax
f0106072:	f7 f7                	div    %edi
f0106074:	31 ff                	xor    %edi,%edi
f0106076:	89 c3                	mov    %eax,%ebx
f0106078:	89 d8                	mov    %ebx,%eax
f010607a:	89 fa                	mov    %edi,%edx
f010607c:	83 c4 1c             	add    $0x1c,%esp
f010607f:	5b                   	pop    %ebx
f0106080:	5e                   	pop    %esi
f0106081:	5f                   	pop    %edi
f0106082:	5d                   	pop    %ebp
f0106083:	c3                   	ret    
f0106084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106088:	39 ce                	cmp    %ecx,%esi
f010608a:	72 0c                	jb     f0106098 <__udivdi3+0x118>
f010608c:	31 db                	xor    %ebx,%ebx
f010608e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106092:	0f 87 34 ff ff ff    	ja     f0105fcc <__udivdi3+0x4c>
f0106098:	bb 01 00 00 00       	mov    $0x1,%ebx
f010609d:	e9 2a ff ff ff       	jmp    f0105fcc <__udivdi3+0x4c>
f01060a2:	66 90                	xchg   %ax,%ax
f01060a4:	66 90                	xchg   %ax,%ax
f01060a6:	66 90                	xchg   %ax,%ax
f01060a8:	66 90                	xchg   %ax,%ax
f01060aa:	66 90                	xchg   %ax,%ax
f01060ac:	66 90                	xchg   %ax,%ax
f01060ae:	66 90                	xchg   %ax,%ax

f01060b0 <__umoddi3>:
f01060b0:	55                   	push   %ebp
f01060b1:	57                   	push   %edi
f01060b2:	56                   	push   %esi
f01060b3:	53                   	push   %ebx
f01060b4:	83 ec 1c             	sub    $0x1c,%esp
f01060b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01060bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01060bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01060c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01060c7:	85 d2                	test   %edx,%edx
f01060c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01060cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01060d1:	89 f3                	mov    %esi,%ebx
f01060d3:	89 3c 24             	mov    %edi,(%esp)
f01060d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01060da:	75 1c                	jne    f01060f8 <__umoddi3+0x48>
f01060dc:	39 f7                	cmp    %esi,%edi
f01060de:	76 50                	jbe    f0106130 <__umoddi3+0x80>
f01060e0:	89 c8                	mov    %ecx,%eax
f01060e2:	89 f2                	mov    %esi,%edx
f01060e4:	f7 f7                	div    %edi
f01060e6:	89 d0                	mov    %edx,%eax
f01060e8:	31 d2                	xor    %edx,%edx
f01060ea:	83 c4 1c             	add    $0x1c,%esp
f01060ed:	5b                   	pop    %ebx
f01060ee:	5e                   	pop    %esi
f01060ef:	5f                   	pop    %edi
f01060f0:	5d                   	pop    %ebp
f01060f1:	c3                   	ret    
f01060f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060f8:	39 f2                	cmp    %esi,%edx
f01060fa:	89 d0                	mov    %edx,%eax
f01060fc:	77 52                	ja     f0106150 <__umoddi3+0xa0>
f01060fe:	0f bd ea             	bsr    %edx,%ebp
f0106101:	83 f5 1f             	xor    $0x1f,%ebp
f0106104:	75 5a                	jne    f0106160 <__umoddi3+0xb0>
f0106106:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010610a:	0f 82 e0 00 00 00    	jb     f01061f0 <__umoddi3+0x140>
f0106110:	39 0c 24             	cmp    %ecx,(%esp)
f0106113:	0f 86 d7 00 00 00    	jbe    f01061f0 <__umoddi3+0x140>
f0106119:	8b 44 24 08          	mov    0x8(%esp),%eax
f010611d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106121:	83 c4 1c             	add    $0x1c,%esp
f0106124:	5b                   	pop    %ebx
f0106125:	5e                   	pop    %esi
f0106126:	5f                   	pop    %edi
f0106127:	5d                   	pop    %ebp
f0106128:	c3                   	ret    
f0106129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106130:	85 ff                	test   %edi,%edi
f0106132:	89 fd                	mov    %edi,%ebp
f0106134:	75 0b                	jne    f0106141 <__umoddi3+0x91>
f0106136:	b8 01 00 00 00       	mov    $0x1,%eax
f010613b:	31 d2                	xor    %edx,%edx
f010613d:	f7 f7                	div    %edi
f010613f:	89 c5                	mov    %eax,%ebp
f0106141:	89 f0                	mov    %esi,%eax
f0106143:	31 d2                	xor    %edx,%edx
f0106145:	f7 f5                	div    %ebp
f0106147:	89 c8                	mov    %ecx,%eax
f0106149:	f7 f5                	div    %ebp
f010614b:	89 d0                	mov    %edx,%eax
f010614d:	eb 99                	jmp    f01060e8 <__umoddi3+0x38>
f010614f:	90                   	nop
f0106150:	89 c8                	mov    %ecx,%eax
f0106152:	89 f2                	mov    %esi,%edx
f0106154:	83 c4 1c             	add    $0x1c,%esp
f0106157:	5b                   	pop    %ebx
f0106158:	5e                   	pop    %esi
f0106159:	5f                   	pop    %edi
f010615a:	5d                   	pop    %ebp
f010615b:	c3                   	ret    
f010615c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106160:	8b 34 24             	mov    (%esp),%esi
f0106163:	bf 20 00 00 00       	mov    $0x20,%edi
f0106168:	89 e9                	mov    %ebp,%ecx
f010616a:	29 ef                	sub    %ebp,%edi
f010616c:	d3 e0                	shl    %cl,%eax
f010616e:	89 f9                	mov    %edi,%ecx
f0106170:	89 f2                	mov    %esi,%edx
f0106172:	d3 ea                	shr    %cl,%edx
f0106174:	89 e9                	mov    %ebp,%ecx
f0106176:	09 c2                	or     %eax,%edx
f0106178:	89 d8                	mov    %ebx,%eax
f010617a:	89 14 24             	mov    %edx,(%esp)
f010617d:	89 f2                	mov    %esi,%edx
f010617f:	d3 e2                	shl    %cl,%edx
f0106181:	89 f9                	mov    %edi,%ecx
f0106183:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106187:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010618b:	d3 e8                	shr    %cl,%eax
f010618d:	89 e9                	mov    %ebp,%ecx
f010618f:	89 c6                	mov    %eax,%esi
f0106191:	d3 e3                	shl    %cl,%ebx
f0106193:	89 f9                	mov    %edi,%ecx
f0106195:	89 d0                	mov    %edx,%eax
f0106197:	d3 e8                	shr    %cl,%eax
f0106199:	89 e9                	mov    %ebp,%ecx
f010619b:	09 d8                	or     %ebx,%eax
f010619d:	89 d3                	mov    %edx,%ebx
f010619f:	89 f2                	mov    %esi,%edx
f01061a1:	f7 34 24             	divl   (%esp)
f01061a4:	89 d6                	mov    %edx,%esi
f01061a6:	d3 e3                	shl    %cl,%ebx
f01061a8:	f7 64 24 04          	mull   0x4(%esp)
f01061ac:	39 d6                	cmp    %edx,%esi
f01061ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01061b2:	89 d1                	mov    %edx,%ecx
f01061b4:	89 c3                	mov    %eax,%ebx
f01061b6:	72 08                	jb     f01061c0 <__umoddi3+0x110>
f01061b8:	75 11                	jne    f01061cb <__umoddi3+0x11b>
f01061ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01061be:	73 0b                	jae    f01061cb <__umoddi3+0x11b>
f01061c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01061c4:	1b 14 24             	sbb    (%esp),%edx
f01061c7:	89 d1                	mov    %edx,%ecx
f01061c9:	89 c3                	mov    %eax,%ebx
f01061cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01061cf:	29 da                	sub    %ebx,%edx
f01061d1:	19 ce                	sbb    %ecx,%esi
f01061d3:	89 f9                	mov    %edi,%ecx
f01061d5:	89 f0                	mov    %esi,%eax
f01061d7:	d3 e0                	shl    %cl,%eax
f01061d9:	89 e9                	mov    %ebp,%ecx
f01061db:	d3 ea                	shr    %cl,%edx
f01061dd:	89 e9                	mov    %ebp,%ecx
f01061df:	d3 ee                	shr    %cl,%esi
f01061e1:	09 d0                	or     %edx,%eax
f01061e3:	89 f2                	mov    %esi,%edx
f01061e5:	83 c4 1c             	add    $0x1c,%esp
f01061e8:	5b                   	pop    %ebx
f01061e9:	5e                   	pop    %esi
f01061ea:	5f                   	pop    %edi
f01061eb:	5d                   	pop    %ebp
f01061ec:	c3                   	ret    
f01061ed:	8d 76 00             	lea    0x0(%esi),%esi
f01061f0:	29 f9                	sub    %edi,%ecx
f01061f2:	19 d6                	sbb    %edx,%esi
f01061f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01061f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061fc:	e9 18 ff ff ff       	jmp    f0106119 <__umoddi3+0x69>
