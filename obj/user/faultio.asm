
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 e0 1d 80 00       	push   $0x801de0
  800048:	e8 13 01 00 00       	call   800160 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 ee 1d 80 00       	push   $0x801dee
  800063:	e8 f8 00 00 00       	call   800160 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800078:	e8 4b 0a 00 00       	call   800ac8 <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x2d>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b9:	e8 04 0e 00 00       	call   800ec2 <close_all>
	sys_env_destroy(0);
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	6a 00                	push   $0x0
  8000c3:	e8 bf 09 00 00       	call   800a87 <sys_env_destroy>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d7:	8b 13                	mov    (%ebx),%edx
  8000d9:	8d 42 01             	lea    0x1(%edx),%eax
  8000dc:	89 03                	mov    %eax,(%ebx)
  8000de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ea:	75 1a                	jne    800106 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	68 ff 00 00 00       	push   $0xff
  8000f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f7:	50                   	push   %eax
  8000f8:	e8 4d 09 00 00       	call   800a4a <sys_cputs>
		b->idx = 0;
  8000fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800103:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800106:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 cd 00 80 00       	push   $0x8000cd
  80013e:	e8 54 01 00 00       	call   800297 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 f2 08 00 00       	call   800a4a <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 1c             	sub    $0x1c,%esp
  80017d:	89 c7                	mov    %eax,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800198:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019b:	39 d3                	cmp    %edx,%ebx
  80019d:	72 05                	jb     8001a4 <printnum+0x30>
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 45                	ja     8001e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 18             	pushl  0x18(%ebp)
  8001aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c3:	e8 88 19 00 00       	call   801b50 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	89 f8                	mov    %edi,%eax
  8001d1:	e8 9e ff ff ff       	call   800174 <printnum>
  8001d6:	83 c4 20             	add    $0x20,%esp
  8001d9:	eb 18                	jmp    8001f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff d7                	call   *%edi
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 03                	jmp    8001ec <printnum+0x78>
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ec:	83 eb 01             	sub    $0x1,%ebx
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7f e8                	jg     8001db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	83 ec 04             	sub    $0x4,%esp
  8001fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800200:	ff 75 dc             	pushl  -0x24(%ebp)
  800203:	ff 75 d8             	pushl  -0x28(%ebp)
  800206:	e8 75 1a 00 00       	call   801c80 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 12 1e 80 00 	movsbl 0x801e12(%eax),%eax
  800215:	50                   	push   %eax
  800216:	ff d7                	call   *%edi
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800226:	83 fa 01             	cmp    $0x1,%edx
  800229:	7e 0e                	jle    800239 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	8b 52 04             	mov    0x4(%edx),%edx
  800237:	eb 22                	jmp    80025b <getuint+0x38>
	else if (lflag)
  800239:	85 d2                	test   %edx,%edx
  80023b:	74 10                	je     80024d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80023d:	8b 10                	mov    (%eax),%edx
  80023f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800242:	89 08                	mov    %ecx,(%eax)
  800244:	8b 02                	mov    (%edx),%eax
  800246:	ba 00 00 00 00       	mov    $0x0,%edx
  80024b:	eb 0e                	jmp    80025b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80024d:	8b 10                	mov    (%eax),%edx
  80024f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 02                	mov    (%edx),%eax
  800256:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800263:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800267:	8b 10                	mov    (%eax),%edx
  800269:	3b 50 04             	cmp    0x4(%eax),%edx
  80026c:	73 0a                	jae    800278 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	88 02                	mov    %al,(%edx)
}
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800280:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800283:	50                   	push   %eax
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	e8 05 00 00 00       	call   800297 <vprintfmt>
	va_end(ap);
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
  8002a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a9:	eb 12                	jmp    8002bd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	0f 84 a7 03 00 00    	je     80065a <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	53                   	push   %ebx
  8002b7:	50                   	push   %eax
  8002b8:	ff d6                	call   *%esi
  8002ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bd:	83 c7 01             	add    $0x1,%edi
  8002c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c4:	83 f8 25             	cmp    $0x25,%eax
  8002c7:	75 e2                	jne    8002ab <vprintfmt+0x14>
  8002c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8002db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e2:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8002e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ee:	eb 07                	jmp    8002f7 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8d 47 01             	lea    0x1(%edi),%eax
  8002fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fd:	0f b6 07             	movzbl (%edi),%eax
  800300:	0f b6 d0             	movzbl %al,%edx
  800303:	83 e8 23             	sub    $0x23,%eax
  800306:	3c 55                	cmp    $0x55,%al
  800308:	0f 87 31 03 00 00    	ja     80063f <vprintfmt+0x3a8>
  80030e:	0f b6 c0             	movzbl %al,%eax
  800311:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
  800318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031f:	eb d6                	jmp    8002f7 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800324:	b8 00 00 00 00       	mov    $0x0,%eax
  800329:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80032c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800333:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800336:	8d 72 d0             	lea    -0x30(%edx),%esi
  800339:	83 fe 09             	cmp    $0x9,%esi
  80033c:	77 34                	ja     800372 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800341:	eb e9                	jmp    80032c <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800343:	8b 45 14             	mov    0x14(%ebp),%eax
  800346:	8d 50 04             	lea    0x4(%eax),%edx
  800349:	89 55 14             	mov    %edx,0x14(%ebp)
  80034c:	8b 00                	mov    (%eax),%eax
  80034e:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800354:	eb 22                	jmp    800378 <vprintfmt+0xe1>
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	85 c0                	test   %eax,%eax
  80035b:	0f 48 c1             	cmovs  %ecx,%eax
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800364:	eb 91                	jmp    8002f7 <vprintfmt+0x60>
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800369:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800370:	eb 85                	jmp    8002f7 <vprintfmt+0x60>
  800372:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800375:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800378:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037c:	0f 89 75 ff ff ff    	jns    8002f7 <vprintfmt+0x60>
				width = precision, precision = -1;
  800382:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800385:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800388:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80038f:	e9 63 ff ff ff       	jmp    8002f7 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800394:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039b:	e9 57 ff ff ff       	jmp    8002f7 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 50 04             	lea    0x4(%eax),%edx
  8003a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	53                   	push   %ebx
  8003ad:	ff 30                	pushl  (%eax)
  8003af:	ff d6                	call   *%esi
			break;
  8003b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b7:	e9 01 ff ff ff       	jmp    8002bd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 50 04             	lea    0x4(%eax),%edx
  8003c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c5:	8b 00                	mov    (%eax),%eax
  8003c7:	99                   	cltd   
  8003c8:	31 d0                	xor    %edx,%eax
  8003ca:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cc:	83 f8 0f             	cmp    $0xf,%eax
  8003cf:	7f 0b                	jg     8003dc <vprintfmt+0x145>
  8003d1:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  8003d8:	85 d2                	test   %edx,%edx
  8003da:	75 18                	jne    8003f4 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8003dc:	50                   	push   %eax
  8003dd:	68 2a 1e 80 00       	push   $0x801e2a
  8003e2:	53                   	push   %ebx
  8003e3:	56                   	push   %esi
  8003e4:	e8 91 fe ff ff       	call   80027a <printfmt>
  8003e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ef:	e9 c9 fe ff ff       	jmp    8002bd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f4:	52                   	push   %edx
  8003f5:	68 f1 21 80 00       	push   $0x8021f1
  8003fa:	53                   	push   %ebx
  8003fb:	56                   	push   %esi
  8003fc:	e8 79 fe ff ff       	call   80027a <printfmt>
  800401:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	e9 b1 fe ff ff       	jmp    8002bd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800417:	85 ff                	test   %edi,%edi
  800419:	b8 23 1e 80 00       	mov    $0x801e23,%eax
  80041e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800421:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800425:	0f 8e 94 00 00 00    	jle    8004bf <vprintfmt+0x228>
  80042b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042f:	0f 84 98 00 00 00    	je     8004cd <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	ff 75 cc             	pushl  -0x34(%ebp)
  80043b:	57                   	push   %edi
  80043c:	e8 a1 02 00 00       	call   8006e2 <strnlen>
  800441:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800444:	29 c1                	sub    %eax,%ecx
  800446:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800449:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800453:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800456:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800458:	eb 0f                	jmp    800469 <vprintfmt+0x1d2>
					putch(padc, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 75 e0             	pushl  -0x20(%ebp)
  800461:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	83 ef 01             	sub    $0x1,%edi
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	85 ff                	test   %edi,%edi
  80046b:	7f ed                	jg     80045a <vprintfmt+0x1c3>
  80046d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800470:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800473:	85 c9                	test   %ecx,%ecx
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	0f 49 c1             	cmovns %ecx,%eax
  80047d:	29 c1                	sub    %eax,%ecx
  80047f:	89 75 08             	mov    %esi,0x8(%ebp)
  800482:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800488:	89 cb                	mov    %ecx,%ebx
  80048a:	eb 4d                	jmp    8004d9 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800490:	74 1b                	je     8004ad <vprintfmt+0x216>
  800492:	0f be c0             	movsbl %al,%eax
  800495:	83 e8 20             	sub    $0x20,%eax
  800498:	83 f8 5e             	cmp    $0x5e,%eax
  80049b:	76 10                	jbe    8004ad <vprintfmt+0x216>
					putch('?', putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	6a 3f                	push   $0x3f
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	eb 0d                	jmp    8004ba <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	52                   	push   %edx
  8004b4:	ff 55 08             	call   *0x8(%ebp)
  8004b7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ba:	83 eb 01             	sub    $0x1,%ebx
  8004bd:	eb 1a                	jmp    8004d9 <vprintfmt+0x242>
  8004bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c2:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cb:	eb 0c                	jmp    8004d9 <vprintfmt+0x242>
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d9:	83 c7 01             	add    $0x1,%edi
  8004dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e0:	0f be d0             	movsbl %al,%edx
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	74 23                	je     80050a <vprintfmt+0x273>
  8004e7:	85 f6                	test   %esi,%esi
  8004e9:	78 a1                	js     80048c <vprintfmt+0x1f5>
  8004eb:	83 ee 01             	sub    $0x1,%esi
  8004ee:	79 9c                	jns    80048c <vprintfmt+0x1f5>
  8004f0:	89 df                	mov    %ebx,%edi
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	eb 18                	jmp    800512 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	6a 20                	push   $0x20
  800500:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800502:	83 ef 01             	sub    $0x1,%edi
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 08                	jmp    800512 <vprintfmt+0x27b>
  80050a:	89 df                	mov    %ebx,%edi
  80050c:	8b 75 08             	mov    0x8(%ebp),%esi
  80050f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800512:	85 ff                	test   %edi,%edi
  800514:	7f e4                	jg     8004fa <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800519:	e9 9f fd ff ff       	jmp    8002bd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051e:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800522:	7e 16                	jle    80053a <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 08             	lea    0x8(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 50 04             	mov    0x4(%eax),%edx
  800530:	8b 00                	mov    (%eax),%eax
  800532:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800535:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800538:	eb 34                	jmp    80056e <vprintfmt+0x2d7>
	else if (lflag)
  80053a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80053e:	74 18                	je     800558 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054e:	89 c1                	mov    %eax,%ecx
  800550:	c1 f9 1f             	sar    $0x1f,%ecx
  800553:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800556:	eb 16                	jmp    80056e <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800566:	89 c1                	mov    %eax,%ecx
  800568:	c1 f9 1f             	sar    $0x1f,%ecx
  80056b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80056e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800571:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800574:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800579:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057d:	0f 89 88 00 00 00    	jns    80060b <vprintfmt+0x374>
				putch('-', putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	6a 2d                	push   $0x2d
  800589:	ff d6                	call   *%esi
				num = -(long long) num;
  80058b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800591:	f7 d8                	neg    %eax
  800593:	83 d2 00             	adc    $0x0,%edx
  800596:	f7 da                	neg    %edx
  800598:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80059b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a0:	eb 69                	jmp    80060b <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a2:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a8:	e8 76 fc ff ff       	call   800223 <getuint>
			base = 10;
  8005ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b2:	eb 57                	jmp    80060b <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	6a 30                	push   $0x30
  8005ba:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8005bc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c2:	e8 5c fc ff ff       	call   800223 <getuint>
			base = 8;
			goto number;
  8005c7:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005ca:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005cf:	eb 3a                	jmp    80060b <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 30                	push   $0x30
  8005d7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d9:	83 c4 08             	add    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 78                	push   $0x78
  8005df:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 04             	lea    0x4(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f9:	eb 10                	jmp    80060b <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 1d fc ff ff       	call   800223 <getuint>
			base = 16;
  800606:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800612:	57                   	push   %edi
  800613:	ff 75 e0             	pushl  -0x20(%ebp)
  800616:	51                   	push   %ecx
  800617:	52                   	push   %edx
  800618:	50                   	push   %eax
  800619:	89 da                	mov    %ebx,%edx
  80061b:	89 f0                	mov    %esi,%eax
  80061d:	e8 52 fb ff ff       	call   800174 <printnum>
			break;
  800622:	83 c4 20             	add    $0x20,%esp
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800628:	e9 90 fc ff ff       	jmp    8002bd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	52                   	push   %edx
  800632:	ff d6                	call   *%esi
			break;
  800634:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80063a:	e9 7e fc ff ff       	jmp    8002bd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 25                	push   $0x25
  800645:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	eb 03                	jmp    80064f <vprintfmt+0x3b8>
  80064c:	83 ef 01             	sub    $0x1,%edi
  80064f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800653:	75 f7                	jne    80064c <vprintfmt+0x3b5>
  800655:	e9 63 fc ff ff       	jmp    8002bd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80065a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065d:	5b                   	pop    %ebx
  80065e:	5e                   	pop    %esi
  80065f:	5f                   	pop    %edi
  800660:	5d                   	pop    %ebp
  800661:	c3                   	ret    

00800662 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	83 ec 18             	sub    $0x18,%esp
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800671:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800675:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067f:	85 c0                	test   %eax,%eax
  800681:	74 26                	je     8006a9 <vsnprintf+0x47>
  800683:	85 d2                	test   %edx,%edx
  800685:	7e 22                	jle    8006a9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800687:	ff 75 14             	pushl  0x14(%ebp)
  80068a:	ff 75 10             	pushl  0x10(%ebp)
  80068d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	68 5d 02 80 00       	push   $0x80025d
  800696:	e8 fc fb ff ff       	call   800297 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	eb 05                	jmp    8006ae <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    

008006b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b9:	50                   	push   %eax
  8006ba:	ff 75 10             	pushl  0x10(%ebp)
  8006bd:	ff 75 0c             	pushl  0xc(%ebp)
  8006c0:	ff 75 08             	pushl  0x8(%ebp)
  8006c3:	e8 9a ff ff ff       	call   800662 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d5:	eb 03                	jmp    8006da <strlen+0x10>
		n++;
  8006d7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006de:	75 f7                	jne    8006d7 <strlen+0xd>
		n++;
	return n;
}
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f0:	eb 03                	jmp    8006f5 <strnlen+0x13>
		n++;
  8006f2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f5:	39 c2                	cmp    %eax,%edx
  8006f7:	74 08                	je     800701 <strnlen+0x1f>
  8006f9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006fd:	75 f3                	jne    8006f2 <strnlen+0x10>
  8006ff:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	53                   	push   %ebx
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070d:	89 c2                	mov    %eax,%edx
  80070f:	83 c2 01             	add    $0x1,%edx
  800712:	83 c1 01             	add    $0x1,%ecx
  800715:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800719:	88 5a ff             	mov    %bl,-0x1(%edx)
  80071c:	84 db                	test   %bl,%bl
  80071e:	75 ef                	jne    80070f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800720:	5b                   	pop    %ebx
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072a:	53                   	push   %ebx
  80072b:	e8 9a ff ff ff       	call   8006ca <strlen>
  800730:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	01 d8                	add    %ebx,%eax
  800738:	50                   	push   %eax
  800739:	e8 c5 ff ff ff       	call   800703 <strcpy>
	return dst;
}
  80073e:	89 d8                	mov    %ebx,%eax
  800740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
  80074a:	8b 75 08             	mov    0x8(%ebp),%esi
  80074d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800750:	89 f3                	mov    %esi,%ebx
  800752:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800755:	89 f2                	mov    %esi,%edx
  800757:	eb 0f                	jmp    800768 <strncpy+0x23>
		*dst++ = *src;
  800759:	83 c2 01             	add    $0x1,%edx
  80075c:	0f b6 01             	movzbl (%ecx),%eax
  80075f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800762:	80 39 01             	cmpb   $0x1,(%ecx)
  800765:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800768:	39 da                	cmp    %ebx,%edx
  80076a:	75 ed                	jne    800759 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80076c:	89 f0                	mov    %esi,%eax
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	56                   	push   %esi
  800776:	53                   	push   %ebx
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077d:	8b 55 10             	mov    0x10(%ebp),%edx
  800780:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800782:	85 d2                	test   %edx,%edx
  800784:	74 21                	je     8007a7 <strlcpy+0x35>
  800786:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80078a:	89 f2                	mov    %esi,%edx
  80078c:	eb 09                	jmp    800797 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	83 c1 01             	add    $0x1,%ecx
  800794:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800797:	39 c2                	cmp    %eax,%edx
  800799:	74 09                	je     8007a4 <strlcpy+0x32>
  80079b:	0f b6 19             	movzbl (%ecx),%ebx
  80079e:	84 db                	test   %bl,%bl
  8007a0:	75 ec                	jne    80078e <strlcpy+0x1c>
  8007a2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007a7:	29 f0                	sub    %esi,%eax
}
  8007a9:	5b                   	pop    %ebx
  8007aa:	5e                   	pop    %esi
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b6:	eb 06                	jmp    8007be <strcmp+0x11>
		p++, q++;
  8007b8:	83 c1 01             	add    $0x1,%ecx
  8007bb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007be:	0f b6 01             	movzbl (%ecx),%eax
  8007c1:	84 c0                	test   %al,%al
  8007c3:	74 04                	je     8007c9 <strcmp+0x1c>
  8007c5:	3a 02                	cmp    (%edx),%al
  8007c7:	74 ef                	je     8007b8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c9:	0f b6 c0             	movzbl %al,%eax
  8007cc:	0f b6 12             	movzbl (%edx),%edx
  8007cf:	29 d0                	sub    %edx,%eax
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dd:	89 c3                	mov    %eax,%ebx
  8007df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e2:	eb 06                	jmp    8007ea <strncmp+0x17>
		n--, p++, q++;
  8007e4:	83 c0 01             	add    $0x1,%eax
  8007e7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ea:	39 d8                	cmp    %ebx,%eax
  8007ec:	74 15                	je     800803 <strncmp+0x30>
  8007ee:	0f b6 08             	movzbl (%eax),%ecx
  8007f1:	84 c9                	test   %cl,%cl
  8007f3:	74 04                	je     8007f9 <strncmp+0x26>
  8007f5:	3a 0a                	cmp    (%edx),%cl
  8007f7:	74 eb                	je     8007e4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f9:	0f b6 00             	movzbl (%eax),%eax
  8007fc:	0f b6 12             	movzbl (%edx),%edx
  8007ff:	29 d0                	sub    %edx,%eax
  800801:	eb 05                	jmp    800808 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800808:	5b                   	pop    %ebx
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800815:	eb 07                	jmp    80081e <strchr+0x13>
		if (*s == c)
  800817:	38 ca                	cmp    %cl,%dl
  800819:	74 0f                	je     80082a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081b:	83 c0 01             	add    $0x1,%eax
  80081e:	0f b6 10             	movzbl (%eax),%edx
  800821:	84 d2                	test   %dl,%dl
  800823:	75 f2                	jne    800817 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800836:	eb 03                	jmp    80083b <strfind+0xf>
  800838:	83 c0 01             	add    $0x1,%eax
  80083b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80083e:	38 ca                	cmp    %cl,%dl
  800840:	74 04                	je     800846 <strfind+0x1a>
  800842:	84 d2                	test   %dl,%dl
  800844:	75 f2                	jne    800838 <strfind+0xc>
			break;
	return (char *) s;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	57                   	push   %edi
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800851:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800854:	85 c9                	test   %ecx,%ecx
  800856:	74 36                	je     80088e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800858:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085e:	75 28                	jne    800888 <memset+0x40>
  800860:	f6 c1 03             	test   $0x3,%cl
  800863:	75 23                	jne    800888 <memset+0x40>
		c &= 0xFF;
  800865:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800869:	89 d3                	mov    %edx,%ebx
  80086b:	c1 e3 08             	shl    $0x8,%ebx
  80086e:	89 d6                	mov    %edx,%esi
  800870:	c1 e6 18             	shl    $0x18,%esi
  800873:	89 d0                	mov    %edx,%eax
  800875:	c1 e0 10             	shl    $0x10,%eax
  800878:	09 f0                	or     %esi,%eax
  80087a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80087c:	89 d8                	mov    %ebx,%eax
  80087e:	09 d0                	or     %edx,%eax
  800880:	c1 e9 02             	shr    $0x2,%ecx
  800883:	fc                   	cld    
  800884:	f3 ab                	rep stos %eax,%es:(%edi)
  800886:	eb 06                	jmp    80088e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088b:	fc                   	cld    
  80088c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088e:	89 f8                	mov    %edi,%eax
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5f                   	pop    %edi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	57                   	push   %edi
  800899:	56                   	push   %esi
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a3:	39 c6                	cmp    %eax,%esi
  8008a5:	73 35                	jae    8008dc <memmove+0x47>
  8008a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008aa:	39 d0                	cmp    %edx,%eax
  8008ac:	73 2e                	jae    8008dc <memmove+0x47>
		s += n;
		d += n;
  8008ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b1:	89 d6                	mov    %edx,%esi
  8008b3:	09 fe                	or     %edi,%esi
  8008b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008bb:	75 13                	jne    8008d0 <memmove+0x3b>
  8008bd:	f6 c1 03             	test   $0x3,%cl
  8008c0:	75 0e                	jne    8008d0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c2:	83 ef 04             	sub    $0x4,%edi
  8008c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
  8008cb:	fd                   	std    
  8008cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ce:	eb 09                	jmp    8008d9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d0:	83 ef 01             	sub    $0x1,%edi
  8008d3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008d6:	fd                   	std    
  8008d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d9:	fc                   	cld    
  8008da:	eb 1d                	jmp    8008f9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dc:	89 f2                	mov    %esi,%edx
  8008de:	09 c2                	or     %eax,%edx
  8008e0:	f6 c2 03             	test   $0x3,%dl
  8008e3:	75 0f                	jne    8008f4 <memmove+0x5f>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 0a                	jne    8008f4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
  8008ed:	89 c7                	mov    %eax,%edi
  8008ef:	fc                   	cld    
  8008f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f2:	eb 05                	jmp    8008f9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f4:	89 c7                	mov    %eax,%edi
  8008f6:	fc                   	cld    
  8008f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f9:	5e                   	pop    %esi
  8008fa:	5f                   	pop    %edi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800900:	ff 75 10             	pushl  0x10(%ebp)
  800903:	ff 75 0c             	pushl  0xc(%ebp)
  800906:	ff 75 08             	pushl  0x8(%ebp)
  800909:	e8 87 ff ff ff       	call   800895 <memmove>
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091b:	89 c6                	mov    %eax,%esi
  80091d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800920:	eb 1a                	jmp    80093c <memcmp+0x2c>
		if (*s1 != *s2)
  800922:	0f b6 08             	movzbl (%eax),%ecx
  800925:	0f b6 1a             	movzbl (%edx),%ebx
  800928:	38 d9                	cmp    %bl,%cl
  80092a:	74 0a                	je     800936 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80092c:	0f b6 c1             	movzbl %cl,%eax
  80092f:	0f b6 db             	movzbl %bl,%ebx
  800932:	29 d8                	sub    %ebx,%eax
  800934:	eb 0f                	jmp    800945 <memcmp+0x35>
		s1++, s2++;
  800936:	83 c0 01             	add    $0x1,%eax
  800939:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093c:	39 f0                	cmp    %esi,%eax
  80093e:	75 e2                	jne    800922 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	53                   	push   %ebx
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800950:	89 c1                	mov    %eax,%ecx
  800952:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800955:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800959:	eb 0a                	jmp    800965 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095b:	0f b6 10             	movzbl (%eax),%edx
  80095e:	39 da                	cmp    %ebx,%edx
  800960:	74 07                	je     800969 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	39 c8                	cmp    %ecx,%eax
  800967:	72 f2                	jb     80095b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800969:	5b                   	pop    %ebx
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800978:	eb 03                	jmp    80097d <strtol+0x11>
		s++;
  80097a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	3c 20                	cmp    $0x20,%al
  800982:	74 f6                	je     80097a <strtol+0xe>
  800984:	3c 09                	cmp    $0x9,%al
  800986:	74 f2                	je     80097a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800988:	3c 2b                	cmp    $0x2b,%al
  80098a:	75 0a                	jne    800996 <strtol+0x2a>
		s++;
  80098c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098f:	bf 00 00 00 00       	mov    $0x0,%edi
  800994:	eb 11                	jmp    8009a7 <strtol+0x3b>
  800996:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099b:	3c 2d                	cmp    $0x2d,%al
  80099d:	75 08                	jne    8009a7 <strtol+0x3b>
		s++, neg = 1;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ad:	75 15                	jne    8009c4 <strtol+0x58>
  8009af:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b2:	75 10                	jne    8009c4 <strtol+0x58>
  8009b4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009b8:	75 7c                	jne    800a36 <strtol+0xca>
		s += 2, base = 16;
  8009ba:	83 c1 02             	add    $0x2,%ecx
  8009bd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c2:	eb 16                	jmp    8009da <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c4:	85 db                	test   %ebx,%ebx
  8009c6:	75 12                	jne    8009da <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009cd:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d0:	75 08                	jne    8009da <strtol+0x6e>
		s++, base = 8;
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
  8009df:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e2:	0f b6 11             	movzbl (%ecx),%edx
  8009e5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e8:	89 f3                	mov    %esi,%ebx
  8009ea:	80 fb 09             	cmp    $0x9,%bl
  8009ed:	77 08                	ja     8009f7 <strtol+0x8b>
			dig = *s - '0';
  8009ef:	0f be d2             	movsbl %dl,%edx
  8009f2:	83 ea 30             	sub    $0x30,%edx
  8009f5:	eb 22                	jmp    800a19 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009f7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009fa:	89 f3                	mov    %esi,%ebx
  8009fc:	80 fb 19             	cmp    $0x19,%bl
  8009ff:	77 08                	ja     800a09 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a01:	0f be d2             	movsbl %dl,%edx
  800a04:	83 ea 57             	sub    $0x57,%edx
  800a07:	eb 10                	jmp    800a19 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a09:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a0c:	89 f3                	mov    %esi,%ebx
  800a0e:	80 fb 19             	cmp    $0x19,%bl
  800a11:	77 16                	ja     800a29 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a13:	0f be d2             	movsbl %dl,%edx
  800a16:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a19:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a1c:	7d 0b                	jge    800a29 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a1e:	83 c1 01             	add    $0x1,%ecx
  800a21:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a25:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a27:	eb b9                	jmp    8009e2 <strtol+0x76>

	if (endptr)
  800a29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2d:	74 0d                	je     800a3c <strtol+0xd0>
		*endptr = (char *) s;
  800a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a32:	89 0e                	mov    %ecx,(%esi)
  800a34:	eb 06                	jmp    800a3c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a36:	85 db                	test   %ebx,%ebx
  800a38:	74 98                	je     8009d2 <strtol+0x66>
  800a3a:	eb 9e                	jmp    8009da <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a3c:	89 c2                	mov    %eax,%edx
  800a3e:	f7 da                	neg    %edx
  800a40:	85 ff                	test   %edi,%edi
  800a42:	0f 45 c2             	cmovne %edx,%eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	89 c3                	mov    %eax,%ebx
  800a5d:	89 c7                	mov    %eax,%edi
  800a5f:	89 c6                	mov    %eax,%esi
  800a61:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	b8 01 00 00 00       	mov    $0x1,%eax
  800a78:	89 d1                	mov    %edx,%ecx
  800a7a:	89 d3                	mov    %edx,%ebx
  800a7c:	89 d7                	mov    %edx,%edi
  800a7e:	89 d6                	mov    %edx,%esi
  800a80:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a95:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	89 cb                	mov    %ecx,%ebx
  800a9f:	89 cf                	mov    %ecx,%edi
  800aa1:	89 ce                	mov    %ecx,%esi
  800aa3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aa5:	85 c0                	test   %eax,%eax
  800aa7:	7e 17                	jle    800ac0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	50                   	push   %eax
  800aad:	6a 03                	push   $0x3
  800aaf:	68 1f 21 80 00       	push   $0x80211f
  800ab4:	6a 23                	push   $0x23
  800ab6:	68 3c 21 80 00       	push   $0x80213c
  800abb:	e8 21 0f 00 00       	call   8019e1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad8:	89 d1                	mov    %edx,%ecx
  800ada:	89 d3                	mov    %edx,%ebx
  800adc:	89 d7                	mov    %edx,%edi
  800ade:	89 d6                	mov    %edx,%esi
  800ae0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_yield>:

void
sys_yield(void)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af7:	89 d1                	mov    %edx,%ecx
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	89 d7                	mov    %edx,%edi
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0f:	be 00 00 00 00       	mov    $0x0,%esi
  800b14:	b8 04 00 00 00       	mov    $0x4,%eax
  800b19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b22:	89 f7                	mov    %esi,%edi
  800b24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b26:	85 c0                	test   %eax,%eax
  800b28:	7e 17                	jle    800b41 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	50                   	push   %eax
  800b2e:	6a 04                	push   $0x4
  800b30:	68 1f 21 80 00       	push   $0x80211f
  800b35:	6a 23                	push   $0x23
  800b37:	68 3c 21 80 00       	push   $0x80213c
  800b3c:	e8 a0 0e 00 00       	call   8019e1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	b8 05 00 00 00       	mov    $0x5,%eax
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b63:	8b 75 18             	mov    0x18(%ebp),%esi
  800b66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 05                	push   $0x5
  800b72:	68 1f 21 80 00       	push   $0x80211f
  800b77:	6a 23                	push   $0x23
  800b79:	68 3c 21 80 00       	push   $0x80213c
  800b7e:	e8 5e 0e 00 00       	call   8019e1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b99:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba4:	89 df                	mov    %ebx,%edi
  800ba6:	89 de                	mov    %ebx,%esi
  800ba8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 17                	jle    800bc5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 06                	push   $0x6
  800bb4:	68 1f 21 80 00       	push   $0x80211f
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 3c 21 80 00       	push   $0x80213c
  800bc0:	e8 1c 0e 00 00       	call   8019e1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	89 df                	mov    %ebx,%edi
  800be8:	89 de                	mov    %ebx,%esi
  800bea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 08                	push   $0x8
  800bf6:	68 1f 21 80 00       	push   $0x80211f
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 3c 21 80 00       	push   $0x80213c
  800c02:	e8 da 0d 00 00       	call   8019e1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 df                	mov    %ebx,%edi
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 09                	push   $0x9
  800c38:	68 1f 21 80 00       	push   $0x80211f
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 3c 21 80 00       	push   $0x80213c
  800c44:	e8 98 0d 00 00       	call   8019e1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 df                	mov    %ebx,%edi
  800c6c:	89 de                	mov    %ebx,%esi
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 0a                	push   $0xa
  800c7a:	68 1f 21 80 00       	push   $0x80211f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 3c 21 80 00       	push   $0x80213c
  800c86:	e8 56 0d 00 00       	call   8019e1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c99:	be 00 00 00 00       	mov    $0x0,%esi
  800c9e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cac:	8b 7d 14             	mov    0x14(%ebp),%edi
  800caf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	89 cb                	mov    %ecx,%ebx
  800cce:	89 cf                	mov    %ecx,%edi
  800cd0:	89 ce                	mov    %ecx,%esi
  800cd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 17                	jle    800cef <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 0d                	push   $0xd
  800cde:	68 1f 21 80 00       	push   $0x80211f
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 3c 21 80 00       	push   $0x80213c
  800cea:	e8 f2 0c 00 00       	call   8019e1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	05 00 00 00 30       	add    $0x30000000,%eax
  800d02:	c1 e8 0c             	shr    $0xc,%eax
}
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d17:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d24:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d29:	89 c2                	mov    %eax,%edx
  800d2b:	c1 ea 16             	shr    $0x16,%edx
  800d2e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d35:	f6 c2 01             	test   $0x1,%dl
  800d38:	74 11                	je     800d4b <fd_alloc+0x2d>
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	c1 ea 0c             	shr    $0xc,%edx
  800d3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d46:	f6 c2 01             	test   $0x1,%dl
  800d49:	75 09                	jne    800d54 <fd_alloc+0x36>
			*fd_store = fd;
  800d4b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d52:	eb 17                	jmp    800d6b <fd_alloc+0x4d>
  800d54:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d59:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d5e:	75 c9                	jne    800d29 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d60:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d66:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d73:	83 f8 1f             	cmp    $0x1f,%eax
  800d76:	77 36                	ja     800dae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d78:	c1 e0 0c             	shl    $0xc,%eax
  800d7b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d80:	89 c2                	mov    %eax,%edx
  800d82:	c1 ea 16             	shr    $0x16,%edx
  800d85:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8c:	f6 c2 01             	test   $0x1,%dl
  800d8f:	74 24                	je     800db5 <fd_lookup+0x48>
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	c1 ea 0c             	shr    $0xc,%edx
  800d96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9d:	f6 c2 01             	test   $0x1,%dl
  800da0:	74 1a                	je     800dbc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800da2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da5:	89 02                	mov    %eax,(%edx)
	return 0;
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dac:	eb 13                	jmp    800dc1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800db3:	eb 0c                	jmp    800dc1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800db5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dba:	eb 05                	jmp    800dc1 <fd_lookup+0x54>
  800dbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcc:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dd1:	eb 13                	jmp    800de6 <dev_lookup+0x23>
  800dd3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dd6:	39 08                	cmp    %ecx,(%eax)
  800dd8:	75 0c                	jne    800de6 <dev_lookup+0x23>
			*dev = devtab[i];
  800dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
  800de4:	eb 2e                	jmp    800e14 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800de6:	8b 02                	mov    (%edx),%eax
  800de8:	85 c0                	test   %eax,%eax
  800dea:	75 e7                	jne    800dd3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dec:	a1 04 40 80 00       	mov    0x804004,%eax
  800df1:	8b 40 48             	mov    0x48(%eax),%eax
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	51                   	push   %ecx
  800df8:	50                   	push   %eax
  800df9:	68 4c 21 80 00       	push   $0x80214c
  800dfe:	e8 5d f3 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800e03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e14:	c9                   	leave  
  800e15:	c3                   	ret    

00800e16 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
  800e1b:	83 ec 10             	sub    $0x10,%esp
  800e1e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e27:	50                   	push   %eax
  800e28:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e2e:	c1 e8 0c             	shr    $0xc,%eax
  800e31:	50                   	push   %eax
  800e32:	e8 36 ff ff ff       	call   800d6d <fd_lookup>
  800e37:	83 c4 08             	add    $0x8,%esp
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	78 05                	js     800e43 <fd_close+0x2d>
	    || fd != fd2)
  800e3e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e41:	74 0c                	je     800e4f <fd_close+0x39>
		return (must_exist ? r : 0);
  800e43:	84 db                	test   %bl,%bl
  800e45:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4a:	0f 44 c2             	cmove  %edx,%eax
  800e4d:	eb 41                	jmp    800e90 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e55:	50                   	push   %eax
  800e56:	ff 36                	pushl  (%esi)
  800e58:	e8 66 ff ff ff       	call   800dc3 <dev_lookup>
  800e5d:	89 c3                	mov    %eax,%ebx
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	78 1a                	js     800e80 <fd_close+0x6a>
		if (dev->dev_close)
  800e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e69:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e6c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e71:	85 c0                	test   %eax,%eax
  800e73:	74 0b                	je     800e80 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	56                   	push   %esi
  800e79:	ff d0                	call   *%eax
  800e7b:	89 c3                	mov    %eax,%ebx
  800e7d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	56                   	push   %esi
  800e84:	6a 00                	push   $0x0
  800e86:	e8 00 fd ff ff       	call   800b8b <sys_page_unmap>
	return r;
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	89 d8                	mov    %ebx,%eax
}
  800e90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea0:	50                   	push   %eax
  800ea1:	ff 75 08             	pushl  0x8(%ebp)
  800ea4:	e8 c4 fe ff ff       	call   800d6d <fd_lookup>
  800ea9:	83 c4 08             	add    $0x8,%esp
  800eac:	85 c0                	test   %eax,%eax
  800eae:	78 10                	js     800ec0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	6a 01                	push   $0x1
  800eb5:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb8:	e8 59 ff ff ff       	call   800e16 <fd_close>
  800ebd:	83 c4 10             	add    $0x10,%esp
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <close_all>:

void
close_all(void)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	53                   	push   %ebx
  800ed2:	e8 c0 ff ff ff       	call   800e97 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed7:	83 c3 01             	add    $0x1,%ebx
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	83 fb 20             	cmp    $0x20,%ebx
  800ee0:	75 ec                	jne    800ece <close_all+0xc>
		close(i);
}
  800ee2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 2c             	sub    $0x2c,%esp
  800ef0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ef3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ef6:	50                   	push   %eax
  800ef7:	ff 75 08             	pushl  0x8(%ebp)
  800efa:	e8 6e fe ff ff       	call   800d6d <fd_lookup>
  800eff:	83 c4 08             	add    $0x8,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	0f 88 c1 00 00 00    	js     800fcb <dup+0xe4>
		return r;
	close(newfdnum);
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	56                   	push   %esi
  800f0e:	e8 84 ff ff ff       	call   800e97 <close>

	newfd = INDEX2FD(newfdnum);
  800f13:	89 f3                	mov    %esi,%ebx
  800f15:	c1 e3 0c             	shl    $0xc,%ebx
  800f18:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f1e:	83 c4 04             	add    $0x4,%esp
  800f21:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f24:	e8 de fd ff ff       	call   800d07 <fd2data>
  800f29:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f2b:	89 1c 24             	mov    %ebx,(%esp)
  800f2e:	e8 d4 fd ff ff       	call   800d07 <fd2data>
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f39:	89 f8                	mov    %edi,%eax
  800f3b:	c1 e8 16             	shr    $0x16,%eax
  800f3e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f45:	a8 01                	test   $0x1,%al
  800f47:	74 37                	je     800f80 <dup+0x99>
  800f49:	89 f8                	mov    %edi,%eax
  800f4b:	c1 e8 0c             	shr    $0xc,%eax
  800f4e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	74 26                	je     800f80 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	25 07 0e 00 00       	and    $0xe07,%eax
  800f69:	50                   	push   %eax
  800f6a:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f6d:	6a 00                	push   $0x0
  800f6f:	57                   	push   %edi
  800f70:	6a 00                	push   $0x0
  800f72:	e8 d2 fb ff ff       	call   800b49 <sys_page_map>
  800f77:	89 c7                	mov    %eax,%edi
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 2e                	js     800fae <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f83:	89 d0                	mov    %edx,%eax
  800f85:	c1 e8 0c             	shr    $0xc,%eax
  800f88:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	25 07 0e 00 00       	and    $0xe07,%eax
  800f97:	50                   	push   %eax
  800f98:	53                   	push   %ebx
  800f99:	6a 00                	push   $0x0
  800f9b:	52                   	push   %edx
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 a6 fb ff ff       	call   800b49 <sys_page_map>
  800fa3:	89 c7                	mov    %eax,%edi
  800fa5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fa8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800faa:	85 ff                	test   %edi,%edi
  800fac:	79 1d                	jns    800fcb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	53                   	push   %ebx
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 d2 fb ff ff       	call   800b8b <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fb9:	83 c4 08             	add    $0x8,%esp
  800fbc:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 c5 fb ff ff       	call   800b8b <sys_page_unmap>
	return r;
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	89 f8                	mov    %edi,%eax
}
  800fcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	53                   	push   %ebx
  800fd7:	83 ec 14             	sub    $0x14,%esp
  800fda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	53                   	push   %ebx
  800fe2:	e8 86 fd ff ff       	call   800d6d <fd_lookup>
  800fe7:	83 c4 08             	add    $0x8,%esp
  800fea:	89 c2                	mov    %eax,%edx
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 6d                	js     80105d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff6:	50                   	push   %eax
  800ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffa:	ff 30                	pushl  (%eax)
  800ffc:	e8 c2 fd ff ff       	call   800dc3 <dev_lookup>
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 4c                	js     801054 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801008:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80100b:	8b 42 08             	mov    0x8(%edx),%eax
  80100e:	83 e0 03             	and    $0x3,%eax
  801011:	83 f8 01             	cmp    $0x1,%eax
  801014:	75 21                	jne    801037 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801016:	a1 04 40 80 00       	mov    0x804004,%eax
  80101b:	8b 40 48             	mov    0x48(%eax),%eax
  80101e:	83 ec 04             	sub    $0x4,%esp
  801021:	53                   	push   %ebx
  801022:	50                   	push   %eax
  801023:	68 8d 21 80 00       	push   $0x80218d
  801028:	e8 33 f1 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801035:	eb 26                	jmp    80105d <read+0x8a>
	}
	if (!dev->dev_read)
  801037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103a:	8b 40 08             	mov    0x8(%eax),%eax
  80103d:	85 c0                	test   %eax,%eax
  80103f:	74 17                	je     801058 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	ff 75 10             	pushl  0x10(%ebp)
  801047:	ff 75 0c             	pushl  0xc(%ebp)
  80104a:	52                   	push   %edx
  80104b:	ff d0                	call   *%eax
  80104d:	89 c2                	mov    %eax,%edx
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	eb 09                	jmp    80105d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801054:	89 c2                	mov    %eax,%edx
  801056:	eb 05                	jmp    80105d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801058:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80105d:	89 d0                	mov    %edx,%eax
  80105f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	57                   	push   %edi
  801068:	56                   	push   %esi
  801069:	53                   	push   %ebx
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801070:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801073:	bb 00 00 00 00       	mov    $0x0,%ebx
  801078:	eb 21                	jmp    80109b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	89 f0                	mov    %esi,%eax
  80107f:	29 d8                	sub    %ebx,%eax
  801081:	50                   	push   %eax
  801082:	89 d8                	mov    %ebx,%eax
  801084:	03 45 0c             	add    0xc(%ebp),%eax
  801087:	50                   	push   %eax
  801088:	57                   	push   %edi
  801089:	e8 45 ff ff ff       	call   800fd3 <read>
		if (m < 0)
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	78 10                	js     8010a5 <readn+0x41>
			return m;
		if (m == 0)
  801095:	85 c0                	test   %eax,%eax
  801097:	74 0a                	je     8010a3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801099:	01 c3                	add    %eax,%ebx
  80109b:	39 f3                	cmp    %esi,%ebx
  80109d:	72 db                	jb     80107a <readn+0x16>
  80109f:	89 d8                	mov    %ebx,%eax
  8010a1:	eb 02                	jmp    8010a5 <readn+0x41>
  8010a3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5f                   	pop    %edi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 14             	sub    $0x14,%esp
  8010b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ba:	50                   	push   %eax
  8010bb:	53                   	push   %ebx
  8010bc:	e8 ac fc ff ff       	call   800d6d <fd_lookup>
  8010c1:	83 c4 08             	add    $0x8,%esp
  8010c4:	89 c2                	mov    %eax,%edx
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	78 68                	js     801132 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ca:	83 ec 08             	sub    $0x8,%esp
  8010cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d0:	50                   	push   %eax
  8010d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d4:	ff 30                	pushl  (%eax)
  8010d6:	e8 e8 fc ff ff       	call   800dc3 <dev_lookup>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 47                	js     801129 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010e9:	75 21                	jne    80110c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f0:	8b 40 48             	mov    0x48(%eax),%eax
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	53                   	push   %ebx
  8010f7:	50                   	push   %eax
  8010f8:	68 a9 21 80 00       	push   $0x8021a9
  8010fd:	e8 5e f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80110a:	eb 26                	jmp    801132 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80110c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80110f:	8b 52 0c             	mov    0xc(%edx),%edx
  801112:	85 d2                	test   %edx,%edx
  801114:	74 17                	je     80112d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801116:	83 ec 04             	sub    $0x4,%esp
  801119:	ff 75 10             	pushl  0x10(%ebp)
  80111c:	ff 75 0c             	pushl  0xc(%ebp)
  80111f:	50                   	push   %eax
  801120:	ff d2                	call   *%edx
  801122:	89 c2                	mov    %eax,%edx
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	eb 09                	jmp    801132 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801129:	89 c2                	mov    %eax,%edx
  80112b:	eb 05                	jmp    801132 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80112d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801132:	89 d0                	mov    %edx,%eax
  801134:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801137:	c9                   	leave  
  801138:	c3                   	ret    

00801139 <seek>:

int
seek(int fdnum, off_t offset)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80113f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	ff 75 08             	pushl  0x8(%ebp)
  801146:	e8 22 fc ff ff       	call   800d6d <fd_lookup>
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 0e                	js     801160 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801152:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801155:	8b 55 0c             	mov    0xc(%ebp),%edx
  801158:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	53                   	push   %ebx
  801166:	83 ec 14             	sub    $0x14,%esp
  801169:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	53                   	push   %ebx
  801171:	e8 f7 fb ff ff       	call   800d6d <fd_lookup>
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	89 c2                	mov    %eax,%edx
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 65                	js     8011e4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801189:	ff 30                	pushl  (%eax)
  80118b:	e8 33 fc ff ff       	call   800dc3 <dev_lookup>
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 44                	js     8011db <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801197:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119e:	75 21                	jne    8011c1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011a0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011a5:	8b 40 48             	mov    0x48(%eax),%eax
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	53                   	push   %ebx
  8011ac:	50                   	push   %eax
  8011ad:	68 6c 21 80 00       	push   $0x80216c
  8011b2:	e8 a9 ef ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011bf:	eb 23                	jmp    8011e4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c4:	8b 52 18             	mov    0x18(%edx),%edx
  8011c7:	85 d2                	test   %edx,%edx
  8011c9:	74 14                	je     8011df <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	ff 75 0c             	pushl  0xc(%ebp)
  8011d1:	50                   	push   %eax
  8011d2:	ff d2                	call   *%edx
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	eb 09                	jmp    8011e4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	eb 05                	jmp    8011e4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011e4:	89 d0                	mov    %edx,%eax
  8011e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 14             	sub    $0x14,%esp
  8011f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 6c fb ff ff       	call   800d6d <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	89 c2                	mov    %eax,%edx
  801206:	85 c0                	test   %eax,%eax
  801208:	78 58                	js     801262 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	ff 30                	pushl  (%eax)
  801216:	e8 a8 fb ff ff       	call   800dc3 <dev_lookup>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 37                	js     801259 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801229:	74 32                	je     80125d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80122b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80122e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801235:	00 00 00 
	stat->st_isdir = 0;
  801238:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80123f:	00 00 00 
	stat->st_dev = dev;
  801242:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	53                   	push   %ebx
  80124c:	ff 75 f0             	pushl  -0x10(%ebp)
  80124f:	ff 50 14             	call   *0x14(%eax)
  801252:	89 c2                	mov    %eax,%edx
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	eb 09                	jmp    801262 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801259:	89 c2                	mov    %eax,%edx
  80125b:	eb 05                	jmp    801262 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80125d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801262:	89 d0                	mov    %edx,%eax
  801264:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	6a 00                	push   $0x0
  801273:	ff 75 08             	pushl  0x8(%ebp)
  801276:	e8 e3 01 00 00       	call   80145e <open>
  80127b:	89 c3                	mov    %eax,%ebx
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	78 1b                	js     80129f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	ff 75 0c             	pushl  0xc(%ebp)
  80128a:	50                   	push   %eax
  80128b:	e8 5b ff ff ff       	call   8011eb <fstat>
  801290:	89 c6                	mov    %eax,%esi
	close(fd);
  801292:	89 1c 24             	mov    %ebx,(%esp)
  801295:	e8 fd fb ff ff       	call   800e97 <close>
	return r;
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	89 f0                	mov    %esi,%eax
}
  80129f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a2:	5b                   	pop    %ebx
  8012a3:	5e                   	pop    %esi
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
  8012ab:	89 c6                	mov    %eax,%esi
  8012ad:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012af:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012b6:	75 12                	jne    8012ca <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012b8:	83 ec 0c             	sub    $0xc,%esp
  8012bb:	6a 01                	push   $0x1
  8012bd:	e8 0e 08 00 00       	call   801ad0 <ipc_find_env>
  8012c2:	a3 00 40 80 00       	mov    %eax,0x804000
  8012c7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012ca:	6a 07                	push   $0x7
  8012cc:	68 00 50 80 00       	push   $0x805000
  8012d1:	56                   	push   %esi
  8012d2:	ff 35 00 40 80 00    	pushl  0x804000
  8012d8:	e8 9f 07 00 00       	call   801a7c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012dd:	83 c4 0c             	add    $0xc,%esp
  8012e0:	6a 00                	push   $0x0
  8012e2:	53                   	push   %ebx
  8012e3:	6a 00                	push   $0x0
  8012e5:	e8 3d 07 00 00       	call   801a27 <ipc_recv>
}
  8012ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8012fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801302:	8b 45 0c             	mov    0xc(%ebp),%eax
  801305:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80130a:	ba 00 00 00 00       	mov    $0x0,%edx
  80130f:	b8 02 00 00 00       	mov    $0x2,%eax
  801314:	e8 8d ff ff ff       	call   8012a6 <fsipc>
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
  801324:	8b 40 0c             	mov    0xc(%eax),%eax
  801327:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80132c:	ba 00 00 00 00       	mov    $0x0,%edx
  801331:	b8 06 00 00 00       	mov    $0x6,%eax
  801336:	e8 6b ff ff ff       	call   8012a6 <fsipc>
}
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	53                   	push   %ebx
  801341:	83 ec 04             	sub    $0x4,%esp
  801344:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801347:	8b 45 08             	mov    0x8(%ebp),%eax
  80134a:	8b 40 0c             	mov    0xc(%eax),%eax
  80134d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801352:	ba 00 00 00 00       	mov    $0x0,%edx
  801357:	b8 05 00 00 00       	mov    $0x5,%eax
  80135c:	e8 45 ff ff ff       	call   8012a6 <fsipc>
  801361:	85 c0                	test   %eax,%eax
  801363:	78 2c                	js     801391 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	68 00 50 80 00       	push   $0x805000
  80136d:	53                   	push   %ebx
  80136e:	e8 90 f3 ff ff       	call   800703 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801373:	a1 80 50 80 00       	mov    0x805080,%eax
  801378:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80137e:	a1 84 50 80 00       	mov    0x805084,%eax
  801383:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801391:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80139f:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a5:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8013ab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013b0:	ba 00 10 00 00       	mov    $0x1000,%edx
  8013b5:	0f 47 c2             	cmova  %edx,%eax
  8013b8:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013bd:	50                   	push   %eax
  8013be:	ff 75 0c             	pushl  0xc(%ebp)
  8013c1:	68 08 50 80 00       	push   $0x805008
  8013c6:	e8 ca f4 ff ff       	call   800895 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d5:	e8 cc fe ff ff       	call   8012a6 <fsipc>
    return r;
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ef:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8013ff:	e8 a2 fe ff ff       	call   8012a6 <fsipc>
  801404:	89 c3                	mov    %eax,%ebx
  801406:	85 c0                	test   %eax,%eax
  801408:	78 4b                	js     801455 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80140a:	39 c6                	cmp    %eax,%esi
  80140c:	73 16                	jae    801424 <devfile_read+0x48>
  80140e:	68 d8 21 80 00       	push   $0x8021d8
  801413:	68 df 21 80 00       	push   $0x8021df
  801418:	6a 7c                	push   $0x7c
  80141a:	68 f4 21 80 00       	push   $0x8021f4
  80141f:	e8 bd 05 00 00       	call   8019e1 <_panic>
	assert(r <= PGSIZE);
  801424:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801429:	7e 16                	jle    801441 <devfile_read+0x65>
  80142b:	68 ff 21 80 00       	push   $0x8021ff
  801430:	68 df 21 80 00       	push   $0x8021df
  801435:	6a 7d                	push   $0x7d
  801437:	68 f4 21 80 00       	push   $0x8021f4
  80143c:	e8 a0 05 00 00       	call   8019e1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801441:	83 ec 04             	sub    $0x4,%esp
  801444:	50                   	push   %eax
  801445:	68 00 50 80 00       	push   $0x805000
  80144a:	ff 75 0c             	pushl  0xc(%ebp)
  80144d:	e8 43 f4 ff ff       	call   800895 <memmove>
	return r;
  801452:	83 c4 10             	add    $0x10,%esp
}
  801455:	89 d8                	mov    %ebx,%eax
  801457:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	53                   	push   %ebx
  801462:	83 ec 20             	sub    $0x20,%esp
  801465:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801468:	53                   	push   %ebx
  801469:	e8 5c f2 ff ff       	call   8006ca <strlen>
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801476:	7f 67                	jg     8014df <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	e8 9a f8 ff ff       	call   800d1e <fd_alloc>
  801484:	83 c4 10             	add    $0x10,%esp
		return r;
  801487:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 57                	js     8014e4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	53                   	push   %ebx
  801491:	68 00 50 80 00       	push   $0x805000
  801496:	e8 68 f2 ff ff       	call   800703 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80149b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ab:	e8 f6 fd ff ff       	call   8012a6 <fsipc>
  8014b0:	89 c3                	mov    %eax,%ebx
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	79 14                	jns    8014cd <open+0x6f>
		fd_close(fd, 0);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	6a 00                	push   $0x0
  8014be:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c1:	e8 50 f9 ff ff       	call   800e16 <fd_close>
		return r;
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	89 da                	mov    %ebx,%edx
  8014cb:	eb 17                	jmp    8014e4 <open+0x86>
	}

	return fd2num(fd);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d3:	e8 1f f8 ff ff       	call   800cf7 <fd2num>
  8014d8:	89 c2                	mov    %eax,%edx
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	eb 05                	jmp    8014e4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014df:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8014fb:	e8 a6 fd ff ff       	call   8012a6 <fsipc>
}
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	56                   	push   %esi
  801506:	53                   	push   %ebx
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80150a:	83 ec 0c             	sub    $0xc,%esp
  80150d:	ff 75 08             	pushl  0x8(%ebp)
  801510:	e8 f2 f7 ff ff       	call   800d07 <fd2data>
  801515:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	68 0b 22 80 00       	push   $0x80220b
  80151f:	53                   	push   %ebx
  801520:	e8 de f1 ff ff       	call   800703 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801525:	8b 46 04             	mov    0x4(%esi),%eax
  801528:	2b 06                	sub    (%esi),%eax
  80152a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801530:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801537:	00 00 00 
	stat->st_dev = &devpipe;
  80153a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801541:	30 80 00 
	return 0;
}
  801544:	b8 00 00 00 00       	mov    $0x0,%eax
  801549:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	53                   	push   %ebx
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80155a:	53                   	push   %ebx
  80155b:	6a 00                	push   $0x0
  80155d:	e8 29 f6 ff ff       	call   800b8b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801562:	89 1c 24             	mov    %ebx,(%esp)
  801565:	e8 9d f7 ff ff       	call   800d07 <fd2data>
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	50                   	push   %eax
  80156e:	6a 00                	push   $0x0
  801570:	e8 16 f6 ff ff       	call   800b8b <sys_page_unmap>
}
  801575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	57                   	push   %edi
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
  801580:	83 ec 1c             	sub    $0x1c,%esp
  801583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801586:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801588:	a1 04 40 80 00       	mov    0x804004,%eax
  80158d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	ff 75 e0             	pushl  -0x20(%ebp)
  801596:	e8 6e 05 00 00       	call   801b09 <pageref>
  80159b:	89 c3                	mov    %eax,%ebx
  80159d:	89 3c 24             	mov    %edi,(%esp)
  8015a0:	e8 64 05 00 00       	call   801b09 <pageref>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	39 c3                	cmp    %eax,%ebx
  8015aa:	0f 94 c1             	sete   %cl
  8015ad:	0f b6 c9             	movzbl %cl,%ecx
  8015b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015b3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015b9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015bc:	39 ce                	cmp    %ecx,%esi
  8015be:	74 1b                	je     8015db <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015c0:	39 c3                	cmp    %eax,%ebx
  8015c2:	75 c4                	jne    801588 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c4:	8b 42 58             	mov    0x58(%edx),%eax
  8015c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ca:	50                   	push   %eax
  8015cb:	56                   	push   %esi
  8015cc:	68 12 22 80 00       	push   $0x802212
  8015d1:	e8 8a eb ff ff       	call   800160 <cprintf>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	eb ad                	jmp    801588 <_pipeisclosed+0xe>
	}
}
  8015db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5f                   	pop    %edi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	57                   	push   %edi
  8015ea:	56                   	push   %esi
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 28             	sub    $0x28,%esp
  8015ef:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015f2:	56                   	push   %esi
  8015f3:	e8 0f f7 ff ff       	call   800d07 <fd2data>
  8015f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	bf 00 00 00 00       	mov    $0x0,%edi
  801602:	eb 4b                	jmp    80164f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801604:	89 da                	mov    %ebx,%edx
  801606:	89 f0                	mov    %esi,%eax
  801608:	e8 6d ff ff ff       	call   80157a <_pipeisclosed>
  80160d:	85 c0                	test   %eax,%eax
  80160f:	75 48                	jne    801659 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801611:	e8 d1 f4 ff ff       	call   800ae7 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801616:	8b 43 04             	mov    0x4(%ebx),%eax
  801619:	8b 0b                	mov    (%ebx),%ecx
  80161b:	8d 51 20             	lea    0x20(%ecx),%edx
  80161e:	39 d0                	cmp    %edx,%eax
  801620:	73 e2                	jae    801604 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801622:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801625:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801629:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	c1 fa 1f             	sar    $0x1f,%edx
  801631:	89 d1                	mov    %edx,%ecx
  801633:	c1 e9 1b             	shr    $0x1b,%ecx
  801636:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801639:	83 e2 1f             	and    $0x1f,%edx
  80163c:	29 ca                	sub    %ecx,%edx
  80163e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801642:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801646:	83 c0 01             	add    $0x1,%eax
  801649:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164c:	83 c7 01             	add    $0x1,%edi
  80164f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801652:	75 c2                	jne    801616 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801654:	8b 45 10             	mov    0x10(%ebp),%eax
  801657:	eb 05                	jmp    80165e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80165e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	57                   	push   %edi
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	83 ec 18             	sub    $0x18,%esp
  80166f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801672:	57                   	push   %edi
  801673:	e8 8f f6 ff ff       	call   800d07 <fd2data>
  801678:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801682:	eb 3d                	jmp    8016c1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801684:	85 db                	test   %ebx,%ebx
  801686:	74 04                	je     80168c <devpipe_read+0x26>
				return i;
  801688:	89 d8                	mov    %ebx,%eax
  80168a:	eb 44                	jmp    8016d0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80168c:	89 f2                	mov    %esi,%edx
  80168e:	89 f8                	mov    %edi,%eax
  801690:	e8 e5 fe ff ff       	call   80157a <_pipeisclosed>
  801695:	85 c0                	test   %eax,%eax
  801697:	75 32                	jne    8016cb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801699:	e8 49 f4 ff ff       	call   800ae7 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80169e:	8b 06                	mov    (%esi),%eax
  8016a0:	3b 46 04             	cmp    0x4(%esi),%eax
  8016a3:	74 df                	je     801684 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016a5:	99                   	cltd   
  8016a6:	c1 ea 1b             	shr    $0x1b,%edx
  8016a9:	01 d0                	add    %edx,%eax
  8016ab:	83 e0 1f             	and    $0x1f,%eax
  8016ae:	29 d0                	sub    %edx,%eax
  8016b0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016bb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016be:	83 c3 01             	add    $0x1,%ebx
  8016c1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016c4:	75 d8                	jne    80169e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c9:	eb 05                	jmp    8016d0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5f                   	pop    %edi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	e8 35 f6 ff ff       	call   800d1e <fd_alloc>
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	0f 88 2c 01 00 00    	js     801822 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f6:	83 ec 04             	sub    $0x4,%esp
  8016f9:	68 07 04 00 00       	push   $0x407
  8016fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801701:	6a 00                	push   $0x0
  801703:	e8 fe f3 ff ff       	call   800b06 <sys_page_alloc>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	89 c2                	mov    %eax,%edx
  80170d:	85 c0                	test   %eax,%eax
  80170f:	0f 88 0d 01 00 00    	js     801822 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801715:	83 ec 0c             	sub    $0xc,%esp
  801718:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	e8 fd f5 ff ff       	call   800d1e <fd_alloc>
  801721:	89 c3                	mov    %eax,%ebx
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	0f 88 e2 00 00 00    	js     801810 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	68 07 04 00 00       	push   $0x407
  801736:	ff 75 f0             	pushl  -0x10(%ebp)
  801739:	6a 00                	push   $0x0
  80173b:	e8 c6 f3 ff ff       	call   800b06 <sys_page_alloc>
  801740:	89 c3                	mov    %eax,%ebx
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	85 c0                	test   %eax,%eax
  801747:	0f 88 c3 00 00 00    	js     801810 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80174d:	83 ec 0c             	sub    $0xc,%esp
  801750:	ff 75 f4             	pushl  -0xc(%ebp)
  801753:	e8 af f5 ff ff       	call   800d07 <fd2data>
  801758:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175a:	83 c4 0c             	add    $0xc,%esp
  80175d:	68 07 04 00 00       	push   $0x407
  801762:	50                   	push   %eax
  801763:	6a 00                	push   $0x0
  801765:	e8 9c f3 ff ff       	call   800b06 <sys_page_alloc>
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	0f 88 89 00 00 00    	js     801800 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	ff 75 f0             	pushl  -0x10(%ebp)
  80177d:	e8 85 f5 ff ff       	call   800d07 <fd2data>
  801782:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801789:	50                   	push   %eax
  80178a:	6a 00                	push   $0x0
  80178c:	56                   	push   %esi
  80178d:	6a 00                	push   $0x0
  80178f:	e8 b5 f3 ff ff       	call   800b49 <sys_page_map>
  801794:	89 c3                	mov    %eax,%ebx
  801796:	83 c4 20             	add    $0x20,%esp
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 55                	js     8017f2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80179d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017b2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cd:	e8 25 f5 ff ff       	call   800cf7 <fd2num>
  8017d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017d7:	83 c4 04             	add    $0x4,%esp
  8017da:	ff 75 f0             	pushl  -0x10(%ebp)
  8017dd:	e8 15 f5 ff ff       	call   800cf7 <fd2num>
  8017e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	eb 30                	jmp    801822 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	56                   	push   %esi
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 8e f3 ff ff       	call   800b8b <sys_page_unmap>
  8017fd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	ff 75 f0             	pushl  -0x10(%ebp)
  801806:	6a 00                	push   $0x0
  801808:	e8 7e f3 ff ff       	call   800b8b <sys_page_unmap>
  80180d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	ff 75 f4             	pushl  -0xc(%ebp)
  801816:	6a 00                	push   $0x0
  801818:	e8 6e f3 ff ff       	call   800b8b <sys_page_unmap>
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801822:	89 d0                	mov    %edx,%eax
  801824:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801827:	5b                   	pop    %ebx
  801828:	5e                   	pop    %esi
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801831:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801834:	50                   	push   %eax
  801835:	ff 75 08             	pushl  0x8(%ebp)
  801838:	e8 30 f5 ff ff       	call   800d6d <fd_lookup>
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	78 18                	js     80185c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801844:	83 ec 0c             	sub    $0xc,%esp
  801847:	ff 75 f4             	pushl  -0xc(%ebp)
  80184a:	e8 b8 f4 ff ff       	call   800d07 <fd2data>
	return _pipeisclosed(fd, p);
  80184f:	89 c2                	mov    %eax,%edx
  801851:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801854:	e8 21 fd ff ff       	call   80157a <_pipeisclosed>
  801859:	83 c4 10             	add    $0x10,%esp
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80186e:	68 2a 22 80 00       	push   $0x80222a
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	e8 88 ee ff ff       	call   800703 <strcpy>
	return 0;
}
  80187b:	b8 00 00 00 00       	mov    $0x0,%eax
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	57                   	push   %edi
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801893:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801899:	eb 2d                	jmp    8018c8 <devcons_write+0x46>
		m = n - tot;
  80189b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80189e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018a0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018a3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018a8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	53                   	push   %ebx
  8018af:	03 45 0c             	add    0xc(%ebp),%eax
  8018b2:	50                   	push   %eax
  8018b3:	57                   	push   %edi
  8018b4:	e8 dc ef ff ff       	call   800895 <memmove>
		sys_cputs(buf, m);
  8018b9:	83 c4 08             	add    $0x8,%esp
  8018bc:	53                   	push   %ebx
  8018bd:	57                   	push   %edi
  8018be:	e8 87 f1 ff ff       	call   800a4a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c3:	01 de                	add    %ebx,%esi
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	89 f0                	mov    %esi,%eax
  8018ca:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018cd:	72 cc                	jb     80189b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5f                   	pop    %edi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 08             	sub    $0x8,%esp
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018e6:	74 2a                	je     801912 <devcons_read+0x3b>
  8018e8:	eb 05                	jmp    8018ef <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018ea:	e8 f8 f1 ff ff       	call   800ae7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018ef:	e8 74 f1 ff ff       	call   800a68 <sys_cgetc>
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	74 f2                	je     8018ea <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 16                	js     801912 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018fc:	83 f8 04             	cmp    $0x4,%eax
  8018ff:	74 0c                	je     80190d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801901:	8b 55 0c             	mov    0xc(%ebp),%edx
  801904:	88 02                	mov    %al,(%edx)
	return 1;
  801906:	b8 01 00 00 00       	mov    $0x1,%eax
  80190b:	eb 05                	jmp    801912 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80190d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801920:	6a 01                	push   $0x1
  801922:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801925:	50                   	push   %eax
  801926:	e8 1f f1 ff ff       	call   800a4a <sys_cputs>
}
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <getchar>:

int
getchar(void)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801936:	6a 01                	push   $0x1
  801938:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	6a 00                	push   $0x0
  80193e:	e8 90 f6 ff ff       	call   800fd3 <read>
	if (r < 0)
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	78 0f                	js     801959 <getchar+0x29>
		return r;
	if (r < 1)
  80194a:	85 c0                	test   %eax,%eax
  80194c:	7e 06                	jle    801954 <getchar+0x24>
		return -E_EOF;
	return c;
  80194e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801952:	eb 05                	jmp    801959 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801954:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	ff 75 08             	pushl  0x8(%ebp)
  801968:	e8 00 f4 ff ff       	call   800d6d <fd_lookup>
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	78 11                	js     801985 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801974:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801977:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80197d:	39 10                	cmp    %edx,(%eax)
  80197f:	0f 94 c0             	sete   %al
  801982:	0f b6 c0             	movzbl %al,%eax
}
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <opencons>:

int
opencons(void)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80198d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801990:	50                   	push   %eax
  801991:	e8 88 f3 ff ff       	call   800d1e <fd_alloc>
  801996:	83 c4 10             	add    $0x10,%esp
		return r;
  801999:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 3e                	js     8019dd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	68 07 04 00 00       	push   $0x407
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 55 f1 ff ff       	call   800b06 <sys_page_alloc>
  8019b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 23                	js     8019dd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019ba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	50                   	push   %eax
  8019d3:	e8 1f f3 ff ff       	call   800cf7 <fd2num>
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	83 c4 10             	add    $0x10,%esp
}
  8019dd:	89 d0                	mov    %edx,%eax
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019e6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019e9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019ef:	e8 d4 f0 ff ff       	call   800ac8 <sys_getenvid>
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	ff 75 08             	pushl  0x8(%ebp)
  8019fd:	56                   	push   %esi
  8019fe:	50                   	push   %eax
  8019ff:	68 38 22 80 00       	push   $0x802238
  801a04:	e8 57 e7 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a09:	83 c4 18             	add    $0x18,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	ff 75 10             	pushl  0x10(%ebp)
  801a10:	e8 fa e6 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801a15:	c7 04 24 23 22 80 00 	movl   $0x802223,(%esp)
  801a1c:	e8 3f e7 ff ff       	call   800160 <cprintf>
  801a21:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a24:	cc                   	int3   
  801a25:	eb fd                	jmp    801a24 <_panic+0x43>

00801a27 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a35:	85 c0                	test   %eax,%eax
  801a37:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a3c:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	50                   	push   %eax
  801a43:	e8 6e f2 ff ff       	call   800cb6 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	75 10                	jne    801a5f <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a54:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a57:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a5a:	8b 40 70             	mov    0x70(%eax),%eax
  801a5d:	eb 0a                	jmp    801a69 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a5f:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a64:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a69:	85 f6                	test   %esi,%esi
  801a6b:	74 02                	je     801a6f <ipc_recv+0x48>
  801a6d:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	74 02                	je     801a75 <ipc_recv+0x4e>
  801a73:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5e                   	pop    %esi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	57                   	push   %edi
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a8e:	85 db                	test   %ebx,%ebx
  801a90:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a95:	0f 44 d8             	cmove  %eax,%ebx
  801a98:	eb 1c                	jmp    801ab6 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a9a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9d:	74 12                	je     801ab1 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a9f:	50                   	push   %eax
  801aa0:	68 5c 22 80 00       	push   $0x80225c
  801aa5:	6a 40                	push   $0x40
  801aa7:	68 6e 22 80 00       	push   $0x80226e
  801aac:	e8 30 ff ff ff       	call   8019e1 <_panic>
        sys_yield();
  801ab1:	e8 31 f0 ff ff       	call   800ae7 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ab6:	ff 75 14             	pushl  0x14(%ebp)
  801ab9:	53                   	push   %ebx
  801aba:	56                   	push   %esi
  801abb:	57                   	push   %edi
  801abc:	e8 d2 f1 ff ff       	call   800c93 <sys_ipc_try_send>
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	75 d2                	jne    801a9a <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801ac8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5f                   	pop    %edi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801adb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ade:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae4:	8b 52 50             	mov    0x50(%edx),%edx
  801ae7:	39 ca                	cmp    %ecx,%edx
  801ae9:	75 0d                	jne    801af8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801aeb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af3:	8b 40 48             	mov    0x48(%eax),%eax
  801af6:	eb 0f                	jmp    801b07 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af8:	83 c0 01             	add    $0x1,%eax
  801afb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b00:	75 d9                	jne    801adb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0f:	89 d0                	mov    %edx,%eax
  801b11:	c1 e8 16             	shr    $0x16,%eax
  801b14:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b20:	f6 c1 01             	test   $0x1,%cl
  801b23:	74 1d                	je     801b42 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b25:	c1 ea 0c             	shr    $0xc,%edx
  801b28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2f:	f6 c2 01             	test   $0x1,%dl
  801b32:	74 0e                	je     801b42 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b34:	c1 ea 0c             	shr    $0xc,%edx
  801b37:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3e:	ef 
  801b3f:	0f b7 c0             	movzwl %ax,%eax
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    
  801b44:	66 90                	xchg   %ax,%ax
  801b46:	66 90                	xchg   %ax,%ax
  801b48:	66 90                	xchg   %ax,%ax
  801b4a:	66 90                	xchg   %ax,%ax
  801b4c:	66 90                	xchg   %ax,%ax
  801b4e:	66 90                	xchg   %ax,%ax

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 1c             	sub    $0x1c,%esp
  801b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b67:	85 f6                	test   %esi,%esi
  801b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b6d:	89 ca                	mov    %ecx,%edx
  801b6f:	89 f8                	mov    %edi,%eax
  801b71:	75 3d                	jne    801bb0 <__udivdi3+0x60>
  801b73:	39 cf                	cmp    %ecx,%edi
  801b75:	0f 87 c5 00 00 00    	ja     801c40 <__udivdi3+0xf0>
  801b7b:	85 ff                	test   %edi,%edi
  801b7d:	89 fd                	mov    %edi,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f7                	div    %edi
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 c8                	mov    %ecx,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c1                	mov    %eax,%ecx
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	89 cf                	mov    %ecx,%edi
  801b98:	f7 f5                	div    %ebp
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	89 d8                	mov    %ebx,%eax
  801b9e:	89 fa                	mov    %edi,%edx
  801ba0:	83 c4 1c             	add    $0x1c,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
  801ba8:	90                   	nop
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	39 ce                	cmp    %ecx,%esi
  801bb2:	77 74                	ja     801c28 <__udivdi3+0xd8>
  801bb4:	0f bd fe             	bsr    %esi,%edi
  801bb7:	83 f7 1f             	xor    $0x1f,%edi
  801bba:	0f 84 98 00 00 00    	je     801c58 <__udivdi3+0x108>
  801bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	89 c5                	mov    %eax,%ebp
  801bc9:	29 fb                	sub    %edi,%ebx
  801bcb:	d3 e6                	shl    %cl,%esi
  801bcd:	89 d9                	mov    %ebx,%ecx
  801bcf:	d3 ed                	shr    %cl,%ebp
  801bd1:	89 f9                	mov    %edi,%ecx
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	09 ee                	or     %ebp,%esi
  801bd7:	89 d9                	mov    %ebx,%ecx
  801bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdd:	89 d5                	mov    %edx,%ebp
  801bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801be3:	d3 ed                	shr    %cl,%ebp
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e2                	shl    %cl,%edx
  801be9:	89 d9                	mov    %ebx,%ecx
  801beb:	d3 e8                	shr    %cl,%eax
  801bed:	09 c2                	or     %eax,%edx
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	89 ea                	mov    %ebp,%edx
  801bf3:	f7 f6                	div    %esi
  801bf5:	89 d5                	mov    %edx,%ebp
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	f7 64 24 0c          	mull   0xc(%esp)
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	72 10                	jb     801c11 <__udivdi3+0xc1>
  801c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	d3 e6                	shl    %cl,%esi
  801c09:	39 c6                	cmp    %eax,%esi
  801c0b:	73 07                	jae    801c14 <__udivdi3+0xc4>
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	75 03                	jne    801c14 <__udivdi3+0xc4>
  801c11:	83 eb 01             	sub    $0x1,%ebx
  801c14:	31 ff                	xor    %edi,%edi
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	89 fa                	mov    %edi,%edx
  801c1a:	83 c4 1c             	add    $0x1c,%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    
  801c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c28:	31 ff                	xor    %edi,%edi
  801c2a:	31 db                	xor    %ebx,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	f7 f7                	div    %edi
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	89 d8                	mov    %ebx,%eax
  801c4a:	89 fa                	mov    %edi,%edx
  801c4c:	83 c4 1c             	add    $0x1c,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5f                   	pop    %edi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	39 ce                	cmp    %ecx,%esi
  801c5a:	72 0c                	jb     801c68 <__udivdi3+0x118>
  801c5c:	31 db                	xor    %ebx,%ebx
  801c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c62:	0f 87 34 ff ff ff    	ja     801b9c <__udivdi3+0x4c>
  801c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c6d:	e9 2a ff ff ff       	jmp    801b9c <__udivdi3+0x4c>
  801c72:	66 90                	xchg   %ax,%ax
  801c74:	66 90                	xchg   %ax,%ax
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 d2                	test   %edx,%edx
  801c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ca1:	89 f3                	mov    %esi,%ebx
  801ca3:	89 3c 24             	mov    %edi,(%esp)
  801ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801caa:	75 1c                	jne    801cc8 <__umoddi3+0x48>
  801cac:	39 f7                	cmp    %esi,%edi
  801cae:	76 50                	jbe    801d00 <__umoddi3+0x80>
  801cb0:	89 c8                	mov    %ecx,%eax
  801cb2:	89 f2                	mov    %esi,%edx
  801cb4:	f7 f7                	div    %edi
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	31 d2                	xor    %edx,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	77 52                	ja     801d20 <__umoddi3+0xa0>
  801cce:	0f bd ea             	bsr    %edx,%ebp
  801cd1:	83 f5 1f             	xor    $0x1f,%ebp
  801cd4:	75 5a                	jne    801d30 <__umoddi3+0xb0>
  801cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	39 0c 24             	cmp    %ecx,(%esp)
  801ce3:	0f 86 d7 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	85 ff                	test   %edi,%edi
  801d02:	89 fd                	mov    %edi,%ebp
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 c8                	mov    %ecx,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	eb 99                	jmp    801cb8 <__umoddi3+0x38>
  801d1f:	90                   	nop
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 1c             	add    $0x1c,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	8b 34 24             	mov    (%esp),%esi
  801d33:	bf 20 00 00 00       	mov    $0x20,%edi
  801d38:	89 e9                	mov    %ebp,%ecx
  801d3a:	29 ef                	sub    %ebp,%edi
  801d3c:	d3 e0                	shl    %cl,%eax
  801d3e:	89 f9                	mov    %edi,%ecx
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	d3 ea                	shr    %cl,%edx
  801d44:	89 e9                	mov    %ebp,%ecx
  801d46:	09 c2                	or     %eax,%edx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 14 24             	mov    %edx,(%esp)
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	d3 e2                	shl    %cl,%edx
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	89 c6                	mov    %eax,%esi
  801d61:	d3 e3                	shl    %cl,%ebx
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 d0                	mov    %edx,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	09 d8                	or     %ebx,%eax
  801d6d:	89 d3                	mov    %edx,%ebx
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	f7 34 24             	divl   (%esp)
  801d74:	89 d6                	mov    %edx,%esi
  801d76:	d3 e3                	shl    %cl,%ebx
  801d78:	f7 64 24 04          	mull   0x4(%esp)
  801d7c:	39 d6                	cmp    %edx,%esi
  801d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d82:	89 d1                	mov    %edx,%ecx
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	72 08                	jb     801d90 <__umoddi3+0x110>
  801d88:	75 11                	jne    801d9b <__umoddi3+0x11b>
  801d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d8e:	73 0b                	jae    801d9b <__umoddi3+0x11b>
  801d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d94:	1b 14 24             	sbb    (%esp),%edx
  801d97:	89 d1                	mov    %edx,%ecx
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d9f:	29 da                	sub    %ebx,%edx
  801da1:	19 ce                	sbb    %ecx,%esi
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	d3 e0                	shl    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	d3 ea                	shr    %cl,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 ee                	shr    %cl,%esi
  801db1:	09 d0                	or     %edx,%eax
  801db3:	89 f2                	mov    %esi,%edx
  801db5:	83 c4 1c             	add    $0x1c,%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 f9                	sub    %edi,%ecx
  801dc2:	19 d6                	sbb    %edx,%esi
  801dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dcc:	e9 18 ff ff ff       	jmp    801ce9 <__umoddi3+0x69>
