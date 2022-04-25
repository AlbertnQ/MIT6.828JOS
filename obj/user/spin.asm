
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 c0 21 80 00       	push   $0x8021c0
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 ca 0e 00 00       	call   800f13 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 22 80 00       	push   $0x802238
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 21 80 00       	push   $0x8021e8
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 b9 0a 00 00       	call   800b2f <sys_yield>
	sys_yield();
  800076:	e8 b4 0a 00 00       	call   800b2f <sys_yield>
	sys_yield();
  80007b:	e8 af 0a 00 00       	call   800b2f <sys_yield>
	sys_yield();
  800080:	e8 aa 0a 00 00       	call   800b2f <sys_yield>
	sys_yield();
  800085:	e8 a5 0a 00 00       	call   800b2f <sys_yield>
	sys_yield();
  80008a:	e8 a0 0a 00 00       	call   800b2f <sys_yield>
	sys_yield();
  80008f:	e8 9b 0a 00 00       	call   800b2f <sys_yield>
	sys_yield();
  800094:	e8 96 0a 00 00       	call   800b2f <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 22 80 00 	movl   $0x802210,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 22 0a 00 00       	call   800acf <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 4b 0a 00 00       	call   800b10 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 14 11 00 00       	call   80121a <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 bf 09 00 00       	call   800acf <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 4d 09 00 00       	call   800a92 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 54 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 f2 08 00 00       	call   800a92 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 20 1d 00 00       	call   801f30 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 0d 1e 00 00       	call   802060 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	ff 75 0c             	pushl  0xc(%ebp)
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 2c             	sub    $0x2c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 a7 03 00 00    	je     8006a2 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e2                	jne    8002f3 <vprintfmt+0x14>
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800331:	b9 00 00 00 00       	mov    $0x0,%ecx
  800336:	eb 07                	jmp    80033f <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8d 47 01             	lea    0x1(%edi),%eax
  800342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800345:	0f b6 07             	movzbl (%edi),%eax
  800348:	0f b6 d0             	movzbl %al,%edx
  80034b:	83 e8 23             	sub    $0x23,%eax
  80034e:	3c 55                	cmp    $0x55,%al
  800350:	0f 87 31 03 00 00    	ja     800687 <vprintfmt+0x3a8>
  800356:	0f b6 c0             	movzbl %al,%eax
  800359:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800363:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800367:	eb d6                	jmp    80033f <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036c:	b8 00 00 00 00       	mov    $0x0,%eax
  800371:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800374:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800377:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80037b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800381:	83 fe 09             	cmp    $0x9,%esi
  800384:	77 34                	ja     8003ba <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800386:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800389:	eb e9                	jmp    800374 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 50 04             	lea    0x4(%eax),%edx
  800391:	89 55 14             	mov    %edx,0x14(%ebp)
  800394:	8b 00                	mov    (%eax),%eax
  800396:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039c:	eb 22                	jmp    8003c0 <vprintfmt+0xe1>
  80039e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	0f 48 c1             	cmovs  %ecx,%eax
  8003a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ac:	eb 91                	jmp    80033f <vprintfmt+0x60>
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b8:	eb 85                	jmp    80033f <vprintfmt+0x60>
  8003ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003bd:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8003c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c4:	0f 89 75 ff ff ff    	jns    80033f <vprintfmt+0x60>
				width = precision, precision = -1;
  8003ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003d7:	e9 63 ff ff ff       	jmp    80033f <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003dc:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e3:	e9 57 ff ff ff       	jmp    80033f <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	53                   	push   %ebx
  8003f5:	ff 30                	pushl  (%eax)
  8003f7:	ff d6                	call   *%esi
			break;
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ff:	e9 01 ff ff ff       	jmp    800305 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	99                   	cltd   
  800410:	31 d0                	xor    %edx,%eax
  800412:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800414:	83 f8 0f             	cmp    $0xf,%eax
  800417:	7f 0b                	jg     800424 <vprintfmt+0x145>
  800419:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800420:	85 d2                	test   %edx,%edx
  800422:	75 18                	jne    80043c <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800424:	50                   	push   %eax
  800425:	68 78 22 80 00       	push   $0x802278
  80042a:	53                   	push   %ebx
  80042b:	56                   	push   %esi
  80042c:	e8 91 fe ff ff       	call   8002c2 <printfmt>
  800431:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800437:	e9 c9 fe ff ff       	jmp    800305 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80043c:	52                   	push   %edx
  80043d:	68 59 27 80 00       	push   $0x802759
  800442:	53                   	push   %ebx
  800443:	56                   	push   %esi
  800444:	e8 79 fe ff ff       	call   8002c2 <printfmt>
  800449:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044f:	e9 b1 fe ff ff       	jmp    800305 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045f:	85 ff                	test   %edi,%edi
  800461:	b8 71 22 80 00       	mov    $0x802271,%eax
  800466:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800469:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046d:	0f 8e 94 00 00 00    	jle    800507 <vprintfmt+0x228>
  800473:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800477:	0f 84 98 00 00 00    	je     800515 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	ff 75 cc             	pushl  -0x34(%ebp)
  800483:	57                   	push   %edi
  800484:	e8 a1 02 00 00       	call   80072a <strnlen>
  800489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048c:	29 c1                	sub    %eax,%ecx
  80048e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800494:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	eb 0f                	jmp    8004b1 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	83 ef 01             	sub    $0x1,%edi
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 ff                	test   %edi,%edi
  8004b3:	7f ed                	jg     8004a2 <vprintfmt+0x1c3>
  8004b5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004bb:	85 c9                	test   %ecx,%ecx
  8004bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c2:	0f 49 c1             	cmovns %ecx,%eax
  8004c5:	29 c1                	sub    %eax,%ecx
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	89 cb                	mov    %ecx,%ebx
  8004d2:	eb 4d                	jmp    800521 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d8:	74 1b                	je     8004f5 <vprintfmt+0x216>
  8004da:	0f be c0             	movsbl %al,%eax
  8004dd:	83 e8 20             	sub    $0x20,%eax
  8004e0:	83 f8 5e             	cmp    $0x5e,%eax
  8004e3:	76 10                	jbe    8004f5 <vprintfmt+0x216>
					putch('?', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	6a 3f                	push   $0x3f
  8004ed:	ff 55 08             	call   *0x8(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 0d                	jmp    800502 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	52                   	push   %edx
  8004fc:	ff 55 08             	call   *0x8(%ebp)
  8004ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	83 eb 01             	sub    $0x1,%ebx
  800505:	eb 1a                	jmp    800521 <vprintfmt+0x242>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	eb 0c                	jmp    800521 <vprintfmt+0x242>
  800515:	89 75 08             	mov    %esi,0x8(%ebp)
  800518:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80051b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800521:	83 c7 01             	add    $0x1,%edi
  800524:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800528:	0f be d0             	movsbl %al,%edx
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 23                	je     800552 <vprintfmt+0x273>
  80052f:	85 f6                	test   %esi,%esi
  800531:	78 a1                	js     8004d4 <vprintfmt+0x1f5>
  800533:	83 ee 01             	sub    $0x1,%esi
  800536:	79 9c                	jns    8004d4 <vprintfmt+0x1f5>
  800538:	89 df                	mov    %ebx,%edi
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800540:	eb 18                	jmp    80055a <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 20                	push   $0x20
  800548:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb 08                	jmp    80055a <vprintfmt+0x27b>
  800552:	89 df                	mov    %ebx,%edi
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	85 ff                	test   %edi,%edi
  80055c:	7f e4                	jg     800542 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800561:	e9 9f fd ff ff       	jmp    800305 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800566:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80056a:	7e 16                	jle    800582 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 08             	lea    0x8(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	8b 50 04             	mov    0x4(%eax),%edx
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800580:	eb 34                	jmp    8005b6 <vprintfmt+0x2d7>
	else if (lflag)
  800582:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800586:	74 18                	je     8005a0 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	89 c1                	mov    %eax,%ecx
  800598:	c1 f9 1f             	sar    $0x1f,%ecx
  80059b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059e:	eb 16                	jmp    8005b6 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 c1                	mov    %eax,%ecx
  8005b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c5:	0f 89 88 00 00 00    	jns    800653 <vprintfmt+0x374>
				putch('-', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 2d                	push   $0x2d
  8005d1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d9:	f7 d8                	neg    %eax
  8005db:	83 d2 00             	adc    $0x0,%edx
  8005de:	f7 da                	neg    %edx
  8005e0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e8:	eb 69                	jmp    800653 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ea:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f0:	e8 76 fc ff ff       	call   80026b <getuint>
			base = 10;
  8005f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fa:	eb 57                	jmp    800653 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 30                	push   $0x30
  800602:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800604:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 5c fc ff ff       	call   80026b <getuint>
			base = 8;
			goto number;
  80060f:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800612:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800617:	eb 3a                	jmp    800653 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 30                	push   $0x30
  80061f:	ff d6                	call   *%esi
			putch('x', putdat);
  800621:	83 c4 08             	add    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 78                	push   $0x78
  800627:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800632:	8b 00                	mov    (%eax),%eax
  800634:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800639:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800641:	eb 10                	jmp    800653 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800643:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 1d fc ff ff       	call   80026b <getuint>
			base = 16;
  80064e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80065a:	57                   	push   %edi
  80065b:	ff 75 e0             	pushl  -0x20(%ebp)
  80065e:	51                   	push   %ecx
  80065f:	52                   	push   %edx
  800660:	50                   	push   %eax
  800661:	89 da                	mov    %ebx,%edx
  800663:	89 f0                	mov    %esi,%eax
  800665:	e8 52 fb ff ff       	call   8001bc <printnum>
			break;
  80066a:	83 c4 20             	add    $0x20,%esp
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800670:	e9 90 fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	52                   	push   %edx
  80067a:	ff d6                	call   *%esi
			break;
  80067c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800682:	e9 7e fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 25                	push   $0x25
  80068d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	eb 03                	jmp    800697 <vprintfmt+0x3b8>
  800694:	83 ef 01             	sub    $0x1,%edi
  800697:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80069b:	75 f7                	jne    800694 <vprintfmt+0x3b5>
  80069d:	e9 63 fc ff ff       	jmp    800305 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a5:	5b                   	pop    %ebx
  8006a6:	5e                   	pop    %esi
  8006a7:	5f                   	pop    %edi
  8006a8:	5d                   	pop    %ebp
  8006a9:	c3                   	ret    

008006aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 18             	sub    $0x18,%esp
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	74 26                	je     8006f1 <vsnprintf+0x47>
  8006cb:	85 d2                	test   %edx,%edx
  8006cd:	7e 22                	jle    8006f1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cf:	ff 75 14             	pushl  0x14(%ebp)
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d8:	50                   	push   %eax
  8006d9:	68 a5 02 80 00       	push   $0x8002a5
  8006de:	e8 fc fb ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 05                	jmp    8006f6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800701:	50                   	push   %eax
  800702:	ff 75 10             	pushl  0x10(%ebp)
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	ff 75 08             	pushl  0x8(%ebp)
  80070b:	e8 9a ff ff ff       	call   8006aa <vsnprintf>
	va_end(ap);

	return rc;
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	eb 03                	jmp    800722 <strlen+0x10>
		n++;
  80071f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800726:	75 f7                	jne    80071f <strlen+0xd>
		n++;
	return n;
}
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800730:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	ba 00 00 00 00       	mov    $0x0,%edx
  800738:	eb 03                	jmp    80073d <strnlen+0x13>
		n++;
  80073a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073d:	39 c2                	cmp    %eax,%edx
  80073f:	74 08                	je     800749 <strnlen+0x1f>
  800741:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800745:	75 f3                	jne    80073a <strnlen+0x10>
  800747:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800755:	89 c2                	mov    %eax,%edx
  800757:	83 c2 01             	add    $0x1,%edx
  80075a:	83 c1 01             	add    $0x1,%ecx
  80075d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800761:	88 5a ff             	mov    %bl,-0x1(%edx)
  800764:	84 db                	test   %bl,%bl
  800766:	75 ef                	jne    800757 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800768:	5b                   	pop    %ebx
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800772:	53                   	push   %ebx
  800773:	e8 9a ff ff ff       	call   800712 <strlen>
  800778:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80077b:	ff 75 0c             	pushl  0xc(%ebp)
  80077e:	01 d8                	add    %ebx,%eax
  800780:	50                   	push   %eax
  800781:	e8 c5 ff ff ff       	call   80074b <strcpy>
	return dst;
}
  800786:	89 d8                	mov    %ebx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	56                   	push   %esi
  800791:	53                   	push   %ebx
  800792:	8b 75 08             	mov    0x8(%ebp),%esi
  800795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800798:	89 f3                	mov    %esi,%ebx
  80079a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	89 f2                	mov    %esi,%edx
  80079f:	eb 0f                	jmp    8007b0 <strncpy+0x23>
		*dst++ = *src;
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	0f b6 01             	movzbl (%ecx),%eax
  8007a7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007aa:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ad:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b0:	39 da                	cmp    %ebx,%edx
  8007b2:	75 ed                	jne    8007a1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	74 21                	je     8007ef <strlcpy+0x35>
  8007ce:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 09                	jmp    8007df <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	83 c1 01             	add    $0x1,%ecx
  8007dc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007df:	39 c2                	cmp    %eax,%edx
  8007e1:	74 09                	je     8007ec <strlcpy+0x32>
  8007e3:	0f b6 19             	movzbl (%ecx),%ebx
  8007e6:	84 db                	test   %bl,%bl
  8007e8:	75 ec                	jne    8007d6 <strlcpy+0x1c>
  8007ea:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ec:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ef:	29 f0                	sub    %esi,%eax
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5e                   	pop    %esi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007fe:	eb 06                	jmp    800806 <strcmp+0x11>
		p++, q++;
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800806:	0f b6 01             	movzbl (%ecx),%eax
  800809:	84 c0                	test   %al,%al
  80080b:	74 04                	je     800811 <strcmp+0x1c>
  80080d:	3a 02                	cmp    (%edx),%al
  80080f:	74 ef                	je     800800 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800811:	0f b6 c0             	movzbl %al,%eax
  800814:	0f b6 12             	movzbl (%edx),%edx
  800817:	29 d0                	sub    %edx,%eax
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	89 c3                	mov    %eax,%ebx
  800827:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082a:	eb 06                	jmp    800832 <strncmp+0x17>
		n--, p++, q++;
  80082c:	83 c0 01             	add    $0x1,%eax
  80082f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800832:	39 d8                	cmp    %ebx,%eax
  800834:	74 15                	je     80084b <strncmp+0x30>
  800836:	0f b6 08             	movzbl (%eax),%ecx
  800839:	84 c9                	test   %cl,%cl
  80083b:	74 04                	je     800841 <strncmp+0x26>
  80083d:	3a 0a                	cmp    (%edx),%cl
  80083f:	74 eb                	je     80082c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 00             	movzbl (%eax),%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
  800849:	eb 05                	jmp    800850 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800850:	5b                   	pop    %ebx
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085d:	eb 07                	jmp    800866 <strchr+0x13>
		if (*s == c)
  80085f:	38 ca                	cmp    %cl,%dl
  800861:	74 0f                	je     800872 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	0f b6 10             	movzbl (%eax),%edx
  800869:	84 d2                	test   %dl,%dl
  80086b:	75 f2                	jne    80085f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087e:	eb 03                	jmp    800883 <strfind+0xf>
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800886:	38 ca                	cmp    %cl,%dl
  800888:	74 04                	je     80088e <strfind+0x1a>
  80088a:	84 d2                	test   %dl,%dl
  80088c:	75 f2                	jne    800880 <strfind+0xc>
			break;
	return (char *) s;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	57                   	push   %edi
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 7d 08             	mov    0x8(%ebp),%edi
  800899:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	74 36                	je     8008d6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a6:	75 28                	jne    8008d0 <memset+0x40>
  8008a8:	f6 c1 03             	test   $0x3,%cl
  8008ab:	75 23                	jne    8008d0 <memset+0x40>
		c &= 0xFF;
  8008ad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b1:	89 d3                	mov    %edx,%ebx
  8008b3:	c1 e3 08             	shl    $0x8,%ebx
  8008b6:	89 d6                	mov    %edx,%esi
  8008b8:	c1 e6 18             	shl    $0x18,%esi
  8008bb:	89 d0                	mov    %edx,%eax
  8008bd:	c1 e0 10             	shl    $0x10,%eax
  8008c0:	09 f0                	or     %esi,%eax
  8008c2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008c4:	89 d8                	mov    %ebx,%eax
  8008c6:	09 d0                	or     %edx,%eax
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
  8008cb:	fc                   	cld    
  8008cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ce:	eb 06                	jmp    8008d6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d3:	fc                   	cld    
  8008d4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d6:	89 f8                	mov    %edi,%eax
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008eb:	39 c6                	cmp    %eax,%esi
  8008ed:	73 35                	jae    800924 <memmove+0x47>
  8008ef:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f2:	39 d0                	cmp    %edx,%eax
  8008f4:	73 2e                	jae    800924 <memmove+0x47>
		s += n;
		d += n;
  8008f6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f9:	89 d6                	mov    %edx,%esi
  8008fb:	09 fe                	or     %edi,%esi
  8008fd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800903:	75 13                	jne    800918 <memmove+0x3b>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0e                	jne    800918 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80090a:	83 ef 04             	sub    $0x4,%edi
  80090d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800910:	c1 e9 02             	shr    $0x2,%ecx
  800913:	fd                   	std    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 09                	jmp    800921 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800918:	83 ef 01             	sub    $0x1,%edi
  80091b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80091e:	fd                   	std    
  80091f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800921:	fc                   	cld    
  800922:	eb 1d                	jmp    800941 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	89 f2                	mov    %esi,%edx
  800926:	09 c2                	or     %eax,%edx
  800928:	f6 c2 03             	test   $0x3,%dl
  80092b:	75 0f                	jne    80093c <memmove+0x5f>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0a                	jne    80093c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	89 c7                	mov    %eax,%edi
  800937:	fc                   	cld    
  800938:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093a:	eb 05                	jmp    800941 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093c:	89 c7                	mov    %eax,%edi
  80093e:	fc                   	cld    
  80093f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800941:	5e                   	pop    %esi
  800942:	5f                   	pop    %edi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800948:	ff 75 10             	pushl  0x10(%ebp)
  80094b:	ff 75 0c             	pushl  0xc(%ebp)
  80094e:	ff 75 08             	pushl  0x8(%ebp)
  800951:	e8 87 ff ff ff       	call   8008dd <memmove>
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
  800963:	89 c6                	mov    %eax,%esi
  800965:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800968:	eb 1a                	jmp    800984 <memcmp+0x2c>
		if (*s1 != *s2)
  80096a:	0f b6 08             	movzbl (%eax),%ecx
  80096d:	0f b6 1a             	movzbl (%edx),%ebx
  800970:	38 d9                	cmp    %bl,%cl
  800972:	74 0a                	je     80097e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800974:	0f b6 c1             	movzbl %cl,%eax
  800977:	0f b6 db             	movzbl %bl,%ebx
  80097a:	29 d8                	sub    %ebx,%eax
  80097c:	eb 0f                	jmp    80098d <memcmp+0x35>
		s1++, s2++;
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800984:	39 f0                	cmp    %esi,%eax
  800986:	75 e2                	jne    80096a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800998:	89 c1                	mov    %eax,%ecx
  80099a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a1:	eb 0a                	jmp    8009ad <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a3:	0f b6 10             	movzbl (%eax),%edx
  8009a6:	39 da                	cmp    %ebx,%edx
  8009a8:	74 07                	je     8009b1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	39 c8                	cmp    %ecx,%eax
  8009af:	72 f2                	jb     8009a3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c0:	eb 03                	jmp    8009c5 <strtol+0x11>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c5:	0f b6 01             	movzbl (%ecx),%eax
  8009c8:	3c 20                	cmp    $0x20,%al
  8009ca:	74 f6                	je     8009c2 <strtol+0xe>
  8009cc:	3c 09                	cmp    $0x9,%al
  8009ce:	74 f2                	je     8009c2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d0:	3c 2b                	cmp    $0x2b,%al
  8009d2:	75 0a                	jne    8009de <strtol+0x2a>
		s++;
  8009d4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009dc:	eb 11                	jmp    8009ef <strtol+0x3b>
  8009de:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e3:	3c 2d                	cmp    $0x2d,%al
  8009e5:	75 08                	jne    8009ef <strtol+0x3b>
		s++, neg = 1;
  8009e7:	83 c1 01             	add    $0x1,%ecx
  8009ea:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ef:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f5:	75 15                	jne    800a0c <strtol+0x58>
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	75 10                	jne    800a0c <strtol+0x58>
  8009fc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a00:	75 7c                	jne    800a7e <strtol+0xca>
		s += 2, base = 16;
  800a02:	83 c1 02             	add    $0x2,%ecx
  800a05:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0a:	eb 16                	jmp    800a22 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a0c:	85 db                	test   %ebx,%ebx
  800a0e:	75 12                	jne    800a22 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a10:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a15:	80 39 30             	cmpb   $0x30,(%ecx)
  800a18:	75 08                	jne    800a22 <strtol+0x6e>
		s++, base = 8;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2a:	0f b6 11             	movzbl (%ecx),%edx
  800a2d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 09             	cmp    $0x9,%bl
  800a35:	77 08                	ja     800a3f <strtol+0x8b>
			dig = *s - '0';
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 30             	sub    $0x30,%edx
  800a3d:	eb 22                	jmp    800a61 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a3f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 08                	ja     800a51 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 57             	sub    $0x57,%edx
  800a4f:	eb 10                	jmp    800a61 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a51:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 19             	cmp    $0x19,%bl
  800a59:	77 16                	ja     800a71 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a61:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a64:	7d 0b                	jge    800a71 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a6f:	eb b9                	jmp    800a2a <strtol+0x76>

	if (endptr)
  800a71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a75:	74 0d                	je     800a84 <strtol+0xd0>
		*endptr = (char *) s;
  800a77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7a:	89 0e                	mov    %ecx,(%esi)
  800a7c:	eb 06                	jmp    800a84 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7e:	85 db                	test   %ebx,%ebx
  800a80:	74 98                	je     800a1a <strtol+0x66>
  800a82:	eb 9e                	jmp    800a22 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a84:	89 c2                	mov    %eax,%edx
  800a86:	f7 da                	neg    %edx
  800a88:	85 ff                	test   %edi,%edi
  800a8a:	0f 45 c2             	cmovne %edx,%eax
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	89 c6                	mov    %eax,%esi
  800aa9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  800abb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac0:	89 d1                	mov    %edx,%ecx
  800ac2:	89 d3                	mov    %edx,%ebx
  800ac4:	89 d7                	mov    %edx,%edi
  800ac6:	89 d6                	mov    %edx,%esi
  800ac8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800add:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 cb                	mov    %ecx,%ebx
  800ae7:	89 cf                	mov    %ecx,%edi
  800ae9:	89 ce                	mov    %ecx,%esi
  800aeb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aed:	85 c0                	test   %eax,%eax
  800aef:	7e 17                	jle    800b08 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	50                   	push   %eax
  800af5:	6a 03                	push   $0x3
  800af7:	68 5f 25 80 00       	push   $0x80255f
  800afc:	6a 23                	push   $0x23
  800afe:	68 7c 25 80 00       	push   $0x80257c
  800b03:	e8 31 12 00 00       	call   801d39 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_yield>:

void
sys_yield(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	be 00 00 00 00       	mov    $0x0,%esi
  800b5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6a:	89 f7                	mov    %esi,%edi
  800b6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	7e 17                	jle    800b89 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	50                   	push   %eax
  800b76:	6a 04                	push   $0x4
  800b78:	68 5f 25 80 00       	push   $0x80255f
  800b7d:	6a 23                	push   $0x23
  800b7f:	68 7c 25 80 00       	push   $0x80257c
  800b84:	e8 b0 11 00 00       	call   801d39 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bab:	8b 75 18             	mov    0x18(%ebp),%esi
  800bae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7e 17                	jle    800bcb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 05                	push   $0x5
  800bba:	68 5f 25 80 00       	push   $0x80255f
  800bbf:	6a 23                	push   $0x23
  800bc1:	68 7c 25 80 00       	push   $0x80257c
  800bc6:	e8 6e 11 00 00       	call   801d39 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be1:	b8 06 00 00 00       	mov    $0x6,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 df                	mov    %ebx,%edi
  800bee:	89 de                	mov    %ebx,%esi
  800bf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	7e 17                	jle    800c0d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 06                	push   $0x6
  800bfc:	68 5f 25 80 00       	push   $0x80255f
  800c01:	6a 23                	push   $0x23
  800c03:	68 7c 25 80 00       	push   $0x80257c
  800c08:	e8 2c 11 00 00       	call   801d39 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c23:	b8 08 00 00 00       	mov    $0x8,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 df                	mov    %ebx,%edi
  800c30:	89 de                	mov    %ebx,%esi
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 08                	push   $0x8
  800c3e:	68 5f 25 80 00       	push   $0x80255f
  800c43:	6a 23                	push   $0x23
  800c45:	68 7c 25 80 00       	push   $0x80257c
  800c4a:	e8 ea 10 00 00       	call   801d39 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 09                	push   $0x9
  800c80:	68 5f 25 80 00       	push   $0x80255f
  800c85:	6a 23                	push   $0x23
  800c87:	68 7c 25 80 00       	push   $0x80257c
  800c8c:	e8 a8 10 00 00       	call   801d39 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 0a                	push   $0xa
  800cc2:	68 5f 25 80 00       	push   $0x80255f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 7c 25 80 00       	push   $0x80257c
  800cce:	e8 66 10 00 00       	call   801d39 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	be 00 00 00 00       	mov    $0x0,%esi
  800ce6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 cb                	mov    %ecx,%ebx
  800d16:	89 cf                	mov    %ecx,%edi
  800d18:	89 ce                	mov    %ecx,%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 0d                	push   $0xd
  800d26:	68 5f 25 80 00       	push   $0x80255f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 7c 25 80 00       	push   $0x80257c
  800d32:	e8 02 10 00 00       	call   801d39 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	53                   	push   %ebx
  800d43:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800d46:	89 d3                	mov    %edx,%ebx
  800d48:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800d4b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d52:	f6 c5 04             	test   $0x4,%ch
  800d55:	74 2f                	je     800d86 <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	68 07 0e 00 00       	push   $0xe07
  800d5f:	53                   	push   %ebx
  800d60:	50                   	push   %eax
  800d61:	53                   	push   %ebx
  800d62:	6a 00                	push   $0x0
  800d64:	e8 28 fe ff ff       	call   800b91 <sys_page_map>
  800d69:	83 c4 20             	add    $0x20,%esp
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	0f 89 a0 00 00 00    	jns    800e14 <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800d74:	50                   	push   %eax
  800d75:	68 8a 25 80 00       	push   $0x80258a
  800d7a:	6a 4d                	push   $0x4d
  800d7c:	68 a2 25 80 00       	push   $0x8025a2
  800d81:	e8 b3 0f 00 00       	call   801d39 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800d86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d8d:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d93:	74 57                	je     800dec <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	68 05 08 00 00       	push   $0x805
  800d9d:	53                   	push   %ebx
  800d9e:	50                   	push   %eax
  800d9f:	53                   	push   %ebx
  800da0:	6a 00                	push   $0x0
  800da2:	e8 ea fd ff ff       	call   800b91 <sys_page_map>
  800da7:	83 c4 20             	add    $0x20,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	79 12                	jns    800dc0 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800dae:	50                   	push   %eax
  800daf:	68 ad 25 80 00       	push   $0x8025ad
  800db4:	6a 50                	push   $0x50
  800db6:	68 a2 25 80 00       	push   $0x8025a2
  800dbb:	e8 79 0f 00 00       	call   801d39 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	68 05 08 00 00       	push   $0x805
  800dc8:	53                   	push   %ebx
  800dc9:	6a 00                	push   $0x0
  800dcb:	53                   	push   %ebx
  800dcc:	6a 00                	push   $0x0
  800dce:	e8 be fd ff ff       	call   800b91 <sys_page_map>
  800dd3:	83 c4 20             	add    $0x20,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	79 3a                	jns    800e14 <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800dda:	50                   	push   %eax
  800ddb:	68 ad 25 80 00       	push   $0x8025ad
  800de0:	6a 53                	push   $0x53
  800de2:	68 a2 25 80 00       	push   $0x8025a2
  800de7:	e8 4d 0f 00 00       	call   801d39 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	6a 05                	push   $0x5
  800df1:	53                   	push   %ebx
  800df2:	50                   	push   %eax
  800df3:	53                   	push   %ebx
  800df4:	6a 00                	push   $0x0
  800df6:	e8 96 fd ff ff       	call   800b91 <sys_page_map>
  800dfb:	83 c4 20             	add    $0x20,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	79 12                	jns    800e14 <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800e02:	50                   	push   %eax
  800e03:	68 c1 25 80 00       	push   $0x8025c1
  800e08:	6a 56                	push   $0x56
  800e0a:	68 a2 25 80 00       	push   $0x8025a2
  800e0f:	e8 25 0f 00 00       	call   801d39 <_panic>
	}
	return 0;
}
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
  800e19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e26:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e28:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e2c:	74 2d                	je     800e5b <pgfault+0x3d>
  800e2e:	89 d8                	mov    %ebx,%eax
  800e30:	c1 e8 16             	shr    $0x16,%eax
  800e33:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e3a:	a8 01                	test   $0x1,%al
  800e3c:	74 1d                	je     800e5b <pgfault+0x3d>
  800e3e:	89 d8                	mov    %ebx,%eax
  800e40:	c1 e8 0c             	shr    $0xc,%eax
  800e43:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e4a:	f6 c2 01             	test   $0x1,%dl
  800e4d:	74 0c                	je     800e5b <pgfault+0x3d>
  800e4f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e56:	f6 c4 08             	test   $0x8,%ah
  800e59:	75 14                	jne    800e6f <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800e5b:	83 ec 04             	sub    $0x4,%esp
  800e5e:	68 40 26 80 00       	push   $0x802640
  800e63:	6a 1d                	push   $0x1d
  800e65:	68 a2 25 80 00       	push   $0x8025a2
  800e6a:	e8 ca 0e 00 00       	call   801d39 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800e6f:	e8 9c fc ff ff       	call   800b10 <sys_getenvid>
  800e74:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	6a 07                	push   $0x7
  800e7b:	68 00 f0 7f 00       	push   $0x7ff000
  800e80:	50                   	push   %eax
  800e81:	e8 c8 fc ff ff       	call   800b4e <sys_page_alloc>
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	79 12                	jns    800e9f <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800e8d:	50                   	push   %eax
  800e8e:	68 70 26 80 00       	push   $0x802670
  800e93:	6a 2b                	push   $0x2b
  800e95:	68 a2 25 80 00       	push   $0x8025a2
  800e9a:	e8 9a 0e 00 00       	call   801d39 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800e9f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 00 10 00 00       	push   $0x1000
  800ead:	53                   	push   %ebx
  800eae:	68 00 f0 7f 00       	push   $0x7ff000
  800eb3:	e8 8d fa ff ff       	call   800945 <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800eb8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ebf:	53                   	push   %ebx
  800ec0:	56                   	push   %esi
  800ec1:	68 00 f0 7f 00       	push   $0x7ff000
  800ec6:	56                   	push   %esi
  800ec7:	e8 c5 fc ff ff       	call   800b91 <sys_page_map>
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	79 12                	jns    800ee5 <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800ed3:	50                   	push   %eax
  800ed4:	68 d4 25 80 00       	push   $0x8025d4
  800ed9:	6a 2f                	push   $0x2f
  800edb:	68 a2 25 80 00       	push   $0x8025a2
  800ee0:	e8 54 0e 00 00       	call   801d39 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	68 00 f0 7f 00       	push   $0x7ff000
  800eed:	56                   	push   %esi
  800eee:	e8 e0 fc ff ff       	call   800bd3 <sys_page_unmap>
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	79 12                	jns    800f0c <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  800efa:	50                   	push   %eax
  800efb:	68 94 26 80 00       	push   $0x802694
  800f00:	6a 32                	push   $0x32
  800f02:	68 a2 25 80 00       	push   $0x8025a2
  800f07:	e8 2d 0e 00 00       	call   801d39 <_panic>
	//panic("pgfault not implemented");
}
  800f0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f1b:	68 1e 0e 80 00       	push   $0x800e1e
  800f20:	e8 5a 0e 00 00       	call   801d7f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f25:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2a:	cd 30                	int    $0x30
  800f2c:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	79 12                	jns    800f47 <fork+0x34>
		panic("sys_exofork:%e", envid);
  800f35:	50                   	push   %eax
  800f36:	68 f1 25 80 00       	push   $0x8025f1
  800f3b:	6a 75                	push   $0x75
  800f3d:	68 a2 25 80 00       	push   $0x8025a2
  800f42:	e8 f2 0d 00 00       	call   801d39 <_panic>
  800f47:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	75 21                	jne    800f6e <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f4d:	e8 be fb ff ff       	call   800b10 <sys_getenvid>
  800f52:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f57:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f5a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f5f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
  800f69:	e9 c0 00 00 00       	jmp    80102e <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800f6e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800f75:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	c1 e8 16             	shr    $0x16,%eax
  800f7f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f86:	a8 01                	test   $0x1,%al
  800f88:	74 20                	je     800faa <fork+0x97>
  800f8a:	c1 ea 0c             	shr    $0xc,%edx
  800f8d:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f94:	a8 01                	test   $0x1,%al
  800f96:	74 12                	je     800faa <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800f98:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f9f:	a8 04                	test   $0x4,%al
  800fa1:	74 07                	je     800faa <fork+0x97>
			duppage(envid, PGNUM(addr));
  800fa3:	89 f0                	mov    %esi,%eax
  800fa5:	e8 95 fd ff ff       	call   800d3f <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fad:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  800fb3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fb6:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  800fbc:	76 bc                	jbe    800f7a <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  800fbe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fc1:	c1 ea 0c             	shr    $0xc,%edx
  800fc4:	89 d8                	mov    %ebx,%eax
  800fc6:	e8 74 fd ff ff       	call   800d3f <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	6a 07                	push   $0x7
  800fd0:	68 00 f0 bf ee       	push   $0xeebff000
  800fd5:	53                   	push   %ebx
  800fd6:	e8 73 fb ff ff       	call   800b4e <sys_page_alloc>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	74 15                	je     800ff7 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  800fe2:	50                   	push   %eax
  800fe3:	68 00 26 80 00       	push   $0x802600
  800fe8:	68 86 00 00 00       	push   $0x86
  800fed:	68 a2 25 80 00       	push   $0x8025a2
  800ff2:	e8 42 0d 00 00       	call   801d39 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	68 e7 1d 80 00       	push   $0x801de7
  800fff:	53                   	push   %ebx
  801000:	e8 94 fc ff ff       	call   800c99 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  801005:	83 c4 08             	add    $0x8,%esp
  801008:	6a 02                	push   $0x2
  80100a:	53                   	push   %ebx
  80100b:	e8 05 fc ff ff       	call   800c15 <sys_env_set_status>
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	74 15                	je     80102c <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801017:	50                   	push   %eax
  801018:	68 12 26 80 00       	push   $0x802612
  80101d:	68 8c 00 00 00       	push   $0x8c
  801022:	68 a2 25 80 00       	push   $0x8025a2
  801027:	e8 0d 0d 00 00       	call   801d39 <_panic>

	return envid;
  80102c:	89 d8                	mov    %ebx,%eax
	    
}
  80102e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sfork>:

// Challenge!
int
sfork(void)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80103b:	68 28 26 80 00       	push   $0x802628
  801040:	68 96 00 00 00       	push   $0x96
  801045:	68 a2 25 80 00       	push   $0x8025a2
  80104a:	e8 ea 0c 00 00       	call   801d39 <_panic>

0080104f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801052:	8b 45 08             	mov    0x8(%ebp),%eax
  801055:	05 00 00 00 30       	add    $0x30000000,%eax
  80105a:	c1 e8 0c             	shr    $0xc,%eax
}
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    

0080105f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
  801065:	05 00 00 00 30       	add    $0x30000000,%eax
  80106a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80106f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801081:	89 c2                	mov    %eax,%edx
  801083:	c1 ea 16             	shr    $0x16,%edx
  801086:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108d:	f6 c2 01             	test   $0x1,%dl
  801090:	74 11                	je     8010a3 <fd_alloc+0x2d>
  801092:	89 c2                	mov    %eax,%edx
  801094:	c1 ea 0c             	shr    $0xc,%edx
  801097:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	75 09                	jne    8010ac <fd_alloc+0x36>
			*fd_store = fd;
  8010a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010aa:	eb 17                	jmp    8010c3 <fd_alloc+0x4d>
  8010ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b6:	75 c9                	jne    801081 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010cb:	83 f8 1f             	cmp    $0x1f,%eax
  8010ce:	77 36                	ja     801106 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d0:	c1 e0 0c             	shl    $0xc,%eax
  8010d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d8:	89 c2                	mov    %eax,%edx
  8010da:	c1 ea 16             	shr    $0x16,%edx
  8010dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e4:	f6 c2 01             	test   $0x1,%dl
  8010e7:	74 24                	je     80110d <fd_lookup+0x48>
  8010e9:	89 c2                	mov    %eax,%edx
  8010eb:	c1 ea 0c             	shr    $0xc,%edx
  8010ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f5:	f6 c2 01             	test   $0x1,%dl
  8010f8:	74 1a                	je     801114 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8010ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801104:	eb 13                	jmp    801119 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801106:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110b:	eb 0c                	jmp    801119 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801112:	eb 05                	jmp    801119 <fd_lookup+0x54>
  801114:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801124:	ba 30 27 80 00       	mov    $0x802730,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801129:	eb 13                	jmp    80113e <dev_lookup+0x23>
  80112b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80112e:	39 08                	cmp    %ecx,(%eax)
  801130:	75 0c                	jne    80113e <dev_lookup+0x23>
			*dev = devtab[i];
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	89 01                	mov    %eax,(%ecx)
			return 0;
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	eb 2e                	jmp    80116c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80113e:	8b 02                	mov    (%edx),%eax
  801140:	85 c0                	test   %eax,%eax
  801142:	75 e7                	jne    80112b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801144:	a1 04 40 80 00       	mov    0x804004,%eax
  801149:	8b 40 48             	mov    0x48(%eax),%eax
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	51                   	push   %ecx
  801150:	50                   	push   %eax
  801151:	68 b4 26 80 00       	push   $0x8026b4
  801156:	e8 4d f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  80115b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 10             	sub    $0x10,%esp
  801176:	8b 75 08             	mov    0x8(%ebp),%esi
  801179:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801186:	c1 e8 0c             	shr    $0xc,%eax
  801189:	50                   	push   %eax
  80118a:	e8 36 ff ff ff       	call   8010c5 <fd_lookup>
  80118f:	83 c4 08             	add    $0x8,%esp
  801192:	85 c0                	test   %eax,%eax
  801194:	78 05                	js     80119b <fd_close+0x2d>
	    || fd != fd2)
  801196:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801199:	74 0c                	je     8011a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80119b:	84 db                	test   %bl,%bl
  80119d:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a2:	0f 44 c2             	cmove  %edx,%eax
  8011a5:	eb 41                	jmp    8011e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	ff 36                	pushl  (%esi)
  8011b0:	e8 66 ff ff ff       	call   80111b <dev_lookup>
  8011b5:	89 c3                	mov    %eax,%ebx
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 1a                	js     8011d8 <fd_close+0x6a>
		if (dev->dev_close)
  8011be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	74 0b                	je     8011d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	56                   	push   %esi
  8011d1:	ff d0                	call   *%eax
  8011d3:	89 c3                	mov    %eax,%ebx
  8011d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	56                   	push   %esi
  8011dc:	6a 00                	push   $0x0
  8011de:	e8 f0 f9 ff ff       	call   800bd3 <sys_page_unmap>
	return r;
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	89 d8                	mov    %ebx,%eax
}
  8011e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 c4 fe ff ff       	call   8010c5 <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 10                	js     801218 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801208:	83 ec 08             	sub    $0x8,%esp
  80120b:	6a 01                	push   $0x1
  80120d:	ff 75 f4             	pushl  -0xc(%ebp)
  801210:	e8 59 ff ff ff       	call   80116e <fd_close>
  801215:	83 c4 10             	add    $0x10,%esp
}
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <close_all>:

void
close_all(void)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	53                   	push   %ebx
  80121e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801221:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	53                   	push   %ebx
  80122a:	e8 c0 ff ff ff       	call   8011ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80122f:	83 c3 01             	add    $0x1,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	83 fb 20             	cmp    $0x20,%ebx
  801238:	75 ec                	jne    801226 <close_all+0xc>
		close(i);
}
  80123a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	57                   	push   %edi
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
  801245:	83 ec 2c             	sub    $0x2c,%esp
  801248:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	ff 75 08             	pushl  0x8(%ebp)
  801252:	e8 6e fe ff ff       	call   8010c5 <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	0f 88 c1 00 00 00    	js     801323 <dup+0xe4>
		return r;
	close(newfdnum);
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	56                   	push   %esi
  801266:	e8 84 ff ff ff       	call   8011ef <close>

	newfd = INDEX2FD(newfdnum);
  80126b:	89 f3                	mov    %esi,%ebx
  80126d:	c1 e3 0c             	shl    $0xc,%ebx
  801270:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801276:	83 c4 04             	add    $0x4,%esp
  801279:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127c:	e8 de fd ff ff       	call   80105f <fd2data>
  801281:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801283:	89 1c 24             	mov    %ebx,(%esp)
  801286:	e8 d4 fd ff ff       	call   80105f <fd2data>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801291:	89 f8                	mov    %edi,%eax
  801293:	c1 e8 16             	shr    $0x16,%eax
  801296:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129d:	a8 01                	test   $0x1,%al
  80129f:	74 37                	je     8012d8 <dup+0x99>
  8012a1:	89 f8                	mov    %edi,%eax
  8012a3:	c1 e8 0c             	shr    $0xc,%eax
  8012a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ad:	f6 c2 01             	test   $0x1,%dl
  8012b0:	74 26                	je     8012d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b9:	83 ec 0c             	sub    $0xc,%esp
  8012bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c1:	50                   	push   %eax
  8012c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c5:	6a 00                	push   $0x0
  8012c7:	57                   	push   %edi
  8012c8:	6a 00                	push   $0x0
  8012ca:	e8 c2 f8 ff ff       	call   800b91 <sys_page_map>
  8012cf:	89 c7                	mov    %eax,%edi
  8012d1:	83 c4 20             	add    $0x20,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 2e                	js     801306 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012db:	89 d0                	mov    %edx,%eax
  8012dd:	c1 e8 0c             	shr    $0xc,%eax
  8012e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e7:	83 ec 0c             	sub    $0xc,%esp
  8012ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ef:	50                   	push   %eax
  8012f0:	53                   	push   %ebx
  8012f1:	6a 00                	push   $0x0
  8012f3:	52                   	push   %edx
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 96 f8 ff ff       	call   800b91 <sys_page_map>
  8012fb:	89 c7                	mov    %eax,%edi
  8012fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801300:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801302:	85 ff                	test   %edi,%edi
  801304:	79 1d                	jns    801323 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	53                   	push   %ebx
  80130a:	6a 00                	push   $0x0
  80130c:	e8 c2 f8 ff ff       	call   800bd3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	ff 75 d4             	pushl  -0x2c(%ebp)
  801317:	6a 00                	push   $0x0
  801319:	e8 b5 f8 ff ff       	call   800bd3 <sys_page_unmap>
	return r;
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	89 f8                	mov    %edi,%eax
}
  801323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    

0080132b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	53                   	push   %ebx
  80132f:	83 ec 14             	sub    $0x14,%esp
  801332:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	53                   	push   %ebx
  80133a:	e8 86 fd ff ff       	call   8010c5 <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	89 c2                	mov    %eax,%edx
  801344:	85 c0                	test   %eax,%eax
  801346:	78 6d                	js     8013b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134e:	50                   	push   %eax
  80134f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801352:	ff 30                	pushl  (%eax)
  801354:	e8 c2 fd ff ff       	call   80111b <dev_lookup>
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 4c                	js     8013ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801360:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801363:	8b 42 08             	mov    0x8(%edx),%eax
  801366:	83 e0 03             	and    $0x3,%eax
  801369:	83 f8 01             	cmp    $0x1,%eax
  80136c:	75 21                	jne    80138f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80136e:	a1 04 40 80 00       	mov    0x804004,%eax
  801373:	8b 40 48             	mov    0x48(%eax),%eax
  801376:	83 ec 04             	sub    $0x4,%esp
  801379:	53                   	push   %ebx
  80137a:	50                   	push   %eax
  80137b:	68 f5 26 80 00       	push   $0x8026f5
  801380:	e8 23 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138d:	eb 26                	jmp    8013b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801392:	8b 40 08             	mov    0x8(%eax),%eax
  801395:	85 c0                	test   %eax,%eax
  801397:	74 17                	je     8013b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801399:	83 ec 04             	sub    $0x4,%esp
  80139c:	ff 75 10             	pushl  0x10(%ebp)
  80139f:	ff 75 0c             	pushl  0xc(%ebp)
  8013a2:	52                   	push   %edx
  8013a3:	ff d0                	call   *%eax
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb 09                	jmp    8013b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	eb 05                	jmp    8013b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013b5:	89 d0                	mov    %edx,%eax
  8013b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	57                   	push   %edi
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 0c             	sub    $0xc,%esp
  8013c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d0:	eb 21                	jmp    8013f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	29 d8                	sub    %ebx,%eax
  8013d9:	50                   	push   %eax
  8013da:	89 d8                	mov    %ebx,%eax
  8013dc:	03 45 0c             	add    0xc(%ebp),%eax
  8013df:	50                   	push   %eax
  8013e0:	57                   	push   %edi
  8013e1:	e8 45 ff ff ff       	call   80132b <read>
		if (m < 0)
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 10                	js     8013fd <readn+0x41>
			return m;
		if (m == 0)
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	74 0a                	je     8013fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f1:	01 c3                	add    %eax,%ebx
  8013f3:	39 f3                	cmp    %esi,%ebx
  8013f5:	72 db                	jb     8013d2 <readn+0x16>
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	eb 02                	jmp    8013fd <readn+0x41>
  8013fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	53                   	push   %ebx
  801409:	83 ec 14             	sub    $0x14,%esp
  80140c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	53                   	push   %ebx
  801414:	e8 ac fc ff ff       	call   8010c5 <fd_lookup>
  801419:	83 c4 08             	add    $0x8,%esp
  80141c:	89 c2                	mov    %eax,%edx
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 68                	js     80148a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801422:	83 ec 08             	sub    $0x8,%esp
  801425:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142c:	ff 30                	pushl  (%eax)
  80142e:	e8 e8 fc ff ff       	call   80111b <dev_lookup>
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	85 c0                	test   %eax,%eax
  801438:	78 47                	js     801481 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801441:	75 21                	jne    801464 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801443:	a1 04 40 80 00       	mov    0x804004,%eax
  801448:	8b 40 48             	mov    0x48(%eax),%eax
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	53                   	push   %ebx
  80144f:	50                   	push   %eax
  801450:	68 11 27 80 00       	push   $0x802711
  801455:	e8 4e ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801462:	eb 26                	jmp    80148a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801464:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801467:	8b 52 0c             	mov    0xc(%edx),%edx
  80146a:	85 d2                	test   %edx,%edx
  80146c:	74 17                	je     801485 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	ff 75 10             	pushl  0x10(%ebp)
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	50                   	push   %eax
  801478:	ff d2                	call   *%edx
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	eb 09                	jmp    80148a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801481:	89 c2                	mov    %eax,%edx
  801483:	eb 05                	jmp    80148a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801485:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148a:	89 d0                	mov    %edx,%eax
  80148c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <seek>:

int
seek(int fdnum, off_t offset)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801497:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	ff 75 08             	pushl  0x8(%ebp)
  80149e:	e8 22 fc ff ff       	call   8010c5 <fd_lookup>
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 0e                	js     8014b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 14             	sub    $0x14,%esp
  8014c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	53                   	push   %ebx
  8014c9:	e8 f7 fb ff ff       	call   8010c5 <fd_lookup>
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 65                	js     80153c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e1:	ff 30                	pushl  (%eax)
  8014e3:	e8 33 fc ff ff       	call   80111b <dev_lookup>
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 44                	js     801533 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f6:	75 21                	jne    801519 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014fd:	8b 40 48             	mov    0x48(%eax),%eax
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	53                   	push   %ebx
  801504:	50                   	push   %eax
  801505:	68 d4 26 80 00       	push   $0x8026d4
  80150a:	e8 99 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801517:	eb 23                	jmp    80153c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801519:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151c:	8b 52 18             	mov    0x18(%edx),%edx
  80151f:	85 d2                	test   %edx,%edx
  801521:	74 14                	je     801537 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	ff 75 0c             	pushl  0xc(%ebp)
  801529:	50                   	push   %eax
  80152a:	ff d2                	call   *%edx
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	eb 09                	jmp    80153c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	89 c2                	mov    %eax,%edx
  801535:	eb 05                	jmp    80153c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801537:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153c:	89 d0                	mov    %edx,%eax
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 14             	sub    $0x14,%esp
  80154a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	ff 75 08             	pushl  0x8(%ebp)
  801554:	e8 6c fb ff ff       	call   8010c5 <fd_lookup>
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 58                	js     8015ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	ff 30                	pushl  (%eax)
  80156e:	e8 a8 fb ff ff       	call   80111b <dev_lookup>
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 37                	js     8015b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801581:	74 32                	je     8015b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801583:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801586:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158d:	00 00 00 
	stat->st_isdir = 0;
  801590:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801597:	00 00 00 
	stat->st_dev = dev;
  80159a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a7:	ff 50 14             	call   *0x14(%eax)
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 09                	jmp    8015ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	eb 05                	jmp    8015ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ba:	89 d0                	mov    %edx,%eax
  8015bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	6a 00                	push   $0x0
  8015cb:	ff 75 08             	pushl  0x8(%ebp)
  8015ce:	e8 e3 01 00 00       	call   8017b6 <open>
  8015d3:	89 c3                	mov    %eax,%ebx
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 1b                	js     8015f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	ff 75 0c             	pushl  0xc(%ebp)
  8015e2:	50                   	push   %eax
  8015e3:	e8 5b ff ff ff       	call   801543 <fstat>
  8015e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ea:	89 1c 24             	mov    %ebx,(%esp)
  8015ed:	e8 fd fb ff ff       	call   8011ef <close>
	return r;
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	89 f0                	mov    %esi,%eax
}
  8015f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    

008015fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	89 c6                	mov    %eax,%esi
  801605:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801607:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80160e:	75 12                	jne    801622 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	6a 01                	push   $0x1
  801615:	e8 9a 08 00 00       	call   801eb4 <ipc_find_env>
  80161a:	a3 00 40 80 00       	mov    %eax,0x804000
  80161f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801622:	6a 07                	push   $0x7
  801624:	68 00 50 80 00       	push   $0x805000
  801629:	56                   	push   %esi
  80162a:	ff 35 00 40 80 00    	pushl  0x804000
  801630:	e8 2b 08 00 00       	call   801e60 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801635:	83 c4 0c             	add    $0xc,%esp
  801638:	6a 00                	push   $0x0
  80163a:	53                   	push   %ebx
  80163b:	6a 00                	push   $0x0
  80163d:	e8 c9 07 00 00       	call   801e0b <ipc_recv>
}
  801642:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	8b 40 0c             	mov    0xc(%eax),%eax
  801655:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80165a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
  801667:	b8 02 00 00 00       	mov    $0x2,%eax
  80166c:	e8 8d ff ff ff       	call   8015fe <fsipc>
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801679:	8b 45 08             	mov    0x8(%ebp),%eax
  80167c:	8b 40 0c             	mov    0xc(%eax),%eax
  80167f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801684:	ba 00 00 00 00       	mov    $0x0,%edx
  801689:	b8 06 00 00 00       	mov    $0x6,%eax
  80168e:	e8 6b ff ff ff       	call   8015fe <fsipc>
}
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 04             	sub    $0x4,%esp
  80169c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80169f:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016af:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b4:	e8 45 ff ff ff       	call   8015fe <fsipc>
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 2c                	js     8016e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	68 00 50 80 00       	push   $0x805000
  8016c5:	53                   	push   %ebx
  8016c6:	e8 80 f0 ff ff       	call   80074b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8016d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8016db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	83 ec 0c             	sub    $0xc,%esp
  8016f4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8016fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fd:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801703:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801708:	ba 00 10 00 00       	mov    $0x1000,%edx
  80170d:	0f 47 c2             	cmova  %edx,%eax
  801710:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801715:	50                   	push   %eax
  801716:	ff 75 0c             	pushl  0xc(%ebp)
  801719:	68 08 50 80 00       	push   $0x805008
  80171e:	e8 ba f1 ff ff       	call   8008dd <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 04 00 00 00       	mov    $0x4,%eax
  80172d:	e8 cc fe ff ff       	call   8015fe <fsipc>
    return r;
}
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	8b 40 0c             	mov    0xc(%eax),%eax
  801742:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801747:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
  801752:	b8 03 00 00 00       	mov    $0x3,%eax
  801757:	e8 a2 fe ff ff       	call   8015fe <fsipc>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 4b                	js     8017ad <devfile_read+0x79>
		return r;
	assert(r <= n);
  801762:	39 c6                	cmp    %eax,%esi
  801764:	73 16                	jae    80177c <devfile_read+0x48>
  801766:	68 40 27 80 00       	push   $0x802740
  80176b:	68 47 27 80 00       	push   $0x802747
  801770:	6a 7c                	push   $0x7c
  801772:	68 5c 27 80 00       	push   $0x80275c
  801777:	e8 bd 05 00 00       	call   801d39 <_panic>
	assert(r <= PGSIZE);
  80177c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801781:	7e 16                	jle    801799 <devfile_read+0x65>
  801783:	68 67 27 80 00       	push   $0x802767
  801788:	68 47 27 80 00       	push   $0x802747
  80178d:	6a 7d                	push   $0x7d
  80178f:	68 5c 27 80 00       	push   $0x80275c
  801794:	e8 a0 05 00 00       	call   801d39 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801799:	83 ec 04             	sub    $0x4,%esp
  80179c:	50                   	push   %eax
  80179d:	68 00 50 80 00       	push   $0x805000
  8017a2:	ff 75 0c             	pushl  0xc(%ebp)
  8017a5:	e8 33 f1 ff ff       	call   8008dd <memmove>
	return r;
  8017aa:	83 c4 10             	add    $0x10,%esp
}
  8017ad:	89 d8                	mov    %ebx,%eax
  8017af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 20             	sub    $0x20,%esp
  8017bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c0:	53                   	push   %ebx
  8017c1:	e8 4c ef ff ff       	call   800712 <strlen>
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ce:	7f 67                	jg     801837 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d0:	83 ec 0c             	sub    $0xc,%esp
  8017d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	e8 9a f8 ff ff       	call   801076 <fd_alloc>
  8017dc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017df:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 57                	js     80183c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	53                   	push   %ebx
  8017e9:	68 00 50 80 00       	push   $0x805000
  8017ee:	e8 58 ef ff ff       	call   80074b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801803:	e8 f6 fd ff ff       	call   8015fe <fsipc>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	79 14                	jns    801825 <open+0x6f>
		fd_close(fd, 0);
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	6a 00                	push   $0x0
  801816:	ff 75 f4             	pushl  -0xc(%ebp)
  801819:	e8 50 f9 ff ff       	call   80116e <fd_close>
		return r;
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	89 da                	mov    %ebx,%edx
  801823:	eb 17                	jmp    80183c <open+0x86>
	}

	return fd2num(fd);
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	ff 75 f4             	pushl  -0xc(%ebp)
  80182b:	e8 1f f8 ff ff       	call   80104f <fd2num>
  801830:	89 c2                	mov    %eax,%edx
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	eb 05                	jmp    80183c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801837:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80183c:	89 d0                	mov    %edx,%eax
  80183e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801849:	ba 00 00 00 00       	mov    $0x0,%edx
  80184e:	b8 08 00 00 00       	mov    $0x8,%eax
  801853:	e8 a6 fd ff ff       	call   8015fe <fsipc>
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	ff 75 08             	pushl  0x8(%ebp)
  801868:	e8 f2 f7 ff ff       	call   80105f <fd2data>
  80186d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80186f:	83 c4 08             	add    $0x8,%esp
  801872:	68 73 27 80 00       	push   $0x802773
  801877:	53                   	push   %ebx
  801878:	e8 ce ee ff ff       	call   80074b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80187d:	8b 46 04             	mov    0x4(%esi),%eax
  801880:	2b 06                	sub    (%esi),%eax
  801882:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80188f:	00 00 00 
	stat->st_dev = &devpipe;
  801892:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801899:	30 80 00 
	return 0;
}
  80189c:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 0c             	sub    $0xc,%esp
  8018af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b2:	53                   	push   %ebx
  8018b3:	6a 00                	push   $0x0
  8018b5:	e8 19 f3 ff ff       	call   800bd3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018ba:	89 1c 24             	mov    %ebx,(%esp)
  8018bd:	e8 9d f7 ff ff       	call   80105f <fd2data>
  8018c2:	83 c4 08             	add    $0x8,%esp
  8018c5:	50                   	push   %eax
  8018c6:	6a 00                	push   $0x0
  8018c8:	e8 06 f3 ff ff       	call   800bd3 <sys_page_unmap>
}
  8018cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	57                   	push   %edi
  8018d6:	56                   	push   %esi
  8018d7:	53                   	push   %ebx
  8018d8:	83 ec 1c             	sub    $0x1c,%esp
  8018db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018de:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ee:	e8 fa 05 00 00       	call   801eed <pageref>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	89 3c 24             	mov    %edi,(%esp)
  8018f8:	e8 f0 05 00 00       	call   801eed <pageref>
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	39 c3                	cmp    %eax,%ebx
  801902:	0f 94 c1             	sete   %cl
  801905:	0f b6 c9             	movzbl %cl,%ecx
  801908:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80190b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801911:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801914:	39 ce                	cmp    %ecx,%esi
  801916:	74 1b                	je     801933 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801918:	39 c3                	cmp    %eax,%ebx
  80191a:	75 c4                	jne    8018e0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80191c:	8b 42 58             	mov    0x58(%edx),%eax
  80191f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801922:	50                   	push   %eax
  801923:	56                   	push   %esi
  801924:	68 7a 27 80 00       	push   $0x80277a
  801929:	e8 7a e8 ff ff       	call   8001a8 <cprintf>
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	eb ad                	jmp    8018e0 <_pipeisclosed+0xe>
	}
}
  801933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801936:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5f                   	pop    %edi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	57                   	push   %edi
  801942:	56                   	push   %esi
  801943:	53                   	push   %ebx
  801944:	83 ec 28             	sub    $0x28,%esp
  801947:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80194a:	56                   	push   %esi
  80194b:	e8 0f f7 ff ff       	call   80105f <fd2data>
  801950:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	bf 00 00 00 00       	mov    $0x0,%edi
  80195a:	eb 4b                	jmp    8019a7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80195c:	89 da                	mov    %ebx,%edx
  80195e:	89 f0                	mov    %esi,%eax
  801960:	e8 6d ff ff ff       	call   8018d2 <_pipeisclosed>
  801965:	85 c0                	test   %eax,%eax
  801967:	75 48                	jne    8019b1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801969:	e8 c1 f1 ff ff       	call   800b2f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80196e:	8b 43 04             	mov    0x4(%ebx),%eax
  801971:	8b 0b                	mov    (%ebx),%ecx
  801973:	8d 51 20             	lea    0x20(%ecx),%edx
  801976:	39 d0                	cmp    %edx,%eax
  801978:	73 e2                	jae    80195c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80197a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801981:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801984:	89 c2                	mov    %eax,%edx
  801986:	c1 fa 1f             	sar    $0x1f,%edx
  801989:	89 d1                	mov    %edx,%ecx
  80198b:	c1 e9 1b             	shr    $0x1b,%ecx
  80198e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801991:	83 e2 1f             	and    $0x1f,%edx
  801994:	29 ca                	sub    %ecx,%edx
  801996:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80199a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80199e:	83 c0 01             	add    $0x1,%eax
  8019a1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a4:	83 c7 01             	add    $0x1,%edi
  8019a7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019aa:	75 c2                	jne    80196e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8019af:	eb 05                	jmp    8019b6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b9:	5b                   	pop    %ebx
  8019ba:	5e                   	pop    %esi
  8019bb:	5f                   	pop    %edi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	57                   	push   %edi
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 18             	sub    $0x18,%esp
  8019c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019ca:	57                   	push   %edi
  8019cb:	e8 8f f6 ff ff       	call   80105f <fd2data>
  8019d0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019da:	eb 3d                	jmp    801a19 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019dc:	85 db                	test   %ebx,%ebx
  8019de:	74 04                	je     8019e4 <devpipe_read+0x26>
				return i;
  8019e0:	89 d8                	mov    %ebx,%eax
  8019e2:	eb 44                	jmp    801a28 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e4:	89 f2                	mov    %esi,%edx
  8019e6:	89 f8                	mov    %edi,%eax
  8019e8:	e8 e5 fe ff ff       	call   8018d2 <_pipeisclosed>
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	75 32                	jne    801a23 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019f1:	e8 39 f1 ff ff       	call   800b2f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f6:	8b 06                	mov    (%esi),%eax
  8019f8:	3b 46 04             	cmp    0x4(%esi),%eax
  8019fb:	74 df                	je     8019dc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019fd:	99                   	cltd   
  8019fe:	c1 ea 1b             	shr    $0x1b,%edx
  801a01:	01 d0                	add    %edx,%eax
  801a03:	83 e0 1f             	and    $0x1f,%eax
  801a06:	29 d0                	sub    %edx,%eax
  801a08:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a10:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a13:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a16:	83 c3 01             	add    $0x1,%ebx
  801a19:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a1c:	75 d8                	jne    8019f6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a21:	eb 05                	jmp    801a28 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5f                   	pop    %edi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3b:	50                   	push   %eax
  801a3c:	e8 35 f6 ff ff       	call   801076 <fd_alloc>
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	89 c2                	mov    %eax,%edx
  801a46:	85 c0                	test   %eax,%eax
  801a48:	0f 88 2c 01 00 00    	js     801b7a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	68 07 04 00 00       	push   $0x407
  801a56:	ff 75 f4             	pushl  -0xc(%ebp)
  801a59:	6a 00                	push   $0x0
  801a5b:	e8 ee f0 ff ff       	call   800b4e <sys_page_alloc>
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	89 c2                	mov    %eax,%edx
  801a65:	85 c0                	test   %eax,%eax
  801a67:	0f 88 0d 01 00 00    	js     801b7a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a73:	50                   	push   %eax
  801a74:	e8 fd f5 ff ff       	call   801076 <fd_alloc>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	0f 88 e2 00 00 00    	js     801b68 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a86:	83 ec 04             	sub    $0x4,%esp
  801a89:	68 07 04 00 00       	push   $0x407
  801a8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a91:	6a 00                	push   $0x0
  801a93:	e8 b6 f0 ff ff       	call   800b4e <sys_page_alloc>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	0f 88 c3 00 00 00    	js     801b68 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	ff 75 f4             	pushl  -0xc(%ebp)
  801aab:	e8 af f5 ff ff       	call   80105f <fd2data>
  801ab0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab2:	83 c4 0c             	add    $0xc,%esp
  801ab5:	68 07 04 00 00       	push   $0x407
  801aba:	50                   	push   %eax
  801abb:	6a 00                	push   $0x0
  801abd:	e8 8c f0 ff ff       	call   800b4e <sys_page_alloc>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	0f 88 89 00 00 00    	js     801b58 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad5:	e8 85 f5 ff ff       	call   80105f <fd2data>
  801ada:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ae1:	50                   	push   %eax
  801ae2:	6a 00                	push   $0x0
  801ae4:	56                   	push   %esi
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 a5 f0 ff ff       	call   800b91 <sys_page_map>
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	83 c4 20             	add    $0x20,%esp
  801af1:	85 c0                	test   %eax,%eax
  801af3:	78 55                	js     801b4a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b0a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b13:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	ff 75 f4             	pushl  -0xc(%ebp)
  801b25:	e8 25 f5 ff ff       	call   80104f <fd2num>
  801b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b2f:	83 c4 04             	add    $0x4,%esp
  801b32:	ff 75 f0             	pushl  -0x10(%ebp)
  801b35:	e8 15 f5 ff ff       	call   80104f <fd2num>
  801b3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	ba 00 00 00 00       	mov    $0x0,%edx
  801b48:	eb 30                	jmp    801b7a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b4a:	83 ec 08             	sub    $0x8,%esp
  801b4d:	56                   	push   %esi
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 7e f0 ff ff       	call   800bd3 <sys_page_unmap>
  801b55:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 6e f0 ff ff       	call   800bd3 <sys_page_unmap>
  801b65:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b68:	83 ec 08             	sub    $0x8,%esp
  801b6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6e:	6a 00                	push   $0x0
  801b70:	e8 5e f0 ff ff       	call   800bd3 <sys_page_unmap>
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b7a:	89 d0                	mov    %edx,%eax
  801b7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8c:	50                   	push   %eax
  801b8d:	ff 75 08             	pushl  0x8(%ebp)
  801b90:	e8 30 f5 ff ff       	call   8010c5 <fd_lookup>
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 18                	js     801bb4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	e8 b8 f4 ff ff       	call   80105f <fd2data>
	return _pipeisclosed(fd, p);
  801ba7:	89 c2                	mov    %eax,%edx
  801ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bac:	e8 21 fd ff ff       	call   8018d2 <_pipeisclosed>
  801bb1:	83 c4 10             	add    $0x10,%esp
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bc6:	68 92 27 80 00       	push   $0x802792
  801bcb:	ff 75 0c             	pushl  0xc(%ebp)
  801bce:	e8 78 eb ff ff       	call   80074b <strcpy>
	return 0;
}
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801beb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf1:	eb 2d                	jmp    801c20 <devcons_write+0x46>
		m = n - tot;
  801bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bf6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bf8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bfb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c00:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c03:	83 ec 04             	sub    $0x4,%esp
  801c06:	53                   	push   %ebx
  801c07:	03 45 0c             	add    0xc(%ebp),%eax
  801c0a:	50                   	push   %eax
  801c0b:	57                   	push   %edi
  801c0c:	e8 cc ec ff ff       	call   8008dd <memmove>
		sys_cputs(buf, m);
  801c11:	83 c4 08             	add    $0x8,%esp
  801c14:	53                   	push   %ebx
  801c15:	57                   	push   %edi
  801c16:	e8 77 ee ff ff       	call   800a92 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1b:	01 de                	add    %ebx,%esi
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	89 f0                	mov    %esi,%eax
  801c22:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c25:	72 cc                	jb     801bf3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5f                   	pop    %edi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	83 ec 08             	sub    $0x8,%esp
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3e:	74 2a                	je     801c6a <devcons_read+0x3b>
  801c40:	eb 05                	jmp    801c47 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c42:	e8 e8 ee ff ff       	call   800b2f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c47:	e8 64 ee ff ff       	call   800ab0 <sys_cgetc>
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	74 f2                	je     801c42 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 16                	js     801c6a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c54:	83 f8 04             	cmp    $0x4,%eax
  801c57:	74 0c                	je     801c65 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5c:	88 02                	mov    %al,(%edx)
	return 1;
  801c5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c63:	eb 05                	jmp    801c6a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c78:	6a 01                	push   $0x1
  801c7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	e8 0f ee ff ff       	call   800a92 <sys_cputs>
}
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <getchar>:

int
getchar(void)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c8e:	6a 01                	push   $0x1
  801c90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c93:	50                   	push   %eax
  801c94:	6a 00                	push   $0x0
  801c96:	e8 90 f6 ff ff       	call   80132b <read>
	if (r < 0)
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 0f                	js     801cb1 <getchar+0x29>
		return r;
	if (r < 1)
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	7e 06                	jle    801cac <getchar+0x24>
		return -E_EOF;
	return c;
  801ca6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801caa:	eb 05                	jmp    801cb1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cac:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	ff 75 08             	pushl  0x8(%ebp)
  801cc0:	e8 00 f4 ff ff       	call   8010c5 <fd_lookup>
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 11                	js     801cdd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd5:	39 10                	cmp    %edx,(%eax)
  801cd7:	0f 94 c0             	sete   %al
  801cda:	0f b6 c0             	movzbl %al,%eax
}
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <opencons>:

int
opencons(void)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce8:	50                   	push   %eax
  801ce9:	e8 88 f3 ff ff       	call   801076 <fd_alloc>
  801cee:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 3e                	js     801d35 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf7:	83 ec 04             	sub    $0x4,%esp
  801cfa:	68 07 04 00 00       	push   $0x407
  801cff:	ff 75 f4             	pushl  -0xc(%ebp)
  801d02:	6a 00                	push   $0x0
  801d04:	e8 45 ee ff ff       	call   800b4e <sys_page_alloc>
  801d09:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 23                	js     801d35 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d12:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d20:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	50                   	push   %eax
  801d2b:	e8 1f f3 ff ff       	call   80104f <fd2num>
  801d30:	89 c2                	mov    %eax,%edx
  801d32:	83 c4 10             	add    $0x10,%esp
}
  801d35:	89 d0                	mov    %edx,%eax
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d3e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d41:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d47:	e8 c4 ed ff ff       	call   800b10 <sys_getenvid>
  801d4c:	83 ec 0c             	sub    $0xc,%esp
  801d4f:	ff 75 0c             	pushl  0xc(%ebp)
  801d52:	ff 75 08             	pushl  0x8(%ebp)
  801d55:	56                   	push   %esi
  801d56:	50                   	push   %eax
  801d57:	68 a0 27 80 00       	push   $0x8027a0
  801d5c:	e8 47 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d61:	83 c4 18             	add    $0x18,%esp
  801d64:	53                   	push   %ebx
  801d65:	ff 75 10             	pushl  0x10(%ebp)
  801d68:	e8 ea e3 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d6d:	c7 04 24 54 22 80 00 	movl   $0x802254,(%esp)
  801d74:	e8 2f e4 ff ff       	call   8001a8 <cprintf>
  801d79:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d7c:	cc                   	int3   
  801d7d:	eb fd                	jmp    801d7c <_panic+0x43>

00801d7f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801d85:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d8c:	75 36                	jne    801dc4 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801d8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801d93:	8b 40 48             	mov    0x48(%eax),%eax
  801d96:	83 ec 04             	sub    $0x4,%esp
  801d99:	68 07 0e 00 00       	push   $0xe07
  801d9e:	68 00 f0 bf ee       	push   $0xeebff000
  801da3:	50                   	push   %eax
  801da4:	e8 a5 ed ff ff       	call   800b4e <sys_page_alloc>
		if (ret < 0) {
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	79 14                	jns    801dc4 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801db0:	83 ec 04             	sub    $0x4,%esp
  801db3:	68 c4 27 80 00       	push   $0x8027c4
  801db8:	6a 23                	push   $0x23
  801dba:	68 ec 27 80 00       	push   $0x8027ec
  801dbf:	e8 75 ff ff ff       	call   801d39 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801dc4:	a1 04 40 80 00       	mov    0x804004,%eax
  801dc9:	8b 40 48             	mov    0x48(%eax),%eax
  801dcc:	83 ec 08             	sub    $0x8,%esp
  801dcf:	68 e7 1d 80 00       	push   $0x801de7
  801dd4:	50                   	push   %eax
  801dd5:	e8 bf ee ff ff       	call   800c99 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801de7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801de8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ded:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801def:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801df2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801df6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801dfb:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801dff:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801e01:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e04:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801e05:	83 c4 04             	add    $0x4,%esp
        popfl
  801e08:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801e09:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e0a:	c3                   	ret    

00801e0b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	8b 75 08             	mov    0x8(%ebp),%esi
  801e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e16:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e20:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	50                   	push   %eax
  801e27:	e8 d2 ee ff ff       	call   800cfe <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	75 10                	jne    801e43 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801e33:	a1 04 40 80 00       	mov    0x804004,%eax
  801e38:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801e3b:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801e3e:	8b 40 70             	mov    0x70(%eax),%eax
  801e41:	eb 0a                	jmp    801e4d <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801e43:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801e48:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801e4d:	85 f6                	test   %esi,%esi
  801e4f:	74 02                	je     801e53 <ipc_recv+0x48>
  801e51:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801e53:	85 db                	test   %ebx,%ebx
  801e55:	74 02                	je     801e59 <ipc_recv+0x4e>
  801e57:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801e59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5d                   	pop    %ebp
  801e5f:	c3                   	ret    

00801e60 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	57                   	push   %edi
  801e64:	56                   	push   %esi
  801e65:	53                   	push   %ebx
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801e72:	85 db                	test   %ebx,%ebx
  801e74:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e79:	0f 44 d8             	cmove  %eax,%ebx
  801e7c:	eb 1c                	jmp    801e9a <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801e7e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e81:	74 12                	je     801e95 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801e83:	50                   	push   %eax
  801e84:	68 fa 27 80 00       	push   $0x8027fa
  801e89:	6a 40                	push   $0x40
  801e8b:	68 0c 28 80 00       	push   $0x80280c
  801e90:	e8 a4 fe ff ff       	call   801d39 <_panic>
        sys_yield();
  801e95:	e8 95 ec ff ff       	call   800b2f <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801e9a:	ff 75 14             	pushl  0x14(%ebp)
  801e9d:	53                   	push   %ebx
  801e9e:	56                   	push   %esi
  801e9f:	57                   	push   %edi
  801ea0:	e8 36 ee ff ff       	call   800cdb <sys_ipc_try_send>
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	75 d2                	jne    801e7e <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    

00801eb4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ebf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ec2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec8:	8b 52 50             	mov    0x50(%edx),%edx
  801ecb:	39 ca                	cmp    %ecx,%edx
  801ecd:	75 0d                	jne    801edc <ipc_find_env+0x28>
			return envs[i].env_id;
  801ecf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ed2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ed7:	8b 40 48             	mov    0x48(%eax),%eax
  801eda:	eb 0f                	jmp    801eeb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801edc:	83 c0 01             	add    $0x1,%eax
  801edf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee4:	75 d9                	jne    801ebf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef3:	89 d0                	mov    %edx,%eax
  801ef5:	c1 e8 16             	shr    $0x16,%eax
  801ef8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f04:	f6 c1 01             	test   $0x1,%cl
  801f07:	74 1d                	je     801f26 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f09:	c1 ea 0c             	shr    $0xc,%edx
  801f0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f13:	f6 c2 01             	test   $0x1,%dl
  801f16:	74 0e                	je     801f26 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f18:	c1 ea 0c             	shr    $0xc,%edx
  801f1b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f22:	ef 
  801f23:	0f b7 c0             	movzwl %ax,%eax
}
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
  801f28:	66 90                	xchg   %ax,%ax
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
