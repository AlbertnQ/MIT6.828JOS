
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 e0 1d 80 00       	push   $0x801de0
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 4b 0a 00 00       	call   800abb <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 04 0e 00 00       	call   800eb5 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 bf 09 00 00       	call   800a7a <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 4d 09 00 00       	call   800a3d <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 54 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 f2 08 00 00       	call   800a3d <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 45                	ja     8001dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 85 19 00 00       	call   801b40 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 18                	jmp    8001e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb 03                	jmp    8001df <printnum+0x78>
  8001dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	85 db                	test   %ebx,%ebx
  8001e4:	7f e8                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 72 1a 00 00       	call   801c70 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 f8 1d 80 00 	movsbl 0x801df8(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff d7                	call   *%edi
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800219:	83 fa 01             	cmp    $0x1,%edx
  80021c:	7e 0e                	jle    80022c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 08             	lea    0x8(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	8b 52 04             	mov    0x4(%edx),%edx
  80022a:	eb 22                	jmp    80024e <getuint+0x38>
	else if (lflag)
  80022c:	85 d2                	test   %edx,%edx
  80022e:	74 10                	je     800240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	eb 0e                	jmp    80024e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 a7 03 00 00    	je     80064d <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e1:	eb 07                	jmp    8002ea <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8d 47 01             	lea    0x1(%edi),%eax
  8002ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f0:	0f b6 07             	movzbl (%edi),%eax
  8002f3:	0f b6 d0             	movzbl %al,%edx
  8002f6:	83 e8 23             	sub    $0x23,%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 31 03 00 00    	ja     800632 <vprintfmt+0x3a8>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800312:	eb d6                	jmp    8002ea <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	b8 00 00 00 00       	mov    $0x0,%eax
  80031c:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800322:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800326:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800329:	8d 72 d0             	lea    -0x30(%edx),%esi
  80032c:	83 fe 09             	cmp    $0x9,%esi
  80032f:	77 34                	ja     800365 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800331:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800334:	eb e9                	jmp    80031f <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8d 50 04             	lea    0x4(%eax),%edx
  80033c:	89 55 14             	mov    %edx,0x14(%ebp)
  80033f:	8b 00                	mov    (%eax),%eax
  800341:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800347:	eb 22                	jmp    80036b <vprintfmt+0xe1>
  800349:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034c:	85 c0                	test   %eax,%eax
  80034e:	0f 48 c1             	cmovs  %ecx,%eax
  800351:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800357:	eb 91                	jmp    8002ea <vprintfmt+0x60>
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800363:	eb 85                	jmp    8002ea <vprintfmt+0x60>
  800365:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800368:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  80036b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036f:	0f 89 75 ff ff ff    	jns    8002ea <vprintfmt+0x60>
				width = precision, precision = -1;
  800375:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800382:	e9 63 ff ff ff       	jmp    8002ea <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800387:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038e:	e9 57 ff ff ff       	jmp    8002ea <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 50 04             	lea    0x4(%eax),%edx
  800399:	89 55 14             	mov    %edx,0x14(%ebp)
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	ff 30                	pushl  (%eax)
  8003a2:	ff d6                	call   *%esi
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003aa:	e9 01 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 50 04             	lea    0x4(%eax),%edx
  8003b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	99                   	cltd   
  8003bb:	31 d0                	xor    %edx,%eax
  8003bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bf:	83 f8 0f             	cmp    $0xf,%eax
  8003c2:	7f 0b                	jg     8003cf <vprintfmt+0x145>
  8003c4:	8b 14 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	75 18                	jne    8003e7 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8003cf:	50                   	push   %eax
  8003d0:	68 10 1e 80 00       	push   $0x801e10
  8003d5:	53                   	push   %ebx
  8003d6:	56                   	push   %esi
  8003d7:	e8 91 fe ff ff       	call   80026d <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e2:	e9 c9 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e7:	52                   	push   %edx
  8003e8:	68 d1 21 80 00       	push   $0x8021d1
  8003ed:	53                   	push   %ebx
  8003ee:	56                   	push   %esi
  8003ef:	e8 79 fe ff ff       	call   80026d <printfmt>
  8003f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fa:	e9 b1 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040a:	85 ff                	test   %edi,%edi
  80040c:	b8 09 1e 80 00       	mov    $0x801e09,%eax
  800411:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	0f 8e 94 00 00 00    	jle    8004b2 <vprintfmt+0x228>
  80041e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800422:	0f 84 98 00 00 00    	je     8004c0 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	ff 75 cc             	pushl  -0x34(%ebp)
  80042e:	57                   	push   %edi
  80042f:	e8 a1 02 00 00       	call   8006d5 <strnlen>
  800434:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800437:	29 c1                	sub    %eax,%ecx
  800439:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80043c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800446:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800449:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	eb 0f                	jmp    80045c <vprintfmt+0x1d2>
					putch(padc, putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	ff 75 e0             	pushl  -0x20(%ebp)
  800454:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ef 01             	sub    $0x1,%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 ff                	test   %edi,%edi
  80045e:	7f ed                	jg     80044d <vprintfmt+0x1c3>
  800460:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800463:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800466:	85 c9                	test   %ecx,%ecx
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	0f 49 c1             	cmovns %ecx,%eax
  800470:	29 c1                	sub    %eax,%ecx
  800472:	89 75 08             	mov    %esi,0x8(%ebp)
  800475:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047b:	89 cb                	mov    %ecx,%ebx
  80047d:	eb 4d                	jmp    8004cc <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800483:	74 1b                	je     8004a0 <vprintfmt+0x216>
  800485:	0f be c0             	movsbl %al,%eax
  800488:	83 e8 20             	sub    $0x20,%eax
  80048b:	83 f8 5e             	cmp    $0x5e,%eax
  80048e:	76 10                	jbe    8004a0 <vprintfmt+0x216>
					putch('?', putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	6a 3f                	push   $0x3f
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	eb 0d                	jmp    8004ad <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	52                   	push   %edx
  8004a7:	ff 55 08             	call   *0x8(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	eb 1a                	jmp    8004cc <vprintfmt+0x242>
  8004b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004be:	eb 0c                	jmp    8004cc <vprintfmt+0x242>
  8004c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cc:	83 c7 01             	add    $0x1,%edi
  8004cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d3:	0f be d0             	movsbl %al,%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 23                	je     8004fd <vprintfmt+0x273>
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	78 a1                	js     80047f <vprintfmt+0x1f5>
  8004de:	83 ee 01             	sub    $0x1,%esi
  8004e1:	79 9c                	jns    80047f <vprintfmt+0x1f5>
  8004e3:	89 df                	mov    %ebx,%edi
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	eb 18                	jmp    800505 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	6a 20                	push   $0x20
  8004f3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 08                	jmp    800505 <vprintfmt+0x27b>
  8004fd:	89 df                	mov    %ebx,%edi
  8004ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800505:	85 ff                	test   %edi,%edi
  800507:	7f e4                	jg     8004ed <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	e9 9f fd ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800511:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800515:	7e 16                	jle    80052d <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 08             	lea    0x8(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 50 04             	mov    0x4(%eax),%edx
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800528:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052b:	eb 34                	jmp    800561 <vprintfmt+0x2d7>
	else if (lflag)
  80052d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800531:	74 18                	je     80054b <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800541:	89 c1                	mov    %eax,%ecx
  800543:	c1 f9 1f             	sar    $0x1f,%ecx
  800546:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800549:	eb 16                	jmp    800561 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 50 04             	lea    0x4(%eax),%edx
  800551:	89 55 14             	mov    %edx,0x14(%ebp)
  800554:	8b 00                	mov    (%eax),%eax
  800556:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800559:	89 c1                	mov    %eax,%ecx
  80055b:	c1 f9 1f             	sar    $0x1f,%ecx
  80055e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800561:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800564:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800567:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800570:	0f 89 88 00 00 00    	jns    8005fe <vprintfmt+0x374>
				putch('-', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	53                   	push   %ebx
  80057a:	6a 2d                	push   $0x2d
  80057c:	ff d6                	call   *%esi
				num = -(long long) num;
  80057e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800581:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800584:	f7 d8                	neg    %eax
  800586:	83 d2 00             	adc    $0x0,%edx
  800589:	f7 da                	neg    %edx
  80058b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800593:	eb 69                	jmp    8005fe <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800595:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 76 fc ff ff       	call   800216 <getuint>
			base = 10;
  8005a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005a5:	eb 57                	jmp    8005fe <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 30                	push   $0x30
  8005ad:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8005af:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b5:	e8 5c fc ff ff       	call   800216 <getuint>
			base = 8;
			goto number;
  8005ba:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005bd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c2:	eb 3a                	jmp    8005fe <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 30                	push   $0x30
  8005ca:	ff d6                	call   *%esi
			putch('x', putdat);
  8005cc:	83 c4 08             	add    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 78                	push   $0x78
  8005d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ec:	eb 10                	jmp    8005fe <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ee:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f4:	e8 1d fc ff ff       	call   800216 <getuint>
			base = 16;
  8005f9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800605:	57                   	push   %edi
  800606:	ff 75 e0             	pushl  -0x20(%ebp)
  800609:	51                   	push   %ecx
  80060a:	52                   	push   %edx
  80060b:	50                   	push   %eax
  80060c:	89 da                	mov    %ebx,%edx
  80060e:	89 f0                	mov    %esi,%eax
  800610:	e8 52 fb ff ff       	call   800167 <printnum>
			break;
  800615:	83 c4 20             	add    $0x20,%esp
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	e9 90 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	52                   	push   %edx
  800625:	ff d6                	call   *%esi
			break;
  800627:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062d:	e9 7e fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 25                	push   $0x25
  800638:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	eb 03                	jmp    800642 <vprintfmt+0x3b8>
  80063f:	83 ef 01             	sub    $0x1,%edi
  800642:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800646:	75 f7                	jne    80063f <vprintfmt+0x3b5>
  800648:	e9 63 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800650:	5b                   	pop    %ebx
  800651:	5e                   	pop    %esi
  800652:	5f                   	pop    %edi
  800653:	5d                   	pop    %ebp
  800654:	c3                   	ret    

00800655 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800655:	55                   	push   %ebp
  800656:	89 e5                	mov    %esp,%ebp
  800658:	83 ec 18             	sub    $0x18,%esp
  80065b:	8b 45 08             	mov    0x8(%ebp),%eax
  80065e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800661:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800664:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800668:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800672:	85 c0                	test   %eax,%eax
  800674:	74 26                	je     80069c <vsnprintf+0x47>
  800676:	85 d2                	test   %edx,%edx
  800678:	7e 22                	jle    80069c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067a:	ff 75 14             	pushl  0x14(%ebp)
  80067d:	ff 75 10             	pushl  0x10(%ebp)
  800680:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800683:	50                   	push   %eax
  800684:	68 50 02 80 00       	push   $0x800250
  800689:	e8 fc fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800691:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	eb 05                	jmp    8006a1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ac:	50                   	push   %eax
  8006ad:	ff 75 10             	pushl  0x10(%ebp)
  8006b0:	ff 75 0c             	pushl  0xc(%ebp)
  8006b3:	ff 75 08             	pushl  0x8(%ebp)
  8006b6:	e8 9a ff ff ff       	call   800655 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c8:	eb 03                	jmp    8006cd <strlen+0x10>
		n++;
  8006ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d1:	75 f7                	jne    8006ca <strlen+0xd>
		n++;
	return n;
}
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006de:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e3:	eb 03                	jmp    8006e8 <strnlen+0x13>
		n++;
  8006e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e8:	39 c2                	cmp    %eax,%edx
  8006ea:	74 08                	je     8006f4 <strnlen+0x1f>
  8006ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f0:	75 f3                	jne    8006e5 <strnlen+0x10>
  8006f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	53                   	push   %ebx
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800700:	89 c2                	mov    %eax,%edx
  800702:	83 c2 01             	add    $0x1,%edx
  800705:	83 c1 01             	add    $0x1,%ecx
  800708:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80070f:	84 db                	test   %bl,%bl
  800711:	75 ef                	jne    800702 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800713:	5b                   	pop    %ebx
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071d:	53                   	push   %ebx
  80071e:	e8 9a ff ff ff       	call   8006bd <strlen>
  800723:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800726:	ff 75 0c             	pushl  0xc(%ebp)
  800729:	01 d8                	add    %ebx,%eax
  80072b:	50                   	push   %eax
  80072c:	e8 c5 ff ff ff       	call   8006f6 <strcpy>
	return dst;
}
  800731:	89 d8                	mov    %ebx,%eax
  800733:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800736:	c9                   	leave  
  800737:	c3                   	ret    

00800738 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	56                   	push   %esi
  80073c:	53                   	push   %ebx
  80073d:	8b 75 08             	mov    0x8(%ebp),%esi
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800743:	89 f3                	mov    %esi,%ebx
  800745:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800748:	89 f2                	mov    %esi,%edx
  80074a:	eb 0f                	jmp    80075b <strncpy+0x23>
		*dst++ = *src;
  80074c:	83 c2 01             	add    $0x1,%edx
  80074f:	0f b6 01             	movzbl (%ecx),%eax
  800752:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800755:	80 39 01             	cmpb   $0x1,(%ecx)
  800758:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075b:	39 da                	cmp    %ebx,%edx
  80075d:	75 ed                	jne    80074c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80075f:	89 f0                	mov    %esi,%eax
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	56                   	push   %esi
  800769:	53                   	push   %ebx
  80076a:	8b 75 08             	mov    0x8(%ebp),%esi
  80076d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800770:	8b 55 10             	mov    0x10(%ebp),%edx
  800773:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800775:	85 d2                	test   %edx,%edx
  800777:	74 21                	je     80079a <strlcpy+0x35>
  800779:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077d:	89 f2                	mov    %esi,%edx
  80077f:	eb 09                	jmp    80078a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800781:	83 c2 01             	add    $0x1,%edx
  800784:	83 c1 01             	add    $0x1,%ecx
  800787:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078a:	39 c2                	cmp    %eax,%edx
  80078c:	74 09                	je     800797 <strlcpy+0x32>
  80078e:	0f b6 19             	movzbl (%ecx),%ebx
  800791:	84 db                	test   %bl,%bl
  800793:	75 ec                	jne    800781 <strlcpy+0x1c>
  800795:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800797:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079a:	29 f0                	sub    %esi,%eax
}
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a9:	eb 06                	jmp    8007b1 <strcmp+0x11>
		p++, q++;
  8007ab:	83 c1 01             	add    $0x1,%ecx
  8007ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b1:	0f b6 01             	movzbl (%ecx),%eax
  8007b4:	84 c0                	test   %al,%al
  8007b6:	74 04                	je     8007bc <strcmp+0x1c>
  8007b8:	3a 02                	cmp    (%edx),%al
  8007ba:	74 ef                	je     8007ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bc:	0f b6 c0             	movzbl %al,%eax
  8007bf:	0f b6 12             	movzbl (%edx),%edx
  8007c2:	29 d0                	sub    %edx,%eax
}
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 c3                	mov    %eax,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d5:	eb 06                	jmp    8007dd <strncmp+0x17>
		n--, p++, q++;
  8007d7:	83 c0 01             	add    $0x1,%eax
  8007da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007dd:	39 d8                	cmp    %ebx,%eax
  8007df:	74 15                	je     8007f6 <strncmp+0x30>
  8007e1:	0f b6 08             	movzbl (%eax),%ecx
  8007e4:	84 c9                	test   %cl,%cl
  8007e6:	74 04                	je     8007ec <strncmp+0x26>
  8007e8:	3a 0a                	cmp    (%edx),%cl
  8007ea:	74 eb                	je     8007d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ec:	0f b6 00             	movzbl (%eax),%eax
  8007ef:	0f b6 12             	movzbl (%edx),%edx
  8007f2:	29 d0                	sub    %edx,%eax
  8007f4:	eb 05                	jmp    8007fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fb:	5b                   	pop    %ebx
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800808:	eb 07                	jmp    800811 <strchr+0x13>
		if (*s == c)
  80080a:	38 ca                	cmp    %cl,%dl
  80080c:	74 0f                	je     80081d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	0f b6 10             	movzbl (%eax),%edx
  800814:	84 d2                	test   %dl,%dl
  800816:	75 f2                	jne    80080a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800829:	eb 03                	jmp    80082e <strfind+0xf>
  80082b:	83 c0 01             	add    $0x1,%eax
  80082e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800831:	38 ca                	cmp    %cl,%dl
  800833:	74 04                	je     800839 <strfind+0x1a>
  800835:	84 d2                	test   %dl,%dl
  800837:	75 f2                	jne    80082b <strfind+0xc>
			break;
	return (char *) s;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	57                   	push   %edi
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 7d 08             	mov    0x8(%ebp),%edi
  800844:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800847:	85 c9                	test   %ecx,%ecx
  800849:	74 36                	je     800881 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800851:	75 28                	jne    80087b <memset+0x40>
  800853:	f6 c1 03             	test   $0x3,%cl
  800856:	75 23                	jne    80087b <memset+0x40>
		c &= 0xFF;
  800858:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085c:	89 d3                	mov    %edx,%ebx
  80085e:	c1 e3 08             	shl    $0x8,%ebx
  800861:	89 d6                	mov    %edx,%esi
  800863:	c1 e6 18             	shl    $0x18,%esi
  800866:	89 d0                	mov    %edx,%eax
  800868:	c1 e0 10             	shl    $0x10,%eax
  80086b:	09 f0                	or     %esi,%eax
  80086d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	09 d0                	or     %edx,%eax
  800873:	c1 e9 02             	shr    $0x2,%ecx
  800876:	fc                   	cld    
  800877:	f3 ab                	rep stos %eax,%es:(%edi)
  800879:	eb 06                	jmp    800881 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087e:	fc                   	cld    
  80087f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800881:	89 f8                	mov    %edi,%eax
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	57                   	push   %edi
  80088c:	56                   	push   %esi
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 75 0c             	mov    0xc(%ebp),%esi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800896:	39 c6                	cmp    %eax,%esi
  800898:	73 35                	jae    8008cf <memmove+0x47>
  80089a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089d:	39 d0                	cmp    %edx,%eax
  80089f:	73 2e                	jae    8008cf <memmove+0x47>
		s += n;
		d += n;
  8008a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a4:	89 d6                	mov    %edx,%esi
  8008a6:	09 fe                	or     %edi,%esi
  8008a8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ae:	75 13                	jne    8008c3 <memmove+0x3b>
  8008b0:	f6 c1 03             	test   $0x3,%cl
  8008b3:	75 0e                	jne    8008c3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b5:	83 ef 04             	sub    $0x4,%edi
  8008b8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bb:	c1 e9 02             	shr    $0x2,%ecx
  8008be:	fd                   	std    
  8008bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c1:	eb 09                	jmp    8008cc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c3:	83 ef 01             	sub    $0x1,%edi
  8008c6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c9:	fd                   	std    
  8008ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cc:	fc                   	cld    
  8008cd:	eb 1d                	jmp    8008ec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cf:	89 f2                	mov    %esi,%edx
  8008d1:	09 c2                	or     %eax,%edx
  8008d3:	f6 c2 03             	test   $0x3,%dl
  8008d6:	75 0f                	jne    8008e7 <memmove+0x5f>
  8008d8:	f6 c1 03             	test   $0x3,%cl
  8008db:	75 0a                	jne    8008e7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
  8008e0:	89 c7                	mov    %eax,%edi
  8008e2:	fc                   	cld    
  8008e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e5:	eb 05                	jmp    8008ec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e7:	89 c7                	mov    %eax,%edi
  8008e9:	fc                   	cld    
  8008ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f3:	ff 75 10             	pushl  0x10(%ebp)
  8008f6:	ff 75 0c             	pushl  0xc(%ebp)
  8008f9:	ff 75 08             	pushl  0x8(%ebp)
  8008fc:	e8 87 ff ff ff       	call   800888 <memmove>
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 c6                	mov    %eax,%esi
  800910:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800913:	eb 1a                	jmp    80092f <memcmp+0x2c>
		if (*s1 != *s2)
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	0f b6 1a             	movzbl (%edx),%ebx
  80091b:	38 d9                	cmp    %bl,%cl
  80091d:	74 0a                	je     800929 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80091f:	0f b6 c1             	movzbl %cl,%eax
  800922:	0f b6 db             	movzbl %bl,%ebx
  800925:	29 d8                	sub    %ebx,%eax
  800927:	eb 0f                	jmp    800938 <memcmp+0x35>
		s1++, s2++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	39 f0                	cmp    %esi,%eax
  800931:	75 e2                	jne    800915 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800943:	89 c1                	mov    %eax,%ecx
  800945:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800948:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094c:	eb 0a                	jmp    800958 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094e:	0f b6 10             	movzbl (%eax),%edx
  800951:	39 da                	cmp    %ebx,%edx
  800953:	74 07                	je     80095c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	39 c8                	cmp    %ecx,%eax
  80095a:	72 f2                	jb     80094e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095c:	5b                   	pop    %ebx
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800968:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096b:	eb 03                	jmp    800970 <strtol+0x11>
		s++;
  80096d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800970:	0f b6 01             	movzbl (%ecx),%eax
  800973:	3c 20                	cmp    $0x20,%al
  800975:	74 f6                	je     80096d <strtol+0xe>
  800977:	3c 09                	cmp    $0x9,%al
  800979:	74 f2                	je     80096d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097b:	3c 2b                	cmp    $0x2b,%al
  80097d:	75 0a                	jne    800989 <strtol+0x2a>
		s++;
  80097f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800982:	bf 00 00 00 00       	mov    $0x0,%edi
  800987:	eb 11                	jmp    80099a <strtol+0x3b>
  800989:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80098e:	3c 2d                	cmp    $0x2d,%al
  800990:	75 08                	jne    80099a <strtol+0x3b>
		s++, neg = 1;
  800992:	83 c1 01             	add    $0x1,%ecx
  800995:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a0:	75 15                	jne    8009b7 <strtol+0x58>
  8009a2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a5:	75 10                	jne    8009b7 <strtol+0x58>
  8009a7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ab:	75 7c                	jne    800a29 <strtol+0xca>
		s += 2, base = 16;
  8009ad:	83 c1 02             	add    $0x2,%ecx
  8009b0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b5:	eb 16                	jmp    8009cd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b7:	85 db                	test   %ebx,%ebx
  8009b9:	75 12                	jne    8009cd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c3:	75 08                	jne    8009cd <strtol+0x6e>
		s++, base = 8;
  8009c5:	83 c1 01             	add    $0x1,%ecx
  8009c8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d5:	0f b6 11             	movzbl (%ecx),%edx
  8009d8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009db:	89 f3                	mov    %esi,%ebx
  8009dd:	80 fb 09             	cmp    $0x9,%bl
  8009e0:	77 08                	ja     8009ea <strtol+0x8b>
			dig = *s - '0';
  8009e2:	0f be d2             	movsbl %dl,%edx
  8009e5:	83 ea 30             	sub    $0x30,%edx
  8009e8:	eb 22                	jmp    800a0c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ea:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	80 fb 19             	cmp    $0x19,%bl
  8009f2:	77 08                	ja     8009fc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f4:	0f be d2             	movsbl %dl,%edx
  8009f7:	83 ea 57             	sub    $0x57,%edx
  8009fa:	eb 10                	jmp    800a0c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 16                	ja     800a1c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a0f:	7d 0b                	jge    800a1c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1a:	eb b9                	jmp    8009d5 <strtol+0x76>

	if (endptr)
  800a1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a20:	74 0d                	je     800a2f <strtol+0xd0>
		*endptr = (char *) s;
  800a22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a25:	89 0e                	mov    %ecx,(%esi)
  800a27:	eb 06                	jmp    800a2f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	74 98                	je     8009c5 <strtol+0x66>
  800a2d:	eb 9e                	jmp    8009cd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	f7 da                	neg    %edx
  800a33:	85 ff                	test   %edi,%edi
  800a35:	0f 45 c2             	cmovne %edx,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4e:	89 c3                	mov    %eax,%ebx
  800a50:	89 c7                	mov    %eax,%edi
  800a52:	89 c6                	mov    %eax,%esi
  800a54:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a61:	ba 00 00 00 00       	mov    $0x0,%edx
  800a66:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6b:	89 d1                	mov    %edx,%ecx
  800a6d:	89 d3                	mov    %edx,%ebx
  800a6f:	89 d7                	mov    %edx,%edi
  800a71:	89 d6                	mov    %edx,%esi
  800a73:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a88:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a90:	89 cb                	mov    %ecx,%ebx
  800a92:	89 cf                	mov    %ecx,%edi
  800a94:	89 ce                	mov    %ecx,%esi
  800a96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	7e 17                	jle    800ab3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	50                   	push   %eax
  800aa0:	6a 03                	push   $0x3
  800aa2:	68 ff 20 80 00       	push   $0x8020ff
  800aa7:	6a 23                	push   $0x23
  800aa9:	68 1c 21 80 00       	push   $0x80211c
  800aae:	e8 21 0f 00 00       	call   8019d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac6:	b8 02 00 00 00       	mov    $0x2,%eax
  800acb:	89 d1                	mov    %edx,%ecx
  800acd:	89 d3                	mov    %edx,%ebx
  800acf:	89 d7                	mov    %edx,%edi
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_yield>:

void
sys_yield(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	be 00 00 00 00       	mov    $0x0,%esi
  800b07:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b15:	89 f7                	mov    %esi,%edi
  800b17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 17                	jle    800b34 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	50                   	push   %eax
  800b21:	6a 04                	push   $0x4
  800b23:	68 ff 20 80 00       	push   $0x8020ff
  800b28:	6a 23                	push   $0x23
  800b2a:	68 1c 21 80 00       	push   $0x80211c
  800b2f:	e8 a0 0e 00 00       	call   8019d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b56:	8b 75 18             	mov    0x18(%ebp),%esi
  800b59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 17                	jle    800b76 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	6a 05                	push   $0x5
  800b65:	68 ff 20 80 00       	push   $0x8020ff
  800b6a:	6a 23                	push   $0x23
  800b6c:	68 1c 21 80 00       	push   $0x80211c
  800b71:	e8 5e 0e 00 00       	call   8019d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	89 df                	mov    %ebx,%edi
  800b99:	89 de                	mov    %ebx,%esi
  800b9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 06                	push   $0x6
  800ba7:	68 ff 20 80 00       	push   $0x8020ff
  800bac:	6a 23                	push   $0x23
  800bae:	68 1c 21 80 00       	push   $0x80211c
  800bb3:	e8 1c 0e 00 00       	call   8019d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bce:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 df                	mov    %ebx,%edi
  800bdb:	89 de                	mov    %ebx,%esi
  800bdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 17                	jle    800bfa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	50                   	push   %eax
  800be7:	6a 08                	push   $0x8
  800be9:	68 ff 20 80 00       	push   $0x8020ff
  800bee:	6a 23                	push   $0x23
  800bf0:	68 1c 21 80 00       	push   $0x80211c
  800bf5:	e8 da 0d 00 00       	call   8019d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c10:	b8 09 00 00 00       	mov    $0x9,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	89 df                	mov    %ebx,%edi
  800c1d:	89 de                	mov    %ebx,%esi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 09                	push   $0x9
  800c2b:	68 ff 20 80 00       	push   $0x8020ff
  800c30:	6a 23                	push   $0x23
  800c32:	68 1c 21 80 00       	push   $0x80211c
  800c37:	e8 98 0d 00 00       	call   8019d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 df                	mov    %ebx,%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 0a                	push   $0xa
  800c6d:	68 ff 20 80 00       	push   $0x8020ff
  800c72:	6a 23                	push   $0x23
  800c74:	68 1c 21 80 00       	push   $0x80211c
  800c79:	e8 56 0d 00 00       	call   8019d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 cb                	mov    %ecx,%ebx
  800cc1:	89 cf                	mov    %ecx,%edi
  800cc3:	89 ce                	mov    %ecx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 17                	jle    800ce2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	50                   	push   %eax
  800ccf:	6a 0d                	push   $0xd
  800cd1:	68 ff 20 80 00       	push   $0x8020ff
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 1c 21 80 00       	push   $0x80211c
  800cdd:	e8 f2 0c 00 00       	call   8019d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	05 00 00 00 30       	add    $0x30000000,%eax
  800cf5:	c1 e8 0c             	shr    $0xc,%eax
}
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	05 00 00 00 30       	add    $0x30000000,%eax
  800d05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d0a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d1c:	89 c2                	mov    %eax,%edx
  800d1e:	c1 ea 16             	shr    $0x16,%edx
  800d21:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d28:	f6 c2 01             	test   $0x1,%dl
  800d2b:	74 11                	je     800d3e <fd_alloc+0x2d>
  800d2d:	89 c2                	mov    %eax,%edx
  800d2f:	c1 ea 0c             	shr    $0xc,%edx
  800d32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d39:	f6 c2 01             	test   $0x1,%dl
  800d3c:	75 09                	jne    800d47 <fd_alloc+0x36>
			*fd_store = fd;
  800d3e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
  800d45:	eb 17                	jmp    800d5e <fd_alloc+0x4d>
  800d47:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d4c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d51:	75 c9                	jne    800d1c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d53:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d59:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d66:	83 f8 1f             	cmp    $0x1f,%eax
  800d69:	77 36                	ja     800da1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d6b:	c1 e0 0c             	shl    $0xc,%eax
  800d6e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	c1 ea 16             	shr    $0x16,%edx
  800d78:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d7f:	f6 c2 01             	test   $0x1,%dl
  800d82:	74 24                	je     800da8 <fd_lookup+0x48>
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	c1 ea 0c             	shr    $0xc,%edx
  800d89:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d90:	f6 c2 01             	test   $0x1,%dl
  800d93:	74 1a                	je     800daf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d98:	89 02                	mov    %eax,(%edx)
	return 0;
  800d9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9f:	eb 13                	jmp    800db4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da6:	eb 0c                	jmp    800db4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800da8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dad:	eb 05                	jmp    800db4 <fd_lookup+0x54>
  800daf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	83 ec 08             	sub    $0x8,%esp
  800dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbf:	ba a8 21 80 00       	mov    $0x8021a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dc4:	eb 13                	jmp    800dd9 <dev_lookup+0x23>
  800dc6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dc9:	39 08                	cmp    %ecx,(%eax)
  800dcb:	75 0c                	jne    800dd9 <dev_lookup+0x23>
			*dev = devtab[i];
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd7:	eb 2e                	jmp    800e07 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dd9:	8b 02                	mov    (%edx),%eax
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	75 e7                	jne    800dc6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ddf:	a1 08 40 80 00       	mov    0x804008,%eax
  800de4:	8b 40 48             	mov    0x48(%eax),%eax
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	51                   	push   %ecx
  800deb:	50                   	push   %eax
  800dec:	68 2c 21 80 00       	push   $0x80212c
  800df1:	e8 5d f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 10             	sub    $0x10,%esp
  800e11:	8b 75 08             	mov    0x8(%ebp),%esi
  800e14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1a:	50                   	push   %eax
  800e1b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e21:	c1 e8 0c             	shr    $0xc,%eax
  800e24:	50                   	push   %eax
  800e25:	e8 36 ff ff ff       	call   800d60 <fd_lookup>
  800e2a:	83 c4 08             	add    $0x8,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	78 05                	js     800e36 <fd_close+0x2d>
	    || fd != fd2)
  800e31:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e34:	74 0c                	je     800e42 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e36:	84 db                	test   %bl,%bl
  800e38:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3d:	0f 44 c2             	cmove  %edx,%eax
  800e40:	eb 41                	jmp    800e83 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e48:	50                   	push   %eax
  800e49:	ff 36                	pushl  (%esi)
  800e4b:	e8 66 ff ff ff       	call   800db6 <dev_lookup>
  800e50:	89 c3                	mov    %eax,%ebx
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	85 c0                	test   %eax,%eax
  800e57:	78 1a                	js     800e73 <fd_close+0x6a>
		if (dev->dev_close)
  800e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e64:	85 c0                	test   %eax,%eax
  800e66:	74 0b                	je     800e73 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	56                   	push   %esi
  800e6c:	ff d0                	call   *%eax
  800e6e:	89 c3                	mov    %eax,%ebx
  800e70:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	56                   	push   %esi
  800e77:	6a 00                	push   $0x0
  800e79:	e8 00 fd ff ff       	call   800b7e <sys_page_unmap>
	return r;
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	89 d8                	mov    %ebx,%eax
}
  800e83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e93:	50                   	push   %eax
  800e94:	ff 75 08             	pushl  0x8(%ebp)
  800e97:	e8 c4 fe ff ff       	call   800d60 <fd_lookup>
  800e9c:	83 c4 08             	add    $0x8,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	78 10                	js     800eb3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	6a 01                	push   $0x1
  800ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  800eab:	e8 59 ff ff ff       	call   800e09 <fd_close>
  800eb0:	83 c4 10             	add    $0x10,%esp
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <close_all>:

void
close_all(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	53                   	push   %ebx
  800ec5:	e8 c0 ff ff ff       	call   800e8a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eca:	83 c3 01             	add    $0x1,%ebx
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	83 fb 20             	cmp    $0x20,%ebx
  800ed3:	75 ec                	jne    800ec1 <close_all+0xc>
		close(i);
}
  800ed5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	83 ec 2c             	sub    $0x2c,%esp
  800ee3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ee6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ee9:	50                   	push   %eax
  800eea:	ff 75 08             	pushl  0x8(%ebp)
  800eed:	e8 6e fe ff ff       	call   800d60 <fd_lookup>
  800ef2:	83 c4 08             	add    $0x8,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	0f 88 c1 00 00 00    	js     800fbe <dup+0xe4>
		return r;
	close(newfdnum);
  800efd:	83 ec 0c             	sub    $0xc,%esp
  800f00:	56                   	push   %esi
  800f01:	e8 84 ff ff ff       	call   800e8a <close>

	newfd = INDEX2FD(newfdnum);
  800f06:	89 f3                	mov    %esi,%ebx
  800f08:	c1 e3 0c             	shl    $0xc,%ebx
  800f0b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f11:	83 c4 04             	add    $0x4,%esp
  800f14:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f17:	e8 de fd ff ff       	call   800cfa <fd2data>
  800f1c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f1e:	89 1c 24             	mov    %ebx,(%esp)
  800f21:	e8 d4 fd ff ff       	call   800cfa <fd2data>
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f2c:	89 f8                	mov    %edi,%eax
  800f2e:	c1 e8 16             	shr    $0x16,%eax
  800f31:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f38:	a8 01                	test   $0x1,%al
  800f3a:	74 37                	je     800f73 <dup+0x99>
  800f3c:	89 f8                	mov    %edi,%eax
  800f3e:	c1 e8 0c             	shr    $0xc,%eax
  800f41:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f48:	f6 c2 01             	test   $0x1,%dl
  800f4b:	74 26                	je     800f73 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f4d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5c:	50                   	push   %eax
  800f5d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f60:	6a 00                	push   $0x0
  800f62:	57                   	push   %edi
  800f63:	6a 00                	push   $0x0
  800f65:	e8 d2 fb ff ff       	call   800b3c <sys_page_map>
  800f6a:	89 c7                	mov    %eax,%edi
  800f6c:	83 c4 20             	add    $0x20,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 2e                	js     800fa1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f76:	89 d0                	mov    %edx,%eax
  800f78:	c1 e8 0c             	shr    $0xc,%eax
  800f7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	25 07 0e 00 00       	and    $0xe07,%eax
  800f8a:	50                   	push   %eax
  800f8b:	53                   	push   %ebx
  800f8c:	6a 00                	push   $0x0
  800f8e:	52                   	push   %edx
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 a6 fb ff ff       	call   800b3c <sys_page_map>
  800f96:	89 c7                	mov    %eax,%edi
  800f98:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f9b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9d:	85 ff                	test   %edi,%edi
  800f9f:	79 1d                	jns    800fbe <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fa1:	83 ec 08             	sub    $0x8,%esp
  800fa4:	53                   	push   %ebx
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 d2 fb ff ff       	call   800b7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fac:	83 c4 08             	add    $0x8,%esp
  800faf:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 c5 fb ff ff       	call   800b7e <sys_page_unmap>
	return r;
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	89 f8                	mov    %edi,%eax
}
  800fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 14             	sub    $0x14,%esp
  800fcd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	53                   	push   %ebx
  800fd5:	e8 86 fd ff ff       	call   800d60 <fd_lookup>
  800fda:	83 c4 08             	add    $0x8,%esp
  800fdd:	89 c2                	mov    %eax,%edx
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	78 6d                	js     801050 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fe3:	83 ec 08             	sub    $0x8,%esp
  800fe6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fed:	ff 30                	pushl  (%eax)
  800fef:	e8 c2 fd ff ff       	call   800db6 <dev_lookup>
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 4c                	js     801047 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ffb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffe:	8b 42 08             	mov    0x8(%edx),%eax
  801001:	83 e0 03             	and    $0x3,%eax
  801004:	83 f8 01             	cmp    $0x1,%eax
  801007:	75 21                	jne    80102a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801009:	a1 08 40 80 00       	mov    0x804008,%eax
  80100e:	8b 40 48             	mov    0x48(%eax),%eax
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	53                   	push   %ebx
  801015:	50                   	push   %eax
  801016:	68 6d 21 80 00       	push   $0x80216d
  80101b:	e8 33 f1 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801028:	eb 26                	jmp    801050 <read+0x8a>
	}
	if (!dev->dev_read)
  80102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102d:	8b 40 08             	mov    0x8(%eax),%eax
  801030:	85 c0                	test   %eax,%eax
  801032:	74 17                	je     80104b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801034:	83 ec 04             	sub    $0x4,%esp
  801037:	ff 75 10             	pushl  0x10(%ebp)
  80103a:	ff 75 0c             	pushl  0xc(%ebp)
  80103d:	52                   	push   %edx
  80103e:	ff d0                	call   *%eax
  801040:	89 c2                	mov    %eax,%edx
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	eb 09                	jmp    801050 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801047:	89 c2                	mov    %eax,%edx
  801049:	eb 05                	jmp    801050 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80104b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801050:	89 d0                	mov    %edx,%eax
  801052:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	8b 7d 08             	mov    0x8(%ebp),%edi
  801063:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801066:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106b:	eb 21                	jmp    80108e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80106d:	83 ec 04             	sub    $0x4,%esp
  801070:	89 f0                	mov    %esi,%eax
  801072:	29 d8                	sub    %ebx,%eax
  801074:	50                   	push   %eax
  801075:	89 d8                	mov    %ebx,%eax
  801077:	03 45 0c             	add    0xc(%ebp),%eax
  80107a:	50                   	push   %eax
  80107b:	57                   	push   %edi
  80107c:	e8 45 ff ff ff       	call   800fc6 <read>
		if (m < 0)
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 10                	js     801098 <readn+0x41>
			return m;
		if (m == 0)
  801088:	85 c0                	test   %eax,%eax
  80108a:	74 0a                	je     801096 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108c:	01 c3                	add    %eax,%ebx
  80108e:	39 f3                	cmp    %esi,%ebx
  801090:	72 db                	jb     80106d <readn+0x16>
  801092:	89 d8                	mov    %ebx,%eax
  801094:	eb 02                	jmp    801098 <readn+0x41>
  801096:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 14             	sub    $0x14,%esp
  8010a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ad:	50                   	push   %eax
  8010ae:	53                   	push   %ebx
  8010af:	e8 ac fc ff ff       	call   800d60 <fd_lookup>
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	89 c2                	mov    %eax,%edx
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 68                	js     801125 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c3:	50                   	push   %eax
  8010c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c7:	ff 30                	pushl  (%eax)
  8010c9:	e8 e8 fc ff ff       	call   800db6 <dev_lookup>
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 47                	js     80111c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010dc:	75 21                	jne    8010ff <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010de:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e3:	8b 40 48             	mov    0x48(%eax),%eax
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	53                   	push   %ebx
  8010ea:	50                   	push   %eax
  8010eb:	68 89 21 80 00       	push   $0x802189
  8010f0:	e8 5e f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010fd:	eb 26                	jmp    801125 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801102:	8b 52 0c             	mov    0xc(%edx),%edx
  801105:	85 d2                	test   %edx,%edx
  801107:	74 17                	je     801120 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	ff 75 10             	pushl  0x10(%ebp)
  80110f:	ff 75 0c             	pushl  0xc(%ebp)
  801112:	50                   	push   %eax
  801113:	ff d2                	call   *%edx
  801115:	89 c2                	mov    %eax,%edx
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	eb 09                	jmp    801125 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111c:	89 c2                	mov    %eax,%edx
  80111e:	eb 05                	jmp    801125 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801120:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801125:	89 d0                	mov    %edx,%eax
  801127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <seek>:

int
seek(int fdnum, off_t offset)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801132:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801135:	50                   	push   %eax
  801136:	ff 75 08             	pushl  0x8(%ebp)
  801139:	e8 22 fc ff ff       	call   800d60 <fd_lookup>
  80113e:	83 c4 08             	add    $0x8,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	78 0e                	js     801153 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801145:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801148:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	53                   	push   %ebx
  801159:	83 ec 14             	sub    $0x14,%esp
  80115c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80115f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801162:	50                   	push   %eax
  801163:	53                   	push   %ebx
  801164:	e8 f7 fb ff ff       	call   800d60 <fd_lookup>
  801169:	83 c4 08             	add    $0x8,%esp
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 65                	js     8011d7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801178:	50                   	push   %eax
  801179:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117c:	ff 30                	pushl  (%eax)
  80117e:	e8 33 fc ff ff       	call   800db6 <dev_lookup>
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	85 c0                	test   %eax,%eax
  801188:	78 44                	js     8011ce <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80118a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801191:	75 21                	jne    8011b4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801193:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801198:	8b 40 48             	mov    0x48(%eax),%eax
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	53                   	push   %ebx
  80119f:	50                   	push   %eax
  8011a0:	68 4c 21 80 00       	push   $0x80214c
  8011a5:	e8 a9 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b2:	eb 23                	jmp    8011d7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011b7:	8b 52 18             	mov    0x18(%edx),%edx
  8011ba:	85 d2                	test   %edx,%edx
  8011bc:	74 14                	je     8011d2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	ff 75 0c             	pushl  0xc(%ebp)
  8011c4:	50                   	push   %eax
  8011c5:	ff d2                	call   *%edx
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	eb 09                	jmp    8011d7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	eb 05                	jmp    8011d7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011d7:	89 d0                	mov    %edx,%eax
  8011d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011dc:	c9                   	leave  
  8011dd:	c3                   	ret    

008011de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 14             	sub    $0x14,%esp
  8011e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011eb:	50                   	push   %eax
  8011ec:	ff 75 08             	pushl  0x8(%ebp)
  8011ef:	e8 6c fb ff ff       	call   800d60 <fd_lookup>
  8011f4:	83 c4 08             	add    $0x8,%esp
  8011f7:	89 c2                	mov    %eax,%edx
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 58                	js     801255 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fd:	83 ec 08             	sub    $0x8,%esp
  801200:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801207:	ff 30                	pushl  (%eax)
  801209:	e8 a8 fb ff ff       	call   800db6 <dev_lookup>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 37                	js     80124c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801218:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80121c:	74 32                	je     801250 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80121e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801221:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801228:	00 00 00 
	stat->st_isdir = 0;
  80122b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801232:	00 00 00 
	stat->st_dev = dev;
  801235:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	53                   	push   %ebx
  80123f:	ff 75 f0             	pushl  -0x10(%ebp)
  801242:	ff 50 14             	call   *0x14(%eax)
  801245:	89 c2                	mov    %eax,%edx
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	eb 09                	jmp    801255 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	eb 05                	jmp    801255 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801250:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801255:	89 d0                	mov    %edx,%eax
  801257:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	6a 00                	push   $0x0
  801266:	ff 75 08             	pushl  0x8(%ebp)
  801269:	e8 e3 01 00 00       	call   801451 <open>
  80126e:	89 c3                	mov    %eax,%ebx
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 1b                	js     801292 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	ff 75 0c             	pushl  0xc(%ebp)
  80127d:	50                   	push   %eax
  80127e:	e8 5b ff ff ff       	call   8011de <fstat>
  801283:	89 c6                	mov    %eax,%esi
	close(fd);
  801285:	89 1c 24             	mov    %ebx,(%esp)
  801288:	e8 fd fb ff ff       	call   800e8a <close>
	return r;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	89 f0                	mov    %esi,%eax
}
  801292:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	89 c6                	mov    %eax,%esi
  8012a0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012a2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012a9:	75 12                	jne    8012bd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ab:	83 ec 0c             	sub    $0xc,%esp
  8012ae:	6a 01                	push   $0x1
  8012b0:	e8 0e 08 00 00       	call   801ac3 <ipc_find_env>
  8012b5:	a3 00 40 80 00       	mov    %eax,0x804000
  8012ba:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012bd:	6a 07                	push   $0x7
  8012bf:	68 00 50 80 00       	push   $0x805000
  8012c4:	56                   	push   %esi
  8012c5:	ff 35 00 40 80 00    	pushl  0x804000
  8012cb:	e8 9f 07 00 00       	call   801a6f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012d0:	83 c4 0c             	add    $0xc,%esp
  8012d3:	6a 00                	push   $0x0
  8012d5:	53                   	push   %ebx
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 3d 07 00 00       	call   801a1a <ipc_recv>
}
  8012dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5e                   	pop    %esi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8012f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801302:	b8 02 00 00 00       	mov    $0x2,%eax
  801307:	e8 8d ff ff ff       	call   801299 <fsipc>
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
  801317:	8b 40 0c             	mov    0xc(%eax),%eax
  80131a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80131f:	ba 00 00 00 00       	mov    $0x0,%edx
  801324:	b8 06 00 00 00       	mov    $0x6,%eax
  801329:	e8 6b ff ff ff       	call   801299 <fsipc>
}
  80132e:	c9                   	leave  
  80132f:	c3                   	ret    

00801330 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	53                   	push   %ebx
  801334:	83 ec 04             	sub    $0x4,%esp
  801337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80133a:	8b 45 08             	mov    0x8(%ebp),%eax
  80133d:	8b 40 0c             	mov    0xc(%eax),%eax
  801340:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801345:	ba 00 00 00 00       	mov    $0x0,%edx
  80134a:	b8 05 00 00 00       	mov    $0x5,%eax
  80134f:	e8 45 ff ff ff       	call   801299 <fsipc>
  801354:	85 c0                	test   %eax,%eax
  801356:	78 2c                	js     801384 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801358:	83 ec 08             	sub    $0x8,%esp
  80135b:	68 00 50 80 00       	push   $0x805000
  801360:	53                   	push   %ebx
  801361:	e8 90 f3 ff ff       	call   8006f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801366:	a1 80 50 80 00       	mov    0x805080,%eax
  80136b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801371:	a1 84 50 80 00       	mov    0x805084,%eax
  801376:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801392:	8b 55 08             	mov    0x8(%ebp),%edx
  801395:	8b 52 0c             	mov    0xc(%edx),%edx
  801398:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80139e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013a3:	ba 00 10 00 00       	mov    $0x1000,%edx
  8013a8:	0f 47 c2             	cmova  %edx,%eax
  8013ab:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013b0:	50                   	push   %eax
  8013b1:	ff 75 0c             	pushl  0xc(%ebp)
  8013b4:	68 08 50 80 00       	push   $0x805008
  8013b9:	e8 ca f4 ff ff       	call   800888 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8013be:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8013c8:	e8 cc fe ff ff       	call   801299 <fsipc>
    return r;
}
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    

008013cf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013e2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8013f2:	e8 a2 fe ff ff       	call   801299 <fsipc>
  8013f7:	89 c3                	mov    %eax,%ebx
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	78 4b                	js     801448 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013fd:	39 c6                	cmp    %eax,%esi
  8013ff:	73 16                	jae    801417 <devfile_read+0x48>
  801401:	68 b8 21 80 00       	push   $0x8021b8
  801406:	68 bf 21 80 00       	push   $0x8021bf
  80140b:	6a 7c                	push   $0x7c
  80140d:	68 d4 21 80 00       	push   $0x8021d4
  801412:	e8 bd 05 00 00       	call   8019d4 <_panic>
	assert(r <= PGSIZE);
  801417:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80141c:	7e 16                	jle    801434 <devfile_read+0x65>
  80141e:	68 df 21 80 00       	push   $0x8021df
  801423:	68 bf 21 80 00       	push   $0x8021bf
  801428:	6a 7d                	push   $0x7d
  80142a:	68 d4 21 80 00       	push   $0x8021d4
  80142f:	e8 a0 05 00 00       	call   8019d4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	50                   	push   %eax
  801438:	68 00 50 80 00       	push   $0x805000
  80143d:	ff 75 0c             	pushl  0xc(%ebp)
  801440:	e8 43 f4 ff ff       	call   800888 <memmove>
	return r;
  801445:	83 c4 10             	add    $0x10,%esp
}
  801448:	89 d8                	mov    %ebx,%eax
  80144a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 20             	sub    $0x20,%esp
  801458:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80145b:	53                   	push   %ebx
  80145c:	e8 5c f2 ff ff       	call   8006bd <strlen>
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801469:	7f 67                	jg     8014d2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	e8 9a f8 ff ff       	call   800d11 <fd_alloc>
  801477:	83 c4 10             	add    $0x10,%esp
		return r;
  80147a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 57                	js     8014d7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801480:	83 ec 08             	sub    $0x8,%esp
  801483:	53                   	push   %ebx
  801484:	68 00 50 80 00       	push   $0x805000
  801489:	e8 68 f2 ff ff       	call   8006f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80148e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801491:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801496:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801499:	b8 01 00 00 00       	mov    $0x1,%eax
  80149e:	e8 f6 fd ff ff       	call   801299 <fsipc>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	79 14                	jns    8014c0 <open+0x6f>
		fd_close(fd, 0);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	6a 00                	push   $0x0
  8014b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b4:	e8 50 f9 ff ff       	call   800e09 <fd_close>
		return r;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	89 da                	mov    %ebx,%edx
  8014be:	eb 17                	jmp    8014d7 <open+0x86>
	}

	return fd2num(fd);
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c6:	e8 1f f8 ff ff       	call   800cea <fd2num>
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	eb 05                	jmp    8014d7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014d2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014d7:	89 d0                	mov    %edx,%eax
  8014d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014dc:	c9                   	leave  
  8014dd:	c3                   	ret    

008014de <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e9:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ee:	e8 a6 fd ff ff       	call   801299 <fsipc>
}
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	56                   	push   %esi
  8014f9:	53                   	push   %ebx
  8014fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014fd:	83 ec 0c             	sub    $0xc,%esp
  801500:	ff 75 08             	pushl  0x8(%ebp)
  801503:	e8 f2 f7 ff ff       	call   800cfa <fd2data>
  801508:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80150a:	83 c4 08             	add    $0x8,%esp
  80150d:	68 eb 21 80 00       	push   $0x8021eb
  801512:	53                   	push   %ebx
  801513:	e8 de f1 ff ff       	call   8006f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801518:	8b 46 04             	mov    0x4(%esi),%eax
  80151b:	2b 06                	sub    (%esi),%eax
  80151d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801523:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80152a:	00 00 00 
	stat->st_dev = &devpipe;
  80152d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801534:	30 80 00 
	return 0;
}
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
  80153c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153f:	5b                   	pop    %ebx
  801540:	5e                   	pop    %esi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80154d:	53                   	push   %ebx
  80154e:	6a 00                	push   $0x0
  801550:	e8 29 f6 ff ff       	call   800b7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801555:	89 1c 24             	mov    %ebx,(%esp)
  801558:	e8 9d f7 ff ff       	call   800cfa <fd2data>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	50                   	push   %eax
  801561:	6a 00                	push   $0x0
  801563:	e8 16 f6 ff ff       	call   800b7e <sys_page_unmap>
}
  801568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	57                   	push   %edi
  801571:	56                   	push   %esi
  801572:	53                   	push   %ebx
  801573:	83 ec 1c             	sub    $0x1c,%esp
  801576:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801579:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80157b:	a1 08 40 80 00       	mov    0x804008,%eax
  801580:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801583:	83 ec 0c             	sub    $0xc,%esp
  801586:	ff 75 e0             	pushl  -0x20(%ebp)
  801589:	e8 6e 05 00 00       	call   801afc <pageref>
  80158e:	89 c3                	mov    %eax,%ebx
  801590:	89 3c 24             	mov    %edi,(%esp)
  801593:	e8 64 05 00 00       	call   801afc <pageref>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	39 c3                	cmp    %eax,%ebx
  80159d:	0f 94 c1             	sete   %cl
  8015a0:	0f b6 c9             	movzbl %cl,%ecx
  8015a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015a6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015ac:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015af:	39 ce                	cmp    %ecx,%esi
  8015b1:	74 1b                	je     8015ce <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015b3:	39 c3                	cmp    %eax,%ebx
  8015b5:	75 c4                	jne    80157b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015b7:	8b 42 58             	mov    0x58(%edx),%eax
  8015ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015bd:	50                   	push   %eax
  8015be:	56                   	push   %esi
  8015bf:	68 f2 21 80 00       	push   $0x8021f2
  8015c4:	e8 8a eb ff ff       	call   800153 <cprintf>
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	eb ad                	jmp    80157b <_pipeisclosed+0xe>
	}
}
  8015ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5e                   	pop    %esi
  8015d6:	5f                   	pop    %edi
  8015d7:	5d                   	pop    %ebp
  8015d8:	c3                   	ret    

008015d9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	57                   	push   %edi
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
  8015df:	83 ec 28             	sub    $0x28,%esp
  8015e2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015e5:	56                   	push   %esi
  8015e6:	e8 0f f7 ff ff       	call   800cfa <fd2data>
  8015eb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8015f5:	eb 4b                	jmp    801642 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015f7:	89 da                	mov    %ebx,%edx
  8015f9:	89 f0                	mov    %esi,%eax
  8015fb:	e8 6d ff ff ff       	call   80156d <_pipeisclosed>
  801600:	85 c0                	test   %eax,%eax
  801602:	75 48                	jne    80164c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801604:	e8 d1 f4 ff ff       	call   800ada <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801609:	8b 43 04             	mov    0x4(%ebx),%eax
  80160c:	8b 0b                	mov    (%ebx),%ecx
  80160e:	8d 51 20             	lea    0x20(%ecx),%edx
  801611:	39 d0                	cmp    %edx,%eax
  801613:	73 e2                	jae    8015f7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801615:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801618:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80161c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80161f:	89 c2                	mov    %eax,%edx
  801621:	c1 fa 1f             	sar    $0x1f,%edx
  801624:	89 d1                	mov    %edx,%ecx
  801626:	c1 e9 1b             	shr    $0x1b,%ecx
  801629:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80162c:	83 e2 1f             	and    $0x1f,%edx
  80162f:	29 ca                	sub    %ecx,%edx
  801631:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801635:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801639:	83 c0 01             	add    $0x1,%eax
  80163c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163f:	83 c7 01             	add    $0x1,%edi
  801642:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801645:	75 c2                	jne    801609 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801647:	8b 45 10             	mov    0x10(%ebp),%eax
  80164a:	eb 05                	jmp    801651 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80164c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801651:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801654:	5b                   	pop    %ebx
  801655:	5e                   	pop    %esi
  801656:	5f                   	pop    %edi
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    

00801659 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	57                   	push   %edi
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 18             	sub    $0x18,%esp
  801662:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801665:	57                   	push   %edi
  801666:	e8 8f f6 ff ff       	call   800cfa <fd2data>
  80166b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	bb 00 00 00 00       	mov    $0x0,%ebx
  801675:	eb 3d                	jmp    8016b4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801677:	85 db                	test   %ebx,%ebx
  801679:	74 04                	je     80167f <devpipe_read+0x26>
				return i;
  80167b:	89 d8                	mov    %ebx,%eax
  80167d:	eb 44                	jmp    8016c3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80167f:	89 f2                	mov    %esi,%edx
  801681:	89 f8                	mov    %edi,%eax
  801683:	e8 e5 fe ff ff       	call   80156d <_pipeisclosed>
  801688:	85 c0                	test   %eax,%eax
  80168a:	75 32                	jne    8016be <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80168c:	e8 49 f4 ff ff       	call   800ada <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801691:	8b 06                	mov    (%esi),%eax
  801693:	3b 46 04             	cmp    0x4(%esi),%eax
  801696:	74 df                	je     801677 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801698:	99                   	cltd   
  801699:	c1 ea 1b             	shr    $0x1b,%edx
  80169c:	01 d0                	add    %edx,%eax
  80169e:	83 e0 1f             	and    $0x1f,%eax
  8016a1:	29 d0                	sub    %edx,%eax
  8016a3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ab:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ae:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b1:	83 c3 01             	add    $0x1,%ebx
  8016b4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016b7:	75 d8                	jne    801691 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bc:	eb 05                	jmp    8016c3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016be:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5f                   	pop    %edi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	56                   	push   %esi
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	e8 35 f6 ff ff       	call   800d11 <fd_alloc>
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	0f 88 2c 01 00 00    	js     801815 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e9:	83 ec 04             	sub    $0x4,%esp
  8016ec:	68 07 04 00 00       	push   $0x407
  8016f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f4:	6a 00                	push   $0x0
  8016f6:	e8 fe f3 ff ff       	call   800af9 <sys_page_alloc>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	85 c0                	test   %eax,%eax
  801702:	0f 88 0d 01 00 00    	js     801815 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801708:	83 ec 0c             	sub    $0xc,%esp
  80170b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170e:	50                   	push   %eax
  80170f:	e8 fd f5 ff ff       	call   800d11 <fd_alloc>
  801714:	89 c3                	mov    %eax,%ebx
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	0f 88 e2 00 00 00    	js     801803 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801721:	83 ec 04             	sub    $0x4,%esp
  801724:	68 07 04 00 00       	push   $0x407
  801729:	ff 75 f0             	pushl  -0x10(%ebp)
  80172c:	6a 00                	push   $0x0
  80172e:	e8 c6 f3 ff ff       	call   800af9 <sys_page_alloc>
  801733:	89 c3                	mov    %eax,%ebx
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	0f 88 c3 00 00 00    	js     801803 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801740:	83 ec 0c             	sub    $0xc,%esp
  801743:	ff 75 f4             	pushl  -0xc(%ebp)
  801746:	e8 af f5 ff ff       	call   800cfa <fd2data>
  80174b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174d:	83 c4 0c             	add    $0xc,%esp
  801750:	68 07 04 00 00       	push   $0x407
  801755:	50                   	push   %eax
  801756:	6a 00                	push   $0x0
  801758:	e8 9c f3 ff ff       	call   800af9 <sys_page_alloc>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	85 c0                	test   %eax,%eax
  801764:	0f 88 89 00 00 00    	js     8017f3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	ff 75 f0             	pushl  -0x10(%ebp)
  801770:	e8 85 f5 ff ff       	call   800cfa <fd2data>
  801775:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80177c:	50                   	push   %eax
  80177d:	6a 00                	push   $0x0
  80177f:	56                   	push   %esi
  801780:	6a 00                	push   $0x0
  801782:	e8 b5 f3 ff ff       	call   800b3c <sys_page_map>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	83 c4 20             	add    $0x20,%esp
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 55                	js     8017e5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801790:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801799:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017a5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ae:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017ba:	83 ec 0c             	sub    $0xc,%esp
  8017bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c0:	e8 25 f5 ff ff       	call   800cea <fd2num>
  8017c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017ca:	83 c4 04             	add    $0x4,%esp
  8017cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d0:	e8 15 f5 ff ff       	call   800cea <fd2num>
  8017d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	eb 30                	jmp    801815 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	56                   	push   %esi
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 8e f3 ff ff       	call   800b7e <sys_page_unmap>
  8017f0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 7e f3 ff ff       	call   800b7e <sys_page_unmap>
  801800:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	ff 75 f4             	pushl  -0xc(%ebp)
  801809:	6a 00                	push   $0x0
  80180b:	e8 6e f3 ff ff       	call   800b7e <sys_page_unmap>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801815:	89 d0                	mov    %edx,%eax
  801817:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801827:	50                   	push   %eax
  801828:	ff 75 08             	pushl  0x8(%ebp)
  80182b:	e8 30 f5 ff ff       	call   800d60 <fd_lookup>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	78 18                	js     80184f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801837:	83 ec 0c             	sub    $0xc,%esp
  80183a:	ff 75 f4             	pushl  -0xc(%ebp)
  80183d:	e8 b8 f4 ff ff       	call   800cfa <fd2data>
	return _pipeisclosed(fd, p);
  801842:	89 c2                	mov    %eax,%edx
  801844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801847:	e8 21 fd ff ff       	call   80156d <_pipeisclosed>
  80184c:	83 c4 10             	add    $0x10,%esp
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801861:	68 0a 22 80 00       	push   $0x80220a
  801866:	ff 75 0c             	pushl  0xc(%ebp)
  801869:	e8 88 ee ff ff       	call   8006f6 <strcpy>
	return 0;
}
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	57                   	push   %edi
  801879:	56                   	push   %esi
  80187a:	53                   	push   %ebx
  80187b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801881:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801886:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188c:	eb 2d                	jmp    8018bb <devcons_write+0x46>
		m = n - tot;
  80188e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801891:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801893:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801896:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80189b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	53                   	push   %ebx
  8018a2:	03 45 0c             	add    0xc(%ebp),%eax
  8018a5:	50                   	push   %eax
  8018a6:	57                   	push   %edi
  8018a7:	e8 dc ef ff ff       	call   800888 <memmove>
		sys_cputs(buf, m);
  8018ac:	83 c4 08             	add    $0x8,%esp
  8018af:	53                   	push   %ebx
  8018b0:	57                   	push   %edi
  8018b1:	e8 87 f1 ff ff       	call   800a3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b6:	01 de                	add    %ebx,%esi
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	89 f0                	mov    %esi,%eax
  8018bd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018c0:	72 cc                	jb     80188e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5f                   	pop    %edi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018d9:	74 2a                	je     801905 <devcons_read+0x3b>
  8018db:	eb 05                	jmp    8018e2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018dd:	e8 f8 f1 ff ff       	call   800ada <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018e2:	e8 74 f1 ff ff       	call   800a5b <sys_cgetc>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	74 f2                	je     8018dd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 16                	js     801905 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018ef:	83 f8 04             	cmp    $0x4,%eax
  8018f2:	74 0c                	je     801900 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f7:	88 02                	mov    %al,(%edx)
	return 1;
  8018f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fe:	eb 05                	jmp    801905 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801900:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801913:	6a 01                	push   $0x1
  801915:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	e8 1f f1 ff ff       	call   800a3d <sys_cputs>
}
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <getchar>:

int
getchar(void)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801929:	6a 01                	push   $0x1
  80192b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80192e:	50                   	push   %eax
  80192f:	6a 00                	push   $0x0
  801931:	e8 90 f6 ff ff       	call   800fc6 <read>
	if (r < 0)
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 0f                	js     80194c <getchar+0x29>
		return r;
	if (r < 1)
  80193d:	85 c0                	test   %eax,%eax
  80193f:	7e 06                	jle    801947 <getchar+0x24>
		return -E_EOF;
	return c;
  801941:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801945:	eb 05                	jmp    80194c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801947:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	ff 75 08             	pushl  0x8(%ebp)
  80195b:	e8 00 f4 ff ff       	call   800d60 <fd_lookup>
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	78 11                	js     801978 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801970:	39 10                	cmp    %edx,(%eax)
  801972:	0f 94 c0             	sete   %al
  801975:	0f b6 c0             	movzbl %al,%eax
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <opencons>:

int
opencons(void)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801980:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801983:	50                   	push   %eax
  801984:	e8 88 f3 ff ff       	call   800d11 <fd_alloc>
  801989:	83 c4 10             	add    $0x10,%esp
		return r;
  80198c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 3e                	js     8019d0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801992:	83 ec 04             	sub    $0x4,%esp
  801995:	68 07 04 00 00       	push   $0x407
  80199a:	ff 75 f4             	pushl  -0xc(%ebp)
  80199d:	6a 00                	push   $0x0
  80199f:	e8 55 f1 ff ff       	call   800af9 <sys_page_alloc>
  8019a4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	78 23                	js     8019d0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019ad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	50                   	push   %eax
  8019c6:	e8 1f f3 ff ff       	call   800cea <fd2num>
  8019cb:	89 c2                	mov    %eax,%edx
  8019cd:	83 c4 10             	add    $0x10,%esp
}
  8019d0:	89 d0                	mov    %edx,%eax
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019d9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019dc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019e2:	e8 d4 f0 ff ff       	call   800abb <sys_getenvid>
  8019e7:	83 ec 0c             	sub    $0xc,%esp
  8019ea:	ff 75 0c             	pushl  0xc(%ebp)
  8019ed:	ff 75 08             	pushl  0x8(%ebp)
  8019f0:	56                   	push   %esi
  8019f1:	50                   	push   %eax
  8019f2:	68 18 22 80 00       	push   $0x802218
  8019f7:	e8 57 e7 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019fc:	83 c4 18             	add    $0x18,%esp
  8019ff:	53                   	push   %ebx
  801a00:	ff 75 10             	pushl  0x10(%ebp)
  801a03:	e8 fa e6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801a08:	c7 04 24 ec 1d 80 00 	movl   $0x801dec,(%esp)
  801a0f:	e8 3f e7 ff ff       	call   800153 <cprintf>
  801a14:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a17:	cc                   	int3   
  801a18:	eb fd                	jmp    801a17 <_panic+0x43>

00801a1a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a2f:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	50                   	push   %eax
  801a36:	e8 6e f2 ff ff       	call   800ca9 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	75 10                	jne    801a52 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a42:	a1 08 40 80 00       	mov    0x804008,%eax
  801a47:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a4a:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a4d:	8b 40 70             	mov    0x70(%eax),%eax
  801a50:	eb 0a                	jmp    801a5c <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a52:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a57:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a5c:	85 f6                	test   %esi,%esi
  801a5e:	74 02                	je     801a62 <ipc_recv+0x48>
  801a60:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a62:	85 db                	test   %ebx,%ebx
  801a64:	74 02                	je     801a68 <ipc_recv+0x4e>
  801a66:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801a68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	57                   	push   %edi
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a81:	85 db                	test   %ebx,%ebx
  801a83:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a88:	0f 44 d8             	cmove  %eax,%ebx
  801a8b:	eb 1c                	jmp    801aa9 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801a8d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a90:	74 12                	je     801aa4 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801a92:	50                   	push   %eax
  801a93:	68 3c 22 80 00       	push   $0x80223c
  801a98:	6a 40                	push   $0x40
  801a9a:	68 4e 22 80 00       	push   $0x80224e
  801a9f:	e8 30 ff ff ff       	call   8019d4 <_panic>
        sys_yield();
  801aa4:	e8 31 f0 ff ff       	call   800ada <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aa9:	ff 75 14             	pushl  0x14(%ebp)
  801aac:	53                   	push   %ebx
  801aad:	56                   	push   %esi
  801aae:	57                   	push   %edi
  801aaf:	e8 d2 f1 ff ff       	call   800c86 <sys_ipc_try_send>
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	75 d2                	jne    801a8d <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5f                   	pop    %edi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ace:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad7:	8b 52 50             	mov    0x50(%edx),%edx
  801ada:	39 ca                	cmp    %ecx,%edx
  801adc:	75 0d                	jne    801aeb <ipc_find_env+0x28>
			return envs[i].env_id;
  801ade:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae6:	8b 40 48             	mov    0x48(%eax),%eax
  801ae9:	eb 0f                	jmp    801afa <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aeb:	83 c0 01             	add    $0x1,%eax
  801aee:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af3:	75 d9                	jne    801ace <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b02:	89 d0                	mov    %edx,%eax
  801b04:	c1 e8 16             	shr    $0x16,%eax
  801b07:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b13:	f6 c1 01             	test   $0x1,%cl
  801b16:	74 1d                	je     801b35 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b18:	c1 ea 0c             	shr    $0xc,%edx
  801b1b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b22:	f6 c2 01             	test   $0x1,%dl
  801b25:	74 0e                	je     801b35 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b27:	c1 ea 0c             	shr    $0xc,%edx
  801b2a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b31:	ef 
  801b32:	0f b7 c0             	movzwl %ax,%eax
}
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    
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
