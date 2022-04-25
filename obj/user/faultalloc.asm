
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 c0 1e 80 00       	push   $0x801ec0
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 4b 0b 00 00       	call   800ba9 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 e0 1e 80 00       	push   $0x801ee0
  80006f:	6a 0e                	push   $0xe
  800071:	68 ca 1e 80 00       	push   $0x801eca
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 0c 1f 80 00       	push   $0x801f0c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ca 06 00 00       	call   800753 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 f9 0c 00 00       	call   800d9a <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 dc 1e 80 00       	push   $0x801edc
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 dc 1e 80 00       	push   $0x801edc
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 91 0a 00 00       	call   800b6b <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 d6 0e 00 00       	call   800ff1 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 05 0a 00 00       	call   800b2a <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 2e 0a 00 00       	call   800b6b <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 38 1f 80 00       	push   $0x801f38
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 9f 23 80 00 	movl   $0x80239f,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 4d 09 00 00       	call   800aed <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 54 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 f2 08 00 00       	call   800aed <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 c5 19 00 00       	call   801c30 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 b2 1a 00 00       	call   801d60 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800323:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 05 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 2c             	sub    $0x2c,%esp
  800343:	8b 75 08             	mov    0x8(%ebp),%esi
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 a7 03 00 00    	je     8006fd <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	ff d6                	call   *%esi
  80035d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800360:	83 c7 01             	add    $0x1,%edi
  800363:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e2                	jne    80034e <vprintfmt+0x14>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80037e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800385:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80038c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800391:	eb 07                	jmp    80039a <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800396:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8d 47 01             	lea    0x1(%edi),%eax
  80039d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a0:	0f b6 07             	movzbl (%edi),%eax
  8003a3:	0f b6 d0             	movzbl %al,%edx
  8003a6:	83 e8 23             	sub    $0x23,%eax
  8003a9:	3c 55                	cmp    $0x55,%al
  8003ab:	0f 87 31 03 00 00    	ja     8006e2 <vprintfmt+0x3a8>
  8003b1:	0f b6 c0             	movzbl %al,%eax
  8003b4:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c2:	eb d6                	jmp    80039a <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cc:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003d6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8003dc:	83 fe 09             	cmp    $0x9,%esi
  8003df:	77 34                	ja     800415 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e4:	eb e9                	jmp    8003cf <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f7:	eb 22                	jmp    80041b <vprintfmt+0xe1>
  8003f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 48 c1             	cmovs  %ecx,%eax
  800401:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	eb 91                	jmp    80039a <vprintfmt+0x60>
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800413:	eb 85                	jmp    80039a <vprintfmt+0x60>
  800415:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800418:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	0f 89 75 ff ff ff    	jns    80039a <vprintfmt+0x60>
				width = precision, precision = -1;
  800425:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800432:	e9 63 ff ff ff       	jmp    80039a <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800437:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043e:	e9 57 ff ff ff       	jmp    80039a <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	53                   	push   %ebx
  800450:	ff 30                	pushl  (%eax)
  800452:	ff d6                	call   *%esi
			break;
  800454:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045a:	e9 01 ff ff ff       	jmp    800360 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8d 50 04             	lea    0x4(%eax),%edx
  800465:	89 55 14             	mov    %edx,0x14(%ebp)
  800468:	8b 00                	mov    (%eax),%eax
  80046a:	99                   	cltd   
  80046b:	31 d0                	xor    %edx,%eax
  80046d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046f:	83 f8 0f             	cmp    $0xf,%eax
  800472:	7f 0b                	jg     80047f <vprintfmt+0x145>
  800474:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80047b:	85 d2                	test   %edx,%edx
  80047d:	75 18                	jne    800497 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80047f:	50                   	push   %eax
  800480:	68 73 1f 80 00       	push   $0x801f73
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 91 fe ff ff       	call   80031d <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800492:	e9 c9 fe ff ff       	jmp    800360 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800497:	52                   	push   %edx
  800498:	68 6d 23 80 00       	push   $0x80236d
  80049d:	53                   	push   %ebx
  80049e:	56                   	push   %esi
  80049f:	e8 79 fe ff ff       	call   80031d <printfmt>
  8004a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004aa:	e9 b1 fe ff ff       	jmp    800360 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  8004c1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c8:	0f 8e 94 00 00 00    	jle    800562 <vprintfmt+0x228>
  8004ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d2:	0f 84 98 00 00 00    	je     800570 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	ff 75 cc             	pushl  -0x34(%ebp)
  8004de:	57                   	push   %edi
  8004df:	e8 a1 02 00 00       	call   800785 <strnlen>
  8004e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e7:	29 c1                	sub    %eax,%ecx
  8004e9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	eb 0f                	jmp    80050c <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	ff 75 e0             	pushl  -0x20(%ebp)
  800504:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	83 ef 01             	sub    $0x1,%edi
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	85 ff                	test   %edi,%edi
  80050e:	7f ed                	jg     8004fd <vprintfmt+0x1c3>
  800510:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800513:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800516:	85 c9                	test   %ecx,%ecx
  800518:	b8 00 00 00 00       	mov    $0x0,%eax
  80051d:	0f 49 c1             	cmovns %ecx,%eax
  800520:	29 c1                	sub    %eax,%ecx
  800522:	89 75 08             	mov    %esi,0x8(%ebp)
  800525:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800528:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052b:	89 cb                	mov    %ecx,%ebx
  80052d:	eb 4d                	jmp    80057c <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800533:	74 1b                	je     800550 <vprintfmt+0x216>
  800535:	0f be c0             	movsbl %al,%eax
  800538:	83 e8 20             	sub    $0x20,%eax
  80053b:	83 f8 5e             	cmp    $0x5e,%eax
  80053e:	76 10                	jbe    800550 <vprintfmt+0x216>
					putch('?', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	6a 3f                	push   $0x3f
  800548:	ff 55 08             	call   *0x8(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	eb 0d                	jmp    80055d <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	ff 75 0c             	pushl  0xc(%ebp)
  800556:	52                   	push   %edx
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055d:	83 eb 01             	sub    $0x1,%ebx
  800560:	eb 1a                	jmp    80057c <vprintfmt+0x242>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	eb 0c                	jmp    80057c <vprintfmt+0x242>
  800570:	89 75 08             	mov    %esi,0x8(%ebp)
  800573:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057c:	83 c7 01             	add    $0x1,%edi
  80057f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800583:	0f be d0             	movsbl %al,%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	74 23                	je     8005ad <vprintfmt+0x273>
  80058a:	85 f6                	test   %esi,%esi
  80058c:	78 a1                	js     80052f <vprintfmt+0x1f5>
  80058e:	83 ee 01             	sub    $0x1,%esi
  800591:	79 9c                	jns    80052f <vprintfmt+0x1f5>
  800593:	89 df                	mov    %ebx,%edi
  800595:	8b 75 08             	mov    0x8(%ebp),%esi
  800598:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059b:	eb 18                	jmp    8005b5 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 20                	push   $0x20
  8005a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a5:	83 ef 01             	sub    $0x1,%edi
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	eb 08                	jmp    8005b5 <vprintfmt+0x27b>
  8005ad:	89 df                	mov    %ebx,%edi
  8005af:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b5:	85 ff                	test   %edi,%edi
  8005b7:	7f e4                	jg     80059d <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bc:	e9 9f fd ff ff       	jmp    800360 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c1:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8005c5:	7e 16                	jle    8005dd <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 08             	lea    0x8(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 50 04             	mov    0x4(%eax),%edx
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005db:	eb 34                	jmp    800611 <vprintfmt+0x2d7>
	else if (lflag)
  8005dd:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005e1:	74 18                	je     8005fb <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f9:	eb 16                	jmp    800611 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 c1                	mov    %eax,%ecx
  80060b:	c1 f9 1f             	sar    $0x1f,%ecx
  80060e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800611:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800614:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800617:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800620:	0f 89 88 00 00 00    	jns    8006ae <vprintfmt+0x374>
				putch('-', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 2d                	push   $0x2d
  80062c:	ff d6                	call   *%esi
				num = -(long long) num;
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800634:	f7 d8                	neg    %eax
  800636:	83 d2 00             	adc    $0x0,%edx
  800639:	f7 da                	neg    %edx
  80063b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800643:	eb 69                	jmp    8006ae <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800645:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800648:	8d 45 14             	lea    0x14(%ebp),%eax
  80064b:	e8 76 fc ff ff       	call   8002c6 <getuint>
			base = 10;
  800650:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800655:	eb 57                	jmp    8006ae <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 30                	push   $0x30
  80065d:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80065f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 5c fc ff ff       	call   8002c6 <getuint>
			base = 8;
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80066d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800672:	eb 3a                	jmp    8006ae <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 30                	push   $0x30
  80067a:	ff d6                	call   *%esi
			putch('x', putdat);
  80067c:	83 c4 08             	add    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 78                	push   $0x78
  800682:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800694:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800697:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069c:	eb 10                	jmp    8006ae <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a4:	e8 1d fc ff ff       	call   8002c6 <getuint>
			base = 16;
  8006a9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ae:	83 ec 0c             	sub    $0xc,%esp
  8006b1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b5:	57                   	push   %edi
  8006b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b9:	51                   	push   %ecx
  8006ba:	52                   	push   %edx
  8006bb:	50                   	push   %eax
  8006bc:	89 da                	mov    %ebx,%edx
  8006be:	89 f0                	mov    %esi,%eax
  8006c0:	e8 52 fb ff ff       	call   800217 <printnum>
			break;
  8006c5:	83 c4 20             	add    $0x20,%esp
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cb:	e9 90 fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	52                   	push   %edx
  8006d5:	ff d6                	call   *%esi
			break;
  8006d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006dd:	e9 7e fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 25                	push   $0x25
  8006e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 03                	jmp    8006f2 <vprintfmt+0x3b8>
  8006ef:	83 ef 01             	sub    $0x1,%edi
  8006f2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f6:	75 f7                	jne    8006ef <vprintfmt+0x3b5>
  8006f8:	e9 63 fc ff ff       	jmp    800360 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800714:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800718:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800722:	85 c0                	test   %eax,%eax
  800724:	74 26                	je     80074c <vsnprintf+0x47>
  800726:	85 d2                	test   %edx,%edx
  800728:	7e 22                	jle    80074c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072a:	ff 75 14             	pushl  0x14(%ebp)
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800733:	50                   	push   %eax
  800734:	68 00 03 80 00       	push   $0x800300
  800739:	e8 fc fb ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800741:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 05                	jmp    800751 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075c:	50                   	push   %eax
  80075d:	ff 75 10             	pushl  0x10(%ebp)
  800760:	ff 75 0c             	pushl  0xc(%ebp)
  800763:	ff 75 08             	pushl  0x8(%ebp)
  800766:	e8 9a ff ff ff       	call   800705 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800773:	b8 00 00 00 00       	mov    $0x0,%eax
  800778:	eb 03                	jmp    80077d <strlen+0x10>
		n++;
  80077a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800781:	75 f7                	jne    80077a <strlen+0xd>
		n++;
	return n;
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078e:	ba 00 00 00 00       	mov    $0x0,%edx
  800793:	eb 03                	jmp    800798 <strnlen+0x13>
		n++;
  800795:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800798:	39 c2                	cmp    %eax,%edx
  80079a:	74 08                	je     8007a4 <strnlen+0x1f>
  80079c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a0:	75 f3                	jne    800795 <strnlen+0x10>
  8007a2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	83 c1 01             	add    $0x1,%ecx
  8007b8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007bf:	84 db                	test   %bl,%bl
  8007c1:	75 ef                	jne    8007b2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c3:	5b                   	pop    %ebx
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cd:	53                   	push   %ebx
  8007ce:	e8 9a ff ff ff       	call   80076d <strlen>
  8007d3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d6:	ff 75 0c             	pushl  0xc(%ebp)
  8007d9:	01 d8                	add    %ebx,%eax
  8007db:	50                   	push   %eax
  8007dc:	e8 c5 ff ff ff       	call   8007a6 <strcpy>
	return dst;
}
  8007e1:	89 d8                	mov    %ebx,%eax
  8007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	89 f3                	mov    %esi,%ebx
  8007f5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	89 f2                	mov    %esi,%edx
  8007fa:	eb 0f                	jmp    80080b <strncpy+0x23>
		*dst++ = *src;
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	0f b6 01             	movzbl (%ecx),%eax
  800802:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800805:	80 39 01             	cmpb   $0x1,(%ecx)
  800808:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	39 da                	cmp    %ebx,%edx
  80080d:	75 ed                	jne    8007fc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080f:	89 f0                	mov    %esi,%eax
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 75 08             	mov    0x8(%ebp),%esi
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	8b 55 10             	mov    0x10(%ebp),%edx
  800823:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800825:	85 d2                	test   %edx,%edx
  800827:	74 21                	je     80084a <strlcpy+0x35>
  800829:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082d:	89 f2                	mov    %esi,%edx
  80082f:	eb 09                	jmp    80083a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800831:	83 c2 01             	add    $0x1,%edx
  800834:	83 c1 01             	add    $0x1,%ecx
  800837:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083a:	39 c2                	cmp    %eax,%edx
  80083c:	74 09                	je     800847 <strlcpy+0x32>
  80083e:	0f b6 19             	movzbl (%ecx),%ebx
  800841:	84 db                	test   %bl,%bl
  800843:	75 ec                	jne    800831 <strlcpy+0x1c>
  800845:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800847:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084a:	29 f0                	sub    %esi,%eax
}
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800859:	eb 06                	jmp    800861 <strcmp+0x11>
		p++, q++;
  80085b:	83 c1 01             	add    $0x1,%ecx
  80085e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800861:	0f b6 01             	movzbl (%ecx),%eax
  800864:	84 c0                	test   %al,%al
  800866:	74 04                	je     80086c <strcmp+0x1c>
  800868:	3a 02                	cmp    (%edx),%al
  80086a:	74 ef                	je     80085b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086c:	0f b6 c0             	movzbl %al,%eax
  80086f:	0f b6 12             	movzbl (%edx),%edx
  800872:	29 d0                	sub    %edx,%eax
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800880:	89 c3                	mov    %eax,%ebx
  800882:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800885:	eb 06                	jmp    80088d <strncmp+0x17>
		n--, p++, q++;
  800887:	83 c0 01             	add    $0x1,%eax
  80088a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088d:	39 d8                	cmp    %ebx,%eax
  80088f:	74 15                	je     8008a6 <strncmp+0x30>
  800891:	0f b6 08             	movzbl (%eax),%ecx
  800894:	84 c9                	test   %cl,%cl
  800896:	74 04                	je     80089c <strncmp+0x26>
  800898:	3a 0a                	cmp    (%edx),%cl
  80089a:	74 eb                	je     800887 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089c:	0f b6 00             	movzbl (%eax),%eax
  80089f:	0f b6 12             	movzbl (%edx),%edx
  8008a2:	29 d0                	sub    %edx,%eax
  8008a4:	eb 05                	jmp    8008ab <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ab:	5b                   	pop    %ebx
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b8:	eb 07                	jmp    8008c1 <strchr+0x13>
		if (*s == c)
  8008ba:	38 ca                	cmp    %cl,%dl
  8008bc:	74 0f                	je     8008cd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	0f b6 10             	movzbl (%eax),%edx
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	75 f2                	jne    8008ba <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d9:	eb 03                	jmp    8008de <strfind+0xf>
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e1:	38 ca                	cmp    %cl,%dl
  8008e3:	74 04                	je     8008e9 <strfind+0x1a>
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	75 f2                	jne    8008db <strfind+0xc>
			break;
	return (char *) s;
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f7:	85 c9                	test   %ecx,%ecx
  8008f9:	74 36                	je     800931 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800901:	75 28                	jne    80092b <memset+0x40>
  800903:	f6 c1 03             	test   $0x3,%cl
  800906:	75 23                	jne    80092b <memset+0x40>
		c &= 0xFF;
  800908:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090c:	89 d3                	mov    %edx,%ebx
  80090e:	c1 e3 08             	shl    $0x8,%ebx
  800911:	89 d6                	mov    %edx,%esi
  800913:	c1 e6 18             	shl    $0x18,%esi
  800916:	89 d0                	mov    %edx,%eax
  800918:	c1 e0 10             	shl    $0x10,%eax
  80091b:	09 f0                	or     %esi,%eax
  80091d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80091f:	89 d8                	mov    %ebx,%eax
  800921:	09 d0                	or     %edx,%eax
  800923:	c1 e9 02             	shr    $0x2,%ecx
  800926:	fc                   	cld    
  800927:	f3 ab                	rep stos %eax,%es:(%edi)
  800929:	eb 06                	jmp    800931 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	fc                   	cld    
  80092f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800931:	89 f8                	mov    %edi,%eax
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5f                   	pop    %edi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8b 75 0c             	mov    0xc(%ebp),%esi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800946:	39 c6                	cmp    %eax,%esi
  800948:	73 35                	jae    80097f <memmove+0x47>
  80094a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094d:	39 d0                	cmp    %edx,%eax
  80094f:	73 2e                	jae    80097f <memmove+0x47>
		s += n;
		d += n;
  800951:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	89 d6                	mov    %edx,%esi
  800956:	09 fe                	or     %edi,%esi
  800958:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095e:	75 13                	jne    800973 <memmove+0x3b>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 0e                	jne    800973 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800965:	83 ef 04             	sub    $0x4,%edi
  800968:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096b:	c1 e9 02             	shr    $0x2,%ecx
  80096e:	fd                   	std    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 09                	jmp    80097c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800973:	83 ef 01             	sub    $0x1,%edi
  800976:	8d 72 ff             	lea    -0x1(%edx),%esi
  800979:	fd                   	std    
  80097a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097c:	fc                   	cld    
  80097d:	eb 1d                	jmp    80099c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	89 f2                	mov    %esi,%edx
  800981:	09 c2                	or     %eax,%edx
  800983:	f6 c2 03             	test   $0x3,%dl
  800986:	75 0f                	jne    800997 <memmove+0x5f>
  800988:	f6 c1 03             	test   $0x3,%cl
  80098b:	75 0a                	jne    800997 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098d:	c1 e9 02             	shr    $0x2,%ecx
  800990:	89 c7                	mov    %eax,%edi
  800992:	fc                   	cld    
  800993:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800995:	eb 05                	jmp    80099c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800997:	89 c7                	mov    %eax,%edi
  800999:	fc                   	cld    
  80099a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099c:	5e                   	pop    %esi
  80099d:	5f                   	pop    %edi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a3:	ff 75 10             	pushl  0x10(%ebp)
  8009a6:	ff 75 0c             	pushl  0xc(%ebp)
  8009a9:	ff 75 08             	pushl  0x8(%ebp)
  8009ac:	e8 87 ff ff ff       	call   800938 <memmove>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009be:	89 c6                	mov    %eax,%esi
  8009c0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c3:	eb 1a                	jmp    8009df <memcmp+0x2c>
		if (*s1 != *s2)
  8009c5:	0f b6 08             	movzbl (%eax),%ecx
  8009c8:	0f b6 1a             	movzbl (%edx),%ebx
  8009cb:	38 d9                	cmp    %bl,%cl
  8009cd:	74 0a                	je     8009d9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009cf:	0f b6 c1             	movzbl %cl,%eax
  8009d2:	0f b6 db             	movzbl %bl,%ebx
  8009d5:	29 d8                	sub    %ebx,%eax
  8009d7:	eb 0f                	jmp    8009e8 <memcmp+0x35>
		s1++, s2++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009df:	39 f0                	cmp    %esi,%eax
  8009e1:	75 e2                	jne    8009c5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	53                   	push   %ebx
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f3:	89 c1                	mov    %eax,%ecx
  8009f5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fc:	eb 0a                	jmp    800a08 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fe:	0f b6 10             	movzbl (%eax),%edx
  800a01:	39 da                	cmp    %ebx,%edx
  800a03:	74 07                	je     800a0c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	39 c8                	cmp    %ecx,%eax
  800a0a:	72 f2                	jb     8009fe <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	eb 03                	jmp    800a20 <strtol+0x11>
		s++;
  800a1d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	0f b6 01             	movzbl (%ecx),%eax
  800a23:	3c 20                	cmp    $0x20,%al
  800a25:	74 f6                	je     800a1d <strtol+0xe>
  800a27:	3c 09                	cmp    $0x9,%al
  800a29:	74 f2                	je     800a1d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2b:	3c 2b                	cmp    $0x2b,%al
  800a2d:	75 0a                	jne    800a39 <strtol+0x2a>
		s++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a32:	bf 00 00 00 00       	mov    $0x0,%edi
  800a37:	eb 11                	jmp    800a4a <strtol+0x3b>
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3e:	3c 2d                	cmp    $0x2d,%al
  800a40:	75 08                	jne    800a4a <strtol+0x3b>
		s++, neg = 1;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a50:	75 15                	jne    800a67 <strtol+0x58>
  800a52:	80 39 30             	cmpb   $0x30,(%ecx)
  800a55:	75 10                	jne    800a67 <strtol+0x58>
  800a57:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5b:	75 7c                	jne    800ad9 <strtol+0xca>
		s += 2, base = 16;
  800a5d:	83 c1 02             	add    $0x2,%ecx
  800a60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a65:	eb 16                	jmp    800a7d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a67:	85 db                	test   %ebx,%ebx
  800a69:	75 12                	jne    800a7d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a70:	80 39 30             	cmpb   $0x30,(%ecx)
  800a73:	75 08                	jne    800a7d <strtol+0x6e>
		s++, base = 8;
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a82:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a85:	0f b6 11             	movzbl (%ecx),%edx
  800a88:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 09             	cmp    $0x9,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x8b>
			dig = *s - '0';
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 30             	sub    $0x30,%edx
  800a98:	eb 22                	jmp    800abc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 08                	ja     800aac <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 57             	sub    $0x57,%edx
  800aaa:	eb 10                	jmp    800abc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aac:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 16                	ja     800acc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abf:	7d 0b                	jge    800acc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aca:	eb b9                	jmp    800a85 <strtol+0x76>

	if (endptr)
  800acc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad0:	74 0d                	je     800adf <strtol+0xd0>
		*endptr = (char *) s;
  800ad2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad5:	89 0e                	mov    %ecx,(%esi)
  800ad7:	eb 06                	jmp    800adf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad9:	85 db                	test   %ebx,%ebx
  800adb:	74 98                	je     800a75 <strtol+0x66>
  800add:	eb 9e                	jmp    800a7d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	f7 da                	neg    %edx
  800ae3:	85 ff                	test   %edi,%edi
  800ae5:	0f 45 c2             	cmovne %edx,%eax
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	89 c3                	mov    %eax,%ebx
  800b00:	89 c7                	mov    %eax,%edi
  800b02:	89 c6                	mov    %eax,%esi
  800b04:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1b:	89 d1                	mov    %edx,%ecx
  800b1d:	89 d3                	mov    %edx,%ebx
  800b1f:	89 d7                	mov    %edx,%edi
  800b21:	89 d6                	mov    %edx,%esi
  800b23:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b38:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	89 cb                	mov    %ecx,%ebx
  800b42:	89 cf                	mov    %ecx,%edi
  800b44:	89 ce                	mov    %ecx,%esi
  800b46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	7e 17                	jle    800b63 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	50                   	push   %eax
  800b50:	6a 03                	push   $0x3
  800b52:	68 5f 22 80 00       	push   $0x80225f
  800b57:	6a 23                	push   $0x23
  800b59:	68 7c 22 80 00       	push   $0x80227c
  800b5e:	e8 c7 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7b:	89 d1                	mov    %edx,%ecx
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	89 d7                	mov    %edx,%edi
  800b81:	89 d6                	mov    %edx,%esi
  800b83:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_yield>:

void
sys_yield(void)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9a:	89 d1                	mov    %edx,%ecx
  800b9c:	89 d3                	mov    %edx,%ebx
  800b9e:	89 d7                	mov    %edx,%edi
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	be 00 00 00 00       	mov    $0x0,%esi
  800bb7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc5:	89 f7                	mov    %esi,%edi
  800bc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	7e 17                	jle    800be4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 04                	push   $0x4
  800bd3:	68 5f 22 80 00       	push   $0x80225f
  800bd8:	6a 23                	push   $0x23
  800bda:	68 7c 22 80 00       	push   $0x80227c
  800bdf:	e8 46 f5 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c03:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c06:	8b 75 18             	mov    0x18(%ebp),%esi
  800c09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 05                	push   $0x5
  800c15:	68 5f 22 80 00       	push   $0x80225f
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 7c 22 80 00       	push   $0x80227c
  800c21:	e8 04 f5 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 df                	mov    %ebx,%edi
  800c49:	89 de                	mov    %ebx,%esi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 06                	push   $0x6
  800c57:	68 5f 22 80 00       	push   $0x80225f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 7c 22 80 00       	push   $0x80227c
  800c63:	e8 c2 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 df                	mov    %ebx,%edi
  800c8b:	89 de                	mov    %ebx,%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 08                	push   $0x8
  800c99:	68 5f 22 80 00       	push   $0x80225f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 7c 22 80 00       	push   $0x80227c
  800ca5:	e8 80 f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 09                	push   $0x9
  800cdb:	68 5f 22 80 00       	push   $0x80225f
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 7c 22 80 00       	push   $0x80227c
  800ce7:	e8 3e f4 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 17                	jle    800d2e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 0a                	push   $0xa
  800d1d:	68 5f 22 80 00       	push   $0x80225f
  800d22:	6a 23                	push   $0x23
  800d24:	68 7c 22 80 00       	push   $0x80227c
  800d29:	e8 fc f3 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	be 00 00 00 00       	mov    $0x0,%esi
  800d41:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d52:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d67:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	89 cb                	mov    %ecx,%ebx
  800d71:	89 cf                	mov    %ecx,%edi
  800d73:	89 ce                	mov    %ecx,%esi
  800d75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d77:	85 c0                	test   %eax,%eax
  800d79:	7e 17                	jle    800d92 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	50                   	push   %eax
  800d7f:	6a 0d                	push   $0xd
  800d81:	68 5f 22 80 00       	push   $0x80225f
  800d86:	6a 23                	push   $0x23
  800d88:	68 7c 22 80 00       	push   $0x80227c
  800d8d:	e8 98 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  800da0:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800da7:	75 36                	jne    800ddf <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800da9:	a1 04 40 80 00       	mov    0x804004,%eax
  800dae:	8b 40 48             	mov    0x48(%eax),%eax
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	68 07 0e 00 00       	push   $0xe07
  800db9:	68 00 f0 bf ee       	push   $0xeebff000
  800dbe:	50                   	push   %eax
  800dbf:	e8 e5 fd ff ff       	call   800ba9 <sys_page_alloc>
		if (ret < 0) {
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	79 14                	jns    800ddf <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	68 8c 22 80 00       	push   $0x80228c
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 b3 22 80 00       	push   $0x8022b3
  800dda:	e8 4b f3 ff ff       	call   80012a <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800ddf:	a1 04 40 80 00       	mov    0x804004,%eax
  800de4:	8b 40 48             	mov    0x48(%eax),%eax
  800de7:	83 ec 08             	sub    $0x8,%esp
  800dea:	68 02 0e 80 00       	push   $0x800e02
  800def:	50                   	push   %eax
  800df0:	e8 ff fe ff ff       	call   800cf4 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e02:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e03:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e08:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e0a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  800e0d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  800e11:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  800e16:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  800e1a:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  800e1c:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e1f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800e20:	83 c4 04             	add    $0x4,%esp
        popfl
  800e23:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800e24:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e25:	c3                   	ret    

00800e26 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e31:	c1 e8 0c             	shr    $0xc,%eax
}
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e46:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e53:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e58:	89 c2                	mov    %eax,%edx
  800e5a:	c1 ea 16             	shr    $0x16,%edx
  800e5d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e64:	f6 c2 01             	test   $0x1,%dl
  800e67:	74 11                	je     800e7a <fd_alloc+0x2d>
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 0c             	shr    $0xc,%edx
  800e6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e75:	f6 c2 01             	test   $0x1,%dl
  800e78:	75 09                	jne    800e83 <fd_alloc+0x36>
			*fd_store = fd;
  800e7a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e81:	eb 17                	jmp    800e9a <fd_alloc+0x4d>
  800e83:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e88:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e8d:	75 c9                	jne    800e58 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e8f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e95:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea2:	83 f8 1f             	cmp    $0x1f,%eax
  800ea5:	77 36                	ja     800edd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea7:	c1 e0 0c             	shl    $0xc,%eax
  800eaa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eaf:	89 c2                	mov    %eax,%edx
  800eb1:	c1 ea 16             	shr    $0x16,%edx
  800eb4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebb:	f6 c2 01             	test   $0x1,%dl
  800ebe:	74 24                	je     800ee4 <fd_lookup+0x48>
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	c1 ea 0c             	shr    $0xc,%edx
  800ec5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ecc:	f6 c2 01             	test   $0x1,%dl
  800ecf:	74 1a                	je     800eeb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed4:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  800edb:	eb 13                	jmp    800ef0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee2:	eb 0c                	jmp    800ef0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee9:	eb 05                	jmp    800ef0 <fd_lookup+0x54>
  800eeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800efb:	ba 44 23 80 00       	mov    $0x802344,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f00:	eb 13                	jmp    800f15 <dev_lookup+0x23>
  800f02:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f05:	39 08                	cmp    %ecx,(%eax)
  800f07:	75 0c                	jne    800f15 <dev_lookup+0x23>
			*dev = devtab[i];
  800f09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	eb 2e                	jmp    800f43 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f15:	8b 02                	mov    (%edx),%eax
  800f17:	85 c0                	test   %eax,%eax
  800f19:	75 e7                	jne    800f02 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f1b:	a1 04 40 80 00       	mov    0x804004,%eax
  800f20:	8b 40 48             	mov    0x48(%eax),%eax
  800f23:	83 ec 04             	sub    $0x4,%esp
  800f26:	51                   	push   %ecx
  800f27:	50                   	push   %eax
  800f28:	68 c4 22 80 00       	push   $0x8022c4
  800f2d:	e8 d1 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
  800f4a:	83 ec 10             	sub    $0x10,%esp
  800f4d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f5d:	c1 e8 0c             	shr    $0xc,%eax
  800f60:	50                   	push   %eax
  800f61:	e8 36 ff ff ff       	call   800e9c <fd_lookup>
  800f66:	83 c4 08             	add    $0x8,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 05                	js     800f72 <fd_close+0x2d>
	    || fd != fd2)
  800f6d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f70:	74 0c                	je     800f7e <fd_close+0x39>
		return (must_exist ? r : 0);
  800f72:	84 db                	test   %bl,%bl
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	0f 44 c2             	cmove  %edx,%eax
  800f7c:	eb 41                	jmp    800fbf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7e:	83 ec 08             	sub    $0x8,%esp
  800f81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f84:	50                   	push   %eax
  800f85:	ff 36                	pushl  (%esi)
  800f87:	e8 66 ff ff ff       	call   800ef2 <dev_lookup>
  800f8c:	89 c3                	mov    %eax,%ebx
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 1a                	js     800faf <fd_close+0x6a>
		if (dev->dev_close)
  800f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f98:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f9b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	74 0b                	je     800faf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	56                   	push   %esi
  800fa8:	ff d0                	call   *%eax
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	56                   	push   %esi
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 74 fc ff ff       	call   800c2e <sys_page_unmap>
	return r;
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	89 d8                	mov    %ebx,%eax
}
  800fbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcf:	50                   	push   %eax
  800fd0:	ff 75 08             	pushl  0x8(%ebp)
  800fd3:	e8 c4 fe ff ff       	call   800e9c <fd_lookup>
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 10                	js     800fef <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	6a 01                	push   $0x1
  800fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe7:	e8 59 ff ff ff       	call   800f45 <fd_close>
  800fec:	83 c4 10             	add    $0x10,%esp
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <close_all>:

void
close_all(void)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	53                   	push   %ebx
  800ff5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ffd:	83 ec 0c             	sub    $0xc,%esp
  801000:	53                   	push   %ebx
  801001:	e8 c0 ff ff ff       	call   800fc6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801006:	83 c3 01             	add    $0x1,%ebx
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	83 fb 20             	cmp    $0x20,%ebx
  80100f:	75 ec                	jne    800ffd <close_all+0xc>
		close(i);
}
  801011:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801014:	c9                   	leave  
  801015:	c3                   	ret    

00801016 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
  80101c:	83 ec 2c             	sub    $0x2c,%esp
  80101f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801022:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801025:	50                   	push   %eax
  801026:	ff 75 08             	pushl  0x8(%ebp)
  801029:	e8 6e fe ff ff       	call   800e9c <fd_lookup>
  80102e:	83 c4 08             	add    $0x8,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	0f 88 c1 00 00 00    	js     8010fa <dup+0xe4>
		return r;
	close(newfdnum);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	56                   	push   %esi
  80103d:	e8 84 ff ff ff       	call   800fc6 <close>

	newfd = INDEX2FD(newfdnum);
  801042:	89 f3                	mov    %esi,%ebx
  801044:	c1 e3 0c             	shl    $0xc,%ebx
  801047:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80104d:	83 c4 04             	add    $0x4,%esp
  801050:	ff 75 e4             	pushl  -0x1c(%ebp)
  801053:	e8 de fd ff ff       	call   800e36 <fd2data>
  801058:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80105a:	89 1c 24             	mov    %ebx,(%esp)
  80105d:	e8 d4 fd ff ff       	call   800e36 <fd2data>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801068:	89 f8                	mov    %edi,%eax
  80106a:	c1 e8 16             	shr    $0x16,%eax
  80106d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801074:	a8 01                	test   $0x1,%al
  801076:	74 37                	je     8010af <dup+0x99>
  801078:	89 f8                	mov    %edi,%eax
  80107a:	c1 e8 0c             	shr    $0xc,%eax
  80107d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801084:	f6 c2 01             	test   $0x1,%dl
  801087:	74 26                	je     8010af <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801089:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	25 07 0e 00 00       	and    $0xe07,%eax
  801098:	50                   	push   %eax
  801099:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109c:	6a 00                	push   $0x0
  80109e:	57                   	push   %edi
  80109f:	6a 00                	push   $0x0
  8010a1:	e8 46 fb ff ff       	call   800bec <sys_page_map>
  8010a6:	89 c7                	mov    %eax,%edi
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 2e                	js     8010dd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010b2:	89 d0                	mov    %edx,%eax
  8010b4:	c1 e8 0c             	shr    $0xc,%eax
  8010b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c6:	50                   	push   %eax
  8010c7:	53                   	push   %ebx
  8010c8:	6a 00                	push   $0x0
  8010ca:	52                   	push   %edx
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 1a fb ff ff       	call   800bec <sys_page_map>
  8010d2:	89 c7                	mov    %eax,%edi
  8010d4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010d7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d9:	85 ff                	test   %edi,%edi
  8010db:	79 1d                	jns    8010fa <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010dd:	83 ec 08             	sub    $0x8,%esp
  8010e0:	53                   	push   %ebx
  8010e1:	6a 00                	push   $0x0
  8010e3:	e8 46 fb ff ff       	call   800c2e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e8:	83 c4 08             	add    $0x8,%esp
  8010eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ee:	6a 00                	push   $0x0
  8010f0:	e8 39 fb ff ff       	call   800c2e <sys_page_unmap>
	return r;
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	89 f8                	mov    %edi,%eax
}
  8010fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	53                   	push   %ebx
  801106:	83 ec 14             	sub    $0x14,%esp
  801109:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	53                   	push   %ebx
  801111:	e8 86 fd ff ff       	call   800e9c <fd_lookup>
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	89 c2                	mov    %eax,%edx
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 6d                	js     80118c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801129:	ff 30                	pushl  (%eax)
  80112b:	e8 c2 fd ff ff       	call   800ef2 <dev_lookup>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	78 4c                	js     801183 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801137:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80113a:	8b 42 08             	mov    0x8(%edx),%eax
  80113d:	83 e0 03             	and    $0x3,%eax
  801140:	83 f8 01             	cmp    $0x1,%eax
  801143:	75 21                	jne    801166 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801145:	a1 04 40 80 00       	mov    0x804004,%eax
  80114a:	8b 40 48             	mov    0x48(%eax),%eax
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	53                   	push   %ebx
  801151:	50                   	push   %eax
  801152:	68 08 23 80 00       	push   $0x802308
  801157:	e8 a7 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801164:	eb 26                	jmp    80118c <read+0x8a>
	}
	if (!dev->dev_read)
  801166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801169:	8b 40 08             	mov    0x8(%eax),%eax
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 17                	je     801187 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	ff 75 10             	pushl  0x10(%ebp)
  801176:	ff 75 0c             	pushl  0xc(%ebp)
  801179:	52                   	push   %edx
  80117a:	ff d0                	call   *%eax
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	eb 09                	jmp    80118c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801183:	89 c2                	mov    %eax,%edx
  801185:	eb 05                	jmp    80118c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801187:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80118c:	89 d0                	mov    %edx,%eax
  80118e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a7:	eb 21                	jmp    8011ca <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	89 f0                	mov    %esi,%eax
  8011ae:	29 d8                	sub    %ebx,%eax
  8011b0:	50                   	push   %eax
  8011b1:	89 d8                	mov    %ebx,%eax
  8011b3:	03 45 0c             	add    0xc(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	57                   	push   %edi
  8011b8:	e8 45 ff ff ff       	call   801102 <read>
		if (m < 0)
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 10                	js     8011d4 <readn+0x41>
			return m;
		if (m == 0)
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	74 0a                	je     8011d2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c8:	01 c3                	add    %eax,%ebx
  8011ca:	39 f3                	cmp    %esi,%ebx
  8011cc:	72 db                	jb     8011a9 <readn+0x16>
  8011ce:	89 d8                	mov    %ebx,%eax
  8011d0:	eb 02                	jmp    8011d4 <readn+0x41>
  8011d2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 14             	sub    $0x14,%esp
  8011e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	53                   	push   %ebx
  8011eb:	e8 ac fc ff ff       	call   800e9c <fd_lookup>
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 68                	js     801261 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801203:	ff 30                	pushl  (%eax)
  801205:	e8 e8 fc ff ff       	call   800ef2 <dev_lookup>
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 47                	js     801258 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801218:	75 21                	jne    80123b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80121a:	a1 04 40 80 00       	mov    0x804004,%eax
  80121f:	8b 40 48             	mov    0x48(%eax),%eax
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	53                   	push   %ebx
  801226:	50                   	push   %eax
  801227:	68 24 23 80 00       	push   $0x802324
  80122c:	e8 d2 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801239:	eb 26                	jmp    801261 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80123b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123e:	8b 52 0c             	mov    0xc(%edx),%edx
  801241:	85 d2                	test   %edx,%edx
  801243:	74 17                	je     80125c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801245:	83 ec 04             	sub    $0x4,%esp
  801248:	ff 75 10             	pushl  0x10(%ebp)
  80124b:	ff 75 0c             	pushl  0xc(%ebp)
  80124e:	50                   	push   %eax
  80124f:	ff d2                	call   *%edx
  801251:	89 c2                	mov    %eax,%edx
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	eb 09                	jmp    801261 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801258:	89 c2                	mov    %eax,%edx
  80125a:	eb 05                	jmp    801261 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80125c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801261:	89 d0                	mov    %edx,%eax
  801263:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <seek>:

int
seek(int fdnum, off_t offset)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	ff 75 08             	pushl  0x8(%ebp)
  801275:	e8 22 fc ff ff       	call   800e9c <fd_lookup>
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 0e                	js     80128f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801281:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801284:	8b 55 0c             	mov    0xc(%ebp),%edx
  801287:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	53                   	push   %ebx
  801295:	83 ec 14             	sub    $0x14,%esp
  801298:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129e:	50                   	push   %eax
  80129f:	53                   	push   %ebx
  8012a0:	e8 f7 fb ff ff       	call   800e9c <fd_lookup>
  8012a5:	83 c4 08             	add    $0x8,%esp
  8012a8:	89 c2                	mov    %eax,%edx
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 65                	js     801313 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ae:	83 ec 08             	sub    $0x8,%esp
  8012b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b8:	ff 30                	pushl  (%eax)
  8012ba:	e8 33 fc ff ff       	call   800ef2 <dev_lookup>
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	78 44                	js     80130a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012cd:	75 21                	jne    8012f0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012cf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d4:	8b 40 48             	mov    0x48(%eax),%eax
  8012d7:	83 ec 04             	sub    $0x4,%esp
  8012da:	53                   	push   %ebx
  8012db:	50                   	push   %eax
  8012dc:	68 e4 22 80 00       	push   $0x8022e4
  8012e1:	e8 1d ef ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ee:	eb 23                	jmp    801313 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f3:	8b 52 18             	mov    0x18(%edx),%edx
  8012f6:	85 d2                	test   %edx,%edx
  8012f8:	74 14                	je     80130e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	ff 75 0c             	pushl  0xc(%ebp)
  801300:	50                   	push   %eax
  801301:	ff d2                	call   *%edx
  801303:	89 c2                	mov    %eax,%edx
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	eb 09                	jmp    801313 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	eb 05                	jmp    801313 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80130e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801313:	89 d0                	mov    %edx,%eax
  801315:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 14             	sub    $0x14,%esp
  801321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801324:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 6c fb ff ff       	call   800e9c <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	89 c2                	mov    %eax,%edx
  801335:	85 c0                	test   %eax,%eax
  801337:	78 58                	js     801391 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801343:	ff 30                	pushl  (%eax)
  801345:	e8 a8 fb ff ff       	call   800ef2 <dev_lookup>
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 37                	js     801388 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801351:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801354:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801358:	74 32                	je     80138c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80135a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80135d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801364:	00 00 00 
	stat->st_isdir = 0;
  801367:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136e:	00 00 00 
	stat->st_dev = dev;
  801371:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	53                   	push   %ebx
  80137b:	ff 75 f0             	pushl  -0x10(%ebp)
  80137e:	ff 50 14             	call   *0x14(%eax)
  801381:	89 c2                	mov    %eax,%edx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	eb 09                	jmp    801391 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801388:	89 c2                	mov    %eax,%edx
  80138a:	eb 05                	jmp    801391 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80138c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801391:	89 d0                	mov    %edx,%eax
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	56                   	push   %esi
  80139c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	6a 00                	push   $0x0
  8013a2:	ff 75 08             	pushl  0x8(%ebp)
  8013a5:	e8 e3 01 00 00       	call   80158d <open>
  8013aa:	89 c3                	mov    %eax,%ebx
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 1b                	js     8013ce <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	ff 75 0c             	pushl  0xc(%ebp)
  8013b9:	50                   	push   %eax
  8013ba:	e8 5b ff ff ff       	call   80131a <fstat>
  8013bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c1:	89 1c 24             	mov    %ebx,(%esp)
  8013c4:	e8 fd fb ff ff       	call   800fc6 <close>
	return r;
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	89 f0                	mov    %esi,%eax
}
  8013ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	89 c6                	mov    %eax,%esi
  8013dc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013de:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e5:	75 12                	jne    8013f9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	6a 01                	push   $0x1
  8013ec:	e8 c8 07 00 00       	call   801bb9 <ipc_find_env>
  8013f1:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f9:	6a 07                	push   $0x7
  8013fb:	68 00 50 80 00       	push   $0x805000
  801400:	56                   	push   %esi
  801401:	ff 35 00 40 80 00    	pushl  0x804000
  801407:	e8 59 07 00 00       	call   801b65 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80140c:	83 c4 0c             	add    $0xc,%esp
  80140f:	6a 00                	push   $0x0
  801411:	53                   	push   %ebx
  801412:	6a 00                	push   $0x0
  801414:	e8 f7 06 00 00       	call   801b10 <ipc_recv>
}
  801419:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	8b 40 0c             	mov    0xc(%eax),%eax
  80142c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801431:	8b 45 0c             	mov    0xc(%ebp),%eax
  801434:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801439:	ba 00 00 00 00       	mov    $0x0,%edx
  80143e:	b8 02 00 00 00       	mov    $0x2,%eax
  801443:	e8 8d ff ff ff       	call   8013d5 <fsipc>
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801450:	8b 45 08             	mov    0x8(%ebp),%eax
  801453:	8b 40 0c             	mov    0xc(%eax),%eax
  801456:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80145b:	ba 00 00 00 00       	mov    $0x0,%edx
  801460:	b8 06 00 00 00       	mov    $0x6,%eax
  801465:	e8 6b ff ff ff       	call   8013d5 <fsipc>
}
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	8b 40 0c             	mov    0xc(%eax),%eax
  80147c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801481:	ba 00 00 00 00       	mov    $0x0,%edx
  801486:	b8 05 00 00 00       	mov    $0x5,%eax
  80148b:	e8 45 ff ff ff       	call   8013d5 <fsipc>
  801490:	85 c0                	test   %eax,%eax
  801492:	78 2c                	js     8014c0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	68 00 50 80 00       	push   $0x805000
  80149c:	53                   	push   %ebx
  80149d:	e8 04 f3 ff ff       	call   8007a6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ad:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d4:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8014da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014df:	ba 00 10 00 00       	mov    $0x1000,%edx
  8014e4:	0f 47 c2             	cmova  %edx,%eax
  8014e7:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014ec:	50                   	push   %eax
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	68 08 50 80 00       	push   $0x805008
  8014f5:	e8 3e f4 ff ff       	call   800938 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801504:	e8 cc fe ff ff       	call   8013d5 <fsipc>
    return r;
}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	8b 40 0c             	mov    0xc(%eax),%eax
  801519:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 03 00 00 00       	mov    $0x3,%eax
  80152e:	e8 a2 fe ff ff       	call   8013d5 <fsipc>
  801533:	89 c3                	mov    %eax,%ebx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 4b                	js     801584 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801539:	39 c6                	cmp    %eax,%esi
  80153b:	73 16                	jae    801553 <devfile_read+0x48>
  80153d:	68 54 23 80 00       	push   $0x802354
  801542:	68 5b 23 80 00       	push   $0x80235b
  801547:	6a 7c                	push   $0x7c
  801549:	68 70 23 80 00       	push   $0x802370
  80154e:	e8 d7 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  801553:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801558:	7e 16                	jle    801570 <devfile_read+0x65>
  80155a:	68 7b 23 80 00       	push   $0x80237b
  80155f:	68 5b 23 80 00       	push   $0x80235b
  801564:	6a 7d                	push   $0x7d
  801566:	68 70 23 80 00       	push   $0x802370
  80156b:	e8 ba eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	50                   	push   %eax
  801574:	68 00 50 80 00       	push   $0x805000
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	e8 b7 f3 ff ff       	call   800938 <memmove>
	return r;
  801581:	83 c4 10             	add    $0x10,%esp
}
  801584:	89 d8                	mov    %ebx,%eax
  801586:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5d                   	pop    %ebp
  80158c:	c3                   	ret    

0080158d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	53                   	push   %ebx
  801591:	83 ec 20             	sub    $0x20,%esp
  801594:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801597:	53                   	push   %ebx
  801598:	e8 d0 f1 ff ff       	call   80076d <strlen>
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a5:	7f 67                	jg     80160e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	e8 9a f8 ff ff       	call   800e4d <fd_alloc>
  8015b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 57                	js     801613 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	68 00 50 80 00       	push   $0x805000
  8015c5:	e8 dc f1 ff ff       	call   8007a6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015da:	e8 f6 fd ff ff       	call   8013d5 <fsipc>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	79 14                	jns    8015fc <open+0x6f>
		fd_close(fd, 0);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	6a 00                	push   $0x0
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 50 f9 ff ff       	call   800f45 <fd_close>
		return r;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	89 da                	mov    %ebx,%edx
  8015fa:	eb 17                	jmp    801613 <open+0x86>
	}

	return fd2num(fd);
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801602:	e8 1f f8 ff ff       	call   800e26 <fd2num>
  801607:	89 c2                	mov    %eax,%edx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 05                	jmp    801613 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801613:	89 d0                	mov    %edx,%eax
  801615:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801620:	ba 00 00 00 00       	mov    $0x0,%edx
  801625:	b8 08 00 00 00       	mov    $0x8,%eax
  80162a:	e8 a6 fd ff ff       	call   8013d5 <fsipc>
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801639:	83 ec 0c             	sub    $0xc,%esp
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 f2 f7 ff ff       	call   800e36 <fd2data>
  801644:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801646:	83 c4 08             	add    $0x8,%esp
  801649:	68 87 23 80 00       	push   $0x802387
  80164e:	53                   	push   %ebx
  80164f:	e8 52 f1 ff ff       	call   8007a6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801654:	8b 46 04             	mov    0x4(%esi),%eax
  801657:	2b 06                	sub    (%esi),%eax
  801659:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80165f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801666:	00 00 00 
	stat->st_dev = &devpipe;
  801669:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801670:	30 80 00 
	return 0;
}
  801673:	b8 00 00 00 00       	mov    $0x0,%eax
  801678:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	83 ec 0c             	sub    $0xc,%esp
  801686:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801689:	53                   	push   %ebx
  80168a:	6a 00                	push   $0x0
  80168c:	e8 9d f5 ff ff       	call   800c2e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801691:	89 1c 24             	mov    %ebx,(%esp)
  801694:	e8 9d f7 ff ff       	call   800e36 <fd2data>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	50                   	push   %eax
  80169d:	6a 00                	push   $0x0
  80169f:	e8 8a f5 ff ff       	call   800c2e <sys_page_unmap>
}
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	57                   	push   %edi
  8016ad:	56                   	push   %esi
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 1c             	sub    $0x1c,%esp
  8016b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8016c5:	e8 28 05 00 00       	call   801bf2 <pageref>
  8016ca:	89 c3                	mov    %eax,%ebx
  8016cc:	89 3c 24             	mov    %edi,(%esp)
  8016cf:	e8 1e 05 00 00       	call   801bf2 <pageref>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	39 c3                	cmp    %eax,%ebx
  8016d9:	0f 94 c1             	sete   %cl
  8016dc:	0f b6 c9             	movzbl %cl,%ecx
  8016df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016e2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016e8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016eb:	39 ce                	cmp    %ecx,%esi
  8016ed:	74 1b                	je     80170a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016ef:	39 c3                	cmp    %eax,%ebx
  8016f1:	75 c4                	jne    8016b7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f3:	8b 42 58             	mov    0x58(%edx),%eax
  8016f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f9:	50                   	push   %eax
  8016fa:	56                   	push   %esi
  8016fb:	68 8e 23 80 00       	push   $0x80238e
  801700:	e8 fe ea ff ff       	call   800203 <cprintf>
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	eb ad                	jmp    8016b7 <_pipeisclosed+0xe>
	}
}
  80170a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80170d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801710:	5b                   	pop    %ebx
  801711:	5e                   	pop    %esi
  801712:	5f                   	pop    %edi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	57                   	push   %edi
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
  80171b:	83 ec 28             	sub    $0x28,%esp
  80171e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801721:	56                   	push   %esi
  801722:	e8 0f f7 ff ff       	call   800e36 <fd2data>
  801727:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	bf 00 00 00 00       	mov    $0x0,%edi
  801731:	eb 4b                	jmp    80177e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801733:	89 da                	mov    %ebx,%edx
  801735:	89 f0                	mov    %esi,%eax
  801737:	e8 6d ff ff ff       	call   8016a9 <_pipeisclosed>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	75 48                	jne    801788 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801740:	e8 45 f4 ff ff       	call   800b8a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801745:	8b 43 04             	mov    0x4(%ebx),%eax
  801748:	8b 0b                	mov    (%ebx),%ecx
  80174a:	8d 51 20             	lea    0x20(%ecx),%edx
  80174d:	39 d0                	cmp    %edx,%eax
  80174f:	73 e2                	jae    801733 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801754:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801758:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80175b:	89 c2                	mov    %eax,%edx
  80175d:	c1 fa 1f             	sar    $0x1f,%edx
  801760:	89 d1                	mov    %edx,%ecx
  801762:	c1 e9 1b             	shr    $0x1b,%ecx
  801765:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801768:	83 e2 1f             	and    $0x1f,%edx
  80176b:	29 ca                	sub    %ecx,%edx
  80176d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801771:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801775:	83 c0 01             	add    $0x1,%eax
  801778:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177b:	83 c7 01             	add    $0x1,%edi
  80177e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801781:	75 c2                	jne    801745 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801783:	8b 45 10             	mov    0x10(%ebp),%eax
  801786:	eb 05                	jmp    80178d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80178d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5f                   	pop    %edi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	57                   	push   %edi
  801799:	56                   	push   %esi
  80179a:	53                   	push   %ebx
  80179b:	83 ec 18             	sub    $0x18,%esp
  80179e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017a1:	57                   	push   %edi
  8017a2:	e8 8f f6 ff ff       	call   800e36 <fd2data>
  8017a7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b1:	eb 3d                	jmp    8017f0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017b3:	85 db                	test   %ebx,%ebx
  8017b5:	74 04                	je     8017bb <devpipe_read+0x26>
				return i;
  8017b7:	89 d8                	mov    %ebx,%eax
  8017b9:	eb 44                	jmp    8017ff <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017bb:	89 f2                	mov    %esi,%edx
  8017bd:	89 f8                	mov    %edi,%eax
  8017bf:	e8 e5 fe ff ff       	call   8016a9 <_pipeisclosed>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	75 32                	jne    8017fa <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017c8:	e8 bd f3 ff ff       	call   800b8a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017cd:	8b 06                	mov    (%esi),%eax
  8017cf:	3b 46 04             	cmp    0x4(%esi),%eax
  8017d2:	74 df                	je     8017b3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017d4:	99                   	cltd   
  8017d5:	c1 ea 1b             	shr    $0x1b,%edx
  8017d8:	01 d0                	add    %edx,%eax
  8017da:	83 e0 1f             	and    $0x1f,%eax
  8017dd:	29 d0                	sub    %edx,%eax
  8017df:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017ea:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ed:	83 c3 01             	add    $0x1,%ebx
  8017f0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017f3:	75 d8                	jne    8017cd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f8:	eb 05                	jmp    8017ff <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801802:	5b                   	pop    %ebx
  801803:	5e                   	pop    %esi
  801804:	5f                   	pop    %edi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80180f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801812:	50                   	push   %eax
  801813:	e8 35 f6 ff ff       	call   800e4d <fd_alloc>
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	85 c0                	test   %eax,%eax
  80181f:	0f 88 2c 01 00 00    	js     801951 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	68 07 04 00 00       	push   $0x407
  80182d:	ff 75 f4             	pushl  -0xc(%ebp)
  801830:	6a 00                	push   $0x0
  801832:	e8 72 f3 ff ff       	call   800ba9 <sys_page_alloc>
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	85 c0                	test   %eax,%eax
  80183e:	0f 88 0d 01 00 00    	js     801951 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801844:	83 ec 0c             	sub    $0xc,%esp
  801847:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	e8 fd f5 ff ff       	call   800e4d <fd_alloc>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	0f 88 e2 00 00 00    	js     80193f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185d:	83 ec 04             	sub    $0x4,%esp
  801860:	68 07 04 00 00       	push   $0x407
  801865:	ff 75 f0             	pushl  -0x10(%ebp)
  801868:	6a 00                	push   $0x0
  80186a:	e8 3a f3 ff ff       	call   800ba9 <sys_page_alloc>
  80186f:	89 c3                	mov    %eax,%ebx
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	85 c0                	test   %eax,%eax
  801876:	0f 88 c3 00 00 00    	js     80193f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	ff 75 f4             	pushl  -0xc(%ebp)
  801882:	e8 af f5 ff ff       	call   800e36 <fd2data>
  801887:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801889:	83 c4 0c             	add    $0xc,%esp
  80188c:	68 07 04 00 00       	push   $0x407
  801891:	50                   	push   %eax
  801892:	6a 00                	push   $0x0
  801894:	e8 10 f3 ff ff       	call   800ba9 <sys_page_alloc>
  801899:	89 c3                	mov    %eax,%ebx
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	0f 88 89 00 00 00    	js     80192f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ac:	e8 85 f5 ff ff       	call   800e36 <fd2data>
  8018b1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018b8:	50                   	push   %eax
  8018b9:	6a 00                	push   $0x0
  8018bb:	56                   	push   %esi
  8018bc:	6a 00                	push   $0x0
  8018be:	e8 29 f3 ff ff       	call   800bec <sys_page_map>
  8018c3:	89 c3                	mov    %eax,%ebx
  8018c5:	83 c4 20             	add    $0x20,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 55                	js     801921 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018cc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018da:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018e1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ea:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fc:	e8 25 f5 ff ff       	call   800e26 <fd2num>
  801901:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801904:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801906:	83 c4 04             	add    $0x4,%esp
  801909:	ff 75 f0             	pushl  -0x10(%ebp)
  80190c:	e8 15 f5 ff ff       	call   800e26 <fd2num>
  801911:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801914:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	ba 00 00 00 00       	mov    $0x0,%edx
  80191f:	eb 30                	jmp    801951 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801921:	83 ec 08             	sub    $0x8,%esp
  801924:	56                   	push   %esi
  801925:	6a 00                	push   $0x0
  801927:	e8 02 f3 ff ff       	call   800c2e <sys_page_unmap>
  80192c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	ff 75 f0             	pushl  -0x10(%ebp)
  801935:	6a 00                	push   $0x0
  801937:	e8 f2 f2 ff ff       	call   800c2e <sys_page_unmap>
  80193c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	ff 75 f4             	pushl  -0xc(%ebp)
  801945:	6a 00                	push   $0x0
  801947:	e8 e2 f2 ff ff       	call   800c2e <sys_page_unmap>
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801951:	89 d0                	mov    %edx,%eax
  801953:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801960:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801963:	50                   	push   %eax
  801964:	ff 75 08             	pushl  0x8(%ebp)
  801967:	e8 30 f5 ff ff       	call   800e9c <fd_lookup>
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 18                	js     80198b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	ff 75 f4             	pushl  -0xc(%ebp)
  801979:	e8 b8 f4 ff ff       	call   800e36 <fd2data>
	return _pipeisclosed(fd, p);
  80197e:	89 c2                	mov    %eax,%edx
  801980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801983:	e8 21 fd ff ff       	call   8016a9 <_pipeisclosed>
  801988:	83 c4 10             	add    $0x10,%esp
}
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801990:	b8 00 00 00 00       	mov    $0x0,%eax
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    

00801997 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80199d:	68 a6 23 80 00       	push   $0x8023a6
  8019a2:	ff 75 0c             	pushl  0xc(%ebp)
  8019a5:	e8 fc ed ff ff       	call   8007a6 <strcpy>
	return 0;
}
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	57                   	push   %edi
  8019b5:	56                   	push   %esi
  8019b6:	53                   	push   %ebx
  8019b7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019bd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c8:	eb 2d                	jmp    8019f7 <devcons_write+0x46>
		m = n - tot;
  8019ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019cd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019cf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019d2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019d7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019da:	83 ec 04             	sub    $0x4,%esp
  8019dd:	53                   	push   %ebx
  8019de:	03 45 0c             	add    0xc(%ebp),%eax
  8019e1:	50                   	push   %eax
  8019e2:	57                   	push   %edi
  8019e3:	e8 50 ef ff ff       	call   800938 <memmove>
		sys_cputs(buf, m);
  8019e8:	83 c4 08             	add    $0x8,%esp
  8019eb:	53                   	push   %ebx
  8019ec:	57                   	push   %edi
  8019ed:	e8 fb f0 ff ff       	call   800aed <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f2:	01 de                	add    %ebx,%esi
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	89 f0                	mov    %esi,%eax
  8019f9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019fc:	72 cc                	jb     8019ca <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5f                   	pop    %edi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a15:	74 2a                	je     801a41 <devcons_read+0x3b>
  801a17:	eb 05                	jmp    801a1e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a19:	e8 6c f1 ff ff       	call   800b8a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a1e:	e8 e8 f0 ff ff       	call   800b0b <sys_cgetc>
  801a23:	85 c0                	test   %eax,%eax
  801a25:	74 f2                	je     801a19 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 16                	js     801a41 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a2b:	83 f8 04             	cmp    $0x4,%eax
  801a2e:	74 0c                	je     801a3c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a30:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a33:	88 02                	mov    %al,(%edx)
	return 1;
  801a35:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3a:	eb 05                	jmp    801a41 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a4f:	6a 01                	push   $0x1
  801a51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a54:	50                   	push   %eax
  801a55:	e8 93 f0 ff ff       	call   800aed <sys_cputs>
}
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <getchar>:

int
getchar(void)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a65:	6a 01                	push   $0x1
  801a67:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6a:	50                   	push   %eax
  801a6b:	6a 00                	push   $0x0
  801a6d:	e8 90 f6 ff ff       	call   801102 <read>
	if (r < 0)
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 0f                	js     801a88 <getchar+0x29>
		return r;
	if (r < 1)
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	7e 06                	jle    801a83 <getchar+0x24>
		return -E_EOF;
	return c;
  801a7d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a81:	eb 05                	jmp    801a88 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a83:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a93:	50                   	push   %eax
  801a94:	ff 75 08             	pushl  0x8(%ebp)
  801a97:	e8 00 f4 ff ff       	call   800e9c <fd_lookup>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 11                	js     801ab4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aac:	39 10                	cmp    %edx,(%eax)
  801aae:	0f 94 c0             	sete   %al
  801ab1:	0f b6 c0             	movzbl %al,%eax
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <opencons>:

int
opencons(void)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801abc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abf:	50                   	push   %eax
  801ac0:	e8 88 f3 ff ff       	call   800e4d <fd_alloc>
  801ac5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 3e                	js     801b0c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ace:	83 ec 04             	sub    $0x4,%esp
  801ad1:	68 07 04 00 00       	push   $0x407
  801ad6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad9:	6a 00                	push   $0x0
  801adb:	e8 c9 f0 ff ff       	call   800ba9 <sys_page_alloc>
  801ae0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 23                	js     801b0c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ae9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	50                   	push   %eax
  801b02:	e8 1f f3 ff ff       	call   800e26 <fd2num>
  801b07:	89 c2                	mov    %eax,%edx
  801b09:	83 c4 10             	add    $0x10,%esp
}
  801b0c:	89 d0                	mov    %edx,%eax
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	8b 75 08             	mov    0x8(%ebp),%esi
  801b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b25:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	50                   	push   %eax
  801b2c:	e8 28 f2 ff ff       	call   800d59 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	75 10                	jne    801b48 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801b38:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3d:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801b40:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801b43:	8b 40 70             	mov    0x70(%eax),%eax
  801b46:	eb 0a                	jmp    801b52 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801b48:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801b52:	85 f6                	test   %esi,%esi
  801b54:	74 02                	je     801b58 <ipc_recv+0x48>
  801b56:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801b58:	85 db                	test   %ebx,%ebx
  801b5a:	74 02                	je     801b5e <ipc_recv+0x4e>
  801b5c:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801b5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	57                   	push   %edi
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b71:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801b77:	85 db                	test   %ebx,%ebx
  801b79:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b7e:	0f 44 d8             	cmove  %eax,%ebx
  801b81:	eb 1c                	jmp    801b9f <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801b83:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b86:	74 12                	je     801b9a <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801b88:	50                   	push   %eax
  801b89:	68 b2 23 80 00       	push   $0x8023b2
  801b8e:	6a 40                	push   $0x40
  801b90:	68 c4 23 80 00       	push   $0x8023c4
  801b95:	e8 90 e5 ff ff       	call   80012a <_panic>
        sys_yield();
  801b9a:	e8 eb ef ff ff       	call   800b8a <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b9f:	ff 75 14             	pushl  0x14(%ebp)
  801ba2:	53                   	push   %ebx
  801ba3:	56                   	push   %esi
  801ba4:	57                   	push   %edi
  801ba5:	e8 8c f1 ff ff       	call   800d36 <sys_ipc_try_send>
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	85 c0                	test   %eax,%eax
  801baf:	75 d2                	jne    801b83 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5f                   	pop    %edi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bbf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bc4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bc7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bcd:	8b 52 50             	mov    0x50(%edx),%edx
  801bd0:	39 ca                	cmp    %ecx,%edx
  801bd2:	75 0d                	jne    801be1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bd4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bd7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bdc:	8b 40 48             	mov    0x48(%eax),%eax
  801bdf:	eb 0f                	jmp    801bf0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801be1:	83 c0 01             	add    $0x1,%eax
  801be4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801be9:	75 d9                	jne    801bc4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf8:	89 d0                	mov    %edx,%eax
  801bfa:	c1 e8 16             	shr    $0x16,%eax
  801bfd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c04:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c09:	f6 c1 01             	test   $0x1,%cl
  801c0c:	74 1d                	je     801c2b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c0e:	c1 ea 0c             	shr    $0xc,%edx
  801c11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c18:	f6 c2 01             	test   $0x1,%dl
  801c1b:	74 0e                	je     801c2b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c1d:	c1 ea 0c             	shr    $0xc,%edx
  801c20:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c27:	ef 
  801c28:	0f b7 c0             	movzwl %ax,%eax
}
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    
  801c2d:	66 90                	xchg   %ax,%ax
  801c2f:	90                   	nop

00801c30 <__udivdi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 f6                	test   %esi,%esi
  801c49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4d:	89 ca                	mov    %ecx,%edx
  801c4f:	89 f8                	mov    %edi,%eax
  801c51:	75 3d                	jne    801c90 <__udivdi3+0x60>
  801c53:	39 cf                	cmp    %ecx,%edi
  801c55:	0f 87 c5 00 00 00    	ja     801d20 <__udivdi3+0xf0>
  801c5b:	85 ff                	test   %edi,%edi
  801c5d:	89 fd                	mov    %edi,%ebp
  801c5f:	75 0b                	jne    801c6c <__udivdi3+0x3c>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	31 d2                	xor    %edx,%edx
  801c68:	f7 f7                	div    %edi
  801c6a:	89 c5                	mov    %eax,%ebp
  801c6c:	89 c8                	mov    %ecx,%eax
  801c6e:	31 d2                	xor    %edx,%edx
  801c70:	f7 f5                	div    %ebp
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	89 cf                	mov    %ecx,%edi
  801c78:	f7 f5                	div    %ebp
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	39 ce                	cmp    %ecx,%esi
  801c92:	77 74                	ja     801d08 <__udivdi3+0xd8>
  801c94:	0f bd fe             	bsr    %esi,%edi
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	0f 84 98 00 00 00    	je     801d38 <__udivdi3+0x108>
  801ca0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	89 c5                	mov    %eax,%ebp
  801ca9:	29 fb                	sub    %edi,%ebx
  801cab:	d3 e6                	shl    %cl,%esi
  801cad:	89 d9                	mov    %ebx,%ecx
  801caf:	d3 ed                	shr    %cl,%ebp
  801cb1:	89 f9                	mov    %edi,%ecx
  801cb3:	d3 e0                	shl    %cl,%eax
  801cb5:	09 ee                	or     %ebp,%esi
  801cb7:	89 d9                	mov    %ebx,%ecx
  801cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cbd:	89 d5                	mov    %edx,%ebp
  801cbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cc3:	d3 ed                	shr    %cl,%ebp
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e2                	shl    %cl,%edx
  801cc9:	89 d9                	mov    %ebx,%ecx
  801ccb:	d3 e8                	shr    %cl,%eax
  801ccd:	09 c2                	or     %eax,%edx
  801ccf:	89 d0                	mov    %edx,%eax
  801cd1:	89 ea                	mov    %ebp,%edx
  801cd3:	f7 f6                	div    %esi
  801cd5:	89 d5                	mov    %edx,%ebp
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	f7 64 24 0c          	mull   0xc(%esp)
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	72 10                	jb     801cf1 <__udivdi3+0xc1>
  801ce1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e6                	shl    %cl,%esi
  801ce9:	39 c6                	cmp    %eax,%esi
  801ceb:	73 07                	jae    801cf4 <__udivdi3+0xc4>
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	75 03                	jne    801cf4 <__udivdi3+0xc4>
  801cf1:	83 eb 01             	sub    $0x1,%ebx
  801cf4:	31 ff                	xor    %edi,%edi
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	89 fa                	mov    %edi,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	31 ff                	xor    %edi,%edi
  801d0a:	31 db                	xor    %ebx,%ebx
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
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	f7 f7                	div    %edi
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 1c             	add    $0x1c,%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
  801d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d38:	39 ce                	cmp    %ecx,%esi
  801d3a:	72 0c                	jb     801d48 <__udivdi3+0x118>
  801d3c:	31 db                	xor    %ebx,%ebx
  801d3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d42:	0f 87 34 ff ff ff    	ja     801c7c <__udivdi3+0x4c>
  801d48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d4d:	e9 2a ff ff ff       	jmp    801c7c <__udivdi3+0x4c>
  801d52:	66 90                	xchg   %ax,%ax
  801d54:	66 90                	xchg   %ax,%ax
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d77:	85 d2                	test   %edx,%edx
  801d79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d81:	89 f3                	mov    %esi,%ebx
  801d83:	89 3c 24             	mov    %edi,(%esp)
  801d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d8a:	75 1c                	jne    801da8 <__umoddi3+0x48>
  801d8c:	39 f7                	cmp    %esi,%edi
  801d8e:	76 50                	jbe    801de0 <__umoddi3+0x80>
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	f7 f7                	div    %edi
  801d96:	89 d0                	mov    %edx,%eax
  801d98:	31 d2                	xor    %edx,%edx
  801d9a:	83 c4 1c             	add    $0x1c,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
  801da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801da8:	39 f2                	cmp    %esi,%edx
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	77 52                	ja     801e00 <__umoddi3+0xa0>
  801dae:	0f bd ea             	bsr    %edx,%ebp
  801db1:	83 f5 1f             	xor    $0x1f,%ebp
  801db4:	75 5a                	jne    801e10 <__umoddi3+0xb0>
  801db6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	39 0c 24             	cmp    %ecx,(%esp)
  801dc3:	0f 86 d7 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dd1:	83 c4 1c             	add    $0x1c,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	85 ff                	test   %edi,%edi
  801de2:	89 fd                	mov    %edi,%ebp
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 c8                	mov    %ecx,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	eb 99                	jmp    801d98 <__umoddi3+0x38>
  801dff:	90                   	nop
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	83 c4 1c             	add    $0x1c,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    
  801e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e10:	8b 34 24             	mov    (%esp),%esi
  801e13:	bf 20 00 00 00       	mov    $0x20,%edi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	29 ef                	sub    %ebp,%edi
  801e1c:	d3 e0                	shl    %cl,%eax
  801e1e:	89 f9                	mov    %edi,%ecx
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	d3 ea                	shr    %cl,%edx
  801e24:	89 e9                	mov    %ebp,%ecx
  801e26:	09 c2                	or     %eax,%edx
  801e28:	89 d8                	mov    %ebx,%eax
  801e2a:	89 14 24             	mov    %edx,(%esp)
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	d3 e2                	shl    %cl,%edx
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	89 c6                	mov    %eax,%esi
  801e41:	d3 e3                	shl    %cl,%ebx
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 d0                	mov    %edx,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	09 d8                	or     %ebx,%eax
  801e4d:	89 d3                	mov    %edx,%ebx
  801e4f:	89 f2                	mov    %esi,%edx
  801e51:	f7 34 24             	divl   (%esp)
  801e54:	89 d6                	mov    %edx,%esi
  801e56:	d3 e3                	shl    %cl,%ebx
  801e58:	f7 64 24 04          	mull   0x4(%esp)
  801e5c:	39 d6                	cmp    %edx,%esi
  801e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e62:	89 d1                	mov    %edx,%ecx
  801e64:	89 c3                	mov    %eax,%ebx
  801e66:	72 08                	jb     801e70 <__umoddi3+0x110>
  801e68:	75 11                	jne    801e7b <__umoddi3+0x11b>
  801e6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e6e:	73 0b                	jae    801e7b <__umoddi3+0x11b>
  801e70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e74:	1b 14 24             	sbb    (%esp),%edx
  801e77:	89 d1                	mov    %edx,%ecx
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e7f:	29 da                	sub    %ebx,%edx
  801e81:	19 ce                	sbb    %ecx,%esi
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	89 f0                	mov    %esi,%eax
  801e87:	d3 e0                	shl    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	d3 ea                	shr    %cl,%edx
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	d3 ee                	shr    %cl,%esi
  801e91:	09 d0                	or     %edx,%eax
  801e93:	89 f2                	mov    %esi,%edx
  801e95:	83 c4 1c             	add    $0x1c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 f9                	sub    %edi,%ecx
  801ea2:	19 d6                	sbb    %edx,%esi
  801ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eac:	e9 18 ff ff ff       	jmp    801dc9 <__umoddi3+0x69>
