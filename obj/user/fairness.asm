
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 bc 0a 00 00       	call   800afc <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 cd 0c 00 00       	call   800d2b <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 20 1e 80 00       	push   $0x801e20
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 31 1e 80 00       	push   $0x801e31
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 e4 0c 00 00       	call   800d80 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 4b 0a 00 00       	call   800afc <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 e6 0e 00 00       	call   800fd8 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 bf 09 00 00       	call   800abb <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 4d 09 00 00       	call   800a7e <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 f2 08 00 00       	call   800a7e <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 84 19 00 00       	call   801b80 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 71 1a 00 00       	call   801cb0 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 a7 03 00 00    	je     80068e <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	eb 07                	jmp    80032b <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800327:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8d 47 01             	lea    0x1(%edi),%eax
  80032e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800331:	0f b6 07             	movzbl (%edi),%eax
  800334:	0f b6 d0             	movzbl %al,%edx
  800337:	83 e8 23             	sub    $0x23,%eax
  80033a:	3c 55                	cmp    $0x55,%al
  80033c:	0f 87 31 03 00 00    	ja     800673 <vprintfmt+0x3a8>
  800342:	0f b6 c0             	movzbl %al,%eax
  800345:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800353:	eb d6                	jmp    80032b <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	b8 00 00 00 00       	mov    $0x0,%eax
  80035d:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800360:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800363:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800367:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036a:	8d 72 d0             	lea    -0x30(%edx),%esi
  80036d:	83 fe 09             	cmp    $0x9,%esi
  800370:	77 34                	ja     8003a6 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800372:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800375:	eb e9                	jmp    800360 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8d 50 04             	lea    0x4(%eax),%edx
  80037d:	89 55 14             	mov    %edx,0x14(%ebp)
  800380:	8b 00                	mov    (%eax),%eax
  800382:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800388:	eb 22                	jmp    8003ac <vprintfmt+0xe1>
  80038a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038d:	85 c0                	test   %eax,%eax
  80038f:	0f 48 c1             	cmovs  %ecx,%eax
  800392:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	eb 91                	jmp    80032b <vprintfmt+0x60>
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a4:	eb 85                	jmp    80032b <vprintfmt+0x60>
  8003a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a9:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8003ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b0:	0f 89 75 ff ff ff    	jns    80032b <vprintfmt+0x60>
				width = precision, precision = -1;
  8003b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003c3:	e9 63 ff ff ff       	jmp    80032b <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cf:	e9 57 ff ff ff       	jmp    80032b <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	ff 30                	pushl  (%eax)
  8003e3:	ff d6                	call   *%esi
			break;
  8003e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003eb:	e9 01 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	99                   	cltd   
  8003fc:	31 d0                	xor    %edx,%eax
  8003fe:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800400:	83 f8 0f             	cmp    $0xf,%eax
  800403:	7f 0b                	jg     800410 <vprintfmt+0x145>
  800405:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  80040c:	85 d2                	test   %edx,%edx
  80040e:	75 18                	jne    800428 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	68 6a 1e 80 00       	push   $0x801e6a
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 91 fe ff ff       	call   8002ae <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 c9 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800428:	52                   	push   %edx
  800429:	68 4d 22 80 00       	push   $0x80224d
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 79 fe ff ff       	call   8002ae <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043b:	e9 b1 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044b:	85 ff                	test   %edi,%edi
  80044d:	b8 63 1e 80 00       	mov    $0x801e63,%eax
  800452:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	0f 8e 94 00 00 00    	jle    8004f3 <vprintfmt+0x228>
  80045f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800463:	0f 84 98 00 00 00    	je     800501 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	ff 75 cc             	pushl  -0x34(%ebp)
  80046f:	57                   	push   %edi
  800470:	e8 a1 02 00 00       	call   800716 <strnlen>
  800475:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800480:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800484:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800487:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	eb 0f                	jmp    80049d <vprintfmt+0x1d2>
					putch(padc, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	ff 75 e0             	pushl  -0x20(%ebp)
  800495:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	83 ef 01             	sub    $0x1,%edi
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	85 ff                	test   %edi,%edi
  80049f:	7f ed                	jg     80048e <vprintfmt+0x1c3>
  8004a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a7:	85 c9                	test   %ecx,%ecx
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	0f 49 c1             	cmovns %ecx,%eax
  8004b1:	29 c1                	sub    %eax,%ecx
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	89 cb                	mov    %ecx,%ebx
  8004be:	eb 4d                	jmp    80050d <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c4:	74 1b                	je     8004e1 <vprintfmt+0x216>
  8004c6:	0f be c0             	movsbl %al,%eax
  8004c9:	83 e8 20             	sub    $0x20,%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 10                	jbe    8004e1 <vprintfmt+0x216>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 0c             	pushl  0xc(%ebp)
  8004d7:	6a 3f                	push   $0x3f
  8004d9:	ff 55 08             	call   *0x8(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	eb 0d                	jmp    8004ee <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	52                   	push   %edx
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	83 eb 01             	sub    $0x1,%ebx
  8004f1:	eb 1a                	jmp    80050d <vprintfmt+0x242>
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ff:	eb 0c                	jmp    80050d <vprintfmt+0x242>
  800501:	89 75 08             	mov    %esi,0x8(%ebp)
  800504:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800507:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050d:	83 c7 01             	add    $0x1,%edi
  800510:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800514:	0f be d0             	movsbl %al,%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	74 23                	je     80053e <vprintfmt+0x273>
  80051b:	85 f6                	test   %esi,%esi
  80051d:	78 a1                	js     8004c0 <vprintfmt+0x1f5>
  80051f:	83 ee 01             	sub    $0x1,%esi
  800522:	79 9c                	jns    8004c0 <vprintfmt+0x1f5>
  800524:	89 df                	mov    %ebx,%edi
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	eb 18                	jmp    800546 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	53                   	push   %ebx
  800532:	6a 20                	push   $0x20
  800534:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800536:	83 ef 01             	sub    $0x1,%edi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb 08                	jmp    800546 <vprintfmt+0x27b>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	85 ff                	test   %edi,%edi
  800548:	7f e4                	jg     80052e <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054d:	e9 9f fd ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800552:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800556:	7e 16                	jle    80056e <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 08             	lea    0x8(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 50 04             	mov    0x4(%eax),%edx
  800564:	8b 00                	mov    (%eax),%eax
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056c:	eb 34                	jmp    8005a2 <vprintfmt+0x2d7>
	else if (lflag)
  80056e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800572:	74 18                	je     80058c <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 c1                	mov    %eax,%ecx
  800584:	c1 f9 1f             	sar    $0x1f,%ecx
  800587:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058a:	eb 16                	jmp    8005a2 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	89 c1                	mov    %eax,%ecx
  80059c:	c1 f9 1f             	sar    $0x1f,%ecx
  80059f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ad:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b1:	0f 89 88 00 00 00    	jns    80063f <vprintfmt+0x374>
				putch('-', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 2d                	push   $0x2d
  8005bd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c5:	f7 d8                	neg    %eax
  8005c7:	83 d2 00             	adc    $0x0,%edx
  8005ca:	f7 da                	neg    %edx
  8005cc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d4:	eb 69                	jmp    80063f <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	e8 76 fc ff ff       	call   800257 <getuint>
			base = 10;
  8005e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e6:	eb 57                	jmp    80063f <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 30                	push   $0x30
  8005ee:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8005f0:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 5c fc ff ff       	call   800257 <getuint>
			base = 8;
			goto number;
  8005fb:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005fe:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800603:	eb 3a                	jmp    80063f <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 30                	push   $0x30
  80060b:	ff d6                	call   *%esi
			putch('x', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 78                	push   $0x78
  800613:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800625:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800628:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062d:	eb 10                	jmp    80063f <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 1d fc ff ff       	call   800257 <getuint>
			base = 16;
  80063a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063f:	83 ec 0c             	sub    $0xc,%esp
  800642:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800646:	57                   	push   %edi
  800647:	ff 75 e0             	pushl  -0x20(%ebp)
  80064a:	51                   	push   %ecx
  80064b:	52                   	push   %edx
  80064c:	50                   	push   %eax
  80064d:	89 da                	mov    %ebx,%edx
  80064f:	89 f0                	mov    %esi,%eax
  800651:	e8 52 fb ff ff       	call   8001a8 <printnum>
			break;
  800656:	83 c4 20             	add    $0x20,%esp
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065c:	e9 90 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	52                   	push   %edx
  800666:	ff d6                	call   *%esi
			break;
  800668:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066e:	e9 7e fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 25                	push   $0x25
  800679:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	eb 03                	jmp    800683 <vprintfmt+0x3b8>
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800687:	75 f7                	jne    800680 <vprintfmt+0x3b5>
  800689:	e9 63 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800691:	5b                   	pop    %ebx
  800692:	5e                   	pop    %esi
  800693:	5f                   	pop    %edi
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	83 ec 18             	sub    $0x18,%esp
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	74 26                	je     8006dd <vsnprintf+0x47>
  8006b7:	85 d2                	test   %edx,%edx
  8006b9:	7e 22                	jle    8006dd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bb:	ff 75 14             	pushl  0x14(%ebp)
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c4:	50                   	push   %eax
  8006c5:	68 91 02 80 00       	push   $0x800291
  8006ca:	e8 fc fb ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	eb 05                	jmp    8006e2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ed:	50                   	push   %eax
  8006ee:	ff 75 10             	pushl  0x10(%ebp)
  8006f1:	ff 75 0c             	pushl  0xc(%ebp)
  8006f4:	ff 75 08             	pushl  0x8(%ebp)
  8006f7:	e8 9a ff ff ff       	call   800696 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	eb 03                	jmp    80070e <strlen+0x10>
		n++;
  80070b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800712:	75 f7                	jne    80070b <strlen+0xd>
		n++;
	return n;
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	ba 00 00 00 00       	mov    $0x0,%edx
  800724:	eb 03                	jmp    800729 <strnlen+0x13>
		n++;
  800726:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800729:	39 c2                	cmp    %eax,%edx
  80072b:	74 08                	je     800735 <strnlen+0x1f>
  80072d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800731:	75 f3                	jne    800726 <strnlen+0x10>
  800733:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	53                   	push   %ebx
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800741:	89 c2                	mov    %eax,%edx
  800743:	83 c2 01             	add    $0x1,%edx
  800746:	83 c1 01             	add    $0x1,%ecx
  800749:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800750:	84 db                	test   %bl,%bl
  800752:	75 ef                	jne    800743 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800754:	5b                   	pop    %ebx
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075e:	53                   	push   %ebx
  80075f:	e8 9a ff ff ff       	call   8006fe <strlen>
  800764:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800767:	ff 75 0c             	pushl  0xc(%ebp)
  80076a:	01 d8                	add    %ebx,%eax
  80076c:	50                   	push   %eax
  80076d:	e8 c5 ff ff ff       	call   800737 <strcpy>
	return dst;
}
  800772:	89 d8                	mov    %ebx,%eax
  800774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800777:	c9                   	leave  
  800778:	c3                   	ret    

00800779 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	56                   	push   %esi
  80077d:	53                   	push   %ebx
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800784:	89 f3                	mov    %esi,%ebx
  800786:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800789:	89 f2                	mov    %esi,%edx
  80078b:	eb 0f                	jmp    80079c <strncpy+0x23>
		*dst++ = *src;
  80078d:	83 c2 01             	add    $0x1,%edx
  800790:	0f b6 01             	movzbl (%ecx),%eax
  800793:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800796:	80 39 01             	cmpb   $0x1,(%ecx)
  800799:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079c:	39 da                	cmp    %ebx,%edx
  80079e:	75 ed                	jne    80078d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a0:	89 f0                	mov    %esi,%eax
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	56                   	push   %esi
  8007aa:	53                   	push   %ebx
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 21                	je     8007db <strlcpy+0x35>
  8007ba:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007be:	89 f2                	mov    %esi,%edx
  8007c0:	eb 09                	jmp    8007cb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cb:	39 c2                	cmp    %eax,%edx
  8007cd:	74 09                	je     8007d8 <strlcpy+0x32>
  8007cf:	0f b6 19             	movzbl (%ecx),%ebx
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ec                	jne    8007c2 <strlcpy+0x1c>
  8007d6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007db:	29 f0                	sub    %esi,%eax
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ea:	eb 06                	jmp    8007f2 <strcmp+0x11>
		p++, q++;
  8007ec:	83 c1 01             	add    $0x1,%ecx
  8007ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f2:	0f b6 01             	movzbl (%ecx),%eax
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 04                	je     8007fd <strcmp+0x1c>
  8007f9:	3a 02                	cmp    (%edx),%al
  8007fb:	74 ef                	je     8007ec <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 c0             	movzbl %al,%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 c3                	mov    %eax,%ebx
  800813:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800816:	eb 06                	jmp    80081e <strncmp+0x17>
		n--, p++, q++;
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081e:	39 d8                	cmp    %ebx,%eax
  800820:	74 15                	je     800837 <strncmp+0x30>
  800822:	0f b6 08             	movzbl (%eax),%ecx
  800825:	84 c9                	test   %cl,%cl
  800827:	74 04                	je     80082d <strncmp+0x26>
  800829:	3a 0a                	cmp    (%edx),%cl
  80082b:	74 eb                	je     800818 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082d:	0f b6 00             	movzbl (%eax),%eax
  800830:	0f b6 12             	movzbl (%edx),%edx
  800833:	29 d0                	sub    %edx,%eax
  800835:	eb 05                	jmp    80083c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800849:	eb 07                	jmp    800852 <strchr+0x13>
		if (*s == c)
  80084b:	38 ca                	cmp    %cl,%dl
  80084d:	74 0f                	je     80085e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	0f b6 10             	movzbl (%eax),%edx
  800855:	84 d2                	test   %dl,%dl
  800857:	75 f2                	jne    80084b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	eb 03                	jmp    80086f <strfind+0xf>
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800872:	38 ca                	cmp    %cl,%dl
  800874:	74 04                	je     80087a <strfind+0x1a>
  800876:	84 d2                	test   %dl,%dl
  800878:	75 f2                	jne    80086c <strfind+0xc>
			break;
	return (char *) s;
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
  800882:	8b 7d 08             	mov    0x8(%ebp),%edi
  800885:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800888:	85 c9                	test   %ecx,%ecx
  80088a:	74 36                	je     8008c2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800892:	75 28                	jne    8008bc <memset+0x40>
  800894:	f6 c1 03             	test   $0x3,%cl
  800897:	75 23                	jne    8008bc <memset+0x40>
		c &= 0xFF;
  800899:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089d:	89 d3                	mov    %edx,%ebx
  80089f:	c1 e3 08             	shl    $0x8,%ebx
  8008a2:	89 d6                	mov    %edx,%esi
  8008a4:	c1 e6 18             	shl    $0x18,%esi
  8008a7:	89 d0                	mov    %edx,%eax
  8008a9:	c1 e0 10             	shl    $0x10,%eax
  8008ac:	09 f0                	or     %esi,%eax
  8008ae:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b0:	89 d8                	mov    %ebx,%eax
  8008b2:	09 d0                	or     %edx,%eax
  8008b4:	c1 e9 02             	shr    $0x2,%ecx
  8008b7:	fc                   	cld    
  8008b8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ba:	eb 06                	jmp    8008c2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bf:	fc                   	cld    
  8008c0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c2:	89 f8                	mov    %edi,%eax
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5f                   	pop    %edi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	57                   	push   %edi
  8008cd:	56                   	push   %esi
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d7:	39 c6                	cmp    %eax,%esi
  8008d9:	73 35                	jae    800910 <memmove+0x47>
  8008db:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008de:	39 d0                	cmp    %edx,%eax
  8008e0:	73 2e                	jae    800910 <memmove+0x47>
		s += n;
		d += n;
  8008e2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e5:	89 d6                	mov    %edx,%esi
  8008e7:	09 fe                	or     %edi,%esi
  8008e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ef:	75 13                	jne    800904 <memmove+0x3b>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 0e                	jne    800904 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f6:	83 ef 04             	sub    $0x4,%edi
  8008f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fc:	c1 e9 02             	shr    $0x2,%ecx
  8008ff:	fd                   	std    
  800900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800902:	eb 09                	jmp    80090d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800904:	83 ef 01             	sub    $0x1,%edi
  800907:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090a:	fd                   	std    
  80090b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090d:	fc                   	cld    
  80090e:	eb 1d                	jmp    80092d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800910:	89 f2                	mov    %esi,%edx
  800912:	09 c2                	or     %eax,%edx
  800914:	f6 c2 03             	test   $0x3,%dl
  800917:	75 0f                	jne    800928 <memmove+0x5f>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0a                	jne    800928 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091e:	c1 e9 02             	shr    $0x2,%ecx
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800926:	eb 05                	jmp    80092d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800928:	89 c7                	mov    %eax,%edi
  80092a:	fc                   	cld    
  80092b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800934:	ff 75 10             	pushl  0x10(%ebp)
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	ff 75 08             	pushl  0x8(%ebp)
  80093d:	e8 87 ff ff ff       	call   8008c9 <memmove>
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094f:	89 c6                	mov    %eax,%esi
  800951:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800954:	eb 1a                	jmp    800970 <memcmp+0x2c>
		if (*s1 != *s2)
  800956:	0f b6 08             	movzbl (%eax),%ecx
  800959:	0f b6 1a             	movzbl (%edx),%ebx
  80095c:	38 d9                	cmp    %bl,%cl
  80095e:	74 0a                	je     80096a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800960:	0f b6 c1             	movzbl %cl,%eax
  800963:	0f b6 db             	movzbl %bl,%ebx
  800966:	29 d8                	sub    %ebx,%eax
  800968:	eb 0f                	jmp    800979 <memcmp+0x35>
		s1++, s2++;
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800970:	39 f0                	cmp    %esi,%eax
  800972:	75 e2                	jne    800956 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	53                   	push   %ebx
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800984:	89 c1                	mov    %eax,%ecx
  800986:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800989:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098d:	eb 0a                	jmp    800999 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098f:	0f b6 10             	movzbl (%eax),%edx
  800992:	39 da                	cmp    %ebx,%edx
  800994:	74 07                	je     80099d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	39 c8                	cmp    %ecx,%eax
  80099b:	72 f2                	jb     80098f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ac:	eb 03                	jmp    8009b1 <strtol+0x11>
		s++;
  8009ae:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	3c 20                	cmp    $0x20,%al
  8009b6:	74 f6                	je     8009ae <strtol+0xe>
  8009b8:	3c 09                	cmp    $0x9,%al
  8009ba:	74 f2                	je     8009ae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bc:	3c 2b                	cmp    $0x2b,%al
  8009be:	75 0a                	jne    8009ca <strtol+0x2a>
		s++;
  8009c0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c8:	eb 11                	jmp    8009db <strtol+0x3b>
  8009ca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cf:	3c 2d                	cmp    $0x2d,%al
  8009d1:	75 08                	jne    8009db <strtol+0x3b>
		s++, neg = 1;
  8009d3:	83 c1 01             	add    $0x1,%ecx
  8009d6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009db:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e1:	75 15                	jne    8009f8 <strtol+0x58>
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	75 10                	jne    8009f8 <strtol+0x58>
  8009e8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ec:	75 7c                	jne    800a6a <strtol+0xca>
		s += 2, base = 16;
  8009ee:	83 c1 02             	add    $0x2,%ecx
  8009f1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f6:	eb 16                	jmp    800a0e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	75 12                	jne    800a0e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a01:	80 39 30             	cmpb   $0x30,(%ecx)
  800a04:	75 08                	jne    800a0e <strtol+0x6e>
		s++, base = 8;
  800a06:	83 c1 01             	add    $0x1,%ecx
  800a09:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a16:	0f b6 11             	movzbl (%ecx),%edx
  800a19:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1c:	89 f3                	mov    %esi,%ebx
  800a1e:	80 fb 09             	cmp    $0x9,%bl
  800a21:	77 08                	ja     800a2b <strtol+0x8b>
			dig = *s - '0';
  800a23:	0f be d2             	movsbl %dl,%edx
  800a26:	83 ea 30             	sub    $0x30,%edx
  800a29:	eb 22                	jmp    800a4d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2e:	89 f3                	mov    %esi,%ebx
  800a30:	80 fb 19             	cmp    $0x19,%bl
  800a33:	77 08                	ja     800a3d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a35:	0f be d2             	movsbl %dl,%edx
  800a38:	83 ea 57             	sub    $0x57,%edx
  800a3b:	eb 10                	jmp    800a4d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a40:	89 f3                	mov    %esi,%ebx
  800a42:	80 fb 19             	cmp    $0x19,%bl
  800a45:	77 16                	ja     800a5d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a47:	0f be d2             	movsbl %dl,%edx
  800a4a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a50:	7d 0b                	jge    800a5d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a59:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5b:	eb b9                	jmp    800a16 <strtol+0x76>

	if (endptr)
  800a5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a61:	74 0d                	je     800a70 <strtol+0xd0>
		*endptr = (char *) s;
  800a63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a66:	89 0e                	mov    %ecx,(%esi)
  800a68:	eb 06                	jmp    800a70 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	74 98                	je     800a06 <strtol+0x66>
  800a6e:	eb 9e                	jmp    800a0e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a70:	89 c2                	mov    %eax,%edx
  800a72:	f7 da                	neg    %edx
  800a74:	85 ff                	test   %edi,%edi
  800a76:	0f 45 c2             	cmovne %edx,%eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
  800a89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	89 c6                	mov    %eax,%esi
  800a95:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	b8 01 00 00 00       	mov    $0x1,%eax
  800aac:	89 d1                	mov    %edx,%ecx
  800aae:	89 d3                	mov    %edx,%ebx
  800ab0:	89 d7                	mov    %edx,%edi
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac9:	b8 03 00 00 00       	mov    $0x3,%eax
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	89 cb                	mov    %ecx,%ebx
  800ad3:	89 cf                	mov    %ecx,%edi
  800ad5:	89 ce                	mov    %ecx,%esi
  800ad7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	7e 17                	jle    800af4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800add:	83 ec 0c             	sub    $0xc,%esp
  800ae0:	50                   	push   %eax
  800ae1:	6a 03                	push   $0x3
  800ae3:	68 5f 21 80 00       	push   $0x80215f
  800ae8:	6a 23                	push   $0x23
  800aea:	68 7c 21 80 00       	push   $0x80217c
  800aef:	e8 03 10 00 00       	call   801af7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_yield>:

void
sys_yield(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b43:	be 00 00 00 00       	mov    $0x0,%esi
  800b48:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b56:	89 f7                	mov    %esi,%edi
  800b58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7e 17                	jle    800b75 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	50                   	push   %eax
  800b62:	6a 04                	push   $0x4
  800b64:	68 5f 21 80 00       	push   $0x80215f
  800b69:	6a 23                	push   $0x23
  800b6b:	68 7c 21 80 00       	push   $0x80217c
  800b70:	e8 82 0f 00 00       	call   801af7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b97:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 05                	push   $0x5
  800ba6:	68 5f 21 80 00       	push   $0x80215f
  800bab:	6a 23                	push   $0x23
  800bad:	68 7c 21 80 00       	push   $0x80217c
  800bb2:	e8 40 0f 00 00       	call   801af7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcd:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	89 df                	mov    %ebx,%edi
  800bda:	89 de                	mov    %ebx,%esi
  800bdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 06                	push   $0x6
  800be8:	68 5f 21 80 00       	push   $0x80215f
  800bed:	6a 23                	push   $0x23
  800bef:	68 7c 21 80 00       	push   $0x80217c
  800bf4:	e8 fe 0e 00 00       	call   801af7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 08                	push   $0x8
  800c2a:	68 5f 21 80 00       	push   $0x80215f
  800c2f:	6a 23                	push   $0x23
  800c31:	68 7c 21 80 00       	push   $0x80217c
  800c36:	e8 bc 0e 00 00       	call   801af7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 09 00 00 00       	mov    $0x9,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 09                	push   $0x9
  800c6c:	68 5f 21 80 00       	push   $0x80215f
  800c71:	6a 23                	push   $0x23
  800c73:	68 7c 21 80 00       	push   $0x80217c
  800c78:	e8 7a 0e 00 00       	call   801af7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 0a                	push   $0xa
  800cae:	68 5f 21 80 00       	push   $0x80215f
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 7c 21 80 00       	push   $0x80217c
  800cba:	e8 38 0e 00 00       	call   801af7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	be 00 00 00 00       	mov    $0x0,%esi
  800cd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 cb                	mov    %ecx,%ebx
  800d02:	89 cf                	mov    %ecx,%edi
  800d04:	89 ce                	mov    %ecx,%esi
  800d06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 0d                	push   $0xd
  800d12:	68 5f 21 80 00       	push   $0x80215f
  800d17:	6a 23                	push   $0x23
  800d19:	68 7c 21 80 00       	push   $0x80217c
  800d1e:	e8 d4 0d 00 00       	call   801af7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	8b 75 08             	mov    0x8(%ebp),%esi
  800d33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800d40:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	e8 9e ff ff ff       	call   800cea <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	75 10                	jne    800d63 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  800d53:	a1 04 40 80 00       	mov    0x804004,%eax
  800d58:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  800d5b:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  800d5e:	8b 40 70             	mov    0x70(%eax),%eax
  800d61:	eb 0a                	jmp    800d6d <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  800d63:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  800d6d:	85 f6                	test   %esi,%esi
  800d6f:	74 02                	je     800d73 <ipc_recv+0x48>
  800d71:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	74 02                	je     800d79 <ipc_recv+0x4e>
  800d77:	89 13                	mov    %edx,(%ebx)

    return r;
}
  800d79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  800d92:	85 db                	test   %ebx,%ebx
  800d94:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800d99:	0f 44 d8             	cmove  %eax,%ebx
  800d9c:	eb 1c                	jmp    800dba <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  800d9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800da1:	74 12                	je     800db5 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  800da3:	50                   	push   %eax
  800da4:	68 8a 21 80 00       	push   $0x80218a
  800da9:	6a 40                	push   $0x40
  800dab:	68 9c 21 80 00       	push   $0x80219c
  800db0:	e8 42 0d 00 00       	call   801af7 <_panic>
        sys_yield();
  800db5:	e8 61 fd ff ff       	call   800b1b <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  800dba:	ff 75 14             	pushl  0x14(%ebp)
  800dbd:	53                   	push   %ebx
  800dbe:	56                   	push   %esi
  800dbf:	57                   	push   %edi
  800dc0:	e8 02 ff ff ff       	call   800cc7 <sys_ipc_try_send>
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	75 d2                	jne    800d9e <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ddf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800de2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800de8:	8b 52 50             	mov    0x50(%edx),%edx
  800deb:	39 ca                	cmp    %ecx,%edx
  800ded:	75 0d                	jne    800dfc <ipc_find_env+0x28>
			return envs[i].env_id;
  800def:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800df2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800df7:	8b 40 48             	mov    0x48(%eax),%eax
  800dfa:	eb 0f                	jmp    800e0b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dfc:	83 c0 01             	add    $0x1,%eax
  800dff:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e04:	75 d9                	jne    800ddf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	05 00 00 00 30       	add    $0x30000000,%eax
  800e18:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	05 00 00 00 30       	add    $0x30000000,%eax
  800e28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	c1 ea 16             	shr    $0x16,%edx
  800e44:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4b:	f6 c2 01             	test   $0x1,%dl
  800e4e:	74 11                	je     800e61 <fd_alloc+0x2d>
  800e50:	89 c2                	mov    %eax,%edx
  800e52:	c1 ea 0c             	shr    $0xc,%edx
  800e55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5c:	f6 c2 01             	test   $0x1,%dl
  800e5f:	75 09                	jne    800e6a <fd_alloc+0x36>
			*fd_store = fd;
  800e61:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e63:	b8 00 00 00 00       	mov    $0x0,%eax
  800e68:	eb 17                	jmp    800e81 <fd_alloc+0x4d>
  800e6a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e6f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e74:	75 c9                	jne    800e3f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e76:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e7c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e89:	83 f8 1f             	cmp    $0x1f,%eax
  800e8c:	77 36                	ja     800ec4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8e:	c1 e0 0c             	shl    $0xc,%eax
  800e91:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	c1 ea 16             	shr    $0x16,%edx
  800e9b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	74 24                	je     800ecb <fd_lookup+0x48>
  800ea7:	89 c2                	mov    %eax,%edx
  800ea9:	c1 ea 0c             	shr    $0xc,%edx
  800eac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb3:	f6 c2 01             	test   $0x1,%dl
  800eb6:	74 1a                	je     800ed2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebb:	89 02                	mov    %eax,(%edx)
	return 0;
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec2:	eb 13                	jmp    800ed7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec9:	eb 0c                	jmp    800ed7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ecb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed0:	eb 05                	jmp    800ed7 <fd_lookup+0x54>
  800ed2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee2:	ba 24 22 80 00       	mov    $0x802224,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee7:	eb 13                	jmp    800efc <dev_lookup+0x23>
  800ee9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eec:	39 08                	cmp    %ecx,(%eax)
  800eee:	75 0c                	jne    800efc <dev_lookup+0x23>
			*dev = devtab[i];
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	eb 2e                	jmp    800f2a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efc:	8b 02                	mov    (%edx),%eax
  800efe:	85 c0                	test   %eax,%eax
  800f00:	75 e7                	jne    800ee9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f02:	a1 04 40 80 00       	mov    0x804004,%eax
  800f07:	8b 40 48             	mov    0x48(%eax),%eax
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	51                   	push   %ecx
  800f0e:	50                   	push   %eax
  800f0f:	68 a8 21 80 00       	push   $0x8021a8
  800f14:	e8 7b f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	83 ec 10             	sub    $0x10,%esp
  800f34:	8b 75 08             	mov    0x8(%ebp),%esi
  800f37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3d:	50                   	push   %eax
  800f3e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f44:	c1 e8 0c             	shr    $0xc,%eax
  800f47:	50                   	push   %eax
  800f48:	e8 36 ff ff ff       	call   800e83 <fd_lookup>
  800f4d:	83 c4 08             	add    $0x8,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 05                	js     800f59 <fd_close+0x2d>
	    || fd != fd2)
  800f54:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f57:	74 0c                	je     800f65 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f59:	84 db                	test   %bl,%bl
  800f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f60:	0f 44 c2             	cmove  %edx,%eax
  800f63:	eb 41                	jmp    800fa6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f65:	83 ec 08             	sub    $0x8,%esp
  800f68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6b:	50                   	push   %eax
  800f6c:	ff 36                	pushl  (%esi)
  800f6e:	e8 66 ff ff ff       	call   800ed9 <dev_lookup>
  800f73:	89 c3                	mov    %eax,%ebx
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 1a                	js     800f96 <fd_close+0x6a>
		if (dev->dev_close)
  800f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f82:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	74 0b                	je     800f96 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	56                   	push   %esi
  800f8f:	ff d0                	call   *%eax
  800f91:	89 c3                	mov    %eax,%ebx
  800f93:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	56                   	push   %esi
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 1e fc ff ff       	call   800bbf <sys_page_unmap>
	return r;
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	89 d8                	mov    %ebx,%eax
}
  800fa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	ff 75 08             	pushl  0x8(%ebp)
  800fba:	e8 c4 fe ff ff       	call   800e83 <fd_lookup>
  800fbf:	83 c4 08             	add    $0x8,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 10                	js     800fd6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	6a 01                	push   $0x1
  800fcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fce:	e8 59 ff ff ff       	call   800f2c <fd_close>
  800fd3:	83 c4 10             	add    $0x10,%esp
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <close_all>:

void
close_all(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	53                   	push   %ebx
  800fdc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	53                   	push   %ebx
  800fe8:	e8 c0 ff ff ff       	call   800fad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fed:	83 c3 01             	add    $0x1,%ebx
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	83 fb 20             	cmp    $0x20,%ebx
  800ff6:	75 ec                	jne    800fe4 <close_all+0xc>
		close(i);
}
  800ff8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 2c             	sub    $0x2c,%esp
  801006:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801009:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80100c:	50                   	push   %eax
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	e8 6e fe ff ff       	call   800e83 <fd_lookup>
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	0f 88 c1 00 00 00    	js     8010e1 <dup+0xe4>
		return r;
	close(newfdnum);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	56                   	push   %esi
  801024:	e8 84 ff ff ff       	call   800fad <close>

	newfd = INDEX2FD(newfdnum);
  801029:	89 f3                	mov    %esi,%ebx
  80102b:	c1 e3 0c             	shl    $0xc,%ebx
  80102e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801034:	83 c4 04             	add    $0x4,%esp
  801037:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103a:	e8 de fd ff ff       	call   800e1d <fd2data>
  80103f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801041:	89 1c 24             	mov    %ebx,(%esp)
  801044:	e8 d4 fd ff ff       	call   800e1d <fd2data>
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104f:	89 f8                	mov    %edi,%eax
  801051:	c1 e8 16             	shr    $0x16,%eax
  801054:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105b:	a8 01                	test   $0x1,%al
  80105d:	74 37                	je     801096 <dup+0x99>
  80105f:	89 f8                	mov    %edi,%eax
  801061:	c1 e8 0c             	shr    $0xc,%eax
  801064:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106b:	f6 c2 01             	test   $0x1,%dl
  80106e:	74 26                	je     801096 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801070:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	25 07 0e 00 00       	and    $0xe07,%eax
  80107f:	50                   	push   %eax
  801080:	ff 75 d4             	pushl  -0x2c(%ebp)
  801083:	6a 00                	push   $0x0
  801085:	57                   	push   %edi
  801086:	6a 00                	push   $0x0
  801088:	e8 f0 fa ff ff       	call   800b7d <sys_page_map>
  80108d:	89 c7                	mov    %eax,%edi
  80108f:	83 c4 20             	add    $0x20,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 2e                	js     8010c4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801096:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801099:	89 d0                	mov    %edx,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
  80109e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ad:	50                   	push   %eax
  8010ae:	53                   	push   %ebx
  8010af:	6a 00                	push   $0x0
  8010b1:	52                   	push   %edx
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 c4 fa ff ff       	call   800b7d <sys_page_map>
  8010b9:	89 c7                	mov    %eax,%edi
  8010bb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010be:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c0:	85 ff                	test   %edi,%edi
  8010c2:	79 1d                	jns    8010e1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	53                   	push   %ebx
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 f0 fa ff ff       	call   800bbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 e3 fa ff ff       	call   800bbf <sys_page_unmap>
	return r;
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	89 f8                	mov    %edi,%eax
}
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 14             	sub    $0x14,%esp
  8010f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	53                   	push   %ebx
  8010f8:	e8 86 fd ff ff       	call   800e83 <fd_lookup>
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	89 c2                	mov    %eax,%edx
  801102:	85 c0                	test   %eax,%eax
  801104:	78 6d                	js     801173 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801106:	83 ec 08             	sub    $0x8,%esp
  801109:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801110:	ff 30                	pushl  (%eax)
  801112:	e8 c2 fd ff ff       	call   800ed9 <dev_lookup>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 4c                	js     80116a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801121:	8b 42 08             	mov    0x8(%edx),%eax
  801124:	83 e0 03             	and    $0x3,%eax
  801127:	83 f8 01             	cmp    $0x1,%eax
  80112a:	75 21                	jne    80114d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112c:	a1 04 40 80 00       	mov    0x804004,%eax
  801131:	8b 40 48             	mov    0x48(%eax),%eax
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	53                   	push   %ebx
  801138:	50                   	push   %eax
  801139:	68 e9 21 80 00       	push   $0x8021e9
  80113e:	e8 51 f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114b:	eb 26                	jmp    801173 <read+0x8a>
	}
	if (!dev->dev_read)
  80114d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801150:	8b 40 08             	mov    0x8(%eax),%eax
  801153:	85 c0                	test   %eax,%eax
  801155:	74 17                	je     80116e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	ff 75 10             	pushl  0x10(%ebp)
  80115d:	ff 75 0c             	pushl  0xc(%ebp)
  801160:	52                   	push   %edx
  801161:	ff d0                	call   *%eax
  801163:	89 c2                	mov    %eax,%edx
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	eb 09                	jmp    801173 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	eb 05                	jmp    801173 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801173:	89 d0                	mov    %edx,%eax
  801175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	8b 7d 08             	mov    0x8(%ebp),%edi
  801186:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118e:	eb 21                	jmp    8011b1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	89 f0                	mov    %esi,%eax
  801195:	29 d8                	sub    %ebx,%eax
  801197:	50                   	push   %eax
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	03 45 0c             	add    0xc(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	57                   	push   %edi
  80119f:	e8 45 ff ff ff       	call   8010e9 <read>
		if (m < 0)
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 10                	js     8011bb <readn+0x41>
			return m;
		if (m == 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 0a                	je     8011b9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011af:	01 c3                	add    %eax,%ebx
  8011b1:	39 f3                	cmp    %esi,%ebx
  8011b3:	72 db                	jb     801190 <readn+0x16>
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	eb 02                	jmp    8011bb <readn+0x41>
  8011b9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5f                   	pop    %edi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 14             	sub    $0x14,%esp
  8011ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	53                   	push   %ebx
  8011d2:	e8 ac fc ff ff       	call   800e83 <fd_lookup>
  8011d7:	83 c4 08             	add    $0x8,%esp
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 68                	js     801248 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e0:	83 ec 08             	sub    $0x8,%esp
  8011e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	ff 30                	pushl  (%eax)
  8011ec:	e8 e8 fc ff ff       	call   800ed9 <dev_lookup>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 47                	js     80123f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ff:	75 21                	jne    801222 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801201:	a1 04 40 80 00       	mov    0x804004,%eax
  801206:	8b 40 48             	mov    0x48(%eax),%eax
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	53                   	push   %ebx
  80120d:	50                   	push   %eax
  80120e:	68 05 22 80 00       	push   $0x802205
  801213:	e8 7c ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801220:	eb 26                	jmp    801248 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801222:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801225:	8b 52 0c             	mov    0xc(%edx),%edx
  801228:	85 d2                	test   %edx,%edx
  80122a:	74 17                	je     801243 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	ff 75 10             	pushl  0x10(%ebp)
  801232:	ff 75 0c             	pushl  0xc(%ebp)
  801235:	50                   	push   %eax
  801236:	ff d2                	call   *%edx
  801238:	89 c2                	mov    %eax,%edx
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	eb 09                	jmp    801248 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123f:	89 c2                	mov    %eax,%edx
  801241:	eb 05                	jmp    801248 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801243:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801248:	89 d0                	mov    %edx,%eax
  80124a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <seek>:

int
seek(int fdnum, off_t offset)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801255:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 22 fc ff ff       	call   800e83 <fd_lookup>
  801261:	83 c4 08             	add    $0x8,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 0e                	js     801276 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801268:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 14             	sub    $0x14,%esp
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	53                   	push   %ebx
  801287:	e8 f7 fb ff ff       	call   800e83 <fd_lookup>
  80128c:	83 c4 08             	add    $0x8,%esp
  80128f:	89 c2                	mov    %eax,%edx
  801291:	85 c0                	test   %eax,%eax
  801293:	78 65                	js     8012fa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801295:	83 ec 08             	sub    $0x8,%esp
  801298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129f:	ff 30                	pushl  (%eax)
  8012a1:	e8 33 fc ff ff       	call   800ed9 <dev_lookup>
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 44                	js     8012f1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b4:	75 21                	jne    8012d7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bb:	8b 40 48             	mov    0x48(%eax),%eax
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	53                   	push   %ebx
  8012c2:	50                   	push   %eax
  8012c3:	68 c8 21 80 00       	push   $0x8021c8
  8012c8:	e8 c7 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d5:	eb 23                	jmp    8012fa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012da:	8b 52 18             	mov    0x18(%edx),%edx
  8012dd:	85 d2                	test   %edx,%edx
  8012df:	74 14                	je     8012f5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	ff 75 0c             	pushl  0xc(%ebp)
  8012e7:	50                   	push   %eax
  8012e8:	ff d2                	call   *%edx
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	eb 09                	jmp    8012fa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	eb 05                	jmp    8012fa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012fa:	89 d0                	mov    %edx,%eax
  8012fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    

00801301 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	53                   	push   %ebx
  801305:	83 ec 14             	sub    $0x14,%esp
  801308:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	ff 75 08             	pushl  0x8(%ebp)
  801312:	e8 6c fb ff ff       	call   800e83 <fd_lookup>
  801317:	83 c4 08             	add    $0x8,%esp
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 58                	js     801378 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132a:	ff 30                	pushl  (%eax)
  80132c:	e8 a8 fb ff ff       	call   800ed9 <dev_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 37                	js     80136f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801338:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133f:	74 32                	je     801373 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801341:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801344:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134b:	00 00 00 
	stat->st_isdir = 0;
  80134e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801355:	00 00 00 
	stat->st_dev = dev;
  801358:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	53                   	push   %ebx
  801362:	ff 75 f0             	pushl  -0x10(%ebp)
  801365:	ff 50 14             	call   *0x14(%eax)
  801368:	89 c2                	mov    %eax,%edx
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	eb 09                	jmp    801378 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136f:	89 c2                	mov    %eax,%edx
  801371:	eb 05                	jmp    801378 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801373:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801378:	89 d0                	mov    %edx,%eax
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	6a 00                	push   $0x0
  801389:	ff 75 08             	pushl  0x8(%ebp)
  80138c:	e8 e3 01 00 00       	call   801574 <open>
  801391:	89 c3                	mov    %eax,%ebx
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 1b                	js     8013b5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	ff 75 0c             	pushl  0xc(%ebp)
  8013a0:	50                   	push   %eax
  8013a1:	e8 5b ff ff ff       	call   801301 <fstat>
  8013a6:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a8:	89 1c 24             	mov    %ebx,(%esp)
  8013ab:	e8 fd fb ff ff       	call   800fad <close>
	return r;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	89 f0                	mov    %esi,%eax
}
  8013b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	89 c6                	mov    %eax,%esi
  8013c3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013cc:	75 12                	jne    8013e0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	6a 01                	push   $0x1
  8013d3:	e8 fc f9 ff ff       	call   800dd4 <ipc_find_env>
  8013d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013dd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e0:	6a 07                	push   $0x7
  8013e2:	68 00 50 80 00       	push   $0x805000
  8013e7:	56                   	push   %esi
  8013e8:	ff 35 00 40 80 00    	pushl  0x804000
  8013ee:	e8 8d f9 ff ff       	call   800d80 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f3:	83 c4 0c             	add    $0xc,%esp
  8013f6:	6a 00                	push   $0x0
  8013f8:	53                   	push   %ebx
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 2b f9 ff ff       	call   800d2b <ipc_recv>
}
  801400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	8b 40 0c             	mov    0xc(%eax),%eax
  801413:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801418:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801420:	ba 00 00 00 00       	mov    $0x0,%edx
  801425:	b8 02 00 00 00       	mov    $0x2,%eax
  80142a:	e8 8d ff ff ff       	call   8013bc <fsipc>
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801437:	8b 45 08             	mov    0x8(%ebp),%eax
  80143a:	8b 40 0c             	mov    0xc(%eax),%eax
  80143d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	b8 06 00 00 00       	mov    $0x6,%eax
  80144c:	e8 6b ff ff ff       	call   8013bc <fsipc>
}
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	8b 40 0c             	mov    0xc(%eax),%eax
  801463:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	b8 05 00 00 00       	mov    $0x5,%eax
  801472:	e8 45 ff ff ff       	call   8013bc <fsipc>
  801477:	85 c0                	test   %eax,%eax
  801479:	78 2c                	js     8014a7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	68 00 50 80 00       	push   $0x805000
  801483:	53                   	push   %ebx
  801484:	e8 ae f2 ff ff       	call   800737 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801489:	a1 80 50 80 00       	mov    0x805080,%eax
  80148e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801494:	a1 84 50 80 00       	mov    0x805084,%eax
  801499:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bb:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8014c1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c6:	ba 00 10 00 00       	mov    $0x1000,%edx
  8014cb:	0f 47 c2             	cmova  %edx,%eax
  8014ce:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	68 08 50 80 00       	push   $0x805008
  8014dc:	e8 e8 f3 ff ff       	call   8008c9 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014eb:	e8 cc fe ff ff       	call   8013bc <fsipc>
    return r;
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	56                   	push   %esi
  8014f6:	53                   	push   %ebx
  8014f7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801500:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801505:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150b:	ba 00 00 00 00       	mov    $0x0,%edx
  801510:	b8 03 00 00 00       	mov    $0x3,%eax
  801515:	e8 a2 fe ff ff       	call   8013bc <fsipc>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 4b                	js     80156b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801520:	39 c6                	cmp    %eax,%esi
  801522:	73 16                	jae    80153a <devfile_read+0x48>
  801524:	68 34 22 80 00       	push   $0x802234
  801529:	68 3b 22 80 00       	push   $0x80223b
  80152e:	6a 7c                	push   $0x7c
  801530:	68 50 22 80 00       	push   $0x802250
  801535:	e8 bd 05 00 00       	call   801af7 <_panic>
	assert(r <= PGSIZE);
  80153a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80153f:	7e 16                	jle    801557 <devfile_read+0x65>
  801541:	68 5b 22 80 00       	push   $0x80225b
  801546:	68 3b 22 80 00       	push   $0x80223b
  80154b:	6a 7d                	push   $0x7d
  80154d:	68 50 22 80 00       	push   $0x802250
  801552:	e8 a0 05 00 00       	call   801af7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	50                   	push   %eax
  80155b:	68 00 50 80 00       	push   $0x805000
  801560:	ff 75 0c             	pushl  0xc(%ebp)
  801563:	e8 61 f3 ff ff       	call   8008c9 <memmove>
	return r;
  801568:	83 c4 10             	add    $0x10,%esp
}
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801570:	5b                   	pop    %ebx
  801571:	5e                   	pop    %esi
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 20             	sub    $0x20,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80157e:	53                   	push   %ebx
  80157f:	e8 7a f1 ff ff       	call   8006fe <strlen>
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80158c:	7f 67                	jg     8015f5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	e8 9a f8 ff ff       	call   800e34 <fd_alloc>
  80159a:	83 c4 10             	add    $0x10,%esp
		return r;
  80159d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 57                	js     8015fa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	68 00 50 80 00       	push   $0x805000
  8015ac:	e8 86 f1 ff ff       	call   800737 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c1:	e8 f6 fd ff ff       	call   8013bc <fsipc>
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	79 14                	jns    8015e3 <open+0x6f>
		fd_close(fd, 0);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	6a 00                	push   $0x0
  8015d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d7:	e8 50 f9 ff ff       	call   800f2c <fd_close>
		return r;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	89 da                	mov    %ebx,%edx
  8015e1:	eb 17                	jmp    8015fa <open+0x86>
	}

	return fd2num(fd);
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e9:	e8 1f f8 ff ff       	call   800e0d <fd2num>
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb 05                	jmp    8015fa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015fa:	89 d0                	mov    %edx,%eax
  8015fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801607:	ba 00 00 00 00       	mov    $0x0,%edx
  80160c:	b8 08 00 00 00       	mov    $0x8,%eax
  801611:	e8 a6 fd ff ff       	call   8013bc <fsipc>
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	ff 75 08             	pushl  0x8(%ebp)
  801626:	e8 f2 f7 ff ff       	call   800e1d <fd2data>
  80162b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80162d:	83 c4 08             	add    $0x8,%esp
  801630:	68 67 22 80 00       	push   $0x802267
  801635:	53                   	push   %ebx
  801636:	e8 fc f0 ff ff       	call   800737 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80163b:	8b 46 04             	mov    0x4(%esi),%eax
  80163e:	2b 06                	sub    (%esi),%eax
  801640:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801646:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164d:	00 00 00 
	stat->st_dev = &devpipe;
  801650:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801657:	30 80 00 
	return 0;
}
  80165a:	b8 00 00 00 00       	mov    $0x0,%eax
  80165f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801662:	5b                   	pop    %ebx
  801663:	5e                   	pop    %esi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801670:	53                   	push   %ebx
  801671:	6a 00                	push   $0x0
  801673:	e8 47 f5 ff ff       	call   800bbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801678:	89 1c 24             	mov    %ebx,(%esp)
  80167b:	e8 9d f7 ff ff       	call   800e1d <fd2data>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	50                   	push   %eax
  801684:	6a 00                	push   $0x0
  801686:	e8 34 f5 ff ff       	call   800bbf <sys_page_unmap>
}
  80168b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 1c             	sub    $0x1c,%esp
  801699:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80169c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80169e:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016a6:	83 ec 0c             	sub    $0xc,%esp
  8016a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ac:	e8 8c 04 00 00       	call   801b3d <pageref>
  8016b1:	89 c3                	mov    %eax,%ebx
  8016b3:	89 3c 24             	mov    %edi,(%esp)
  8016b6:	e8 82 04 00 00       	call   801b3d <pageref>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	39 c3                	cmp    %eax,%ebx
  8016c0:	0f 94 c1             	sete   %cl
  8016c3:	0f b6 c9             	movzbl %cl,%ecx
  8016c6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016c9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016cf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016d2:	39 ce                	cmp    %ecx,%esi
  8016d4:	74 1b                	je     8016f1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016d6:	39 c3                	cmp    %eax,%ebx
  8016d8:	75 c4                	jne    80169e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016da:	8b 42 58             	mov    0x58(%edx),%eax
  8016dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e0:	50                   	push   %eax
  8016e1:	56                   	push   %esi
  8016e2:	68 6e 22 80 00       	push   $0x80226e
  8016e7:	e8 a8 ea ff ff       	call   800194 <cprintf>
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	eb ad                	jmp    80169e <_pipeisclosed+0xe>
	}
}
  8016f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	57                   	push   %edi
  801700:	56                   	push   %esi
  801701:	53                   	push   %ebx
  801702:	83 ec 28             	sub    $0x28,%esp
  801705:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801708:	56                   	push   %esi
  801709:	e8 0f f7 ff ff       	call   800e1d <fd2data>
  80170e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	bf 00 00 00 00       	mov    $0x0,%edi
  801718:	eb 4b                	jmp    801765 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80171a:	89 da                	mov    %ebx,%edx
  80171c:	89 f0                	mov    %esi,%eax
  80171e:	e8 6d ff ff ff       	call   801690 <_pipeisclosed>
  801723:	85 c0                	test   %eax,%eax
  801725:	75 48                	jne    80176f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801727:	e8 ef f3 ff ff       	call   800b1b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80172c:	8b 43 04             	mov    0x4(%ebx),%eax
  80172f:	8b 0b                	mov    (%ebx),%ecx
  801731:	8d 51 20             	lea    0x20(%ecx),%edx
  801734:	39 d0                	cmp    %edx,%eax
  801736:	73 e2                	jae    80171a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80173f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801742:	89 c2                	mov    %eax,%edx
  801744:	c1 fa 1f             	sar    $0x1f,%edx
  801747:	89 d1                	mov    %edx,%ecx
  801749:	c1 e9 1b             	shr    $0x1b,%ecx
  80174c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80174f:	83 e2 1f             	and    $0x1f,%edx
  801752:	29 ca                	sub    %ecx,%edx
  801754:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801758:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80175c:	83 c0 01             	add    $0x1,%eax
  80175f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801762:	83 c7 01             	add    $0x1,%edi
  801765:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801768:	75 c2                	jne    80172c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80176a:	8b 45 10             	mov    0x10(%ebp),%eax
  80176d:	eb 05                	jmp    801774 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80176f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801774:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	5f                   	pop    %edi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	57                   	push   %edi
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	83 ec 18             	sub    $0x18,%esp
  801785:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801788:	57                   	push   %edi
  801789:	e8 8f f6 ff ff       	call   800e1d <fd2data>
  80178e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	bb 00 00 00 00       	mov    $0x0,%ebx
  801798:	eb 3d                	jmp    8017d7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80179a:	85 db                	test   %ebx,%ebx
  80179c:	74 04                	je     8017a2 <devpipe_read+0x26>
				return i;
  80179e:	89 d8                	mov    %ebx,%eax
  8017a0:	eb 44                	jmp    8017e6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017a2:	89 f2                	mov    %esi,%edx
  8017a4:	89 f8                	mov    %edi,%eax
  8017a6:	e8 e5 fe ff ff       	call   801690 <_pipeisclosed>
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	75 32                	jne    8017e1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017af:	e8 67 f3 ff ff       	call   800b1b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017b4:	8b 06                	mov    (%esi),%eax
  8017b6:	3b 46 04             	cmp    0x4(%esi),%eax
  8017b9:	74 df                	je     80179a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017bb:	99                   	cltd   
  8017bc:	c1 ea 1b             	shr    $0x1b,%edx
  8017bf:	01 d0                	add    %edx,%eax
  8017c1:	83 e0 1f             	and    $0x1f,%eax
  8017c4:	29 d0                	sub    %edx,%eax
  8017c6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ce:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017d1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d4:	83 c3 01             	add    $0x1,%ebx
  8017d7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017da:	75 d8                	jne    8017b4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8017df:	eb 05                	jmp    8017e6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017e1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5f                   	pop    %edi
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f9:	50                   	push   %eax
  8017fa:	e8 35 f6 ff ff       	call   800e34 <fd_alloc>
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	89 c2                	mov    %eax,%edx
  801804:	85 c0                	test   %eax,%eax
  801806:	0f 88 2c 01 00 00    	js     801938 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	68 07 04 00 00       	push   $0x407
  801814:	ff 75 f4             	pushl  -0xc(%ebp)
  801817:	6a 00                	push   $0x0
  801819:	e8 1c f3 ff ff       	call   800b3a <sys_page_alloc>
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	89 c2                	mov    %eax,%edx
  801823:	85 c0                	test   %eax,%eax
  801825:	0f 88 0d 01 00 00    	js     801938 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	e8 fd f5 ff ff       	call   800e34 <fd_alloc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	0f 88 e2 00 00 00    	js     801926 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	68 07 04 00 00       	push   $0x407
  80184c:	ff 75 f0             	pushl  -0x10(%ebp)
  80184f:	6a 00                	push   $0x0
  801851:	e8 e4 f2 ff ff       	call   800b3a <sys_page_alloc>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	0f 88 c3 00 00 00    	js     801926 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801863:	83 ec 0c             	sub    $0xc,%esp
  801866:	ff 75 f4             	pushl  -0xc(%ebp)
  801869:	e8 af f5 ff ff       	call   800e1d <fd2data>
  80186e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801870:	83 c4 0c             	add    $0xc,%esp
  801873:	68 07 04 00 00       	push   $0x407
  801878:	50                   	push   %eax
  801879:	6a 00                	push   $0x0
  80187b:	e8 ba f2 ff ff       	call   800b3a <sys_page_alloc>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 89 00 00 00    	js     801916 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	ff 75 f0             	pushl  -0x10(%ebp)
  801893:	e8 85 f5 ff ff       	call   800e1d <fd2data>
  801898:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80189f:	50                   	push   %eax
  8018a0:	6a 00                	push   $0x0
  8018a2:	56                   	push   %esi
  8018a3:	6a 00                	push   $0x0
  8018a5:	e8 d3 f2 ff ff       	call   800b7d <sys_page_map>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	83 c4 20             	add    $0x20,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 55                	js     801908 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018b3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018c8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e3:	e8 25 f5 ff ff       	call   800e0d <fd2num>
  8018e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018eb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018ed:	83 c4 04             	add    $0x4,%esp
  8018f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f3:	e8 15 f5 ff ff       	call   800e0d <fd2num>
  8018f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018fb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	eb 30                	jmp    801938 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	56                   	push   %esi
  80190c:	6a 00                	push   $0x0
  80190e:	e8 ac f2 ff ff       	call   800bbf <sys_page_unmap>
  801913:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 f0             	pushl  -0x10(%ebp)
  80191c:	6a 00                	push   $0x0
  80191e:	e8 9c f2 ff ff       	call   800bbf <sys_page_unmap>
  801923:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	6a 00                	push   $0x0
  80192e:	e8 8c f2 ff ff       	call   800bbf <sys_page_unmap>
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801938:	89 d0                	mov    %edx,%eax
  80193a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	50                   	push   %eax
  80194b:	ff 75 08             	pushl  0x8(%ebp)
  80194e:	e8 30 f5 ff ff       	call   800e83 <fd_lookup>
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	78 18                	js     801972 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	e8 b8 f4 ff ff       	call   800e1d <fd2data>
	return _pipeisclosed(fd, p);
  801965:	89 c2                	mov    %eax,%edx
  801967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196a:	e8 21 fd ff ff       	call   801690 <_pipeisclosed>
  80196f:	83 c4 10             	add    $0x10,%esp
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801984:	68 86 22 80 00       	push   $0x802286
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	e8 a6 ed ff ff       	call   800737 <strcpy>
	return 0;
}
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	57                   	push   %edi
  80199c:	56                   	push   %esi
  80199d:	53                   	push   %ebx
  80199e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019af:	eb 2d                	jmp    8019de <devcons_write+0x46>
		m = n - tot;
  8019b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019b4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019b6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019b9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019be:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	53                   	push   %ebx
  8019c5:	03 45 0c             	add    0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	57                   	push   %edi
  8019ca:	e8 fa ee ff ff       	call   8008c9 <memmove>
		sys_cputs(buf, m);
  8019cf:	83 c4 08             	add    $0x8,%esp
  8019d2:	53                   	push   %ebx
  8019d3:	57                   	push   %edi
  8019d4:	e8 a5 f0 ff ff       	call   800a7e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d9:	01 de                	add    %ebx,%esi
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	89 f0                	mov    %esi,%eax
  8019e0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e3:	72 cc                	jb     8019b1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5f                   	pop    %edi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 08             	sub    $0x8,%esp
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fc:	74 2a                	je     801a28 <devcons_read+0x3b>
  8019fe:	eb 05                	jmp    801a05 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a00:	e8 16 f1 ff ff       	call   800b1b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a05:	e8 92 f0 ff ff       	call   800a9c <sys_cgetc>
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	74 f2                	je     801a00 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 16                	js     801a28 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a12:	83 f8 04             	cmp    $0x4,%eax
  801a15:	74 0c                	je     801a23 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1a:	88 02                	mov    %al,(%edx)
	return 1;
  801a1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a21:	eb 05                	jmp    801a28 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a36:	6a 01                	push   $0x1
  801a38:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a3b:	50                   	push   %eax
  801a3c:	e8 3d f0 ff ff       	call   800a7e <sys_cputs>
}
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <getchar>:

int
getchar(void)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a4c:	6a 01                	push   $0x1
  801a4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a51:	50                   	push   %eax
  801a52:	6a 00                	push   $0x0
  801a54:	e8 90 f6 ff ff       	call   8010e9 <read>
	if (r < 0)
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 0f                	js     801a6f <getchar+0x29>
		return r;
	if (r < 1)
  801a60:	85 c0                	test   %eax,%eax
  801a62:	7e 06                	jle    801a6a <getchar+0x24>
		return -E_EOF;
	return c;
  801a64:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a68:	eb 05                	jmp    801a6f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a6a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	ff 75 08             	pushl  0x8(%ebp)
  801a7e:	e8 00 f4 ff ff       	call   800e83 <fd_lookup>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 11                	js     801a9b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a93:	39 10                	cmp    %edx,(%eax)
  801a95:	0f 94 c0             	sete   %al
  801a98:	0f b6 c0             	movzbl %al,%eax
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <opencons>:

int
opencons(void)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa6:	50                   	push   %eax
  801aa7:	e8 88 f3 ff ff       	call   800e34 <fd_alloc>
  801aac:	83 c4 10             	add    $0x10,%esp
		return r;
  801aaf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 3e                	js     801af3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab5:	83 ec 04             	sub    $0x4,%esp
  801ab8:	68 07 04 00 00       	push   $0x407
  801abd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 73 f0 ff ff       	call   800b3a <sys_page_alloc>
  801ac7:	83 c4 10             	add    $0x10,%esp
		return r;
  801aca:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 23                	js     801af3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ad0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	50                   	push   %eax
  801ae9:	e8 1f f3 ff ff       	call   800e0d <fd2num>
  801aee:	89 c2                	mov    %eax,%edx
  801af0:	83 c4 10             	add    $0x10,%esp
}
  801af3:	89 d0                	mov    %edx,%eax
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801afc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b05:	e8 f2 ef ff ff       	call   800afc <sys_getenvid>
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	ff 75 0c             	pushl  0xc(%ebp)
  801b10:	ff 75 08             	pushl  0x8(%ebp)
  801b13:	56                   	push   %esi
  801b14:	50                   	push   %eax
  801b15:	68 94 22 80 00       	push   $0x802294
  801b1a:	e8 75 e6 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b1f:	83 c4 18             	add    $0x18,%esp
  801b22:	53                   	push   %ebx
  801b23:	ff 75 10             	pushl  0x10(%ebp)
  801b26:	e8 18 e6 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801b2b:	c7 04 24 7f 22 80 00 	movl   $0x80227f,(%esp)
  801b32:	e8 5d e6 ff ff       	call   800194 <cprintf>
  801b37:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b3a:	cc                   	int3   
  801b3b:	eb fd                	jmp    801b3a <_panic+0x43>

00801b3d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b43:	89 d0                	mov    %edx,%eax
  801b45:	c1 e8 16             	shr    $0x16,%eax
  801b48:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b54:	f6 c1 01             	test   $0x1,%cl
  801b57:	74 1d                	je     801b76 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b59:	c1 ea 0c             	shr    $0xc,%edx
  801b5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b63:	f6 c2 01             	test   $0x1,%dl
  801b66:	74 0e                	je     801b76 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b68:	c1 ea 0c             	shr    $0xc,%edx
  801b6b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b72:	ef 
  801b73:	0f b7 c0             	movzwl %ax,%eax
}
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    
  801b78:	66 90                	xchg   %ax,%ax
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b97:	85 f6                	test   %esi,%esi
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 ca                	mov    %ecx,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	75 3d                	jne    801be0 <__udivdi3+0x60>
  801ba3:	39 cf                	cmp    %ecx,%edi
  801ba5:	0f 87 c5 00 00 00    	ja     801c70 <__udivdi3+0xf0>
  801bab:	85 ff                	test   %edi,%edi
  801bad:	89 fd                	mov    %edi,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f7                	div    %edi
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	89 cf                	mov    %ecx,%edi
  801bc8:	f7 f5                	div    %ebp
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 ce                	cmp    %ecx,%esi
  801be2:	77 74                	ja     801c58 <__udivdi3+0xd8>
  801be4:	0f bd fe             	bsr    %esi,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0x108>
  801bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	89 c5                	mov    %eax,%ebp
  801bf9:	29 fb                	sub    %edi,%ebx
  801bfb:	d3 e6                	shl    %cl,%esi
  801bfd:	89 d9                	mov    %ebx,%ecx
  801bff:	d3 ed                	shr    %cl,%ebp
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	09 ee                	or     %ebp,%esi
  801c07:	89 d9                	mov    %ebx,%ecx
  801c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0d:	89 d5                	mov    %edx,%ebp
  801c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c13:	d3 ed                	shr    %cl,%ebp
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e2                	shl    %cl,%edx
  801c19:	89 d9                	mov    %ebx,%ecx
  801c1b:	d3 e8                	shr    %cl,%eax
  801c1d:	09 c2                	or     %eax,%edx
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	89 ea                	mov    %ebp,%edx
  801c23:	f7 f6                	div    %esi
  801c25:	89 d5                	mov    %edx,%ebp
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	f7 64 24 0c          	mull   0xc(%esp)
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	72 10                	jb     801c41 <__udivdi3+0xc1>
  801c31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e6                	shl    %cl,%esi
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 07                	jae    801c44 <__udivdi3+0xc4>
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	75 03                	jne    801c44 <__udivdi3+0xc4>
  801c41:	83 eb 01             	sub    $0x1,%ebx
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 db                	xor    %ebx,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	f7 f7                	div    %edi
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0c                	jb     801c98 <__udivdi3+0x118>
  801c8c:	31 db                	xor    %ebx,%ebx
  801c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c92:	0f 87 34 ff ff ff    	ja     801bcc <__udivdi3+0x4c>
  801c98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c9d:	e9 2a ff ff ff       	jmp    801bcc <__udivdi3+0x4c>
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 d2                	test   %edx,%edx
  801cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f3                	mov    %esi,%ebx
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	75 1c                	jne    801cf8 <__umoddi3+0x48>
  801cdc:	39 f7                	cmp    %esi,%edi
  801cde:	76 50                	jbe    801d30 <__umoddi3+0x80>
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	77 52                	ja     801d50 <__umoddi3+0xa0>
  801cfe:	0f bd ea             	bsr    %edx,%ebp
  801d01:	83 f5 1f             	xor    $0x1f,%ebp
  801d04:	75 5a                	jne    801d60 <__umoddi3+0xb0>
  801d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	39 0c 24             	cmp    %ecx,(%esp)
  801d13:	0f 86 d7 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	85 ff                	test   %edi,%edi
  801d32:	89 fd                	mov    %edi,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 c8                	mov    %ecx,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	eb 99                	jmp    801ce8 <__umoddi3+0x38>
  801d4f:	90                   	nop
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	83 c4 1c             	add    $0x1c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	8b 34 24             	mov    (%esp),%esi
  801d63:	bf 20 00 00 00       	mov    $0x20,%edi
  801d68:	89 e9                	mov    %ebp,%ecx
  801d6a:	29 ef                	sub    %ebp,%edi
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 f9                	mov    %edi,%ecx
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	d3 ea                	shr    %cl,%edx
  801d74:	89 e9                	mov    %ebp,%ecx
  801d76:	09 c2                	or     %eax,%edx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 14 24             	mov    %edx,(%esp)
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 f9                	mov    %edi,%ecx
  801d83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	89 c6                	mov    %eax,%esi
  801d91:	d3 e3                	shl    %cl,%ebx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	09 d8                	or     %ebx,%eax
  801d9d:	89 d3                	mov    %edx,%ebx
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	f7 34 24             	divl   (%esp)
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	d3 e3                	shl    %cl,%ebx
  801da8:	f7 64 24 04          	mull   0x4(%esp)
  801dac:	39 d6                	cmp    %edx,%esi
  801dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	72 08                	jb     801dc0 <__umoddi3+0x110>
  801db8:	75 11                	jne    801dcb <__umoddi3+0x11b>
  801dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dbe:	73 0b                	jae    801dcb <__umoddi3+0x11b>
  801dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dc4:	1b 14 24             	sbb    (%esp),%edx
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dcf:	29 da                	sub    %ebx,%edx
  801dd1:	19 ce                	sbb    %ecx,%esi
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	d3 e0                	shl    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	d3 ee                	shr    %cl,%esi
  801de1:	09 d0                	or     %edx,%eax
  801de3:	89 f2                	mov    %esi,%edx
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 f9                	sub    %edi,%ecx
  801df2:	19 d6                	sbb    %edx,%esi
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dfc:	e9 18 ff ff ff       	jmp    801d19 <__umoddi3+0x69>
