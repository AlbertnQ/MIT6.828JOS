
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 c0 1d 80 00       	push   $0x801dc0
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 4b 0a 00 00       	call   800aa9 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 04 0e 00 00       	call   800ea3 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 bf 09 00 00       	call   800a68 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 4d 09 00 00       	call   800a2b <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 54 01 00 00       	call   800278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 f2 08 00 00       	call   800a2b <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 87 19 00 00       	call   801b30 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 74 1a 00 00       	call   801c60 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 e8 1d 80 00 	movsbl 0x801de8(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800207:	83 fa 01             	cmp    $0x1,%edx
  80020a:	7e 0e                	jle    80021a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020c:	8b 10                	mov    (%eax),%edx
  80020e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800211:	89 08                	mov    %ecx,(%eax)
  800213:	8b 02                	mov    (%edx),%eax
  800215:	8b 52 04             	mov    0x4(%edx),%edx
  800218:	eb 22                	jmp    80023c <getuint+0x38>
	else if (lflag)
  80021a:	85 d2                	test   %edx,%edx
  80021c:	74 10                	je     80022e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 04             	lea    0x4(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	ba 00 00 00 00       	mov    $0x0,%edx
  80022c:	eb 0e                	jmp    80023c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800244:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	3b 50 04             	cmp    0x4(%eax),%edx
  80024d:	73 0a                	jae    800259 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	88 02                	mov    %al,(%edx)
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800261:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800264:	50                   	push   %eax
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	e8 05 00 00 00       	call   800278 <vprintfmt>
	va_end(ap);
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028a:	eb 12                	jmp    80029e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028c:	85 c0                	test   %eax,%eax
  80028e:	0f 84 a7 03 00 00    	je     80063b <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	53                   	push   %ebx
  800298:	50                   	push   %eax
  800299:	ff d6                	call   *%esi
  80029b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029e:	83 c7 01             	add    $0x1,%edi
  8002a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a5:	83 f8 25             	cmp    $0x25,%eax
  8002a8:	75 e2                	jne    80028c <vprintfmt+0x14>
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c3:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8002ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002cf:	eb 07                	jmp    8002d8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d8:	8d 47 01             	lea    0x1(%edi),%eax
  8002db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002de:	0f b6 07             	movzbl (%edi),%eax
  8002e1:	0f b6 d0             	movzbl %al,%edx
  8002e4:	83 e8 23             	sub    $0x23,%eax
  8002e7:	3c 55                	cmp    $0x55,%al
  8002e9:	0f 87 31 03 00 00    	ja     800620 <vprintfmt+0x3a8>
  8002ef:	0f b6 c0             	movzbl %al,%eax
  8002f2:	ff 24 85 20 1f 80 00 	jmp    *0x801f20(,%eax,4)
  8002f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800300:	eb d6                	jmp    8002d8 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800305:	b8 00 00 00 00       	mov    $0x0,%eax
  80030a:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800310:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800314:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800317:	8d 72 d0             	lea    -0x30(%edx),%esi
  80031a:	83 fe 09             	cmp    $0x9,%esi
  80031d:	77 34                	ja     800353 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800322:	eb e9                	jmp    80030d <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800324:	8b 45 14             	mov    0x14(%ebp),%eax
  800327:	8d 50 04             	lea    0x4(%eax),%edx
  80032a:	89 55 14             	mov    %edx,0x14(%ebp)
  80032d:	8b 00                	mov    (%eax),%eax
  80032f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800335:	eb 22                	jmp    800359 <vprintfmt+0xe1>
  800337:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033a:	85 c0                	test   %eax,%eax
  80033c:	0f 48 c1             	cmovs  %ecx,%eax
  80033f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800345:	eb 91                	jmp    8002d8 <vprintfmt+0x60>
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800351:	eb 85                	jmp    8002d8 <vprintfmt+0x60>
  800353:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800356:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035d:	0f 89 75 ff ff ff    	jns    8002d8 <vprintfmt+0x60>
				width = precision, precision = -1;
  800363:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800366:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800369:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800370:	e9 63 ff ff ff       	jmp    8002d8 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800375:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037c:	e9 57 ff ff ff       	jmp    8002d8 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8d 50 04             	lea    0x4(%eax),%edx
  800387:	89 55 14             	mov    %edx,0x14(%ebp)
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	53                   	push   %ebx
  80038e:	ff 30                	pushl  (%eax)
  800390:	ff d6                	call   *%esi
			break;
  800392:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800398:	e9 01 ff ff ff       	jmp    80029e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	99                   	cltd   
  8003a9:	31 d0                	xor    %edx,%eax
  8003ab:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ad:	83 f8 0f             	cmp    $0xf,%eax
  8003b0:	7f 0b                	jg     8003bd <vprintfmt+0x145>
  8003b2:	8b 14 85 80 20 80 00 	mov    0x802080(,%eax,4),%edx
  8003b9:	85 d2                	test   %edx,%edx
  8003bb:	75 18                	jne    8003d5 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8003bd:	50                   	push   %eax
  8003be:	68 00 1e 80 00       	push   $0x801e00
  8003c3:	53                   	push   %ebx
  8003c4:	56                   	push   %esi
  8003c5:	e8 91 fe ff ff       	call   80025b <printfmt>
  8003ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d0:	e9 c9 fe ff ff       	jmp    80029e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d5:	52                   	push   %edx
  8003d6:	68 b1 21 80 00       	push   $0x8021b1
  8003db:	53                   	push   %ebx
  8003dc:	56                   	push   %esi
  8003dd:	e8 79 fe ff ff       	call   80025b <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e8:	e9 b1 fe ff ff       	jmp    80029e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f8:	85 ff                	test   %edi,%edi
  8003fa:	b8 f9 1d 80 00       	mov    $0x801df9,%eax
  8003ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800402:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800406:	0f 8e 94 00 00 00    	jle    8004a0 <vprintfmt+0x228>
  80040c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800410:	0f 84 98 00 00 00    	je     8004ae <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	ff 75 cc             	pushl  -0x34(%ebp)
  80041c:	57                   	push   %edi
  80041d:	e8 a1 02 00 00       	call   8006c3 <strnlen>
  800422:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800425:	29 c1                	sub    %eax,%ecx
  800427:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80042a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800434:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800437:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	eb 0f                	jmp    80044a <vprintfmt+0x1d2>
					putch(padc, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 75 e0             	pushl  -0x20(%ebp)
  800442:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800444:	83 ef 01             	sub    $0x1,%edi
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	85 ff                	test   %edi,%edi
  80044c:	7f ed                	jg     80043b <vprintfmt+0x1c3>
  80044e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800451:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800454:	85 c9                	test   %ecx,%ecx
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	0f 49 c1             	cmovns %ecx,%eax
  80045e:	29 c1                	sub    %eax,%ecx
  800460:	89 75 08             	mov    %esi,0x8(%ebp)
  800463:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800466:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800469:	89 cb                	mov    %ecx,%ebx
  80046b:	eb 4d                	jmp    8004ba <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800471:	74 1b                	je     80048e <vprintfmt+0x216>
  800473:	0f be c0             	movsbl %al,%eax
  800476:	83 e8 20             	sub    $0x20,%eax
  800479:	83 f8 5e             	cmp    $0x5e,%eax
  80047c:	76 10                	jbe    80048e <vprintfmt+0x216>
					putch('?', putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 0c             	pushl  0xc(%ebp)
  800484:	6a 3f                	push   $0x3f
  800486:	ff 55 08             	call   *0x8(%ebp)
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	eb 0d                	jmp    80049b <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	ff 75 0c             	pushl  0xc(%ebp)
  800494:	52                   	push   %edx
  800495:	ff 55 08             	call   *0x8(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049b:	83 eb 01             	sub    $0x1,%ebx
  80049e:	eb 1a                	jmp    8004ba <vprintfmt+0x242>
  8004a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ac:	eb 0c                	jmp    8004ba <vprintfmt+0x242>
  8004ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ba:	83 c7 01             	add    $0x1,%edi
  8004bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c1:	0f be d0             	movsbl %al,%edx
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 23                	je     8004eb <vprintfmt+0x273>
  8004c8:	85 f6                	test   %esi,%esi
  8004ca:	78 a1                	js     80046d <vprintfmt+0x1f5>
  8004cc:	83 ee 01             	sub    $0x1,%esi
  8004cf:	79 9c                	jns    80046d <vprintfmt+0x1f5>
  8004d1:	89 df                	mov    %ebx,%edi
  8004d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d9:	eb 18                	jmp    8004f3 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	6a 20                	push   $0x20
  8004e1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb 08                	jmp    8004f3 <vprintfmt+0x27b>
  8004eb:	89 df                	mov    %ebx,%edi
  8004ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	7f e4                	jg     8004db <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fa:	e9 9f fd ff ff       	jmp    80029e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ff:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800503:	7e 16                	jle    80051b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 50 08             	lea    0x8(%eax),%edx
  80050b:	89 55 14             	mov    %edx,0x14(%ebp)
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	eb 34                	jmp    80054f <vprintfmt+0x2d7>
	else if (lflag)
  80051b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80051f:	74 18                	je     800539 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052f:	89 c1                	mov    %eax,%ecx
  800531:	c1 f9 1f             	sar    $0x1f,%ecx
  800534:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800537:	eb 16                	jmp    80054f <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800547:	89 c1                	mov    %eax,%ecx
  800549:	c1 f9 1f             	sar    $0x1f,%ecx
  80054c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800552:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800555:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055e:	0f 89 88 00 00 00    	jns    8005ec <vprintfmt+0x374>
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 2d                	push   $0x2d
  80056a:	ff d6                	call   *%esi
				num = -(long long) num;
  80056c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800572:	f7 d8                	neg    %eax
  800574:	83 d2 00             	adc    $0x0,%edx
  800577:	f7 da                	neg    %edx
  800579:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800581:	eb 69                	jmp    8005ec <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800583:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 76 fc ff ff       	call   800204 <getuint>
			base = 10;
  80058e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800593:	eb 57                	jmp    8005ec <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	53                   	push   %ebx
  800599:	6a 30                	push   $0x30
  80059b:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80059d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a3:	e8 5c fc ff ff       	call   800204 <getuint>
			base = 8;
			goto number;
  8005a8:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005ab:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005b0:	eb 3a                	jmp    8005ec <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 30                	push   $0x30
  8005b8:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ba:	83 c4 08             	add    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 78                	push   $0x78
  8005c0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005da:	eb 10                	jmp    8005ec <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005dc:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 1d fc ff ff       	call   800204 <getuint>
			base = 16;
  8005e7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f3:	57                   	push   %edi
  8005f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f7:	51                   	push   %ecx
  8005f8:	52                   	push   %edx
  8005f9:	50                   	push   %eax
  8005fa:	89 da                	mov    %ebx,%edx
  8005fc:	89 f0                	mov    %esi,%eax
  8005fe:	e8 52 fb ff ff       	call   800155 <printnum>
			break;
  800603:	83 c4 20             	add    $0x20,%esp
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800609:	e9 90 fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	52                   	push   %edx
  800613:	ff d6                	call   *%esi
			break;
  800615:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80061b:	e9 7e fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 25                	push   $0x25
  800626:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	eb 03                	jmp    800630 <vprintfmt+0x3b8>
  80062d:	83 ef 01             	sub    $0x1,%edi
  800630:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800634:	75 f7                	jne    80062d <vprintfmt+0x3b5>
  800636:	e9 63 fc ff ff       	jmp    80029e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80063b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	5f                   	pop    %edi
  800641:	5d                   	pop    %ebp
  800642:	c3                   	ret    

00800643 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	83 ec 18             	sub    $0x18,%esp
  800649:	8b 45 08             	mov    0x8(%ebp),%eax
  80064c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800652:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800656:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800659:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800660:	85 c0                	test   %eax,%eax
  800662:	74 26                	je     80068a <vsnprintf+0x47>
  800664:	85 d2                	test   %edx,%edx
  800666:	7e 22                	jle    80068a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800668:	ff 75 14             	pushl  0x14(%ebp)
  80066b:	ff 75 10             	pushl  0x10(%ebp)
  80066e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	68 3e 02 80 00       	push   $0x80023e
  800677:	e8 fc fb ff ff       	call   800278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	eb 05                	jmp    80068f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    

00800691 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069a:	50                   	push   %eax
  80069b:	ff 75 10             	pushl  0x10(%ebp)
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	e8 9a ff ff ff       	call   800643 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b6:	eb 03                	jmp    8006bb <strlen+0x10>
		n++;
  8006b8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006bf:	75 f7                	jne    8006b8 <strlen+0xd>
		n++;
	return n;
}
  8006c1:	5d                   	pop    %ebp
  8006c2:	c3                   	ret    

008006c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d1:	eb 03                	jmp    8006d6 <strnlen+0x13>
		n++;
  8006d3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d6:	39 c2                	cmp    %eax,%edx
  8006d8:	74 08                	je     8006e2 <strnlen+0x1f>
  8006da:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006de:	75 f3                	jne    8006d3 <strnlen+0x10>
  8006e0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	53                   	push   %ebx
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	83 c2 01             	add    $0x1,%edx
  8006f3:	83 c1 01             	add    $0x1,%ecx
  8006f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006fd:	84 db                	test   %bl,%bl
  8006ff:	75 ef                	jne    8006f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800701:	5b                   	pop    %ebx
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80070b:	53                   	push   %ebx
  80070c:	e8 9a ff ff ff       	call   8006ab <strlen>
  800711:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	01 d8                	add    %ebx,%eax
  800719:	50                   	push   %eax
  80071a:	e8 c5 ff ff ff       	call   8006e4 <strcpy>
	return dst;
}
  80071f:	89 d8                	mov    %ebx,%eax
  800721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	56                   	push   %esi
  80072a:	53                   	push   %ebx
  80072b:	8b 75 08             	mov    0x8(%ebp),%esi
  80072e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800731:	89 f3                	mov    %esi,%ebx
  800733:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800736:	89 f2                	mov    %esi,%edx
  800738:	eb 0f                	jmp    800749 <strncpy+0x23>
		*dst++ = *src;
  80073a:	83 c2 01             	add    $0x1,%edx
  80073d:	0f b6 01             	movzbl (%ecx),%eax
  800740:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800743:	80 39 01             	cmpb   $0x1,(%ecx)
  800746:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800749:	39 da                	cmp    %ebx,%edx
  80074b:	75 ed                	jne    80073a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80074d:	89 f0                	mov    %esi,%eax
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	8b 75 08             	mov    0x8(%ebp),%esi
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075e:	8b 55 10             	mov    0x10(%ebp),%edx
  800761:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800763:	85 d2                	test   %edx,%edx
  800765:	74 21                	je     800788 <strlcpy+0x35>
  800767:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80076b:	89 f2                	mov    %esi,%edx
  80076d:	eb 09                	jmp    800778 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80076f:	83 c2 01             	add    $0x1,%edx
  800772:	83 c1 01             	add    $0x1,%ecx
  800775:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800778:	39 c2                	cmp    %eax,%edx
  80077a:	74 09                	je     800785 <strlcpy+0x32>
  80077c:	0f b6 19             	movzbl (%ecx),%ebx
  80077f:	84 db                	test   %bl,%bl
  800781:	75 ec                	jne    80076f <strlcpy+0x1c>
  800783:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800785:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800788:	29 f0                	sub    %esi,%eax
}
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800797:	eb 06                	jmp    80079f <strcmp+0x11>
		p++, q++;
  800799:	83 c1 01             	add    $0x1,%ecx
  80079c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80079f:	0f b6 01             	movzbl (%ecx),%eax
  8007a2:	84 c0                	test   %al,%al
  8007a4:	74 04                	je     8007aa <strcmp+0x1c>
  8007a6:	3a 02                	cmp    (%edx),%al
  8007a8:	74 ef                	je     800799 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007aa:	0f b6 c0             	movzbl %al,%eax
  8007ad:	0f b6 12             	movzbl (%edx),%edx
  8007b0:	29 d0                	sub    %edx,%eax
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007be:	89 c3                	mov    %eax,%ebx
  8007c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c3:	eb 06                	jmp    8007cb <strncmp+0x17>
		n--, p++, q++;
  8007c5:	83 c0 01             	add    $0x1,%eax
  8007c8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007cb:	39 d8                	cmp    %ebx,%eax
  8007cd:	74 15                	je     8007e4 <strncmp+0x30>
  8007cf:	0f b6 08             	movzbl (%eax),%ecx
  8007d2:	84 c9                	test   %cl,%cl
  8007d4:	74 04                	je     8007da <strncmp+0x26>
  8007d6:	3a 0a                	cmp    (%edx),%cl
  8007d8:	74 eb                	je     8007c5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007da:	0f b6 00             	movzbl (%eax),%eax
  8007dd:	0f b6 12             	movzbl (%edx),%edx
  8007e0:	29 d0                	sub    %edx,%eax
  8007e2:	eb 05                	jmp    8007e9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007e9:	5b                   	pop    %ebx
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f6:	eb 07                	jmp    8007ff <strchr+0x13>
		if (*s == c)
  8007f8:	38 ca                	cmp    %cl,%dl
  8007fa:	74 0f                	je     80080b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007fc:	83 c0 01             	add    $0x1,%eax
  8007ff:	0f b6 10             	movzbl (%eax),%edx
  800802:	84 d2                	test   %dl,%dl
  800804:	75 f2                	jne    8007f8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800817:	eb 03                	jmp    80081c <strfind+0xf>
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80081f:	38 ca                	cmp    %cl,%dl
  800821:	74 04                	je     800827 <strfind+0x1a>
  800823:	84 d2                	test   %dl,%dl
  800825:	75 f2                	jne    800819 <strfind+0xc>
			break;
	return (char *) s;
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	57                   	push   %edi
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800832:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 36                	je     80086f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800839:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80083f:	75 28                	jne    800869 <memset+0x40>
  800841:	f6 c1 03             	test   $0x3,%cl
  800844:	75 23                	jne    800869 <memset+0x40>
		c &= 0xFF;
  800846:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084a:	89 d3                	mov    %edx,%ebx
  80084c:	c1 e3 08             	shl    $0x8,%ebx
  80084f:	89 d6                	mov    %edx,%esi
  800851:	c1 e6 18             	shl    $0x18,%esi
  800854:	89 d0                	mov    %edx,%eax
  800856:	c1 e0 10             	shl    $0x10,%eax
  800859:	09 f0                	or     %esi,%eax
  80085b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80085d:	89 d8                	mov    %ebx,%eax
  80085f:	09 d0                	or     %edx,%eax
  800861:	c1 e9 02             	shr    $0x2,%ecx
  800864:	fc                   	cld    
  800865:	f3 ab                	rep stos %eax,%es:(%edi)
  800867:	eb 06                	jmp    80086f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086c:	fc                   	cld    
  80086d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80086f:	89 f8                	mov    %edi,%eax
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5f                   	pop    %edi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	57                   	push   %edi
  80087a:	56                   	push   %esi
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800884:	39 c6                	cmp    %eax,%esi
  800886:	73 35                	jae    8008bd <memmove+0x47>
  800888:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	73 2e                	jae    8008bd <memmove+0x47>
		s += n;
		d += n;
  80088f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800892:	89 d6                	mov    %edx,%esi
  800894:	09 fe                	or     %edi,%esi
  800896:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089c:	75 13                	jne    8008b1 <memmove+0x3b>
  80089e:	f6 c1 03             	test   $0x3,%cl
  8008a1:	75 0e                	jne    8008b1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a3:	83 ef 04             	sub    $0x4,%edi
  8008a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008a9:	c1 e9 02             	shr    $0x2,%ecx
  8008ac:	fd                   	std    
  8008ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008af:	eb 09                	jmp    8008ba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b1:	83 ef 01             	sub    $0x1,%edi
  8008b4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008b7:	fd                   	std    
  8008b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ba:	fc                   	cld    
  8008bb:	eb 1d                	jmp    8008da <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bd:	89 f2                	mov    %esi,%edx
  8008bf:	09 c2                	or     %eax,%edx
  8008c1:	f6 c2 03             	test   $0x3,%dl
  8008c4:	75 0f                	jne    8008d5 <memmove+0x5f>
  8008c6:	f6 c1 03             	test   $0x3,%cl
  8008c9:	75 0a                	jne    8008d5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008cb:	c1 e9 02             	shr    $0x2,%ecx
  8008ce:	89 c7                	mov    %eax,%edi
  8008d0:	fc                   	cld    
  8008d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d3:	eb 05                	jmp    8008da <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d5:	89 c7                	mov    %eax,%edi
  8008d7:	fc                   	cld    
  8008d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008da:	5e                   	pop    %esi
  8008db:	5f                   	pop    %edi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	ff 75 08             	pushl  0x8(%ebp)
  8008ea:	e8 87 ff ff ff       	call   800876 <memmove>
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 c6                	mov    %eax,%esi
  8008fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800901:	eb 1a                	jmp    80091d <memcmp+0x2c>
		if (*s1 != *s2)
  800903:	0f b6 08             	movzbl (%eax),%ecx
  800906:	0f b6 1a             	movzbl (%edx),%ebx
  800909:	38 d9                	cmp    %bl,%cl
  80090b:	74 0a                	je     800917 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80090d:	0f b6 c1             	movzbl %cl,%eax
  800910:	0f b6 db             	movzbl %bl,%ebx
  800913:	29 d8                	sub    %ebx,%eax
  800915:	eb 0f                	jmp    800926 <memcmp+0x35>
		s1++, s2++;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091d:	39 f0                	cmp    %esi,%eax
  80091f:	75 e2                	jne    800903 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800931:	89 c1                	mov    %eax,%ecx
  800933:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800936:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093a:	eb 0a                	jmp    800946 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80093c:	0f b6 10             	movzbl (%eax),%edx
  80093f:	39 da                	cmp    %ebx,%edx
  800941:	74 07                	je     80094a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	39 c8                	cmp    %ecx,%eax
  800948:	72 f2                	jb     80093c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094a:	5b                   	pop    %ebx
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800956:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800959:	eb 03                	jmp    80095e <strtol+0x11>
		s++;
  80095b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095e:	0f b6 01             	movzbl (%ecx),%eax
  800961:	3c 20                	cmp    $0x20,%al
  800963:	74 f6                	je     80095b <strtol+0xe>
  800965:	3c 09                	cmp    $0x9,%al
  800967:	74 f2                	je     80095b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800969:	3c 2b                	cmp    $0x2b,%al
  80096b:	75 0a                	jne    800977 <strtol+0x2a>
		s++;
  80096d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800970:	bf 00 00 00 00       	mov    $0x0,%edi
  800975:	eb 11                	jmp    800988 <strtol+0x3b>
  800977:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80097c:	3c 2d                	cmp    $0x2d,%al
  80097e:	75 08                	jne    800988 <strtol+0x3b>
		s++, neg = 1;
  800980:	83 c1 01             	add    $0x1,%ecx
  800983:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800988:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80098e:	75 15                	jne    8009a5 <strtol+0x58>
  800990:	80 39 30             	cmpb   $0x30,(%ecx)
  800993:	75 10                	jne    8009a5 <strtol+0x58>
  800995:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800999:	75 7c                	jne    800a17 <strtol+0xca>
		s += 2, base = 16;
  80099b:	83 c1 02             	add    $0x2,%ecx
  80099e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a3:	eb 16                	jmp    8009bb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009a5:	85 db                	test   %ebx,%ebx
  8009a7:	75 12                	jne    8009bb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009a9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b1:	75 08                	jne    8009bb <strtol+0x6e>
		s++, base = 8;
  8009b3:	83 c1 01             	add    $0x1,%ecx
  8009b6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c3:	0f b6 11             	movzbl (%ecx),%edx
  8009c6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009c9:	89 f3                	mov    %esi,%ebx
  8009cb:	80 fb 09             	cmp    $0x9,%bl
  8009ce:	77 08                	ja     8009d8 <strtol+0x8b>
			dig = *s - '0';
  8009d0:	0f be d2             	movsbl %dl,%edx
  8009d3:	83 ea 30             	sub    $0x30,%edx
  8009d6:	eb 22                	jmp    8009fa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009d8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009db:	89 f3                	mov    %esi,%ebx
  8009dd:	80 fb 19             	cmp    $0x19,%bl
  8009e0:	77 08                	ja     8009ea <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e2:	0f be d2             	movsbl %dl,%edx
  8009e5:	83 ea 57             	sub    $0x57,%edx
  8009e8:	eb 10                	jmp    8009fa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ea:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	80 fb 19             	cmp    $0x19,%bl
  8009f2:	77 16                	ja     800a0a <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f4:	0f be d2             	movsbl %dl,%edx
  8009f7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009fa:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009fd:	7d 0b                	jge    800a0a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009ff:	83 c1 01             	add    $0x1,%ecx
  800a02:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a06:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a08:	eb b9                	jmp    8009c3 <strtol+0x76>

	if (endptr)
  800a0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0e:	74 0d                	je     800a1d <strtol+0xd0>
		*endptr = (char *) s;
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	89 0e                	mov    %ecx,(%esi)
  800a15:	eb 06                	jmp    800a1d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a17:	85 db                	test   %ebx,%ebx
  800a19:	74 98                	je     8009b3 <strtol+0x66>
  800a1b:	eb 9e                	jmp    8009bb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	f7 da                	neg    %edx
  800a21:	85 ff                	test   %edi,%edi
  800a23:	0f 45 c2             	cmovne %edx,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3c:	89 c3                	mov    %eax,%ebx
  800a3e:	89 c7                	mov    %eax,%edi
  800a40:	89 c6                	mov    %eax,%esi
  800a42:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a54:	b8 01 00 00 00       	mov    $0x1,%eax
  800a59:	89 d1                	mov    %edx,%ecx
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	89 d7                	mov    %edx,%edi
  800a5f:	89 d6                	mov    %edx,%esi
  800a61:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a76:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7e:	89 cb                	mov    %ecx,%ebx
  800a80:	89 cf                	mov    %ecx,%edi
  800a82:	89 ce                	mov    %ecx,%esi
  800a84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a86:	85 c0                	test   %eax,%eax
  800a88:	7e 17                	jle    800aa1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8a:	83 ec 0c             	sub    $0xc,%esp
  800a8d:	50                   	push   %eax
  800a8e:	6a 03                	push   $0x3
  800a90:	68 df 20 80 00       	push   $0x8020df
  800a95:	6a 23                	push   $0x23
  800a97:	68 fc 20 80 00       	push   $0x8020fc
  800a9c:	e8 21 0f 00 00       	call   8019c2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab9:	89 d1                	mov    %edx,%ecx
  800abb:	89 d3                	mov    %edx,%ebx
  800abd:	89 d7                	mov    %edx,%edi
  800abf:	89 d6                	mov    %edx,%esi
  800ac1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <sys_yield>:

void
sys_yield(void)
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
  800ad3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad8:	89 d1                	mov    %edx,%ecx
  800ada:	89 d3                	mov    %edx,%ebx
  800adc:	89 d7                	mov    %edx,%edi
  800ade:	89 d6                	mov    %edx,%esi
  800ae0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	be 00 00 00 00       	mov    $0x0,%esi
  800af5:	b8 04 00 00 00       	mov    $0x4,%eax
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b03:	89 f7                	mov    %esi,%edi
  800b05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b07:	85 c0                	test   %eax,%eax
  800b09:	7e 17                	jle    800b22 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	50                   	push   %eax
  800b0f:	6a 04                	push   $0x4
  800b11:	68 df 20 80 00       	push   $0x8020df
  800b16:	6a 23                	push   $0x23
  800b18:	68 fc 20 80 00       	push   $0x8020fc
  800b1d:	e8 a0 0e 00 00       	call   8019c2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b33:	b8 05 00 00 00       	mov    $0x5,%eax
  800b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b44:	8b 75 18             	mov    0x18(%ebp),%esi
  800b47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	7e 17                	jle    800b64 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	50                   	push   %eax
  800b51:	6a 05                	push   $0x5
  800b53:	68 df 20 80 00       	push   $0x8020df
  800b58:	6a 23                	push   $0x23
  800b5a:	68 fc 20 80 00       	push   $0x8020fc
  800b5f:	e8 5e 0e 00 00       	call   8019c2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b82:	8b 55 08             	mov    0x8(%ebp),%edx
  800b85:	89 df                	mov    %ebx,%edi
  800b87:	89 de                	mov    %ebx,%esi
  800b89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 17                	jle    800ba6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	50                   	push   %eax
  800b93:	6a 06                	push   $0x6
  800b95:	68 df 20 80 00       	push   $0x8020df
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 fc 20 80 00       	push   $0x8020fc
  800ba1:	e8 1c 0e 00 00       	call   8019c2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 df                	mov    %ebx,%edi
  800bc9:	89 de                	mov    %ebx,%esi
  800bcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	7e 17                	jle    800be8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	50                   	push   %eax
  800bd5:	6a 08                	push   $0x8
  800bd7:	68 df 20 80 00       	push   $0x8020df
  800bdc:	6a 23                	push   $0x23
  800bde:	68 fc 20 80 00       	push   $0x8020fc
  800be3:	e8 da 0d 00 00       	call   8019c2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 df                	mov    %ebx,%edi
  800c0b:	89 de                	mov    %ebx,%esi
  800c0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7e 17                	jle    800c2a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	50                   	push   %eax
  800c17:	6a 09                	push   $0x9
  800c19:	68 df 20 80 00       	push   $0x8020df
  800c1e:	6a 23                	push   $0x23
  800c20:	68 fc 20 80 00       	push   $0x8020fc
  800c25:	e8 98 0d 00 00       	call   8019c2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 df                	mov    %ebx,%edi
  800c4d:	89 de                	mov    %ebx,%esi
  800c4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 17                	jle    800c6c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 0a                	push   $0xa
  800c5b:	68 df 20 80 00       	push   $0x8020df
  800c60:	6a 23                	push   $0x23
  800c62:	68 fc 20 80 00       	push   $0x8020fc
  800c67:	e8 56 0d 00 00       	call   8019c2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	be 00 00 00 00       	mov    $0x0,%esi
  800c7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c90:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 cb                	mov    %ecx,%ebx
  800caf:	89 cf                	mov    %ecx,%edi
  800cb1:	89 ce                	mov    %ecx,%esi
  800cb3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 17                	jle    800cd0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 0d                	push   $0xd
  800cbf:	68 df 20 80 00       	push   $0x8020df
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 fc 20 80 00       	push   $0x8020fc
  800ccb:	e8 f2 0c 00 00       	call   8019c2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	05 00 00 00 30       	add    $0x30000000,%eax
  800ce3:	c1 e8 0c             	shr    $0xc,%eax
}
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cf8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d05:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d0a:	89 c2                	mov    %eax,%edx
  800d0c:	c1 ea 16             	shr    $0x16,%edx
  800d0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d16:	f6 c2 01             	test   $0x1,%dl
  800d19:	74 11                	je     800d2c <fd_alloc+0x2d>
  800d1b:	89 c2                	mov    %eax,%edx
  800d1d:	c1 ea 0c             	shr    $0xc,%edx
  800d20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d27:	f6 c2 01             	test   $0x1,%dl
  800d2a:	75 09                	jne    800d35 <fd_alloc+0x36>
			*fd_store = fd;
  800d2c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d33:	eb 17                	jmp    800d4c <fd_alloc+0x4d>
  800d35:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d3a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d3f:	75 c9                	jne    800d0a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d41:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d47:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d54:	83 f8 1f             	cmp    $0x1f,%eax
  800d57:	77 36                	ja     800d8f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d59:	c1 e0 0c             	shl    $0xc,%eax
  800d5c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	c1 ea 16             	shr    $0x16,%edx
  800d66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d6d:	f6 c2 01             	test   $0x1,%dl
  800d70:	74 24                	je     800d96 <fd_lookup+0x48>
  800d72:	89 c2                	mov    %eax,%edx
  800d74:	c1 ea 0c             	shr    $0xc,%edx
  800d77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7e:	f6 c2 01             	test   $0x1,%dl
  800d81:	74 1a                	je     800d9d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d86:	89 02                	mov    %eax,(%edx)
	return 0;
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8d:	eb 13                	jmp    800da2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d94:	eb 0c                	jmp    800da2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d9b:	eb 05                	jmp    800da2 <fd_lookup+0x54>
  800d9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 08             	sub    $0x8,%esp
  800daa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dad:	ba 88 21 80 00       	mov    $0x802188,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800db2:	eb 13                	jmp    800dc7 <dev_lookup+0x23>
  800db4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800db7:	39 08                	cmp    %ecx,(%eax)
  800db9:	75 0c                	jne    800dc7 <dev_lookup+0x23>
			*dev = devtab[i];
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc5:	eb 2e                	jmp    800df5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dc7:	8b 02                	mov    (%edx),%eax
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	75 e7                	jne    800db4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dcd:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd2:	8b 40 48             	mov    0x48(%eax),%eax
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	51                   	push   %ecx
  800dd9:	50                   	push   %eax
  800dda:	68 0c 21 80 00       	push   $0x80210c
  800ddf:	e8 5d f3 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800de4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 10             	sub    $0x10,%esp
  800dff:	8b 75 08             	mov    0x8(%ebp),%esi
  800e02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e08:	50                   	push   %eax
  800e09:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e0f:	c1 e8 0c             	shr    $0xc,%eax
  800e12:	50                   	push   %eax
  800e13:	e8 36 ff ff ff       	call   800d4e <fd_lookup>
  800e18:	83 c4 08             	add    $0x8,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	78 05                	js     800e24 <fd_close+0x2d>
	    || fd != fd2)
  800e1f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e22:	74 0c                	je     800e30 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e24:	84 db                	test   %bl,%bl
  800e26:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2b:	0f 44 c2             	cmove  %edx,%eax
  800e2e:	eb 41                	jmp    800e71 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e30:	83 ec 08             	sub    $0x8,%esp
  800e33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e36:	50                   	push   %eax
  800e37:	ff 36                	pushl  (%esi)
  800e39:	e8 66 ff ff ff       	call   800da4 <dev_lookup>
  800e3e:	89 c3                	mov    %eax,%ebx
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 1a                	js     800e61 <fd_close+0x6a>
		if (dev->dev_close)
  800e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	74 0b                	je     800e61 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e56:	83 ec 0c             	sub    $0xc,%esp
  800e59:	56                   	push   %esi
  800e5a:	ff d0                	call   *%eax
  800e5c:	89 c3                	mov    %eax,%ebx
  800e5e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	56                   	push   %esi
  800e65:	6a 00                	push   $0x0
  800e67:	e8 00 fd ff ff       	call   800b6c <sys_page_unmap>
	return r;
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	89 d8                	mov    %ebx,%eax
}
  800e71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e81:	50                   	push   %eax
  800e82:	ff 75 08             	pushl  0x8(%ebp)
  800e85:	e8 c4 fe ff ff       	call   800d4e <fd_lookup>
  800e8a:	83 c4 08             	add    $0x8,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 10                	js     800ea1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	6a 01                	push   $0x1
  800e96:	ff 75 f4             	pushl  -0xc(%ebp)
  800e99:	e8 59 ff ff ff       	call   800df7 <fd_close>
  800e9e:	83 c4 10             	add    $0x10,%esp
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <close_all>:

void
close_all(void)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	53                   	push   %ebx
  800eb3:	e8 c0 ff ff ff       	call   800e78 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eb8:	83 c3 01             	add    $0x1,%ebx
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	83 fb 20             	cmp    $0x20,%ebx
  800ec1:	75 ec                	jne    800eaf <close_all+0xc>
		close(i);
}
  800ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 2c             	sub    $0x2c,%esp
  800ed1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ed4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed7:	50                   	push   %eax
  800ed8:	ff 75 08             	pushl  0x8(%ebp)
  800edb:	e8 6e fe ff ff       	call   800d4e <fd_lookup>
  800ee0:	83 c4 08             	add    $0x8,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	0f 88 c1 00 00 00    	js     800fac <dup+0xe4>
		return r;
	close(newfdnum);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	56                   	push   %esi
  800eef:	e8 84 ff ff ff       	call   800e78 <close>

	newfd = INDEX2FD(newfdnum);
  800ef4:	89 f3                	mov    %esi,%ebx
  800ef6:	c1 e3 0c             	shl    $0xc,%ebx
  800ef9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800eff:	83 c4 04             	add    $0x4,%esp
  800f02:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f05:	e8 de fd ff ff       	call   800ce8 <fd2data>
  800f0a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f0c:	89 1c 24             	mov    %ebx,(%esp)
  800f0f:	e8 d4 fd ff ff       	call   800ce8 <fd2data>
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f1a:	89 f8                	mov    %edi,%eax
  800f1c:	c1 e8 16             	shr    $0x16,%eax
  800f1f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f26:	a8 01                	test   $0x1,%al
  800f28:	74 37                	je     800f61 <dup+0x99>
  800f2a:	89 f8                	mov    %edi,%eax
  800f2c:	c1 e8 0c             	shr    $0xc,%eax
  800f2f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f36:	f6 c2 01             	test   $0x1,%dl
  800f39:	74 26                	je     800f61 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f3b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4a:	50                   	push   %eax
  800f4b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f4e:	6a 00                	push   $0x0
  800f50:	57                   	push   %edi
  800f51:	6a 00                	push   $0x0
  800f53:	e8 d2 fb ff ff       	call   800b2a <sys_page_map>
  800f58:	89 c7                	mov    %eax,%edi
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 2e                	js     800f8f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f61:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f64:	89 d0                	mov    %edx,%eax
  800f66:	c1 e8 0c             	shr    $0xc,%eax
  800f69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	25 07 0e 00 00       	and    $0xe07,%eax
  800f78:	50                   	push   %eax
  800f79:	53                   	push   %ebx
  800f7a:	6a 00                	push   $0x0
  800f7c:	52                   	push   %edx
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 a6 fb ff ff       	call   800b2a <sys_page_map>
  800f84:	89 c7                	mov    %eax,%edi
  800f86:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f89:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8b:	85 ff                	test   %edi,%edi
  800f8d:	79 1d                	jns    800fac <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	53                   	push   %ebx
  800f93:	6a 00                	push   $0x0
  800f95:	e8 d2 fb ff ff       	call   800b6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f9a:	83 c4 08             	add    $0x8,%esp
  800f9d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 c5 fb ff ff       	call   800b6c <sys_page_unmap>
	return r;
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	89 f8                	mov    %edi,%eax
}
  800fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 14             	sub    $0x14,%esp
  800fbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	53                   	push   %ebx
  800fc3:	e8 86 fd ff ff       	call   800d4e <fd_lookup>
  800fc8:	83 c4 08             	add    $0x8,%esp
  800fcb:	89 c2                	mov    %eax,%edx
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 6d                	js     80103e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fd1:	83 ec 08             	sub    $0x8,%esp
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdb:	ff 30                	pushl  (%eax)
  800fdd:	e8 c2 fd ff ff       	call   800da4 <dev_lookup>
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 4c                	js     801035 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fe9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fec:	8b 42 08             	mov    0x8(%edx),%eax
  800fef:	83 e0 03             	and    $0x3,%eax
  800ff2:	83 f8 01             	cmp    $0x1,%eax
  800ff5:	75 21                	jne    801018 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ff7:	a1 04 40 80 00       	mov    0x804004,%eax
  800ffc:	8b 40 48             	mov    0x48(%eax),%eax
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	53                   	push   %ebx
  801003:	50                   	push   %eax
  801004:	68 4d 21 80 00       	push   $0x80214d
  801009:	e8 33 f1 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801016:	eb 26                	jmp    80103e <read+0x8a>
	}
	if (!dev->dev_read)
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	8b 40 08             	mov    0x8(%eax),%eax
  80101e:	85 c0                	test   %eax,%eax
  801020:	74 17                	je     801039 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	ff 75 10             	pushl  0x10(%ebp)
  801028:	ff 75 0c             	pushl  0xc(%ebp)
  80102b:	52                   	push   %edx
  80102c:	ff d0                	call   *%eax
  80102e:	89 c2                	mov    %eax,%edx
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	eb 09                	jmp    80103e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801035:	89 c2                	mov    %eax,%edx
  801037:	eb 05                	jmp    80103e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801039:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80103e:	89 d0                	mov    %edx,%eax
  801040:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	57                   	push   %edi
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801051:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801054:	bb 00 00 00 00       	mov    $0x0,%ebx
  801059:	eb 21                	jmp    80107c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80105b:	83 ec 04             	sub    $0x4,%esp
  80105e:	89 f0                	mov    %esi,%eax
  801060:	29 d8                	sub    %ebx,%eax
  801062:	50                   	push   %eax
  801063:	89 d8                	mov    %ebx,%eax
  801065:	03 45 0c             	add    0xc(%ebp),%eax
  801068:	50                   	push   %eax
  801069:	57                   	push   %edi
  80106a:	e8 45 ff ff ff       	call   800fb4 <read>
		if (m < 0)
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	78 10                	js     801086 <readn+0x41>
			return m;
		if (m == 0)
  801076:	85 c0                	test   %eax,%eax
  801078:	74 0a                	je     801084 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80107a:	01 c3                	add    %eax,%ebx
  80107c:	39 f3                	cmp    %esi,%ebx
  80107e:	72 db                	jb     80105b <readn+0x16>
  801080:	89 d8                	mov    %ebx,%eax
  801082:	eb 02                	jmp    801086 <readn+0x41>
  801084:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801086:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801089:	5b                   	pop    %ebx
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	53                   	push   %ebx
  801092:	83 ec 14             	sub    $0x14,%esp
  801095:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801098:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80109b:	50                   	push   %eax
  80109c:	53                   	push   %ebx
  80109d:	e8 ac fc ff ff       	call   800d4e <fd_lookup>
  8010a2:	83 c4 08             	add    $0x8,%esp
  8010a5:	89 c2                	mov    %eax,%edx
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 68                	js     801113 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b1:	50                   	push   %eax
  8010b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b5:	ff 30                	pushl  (%eax)
  8010b7:	e8 e8 fc ff ff       	call   800da4 <dev_lookup>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 47                	js     80110a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010ca:	75 21                	jne    8010ed <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d1:	8b 40 48             	mov    0x48(%eax),%eax
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	53                   	push   %ebx
  8010d8:	50                   	push   %eax
  8010d9:	68 69 21 80 00       	push   $0x802169
  8010de:	e8 5e f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010eb:	eb 26                	jmp    801113 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8010f3:	85 d2                	test   %edx,%edx
  8010f5:	74 17                	je     80110e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	ff 75 10             	pushl  0x10(%ebp)
  8010fd:	ff 75 0c             	pushl  0xc(%ebp)
  801100:	50                   	push   %eax
  801101:	ff d2                	call   *%edx
  801103:	89 c2                	mov    %eax,%edx
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	eb 09                	jmp    801113 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110a:	89 c2                	mov    %eax,%edx
  80110c:	eb 05                	jmp    801113 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80110e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801113:	89 d0                	mov    %edx,%eax
  801115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <seek>:

int
seek(int fdnum, off_t offset)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801120:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	ff 75 08             	pushl  0x8(%ebp)
  801127:	e8 22 fc ff ff       	call   800d4e <fd_lookup>
  80112c:	83 c4 08             	add    $0x8,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 0e                	js     801141 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801133:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801136:	8b 55 0c             	mov    0xc(%ebp),%edx
  801139:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80113c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	53                   	push   %ebx
  801147:	83 ec 14             	sub    $0x14,%esp
  80114a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	53                   	push   %ebx
  801152:	e8 f7 fb ff ff       	call   800d4e <fd_lookup>
  801157:	83 c4 08             	add    $0x8,%esp
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 65                	js     8011c5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801160:	83 ec 08             	sub    $0x8,%esp
  801163:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801166:	50                   	push   %eax
  801167:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116a:	ff 30                	pushl  (%eax)
  80116c:	e8 33 fc ff ff       	call   800da4 <dev_lookup>
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	78 44                	js     8011bc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801178:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80117f:	75 21                	jne    8011a2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801181:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801186:	8b 40 48             	mov    0x48(%eax),%eax
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	53                   	push   %ebx
  80118d:	50                   	push   %eax
  80118e:	68 2c 21 80 00       	push   $0x80212c
  801193:	e8 a9 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a0:	eb 23                	jmp    8011c5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a5:	8b 52 18             	mov    0x18(%edx),%edx
  8011a8:	85 d2                	test   %edx,%edx
  8011aa:	74 14                	je     8011c0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	ff 75 0c             	pushl  0xc(%ebp)
  8011b2:	50                   	push   %eax
  8011b3:	ff d2                	call   *%edx
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb 09                	jmp    8011c5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	eb 05                	jmp    8011c5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011c5:	89 d0                	mov    %edx,%eax
  8011c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 14             	sub    $0x14,%esp
  8011d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff 75 08             	pushl  0x8(%ebp)
  8011dd:	e8 6c fb ff ff       	call   800d4e <fd_lookup>
  8011e2:	83 c4 08             	add    $0x8,%esp
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 58                	js     801243 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f5:	ff 30                	pushl  (%eax)
  8011f7:	e8 a8 fb ff ff       	call   800da4 <dev_lookup>
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 37                	js     80123a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801203:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801206:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80120a:	74 32                	je     80123e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80120c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80120f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801216:	00 00 00 
	stat->st_isdir = 0;
  801219:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801220:	00 00 00 
	stat->st_dev = dev;
  801223:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	53                   	push   %ebx
  80122d:	ff 75 f0             	pushl  -0x10(%ebp)
  801230:	ff 50 14             	call   *0x14(%eax)
  801233:	89 c2                	mov    %eax,%edx
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	eb 09                	jmp    801243 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	eb 05                	jmp    801243 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80123e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801243:	89 d0                	mov    %edx,%eax
  801245:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801248:	c9                   	leave  
  801249:	c3                   	ret    

0080124a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80124f:	83 ec 08             	sub    $0x8,%esp
  801252:	6a 00                	push   $0x0
  801254:	ff 75 08             	pushl  0x8(%ebp)
  801257:	e8 e3 01 00 00       	call   80143f <open>
  80125c:	89 c3                	mov    %eax,%ebx
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	78 1b                	js     801280 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	ff 75 0c             	pushl  0xc(%ebp)
  80126b:	50                   	push   %eax
  80126c:	e8 5b ff ff ff       	call   8011cc <fstat>
  801271:	89 c6                	mov    %eax,%esi
	close(fd);
  801273:	89 1c 24             	mov    %ebx,(%esp)
  801276:	e8 fd fb ff ff       	call   800e78 <close>
	return r;
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	89 f0                	mov    %esi,%eax
}
  801280:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	89 c6                	mov    %eax,%esi
  80128e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801290:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801297:	75 12                	jne    8012ab <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	6a 01                	push   $0x1
  80129e:	e8 0e 08 00 00       	call   801ab1 <ipc_find_env>
  8012a3:	a3 00 40 80 00       	mov    %eax,0x804000
  8012a8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012ab:	6a 07                	push   $0x7
  8012ad:	68 00 50 80 00       	push   $0x805000
  8012b2:	56                   	push   %esi
  8012b3:	ff 35 00 40 80 00    	pushl  0x804000
  8012b9:	e8 9f 07 00 00       	call   801a5d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012be:	83 c4 0c             	add    $0xc,%esp
  8012c1:	6a 00                	push   $0x0
  8012c3:	53                   	push   %ebx
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 3d 07 00 00       	call   801a08 <ipc_recv>
}
  8012cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012db:	8b 40 0c             	mov    0xc(%eax),%eax
  8012de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8012f5:	e8 8d ff ff ff       	call   801287 <fsipc>
}
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	8b 40 0c             	mov    0xc(%eax),%eax
  801308:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80130d:	ba 00 00 00 00       	mov    $0x0,%edx
  801312:	b8 06 00 00 00       	mov    $0x6,%eax
  801317:	e8 6b ff ff ff       	call   801287 <fsipc>
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	53                   	push   %ebx
  801322:	83 ec 04             	sub    $0x4,%esp
  801325:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
  80132b:	8b 40 0c             	mov    0xc(%eax),%eax
  80132e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801333:	ba 00 00 00 00       	mov    $0x0,%edx
  801338:	b8 05 00 00 00       	mov    $0x5,%eax
  80133d:	e8 45 ff ff ff       	call   801287 <fsipc>
  801342:	85 c0                	test   %eax,%eax
  801344:	78 2c                	js     801372 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	68 00 50 80 00       	push   $0x805000
  80134e:	53                   	push   %ebx
  80134f:	e8 90 f3 ff ff       	call   8006e4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801354:	a1 80 50 80 00       	mov    0x805080,%eax
  801359:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80135f:	a1 84 50 80 00       	mov    0x805084,%eax
  801364:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 0c             	sub    $0xc,%esp
  80137d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801380:	8b 55 08             	mov    0x8(%ebp),%edx
  801383:	8b 52 0c             	mov    0xc(%edx),%edx
  801386:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80138c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801391:	ba 00 10 00 00       	mov    $0x1000,%edx
  801396:	0f 47 c2             	cmova  %edx,%eax
  801399:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80139e:	50                   	push   %eax
  80139f:	ff 75 0c             	pushl  0xc(%ebp)
  8013a2:	68 08 50 80 00       	push   $0x805008
  8013a7:	e8 ca f4 ff ff       	call   800876 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8013ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8013b6:	e8 cc fe ff ff       	call   801287 <fsipc>
    return r;
}
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
  8013c2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013d0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	b8 03 00 00 00       	mov    $0x3,%eax
  8013e0:	e8 a2 fe ff ff       	call   801287 <fsipc>
  8013e5:	89 c3                	mov    %eax,%ebx
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 4b                	js     801436 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013eb:	39 c6                	cmp    %eax,%esi
  8013ed:	73 16                	jae    801405 <devfile_read+0x48>
  8013ef:	68 98 21 80 00       	push   $0x802198
  8013f4:	68 9f 21 80 00       	push   $0x80219f
  8013f9:	6a 7c                	push   $0x7c
  8013fb:	68 b4 21 80 00       	push   $0x8021b4
  801400:	e8 bd 05 00 00       	call   8019c2 <_panic>
	assert(r <= PGSIZE);
  801405:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80140a:	7e 16                	jle    801422 <devfile_read+0x65>
  80140c:	68 bf 21 80 00       	push   $0x8021bf
  801411:	68 9f 21 80 00       	push   $0x80219f
  801416:	6a 7d                	push   $0x7d
  801418:	68 b4 21 80 00       	push   $0x8021b4
  80141d:	e8 a0 05 00 00       	call   8019c2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801422:	83 ec 04             	sub    $0x4,%esp
  801425:	50                   	push   %eax
  801426:	68 00 50 80 00       	push   $0x805000
  80142b:	ff 75 0c             	pushl  0xc(%ebp)
  80142e:	e8 43 f4 ff ff       	call   800876 <memmove>
	return r;
  801433:	83 c4 10             	add    $0x10,%esp
}
  801436:	89 d8                	mov    %ebx,%eax
  801438:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	53                   	push   %ebx
  801443:	83 ec 20             	sub    $0x20,%esp
  801446:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801449:	53                   	push   %ebx
  80144a:	e8 5c f2 ff ff       	call   8006ab <strlen>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801457:	7f 67                	jg     8014c0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	e8 9a f8 ff ff       	call   800cff <fd_alloc>
  801465:	83 c4 10             	add    $0x10,%esp
		return r;
  801468:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 57                	js     8014c5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	53                   	push   %ebx
  801472:	68 00 50 80 00       	push   $0x805000
  801477:	e8 68 f2 ff ff       	call   8006e4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80147c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801484:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801487:	b8 01 00 00 00       	mov    $0x1,%eax
  80148c:	e8 f6 fd ff ff       	call   801287 <fsipc>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	79 14                	jns    8014ae <open+0x6f>
		fd_close(fd, 0);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	6a 00                	push   $0x0
  80149f:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a2:	e8 50 f9 ff ff       	call   800df7 <fd_close>
		return r;
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	89 da                	mov    %ebx,%edx
  8014ac:	eb 17                	jmp    8014c5 <open+0x86>
	}

	return fd2num(fd);
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b4:	e8 1f f8 ff ff       	call   800cd8 <fd2num>
  8014b9:	89 c2                	mov    %eax,%edx
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	eb 05                	jmp    8014c5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014c0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014c5:	89 d0                	mov    %edx,%eax
  8014c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8014dc:	e8 a6 fd ff ff       	call   801287 <fsipc>
}
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014eb:	83 ec 0c             	sub    $0xc,%esp
  8014ee:	ff 75 08             	pushl  0x8(%ebp)
  8014f1:	e8 f2 f7 ff ff       	call   800ce8 <fd2data>
  8014f6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014f8:	83 c4 08             	add    $0x8,%esp
  8014fb:	68 cb 21 80 00       	push   $0x8021cb
  801500:	53                   	push   %ebx
  801501:	e8 de f1 ff ff       	call   8006e4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801506:	8b 46 04             	mov    0x4(%esi),%eax
  801509:	2b 06                	sub    (%esi),%eax
  80150b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801511:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801518:	00 00 00 
	stat->st_dev = &devpipe;
  80151b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801522:	30 80 00 
	return 0;
}
  801525:	b8 00 00 00 00       	mov    $0x0,%eax
  80152a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80153b:	53                   	push   %ebx
  80153c:	6a 00                	push   $0x0
  80153e:	e8 29 f6 ff ff       	call   800b6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801543:	89 1c 24             	mov    %ebx,(%esp)
  801546:	e8 9d f7 ff ff       	call   800ce8 <fd2data>
  80154b:	83 c4 08             	add    $0x8,%esp
  80154e:	50                   	push   %eax
  80154f:	6a 00                	push   $0x0
  801551:	e8 16 f6 ff ff       	call   800b6c <sys_page_unmap>
}
  801556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 1c             	sub    $0x1c,%esp
  801564:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801567:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801569:	a1 04 40 80 00       	mov    0x804004,%eax
  80156e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801571:	83 ec 0c             	sub    $0xc,%esp
  801574:	ff 75 e0             	pushl  -0x20(%ebp)
  801577:	e8 6e 05 00 00       	call   801aea <pageref>
  80157c:	89 c3                	mov    %eax,%ebx
  80157e:	89 3c 24             	mov    %edi,(%esp)
  801581:	e8 64 05 00 00       	call   801aea <pageref>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	39 c3                	cmp    %eax,%ebx
  80158b:	0f 94 c1             	sete   %cl
  80158e:	0f b6 c9             	movzbl %cl,%ecx
  801591:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801594:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80159a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80159d:	39 ce                	cmp    %ecx,%esi
  80159f:	74 1b                	je     8015bc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015a1:	39 c3                	cmp    %eax,%ebx
  8015a3:	75 c4                	jne    801569 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015a5:	8b 42 58             	mov    0x58(%edx),%eax
  8015a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	56                   	push   %esi
  8015ad:	68 d2 21 80 00       	push   $0x8021d2
  8015b2:	e8 8a eb ff ff       	call   800141 <cprintf>
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	eb ad                	jmp    801569 <_pipeisclosed+0xe>
	}
}
  8015bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c2:	5b                   	pop    %ebx
  8015c3:	5e                   	pop    %esi
  8015c4:	5f                   	pop    %edi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	57                   	push   %edi
  8015cb:	56                   	push   %esi
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 28             	sub    $0x28,%esp
  8015d0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015d3:	56                   	push   %esi
  8015d4:	e8 0f f7 ff ff       	call   800ce8 <fd2data>
  8015d9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	bf 00 00 00 00       	mov    $0x0,%edi
  8015e3:	eb 4b                	jmp    801630 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015e5:	89 da                	mov    %ebx,%edx
  8015e7:	89 f0                	mov    %esi,%eax
  8015e9:	e8 6d ff ff ff       	call   80155b <_pipeisclosed>
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	75 48                	jne    80163a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015f2:	e8 d1 f4 ff ff       	call   800ac8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8015fa:	8b 0b                	mov    (%ebx),%ecx
  8015fc:	8d 51 20             	lea    0x20(%ecx),%edx
  8015ff:	39 d0                	cmp    %edx,%eax
  801601:	73 e2                	jae    8015e5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801603:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801606:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80160a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	c1 fa 1f             	sar    $0x1f,%edx
  801612:	89 d1                	mov    %edx,%ecx
  801614:	c1 e9 1b             	shr    $0x1b,%ecx
  801617:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80161a:	83 e2 1f             	and    $0x1f,%edx
  80161d:	29 ca                	sub    %ecx,%edx
  80161f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801623:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801627:	83 c0 01             	add    $0x1,%eax
  80162a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162d:	83 c7 01             	add    $0x1,%edi
  801630:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801633:	75 c2                	jne    8015f7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801635:	8b 45 10             	mov    0x10(%ebp),%eax
  801638:	eb 05                	jmp    80163f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80163a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80163f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5f                   	pop    %edi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	57                   	push   %edi
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	83 ec 18             	sub    $0x18,%esp
  801650:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801653:	57                   	push   %edi
  801654:	e8 8f f6 ff ff       	call   800ce8 <fd2data>
  801659:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801663:	eb 3d                	jmp    8016a2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801665:	85 db                	test   %ebx,%ebx
  801667:	74 04                	je     80166d <devpipe_read+0x26>
				return i;
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	eb 44                	jmp    8016b1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80166d:	89 f2                	mov    %esi,%edx
  80166f:	89 f8                	mov    %edi,%eax
  801671:	e8 e5 fe ff ff       	call   80155b <_pipeisclosed>
  801676:	85 c0                	test   %eax,%eax
  801678:	75 32                	jne    8016ac <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80167a:	e8 49 f4 ff ff       	call   800ac8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80167f:	8b 06                	mov    (%esi),%eax
  801681:	3b 46 04             	cmp    0x4(%esi),%eax
  801684:	74 df                	je     801665 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801686:	99                   	cltd   
  801687:	c1 ea 1b             	shr    $0x1b,%edx
  80168a:	01 d0                	add    %edx,%eax
  80168c:	83 e0 1f             	and    $0x1f,%eax
  80168f:	29 d0                	sub    %edx,%eax
  801691:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801699:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80169c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169f:	83 c3 01             	add    $0x1,%ebx
  8016a2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016a5:	75 d8                	jne    80167f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8016aa:	eb 05                	jmp    8016b1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5f                   	pop    %edi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	e8 35 f6 ff ff       	call   800cff <fd_alloc>
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	0f 88 2c 01 00 00    	js     801803 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016d7:	83 ec 04             	sub    $0x4,%esp
  8016da:	68 07 04 00 00       	push   $0x407
  8016df:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e2:	6a 00                	push   $0x0
  8016e4:	e8 fe f3 ff ff       	call   800ae7 <sys_page_alloc>
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	0f 88 0d 01 00 00    	js     801803 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016f6:	83 ec 0c             	sub    $0xc,%esp
  8016f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	e8 fd f5 ff ff       	call   800cff <fd_alloc>
  801702:	89 c3                	mov    %eax,%ebx
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	0f 88 e2 00 00 00    	js     8017f1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170f:	83 ec 04             	sub    $0x4,%esp
  801712:	68 07 04 00 00       	push   $0x407
  801717:	ff 75 f0             	pushl  -0x10(%ebp)
  80171a:	6a 00                	push   $0x0
  80171c:	e8 c6 f3 ff ff       	call   800ae7 <sys_page_alloc>
  801721:	89 c3                	mov    %eax,%ebx
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	0f 88 c3 00 00 00    	js     8017f1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80172e:	83 ec 0c             	sub    $0xc,%esp
  801731:	ff 75 f4             	pushl  -0xc(%ebp)
  801734:	e8 af f5 ff ff       	call   800ce8 <fd2data>
  801739:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173b:	83 c4 0c             	add    $0xc,%esp
  80173e:	68 07 04 00 00       	push   $0x407
  801743:	50                   	push   %eax
  801744:	6a 00                	push   $0x0
  801746:	e8 9c f3 ff ff       	call   800ae7 <sys_page_alloc>
  80174b:	89 c3                	mov    %eax,%ebx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	85 c0                	test   %eax,%eax
  801752:	0f 88 89 00 00 00    	js     8017e1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	ff 75 f0             	pushl  -0x10(%ebp)
  80175e:	e8 85 f5 ff ff       	call   800ce8 <fd2data>
  801763:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80176a:	50                   	push   %eax
  80176b:	6a 00                	push   $0x0
  80176d:	56                   	push   %esi
  80176e:	6a 00                	push   $0x0
  801770:	e8 b5 f3 ff ff       	call   800b2a <sys_page_map>
  801775:	89 c3                	mov    %eax,%ebx
  801777:	83 c4 20             	add    $0x20,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 55                	js     8017d3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80177e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801784:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801787:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801793:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017a8:	83 ec 0c             	sub    $0xc,%esp
  8017ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ae:	e8 25 f5 ff ff       	call   800cd8 <fd2num>
  8017b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017b8:	83 c4 04             	add    $0x4,%esp
  8017bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017be:	e8 15 f5 ff ff       	call   800cd8 <fd2num>
  8017c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d1:	eb 30                	jmp    801803 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	56                   	push   %esi
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 8e f3 ff ff       	call   800b6c <sys_page_unmap>
  8017de:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 7e f3 ff ff       	call   800b6c <sys_page_unmap>
  8017ee:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f7:	6a 00                	push   $0x0
  8017f9:	e8 6e f3 ff ff       	call   800b6c <sys_page_unmap>
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801803:	89 d0                	mov    %edx,%eax
  801805:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	ff 75 08             	pushl  0x8(%ebp)
  801819:	e8 30 f5 ff ff       	call   800d4e <fd_lookup>
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	78 18                	js     80183d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	ff 75 f4             	pushl  -0xc(%ebp)
  80182b:	e8 b8 f4 ff ff       	call   800ce8 <fd2data>
	return _pipeisclosed(fd, p);
  801830:	89 c2                	mov    %eax,%edx
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	e8 21 fd ff ff       	call   80155b <_pipeisclosed>
  80183a:	83 c4 10             	add    $0x10,%esp
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801842:	b8 00 00 00 00       	mov    $0x0,%eax
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80184f:	68 ea 21 80 00       	push   $0x8021ea
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	e8 88 ee ff ff       	call   8006e4 <strcpy>
	return 0;
}
  80185c:	b8 00 00 00 00       	mov    $0x0,%eax
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	57                   	push   %edi
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80186f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801874:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80187a:	eb 2d                	jmp    8018a9 <devcons_write+0x46>
		m = n - tot;
  80187c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80187f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801881:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801884:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801889:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	53                   	push   %ebx
  801890:	03 45 0c             	add    0xc(%ebp),%eax
  801893:	50                   	push   %eax
  801894:	57                   	push   %edi
  801895:	e8 dc ef ff ff       	call   800876 <memmove>
		sys_cputs(buf, m);
  80189a:	83 c4 08             	add    $0x8,%esp
  80189d:	53                   	push   %ebx
  80189e:	57                   	push   %edi
  80189f:	e8 87 f1 ff ff       	call   800a2b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a4:	01 de                	add    %ebx,%esi
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	89 f0                	mov    %esi,%eax
  8018ab:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018ae:	72 cc                	jb     80187c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b3:	5b                   	pop    %ebx
  8018b4:	5e                   	pop    %esi
  8018b5:	5f                   	pop    %edi
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018c7:	74 2a                	je     8018f3 <devcons_read+0x3b>
  8018c9:	eb 05                	jmp    8018d0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018cb:	e8 f8 f1 ff ff       	call   800ac8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018d0:	e8 74 f1 ff ff       	call   800a49 <sys_cgetc>
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	74 f2                	je     8018cb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 16                	js     8018f3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018dd:	83 f8 04             	cmp    $0x4,%eax
  8018e0:	74 0c                	je     8018ee <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e5:	88 02                	mov    %al,(%edx)
	return 1;
  8018e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ec:	eb 05                	jmp    8018f3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801901:	6a 01                	push   $0x1
  801903:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801906:	50                   	push   %eax
  801907:	e8 1f f1 ff ff       	call   800a2b <sys_cputs>
}
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <getchar>:

int
getchar(void)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801917:	6a 01                	push   $0x1
  801919:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80191c:	50                   	push   %eax
  80191d:	6a 00                	push   $0x0
  80191f:	e8 90 f6 ff ff       	call   800fb4 <read>
	if (r < 0)
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	85 c0                	test   %eax,%eax
  801929:	78 0f                	js     80193a <getchar+0x29>
		return r;
	if (r < 1)
  80192b:	85 c0                	test   %eax,%eax
  80192d:	7e 06                	jle    801935 <getchar+0x24>
		return -E_EOF;
	return c;
  80192f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801933:	eb 05                	jmp    80193a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801935:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	ff 75 08             	pushl  0x8(%ebp)
  801949:	e8 00 f4 ff ff       	call   800d4e <fd_lookup>
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	78 11                	js     801966 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801958:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80195e:	39 10                	cmp    %edx,(%eax)
  801960:	0f 94 c0             	sete   %al
  801963:	0f b6 c0             	movzbl %al,%eax
}
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <opencons>:

int
opencons(void)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80196e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801971:	50                   	push   %eax
  801972:	e8 88 f3 ff ff       	call   800cff <fd_alloc>
  801977:	83 c4 10             	add    $0x10,%esp
		return r;
  80197a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 3e                	js     8019be <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801980:	83 ec 04             	sub    $0x4,%esp
  801983:	68 07 04 00 00       	push   $0x407
  801988:	ff 75 f4             	pushl  -0xc(%ebp)
  80198b:	6a 00                	push   $0x0
  80198d:	e8 55 f1 ff ff       	call   800ae7 <sys_page_alloc>
  801992:	83 c4 10             	add    $0x10,%esp
		return r;
  801995:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801997:	85 c0                	test   %eax,%eax
  801999:	78 23                	js     8019be <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80199b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	50                   	push   %eax
  8019b4:	e8 1f f3 ff ff       	call   800cd8 <fd2num>
  8019b9:	89 c2                	mov    %eax,%edx
  8019bb:	83 c4 10             	add    $0x10,%esp
}
  8019be:	89 d0                	mov    %edx,%eax
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019ca:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019d0:	e8 d4 f0 ff ff       	call   800aa9 <sys_getenvid>
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	ff 75 0c             	pushl  0xc(%ebp)
  8019db:	ff 75 08             	pushl  0x8(%ebp)
  8019de:	56                   	push   %esi
  8019df:	50                   	push   %eax
  8019e0:	68 f8 21 80 00       	push   $0x8021f8
  8019e5:	e8 57 e7 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019ea:	83 c4 18             	add    $0x18,%esp
  8019ed:	53                   	push   %ebx
  8019ee:	ff 75 10             	pushl  0x10(%ebp)
  8019f1:	e8 fa e6 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  8019f6:	c7 04 24 dc 1d 80 00 	movl   $0x801ddc,(%esp)
  8019fd:	e8 3f e7 ff ff       	call   800141 <cprintf>
  801a02:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a05:	cc                   	int3   
  801a06:	eb fd                	jmp    801a05 <_panic+0x43>

00801a08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a16:	85 c0                	test   %eax,%eax
  801a18:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1d:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	50                   	push   %eax
  801a24:	e8 6e f2 ff ff       	call   800c97 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	75 10                	jne    801a40 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a30:	a1 04 40 80 00       	mov    0x804004,%eax
  801a35:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a38:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a3b:	8b 40 70             	mov    0x70(%eax),%eax
  801a3e:	eb 0a                	jmp    801a4a <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a40:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a45:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a4a:	85 f6                	test   %esi,%esi
  801a4c:	74 02                	je     801a50 <ipc_recv+0x48>
  801a4e:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a50:	85 db                	test   %ebx,%ebx
  801a52:	74 02                	je     801a56 <ipc_recv+0x4e>
  801a54:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a69:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a76:	0f 44 d8             	cmove  %eax,%ebx
  801a79:	eb 1c                	jmp    801a97 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a7b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7e:	74 12                	je     801a92 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a80:	50                   	push   %eax
  801a81:	68 1c 22 80 00       	push   $0x80221c
  801a86:	6a 40                	push   $0x40
  801a88:	68 2e 22 80 00       	push   $0x80222e
  801a8d:	e8 30 ff ff ff       	call   8019c2 <_panic>
        sys_yield();
  801a92:	e8 31 f0 ff ff       	call   800ac8 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a97:	ff 75 14             	pushl  0x14(%ebp)
  801a9a:	53                   	push   %ebx
  801a9b:	56                   	push   %esi
  801a9c:	57                   	push   %edi
  801a9d:	e8 d2 f1 ff ff       	call   800c74 <sys_ipc_try_send>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	75 d2                	jne    801a7b <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801abc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801abf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ac5:	8b 52 50             	mov    0x50(%edx),%edx
  801ac8:	39 ca                	cmp    %ecx,%edx
  801aca:	75 0d                	jne    801ad9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801acc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801acf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ad4:	8b 40 48             	mov    0x48(%eax),%eax
  801ad7:	eb 0f                	jmp    801ae8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad9:	83 c0 01             	add    $0x1,%eax
  801adc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ae1:	75 d9                	jne    801abc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801af0:	89 d0                	mov    %edx,%eax
  801af2:	c1 e8 16             	shr    $0x16,%eax
  801af5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b01:	f6 c1 01             	test   $0x1,%cl
  801b04:	74 1d                	je     801b23 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b06:	c1 ea 0c             	shr    $0xc,%edx
  801b09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b10:	f6 c2 01             	test   $0x1,%dl
  801b13:	74 0e                	je     801b23 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b15:	c1 ea 0c             	shr    $0xc,%edx
  801b18:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b1f:	ef 
  801b20:	0f b7 c0             	movzwl %ax,%eax
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    
  801b25:	66 90                	xchg   %ax,%ax
  801b27:	66 90                	xchg   %ax,%ax
  801b29:	66 90                	xchg   %ax,%ax
  801b2b:	66 90                	xchg   %ax,%ax
  801b2d:	66 90                	xchg   %ax,%ax
  801b2f:	90                   	nop

00801b30 <__udivdi3>:
  801b30:	55                   	push   %ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 1c             	sub    $0x1c,%esp
  801b37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b47:	85 f6                	test   %esi,%esi
  801b49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b4d:	89 ca                	mov    %ecx,%edx
  801b4f:	89 f8                	mov    %edi,%eax
  801b51:	75 3d                	jne    801b90 <__udivdi3+0x60>
  801b53:	39 cf                	cmp    %ecx,%edi
  801b55:	0f 87 c5 00 00 00    	ja     801c20 <__udivdi3+0xf0>
  801b5b:	85 ff                	test   %edi,%edi
  801b5d:	89 fd                	mov    %edi,%ebp
  801b5f:	75 0b                	jne    801b6c <__udivdi3+0x3c>
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	31 d2                	xor    %edx,%edx
  801b68:	f7 f7                	div    %edi
  801b6a:	89 c5                	mov    %eax,%ebp
  801b6c:	89 c8                	mov    %ecx,%eax
  801b6e:	31 d2                	xor    %edx,%edx
  801b70:	f7 f5                	div    %ebp
  801b72:	89 c1                	mov    %eax,%ecx
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	89 cf                	mov    %ecx,%edi
  801b78:	f7 f5                	div    %ebp
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	89 fa                	mov    %edi,%edx
  801b80:	83 c4 1c             	add    $0x1c,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    
  801b88:	90                   	nop
  801b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b90:	39 ce                	cmp    %ecx,%esi
  801b92:	77 74                	ja     801c08 <__udivdi3+0xd8>
  801b94:	0f bd fe             	bsr    %esi,%edi
  801b97:	83 f7 1f             	xor    $0x1f,%edi
  801b9a:	0f 84 98 00 00 00    	je     801c38 <__udivdi3+0x108>
  801ba0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	89 c5                	mov    %eax,%ebp
  801ba9:	29 fb                	sub    %edi,%ebx
  801bab:	d3 e6                	shl    %cl,%esi
  801bad:	89 d9                	mov    %ebx,%ecx
  801baf:	d3 ed                	shr    %cl,%ebp
  801bb1:	89 f9                	mov    %edi,%ecx
  801bb3:	d3 e0                	shl    %cl,%eax
  801bb5:	09 ee                	or     %ebp,%esi
  801bb7:	89 d9                	mov    %ebx,%ecx
  801bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbd:	89 d5                	mov    %edx,%ebp
  801bbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bc3:	d3 ed                	shr    %cl,%ebp
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e2                	shl    %cl,%edx
  801bc9:	89 d9                	mov    %ebx,%ecx
  801bcb:	d3 e8                	shr    %cl,%eax
  801bcd:	09 c2                	or     %eax,%edx
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	89 ea                	mov    %ebp,%edx
  801bd3:	f7 f6                	div    %esi
  801bd5:	89 d5                	mov    %edx,%ebp
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	f7 64 24 0c          	mull   0xc(%esp)
  801bdd:	39 d5                	cmp    %edx,%ebp
  801bdf:	72 10                	jb     801bf1 <__udivdi3+0xc1>
  801be1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e6                	shl    %cl,%esi
  801be9:	39 c6                	cmp    %eax,%esi
  801beb:	73 07                	jae    801bf4 <__udivdi3+0xc4>
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	75 03                	jne    801bf4 <__udivdi3+0xc4>
  801bf1:	83 eb 01             	sub    $0x1,%ebx
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 d8                	mov    %ebx,%eax
  801bf8:	89 fa                	mov    %edi,%edx
  801bfa:	83 c4 1c             	add    $0x1c,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    
  801c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c08:	31 ff                	xor    %edi,%edi
  801c0a:	31 db                	xor    %ebx,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	f7 f7                	div    %edi
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	89 fa                	mov    %edi,%edx
  801c2c:	83 c4 1c             	add    $0x1c,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	72 0c                	jb     801c48 <__udivdi3+0x118>
  801c3c:	31 db                	xor    %ebx,%ebx
  801c3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c42:	0f 87 34 ff ff ff    	ja     801b7c <__udivdi3+0x4c>
  801c48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c4d:	e9 2a ff ff ff       	jmp    801b7c <__udivdi3+0x4c>
  801c52:	66 90                	xchg   %ax,%ax
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__umoddi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 d2                	test   %edx,%edx
  801c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f3                	mov    %esi,%ebx
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8a:	75 1c                	jne    801ca8 <__umoddi3+0x48>
  801c8c:	39 f7                	cmp    %esi,%edi
  801c8e:	76 50                	jbe    801ce0 <__umoddi3+0x80>
  801c90:	89 c8                	mov    %ecx,%eax
  801c92:	89 f2                	mov    %esi,%edx
  801c94:	f7 f7                	div    %edi
  801c96:	89 d0                	mov    %edx,%eax
  801c98:	31 d2                	xor    %edx,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	89 d0                	mov    %edx,%eax
  801cac:	77 52                	ja     801d00 <__umoddi3+0xa0>
  801cae:	0f bd ea             	bsr    %edx,%ebp
  801cb1:	83 f5 1f             	xor    $0x1f,%ebp
  801cb4:	75 5a                	jne    801d10 <__umoddi3+0xb0>
  801cb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cba:	0f 82 e0 00 00 00    	jb     801da0 <__umoddi3+0x140>
  801cc0:	39 0c 24             	cmp    %ecx,(%esp)
  801cc3:	0f 86 d7 00 00 00    	jbe    801da0 <__umoddi3+0x140>
  801cc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ccd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cd1:	83 c4 1c             	add    $0x1c,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	85 ff                	test   %edi,%edi
  801ce2:	89 fd                	mov    %edi,%ebp
  801ce4:	75 0b                	jne    801cf1 <__umoddi3+0x91>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f7                	div    %edi
  801cef:	89 c5                	mov    %eax,%ebp
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	31 d2                	xor    %edx,%edx
  801cf5:	f7 f5                	div    %ebp
  801cf7:	89 c8                	mov    %ecx,%eax
  801cf9:	f7 f5                	div    %ebp
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	eb 99                	jmp    801c98 <__umoddi3+0x38>
  801cff:	90                   	nop
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	83 c4 1c             	add    $0x1c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	8b 34 24             	mov    (%esp),%esi
  801d13:	bf 20 00 00 00       	mov    $0x20,%edi
  801d18:	89 e9                	mov    %ebp,%ecx
  801d1a:	29 ef                	sub    %ebp,%edi
  801d1c:	d3 e0                	shl    %cl,%eax
  801d1e:	89 f9                	mov    %edi,%ecx
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	d3 ea                	shr    %cl,%edx
  801d24:	89 e9                	mov    %ebp,%ecx
  801d26:	09 c2                	or     %eax,%edx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 14 24             	mov    %edx,(%esp)
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	d3 e2                	shl    %cl,%edx
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	89 e9                	mov    %ebp,%ecx
  801d3f:	89 c6                	mov    %eax,%esi
  801d41:	d3 e3                	shl    %cl,%ebx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	09 d8                	or     %ebx,%eax
  801d4d:	89 d3                	mov    %edx,%ebx
  801d4f:	89 f2                	mov    %esi,%edx
  801d51:	f7 34 24             	divl   (%esp)
  801d54:	89 d6                	mov    %edx,%esi
  801d56:	d3 e3                	shl    %cl,%ebx
  801d58:	f7 64 24 04          	mull   0x4(%esp)
  801d5c:	39 d6                	cmp    %edx,%esi
  801d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d62:	89 d1                	mov    %edx,%ecx
  801d64:	89 c3                	mov    %eax,%ebx
  801d66:	72 08                	jb     801d70 <__umoddi3+0x110>
  801d68:	75 11                	jne    801d7b <__umoddi3+0x11b>
  801d6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d6e:	73 0b                	jae    801d7b <__umoddi3+0x11b>
  801d70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d74:	1b 14 24             	sbb    (%esp),%edx
  801d77:	89 d1                	mov    %edx,%ecx
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d7f:	29 da                	sub    %ebx,%edx
  801d81:	19 ce                	sbb    %ecx,%esi
  801d83:	89 f9                	mov    %edi,%ecx
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	d3 e0                	shl    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	d3 ea                	shr    %cl,%edx
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	d3 ee                	shr    %cl,%esi
  801d91:	09 d0                	or     %edx,%eax
  801d93:	89 f2                	mov    %esi,%edx
  801d95:	83 c4 1c             	add    $0x1c,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
  801da0:	29 f9                	sub    %edi,%ecx
  801da2:	19 d6                	sbb    %edx,%esi
  801da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dac:	e9 18 ff ff ff       	jmp    801cc9 <__umoddi3+0x69>
