
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 80 1e 80 00       	push   $0x801e80
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 87 0a 00 00       	call   800adb <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 3e 0a 00 00       	call   800a9a <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 99 0c 00 00       	call   800d0a <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 4b 0a 00 00       	call   800adb <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 90 0e 00 00       	call   800f61 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 bf 09 00 00       	call   800a9a <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 4d 09 00 00       	call   800a5d <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 f2 08 00 00       	call   800a5d <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 15 1a 00 00       	call   801bf0 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 02 1b 00 00       	call   801d20 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 a6 1e 80 00 	movsbl 0x801ea6(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 a7 03 00 00    	je     80066d <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8002fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800301:	eb 07                	jmp    80030a <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800306:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 07             	movzbl (%edi),%eax
  800313:	0f b6 d0             	movzbl %al,%edx
  800316:	83 e8 23             	sub    $0x23,%eax
  800319:	3c 55                	cmp    $0x55,%al
  80031b:	0f 87 31 03 00 00    	ja     800652 <vprintfmt+0x3a8>
  800321:	0f b6 c0             	movzbl %al,%eax
  800324:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800332:	eb d6                	jmp    80030a <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800337:	b8 00 00 00 00       	mov    $0x0,%eax
  80033c:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 72 d0             	lea    -0x30(%edx),%esi
  80034c:	83 fe 09             	cmp    $0x9,%esi
  80034f:	77 34                	ja     800385 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800354:	eb e9                	jmp    80033f <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8d 50 04             	lea    0x4(%eax),%edx
  80035c:	89 55 14             	mov    %edx,0x14(%ebp)
  80035f:	8b 00                	mov    (%eax),%eax
  800361:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800367:	eb 22                	jmp    80038b <vprintfmt+0xe1>
  800369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036c:	85 c0                	test   %eax,%eax
  80036e:	0f 48 c1             	cmovs  %ecx,%eax
  800371:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800377:	eb 91                	jmp    80030a <vprintfmt+0x60>
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800383:	eb 85                	jmp    80030a <vprintfmt+0x60>
  800385:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800388:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80038b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038f:	0f 89 75 ff ff ff    	jns    80030a <vprintfmt+0x60>
				width = precision, precision = -1;
  800395:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800398:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003a2:	e9 63 ff ff ff       	jmp    80030a <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a7:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ae:	e9 57 ff ff ff       	jmp    80030a <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 50 04             	lea    0x4(%eax),%edx
  8003b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	53                   	push   %ebx
  8003c0:	ff 30                	pushl  (%eax)
  8003c2:	ff d6                	call   *%esi
			break;
  8003c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ca:	e9 01 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 50 04             	lea    0x4(%eax),%edx
  8003d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	99                   	cltd   
  8003db:	31 d0                	xor    %edx,%eax
  8003dd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003df:	83 f8 0f             	cmp    $0xf,%eax
  8003e2:	7f 0b                	jg     8003ef <vprintfmt+0x145>
  8003e4:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	75 18                	jne    800407 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8003ef:	50                   	push   %eax
  8003f0:	68 be 1e 80 00       	push   $0x801ebe
  8003f5:	53                   	push   %ebx
  8003f6:	56                   	push   %esi
  8003f7:	e8 91 fe ff ff       	call   80028d <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800402:	e9 c9 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800407:	52                   	push   %edx
  800408:	68 a9 22 80 00       	push   $0x8022a9
  80040d:	53                   	push   %ebx
  80040e:	56                   	push   %esi
  80040f:	e8 79 fe ff ff       	call   80028d <printfmt>
  800414:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041a:	e9 b1 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042a:	85 ff                	test   %edi,%edi
  80042c:	b8 b7 1e 80 00       	mov    $0x801eb7,%eax
  800431:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800434:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800438:	0f 8e 94 00 00 00    	jle    8004d2 <vprintfmt+0x228>
  80043e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800442:	0f 84 98 00 00 00    	je     8004e0 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	ff 75 cc             	pushl  -0x34(%ebp)
  80044e:	57                   	push   %edi
  80044f:	e8 a1 02 00 00       	call   8006f5 <strnlen>
  800454:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800457:	29 c1                	sub    %eax,%ecx
  800459:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80045c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800469:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	eb 0f                	jmp    80047c <vprintfmt+0x1d2>
					putch(padc, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	53                   	push   %ebx
  800471:	ff 75 e0             	pushl  -0x20(%ebp)
  800474:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	83 ef 01             	sub    $0x1,%edi
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	85 ff                	test   %edi,%edi
  80047e:	7f ed                	jg     80046d <vprintfmt+0x1c3>
  800480:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800483:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800486:	85 c9                	test   %ecx,%ecx
  800488:	b8 00 00 00 00       	mov    $0x0,%eax
  80048d:	0f 49 c1             	cmovns %ecx,%eax
  800490:	29 c1                	sub    %eax,%ecx
  800492:	89 75 08             	mov    %esi,0x8(%ebp)
  800495:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800498:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049b:	89 cb                	mov    %ecx,%ebx
  80049d:	eb 4d                	jmp    8004ec <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a3:	74 1b                	je     8004c0 <vprintfmt+0x216>
  8004a5:	0f be c0             	movsbl %al,%eax
  8004a8:	83 e8 20             	sub    $0x20,%eax
  8004ab:	83 f8 5e             	cmp    $0x5e,%eax
  8004ae:	76 10                	jbe    8004c0 <vprintfmt+0x216>
					putch('?', putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	6a 3f                	push   $0x3f
  8004b8:	ff 55 08             	call   *0x8(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	eb 0d                	jmp    8004cd <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 0c             	pushl  0xc(%ebp)
  8004c6:	52                   	push   %edx
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cd:	83 eb 01             	sub    $0x1,%ebx
  8004d0:	eb 1a                	jmp    8004ec <vprintfmt+0x242>
  8004d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004de:	eb 0c                	jmp    8004ec <vprintfmt+0x242>
  8004e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ec:	83 c7 01             	add    $0x1,%edi
  8004ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f3:	0f be d0             	movsbl %al,%edx
  8004f6:	85 d2                	test   %edx,%edx
  8004f8:	74 23                	je     80051d <vprintfmt+0x273>
  8004fa:	85 f6                	test   %esi,%esi
  8004fc:	78 a1                	js     80049f <vprintfmt+0x1f5>
  8004fe:	83 ee 01             	sub    $0x1,%esi
  800501:	79 9c                	jns    80049f <vprintfmt+0x1f5>
  800503:	89 df                	mov    %ebx,%edi
  800505:	8b 75 08             	mov    0x8(%ebp),%esi
  800508:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050b:	eb 18                	jmp    800525 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	53                   	push   %ebx
  800511:	6a 20                	push   $0x20
  800513:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb 08                	jmp    800525 <vprintfmt+0x27b>
  80051d:	89 df                	mov    %ebx,%edi
  80051f:	8b 75 08             	mov    0x8(%ebp),%esi
  800522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800525:	85 ff                	test   %edi,%edi
  800527:	7f e4                	jg     80050d <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052c:	e9 9f fd ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800531:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800535:	7e 16                	jle    80054d <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 08             	lea    0x8(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 50 04             	mov    0x4(%eax),%edx
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800548:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054b:	eb 34                	jmp    800581 <vprintfmt+0x2d7>
	else if (lflag)
  80054d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800551:	74 18                	je     80056b <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 50 04             	lea    0x4(%eax),%edx
  800559:	89 55 14             	mov    %edx,0x14(%ebp)
  80055c:	8b 00                	mov    (%eax),%eax
  80055e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800561:	89 c1                	mov    %eax,%ecx
  800563:	c1 f9 1f             	sar    $0x1f,%ecx
  800566:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800569:	eb 16                	jmp    800581 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 04             	lea    0x4(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 c1                	mov    %eax,%ecx
  80057b:	c1 f9 1f             	sar    $0x1f,%ecx
  80057e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800581:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800584:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800587:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800590:	0f 89 88 00 00 00    	jns    80061e <vprintfmt+0x374>
				putch('-', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	6a 2d                	push   $0x2d
  80059c:	ff d6                	call   *%esi
				num = -(long long) num;
  80059e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005a4:	f7 d8                	neg    %eax
  8005a6:	83 d2 00             	adc    $0x0,%edx
  8005a9:	f7 da                	neg    %edx
  8005ab:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005b3:	eb 69                	jmp    80061e <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bb:	e8 76 fc ff ff       	call   800236 <getuint>
			base = 10;
  8005c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005c5:	eb 57                	jmp    80061e <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 30                	push   $0x30
  8005cd:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8005cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 5c fc ff ff       	call   800236 <getuint>
			base = 8;
			goto number;
  8005da:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005dd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e2:	eb 3a                	jmp    80061e <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 30                	push   $0x30
  8005ea:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ec:	83 c4 08             	add    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 78                	push   $0x78
  8005f2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800604:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800607:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060c:	eb 10                	jmp    80061e <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 1d fc ff ff       	call   800236 <getuint>
			base = 16;
  800619:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061e:	83 ec 0c             	sub    $0xc,%esp
  800621:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800625:	57                   	push   %edi
  800626:	ff 75 e0             	pushl  -0x20(%ebp)
  800629:	51                   	push   %ecx
  80062a:	52                   	push   %edx
  80062b:	50                   	push   %eax
  80062c:	89 da                	mov    %ebx,%edx
  80062e:	89 f0                	mov    %esi,%eax
  800630:	e8 52 fb ff ff       	call   800187 <printnum>
			break;
  800635:	83 c4 20             	add    $0x20,%esp
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063b:	e9 90 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	52                   	push   %edx
  800645:	ff d6                	call   *%esi
			break;
  800647:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064d:	e9 7e fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 25                	push   $0x25
  800658:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	eb 03                	jmp    800662 <vprintfmt+0x3b8>
  80065f:	83 ef 01             	sub    $0x1,%edi
  800662:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800666:	75 f7                	jne    80065f <vprintfmt+0x3b5>
  800668:	e9 63 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800670:	5b                   	pop    %ebx
  800671:	5e                   	pop    %esi
  800672:	5f                   	pop    %edi
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 18             	sub    $0x18,%esp
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800681:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800684:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800688:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800692:	85 c0                	test   %eax,%eax
  800694:	74 26                	je     8006bc <vsnprintf+0x47>
  800696:	85 d2                	test   %edx,%edx
  800698:	7e 22                	jle    8006bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069a:	ff 75 14             	pushl  0x14(%ebp)
  80069d:	ff 75 10             	pushl  0x10(%ebp)
  8006a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	68 70 02 80 00       	push   $0x800270
  8006a9:	e8 fc fb ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 05                	jmp    8006c1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cc:	50                   	push   %eax
  8006cd:	ff 75 10             	pushl  0x10(%ebp)
  8006d0:	ff 75 0c             	pushl  0xc(%ebp)
  8006d3:	ff 75 08             	pushl  0x8(%ebp)
  8006d6:	e8 9a ff ff ff       	call   800675 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	eb 03                	jmp    8006ed <strlen+0x10>
		n++;
  8006ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f1:	75 f7                	jne    8006ea <strlen+0xd>
		n++;
	return n;
}
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800703:	eb 03                	jmp    800708 <strnlen+0x13>
		n++;
  800705:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800708:	39 c2                	cmp    %eax,%edx
  80070a:	74 08                	je     800714 <strnlen+0x1f>
  80070c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800710:	75 f3                	jne    800705 <strnlen+0x10>
  800712:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800720:	89 c2                	mov    %eax,%edx
  800722:	83 c2 01             	add    $0x1,%edx
  800725:	83 c1 01             	add    $0x1,%ecx
  800728:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072f:	84 db                	test   %bl,%bl
  800731:	75 ef                	jne    800722 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800733:	5b                   	pop    %ebx
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073d:	53                   	push   %ebx
  80073e:	e8 9a ff ff ff       	call   8006dd <strlen>
  800743:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	50                   	push   %eax
  80074c:	e8 c5 ff ff ff       	call   800716 <strcpy>
	return dst;
}
  800751:	89 d8                	mov    %ebx,%eax
  800753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	8b 75 08             	mov    0x8(%ebp),%esi
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	89 f3                	mov    %esi,%ebx
  800765:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800768:	89 f2                	mov    %esi,%edx
  80076a:	eb 0f                	jmp    80077b <strncpy+0x23>
		*dst++ = *src;
  80076c:	83 c2 01             	add    $0x1,%edx
  80076f:	0f b6 01             	movzbl (%ecx),%eax
  800772:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 39 01             	cmpb   $0x1,(%ecx)
  800778:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	39 da                	cmp    %ebx,%edx
  80077d:	75 ed                	jne    80076c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077f:	89 f0                	mov    %esi,%eax
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	8b 55 10             	mov    0x10(%ebp),%edx
  800793:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800795:	85 d2                	test   %edx,%edx
  800797:	74 21                	je     8007ba <strlcpy+0x35>
  800799:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079d:	89 f2                	mov    %esi,%edx
  80079f:	eb 09                	jmp    8007aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	83 c1 01             	add    $0x1,%ecx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 09                	je     8007b7 <strlcpy+0x32>
  8007ae:	0f b6 19             	movzbl (%ecx),%ebx
  8007b1:	84 db                	test   %bl,%bl
  8007b3:	75 ec                	jne    8007a1 <strlcpy+0x1c>
  8007b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ba:	29 f0                	sub    %esi,%eax
}
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c9:	eb 06                	jmp    8007d1 <strcmp+0x11>
		p++, q++;
  8007cb:	83 c1 01             	add    $0x1,%ecx
  8007ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d1:	0f b6 01             	movzbl (%ecx),%eax
  8007d4:	84 c0                	test   %al,%al
  8007d6:	74 04                	je     8007dc <strcmp+0x1c>
  8007d8:	3a 02                	cmp    (%edx),%al
  8007da:	74 ef                	je     8007cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dc:	0f b6 c0             	movzbl %al,%eax
  8007df:	0f b6 12             	movzbl (%edx),%edx
  8007e2:	29 d0                	sub    %edx,%eax
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	89 c3                	mov    %eax,%ebx
  8007f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f5:	eb 06                	jmp    8007fd <strncmp+0x17>
		n--, p++, q++;
  8007f7:	83 c0 01             	add    $0x1,%eax
  8007fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fd:	39 d8                	cmp    %ebx,%eax
  8007ff:	74 15                	je     800816 <strncmp+0x30>
  800801:	0f b6 08             	movzbl (%eax),%ecx
  800804:	84 c9                	test   %cl,%cl
  800806:	74 04                	je     80080c <strncmp+0x26>
  800808:	3a 0a                	cmp    (%edx),%cl
  80080a:	74 eb                	je     8007f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080c:	0f b6 00             	movzbl (%eax),%eax
  80080f:	0f b6 12             	movzbl (%edx),%edx
  800812:	29 d0                	sub    %edx,%eax
  800814:	eb 05                	jmp    80081b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081b:	5b                   	pop    %ebx
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800828:	eb 07                	jmp    800831 <strchr+0x13>
		if (*s == c)
  80082a:	38 ca                	cmp    %cl,%dl
  80082c:	74 0f                	je     80083d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082e:	83 c0 01             	add    $0x1,%eax
  800831:	0f b6 10             	movzbl (%eax),%edx
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f2                	jne    80082a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800849:	eb 03                	jmp    80084e <strfind+0xf>
  80084b:	83 c0 01             	add    $0x1,%eax
  80084e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 04                	je     800859 <strfind+0x1a>
  800855:	84 d2                	test   %dl,%dl
  800857:	75 f2                	jne    80084b <strfind+0xc>
			break;
	return (char *) s;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	57                   	push   %edi
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 7d 08             	mov    0x8(%ebp),%edi
  800864:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800867:	85 c9                	test   %ecx,%ecx
  800869:	74 36                	je     8008a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800871:	75 28                	jne    80089b <memset+0x40>
  800873:	f6 c1 03             	test   $0x3,%cl
  800876:	75 23                	jne    80089b <memset+0x40>
		c &= 0xFF;
  800878:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087c:	89 d3                	mov    %edx,%ebx
  80087e:	c1 e3 08             	shl    $0x8,%ebx
  800881:	89 d6                	mov    %edx,%esi
  800883:	c1 e6 18             	shl    $0x18,%esi
  800886:	89 d0                	mov    %edx,%eax
  800888:	c1 e0 10             	shl    $0x10,%eax
  80088b:	09 f0                	or     %esi,%eax
  80088d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088f:	89 d8                	mov    %ebx,%eax
  800891:	09 d0                	or     %edx,%eax
  800893:	c1 e9 02             	shr    $0x2,%ecx
  800896:	fc                   	cld    
  800897:	f3 ab                	rep stos %eax,%es:(%edi)
  800899:	eb 06                	jmp    8008a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	fc                   	cld    
  80089f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b6:	39 c6                	cmp    %eax,%esi
  8008b8:	73 35                	jae    8008ef <memmove+0x47>
  8008ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bd:	39 d0                	cmp    %edx,%eax
  8008bf:	73 2e                	jae    8008ef <memmove+0x47>
		s += n;
		d += n;
  8008c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c4:	89 d6                	mov    %edx,%esi
  8008c6:	09 fe                	or     %edi,%esi
  8008c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ce:	75 13                	jne    8008e3 <memmove+0x3b>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 0e                	jne    8008e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d5:	83 ef 04             	sub    $0x4,%edi
  8008d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008db:	c1 e9 02             	shr    $0x2,%ecx
  8008de:	fd                   	std    
  8008df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e1:	eb 09                	jmp    8008ec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e3:	83 ef 01             	sub    $0x1,%edi
  8008e6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e9:	fd                   	std    
  8008ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ec:	fc                   	cld    
  8008ed:	eb 1d                	jmp    80090c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ef:	89 f2                	mov    %esi,%edx
  8008f1:	09 c2                	or     %eax,%edx
  8008f3:	f6 c2 03             	test   $0x3,%dl
  8008f6:	75 0f                	jne    800907 <memmove+0x5f>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 0a                	jne    800907 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	89 c7                	mov    %eax,%edi
  800902:	fc                   	cld    
  800903:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800905:	eb 05                	jmp    80090c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800907:	89 c7                	mov    %eax,%edi
  800909:	fc                   	cld    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090c:	5e                   	pop    %esi
  80090d:	5f                   	pop    %edi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800913:	ff 75 10             	pushl  0x10(%ebp)
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	ff 75 08             	pushl  0x8(%ebp)
  80091c:	e8 87 ff ff ff       	call   8008a8 <memmove>
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800933:	eb 1a                	jmp    80094f <memcmp+0x2c>
		if (*s1 != *s2)
  800935:	0f b6 08             	movzbl (%eax),%ecx
  800938:	0f b6 1a             	movzbl (%edx),%ebx
  80093b:	38 d9                	cmp    %bl,%cl
  80093d:	74 0a                	je     800949 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093f:	0f b6 c1             	movzbl %cl,%eax
  800942:	0f b6 db             	movzbl %bl,%ebx
  800945:	29 d8                	sub    %ebx,%eax
  800947:	eb 0f                	jmp    800958 <memcmp+0x35>
		s1++, s2++;
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094f:	39 f0                	cmp    %esi,%eax
  800951:	75 e2                	jne    800935 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800963:	89 c1                	mov    %eax,%ecx
  800965:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800968:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096c:	eb 0a                	jmp    800978 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096e:	0f b6 10             	movzbl (%eax),%edx
  800971:	39 da                	cmp    %ebx,%edx
  800973:	74 07                	je     80097c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	39 c8                	cmp    %ecx,%eax
  80097a:	72 f2                	jb     80096e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097c:	5b                   	pop    %ebx
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800988:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098b:	eb 03                	jmp    800990 <strtol+0x11>
		s++;
  80098d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800990:	0f b6 01             	movzbl (%ecx),%eax
  800993:	3c 20                	cmp    $0x20,%al
  800995:	74 f6                	je     80098d <strtol+0xe>
  800997:	3c 09                	cmp    $0x9,%al
  800999:	74 f2                	je     80098d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099b:	3c 2b                	cmp    $0x2b,%al
  80099d:	75 0a                	jne    8009a9 <strtol+0x2a>
		s++;
  80099f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a7:	eb 11                	jmp    8009ba <strtol+0x3b>
  8009a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ae:	3c 2d                	cmp    $0x2d,%al
  8009b0:	75 08                	jne    8009ba <strtol+0x3b>
		s++, neg = 1;
  8009b2:	83 c1 01             	add    $0x1,%ecx
  8009b5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c0:	75 15                	jne    8009d7 <strtol+0x58>
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 10                	jne    8009d7 <strtol+0x58>
  8009c7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cb:	75 7c                	jne    800a49 <strtol+0xca>
		s += 2, base = 16;
  8009cd:	83 c1 02             	add    $0x2,%ecx
  8009d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d5:	eb 16                	jmp    8009ed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	75 12                	jne    8009ed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009db:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e3:	75 08                	jne    8009ed <strtol+0x6e>
		s++, base = 8;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f5:	0f b6 11             	movzbl (%ecx),%edx
  8009f8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fb:	89 f3                	mov    %esi,%ebx
  8009fd:	80 fb 09             	cmp    $0x9,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x8b>
			dig = *s - '0';
  800a02:	0f be d2             	movsbl %dl,%edx
  800a05:	83 ea 30             	sub    $0x30,%edx
  800a08:	eb 22                	jmp    800a2c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 19             	cmp    $0x19,%bl
  800a12:	77 08                	ja     800a1c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 57             	sub    $0x57,%edx
  800a1a:	eb 10                	jmp    800a2c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 16                	ja     800a3c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2f:	7d 0b                	jge    800a3c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a31:	83 c1 01             	add    $0x1,%ecx
  800a34:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a38:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3a:	eb b9                	jmp    8009f5 <strtol+0x76>

	if (endptr)
  800a3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a40:	74 0d                	je     800a4f <strtol+0xd0>
		*endptr = (char *) s;
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	89 0e                	mov    %ecx,(%esi)
  800a47:	eb 06                	jmp    800a4f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a49:	85 db                	test   %ebx,%ebx
  800a4b:	74 98                	je     8009e5 <strtol+0x66>
  800a4d:	eb 9e                	jmp    8009ed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	f7 da                	neg    %edx
  800a53:	85 ff                	test   %edi,%edi
  800a55:	0f 45 c2             	cmovne %edx,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	89 c7                	mov    %eax,%edi
  800a72:	89 c6                	mov    %eax,%esi
  800a74:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8b:	89 d1                	mov    %edx,%ecx
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	89 d7                	mov    %edx,%edi
  800a91:	89 d6                	mov    %edx,%esi
  800a93:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa8:	b8 03 00 00 00       	mov    $0x3,%eax
  800aad:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab0:	89 cb                	mov    %ecx,%ebx
  800ab2:	89 cf                	mov    %ecx,%edi
  800ab4:	89 ce                	mov    %ecx,%esi
  800ab6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	7e 17                	jle    800ad3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abc:	83 ec 0c             	sub    $0xc,%esp
  800abf:	50                   	push   %eax
  800ac0:	6a 03                	push   $0x3
  800ac2:	68 9f 21 80 00       	push   $0x80219f
  800ac7:	6a 23                	push   $0x23
  800ac9:	68 bc 21 80 00       	push   $0x8021bc
  800ace:	e8 ad 0f 00 00       	call   801a80 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_yield>:

void
sys_yield(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	be 00 00 00 00       	mov    $0x0,%esi
  800b27:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b35:	89 f7                	mov    %esi,%edi
  800b37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 17                	jle    800b54 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 04                	push   $0x4
  800b43:	68 9f 21 80 00       	push   $0x80219f
  800b48:	6a 23                	push   $0x23
  800b4a:	68 bc 21 80 00       	push   $0x8021bc
  800b4f:	e8 2c 0f 00 00       	call   801a80 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b76:	8b 75 18             	mov    0x18(%ebp),%esi
  800b79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 17                	jle    800b96 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	50                   	push   %eax
  800b83:	6a 05                	push   $0x5
  800b85:	68 9f 21 80 00       	push   $0x80219f
  800b8a:	6a 23                	push   $0x23
  800b8c:	68 bc 21 80 00       	push   $0x8021bc
  800b91:	e8 ea 0e 00 00       	call   801a80 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bac:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 df                	mov    %ebx,%edi
  800bb9:	89 de                	mov    %ebx,%esi
  800bbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 06                	push   $0x6
  800bc7:	68 9f 21 80 00       	push   $0x80219f
  800bcc:	6a 23                	push   $0x23
  800bce:	68 bc 21 80 00       	push   $0x8021bc
  800bd3:	e8 a8 0e 00 00       	call   801a80 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bee:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 df                	mov    %ebx,%edi
  800bfb:	89 de                	mov    %ebx,%esi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 08                	push   $0x8
  800c09:	68 9f 21 80 00       	push   $0x80219f
  800c0e:	6a 23                	push   $0x23
  800c10:	68 bc 21 80 00       	push   $0x8021bc
  800c15:	e8 66 0e 00 00       	call   801a80 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	b8 09 00 00 00       	mov    $0x9,%eax
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 09                	push   $0x9
  800c4b:	68 9f 21 80 00       	push   $0x80219f
  800c50:	6a 23                	push   $0x23
  800c52:	68 bc 21 80 00       	push   $0x8021bc
  800c57:	e8 24 0e 00 00       	call   801a80 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 0a                	push   $0xa
  800c8d:	68 9f 21 80 00       	push   $0x80219f
  800c92:	6a 23                	push   $0x23
  800c94:	68 bc 21 80 00       	push   $0x8021bc
  800c99:	e8 e2 0d 00 00       	call   801a80 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	be 00 00 00 00       	mov    $0x0,%esi
  800cb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 cb                	mov    %ecx,%ebx
  800ce1:	89 cf                	mov    %ecx,%edi
  800ce3:	89 ce                	mov    %ecx,%esi
  800ce5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 0d                	push   $0xd
  800cf1:	68 9f 21 80 00       	push   $0x80219f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 bc 21 80 00       	push   $0x8021bc
  800cfd:	e8 7e 0d 00 00       	call   801a80 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  800d10:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d17:	75 36                	jne    800d4f <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800d19:	a1 04 40 80 00       	mov    0x804004,%eax
  800d1e:	8b 40 48             	mov    0x48(%eax),%eax
  800d21:	83 ec 04             	sub    $0x4,%esp
  800d24:	68 07 0e 00 00       	push   $0xe07
  800d29:	68 00 f0 bf ee       	push   $0xeebff000
  800d2e:	50                   	push   %eax
  800d2f:	e8 e5 fd ff ff       	call   800b19 <sys_page_alloc>
		if (ret < 0) {
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	85 c0                	test   %eax,%eax
  800d39:	79 14                	jns    800d4f <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  800d3b:	83 ec 04             	sub    $0x4,%esp
  800d3e:	68 cc 21 80 00       	push   $0x8021cc
  800d43:	6a 23                	push   $0x23
  800d45:	68 f3 21 80 00       	push   $0x8021f3
  800d4a:	e8 31 0d 00 00       	call   801a80 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800d4f:	a1 04 40 80 00       	mov    0x804004,%eax
  800d54:	8b 40 48             	mov    0x48(%eax),%eax
  800d57:	83 ec 08             	sub    $0x8,%esp
  800d5a:	68 72 0d 80 00       	push   $0x800d72
  800d5f:	50                   	push   %eax
  800d60:	e8 ff fe ff ff       	call   800c64 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    

00800d72 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d72:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d73:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d78:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d7a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  800d7d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  800d81:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  800d86:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  800d8a:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  800d8c:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800d8f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800d90:	83 c4 04             	add    $0x4,%esp
        popfl
  800d93:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800d94:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800d95:	c3                   	ret    

00800d96 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	05 00 00 00 30       	add    $0x30000000,%eax
  800da1:	c1 e8 0c             	shr    $0xc,%eax
}
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	05 00 00 00 30       	add    $0x30000000,%eax
  800db1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800db6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dc8:	89 c2                	mov    %eax,%edx
  800dca:	c1 ea 16             	shr    $0x16,%edx
  800dcd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd4:	f6 c2 01             	test   $0x1,%dl
  800dd7:	74 11                	je     800dea <fd_alloc+0x2d>
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	c1 ea 0c             	shr    $0xc,%edx
  800dde:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de5:	f6 c2 01             	test   $0x1,%dl
  800de8:	75 09                	jne    800df3 <fd_alloc+0x36>
			*fd_store = fd;
  800dea:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	eb 17                	jmp    800e0a <fd_alloc+0x4d>
  800df3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800df8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dfd:	75 c9                	jne    800dc8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dff:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e05:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e12:	83 f8 1f             	cmp    $0x1f,%eax
  800e15:	77 36                	ja     800e4d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e17:	c1 e0 0c             	shl    $0xc,%eax
  800e1a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e1f:	89 c2                	mov    %eax,%edx
  800e21:	c1 ea 16             	shr    $0x16,%edx
  800e24:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2b:	f6 c2 01             	test   $0x1,%dl
  800e2e:	74 24                	je     800e54 <fd_lookup+0x48>
  800e30:	89 c2                	mov    %eax,%edx
  800e32:	c1 ea 0c             	shr    $0xc,%edx
  800e35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3c:	f6 c2 01             	test   $0x1,%dl
  800e3f:	74 1a                	je     800e5b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e44:	89 02                	mov    %eax,(%edx)
	return 0;
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	eb 13                	jmp    800e60 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e52:	eb 0c                	jmp    800e60 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e59:	eb 05                	jmp    800e60 <fd_lookup+0x54>
  800e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6b:	ba 80 22 80 00       	mov    $0x802280,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e70:	eb 13                	jmp    800e85 <dev_lookup+0x23>
  800e72:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e75:	39 08                	cmp    %ecx,(%eax)
  800e77:	75 0c                	jne    800e85 <dev_lookup+0x23>
			*dev = devtab[i];
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	eb 2e                	jmp    800eb3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e85:	8b 02                	mov    (%edx),%eax
  800e87:	85 c0                	test   %eax,%eax
  800e89:	75 e7                	jne    800e72 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e8b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e90:	8b 40 48             	mov    0x48(%eax),%eax
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	51                   	push   %ecx
  800e97:	50                   	push   %eax
  800e98:	68 04 22 80 00       	push   $0x802204
  800e9d:	e8 d1 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 10             	sub    $0x10,%esp
  800ebd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ec0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec6:	50                   	push   %eax
  800ec7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ecd:	c1 e8 0c             	shr    $0xc,%eax
  800ed0:	50                   	push   %eax
  800ed1:	e8 36 ff ff ff       	call   800e0c <fd_lookup>
  800ed6:	83 c4 08             	add    $0x8,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	78 05                	js     800ee2 <fd_close+0x2d>
	    || fd != fd2)
  800edd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ee0:	74 0c                	je     800eee <fd_close+0x39>
		return (must_exist ? r : 0);
  800ee2:	84 db                	test   %bl,%bl
  800ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee9:	0f 44 c2             	cmove  %edx,%eax
  800eec:	eb 41                	jmp    800f2f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eee:	83 ec 08             	sub    $0x8,%esp
  800ef1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ef4:	50                   	push   %eax
  800ef5:	ff 36                	pushl  (%esi)
  800ef7:	e8 66 ff ff ff       	call   800e62 <dev_lookup>
  800efc:	89 c3                	mov    %eax,%ebx
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	78 1a                	js     800f1f <fd_close+0x6a>
		if (dev->dev_close)
  800f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f08:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f0b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f10:	85 c0                	test   %eax,%eax
  800f12:	74 0b                	je     800f1f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	56                   	push   %esi
  800f18:	ff d0                	call   *%eax
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	56                   	push   %esi
  800f23:	6a 00                	push   $0x0
  800f25:	e8 74 fc ff ff       	call   800b9e <sys_page_unmap>
	return r;
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	89 d8                	mov    %ebx,%eax
}
  800f2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3f:	50                   	push   %eax
  800f40:	ff 75 08             	pushl  0x8(%ebp)
  800f43:	e8 c4 fe ff ff       	call   800e0c <fd_lookup>
  800f48:	83 c4 08             	add    $0x8,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 10                	js     800f5f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f4f:	83 ec 08             	sub    $0x8,%esp
  800f52:	6a 01                	push   $0x1
  800f54:	ff 75 f4             	pushl  -0xc(%ebp)
  800f57:	e8 59 ff ff ff       	call   800eb5 <fd_close>
  800f5c:	83 c4 10             	add    $0x10,%esp
}
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <close_all>:

void
close_all(void)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	53                   	push   %ebx
  800f65:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f68:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	53                   	push   %ebx
  800f71:	e8 c0 ff ff ff       	call   800f36 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f76:	83 c3 01             	add    $0x1,%ebx
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	83 fb 20             	cmp    $0x20,%ebx
  800f7f:	75 ec                	jne    800f6d <close_all+0xc>
		close(i);
}
  800f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	53                   	push   %ebx
  800f8c:	83 ec 2c             	sub    $0x2c,%esp
  800f8f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f92:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	ff 75 08             	pushl  0x8(%ebp)
  800f99:	e8 6e fe ff ff       	call   800e0c <fd_lookup>
  800f9e:	83 c4 08             	add    $0x8,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	0f 88 c1 00 00 00    	js     80106a <dup+0xe4>
		return r;
	close(newfdnum);
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	56                   	push   %esi
  800fad:	e8 84 ff ff ff       	call   800f36 <close>

	newfd = INDEX2FD(newfdnum);
  800fb2:	89 f3                	mov    %esi,%ebx
  800fb4:	c1 e3 0c             	shl    $0xc,%ebx
  800fb7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fbd:	83 c4 04             	add    $0x4,%esp
  800fc0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc3:	e8 de fd ff ff       	call   800da6 <fd2data>
  800fc8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fca:	89 1c 24             	mov    %ebx,(%esp)
  800fcd:	e8 d4 fd ff ff       	call   800da6 <fd2data>
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd8:	89 f8                	mov    %edi,%eax
  800fda:	c1 e8 16             	shr    $0x16,%eax
  800fdd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe4:	a8 01                	test   $0x1,%al
  800fe6:	74 37                	je     80101f <dup+0x99>
  800fe8:	89 f8                	mov    %edi,%eax
  800fea:	c1 e8 0c             	shr    $0xc,%eax
  800fed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff4:	f6 c2 01             	test   $0x1,%dl
  800ff7:	74 26                	je     80101f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ff9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	25 07 0e 00 00       	and    $0xe07,%eax
  801008:	50                   	push   %eax
  801009:	ff 75 d4             	pushl  -0x2c(%ebp)
  80100c:	6a 00                	push   $0x0
  80100e:	57                   	push   %edi
  80100f:	6a 00                	push   $0x0
  801011:	e8 46 fb ff ff       	call   800b5c <sys_page_map>
  801016:	89 c7                	mov    %eax,%edi
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 2e                	js     80104d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80101f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801022:	89 d0                	mov    %edx,%eax
  801024:	c1 e8 0c             	shr    $0xc,%eax
  801027:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	25 07 0e 00 00       	and    $0xe07,%eax
  801036:	50                   	push   %eax
  801037:	53                   	push   %ebx
  801038:	6a 00                	push   $0x0
  80103a:	52                   	push   %edx
  80103b:	6a 00                	push   $0x0
  80103d:	e8 1a fb ff ff       	call   800b5c <sys_page_map>
  801042:	89 c7                	mov    %eax,%edi
  801044:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801047:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801049:	85 ff                	test   %edi,%edi
  80104b:	79 1d                	jns    80106a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	53                   	push   %ebx
  801051:	6a 00                	push   $0x0
  801053:	e8 46 fb ff ff       	call   800b9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801058:	83 c4 08             	add    $0x8,%esp
  80105b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80105e:	6a 00                	push   $0x0
  801060:	e8 39 fb ff ff       	call   800b9e <sys_page_unmap>
	return r;
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	89 f8                	mov    %edi,%eax
}
  80106a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5f                   	pop    %edi
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	53                   	push   %ebx
  801076:	83 ec 14             	sub    $0x14,%esp
  801079:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80107c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107f:	50                   	push   %eax
  801080:	53                   	push   %ebx
  801081:	e8 86 fd ff ff       	call   800e0c <fd_lookup>
  801086:	83 c4 08             	add    $0x8,%esp
  801089:	89 c2                	mov    %eax,%edx
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 6d                	js     8010fc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108f:	83 ec 08             	sub    $0x8,%esp
  801092:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801099:	ff 30                	pushl  (%eax)
  80109b:	e8 c2 fd ff ff       	call   800e62 <dev_lookup>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 4c                	js     8010f3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010aa:	8b 42 08             	mov    0x8(%edx),%eax
  8010ad:	83 e0 03             	and    $0x3,%eax
  8010b0:	83 f8 01             	cmp    $0x1,%eax
  8010b3:	75 21                	jne    8010d6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ba:	8b 40 48             	mov    0x48(%eax),%eax
  8010bd:	83 ec 04             	sub    $0x4,%esp
  8010c0:	53                   	push   %ebx
  8010c1:	50                   	push   %eax
  8010c2:	68 45 22 80 00       	push   $0x802245
  8010c7:	e8 a7 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010d4:	eb 26                	jmp    8010fc <read+0x8a>
	}
	if (!dev->dev_read)
  8010d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d9:	8b 40 08             	mov    0x8(%eax),%eax
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	74 17                	je     8010f7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	ff 75 10             	pushl  0x10(%ebp)
  8010e6:	ff 75 0c             	pushl  0xc(%ebp)
  8010e9:	52                   	push   %edx
  8010ea:	ff d0                	call   *%eax
  8010ec:	89 c2                	mov    %eax,%edx
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	eb 09                	jmp    8010fc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	eb 05                	jmp    8010fc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010fc:	89 d0                	mov    %edx,%eax
  8010fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	57                   	push   %edi
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80110f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801112:	bb 00 00 00 00       	mov    $0x0,%ebx
  801117:	eb 21                	jmp    80113a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	89 f0                	mov    %esi,%eax
  80111e:	29 d8                	sub    %ebx,%eax
  801120:	50                   	push   %eax
  801121:	89 d8                	mov    %ebx,%eax
  801123:	03 45 0c             	add    0xc(%ebp),%eax
  801126:	50                   	push   %eax
  801127:	57                   	push   %edi
  801128:	e8 45 ff ff ff       	call   801072 <read>
		if (m < 0)
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 10                	js     801144 <readn+0x41>
			return m;
		if (m == 0)
  801134:	85 c0                	test   %eax,%eax
  801136:	74 0a                	je     801142 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801138:	01 c3                	add    %eax,%ebx
  80113a:	39 f3                	cmp    %esi,%ebx
  80113c:	72 db                	jb     801119 <readn+0x16>
  80113e:	89 d8                	mov    %ebx,%eax
  801140:	eb 02                	jmp    801144 <readn+0x41>
  801142:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	53                   	push   %ebx
  801150:	83 ec 14             	sub    $0x14,%esp
  801153:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801156:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	53                   	push   %ebx
  80115b:	e8 ac fc ff ff       	call   800e0c <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	89 c2                	mov    %eax,%edx
  801165:	85 c0                	test   %eax,%eax
  801167:	78 68                	js     8011d1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801173:	ff 30                	pushl  (%eax)
  801175:	e8 e8 fc ff ff       	call   800e62 <dev_lookup>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 47                	js     8011c8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801188:	75 21                	jne    8011ab <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80118a:	a1 04 40 80 00       	mov    0x804004,%eax
  80118f:	8b 40 48             	mov    0x48(%eax),%eax
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	53                   	push   %ebx
  801196:	50                   	push   %eax
  801197:	68 61 22 80 00       	push   $0x802261
  80119c:	e8 d2 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a9:	eb 26                	jmp    8011d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8011b1:	85 d2                	test   %edx,%edx
  8011b3:	74 17                	je     8011cc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	ff 75 10             	pushl  0x10(%ebp)
  8011bb:	ff 75 0c             	pushl  0xc(%ebp)
  8011be:	50                   	push   %eax
  8011bf:	ff d2                	call   *%edx
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	eb 09                	jmp    8011d1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	eb 05                	jmp    8011d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011d1:	89 d0                	mov    %edx,%eax
  8011d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011de:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	ff 75 08             	pushl  0x8(%ebp)
  8011e5:	e8 22 fc ff ff       	call   800e0c <fd_lookup>
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 0e                	js     8011ff <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	53                   	push   %ebx
  801205:	83 ec 14             	sub    $0x14,%esp
  801208:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120e:	50                   	push   %eax
  80120f:	53                   	push   %ebx
  801210:	e8 f7 fb ff ff       	call   800e0c <fd_lookup>
  801215:	83 c4 08             	add    $0x8,%esp
  801218:	89 c2                	mov    %eax,%edx
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 65                	js     801283 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801228:	ff 30                	pushl  (%eax)
  80122a:	e8 33 fc ff ff       	call   800e62 <dev_lookup>
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 44                	js     80127a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801239:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80123d:	75 21                	jne    801260 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80123f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801244:	8b 40 48             	mov    0x48(%eax),%eax
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	53                   	push   %ebx
  80124b:	50                   	push   %eax
  80124c:	68 24 22 80 00       	push   $0x802224
  801251:	e8 1d ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125e:	eb 23                	jmp    801283 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801260:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801263:	8b 52 18             	mov    0x18(%edx),%edx
  801266:	85 d2                	test   %edx,%edx
  801268:	74 14                	je     80127e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	ff 75 0c             	pushl  0xc(%ebp)
  801270:	50                   	push   %eax
  801271:	ff d2                	call   *%edx
  801273:	89 c2                	mov    %eax,%edx
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	eb 09                	jmp    801283 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	eb 05                	jmp    801283 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80127e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801283:	89 d0                	mov    %edx,%eax
  801285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	53                   	push   %ebx
  80128e:	83 ec 14             	sub    $0x14,%esp
  801291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801294:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	ff 75 08             	pushl  0x8(%ebp)
  80129b:	e8 6c fb ff ff       	call   800e0c <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 58                	js     801301 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b3:	ff 30                	pushl  (%eax)
  8012b5:	e8 a8 fb ff ff       	call   800e62 <dev_lookup>
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 37                	js     8012f8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012c8:	74 32                	je     8012fc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ca:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012cd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012d4:	00 00 00 
	stat->st_isdir = 0;
  8012d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012de:	00 00 00 
	stat->st_dev = dev;
  8012e1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	53                   	push   %ebx
  8012eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ee:	ff 50 14             	call   *0x14(%eax)
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	eb 09                	jmp    801301 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	eb 05                	jmp    801301 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801301:	89 d0                	mov    %edx,%eax
  801303:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	6a 00                	push   $0x0
  801312:	ff 75 08             	pushl  0x8(%ebp)
  801315:	e8 e3 01 00 00       	call   8014fd <open>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 1b                	js     80133e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	ff 75 0c             	pushl  0xc(%ebp)
  801329:	50                   	push   %eax
  80132a:	e8 5b ff ff ff       	call   80128a <fstat>
  80132f:	89 c6                	mov    %eax,%esi
	close(fd);
  801331:	89 1c 24             	mov    %ebx,(%esp)
  801334:	e8 fd fb ff ff       	call   800f36 <close>
	return r;
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	89 f0                	mov    %esi,%eax
}
  80133e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	56                   	push   %esi
  801349:	53                   	push   %ebx
  80134a:	89 c6                	mov    %eax,%esi
  80134c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80134e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801355:	75 12                	jne    801369 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	6a 01                	push   $0x1
  80135c:	e8 0e 08 00 00       	call   801b6f <ipc_find_env>
  801361:	a3 00 40 80 00       	mov    %eax,0x804000
  801366:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801369:	6a 07                	push   $0x7
  80136b:	68 00 50 80 00       	push   $0x805000
  801370:	56                   	push   %esi
  801371:	ff 35 00 40 80 00    	pushl  0x804000
  801377:	e8 9f 07 00 00       	call   801b1b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80137c:	83 c4 0c             	add    $0xc,%esp
  80137f:	6a 00                	push   $0x0
  801381:	53                   	push   %ebx
  801382:	6a 00                	push   $0x0
  801384:	e8 3d 07 00 00       	call   801ac6 <ipc_recv>
}
  801389:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	8b 40 0c             	mov    0xc(%eax),%eax
  80139c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b3:	e8 8d ff ff ff       	call   801345 <fsipc>
}
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8013d5:	e8 6b ff ff ff       	call   801345 <fsipc>
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ec:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8013fb:	e8 45 ff ff ff       	call   801345 <fsipc>
  801400:	85 c0                	test   %eax,%eax
  801402:	78 2c                	js     801430 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	68 00 50 80 00       	push   $0x805000
  80140c:	53                   	push   %ebx
  80140d:	e8 04 f3 ff ff       	call   800716 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801412:	a1 80 50 80 00       	mov    0x805080,%eax
  801417:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80141d:	a1 84 50 80 00       	mov    0x805084,%eax
  801422:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80143e:	8b 55 08             	mov    0x8(%ebp),%edx
  801441:	8b 52 0c             	mov    0xc(%edx),%edx
  801444:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80144a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80144f:	ba 00 10 00 00       	mov    $0x1000,%edx
  801454:	0f 47 c2             	cmova  %edx,%eax
  801457:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80145c:	50                   	push   %eax
  80145d:	ff 75 0c             	pushl  0xc(%ebp)
  801460:	68 08 50 80 00       	push   $0x805008
  801465:	e8 3e f4 ff ff       	call   8008a8 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80146a:	ba 00 00 00 00       	mov    $0x0,%edx
  80146f:	b8 04 00 00 00       	mov    $0x4,%eax
  801474:	e8 cc fe ff ff       	call   801345 <fsipc>
    return r;
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	56                   	push   %esi
  80147f:	53                   	push   %ebx
  801480:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	8b 40 0c             	mov    0xc(%eax),%eax
  801489:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80148e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 03 00 00 00       	mov    $0x3,%eax
  80149e:	e8 a2 fe ff ff       	call   801345 <fsipc>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 4b                	js     8014f4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014a9:	39 c6                	cmp    %eax,%esi
  8014ab:	73 16                	jae    8014c3 <devfile_read+0x48>
  8014ad:	68 90 22 80 00       	push   $0x802290
  8014b2:	68 97 22 80 00       	push   $0x802297
  8014b7:	6a 7c                	push   $0x7c
  8014b9:	68 ac 22 80 00       	push   $0x8022ac
  8014be:	e8 bd 05 00 00       	call   801a80 <_panic>
	assert(r <= PGSIZE);
  8014c3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c8:	7e 16                	jle    8014e0 <devfile_read+0x65>
  8014ca:	68 b7 22 80 00       	push   $0x8022b7
  8014cf:	68 97 22 80 00       	push   $0x802297
  8014d4:	6a 7d                	push   $0x7d
  8014d6:	68 ac 22 80 00       	push   $0x8022ac
  8014db:	e8 a0 05 00 00       	call   801a80 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	50                   	push   %eax
  8014e4:	68 00 50 80 00       	push   $0x805000
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	e8 b7 f3 ff ff       	call   8008a8 <memmove>
	return r;
  8014f1:	83 c4 10             	add    $0x10,%esp
}
  8014f4:	89 d8                	mov    %ebx,%eax
  8014f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 20             	sub    $0x20,%esp
  801504:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801507:	53                   	push   %ebx
  801508:	e8 d0 f1 ff ff       	call   8006dd <strlen>
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801515:	7f 67                	jg     80157e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	e8 9a f8 ff ff       	call   800dbd <fd_alloc>
  801523:	83 c4 10             	add    $0x10,%esp
		return r;
  801526:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 57                	js     801583 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	53                   	push   %ebx
  801530:	68 00 50 80 00       	push   $0x805000
  801535:	e8 dc f1 ff ff       	call   800716 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80153a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801542:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801545:	b8 01 00 00 00       	mov    $0x1,%eax
  80154a:	e8 f6 fd ff ff       	call   801345 <fsipc>
  80154f:	89 c3                	mov    %eax,%ebx
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	79 14                	jns    80156c <open+0x6f>
		fd_close(fd, 0);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	6a 00                	push   $0x0
  80155d:	ff 75 f4             	pushl  -0xc(%ebp)
  801560:	e8 50 f9 ff ff       	call   800eb5 <fd_close>
		return r;
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	89 da                	mov    %ebx,%edx
  80156a:	eb 17                	jmp    801583 <open+0x86>
	}

	return fd2num(fd);
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	ff 75 f4             	pushl  -0xc(%ebp)
  801572:	e8 1f f8 ff ff       	call   800d96 <fd2num>
  801577:	89 c2                	mov    %eax,%edx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	eb 05                	jmp    801583 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80157e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801583:	89 d0                	mov    %edx,%eax
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801590:	ba 00 00 00 00       	mov    $0x0,%edx
  801595:	b8 08 00 00 00       	mov    $0x8,%eax
  80159a:	e8 a6 fd ff ff       	call   801345 <fsipc>
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	e8 f2 f7 ff ff       	call   800da6 <fd2data>
  8015b4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	68 c3 22 80 00       	push   $0x8022c3
  8015be:	53                   	push   %ebx
  8015bf:	e8 52 f1 ff ff       	call   800716 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015c4:	8b 46 04             	mov    0x4(%esi),%eax
  8015c7:	2b 06                	sub    (%esi),%eax
  8015c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d6:	00 00 00 
	stat->st_dev = &devpipe;
  8015d9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015e0:	30 80 00 
	return 0;
}
  8015e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5e                   	pop    %esi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015f9:	53                   	push   %ebx
  8015fa:	6a 00                	push   $0x0
  8015fc:	e8 9d f5 ff ff       	call   800b9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801601:	89 1c 24             	mov    %ebx,(%esp)
  801604:	e8 9d f7 ff ff       	call   800da6 <fd2data>
  801609:	83 c4 08             	add    $0x8,%esp
  80160c:	50                   	push   %eax
  80160d:	6a 00                	push   $0x0
  80160f:	e8 8a f5 ff ff       	call   800b9e <sys_page_unmap>
}
  801614:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	57                   	push   %edi
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
  80161f:	83 ec 1c             	sub    $0x1c,%esp
  801622:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801625:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801627:	a1 04 40 80 00       	mov    0x804004,%eax
  80162c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80162f:	83 ec 0c             	sub    $0xc,%esp
  801632:	ff 75 e0             	pushl  -0x20(%ebp)
  801635:	e8 6e 05 00 00       	call   801ba8 <pageref>
  80163a:	89 c3                	mov    %eax,%ebx
  80163c:	89 3c 24             	mov    %edi,(%esp)
  80163f:	e8 64 05 00 00       	call   801ba8 <pageref>
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	39 c3                	cmp    %eax,%ebx
  801649:	0f 94 c1             	sete   %cl
  80164c:	0f b6 c9             	movzbl %cl,%ecx
  80164f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801652:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801658:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80165b:	39 ce                	cmp    %ecx,%esi
  80165d:	74 1b                	je     80167a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80165f:	39 c3                	cmp    %eax,%ebx
  801661:	75 c4                	jne    801627 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801663:	8b 42 58             	mov    0x58(%edx),%eax
  801666:	ff 75 e4             	pushl  -0x1c(%ebp)
  801669:	50                   	push   %eax
  80166a:	56                   	push   %esi
  80166b:	68 ca 22 80 00       	push   $0x8022ca
  801670:	e8 fe ea ff ff       	call   800173 <cprintf>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	eb ad                	jmp    801627 <_pipeisclosed+0xe>
	}
}
  80167a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801680:	5b                   	pop    %ebx
  801681:	5e                   	pop    %esi
  801682:	5f                   	pop    %edi
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	57                   	push   %edi
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
  80168b:	83 ec 28             	sub    $0x28,%esp
  80168e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801691:	56                   	push   %esi
  801692:	e8 0f f7 ff ff       	call   800da6 <fd2data>
  801697:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	bf 00 00 00 00       	mov    $0x0,%edi
  8016a1:	eb 4b                	jmp    8016ee <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016a3:	89 da                	mov    %ebx,%edx
  8016a5:	89 f0                	mov    %esi,%eax
  8016a7:	e8 6d ff ff ff       	call   801619 <_pipeisclosed>
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	75 48                	jne    8016f8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016b0:	e8 45 f4 ff ff       	call   800afa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016b5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016b8:	8b 0b                	mov    (%ebx),%ecx
  8016ba:	8d 51 20             	lea    0x20(%ecx),%edx
  8016bd:	39 d0                	cmp    %edx,%eax
  8016bf:	73 e2                	jae    8016a3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016c8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	c1 fa 1f             	sar    $0x1f,%edx
  8016d0:	89 d1                	mov    %edx,%ecx
  8016d2:	c1 e9 1b             	shr    $0x1b,%ecx
  8016d5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016d8:	83 e2 1f             	and    $0x1f,%edx
  8016db:	29 ca                	sub    %ecx,%edx
  8016dd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016e5:	83 c0 01             	add    $0x1,%eax
  8016e8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016eb:	83 c7 01             	add    $0x1,%edi
  8016ee:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016f1:	75 c2                	jne    8016b5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f6:	eb 05                	jmp    8016fd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016f8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5f                   	pop    %edi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	57                   	push   %edi
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	83 ec 18             	sub    $0x18,%esp
  80170e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801711:	57                   	push   %edi
  801712:	e8 8f f6 ff ff       	call   800da6 <fd2data>
  801717:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801721:	eb 3d                	jmp    801760 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801723:	85 db                	test   %ebx,%ebx
  801725:	74 04                	je     80172b <devpipe_read+0x26>
				return i;
  801727:	89 d8                	mov    %ebx,%eax
  801729:	eb 44                	jmp    80176f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80172b:	89 f2                	mov    %esi,%edx
  80172d:	89 f8                	mov    %edi,%eax
  80172f:	e8 e5 fe ff ff       	call   801619 <_pipeisclosed>
  801734:	85 c0                	test   %eax,%eax
  801736:	75 32                	jne    80176a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801738:	e8 bd f3 ff ff       	call   800afa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80173d:	8b 06                	mov    (%esi),%eax
  80173f:	3b 46 04             	cmp    0x4(%esi),%eax
  801742:	74 df                	je     801723 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801744:	99                   	cltd   
  801745:	c1 ea 1b             	shr    $0x1b,%edx
  801748:	01 d0                	add    %edx,%eax
  80174a:	83 e0 1f             	and    $0x1f,%eax
  80174d:	29 d0                	sub    %edx,%eax
  80174f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801757:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80175a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175d:	83 c3 01             	add    $0x1,%ebx
  801760:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801763:	75 d8                	jne    80173d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801765:	8b 45 10             	mov    0x10(%ebp),%eax
  801768:	eb 05                	jmp    80176f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80176a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80176f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5f                   	pop    %edi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	56                   	push   %esi
  80177b:	53                   	push   %ebx
  80177c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	50                   	push   %eax
  801783:	e8 35 f6 ff ff       	call   800dbd <fd_alloc>
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	85 c0                	test   %eax,%eax
  80178f:	0f 88 2c 01 00 00    	js     8018c1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801795:	83 ec 04             	sub    $0x4,%esp
  801798:	68 07 04 00 00       	push   $0x407
  80179d:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 72 f3 ff ff       	call   800b19 <sys_page_alloc>
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	89 c2                	mov    %eax,%edx
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	0f 88 0d 01 00 00    	js     8018c1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	e8 fd f5 ff ff       	call   800dbd <fd_alloc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	0f 88 e2 00 00 00    	js     8018af <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017cd:	83 ec 04             	sub    $0x4,%esp
  8017d0:	68 07 04 00 00       	push   $0x407
  8017d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d8:	6a 00                	push   $0x0
  8017da:	e8 3a f3 ff ff       	call   800b19 <sys_page_alloc>
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	0f 88 c3 00 00 00    	js     8018af <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f2:	e8 af f5 ff ff       	call   800da6 <fd2data>
  8017f7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f9:	83 c4 0c             	add    $0xc,%esp
  8017fc:	68 07 04 00 00       	push   $0x407
  801801:	50                   	push   %eax
  801802:	6a 00                	push   $0x0
  801804:	e8 10 f3 ff ff       	call   800b19 <sys_page_alloc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	0f 88 89 00 00 00    	js     80189f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801816:	83 ec 0c             	sub    $0xc,%esp
  801819:	ff 75 f0             	pushl  -0x10(%ebp)
  80181c:	e8 85 f5 ff ff       	call   800da6 <fd2data>
  801821:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801828:	50                   	push   %eax
  801829:	6a 00                	push   $0x0
  80182b:	56                   	push   %esi
  80182c:	6a 00                	push   $0x0
  80182e:	e8 29 f3 ff ff       	call   800b5c <sys_page_map>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	83 c4 20             	add    $0x20,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 55                	js     801891 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80183c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801845:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801851:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80185c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	ff 75 f4             	pushl  -0xc(%ebp)
  80186c:	e8 25 f5 ff ff       	call   800d96 <fd2num>
  801871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801874:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801876:	83 c4 04             	add    $0x4,%esp
  801879:	ff 75 f0             	pushl  -0x10(%ebp)
  80187c:	e8 15 f5 ff ff       	call   800d96 <fd2num>
  801881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801884:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	eb 30                	jmp    8018c1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	56                   	push   %esi
  801895:	6a 00                	push   $0x0
  801897:	e8 02 f3 ff ff       	call   800b9e <sys_page_unmap>
  80189c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 f2 f2 ff ff       	call   800b9e <sys_page_unmap>
  8018ac:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b5:	6a 00                	push   $0x0
  8018b7:	e8 e2 f2 ff ff       	call   800b9e <sys_page_unmap>
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018c1:	89 d0                	mov    %edx,%eax
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	ff 75 08             	pushl  0x8(%ebp)
  8018d7:	e8 30 f5 ff ff       	call   800e0c <fd_lookup>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 18                	js     8018fb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e9:	e8 b8 f4 ff ff       	call   800da6 <fd2data>
	return _pipeisclosed(fd, p);
  8018ee:	89 c2                	mov    %eax,%edx
  8018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f3:	e8 21 fd ff ff       	call   801619 <_pipeisclosed>
  8018f8:	83 c4 10             	add    $0x10,%esp
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801900:	b8 00 00 00 00       	mov    $0x0,%eax
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80190d:	68 e2 22 80 00       	push   $0x8022e2
  801912:	ff 75 0c             	pushl  0xc(%ebp)
  801915:	e8 fc ed ff ff       	call   800716 <strcpy>
	return 0;
}
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	57                   	push   %edi
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80192d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801932:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801938:	eb 2d                	jmp    801967 <devcons_write+0x46>
		m = n - tot;
  80193a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80193d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80193f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801942:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801947:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80194a:	83 ec 04             	sub    $0x4,%esp
  80194d:	53                   	push   %ebx
  80194e:	03 45 0c             	add    0xc(%ebp),%eax
  801951:	50                   	push   %eax
  801952:	57                   	push   %edi
  801953:	e8 50 ef ff ff       	call   8008a8 <memmove>
		sys_cputs(buf, m);
  801958:	83 c4 08             	add    $0x8,%esp
  80195b:	53                   	push   %ebx
  80195c:	57                   	push   %edi
  80195d:	e8 fb f0 ff ff       	call   800a5d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801962:	01 de                	add    %ebx,%esi
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	89 f0                	mov    %esi,%eax
  801969:	3b 75 10             	cmp    0x10(%ebp),%esi
  80196c:	72 cc                	jb     80193a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80196e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801971:	5b                   	pop    %ebx
  801972:	5e                   	pop    %esi
  801973:	5f                   	pop    %edi
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
  80197c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801981:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801985:	74 2a                	je     8019b1 <devcons_read+0x3b>
  801987:	eb 05                	jmp    80198e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801989:	e8 6c f1 ff ff       	call   800afa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80198e:	e8 e8 f0 ff ff       	call   800a7b <sys_cgetc>
  801993:	85 c0                	test   %eax,%eax
  801995:	74 f2                	je     801989 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801997:	85 c0                	test   %eax,%eax
  801999:	78 16                	js     8019b1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80199b:	83 f8 04             	cmp    $0x4,%eax
  80199e:	74 0c                	je     8019ac <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a3:	88 02                	mov    %al,(%edx)
	return 1;
  8019a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019aa:	eb 05                	jmp    8019b1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019bf:	6a 01                	push   $0x1
  8019c1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	e8 93 f0 ff ff       	call   800a5d <sys_cputs>
}
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <getchar>:

int
getchar(void)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019d5:	6a 01                	push   $0x1
  8019d7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019da:	50                   	push   %eax
  8019db:	6a 00                	push   $0x0
  8019dd:	e8 90 f6 ff ff       	call   801072 <read>
	if (r < 0)
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 0f                	js     8019f8 <getchar+0x29>
		return r;
	if (r < 1)
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	7e 06                	jle    8019f3 <getchar+0x24>
		return -E_EOF;
	return c;
  8019ed:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019f1:	eb 05                	jmp    8019f8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019f3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a03:	50                   	push   %eax
  801a04:	ff 75 08             	pushl  0x8(%ebp)
  801a07:	e8 00 f4 ff ff       	call   800e0c <fd_lookup>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 11                	js     801a24 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a16:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a1c:	39 10                	cmp    %edx,(%eax)
  801a1e:	0f 94 c0             	sete   %al
  801a21:	0f b6 c0             	movzbl %al,%eax
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <opencons>:

int
opencons(void)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2f:	50                   	push   %eax
  801a30:	e8 88 f3 ff ff       	call   800dbd <fd_alloc>
  801a35:	83 c4 10             	add    $0x10,%esp
		return r;
  801a38:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 3e                	js     801a7c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	68 07 04 00 00       	push   $0x407
  801a46:	ff 75 f4             	pushl  -0xc(%ebp)
  801a49:	6a 00                	push   $0x0
  801a4b:	e8 c9 f0 ff ff       	call   800b19 <sys_page_alloc>
  801a50:	83 c4 10             	add    $0x10,%esp
		return r;
  801a53:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a55:	85 c0                	test   %eax,%eax
  801a57:	78 23                	js     801a7c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a59:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a62:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a67:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	50                   	push   %eax
  801a72:	e8 1f f3 ff ff       	call   800d96 <fd2num>
  801a77:	89 c2                	mov    %eax,%edx
  801a79:	83 c4 10             	add    $0x10,%esp
}
  801a7c:	89 d0                	mov    %edx,%eax
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a85:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a88:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a8e:	e8 48 f0 ff ff       	call   800adb <sys_getenvid>
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	ff 75 08             	pushl  0x8(%ebp)
  801a9c:	56                   	push   %esi
  801a9d:	50                   	push   %eax
  801a9e:	68 f0 22 80 00       	push   $0x8022f0
  801aa3:	e8 cb e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801aa8:	83 c4 18             	add    $0x18,%esp
  801aab:	53                   	push   %ebx
  801aac:	ff 75 10             	pushl  0x10(%ebp)
  801aaf:	e8 6e e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801ab4:	c7 04 24 db 22 80 00 	movl   $0x8022db,(%esp)
  801abb:	e8 b3 e6 ff ff       	call   800173 <cprintf>
  801ac0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ac3:	cc                   	int3   
  801ac4:	eb fd                	jmp    801ac3 <_panic+0x43>

00801ac6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	56                   	push   %esi
  801aca:	53                   	push   %ebx
  801acb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801adb:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	50                   	push   %eax
  801ae2:	e8 e2 f1 ff ff       	call   800cc9 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	75 10                	jne    801afe <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801aee:	a1 04 40 80 00       	mov    0x804004,%eax
  801af3:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801af6:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801af9:	8b 40 70             	mov    0x70(%eax),%eax
  801afc:	eb 0a                	jmp    801b08 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801afe:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801b03:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801b08:	85 f6                	test   %esi,%esi
  801b0a:	74 02                	je     801b0e <ipc_recv+0x48>
  801b0c:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801b0e:	85 db                	test   %ebx,%ebx
  801b10:	74 02                	je     801b14 <ipc_recv+0x4e>
  801b12:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801b14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b17:	5b                   	pop    %ebx
  801b18:	5e                   	pop    %esi
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	57                   	push   %edi
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	83 ec 0c             	sub    $0xc,%esp
  801b24:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b27:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801b2d:	85 db                	test   %ebx,%ebx
  801b2f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b34:	0f 44 d8             	cmove  %eax,%ebx
  801b37:	eb 1c                	jmp    801b55 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801b39:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b3c:	74 12                	je     801b50 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801b3e:	50                   	push   %eax
  801b3f:	68 14 23 80 00       	push   $0x802314
  801b44:	6a 40                	push   $0x40
  801b46:	68 26 23 80 00       	push   $0x802326
  801b4b:	e8 30 ff ff ff       	call   801a80 <_panic>
        sys_yield();
  801b50:	e8 a5 ef ff ff       	call   800afa <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b55:	ff 75 14             	pushl  0x14(%ebp)
  801b58:	53                   	push   %ebx
  801b59:	56                   	push   %esi
  801b5a:	57                   	push   %edi
  801b5b:	e8 46 f1 ff ff       	call   800ca6 <sys_ipc_try_send>
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	75 d2                	jne    801b39 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5f                   	pop    %edi
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b7a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b7d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b83:	8b 52 50             	mov    0x50(%edx),%edx
  801b86:	39 ca                	cmp    %ecx,%edx
  801b88:	75 0d                	jne    801b97 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b8a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b8d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b92:	8b 40 48             	mov    0x48(%eax),%eax
  801b95:	eb 0f                	jmp    801ba6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b97:	83 c0 01             	add    $0x1,%eax
  801b9a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b9f:	75 d9                	jne    801b7a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bae:	89 d0                	mov    %edx,%eax
  801bb0:	c1 e8 16             	shr    $0x16,%eax
  801bb3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bba:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bbf:	f6 c1 01             	test   $0x1,%cl
  801bc2:	74 1d                	je     801be1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bc4:	c1 ea 0c             	shr    $0xc,%edx
  801bc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bce:	f6 c2 01             	test   $0x1,%dl
  801bd1:	74 0e                	je     801be1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bd3:	c1 ea 0c             	shr    $0xc,%edx
  801bd6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bdd:	ef 
  801bde:	0f b7 c0             	movzwl %ax,%eax
}
  801be1:	5d                   	pop    %ebp
  801be2:	c3                   	ret    
  801be3:	66 90                	xchg   %ax,%ax
  801be5:	66 90                	xchg   %ax,%ax
  801be7:	66 90                	xchg   %ax,%ax
  801be9:	66 90                	xchg   %ax,%ax
  801beb:	66 90                	xchg   %ax,%ax
  801bed:	66 90                	xchg   %ax,%ax
  801bef:	90                   	nop

00801bf0 <__udivdi3>:
  801bf0:	55                   	push   %ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c07:	85 f6                	test   %esi,%esi
  801c09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0d:	89 ca                	mov    %ecx,%edx
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	75 3d                	jne    801c50 <__udivdi3+0x60>
  801c13:	39 cf                	cmp    %ecx,%edi
  801c15:	0f 87 c5 00 00 00    	ja     801ce0 <__udivdi3+0xf0>
  801c1b:	85 ff                	test   %edi,%edi
  801c1d:	89 fd                	mov    %edi,%ebp
  801c1f:	75 0b                	jne    801c2c <__udivdi3+0x3c>
  801c21:	b8 01 00 00 00       	mov    $0x1,%eax
  801c26:	31 d2                	xor    %edx,%edx
  801c28:	f7 f7                	div    %edi
  801c2a:	89 c5                	mov    %eax,%ebp
  801c2c:	89 c8                	mov    %ecx,%eax
  801c2e:	31 d2                	xor    %edx,%edx
  801c30:	f7 f5                	div    %ebp
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	89 cf                	mov    %ecx,%edi
  801c38:	f7 f5                	div    %ebp
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	39 ce                	cmp    %ecx,%esi
  801c52:	77 74                	ja     801cc8 <__udivdi3+0xd8>
  801c54:	0f bd fe             	bsr    %esi,%edi
  801c57:	83 f7 1f             	xor    $0x1f,%edi
  801c5a:	0f 84 98 00 00 00    	je     801cf8 <__udivdi3+0x108>
  801c60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	89 c5                	mov    %eax,%ebp
  801c69:	29 fb                	sub    %edi,%ebx
  801c6b:	d3 e6                	shl    %cl,%esi
  801c6d:	89 d9                	mov    %ebx,%ecx
  801c6f:	d3 ed                	shr    %cl,%ebp
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e0                	shl    %cl,%eax
  801c75:	09 ee                	or     %ebp,%esi
  801c77:	89 d9                	mov    %ebx,%ecx
  801c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7d:	89 d5                	mov    %edx,%ebp
  801c7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c83:	d3 ed                	shr    %cl,%ebp
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e2                	shl    %cl,%edx
  801c89:	89 d9                	mov    %ebx,%ecx
  801c8b:	d3 e8                	shr    %cl,%eax
  801c8d:	09 c2                	or     %eax,%edx
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	89 ea                	mov    %ebp,%edx
  801c93:	f7 f6                	div    %esi
  801c95:	89 d5                	mov    %edx,%ebp
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	f7 64 24 0c          	mull   0xc(%esp)
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	72 10                	jb     801cb1 <__udivdi3+0xc1>
  801ca1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e6                	shl    %cl,%esi
  801ca9:	39 c6                	cmp    %eax,%esi
  801cab:	73 07                	jae    801cb4 <__udivdi3+0xc4>
  801cad:	39 d5                	cmp    %edx,%ebp
  801caf:	75 03                	jne    801cb4 <__udivdi3+0xc4>
  801cb1:	83 eb 01             	sub    $0x1,%ebx
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 d8                	mov    %ebx,%eax
  801cb8:	89 fa                	mov    %edi,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	31 ff                	xor    %edi,%edi
  801cca:	31 db                	xor    %ebx,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	f7 f7                	div    %edi
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 fa                	mov    %edi,%edx
  801cec:	83 c4 1c             	add    $0x1c,%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	39 ce                	cmp    %ecx,%esi
  801cfa:	72 0c                	jb     801d08 <__udivdi3+0x118>
  801cfc:	31 db                	xor    %ebx,%ebx
  801cfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d02:	0f 87 34 ff ff ff    	ja     801c3c <__udivdi3+0x4c>
  801d08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d0d:	e9 2a ff ff ff       	jmp    801c3c <__udivdi3+0x4c>
  801d12:	66 90                	xchg   %ax,%ax
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__umoddi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 d2                	test   %edx,%edx
  801d39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f3                	mov    %esi,%ebx
  801d43:	89 3c 24             	mov    %edi,(%esp)
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	75 1c                	jne    801d68 <__umoddi3+0x48>
  801d4c:	39 f7                	cmp    %esi,%edi
  801d4e:	76 50                	jbe    801da0 <__umoddi3+0x80>
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	f7 f7                	div    %edi
  801d56:	89 d0                	mov    %edx,%eax
  801d58:	31 d2                	xor    %edx,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	39 f2                	cmp    %esi,%edx
  801d6a:	89 d0                	mov    %edx,%eax
  801d6c:	77 52                	ja     801dc0 <__umoddi3+0xa0>
  801d6e:	0f bd ea             	bsr    %edx,%ebp
  801d71:	83 f5 1f             	xor    $0x1f,%ebp
  801d74:	75 5a                	jne    801dd0 <__umoddi3+0xb0>
  801d76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d7a:	0f 82 e0 00 00 00    	jb     801e60 <__umoddi3+0x140>
  801d80:	39 0c 24             	cmp    %ecx,(%esp)
  801d83:	0f 86 d7 00 00 00    	jbe    801e60 <__umoddi3+0x140>
  801d89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d91:	83 c4 1c             	add    $0x1c,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	85 ff                	test   %edi,%edi
  801da2:	89 fd                	mov    %edi,%ebp
  801da4:	75 0b                	jne    801db1 <__umoddi3+0x91>
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f7                	div    %edi
  801daf:	89 c5                	mov    %eax,%ebp
  801db1:	89 f0                	mov    %esi,%eax
  801db3:	31 d2                	xor    %edx,%edx
  801db5:	f7 f5                	div    %ebp
  801db7:	89 c8                	mov    %ecx,%eax
  801db9:	f7 f5                	div    %ebp
  801dbb:	89 d0                	mov    %edx,%eax
  801dbd:	eb 99                	jmp    801d58 <__umoddi3+0x38>
  801dbf:	90                   	nop
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 1c             	add    $0x1c,%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	8b 34 24             	mov    (%esp),%esi
  801dd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	29 ef                	sub    %ebp,%edi
  801ddc:	d3 e0                	shl    %cl,%eax
  801dde:	89 f9                	mov    %edi,%ecx
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	d3 ea                	shr    %cl,%edx
  801de4:	89 e9                	mov    %ebp,%ecx
  801de6:	09 c2                	or     %eax,%edx
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	89 14 24             	mov    %edx,(%esp)
  801ded:	89 f2                	mov    %esi,%edx
  801def:	d3 e2                	shl    %cl,%edx
  801df1:	89 f9                	mov    %edi,%ecx
  801df3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dfb:	d3 e8                	shr    %cl,%eax
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	89 c6                	mov    %eax,%esi
  801e01:	d3 e3                	shl    %cl,%ebx
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 d0                	mov    %edx,%eax
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	09 d8                	or     %ebx,%eax
  801e0d:	89 d3                	mov    %edx,%ebx
  801e0f:	89 f2                	mov    %esi,%edx
  801e11:	f7 34 24             	divl   (%esp)
  801e14:	89 d6                	mov    %edx,%esi
  801e16:	d3 e3                	shl    %cl,%ebx
  801e18:	f7 64 24 04          	mull   0x4(%esp)
  801e1c:	39 d6                	cmp    %edx,%esi
  801e1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e22:	89 d1                	mov    %edx,%ecx
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	72 08                	jb     801e30 <__umoddi3+0x110>
  801e28:	75 11                	jne    801e3b <__umoddi3+0x11b>
  801e2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e2e:	73 0b                	jae    801e3b <__umoddi3+0x11b>
  801e30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e34:	1b 14 24             	sbb    (%esp),%edx
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e3f:	29 da                	sub    %ebx,%edx
  801e41:	19 ce                	sbb    %ecx,%esi
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e0                	shl    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	d3 ea                	shr    %cl,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	d3 ee                	shr    %cl,%esi
  801e51:	09 d0                	or     %edx,%eax
  801e53:	89 f2                	mov    %esi,%edx
  801e55:	83 c4 1c             	add    $0x1c,%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	29 f9                	sub    %edi,%ecx
  801e62:	19 d6                	sbb    %edx,%esi
  801e64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e6c:	e9 18 ff ff ff       	jmp    801d89 <__umoddi3+0x69>
