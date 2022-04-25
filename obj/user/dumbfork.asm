
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 70 0c 00 00       	call   800cba <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 60 1f 80 00       	push   $0x801f60
  800057:	6a 20                	push   $0x20
  800059:	68 73 1f 80 00       	push   $0x801f73
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 87 0c 00 00       	call   800cfd <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 83 1f 80 00       	push   $0x801f83
  800083:	6a 22                	push   $0x22
  800085:	68 73 1f 80 00       	push   $0x801f73
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 a7 09 00 00       	call   800a49 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 8e 0c 00 00       	call   800d3f <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 94 1f 80 00       	push   $0x801f94
  8000be:	6a 25                	push   $0x25
  8000c0:	68 73 1f 80 00       	push   $0x801f73
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 a7 1f 80 00       	push   $0x801fa7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 73 1f 80 00       	push   $0x801f73
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 79 0b 00 00       	call   800c7c <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 20 0c 00 00       	call   800d81 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 b7 1f 80 00       	push   $0x801fb7
  80016e:	6a 4c                	push   $0x4c
  800170:	68 73 1f 80 00       	push   $0x801f73
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be d5 1f 80 00       	mov    $0x801fd5,%esi
  80019a:	b8 ce 1f 80 00       	mov    $0x801fce,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 db 1f 80 00       	push   $0x801fdb
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 de 0a 00 00       	call   800c9b <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e6:	e8 91 0a 00 00       	call   800c7c <sys_getenvid>
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 4a 0e 00 00       	call   801076 <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 05 0a 00 00       	call   800c3b <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 2e 0a 00 00       	call   800c7c <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 f8 1f 80 00       	push   $0x801ff8
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 eb 1f 80 00 	movl   $0x801feb,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 4d 09 00 00       	call   800bfe <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 54 01 00 00       	call   80044b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 f2 08 00 00       	call   800bfe <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 44 19 00 00       	call   801cc0 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 31 1a 00 00       	call   801df0 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 1b 20 80 00 	movsbl 0x80201b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003da:	83 fa 01             	cmp    $0x1,%edx
  8003dd:	7e 0e                	jle    8003ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	8b 52 04             	mov    0x4(%edx),%edx
  8003eb:	eb 22                	jmp    80040f <getuint+0x38>
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 10                	je     800401 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	eb 0e                	jmp    80040f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 04             	lea    0x4(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800417:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041b:	8b 10                	mov    (%eax),%edx
  80041d:	3b 50 04             	cmp    0x4(%eax),%edx
  800420:	73 0a                	jae    80042c <sprintputch+0x1b>
		*b->buf++ = ch;
  800422:	8d 4a 01             	lea    0x1(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	88 02                	mov    %al,(%edx)
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 10             	pushl  0x10(%ebp)
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 05 00 00 00       	call   80044b <vprintfmt>
	va_end(ap);
}
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	57                   	push   %edi
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 2c             	sub    $0x2c,%esp
  800454:	8b 75 08             	mov    0x8(%ebp),%esi
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045d:	eb 12                	jmp    800471 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 a7 03 00 00    	je     80080e <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	50                   	push   %eax
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 e2                	jne    80045f <vprintfmt+0x14>
  80047d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800481:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800488:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80048f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800496:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80049d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a2:	eb 07                	jmp    8004ab <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8d 47 01             	lea    0x1(%edi),%eax
  8004ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b1:	0f b6 07             	movzbl (%edi),%eax
  8004b4:	0f b6 d0             	movzbl %al,%edx
  8004b7:	83 e8 23             	sub    $0x23,%eax
  8004ba:	3c 55                	cmp    $0x55,%al
  8004bc:	0f 87 31 03 00 00    	ja     8007f3 <vprintfmt+0x3a8>
  8004c2:	0f b6 c0             	movzbl %al,%eax
  8004c5:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004cf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d3:	eb d6                	jmp    8004ab <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004e7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004ea:	8d 72 d0             	lea    -0x30(%edx),%esi
  8004ed:	83 fe 09             	cmp    $0x9,%esi
  8004f0:	77 34                	ja     800526 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f5:	eb e9                	jmp    8004e0 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 50 04             	lea    0x4(%eax),%edx
  8004fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800500:	8b 00                	mov    (%eax),%eax
  800502:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800508:	eb 22                	jmp    80052c <vprintfmt+0xe1>
  80050a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050d:	85 c0                	test   %eax,%eax
  80050f:	0f 48 c1             	cmovs  %ecx,%eax
  800512:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800518:	eb 91                	jmp    8004ab <vprintfmt+0x60>
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800524:	eb 85                	jmp    8004ab <vprintfmt+0x60>
  800526:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800529:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80052c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800530:	0f 89 75 ff ff ff    	jns    8004ab <vprintfmt+0x60>
				width = precision, precision = -1;
  800536:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800539:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800543:	e9 63 ff ff ff       	jmp    8004ab <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800548:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054f:	e9 57 ff ff ff       	jmp    8004ab <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	ff 30                	pushl  (%eax)
  800563:	ff d6                	call   *%esi
			break;
  800565:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80056b:	e9 01 ff ff ff       	jmp    800471 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	99                   	cltd   
  80057c:	31 d0                	xor    %edx,%eax
  80057e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800580:	83 f8 0f             	cmp    $0xf,%eax
  800583:	7f 0b                	jg     800590 <vprintfmt+0x145>
  800585:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	75 18                	jne    8005a8 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800590:	50                   	push   %eax
  800591:	68 33 20 80 00       	push   $0x802033
  800596:	53                   	push   %ebx
  800597:	56                   	push   %esi
  800598:	e8 91 fe ff ff       	call   80042e <printfmt>
  80059d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a3:	e9 c9 fe ff ff       	jmp    800471 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a8:	52                   	push   %edx
  8005a9:	68 f5 23 80 00       	push   $0x8023f5
  8005ae:	53                   	push   %ebx
  8005af:	56                   	push   %esi
  8005b0:	e8 79 fe ff ff       	call   80042e <printfmt>
  8005b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	e9 b1 fe ff ff       	jmp    800471 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005cb:	85 ff                	test   %edi,%edi
  8005cd:	b8 2c 20 80 00       	mov    $0x80202c,%eax
  8005d2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d9:	0f 8e 94 00 00 00    	jle    800673 <vprintfmt+0x228>
  8005df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e3:	0f 84 98 00 00 00    	je     800681 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	ff 75 cc             	pushl  -0x34(%ebp)
  8005ef:	57                   	push   %edi
  8005f0:	e8 a1 02 00 00       	call   800896 <strnlen>
  8005f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f8:	29 c1                	sub    %eax,%ecx
  8005fa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005fd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800600:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800604:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800607:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80060a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	eb 0f                	jmp    80061d <vprintfmt+0x1d2>
					putch(padc, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	ff 75 e0             	pushl  -0x20(%ebp)
  800615:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800617:	83 ef 01             	sub    $0x1,%edi
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	85 ff                	test   %edi,%edi
  80061f:	7f ed                	jg     80060e <vprintfmt+0x1c3>
  800621:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800624:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800627:	85 c9                	test   %ecx,%ecx
  800629:	b8 00 00 00 00       	mov    $0x0,%eax
  80062e:	0f 49 c1             	cmovns %ecx,%eax
  800631:	29 c1                	sub    %eax,%ecx
  800633:	89 75 08             	mov    %esi,0x8(%ebp)
  800636:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800639:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063c:	89 cb                	mov    %ecx,%ebx
  80063e:	eb 4d                	jmp    80068d <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800640:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800644:	74 1b                	je     800661 <vprintfmt+0x216>
  800646:	0f be c0             	movsbl %al,%eax
  800649:	83 e8 20             	sub    $0x20,%eax
  80064c:	83 f8 5e             	cmp    $0x5e,%eax
  80064f:	76 10                	jbe    800661 <vprintfmt+0x216>
					putch('?', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	ff 75 0c             	pushl  0xc(%ebp)
  800657:	6a 3f                	push   $0x3f
  800659:	ff 55 08             	call   *0x8(%ebp)
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb 0d                	jmp    80066e <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	52                   	push   %edx
  800668:	ff 55 08             	call   *0x8(%ebp)
  80066b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066e:	83 eb 01             	sub    $0x1,%ebx
  800671:	eb 1a                	jmp    80068d <vprintfmt+0x242>
  800673:	89 75 08             	mov    %esi,0x8(%ebp)
  800676:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800679:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067f:	eb 0c                	jmp    80068d <vprintfmt+0x242>
  800681:	89 75 08             	mov    %esi,0x8(%ebp)
  800684:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800687:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068d:	83 c7 01             	add    $0x1,%edi
  800690:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800694:	0f be d0             	movsbl %al,%edx
  800697:	85 d2                	test   %edx,%edx
  800699:	74 23                	je     8006be <vprintfmt+0x273>
  80069b:	85 f6                	test   %esi,%esi
  80069d:	78 a1                	js     800640 <vprintfmt+0x1f5>
  80069f:	83 ee 01             	sub    $0x1,%esi
  8006a2:	79 9c                	jns    800640 <vprintfmt+0x1f5>
  8006a4:	89 df                	mov    %ebx,%edi
  8006a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ac:	eb 18                	jmp    8006c6 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 20                	push   $0x20
  8006b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b6:	83 ef 01             	sub    $0x1,%edi
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 08                	jmp    8006c6 <vprintfmt+0x27b>
  8006be:	89 df                	mov    %ebx,%edi
  8006c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c6:	85 ff                	test   %edi,%edi
  8006c8:	7f e4                	jg     8006ae <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cd:	e9 9f fd ff ff       	jmp    800471 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d2:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8006d6:	7e 16                	jle    8006ee <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 08             	lea    0x8(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 50 04             	mov    0x4(%eax),%edx
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ec:	eb 34                	jmp    800722 <vprintfmt+0x2d7>
	else if (lflag)
  8006ee:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006f2:	74 18                	je     80070c <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800702:	89 c1                	mov    %eax,%ecx
  800704:	c1 f9 1f             	sar    $0x1f,%ecx
  800707:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070a:	eb 16                	jmp    800722 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 50 04             	lea    0x4(%eax),%edx
  800712:	89 55 14             	mov    %edx,0x14(%ebp)
  800715:	8b 00                	mov    (%eax),%eax
  800717:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071a:	89 c1                	mov    %eax,%ecx
  80071c:	c1 f9 1f             	sar    $0x1f,%ecx
  80071f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800722:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800725:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800728:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80072d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800731:	0f 89 88 00 00 00    	jns    8007bf <vprintfmt+0x374>
				putch('-', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 2d                	push   $0x2d
  80073d:	ff d6                	call   *%esi
				num = -(long long) num;
  80073f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800742:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800745:	f7 d8                	neg    %eax
  800747:	83 d2 00             	adc    $0x0,%edx
  80074a:	f7 da                	neg    %edx
  80074c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800754:	eb 69                	jmp    8007bf <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800756:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
  80075c:	e8 76 fc ff ff       	call   8003d7 <getuint>
			base = 10;
  800761:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800766:	eb 57                	jmp    8007bf <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	53                   	push   %ebx
  80076c:	6a 30                	push   $0x30
  80076e:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800770:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
  800776:	e8 5c fc ff ff       	call   8003d7 <getuint>
			base = 8;
			goto number;
  80077b:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80077e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800783:	eb 3a                	jmp    8007bf <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 30                	push   $0x30
  80078b:	ff d6                	call   *%esi
			putch('x', putdat);
  80078d:	83 c4 08             	add    $0x8,%esp
  800790:	53                   	push   %ebx
  800791:	6a 78                	push   $0x78
  800793:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 04             	lea    0x4(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ad:	eb 10                	jmp    8007bf <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007af:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b5:	e8 1d fc ff ff       	call   8003d7 <getuint>
			base = 16;
  8007ba:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c6:	57                   	push   %edi
  8007c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ca:	51                   	push   %ecx
  8007cb:	52                   	push   %edx
  8007cc:	50                   	push   %eax
  8007cd:	89 da                	mov    %ebx,%edx
  8007cf:	89 f0                	mov    %esi,%eax
  8007d1:	e8 52 fb ff ff       	call   800328 <printnum>
			break;
  8007d6:	83 c4 20             	add    $0x20,%esp
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007dc:	e9 90 fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e1:	83 ec 08             	sub    $0x8,%esp
  8007e4:	53                   	push   %ebx
  8007e5:	52                   	push   %edx
  8007e6:	ff d6                	call   *%esi
			break;
  8007e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ee:	e9 7e fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	6a 25                	push   $0x25
  8007f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb 03                	jmp    800803 <vprintfmt+0x3b8>
  800800:	83 ef 01             	sub    $0x1,%edi
  800803:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800807:	75 f7                	jne    800800 <vprintfmt+0x3b5>
  800809:	e9 63 fc ff ff       	jmp    800471 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80080e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 18             	sub    $0x18,%esp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800822:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800825:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800829:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800833:	85 c0                	test   %eax,%eax
  800835:	74 26                	je     80085d <vsnprintf+0x47>
  800837:	85 d2                	test   %edx,%edx
  800839:	7e 22                	jle    80085d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083b:	ff 75 14             	pushl  0x14(%ebp)
  80083e:	ff 75 10             	pushl  0x10(%ebp)
  800841:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800844:	50                   	push   %eax
  800845:	68 11 04 80 00       	push   $0x800411
  80084a:	e8 fc fb ff ff       	call   80044b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800852:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800855:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	eb 05                	jmp    800862 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086d:	50                   	push   %eax
  80086e:	ff 75 10             	pushl  0x10(%ebp)
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 9a ff ff ff       	call   800816 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	eb 03                	jmp    80088e <strlen+0x10>
		n++;
  80088b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800892:	75 f7                	jne    80088b <strlen+0xd>
		n++;
	return n;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089f:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a4:	eb 03                	jmp    8008a9 <strnlen+0x13>
		n++;
  8008a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a9:	39 c2                	cmp    %eax,%edx
  8008ab:	74 08                	je     8008b5 <strnlen+0x1f>
  8008ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008b1:	75 f3                	jne    8008a6 <strnlen+0x10>
  8008b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	75 ef                	jne    8008c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008de:	53                   	push   %ebx
  8008df:	e8 9a ff ff ff       	call   80087e <strlen>
  8008e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	01 d8                	add    %ebx,%eax
  8008ec:	50                   	push   %eax
  8008ed:	e8 c5 ff ff ff       	call   8008b7 <strcpy>
	return dst;
}
  8008f2:	89 d8                	mov    %ebx,%eax
  8008f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800904:	89 f3                	mov    %esi,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	89 f2                	mov    %esi,%edx
  80090b:	eb 0f                	jmp    80091c <strncpy+0x23>
		*dst++ = *src;
  80090d:	83 c2 01             	add    $0x1,%edx
  800910:	0f b6 01             	movzbl (%ecx),%eax
  800913:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800916:	80 39 01             	cmpb   $0x1,(%ecx)
  800919:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091c:	39 da                	cmp    %ebx,%edx
  80091e:	75 ed                	jne    80090d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800920:	89 f0                	mov    %esi,%eax
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 75 08             	mov    0x8(%ebp),%esi
  80092e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800931:	8b 55 10             	mov    0x10(%ebp),%edx
  800934:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800936:	85 d2                	test   %edx,%edx
  800938:	74 21                	je     80095b <strlcpy+0x35>
  80093a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093e:	89 f2                	mov    %esi,%edx
  800940:	eb 09                	jmp    80094b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800942:	83 c2 01             	add    $0x1,%edx
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094b:	39 c2                	cmp    %eax,%edx
  80094d:	74 09                	je     800958 <strlcpy+0x32>
  80094f:	0f b6 19             	movzbl (%ecx),%ebx
  800952:	84 db                	test   %bl,%bl
  800954:	75 ec                	jne    800942 <strlcpy+0x1c>
  800956:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800958:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095b:	29 f0                	sub    %esi,%eax
}
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096a:	eb 06                	jmp    800972 <strcmp+0x11>
		p++, q++;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	84 c0                	test   %al,%al
  800977:	74 04                	je     80097d <strcmp+0x1c>
  800979:	3a 02                	cmp    (%edx),%al
  80097b:	74 ef                	je     80096c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097d:	0f b6 c0             	movzbl %al,%eax
  800980:	0f b6 12             	movzbl (%edx),%edx
  800983:	29 d0                	sub    %edx,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	89 c3                	mov    %eax,%ebx
  800993:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800996:	eb 06                	jmp    80099e <strncmp+0x17>
		n--, p++, q++;
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099e:	39 d8                	cmp    %ebx,%eax
  8009a0:	74 15                	je     8009b7 <strncmp+0x30>
  8009a2:	0f b6 08             	movzbl (%eax),%ecx
  8009a5:	84 c9                	test   %cl,%cl
  8009a7:	74 04                	je     8009ad <strncmp+0x26>
  8009a9:	3a 0a                	cmp    (%edx),%cl
  8009ab:	74 eb                	je     800998 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 00             	movzbl (%eax),%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
  8009b5:	eb 05                	jmp    8009bc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c9:	eb 07                	jmp    8009d2 <strchr+0x13>
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 0f                	je     8009de <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	0f b6 10             	movzbl (%eax),%edx
  8009d5:	84 d2                	test   %dl,%dl
  8009d7:	75 f2                	jne    8009cb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ea:	eb 03                	jmp    8009ef <strfind+0xf>
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	74 04                	je     8009fa <strfind+0x1a>
  8009f6:	84 d2                	test   %dl,%dl
  8009f8:	75 f2                	jne    8009ec <strfind+0xc>
			break;
	return (char *) s;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 36                	je     800a42 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a12:	75 28                	jne    800a3c <memset+0x40>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 23                	jne    800a3c <memset+0x40>
		c &= 0xFF;
  800a19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1d:	89 d3                	mov    %edx,%ebx
  800a1f:	c1 e3 08             	shl    $0x8,%ebx
  800a22:	89 d6                	mov    %edx,%esi
  800a24:	c1 e6 18             	shl    $0x18,%esi
  800a27:	89 d0                	mov    %edx,%eax
  800a29:	c1 e0 10             	shl    $0x10,%eax
  800a2c:	09 f0                	or     %esi,%eax
  800a2e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a30:	89 d8                	mov    %ebx,%eax
  800a32:	09 d0                	or     %edx,%eax
  800a34:	c1 e9 02             	shr    $0x2,%ecx
  800a37:	fc                   	cld    
  800a38:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3a:	eb 06                	jmp    800a42 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	fc                   	cld    
  800a40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a42:	89 f8                	mov    %edi,%eax
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a57:	39 c6                	cmp    %eax,%esi
  800a59:	73 35                	jae    800a90 <memmove+0x47>
  800a5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	73 2e                	jae    800a90 <memmove+0x47>
		s += n;
		d += n;
  800a62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a65:	89 d6                	mov    %edx,%esi
  800a67:	09 fe                	or     %edi,%esi
  800a69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6f:	75 13                	jne    800a84 <memmove+0x3b>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 0e                	jne    800a84 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a76:	83 ef 04             	sub    $0x4,%edi
  800a79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
  800a7f:	fd                   	std    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 09                	jmp    800a8d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a84:	83 ef 01             	sub    $0x1,%edi
  800a87:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a8a:	fd                   	std    
  800a8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8d:	fc                   	cld    
  800a8e:	eb 1d                	jmp    800aad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a90:	89 f2                	mov    %esi,%edx
  800a92:	09 c2                	or     %eax,%edx
  800a94:	f6 c2 03             	test   $0x3,%dl
  800a97:	75 0f                	jne    800aa8 <memmove+0x5f>
  800a99:	f6 c1 03             	test   $0x3,%cl
  800a9c:	75 0a                	jne    800aa8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
  800aa1:	89 c7                	mov    %eax,%edi
  800aa3:	fc                   	cld    
  800aa4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa6:	eb 05                	jmp    800aad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa8:	89 c7                	mov    %eax,%edi
  800aaa:	fc                   	cld    
  800aab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab4:	ff 75 10             	pushl  0x10(%ebp)
  800ab7:	ff 75 0c             	pushl  0xc(%ebp)
  800aba:	ff 75 08             	pushl  0x8(%ebp)
  800abd:	e8 87 ff ff ff       	call   800a49 <memmove>
}
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad4:	eb 1a                	jmp    800af0 <memcmp+0x2c>
		if (*s1 != *s2)
  800ad6:	0f b6 08             	movzbl (%eax),%ecx
  800ad9:	0f b6 1a             	movzbl (%edx),%ebx
  800adc:	38 d9                	cmp    %bl,%cl
  800ade:	74 0a                	je     800aea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae0:	0f b6 c1             	movzbl %cl,%eax
  800ae3:	0f b6 db             	movzbl %bl,%ebx
  800ae6:	29 d8                	sub    %ebx,%eax
  800ae8:	eb 0f                	jmp    800af9 <memcmp+0x35>
		s1++, s2++;
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af0:	39 f0                	cmp    %esi,%eax
  800af2:	75 e2                	jne    800ad6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	53                   	push   %ebx
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b04:	89 c1                	mov    %eax,%ecx
  800b06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0d:	eb 0a                	jmp    800b19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0f:	0f b6 10             	movzbl (%eax),%edx
  800b12:	39 da                	cmp    %ebx,%edx
  800b14:	74 07                	je     800b1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b16:	83 c0 01             	add    $0x1,%eax
  800b19:	39 c8                	cmp    %ecx,%eax
  800b1b:	72 f2                	jb     800b0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2c:	eb 03                	jmp    800b31 <strtol+0x11>
		s++;
  800b2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b31:	0f b6 01             	movzbl (%ecx),%eax
  800b34:	3c 20                	cmp    $0x20,%al
  800b36:	74 f6                	je     800b2e <strtol+0xe>
  800b38:	3c 09                	cmp    $0x9,%al
  800b3a:	74 f2                	je     800b2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3c:	3c 2b                	cmp    $0x2b,%al
  800b3e:	75 0a                	jne    800b4a <strtol+0x2a>
		s++;
  800b40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	eb 11                	jmp    800b5b <strtol+0x3b>
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4f:	3c 2d                	cmp    $0x2d,%al
  800b51:	75 08                	jne    800b5b <strtol+0x3b>
		s++, neg = 1;
  800b53:	83 c1 01             	add    $0x1,%ecx
  800b56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b61:	75 15                	jne    800b78 <strtol+0x58>
  800b63:	80 39 30             	cmpb   $0x30,(%ecx)
  800b66:	75 10                	jne    800b78 <strtol+0x58>
  800b68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6c:	75 7c                	jne    800bea <strtol+0xca>
		s += 2, base = 16;
  800b6e:	83 c1 02             	add    $0x2,%ecx
  800b71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b76:	eb 16                	jmp    800b8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b78:	85 db                	test   %ebx,%ebx
  800b7a:	75 12                	jne    800b8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b81:	80 39 30             	cmpb   $0x30,(%ecx)
  800b84:	75 08                	jne    800b8e <strtol+0x6e>
		s++, base = 8;
  800b86:	83 c1 01             	add    $0x1,%ecx
  800b89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b96:	0f b6 11             	movzbl (%ecx),%edx
  800b99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9c:	89 f3                	mov    %esi,%ebx
  800b9e:	80 fb 09             	cmp    $0x9,%bl
  800ba1:	77 08                	ja     800bab <strtol+0x8b>
			dig = *s - '0';
  800ba3:	0f be d2             	movsbl %dl,%edx
  800ba6:	83 ea 30             	sub    $0x30,%edx
  800ba9:	eb 22                	jmp    800bcd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bae:	89 f3                	mov    %esi,%ebx
  800bb0:	80 fb 19             	cmp    $0x19,%bl
  800bb3:	77 08                	ja     800bbd <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb5:	0f be d2             	movsbl %dl,%edx
  800bb8:	83 ea 57             	sub    $0x57,%edx
  800bbb:	eb 10                	jmp    800bcd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bbd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc0:	89 f3                	mov    %esi,%ebx
  800bc2:	80 fb 19             	cmp    $0x19,%bl
  800bc5:	77 16                	ja     800bdd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc7:	0f be d2             	movsbl %dl,%edx
  800bca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bcd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd0:	7d 0b                	jge    800bdd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd2:	83 c1 01             	add    $0x1,%ecx
  800bd5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bdb:	eb b9                	jmp    800b96 <strtol+0x76>

	if (endptr)
  800bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be1:	74 0d                	je     800bf0 <strtol+0xd0>
		*endptr = (char *) s;
  800be3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be6:	89 0e                	mov    %ecx,(%esi)
  800be8:	eb 06                	jmp    800bf0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bea:	85 db                	test   %ebx,%ebx
  800bec:	74 98                	je     800b86 <strtol+0x66>
  800bee:	eb 9e                	jmp    800b8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf0:	89 c2                	mov    %eax,%edx
  800bf2:	f7 da                	neg    %edx
  800bf4:	85 ff                	test   %edi,%edi
  800bf6:	0f 45 c2             	cmovne %edx,%eax
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 c3                	mov    %eax,%ebx
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	89 c6                	mov    %eax,%esi
  800c15:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c49:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 cb                	mov    %ecx,%ebx
  800c53:	89 cf                	mov    %ecx,%edi
  800c55:	89 ce                	mov    %ecx,%esi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 03                	push   $0x3
  800c63:	68 1f 23 80 00       	push   $0x80231f
  800c68:	6a 23                	push   $0x23
  800c6a:	68 3c 23 80 00       	push   $0x80233c
  800c6f:	e8 c7 f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8c:	89 d1                	mov    %edx,%ecx
  800c8e:	89 d3                	mov    %edx,%ebx
  800c90:	89 d7                	mov    %edx,%edi
  800c92:	89 d6                	mov    %edx,%esi
  800c94:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_yield>:

void
sys_yield(void)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	89 d3                	mov    %edx,%ebx
  800caf:	89 d7                	mov    %edx,%edi
  800cb1:	89 d6                	mov    %edx,%esi
  800cb3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	89 f7                	mov    %esi,%edi
  800cd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 17                	jle    800cf5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 04                	push   $0x4
  800ce4:	68 1f 23 80 00       	push   $0x80231f
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 3c 23 80 00       	push   $0x80233c
  800cf0:	e8 46 f5 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d17:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 05                	push   $0x5
  800d26:	68 1f 23 80 00       	push   $0x80231f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 3c 23 80 00       	push   $0x80233c
  800d32:	e8 04 f5 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 06                	push   $0x6
  800d68:	68 1f 23 80 00       	push   $0x80231f
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 3c 23 80 00       	push   $0x80233c
  800d74:	e8 c2 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 17                	jle    800dbb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 08                	push   $0x8
  800daa:	68 1f 23 80 00       	push   $0x80231f
  800daf:	6a 23                	push   $0x23
  800db1:	68 3c 23 80 00       	push   $0x80233c
  800db6:	e8 80 f4 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 09                	push   $0x9
  800dec:	68 1f 23 80 00       	push   $0x80231f
  800df1:	6a 23                	push   $0x23
  800df3:	68 3c 23 80 00       	push   $0x80233c
  800df8:	e8 3e f4 ff ff       	call   80023b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 0a                	push   $0xa
  800e2e:	68 1f 23 80 00       	push   $0x80231f
  800e33:	6a 23                	push   $0x23
  800e35:	68 3c 23 80 00       	push   $0x80233c
  800e3a:	e8 fc f3 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	be 00 00 00 00       	mov    $0x0,%esi
  800e52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e63:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e78:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 cb                	mov    %ecx,%ebx
  800e82:	89 cf                	mov    %ecx,%edi
  800e84:	89 ce                	mov    %ecx,%esi
  800e86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 17                	jle    800ea3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	50                   	push   %eax
  800e90:	6a 0d                	push   $0xd
  800e92:	68 1f 23 80 00       	push   $0x80231f
  800e97:	6a 23                	push   $0x23
  800e99:	68 3c 23 80 00       	push   $0x80233c
  800e9e:	e8 98 f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb6:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ecb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	c1 ea 16             	shr    $0x16,%edx
  800ee2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee9:	f6 c2 01             	test   $0x1,%dl
  800eec:	74 11                	je     800eff <fd_alloc+0x2d>
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	c1 ea 0c             	shr    $0xc,%edx
  800ef3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efa:	f6 c2 01             	test   $0x1,%dl
  800efd:	75 09                	jne    800f08 <fd_alloc+0x36>
			*fd_store = fd;
  800eff:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	eb 17                	jmp    800f1f <fd_alloc+0x4d>
  800f08:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f0d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f12:	75 c9                	jne    800edd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f14:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f1a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f27:	83 f8 1f             	cmp    $0x1f,%eax
  800f2a:	77 36                	ja     800f62 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f2c:	c1 e0 0c             	shl    $0xc,%eax
  800f2f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f34:	89 c2                	mov    %eax,%edx
  800f36:	c1 ea 16             	shr    $0x16,%edx
  800f39:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f40:	f6 c2 01             	test   $0x1,%dl
  800f43:	74 24                	je     800f69 <fd_lookup+0x48>
  800f45:	89 c2                	mov    %eax,%edx
  800f47:	c1 ea 0c             	shr    $0xc,%edx
  800f4a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f51:	f6 c2 01             	test   $0x1,%dl
  800f54:	74 1a                	je     800f70 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f59:	89 02                	mov    %eax,(%edx)
	return 0;
  800f5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f60:	eb 13                	jmp    800f75 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f67:	eb 0c                	jmp    800f75 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6e:	eb 05                	jmp    800f75 <fd_lookup+0x54>
  800f70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f80:	ba cc 23 80 00       	mov    $0x8023cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f85:	eb 13                	jmp    800f9a <dev_lookup+0x23>
  800f87:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f8a:	39 08                	cmp    %ecx,(%eax)
  800f8c:	75 0c                	jne    800f9a <dev_lookup+0x23>
			*dev = devtab[i];
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
  800f98:	eb 2e                	jmp    800fc8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f9a:	8b 02                	mov    (%edx),%eax
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	75 e7                	jne    800f87 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fa0:	a1 04 40 80 00       	mov    0x804004,%eax
  800fa5:	8b 40 48             	mov    0x48(%eax),%eax
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	51                   	push   %ecx
  800fac:	50                   	push   %eax
  800fad:	68 4c 23 80 00       	push   $0x80234c
  800fb2:	e8 5d f3 ff ff       	call   800314 <cprintf>
	*dev = 0;
  800fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 10             	sub    $0x10,%esp
  800fd2:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe2:	c1 e8 0c             	shr    $0xc,%eax
  800fe5:	50                   	push   %eax
  800fe6:	e8 36 ff ff ff       	call   800f21 <fd_lookup>
  800feb:	83 c4 08             	add    $0x8,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 05                	js     800ff7 <fd_close+0x2d>
	    || fd != fd2)
  800ff2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff5:	74 0c                	je     801003 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ff7:	84 db                	test   %bl,%bl
  800ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffe:	0f 44 c2             	cmove  %edx,%eax
  801001:	eb 41                	jmp    801044 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801009:	50                   	push   %eax
  80100a:	ff 36                	pushl  (%esi)
  80100c:	e8 66 ff ff ff       	call   800f77 <dev_lookup>
  801011:	89 c3                	mov    %eax,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	78 1a                	js     801034 <fd_close+0x6a>
		if (dev->dev_close)
  80101a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801020:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801025:	85 c0                	test   %eax,%eax
  801027:	74 0b                	je     801034 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	56                   	push   %esi
  80102d:	ff d0                	call   *%eax
  80102f:	89 c3                	mov    %eax,%ebx
  801031:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801034:	83 ec 08             	sub    $0x8,%esp
  801037:	56                   	push   %esi
  801038:	6a 00                	push   $0x0
  80103a:	e8 00 fd ff ff       	call   800d3f <sys_page_unmap>
	return r;
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	89 d8                	mov    %ebx,%eax
}
  801044:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	ff 75 08             	pushl  0x8(%ebp)
  801058:	e8 c4 fe ff ff       	call   800f21 <fd_lookup>
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	78 10                	js     801074 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	6a 01                	push   $0x1
  801069:	ff 75 f4             	pushl  -0xc(%ebp)
  80106c:	e8 59 ff ff ff       	call   800fca <fd_close>
  801071:	83 c4 10             	add    $0x10,%esp
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <close_all>:

void
close_all(void)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	53                   	push   %ebx
  801086:	e8 c0 ff ff ff       	call   80104b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108b:	83 c3 01             	add    $0x1,%ebx
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	83 fb 20             	cmp    $0x20,%ebx
  801094:	75 ec                	jne    801082 <close_all+0xc>
		close(i);
}
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 2c             	sub    $0x2c,%esp
  8010a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	ff 75 08             	pushl  0x8(%ebp)
  8010ae:	e8 6e fe ff ff       	call   800f21 <fd_lookup>
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	0f 88 c1 00 00 00    	js     80117f <dup+0xe4>
		return r;
	close(newfdnum);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	56                   	push   %esi
  8010c2:	e8 84 ff ff ff       	call   80104b <close>

	newfd = INDEX2FD(newfdnum);
  8010c7:	89 f3                	mov    %esi,%ebx
  8010c9:	c1 e3 0c             	shl    $0xc,%ebx
  8010cc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010d2:	83 c4 04             	add    $0x4,%esp
  8010d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d8:	e8 de fd ff ff       	call   800ebb <fd2data>
  8010dd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010df:	89 1c 24             	mov    %ebx,(%esp)
  8010e2:	e8 d4 fd ff ff       	call   800ebb <fd2data>
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ed:	89 f8                	mov    %edi,%eax
  8010ef:	c1 e8 16             	shr    $0x16,%eax
  8010f2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f9:	a8 01                	test   $0x1,%al
  8010fb:	74 37                	je     801134 <dup+0x99>
  8010fd:	89 f8                	mov    %edi,%eax
  8010ff:	c1 e8 0c             	shr    $0xc,%eax
  801102:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801109:	f6 c2 01             	test   $0x1,%dl
  80110c:	74 26                	je     801134 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80110e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	25 07 0e 00 00       	and    $0xe07,%eax
  80111d:	50                   	push   %eax
  80111e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801121:	6a 00                	push   $0x0
  801123:	57                   	push   %edi
  801124:	6a 00                	push   $0x0
  801126:	e8 d2 fb ff ff       	call   800cfd <sys_page_map>
  80112b:	89 c7                	mov    %eax,%edi
  80112d:	83 c4 20             	add    $0x20,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 2e                	js     801162 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801134:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801137:	89 d0                	mov    %edx,%eax
  801139:	c1 e8 0c             	shr    $0xc,%eax
  80113c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801143:	83 ec 0c             	sub    $0xc,%esp
  801146:	25 07 0e 00 00       	and    $0xe07,%eax
  80114b:	50                   	push   %eax
  80114c:	53                   	push   %ebx
  80114d:	6a 00                	push   $0x0
  80114f:	52                   	push   %edx
  801150:	6a 00                	push   $0x0
  801152:	e8 a6 fb ff ff       	call   800cfd <sys_page_map>
  801157:	89 c7                	mov    %eax,%edi
  801159:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80115c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80115e:	85 ff                	test   %edi,%edi
  801160:	79 1d                	jns    80117f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801162:	83 ec 08             	sub    $0x8,%esp
  801165:	53                   	push   %ebx
  801166:	6a 00                	push   $0x0
  801168:	e8 d2 fb ff ff       	call   800d3f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116d:	83 c4 08             	add    $0x8,%esp
  801170:	ff 75 d4             	pushl  -0x2c(%ebp)
  801173:	6a 00                	push   $0x0
  801175:	e8 c5 fb ff ff       	call   800d3f <sys_page_unmap>
	return r;
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	89 f8                	mov    %edi,%eax
}
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	53                   	push   %ebx
  80118b:	83 ec 14             	sub    $0x14,%esp
  80118e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801191:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	53                   	push   %ebx
  801196:	e8 86 fd ff ff       	call   800f21 <fd_lookup>
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 6d                	js     801211 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a4:	83 ec 08             	sub    $0x8,%esp
  8011a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ae:	ff 30                	pushl  (%eax)
  8011b0:	e8 c2 fd ff ff       	call   800f77 <dev_lookup>
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 4c                	js     801208 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011bf:	8b 42 08             	mov    0x8(%edx),%eax
  8011c2:	83 e0 03             	and    $0x3,%eax
  8011c5:	83 f8 01             	cmp    $0x1,%eax
  8011c8:	75 21                	jne    8011eb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cf:	8b 40 48             	mov    0x48(%eax),%eax
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	53                   	push   %ebx
  8011d6:	50                   	push   %eax
  8011d7:	68 90 23 80 00       	push   $0x802390
  8011dc:	e8 33 f1 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e9:	eb 26                	jmp    801211 <read+0x8a>
	}
	if (!dev->dev_read)
  8011eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ee:	8b 40 08             	mov    0x8(%eax),%eax
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	74 17                	je     80120c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	ff 75 10             	pushl  0x10(%ebp)
  8011fb:	ff 75 0c             	pushl  0xc(%ebp)
  8011fe:	52                   	push   %edx
  8011ff:	ff d0                	call   *%eax
  801201:	89 c2                	mov    %eax,%edx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	eb 09                	jmp    801211 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801208:	89 c2                	mov    %eax,%edx
  80120a:	eb 05                	jmp    801211 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80120c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801211:	89 d0                	mov    %edx,%eax
  801213:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	57                   	push   %edi
  80121c:	56                   	push   %esi
  80121d:	53                   	push   %ebx
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	8b 7d 08             	mov    0x8(%ebp),%edi
  801224:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122c:	eb 21                	jmp    80124f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	89 f0                	mov    %esi,%eax
  801233:	29 d8                	sub    %ebx,%eax
  801235:	50                   	push   %eax
  801236:	89 d8                	mov    %ebx,%eax
  801238:	03 45 0c             	add    0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	57                   	push   %edi
  80123d:	e8 45 ff ff ff       	call   801187 <read>
		if (m < 0)
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 10                	js     801259 <readn+0x41>
			return m;
		if (m == 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	74 0a                	je     801257 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124d:	01 c3                	add    %eax,%ebx
  80124f:	39 f3                	cmp    %esi,%ebx
  801251:	72 db                	jb     80122e <readn+0x16>
  801253:	89 d8                	mov    %ebx,%eax
  801255:	eb 02                	jmp    801259 <readn+0x41>
  801257:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801259:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125c:	5b                   	pop    %ebx
  80125d:	5e                   	pop    %esi
  80125e:	5f                   	pop    %edi
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	53                   	push   %ebx
  801265:	83 ec 14             	sub    $0x14,%esp
  801268:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	53                   	push   %ebx
  801270:	e8 ac fc ff ff       	call   800f21 <fd_lookup>
  801275:	83 c4 08             	add    $0x8,%esp
  801278:	89 c2                	mov    %eax,%edx
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 68                	js     8012e6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127e:	83 ec 08             	sub    $0x8,%esp
  801281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	ff 30                	pushl  (%eax)
  80128a:	e8 e8 fc ff ff       	call   800f77 <dev_lookup>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 47                	js     8012dd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801296:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801299:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129d:	75 21                	jne    8012c0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80129f:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a4:	8b 40 48             	mov    0x48(%eax),%eax
  8012a7:	83 ec 04             	sub    $0x4,%esp
  8012aa:	53                   	push   %ebx
  8012ab:	50                   	push   %eax
  8012ac:	68 ac 23 80 00       	push   $0x8023ac
  8012b1:	e8 5e f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012be:	eb 26                	jmp    8012e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c3:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c6:	85 d2                	test   %edx,%edx
  8012c8:	74 17                	je     8012e1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	ff 75 10             	pushl  0x10(%ebp)
  8012d0:	ff 75 0c             	pushl  0xc(%ebp)
  8012d3:	50                   	push   %eax
  8012d4:	ff d2                	call   *%edx
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	eb 09                	jmp    8012e6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	eb 05                	jmp    8012e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012e6:	89 d0                	mov    %edx,%eax
  8012e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    

008012ed <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 08             	pushl  0x8(%ebp)
  8012fa:	e8 22 fc ff ff       	call   800f21 <fd_lookup>
  8012ff:	83 c4 08             	add    $0x8,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 0e                	js     801314 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801306:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801309:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 14             	sub    $0x14,%esp
  80131d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801320:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	53                   	push   %ebx
  801325:	e8 f7 fb ff ff       	call   800f21 <fd_lookup>
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 65                	js     801398 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	ff 30                	pushl  (%eax)
  80133f:	e8 33 fc ff ff       	call   800f77 <dev_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 44                	js     80138f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801352:	75 21                	jne    801375 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801354:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801359:	8b 40 48             	mov    0x48(%eax),%eax
  80135c:	83 ec 04             	sub    $0x4,%esp
  80135f:	53                   	push   %ebx
  801360:	50                   	push   %eax
  801361:	68 6c 23 80 00       	push   $0x80236c
  801366:	e8 a9 ef ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801373:	eb 23                	jmp    801398 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801375:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801378:	8b 52 18             	mov    0x18(%edx),%edx
  80137b:	85 d2                	test   %edx,%edx
  80137d:	74 14                	je     801393 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	ff 75 0c             	pushl  0xc(%ebp)
  801385:	50                   	push   %eax
  801386:	ff d2                	call   *%edx
  801388:	89 c2                	mov    %eax,%edx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	eb 09                	jmp    801398 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	89 c2                	mov    %eax,%edx
  801391:	eb 05                	jmp    801398 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801393:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801398:	89 d0                	mov    %edx,%eax
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 14             	sub    $0x14,%esp
  8013a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 6c fb ff ff       	call   800f21 <fd_lookup>
  8013b5:	83 c4 08             	add    $0x8,%esp
  8013b8:	89 c2                	mov    %eax,%edx
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 58                	js     801416 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c8:	ff 30                	pushl  (%eax)
  8013ca:	e8 a8 fb ff ff       	call   800f77 <dev_lookup>
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 37                	js     80140d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013dd:	74 32                	je     801411 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013df:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e9:	00 00 00 
	stat->st_isdir = 0;
  8013ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f3:	00 00 00 
	stat->st_dev = dev;
  8013f6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	53                   	push   %ebx
  801400:	ff 75 f0             	pushl  -0x10(%ebp)
  801403:	ff 50 14             	call   *0x14(%eax)
  801406:	89 c2                	mov    %eax,%edx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	eb 09                	jmp    801416 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140d:	89 c2                	mov    %eax,%edx
  80140f:	eb 05                	jmp    801416 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801411:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801416:	89 d0                	mov    %edx,%eax
  801418:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801422:	83 ec 08             	sub    $0x8,%esp
  801425:	6a 00                	push   $0x0
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	e8 e3 01 00 00       	call   801612 <open>
  80142f:	89 c3                	mov    %eax,%ebx
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 1b                	js     801453 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	ff 75 0c             	pushl  0xc(%ebp)
  80143e:	50                   	push   %eax
  80143f:	e8 5b ff ff ff       	call   80139f <fstat>
  801444:	89 c6                	mov    %eax,%esi
	close(fd);
  801446:	89 1c 24             	mov    %ebx,(%esp)
  801449:	e8 fd fb ff ff       	call   80104b <close>
	return r;
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	89 f0                	mov    %esi,%eax
}
  801453:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801456:	5b                   	pop    %ebx
  801457:	5e                   	pop    %esi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	56                   	push   %esi
  80145e:	53                   	push   %ebx
  80145f:	89 c6                	mov    %eax,%esi
  801461:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801463:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80146a:	75 12                	jne    80147e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	6a 01                	push   $0x1
  801471:	e8 c8 07 00 00       	call   801c3e <ipc_find_env>
  801476:	a3 00 40 80 00       	mov    %eax,0x804000
  80147b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147e:	6a 07                	push   $0x7
  801480:	68 00 50 80 00       	push   $0x805000
  801485:	56                   	push   %esi
  801486:	ff 35 00 40 80 00    	pushl  0x804000
  80148c:	e8 59 07 00 00       	call   801bea <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801491:	83 c4 0c             	add    $0xc,%esp
  801494:	6a 00                	push   $0x0
  801496:	53                   	push   %ebx
  801497:	6a 00                	push   $0x0
  801499:	e8 f7 06 00 00       	call   801b95 <ipc_recv>
}
  80149e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a1:	5b                   	pop    %ebx
  8014a2:	5e                   	pop    %esi
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014be:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c8:	e8 8d ff ff ff       	call   80145a <fsipc>
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014db:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ea:	e8 6b ff ff ff       	call   80145a <fsipc>
}
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    

008014f1 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801501:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801506:	ba 00 00 00 00       	mov    $0x0,%edx
  80150b:	b8 05 00 00 00       	mov    $0x5,%eax
  801510:	e8 45 ff ff ff       	call   80145a <fsipc>
  801515:	85 c0                	test   %eax,%eax
  801517:	78 2c                	js     801545 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	68 00 50 80 00       	push   $0x805000
  801521:	53                   	push   %ebx
  801522:	e8 90 f3 ff ff       	call   8008b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801527:	a1 80 50 80 00       	mov    0x805080,%eax
  80152c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801532:	a1 84 50 80 00       	mov    0x805084,%eax
  801537:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801553:	8b 55 08             	mov    0x8(%ebp),%edx
  801556:	8b 52 0c             	mov    0xc(%edx),%edx
  801559:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80155f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801564:	ba 00 10 00 00       	mov    $0x1000,%edx
  801569:	0f 47 c2             	cmova  %edx,%eax
  80156c:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801571:	50                   	push   %eax
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	68 08 50 80 00       	push   $0x805008
  80157a:	e8 ca f4 ff ff       	call   800a49 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80157f:	ba 00 00 00 00       	mov    $0x0,%edx
  801584:	b8 04 00 00 00       	mov    $0x4,%eax
  801589:	e8 cc fe ff ff       	call   80145a <fsipc>
    return r;
}
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801598:	8b 45 08             	mov    0x8(%ebp),%eax
  80159b:	8b 40 0c             	mov    0xc(%eax),%eax
  80159e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8015b3:	e8 a2 fe ff ff       	call   80145a <fsipc>
  8015b8:	89 c3                	mov    %eax,%ebx
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 4b                	js     801609 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015be:	39 c6                	cmp    %eax,%esi
  8015c0:	73 16                	jae    8015d8 <devfile_read+0x48>
  8015c2:	68 dc 23 80 00       	push   $0x8023dc
  8015c7:	68 e3 23 80 00       	push   $0x8023e3
  8015cc:	6a 7c                	push   $0x7c
  8015ce:	68 f8 23 80 00       	push   $0x8023f8
  8015d3:	e8 63 ec ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  8015d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015dd:	7e 16                	jle    8015f5 <devfile_read+0x65>
  8015df:	68 03 24 80 00       	push   $0x802403
  8015e4:	68 e3 23 80 00       	push   $0x8023e3
  8015e9:	6a 7d                	push   $0x7d
  8015eb:	68 f8 23 80 00       	push   $0x8023f8
  8015f0:	e8 46 ec ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015f5:	83 ec 04             	sub    $0x4,%esp
  8015f8:	50                   	push   %eax
  8015f9:	68 00 50 80 00       	push   $0x805000
  8015fe:	ff 75 0c             	pushl  0xc(%ebp)
  801601:	e8 43 f4 ff ff       	call   800a49 <memmove>
	return r;
  801606:	83 c4 10             	add    $0x10,%esp
}
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	53                   	push   %ebx
  801616:	83 ec 20             	sub    $0x20,%esp
  801619:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80161c:	53                   	push   %ebx
  80161d:	e8 5c f2 ff ff       	call   80087e <strlen>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80162a:	7f 67                	jg     801693 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162c:	83 ec 0c             	sub    $0xc,%esp
  80162f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	e8 9a f8 ff ff       	call   800ed2 <fd_alloc>
  801638:	83 c4 10             	add    $0x10,%esp
		return r;
  80163b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 57                	js     801698 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	53                   	push   %ebx
  801645:	68 00 50 80 00       	push   $0x805000
  80164a:	e8 68 f2 ff ff       	call   8008b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80164f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801652:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801657:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165a:	b8 01 00 00 00       	mov    $0x1,%eax
  80165f:	e8 f6 fd ff ff       	call   80145a <fsipc>
  801664:	89 c3                	mov    %eax,%ebx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	79 14                	jns    801681 <open+0x6f>
		fd_close(fd, 0);
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	6a 00                	push   $0x0
  801672:	ff 75 f4             	pushl  -0xc(%ebp)
  801675:	e8 50 f9 ff ff       	call   800fca <fd_close>
		return r;
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	89 da                	mov    %ebx,%edx
  80167f:	eb 17                	jmp    801698 <open+0x86>
	}

	return fd2num(fd);
  801681:	83 ec 0c             	sub    $0xc,%esp
  801684:	ff 75 f4             	pushl  -0xc(%ebp)
  801687:	e8 1f f8 ff ff       	call   800eab <fd2num>
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	eb 05                	jmp    801698 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801693:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801698:	89 d0                	mov    %edx,%eax
  80169a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8016af:	e8 a6 fd ff ff       	call   80145a <fsipc>
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	56                   	push   %esi
  8016ba:	53                   	push   %ebx
  8016bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	ff 75 08             	pushl  0x8(%ebp)
  8016c4:	e8 f2 f7 ff ff       	call   800ebb <fd2data>
  8016c9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016cb:	83 c4 08             	add    $0x8,%esp
  8016ce:	68 0f 24 80 00       	push   $0x80240f
  8016d3:	53                   	push   %ebx
  8016d4:	e8 de f1 ff ff       	call   8008b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016d9:	8b 46 04             	mov    0x4(%esi),%eax
  8016dc:	2b 06                	sub    (%esi),%eax
  8016de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016e4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016eb:	00 00 00 
	stat->st_dev = &devpipe;
  8016ee:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016f5:	30 80 00 
	return 0;
}
  8016f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	53                   	push   %ebx
  801708:	83 ec 0c             	sub    $0xc,%esp
  80170b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80170e:	53                   	push   %ebx
  80170f:	6a 00                	push   $0x0
  801711:	e8 29 f6 ff ff       	call   800d3f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801716:	89 1c 24             	mov    %ebx,(%esp)
  801719:	e8 9d f7 ff ff       	call   800ebb <fd2data>
  80171e:	83 c4 08             	add    $0x8,%esp
  801721:	50                   	push   %eax
  801722:	6a 00                	push   $0x0
  801724:	e8 16 f6 ff ff       	call   800d3f <sys_page_unmap>
}
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	57                   	push   %edi
  801732:	56                   	push   %esi
  801733:	53                   	push   %ebx
  801734:	83 ec 1c             	sub    $0x1c,%esp
  801737:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80173a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80173c:	a1 04 40 80 00       	mov    0x804004,%eax
  801741:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	ff 75 e0             	pushl  -0x20(%ebp)
  80174a:	e8 28 05 00 00       	call   801c77 <pageref>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	89 3c 24             	mov    %edi,(%esp)
  801754:	e8 1e 05 00 00       	call   801c77 <pageref>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	39 c3                	cmp    %eax,%ebx
  80175e:	0f 94 c1             	sete   %cl
  801761:	0f b6 c9             	movzbl %cl,%ecx
  801764:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801767:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80176d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801770:	39 ce                	cmp    %ecx,%esi
  801772:	74 1b                	je     80178f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801774:	39 c3                	cmp    %eax,%ebx
  801776:	75 c4                	jne    80173c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801778:	8b 42 58             	mov    0x58(%edx),%eax
  80177b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177e:	50                   	push   %eax
  80177f:	56                   	push   %esi
  801780:	68 16 24 80 00       	push   $0x802416
  801785:	e8 8a eb ff ff       	call   800314 <cprintf>
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	eb ad                	jmp    80173c <_pipeisclosed+0xe>
	}
}
  80178f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801792:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5f                   	pop    %edi
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	57                   	push   %edi
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
  8017a0:	83 ec 28             	sub    $0x28,%esp
  8017a3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017a6:	56                   	push   %esi
  8017a7:	e8 0f f7 ff ff       	call   800ebb <fd2data>
  8017ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8017b6:	eb 4b                	jmp    801803 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017b8:	89 da                	mov    %ebx,%edx
  8017ba:	89 f0                	mov    %esi,%eax
  8017bc:	e8 6d ff ff ff       	call   80172e <_pipeisclosed>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	75 48                	jne    80180d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017c5:	e8 d1 f4 ff ff       	call   800c9b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017ca:	8b 43 04             	mov    0x4(%ebx),%eax
  8017cd:	8b 0b                	mov    (%ebx),%ecx
  8017cf:	8d 51 20             	lea    0x20(%ecx),%edx
  8017d2:	39 d0                	cmp    %edx,%eax
  8017d4:	73 e2                	jae    8017b8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017dd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	c1 fa 1f             	sar    $0x1f,%edx
  8017e5:	89 d1                	mov    %edx,%ecx
  8017e7:	c1 e9 1b             	shr    $0x1b,%ecx
  8017ea:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017ed:	83 e2 1f             	and    $0x1f,%edx
  8017f0:	29 ca                	sub    %ecx,%edx
  8017f2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017fa:	83 c0 01             	add    $0x1,%eax
  8017fd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801800:	83 c7 01             	add    $0x1,%edi
  801803:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801806:	75 c2                	jne    8017ca <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801808:	8b 45 10             	mov    0x10(%ebp),%eax
  80180b:	eb 05                	jmp    801812 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801812:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801815:	5b                   	pop    %ebx
  801816:	5e                   	pop    %esi
  801817:	5f                   	pop    %edi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	57                   	push   %edi
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	83 ec 18             	sub    $0x18,%esp
  801823:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801826:	57                   	push   %edi
  801827:	e8 8f f6 ff ff       	call   800ebb <fd2data>
  80182c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	bb 00 00 00 00       	mov    $0x0,%ebx
  801836:	eb 3d                	jmp    801875 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801838:	85 db                	test   %ebx,%ebx
  80183a:	74 04                	je     801840 <devpipe_read+0x26>
				return i;
  80183c:	89 d8                	mov    %ebx,%eax
  80183e:	eb 44                	jmp    801884 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801840:	89 f2                	mov    %esi,%edx
  801842:	89 f8                	mov    %edi,%eax
  801844:	e8 e5 fe ff ff       	call   80172e <_pipeisclosed>
  801849:	85 c0                	test   %eax,%eax
  80184b:	75 32                	jne    80187f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80184d:	e8 49 f4 ff ff       	call   800c9b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801852:	8b 06                	mov    (%esi),%eax
  801854:	3b 46 04             	cmp    0x4(%esi),%eax
  801857:	74 df                	je     801838 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801859:	99                   	cltd   
  80185a:	c1 ea 1b             	shr    $0x1b,%edx
  80185d:	01 d0                	add    %edx,%eax
  80185f:	83 e0 1f             	and    $0x1f,%eax
  801862:	29 d0                	sub    %edx,%eax
  801864:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80186f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801872:	83 c3 01             	add    $0x1,%ebx
  801875:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801878:	75 d8                	jne    801852 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80187a:	8b 45 10             	mov    0x10(%ebp),%eax
  80187d:	eb 05                	jmp    801884 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80187f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801884:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801887:	5b                   	pop    %ebx
  801888:	5e                   	pop    %esi
  801889:	5f                   	pop    %edi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
  801891:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801894:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	e8 35 f6 ff ff       	call   800ed2 <fd_alloc>
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	89 c2                	mov    %eax,%edx
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	0f 88 2c 01 00 00    	js     8019d6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018aa:	83 ec 04             	sub    $0x4,%esp
  8018ad:	68 07 04 00 00       	push   $0x407
  8018b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b5:	6a 00                	push   $0x0
  8018b7:	e8 fe f3 ff ff       	call   800cba <sys_page_alloc>
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	89 c2                	mov    %eax,%edx
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	0f 88 0d 01 00 00    	js     8019d6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018c9:	83 ec 0c             	sub    $0xc,%esp
  8018cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cf:	50                   	push   %eax
  8018d0:	e8 fd f5 ff ff       	call   800ed2 <fd_alloc>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	0f 88 e2 00 00 00    	js     8019c4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	68 07 04 00 00       	push   $0x407
  8018ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 c6 f3 ff ff       	call   800cba <sys_page_alloc>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	0f 88 c3 00 00 00    	js     8019c4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	ff 75 f4             	pushl  -0xc(%ebp)
  801907:	e8 af f5 ff ff       	call   800ebb <fd2data>
  80190c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80190e:	83 c4 0c             	add    $0xc,%esp
  801911:	68 07 04 00 00       	push   $0x407
  801916:	50                   	push   %eax
  801917:	6a 00                	push   $0x0
  801919:	e8 9c f3 ff ff       	call   800cba <sys_page_alloc>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	0f 88 89 00 00 00    	js     8019b4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	ff 75 f0             	pushl  -0x10(%ebp)
  801931:	e8 85 f5 ff ff       	call   800ebb <fd2data>
  801936:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80193d:	50                   	push   %eax
  80193e:	6a 00                	push   $0x0
  801940:	56                   	push   %esi
  801941:	6a 00                	push   $0x0
  801943:	e8 b5 f3 ff ff       	call   800cfd <sys_page_map>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	83 c4 20             	add    $0x20,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 55                	js     8019a6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801951:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80195c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801966:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80196c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801971:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801974:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	ff 75 f4             	pushl  -0xc(%ebp)
  801981:	e8 25 f5 ff ff       	call   800eab <fd2num>
  801986:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801989:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80198b:	83 c4 04             	add    $0x4,%esp
  80198e:	ff 75 f0             	pushl  -0x10(%ebp)
  801991:	e8 15 f5 ff ff       	call   800eab <fd2num>
  801996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801999:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a4:	eb 30                	jmp    8019d6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	56                   	push   %esi
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 8e f3 ff ff       	call   800d3f <sys_page_unmap>
  8019b1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 7e f3 ff ff       	call   800d3f <sys_page_unmap>
  8019c1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ca:	6a 00                	push   $0x0
  8019cc:	e8 6e f3 ff ff       	call   800d3f <sys_page_unmap>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019d6:	89 d0                	mov    %edx,%eax
  8019d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e8:	50                   	push   %eax
  8019e9:	ff 75 08             	pushl  0x8(%ebp)
  8019ec:	e8 30 f5 ff ff       	call   800f21 <fd_lookup>
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 18                	js     801a10 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fe:	e8 b8 f4 ff ff       	call   800ebb <fd2data>
	return _pipeisclosed(fd, p);
  801a03:	89 c2                	mov    %eax,%edx
  801a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a08:	e8 21 fd ff ff       	call   80172e <_pipeisclosed>
  801a0d:	83 c4 10             	add    $0x10,%esp
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a15:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a22:	68 2e 24 80 00       	push   $0x80242e
  801a27:	ff 75 0c             	pushl  0xc(%ebp)
  801a2a:	e8 88 ee ff ff       	call   8008b7 <strcpy>
	return 0;
}
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a42:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a4d:	eb 2d                	jmp    801a7c <devcons_write+0x46>
		m = n - tot;
  801a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a52:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a54:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a57:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a5c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a5f:	83 ec 04             	sub    $0x4,%esp
  801a62:	53                   	push   %ebx
  801a63:	03 45 0c             	add    0xc(%ebp),%eax
  801a66:	50                   	push   %eax
  801a67:	57                   	push   %edi
  801a68:	e8 dc ef ff ff       	call   800a49 <memmove>
		sys_cputs(buf, m);
  801a6d:	83 c4 08             	add    $0x8,%esp
  801a70:	53                   	push   %ebx
  801a71:	57                   	push   %edi
  801a72:	e8 87 f1 ff ff       	call   800bfe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a77:	01 de                	add    %ebx,%esi
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	89 f0                	mov    %esi,%eax
  801a7e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a81:	72 cc                	jb     801a4f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5f                   	pop    %edi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a9a:	74 2a                	je     801ac6 <devcons_read+0x3b>
  801a9c:	eb 05                	jmp    801aa3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a9e:	e8 f8 f1 ff ff       	call   800c9b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801aa3:	e8 74 f1 ff ff       	call   800c1c <sys_cgetc>
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	74 f2                	je     801a9e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 16                	js     801ac6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ab0:	83 f8 04             	cmp    $0x4,%eax
  801ab3:	74 0c                	je     801ac1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab8:	88 02                	mov    %al,(%edx)
	return 1;
  801aba:	b8 01 00 00 00       	mov    $0x1,%eax
  801abf:	eb 05                	jmp    801ac6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ac1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ad4:	6a 01                	push   $0x1
  801ad6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad9:	50                   	push   %eax
  801ada:	e8 1f f1 ff ff       	call   800bfe <sys_cputs>
}
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <getchar>:

int
getchar(void)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aea:	6a 01                	push   $0x1
  801aec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	6a 00                	push   $0x0
  801af2:	e8 90 f6 ff ff       	call   801187 <read>
	if (r < 0)
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 0f                	js     801b0d <getchar+0x29>
		return r;
	if (r < 1)
  801afe:	85 c0                	test   %eax,%eax
  801b00:	7e 06                	jle    801b08 <getchar+0x24>
		return -E_EOF;
	return c;
  801b02:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b06:	eb 05                	jmp    801b0d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b08:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b18:	50                   	push   %eax
  801b19:	ff 75 08             	pushl  0x8(%ebp)
  801b1c:	e8 00 f4 ff ff       	call   800f21 <fd_lookup>
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 11                	js     801b39 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b31:	39 10                	cmp    %edx,(%eax)
  801b33:	0f 94 c0             	sete   %al
  801b36:	0f b6 c0             	movzbl %al,%eax
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <opencons>:

int
opencons(void)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b44:	50                   	push   %eax
  801b45:	e8 88 f3 ff ff       	call   800ed2 <fd_alloc>
  801b4a:	83 c4 10             	add    $0x10,%esp
		return r;
  801b4d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 3e                	js     801b91 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b53:	83 ec 04             	sub    $0x4,%esp
  801b56:	68 07 04 00 00       	push   $0x407
  801b5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 55 f1 ff ff       	call   800cba <sys_page_alloc>
  801b65:	83 c4 10             	add    $0x10,%esp
		return r;
  801b68:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	78 23                	js     801b91 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b77:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b83:	83 ec 0c             	sub    $0xc,%esp
  801b86:	50                   	push   %eax
  801b87:	e8 1f f3 ff ff       	call   800eab <fd2num>
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	83 c4 10             	add    $0x10,%esp
}
  801b91:	89 d0                	mov    %edx,%eax
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba0:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801baa:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801bad:	83 ec 0c             	sub    $0xc,%esp
  801bb0:	50                   	push   %eax
  801bb1:	e8 b4 f2 ff ff       	call   800e6a <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	75 10                	jne    801bcd <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801bbd:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc2:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801bc5:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801bc8:	8b 40 70             	mov    0x70(%eax),%eax
  801bcb:	eb 0a                	jmp    801bd7 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801bcd:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	74 02                	je     801bdd <ipc_recv+0x48>
  801bdb:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801bdd:	85 db                	test   %ebx,%ebx
  801bdf:	74 02                	je     801be3 <ipc_recv+0x4e>
  801be1:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801be3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    

00801bea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	57                   	push   %edi
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801bfc:	85 db                	test   %ebx,%ebx
  801bfe:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c03:	0f 44 d8             	cmove  %eax,%ebx
  801c06:	eb 1c                	jmp    801c24 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801c08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c0b:	74 12                	je     801c1f <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801c0d:	50                   	push   %eax
  801c0e:	68 3a 24 80 00       	push   $0x80243a
  801c13:	6a 40                	push   $0x40
  801c15:	68 4c 24 80 00       	push   $0x80244c
  801c1a:	e8 1c e6 ff ff       	call   80023b <_panic>
        sys_yield();
  801c1f:	e8 77 f0 ff ff       	call   800c9b <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801c24:	ff 75 14             	pushl  0x14(%ebp)
  801c27:	53                   	push   %ebx
  801c28:	56                   	push   %esi
  801c29:	57                   	push   %edi
  801c2a:	e8 18 f2 ff ff       	call   800e47 <sys_ipc_try_send>
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	85 c0                	test   %eax,%eax
  801c34:	75 d2                	jne    801c08 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5f                   	pop    %edi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c49:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c4c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c52:	8b 52 50             	mov    0x50(%edx),%edx
  801c55:	39 ca                	cmp    %ecx,%edx
  801c57:	75 0d                	jne    801c66 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c59:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c61:	8b 40 48             	mov    0x48(%eax),%eax
  801c64:	eb 0f                	jmp    801c75 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c66:	83 c0 01             	add    $0x1,%eax
  801c69:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c6e:	75 d9                	jne    801c49 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c7d:	89 d0                	mov    %edx,%eax
  801c7f:	c1 e8 16             	shr    $0x16,%eax
  801c82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c8e:	f6 c1 01             	test   $0x1,%cl
  801c91:	74 1d                	je     801cb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c93:	c1 ea 0c             	shr    $0xc,%edx
  801c96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c9d:	f6 c2 01             	test   $0x1,%dl
  801ca0:	74 0e                	je     801cb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ca2:	c1 ea 0c             	shr    $0xc,%edx
  801ca5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cac:	ef 
  801cad:	0f b7 c0             	movzwl %ax,%eax
}
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__udivdi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ccb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ccf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 f6                	test   %esi,%esi
  801cd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cdd:	89 ca                	mov    %ecx,%edx
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	75 3d                	jne    801d20 <__udivdi3+0x60>
  801ce3:	39 cf                	cmp    %ecx,%edi
  801ce5:	0f 87 c5 00 00 00    	ja     801db0 <__udivdi3+0xf0>
  801ceb:	85 ff                	test   %edi,%edi
  801ced:	89 fd                	mov    %edi,%ebp
  801cef:	75 0b                	jne    801cfc <__udivdi3+0x3c>
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	31 d2                	xor    %edx,%edx
  801cf8:	f7 f7                	div    %edi
  801cfa:	89 c5                	mov    %eax,%ebp
  801cfc:	89 c8                	mov    %ecx,%eax
  801cfe:	31 d2                	xor    %edx,%edx
  801d00:	f7 f5                	div    %ebp
  801d02:	89 c1                	mov    %eax,%ecx
  801d04:	89 d8                	mov    %ebx,%eax
  801d06:	89 cf                	mov    %ecx,%edi
  801d08:	f7 f5                	div    %ebp
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	89 d8                	mov    %ebx,%eax
  801d0e:	89 fa                	mov    %edi,%edx
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
  801d18:	90                   	nop
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	39 ce                	cmp    %ecx,%esi
  801d22:	77 74                	ja     801d98 <__udivdi3+0xd8>
  801d24:	0f bd fe             	bsr    %esi,%edi
  801d27:	83 f7 1f             	xor    $0x1f,%edi
  801d2a:	0f 84 98 00 00 00    	je     801dc8 <__udivdi3+0x108>
  801d30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	89 c5                	mov    %eax,%ebp
  801d39:	29 fb                	sub    %edi,%ebx
  801d3b:	d3 e6                	shl    %cl,%esi
  801d3d:	89 d9                	mov    %ebx,%ecx
  801d3f:	d3 ed                	shr    %cl,%ebp
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	d3 e0                	shl    %cl,%eax
  801d45:	09 ee                	or     %ebp,%esi
  801d47:	89 d9                	mov    %ebx,%ecx
  801d49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4d:	89 d5                	mov    %edx,%ebp
  801d4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d53:	d3 ed                	shr    %cl,%ebp
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e2                	shl    %cl,%edx
  801d59:	89 d9                	mov    %ebx,%ecx
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	09 c2                	or     %eax,%edx
  801d5f:	89 d0                	mov    %edx,%eax
  801d61:	89 ea                	mov    %ebp,%edx
  801d63:	f7 f6                	div    %esi
  801d65:	89 d5                	mov    %edx,%ebp
  801d67:	89 c3                	mov    %eax,%ebx
  801d69:	f7 64 24 0c          	mull   0xc(%esp)
  801d6d:	39 d5                	cmp    %edx,%ebp
  801d6f:	72 10                	jb     801d81 <__udivdi3+0xc1>
  801d71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d75:	89 f9                	mov    %edi,%ecx
  801d77:	d3 e6                	shl    %cl,%esi
  801d79:	39 c6                	cmp    %eax,%esi
  801d7b:	73 07                	jae    801d84 <__udivdi3+0xc4>
  801d7d:	39 d5                	cmp    %edx,%ebp
  801d7f:	75 03                	jne    801d84 <__udivdi3+0xc4>
  801d81:	83 eb 01             	sub    $0x1,%ebx
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 d8                	mov    %ebx,%eax
  801d88:	89 fa                	mov    %edi,%edx
  801d8a:	83 c4 1c             	add    $0x1c,%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
  801d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d98:	31 ff                	xor    %edi,%edi
  801d9a:	31 db                	xor    %ebx,%ebx
  801d9c:	89 d8                	mov    %ebx,%eax
  801d9e:	89 fa                	mov    %edi,%edx
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	89 d8                	mov    %ebx,%eax
  801db2:	f7 f7                	div    %edi
  801db4:	31 ff                	xor    %edi,%edi
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 fa                	mov    %edi,%edx
  801dbc:	83 c4 1c             	add    $0x1c,%esp
  801dbf:	5b                   	pop    %ebx
  801dc0:	5e                   	pop    %esi
  801dc1:	5f                   	pop    %edi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	39 ce                	cmp    %ecx,%esi
  801dca:	72 0c                	jb     801dd8 <__udivdi3+0x118>
  801dcc:	31 db                	xor    %ebx,%ebx
  801dce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801dd2:	0f 87 34 ff ff ff    	ja     801d0c <__udivdi3+0x4c>
  801dd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ddd:	e9 2a ff ff ff       	jmp    801d0c <__udivdi3+0x4c>
  801de2:	66 90                	xchg   %ax,%ax
  801de4:	66 90                	xchg   %ax,%ax
  801de6:	66 90                	xchg   %ax,%ax
  801de8:	66 90                	xchg   %ax,%ax
  801dea:	66 90                	xchg   %ax,%ax
  801dec:	66 90                	xchg   %ax,%ax
  801dee:	66 90                	xchg   %ax,%ax

00801df0 <__umoddi3>:
  801df0:	55                   	push   %ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	83 ec 1c             	sub    $0x1c,%esp
  801df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e07:	85 d2                	test   %edx,%edx
  801e09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e11:	89 f3                	mov    %esi,%ebx
  801e13:	89 3c 24             	mov    %edi,(%esp)
  801e16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e1a:	75 1c                	jne    801e38 <__umoddi3+0x48>
  801e1c:	39 f7                	cmp    %esi,%edi
  801e1e:	76 50                	jbe    801e70 <__umoddi3+0x80>
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	f7 f7                	div    %edi
  801e26:	89 d0                	mov    %edx,%eax
  801e28:	31 d2                	xor    %edx,%edx
  801e2a:	83 c4 1c             	add    $0x1c,%esp
  801e2d:	5b                   	pop    %ebx
  801e2e:	5e                   	pop    %esi
  801e2f:	5f                   	pop    %edi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    
  801e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e38:	39 f2                	cmp    %esi,%edx
  801e3a:	89 d0                	mov    %edx,%eax
  801e3c:	77 52                	ja     801e90 <__umoddi3+0xa0>
  801e3e:	0f bd ea             	bsr    %edx,%ebp
  801e41:	83 f5 1f             	xor    $0x1f,%ebp
  801e44:	75 5a                	jne    801ea0 <__umoddi3+0xb0>
  801e46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e4a:	0f 82 e0 00 00 00    	jb     801f30 <__umoddi3+0x140>
  801e50:	39 0c 24             	cmp    %ecx,(%esp)
  801e53:	0f 86 d7 00 00 00    	jbe    801f30 <__umoddi3+0x140>
  801e59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e61:	83 c4 1c             	add    $0x1c,%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5f                   	pop    %edi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    
  801e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e70:	85 ff                	test   %edi,%edi
  801e72:	89 fd                	mov    %edi,%ebp
  801e74:	75 0b                	jne    801e81 <__umoddi3+0x91>
  801e76:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7b:	31 d2                	xor    %edx,%edx
  801e7d:	f7 f7                	div    %edi
  801e7f:	89 c5                	mov    %eax,%ebp
  801e81:	89 f0                	mov    %esi,%eax
  801e83:	31 d2                	xor    %edx,%edx
  801e85:	f7 f5                	div    %ebp
  801e87:	89 c8                	mov    %ecx,%eax
  801e89:	f7 f5                	div    %ebp
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	eb 99                	jmp    801e28 <__umoddi3+0x38>
  801e8f:	90                   	nop
  801e90:	89 c8                	mov    %ecx,%eax
  801e92:	89 f2                	mov    %esi,%edx
  801e94:	83 c4 1c             	add    $0x1c,%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    
  801e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	8b 34 24             	mov    (%esp),%esi
  801ea3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	29 ef                	sub    %ebp,%edi
  801eac:	d3 e0                	shl    %cl,%eax
  801eae:	89 f9                	mov    %edi,%ecx
  801eb0:	89 f2                	mov    %esi,%edx
  801eb2:	d3 ea                	shr    %cl,%edx
  801eb4:	89 e9                	mov    %ebp,%ecx
  801eb6:	09 c2                	or     %eax,%edx
  801eb8:	89 d8                	mov    %ebx,%eax
  801eba:	89 14 24             	mov    %edx,(%esp)
  801ebd:	89 f2                	mov    %esi,%edx
  801ebf:	d3 e2                	shl    %cl,%edx
  801ec1:	89 f9                	mov    %edi,%ecx
  801ec3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ec7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ecb:	d3 e8                	shr    %cl,%eax
  801ecd:	89 e9                	mov    %ebp,%ecx
  801ecf:	89 c6                	mov    %eax,%esi
  801ed1:	d3 e3                	shl    %cl,%ebx
  801ed3:	89 f9                	mov    %edi,%ecx
  801ed5:	89 d0                	mov    %edx,%eax
  801ed7:	d3 e8                	shr    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	09 d8                	or     %ebx,%eax
  801edd:	89 d3                	mov    %edx,%ebx
  801edf:	89 f2                	mov    %esi,%edx
  801ee1:	f7 34 24             	divl   (%esp)
  801ee4:	89 d6                	mov    %edx,%esi
  801ee6:	d3 e3                	shl    %cl,%ebx
  801ee8:	f7 64 24 04          	mull   0x4(%esp)
  801eec:	39 d6                	cmp    %edx,%esi
  801eee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ef2:	89 d1                	mov    %edx,%ecx
  801ef4:	89 c3                	mov    %eax,%ebx
  801ef6:	72 08                	jb     801f00 <__umoddi3+0x110>
  801ef8:	75 11                	jne    801f0b <__umoddi3+0x11b>
  801efa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801efe:	73 0b                	jae    801f0b <__umoddi3+0x11b>
  801f00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f04:	1b 14 24             	sbb    (%esp),%edx
  801f07:	89 d1                	mov    %edx,%ecx
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f0f:	29 da                	sub    %ebx,%edx
  801f11:	19 ce                	sbb    %ecx,%esi
  801f13:	89 f9                	mov    %edi,%ecx
  801f15:	89 f0                	mov    %esi,%eax
  801f17:	d3 e0                	shl    %cl,%eax
  801f19:	89 e9                	mov    %ebp,%ecx
  801f1b:	d3 ea                	shr    %cl,%edx
  801f1d:	89 e9                	mov    %ebp,%ecx
  801f1f:	d3 ee                	shr    %cl,%esi
  801f21:	09 d0                	or     %edx,%eax
  801f23:	89 f2                	mov    %esi,%edx
  801f25:	83 c4 1c             	add    $0x1c,%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	29 f9                	sub    %edi,%ecx
  801f32:	19 d6                	sbb    %edx,%esi
  801f34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f3c:	e9 18 ff ff ff       	jmp    801e59 <__umoddi3+0x69>
