
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 3d 10 00 00       	call   80107e <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 06 0b 00 00       	call   800b59 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 20 22 80 00       	push   $0x802220
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 ef 0a 00 00       	call   800b59 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 3a 22 80 00       	push   $0x80223a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 66 10 00 00       	call   8010ed <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 fe 0f 00 00       	call   801098 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 a6 0a 00 00       	call   800b59 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 50 22 80 00       	push   $0x802250
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 03 10 00 00       	call   8010ed <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 4b 0a 00 00       	call   800b59 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 f6 11 00 00       	call   801345 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 bf 09 00 00       	call   800b18 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 4d 09 00 00       	call   800adb <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 f2 08 00 00       	call   800adb <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 27 1d 00 00       	call   801f80 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 14 1e 00 00       	call   8020b0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 a7 03 00 00    	je     8006eb <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80037a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037f:	eb 07                	jmp    800388 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800384:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8d 47 01             	lea    0x1(%edi),%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038e:	0f b6 07             	movzbl (%edi),%eax
  800391:	0f b6 d0             	movzbl %al,%edx
  800394:	83 e8 23             	sub    $0x23,%eax
  800397:	3c 55                	cmp    $0x55,%al
  800399:	0f 87 31 03 00 00    	ja     8006d0 <vprintfmt+0x3a8>
  80039f:	0f b6 c0             	movzbl %al,%eax
  8003a2:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b0:	eb d6                	jmp    800388 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ba:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8003ca:	83 fe 09             	cmp    $0x9,%esi
  8003cd:	77 34                	ja     800403 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d2:	eb e9                	jmp    8003bd <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e5:	eb 22                	jmp    800409 <vprintfmt+0xe1>
  8003e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	0f 48 c1             	cmovs  %ecx,%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	eb 91                	jmp    800388 <vprintfmt+0x60>
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800401:	eb 85                	jmp    800388 <vprintfmt+0x60>
  800403:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800406:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040d:	0f 89 75 ff ff ff    	jns    800388 <vprintfmt+0x60>
				width = precision, precision = -1;
  800413:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800419:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800420:	e9 63 ff ff ff       	jmp    800388 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800425:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042c:	e9 57 ff ff ff       	jmp    800388 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 30                	pushl  (%eax)
  800440:	ff d6                	call   *%esi
			break;
  800442:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800448:	e9 01 ff ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	99                   	cltd   
  800459:	31 d0                	xor    %edx,%eax
  80045b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045d:	83 f8 0f             	cmp    $0xf,%eax
  800460:	7f 0b                	jg     80046d <vprintfmt+0x145>
  800462:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800469:	85 d2                	test   %edx,%edx
  80046b:	75 18                	jne    800485 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 98 22 80 00       	push   $0x802298
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 91 fe ff ff       	call   80030b <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800480:	e9 c9 fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800485:	52                   	push   %edx
  800486:	68 95 27 80 00       	push   $0x802795
  80048b:	53                   	push   %ebx
  80048c:	56                   	push   %esi
  80048d:	e8 79 fe ff ff       	call   80030b <printfmt>
  800492:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800498:	e9 b1 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a8:	85 ff                	test   %edi,%edi
  8004aa:	b8 91 22 80 00       	mov    $0x802291,%eax
  8004af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b6:	0f 8e 94 00 00 00    	jle    800550 <vprintfmt+0x228>
  8004bc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c0:	0f 84 98 00 00 00    	je     80055e <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 cc             	pushl  -0x34(%ebp)
  8004cc:	57                   	push   %edi
  8004cd:	e8 a1 02 00 00       	call   800773 <strnlen>
  8004d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d5:	29 c1                	sub    %eax,%ecx
  8004d7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004dd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	eb 0f                	jmp    8004fa <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 ef 01             	sub    $0x1,%edi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	7f ed                	jg     8004eb <vprintfmt+0x1c3>
  8004fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800501:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800504:	85 c9                	test   %ecx,%ecx
  800506:	b8 00 00 00 00       	mov    $0x0,%eax
  80050b:	0f 49 c1             	cmovns %ecx,%eax
  80050e:	29 c1                	sub    %eax,%ecx
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	89 cb                	mov    %ecx,%ebx
  80051b:	eb 4d                	jmp    80056a <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800521:	74 1b                	je     80053e <vprintfmt+0x216>
  800523:	0f be c0             	movsbl %al,%eax
  800526:	83 e8 20             	sub    $0x20,%eax
  800529:	83 f8 5e             	cmp    $0x5e,%eax
  80052c:	76 10                	jbe    80053e <vprintfmt+0x216>
					putch('?', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	6a 3f                	push   $0x3f
  800536:	ff 55 08             	call   *0x8(%ebp)
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb 0d                	jmp    80054b <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	52                   	push   %edx
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	83 eb 01             	sub    $0x1,%ebx
  80054e:	eb 1a                	jmp    80056a <vprintfmt+0x242>
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055c:	eb 0c                	jmp    80056a <vprintfmt+0x242>
  80055e:	89 75 08             	mov    %esi,0x8(%ebp)
  800561:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800564:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800567:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056a:	83 c7 01             	add    $0x1,%edi
  80056d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800571:	0f be d0             	movsbl %al,%edx
  800574:	85 d2                	test   %edx,%edx
  800576:	74 23                	je     80059b <vprintfmt+0x273>
  800578:	85 f6                	test   %esi,%esi
  80057a:	78 a1                	js     80051d <vprintfmt+0x1f5>
  80057c:	83 ee 01             	sub    $0x1,%esi
  80057f:	79 9c                	jns    80051d <vprintfmt+0x1f5>
  800581:	89 df                	mov    %ebx,%edi
  800583:	8b 75 08             	mov    0x8(%ebp),%esi
  800586:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800589:	eb 18                	jmp    8005a3 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 20                	push   $0x20
  800591:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800593:	83 ef 01             	sub    $0x1,%edi
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	eb 08                	jmp    8005a3 <vprintfmt+0x27b>
  80059b:	89 df                	mov    %ebx,%edi
  80059d:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a3:	85 ff                	test   %edi,%edi
  8005a5:	7f e4                	jg     80058b <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005aa:	e9 9f fd ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005af:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8005b3:	7e 16                	jle    8005cb <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 08             	lea    0x8(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 50 04             	mov    0x4(%eax),%edx
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c9:	eb 34                	jmp    8005ff <vprintfmt+0x2d7>
	else if (lflag)
  8005cb:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005cf:	74 18                	je     8005e9 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 c1                	mov    %eax,%ecx
  8005e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e7:	eb 16                	jmp    8005ff <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 c1                	mov    %eax,%ecx
  8005f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800602:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800605:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060e:	0f 89 88 00 00 00    	jns    80069c <vprintfmt+0x374>
				putch('-', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 2d                	push   $0x2d
  80061a:	ff d6                	call   *%esi
				num = -(long long) num;
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800622:	f7 d8                	neg    %eax
  800624:	83 d2 00             	adc    $0x0,%edx
  800627:	f7 da                	neg    %edx
  800629:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800631:	eb 69                	jmp    80069c <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800633:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 76 fc ff ff       	call   8002b4 <getuint>
			base = 10;
  80063e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800643:	eb 57                	jmp    80069c <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 30                	push   $0x30
  80064b:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80064d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800650:	8d 45 14             	lea    0x14(%ebp),%eax
  800653:	e8 5c fc ff ff       	call   8002b4 <getuint>
			base = 8;
			goto number;
  800658:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80065b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800660:	eb 3a                	jmp    80069c <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	6a 30                	push   $0x30
  800668:	ff d6                	call   *%esi
			putch('x', putdat);
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 78                	push   $0x78
  800670:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800685:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068a:	eb 10                	jmp    80069c <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 1d fc ff ff       	call   8002b4 <getuint>
			base = 16;
  800697:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a3:	57                   	push   %edi
  8006a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a7:	51                   	push   %ecx
  8006a8:	52                   	push   %edx
  8006a9:	50                   	push   %eax
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	89 f0                	mov    %esi,%eax
  8006ae:	e8 52 fb ff ff       	call   800205 <printnum>
			break;
  8006b3:	83 c4 20             	add    $0x20,%esp
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	e9 90 fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	52                   	push   %edx
  8006c3:	ff d6                	call   *%esi
			break;
  8006c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cb:	e9 7e fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	eb 03                	jmp    8006e0 <vprintfmt+0x3b8>
  8006dd:	83 ef 01             	sub    $0x1,%edi
  8006e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e4:	75 f7                	jne    8006dd <vprintfmt+0x3b5>
  8006e6:	e9 63 fc ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ee:	5b                   	pop    %ebx
  8006ef:	5e                   	pop    %esi
  8006f0:	5f                   	pop    %edi
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 18             	sub    $0x18,%esp
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800702:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800706:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800709:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 26                	je     80073a <vsnprintf+0x47>
  800714:	85 d2                	test   %edx,%edx
  800716:	7e 22                	jle    80073a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800718:	ff 75 14             	pushl  0x14(%ebp)
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	68 ee 02 80 00       	push   $0x8002ee
  800727:	e8 fc fb ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 05                	jmp    80073f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074a:	50                   	push   %eax
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	ff 75 08             	pushl  0x8(%ebp)
  800754:	e8 9a ff ff ff       	call   8006f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 03                	jmp    80076b <strlen+0x10>
		n++;
  800768:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076f:	75 f7                	jne    800768 <strlen+0xd>
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
  800781:	eb 03                	jmp    800786 <strnlen+0x13>
		n++;
  800783:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800786:	39 c2                	cmp    %eax,%edx
  800788:	74 08                	je     800792 <strnlen+0x1f>
  80078a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078e:	75 f3                	jne    800783 <strnlen+0x10>
  800790:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c2 01             	add    $0x1,%edx
  8007a3:	83 c1 01             	add    $0x1,%ecx
  8007a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ef                	jne    8007a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	53                   	push   %ebx
  8007bc:	e8 9a ff ff ff       	call   80075b <strlen>
  8007c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 ff ff ff       	call   800794 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x23>
		*dst++ = *src;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f9:	39 da                	cmp    %ebx,%edx
  8007fb:	75 ed                	jne    8007ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080e:	8b 55 10             	mov    0x10(%ebp),%edx
  800811:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800813:	85 d2                	test   %edx,%edx
  800815:	74 21                	je     800838 <strlcpy+0x35>
  800817:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 09                	jmp    800828 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 09                	je     800835 <strlcpy+0x32>
  80082c:	0f b6 19             	movzbl (%ecx),%ebx
  80082f:	84 db                	test   %bl,%bl
  800831:	75 ec                	jne    80081f <strlcpy+0x1c>
  800833:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800835:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800838:	29 f0                	sub    %esi,%eax
}
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800847:	eb 06                	jmp    80084f <strcmp+0x11>
		p++, q++;
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084f:	0f b6 01             	movzbl (%ecx),%eax
  800852:	84 c0                	test   %al,%al
  800854:	74 04                	je     80085a <strcmp+0x1c>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	74 ef                	je     800849 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	0f b6 c0             	movzbl %al,%eax
  80085d:	0f b6 12             	movzbl (%edx),%edx
  800860:	29 d0                	sub    %edx,%eax
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	89 c3                	mov    %eax,%ebx
  800870:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800873:	eb 06                	jmp    80087b <strncmp+0x17>
		n--, p++, q++;
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087b:	39 d8                	cmp    %ebx,%eax
  80087d:	74 15                	je     800894 <strncmp+0x30>
  80087f:	0f b6 08             	movzbl (%eax),%ecx
  800882:	84 c9                	test   %cl,%cl
  800884:	74 04                	je     80088a <strncmp+0x26>
  800886:	3a 0a                	cmp    (%edx),%cl
  800888:	74 eb                	je     800875 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 00             	movzbl (%eax),%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
  800892:	eb 05                	jmp    800899 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800899:	5b                   	pop    %ebx
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 07                	jmp    8008af <strchr+0x13>
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 0f                	je     8008bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 03                	jmp    8008cc <strfind+0xf>
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cf:	38 ca                	cmp    %cl,%dl
  8008d1:	74 04                	je     8008d7 <strfind+0x1a>
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 36                	je     80091f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 28                	jne    800919 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 23                	jne    800919 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fa:	89 d3                	mov    %edx,%ebx
  8008fc:	c1 e3 08             	shl    $0x8,%ebx
  8008ff:	89 d6                	mov    %edx,%esi
  800901:	c1 e6 18             	shl    $0x18,%esi
  800904:	89 d0                	mov    %edx,%eax
  800906:	c1 e0 10             	shl    $0x10,%eax
  800909:	09 f0                	or     %esi,%eax
  80090b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090d:	89 d8                	mov    %ebx,%eax
  80090f:	09 d0                	or     %edx,%eax
  800911:	c1 e9 02             	shr    $0x2,%ecx
  800914:	fc                   	cld    
  800915:	f3 ab                	rep stos %eax,%es:(%edi)
  800917:	eb 06                	jmp    80091f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	fc                   	cld    
  80091d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091f:	89 f8                	mov    %edi,%eax
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 35                	jae    80096d <memmove+0x47>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	73 2e                	jae    80096d <memmove+0x47>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 d6                	mov    %edx,%esi
  800944:	09 fe                	or     %edi,%esi
  800946:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094c:	75 13                	jne    800961 <memmove+0x3b>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 0e                	jne    800961 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800953:	83 ef 04             	sub    $0x4,%edi
  800956:	8d 72 fc             	lea    -0x4(%edx),%esi
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	fd                   	std    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb 09                	jmp    80096a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800961:	83 ef 01             	sub    $0x1,%edi
  800964:	8d 72 ff             	lea    -0x1(%edx),%esi
  800967:	fd                   	std    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096a:	fc                   	cld    
  80096b:	eb 1d                	jmp    80098a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	89 f2                	mov    %esi,%edx
  80096f:	09 c2                	or     %eax,%edx
  800971:	f6 c2 03             	test   $0x3,%dl
  800974:	75 0f                	jne    800985 <memmove+0x5f>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0a                	jne    800985 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 05                	jmp    80098a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800991:	ff 75 10             	pushl  0x10(%ebp)
  800994:	ff 75 0c             	pushl  0xc(%ebp)
  800997:	ff 75 08             	pushl  0x8(%ebp)
  80099a:	e8 87 ff ff ff       	call   800926 <memmove>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c6                	mov    %eax,%esi
  8009ae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	eb 1a                	jmp    8009cd <memcmp+0x2c>
		if (*s1 != *s2)
  8009b3:	0f b6 08             	movzbl (%eax),%ecx
  8009b6:	0f b6 1a             	movzbl (%edx),%ebx
  8009b9:	38 d9                	cmp    %bl,%cl
  8009bb:	74 0a                	je     8009c7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bd:	0f b6 c1             	movzbl %cl,%eax
  8009c0:	0f b6 db             	movzbl %bl,%ebx
  8009c3:	29 d8                	sub    %ebx,%eax
  8009c5:	eb 0f                	jmp    8009d6 <memcmp+0x35>
		s1++, s2++;
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	39 f0                	cmp    %esi,%eax
  8009cf:	75 e2                	jne    8009b3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e1:	89 c1                	mov    %eax,%ecx
  8009e3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ea:	eb 0a                	jmp    8009f6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	0f b6 10             	movzbl (%eax),%edx
  8009ef:	39 da                	cmp    %ebx,%edx
  8009f1:	74 07                	je     8009fa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	39 c8                	cmp    %ecx,%eax
  8009f8:	72 f2                	jb     8009ec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a09:	eb 03                	jmp    800a0e <strtol+0x11>
		s++;
  800a0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f6                	je     800a0b <strtol+0xe>
  800a15:	3c 09                	cmp    $0x9,%al
  800a17:	74 f2                	je     800a0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 0a                	jne    800a27 <strtol+0x2a>
		s++;
  800a1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
  800a25:	eb 11                	jmp    800a38 <strtol+0x3b>
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2c:	3c 2d                	cmp    $0x2d,%al
  800a2e:	75 08                	jne    800a38 <strtol+0x3b>
		s++, neg = 1;
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3e:	75 15                	jne    800a55 <strtol+0x58>
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 10                	jne    800a55 <strtol+0x58>
  800a45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a49:	75 7c                	jne    800ac7 <strtol+0xca>
		s += 2, base = 16;
  800a4b:	83 c1 02             	add    $0x2,%ecx
  800a4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a53:	eb 16                	jmp    800a6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	75 12                	jne    800a6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a61:	75 08                	jne    800a6b <strtol+0x6e>
		s++, base = 8;
  800a63:	83 c1 01             	add    $0x1,%ecx
  800a66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a73:	0f b6 11             	movzbl (%ecx),%edx
  800a76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a79:	89 f3                	mov    %esi,%ebx
  800a7b:	80 fb 09             	cmp    $0x9,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0x8b>
			dig = *s - '0';
  800a80:	0f be d2             	movsbl %dl,%edx
  800a83:	83 ea 30             	sub    $0x30,%edx
  800a86:	eb 22                	jmp    800aaa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 57             	sub    $0x57,%edx
  800a98:	eb 10                	jmp    800aaa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 16                	ja     800aba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aad:	7d 0b                	jge    800aba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab8:	eb b9                	jmp    800a73 <strtol+0x76>

	if (endptr)
  800aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abe:	74 0d                	je     800acd <strtol+0xd0>
		*endptr = (char *) s;
  800ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac3:	89 0e                	mov    %ecx,(%esi)
  800ac5:	eb 06                	jmp    800acd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	74 98                	je     800a63 <strtol+0x66>
  800acb:	eb 9e                	jmp    800a6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	f7 da                	neg    %edx
  800ad1:	85 ff                	test   %edi,%edi
  800ad3:	0f 45 c2             	cmovne %edx,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	89 c7                	mov    %eax,%edi
  800af0:	89 c6                	mov    %eax,%esi
  800af2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aff:	ba 00 00 00 00       	mov    $0x0,%edx
  800b04:	b8 01 00 00 00       	mov    $0x1,%eax
  800b09:	89 d1                	mov    %edx,%ecx
  800b0b:	89 d3                	mov    %edx,%ebx
  800b0d:	89 d7                	mov    %edx,%edi
  800b0f:	89 d6                	mov    %edx,%esi
  800b11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b26:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	89 cb                	mov    %ecx,%ebx
  800b30:	89 cf                	mov    %ecx,%edi
  800b32:	89 ce                	mov    %ecx,%esi
  800b34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b36:	85 c0                	test   %eax,%eax
  800b38:	7e 17                	jle    800b51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	50                   	push   %eax
  800b3e:	6a 03                	push   $0x3
  800b40:	68 7f 25 80 00       	push   $0x80257f
  800b45:	6a 23                	push   $0x23
  800b47:	68 9c 25 80 00       	push   $0x80259c
  800b4c:	e8 13 13 00 00       	call   801e64 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 02 00 00 00       	mov    $0x2,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_yield>:

void
sys_yield(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b88:	89 d1                	mov    %edx,%ecx
  800b8a:	89 d3                	mov    %edx,%ebx
  800b8c:	89 d7                	mov    %edx,%edi
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	be 00 00 00 00       	mov    $0x0,%esi
  800ba5:	b8 04 00 00 00       	mov    $0x4,%eax
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb3:	89 f7                	mov    %esi,%edi
  800bb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 04                	push   $0x4
  800bc1:	68 7f 25 80 00       	push   $0x80257f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 9c 25 80 00       	push   $0x80259c
  800bcd:	e8 92 12 00 00       	call   801e64 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	b8 05 00 00 00       	mov    $0x5,%eax
  800be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 17                	jle    800c14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 05                	push   $0x5
  800c03:	68 7f 25 80 00       	push   $0x80257f
  800c08:	6a 23                	push   $0x23
  800c0a:	68 9c 25 80 00       	push   $0x80259c
  800c0f:	e8 50 12 00 00       	call   801e64 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 df                	mov    %ebx,%edi
  800c37:	89 de                	mov    %ebx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 06                	push   $0x6
  800c45:	68 7f 25 80 00       	push   $0x80257f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 9c 25 80 00       	push   $0x80259c
  800c51:	e8 0e 12 00 00       	call   801e64 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 17                	jle    800c98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 08                	push   $0x8
  800c87:	68 7f 25 80 00       	push   $0x80257f
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 9c 25 80 00       	push   $0x80259c
  800c93:	e8 cc 11 00 00       	call   801e64 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cae:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	89 df                	mov    %ebx,%edi
  800cbb:	89 de                	mov    %ebx,%esi
  800cbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 09                	push   $0x9
  800cc9:	68 7f 25 80 00       	push   $0x80257f
  800cce:	6a 23                	push   $0x23
  800cd0:	68 9c 25 80 00       	push   $0x80259c
  800cd5:	e8 8a 11 00 00       	call   801e64 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 df                	mov    %ebx,%edi
  800cfd:	89 de                	mov    %ebx,%esi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 0a                	push   $0xa
  800d0b:	68 7f 25 80 00       	push   $0x80257f
  800d10:	6a 23                	push   $0x23
  800d12:	68 9c 25 80 00       	push   $0x80259c
  800d17:	e8 48 11 00 00       	call   801e64 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	be 00 00 00 00       	mov    $0x0,%esi
  800d2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 cb                	mov    %ecx,%ebx
  800d5f:	89 cf                	mov    %ecx,%edi
  800d61:	89 ce                	mov    %ecx,%esi
  800d63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 17                	jle    800d80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 0d                	push   $0xd
  800d6f:	68 7f 25 80 00       	push   $0x80257f
  800d74:	6a 23                	push   $0x23
  800d76:	68 9c 25 80 00       	push   $0x80259c
  800d7b:	e8 e4 10 00 00       	call   801e64 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800d8f:	89 d3                	mov    %edx,%ebx
  800d91:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800d94:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d9b:	f6 c5 04             	test   $0x4,%ch
  800d9e:	74 2f                	je     800dcf <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	68 07 0e 00 00       	push   $0xe07
  800da8:	53                   	push   %ebx
  800da9:	50                   	push   %eax
  800daa:	53                   	push   %ebx
  800dab:	6a 00                	push   $0x0
  800dad:	e8 28 fe ff ff       	call   800bda <sys_page_map>
  800db2:	83 c4 20             	add    $0x20,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	0f 89 a0 00 00 00    	jns    800e5d <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800dbd:	50                   	push   %eax
  800dbe:	68 aa 25 80 00       	push   $0x8025aa
  800dc3:	6a 4d                	push   $0x4d
  800dc5:	68 c2 25 80 00       	push   $0x8025c2
  800dca:	e8 95 10 00 00       	call   801e64 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800dcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd6:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ddc:	74 57                	je     800e35 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	68 05 08 00 00       	push   $0x805
  800de6:	53                   	push   %ebx
  800de7:	50                   	push   %eax
  800de8:	53                   	push   %ebx
  800de9:	6a 00                	push   $0x0
  800deb:	e8 ea fd ff ff       	call   800bda <sys_page_map>
  800df0:	83 c4 20             	add    $0x20,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	79 12                	jns    800e09 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800df7:	50                   	push   %eax
  800df8:	68 cd 25 80 00       	push   $0x8025cd
  800dfd:	6a 50                	push   $0x50
  800dff:	68 c2 25 80 00       	push   $0x8025c2
  800e04:	e8 5b 10 00 00       	call   801e64 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	68 05 08 00 00       	push   $0x805
  800e11:	53                   	push   %ebx
  800e12:	6a 00                	push   $0x0
  800e14:	53                   	push   %ebx
  800e15:	6a 00                	push   $0x0
  800e17:	e8 be fd ff ff       	call   800bda <sys_page_map>
  800e1c:	83 c4 20             	add    $0x20,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	79 3a                	jns    800e5d <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800e23:	50                   	push   %eax
  800e24:	68 cd 25 80 00       	push   $0x8025cd
  800e29:	6a 53                	push   $0x53
  800e2b:	68 c2 25 80 00       	push   $0x8025c2
  800e30:	e8 2f 10 00 00       	call   801e64 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	6a 05                	push   $0x5
  800e3a:	53                   	push   %ebx
  800e3b:	50                   	push   %eax
  800e3c:	53                   	push   %ebx
  800e3d:	6a 00                	push   $0x0
  800e3f:	e8 96 fd ff ff       	call   800bda <sys_page_map>
  800e44:	83 c4 20             	add    $0x20,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	79 12                	jns    800e5d <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800e4b:	50                   	push   %eax
  800e4c:	68 e1 25 80 00       	push   $0x8025e1
  800e51:	6a 56                	push   $0x56
  800e53:	68 c2 25 80 00       	push   $0x8025c2
  800e58:	e8 07 10 00 00       	call   801e64 <_panic>
	}
	return 0;
}
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e6f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e71:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e75:	74 2d                	je     800ea4 <pgfault+0x3d>
  800e77:	89 d8                	mov    %ebx,%eax
  800e79:	c1 e8 16             	shr    $0x16,%eax
  800e7c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e83:	a8 01                	test   $0x1,%al
  800e85:	74 1d                	je     800ea4 <pgfault+0x3d>
  800e87:	89 d8                	mov    %ebx,%eax
  800e89:	c1 e8 0c             	shr    $0xc,%eax
  800e8c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e93:	f6 c2 01             	test   $0x1,%dl
  800e96:	74 0c                	je     800ea4 <pgfault+0x3d>
  800e98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e9f:	f6 c4 08             	test   $0x8,%ah
  800ea2:	75 14                	jne    800eb8 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	68 60 26 80 00       	push   $0x802660
  800eac:	6a 1d                	push   $0x1d
  800eae:	68 c2 25 80 00       	push   $0x8025c2
  800eb3:	e8 ac 0f 00 00       	call   801e64 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800eb8:	e8 9c fc ff ff       	call   800b59 <sys_getenvid>
  800ebd:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	6a 07                	push   $0x7
  800ec4:	68 00 f0 7f 00       	push   $0x7ff000
  800ec9:	50                   	push   %eax
  800eca:	e8 c8 fc ff ff       	call   800b97 <sys_page_alloc>
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	79 12                	jns    800ee8 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800ed6:	50                   	push   %eax
  800ed7:	68 90 26 80 00       	push   $0x802690
  800edc:	6a 2b                	push   $0x2b
  800ede:	68 c2 25 80 00       	push   $0x8025c2
  800ee3:	e8 7c 0f 00 00       	call   801e64 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800ee8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	68 00 10 00 00       	push   $0x1000
  800ef6:	53                   	push   %ebx
  800ef7:	68 00 f0 7f 00       	push   $0x7ff000
  800efc:	e8 8d fa ff ff       	call   80098e <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800f01:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f08:	53                   	push   %ebx
  800f09:	56                   	push   %esi
  800f0a:	68 00 f0 7f 00       	push   $0x7ff000
  800f0f:	56                   	push   %esi
  800f10:	e8 c5 fc ff ff       	call   800bda <sys_page_map>
  800f15:	83 c4 20             	add    $0x20,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	79 12                	jns    800f2e <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800f1c:	50                   	push   %eax
  800f1d:	68 f4 25 80 00       	push   $0x8025f4
  800f22:	6a 2f                	push   $0x2f
  800f24:	68 c2 25 80 00       	push   $0x8025c2
  800f29:	e8 36 0f 00 00       	call   801e64 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	56                   	push   %esi
  800f37:	e8 e0 fc ff ff       	call   800c1c <sys_page_unmap>
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 12                	jns    800f55 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  800f43:	50                   	push   %eax
  800f44:	68 b4 26 80 00       	push   $0x8026b4
  800f49:	6a 32                	push   $0x32
  800f4b:	68 c2 25 80 00       	push   $0x8025c2
  800f50:	e8 0f 0f 00 00       	call   801e64 <_panic>
	//panic("pgfault not implemented");
}
  800f55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	56                   	push   %esi
  800f60:	53                   	push   %ebx
  800f61:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f64:	68 67 0e 80 00       	push   $0x800e67
  800f69:	e8 3c 0f 00 00       	call   801eaa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f6e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f73:	cd 30                	int    $0x30
  800f75:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	79 12                	jns    800f90 <fork+0x34>
		panic("sys_exofork:%e", envid);
  800f7e:	50                   	push   %eax
  800f7f:	68 11 26 80 00       	push   $0x802611
  800f84:	6a 75                	push   $0x75
  800f86:	68 c2 25 80 00       	push   $0x8025c2
  800f8b:	e8 d4 0e 00 00       	call   801e64 <_panic>
  800f90:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  800f92:	85 c0                	test   %eax,%eax
  800f94:	75 21                	jne    800fb7 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f96:	e8 be fb ff ff       	call   800b59 <sys_getenvid>
  800f9b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb2:	e9 c0 00 00 00       	jmp    801077 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800fb7:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800fbe:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800fc3:	89 d0                	mov    %edx,%eax
  800fc5:	c1 e8 16             	shr    $0x16,%eax
  800fc8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcf:	a8 01                	test   $0x1,%al
  800fd1:	74 20                	je     800ff3 <fork+0x97>
  800fd3:	c1 ea 0c             	shr    $0xc,%edx
  800fd6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fdd:	a8 01                	test   $0x1,%al
  800fdf:	74 12                	je     800ff3 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fe1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fe8:	a8 04                	test   $0x4,%al
  800fea:	74 07                	je     800ff3 <fork+0x97>
			duppage(envid, PGNUM(addr));
  800fec:	89 f0                	mov    %esi,%eax
  800fee:	e8 95 fd ff ff       	call   800d88 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  800ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff6:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  800ffc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fff:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  801005:	76 bc                	jbe    800fc3 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  801007:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80100a:	c1 ea 0c             	shr    $0xc,%edx
  80100d:	89 d8                	mov    %ebx,%eax
  80100f:	e8 74 fd ff ff       	call   800d88 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	6a 07                	push   $0x7
  801019:	68 00 f0 bf ee       	push   $0xeebff000
  80101e:	53                   	push   %ebx
  80101f:	e8 73 fb ff ff       	call   800b97 <sys_page_alloc>
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	74 15                	je     801040 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  80102b:	50                   	push   %eax
  80102c:	68 20 26 80 00       	push   $0x802620
  801031:	68 86 00 00 00       	push   $0x86
  801036:	68 c2 25 80 00       	push   $0x8025c2
  80103b:	e8 24 0e 00 00       	call   801e64 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801040:	83 ec 08             	sub    $0x8,%esp
  801043:	68 12 1f 80 00       	push   $0x801f12
  801048:	53                   	push   %ebx
  801049:	e8 94 fc ff ff       	call   800ce2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80104e:	83 c4 08             	add    $0x8,%esp
  801051:	6a 02                	push   $0x2
  801053:	53                   	push   %ebx
  801054:	e8 05 fc ff ff       	call   800c5e <sys_env_set_status>
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	74 15                	je     801075 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801060:	50                   	push   %eax
  801061:	68 32 26 80 00       	push   $0x802632
  801066:	68 8c 00 00 00       	push   $0x8c
  80106b:	68 c2 25 80 00       	push   $0x8025c2
  801070:	e8 ef 0d 00 00       	call   801e64 <_panic>

	return envid;
  801075:	89 d8                	mov    %ebx,%eax
	    
}
  801077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5e                   	pop    %esi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sfork>:

// Challenge!
int
sfork(void)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801084:	68 48 26 80 00       	push   $0x802648
  801089:	68 96 00 00 00       	push   $0x96
  80108e:	68 c2 25 80 00       	push   $0x8025c2
  801093:	e8 cc 0d 00 00       	call   801e64 <_panic>

00801098 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010ad:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	50                   	push   %eax
  8010b4:	e8 8e fc ff ff       	call   800d47 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	75 10                	jne    8010d0 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  8010c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c5:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  8010c8:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  8010cb:	8b 40 70             	mov    0x70(%eax),%eax
  8010ce:	eb 0a                	jmp    8010da <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  8010d5:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  8010da:	85 f6                	test   %esi,%esi
  8010dc:	74 02                	je     8010e0 <ipc_recv+0x48>
  8010de:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  8010e0:	85 db                	test   %ebx,%ebx
  8010e2:	74 02                	je     8010e6 <ipc_recv+0x4e>
  8010e4:	89 13                	mov    %edx,(%ebx)

    return r;
}
  8010e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801106:	0f 44 d8             	cmove  %eax,%ebx
  801109:	eb 1c                	jmp    801127 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  80110b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80110e:	74 12                	je     801122 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801110:	50                   	push   %eax
  801111:	68 d3 26 80 00       	push   $0x8026d3
  801116:	6a 40                	push   $0x40
  801118:	68 e5 26 80 00       	push   $0x8026e5
  80111d:	e8 42 0d 00 00       	call   801e64 <_panic>
        sys_yield();
  801122:	e8 51 fa ff ff       	call   800b78 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801127:	ff 75 14             	pushl  0x14(%ebp)
  80112a:	53                   	push   %ebx
  80112b:	56                   	push   %esi
  80112c:	57                   	push   %edi
  80112d:	e8 f2 fb ff ff       	call   800d24 <sys_ipc_try_send>
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	75 d2                	jne    80110b <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801147:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80114c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80114f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801155:	8b 52 50             	mov    0x50(%edx),%edx
  801158:	39 ca                	cmp    %ecx,%edx
  80115a:	75 0d                	jne    801169 <ipc_find_env+0x28>
			return envs[i].env_id;
  80115c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801164:	8b 40 48             	mov    0x48(%eax),%eax
  801167:	eb 0f                	jmp    801178 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801169:	83 c0 01             	add    $0x1,%eax
  80116c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801171:	75 d9                	jne    80114c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801173:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117d:	8b 45 08             	mov    0x8(%ebp),%eax
  801180:	05 00 00 00 30       	add    $0x30000000,%eax
  801185:	c1 e8 0c             	shr    $0xc,%eax
}
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
  801190:	05 00 00 00 30       	add    $0x30000000,%eax
  801195:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 16             	shr    $0x16,%edx
  8011b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	74 11                	je     8011ce <fd_alloc+0x2d>
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	c1 ea 0c             	shr    $0xc,%edx
  8011c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c9:	f6 c2 01             	test   $0x1,%dl
  8011cc:	75 09                	jne    8011d7 <fd_alloc+0x36>
			*fd_store = fd;
  8011ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d5:	eb 17                	jmp    8011ee <fd_alloc+0x4d>
  8011d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e1:	75 c9                	jne    8011ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f6:	83 f8 1f             	cmp    $0x1f,%eax
  8011f9:	77 36                	ja     801231 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fb:	c1 e0 0c             	shl    $0xc,%eax
  8011fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801203:	89 c2                	mov    %eax,%edx
  801205:	c1 ea 16             	shr    $0x16,%edx
  801208:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120f:	f6 c2 01             	test   $0x1,%dl
  801212:	74 24                	je     801238 <fd_lookup+0x48>
  801214:	89 c2                	mov    %eax,%edx
  801216:	c1 ea 0c             	shr    $0xc,%edx
  801219:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801220:	f6 c2 01             	test   $0x1,%dl
  801223:	74 1a                	je     80123f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801225:	8b 55 0c             	mov    0xc(%ebp),%edx
  801228:	89 02                	mov    %eax,(%edx)
	return 0;
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
  80122f:	eb 13                	jmp    801244 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801231:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801236:	eb 0c                	jmp    801244 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801238:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123d:	eb 05                	jmp    801244 <fd_lookup+0x54>
  80123f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124f:	ba 6c 27 80 00       	mov    $0x80276c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801254:	eb 13                	jmp    801269 <dev_lookup+0x23>
  801256:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801259:	39 08                	cmp    %ecx,(%eax)
  80125b:	75 0c                	jne    801269 <dev_lookup+0x23>
			*dev = devtab[i];
  80125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801260:	89 01                	mov    %eax,(%ecx)
			return 0;
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	eb 2e                	jmp    801297 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801269:	8b 02                	mov    (%edx),%eax
  80126b:	85 c0                	test   %eax,%eax
  80126d:	75 e7                	jne    801256 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126f:	a1 08 40 80 00       	mov    0x804008,%eax
  801274:	8b 40 48             	mov    0x48(%eax),%eax
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	51                   	push   %ecx
  80127b:	50                   	push   %eax
  80127c:	68 f0 26 80 00       	push   $0x8026f0
  801281:	e8 6b ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  801286:	8b 45 0c             	mov    0xc(%ebp),%eax
  801289:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 10             	sub    $0x10,%esp
  8012a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012aa:	50                   	push   %eax
  8012ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
  8012b4:	50                   	push   %eax
  8012b5:	e8 36 ff ff ff       	call   8011f0 <fd_lookup>
  8012ba:	83 c4 08             	add    $0x8,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 05                	js     8012c6 <fd_close+0x2d>
	    || fd != fd2)
  8012c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c4:	74 0c                	je     8012d2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c6:	84 db                	test   %bl,%bl
  8012c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cd:	0f 44 c2             	cmove  %edx,%eax
  8012d0:	eb 41                	jmp    801313 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 36                	pushl  (%esi)
  8012db:	e8 66 ff ff ff       	call   801246 <dev_lookup>
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 1a                	js     801303 <fd_close+0x6a>
		if (dev->dev_close)
  8012e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	74 0b                	je     801303 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f8:	83 ec 0c             	sub    $0xc,%esp
  8012fb:	56                   	push   %esi
  8012fc:	ff d0                	call   *%eax
  8012fe:	89 c3                	mov    %eax,%ebx
  801300:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	56                   	push   %esi
  801307:	6a 00                	push   $0x0
  801309:	e8 0e f9 ff ff       	call   800c1c <sys_page_unmap>
	return r;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	89 d8                	mov    %ebx,%eax
}
  801313:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 c4 fe ff ff       	call   8011f0 <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 10                	js     801343 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	6a 01                	push   $0x1
  801338:	ff 75 f4             	pushl  -0xc(%ebp)
  80133b:	e8 59 ff ff ff       	call   801299 <fd_close>
  801340:	83 c4 10             	add    $0x10,%esp
}
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <close_all>:

void
close_all(void)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	53                   	push   %ebx
  801355:	e8 c0 ff ff ff       	call   80131a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135a:	83 c3 01             	add    $0x1,%ebx
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	83 fb 20             	cmp    $0x20,%ebx
  801363:	75 ec                	jne    801351 <close_all+0xc>
		close(i);
}
  801365:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	57                   	push   %edi
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 2c             	sub    $0x2c,%esp
  801373:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801376:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	ff 75 08             	pushl  0x8(%ebp)
  80137d:	e8 6e fe ff ff       	call   8011f0 <fd_lookup>
  801382:	83 c4 08             	add    $0x8,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	0f 88 c1 00 00 00    	js     80144e <dup+0xe4>
		return r;
	close(newfdnum);
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	56                   	push   %esi
  801391:	e8 84 ff ff ff       	call   80131a <close>

	newfd = INDEX2FD(newfdnum);
  801396:	89 f3                	mov    %esi,%ebx
  801398:	c1 e3 0c             	shl    $0xc,%ebx
  80139b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a1:	83 c4 04             	add    $0x4,%esp
  8013a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a7:	e8 de fd ff ff       	call   80118a <fd2data>
  8013ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ae:	89 1c 24             	mov    %ebx,(%esp)
  8013b1:	e8 d4 fd ff ff       	call   80118a <fd2data>
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bc:	89 f8                	mov    %edi,%eax
  8013be:	c1 e8 16             	shr    $0x16,%eax
  8013c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c8:	a8 01                	test   $0x1,%al
  8013ca:	74 37                	je     801403 <dup+0x99>
  8013cc:	89 f8                	mov    %edi,%eax
  8013ce:	c1 e8 0c             	shr    $0xc,%eax
  8013d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d8:	f6 c2 01             	test   $0x1,%dl
  8013db:	74 26                	je     801403 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e4:	83 ec 0c             	sub    $0xc,%esp
  8013e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ec:	50                   	push   %eax
  8013ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f0:	6a 00                	push   $0x0
  8013f2:	57                   	push   %edi
  8013f3:	6a 00                	push   $0x0
  8013f5:	e8 e0 f7 ff ff       	call   800bda <sys_page_map>
  8013fa:	89 c7                	mov    %eax,%edi
  8013fc:	83 c4 20             	add    $0x20,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 2e                	js     801431 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801403:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801406:	89 d0                	mov    %edx,%eax
  801408:	c1 e8 0c             	shr    $0xc,%eax
  80140b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	25 07 0e 00 00       	and    $0xe07,%eax
  80141a:	50                   	push   %eax
  80141b:	53                   	push   %ebx
  80141c:	6a 00                	push   $0x0
  80141e:	52                   	push   %edx
  80141f:	6a 00                	push   $0x0
  801421:	e8 b4 f7 ff ff       	call   800bda <sys_page_map>
  801426:	89 c7                	mov    %eax,%edi
  801428:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142d:	85 ff                	test   %edi,%edi
  80142f:	79 1d                	jns    80144e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	53                   	push   %ebx
  801435:	6a 00                	push   $0x0
  801437:	e8 e0 f7 ff ff       	call   800c1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143c:	83 c4 08             	add    $0x8,%esp
  80143f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801442:	6a 00                	push   $0x0
  801444:	e8 d3 f7 ff ff       	call   800c1c <sys_page_unmap>
	return r;
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	89 f8                	mov    %edi,%eax
}
  80144e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5f                   	pop    %edi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 14             	sub    $0x14,%esp
  80145d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801460:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	53                   	push   %ebx
  801465:	e8 86 fd ff ff       	call   8011f0 <fd_lookup>
  80146a:	83 c4 08             	add    $0x8,%esp
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 6d                	js     8014e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147d:	ff 30                	pushl  (%eax)
  80147f:	e8 c2 fd ff ff       	call   801246 <dev_lookup>
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 4c                	js     8014d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148e:	8b 42 08             	mov    0x8(%edx),%eax
  801491:	83 e0 03             	and    $0x3,%eax
  801494:	83 f8 01             	cmp    $0x1,%eax
  801497:	75 21                	jne    8014ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801499:	a1 08 40 80 00       	mov    0x804008,%eax
  80149e:	8b 40 48             	mov    0x48(%eax),%eax
  8014a1:	83 ec 04             	sub    $0x4,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	50                   	push   %eax
  8014a6:	68 31 27 80 00       	push   $0x802731
  8014ab:	e8 41 ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b8:	eb 26                	jmp    8014e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bd:	8b 40 08             	mov    0x8(%eax),%eax
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	74 17                	je     8014db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c4:	83 ec 04             	sub    $0x4,%esp
  8014c7:	ff 75 10             	pushl  0x10(%ebp)
  8014ca:	ff 75 0c             	pushl  0xc(%ebp)
  8014cd:	52                   	push   %edx
  8014ce:	ff d0                	call   *%eax
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	eb 09                	jmp    8014e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	eb 05                	jmp    8014e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	57                   	push   %edi
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fb:	eb 21                	jmp    80151e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fd:	83 ec 04             	sub    $0x4,%esp
  801500:	89 f0                	mov    %esi,%eax
  801502:	29 d8                	sub    %ebx,%eax
  801504:	50                   	push   %eax
  801505:	89 d8                	mov    %ebx,%eax
  801507:	03 45 0c             	add    0xc(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	57                   	push   %edi
  80150c:	e8 45 ff ff ff       	call   801456 <read>
		if (m < 0)
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 10                	js     801528 <readn+0x41>
			return m;
		if (m == 0)
  801518:	85 c0                	test   %eax,%eax
  80151a:	74 0a                	je     801526 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151c:	01 c3                	add    %eax,%ebx
  80151e:	39 f3                	cmp    %esi,%ebx
  801520:	72 db                	jb     8014fd <readn+0x16>
  801522:	89 d8                	mov    %ebx,%eax
  801524:	eb 02                	jmp    801528 <readn+0x41>
  801526:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801528:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 14             	sub    $0x14,%esp
  801537:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	53                   	push   %ebx
  80153f:	e8 ac fc ff ff       	call   8011f0 <fd_lookup>
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	89 c2                	mov    %eax,%edx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 68                	js     8015b5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801557:	ff 30                	pushl  (%eax)
  801559:	e8 e8 fc ff ff       	call   801246 <dev_lookup>
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 47                	js     8015ac <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801565:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801568:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156c:	75 21                	jne    80158f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156e:	a1 08 40 80 00       	mov    0x804008,%eax
  801573:	8b 40 48             	mov    0x48(%eax),%eax
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	53                   	push   %ebx
  80157a:	50                   	push   %eax
  80157b:	68 4d 27 80 00       	push   $0x80274d
  801580:	e8 6c ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158d:	eb 26                	jmp    8015b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801592:	8b 52 0c             	mov    0xc(%edx),%edx
  801595:	85 d2                	test   %edx,%edx
  801597:	74 17                	je     8015b0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	ff 75 10             	pushl  0x10(%ebp)
  80159f:	ff 75 0c             	pushl  0xc(%ebp)
  8015a2:	50                   	push   %eax
  8015a3:	ff d2                	call   *%edx
  8015a5:	89 c2                	mov    %eax,%edx
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	eb 09                	jmp    8015b5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ac:	89 c2                	mov    %eax,%edx
  8015ae:	eb 05                	jmp    8015b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b5:	89 d0                	mov    %edx,%eax
  8015b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	ff 75 08             	pushl  0x8(%ebp)
  8015c9:	e8 22 fc ff ff       	call   8011f0 <fd_lookup>
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 0e                	js     8015e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e3:	c9                   	leave  
  8015e4:	c3                   	ret    

008015e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 14             	sub    $0x14,%esp
  8015ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f2:	50                   	push   %eax
  8015f3:	53                   	push   %ebx
  8015f4:	e8 f7 fb ff ff       	call   8011f0 <fd_lookup>
  8015f9:	83 c4 08             	add    $0x8,%esp
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 65                	js     801667 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160c:	ff 30                	pushl  (%eax)
  80160e:	e8 33 fc ff ff       	call   801246 <dev_lookup>
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	78 44                	js     80165e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801621:	75 21                	jne    801644 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801623:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801628:	8b 40 48             	mov    0x48(%eax),%eax
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	53                   	push   %ebx
  80162f:	50                   	push   %eax
  801630:	68 10 27 80 00       	push   $0x802710
  801635:	e8 b7 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801642:	eb 23                	jmp    801667 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801644:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801647:	8b 52 18             	mov    0x18(%edx),%edx
  80164a:	85 d2                	test   %edx,%edx
  80164c:	74 14                	je     801662 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	ff 75 0c             	pushl  0xc(%ebp)
  801654:	50                   	push   %eax
  801655:	ff d2                	call   *%edx
  801657:	89 c2                	mov    %eax,%edx
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 09                	jmp    801667 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	89 c2                	mov    %eax,%edx
  801660:	eb 05                	jmp    801667 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801662:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801667:	89 d0                	mov    %edx,%eax
  801669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 14             	sub    $0x14,%esp
  801675:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	e8 6c fb ff ff       	call   8011f0 <fd_lookup>
  801684:	83 c4 08             	add    $0x8,%esp
  801687:	89 c2                	mov    %eax,%edx
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 58                	js     8016e5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801697:	ff 30                	pushl  (%eax)
  801699:	e8 a8 fb ff ff       	call   801246 <dev_lookup>
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 37                	js     8016dc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ac:	74 32                	je     8016e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b8:	00 00 00 
	stat->st_isdir = 0;
  8016bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c2:	00 00 00 
	stat->st_dev = dev;
  8016c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	53                   	push   %ebx
  8016cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d2:	ff 50 14             	call   *0x14(%eax)
  8016d5:	89 c2                	mov    %eax,%edx
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	eb 09                	jmp    8016e5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	eb 05                	jmp    8016e5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e5:	89 d0                	mov    %edx,%eax
  8016e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	6a 00                	push   $0x0
  8016f6:	ff 75 08             	pushl  0x8(%ebp)
  8016f9:	e8 e3 01 00 00       	call   8018e1 <open>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 1b                	js     801722 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	ff 75 0c             	pushl  0xc(%ebp)
  80170d:	50                   	push   %eax
  80170e:	e8 5b ff ff ff       	call   80166e <fstat>
  801713:	89 c6                	mov    %eax,%esi
	close(fd);
  801715:	89 1c 24             	mov    %ebx,(%esp)
  801718:	e8 fd fb ff ff       	call   80131a <close>
	return r;
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	89 f0                	mov    %esi,%eax
}
  801722:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	89 c6                	mov    %eax,%esi
  801730:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801732:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801739:	75 12                	jne    80174d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	6a 01                	push   $0x1
  801740:	e8 fc f9 ff ff       	call   801141 <ipc_find_env>
  801745:	a3 00 40 80 00       	mov    %eax,0x804000
  80174a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174d:	6a 07                	push   $0x7
  80174f:	68 00 50 80 00       	push   $0x805000
  801754:	56                   	push   %esi
  801755:	ff 35 00 40 80 00    	pushl  0x804000
  80175b:	e8 8d f9 ff ff       	call   8010ed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801760:	83 c4 0c             	add    $0xc,%esp
  801763:	6a 00                	push   $0x0
  801765:	53                   	push   %ebx
  801766:	6a 00                	push   $0x0
  801768:	e8 2b f9 ff ff       	call   801098 <ipc_recv>
}
  80176d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
  80177d:	8b 40 0c             	mov    0xc(%eax),%eax
  801780:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801785:	8b 45 0c             	mov    0xc(%ebp),%eax
  801788:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80178d:	ba 00 00 00 00       	mov    $0x0,%edx
  801792:	b8 02 00 00 00       	mov    $0x2,%eax
  801797:	e8 8d ff ff ff       	call   801729 <fsipc>
}
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017af:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b9:	e8 6b ff ff ff       	call   801729 <fsipc>
}
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017da:	b8 05 00 00 00       	mov    $0x5,%eax
  8017df:	e8 45 ff ff ff       	call   801729 <fsipc>
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 2c                	js     801814 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	68 00 50 80 00       	push   $0x805000
  8017f0:	53                   	push   %ebx
  8017f1:	e8 9e ef ff ff       	call   800794 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801801:	a1 84 50 80 00       	mov    0x805084,%eax
  801806:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 0c             	sub    $0xc,%esp
  80181f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801822:	8b 55 08             	mov    0x8(%ebp),%edx
  801825:	8b 52 0c             	mov    0xc(%edx),%edx
  801828:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80182e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801833:	ba 00 10 00 00       	mov    $0x1000,%edx
  801838:	0f 47 c2             	cmova  %edx,%eax
  80183b:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801840:	50                   	push   %eax
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	68 08 50 80 00       	push   $0x805008
  801849:	e8 d8 f0 ff ff       	call   800926 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80184e:	ba 00 00 00 00       	mov    $0x0,%edx
  801853:	b8 04 00 00 00       	mov    $0x4,%eax
  801858:	e8 cc fe ff ff       	call   801729 <fsipc>
    return r;
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	8b 40 0c             	mov    0xc(%eax),%eax
  80186d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801872:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 03 00 00 00       	mov    $0x3,%eax
  801882:	e8 a2 fe ff ff       	call   801729 <fsipc>
  801887:	89 c3                	mov    %eax,%ebx
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 4b                	js     8018d8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80188d:	39 c6                	cmp    %eax,%esi
  80188f:	73 16                	jae    8018a7 <devfile_read+0x48>
  801891:	68 7c 27 80 00       	push   $0x80277c
  801896:	68 83 27 80 00       	push   $0x802783
  80189b:	6a 7c                	push   $0x7c
  80189d:	68 98 27 80 00       	push   $0x802798
  8018a2:	e8 bd 05 00 00       	call   801e64 <_panic>
	assert(r <= PGSIZE);
  8018a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ac:	7e 16                	jle    8018c4 <devfile_read+0x65>
  8018ae:	68 a3 27 80 00       	push   $0x8027a3
  8018b3:	68 83 27 80 00       	push   $0x802783
  8018b8:	6a 7d                	push   $0x7d
  8018ba:	68 98 27 80 00       	push   $0x802798
  8018bf:	e8 a0 05 00 00       	call   801e64 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c4:	83 ec 04             	sub    $0x4,%esp
  8018c7:	50                   	push   %eax
  8018c8:	68 00 50 80 00       	push   $0x805000
  8018cd:	ff 75 0c             	pushl  0xc(%ebp)
  8018d0:	e8 51 f0 ff ff       	call   800926 <memmove>
	return r;
  8018d5:	83 c4 10             	add    $0x10,%esp
}
  8018d8:	89 d8                	mov    %ebx,%eax
  8018da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5e                   	pop    %esi
  8018df:	5d                   	pop    %ebp
  8018e0:	c3                   	ret    

008018e1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 20             	sub    $0x20,%esp
  8018e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018eb:	53                   	push   %ebx
  8018ec:	e8 6a ee ff ff       	call   80075b <strlen>
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f9:	7f 67                	jg     801962 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801901:	50                   	push   %eax
  801902:	e8 9a f8 ff ff       	call   8011a1 <fd_alloc>
  801907:	83 c4 10             	add    $0x10,%esp
		return r;
  80190a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 57                	js     801967 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	53                   	push   %ebx
  801914:	68 00 50 80 00       	push   $0x805000
  801919:	e8 76 ee ff ff       	call   800794 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801921:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801926:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801929:	b8 01 00 00 00       	mov    $0x1,%eax
  80192e:	e8 f6 fd ff ff       	call   801729 <fsipc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	79 14                	jns    801950 <open+0x6f>
		fd_close(fd, 0);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	6a 00                	push   $0x0
  801941:	ff 75 f4             	pushl  -0xc(%ebp)
  801944:	e8 50 f9 ff ff       	call   801299 <fd_close>
		return r;
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	89 da                	mov    %ebx,%edx
  80194e:	eb 17                	jmp    801967 <open+0x86>
	}

	return fd2num(fd);
  801950:	83 ec 0c             	sub    $0xc,%esp
  801953:	ff 75 f4             	pushl  -0xc(%ebp)
  801956:	e8 1f f8 ff ff       	call   80117a <fd2num>
  80195b:	89 c2                	mov    %eax,%edx
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	eb 05                	jmp    801967 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801962:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801967:	89 d0                	mov    %edx,%eax
  801969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 08 00 00 00       	mov    $0x8,%eax
  80197e:	e8 a6 fd ff ff       	call   801729 <fsipc>
}
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
  80198a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80198d:	83 ec 0c             	sub    $0xc,%esp
  801990:	ff 75 08             	pushl  0x8(%ebp)
  801993:	e8 f2 f7 ff ff       	call   80118a <fd2data>
  801998:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80199a:	83 c4 08             	add    $0x8,%esp
  80199d:	68 af 27 80 00       	push   $0x8027af
  8019a2:	53                   	push   %ebx
  8019a3:	e8 ec ed ff ff       	call   800794 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019a8:	8b 46 04             	mov    0x4(%esi),%eax
  8019ab:	2b 06                	sub    (%esi),%eax
  8019ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ba:	00 00 00 
	stat->st_dev = &devpipe;
  8019bd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c4:	30 80 00 
	return 0;
}
  8019c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019dd:	53                   	push   %ebx
  8019de:	6a 00                	push   $0x0
  8019e0:	e8 37 f2 ff ff       	call   800c1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e5:	89 1c 24             	mov    %ebx,(%esp)
  8019e8:	e8 9d f7 ff ff       	call   80118a <fd2data>
  8019ed:	83 c4 08             	add    $0x8,%esp
  8019f0:	50                   	push   %eax
  8019f1:	6a 00                	push   $0x0
  8019f3:	e8 24 f2 ff ff       	call   800c1c <sys_page_unmap>
}
  8019f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	57                   	push   %edi
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	83 ec 1c             	sub    $0x1c,%esp
  801a06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a09:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a0b:	a1 08 40 80 00       	mov    0x804008,%eax
  801a10:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	ff 75 e0             	pushl  -0x20(%ebp)
  801a19:	e8 18 05 00 00       	call   801f36 <pageref>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	89 3c 24             	mov    %edi,(%esp)
  801a23:	e8 0e 05 00 00       	call   801f36 <pageref>
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	39 c3                	cmp    %eax,%ebx
  801a2d:	0f 94 c1             	sete   %cl
  801a30:	0f b6 c9             	movzbl %cl,%ecx
  801a33:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a36:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a3c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a3f:	39 ce                	cmp    %ecx,%esi
  801a41:	74 1b                	je     801a5e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a43:	39 c3                	cmp    %eax,%ebx
  801a45:	75 c4                	jne    801a0b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a47:	8b 42 58             	mov    0x58(%edx),%eax
  801a4a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a4d:	50                   	push   %eax
  801a4e:	56                   	push   %esi
  801a4f:	68 b6 27 80 00       	push   $0x8027b6
  801a54:	e8 98 e7 ff ff       	call   8001f1 <cprintf>
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	eb ad                	jmp    801a0b <_pipeisclosed+0xe>
	}
}
  801a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5f                   	pop    %edi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	57                   	push   %edi
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 28             	sub    $0x28,%esp
  801a72:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a75:	56                   	push   %esi
  801a76:	e8 0f f7 ff ff       	call   80118a <fd2data>
  801a7b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	bf 00 00 00 00       	mov    $0x0,%edi
  801a85:	eb 4b                	jmp    801ad2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a87:	89 da                	mov    %ebx,%edx
  801a89:	89 f0                	mov    %esi,%eax
  801a8b:	e8 6d ff ff ff       	call   8019fd <_pipeisclosed>
  801a90:	85 c0                	test   %eax,%eax
  801a92:	75 48                	jne    801adc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a94:	e8 df f0 ff ff       	call   800b78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a99:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9c:	8b 0b                	mov    (%ebx),%ecx
  801a9e:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa1:	39 d0                	cmp    %edx,%eax
  801aa3:	73 e2                	jae    801a87 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aaf:	89 c2                	mov    %eax,%edx
  801ab1:	c1 fa 1f             	sar    $0x1f,%edx
  801ab4:	89 d1                	mov    %edx,%ecx
  801ab6:	c1 e9 1b             	shr    $0x1b,%ecx
  801ab9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801abc:	83 e2 1f             	and    $0x1f,%edx
  801abf:	29 ca                	sub    %ecx,%edx
  801ac1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ac5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ac9:	83 c0 01             	add    $0x1,%eax
  801acc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801acf:	83 c7 01             	add    $0x1,%edi
  801ad2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ad5:	75 c2                	jne    801a99 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  801ada:	eb 05                	jmp    801ae1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	57                   	push   %edi
  801aed:	56                   	push   %esi
  801aee:	53                   	push   %ebx
  801aef:	83 ec 18             	sub    $0x18,%esp
  801af2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801af5:	57                   	push   %edi
  801af6:	e8 8f f6 ff ff       	call   80118a <fd2data>
  801afb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b05:	eb 3d                	jmp    801b44 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b07:	85 db                	test   %ebx,%ebx
  801b09:	74 04                	je     801b0f <devpipe_read+0x26>
				return i;
  801b0b:	89 d8                	mov    %ebx,%eax
  801b0d:	eb 44                	jmp    801b53 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b0f:	89 f2                	mov    %esi,%edx
  801b11:	89 f8                	mov    %edi,%eax
  801b13:	e8 e5 fe ff ff       	call   8019fd <_pipeisclosed>
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	75 32                	jne    801b4e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b1c:	e8 57 f0 ff ff       	call   800b78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b21:	8b 06                	mov    (%esi),%eax
  801b23:	3b 46 04             	cmp    0x4(%esi),%eax
  801b26:	74 df                	je     801b07 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b28:	99                   	cltd   
  801b29:	c1 ea 1b             	shr    $0x1b,%edx
  801b2c:	01 d0                	add    %edx,%eax
  801b2e:	83 e0 1f             	and    $0x1f,%eax
  801b31:	29 d0                	sub    %edx,%eax
  801b33:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b3e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b41:	83 c3 01             	add    $0x1,%ebx
  801b44:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b47:	75 d8                	jne    801b21 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b49:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4c:	eb 05                	jmp    801b53 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b4e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b56:	5b                   	pop    %ebx
  801b57:	5e                   	pop    %esi
  801b58:	5f                   	pop    %edi
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	56                   	push   %esi
  801b5f:	53                   	push   %ebx
  801b60:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b66:	50                   	push   %eax
  801b67:	e8 35 f6 ff ff       	call   8011a1 <fd_alloc>
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	89 c2                	mov    %eax,%edx
  801b71:	85 c0                	test   %eax,%eax
  801b73:	0f 88 2c 01 00 00    	js     801ca5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b79:	83 ec 04             	sub    $0x4,%esp
  801b7c:	68 07 04 00 00       	push   $0x407
  801b81:	ff 75 f4             	pushl  -0xc(%ebp)
  801b84:	6a 00                	push   $0x0
  801b86:	e8 0c f0 ff ff       	call   800b97 <sys_page_alloc>
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	89 c2                	mov    %eax,%edx
  801b90:	85 c0                	test   %eax,%eax
  801b92:	0f 88 0d 01 00 00    	js     801ca5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b98:	83 ec 0c             	sub    $0xc,%esp
  801b9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b9e:	50                   	push   %eax
  801b9f:	e8 fd f5 ff ff       	call   8011a1 <fd_alloc>
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	0f 88 e2 00 00 00    	js     801c93 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb1:	83 ec 04             	sub    $0x4,%esp
  801bb4:	68 07 04 00 00       	push   $0x407
  801bb9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 d4 ef ff ff       	call   800b97 <sys_page_alloc>
  801bc3:	89 c3                	mov    %eax,%ebx
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	0f 88 c3 00 00 00    	js     801c93 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd6:	e8 af f5 ff ff       	call   80118a <fd2data>
  801bdb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdd:	83 c4 0c             	add    $0xc,%esp
  801be0:	68 07 04 00 00       	push   $0x407
  801be5:	50                   	push   %eax
  801be6:	6a 00                	push   $0x0
  801be8:	e8 aa ef ff ff       	call   800b97 <sys_page_alloc>
  801bed:	89 c3                	mov    %eax,%ebx
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	0f 88 89 00 00 00    	js     801c83 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801c00:	e8 85 f5 ff ff       	call   80118a <fd2data>
  801c05:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c0c:	50                   	push   %eax
  801c0d:	6a 00                	push   $0x0
  801c0f:	56                   	push   %esi
  801c10:	6a 00                	push   $0x0
  801c12:	e8 c3 ef ff ff       	call   800bda <sys_page_map>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	83 c4 20             	add    $0x20,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 55                	js     801c75 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c20:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c29:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c43:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c4a:	83 ec 0c             	sub    $0xc,%esp
  801c4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c50:	e8 25 f5 ff ff       	call   80117a <fd2num>
  801c55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c58:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c5a:	83 c4 04             	add    $0x4,%esp
  801c5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c60:	e8 15 f5 ff ff       	call   80117a <fd2num>
  801c65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c68:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c73:	eb 30                	jmp    801ca5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c75:	83 ec 08             	sub    $0x8,%esp
  801c78:	56                   	push   %esi
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 9c ef ff ff       	call   800c1c <sys_page_unmap>
  801c80:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c83:	83 ec 08             	sub    $0x8,%esp
  801c86:	ff 75 f0             	pushl  -0x10(%ebp)
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 8c ef ff ff       	call   800c1c <sys_page_unmap>
  801c90:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c93:	83 ec 08             	sub    $0x8,%esp
  801c96:	ff 75 f4             	pushl  -0xc(%ebp)
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 7c ef ff ff       	call   800c1c <sys_page_unmap>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ca5:	89 d0                	mov    %edx,%eax
  801ca7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb7:	50                   	push   %eax
  801cb8:	ff 75 08             	pushl  0x8(%ebp)
  801cbb:	e8 30 f5 ff ff       	call   8011f0 <fd_lookup>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 18                	js     801cdf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cc7:	83 ec 0c             	sub    $0xc,%esp
  801cca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccd:	e8 b8 f4 ff ff       	call   80118a <fd2data>
	return _pipeisclosed(fd, p);
  801cd2:	89 c2                	mov    %eax,%edx
  801cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd7:	e8 21 fd ff ff       	call   8019fd <_pipeisclosed>
  801cdc:	83 c4 10             	add    $0x10,%esp
}
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf1:	68 ce 27 80 00       	push   $0x8027ce
  801cf6:	ff 75 0c             	pushl  0xc(%ebp)
  801cf9:	e8 96 ea ff ff       	call   800794 <strcpy>
	return 0;
}
  801cfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d11:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d16:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1c:	eb 2d                	jmp    801d4b <devcons_write+0x46>
		m = n - tot;
  801d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d21:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d23:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d26:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d2b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d2e:	83 ec 04             	sub    $0x4,%esp
  801d31:	53                   	push   %ebx
  801d32:	03 45 0c             	add    0xc(%ebp),%eax
  801d35:	50                   	push   %eax
  801d36:	57                   	push   %edi
  801d37:	e8 ea eb ff ff       	call   800926 <memmove>
		sys_cputs(buf, m);
  801d3c:	83 c4 08             	add    $0x8,%esp
  801d3f:	53                   	push   %ebx
  801d40:	57                   	push   %edi
  801d41:	e8 95 ed ff ff       	call   800adb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d46:	01 de                	add    %ebx,%esi
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	89 f0                	mov    %esi,%eax
  801d4d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d50:	72 cc                	jb     801d1e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5f                   	pop    %edi
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 08             	sub    $0x8,%esp
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d69:	74 2a                	je     801d95 <devcons_read+0x3b>
  801d6b:	eb 05                	jmp    801d72 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d6d:	e8 06 ee ff ff       	call   800b78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d72:	e8 82 ed ff ff       	call   800af9 <sys_cgetc>
  801d77:	85 c0                	test   %eax,%eax
  801d79:	74 f2                	je     801d6d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	78 16                	js     801d95 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d7f:	83 f8 04             	cmp    $0x4,%eax
  801d82:	74 0c                	je     801d90 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d87:	88 02                	mov    %al,(%edx)
	return 1;
  801d89:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8e:	eb 05                	jmp    801d95 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d90:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801da0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da3:	6a 01                	push   $0x1
  801da5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da8:	50                   	push   %eax
  801da9:	e8 2d ed ff ff       	call   800adb <sys_cputs>
}
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <getchar>:

int
getchar(void)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801db9:	6a 01                	push   $0x1
  801dbb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dbe:	50                   	push   %eax
  801dbf:	6a 00                	push   $0x0
  801dc1:	e8 90 f6 ff ff       	call   801456 <read>
	if (r < 0)
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	78 0f                	js     801ddc <getchar+0x29>
		return r;
	if (r < 1)
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	7e 06                	jle    801dd7 <getchar+0x24>
		return -E_EOF;
	return c;
  801dd1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dd5:	eb 05                	jmp    801ddc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dd7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de7:	50                   	push   %eax
  801de8:	ff 75 08             	pushl  0x8(%ebp)
  801deb:	e8 00 f4 ff ff       	call   8011f0 <fd_lookup>
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	78 11                	js     801e08 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e00:	39 10                	cmp    %edx,(%eax)
  801e02:	0f 94 c0             	sete   %al
  801e05:	0f b6 c0             	movzbl %al,%eax
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <opencons>:

int
opencons(void)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e13:	50                   	push   %eax
  801e14:	e8 88 f3 ff ff       	call   8011a1 <fd_alloc>
  801e19:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 3e                	js     801e60 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	68 07 04 00 00       	push   $0x407
  801e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 63 ed ff ff       	call   800b97 <sys_page_alloc>
  801e34:	83 c4 10             	add    $0x10,%esp
		return r;
  801e37:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 23                	js     801e60 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e3d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e46:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e52:	83 ec 0c             	sub    $0xc,%esp
  801e55:	50                   	push   %eax
  801e56:	e8 1f f3 ff ff       	call   80117a <fd2num>
  801e5b:	89 c2                	mov    %eax,%edx
  801e5d:	83 c4 10             	add    $0x10,%esp
}
  801e60:	89 d0                	mov    %edx,%eax
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    

00801e64 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e69:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e6c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e72:	e8 e2 ec ff ff       	call   800b59 <sys_getenvid>
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	ff 75 0c             	pushl  0xc(%ebp)
  801e7d:	ff 75 08             	pushl  0x8(%ebp)
  801e80:	56                   	push   %esi
  801e81:	50                   	push   %eax
  801e82:	68 dc 27 80 00       	push   $0x8027dc
  801e87:	e8 65 e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e8c:	83 c4 18             	add    $0x18,%esp
  801e8f:	53                   	push   %ebx
  801e90:	ff 75 10             	pushl  0x10(%ebp)
  801e93:	e8 08 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801e98:	c7 04 24 c7 27 80 00 	movl   $0x8027c7,(%esp)
  801e9f:	e8 4d e3 ff ff       	call   8001f1 <cprintf>
  801ea4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ea7:	cc                   	int3   
  801ea8:	eb fd                	jmp    801ea7 <_panic+0x43>

00801eaa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801eb0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb7:	75 36                	jne    801eef <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801eb9:	a1 08 40 80 00       	mov    0x804008,%eax
  801ebe:	8b 40 48             	mov    0x48(%eax),%eax
  801ec1:	83 ec 04             	sub    $0x4,%esp
  801ec4:	68 07 0e 00 00       	push   $0xe07
  801ec9:	68 00 f0 bf ee       	push   $0xeebff000
  801ece:	50                   	push   %eax
  801ecf:	e8 c3 ec ff ff       	call   800b97 <sys_page_alloc>
		if (ret < 0) {
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	79 14                	jns    801eef <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801edb:	83 ec 04             	sub    $0x4,%esp
  801ede:	68 00 28 80 00       	push   $0x802800
  801ee3:	6a 23                	push   $0x23
  801ee5:	68 28 28 80 00       	push   $0x802828
  801eea:	e8 75 ff ff ff       	call   801e64 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801eef:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef4:	8b 40 48             	mov    0x48(%eax),%eax
  801ef7:	83 ec 08             	sub    $0x8,%esp
  801efa:	68 12 1f 80 00       	push   $0x801f12
  801eff:	50                   	push   %eax
  801f00:	e8 dd ed ff ff       	call   800ce2 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f05:	8b 45 08             	mov    0x8(%ebp),%eax
  801f08:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f12:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f13:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f18:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f1a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801f1d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801f21:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801f26:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801f2a:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801f2c:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f2f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f30:	83 c4 04             	add    $0x4,%esp
        popfl
  801f33:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f34:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f35:	c3                   	ret    

00801f36 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3c:	89 d0                	mov    %edx,%eax
  801f3e:	c1 e8 16             	shr    $0x16,%eax
  801f41:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f48:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4d:	f6 c1 01             	test   $0x1,%cl
  801f50:	74 1d                	je     801f6f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f52:	c1 ea 0c             	shr    $0xc,%edx
  801f55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5c:	f6 c2 01             	test   $0x1,%dl
  801f5f:	74 0e                	je     801f6f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f61:	c1 ea 0c             	shr    $0xc,%edx
  801f64:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6b:	ef 
  801f6c:	0f b7 c0             	movzwl %ax,%eax
}
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    
  801f71:	66 90                	xchg   %ax,%ax
  801f73:	66 90                	xchg   %ax,%ax
  801f75:	66 90                	xchg   %ax,%ax
  801f77:	66 90                	xchg   %ax,%ax
  801f79:	66 90                	xchg   %ax,%ax
  801f7b:	66 90                	xchg   %ax,%ax
  801f7d:	66 90                	xchg   %ax,%ax
  801f7f:	90                   	nop

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
