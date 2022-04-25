
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 e0 1d 80 00       	push   $0x801de0
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ee 1d 80 00       	push   $0x801dee
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 4b 0a 00 00       	call   800ab9 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 04 0e 00 00       	call   800eb3 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 bf 09 00 00       	call   800a78 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 4d 09 00 00       	call   800a3b <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 54 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 f2 08 00 00       	call   800a3b <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 87 19 00 00       	call   801b40 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 74 1a 00 00       	call   801c70 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 0f 1e 80 00 	movsbl 0x801e0f(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800217:	83 fa 01             	cmp    $0x1,%edx
  80021a:	7e 0e                	jle    80022a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	8b 52 04             	mov    0x4(%edx),%edx
  800228:	eb 22                	jmp    80024c <getuint+0x38>
	else if (lflag)
  80022a:	85 d2                	test   %edx,%edx
  80022c:	74 10                	je     80023e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	eb 0e                	jmp    80024c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 04             	lea    0x4(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	3b 50 04             	cmp    0x4(%eax),%edx
  80025d:	73 0a                	jae    800269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	88 02                	mov    %al,(%edx)
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
	va_end(ap);
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 2c             	sub    $0x2c,%esp
  800291:	8b 75 08             	mov    0x8(%ebp),%esi
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029a:	eb 12                	jmp    8002ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029c:	85 c0                	test   %eax,%eax
  80029e:	0f 84 a7 03 00 00    	je     80064b <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	53                   	push   %ebx
  8002a8:	50                   	push   %eax
  8002a9:	ff d6                	call   *%esi
  8002ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ae:	83 c7 01             	add    $0x1,%edi
  8002b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	75 e2                	jne    80029c <vprintfmt+0x14>
  8002ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8002cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d3:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8002da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002df:	eb 07                	jmp    8002e8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8d 47 01             	lea    0x1(%edi),%eax
  8002eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ee:	0f b6 07             	movzbl (%edi),%eax
  8002f1:	0f b6 d0             	movzbl %al,%edx
  8002f4:	83 e8 23             	sub    $0x23,%eax
  8002f7:	3c 55                	cmp    $0x55,%al
  8002f9:	0f 87 31 03 00 00    	ja     800630 <vprintfmt+0x3a8>
  8002ff:	0f b6 c0             	movzbl %al,%eax
  800302:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800310:	eb d6                	jmp    8002e8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800315:	b8 00 00 00 00       	mov    $0x0,%eax
  80031a:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800320:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800324:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800327:	8d 72 d0             	lea    -0x30(%edx),%esi
  80032a:	83 fe 09             	cmp    $0x9,%esi
  80032d:	77 34                	ja     800363 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800332:	eb e9                	jmp    80031d <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800334:	8b 45 14             	mov    0x14(%ebp),%eax
  800337:	8d 50 04             	lea    0x4(%eax),%edx
  80033a:	89 55 14             	mov    %edx,0x14(%ebp)
  80033d:	8b 00                	mov    (%eax),%eax
  80033f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800345:	eb 22                	jmp    800369 <vprintfmt+0xe1>
  800347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034a:	85 c0                	test   %eax,%eax
  80034c:	0f 48 c1             	cmovs  %ecx,%eax
  80034f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800355:	eb 91                	jmp    8002e8 <vprintfmt+0x60>
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800361:	eb 85                	jmp    8002e8 <vprintfmt+0x60>
  800363:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800366:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036d:	0f 89 75 ff ff ff    	jns    8002e8 <vprintfmt+0x60>
				width = precision, precision = -1;
  800373:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800379:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800380:	e9 63 ff ff ff       	jmp    8002e8 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800385:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038c:	e9 57 ff ff ff       	jmp    8002e8 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 50 04             	lea    0x4(%eax),%edx
  800397:	89 55 14             	mov    %edx,0x14(%ebp)
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	53                   	push   %ebx
  80039e:	ff 30                	pushl  (%eax)
  8003a0:	ff d6                	call   *%esi
			break;
  8003a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a8:	e9 01 ff ff ff       	jmp    8002ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	99                   	cltd   
  8003b9:	31 d0                	xor    %edx,%eax
  8003bb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bd:	83 f8 0f             	cmp    $0xf,%eax
  8003c0:	7f 0b                	jg     8003cd <vprintfmt+0x145>
  8003c2:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  8003c9:	85 d2                	test   %edx,%edx
  8003cb:	75 18                	jne    8003e5 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8003cd:	50                   	push   %eax
  8003ce:	68 27 1e 80 00       	push   $0x801e27
  8003d3:	53                   	push   %ebx
  8003d4:	56                   	push   %esi
  8003d5:	e8 91 fe ff ff       	call   80026b <printfmt>
  8003da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e0:	e9 c9 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e5:	52                   	push   %edx
  8003e6:	68 f1 21 80 00       	push   $0x8021f1
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 79 fe ff ff       	call   80026b <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f8:	e9 b1 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800408:	85 ff                	test   %edi,%edi
  80040a:	b8 20 1e 80 00       	mov    $0x801e20,%eax
  80040f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800412:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800416:	0f 8e 94 00 00 00    	jle    8004b0 <vprintfmt+0x228>
  80041c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800420:	0f 84 98 00 00 00    	je     8004be <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	ff 75 cc             	pushl  -0x34(%ebp)
  80042c:	57                   	push   %edi
  80042d:	e8 a1 02 00 00       	call   8006d3 <strnlen>
  800432:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800435:	29 c1                	sub    %eax,%ecx
  800437:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80043a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800441:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800444:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800447:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	eb 0f                	jmp    80045a <vprintfmt+0x1d2>
					putch(padc, putdat);
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	53                   	push   %ebx
  80044f:	ff 75 e0             	pushl  -0x20(%ebp)
  800452:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800454:	83 ef 01             	sub    $0x1,%edi
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	85 ff                	test   %edi,%edi
  80045c:	7f ed                	jg     80044b <vprintfmt+0x1c3>
  80045e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800461:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800464:	85 c9                	test   %ecx,%ecx
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	0f 49 c1             	cmovns %ecx,%eax
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 75 08             	mov    %esi,0x8(%ebp)
  800473:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800476:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800479:	89 cb                	mov    %ecx,%ebx
  80047b:	eb 4d                	jmp    8004ca <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800481:	74 1b                	je     80049e <vprintfmt+0x216>
  800483:	0f be c0             	movsbl %al,%eax
  800486:	83 e8 20             	sub    $0x20,%eax
  800489:	83 f8 5e             	cmp    $0x5e,%eax
  80048c:	76 10                	jbe    80049e <vprintfmt+0x216>
					putch('?', putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	ff 75 0c             	pushl  0xc(%ebp)
  800494:	6a 3f                	push   $0x3f
  800496:	ff 55 08             	call   *0x8(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	eb 0d                	jmp    8004ab <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 0c             	pushl  0xc(%ebp)
  8004a4:	52                   	push   %edx
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ab:	83 eb 01             	sub    $0x1,%ebx
  8004ae:	eb 1a                	jmp    8004ca <vprintfmt+0x242>
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bc:	eb 0c                	jmp    8004ca <vprintfmt+0x242>
  8004be:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ca:	83 c7 01             	add    $0x1,%edi
  8004cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d1:	0f be d0             	movsbl %al,%edx
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	74 23                	je     8004fb <vprintfmt+0x273>
  8004d8:	85 f6                	test   %esi,%esi
  8004da:	78 a1                	js     80047d <vprintfmt+0x1f5>
  8004dc:	83 ee 01             	sub    $0x1,%esi
  8004df:	79 9c                	jns    80047d <vprintfmt+0x1f5>
  8004e1:	89 df                	mov    %ebx,%edi
  8004e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e9:	eb 18                	jmp    800503 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	6a 20                	push   $0x20
  8004f1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 08                	jmp    800503 <vprintfmt+0x27b>
  8004fb:	89 df                	mov    %ebx,%edi
  8004fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800500:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800503:	85 ff                	test   %edi,%edi
  800505:	7f e4                	jg     8004eb <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050a:	e9 9f fd ff ff       	jmp    8002ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050f:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800513:	7e 16                	jle    80052b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 08             	lea    0x8(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 50 04             	mov    0x4(%eax),%edx
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800526:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800529:	eb 34                	jmp    80055f <vprintfmt+0x2d7>
	else if (lflag)
  80052b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80052f:	74 18                	je     800549 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	89 c1                	mov    %eax,%ecx
  800541:	c1 f9 1f             	sar    $0x1f,%ecx
  800544:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800547:	eb 16                	jmp    80055f <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8d 50 04             	lea    0x4(%eax),%edx
  80054f:	89 55 14             	mov    %edx,0x14(%ebp)
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	89 c1                	mov    %eax,%ecx
  800559:	c1 f9 1f             	sar    $0x1f,%ecx
  80055c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800562:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800565:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056e:	0f 89 88 00 00 00    	jns    8005fc <vprintfmt+0x374>
				putch('-', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	6a 2d                	push   $0x2d
  80057a:	ff d6                	call   *%esi
				num = -(long long) num;
  80057c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800582:	f7 d8                	neg    %eax
  800584:	83 d2 00             	adc    $0x0,%edx
  800587:	f7 da                	neg    %edx
  800589:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800591:	eb 69                	jmp    8005fc <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800593:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 76 fc ff ff       	call   800214 <getuint>
			base = 10;
  80059e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005a3:	eb 57                	jmp    8005fc <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	53                   	push   %ebx
  8005a9:	6a 30                	push   $0x30
  8005ab:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8005ad:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b3:	e8 5c fc ff ff       	call   800214 <getuint>
			base = 8;
			goto number;
  8005b8:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005bb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c0:	eb 3a                	jmp    8005fc <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 30                	push   $0x30
  8005c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ca:	83 c4 08             	add    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 78                	push   $0x78
  8005d0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ea:	eb 10                	jmp    8005fc <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ec:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 1d fc ff ff       	call   800214 <getuint>
			base = 16;
  8005f7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800603:	57                   	push   %edi
  800604:	ff 75 e0             	pushl  -0x20(%ebp)
  800607:	51                   	push   %ecx
  800608:	52                   	push   %edx
  800609:	50                   	push   %eax
  80060a:	89 da                	mov    %ebx,%edx
  80060c:	89 f0                	mov    %esi,%eax
  80060e:	e8 52 fb ff ff       	call   800165 <printnum>
			break;
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800619:	e9 90 fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	52                   	push   %edx
  800623:	ff d6                	call   *%esi
			break;
  800625:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062b:	e9 7e fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 25                	push   $0x25
  800636:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	eb 03                	jmp    800640 <vprintfmt+0x3b8>
  80063d:	83 ef 01             	sub    $0x1,%edi
  800640:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800644:	75 f7                	jne    80063d <vprintfmt+0x3b5>
  800646:	e9 63 fc ff ff       	jmp    8002ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064e:	5b                   	pop    %ebx
  80064f:	5e                   	pop    %esi
  800650:	5f                   	pop    %edi
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	83 ec 18             	sub    $0x18,%esp
  800659:	8b 45 08             	mov    0x8(%ebp),%eax
  80065c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800662:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800666:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800670:	85 c0                	test   %eax,%eax
  800672:	74 26                	je     80069a <vsnprintf+0x47>
  800674:	85 d2                	test   %edx,%edx
  800676:	7e 22                	jle    80069a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800678:	ff 75 14             	pushl  0x14(%ebp)
  80067b:	ff 75 10             	pushl  0x10(%ebp)
  80067e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800681:	50                   	push   %eax
  800682:	68 4e 02 80 00       	push   $0x80024e
  800687:	e8 fc fb ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	eb 05                	jmp    80069f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    

008006a1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006aa:	50                   	push   %eax
  8006ab:	ff 75 10             	pushl  0x10(%ebp)
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	ff 75 08             	pushl  0x8(%ebp)
  8006b4:	e8 9a ff ff ff       	call   800653 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b9:	c9                   	leave  
  8006ba:	c3                   	ret    

008006bb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c6:	eb 03                	jmp    8006cb <strlen+0x10>
		n++;
  8006c8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006cf:	75 f7                	jne    8006c8 <strlen+0xd>
		n++;
	return n;
}
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e1:	eb 03                	jmp    8006e6 <strnlen+0x13>
		n++;
  8006e3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e6:	39 c2                	cmp    %eax,%edx
  8006e8:	74 08                	je     8006f2 <strnlen+0x1f>
  8006ea:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ee:	75 f3                	jne    8006e3 <strnlen+0x10>
  8006f0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    

008006f4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	53                   	push   %ebx
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006fe:	89 c2                	mov    %eax,%edx
  800700:	83 c2 01             	add    $0x1,%edx
  800703:	83 c1 01             	add    $0x1,%ecx
  800706:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80070d:	84 db                	test   %bl,%bl
  80070f:	75 ef                	jne    800700 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800711:	5b                   	pop    %ebx
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071b:	53                   	push   %ebx
  80071c:	e8 9a ff ff ff       	call   8006bb <strlen>
  800721:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800724:	ff 75 0c             	pushl  0xc(%ebp)
  800727:	01 d8                	add    %ebx,%eax
  800729:	50                   	push   %eax
  80072a:	e8 c5 ff ff ff       	call   8006f4 <strcpy>
	return dst;
}
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	56                   	push   %esi
  80073a:	53                   	push   %ebx
  80073b:	8b 75 08             	mov    0x8(%ebp),%esi
  80073e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800741:	89 f3                	mov    %esi,%ebx
  800743:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800746:	89 f2                	mov    %esi,%edx
  800748:	eb 0f                	jmp    800759 <strncpy+0x23>
		*dst++ = *src;
  80074a:	83 c2 01             	add    $0x1,%edx
  80074d:	0f b6 01             	movzbl (%ecx),%eax
  800750:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800753:	80 39 01             	cmpb   $0x1,(%ecx)
  800756:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800759:	39 da                	cmp    %ebx,%edx
  80075b:	75 ed                	jne    80074a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80075d:	89 f0                	mov    %esi,%eax
  80075f:	5b                   	pop    %ebx
  800760:	5e                   	pop    %esi
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	8b 75 08             	mov    0x8(%ebp),%esi
  80076b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076e:	8b 55 10             	mov    0x10(%ebp),%edx
  800771:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800773:	85 d2                	test   %edx,%edx
  800775:	74 21                	je     800798 <strlcpy+0x35>
  800777:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077b:	89 f2                	mov    %esi,%edx
  80077d:	eb 09                	jmp    800788 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80077f:	83 c2 01             	add    $0x1,%edx
  800782:	83 c1 01             	add    $0x1,%ecx
  800785:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800788:	39 c2                	cmp    %eax,%edx
  80078a:	74 09                	je     800795 <strlcpy+0x32>
  80078c:	0f b6 19             	movzbl (%ecx),%ebx
  80078f:	84 db                	test   %bl,%bl
  800791:	75 ec                	jne    80077f <strlcpy+0x1c>
  800793:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800795:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800798:	29 f0                	sub    %esi,%eax
}
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a7:	eb 06                	jmp    8007af <strcmp+0x11>
		p++, q++;
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007af:	0f b6 01             	movzbl (%ecx),%eax
  8007b2:	84 c0                	test   %al,%al
  8007b4:	74 04                	je     8007ba <strcmp+0x1c>
  8007b6:	3a 02                	cmp    (%edx),%al
  8007b8:	74 ef                	je     8007a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ba:	0f b6 c0             	movzbl %al,%eax
  8007bd:	0f b6 12             	movzbl (%edx),%edx
  8007c0:	29 d0                	sub    %edx,%eax
}
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	89 c3                	mov    %eax,%ebx
  8007d0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d3:	eb 06                	jmp    8007db <strncmp+0x17>
		n--, p++, q++;
  8007d5:	83 c0 01             	add    $0x1,%eax
  8007d8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007db:	39 d8                	cmp    %ebx,%eax
  8007dd:	74 15                	je     8007f4 <strncmp+0x30>
  8007df:	0f b6 08             	movzbl (%eax),%ecx
  8007e2:	84 c9                	test   %cl,%cl
  8007e4:	74 04                	je     8007ea <strncmp+0x26>
  8007e6:	3a 0a                	cmp    (%edx),%cl
  8007e8:	74 eb                	je     8007d5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ea:	0f b6 00             	movzbl (%eax),%eax
  8007ed:	0f b6 12             	movzbl (%edx),%edx
  8007f0:	29 d0                	sub    %edx,%eax
  8007f2:	eb 05                	jmp    8007f9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800806:	eb 07                	jmp    80080f <strchr+0x13>
		if (*s == c)
  800808:	38 ca                	cmp    %cl,%dl
  80080a:	74 0f                	je     80081b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080c:	83 c0 01             	add    $0x1,%eax
  80080f:	0f b6 10             	movzbl (%eax),%edx
  800812:	84 d2                	test   %dl,%dl
  800814:	75 f2                	jne    800808 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800827:	eb 03                	jmp    80082c <strfind+0xf>
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80082f:	38 ca                	cmp    %cl,%dl
  800831:	74 04                	je     800837 <strfind+0x1a>
  800833:	84 d2                	test   %dl,%dl
  800835:	75 f2                	jne    800829 <strfind+0xc>
			break;
	return (char *) s;
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	57                   	push   %edi
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800842:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 36                	je     80087f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800849:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084f:	75 28                	jne    800879 <memset+0x40>
  800851:	f6 c1 03             	test   $0x3,%cl
  800854:	75 23                	jne    800879 <memset+0x40>
		c &= 0xFF;
  800856:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085a:	89 d3                	mov    %edx,%ebx
  80085c:	c1 e3 08             	shl    $0x8,%ebx
  80085f:	89 d6                	mov    %edx,%esi
  800861:	c1 e6 18             	shl    $0x18,%esi
  800864:	89 d0                	mov    %edx,%eax
  800866:	c1 e0 10             	shl    $0x10,%eax
  800869:	09 f0                	or     %esi,%eax
  80086b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80086d:	89 d8                	mov    %ebx,%eax
  80086f:	09 d0                	or     %edx,%eax
  800871:	c1 e9 02             	shr    $0x2,%ecx
  800874:	fc                   	cld    
  800875:	f3 ab                	rep stos %eax,%es:(%edi)
  800877:	eb 06                	jmp    80087f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	fc                   	cld    
  80087d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80087f:	89 f8                	mov    %edi,%eax
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5f                   	pop    %edi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	57                   	push   %edi
  80088a:	56                   	push   %esi
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800891:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800894:	39 c6                	cmp    %eax,%esi
  800896:	73 35                	jae    8008cd <memmove+0x47>
  800898:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089b:	39 d0                	cmp    %edx,%eax
  80089d:	73 2e                	jae    8008cd <memmove+0x47>
		s += n;
		d += n;
  80089f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a2:	89 d6                	mov    %edx,%esi
  8008a4:	09 fe                	or     %edi,%esi
  8008a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ac:	75 13                	jne    8008c1 <memmove+0x3b>
  8008ae:	f6 c1 03             	test   $0x3,%cl
  8008b1:	75 0e                	jne    8008c1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b3:	83 ef 04             	sub    $0x4,%edi
  8008b6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
  8008bc:	fd                   	std    
  8008bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bf:	eb 09                	jmp    8008ca <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c1:	83 ef 01             	sub    $0x1,%edi
  8008c4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c7:	fd                   	std    
  8008c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ca:	fc                   	cld    
  8008cb:	eb 1d                	jmp    8008ea <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cd:	89 f2                	mov    %esi,%edx
  8008cf:	09 c2                	or     %eax,%edx
  8008d1:	f6 c2 03             	test   $0x3,%dl
  8008d4:	75 0f                	jne    8008e5 <memmove+0x5f>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 0a                	jne    8008e5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008db:	c1 e9 02             	shr    $0x2,%ecx
  8008de:	89 c7                	mov    %eax,%edi
  8008e0:	fc                   	cld    
  8008e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e3:	eb 05                	jmp    8008ea <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e5:	89 c7                	mov    %eax,%edi
  8008e7:	fc                   	cld    
  8008e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f1:	ff 75 10             	pushl  0x10(%ebp)
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 87 ff ff ff       	call   800886 <memmove>
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 c6                	mov    %eax,%esi
  80090e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800911:	eb 1a                	jmp    80092d <memcmp+0x2c>
		if (*s1 != *s2)
  800913:	0f b6 08             	movzbl (%eax),%ecx
  800916:	0f b6 1a             	movzbl (%edx),%ebx
  800919:	38 d9                	cmp    %bl,%cl
  80091b:	74 0a                	je     800927 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80091d:	0f b6 c1             	movzbl %cl,%eax
  800920:	0f b6 db             	movzbl %bl,%ebx
  800923:	29 d8                	sub    %ebx,%eax
  800925:	eb 0f                	jmp    800936 <memcmp+0x35>
		s1++, s2++;
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092d:	39 f0                	cmp    %esi,%eax
  80092f:	75 e2                	jne    800913 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800941:	89 c1                	mov    %eax,%ecx
  800943:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800946:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094a:	eb 0a                	jmp    800956 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094c:	0f b6 10             	movzbl (%eax),%edx
  80094f:	39 da                	cmp    %ebx,%edx
  800951:	74 07                	je     80095a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	39 c8                	cmp    %ecx,%eax
  800958:	72 f2                	jb     80094c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800966:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800969:	eb 03                	jmp    80096e <strtol+0x11>
		s++;
  80096b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096e:	0f b6 01             	movzbl (%ecx),%eax
  800971:	3c 20                	cmp    $0x20,%al
  800973:	74 f6                	je     80096b <strtol+0xe>
  800975:	3c 09                	cmp    $0x9,%al
  800977:	74 f2                	je     80096b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800979:	3c 2b                	cmp    $0x2b,%al
  80097b:	75 0a                	jne    800987 <strtol+0x2a>
		s++;
  80097d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800980:	bf 00 00 00 00       	mov    $0x0,%edi
  800985:	eb 11                	jmp    800998 <strtol+0x3b>
  800987:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80098c:	3c 2d                	cmp    $0x2d,%al
  80098e:	75 08                	jne    800998 <strtol+0x3b>
		s++, neg = 1;
  800990:	83 c1 01             	add    $0x1,%ecx
  800993:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800998:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80099e:	75 15                	jne    8009b5 <strtol+0x58>
  8009a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a3:	75 10                	jne    8009b5 <strtol+0x58>
  8009a5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a9:	75 7c                	jne    800a27 <strtol+0xca>
		s += 2, base = 16;
  8009ab:	83 c1 02             	add    $0x2,%ecx
  8009ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b3:	eb 16                	jmp    8009cb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b5:	85 db                	test   %ebx,%ebx
  8009b7:	75 12                	jne    8009cb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009be:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c1:	75 08                	jne    8009cb <strtol+0x6e>
		s++, base = 8;
  8009c3:	83 c1 01             	add    $0x1,%ecx
  8009c6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d3:	0f b6 11             	movzbl (%ecx),%edx
  8009d6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009d9:	89 f3                	mov    %esi,%ebx
  8009db:	80 fb 09             	cmp    $0x9,%bl
  8009de:	77 08                	ja     8009e8 <strtol+0x8b>
			dig = *s - '0';
  8009e0:	0f be d2             	movsbl %dl,%edx
  8009e3:	83 ea 30             	sub    $0x30,%edx
  8009e6:	eb 22                	jmp    800a0a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009e8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009eb:	89 f3                	mov    %esi,%ebx
  8009ed:	80 fb 19             	cmp    $0x19,%bl
  8009f0:	77 08                	ja     8009fa <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f2:	0f be d2             	movsbl %dl,%edx
  8009f5:	83 ea 57             	sub    $0x57,%edx
  8009f8:	eb 10                	jmp    800a0a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fa:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009fd:	89 f3                	mov    %esi,%ebx
  8009ff:	80 fb 19             	cmp    $0x19,%bl
  800a02:	77 16                	ja     800a1a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a04:	0f be d2             	movsbl %dl,%edx
  800a07:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a0d:	7d 0b                	jge    800a1a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a16:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a18:	eb b9                	jmp    8009d3 <strtol+0x76>

	if (endptr)
  800a1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1e:	74 0d                	je     800a2d <strtol+0xd0>
		*endptr = (char *) s;
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	89 0e                	mov    %ecx,(%esi)
  800a25:	eb 06                	jmp    800a2d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a27:	85 db                	test   %ebx,%ebx
  800a29:	74 98                	je     8009c3 <strtol+0x66>
  800a2b:	eb 9e                	jmp    8009cb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a2d:	89 c2                	mov    %eax,%edx
  800a2f:	f7 da                	neg    %edx
  800a31:	85 ff                	test   %edi,%edi
  800a33:	0f 45 c2             	cmovne %edx,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
  800a46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	89 c7                	mov    %eax,%edi
  800a50:	89 c6                	mov    %eax,%esi
  800a52:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a64:	b8 01 00 00 00       	mov    $0x1,%eax
  800a69:	89 d1                	mov    %edx,%ecx
  800a6b:	89 d3                	mov    %edx,%ebx
  800a6d:	89 d7                	mov    %edx,%edi
  800a6f:	89 d6                	mov    %edx,%esi
  800a71:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5f                   	pop    %edi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a86:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8e:	89 cb                	mov    %ecx,%ebx
  800a90:	89 cf                	mov    %ecx,%edi
  800a92:	89 ce                	mov    %ecx,%esi
  800a94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a96:	85 c0                	test   %eax,%eax
  800a98:	7e 17                	jle    800ab1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9a:	83 ec 0c             	sub    $0xc,%esp
  800a9d:	50                   	push   %eax
  800a9e:	6a 03                	push   $0x3
  800aa0:	68 1f 21 80 00       	push   $0x80211f
  800aa5:	6a 23                	push   $0x23
  800aa7:	68 3c 21 80 00       	push   $0x80213c
  800aac:	e8 21 0f 00 00       	call   8019d2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac9:	89 d1                	mov    %edx,%ecx
  800acb:	89 d3                	mov    %edx,%ebx
  800acd:	89 d7                	mov    %edx,%edi
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_yield>:

void
sys_yield(void)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ae8:	89 d1                	mov    %edx,%ecx
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	be 00 00 00 00       	mov    $0x0,%esi
  800b05:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b13:	89 f7                	mov    %esi,%edi
  800b15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	7e 17                	jle    800b32 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	50                   	push   %eax
  800b1f:	6a 04                	push   $0x4
  800b21:	68 1f 21 80 00       	push   $0x80211f
  800b26:	6a 23                	push   $0x23
  800b28:	68 3c 21 80 00       	push   $0x80213c
  800b2d:	e8 a0 0e 00 00       	call   8019d2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b8 05 00 00 00       	mov    $0x5,%eax
  800b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b51:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b54:	8b 75 18             	mov    0x18(%ebp),%esi
  800b57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 05                	push   $0x5
  800b63:	68 1f 21 80 00       	push   $0x80211f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 3c 21 80 00       	push   $0x80213c
  800b6f:	e8 5e 0e 00 00       	call   8019d2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	89 df                	mov    %ebx,%edi
  800b97:	89 de                	mov    %ebx,%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 06                	push   $0x6
  800ba5:	68 1f 21 80 00       	push   $0x80211f
  800baa:	6a 23                	push   $0x23
  800bac:	68 3c 21 80 00       	push   $0x80213c
  800bb1:	e8 1c 0e 00 00       	call   8019d2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcc:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 df                	mov    %ebx,%edi
  800bd9:	89 de                	mov    %ebx,%esi
  800bdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 08                	push   $0x8
  800be7:	68 1f 21 80 00       	push   $0x80211f
  800bec:	6a 23                	push   $0x23
  800bee:	68 3c 21 80 00       	push   $0x80213c
  800bf3:	e8 da 0d 00 00       	call   8019d2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 09                	push   $0x9
  800c29:	68 1f 21 80 00       	push   $0x80211f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 3c 21 80 00       	push   $0x80213c
  800c35:	e8 98 0d 00 00       	call   8019d2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 0a                	push   $0xa
  800c6b:	68 1f 21 80 00       	push   $0x80211f
  800c70:	6a 23                	push   $0x23
  800c72:	68 3c 21 80 00       	push   $0x80213c
  800c77:	e8 56 0d 00 00       	call   8019d2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	be 00 00 00 00       	mov    $0x0,%esi
  800c8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 cb                	mov    %ecx,%ebx
  800cbf:	89 cf                	mov    %ecx,%edi
  800cc1:	89 ce                	mov    %ecx,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 0d                	push   $0xd
  800ccf:	68 1f 21 80 00       	push   $0x80211f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 3c 21 80 00       	push   $0x80213c
  800cdb:	e8 f2 0c 00 00       	call   8019d2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf3:	c1 e8 0c             	shr    $0xc,%eax
}
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	05 00 00 00 30       	add    $0x30000000,%eax
  800d03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d08:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d15:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d1a:	89 c2                	mov    %eax,%edx
  800d1c:	c1 ea 16             	shr    $0x16,%edx
  800d1f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d26:	f6 c2 01             	test   $0x1,%dl
  800d29:	74 11                	je     800d3c <fd_alloc+0x2d>
  800d2b:	89 c2                	mov    %eax,%edx
  800d2d:	c1 ea 0c             	shr    $0xc,%edx
  800d30:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d37:	f6 c2 01             	test   $0x1,%dl
  800d3a:	75 09                	jne    800d45 <fd_alloc+0x36>
			*fd_store = fd;
  800d3c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d43:	eb 17                	jmp    800d5c <fd_alloc+0x4d>
  800d45:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d4a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d4f:	75 c9                	jne    800d1a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d51:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d57:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d64:	83 f8 1f             	cmp    $0x1f,%eax
  800d67:	77 36                	ja     800d9f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d69:	c1 e0 0c             	shl    $0xc,%eax
  800d6c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	c1 ea 16             	shr    $0x16,%edx
  800d76:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d7d:	f6 c2 01             	test   $0x1,%dl
  800d80:	74 24                	je     800da6 <fd_lookup+0x48>
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	c1 ea 0c             	shr    $0xc,%edx
  800d87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d8e:	f6 c2 01             	test   $0x1,%dl
  800d91:	74 1a                	je     800dad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d96:	89 02                	mov    %eax,(%edx)
	return 0;
  800d98:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9d:	eb 13                	jmp    800db2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da4:	eb 0c                	jmp    800db2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dab:	eb 05                	jmp    800db2 <fd_lookup+0x54>
  800dad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
  800dba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbd:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dc2:	eb 13                	jmp    800dd7 <dev_lookup+0x23>
  800dc4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dc7:	39 08                	cmp    %ecx,(%eax)
  800dc9:	75 0c                	jne    800dd7 <dev_lookup+0x23>
			*dev = devtab[i];
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd5:	eb 2e                	jmp    800e05 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dd7:	8b 02                	mov    (%edx),%eax
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	75 e7                	jne    800dc4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ddd:	a1 04 40 80 00       	mov    0x804004,%eax
  800de2:	8b 40 48             	mov    0x48(%eax),%eax
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	51                   	push   %ecx
  800de9:	50                   	push   %eax
  800dea:	68 4c 21 80 00       	push   $0x80214c
  800def:	e8 5d f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    

00800e07 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 10             	sub    $0x10,%esp
  800e0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e18:	50                   	push   %eax
  800e19:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e1f:	c1 e8 0c             	shr    $0xc,%eax
  800e22:	50                   	push   %eax
  800e23:	e8 36 ff ff ff       	call   800d5e <fd_lookup>
  800e28:	83 c4 08             	add    $0x8,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 05                	js     800e34 <fd_close+0x2d>
	    || fd != fd2)
  800e2f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e32:	74 0c                	je     800e40 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e34:	84 db                	test   %bl,%bl
  800e36:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3b:	0f 44 c2             	cmove  %edx,%eax
  800e3e:	eb 41                	jmp    800e81 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e46:	50                   	push   %eax
  800e47:	ff 36                	pushl  (%esi)
  800e49:	e8 66 ff ff ff       	call   800db4 <dev_lookup>
  800e4e:	89 c3                	mov    %eax,%ebx
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	78 1a                	js     800e71 <fd_close+0x6a>
		if (dev->dev_close)
  800e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e5d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	74 0b                	je     800e71 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	56                   	push   %esi
  800e6a:	ff d0                	call   *%eax
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	56                   	push   %esi
  800e75:	6a 00                	push   $0x0
  800e77:	e8 00 fd ff ff       	call   800b7c <sys_page_unmap>
	return r;
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	89 d8                	mov    %ebx,%eax
}
  800e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff 75 08             	pushl  0x8(%ebp)
  800e95:	e8 c4 fe ff ff       	call   800d5e <fd_lookup>
  800e9a:	83 c4 08             	add    $0x8,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	78 10                	js     800eb1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	6a 01                	push   $0x1
  800ea6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea9:	e8 59 ff ff ff       	call   800e07 <fd_close>
  800eae:	83 c4 10             	add    $0x10,%esp
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <close_all>:

void
close_all(void)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	53                   	push   %ebx
  800eb7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	53                   	push   %ebx
  800ec3:	e8 c0 ff ff ff       	call   800e88 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec8:	83 c3 01             	add    $0x1,%ebx
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	83 fb 20             	cmp    $0x20,%ebx
  800ed1:	75 ec                	jne    800ebf <close_all+0xc>
		close(i);
}
  800ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 2c             	sub    $0x2c,%esp
  800ee1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ee4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ee7:	50                   	push   %eax
  800ee8:	ff 75 08             	pushl  0x8(%ebp)
  800eeb:	e8 6e fe ff ff       	call   800d5e <fd_lookup>
  800ef0:	83 c4 08             	add    $0x8,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	0f 88 c1 00 00 00    	js     800fbc <dup+0xe4>
		return r;
	close(newfdnum);
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	56                   	push   %esi
  800eff:	e8 84 ff ff ff       	call   800e88 <close>

	newfd = INDEX2FD(newfdnum);
  800f04:	89 f3                	mov    %esi,%ebx
  800f06:	c1 e3 0c             	shl    $0xc,%ebx
  800f09:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f0f:	83 c4 04             	add    $0x4,%esp
  800f12:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f15:	e8 de fd ff ff       	call   800cf8 <fd2data>
  800f1a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f1c:	89 1c 24             	mov    %ebx,(%esp)
  800f1f:	e8 d4 fd ff ff       	call   800cf8 <fd2data>
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f2a:	89 f8                	mov    %edi,%eax
  800f2c:	c1 e8 16             	shr    $0x16,%eax
  800f2f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f36:	a8 01                	test   $0x1,%al
  800f38:	74 37                	je     800f71 <dup+0x99>
  800f3a:	89 f8                	mov    %edi,%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
  800f3f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f46:	f6 c2 01             	test   $0x1,%dl
  800f49:	74 26                	je     800f71 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f4b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5a:	50                   	push   %eax
  800f5b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f5e:	6a 00                	push   $0x0
  800f60:	57                   	push   %edi
  800f61:	6a 00                	push   $0x0
  800f63:	e8 d2 fb ff ff       	call   800b3a <sys_page_map>
  800f68:	89 c7                	mov    %eax,%edi
  800f6a:	83 c4 20             	add    $0x20,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 2e                	js     800f9f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f71:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f74:	89 d0                	mov    %edx,%eax
  800f76:	c1 e8 0c             	shr    $0xc,%eax
  800f79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	25 07 0e 00 00       	and    $0xe07,%eax
  800f88:	50                   	push   %eax
  800f89:	53                   	push   %ebx
  800f8a:	6a 00                	push   $0x0
  800f8c:	52                   	push   %edx
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 a6 fb ff ff       	call   800b3a <sys_page_map>
  800f94:	89 c7                	mov    %eax,%edi
  800f96:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f99:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9b:	85 ff                	test   %edi,%edi
  800f9d:	79 1d                	jns    800fbc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	53                   	push   %ebx
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 d2 fb ff ff       	call   800b7c <sys_page_unmap>
	sys_page_unmap(0, nva);
  800faa:	83 c4 08             	add    $0x8,%esp
  800fad:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 c5 fb ff ff       	call   800b7c <sys_page_unmap>
	return r;
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	89 f8                	mov    %edi,%eax
}
  800fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 14             	sub    $0x14,%esp
  800fcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	53                   	push   %ebx
  800fd3:	e8 86 fd ff ff       	call   800d5e <fd_lookup>
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	89 c2                	mov    %eax,%edx
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 6d                	js     80104e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800feb:	ff 30                	pushl  (%eax)
  800fed:	e8 c2 fd ff ff       	call   800db4 <dev_lookup>
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 4c                	js     801045 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ff9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffc:	8b 42 08             	mov    0x8(%edx),%eax
  800fff:	83 e0 03             	and    $0x3,%eax
  801002:	83 f8 01             	cmp    $0x1,%eax
  801005:	75 21                	jne    801028 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801007:	a1 04 40 80 00       	mov    0x804004,%eax
  80100c:	8b 40 48             	mov    0x48(%eax),%eax
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	53                   	push   %ebx
  801013:	50                   	push   %eax
  801014:	68 8d 21 80 00       	push   $0x80218d
  801019:	e8 33 f1 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801026:	eb 26                	jmp    80104e <read+0x8a>
	}
	if (!dev->dev_read)
  801028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102b:	8b 40 08             	mov    0x8(%eax),%eax
  80102e:	85 c0                	test   %eax,%eax
  801030:	74 17                	je     801049 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	ff 75 10             	pushl  0x10(%ebp)
  801038:	ff 75 0c             	pushl  0xc(%ebp)
  80103b:	52                   	push   %edx
  80103c:	ff d0                	call   *%eax
  80103e:	89 c2                	mov    %eax,%edx
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	eb 09                	jmp    80104e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801045:	89 c2                	mov    %eax,%edx
  801047:	eb 05                	jmp    80104e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801049:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80104e:	89 d0                	mov    %edx,%eax
  801050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801061:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801064:	bb 00 00 00 00       	mov    $0x0,%ebx
  801069:	eb 21                	jmp    80108c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80106b:	83 ec 04             	sub    $0x4,%esp
  80106e:	89 f0                	mov    %esi,%eax
  801070:	29 d8                	sub    %ebx,%eax
  801072:	50                   	push   %eax
  801073:	89 d8                	mov    %ebx,%eax
  801075:	03 45 0c             	add    0xc(%ebp),%eax
  801078:	50                   	push   %eax
  801079:	57                   	push   %edi
  80107a:	e8 45 ff ff ff       	call   800fc4 <read>
		if (m < 0)
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 10                	js     801096 <readn+0x41>
			return m;
		if (m == 0)
  801086:	85 c0                	test   %eax,%eax
  801088:	74 0a                	je     801094 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108a:	01 c3                	add    %eax,%ebx
  80108c:	39 f3                	cmp    %esi,%ebx
  80108e:	72 db                	jb     80106b <readn+0x16>
  801090:	89 d8                	mov    %ebx,%eax
  801092:	eb 02                	jmp    801096 <readn+0x41>
  801094:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801096:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801099:	5b                   	pop    %ebx
  80109a:	5e                   	pop    %esi
  80109b:	5f                   	pop    %edi
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 14             	sub    $0x14,%esp
  8010a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	53                   	push   %ebx
  8010ad:	e8 ac fc ff ff       	call   800d5e <fd_lookup>
  8010b2:	83 c4 08             	add    $0x8,%esp
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 68                	js     801123 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c5:	ff 30                	pushl  (%eax)
  8010c7:	e8 e8 fc ff ff       	call   800db4 <dev_lookup>
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 47                	js     80111a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010da:	75 21                	jne    8010fd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e1:	8b 40 48             	mov    0x48(%eax),%eax
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	53                   	push   %ebx
  8010e8:	50                   	push   %eax
  8010e9:	68 a9 21 80 00       	push   $0x8021a9
  8010ee:	e8 5e f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010fb:	eb 26                	jmp    801123 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801100:	8b 52 0c             	mov    0xc(%edx),%edx
  801103:	85 d2                	test   %edx,%edx
  801105:	74 17                	je     80111e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	ff 75 10             	pushl  0x10(%ebp)
  80110d:	ff 75 0c             	pushl  0xc(%ebp)
  801110:	50                   	push   %eax
  801111:	ff d2                	call   *%edx
  801113:	89 c2                	mov    %eax,%edx
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	eb 09                	jmp    801123 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	eb 05                	jmp    801123 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80111e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801123:	89 d0                	mov    %edx,%eax
  801125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801128:	c9                   	leave  
  801129:	c3                   	ret    

0080112a <seek>:

int
seek(int fdnum, off_t offset)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801130:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801133:	50                   	push   %eax
  801134:	ff 75 08             	pushl  0x8(%ebp)
  801137:	e8 22 fc ff ff       	call   800d5e <fd_lookup>
  80113c:	83 c4 08             	add    $0x8,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 0e                	js     801151 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801143:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801146:	8b 55 0c             	mov    0xc(%ebp),%edx
  801149:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80114c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	53                   	push   %ebx
  801157:	83 ec 14             	sub    $0x14,%esp
  80115a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80115d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	53                   	push   %ebx
  801162:	e8 f7 fb ff ff       	call   800d5e <fd_lookup>
  801167:	83 c4 08             	add    $0x8,%esp
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 65                	js     8011d5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117a:	ff 30                	pushl  (%eax)
  80117c:	e8 33 fc ff ff       	call   800db4 <dev_lookup>
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 44                	js     8011cc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801188:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80118f:	75 21                	jne    8011b2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801191:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801196:	8b 40 48             	mov    0x48(%eax),%eax
  801199:	83 ec 04             	sub    $0x4,%esp
  80119c:	53                   	push   %ebx
  80119d:	50                   	push   %eax
  80119e:	68 6c 21 80 00       	push   $0x80216c
  8011a3:	e8 a9 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b0:	eb 23                	jmp    8011d5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011b5:	8b 52 18             	mov    0x18(%edx),%edx
  8011b8:	85 d2                	test   %edx,%edx
  8011ba:	74 14                	je     8011d0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011bc:	83 ec 08             	sub    $0x8,%esp
  8011bf:	ff 75 0c             	pushl  0xc(%ebp)
  8011c2:	50                   	push   %eax
  8011c3:	ff d2                	call   *%edx
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	eb 09                	jmp    8011d5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	eb 05                	jmp    8011d5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011d5:	89 d0                	mov    %edx,%eax
  8011d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 14             	sub    $0x14,%esp
  8011e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	ff 75 08             	pushl  0x8(%ebp)
  8011ed:	e8 6c fb ff ff       	call   800d5e <fd_lookup>
  8011f2:	83 c4 08             	add    $0x8,%esp
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 58                	js     801253 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fb:	83 ec 08             	sub    $0x8,%esp
  8011fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	ff 30                	pushl  (%eax)
  801207:	e8 a8 fb ff ff       	call   800db4 <dev_lookup>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 37                	js     80124a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801213:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801216:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80121a:	74 32                	je     80124e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80121c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80121f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801226:	00 00 00 
	stat->st_isdir = 0;
  801229:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801230:	00 00 00 
	stat->st_dev = dev;
  801233:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	53                   	push   %ebx
  80123d:	ff 75 f0             	pushl  -0x10(%ebp)
  801240:	ff 50 14             	call   *0x14(%eax)
  801243:	89 c2                	mov    %eax,%edx
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	eb 09                	jmp    801253 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	eb 05                	jmp    801253 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80124e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801253:	89 d0                	mov    %edx,%eax
  801255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	6a 00                	push   $0x0
  801264:	ff 75 08             	pushl  0x8(%ebp)
  801267:	e8 e3 01 00 00       	call   80144f <open>
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 1b                	js     801290 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801275:	83 ec 08             	sub    $0x8,%esp
  801278:	ff 75 0c             	pushl  0xc(%ebp)
  80127b:	50                   	push   %eax
  80127c:	e8 5b ff ff ff       	call   8011dc <fstat>
  801281:	89 c6                	mov    %eax,%esi
	close(fd);
  801283:	89 1c 24             	mov    %ebx,(%esp)
  801286:	e8 fd fb ff ff       	call   800e88 <close>
	return r;
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	89 f0                	mov    %esi,%eax
}
  801290:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	89 c6                	mov    %eax,%esi
  80129e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012a0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012a7:	75 12                	jne    8012bb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	6a 01                	push   $0x1
  8012ae:	e8 0e 08 00 00       	call   801ac1 <ipc_find_env>
  8012b3:	a3 00 40 80 00       	mov    %eax,0x804000
  8012b8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012bb:	6a 07                	push   $0x7
  8012bd:	68 00 50 80 00       	push   $0x805000
  8012c2:	56                   	push   %esi
  8012c3:	ff 35 00 40 80 00    	pushl  0x804000
  8012c9:	e8 9f 07 00 00       	call   801a6d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012ce:	83 c4 0c             	add    $0xc,%esp
  8012d1:	6a 00                	push   $0x0
  8012d3:	53                   	push   %ebx
  8012d4:	6a 00                	push   $0x0
  8012d6:	e8 3d 07 00 00       	call   801a18 <ipc_recv>
}
  8012db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801300:	b8 02 00 00 00       	mov    $0x2,%eax
  801305:	e8 8d ff ff ff       	call   801297 <fsipc>
}
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    

0080130c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	8b 40 0c             	mov    0xc(%eax),%eax
  801318:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80131d:	ba 00 00 00 00       	mov    $0x0,%edx
  801322:	b8 06 00 00 00       	mov    $0x6,%eax
  801327:	e8 6b ff ff ff       	call   801297 <fsipc>
}
  80132c:	c9                   	leave  
  80132d:	c3                   	ret    

0080132e <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	53                   	push   %ebx
  801332:	83 ec 04             	sub    $0x4,%esp
  801335:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	8b 40 0c             	mov    0xc(%eax),%eax
  80133e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801343:	ba 00 00 00 00       	mov    $0x0,%edx
  801348:	b8 05 00 00 00       	mov    $0x5,%eax
  80134d:	e8 45 ff ff ff       	call   801297 <fsipc>
  801352:	85 c0                	test   %eax,%eax
  801354:	78 2c                	js     801382 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	68 00 50 80 00       	push   $0x805000
  80135e:	53                   	push   %ebx
  80135f:	e8 90 f3 ff ff       	call   8006f4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801364:	a1 80 50 80 00       	mov    0x805080,%eax
  801369:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80136f:	a1 84 50 80 00       	mov    0x805084,%eax
  801374:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801382:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801390:	8b 55 08             	mov    0x8(%ebp),%edx
  801393:	8b 52 0c             	mov    0xc(%edx),%edx
  801396:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80139c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013a1:	ba 00 10 00 00       	mov    $0x1000,%edx
  8013a6:	0f 47 c2             	cmova  %edx,%eax
  8013a9:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013ae:	50                   	push   %eax
  8013af:	ff 75 0c             	pushl  0xc(%ebp)
  8013b2:	68 08 50 80 00       	push   $0x805008
  8013b7:	e8 ca f4 ff ff       	call   800886 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8013bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8013c6:	e8 cc fe ff ff       	call   801297 <fsipc>
    return r;
}
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013e0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8013f0:	e8 a2 fe ff ff       	call   801297 <fsipc>
  8013f5:	89 c3                	mov    %eax,%ebx
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 4b                	js     801446 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013fb:	39 c6                	cmp    %eax,%esi
  8013fd:	73 16                	jae    801415 <devfile_read+0x48>
  8013ff:	68 d8 21 80 00       	push   $0x8021d8
  801404:	68 df 21 80 00       	push   $0x8021df
  801409:	6a 7c                	push   $0x7c
  80140b:	68 f4 21 80 00       	push   $0x8021f4
  801410:	e8 bd 05 00 00       	call   8019d2 <_panic>
	assert(r <= PGSIZE);
  801415:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80141a:	7e 16                	jle    801432 <devfile_read+0x65>
  80141c:	68 ff 21 80 00       	push   $0x8021ff
  801421:	68 df 21 80 00       	push   $0x8021df
  801426:	6a 7d                	push   $0x7d
  801428:	68 f4 21 80 00       	push   $0x8021f4
  80142d:	e8 a0 05 00 00       	call   8019d2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	50                   	push   %eax
  801436:	68 00 50 80 00       	push   $0x805000
  80143b:	ff 75 0c             	pushl  0xc(%ebp)
  80143e:	e8 43 f4 ff ff       	call   800886 <memmove>
	return r;
  801443:	83 c4 10             	add    $0x10,%esp
}
  801446:	89 d8                	mov    %ebx,%eax
  801448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 20             	sub    $0x20,%esp
  801456:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801459:	53                   	push   %ebx
  80145a:	e8 5c f2 ff ff       	call   8006bb <strlen>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801467:	7f 67                	jg     8014d0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	e8 9a f8 ff ff       	call   800d0f <fd_alloc>
  801475:	83 c4 10             	add    $0x10,%esp
		return r;
  801478:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 57                	js     8014d5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	53                   	push   %ebx
  801482:	68 00 50 80 00       	push   $0x805000
  801487:	e8 68 f2 ff ff       	call   8006f4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80148c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801494:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801497:	b8 01 00 00 00       	mov    $0x1,%eax
  80149c:	e8 f6 fd ff ff       	call   801297 <fsipc>
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	79 14                	jns    8014be <open+0x6f>
		fd_close(fd, 0);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	6a 00                	push   $0x0
  8014af:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b2:	e8 50 f9 ff ff       	call   800e07 <fd_close>
		return r;
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	89 da                	mov    %ebx,%edx
  8014bc:	eb 17                	jmp    8014d5 <open+0x86>
	}

	return fd2num(fd);
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c4:	e8 1f f8 ff ff       	call   800ce8 <fd2num>
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	eb 05                	jmp    8014d5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014d0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014d5:	89 d0                	mov    %edx,%eax
  8014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ec:	e8 a6 fd ff ff       	call   801297 <fsipc>
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	ff 75 08             	pushl  0x8(%ebp)
  801501:	e8 f2 f7 ff ff       	call   800cf8 <fd2data>
  801506:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801508:	83 c4 08             	add    $0x8,%esp
  80150b:	68 0b 22 80 00       	push   $0x80220b
  801510:	53                   	push   %ebx
  801511:	e8 de f1 ff ff       	call   8006f4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801516:	8b 46 04             	mov    0x4(%esi),%eax
  801519:	2b 06                	sub    (%esi),%eax
  80151b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801521:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801528:	00 00 00 
	stat->st_dev = &devpipe;
  80152b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801532:	30 80 00 
	return 0;
}
  801535:	b8 00 00 00 00       	mov    $0x0,%eax
  80153a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153d:	5b                   	pop    %ebx
  80153e:	5e                   	pop    %esi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80154b:	53                   	push   %ebx
  80154c:	6a 00                	push   $0x0
  80154e:	e8 29 f6 ff ff       	call   800b7c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801553:	89 1c 24             	mov    %ebx,(%esp)
  801556:	e8 9d f7 ff ff       	call   800cf8 <fd2data>
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	50                   	push   %eax
  80155f:	6a 00                	push   $0x0
  801561:	e8 16 f6 ff ff       	call   800b7c <sys_page_unmap>
}
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	57                   	push   %edi
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	83 ec 1c             	sub    $0x1c,%esp
  801574:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801577:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801579:	a1 04 40 80 00       	mov    0x804004,%eax
  80157e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801581:	83 ec 0c             	sub    $0xc,%esp
  801584:	ff 75 e0             	pushl  -0x20(%ebp)
  801587:	e8 6e 05 00 00       	call   801afa <pageref>
  80158c:	89 c3                	mov    %eax,%ebx
  80158e:	89 3c 24             	mov    %edi,(%esp)
  801591:	e8 64 05 00 00       	call   801afa <pageref>
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	39 c3                	cmp    %eax,%ebx
  80159b:	0f 94 c1             	sete   %cl
  80159e:	0f b6 c9             	movzbl %cl,%ecx
  8015a1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015a4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015aa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015ad:	39 ce                	cmp    %ecx,%esi
  8015af:	74 1b                	je     8015cc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015b1:	39 c3                	cmp    %eax,%ebx
  8015b3:	75 c4                	jne    801579 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015b5:	8b 42 58             	mov    0x58(%edx),%eax
  8015b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015bb:	50                   	push   %eax
  8015bc:	56                   	push   %esi
  8015bd:	68 12 22 80 00       	push   $0x802212
  8015c2:	e8 8a eb ff ff       	call   800151 <cprintf>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb ad                	jmp    801579 <_pipeisclosed+0xe>
	}
}
  8015cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 28             	sub    $0x28,%esp
  8015e0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015e3:	56                   	push   %esi
  8015e4:	e8 0f f7 ff ff       	call   800cf8 <fd2data>
  8015e9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8015f3:	eb 4b                	jmp    801640 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015f5:	89 da                	mov    %ebx,%edx
  8015f7:	89 f0                	mov    %esi,%eax
  8015f9:	e8 6d ff ff ff       	call   80156b <_pipeisclosed>
  8015fe:	85 c0                	test   %eax,%eax
  801600:	75 48                	jne    80164a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801602:	e8 d1 f4 ff ff       	call   800ad8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801607:	8b 43 04             	mov    0x4(%ebx),%eax
  80160a:	8b 0b                	mov    (%ebx),%ecx
  80160c:	8d 51 20             	lea    0x20(%ecx),%edx
  80160f:	39 d0                	cmp    %edx,%eax
  801611:	73 e2                	jae    8015f5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801613:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801616:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80161a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80161d:	89 c2                	mov    %eax,%edx
  80161f:	c1 fa 1f             	sar    $0x1f,%edx
  801622:	89 d1                	mov    %edx,%ecx
  801624:	c1 e9 1b             	shr    $0x1b,%ecx
  801627:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80162a:	83 e2 1f             	and    $0x1f,%edx
  80162d:	29 ca                	sub    %ecx,%edx
  80162f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801633:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801637:	83 c0 01             	add    $0x1,%eax
  80163a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163d:	83 c7 01             	add    $0x1,%edi
  801640:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801643:	75 c2                	jne    801607 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801645:	8b 45 10             	mov    0x10(%ebp),%eax
  801648:	eb 05                	jmp    80164f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80164f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801652:	5b                   	pop    %ebx
  801653:	5e                   	pop    %esi
  801654:	5f                   	pop    %edi
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    

00801657 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	57                   	push   %edi
  80165b:	56                   	push   %esi
  80165c:	53                   	push   %ebx
  80165d:	83 ec 18             	sub    $0x18,%esp
  801660:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801663:	57                   	push   %edi
  801664:	e8 8f f6 ff ff       	call   800cf8 <fd2data>
  801669:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801673:	eb 3d                	jmp    8016b2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801675:	85 db                	test   %ebx,%ebx
  801677:	74 04                	je     80167d <devpipe_read+0x26>
				return i;
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	eb 44                	jmp    8016c1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80167d:	89 f2                	mov    %esi,%edx
  80167f:	89 f8                	mov    %edi,%eax
  801681:	e8 e5 fe ff ff       	call   80156b <_pipeisclosed>
  801686:	85 c0                	test   %eax,%eax
  801688:	75 32                	jne    8016bc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80168a:	e8 49 f4 ff ff       	call   800ad8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80168f:	8b 06                	mov    (%esi),%eax
  801691:	3b 46 04             	cmp    0x4(%esi),%eax
  801694:	74 df                	je     801675 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801696:	99                   	cltd   
  801697:	c1 ea 1b             	shr    $0x1b,%edx
  80169a:	01 d0                	add    %edx,%eax
  80169c:	83 e0 1f             	and    $0x1f,%eax
  80169f:	29 d0                	sub    %edx,%eax
  8016a1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ac:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016af:	83 c3 01             	add    $0x1,%ebx
  8016b2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016b5:	75 d8                	jne    80168f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ba:	eb 05                	jmp    8016c1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016bc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5e                   	pop    %esi
  8016c6:	5f                   	pop    %edi
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	56                   	push   %esi
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	e8 35 f6 ff ff       	call   800d0f <fd_alloc>
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	0f 88 2c 01 00 00    	js     801813 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e7:	83 ec 04             	sub    $0x4,%esp
  8016ea:	68 07 04 00 00       	push   $0x407
  8016ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f2:	6a 00                	push   $0x0
  8016f4:	e8 fe f3 ff ff       	call   800af7 <sys_page_alloc>
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	85 c0                	test   %eax,%eax
  801700:	0f 88 0d 01 00 00    	js     801813 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801706:	83 ec 0c             	sub    $0xc,%esp
  801709:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	e8 fd f5 ff ff       	call   800d0f <fd_alloc>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	0f 88 e2 00 00 00    	js     801801 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80171f:	83 ec 04             	sub    $0x4,%esp
  801722:	68 07 04 00 00       	push   $0x407
  801727:	ff 75 f0             	pushl  -0x10(%ebp)
  80172a:	6a 00                	push   $0x0
  80172c:	e8 c6 f3 ff ff       	call   800af7 <sys_page_alloc>
  801731:	89 c3                	mov    %eax,%ebx
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	85 c0                	test   %eax,%eax
  801738:	0f 88 c3 00 00 00    	js     801801 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	ff 75 f4             	pushl  -0xc(%ebp)
  801744:	e8 af f5 ff ff       	call   800cf8 <fd2data>
  801749:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174b:	83 c4 0c             	add    $0xc,%esp
  80174e:	68 07 04 00 00       	push   $0x407
  801753:	50                   	push   %eax
  801754:	6a 00                	push   $0x0
  801756:	e8 9c f3 ff ff       	call   800af7 <sys_page_alloc>
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	0f 88 89 00 00 00    	js     8017f1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801768:	83 ec 0c             	sub    $0xc,%esp
  80176b:	ff 75 f0             	pushl  -0x10(%ebp)
  80176e:	e8 85 f5 ff ff       	call   800cf8 <fd2data>
  801773:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80177a:	50                   	push   %eax
  80177b:	6a 00                	push   $0x0
  80177d:	56                   	push   %esi
  80177e:	6a 00                	push   $0x0
  801780:	e8 b5 f3 ff ff       	call   800b3a <sys_page_map>
  801785:	89 c3                	mov    %eax,%ebx
  801787:	83 c4 20             	add    $0x20,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 55                	js     8017e3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80178e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017a3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017b8:	83 ec 0c             	sub    $0xc,%esp
  8017bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017be:	e8 25 f5 ff ff       	call   800ce8 <fd2num>
  8017c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017c8:	83 c4 04             	add    $0x4,%esp
  8017cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ce:	e8 15 f5 ff ff       	call   800ce8 <fd2num>
  8017d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e1:	eb 30                	jmp    801813 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	56                   	push   %esi
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 8e f3 ff ff       	call   800b7c <sys_page_unmap>
  8017ee:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f7:	6a 00                	push   $0x0
  8017f9:	e8 7e f3 ff ff       	call   800b7c <sys_page_unmap>
  8017fe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	ff 75 f4             	pushl  -0xc(%ebp)
  801807:	6a 00                	push   $0x0
  801809:	e8 6e f3 ff ff       	call   800b7c <sys_page_unmap>
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801813:	89 d0                	mov    %edx,%eax
  801815:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	ff 75 08             	pushl  0x8(%ebp)
  801829:	e8 30 f5 ff ff       	call   800d5e <fd_lookup>
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	78 18                	js     80184d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801835:	83 ec 0c             	sub    $0xc,%esp
  801838:	ff 75 f4             	pushl  -0xc(%ebp)
  80183b:	e8 b8 f4 ff ff       	call   800cf8 <fd2data>
	return _pipeisclosed(fd, p);
  801840:	89 c2                	mov    %eax,%edx
  801842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801845:	e8 21 fd ff ff       	call   80156b <_pipeisclosed>
  80184a:	83 c4 10             	add    $0x10,%esp
}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80185f:	68 2a 22 80 00       	push   $0x80222a
  801864:	ff 75 0c             	pushl  0xc(%ebp)
  801867:	e8 88 ee ff ff       	call   8006f4 <strcpy>
	return 0;
}
  80186c:	b8 00 00 00 00       	mov    $0x0,%eax
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	57                   	push   %edi
  801877:	56                   	push   %esi
  801878:	53                   	push   %ebx
  801879:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80187f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801884:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188a:	eb 2d                	jmp    8018b9 <devcons_write+0x46>
		m = n - tot;
  80188c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80188f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801891:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801894:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801899:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	53                   	push   %ebx
  8018a0:	03 45 0c             	add    0xc(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	57                   	push   %edi
  8018a5:	e8 dc ef ff ff       	call   800886 <memmove>
		sys_cputs(buf, m);
  8018aa:	83 c4 08             	add    $0x8,%esp
  8018ad:	53                   	push   %ebx
  8018ae:	57                   	push   %edi
  8018af:	e8 87 f1 ff ff       	call   800a3b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b4:	01 de                	add    %ebx,%esi
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	89 f0                	mov    %esi,%eax
  8018bb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018be:	72 cc                	jb     80188c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5f                   	pop    %edi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018d7:	74 2a                	je     801903 <devcons_read+0x3b>
  8018d9:	eb 05                	jmp    8018e0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018db:	e8 f8 f1 ff ff       	call   800ad8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018e0:	e8 74 f1 ff ff       	call   800a59 <sys_cgetc>
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	74 f2                	je     8018db <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 16                	js     801903 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018ed:	83 f8 04             	cmp    $0x4,%eax
  8018f0:	74 0c                	je     8018fe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f5:	88 02                	mov    %al,(%edx)
	return 1;
  8018f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fc:	eb 05                	jmp    801903 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801911:	6a 01                	push   $0x1
  801913:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801916:	50                   	push   %eax
  801917:	e8 1f f1 ff ff       	call   800a3b <sys_cputs>
}
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <getchar>:

int
getchar(void)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801927:	6a 01                	push   $0x1
  801929:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	6a 00                	push   $0x0
  80192f:	e8 90 f6 ff ff       	call   800fc4 <read>
	if (r < 0)
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 0f                	js     80194a <getchar+0x29>
		return r;
	if (r < 1)
  80193b:	85 c0                	test   %eax,%eax
  80193d:	7e 06                	jle    801945 <getchar+0x24>
		return -E_EOF;
	return c;
  80193f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801943:	eb 05                	jmp    80194a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801945:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	ff 75 08             	pushl  0x8(%ebp)
  801959:	e8 00 f4 ff ff       	call   800d5e <fd_lookup>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	85 c0                	test   %eax,%eax
  801963:	78 11                	js     801976 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801965:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801968:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80196e:	39 10                	cmp    %edx,(%eax)
  801970:	0f 94 c0             	sete   %al
  801973:	0f b6 c0             	movzbl %al,%eax
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <opencons>:

int
opencons(void)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801981:	50                   	push   %eax
  801982:	e8 88 f3 ff ff       	call   800d0f <fd_alloc>
  801987:	83 c4 10             	add    $0x10,%esp
		return r;
  80198a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 3e                	js     8019ce <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801990:	83 ec 04             	sub    $0x4,%esp
  801993:	68 07 04 00 00       	push   $0x407
  801998:	ff 75 f4             	pushl  -0xc(%ebp)
  80199b:	6a 00                	push   $0x0
  80199d:	e8 55 f1 ff ff       	call   800af7 <sys_page_alloc>
  8019a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 23                	js     8019ce <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	50                   	push   %eax
  8019c4:	e8 1f f3 ff ff       	call   800ce8 <fd2num>
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	83 c4 10             	add    $0x10,%esp
}
  8019ce:	89 d0                	mov    %edx,%eax
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	56                   	push   %esi
  8019d6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019d7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019da:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019e0:	e8 d4 f0 ff ff       	call   800ab9 <sys_getenvid>
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	ff 75 0c             	pushl  0xc(%ebp)
  8019eb:	ff 75 08             	pushl  0x8(%ebp)
  8019ee:	56                   	push   %esi
  8019ef:	50                   	push   %eax
  8019f0:	68 38 22 80 00       	push   $0x802238
  8019f5:	e8 57 e7 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019fa:	83 c4 18             	add    $0x18,%esp
  8019fd:	53                   	push   %ebx
  8019fe:	ff 75 10             	pushl  0x10(%ebp)
  801a01:	e8 fa e6 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801a06:	c7 04 24 23 22 80 00 	movl   $0x802223,(%esp)
  801a0d:	e8 3f e7 ff ff       	call   800151 <cprintf>
  801a12:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a15:	cc                   	int3   
  801a16:	eb fd                	jmp    801a15 <_panic+0x43>

00801a18 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a26:	85 c0                	test   %eax,%eax
  801a28:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a2d:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	50                   	push   %eax
  801a34:	e8 6e f2 ff ff       	call   800ca7 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	75 10                	jne    801a50 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a40:	a1 04 40 80 00       	mov    0x804004,%eax
  801a45:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a48:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a4b:	8b 40 70             	mov    0x70(%eax),%eax
  801a4e:	eb 0a                	jmp    801a5a <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a50:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a55:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a5a:	85 f6                	test   %esi,%esi
  801a5c:	74 02                	je     801a60 <ipc_recv+0x48>
  801a5e:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a60:	85 db                	test   %ebx,%ebx
  801a62:	74 02                	je     801a66 <ipc_recv+0x4e>
  801a64:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	57                   	push   %edi
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a79:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a7f:	85 db                	test   %ebx,%ebx
  801a81:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a86:	0f 44 d8             	cmove  %eax,%ebx
  801a89:	eb 1c                	jmp    801aa7 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a8b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8e:	74 12                	je     801aa2 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a90:	50                   	push   %eax
  801a91:	68 5c 22 80 00       	push   $0x80225c
  801a96:	6a 40                	push   $0x40
  801a98:	68 6e 22 80 00       	push   $0x80226e
  801a9d:	e8 30 ff ff ff       	call   8019d2 <_panic>
        sys_yield();
  801aa2:	e8 31 f0 ff ff       	call   800ad8 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aa7:	ff 75 14             	pushl  0x14(%ebp)
  801aaa:	53                   	push   %ebx
  801aab:	56                   	push   %esi
  801aac:	57                   	push   %edi
  801aad:	e8 d2 f1 ff ff       	call   800c84 <sys_ipc_try_send>
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	75 d2                	jne    801a8b <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5f                   	pop    %edi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801acc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801acf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad5:	8b 52 50             	mov    0x50(%edx),%edx
  801ad8:	39 ca                	cmp    %ecx,%edx
  801ada:	75 0d                	jne    801ae9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801adc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801adf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae4:	8b 40 48             	mov    0x48(%eax),%eax
  801ae7:	eb 0f                	jmp    801af8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae9:	83 c0 01             	add    $0x1,%eax
  801aec:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af1:	75 d9                	jne    801acc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b00:	89 d0                	mov    %edx,%eax
  801b02:	c1 e8 16             	shr    $0x16,%eax
  801b05:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b11:	f6 c1 01             	test   $0x1,%cl
  801b14:	74 1d                	je     801b33 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b16:	c1 ea 0c             	shr    $0xc,%edx
  801b19:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b20:	f6 c2 01             	test   $0x1,%dl
  801b23:	74 0e                	je     801b33 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b25:	c1 ea 0c             	shr    $0xc,%edx
  801b28:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2f:	ef 
  801b30:	0f b7 c0             	movzwl %ax,%eax
}
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    
  801b35:	66 90                	xchg   %ax,%ax
  801b37:	66 90                	xchg   %ax,%ax
  801b39:	66 90                	xchg   %ax,%ax
  801b3b:	66 90                	xchg   %ax,%ax
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b57:	85 f6                	test   %esi,%esi
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 ca                	mov    %ecx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	75 3d                	jne    801ba0 <__udivdi3+0x60>
  801b63:	39 cf                	cmp    %ecx,%edi
  801b65:	0f 87 c5 00 00 00    	ja     801c30 <__udivdi3+0xf0>
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	89 fd                	mov    %edi,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f7                	div    %edi
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 c8                	mov    %ecx,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c1                	mov    %eax,%ecx
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	89 cf                	mov    %ecx,%edi
  801b88:	f7 f5                	div    %ebp
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	89 fa                	mov    %edi,%edx
  801b90:	83 c4 1c             	add    $0x1c,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	90                   	nop
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	77 74                	ja     801c18 <__udivdi3+0xd8>
  801ba4:	0f bd fe             	bsr    %esi,%edi
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	0f 84 98 00 00 00    	je     801c48 <__udivdi3+0x108>
  801bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	89 c5                	mov    %eax,%ebp
  801bb9:	29 fb                	sub    %edi,%ebx
  801bbb:	d3 e6                	shl    %cl,%esi
  801bbd:	89 d9                	mov    %ebx,%ecx
  801bbf:	d3 ed                	shr    %cl,%ebp
  801bc1:	89 f9                	mov    %edi,%ecx
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	09 ee                	or     %ebp,%esi
  801bc7:	89 d9                	mov    %ebx,%ecx
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	89 d5                	mov    %edx,%ebp
  801bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bd3:	d3 ed                	shr    %cl,%ebp
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e2                	shl    %cl,%edx
  801bd9:	89 d9                	mov    %ebx,%ecx
  801bdb:	d3 e8                	shr    %cl,%eax
  801bdd:	09 c2                	or     %eax,%edx
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	89 ea                	mov    %ebp,%edx
  801be3:	f7 f6                	div    %esi
  801be5:	89 d5                	mov    %edx,%ebp
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	f7 64 24 0c          	mull   0xc(%esp)
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	72 10                	jb     801c01 <__udivdi3+0xc1>
  801bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e6                	shl    %cl,%esi
  801bf9:	39 c6                	cmp    %eax,%esi
  801bfb:	73 07                	jae    801c04 <__udivdi3+0xc4>
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	75 03                	jne    801c04 <__udivdi3+0xc4>
  801c01:	83 eb 01             	sub    $0x1,%ebx
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	83 c4 1c             	add    $0x1c,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    
  801c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	31 db                	xor    %ebx,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f7                	div    %edi
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	72 0c                	jb     801c58 <__udivdi3+0x118>
  801c4c:	31 db                	xor    %ebx,%ebx
  801c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c52:	0f 87 34 ff ff ff    	ja     801b8c <__udivdi3+0x4c>
  801c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c5d:	e9 2a ff ff ff       	jmp    801b8c <__udivdi3+0x4c>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 d2                	test   %edx,%edx
  801c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x48>
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	76 50                	jbe    801cf0 <__umoddi3+0x80>
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	f7 f7                	div    %edi
  801ca6:	89 d0                	mov    %edx,%eax
  801ca8:	31 d2                	xor    %edx,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	77 52                	ja     801d10 <__umoddi3+0xa0>
  801cbe:	0f bd ea             	bsr    %edx,%ebp
  801cc1:	83 f5 1f             	xor    $0x1f,%ebp
  801cc4:	75 5a                	jne    801d20 <__umoddi3+0xb0>
  801cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	39 0c 24             	cmp    %ecx,(%esp)
  801cd3:	0f 86 d7 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	89 fd                	mov    %edi,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 c8                	mov    %ecx,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	eb 99                	jmp    801ca8 <__umoddi3+0x38>
  801d0f:	90                   	nop
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 1c             	add    $0x1c,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	8b 34 24             	mov    (%esp),%esi
  801d23:	bf 20 00 00 00       	mov    $0x20,%edi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	29 ef                	sub    %ebp,%edi
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 f9                	mov    %edi,%ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	d3 ea                	shr    %cl,%edx
  801d34:	89 e9                	mov    %ebp,%ecx
  801d36:	09 c2                	or     %eax,%edx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 14 24             	mov    %edx,(%esp)
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	d3 e2                	shl    %cl,%edx
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	89 c6                	mov    %eax,%esi
  801d51:	d3 e3                	shl    %cl,%ebx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	09 d8                	or     %ebx,%eax
  801d5d:	89 d3                	mov    %edx,%ebx
  801d5f:	89 f2                	mov    %esi,%edx
  801d61:	f7 34 24             	divl   (%esp)
  801d64:	89 d6                	mov    %edx,%esi
  801d66:	d3 e3                	shl    %cl,%ebx
  801d68:	f7 64 24 04          	mull   0x4(%esp)
  801d6c:	39 d6                	cmp    %edx,%esi
  801d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	72 08                	jb     801d80 <__umoddi3+0x110>
  801d78:	75 11                	jne    801d8b <__umoddi3+0x11b>
  801d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d7e:	73 0b                	jae    801d8b <__umoddi3+0x11b>
  801d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d84:	1b 14 24             	sbb    (%esp),%edx
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d8f:	29 da                	sub    %ebx,%edx
  801d91:	19 ce                	sbb    %ecx,%esi
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	d3 ee                	shr    %cl,%esi
  801da1:	09 d0                	or     %edx,%eax
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 f9                	sub    %edi,%ecx
  801db2:	19 d6                	sbb    %edx,%esi
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbc:	e9 18 ff ff ff       	jmp    801cd9 <__umoddi3+0x69>
