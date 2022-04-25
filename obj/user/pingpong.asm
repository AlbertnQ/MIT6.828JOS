
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 db 0e 00 00       	call   800f1c <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ca 0a 00 00       	call   800b19 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 e0 21 80 00       	push   $0x8021e0
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 41 10 00 00       	call   8010ad <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 d9 0f 00 00       	call   801058 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 90 0a 00 00       	call   800b19 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 f6 21 80 00       	push   $0x8021f6
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 ff 0f 00 00       	call   8010ad <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 4b 0a 00 00       	call   800b19 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 f6 11 00 00       	call   801305 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 bf 09 00 00       	call   800ad8 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 4d 09 00 00       	call   800a9b <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 f2 08 00 00       	call   800a9b <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 27 1d 00 00       	call   801f40 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 14 1e 00 00       	call   802070 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 13 22 80 00 	movsbl 0x802213(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 a7 03 00 00    	je     8006ab <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	eb 07                	jmp    800348 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800344:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	0f b6 07             	movzbl (%edi),%eax
  800351:	0f b6 d0             	movzbl %al,%edx
  800354:	83 e8 23             	sub    $0x23,%eax
  800357:	3c 55                	cmp    $0x55,%al
  800359:	0f 87 31 03 00 00    	ja     800690 <vprintfmt+0x3a8>
  80035f:	0f b6 c0             	movzbl %al,%eax
  800362:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800370:	eb d6                	jmp    800348 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	b8 00 00 00 00       	mov    $0x0,%eax
  80037a:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800380:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800384:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800387:	8d 72 d0             	lea    -0x30(%edx),%esi
  80038a:	83 fe 09             	cmp    $0x9,%esi
  80038d:	77 34                	ja     8003c3 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800392:	eb e9                	jmp    80037d <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 50 04             	lea    0x4(%eax),%edx
  80039a:	89 55 14             	mov    %edx,0x14(%ebp)
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a5:	eb 22                	jmp    8003c9 <vprintfmt+0xe1>
  8003a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	0f 48 c1             	cmovs  %ecx,%eax
  8003af:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	eb 91                	jmp    800348 <vprintfmt+0x60>
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c1:	eb 85                	jmp    800348 <vprintfmt+0x60>
  8003c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003c6:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8003c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cd:	0f 89 75 ff ff ff    	jns    800348 <vprintfmt+0x60>
				width = precision, precision = -1;
  8003d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003e0:	e9 63 ff ff ff       	jmp    800348 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e5:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 57 ff ff ff       	jmp    800348 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 01 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x145>
  800422:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 2b 22 80 00       	push   $0x80222b
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 91 fe ff ff       	call   8002cb <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 c9 fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 35 27 80 00       	push   $0x802735
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 79 fe ff ff       	call   8002cb <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b1 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 24 22 80 00       	mov    $0x802224,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x228>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 cc             	pushl  -0x34(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 a1 02 00 00       	call   800733 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c3>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x216>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x216>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x242>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x242>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x273>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f5>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f5>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x27b>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 9f fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800573:	7e 16                	jle    80058b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 08             	lea    0x8(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 50 04             	mov    0x4(%eax),%edx
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800589:	eb 34                	jmp    8005bf <vprintfmt+0x2d7>
	else if (lflag)
  80058b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80058f:	74 18                	je     8005a9 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 c1                	mov    %eax,%ecx
  8005a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a7:	eb 16                	jmp    8005bf <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	89 c1                	mov    %eax,%ecx
  8005b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ce:	0f 89 88 00 00 00    	jns    80065c <vprintfmt+0x374>
				putch('-', putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 2d                	push   $0x2d
  8005da:	ff d6                	call   *%esi
				num = -(long long) num;
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e2:	f7 d8                	neg    %eax
  8005e4:	83 d2 00             	adc    $0x0,%edx
  8005e7:	f7 da                	neg    %edx
  8005e9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f1:	eb 69                	jmp    80065c <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 76 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800603:	eb 57                	jmp    80065c <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 30                	push   $0x30
  80060b:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80060d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 5c fc ff ff       	call   800274 <getuint>
			base = 8;
			goto number;
  800618:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80061b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800620:	eb 3a                	jmp    80065c <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 30                	push   $0x30
  800628:	ff d6                	call   *%esi
			putch('x', putdat);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 78                	push   $0x78
  800630:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800642:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800645:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064a:	eb 10                	jmp    80065c <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 1d fc ff ff       	call   800274 <getuint>
			base = 16;
  800657:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065c:	83 ec 0c             	sub    $0xc,%esp
  80065f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800663:	57                   	push   %edi
  800664:	ff 75 e0             	pushl  -0x20(%ebp)
  800667:	51                   	push   %ecx
  800668:	52                   	push   %edx
  800669:	50                   	push   %eax
  80066a:	89 da                	mov    %ebx,%edx
  80066c:	89 f0                	mov    %esi,%eax
  80066e:	e8 52 fb ff ff       	call   8001c5 <printnum>
			break;
  800673:	83 c4 20             	add    $0x20,%esp
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800679:	e9 90 fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	52                   	push   %edx
  800683:	ff d6                	call   *%esi
			break;
  800685:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068b:	e9 7e fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 25                	push   $0x25
  800696:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	eb 03                	jmp    8006a0 <vprintfmt+0x3b8>
  80069d:	83 ef 01             	sub    $0x1,%edi
  8006a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a4:	75 f7                	jne    80069d <vprintfmt+0x3b5>
  8006a6:	e9 63 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ae:	5b                   	pop    %ebx
  8006af:	5e                   	pop    %esi
  8006b0:	5f                   	pop    %edi
  8006b1:	5d                   	pop    %ebp
  8006b2:	c3                   	ret    

008006b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 18             	sub    $0x18,%esp
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 26                	je     8006fa <vsnprintf+0x47>
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e 22                	jle    8006fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d8:	ff 75 14             	pushl  0x14(%ebp)
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	50                   	push   %eax
  8006e2:	68 ae 02 80 00       	push   $0x8002ae
  8006e7:	e8 fc fb ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb 05                	jmp    8006ff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070a:	50                   	push   %eax
  80070b:	ff 75 10             	pushl  0x10(%ebp)
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	ff 75 08             	pushl  0x8(%ebp)
  800714:	e8 9a ff ff ff       	call   8006b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
  800726:	eb 03                	jmp    80072b <strlen+0x10>
		n++;
  800728:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072f:	75 f7                	jne    800728 <strlen+0xd>
		n++;
	return n;
}
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800739:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073c:	ba 00 00 00 00       	mov    $0x0,%edx
  800741:	eb 03                	jmp    800746 <strnlen+0x13>
		n++;
  800743:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800746:	39 c2                	cmp    %eax,%edx
  800748:	74 08                	je     800752 <strnlen+0x1f>
  80074a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074e:	75 f3                	jne    800743 <strnlen+0x10>
  800750:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075e:	89 c2                	mov    %eax,%edx
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	83 c1 01             	add    $0x1,%ecx
  800766:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076d:	84 db                	test   %bl,%bl
  80076f:	75 ef                	jne    800760 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800771:	5b                   	pop    %ebx
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077b:	53                   	push   %ebx
  80077c:	e8 9a ff ff ff       	call   80071b <strlen>
  800781:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800784:	ff 75 0c             	pushl  0xc(%ebp)
  800787:	01 d8                	add    %ebx,%eax
  800789:	50                   	push   %eax
  80078a:	e8 c5 ff ff ff       	call   800754 <strcpy>
	return dst;
}
  80078f:	89 d8                	mov    %ebx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	8b 75 08             	mov    0x8(%ebp),%esi
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	89 f3                	mov    %esi,%ebx
  8007a3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a6:	89 f2                	mov    %esi,%edx
  8007a8:	eb 0f                	jmp    8007b9 <strncpy+0x23>
		*dst++ = *src;
  8007aa:	83 c2 01             	add    $0x1,%edx
  8007ad:	0f b6 01             	movzbl (%ecx),%eax
  8007b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	39 da                	cmp    %ebx,%edx
  8007bb:	75 ed                	jne    8007aa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	56                   	push   %esi
  8007c7:	53                   	push   %ebx
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ce:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 21                	je     8007f8 <strlcpy+0x35>
  8007d7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007db:	89 f2                	mov    %esi,%edx
  8007dd:	eb 09                	jmp    8007e8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e8:	39 c2                	cmp    %eax,%edx
  8007ea:	74 09                	je     8007f5 <strlcpy+0x32>
  8007ec:	0f b6 19             	movzbl (%ecx),%ebx
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ec                	jne    8007df <strlcpy+0x1c>
  8007f3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f8:	29 f0                	sub    %esi,%eax
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800807:	eb 06                	jmp    80080f <strcmp+0x11>
		p++, q++;
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	84 c0                	test   %al,%al
  800814:	74 04                	je     80081a <strcmp+0x1c>
  800816:	3a 02                	cmp    (%edx),%al
  800818:	74 ef                	je     800809 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081a:	0f b6 c0             	movzbl %al,%eax
  80081d:	0f b6 12             	movzbl (%edx),%edx
  800820:	29 d0                	sub    %edx,%eax
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800833:	eb 06                	jmp    80083b <strncmp+0x17>
		n--, p++, q++;
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083b:	39 d8                	cmp    %ebx,%eax
  80083d:	74 15                	je     800854 <strncmp+0x30>
  80083f:	0f b6 08             	movzbl (%eax),%ecx
  800842:	84 c9                	test   %cl,%cl
  800844:	74 04                	je     80084a <strncmp+0x26>
  800846:	3a 0a                	cmp    (%edx),%cl
  800848:	74 eb                	je     800835 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 00             	movzbl (%eax),%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
  800852:	eb 05                	jmp    800859 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800859:	5b                   	pop    %ebx
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800866:	eb 07                	jmp    80086f <strchr+0x13>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 0f                	je     80087b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	0f b6 10             	movzbl (%eax),%edx
  800872:	84 d2                	test   %dl,%dl
  800874:	75 f2                	jne    800868 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 03                	jmp    80088c <strfind+0xf>
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80088f:	38 ca                	cmp    %cl,%dl
  800891:	74 04                	je     800897 <strfind+0x1a>
  800893:	84 d2                	test   %dl,%dl
  800895:	75 f2                	jne    800889 <strfind+0xc>
			break;
	return (char *) s;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	57                   	push   %edi
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a5:	85 c9                	test   %ecx,%ecx
  8008a7:	74 36                	je     8008df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008af:	75 28                	jne    8008d9 <memset+0x40>
  8008b1:	f6 c1 03             	test   $0x3,%cl
  8008b4:	75 23                	jne    8008d9 <memset+0x40>
		c &= 0xFF;
  8008b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ba:	89 d3                	mov    %edx,%ebx
  8008bc:	c1 e3 08             	shl    $0x8,%ebx
  8008bf:	89 d6                	mov    %edx,%esi
  8008c1:	c1 e6 18             	shl    $0x18,%esi
  8008c4:	89 d0                	mov    %edx,%eax
  8008c6:	c1 e0 10             	shl    $0x10,%eax
  8008c9:	09 f0                	or     %esi,%eax
  8008cb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008cd:	89 d8                	mov    %ebx,%eax
  8008cf:	09 d0                	or     %edx,%eax
  8008d1:	c1 e9 02             	shr    $0x2,%ecx
  8008d4:	fc                   	cld    
  8008d5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d7:	eb 06                	jmp    8008df <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dc:	fc                   	cld    
  8008dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008df:	89 f8                	mov    %edi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5f                   	pop    %edi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	57                   	push   %edi
  8008ea:	56                   	push   %esi
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f4:	39 c6                	cmp    %eax,%esi
  8008f6:	73 35                	jae    80092d <memmove+0x47>
  8008f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	73 2e                	jae    80092d <memmove+0x47>
		s += n;
		d += n;
  8008ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800902:	89 d6                	mov    %edx,%esi
  800904:	09 fe                	or     %edi,%esi
  800906:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090c:	75 13                	jne    800921 <memmove+0x3b>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 0e                	jne    800921 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800913:	83 ef 04             	sub    $0x4,%edi
  800916:	8d 72 fc             	lea    -0x4(%edx),%esi
  800919:	c1 e9 02             	shr    $0x2,%ecx
  80091c:	fd                   	std    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 09                	jmp    80092a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800921:	83 ef 01             	sub    $0x1,%edi
  800924:	8d 72 ff             	lea    -0x1(%edx),%esi
  800927:	fd                   	std    
  800928:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092a:	fc                   	cld    
  80092b:	eb 1d                	jmp    80094a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	89 f2                	mov    %esi,%edx
  80092f:	09 c2                	or     %eax,%edx
  800931:	f6 c2 03             	test   $0x3,%dl
  800934:	75 0f                	jne    800945 <memmove+0x5f>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0a                	jne    800945 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 05                	jmp    80094a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800951:	ff 75 10             	pushl  0x10(%ebp)
  800954:	ff 75 0c             	pushl  0xc(%ebp)
  800957:	ff 75 08             	pushl  0x8(%ebp)
  80095a:	e8 87 ff ff ff       	call   8008e6 <memmove>
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c6                	mov    %eax,%esi
  80096e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	eb 1a                	jmp    80098d <memcmp+0x2c>
		if (*s1 != *s2)
  800973:	0f b6 08             	movzbl (%eax),%ecx
  800976:	0f b6 1a             	movzbl (%edx),%ebx
  800979:	38 d9                	cmp    %bl,%cl
  80097b:	74 0a                	je     800987 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097d:	0f b6 c1             	movzbl %cl,%eax
  800980:	0f b6 db             	movzbl %bl,%ebx
  800983:	29 d8                	sub    %ebx,%eax
  800985:	eb 0f                	jmp    800996 <memcmp+0x35>
		s1++, s2++;
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098d:	39 f0                	cmp    %esi,%eax
  80098f:	75 e2                	jne    800973 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a1:	89 c1                	mov    %eax,%ecx
  8009a3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009aa:	eb 0a                	jmp    8009b6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ac:	0f b6 10             	movzbl (%eax),%edx
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	74 07                	je     8009ba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	39 c8                	cmp    %ecx,%eax
  8009b8:	72 f2                	jb     8009ac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c9:	eb 03                	jmp    8009ce <strtol+0x11>
		s++;
  8009cb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	3c 20                	cmp    $0x20,%al
  8009d3:	74 f6                	je     8009cb <strtol+0xe>
  8009d5:	3c 09                	cmp    $0x9,%al
  8009d7:	74 f2                	je     8009cb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d9:	3c 2b                	cmp    $0x2b,%al
  8009db:	75 0a                	jne    8009e7 <strtol+0x2a>
		s++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e5:	eb 11                	jmp    8009f8 <strtol+0x3b>
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ec:	3c 2d                	cmp    $0x2d,%al
  8009ee:	75 08                	jne    8009f8 <strtol+0x3b>
		s++, neg = 1;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fe:	75 15                	jne    800a15 <strtol+0x58>
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 10                	jne    800a15 <strtol+0x58>
  800a05:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a09:	75 7c                	jne    800a87 <strtol+0xca>
		s += 2, base = 16;
  800a0b:	83 c1 02             	add    $0x2,%ecx
  800a0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a13:	eb 16                	jmp    800a2b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a15:	85 db                	test   %ebx,%ebx
  800a17:	75 12                	jne    800a2b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a19:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a21:	75 08                	jne    800a2b <strtol+0x6e>
		s++, base = 8;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a33:	0f b6 11             	movzbl (%ecx),%edx
  800a36:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a39:	89 f3                	mov    %esi,%ebx
  800a3b:	80 fb 09             	cmp    $0x9,%bl
  800a3e:	77 08                	ja     800a48 <strtol+0x8b>
			dig = *s - '0';
  800a40:	0f be d2             	movsbl %dl,%edx
  800a43:	83 ea 30             	sub    $0x30,%edx
  800a46:	eb 22                	jmp    800a6a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4b:	89 f3                	mov    %esi,%ebx
  800a4d:	80 fb 19             	cmp    $0x19,%bl
  800a50:	77 08                	ja     800a5a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a52:	0f be d2             	movsbl %dl,%edx
  800a55:	83 ea 57             	sub    $0x57,%edx
  800a58:	eb 10                	jmp    800a6a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	80 fb 19             	cmp    $0x19,%bl
  800a62:	77 16                	ja     800a7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a64:	0f be d2             	movsbl %dl,%edx
  800a67:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6d:	7d 0b                	jge    800a7a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a76:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a78:	eb b9                	jmp    800a33 <strtol+0x76>

	if (endptr)
  800a7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7e:	74 0d                	je     800a8d <strtol+0xd0>
		*endptr = (char *) s;
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	89 0e                	mov    %ecx,(%esi)
  800a85:	eb 06                	jmp    800a8d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a87:	85 db                	test   %ebx,%ebx
  800a89:	74 98                	je     800a23 <strtol+0x66>
  800a8b:	eb 9e                	jmp    800a2b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	f7 da                	neg    %edx
  800a91:	85 ff                	test   %edi,%edi
  800a93:	0f 45 c2             	cmovne %edx,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	89 c7                	mov    %eax,%edi
  800ab0:	89 c6                	mov    %eax,%esi
  800ab2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_cgetc>:

int
sys_cgetc(void)
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
  800ac4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac9:	89 d1                	mov    %edx,%ecx
  800acb:	89 d3                	mov    %edx,%ebx
  800acd:	89 d7                	mov    %edx,%edi
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae6:	b8 03 00 00 00       	mov    $0x3,%eax
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	89 cb                	mov    %ecx,%ebx
  800af0:	89 cf                	mov    %ecx,%edi
  800af2:	89 ce                	mov    %ecx,%esi
  800af4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af6:	85 c0                	test   %eax,%eax
  800af8:	7e 17                	jle    800b11 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afa:	83 ec 0c             	sub    $0xc,%esp
  800afd:	50                   	push   %eax
  800afe:	6a 03                	push   $0x3
  800b00:	68 1f 25 80 00       	push   $0x80251f
  800b05:	6a 23                	push   $0x23
  800b07:	68 3c 25 80 00       	push   $0x80253c
  800b0c:	e8 13 13 00 00       	call   801e24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b24:	b8 02 00 00 00       	mov    $0x2,%eax
  800b29:	89 d1                	mov    %edx,%ecx
  800b2b:	89 d3                	mov    %edx,%ebx
  800b2d:	89 d7                	mov    %edx,%edi
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_yield>:

void
sys_yield(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	be 00 00 00 00       	mov    $0x0,%esi
  800b65:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	89 f7                	mov    %esi,%edi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 04                	push   $0x4
  800b81:	68 1f 25 80 00       	push   $0x80251f
  800b86:	6a 23                	push   $0x23
  800b88:	68 3c 25 80 00       	push   $0x80253c
  800b8d:	e8 92 12 00 00       	call   801e24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 05                	push   $0x5
  800bc3:	68 1f 25 80 00       	push   $0x80251f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 3c 25 80 00       	push   $0x80253c
  800bcf:	e8 50 12 00 00       	call   801e24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 06 00 00 00       	mov    $0x6,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 06                	push   $0x6
  800c05:	68 1f 25 80 00       	push   $0x80251f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 3c 25 80 00       	push   $0x80253c
  800c11:	e8 0e 12 00 00       	call   801e24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 08                	push   $0x8
  800c47:	68 1f 25 80 00       	push   $0x80251f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 3c 25 80 00       	push   $0x80253c
  800c53:	e8 cc 11 00 00       	call   801e24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 09                	push   $0x9
  800c89:	68 1f 25 80 00       	push   $0x80251f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 3c 25 80 00       	push   $0x80253c
  800c95:	e8 8a 11 00 00       	call   801e24 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 0a                	push   $0xa
  800ccb:	68 1f 25 80 00       	push   $0x80251f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 3c 25 80 00       	push   $0x80253c
  800cd7:	e8 48 11 00 00       	call   801e24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d00:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d15:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 cb                	mov    %ecx,%ebx
  800d1f:	89 cf                	mov    %ecx,%edi
  800d21:	89 ce                	mov    %ecx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 0d                	push   $0xd
  800d2f:	68 1f 25 80 00       	push   $0x80251f
  800d34:	6a 23                	push   $0x23
  800d36:	68 3c 25 80 00       	push   $0x80253c
  800d3b:	e8 e4 10 00 00       	call   801e24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800d4f:	89 d3                	mov    %edx,%ebx
  800d51:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800d54:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d5b:	f6 c5 04             	test   $0x4,%ch
  800d5e:	74 2f                	je     800d8f <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	68 07 0e 00 00       	push   $0xe07
  800d68:	53                   	push   %ebx
  800d69:	50                   	push   %eax
  800d6a:	53                   	push   %ebx
  800d6b:	6a 00                	push   $0x0
  800d6d:	e8 28 fe ff ff       	call   800b9a <sys_page_map>
  800d72:	83 c4 20             	add    $0x20,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	0f 89 a0 00 00 00    	jns    800e1d <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800d7d:	50                   	push   %eax
  800d7e:	68 4a 25 80 00       	push   $0x80254a
  800d83:	6a 4d                	push   $0x4d
  800d85:	68 62 25 80 00       	push   $0x802562
  800d8a:	e8 95 10 00 00       	call   801e24 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800d8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d96:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d9c:	74 57                	je     800df5 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	68 05 08 00 00       	push   $0x805
  800da6:	53                   	push   %ebx
  800da7:	50                   	push   %eax
  800da8:	53                   	push   %ebx
  800da9:	6a 00                	push   $0x0
  800dab:	e8 ea fd ff ff       	call   800b9a <sys_page_map>
  800db0:	83 c4 20             	add    $0x20,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	79 12                	jns    800dc9 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800db7:	50                   	push   %eax
  800db8:	68 6d 25 80 00       	push   $0x80256d
  800dbd:	6a 50                	push   $0x50
  800dbf:	68 62 25 80 00       	push   $0x802562
  800dc4:	e8 5b 10 00 00       	call   801e24 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	68 05 08 00 00       	push   $0x805
  800dd1:	53                   	push   %ebx
  800dd2:	6a 00                	push   $0x0
  800dd4:	53                   	push   %ebx
  800dd5:	6a 00                	push   $0x0
  800dd7:	e8 be fd ff ff       	call   800b9a <sys_page_map>
  800ddc:	83 c4 20             	add    $0x20,%esp
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	79 3a                	jns    800e1d <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800de3:	50                   	push   %eax
  800de4:	68 6d 25 80 00       	push   $0x80256d
  800de9:	6a 53                	push   $0x53
  800deb:	68 62 25 80 00       	push   $0x802562
  800df0:	e8 2f 10 00 00       	call   801e24 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	6a 05                	push   $0x5
  800dfa:	53                   	push   %ebx
  800dfb:	50                   	push   %eax
  800dfc:	53                   	push   %ebx
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 96 fd ff ff       	call   800b9a <sys_page_map>
  800e04:	83 c4 20             	add    $0x20,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	79 12                	jns    800e1d <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800e0b:	50                   	push   %eax
  800e0c:	68 81 25 80 00       	push   $0x802581
  800e11:	6a 56                	push   $0x56
  800e13:	68 62 25 80 00       	push   $0x802562
  800e18:	e8 07 10 00 00       	call   801e24 <_panic>
	}
	return 0;
}
  800e1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e25:	c9                   	leave  
  800e26:	c3                   	ret    

00800e27 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e31:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e35:	74 2d                	je     800e64 <pgfault+0x3d>
  800e37:	89 d8                	mov    %ebx,%eax
  800e39:	c1 e8 16             	shr    $0x16,%eax
  800e3c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e43:	a8 01                	test   $0x1,%al
  800e45:	74 1d                	je     800e64 <pgfault+0x3d>
  800e47:	89 d8                	mov    %ebx,%eax
  800e49:	c1 e8 0c             	shr    $0xc,%eax
  800e4c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e53:	f6 c2 01             	test   $0x1,%dl
  800e56:	74 0c                	je     800e64 <pgfault+0x3d>
  800e58:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e5f:	f6 c4 08             	test   $0x8,%ah
  800e62:	75 14                	jne    800e78 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	68 00 26 80 00       	push   $0x802600
  800e6c:	6a 1d                	push   $0x1d
  800e6e:	68 62 25 80 00       	push   $0x802562
  800e73:	e8 ac 0f 00 00       	call   801e24 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800e78:	e8 9c fc ff ff       	call   800b19 <sys_getenvid>
  800e7d:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	6a 07                	push   $0x7
  800e84:	68 00 f0 7f 00       	push   $0x7ff000
  800e89:	50                   	push   %eax
  800e8a:	e8 c8 fc ff ff       	call   800b57 <sys_page_alloc>
  800e8f:	83 c4 10             	add    $0x10,%esp
  800e92:	85 c0                	test   %eax,%eax
  800e94:	79 12                	jns    800ea8 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800e96:	50                   	push   %eax
  800e97:	68 30 26 80 00       	push   $0x802630
  800e9c:	6a 2b                	push   $0x2b
  800e9e:	68 62 25 80 00       	push   $0x802562
  800ea3:	e8 7c 0f 00 00       	call   801e24 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800ea8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	68 00 10 00 00       	push   $0x1000
  800eb6:	53                   	push   %ebx
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	e8 8d fa ff ff       	call   80094e <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800ec1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec8:	53                   	push   %ebx
  800ec9:	56                   	push   %esi
  800eca:	68 00 f0 7f 00       	push   $0x7ff000
  800ecf:	56                   	push   %esi
  800ed0:	e8 c5 fc ff ff       	call   800b9a <sys_page_map>
  800ed5:	83 c4 20             	add    $0x20,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	79 12                	jns    800eee <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800edc:	50                   	push   %eax
  800edd:	68 94 25 80 00       	push   $0x802594
  800ee2:	6a 2f                	push   $0x2f
  800ee4:	68 62 25 80 00       	push   $0x802562
  800ee9:	e8 36 0f 00 00       	call   801e24 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800eee:	83 ec 08             	sub    $0x8,%esp
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	56                   	push   %esi
  800ef7:	e8 e0 fc ff ff       	call   800bdc <sys_page_unmap>
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	79 12                	jns    800f15 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  800f03:	50                   	push   %eax
  800f04:	68 54 26 80 00       	push   $0x802654
  800f09:	6a 32                	push   $0x32
  800f0b:	68 62 25 80 00       	push   $0x802562
  800f10:	e8 0f 0f 00 00       	call   801e24 <_panic>
	//panic("pgfault not implemented");
}
  800f15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f24:	68 27 0e 80 00       	push   $0x800e27
  800f29:	e8 3c 0f 00 00       	call   801e6a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f2e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f33:	cd 30                	int    $0x30
  800f35:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 12                	jns    800f50 <fork+0x34>
		panic("sys_exofork:%e", envid);
  800f3e:	50                   	push   %eax
  800f3f:	68 b1 25 80 00       	push   $0x8025b1
  800f44:	6a 75                	push   $0x75
  800f46:	68 62 25 80 00       	push   $0x802562
  800f4b:	e8 d4 0e 00 00       	call   801e24 <_panic>
  800f50:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  800f52:	85 c0                	test   %eax,%eax
  800f54:	75 21                	jne    800f77 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f56:	e8 be fb ff ff       	call   800b19 <sys_getenvid>
  800f5b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f68:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f72:	e9 c0 00 00 00       	jmp    801037 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800f77:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800f7e:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f83:	89 d0                	mov    %edx,%eax
  800f85:	c1 e8 16             	shr    $0x16,%eax
  800f88:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8f:	a8 01                	test   $0x1,%al
  800f91:	74 20                	je     800fb3 <fork+0x97>
  800f93:	c1 ea 0c             	shr    $0xc,%edx
  800f96:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f9d:	a8 01                	test   $0x1,%al
  800f9f:	74 12                	je     800fb3 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fa1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fa8:	a8 04                	test   $0x4,%al
  800faa:	74 07                	je     800fb3 <fork+0x97>
			duppage(envid, PGNUM(addr));
  800fac:	89 f0                	mov    %esi,%eax
  800fae:	e8 95 fd ff ff       	call   800d48 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb6:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  800fbc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fbf:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  800fc5:	76 bc                	jbe    800f83 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  800fc7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fca:	c1 ea 0c             	shr    $0xc,%edx
  800fcd:	89 d8                	mov    %ebx,%eax
  800fcf:	e8 74 fd ff ff       	call   800d48 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	6a 07                	push   $0x7
  800fd9:	68 00 f0 bf ee       	push   $0xeebff000
  800fde:	53                   	push   %ebx
  800fdf:	e8 73 fb ff ff       	call   800b57 <sys_page_alloc>
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	74 15                	je     801000 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  800feb:	50                   	push   %eax
  800fec:	68 c0 25 80 00       	push   $0x8025c0
  800ff1:	68 86 00 00 00       	push   $0x86
  800ff6:	68 62 25 80 00       	push   $0x802562
  800ffb:	e8 24 0e 00 00       	call   801e24 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	68 d2 1e 80 00       	push   $0x801ed2
  801008:	53                   	push   %ebx
  801009:	e8 94 fc ff ff       	call   800ca2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80100e:	83 c4 08             	add    $0x8,%esp
  801011:	6a 02                	push   $0x2
  801013:	53                   	push   %ebx
  801014:	e8 05 fc ff ff       	call   800c1e <sys_env_set_status>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	74 15                	je     801035 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801020:	50                   	push   %eax
  801021:	68 d2 25 80 00       	push   $0x8025d2
  801026:	68 8c 00 00 00       	push   $0x8c
  80102b:	68 62 25 80 00       	push   $0x802562
  801030:	e8 ef 0d 00 00       	call   801e24 <_panic>

	return envid;
  801035:	89 d8                	mov    %ebx,%eax
	    
}
  801037:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    

0080103e <sfork>:

// Challenge!
int
sfork(void)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801044:	68 e8 25 80 00       	push   $0x8025e8
  801049:	68 96 00 00 00       	push   $0x96
  80104e:	68 62 25 80 00       	push   $0x802562
  801053:	e8 cc 0d 00 00       	call   801e24 <_panic>

00801058 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	8b 75 08             	mov    0x8(%ebp),%esi
  801060:	8b 45 0c             	mov    0xc(%ebp),%eax
  801063:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801066:	85 c0                	test   %eax,%eax
  801068:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80106d:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	50                   	push   %eax
  801074:	e8 8e fc ff ff       	call   800d07 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	75 10                	jne    801090 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801080:	a1 04 40 80 00       	mov    0x804004,%eax
  801085:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801088:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  80108b:	8b 40 70             	mov    0x70(%eax),%eax
  80108e:	eb 0a                	jmp    80109a <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801090:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801095:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  80109a:	85 f6                	test   %esi,%esi
  80109c:	74 02                	je     8010a0 <ipc_recv+0x48>
  80109e:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  8010a0:	85 db                	test   %ebx,%ebx
  8010a2:	74 02                	je     8010a6 <ipc_recv+0x4e>
  8010a4:	89 13                	mov    %edx,(%ebx)

    return r;
}
  8010a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	57                   	push   %edi
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8010bf:	85 db                	test   %ebx,%ebx
  8010c1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010c6:	0f 44 d8             	cmove  %eax,%ebx
  8010c9:	eb 1c                	jmp    8010e7 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  8010cb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010ce:	74 12                	je     8010e2 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  8010d0:	50                   	push   %eax
  8010d1:	68 73 26 80 00       	push   $0x802673
  8010d6:	6a 40                	push   $0x40
  8010d8:	68 85 26 80 00       	push   $0x802685
  8010dd:	e8 42 0d 00 00       	call   801e24 <_panic>
        sys_yield();
  8010e2:	e8 51 fa ff ff       	call   800b38 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8010e7:	ff 75 14             	pushl  0x14(%ebp)
  8010ea:	53                   	push   %ebx
  8010eb:	56                   	push   %esi
  8010ec:	57                   	push   %edi
  8010ed:	e8 f2 fb ff ff       	call   800ce4 <sys_ipc_try_send>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	75 d2                	jne    8010cb <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80110c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80110f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801115:	8b 52 50             	mov    0x50(%edx),%edx
  801118:	39 ca                	cmp    %ecx,%edx
  80111a:	75 0d                	jne    801129 <ipc_find_env+0x28>
			return envs[i].env_id;
  80111c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80111f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801124:	8b 40 48             	mov    0x48(%eax),%eax
  801127:	eb 0f                	jmp    801138 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801129:	83 c0 01             	add    $0x1,%eax
  80112c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801131:	75 d9                	jne    80110c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801133:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
  801140:	05 00 00 00 30       	add    $0x30000000,%eax
  801145:	c1 e8 0c             	shr    $0xc,%eax
}
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	05 00 00 00 30       	add    $0x30000000,%eax
  801155:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801167:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	c1 ea 16             	shr    $0x16,%edx
  801171:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801178:	f6 c2 01             	test   $0x1,%dl
  80117b:	74 11                	je     80118e <fd_alloc+0x2d>
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	c1 ea 0c             	shr    $0xc,%edx
  801182:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801189:	f6 c2 01             	test   $0x1,%dl
  80118c:	75 09                	jne    801197 <fd_alloc+0x36>
			*fd_store = fd;
  80118e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801190:	b8 00 00 00 00       	mov    $0x0,%eax
  801195:	eb 17                	jmp    8011ae <fd_alloc+0x4d>
  801197:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80119c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a1:	75 c9                	jne    80116c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b6:	83 f8 1f             	cmp    $0x1f,%eax
  8011b9:	77 36                	ja     8011f1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011bb:	c1 e0 0c             	shl    $0xc,%eax
  8011be:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c3:	89 c2                	mov    %eax,%edx
  8011c5:	c1 ea 16             	shr    $0x16,%edx
  8011c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cf:	f6 c2 01             	test   $0x1,%dl
  8011d2:	74 24                	je     8011f8 <fd_lookup+0x48>
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	c1 ea 0c             	shr    $0xc,%edx
  8011d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e0:	f6 c2 01             	test   $0x1,%dl
  8011e3:	74 1a                	je     8011ff <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e8:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ef:	eb 13                	jmp    801204 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f6:	eb 0c                	jmp    801204 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fd:	eb 05                	jmp    801204 <fd_lookup+0x54>
  8011ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120f:	ba 0c 27 80 00       	mov    $0x80270c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801214:	eb 13                	jmp    801229 <dev_lookup+0x23>
  801216:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801219:	39 08                	cmp    %ecx,(%eax)
  80121b:	75 0c                	jne    801229 <dev_lookup+0x23>
			*dev = devtab[i];
  80121d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801220:	89 01                	mov    %eax,(%ecx)
			return 0;
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
  801227:	eb 2e                	jmp    801257 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801229:	8b 02                	mov    (%edx),%eax
  80122b:	85 c0                	test   %eax,%eax
  80122d:	75 e7                	jne    801216 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122f:	a1 04 40 80 00       	mov    0x804004,%eax
  801234:	8b 40 48             	mov    0x48(%eax),%eax
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	51                   	push   %ecx
  80123b:	50                   	push   %eax
  80123c:	68 90 26 80 00       	push   $0x802690
  801241:	e8 6b ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  801246:	8b 45 0c             	mov    0xc(%ebp),%eax
  801249:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801257:	c9                   	leave  
  801258:	c3                   	ret    

00801259 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	83 ec 10             	sub    $0x10,%esp
  801261:	8b 75 08             	mov    0x8(%ebp),%esi
  801264:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801271:	c1 e8 0c             	shr    $0xc,%eax
  801274:	50                   	push   %eax
  801275:	e8 36 ff ff ff       	call   8011b0 <fd_lookup>
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 05                	js     801286 <fd_close+0x2d>
	    || fd != fd2)
  801281:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801284:	74 0c                	je     801292 <fd_close+0x39>
		return (must_exist ? r : 0);
  801286:	84 db                	test   %bl,%bl
  801288:	ba 00 00 00 00       	mov    $0x0,%edx
  80128d:	0f 44 c2             	cmove  %edx,%eax
  801290:	eb 41                	jmp    8012d3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	ff 36                	pushl  (%esi)
  80129b:	e8 66 ff ff ff       	call   801206 <dev_lookup>
  8012a0:	89 c3                	mov    %eax,%ebx
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 1a                	js     8012c3 <fd_close+0x6a>
		if (dev->dev_close)
  8012a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ac:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012af:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	74 0b                	je     8012c3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b8:	83 ec 0c             	sub    $0xc,%esp
  8012bb:	56                   	push   %esi
  8012bc:	ff d0                	call   *%eax
  8012be:	89 c3                	mov    %eax,%ebx
  8012c0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	56                   	push   %esi
  8012c7:	6a 00                	push   $0x0
  8012c9:	e8 0e f9 ff ff       	call   800bdc <sys_page_unmap>
	return r;
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	89 d8                	mov    %ebx,%eax
}
  8012d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 c4 fe ff ff       	call   8011b0 <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 10                	js     801303 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	6a 01                	push   $0x1
  8012f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fb:	e8 59 ff ff ff       	call   801259 <fd_close>
  801300:	83 c4 10             	add    $0x10,%esp
}
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <close_all>:

void
close_all(void)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	53                   	push   %ebx
  801309:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	53                   	push   %ebx
  801315:	e8 c0 ff ff ff       	call   8012da <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80131a:	83 c3 01             	add    $0x1,%ebx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	83 fb 20             	cmp    $0x20,%ebx
  801323:	75 ec                	jne    801311 <close_all+0xc>
		close(i);
}
  801325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	57                   	push   %edi
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
  801330:	83 ec 2c             	sub    $0x2c,%esp
  801333:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801336:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	ff 75 08             	pushl  0x8(%ebp)
  80133d:	e8 6e fe ff ff       	call   8011b0 <fd_lookup>
  801342:	83 c4 08             	add    $0x8,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	0f 88 c1 00 00 00    	js     80140e <dup+0xe4>
		return r;
	close(newfdnum);
  80134d:	83 ec 0c             	sub    $0xc,%esp
  801350:	56                   	push   %esi
  801351:	e8 84 ff ff ff       	call   8012da <close>

	newfd = INDEX2FD(newfdnum);
  801356:	89 f3                	mov    %esi,%ebx
  801358:	c1 e3 0c             	shl    $0xc,%ebx
  80135b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801361:	83 c4 04             	add    $0x4,%esp
  801364:	ff 75 e4             	pushl  -0x1c(%ebp)
  801367:	e8 de fd ff ff       	call   80114a <fd2data>
  80136c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136e:	89 1c 24             	mov    %ebx,(%esp)
  801371:	e8 d4 fd ff ff       	call   80114a <fd2data>
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137c:	89 f8                	mov    %edi,%eax
  80137e:	c1 e8 16             	shr    $0x16,%eax
  801381:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801388:	a8 01                	test   $0x1,%al
  80138a:	74 37                	je     8013c3 <dup+0x99>
  80138c:	89 f8                	mov    %edi,%eax
  80138e:	c1 e8 0c             	shr    $0xc,%eax
  801391:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801398:	f6 c2 01             	test   $0x1,%dl
  80139b:	74 26                	je     8013c3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b0:	6a 00                	push   $0x0
  8013b2:	57                   	push   %edi
  8013b3:	6a 00                	push   $0x0
  8013b5:	e8 e0 f7 ff ff       	call   800b9a <sys_page_map>
  8013ba:	89 c7                	mov    %eax,%edi
  8013bc:	83 c4 20             	add    $0x20,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 2e                	js     8013f1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c6:	89 d0                	mov    %edx,%eax
  8013c8:	c1 e8 0c             	shr    $0xc,%eax
  8013cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013da:	50                   	push   %eax
  8013db:	53                   	push   %ebx
  8013dc:	6a 00                	push   $0x0
  8013de:	52                   	push   %edx
  8013df:	6a 00                	push   $0x0
  8013e1:	e8 b4 f7 ff ff       	call   800b9a <sys_page_map>
  8013e6:	89 c7                	mov    %eax,%edi
  8013e8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013eb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ed:	85 ff                	test   %edi,%edi
  8013ef:	79 1d                	jns    80140e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 e0 f7 ff ff       	call   800bdc <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fc:	83 c4 08             	add    $0x8,%esp
  8013ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801402:	6a 00                	push   $0x0
  801404:	e8 d3 f7 ff ff       	call   800bdc <sys_page_unmap>
	return r;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 f8                	mov    %edi,%eax
}
  80140e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5f                   	pop    %edi
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    

00801416 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	83 ec 14             	sub    $0x14,%esp
  80141d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801420:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	53                   	push   %ebx
  801425:	e8 86 fd ff ff       	call   8011b0 <fd_lookup>
  80142a:	83 c4 08             	add    $0x8,%esp
  80142d:	89 c2                	mov    %eax,%edx
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 6d                	js     8014a0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143d:	ff 30                	pushl  (%eax)
  80143f:	e8 c2 fd ff ff       	call   801206 <dev_lookup>
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	78 4c                	js     801497 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144e:	8b 42 08             	mov    0x8(%edx),%eax
  801451:	83 e0 03             	and    $0x3,%eax
  801454:	83 f8 01             	cmp    $0x1,%eax
  801457:	75 21                	jne    80147a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801459:	a1 04 40 80 00       	mov    0x804004,%eax
  80145e:	8b 40 48             	mov    0x48(%eax),%eax
  801461:	83 ec 04             	sub    $0x4,%esp
  801464:	53                   	push   %ebx
  801465:	50                   	push   %eax
  801466:	68 d1 26 80 00       	push   $0x8026d1
  80146b:	e8 41 ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801478:	eb 26                	jmp    8014a0 <read+0x8a>
	}
	if (!dev->dev_read)
  80147a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147d:	8b 40 08             	mov    0x8(%eax),%eax
  801480:	85 c0                	test   %eax,%eax
  801482:	74 17                	je     80149b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	ff 75 10             	pushl  0x10(%ebp)
  80148a:	ff 75 0c             	pushl  0xc(%ebp)
  80148d:	52                   	push   %edx
  80148e:	ff d0                	call   *%eax
  801490:	89 c2                	mov    %eax,%edx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb 09                	jmp    8014a0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	89 c2                	mov    %eax,%edx
  801499:	eb 05                	jmp    8014a0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014a0:	89 d0                	mov    %edx,%eax
  8014a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	57                   	push   %edi
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bb:	eb 21                	jmp    8014de <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bd:	83 ec 04             	sub    $0x4,%esp
  8014c0:	89 f0                	mov    %esi,%eax
  8014c2:	29 d8                	sub    %ebx,%eax
  8014c4:	50                   	push   %eax
  8014c5:	89 d8                	mov    %ebx,%eax
  8014c7:	03 45 0c             	add    0xc(%ebp),%eax
  8014ca:	50                   	push   %eax
  8014cb:	57                   	push   %edi
  8014cc:	e8 45 ff ff ff       	call   801416 <read>
		if (m < 0)
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 10                	js     8014e8 <readn+0x41>
			return m;
		if (m == 0)
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	74 0a                	je     8014e6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014dc:	01 c3                	add    %eax,%ebx
  8014de:	39 f3                	cmp    %esi,%ebx
  8014e0:	72 db                	jb     8014bd <readn+0x16>
  8014e2:	89 d8                	mov    %ebx,%eax
  8014e4:	eb 02                	jmp    8014e8 <readn+0x41>
  8014e6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014eb:	5b                   	pop    %ebx
  8014ec:	5e                   	pop    %esi
  8014ed:	5f                   	pop    %edi
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 14             	sub    $0x14,%esp
  8014f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	53                   	push   %ebx
  8014ff:	e8 ac fc ff ff       	call   8011b0 <fd_lookup>
  801504:	83 c4 08             	add    $0x8,%esp
  801507:	89 c2                	mov    %eax,%edx
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 68                	js     801575 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801517:	ff 30                	pushl  (%eax)
  801519:	e8 e8 fc ff ff       	call   801206 <dev_lookup>
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	85 c0                	test   %eax,%eax
  801523:	78 47                	js     80156c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801528:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152c:	75 21                	jne    80154f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152e:	a1 04 40 80 00       	mov    0x804004,%eax
  801533:	8b 40 48             	mov    0x48(%eax),%eax
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	53                   	push   %ebx
  80153a:	50                   	push   %eax
  80153b:	68 ed 26 80 00       	push   $0x8026ed
  801540:	e8 6c ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154d:	eb 26                	jmp    801575 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801552:	8b 52 0c             	mov    0xc(%edx),%edx
  801555:	85 d2                	test   %edx,%edx
  801557:	74 17                	je     801570 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801559:	83 ec 04             	sub    $0x4,%esp
  80155c:	ff 75 10             	pushl  0x10(%ebp)
  80155f:	ff 75 0c             	pushl  0xc(%ebp)
  801562:	50                   	push   %eax
  801563:	ff d2                	call   *%edx
  801565:	89 c2                	mov    %eax,%edx
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	eb 09                	jmp    801575 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	eb 05                	jmp    801575 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801570:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801575:	89 d0                	mov    %edx,%eax
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <seek>:

int
seek(int fdnum, off_t offset)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801582:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	ff 75 08             	pushl  0x8(%ebp)
  801589:	e8 22 fc ff ff       	call   8011b0 <fd_lookup>
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 0e                	js     8015a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801595:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801598:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 14             	sub    $0x14,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	53                   	push   %ebx
  8015b4:	e8 f7 fb ff ff       	call   8011b0 <fd_lookup>
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	89 c2                	mov    %eax,%edx
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 65                	js     801627 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cc:	ff 30                	pushl  (%eax)
  8015ce:	e8 33 fc ff ff       	call   801206 <dev_lookup>
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 44                	js     80161e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e1:	75 21                	jne    801604 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e8:	8b 40 48             	mov    0x48(%eax),%eax
  8015eb:	83 ec 04             	sub    $0x4,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	50                   	push   %eax
  8015f0:	68 b0 26 80 00       	push   $0x8026b0
  8015f5:	e8 b7 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801602:	eb 23                	jmp    801627 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801604:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801607:	8b 52 18             	mov    0x18(%edx),%edx
  80160a:	85 d2                	test   %edx,%edx
  80160c:	74 14                	je     801622 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	ff 75 0c             	pushl  0xc(%ebp)
  801614:	50                   	push   %eax
  801615:	ff d2                	call   *%edx
  801617:	89 c2                	mov    %eax,%edx
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	eb 09                	jmp    801627 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161e:	89 c2                	mov    %eax,%edx
  801620:	eb 05                	jmp    801627 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801622:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801627:	89 d0                	mov    %edx,%eax
  801629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	53                   	push   %ebx
  801632:	83 ec 14             	sub    $0x14,%esp
  801635:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 6c fb ff ff       	call   8011b0 <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	89 c2                	mov    %eax,%edx
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 58                	js     8016a5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801657:	ff 30                	pushl  (%eax)
  801659:	e8 a8 fb ff ff       	call   801206 <dev_lookup>
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	85 c0                	test   %eax,%eax
  801663:	78 37                	js     80169c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801665:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801668:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80166c:	74 32                	je     8016a0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801671:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801678:	00 00 00 
	stat->st_isdir = 0;
  80167b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801682:	00 00 00 
	stat->st_dev = dev;
  801685:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	53                   	push   %ebx
  80168f:	ff 75 f0             	pushl  -0x10(%ebp)
  801692:	ff 50 14             	call   *0x14(%eax)
  801695:	89 c2                	mov    %eax,%edx
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	eb 09                	jmp    8016a5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	eb 05                	jmp    8016a5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a5:	89 d0                	mov    %edx,%eax
  8016a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	6a 00                	push   $0x0
  8016b6:	ff 75 08             	pushl  0x8(%ebp)
  8016b9:	e8 e3 01 00 00       	call   8018a1 <open>
  8016be:	89 c3                	mov    %eax,%ebx
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 1b                	js     8016e2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	ff 75 0c             	pushl  0xc(%ebp)
  8016cd:	50                   	push   %eax
  8016ce:	e8 5b ff ff ff       	call   80162e <fstat>
  8016d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d5:	89 1c 24             	mov    %ebx,(%esp)
  8016d8:	e8 fd fb ff ff       	call   8012da <close>
	return r;
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	89 f0                	mov    %esi,%eax
}
  8016e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e5:	5b                   	pop    %ebx
  8016e6:	5e                   	pop    %esi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	56                   	push   %esi
  8016ed:	53                   	push   %ebx
  8016ee:	89 c6                	mov    %eax,%esi
  8016f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016f9:	75 12                	jne    80170d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016fb:	83 ec 0c             	sub    $0xc,%esp
  8016fe:	6a 01                	push   $0x1
  801700:	e8 fc f9 ff ff       	call   801101 <ipc_find_env>
  801705:	a3 00 40 80 00       	mov    %eax,0x804000
  80170a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170d:	6a 07                	push   $0x7
  80170f:	68 00 50 80 00       	push   $0x805000
  801714:	56                   	push   %esi
  801715:	ff 35 00 40 80 00    	pushl  0x804000
  80171b:	e8 8d f9 ff ff       	call   8010ad <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801720:	83 c4 0c             	add    $0xc,%esp
  801723:	6a 00                	push   $0x0
  801725:	53                   	push   %ebx
  801726:	6a 00                	push   $0x0
  801728:	e8 2b f9 ff ff       	call   801058 <ipc_recv>
}
  80172d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801730:	5b                   	pop    %ebx
  801731:	5e                   	pop    %esi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
  80173d:	8b 40 0c             	mov    0xc(%eax),%eax
  801740:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801745:	8b 45 0c             	mov    0xc(%ebp),%eax
  801748:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
  801752:	b8 02 00 00 00       	mov    $0x2,%eax
  801757:	e8 8d ff ff ff       	call   8016e9 <fsipc>
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8b 40 0c             	mov    0xc(%eax),%eax
  80176a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 06 00 00 00       	mov    $0x6,%eax
  801779:	e8 6b ff ff ff       	call   8016e9 <fsipc>
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 04             	sub    $0x4,%esp
  801787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	b8 05 00 00 00       	mov    $0x5,%eax
  80179f:	e8 45 ff ff ff       	call   8016e9 <fsipc>
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 2c                	js     8017d4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	68 00 50 80 00       	push   $0x805000
  8017b0:	53                   	push   %ebx
  8017b1:	e8 9e ef ff ff       	call   800754 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 0c             	sub    $0xc,%esp
  8017df:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e8:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8017ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017f3:	ba 00 10 00 00       	mov    $0x1000,%edx
  8017f8:	0f 47 c2             	cmova  %edx,%eax
  8017fb:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801800:	50                   	push   %eax
  801801:	ff 75 0c             	pushl  0xc(%ebp)
  801804:	68 08 50 80 00       	push   $0x805008
  801809:	e8 d8 f0 ff ff       	call   8008e6 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80180e:	ba 00 00 00 00       	mov    $0x0,%edx
  801813:	b8 04 00 00 00       	mov    $0x4,%eax
  801818:	e8 cc fe ff ff       	call   8016e9 <fsipc>
    return r;
}
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	56                   	push   %esi
  801823:	53                   	push   %ebx
  801824:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	8b 40 0c             	mov    0xc(%eax),%eax
  80182d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801832:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801838:	ba 00 00 00 00       	mov    $0x0,%edx
  80183d:	b8 03 00 00 00       	mov    $0x3,%eax
  801842:	e8 a2 fe ff ff       	call   8016e9 <fsipc>
  801847:	89 c3                	mov    %eax,%ebx
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 4b                	js     801898 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80184d:	39 c6                	cmp    %eax,%esi
  80184f:	73 16                	jae    801867 <devfile_read+0x48>
  801851:	68 1c 27 80 00       	push   $0x80271c
  801856:	68 23 27 80 00       	push   $0x802723
  80185b:	6a 7c                	push   $0x7c
  80185d:	68 38 27 80 00       	push   $0x802738
  801862:	e8 bd 05 00 00       	call   801e24 <_panic>
	assert(r <= PGSIZE);
  801867:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186c:	7e 16                	jle    801884 <devfile_read+0x65>
  80186e:	68 43 27 80 00       	push   $0x802743
  801873:	68 23 27 80 00       	push   $0x802723
  801878:	6a 7d                	push   $0x7d
  80187a:	68 38 27 80 00       	push   $0x802738
  80187f:	e8 a0 05 00 00       	call   801e24 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	50                   	push   %eax
  801888:	68 00 50 80 00       	push   $0x805000
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	e8 51 f0 ff ff       	call   8008e6 <memmove>
	return r;
  801895:	83 c4 10             	add    $0x10,%esp
}
  801898:	89 d8                	mov    %ebx,%eax
  80189a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    

008018a1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 20             	sub    $0x20,%esp
  8018a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ab:	53                   	push   %ebx
  8018ac:	e8 6a ee ff ff       	call   80071b <strlen>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018b9:	7f 67                	jg     801922 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bb:	83 ec 0c             	sub    $0xc,%esp
  8018be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	e8 9a f8 ff ff       	call   801161 <fd_alloc>
  8018c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 57                	js     801927 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	68 00 50 80 00       	push   $0x805000
  8018d9:	e8 76 ee ff ff       	call   800754 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ee:	e8 f6 fd ff ff       	call   8016e9 <fsipc>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	79 14                	jns    801910 <open+0x6f>
		fd_close(fd, 0);
  8018fc:	83 ec 08             	sub    $0x8,%esp
  8018ff:	6a 00                	push   $0x0
  801901:	ff 75 f4             	pushl  -0xc(%ebp)
  801904:	e8 50 f9 ff ff       	call   801259 <fd_close>
		return r;
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	89 da                	mov    %ebx,%edx
  80190e:	eb 17                	jmp    801927 <open+0x86>
	}

	return fd2num(fd);
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	ff 75 f4             	pushl  -0xc(%ebp)
  801916:	e8 1f f8 ff ff       	call   80113a <fd2num>
  80191b:	89 c2                	mov    %eax,%edx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	eb 05                	jmp    801927 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801922:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801927:	89 d0                	mov    %edx,%eax
  801929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
  801939:	b8 08 00 00 00       	mov    $0x8,%eax
  80193e:	e8 a6 fd ff ff       	call   8016e9 <fsipc>
}
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	ff 75 08             	pushl  0x8(%ebp)
  801953:	e8 f2 f7 ff ff       	call   80114a <fd2data>
  801958:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80195a:	83 c4 08             	add    $0x8,%esp
  80195d:	68 4f 27 80 00       	push   $0x80274f
  801962:	53                   	push   %ebx
  801963:	e8 ec ed ff ff       	call   800754 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801968:	8b 46 04             	mov    0x4(%esi),%eax
  80196b:	2b 06                	sub    (%esi),%eax
  80196d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801973:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197a:	00 00 00 
	stat->st_dev = &devpipe;
  80197d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801984:	30 80 00 
	return 0;
}
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
  80198c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	53                   	push   %ebx
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80199d:	53                   	push   %ebx
  80199e:	6a 00                	push   $0x0
  8019a0:	e8 37 f2 ff ff       	call   800bdc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019a5:	89 1c 24             	mov    %ebx,(%esp)
  8019a8:	e8 9d f7 ff ff       	call   80114a <fd2data>
  8019ad:	83 c4 08             	add    $0x8,%esp
  8019b0:	50                   	push   %eax
  8019b1:	6a 00                	push   $0x0
  8019b3:	e8 24 f2 ff ff       	call   800bdc <sys_page_unmap>
}
  8019b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	57                   	push   %edi
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 1c             	sub    $0x1c,%esp
  8019c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019c9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8019d0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8019d9:	e8 18 05 00 00       	call   801ef6 <pageref>
  8019de:	89 c3                	mov    %eax,%ebx
  8019e0:	89 3c 24             	mov    %edi,(%esp)
  8019e3:	e8 0e 05 00 00       	call   801ef6 <pageref>
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	39 c3                	cmp    %eax,%ebx
  8019ed:	0f 94 c1             	sete   %cl
  8019f0:	0f b6 c9             	movzbl %cl,%ecx
  8019f3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019f6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ff:	39 ce                	cmp    %ecx,%esi
  801a01:	74 1b                	je     801a1e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a03:	39 c3                	cmp    %eax,%ebx
  801a05:	75 c4                	jne    8019cb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a07:	8b 42 58             	mov    0x58(%edx),%eax
  801a0a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a0d:	50                   	push   %eax
  801a0e:	56                   	push   %esi
  801a0f:	68 56 27 80 00       	push   $0x802756
  801a14:	e8 98 e7 ff ff       	call   8001b1 <cprintf>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	eb ad                	jmp    8019cb <_pipeisclosed+0xe>
	}
}
  801a1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a24:	5b                   	pop    %ebx
  801a25:	5e                   	pop    %esi
  801a26:	5f                   	pop    %edi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	57                   	push   %edi
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
  801a2f:	83 ec 28             	sub    $0x28,%esp
  801a32:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a35:	56                   	push   %esi
  801a36:	e8 0f f7 ff ff       	call   80114a <fd2data>
  801a3b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	bf 00 00 00 00       	mov    $0x0,%edi
  801a45:	eb 4b                	jmp    801a92 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a47:	89 da                	mov    %ebx,%edx
  801a49:	89 f0                	mov    %esi,%eax
  801a4b:	e8 6d ff ff ff       	call   8019bd <_pipeisclosed>
  801a50:	85 c0                	test   %eax,%eax
  801a52:	75 48                	jne    801a9c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a54:	e8 df f0 ff ff       	call   800b38 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a59:	8b 43 04             	mov    0x4(%ebx),%eax
  801a5c:	8b 0b                	mov    (%ebx),%ecx
  801a5e:	8d 51 20             	lea    0x20(%ecx),%edx
  801a61:	39 d0                	cmp    %edx,%eax
  801a63:	73 e2                	jae    801a47 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a68:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a6c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a6f:	89 c2                	mov    %eax,%edx
  801a71:	c1 fa 1f             	sar    $0x1f,%edx
  801a74:	89 d1                	mov    %edx,%ecx
  801a76:	c1 e9 1b             	shr    $0x1b,%ecx
  801a79:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a7c:	83 e2 1f             	and    $0x1f,%edx
  801a7f:	29 ca                	sub    %ecx,%edx
  801a81:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a85:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a89:	83 c0 01             	add    $0x1,%eax
  801a8c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8f:	83 c7 01             	add    $0x1,%edi
  801a92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a95:	75 c2                	jne    801a59 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a97:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9a:	eb 05                	jmp    801aa1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	57                   	push   %edi
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 18             	sub    $0x18,%esp
  801ab2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ab5:	57                   	push   %edi
  801ab6:	e8 8f f6 ff ff       	call   80114a <fd2data>
  801abb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ac5:	eb 3d                	jmp    801b04 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ac7:	85 db                	test   %ebx,%ebx
  801ac9:	74 04                	je     801acf <devpipe_read+0x26>
				return i;
  801acb:	89 d8                	mov    %ebx,%eax
  801acd:	eb 44                	jmp    801b13 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801acf:	89 f2                	mov    %esi,%edx
  801ad1:	89 f8                	mov    %edi,%eax
  801ad3:	e8 e5 fe ff ff       	call   8019bd <_pipeisclosed>
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	75 32                	jne    801b0e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801adc:	e8 57 f0 ff ff       	call   800b38 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae1:	8b 06                	mov    (%esi),%eax
  801ae3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ae6:	74 df                	je     801ac7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ae8:	99                   	cltd   
  801ae9:	c1 ea 1b             	shr    $0x1b,%edx
  801aec:	01 d0                	add    %edx,%eax
  801aee:	83 e0 1f             	and    $0x1f,%eax
  801af1:	29 d0                	sub    %edx,%eax
  801af3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801afe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b01:	83 c3 01             	add    $0x1,%ebx
  801b04:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b07:	75 d8                	jne    801ae1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b09:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0c:	eb 05                	jmp    801b13 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b0e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b16:	5b                   	pop    %ebx
  801b17:	5e                   	pop    %esi
  801b18:	5f                   	pop    %edi
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	56                   	push   %esi
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b26:	50                   	push   %eax
  801b27:	e8 35 f6 ff ff       	call   801161 <fd_alloc>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	89 c2                	mov    %eax,%edx
  801b31:	85 c0                	test   %eax,%eax
  801b33:	0f 88 2c 01 00 00    	js     801c65 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b39:	83 ec 04             	sub    $0x4,%esp
  801b3c:	68 07 04 00 00       	push   $0x407
  801b41:	ff 75 f4             	pushl  -0xc(%ebp)
  801b44:	6a 00                	push   $0x0
  801b46:	e8 0c f0 ff ff       	call   800b57 <sys_page_alloc>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	85 c0                	test   %eax,%eax
  801b52:	0f 88 0d 01 00 00    	js     801c65 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b58:	83 ec 0c             	sub    $0xc,%esp
  801b5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5e:	50                   	push   %eax
  801b5f:	e8 fd f5 ff ff       	call   801161 <fd_alloc>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	0f 88 e2 00 00 00    	js     801c53 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	68 07 04 00 00       	push   $0x407
  801b79:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7c:	6a 00                	push   $0x0
  801b7e:	e8 d4 ef ff ff       	call   800b57 <sys_page_alloc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 88 c3 00 00 00    	js     801c53 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b90:	83 ec 0c             	sub    $0xc,%esp
  801b93:	ff 75 f4             	pushl  -0xc(%ebp)
  801b96:	e8 af f5 ff ff       	call   80114a <fd2data>
  801b9b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9d:	83 c4 0c             	add    $0xc,%esp
  801ba0:	68 07 04 00 00       	push   $0x407
  801ba5:	50                   	push   %eax
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 aa ef ff ff       	call   800b57 <sys_page_alloc>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 89 00 00 00    	js     801c43 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc0:	e8 85 f5 ff ff       	call   80114a <fd2data>
  801bc5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bcc:	50                   	push   %eax
  801bcd:	6a 00                	push   $0x0
  801bcf:	56                   	push   %esi
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 c3 ef ff ff       	call   800b9a <sys_page_map>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	83 c4 20             	add    $0x20,%esp
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	78 55                	js     801c35 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bf5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c03:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c0a:	83 ec 0c             	sub    $0xc,%esp
  801c0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c10:	e8 25 f5 ff ff       	call   80113a <fd2num>
  801c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c18:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c1a:	83 c4 04             	add    $0x4,%esp
  801c1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c20:	e8 15 f5 ff ff       	call   80113a <fd2num>
  801c25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c28:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c33:	eb 30                	jmp    801c65 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	56                   	push   %esi
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 9c ef ff ff       	call   800bdc <sys_page_unmap>
  801c40:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c43:	83 ec 08             	sub    $0x8,%esp
  801c46:	ff 75 f0             	pushl  -0x10(%ebp)
  801c49:	6a 00                	push   $0x0
  801c4b:	e8 8c ef ff ff       	call   800bdc <sys_page_unmap>
  801c50:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c53:	83 ec 08             	sub    $0x8,%esp
  801c56:	ff 75 f4             	pushl  -0xc(%ebp)
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 7c ef ff ff       	call   800bdc <sys_page_unmap>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c65:	89 d0                	mov    %edx,%eax
  801c67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6a:	5b                   	pop    %ebx
  801c6b:	5e                   	pop    %esi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c77:	50                   	push   %eax
  801c78:	ff 75 08             	pushl  0x8(%ebp)
  801c7b:	e8 30 f5 ff ff       	call   8011b0 <fd_lookup>
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	85 c0                	test   %eax,%eax
  801c85:	78 18                	js     801c9f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8d:	e8 b8 f4 ff ff       	call   80114a <fd2data>
	return _pipeisclosed(fd, p);
  801c92:	89 c2                	mov    %eax,%edx
  801c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c97:	e8 21 fd ff ff       	call   8019bd <_pipeisclosed>
  801c9c:	83 c4 10             	add    $0x10,%esp
}
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cb1:	68 6e 27 80 00       	push   $0x80276e
  801cb6:	ff 75 0c             	pushl  0xc(%ebp)
  801cb9:	e8 96 ea ff ff       	call   800754 <strcpy>
	return 0;
}
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	57                   	push   %edi
  801cc9:	56                   	push   %esi
  801cca:	53                   	push   %ebx
  801ccb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cdc:	eb 2d                	jmp    801d0b <devcons_write+0x46>
		m = n - tot;
  801cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ce1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ce3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ce6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ceb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cee:	83 ec 04             	sub    $0x4,%esp
  801cf1:	53                   	push   %ebx
  801cf2:	03 45 0c             	add    0xc(%ebp),%eax
  801cf5:	50                   	push   %eax
  801cf6:	57                   	push   %edi
  801cf7:	e8 ea eb ff ff       	call   8008e6 <memmove>
		sys_cputs(buf, m);
  801cfc:	83 c4 08             	add    $0x8,%esp
  801cff:	53                   	push   %ebx
  801d00:	57                   	push   %edi
  801d01:	e8 95 ed ff ff       	call   800a9b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d06:	01 de                	add    %ebx,%esi
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d10:	72 cc                	jb     801cde <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d15:	5b                   	pop    %ebx
  801d16:	5e                   	pop    %esi
  801d17:	5f                   	pop    %edi
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 08             	sub    $0x8,%esp
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d29:	74 2a                	je     801d55 <devcons_read+0x3b>
  801d2b:	eb 05                	jmp    801d32 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d2d:	e8 06 ee ff ff       	call   800b38 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d32:	e8 82 ed ff ff       	call   800ab9 <sys_cgetc>
  801d37:	85 c0                	test   %eax,%eax
  801d39:	74 f2                	je     801d2d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 16                	js     801d55 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d3f:	83 f8 04             	cmp    $0x4,%eax
  801d42:	74 0c                	je     801d50 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d47:	88 02                	mov    %al,(%edx)
	return 1;
  801d49:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4e:	eb 05                	jmp    801d55 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d60:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d63:	6a 01                	push   $0x1
  801d65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d68:	50                   	push   %eax
  801d69:	e8 2d ed ff ff       	call   800a9b <sys_cputs>
}
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <getchar>:

int
getchar(void)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d79:	6a 01                	push   $0x1
  801d7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d7e:	50                   	push   %eax
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 90 f6 ff ff       	call   801416 <read>
	if (r < 0)
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 0f                	js     801d9c <getchar+0x29>
		return r;
	if (r < 1)
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	7e 06                	jle    801d97 <getchar+0x24>
		return -E_EOF;
	return c;
  801d91:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d95:	eb 05                	jmp    801d9c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d97:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da7:	50                   	push   %eax
  801da8:	ff 75 08             	pushl  0x8(%ebp)
  801dab:	e8 00 f4 ff ff       	call   8011b0 <fd_lookup>
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	78 11                	js     801dc8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc0:	39 10                	cmp    %edx,(%eax)
  801dc2:	0f 94 c0             	sete   %al
  801dc5:	0f b6 c0             	movzbl %al,%eax
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <opencons>:

int
opencons(void)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	e8 88 f3 ff ff       	call   801161 <fd_alloc>
  801dd9:	83 c4 10             	add    $0x10,%esp
		return r;
  801ddc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 3e                	js     801e20 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de2:	83 ec 04             	sub    $0x4,%esp
  801de5:	68 07 04 00 00       	push   $0x407
  801dea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ded:	6a 00                	push   $0x0
  801def:	e8 63 ed ff ff       	call   800b57 <sys_page_alloc>
  801df4:	83 c4 10             	add    $0x10,%esp
		return r;
  801df7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 23                	js     801e20 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dfd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e06:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	50                   	push   %eax
  801e16:	e8 1f f3 ff ff       	call   80113a <fd2num>
  801e1b:	89 c2                	mov    %eax,%edx
  801e1d:	83 c4 10             	add    $0x10,%esp
}
  801e20:	89 d0                	mov    %edx,%eax
  801e22:	c9                   	leave  
  801e23:	c3                   	ret    

00801e24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	56                   	push   %esi
  801e28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e29:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e2c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e32:	e8 e2 ec ff ff       	call   800b19 <sys_getenvid>
  801e37:	83 ec 0c             	sub    $0xc,%esp
  801e3a:	ff 75 0c             	pushl  0xc(%ebp)
  801e3d:	ff 75 08             	pushl  0x8(%ebp)
  801e40:	56                   	push   %esi
  801e41:	50                   	push   %eax
  801e42:	68 7c 27 80 00       	push   $0x80277c
  801e47:	e8 65 e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e4c:	83 c4 18             	add    $0x18,%esp
  801e4f:	53                   	push   %ebx
  801e50:	ff 75 10             	pushl  0x10(%ebp)
  801e53:	e8 08 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801e58:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  801e5f:	e8 4d e3 ff ff       	call   8001b1 <cprintf>
  801e64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e67:	cc                   	int3   
  801e68:	eb fd                	jmp    801e67 <_panic+0x43>

00801e6a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801e70:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e77:	75 36                	jne    801eaf <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e79:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7e:	8b 40 48             	mov    0x48(%eax),%eax
  801e81:	83 ec 04             	sub    $0x4,%esp
  801e84:	68 07 0e 00 00       	push   $0xe07
  801e89:	68 00 f0 bf ee       	push   $0xeebff000
  801e8e:	50                   	push   %eax
  801e8f:	e8 c3 ec ff ff       	call   800b57 <sys_page_alloc>
		if (ret < 0) {
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	79 14                	jns    801eaf <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801e9b:	83 ec 04             	sub    $0x4,%esp
  801e9e:	68 a0 27 80 00       	push   $0x8027a0
  801ea3:	6a 23                	push   $0x23
  801ea5:	68 c8 27 80 00       	push   $0x8027c8
  801eaa:	e8 75 ff ff ff       	call   801e24 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801eaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb4:	8b 40 48             	mov    0x48(%eax),%eax
  801eb7:	83 ec 08             	sub    $0x8,%esp
  801eba:	68 d2 1e 80 00       	push   $0x801ed2
  801ebf:	50                   	push   %eax
  801ec0:	e8 dd ed ff ff       	call   800ca2 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ed2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ed3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ed8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eda:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801edd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801ee1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801ee6:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801eea:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801eec:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801eef:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801ef0:	83 c4 04             	add    $0x4,%esp
        popfl
  801ef3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801ef4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801ef5:	c3                   	ret    

00801ef6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efc:	89 d0                	mov    %edx,%eax
  801efe:	c1 e8 16             	shr    $0x16,%eax
  801f01:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0d:	f6 c1 01             	test   $0x1,%cl
  801f10:	74 1d                	je     801f2f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f12:	c1 ea 0c             	shr    $0xc,%edx
  801f15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f1c:	f6 c2 01             	test   $0x1,%dl
  801f1f:	74 0e                	je     801f2f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f21:	c1 ea 0c             	shr    $0xc,%edx
  801f24:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f2b:	ef 
  801f2c:	0f b7 c0             	movzwl %ax,%eax
}
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    
  801f31:	66 90                	xchg   %ax,%ax
  801f33:	66 90                	xchg   %ax,%ax
  801f35:	66 90                	xchg   %ax,%ax
  801f37:	66 90                	xchg   %ax,%ax
  801f39:	66 90                	xchg   %ax,%ax
  801f3b:	66 90                	xchg   %ax,%ax
  801f3d:	66 90                	xchg   %ax,%ax
  801f3f:	90                   	nop

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
