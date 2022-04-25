
obj/user/spawnfaultio.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 a0 23 80 00       	push   $0x8023a0
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 be 23 80 00       	push   $0x8023be
  800056:	68 be 23 80 00       	push   $0x8023be
  80005b:	e8 37 1a 00 00       	call   801a97 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(faultio) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 c6 23 80 00       	push   $0x8023c6
  80006d:	6a 09                	push   $0x9
  80006f:	68 e0 23 80 00       	push   $0x8023e0
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 91 0a 00 00       	call   800b1c <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 4a 0e 00 00       	call   800f16 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 05 0a 00 00       	call   800adb <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 2e 0a 00 00       	call   800b1c <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 00 24 80 00       	push   $0x802400
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 c0 28 80 00 	movl   $0x8028c0,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 4d 09 00 00       	call   800a9e <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 f2 08 00 00       	call   800a9e <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 f4 1e 00 00       	call   802110 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 e1 1f 00 00       	call   802240 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 a7 03 00 00    	je     8006ae <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	eb 07                	jmp    80034b <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8d 47 01             	lea    0x1(%edi),%eax
  80034e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800351:	0f b6 07             	movzbl (%edi),%eax
  800354:	0f b6 d0             	movzbl %al,%edx
  800357:	83 e8 23             	sub    $0x23,%eax
  80035a:	3c 55                	cmp    $0x55,%al
  80035c:	0f 87 31 03 00 00    	ja     800693 <vprintfmt+0x3a8>
  800362:	0f b6 c0             	movzbl %al,%eax
  800365:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800373:	eb d6                	jmp    80034b <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800380:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800383:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800387:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038a:	8d 72 d0             	lea    -0x30(%edx),%esi
  80038d:	83 fe 09             	cmp    $0x9,%esi
  800390:	77 34                	ja     8003c6 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800392:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800395:	eb e9                	jmp    800380 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 50 04             	lea    0x4(%eax),%edx
  80039d:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a8:	eb 22                	jmp    8003cc <vprintfmt+0xe1>
  8003aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	0f 48 c1             	cmovs  %ecx,%eax
  8003b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b8:	eb 91                	jmp    80034b <vprintfmt+0x60>
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c4:	eb 85                	jmp    80034b <vprintfmt+0x60>
  8003c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003c9:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8003cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d0:	0f 89 75 ff ff ff    	jns    80034b <vprintfmt+0x60>
				width = precision, precision = -1;
  8003d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003e3:	e9 63 ff ff ff       	jmp    80034b <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ef:	e9 57 ff ff ff       	jmp    80034b <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	53                   	push   %ebx
  800401:	ff 30                	pushl  (%eax)
  800403:	ff d6                	call   *%esi
			break;
  800405:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040b:	e9 01 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	99                   	cltd   
  80041c:	31 d0                	xor    %edx,%eax
  80041e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 0f             	cmp    $0xf,%eax
  800423:	7f 0b                	jg     800430 <vprintfmt+0x145>
  800425:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 18                	jne    800448 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 3b 24 80 00       	push   $0x80243b
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 91 fe ff ff       	call   8002ce <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800443:	e9 c9 fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800448:	52                   	push   %edx
  800449:	68 f1 27 80 00       	push   $0x8027f1
  80044e:	53                   	push   %ebx
  80044f:	56                   	push   %esi
  800450:	e8 79 fe ff ff       	call   8002ce <printfmt>
  800455:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045b:	e9 b1 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046b:	85 ff                	test   %edi,%edi
  80046d:	b8 34 24 80 00       	mov    $0x802434,%eax
  800472:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800475:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800479:	0f 8e 94 00 00 00    	jle    800513 <vprintfmt+0x228>
  80047f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800483:	0f 84 98 00 00 00    	je     800521 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	ff 75 cc             	pushl  -0x34(%ebp)
  80048f:	57                   	push   %edi
  800490:	e8 a1 02 00 00       	call   800736 <strnlen>
  800495:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800498:	29 c1                	sub    %eax,%ecx
  80049a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80049d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004aa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	eb 0f                	jmp    8004bd <vprintfmt+0x1d2>
					putch(padc, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	53                   	push   %ebx
  8004b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	83 ef 01             	sub    $0x1,%edi
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	7f ed                	jg     8004ae <vprintfmt+0x1c3>
  8004c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c7:	85 c9                	test   %ecx,%ecx
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ce:	0f 49 c1             	cmovns %ecx,%eax
  8004d1:	29 c1                	sub    %eax,%ecx
  8004d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d6:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004dc:	89 cb                	mov    %ecx,%ebx
  8004de:	eb 4d                	jmp    80052d <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e4:	74 1b                	je     800501 <vprintfmt+0x216>
  8004e6:	0f be c0             	movsbl %al,%eax
  8004e9:	83 e8 20             	sub    $0x20,%eax
  8004ec:	83 f8 5e             	cmp    $0x5e,%eax
  8004ef:	76 10                	jbe    800501 <vprintfmt+0x216>
					putch('?', putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	6a 3f                	push   $0x3f
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	eb 0d                	jmp    80050e <vprintfmt+0x223>
				else
					putch(ch, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	ff 75 0c             	pushl  0xc(%ebp)
  800507:	52                   	push   %edx
  800508:	ff 55 08             	call   *0x8(%ebp)
  80050b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	83 eb 01             	sub    $0x1,%ebx
  800511:	eb 1a                	jmp    80052d <vprintfmt+0x242>
  800513:	89 75 08             	mov    %esi,0x8(%ebp)
  800516:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800519:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051f:	eb 0c                	jmp    80052d <vprintfmt+0x242>
  800521:	89 75 08             	mov    %esi,0x8(%ebp)
  800524:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052d:	83 c7 01             	add    $0x1,%edi
  800530:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800534:	0f be d0             	movsbl %al,%edx
  800537:	85 d2                	test   %edx,%edx
  800539:	74 23                	je     80055e <vprintfmt+0x273>
  80053b:	85 f6                	test   %esi,%esi
  80053d:	78 a1                	js     8004e0 <vprintfmt+0x1f5>
  80053f:	83 ee 01             	sub    $0x1,%esi
  800542:	79 9c                	jns    8004e0 <vprintfmt+0x1f5>
  800544:	89 df                	mov    %ebx,%edi
  800546:	8b 75 08             	mov    0x8(%ebp),%esi
  800549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	6a 20                	push   $0x20
  800554:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800556:	83 ef 01             	sub    $0x1,%edi
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	eb 08                	jmp    800566 <vprintfmt+0x27b>
  80055e:	89 df                	mov    %ebx,%edi
  800560:	8b 75 08             	mov    0x8(%ebp),%esi
  800563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800566:	85 ff                	test   %edi,%edi
  800568:	7f e4                	jg     80054e <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056d:	e9 9f fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800572:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800576:	7e 16                	jle    80058e <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 50 08             	lea    0x8(%eax),%edx
  80057e:	89 55 14             	mov    %edx,0x14(%ebp)
  800581:	8b 50 04             	mov    0x4(%eax),%edx
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	eb 34                	jmp    8005c2 <vprintfmt+0x2d7>
	else if (lflag)
  80058e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800592:	74 18                	je     8005ac <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a2:	89 c1                	mov    %eax,%ecx
  8005a4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005aa:	eb 16                	jmp    8005c2 <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	89 c1                	mov    %eax,%ecx
  8005bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d1:	0f 89 88 00 00 00    	jns    80065f <vprintfmt+0x374>
				putch('-', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	53                   	push   %ebx
  8005db:	6a 2d                	push   $0x2d
  8005dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e5:	f7 d8                	neg    %eax
  8005e7:	83 d2 00             	adc    $0x0,%edx
  8005ea:	f7 da                	neg    %edx
  8005ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f4:	eb 69                	jmp    80065f <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fc:	e8 76 fc ff ff       	call   800277 <getuint>
			base = 10;
  800601:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800606:	eb 57                	jmp    80065f <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 30                	push   $0x30
  80060e:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  800610:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 5c fc ff ff       	call   800277 <getuint>
			base = 8;
			goto number;
  80061b:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80061e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800623:	eb 3a                	jmp    80065f <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 30                	push   $0x30
  80062b:	ff d6                	call   *%esi
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 78                	push   $0x78
  800633:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 50 04             	lea    0x4(%eax),%edx
  80063b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800645:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800648:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064d:	eb 10                	jmp    80065f <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 1d fc ff ff       	call   800277 <getuint>
			base = 16;
  80065a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800666:	57                   	push   %edi
  800667:	ff 75 e0             	pushl  -0x20(%ebp)
  80066a:	51                   	push   %ecx
  80066b:	52                   	push   %edx
  80066c:	50                   	push   %eax
  80066d:	89 da                	mov    %ebx,%edx
  80066f:	89 f0                	mov    %esi,%eax
  800671:	e8 52 fb ff ff       	call   8001c8 <printnum>
			break;
  800676:	83 c4 20             	add    $0x20,%esp
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067c:	e9 90 fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	52                   	push   %edx
  800686:	ff d6                	call   *%esi
			break;
  800688:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068e:	e9 7e fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 25                	push   $0x25
  800699:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	eb 03                	jmp    8006a3 <vprintfmt+0x3b8>
  8006a0:	83 ef 01             	sub    $0x1,%edi
  8006a3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a7:	75 f7                	jne    8006a0 <vprintfmt+0x3b5>
  8006a9:	e9 63 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b1:	5b                   	pop    %ebx
  8006b2:	5e                   	pop    %esi
  8006b3:	5f                   	pop    %edi
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	83 ec 18             	sub    $0x18,%esp
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	74 26                	je     8006fd <vsnprintf+0x47>
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	7e 22                	jle    8006fd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006db:	ff 75 14             	pushl  0x14(%ebp)
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	68 b1 02 80 00       	push   $0x8002b1
  8006ea:	e8 fc fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	eb 05                	jmp    800702 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070d:	50                   	push   %eax
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	ff 75 08             	pushl  0x8(%ebp)
  800717:	e8 9a ff ff ff       	call   8006b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800724:	b8 00 00 00 00       	mov    $0x0,%eax
  800729:	eb 03                	jmp    80072e <strlen+0x10>
		n++;
  80072b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	75 f7                	jne    80072b <strlen+0xd>
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 03                	jmp    800749 <strnlen+0x13>
		n++;
  800746:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800749:	39 c2                	cmp    %eax,%edx
  80074b:	74 08                	je     800755 <strnlen+0x1f>
  80074d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800751:	75 f3                	jne    800746 <strnlen+0x10>
  800753:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800761:	89 c2                	mov    %eax,%edx
  800763:	83 c2 01             	add    $0x1,%edx
  800766:	83 c1 01             	add    $0x1,%ecx
  800769:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800770:	84 db                	test   %bl,%bl
  800772:	75 ef                	jne    800763 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077e:	53                   	push   %ebx
  80077f:	e8 9a ff ff ff       	call   80071e <strlen>
  800784:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800787:	ff 75 0c             	pushl  0xc(%ebp)
  80078a:	01 d8                	add    %ebx,%eax
  80078c:	50                   	push   %eax
  80078d:	e8 c5 ff ff ff       	call   800757 <strcpy>
	return dst;
}
  800792:	89 d8                	mov    %ebx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	56                   	push   %esi
  80079d:	53                   	push   %ebx
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a4:	89 f3                	mov    %esi,%ebx
  8007a6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	eb 0f                	jmp    8007bc <strncpy+0x23>
		*dst++ = *src;
  8007ad:	83 c2 01             	add    $0x1,%edx
  8007b0:	0f b6 01             	movzbl (%ecx),%eax
  8007b3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bc:	39 da                	cmp    %ebx,%edx
  8007be:	75 ed                	jne    8007ad <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	74 21                	je     8007fb <strlcpy+0x35>
  8007da:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007de:	89 f2                	mov    %esi,%edx
  8007e0:	eb 09                	jmp    8007eb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007eb:	39 c2                	cmp    %eax,%edx
  8007ed:	74 09                	je     8007f8 <strlcpy+0x32>
  8007ef:	0f b6 19             	movzbl (%ecx),%ebx
  8007f2:	84 db                	test   %bl,%bl
  8007f4:	75 ec                	jne    8007e2 <strlcpy+0x1c>
  8007f6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fb:	29 f0                	sub    %esi,%eax
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080a:	eb 06                	jmp    800812 <strcmp+0x11>
		p++, q++;
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800812:	0f b6 01             	movzbl (%ecx),%eax
  800815:	84 c0                	test   %al,%al
  800817:	74 04                	je     80081d <strcmp+0x1c>
  800819:	3a 02                	cmp    (%edx),%al
  80081b:	74 ef                	je     80080c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081d:	0f b6 c0             	movzbl %al,%eax
  800820:	0f b6 12             	movzbl (%edx),%edx
  800823:	29 d0                	sub    %edx,%eax
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	89 c3                	mov    %eax,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800836:	eb 06                	jmp    80083e <strncmp+0x17>
		n--, p++, q++;
  800838:	83 c0 01             	add    $0x1,%eax
  80083b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083e:	39 d8                	cmp    %ebx,%eax
  800840:	74 15                	je     800857 <strncmp+0x30>
  800842:	0f b6 08             	movzbl (%eax),%ecx
  800845:	84 c9                	test   %cl,%cl
  800847:	74 04                	je     80084d <strncmp+0x26>
  800849:	3a 0a                	cmp    (%edx),%cl
  80084b:	74 eb                	je     800838 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 00             	movzbl (%eax),%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
  800855:	eb 05                	jmp    80085c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 07                	jmp    800872 <strchr+0x13>
		if (*s == c)
  80086b:	38 ca                	cmp    %cl,%dl
  80086d:	74 0f                	je     80087e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	0f b6 10             	movzbl (%eax),%edx
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088a:	eb 03                	jmp    80088f <strfind+0xf>
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 04                	je     80089a <strfind+0x1a>
  800896:	84 d2                	test   %dl,%dl
  800898:	75 f2                	jne    80088c <strfind+0xc>
			break;
	return (char *) s;
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	57                   	push   %edi
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a8:	85 c9                	test   %ecx,%ecx
  8008aa:	74 36                	je     8008e2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b2:	75 28                	jne    8008dc <memset+0x40>
  8008b4:	f6 c1 03             	test   $0x3,%cl
  8008b7:	75 23                	jne    8008dc <memset+0x40>
		c &= 0xFF;
  8008b9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	89 d3                	mov    %edx,%ebx
  8008bf:	c1 e3 08             	shl    $0x8,%ebx
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	c1 e6 18             	shl    $0x18,%esi
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	c1 e0 10             	shl    $0x10,%eax
  8008cc:	09 f0                	or     %esi,%eax
  8008ce:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d0:	89 d8                	mov    %ebx,%eax
  8008d2:	09 d0                	or     %edx,%eax
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
  8008d7:	fc                   	cld    
  8008d8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008da:	eb 06                	jmp    8008e2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	fc                   	cld    
  8008e0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e2:	89 f8                	mov    %edi,%eax
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5f                   	pop    %edi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f7:	39 c6                	cmp    %eax,%esi
  8008f9:	73 35                	jae    800930 <memmove+0x47>
  8008fb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fe:	39 d0                	cmp    %edx,%eax
  800900:	73 2e                	jae    800930 <memmove+0x47>
		s += n;
		d += n;
  800902:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800905:	89 d6                	mov    %edx,%esi
  800907:	09 fe                	or     %edi,%esi
  800909:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090f:	75 13                	jne    800924 <memmove+0x3b>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 0e                	jne    800924 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800916:	83 ef 04             	sub    $0x4,%edi
  800919:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091c:	c1 e9 02             	shr    $0x2,%ecx
  80091f:	fd                   	std    
  800920:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800922:	eb 09                	jmp    80092d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	83 ef 01             	sub    $0x1,%edi
  800927:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092a:	fd                   	std    
  80092b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092d:	fc                   	cld    
  80092e:	eb 1d                	jmp    80094d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800930:	89 f2                	mov    %esi,%edx
  800932:	09 c2                	or     %eax,%edx
  800934:	f6 c2 03             	test   $0x3,%dl
  800937:	75 0f                	jne    800948 <memmove+0x5f>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 0a                	jne    800948 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 05                	jmp    80094d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800948:	89 c7                	mov    %eax,%edi
  80094a:	fc                   	cld    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 87 ff ff ff       	call   8008e9 <memmove>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096f:	89 c6                	mov    %eax,%esi
  800971:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800974:	eb 1a                	jmp    800990 <memcmp+0x2c>
		if (*s1 != *s2)
  800976:	0f b6 08             	movzbl (%eax),%ecx
  800979:	0f b6 1a             	movzbl (%edx),%ebx
  80097c:	38 d9                	cmp    %bl,%cl
  80097e:	74 0a                	je     80098a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800980:	0f b6 c1             	movzbl %cl,%eax
  800983:	0f b6 db             	movzbl %bl,%ebx
  800986:	29 d8                	sub    %ebx,%eax
  800988:	eb 0f                	jmp    800999 <memcmp+0x35>
		s1++, s2++;
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	39 f0                	cmp    %esi,%eax
  800992:	75 e2                	jne    800976 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a4:	89 c1                	mov    %eax,%ecx
  8009a6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	eb 0a                	jmp    8009b9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	39 da                	cmp    %ebx,%edx
  8009b4:	74 07                	je     8009bd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	39 c8                	cmp    %ecx,%eax
  8009bb:	72 f2                	jb     8009af <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cc:	eb 03                	jmp    8009d1 <strtol+0x11>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d1:	0f b6 01             	movzbl (%ecx),%eax
  8009d4:	3c 20                	cmp    $0x20,%al
  8009d6:	74 f6                	je     8009ce <strtol+0xe>
  8009d8:	3c 09                	cmp    $0x9,%al
  8009da:	74 f2                	je     8009ce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dc:	3c 2b                	cmp    $0x2b,%al
  8009de:	75 0a                	jne    8009ea <strtol+0x2a>
		s++;
  8009e0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e8:	eb 11                	jmp    8009fb <strtol+0x3b>
  8009ea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ef:	3c 2d                	cmp    $0x2d,%al
  8009f1:	75 08                	jne    8009fb <strtol+0x3b>
		s++, neg = 1;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a01:	75 15                	jne    800a18 <strtol+0x58>
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 10                	jne    800a18 <strtol+0x58>
  800a08:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0c:	75 7c                	jne    800a8a <strtol+0xca>
		s += 2, base = 16;
  800a0e:	83 c1 02             	add    $0x2,%ecx
  800a11:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a16:	eb 16                	jmp    800a2e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	75 12                	jne    800a2e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	75 08                	jne    800a2e <strtol+0x6e>
		s++, base = 8;
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a36:	0f b6 11             	movzbl (%ecx),%edx
  800a39:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 09             	cmp    $0x9,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x8b>
			dig = *s - '0';
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 30             	sub    $0x30,%edx
  800a49:	eb 22                	jmp    800a6d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 08                	ja     800a5d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 57             	sub    $0x57,%edx
  800a5b:	eb 10                	jmp    800a6d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a60:	89 f3                	mov    %esi,%ebx
  800a62:	80 fb 19             	cmp    $0x19,%bl
  800a65:	77 16                	ja     800a7d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a67:	0f be d2             	movsbl %dl,%edx
  800a6a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a70:	7d 0b                	jge    800a7d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a79:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7b:	eb b9                	jmp    800a36 <strtol+0x76>

	if (endptr)
  800a7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a81:	74 0d                	je     800a90 <strtol+0xd0>
		*endptr = (char *) s;
  800a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a86:	89 0e                	mov    %ecx,(%esi)
  800a88:	eb 06                	jmp    800a90 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	74 98                	je     800a26 <strtol+0x66>
  800a8e:	eb 9e                	jmp    800a2e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a90:	89 c2                	mov    %eax,%edx
  800a92:	f7 da                	neg    %edx
  800a94:	85 ff                	test   %edi,%edi
  800a96:	0f 45 c2             	cmovne %edx,%eax
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aac:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaf:	89 c3                	mov    %eax,%ebx
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	89 c6                	mov    %eax,%esi
  800ab5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_cgetc>:

int
sys_cgetc(void)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 01 00 00 00       	mov    $0x1,%eax
  800acc:	89 d1                	mov    %edx,%ecx
  800ace:	89 d3                	mov    %edx,%ebx
  800ad0:	89 d7                	mov    %edx,%edi
  800ad2:	89 d6                	mov    %edx,%esi
  800ad4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae9:	b8 03 00 00 00       	mov    $0x3,%eax
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	89 cb                	mov    %ecx,%ebx
  800af3:	89 cf                	mov    %ecx,%edi
  800af5:	89 ce                	mov    %ecx,%esi
  800af7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af9:	85 c0                	test   %eax,%eax
  800afb:	7e 17                	jle    800b14 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	50                   	push   %eax
  800b01:	6a 03                	push   $0x3
  800b03:	68 1f 27 80 00       	push   $0x80271f
  800b08:	6a 23                	push   $0x23
  800b0a:	68 3c 27 80 00       	push   $0x80273c
  800b0f:	e8 c7 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_yield>:

void
sys_yield(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	be 00 00 00 00       	mov    $0x0,%esi
  800b68:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	89 f7                	mov    %esi,%edi
  800b78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 04                	push   $0x4
  800b84:	68 1f 27 80 00       	push   $0x80271f
  800b89:	6a 23                	push   $0x23
  800b8b:	68 3c 27 80 00       	push   $0x80273c
  800b90:	e8 46 f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 05                	push   $0x5
  800bc6:	68 1f 27 80 00       	push   $0x80271f
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 3c 27 80 00       	push   $0x80273c
  800bd2:	e8 04 f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bed:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	89 df                	mov    %ebx,%edi
  800bfa:	89 de                	mov    %ebx,%esi
  800bfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 06                	push   $0x6
  800c08:	68 1f 27 80 00       	push   $0x80271f
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 3c 27 80 00       	push   $0x80273c
  800c14:	e8 c2 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 df                	mov    %ebx,%edi
  800c3c:	89 de                	mov    %ebx,%esi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 08                	push   $0x8
  800c4a:	68 1f 27 80 00       	push   $0x80271f
  800c4f:	6a 23                	push   $0x23
  800c51:	68 3c 27 80 00       	push   $0x80273c
  800c56:	e8 80 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	b8 09 00 00 00       	mov    $0x9,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 09                	push   $0x9
  800c8c:	68 1f 27 80 00       	push   $0x80271f
  800c91:	6a 23                	push   $0x23
  800c93:	68 3c 27 80 00       	push   $0x80273c
  800c98:	e8 3e f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 0a                	push   $0xa
  800cce:	68 1f 27 80 00       	push   $0x80271f
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 3c 27 80 00       	push   $0x80273c
  800cda:	e8 fc f3 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	be 00 00 00 00       	mov    $0x0,%esi
  800cf2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d03:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 cb                	mov    %ecx,%ebx
  800d22:	89 cf                	mov    %ecx,%edi
  800d24:	89 ce                	mov    %ecx,%esi
  800d26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7e 17                	jle    800d43 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	50                   	push   %eax
  800d30:	6a 0d                	push   $0xd
  800d32:	68 1f 27 80 00       	push   $0x80271f
  800d37:	6a 23                	push   $0x23
  800d39:	68 3c 27 80 00       	push   $0x80273c
  800d3e:	e8 98 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	05 00 00 00 30       	add    $0x30000000,%eax
  800d56:	c1 e8 0c             	shr    $0xc,%eax
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	05 00 00 00 30       	add    $0x30000000,%eax
  800d66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d6b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d78:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	c1 ea 16             	shr    $0x16,%edx
  800d82:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d89:	f6 c2 01             	test   $0x1,%dl
  800d8c:	74 11                	je     800d9f <fd_alloc+0x2d>
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	c1 ea 0c             	shr    $0xc,%edx
  800d93:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9a:	f6 c2 01             	test   $0x1,%dl
  800d9d:	75 09                	jne    800da8 <fd_alloc+0x36>
			*fd_store = fd;
  800d9f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
  800da6:	eb 17                	jmp    800dbf <fd_alloc+0x4d>
  800da8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db2:	75 c9                	jne    800d7d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc7:	83 f8 1f             	cmp    $0x1f,%eax
  800dca:	77 36                	ja     800e02 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dcc:	c1 e0 0c             	shl    $0xc,%eax
  800dcf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd4:	89 c2                	mov    %eax,%edx
  800dd6:	c1 ea 16             	shr    $0x16,%edx
  800dd9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de0:	f6 c2 01             	test   $0x1,%dl
  800de3:	74 24                	je     800e09 <fd_lookup+0x48>
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	c1 ea 0c             	shr    $0xc,%edx
  800dea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df1:	f6 c2 01             	test   $0x1,%dl
  800df4:	74 1a                	je     800e10 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df9:	89 02                	mov    %eax,(%edx)
	return 0;
  800dfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800e00:	eb 13                	jmp    800e15 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e07:	eb 0c                	jmp    800e15 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0e:	eb 05                	jmp    800e15 <fd_lookup+0x54>
  800e10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	ba c8 27 80 00       	mov    $0x8027c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e25:	eb 13                	jmp    800e3a <dev_lookup+0x23>
  800e27:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e2a:	39 08                	cmp    %ecx,(%eax)
  800e2c:	75 0c                	jne    800e3a <dev_lookup+0x23>
			*dev = devtab[i];
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
  800e38:	eb 2e                	jmp    800e68 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3a:	8b 02                	mov    (%edx),%eax
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	75 e7                	jne    800e27 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e40:	a1 04 40 80 00       	mov    0x804004,%eax
  800e45:	8b 40 48             	mov    0x48(%eax),%eax
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	51                   	push   %ecx
  800e4c:	50                   	push   %eax
  800e4d:	68 4c 27 80 00       	push   $0x80274c
  800e52:	e8 5d f3 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 10             	sub    $0x10,%esp
  800e72:	8b 75 08             	mov    0x8(%ebp),%esi
  800e75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7b:	50                   	push   %eax
  800e7c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e82:	c1 e8 0c             	shr    $0xc,%eax
  800e85:	50                   	push   %eax
  800e86:	e8 36 ff ff ff       	call   800dc1 <fd_lookup>
  800e8b:	83 c4 08             	add    $0x8,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 05                	js     800e97 <fd_close+0x2d>
	    || fd != fd2)
  800e92:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e95:	74 0c                	je     800ea3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e97:	84 db                	test   %bl,%bl
  800e99:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9e:	0f 44 c2             	cmove  %edx,%eax
  800ea1:	eb 41                	jmp    800ee4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ea9:	50                   	push   %eax
  800eaa:	ff 36                	pushl  (%esi)
  800eac:	e8 66 ff ff ff       	call   800e17 <dev_lookup>
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 1a                	js     800ed4 <fd_close+0x6a>
		if (dev->dev_close)
  800eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	74 0b                	je     800ed4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	56                   	push   %esi
  800ecd:	ff d0                	call   *%eax
  800ecf:	89 c3                	mov    %eax,%ebx
  800ed1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	56                   	push   %esi
  800ed8:	6a 00                	push   $0x0
  800eda:	e8 00 fd ff ff       	call   800bdf <sys_page_unmap>
	return r;
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	89 d8                	mov    %ebx,%eax
}
  800ee4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef4:	50                   	push   %eax
  800ef5:	ff 75 08             	pushl  0x8(%ebp)
  800ef8:	e8 c4 fe ff ff       	call   800dc1 <fd_lookup>
  800efd:	83 c4 08             	add    $0x8,%esp
  800f00:	85 c0                	test   %eax,%eax
  800f02:	78 10                	js     800f14 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	6a 01                	push   $0x1
  800f09:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0c:	e8 59 ff ff ff       	call   800e6a <fd_close>
  800f11:	83 c4 10             	add    $0x10,%esp
}
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <close_all>:

void
close_all(void)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f22:	83 ec 0c             	sub    $0xc,%esp
  800f25:	53                   	push   %ebx
  800f26:	e8 c0 ff ff ff       	call   800eeb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2b:	83 c3 01             	add    $0x1,%ebx
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	83 fb 20             	cmp    $0x20,%ebx
  800f34:	75 ec                	jne    800f22 <close_all+0xc>
		close(i);
}
  800f36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	57                   	push   %edi
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	83 ec 2c             	sub    $0x2c,%esp
  800f44:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	ff 75 08             	pushl  0x8(%ebp)
  800f4e:	e8 6e fe ff ff       	call   800dc1 <fd_lookup>
  800f53:	83 c4 08             	add    $0x8,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	0f 88 c1 00 00 00    	js     80101f <dup+0xe4>
		return r;
	close(newfdnum);
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	56                   	push   %esi
  800f62:	e8 84 ff ff ff       	call   800eeb <close>

	newfd = INDEX2FD(newfdnum);
  800f67:	89 f3                	mov    %esi,%ebx
  800f69:	c1 e3 0c             	shl    $0xc,%ebx
  800f6c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f72:	83 c4 04             	add    $0x4,%esp
  800f75:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f78:	e8 de fd ff ff       	call   800d5b <fd2data>
  800f7d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f7f:	89 1c 24             	mov    %ebx,(%esp)
  800f82:	e8 d4 fd ff ff       	call   800d5b <fd2data>
  800f87:	83 c4 10             	add    $0x10,%esp
  800f8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f8d:	89 f8                	mov    %edi,%eax
  800f8f:	c1 e8 16             	shr    $0x16,%eax
  800f92:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f99:	a8 01                	test   $0x1,%al
  800f9b:	74 37                	je     800fd4 <dup+0x99>
  800f9d:	89 f8                	mov    %edi,%eax
  800f9f:	c1 e8 0c             	shr    $0xc,%eax
  800fa2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa9:	f6 c2 01             	test   $0x1,%dl
  800fac:	74 26                	je     800fd4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbd:	50                   	push   %eax
  800fbe:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc1:	6a 00                	push   $0x0
  800fc3:	57                   	push   %edi
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 d2 fb ff ff       	call   800b9d <sys_page_map>
  800fcb:	89 c7                	mov    %eax,%edi
  800fcd:	83 c4 20             	add    $0x20,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 2e                	js     801002 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd7:	89 d0                	mov    %edx,%eax
  800fd9:	c1 e8 0c             	shr    $0xc,%eax
  800fdc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	25 07 0e 00 00       	and    $0xe07,%eax
  800feb:	50                   	push   %eax
  800fec:	53                   	push   %ebx
  800fed:	6a 00                	push   $0x0
  800fef:	52                   	push   %edx
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 a6 fb ff ff       	call   800b9d <sys_page_map>
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ffc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffe:	85 ff                	test   %edi,%edi
  801000:	79 1d                	jns    80101f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801002:	83 ec 08             	sub    $0x8,%esp
  801005:	53                   	push   %ebx
  801006:	6a 00                	push   $0x0
  801008:	e8 d2 fb ff ff       	call   800bdf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	ff 75 d4             	pushl  -0x2c(%ebp)
  801013:	6a 00                	push   $0x0
  801015:	e8 c5 fb ff ff       	call   800bdf <sys_page_unmap>
	return r;
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	89 f8                	mov    %edi,%eax
}
  80101f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	53                   	push   %ebx
  80102b:	83 ec 14             	sub    $0x14,%esp
  80102e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801031:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	53                   	push   %ebx
  801036:	e8 86 fd ff ff       	call   800dc1 <fd_lookup>
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	89 c2                	mov    %eax,%edx
  801040:	85 c0                	test   %eax,%eax
  801042:	78 6d                	js     8010b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104a:	50                   	push   %eax
  80104b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104e:	ff 30                	pushl  (%eax)
  801050:	e8 c2 fd ff ff       	call   800e17 <dev_lookup>
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 4c                	js     8010a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80105f:	8b 42 08             	mov    0x8(%edx),%eax
  801062:	83 e0 03             	and    $0x3,%eax
  801065:	83 f8 01             	cmp    $0x1,%eax
  801068:	75 21                	jne    80108b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106a:	a1 04 40 80 00       	mov    0x804004,%eax
  80106f:	8b 40 48             	mov    0x48(%eax),%eax
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	53                   	push   %ebx
  801076:	50                   	push   %eax
  801077:	68 8d 27 80 00       	push   $0x80278d
  80107c:	e8 33 f1 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801089:	eb 26                	jmp    8010b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80108b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108e:	8b 40 08             	mov    0x8(%eax),%eax
  801091:	85 c0                	test   %eax,%eax
  801093:	74 17                	je     8010ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	ff 75 10             	pushl  0x10(%ebp)
  80109b:	ff 75 0c             	pushl  0xc(%ebp)
  80109e:	52                   	push   %edx
  80109f:	ff d0                	call   *%eax
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	eb 09                	jmp    8010b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a8:	89 c2                	mov    %eax,%edx
  8010aa:	eb 05                	jmp    8010b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010b1:	89 d0                	mov    %edx,%eax
  8010b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cc:	eb 21                	jmp    8010ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	89 f0                	mov    %esi,%eax
  8010d3:	29 d8                	sub    %ebx,%eax
  8010d5:	50                   	push   %eax
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	03 45 0c             	add    0xc(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	57                   	push   %edi
  8010dd:	e8 45 ff ff ff       	call   801027 <read>
		if (m < 0)
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 10                	js     8010f9 <readn+0x41>
			return m;
		if (m == 0)
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	74 0a                	je     8010f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ed:	01 c3                	add    %eax,%ebx
  8010ef:	39 f3                	cmp    %esi,%ebx
  8010f1:	72 db                	jb     8010ce <readn+0x16>
  8010f3:	89 d8                	mov    %ebx,%eax
  8010f5:	eb 02                	jmp    8010f9 <readn+0x41>
  8010f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	53                   	push   %ebx
  801105:	83 ec 14             	sub    $0x14,%esp
  801108:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	53                   	push   %ebx
  801110:	e8 ac fc ff ff       	call   800dc1 <fd_lookup>
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	89 c2                	mov    %eax,%edx
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 68                	js     801186 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801128:	ff 30                	pushl  (%eax)
  80112a:	e8 e8 fc ff ff       	call   800e17 <dev_lookup>
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	78 47                	js     80117d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801136:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801139:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80113d:	75 21                	jne    801160 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80113f:	a1 04 40 80 00       	mov    0x804004,%eax
  801144:	8b 40 48             	mov    0x48(%eax),%eax
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	53                   	push   %ebx
  80114b:	50                   	push   %eax
  80114c:	68 a9 27 80 00       	push   $0x8027a9
  801151:	e8 5e f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80115e:	eb 26                	jmp    801186 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801160:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801163:	8b 52 0c             	mov    0xc(%edx),%edx
  801166:	85 d2                	test   %edx,%edx
  801168:	74 17                	je     801181 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	ff 75 10             	pushl  0x10(%ebp)
  801170:	ff 75 0c             	pushl  0xc(%ebp)
  801173:	50                   	push   %eax
  801174:	ff d2                	call   *%edx
  801176:	89 c2                	mov    %eax,%edx
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	eb 09                	jmp    801186 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	eb 05                	jmp    801186 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801181:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801186:	89 d0                	mov    %edx,%eax
  801188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <seek>:

int
seek(int fdnum, off_t offset)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801193:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801196:	50                   	push   %eax
  801197:	ff 75 08             	pushl  0x8(%ebp)
  80119a:	e8 22 fc ff ff       	call   800dc1 <fd_lookup>
  80119f:	83 c4 08             	add    $0x8,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 0e                	js     8011b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 14             	sub    $0x14,%esp
  8011bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	53                   	push   %ebx
  8011c5:	e8 f7 fb ff ff       	call   800dc1 <fd_lookup>
  8011ca:	83 c4 08             	add    $0x8,%esp
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 65                	js     801238 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dd:	ff 30                	pushl  (%eax)
  8011df:	e8 33 fc ff ff       	call   800e17 <dev_lookup>
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 44                	js     80122f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f2:	75 21                	jne    801215 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011f9:	8b 40 48             	mov    0x48(%eax),%eax
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	53                   	push   %ebx
  801200:	50                   	push   %eax
  801201:	68 6c 27 80 00       	push   $0x80276c
  801206:	e8 a9 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801213:	eb 23                	jmp    801238 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801215:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801218:	8b 52 18             	mov    0x18(%edx),%edx
  80121b:	85 d2                	test   %edx,%edx
  80121d:	74 14                	je     801233 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	ff 75 0c             	pushl  0xc(%ebp)
  801225:	50                   	push   %eax
  801226:	ff d2                	call   *%edx
  801228:	89 c2                	mov    %eax,%edx
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	eb 09                	jmp    801238 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122f:	89 c2                	mov    %eax,%edx
  801231:	eb 05                	jmp    801238 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801233:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801238:	89 d0                	mov    %edx,%eax
  80123a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	53                   	push   %ebx
  801243:	83 ec 14             	sub    $0x14,%esp
  801246:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 6c fb ff ff       	call   800dc1 <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	89 c2                	mov    %eax,%edx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 58                	js     8012b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801268:	ff 30                	pushl  (%eax)
  80126a:	e8 a8 fb ff ff       	call   800e17 <dev_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 37                	js     8012ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801276:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801279:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80127d:	74 32                	je     8012b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80127f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801282:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801289:	00 00 00 
	stat->st_isdir = 0;
  80128c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801293:	00 00 00 
	stat->st_dev = dev;
  801296:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	53                   	push   %ebx
  8012a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a3:	ff 50 14             	call   *0x14(%eax)
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	eb 09                	jmp    8012b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	eb 05                	jmp    8012b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b6:	89 d0                	mov    %edx,%eax
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	6a 00                	push   $0x0
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 e3 01 00 00       	call   8014b2 <open>
  8012cf:	89 c3                	mov    %eax,%ebx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 1b                	js     8012f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	ff 75 0c             	pushl  0xc(%ebp)
  8012de:	50                   	push   %eax
  8012df:	e8 5b ff ff ff       	call   80123f <fstat>
  8012e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e6:	89 1c 24             	mov    %ebx,(%esp)
  8012e9:	e8 fd fb ff ff       	call   800eeb <close>
	return r;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	89 f0                	mov    %esi,%eax
}
  8012f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f6:	5b                   	pop    %ebx
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	89 c6                	mov    %eax,%esi
  801301:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801303:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130a:	75 12                	jne    80131e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	6a 01                	push   $0x1
  801311:	e8 7c 0d 00 00       	call   802092 <ipc_find_env>
  801316:	a3 00 40 80 00       	mov    %eax,0x804000
  80131b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131e:	6a 07                	push   $0x7
  801320:	68 00 50 80 00       	push   $0x805000
  801325:	56                   	push   %esi
  801326:	ff 35 00 40 80 00    	pushl  0x804000
  80132c:	e8 0d 0d 00 00       	call   80203e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801331:	83 c4 0c             	add    $0xc,%esp
  801334:	6a 00                	push   $0x0
  801336:	53                   	push   %ebx
  801337:	6a 00                	push   $0x0
  801339:	e8 ab 0c 00 00       	call   801fe9 <ipc_recv>
}
  80133e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134b:	8b 45 08             	mov    0x8(%ebp),%eax
  80134e:	8b 40 0c             	mov    0xc(%eax),%eax
  801351:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801356:	8b 45 0c             	mov    0xc(%ebp),%eax
  801359:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80135e:	ba 00 00 00 00       	mov    $0x0,%edx
  801363:	b8 02 00 00 00       	mov    $0x2,%eax
  801368:	e8 8d ff ff ff       	call   8012fa <fsipc>
}
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
  801378:	8b 40 0c             	mov    0xc(%eax),%eax
  80137b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	b8 06 00 00 00       	mov    $0x6,%eax
  80138a:	e8 6b ff ff ff       	call   8012fa <fsipc>
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	53                   	push   %ebx
  801395:	83 ec 04             	sub    $0x4,%esp
  801398:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139b:	8b 45 08             	mov    0x8(%ebp),%eax
  80139e:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b0:	e8 45 ff ff ff       	call   8012fa <fsipc>
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 2c                	js     8013e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	68 00 50 80 00       	push   $0x805000
  8013c1:	53                   	push   %ebx
  8013c2:	e8 90 f3 ff ff       	call   800757 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8013cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8013f9:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8013ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801404:	ba 00 10 00 00       	mov    $0x1000,%edx
  801409:	0f 47 c2             	cmova  %edx,%eax
  80140c:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801411:	50                   	push   %eax
  801412:	ff 75 0c             	pushl  0xc(%ebp)
  801415:	68 08 50 80 00       	push   $0x805008
  80141a:	e8 ca f4 ff ff       	call   8008e9 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	b8 04 00 00 00       	mov    $0x4,%eax
  801429:	e8 cc fe ff ff       	call   8012fa <fsipc>
    return r;
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	8b 40 0c             	mov    0xc(%eax),%eax
  80143e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801443:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	b8 03 00 00 00       	mov    $0x3,%eax
  801453:	e8 a2 fe ff ff       	call   8012fa <fsipc>
  801458:	89 c3                	mov    %eax,%ebx
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 4b                	js     8014a9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80145e:	39 c6                	cmp    %eax,%esi
  801460:	73 16                	jae    801478 <devfile_read+0x48>
  801462:	68 d8 27 80 00       	push   $0x8027d8
  801467:	68 df 27 80 00       	push   $0x8027df
  80146c:	6a 7c                	push   $0x7c
  80146e:	68 f4 27 80 00       	push   $0x8027f4
  801473:	e8 63 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  801478:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80147d:	7e 16                	jle    801495 <devfile_read+0x65>
  80147f:	68 ff 27 80 00       	push   $0x8027ff
  801484:	68 df 27 80 00       	push   $0x8027df
  801489:	6a 7d                	push   $0x7d
  80148b:	68 f4 27 80 00       	push   $0x8027f4
  801490:	e8 46 ec ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	50                   	push   %eax
  801499:	68 00 50 80 00       	push   $0x805000
  80149e:	ff 75 0c             	pushl  0xc(%ebp)
  8014a1:	e8 43 f4 ff ff       	call   8008e9 <memmove>
	return r;
  8014a6:	83 c4 10             	add    $0x10,%esp
}
  8014a9:	89 d8                	mov    %ebx,%eax
  8014ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    

008014b2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 20             	sub    $0x20,%esp
  8014b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014bc:	53                   	push   %ebx
  8014bd:	e8 5c f2 ff ff       	call   80071e <strlen>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ca:	7f 67                	jg     801533 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014cc:	83 ec 0c             	sub    $0xc,%esp
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	e8 9a f8 ff ff       	call   800d72 <fd_alloc>
  8014d8:	83 c4 10             	add    $0x10,%esp
		return r;
  8014db:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 57                	js     801538 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	68 00 50 80 00       	push   $0x805000
  8014ea:	e8 68 f2 ff ff       	call   800757 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ff:	e8 f6 fd ff ff       	call   8012fa <fsipc>
  801504:	89 c3                	mov    %eax,%ebx
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	79 14                	jns    801521 <open+0x6f>
		fd_close(fd, 0);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	6a 00                	push   $0x0
  801512:	ff 75 f4             	pushl  -0xc(%ebp)
  801515:	e8 50 f9 ff ff       	call   800e6a <fd_close>
		return r;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	89 da                	mov    %ebx,%edx
  80151f:	eb 17                	jmp    801538 <open+0x86>
	}

	return fd2num(fd);
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	ff 75 f4             	pushl  -0xc(%ebp)
  801527:	e8 1f f8 ff ff       	call   800d4b <fd2num>
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	eb 05                	jmp    801538 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801533:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801538:	89 d0                	mov    %edx,%eax
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
  80154a:	b8 08 00 00 00       	mov    $0x8,%eax
  80154f:	e8 a6 fd ff ff       	call   8012fa <fsipc>
}
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	57                   	push   %edi
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
  80155c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801562:	6a 00                	push   $0x0
  801564:	ff 75 08             	pushl  0x8(%ebp)
  801567:	e8 46 ff ff ff       	call   8014b2 <open>
  80156c:	89 c7                	mov    %eax,%edi
  80156e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	0f 88 ae 04 00 00    	js     801a2d <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	68 00 02 00 00       	push   $0x200
  801587:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	57                   	push   %edi
  80158f:	e8 24 fb ff ff       	call   8010b8 <readn>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	3d 00 02 00 00       	cmp    $0x200,%eax
  80159c:	75 0c                	jne    8015aa <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80159e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015a5:	45 4c 46 
  8015a8:	74 33                	je     8015dd <spawn+0x87>
		close(fd);
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8015b3:	e8 33 f9 ff ff       	call   800eeb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015b8:	83 c4 0c             	add    $0xc,%esp
  8015bb:	68 7f 45 4c 46       	push   $0x464c457f
  8015c0:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015c6:	68 0b 28 80 00       	push   $0x80280b
  8015cb:	e8 e4 eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8015d8:	e9 b0 04 00 00       	jmp    801a8d <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8015dd:	b8 07 00 00 00       	mov    $0x7,%eax
  8015e2:	cd 30                	int    $0x30
  8015e4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8015ea:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	0f 88 3d 04 00 00    	js     801a35 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8015f8:	89 c6                	mov    %eax,%esi
  8015fa:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801600:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801603:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801609:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80160f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801614:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801616:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80161c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801622:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801627:	be 00 00 00 00       	mov    $0x0,%esi
  80162c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80162f:	eb 13                	jmp    801644 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	50                   	push   %eax
  801635:	e8 e4 f0 ff ff       	call   80071e <strlen>
  80163a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80163e:	83 c3 01             	add    $0x1,%ebx
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80164b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80164e:	85 c0                	test   %eax,%eax
  801650:	75 df                	jne    801631 <spawn+0xdb>
  801652:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801658:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80165e:	bf 00 10 40 00       	mov    $0x401000,%edi
  801663:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801665:	89 fa                	mov    %edi,%edx
  801667:	83 e2 fc             	and    $0xfffffffc,%edx
  80166a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801671:	29 c2                	sub    %eax,%edx
  801673:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801679:	8d 42 f8             	lea    -0x8(%edx),%eax
  80167c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801681:	0f 86 be 03 00 00    	jbe    801a45 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	6a 07                	push   $0x7
  80168c:	68 00 00 40 00       	push   $0x400000
  801691:	6a 00                	push   $0x0
  801693:	e8 c2 f4 ff ff       	call   800b5a <sys_page_alloc>
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	0f 88 a9 03 00 00    	js     801a4c <spawn+0x4f6>
  8016a3:	be 00 00 00 00       	mov    $0x0,%esi
  8016a8:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016b1:	eb 30                	jmp    8016e3 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8016b3:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016b9:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016bf:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016c8:	57                   	push   %edi
  8016c9:	e8 89 f0 ff ff       	call   800757 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016ce:	83 c4 04             	add    $0x4,%esp
  8016d1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016d4:	e8 45 f0 ff ff       	call   80071e <strlen>
  8016d9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8016dd:	83 c6 01             	add    $0x1,%esi
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8016e9:	7f c8                	jg     8016b3 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8016eb:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8016f1:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8016f7:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8016fe:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801704:	74 19                	je     80171f <spawn+0x1c9>
  801706:	68 80 28 80 00       	push   $0x802880
  80170b:	68 df 27 80 00       	push   $0x8027df
  801710:	68 f2 00 00 00       	push   $0xf2
  801715:	68 25 28 80 00       	push   $0x802825
  80171a:	e8 bc e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80171f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801725:	89 f8                	mov    %edi,%eax
  801727:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80172c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80172f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801735:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801738:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80173e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	6a 07                	push   $0x7
  801749:	68 00 d0 bf ee       	push   $0xeebfd000
  80174e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801754:	68 00 00 40 00       	push   $0x400000
  801759:	6a 00                	push   $0x0
  80175b:	e8 3d f4 ff ff       	call   800b9d <sys_page_map>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 20             	add    $0x20,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	0f 88 0e 03 00 00    	js     801a7b <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	68 00 00 40 00       	push   $0x400000
  801775:	6a 00                	push   $0x0
  801777:	e8 63 f4 ff ff       	call   800bdf <sys_page_unmap>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	0f 88 f2 02 00 00    	js     801a7b <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801789:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80178f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801796:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80179c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017a3:	00 00 00 
  8017a6:	e9 88 01 00 00       	jmp    801933 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8017ab:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017b1:	83 38 01             	cmpl   $0x1,(%eax)
  8017b4:	0f 85 6b 01 00 00    	jne    801925 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017ba:	89 c7                	mov    %eax,%edi
  8017bc:	8b 40 18             	mov    0x18(%eax),%eax
  8017bf:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017c5:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8017c8:	83 f8 01             	cmp    $0x1,%eax
  8017cb:	19 c0                	sbb    %eax,%eax
  8017cd:	83 e0 fe             	and    $0xfffffffe,%eax
  8017d0:	83 c0 07             	add    $0x7,%eax
  8017d3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8017d9:	89 f8                	mov    %edi,%eax
  8017db:	8b 7f 04             	mov    0x4(%edi),%edi
  8017de:	89 f9                	mov    %edi,%ecx
  8017e0:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8017e6:	8b 78 10             	mov    0x10(%eax),%edi
  8017e9:	8b 50 14             	mov    0x14(%eax),%edx
  8017ec:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8017f2:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8017f5:	89 f0                	mov    %esi,%eax
  8017f7:	25 ff 0f 00 00       	and    $0xfff,%eax
  8017fc:	74 14                	je     801812 <spawn+0x2bc>
		va -= i;
  8017fe:	29 c6                	sub    %eax,%esi
		memsz += i;
  801800:	01 c2                	add    %eax,%edx
  801802:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801808:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80180a:	29 c1                	sub    %eax,%ecx
  80180c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801812:	bb 00 00 00 00       	mov    $0x0,%ebx
  801817:	e9 f7 00 00 00       	jmp    801913 <spawn+0x3bd>
		if (i >= filesz) {
  80181c:	39 df                	cmp    %ebx,%edi
  80181e:	77 27                	ja     801847 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801820:	83 ec 04             	sub    $0x4,%esp
  801823:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801829:	56                   	push   %esi
  80182a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801830:	e8 25 f3 ff ff       	call   800b5a <sys_page_alloc>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	0f 89 c7 00 00 00    	jns    801907 <spawn+0x3b1>
  801840:	89 c3                	mov    %eax,%ebx
  801842:	e9 13 02 00 00       	jmp    801a5a <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	6a 07                	push   $0x7
  80184c:	68 00 00 40 00       	push   $0x400000
  801851:	6a 00                	push   $0x0
  801853:	e8 02 f3 ff ff       	call   800b5a <sys_page_alloc>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	0f 88 ed 01 00 00    	js     801a50 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80186c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801872:	50                   	push   %eax
  801873:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801879:	e8 0f f9 ff ff       	call   80118d <seek>
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	0f 88 cb 01 00 00    	js     801a54 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	89 f8                	mov    %edi,%eax
  80188e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801894:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801899:	ba 00 10 00 00       	mov    $0x1000,%edx
  80189e:	0f 47 c2             	cmova  %edx,%eax
  8018a1:	50                   	push   %eax
  8018a2:	68 00 00 40 00       	push   $0x400000
  8018a7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018ad:	e8 06 f8 ff ff       	call   8010b8 <readn>
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	0f 88 9b 01 00 00    	js     801a58 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018c6:	56                   	push   %esi
  8018c7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018cd:	68 00 00 40 00       	push   $0x400000
  8018d2:	6a 00                	push   $0x0
  8018d4:	e8 c4 f2 ff ff       	call   800b9d <sys_page_map>
  8018d9:	83 c4 20             	add    $0x20,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	79 15                	jns    8018f5 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8018e0:	50                   	push   %eax
  8018e1:	68 31 28 80 00       	push   $0x802831
  8018e6:	68 25 01 00 00       	push   $0x125
  8018eb:	68 25 28 80 00       	push   $0x802825
  8018f0:	e8 e6 e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	68 00 00 40 00       	push   $0x400000
  8018fd:	6a 00                	push   $0x0
  8018ff:	e8 db f2 ff ff       	call   800bdf <sys_page_unmap>
  801904:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801907:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80190d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801913:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801919:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80191f:	0f 87 f7 fe ff ff    	ja     80181c <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801925:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80192c:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801933:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80193a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801940:	0f 8c 65 fe ff ff    	jl     8017ab <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80194f:	e8 97 f5 ff ff       	call   800eeb <close>
  801954:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801957:	bb 00 00 00 00       	mov    $0x0,%ebx
  80195c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801962:	89 d8                	mov    %ebx,%eax
  801964:	c1 e8 16             	shr    $0x16,%eax
  801967:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80196e:	a8 01                	test   $0x1,%al
  801970:	74 46                	je     8019b8 <spawn+0x462>
  801972:	89 d8                	mov    %ebx,%eax
  801974:	c1 e8 0c             	shr    $0xc,%eax
  801977:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80197e:	f6 c2 01             	test   $0x1,%dl
  801981:	74 35                	je     8019b8 <spawn+0x462>
  801983:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80198a:	f6 c2 04             	test   $0x4,%dl
  80198d:	74 29                	je     8019b8 <spawn+0x462>
  80198f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801996:	f6 c6 04             	test   $0x4,%dh
  801999:	74 1d                	je     8019b8 <spawn+0x462>
			// cprintf("copy shared page %d to env:%x\n", PGNUM(addr), child);
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80199b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019a2:	83 ec 0c             	sub    $0xc,%esp
  8019a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8019aa:	50                   	push   %eax
  8019ab:	53                   	push   %ebx
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	6a 00                	push   $0x0
  8019b0:	e8 e8 f1 ff ff       	call   800b9d <sys_page_map>
  8019b5:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8019b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019be:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8019c4:	75 9c                	jne    801962 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8019c6:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8019cd:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019e0:	e8 7e f2 ff ff       	call   800c63 <sys_env_set_trapframe>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	79 15                	jns    801a01 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  8019ec:	50                   	push   %eax
  8019ed:	68 4e 28 80 00       	push   $0x80284e
  8019f2:	68 86 00 00 00       	push   $0x86
  8019f7:	68 25 28 80 00       	push   $0x802825
  8019fc:	e8 da e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a01:	83 ec 08             	sub    $0x8,%esp
  801a04:	6a 02                	push   $0x2
  801a06:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a0c:	e8 10 f2 ff ff       	call   800c21 <sys_env_set_status>
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	79 25                	jns    801a3d <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801a18:	50                   	push   %eax
  801a19:	68 68 28 80 00       	push   $0x802868
  801a1e:	68 89 00 00 00       	push   $0x89
  801a23:	68 25 28 80 00       	push   $0x802825
  801a28:	e8 ae e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a2d:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a33:	eb 58                	jmp    801a8d <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a35:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a3b:	eb 50                	jmp    801a8d <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a3d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a43:	eb 48                	jmp    801a8d <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a45:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a4a:	eb 41                	jmp    801a8d <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a4c:	89 c3                	mov    %eax,%ebx
  801a4e:	eb 3d                	jmp    801a8d <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a50:	89 c3                	mov    %eax,%ebx
  801a52:	eb 06                	jmp    801a5a <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a54:	89 c3                	mov    %eax,%ebx
  801a56:	eb 02                	jmp    801a5a <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a58:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a63:	e8 73 f0 ff ff       	call   800adb <sys_env_destroy>
	close(fd);
  801a68:	83 c4 04             	add    $0x4,%esp
  801a6b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a71:	e8 75 f4 ff ff       	call   800eeb <close>
	return r;
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	eb 12                	jmp    801a8d <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	68 00 00 40 00       	push   $0x400000
  801a83:	6a 00                	push   $0x0
  801a85:	e8 55 f1 ff ff       	call   800bdf <sys_page_unmap>
  801a8a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a8d:	89 d8                	mov    %ebx,%eax
  801a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a9c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801aa4:	eb 03                	jmp    801aa9 <spawnl+0x12>
		argc++;
  801aa6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801aa9:	83 c2 04             	add    $0x4,%edx
  801aac:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ab0:	75 f4                	jne    801aa6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ab2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ab9:	83 e2 f0             	and    $0xfffffff0,%edx
  801abc:	29 d4                	sub    %edx,%esp
  801abe:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ac2:	c1 ea 02             	shr    $0x2,%edx
  801ac5:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801acc:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ad8:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801adf:	00 
  801ae0:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae7:	eb 0a                	jmp    801af3 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ae9:	83 c0 01             	add    $0x1,%eax
  801aec:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801af0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801af3:	39 d0                	cmp    %edx,%eax
  801af5:	75 f2                	jne    801ae9 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801af7:	83 ec 08             	sub    $0x8,%esp
  801afa:	56                   	push   %esi
  801afb:	ff 75 08             	pushl  0x8(%ebp)
  801afe:	e8 53 fa ff ff       	call   801556 <spawn>
}
  801b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	56                   	push   %esi
  801b0e:	53                   	push   %ebx
  801b0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	ff 75 08             	pushl  0x8(%ebp)
  801b18:	e8 3e f2 ff ff       	call   800d5b <fd2data>
  801b1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b1f:	83 c4 08             	add    $0x8,%esp
  801b22:	68 a8 28 80 00       	push   $0x8028a8
  801b27:	53                   	push   %ebx
  801b28:	e8 2a ec ff ff       	call   800757 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b2d:	8b 46 04             	mov    0x4(%esi),%eax
  801b30:	2b 06                	sub    (%esi),%eax
  801b32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b3f:	00 00 00 
	stat->st_dev = &devpipe;
  801b42:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b49:	30 80 00 
	return 0;
}
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b62:	53                   	push   %ebx
  801b63:	6a 00                	push   $0x0
  801b65:	e8 75 f0 ff ff       	call   800bdf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b6a:	89 1c 24             	mov    %ebx,(%esp)
  801b6d:	e8 e9 f1 ff ff       	call   800d5b <fd2data>
  801b72:	83 c4 08             	add    $0x8,%esp
  801b75:	50                   	push   %eax
  801b76:	6a 00                	push   $0x0
  801b78:	e8 62 f0 ff ff       	call   800bdf <sys_page_unmap>
}
  801b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	57                   	push   %edi
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	83 ec 1c             	sub    $0x1c,%esp
  801b8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b8e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b90:	a1 04 40 80 00       	mov    0x804004,%eax
  801b95:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b98:	83 ec 0c             	sub    $0xc,%esp
  801b9b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9e:	e8 28 05 00 00       	call   8020cb <pageref>
  801ba3:	89 c3                	mov    %eax,%ebx
  801ba5:	89 3c 24             	mov    %edi,(%esp)
  801ba8:	e8 1e 05 00 00       	call   8020cb <pageref>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	39 c3                	cmp    %eax,%ebx
  801bb2:	0f 94 c1             	sete   %cl
  801bb5:	0f b6 c9             	movzbl %cl,%ecx
  801bb8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bbb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bc1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc4:	39 ce                	cmp    %ecx,%esi
  801bc6:	74 1b                	je     801be3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bc8:	39 c3                	cmp    %eax,%ebx
  801bca:	75 c4                	jne    801b90 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bcc:	8b 42 58             	mov    0x58(%edx),%eax
  801bcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd2:	50                   	push   %eax
  801bd3:	56                   	push   %esi
  801bd4:	68 af 28 80 00       	push   $0x8028af
  801bd9:	e8 d6 e5 ff ff       	call   8001b4 <cprintf>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	eb ad                	jmp    801b90 <_pipeisclosed+0xe>
	}
}
  801be3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5f                   	pop    %edi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 28             	sub    $0x28,%esp
  801bf7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bfa:	56                   	push   %esi
  801bfb:	e8 5b f1 ff ff       	call   800d5b <fd2data>
  801c00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	bf 00 00 00 00       	mov    $0x0,%edi
  801c0a:	eb 4b                	jmp    801c57 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c0c:	89 da                	mov    %ebx,%edx
  801c0e:	89 f0                	mov    %esi,%eax
  801c10:	e8 6d ff ff ff       	call   801b82 <_pipeisclosed>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	75 48                	jne    801c61 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c19:	e8 1d ef ff ff       	call   800b3b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c21:	8b 0b                	mov    (%ebx),%ecx
  801c23:	8d 51 20             	lea    0x20(%ecx),%edx
  801c26:	39 d0                	cmp    %edx,%eax
  801c28:	73 e2                	jae    801c0c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c31:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c34:	89 c2                	mov    %eax,%edx
  801c36:	c1 fa 1f             	sar    $0x1f,%edx
  801c39:	89 d1                	mov    %edx,%ecx
  801c3b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c3e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c41:	83 e2 1f             	and    $0x1f,%edx
  801c44:	29 ca                	sub    %ecx,%edx
  801c46:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c54:	83 c7 01             	add    $0x1,%edi
  801c57:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c5a:	75 c2                	jne    801c1e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5f:	eb 05                	jmp    801c66 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 18             	sub    $0x18,%esp
  801c77:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c7a:	57                   	push   %edi
  801c7b:	e8 db f0 ff ff       	call   800d5b <fd2data>
  801c80:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8a:	eb 3d                	jmp    801cc9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c8c:	85 db                	test   %ebx,%ebx
  801c8e:	74 04                	je     801c94 <devpipe_read+0x26>
				return i;
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	eb 44                	jmp    801cd8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f8                	mov    %edi,%eax
  801c98:	e8 e5 fe ff ff       	call   801b82 <_pipeisclosed>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	75 32                	jne    801cd3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ca1:	e8 95 ee ff ff       	call   800b3b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca6:	8b 06                	mov    (%esi),%eax
  801ca8:	3b 46 04             	cmp    0x4(%esi),%eax
  801cab:	74 df                	je     801c8c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cad:	99                   	cltd   
  801cae:	c1 ea 1b             	shr    $0x1b,%edx
  801cb1:	01 d0                	add    %edx,%eax
  801cb3:	83 e0 1f             	and    $0x1f,%eax
  801cb6:	29 d0                	sub    %edx,%eax
  801cb8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cc3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc6:	83 c3 01             	add    $0x1,%ebx
  801cc9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ccc:	75 d8                	jne    801ca6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cce:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd1:	eb 05                	jmp    801cd8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	56                   	push   %esi
  801ce4:	53                   	push   %ebx
  801ce5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	e8 81 f0 ff ff       	call   800d72 <fd_alloc>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 2c 01 00 00    	js     801e2a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfe:	83 ec 04             	sub    $0x4,%esp
  801d01:	68 07 04 00 00       	push   $0x407
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 4a ee ff ff       	call   800b5a <sys_page_alloc>
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	0f 88 0d 01 00 00    	js     801e2a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	e8 49 f0 ff ff       	call   800d72 <fd_alloc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 e2 00 00 00    	js     801e18 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d36:	83 ec 04             	sub    $0x4,%esp
  801d39:	68 07 04 00 00       	push   $0x407
  801d3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 12 ee ff ff       	call   800b5a <sys_page_alloc>
  801d48:	89 c3                	mov    %eax,%ebx
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	0f 88 c3 00 00 00    	js     801e18 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d55:	83 ec 0c             	sub    $0xc,%esp
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	e8 fb ef ff ff       	call   800d5b <fd2data>
  801d60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d62:	83 c4 0c             	add    $0xc,%esp
  801d65:	68 07 04 00 00       	push   $0x407
  801d6a:	50                   	push   %eax
  801d6b:	6a 00                	push   $0x0
  801d6d:	e8 e8 ed ff ff       	call   800b5a <sys_page_alloc>
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 89 00 00 00    	js     801e08 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff 75 f0             	pushl  -0x10(%ebp)
  801d85:	e8 d1 ef ff ff       	call   800d5b <fd2data>
  801d8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d91:	50                   	push   %eax
  801d92:	6a 00                	push   $0x0
  801d94:	56                   	push   %esi
  801d95:	6a 00                	push   $0x0
  801d97:	e8 01 ee ff ff       	call   800b9d <sys_page_map>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	83 c4 20             	add    $0x20,%esp
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 55                	js     801dfa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801da5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd5:	e8 71 ef ff ff       	call   800d4b <fd2num>
  801dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ddf:	83 c4 04             	add    $0x4,%esp
  801de2:	ff 75 f0             	pushl  -0x10(%ebp)
  801de5:	e8 61 ef ff ff       	call   800d4b <fd2num>
  801dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ded:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	ba 00 00 00 00       	mov    $0x0,%edx
  801df8:	eb 30                	jmp    801e2a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dfa:	83 ec 08             	sub    $0x8,%esp
  801dfd:	56                   	push   %esi
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 da ed ff ff       	call   800bdf <sys_page_unmap>
  801e05:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e08:	83 ec 08             	sub    $0x8,%esp
  801e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0e:	6a 00                	push   $0x0
  801e10:	e8 ca ed ff ff       	call   800bdf <sys_page_unmap>
  801e15:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e18:	83 ec 08             	sub    $0x8,%esp
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 ba ed ff ff       	call   800bdf <sys_page_unmap>
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e2a:	89 d0                	mov    %edx,%eax
  801e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	ff 75 08             	pushl  0x8(%ebp)
  801e40:	e8 7c ef ff ff       	call   800dc1 <fd_lookup>
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	78 18                	js     801e64 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	e8 04 ef ff ff       	call   800d5b <fd2data>
	return _pipeisclosed(fd, p);
  801e57:	89 c2                	mov    %eax,%edx
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	e8 21 fd ff ff       	call   801b82 <_pipeisclosed>
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e69:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6e:	5d                   	pop    %ebp
  801e6f:	c3                   	ret    

00801e70 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e76:	68 c7 28 80 00       	push   $0x8028c7
  801e7b:	ff 75 0c             	pushl  0xc(%ebp)
  801e7e:	e8 d4 e8 ff ff       	call   800757 <strcpy>
	return 0;
}
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	57                   	push   %edi
  801e8e:	56                   	push   %esi
  801e8f:	53                   	push   %ebx
  801e90:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e96:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e9b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea1:	eb 2d                	jmp    801ed0 <devcons_write+0x46>
		m = n - tot;
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ea8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eb0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb3:	83 ec 04             	sub    $0x4,%esp
  801eb6:	53                   	push   %ebx
  801eb7:	03 45 0c             	add    0xc(%ebp),%eax
  801eba:	50                   	push   %eax
  801ebb:	57                   	push   %edi
  801ebc:	e8 28 ea ff ff       	call   8008e9 <memmove>
		sys_cputs(buf, m);
  801ec1:	83 c4 08             	add    $0x8,%esp
  801ec4:	53                   	push   %ebx
  801ec5:	57                   	push   %edi
  801ec6:	e8 d3 eb ff ff       	call   800a9e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecb:	01 de                	add    %ebx,%esi
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	89 f0                	mov    %esi,%eax
  801ed2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed5:	72 cc                	jb     801ea3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 08             	sub    $0x8,%esp
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eee:	74 2a                	je     801f1a <devcons_read+0x3b>
  801ef0:	eb 05                	jmp    801ef7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ef2:	e8 44 ec ff ff       	call   800b3b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef7:	e8 c0 eb ff ff       	call   800abc <sys_cgetc>
  801efc:	85 c0                	test   %eax,%eax
  801efe:	74 f2                	je     801ef2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 16                	js     801f1a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f04:	83 f8 04             	cmp    $0x4,%eax
  801f07:	74 0c                	je     801f15 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f09:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0c:	88 02                	mov    %al,(%edx)
	return 1;
  801f0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f13:	eb 05                	jmp    801f1a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f15:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f28:	6a 01                	push   $0x1
  801f2a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f2d:	50                   	push   %eax
  801f2e:	e8 6b eb ff ff       	call   800a9e <sys_cputs>
}
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <getchar>:

int
getchar(void)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f3e:	6a 01                	push   $0x1
  801f40:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	6a 00                	push   $0x0
  801f46:	e8 dc f0 ff ff       	call   801027 <read>
	if (r < 0)
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 0f                	js     801f61 <getchar+0x29>
		return r;
	if (r < 1)
  801f52:	85 c0                	test   %eax,%eax
  801f54:	7e 06                	jle    801f5c <getchar+0x24>
		return -E_EOF;
	return c;
  801f56:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f5a:	eb 05                	jmp    801f61 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f5c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6c:	50                   	push   %eax
  801f6d:	ff 75 08             	pushl  0x8(%ebp)
  801f70:	e8 4c ee ff ff       	call   800dc1 <fd_lookup>
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 11                	js     801f8d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f85:	39 10                	cmp    %edx,(%eax)
  801f87:	0f 94 c0             	sete   %al
  801f8a:	0f b6 c0             	movzbl %al,%eax
}
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <opencons>:

int
opencons(void)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f98:	50                   	push   %eax
  801f99:	e8 d4 ed ff ff       	call   800d72 <fd_alloc>
  801f9e:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 3e                	js     801fe5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa7:	83 ec 04             	sub    $0x4,%esp
  801faa:	68 07 04 00 00       	push   $0x407
  801faf:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb2:	6a 00                	push   $0x0
  801fb4:	e8 a1 eb ff ff       	call   800b5a <sys_page_alloc>
  801fb9:	83 c4 10             	add    $0x10,%esp
		return r;
  801fbc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	78 23                	js     801fe5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fc2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd7:	83 ec 0c             	sub    $0xc,%esp
  801fda:	50                   	push   %eax
  801fdb:	e8 6b ed ff ff       	call   800d4b <fd2num>
  801fe0:	89 c2                	mov    %eax,%edx
  801fe2:	83 c4 10             	add    $0x10,%esp
}
  801fe5:	89 d0                	mov    %edx,%eax
  801fe7:	c9                   	leave  
  801fe8:	c3                   	ret    

00801fe9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
  801fee:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff4:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ffe:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	50                   	push   %eax
  802005:	e8 00 ed ff ff       	call   800d0a <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	75 10                	jne    802021 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  802011:	a1 04 40 80 00       	mov    0x804004,%eax
  802016:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  802019:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  80201c:	8b 40 70             	mov    0x70(%eax),%eax
  80201f:	eb 0a                	jmp    80202b <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  802021:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  802026:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  80202b:	85 f6                	test   %esi,%esi
  80202d:	74 02                	je     802031 <ipc_recv+0x48>
  80202f:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  802031:	85 db                	test   %ebx,%ebx
  802033:	74 02                	je     802037 <ipc_recv+0x4e>
  802035:	89 13                	mov    %edx,(%ebx)

    return r;
}
  802037:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802050:	85 db                	test   %ebx,%ebx
  802052:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802057:	0f 44 d8             	cmove  %eax,%ebx
  80205a:	eb 1c                	jmp    802078 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  80205c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80205f:	74 12                	je     802073 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  802061:	50                   	push   %eax
  802062:	68 d3 28 80 00       	push   $0x8028d3
  802067:	6a 40                	push   $0x40
  802069:	68 e5 28 80 00       	push   $0x8028e5
  80206e:	e8 68 e0 ff ff       	call   8000db <_panic>
        sys_yield();
  802073:	e8 c3 ea ff ff       	call   800b3b <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802078:	ff 75 14             	pushl  0x14(%ebp)
  80207b:	53                   	push   %ebx
  80207c:	56                   	push   %esi
  80207d:	57                   	push   %edi
  80207e:	e8 64 ec ff ff       	call   800ce7 <sys_ipc_try_send>
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	75 d2                	jne    80205c <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  80208a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    

00802092 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802098:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80209d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a6:	8b 52 50             	mov    0x50(%edx),%edx
  8020a9:	39 ca                	cmp    %ecx,%edx
  8020ab:	75 0d                	jne    8020ba <ipc_find_env+0x28>
			return envs[i].env_id;
  8020ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b5:	8b 40 48             	mov    0x48(%eax),%eax
  8020b8:	eb 0f                	jmp    8020c9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020ba:	83 c0 01             	add    $0x1,%eax
  8020bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c2:	75 d9                	jne    80209d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d1:	89 d0                	mov    %edx,%eax
  8020d3:	c1 e8 16             	shr    $0x16,%eax
  8020d6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020dd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e2:	f6 c1 01             	test   $0x1,%cl
  8020e5:	74 1d                	je     802104 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e7:	c1 ea 0c             	shr    $0xc,%edx
  8020ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f1:	f6 c2 01             	test   $0x1,%dl
  8020f4:	74 0e                	je     802104 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f6:	c1 ea 0c             	shr    $0xc,%edx
  8020f9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802100:	ef 
  802101:	0f b7 c0             	movzwl %ax,%eax
}
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
