
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 00 20 80 00       	push   $0x802000
  800062:	e8 f3 16 00 00       	call   80175a <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 8a 11 00 00       	call   80120b <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 05 20 80 00       	push   $0x802005
  800095:	6a 13                	push   $0x13
  800097:	68 20 20 80 00       	push   $0x802020
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 74 10 00 00       	call   801131 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 2b 20 80 00       	push   $0x80202b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 20 20 80 00       	push   $0x802020
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 40 	movl   $0x802040,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 44 20 80 00       	push   $0x802044
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 88 14 00 00       	call   8015bc <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 4c 20 80 00       	push   $0x80204c
  80014b:	6a 27                	push   $0x27
  80014d:	68 20 20 80 00       	push   $0x802020
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 8b 0e 00 00       	call   800ff5 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800190:	e8 91 0a 00 00       	call   800c26 <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 4a 0e 00 00       	call   801020 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 05 0a 00 00       	call   800be5 <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 2e 0a 00 00       	call   800c26 <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 68 20 80 00       	push   $0x802068
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 87 24 80 00 	movl   $0x802487,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 4d 09 00 00       	call   800ba8 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 54 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 f2 08 00 00       	call   800ba8 <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 4a 1a 00 00       	call   801d70 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 37 1b 00 00       	call   801ea0 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 8b 20 80 00 	movsbl 0x80208b(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800384:	83 fa 01             	cmp    $0x1,%edx
  800387:	7e 0e                	jle    800397 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	8b 52 04             	mov    0x4(%edx),%edx
  800395:	eb 22                	jmp    8003b9 <getuint+0x38>
	else if (lflag)
  800397:	85 d2                	test   %edx,%edx
  800399:	74 10                	je     8003ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a9:	eb 0e                	jmp    8003b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 02                	mov    %al,(%edx)
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	pushl  0x10(%ebp)
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
	va_end(ap);
}
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800404:	8b 7d 10             	mov    0x10(%ebp),%edi
  800407:	eb 12                	jmp    80041b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800409:	85 c0                	test   %eax,%eax
  80040b:	0f 84 a7 03 00 00    	je     8007b8 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	50                   	push   %eax
  800416:	ff d6                	call   *%esi
  800418:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	83 c7 01             	add    $0x1,%edi
  80041e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800422:	83 f8 25             	cmp    $0x25,%eax
  800425:	75 e2                	jne    800409 <vprintfmt+0x14>
  800427:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800432:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800439:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800440:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800447:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044c:	eb 07                	jmp    800455 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800451:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8d 47 01             	lea    0x1(%edi),%eax
  800458:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045b:	0f b6 07             	movzbl (%edi),%eax
  80045e:	0f b6 d0             	movzbl %al,%edx
  800461:	83 e8 23             	sub    $0x23,%eax
  800464:	3c 55                	cmp    $0x55,%al
  800466:	0f 87 31 03 00 00    	ja     80079d <vprintfmt+0x3a8>
  80046c:	0f b6 c0             	movzbl %al,%eax
  80046f:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800479:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80047d:	eb d6                	jmp    800455 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800482:	b8 00 00 00 00       	mov    $0x0,%eax
  800487:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80048d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800491:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800494:	8d 72 d0             	lea    -0x30(%edx),%esi
  800497:	83 fe 09             	cmp    $0x9,%esi
  80049a:	77 34                	ja     8004d0 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80049f:	eb e9                	jmp    80048a <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b2:	eb 22                	jmp    8004d6 <vprintfmt+0xe1>
  8004b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	0f 48 c1             	cmovs  %ecx,%eax
  8004bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	eb 91                	jmp    800455 <vprintfmt+0x60>
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ce:	eb 85                	jmp    800455 <vprintfmt+0x60>
  8004d0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004d3:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8004d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004da:	0f 89 75 ff ff ff    	jns    800455 <vprintfmt+0x60>
				width = precision, precision = -1;
  8004e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e6:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004ed:	e9 63 ff ff ff       	jmp    800455 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f2:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f9:	e9 57 ff ff ff       	jmp    800455 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	53                   	push   %ebx
  80050b:	ff 30                	pushl  (%eax)
  80050d:	ff d6                	call   *%esi
			break;
  80050f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800515:	e9 01 ff ff ff       	jmp    80041b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 04             	lea    0x4(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	8b 00                	mov    (%eax),%eax
  800525:	99                   	cltd   
  800526:	31 d0                	xor    %edx,%eax
  800528:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052a:	83 f8 0f             	cmp    $0xf,%eax
  80052d:	7f 0b                	jg     80053a <vprintfmt+0x145>
  80052f:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  800536:	85 d2                	test   %edx,%edx
  800538:	75 18                	jne    800552 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80053a:	50                   	push   %eax
  80053b:	68 a3 20 80 00       	push   $0x8020a3
  800540:	53                   	push   %ebx
  800541:	56                   	push   %esi
  800542:	e8 91 fe ff ff       	call   8003d8 <printfmt>
  800547:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054d:	e9 c9 fe ff ff       	jmp    80041b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800552:	52                   	push   %edx
  800553:	68 55 24 80 00       	push   $0x802455
  800558:	53                   	push   %ebx
  800559:	56                   	push   %esi
  80055a:	e8 79 fe ff ff       	call   8003d8 <printfmt>
  80055f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800565:	e9 b1 fe ff ff       	jmp    80041b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 04             	lea    0x4(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800575:	85 ff                	test   %edi,%edi
  800577:	b8 9c 20 80 00       	mov    $0x80209c,%eax
  80057c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80057f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800583:	0f 8e 94 00 00 00    	jle    80061d <vprintfmt+0x228>
  800589:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058d:	0f 84 98 00 00 00    	je     80062b <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	ff 75 cc             	pushl  -0x34(%ebp)
  800599:	57                   	push   %edi
  80059a:	e8 a1 02 00 00       	call   800840 <strnlen>
  80059f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a2:	29 c1                	sub    %eax,%ecx
  8005a4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b6:	eb 0f                	jmp    8005c7 <vprintfmt+0x1d2>
					putch(padc, putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	53                   	push   %ebx
  8005bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 ef 01             	sub    $0x1,%edi
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	85 ff                	test   %edi,%edi
  8005c9:	7f ed                	jg     8005b8 <vprintfmt+0x1c3>
  8005cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d8:	0f 49 c1             	cmovns %ecx,%eax
  8005db:	29 c1                	sub    %eax,%ecx
  8005dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e6:	89 cb                	mov    %ecx,%ebx
  8005e8:	eb 4d                	jmp    800637 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ee:	74 1b                	je     80060b <vprintfmt+0x216>
  8005f0:	0f be c0             	movsbl %al,%eax
  8005f3:	83 e8 20             	sub    $0x20,%eax
  8005f6:	83 f8 5e             	cmp    $0x5e,%eax
  8005f9:	76 10                	jbe    80060b <vprintfmt+0x216>
					putch('?', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	6a 3f                	push   $0x3f
  800603:	ff 55 08             	call   *0x8(%ebp)
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb 0d                	jmp    800618 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	ff 75 0c             	pushl  0xc(%ebp)
  800611:	52                   	push   %edx
  800612:	ff 55 08             	call   *0x8(%ebp)
  800615:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800618:	83 eb 01             	sub    $0x1,%ebx
  80061b:	eb 1a                	jmp    800637 <vprintfmt+0x242>
  80061d:	89 75 08             	mov    %esi,0x8(%ebp)
  800620:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800623:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800626:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800629:	eb 0c                	jmp    800637 <vprintfmt+0x242>
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800637:	83 c7 01             	add    $0x1,%edi
  80063a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063e:	0f be d0             	movsbl %al,%edx
  800641:	85 d2                	test   %edx,%edx
  800643:	74 23                	je     800668 <vprintfmt+0x273>
  800645:	85 f6                	test   %esi,%esi
  800647:	78 a1                	js     8005ea <vprintfmt+0x1f5>
  800649:	83 ee 01             	sub    $0x1,%esi
  80064c:	79 9c                	jns    8005ea <vprintfmt+0x1f5>
  80064e:	89 df                	mov    %ebx,%edi
  800650:	8b 75 08             	mov    0x8(%ebp),%esi
  800653:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800656:	eb 18                	jmp    800670 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 20                	push   $0x20
  80065e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800660:	83 ef 01             	sub    $0x1,%edi
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 08                	jmp    800670 <vprintfmt+0x27b>
  800668:	89 df                	mov    %ebx,%edi
  80066a:	8b 75 08             	mov    0x8(%ebp),%esi
  80066d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800670:	85 ff                	test   %edi,%edi
  800672:	7f e4                	jg     800658 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800677:	e9 9f fd ff ff       	jmp    80041b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067c:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800680:	7e 16                	jle    800698 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 08             	lea    0x8(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 50 04             	mov    0x4(%eax),%edx
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800693:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800696:	eb 34                	jmp    8006cc <vprintfmt+0x2d7>
	else if (lflag)
  800698:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80069c:	74 18                	je     8006b6 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ac:	89 c1                	mov    %eax,%ecx
  8006ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b4:	eb 16                	jmp    8006cc <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 04             	lea    0x4(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c4:	89 c1                	mov    %eax,%ecx
  8006c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006db:	0f 89 88 00 00 00    	jns    800769 <vprintfmt+0x374>
				putch('-', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 2d                	push   $0x2d
  8006e7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006ef:	f7 d8                	neg    %eax
  8006f1:	83 d2 00             	adc    $0x0,%edx
  8006f4:	f7 da                	neg    %edx
  8006f6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006fe:	eb 69                	jmp    800769 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800700:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 76 fc ff ff       	call   800381 <getuint>
			base = 10;
  80070b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800710:	eb 57                	jmp    800769 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 30                	push   $0x30
  800718:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80071a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
  800720:	e8 5c fc ff ff       	call   800381 <getuint>
			base = 8;
			goto number;
  800725:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800728:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80072d:	eb 3a                	jmp    800769 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 30                	push   $0x30
  800735:	ff d6                	call   *%esi
			putch('x', putdat);
  800737:	83 c4 08             	add    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 78                	push   $0x78
  80073d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8d 50 04             	lea    0x4(%eax),%edx
  800745:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80074f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800752:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800757:	eb 10                	jmp    800769 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800759:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
  80075f:	e8 1d fc ff ff       	call   800381 <getuint>
			base = 16;
  800764:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800770:	57                   	push   %edi
  800771:	ff 75 e0             	pushl  -0x20(%ebp)
  800774:	51                   	push   %ecx
  800775:	52                   	push   %edx
  800776:	50                   	push   %eax
  800777:	89 da                	mov    %ebx,%edx
  800779:	89 f0                	mov    %esi,%eax
  80077b:	e8 52 fb ff ff       	call   8002d2 <printnum>
			break;
  800780:	83 c4 20             	add    $0x20,%esp
  800783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800786:	e9 90 fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	52                   	push   %edx
  800790:	ff d6                	call   *%esi
			break;
  800792:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800795:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800798:	e9 7e fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	53                   	push   %ebx
  8007a1:	6a 25                	push   $0x25
  8007a3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	eb 03                	jmp    8007ad <vprintfmt+0x3b8>
  8007aa:	83 ef 01             	sub    $0x1,%edi
  8007ad:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b1:	75 f7                	jne    8007aa <vprintfmt+0x3b5>
  8007b3:	e9 63 fc ff ff       	jmp    80041b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007bb:	5b                   	pop    %ebx
  8007bc:	5e                   	pop    %esi
  8007bd:	5f                   	pop    %edi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 18             	sub    $0x18,%esp
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	74 26                	je     800807 <vsnprintf+0x47>
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	7e 22                	jle    800807 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e5:	ff 75 14             	pushl  0x14(%ebp)
  8007e8:	ff 75 10             	pushl  0x10(%ebp)
  8007eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	68 bb 03 80 00       	push   $0x8003bb
  8007f4:	e8 fc fb ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	eb 05                	jmp    80080c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800814:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800817:	50                   	push   %eax
  800818:	ff 75 10             	pushl  0x10(%ebp)
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	ff 75 08             	pushl  0x8(%ebp)
  800821:	e8 9a ff ff ff       	call   8007c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
  800833:	eb 03                	jmp    800838 <strlen+0x10>
		n++;
  800835:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800838:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80083c:	75 f7                	jne    800835 <strlen+0xd>
		n++;
	return n;
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
  80084e:	eb 03                	jmp    800853 <strnlen+0x13>
		n++;
  800850:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800853:	39 c2                	cmp    %eax,%edx
  800855:	74 08                	je     80085f <strnlen+0x1f>
  800857:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80085b:	75 f3                	jne    800850 <strnlen+0x10>
  80085d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	83 c2 01             	add    $0x1,%edx
  800870:	83 c1 01             	add    $0x1,%ecx
  800873:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800877:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087a:	84 db                	test   %bl,%bl
  80087c:	75 ef                	jne    80086d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800888:	53                   	push   %ebx
  800889:	e8 9a ff ff ff       	call   800828 <strlen>
  80088e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800891:	ff 75 0c             	pushl  0xc(%ebp)
  800894:	01 d8                	add    %ebx,%eax
  800896:	50                   	push   %eax
  800897:	e8 c5 ff ff ff       	call   800861 <strcpy>
	return dst;
}
  80089c:	89 d8                	mov    %ebx,%eax
  80089e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ae:	89 f3                	mov    %esi,%ebx
  8008b0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b3:	89 f2                	mov    %esi,%edx
  8008b5:	eb 0f                	jmp    8008c6 <strncpy+0x23>
		*dst++ = *src;
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	0f b6 01             	movzbl (%ecx),%eax
  8008bd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c6:	39 da                	cmp    %ebx,%edx
  8008c8:	75 ed                	jne    8008b7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ca:	89 f0                	mov    %esi,%eax
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008db:	8b 55 10             	mov    0x10(%ebp),%edx
  8008de:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e0:	85 d2                	test   %edx,%edx
  8008e2:	74 21                	je     800905 <strlcpy+0x35>
  8008e4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e8:	89 f2                	mov    %esi,%edx
  8008ea:	eb 09                	jmp    8008f5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	83 c1 01             	add    $0x1,%ecx
  8008f2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f5:	39 c2                	cmp    %eax,%edx
  8008f7:	74 09                	je     800902 <strlcpy+0x32>
  8008f9:	0f b6 19             	movzbl (%ecx),%ebx
  8008fc:	84 db                	test   %bl,%bl
  8008fe:	75 ec                	jne    8008ec <strlcpy+0x1c>
  800900:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800902:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800905:	29 f0                	sub    %esi,%eax
}
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800914:	eb 06                	jmp    80091c <strcmp+0x11>
		p++, q++;
  800916:	83 c1 01             	add    $0x1,%ecx
  800919:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091c:	0f b6 01             	movzbl (%ecx),%eax
  80091f:	84 c0                	test   %al,%al
  800921:	74 04                	je     800927 <strcmp+0x1c>
  800923:	3a 02                	cmp    (%edx),%al
  800925:	74 ef                	je     800916 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800927:	0f b6 c0             	movzbl %al,%eax
  80092a:	0f b6 12             	movzbl (%edx),%edx
  80092d:	29 d0                	sub    %edx,%eax
}
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	53                   	push   %ebx
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093b:	89 c3                	mov    %eax,%ebx
  80093d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800940:	eb 06                	jmp    800948 <strncmp+0x17>
		n--, p++, q++;
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800948:	39 d8                	cmp    %ebx,%eax
  80094a:	74 15                	je     800961 <strncmp+0x30>
  80094c:	0f b6 08             	movzbl (%eax),%ecx
  80094f:	84 c9                	test   %cl,%cl
  800951:	74 04                	je     800957 <strncmp+0x26>
  800953:	3a 0a                	cmp    (%edx),%cl
  800955:	74 eb                	je     800942 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800957:	0f b6 00             	movzbl (%eax),%eax
  80095a:	0f b6 12             	movzbl (%edx),%edx
  80095d:	29 d0                	sub    %edx,%eax
  80095f:	eb 05                	jmp    800966 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800966:	5b                   	pop    %ebx
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800973:	eb 07                	jmp    80097c <strchr+0x13>
		if (*s == c)
  800975:	38 ca                	cmp    %cl,%dl
  800977:	74 0f                	je     800988 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	0f b6 10             	movzbl (%eax),%edx
  80097f:	84 d2                	test   %dl,%dl
  800981:	75 f2                	jne    800975 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800994:	eb 03                	jmp    800999 <strfind+0xf>
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	74 04                	je     8009a4 <strfind+0x1a>
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f2                	jne    800996 <strfind+0xc>
			break;
	return (char *) s;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b2:	85 c9                	test   %ecx,%ecx
  8009b4:	74 36                	je     8009ec <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bc:	75 28                	jne    8009e6 <memset+0x40>
  8009be:	f6 c1 03             	test   $0x3,%cl
  8009c1:	75 23                	jne    8009e6 <memset+0x40>
		c &= 0xFF;
  8009c3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c7:	89 d3                	mov    %edx,%ebx
  8009c9:	c1 e3 08             	shl    $0x8,%ebx
  8009cc:	89 d6                	mov    %edx,%esi
  8009ce:	c1 e6 18             	shl    $0x18,%esi
  8009d1:	89 d0                	mov    %edx,%eax
  8009d3:	c1 e0 10             	shl    $0x10,%eax
  8009d6:	09 f0                	or     %esi,%eax
  8009d8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009da:	89 d8                	mov    %ebx,%eax
  8009dc:	09 d0                	or     %edx,%eax
  8009de:	c1 e9 02             	shr    $0x2,%ecx
  8009e1:	fc                   	cld    
  8009e2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e4:	eb 06                	jmp    8009ec <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e9:	fc                   	cld    
  8009ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ec:	89 f8                	mov    %edi,%eax
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a01:	39 c6                	cmp    %eax,%esi
  800a03:	73 35                	jae    800a3a <memmove+0x47>
  800a05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a08:	39 d0                	cmp    %edx,%eax
  800a0a:	73 2e                	jae    800a3a <memmove+0x47>
		s += n;
		d += n;
  800a0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 d6                	mov    %edx,%esi
  800a11:	09 fe                	or     %edi,%esi
  800a13:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a19:	75 13                	jne    800a2e <memmove+0x3b>
  800a1b:	f6 c1 03             	test   $0x3,%cl
  800a1e:	75 0e                	jne    800a2e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a20:	83 ef 04             	sub    $0x4,%edi
  800a23:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a26:	c1 e9 02             	shr    $0x2,%ecx
  800a29:	fd                   	std    
  800a2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2c:	eb 09                	jmp    800a37 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2e:	83 ef 01             	sub    $0x1,%edi
  800a31:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a34:	fd                   	std    
  800a35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a37:	fc                   	cld    
  800a38:	eb 1d                	jmp    800a57 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3a:	89 f2                	mov    %esi,%edx
  800a3c:	09 c2                	or     %eax,%edx
  800a3e:	f6 c2 03             	test   $0x3,%dl
  800a41:	75 0f                	jne    800a52 <memmove+0x5f>
  800a43:	f6 c1 03             	test   $0x3,%cl
  800a46:	75 0a                	jne    800a52 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a48:	c1 e9 02             	shr    $0x2,%ecx
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	fc                   	cld    
  800a4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a50:	eb 05                	jmp    800a57 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	fc                   	cld    
  800a55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a5e:	ff 75 10             	pushl  0x10(%ebp)
  800a61:	ff 75 0c             	pushl  0xc(%ebp)
  800a64:	ff 75 08             	pushl  0x8(%ebp)
  800a67:	e8 87 ff ff ff       	call   8009f3 <memmove>
}
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7e:	eb 1a                	jmp    800a9a <memcmp+0x2c>
		if (*s1 != *s2)
  800a80:	0f b6 08             	movzbl (%eax),%ecx
  800a83:	0f b6 1a             	movzbl (%edx),%ebx
  800a86:	38 d9                	cmp    %bl,%cl
  800a88:	74 0a                	je     800a94 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a8a:	0f b6 c1             	movzbl %cl,%eax
  800a8d:	0f b6 db             	movzbl %bl,%ebx
  800a90:	29 d8                	sub    %ebx,%eax
  800a92:	eb 0f                	jmp    800aa3 <memcmp+0x35>
		s1++, s2++;
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9a:	39 f0                	cmp    %esi,%eax
  800a9c:	75 e2                	jne    800a80 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aae:	89 c1                	mov    %eax,%ecx
  800ab0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab7:	eb 0a                	jmp    800ac3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab9:	0f b6 10             	movzbl (%eax),%edx
  800abc:	39 da                	cmp    %ebx,%edx
  800abe:	74 07                	je     800ac7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	39 c8                	cmp    %ecx,%eax
  800ac5:	72 f2                	jb     800ab9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad6:	eb 03                	jmp    800adb <strtol+0x11>
		s++;
  800ad8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adb:	0f b6 01             	movzbl (%ecx),%eax
  800ade:	3c 20                	cmp    $0x20,%al
  800ae0:	74 f6                	je     800ad8 <strtol+0xe>
  800ae2:	3c 09                	cmp    $0x9,%al
  800ae4:	74 f2                	je     800ad8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae6:	3c 2b                	cmp    $0x2b,%al
  800ae8:	75 0a                	jne    800af4 <strtol+0x2a>
		s++;
  800aea:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aed:	bf 00 00 00 00       	mov    $0x0,%edi
  800af2:	eb 11                	jmp    800b05 <strtol+0x3b>
  800af4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af9:	3c 2d                	cmp    $0x2d,%al
  800afb:	75 08                	jne    800b05 <strtol+0x3b>
		s++, neg = 1;
  800afd:	83 c1 01             	add    $0x1,%ecx
  800b00:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b05:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0b:	75 15                	jne    800b22 <strtol+0x58>
  800b0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b10:	75 10                	jne    800b22 <strtol+0x58>
  800b12:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b16:	75 7c                	jne    800b94 <strtol+0xca>
		s += 2, base = 16;
  800b18:	83 c1 02             	add    $0x2,%ecx
  800b1b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b20:	eb 16                	jmp    800b38 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b22:	85 db                	test   %ebx,%ebx
  800b24:	75 12                	jne    800b38 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b26:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2e:	75 08                	jne    800b38 <strtol+0x6e>
		s++, base = 8;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b40:	0f b6 11             	movzbl (%ecx),%edx
  800b43:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b46:	89 f3                	mov    %esi,%ebx
  800b48:	80 fb 09             	cmp    $0x9,%bl
  800b4b:	77 08                	ja     800b55 <strtol+0x8b>
			dig = *s - '0';
  800b4d:	0f be d2             	movsbl %dl,%edx
  800b50:	83 ea 30             	sub    $0x30,%edx
  800b53:	eb 22                	jmp    800b77 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b55:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b58:	89 f3                	mov    %esi,%ebx
  800b5a:	80 fb 19             	cmp    $0x19,%bl
  800b5d:	77 08                	ja     800b67 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b5f:	0f be d2             	movsbl %dl,%edx
  800b62:	83 ea 57             	sub    $0x57,%edx
  800b65:	eb 10                	jmp    800b77 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b67:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b6a:	89 f3                	mov    %esi,%ebx
  800b6c:	80 fb 19             	cmp    $0x19,%bl
  800b6f:	77 16                	ja     800b87 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b71:	0f be d2             	movsbl %dl,%edx
  800b74:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b77:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7a:	7d 0b                	jge    800b87 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b7c:	83 c1 01             	add    $0x1,%ecx
  800b7f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b83:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b85:	eb b9                	jmp    800b40 <strtol+0x76>

	if (endptr)
  800b87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8b:	74 0d                	je     800b9a <strtol+0xd0>
		*endptr = (char *) s;
  800b8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b90:	89 0e                	mov    %ecx,(%esi)
  800b92:	eb 06                	jmp    800b9a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b94:	85 db                	test   %ebx,%ebx
  800b96:	74 98                	je     800b30 <strtol+0x66>
  800b98:	eb 9e                	jmp    800b38 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b9a:	89 c2                	mov    %eax,%edx
  800b9c:	f7 da                	neg    %edx
  800b9e:	85 ff                	test   %edi,%edi
  800ba0:	0f 45 c2             	cmovne %edx,%eax
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 c3                	mov    %eax,%ebx
  800bbb:	89 c7                	mov    %eax,%edi
  800bbd:	89 c6                	mov    %eax,%esi
  800bbf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd6:	89 d1                	mov    %edx,%ecx
  800bd8:	89 d3                	mov    %edx,%ebx
  800bda:	89 d7                	mov    %edx,%edi
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 cb                	mov    %ecx,%ebx
  800bfd:	89 cf                	mov    %ecx,%edi
  800bff:	89 ce                	mov    %ecx,%esi
  800c01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 03                	push   $0x3
  800c0d:	68 7f 23 80 00       	push   $0x80237f
  800c12:	6a 23                	push   $0x23
  800c14:	68 9c 23 80 00       	push   $0x80239c
  800c19:	e8 c7 f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 02 00 00 00       	mov    $0x2,%eax
  800c36:	89 d1                	mov    %edx,%ecx
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	89 d7                	mov    %edx,%edi
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_yield>:

void
sys_yield(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c6d:	be 00 00 00 00       	mov    $0x0,%esi
  800c72:	b8 04 00 00 00       	mov    $0x4,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c80:	89 f7                	mov    %esi,%edi
  800c82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 04                	push   $0x4
  800c8e:	68 7f 23 80 00       	push   $0x80237f
  800c93:	6a 23                	push   $0x23
  800c95:	68 9c 23 80 00       	push   $0x80239c
  800c9a:	e8 46 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800cb0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 05                	push   $0x5
  800cd0:	68 7f 23 80 00       	push   $0x80237f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 9c 23 80 00       	push   $0x80239c
  800cdc:	e8 04 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 df                	mov    %ebx,%edi
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 06                	push   $0x6
  800d12:	68 7f 23 80 00       	push   $0x80237f
  800d17:	6a 23                	push   $0x23
  800d19:	68 9c 23 80 00       	push   $0x80239c
  800d1e:	e8 c2 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d39:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 df                	mov    %ebx,%edi
  800d46:	89 de                	mov    %ebx,%esi
  800d48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 08                	push   $0x8
  800d54:	68 7f 23 80 00       	push   $0x80237f
  800d59:	6a 23                	push   $0x23
  800d5b:	68 9c 23 80 00       	push   $0x80239c
  800d60:	e8 80 f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 09                	push   $0x9
  800d96:	68 7f 23 80 00       	push   $0x80237f
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 9c 23 80 00       	push   $0x80239c
  800da2:	e8 3e f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	89 df                	mov    %ebx,%edi
  800dca:	89 de                	mov    %ebx,%esi
  800dcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 17                	jle    800de9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	50                   	push   %eax
  800dd6:	6a 0a                	push   $0xa
  800dd8:	68 7f 23 80 00       	push   $0x80237f
  800ddd:	6a 23                	push   $0x23
  800ddf:	68 9c 23 80 00       	push   $0x80239c
  800de4:	e8 fc f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df7:	be 00 00 00 00       	mov    $0x0,%esi
  800dfc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e22:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	89 cb                	mov    %ecx,%ebx
  800e2c:	89 cf                	mov    %ecx,%edi
  800e2e:	89 ce                	mov    %ecx,%esi
  800e30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 17                	jle    800e4d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	50                   	push   %eax
  800e3a:	6a 0d                	push   $0xd
  800e3c:	68 7f 23 80 00       	push   $0x80237f
  800e41:	6a 23                	push   $0x23
  800e43:	68 9c 23 80 00       	push   $0x80239c
  800e48:	e8 98 f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e60:	c1 e8 0c             	shr    $0xc,%eax
}
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e75:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e82:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e87:	89 c2                	mov    %eax,%edx
  800e89:	c1 ea 16             	shr    $0x16,%edx
  800e8c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e93:	f6 c2 01             	test   $0x1,%dl
  800e96:	74 11                	je     800ea9 <fd_alloc+0x2d>
  800e98:	89 c2                	mov    %eax,%edx
  800e9a:	c1 ea 0c             	shr    $0xc,%edx
  800e9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea4:	f6 c2 01             	test   $0x1,%dl
  800ea7:	75 09                	jne    800eb2 <fd_alloc+0x36>
			*fd_store = fd;
  800ea9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eab:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb0:	eb 17                	jmp    800ec9 <fd_alloc+0x4d>
  800eb2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ebc:	75 c9                	jne    800e87 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ebe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed1:	83 f8 1f             	cmp    $0x1f,%eax
  800ed4:	77 36                	ja     800f0c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed6:	c1 e0 0c             	shl    $0xc,%eax
  800ed9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	c1 ea 16             	shr    $0x16,%edx
  800ee3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eea:	f6 c2 01             	test   $0x1,%dl
  800eed:	74 24                	je     800f13 <fd_lookup+0x48>
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	c1 ea 0c             	shr    $0xc,%edx
  800ef4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efb:	f6 c2 01             	test   $0x1,%dl
  800efe:	74 1a                	je     800f1a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f03:	89 02                	mov    %eax,(%edx)
	return 0;
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0a:	eb 13                	jmp    800f1f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f11:	eb 0c                	jmp    800f1f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f18:	eb 05                	jmp    800f1f <fd_lookup+0x54>
  800f1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	83 ec 08             	sub    $0x8,%esp
  800f27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2a:	ba 2c 24 80 00       	mov    $0x80242c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2f:	eb 13                	jmp    800f44 <dev_lookup+0x23>
  800f31:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f34:	39 08                	cmp    %ecx,(%eax)
  800f36:	75 0c                	jne    800f44 <dev_lookup+0x23>
			*dev = devtab[i];
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	eb 2e                	jmp    800f72 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f44:	8b 02                	mov    (%edx),%eax
  800f46:	85 c0                	test   %eax,%eax
  800f48:	75 e7                	jne    800f31 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f4a:	a1 08 40 80 00       	mov    0x804008,%eax
  800f4f:	8b 40 48             	mov    0x48(%eax),%eax
  800f52:	83 ec 04             	sub    $0x4,%esp
  800f55:	51                   	push   %ecx
  800f56:	50                   	push   %eax
  800f57:	68 ac 23 80 00       	push   $0x8023ac
  800f5c:	e8 5d f3 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 10             	sub    $0x10,%esp
  800f7c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f85:	50                   	push   %eax
  800f86:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f8c:	c1 e8 0c             	shr    $0xc,%eax
  800f8f:	50                   	push   %eax
  800f90:	e8 36 ff ff ff       	call   800ecb <fd_lookup>
  800f95:	83 c4 08             	add    $0x8,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 05                	js     800fa1 <fd_close+0x2d>
	    || fd != fd2)
  800f9c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f9f:	74 0c                	je     800fad <fd_close+0x39>
		return (must_exist ? r : 0);
  800fa1:	84 db                	test   %bl,%bl
  800fa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa8:	0f 44 c2             	cmove  %edx,%eax
  800fab:	eb 41                	jmp    800fee <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fad:	83 ec 08             	sub    $0x8,%esp
  800fb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 36                	pushl  (%esi)
  800fb6:	e8 66 ff ff ff       	call   800f21 <dev_lookup>
  800fbb:	89 c3                	mov    %eax,%ebx
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 1a                	js     800fde <fd_close+0x6a>
		if (dev->dev_close)
  800fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fca:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	74 0b                	je     800fde <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	56                   	push   %esi
  800fd7:	ff d0                	call   *%eax
  800fd9:	89 c3                	mov    %eax,%ebx
  800fdb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	56                   	push   %esi
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 00 fd ff ff       	call   800ce9 <sys_page_unmap>
	return r;
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	89 d8                	mov    %ebx,%eax
}
  800fee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	ff 75 08             	pushl  0x8(%ebp)
  801002:	e8 c4 fe ff ff       	call   800ecb <fd_lookup>
  801007:	83 c4 08             	add    $0x8,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 10                	js     80101e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	6a 01                	push   $0x1
  801013:	ff 75 f4             	pushl  -0xc(%ebp)
  801016:	e8 59 ff ff ff       	call   800f74 <fd_close>
  80101b:	83 c4 10             	add    $0x10,%esp
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <close_all>:

void
close_all(void)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	53                   	push   %ebx
  801024:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801027:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	53                   	push   %ebx
  801030:	e8 c0 ff ff ff       	call   800ff5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801035:	83 c3 01             	add    $0x1,%ebx
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	83 fb 20             	cmp    $0x20,%ebx
  80103e:	75 ec                	jne    80102c <close_all+0xc>
		close(i);
}
  801040:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	57                   	push   %edi
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
  80104b:	83 ec 2c             	sub    $0x2c,%esp
  80104e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801051:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	ff 75 08             	pushl  0x8(%ebp)
  801058:	e8 6e fe ff ff       	call   800ecb <fd_lookup>
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	0f 88 c1 00 00 00    	js     801129 <dup+0xe4>
		return r;
	close(newfdnum);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	56                   	push   %esi
  80106c:	e8 84 ff ff ff       	call   800ff5 <close>

	newfd = INDEX2FD(newfdnum);
  801071:	89 f3                	mov    %esi,%ebx
  801073:	c1 e3 0c             	shl    $0xc,%ebx
  801076:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80107c:	83 c4 04             	add    $0x4,%esp
  80107f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801082:	e8 de fd ff ff       	call   800e65 <fd2data>
  801087:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801089:	89 1c 24             	mov    %ebx,(%esp)
  80108c:	e8 d4 fd ff ff       	call   800e65 <fd2data>
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801097:	89 f8                	mov    %edi,%eax
  801099:	c1 e8 16             	shr    $0x16,%eax
  80109c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a3:	a8 01                	test   $0x1,%al
  8010a5:	74 37                	je     8010de <dup+0x99>
  8010a7:	89 f8                	mov    %edi,%eax
  8010a9:	c1 e8 0c             	shr    $0xc,%eax
  8010ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b3:	f6 c2 01             	test   $0x1,%dl
  8010b6:	74 26                	je     8010de <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c7:	50                   	push   %eax
  8010c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cb:	6a 00                	push   $0x0
  8010cd:	57                   	push   %edi
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 d2 fb ff ff       	call   800ca7 <sys_page_map>
  8010d5:	89 c7                	mov    %eax,%edi
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 2e                	js     80110c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010e1:	89 d0                	mov    %edx,%eax
  8010e3:	c1 e8 0c             	shr    $0xc,%eax
  8010e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f5:	50                   	push   %eax
  8010f6:	53                   	push   %ebx
  8010f7:	6a 00                	push   $0x0
  8010f9:	52                   	push   %edx
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 a6 fb ff ff       	call   800ca7 <sys_page_map>
  801101:	89 c7                	mov    %eax,%edi
  801103:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801106:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801108:	85 ff                	test   %edi,%edi
  80110a:	79 1d                	jns    801129 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80110c:	83 ec 08             	sub    $0x8,%esp
  80110f:	53                   	push   %ebx
  801110:	6a 00                	push   $0x0
  801112:	e8 d2 fb ff ff       	call   800ce9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801117:	83 c4 08             	add    $0x8,%esp
  80111a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111d:	6a 00                	push   $0x0
  80111f:	e8 c5 fb ff ff       	call   800ce9 <sys_page_unmap>
	return r;
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	89 f8                	mov    %edi,%eax
}
  801129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	53                   	push   %ebx
  801135:	83 ec 14             	sub    $0x14,%esp
  801138:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	53                   	push   %ebx
  801140:	e8 86 fd ff ff       	call   800ecb <fd_lookup>
  801145:	83 c4 08             	add    $0x8,%esp
  801148:	89 c2                	mov    %eax,%edx
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 6d                	js     8011bb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114e:	83 ec 08             	sub    $0x8,%esp
  801151:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801154:	50                   	push   %eax
  801155:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801158:	ff 30                	pushl  (%eax)
  80115a:	e8 c2 fd ff ff       	call   800f21 <dev_lookup>
  80115f:	83 c4 10             	add    $0x10,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	78 4c                	js     8011b2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801166:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801169:	8b 42 08             	mov    0x8(%edx),%eax
  80116c:	83 e0 03             	and    $0x3,%eax
  80116f:	83 f8 01             	cmp    $0x1,%eax
  801172:	75 21                	jne    801195 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801174:	a1 08 40 80 00       	mov    0x804008,%eax
  801179:	8b 40 48             	mov    0x48(%eax),%eax
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	53                   	push   %ebx
  801180:	50                   	push   %eax
  801181:	68 f0 23 80 00       	push   $0x8023f0
  801186:	e8 33 f1 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801193:	eb 26                	jmp    8011bb <read+0x8a>
	}
	if (!dev->dev_read)
  801195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801198:	8b 40 08             	mov    0x8(%eax),%eax
  80119b:	85 c0                	test   %eax,%eax
  80119d:	74 17                	je     8011b6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	ff 75 10             	pushl  0x10(%ebp)
  8011a5:	ff 75 0c             	pushl  0xc(%ebp)
  8011a8:	52                   	push   %edx
  8011a9:	ff d0                	call   *%eax
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	eb 09                	jmp    8011bb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	eb 05                	jmp    8011bb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011bb:	89 d0                	mov    %edx,%eax
  8011bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	57                   	push   %edi
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 0c             	sub    $0xc,%esp
  8011cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d6:	eb 21                	jmp    8011f9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d8:	83 ec 04             	sub    $0x4,%esp
  8011db:	89 f0                	mov    %esi,%eax
  8011dd:	29 d8                	sub    %ebx,%eax
  8011df:	50                   	push   %eax
  8011e0:	89 d8                	mov    %ebx,%eax
  8011e2:	03 45 0c             	add    0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	57                   	push   %edi
  8011e7:	e8 45 ff ff ff       	call   801131 <read>
		if (m < 0)
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 10                	js     801203 <readn+0x41>
			return m;
		if (m == 0)
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	74 0a                	je     801201 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f7:	01 c3                	add    %eax,%ebx
  8011f9:	39 f3                	cmp    %esi,%ebx
  8011fb:	72 db                	jb     8011d8 <readn+0x16>
  8011fd:	89 d8                	mov    %ebx,%eax
  8011ff:	eb 02                	jmp    801203 <readn+0x41>
  801201:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	53                   	push   %ebx
  80120f:	83 ec 14             	sub    $0x14,%esp
  801212:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801215:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	53                   	push   %ebx
  80121a:	e8 ac fc ff ff       	call   800ecb <fd_lookup>
  80121f:	83 c4 08             	add    $0x8,%esp
  801222:	89 c2                	mov    %eax,%edx
  801224:	85 c0                	test   %eax,%eax
  801226:	78 68                	js     801290 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801232:	ff 30                	pushl  (%eax)
  801234:	e8 e8 fc ff ff       	call   800f21 <dev_lookup>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 47                	js     801287 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801247:	75 21                	jne    80126a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801249:	a1 08 40 80 00       	mov    0x804008,%eax
  80124e:	8b 40 48             	mov    0x48(%eax),%eax
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	53                   	push   %ebx
  801255:	50                   	push   %eax
  801256:	68 0c 24 80 00       	push   $0x80240c
  80125b:	e8 5e f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801268:	eb 26                	jmp    801290 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80126a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126d:	8b 52 0c             	mov    0xc(%edx),%edx
  801270:	85 d2                	test   %edx,%edx
  801272:	74 17                	je     80128b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801274:	83 ec 04             	sub    $0x4,%esp
  801277:	ff 75 10             	pushl  0x10(%ebp)
  80127a:	ff 75 0c             	pushl  0xc(%ebp)
  80127d:	50                   	push   %eax
  80127e:	ff d2                	call   *%edx
  801280:	89 c2                	mov    %eax,%edx
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	eb 09                	jmp    801290 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	89 c2                	mov    %eax,%edx
  801289:	eb 05                	jmp    801290 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80128b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801290:	89 d0                	mov    %edx,%eax
  801292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <seek>:

int
seek(int fdnum, off_t offset)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	ff 75 08             	pushl  0x8(%ebp)
  8012a4:	e8 22 fc ff ff       	call   800ecb <fd_lookup>
  8012a9:	83 c4 08             	add    $0x8,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 0e                	js     8012be <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 14             	sub    $0x14,%esp
  8012c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	53                   	push   %ebx
  8012cf:	e8 f7 fb ff ff       	call   800ecb <fd_lookup>
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 65                	js     801342 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	ff 30                	pushl  (%eax)
  8012e9:	e8 33 fc ff ff       	call   800f21 <dev_lookup>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 44                	js     801339 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fc:	75 21                	jne    80131f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fe:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801303:	8b 40 48             	mov    0x48(%eax),%eax
  801306:	83 ec 04             	sub    $0x4,%esp
  801309:	53                   	push   %ebx
  80130a:	50                   	push   %eax
  80130b:	68 cc 23 80 00       	push   $0x8023cc
  801310:	e8 a9 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131d:	eb 23                	jmp    801342 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80131f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801322:	8b 52 18             	mov    0x18(%edx),%edx
  801325:	85 d2                	test   %edx,%edx
  801327:	74 14                	je     80133d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	ff 75 0c             	pushl  0xc(%ebp)
  80132f:	50                   	push   %eax
  801330:	ff d2                	call   *%edx
  801332:	89 c2                	mov    %eax,%edx
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	eb 09                	jmp    801342 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801339:	89 c2                	mov    %eax,%edx
  80133b:	eb 05                	jmp    801342 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80133d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801342:	89 d0                	mov    %edx,%eax
  801344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	53                   	push   %ebx
  80134d:	83 ec 14             	sub    $0x14,%esp
  801350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801353:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801356:	50                   	push   %eax
  801357:	ff 75 08             	pushl  0x8(%ebp)
  80135a:	e8 6c fb ff ff       	call   800ecb <fd_lookup>
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	89 c2                	mov    %eax,%edx
  801364:	85 c0                	test   %eax,%eax
  801366:	78 58                	js     8013c0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801372:	ff 30                	pushl  (%eax)
  801374:	e8 a8 fb ff ff       	call   800f21 <dev_lookup>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 37                	js     8013b7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801383:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801387:	74 32                	je     8013bb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801389:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80138c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801393:	00 00 00 
	stat->st_isdir = 0;
  801396:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80139d:	00 00 00 
	stat->st_dev = dev;
  8013a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ad:	ff 50 14             	call   *0x14(%eax)
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	eb 09                	jmp    8013c0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b7:	89 c2                	mov    %eax,%edx
  8013b9:	eb 05                	jmp    8013c0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013c0:	89 d0                	mov    %edx,%eax
  8013c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	6a 00                	push   $0x0
  8013d1:	ff 75 08             	pushl  0x8(%ebp)
  8013d4:	e8 e3 01 00 00       	call   8015bc <open>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 1b                	js     8013fd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	ff 75 0c             	pushl  0xc(%ebp)
  8013e8:	50                   	push   %eax
  8013e9:	e8 5b ff ff ff       	call   801349 <fstat>
  8013ee:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f0:	89 1c 24             	mov    %ebx,(%esp)
  8013f3:	e8 fd fb ff ff       	call   800ff5 <close>
	return r;
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	89 f0                	mov    %esi,%eax
}
  8013fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	89 c6                	mov    %eax,%esi
  80140b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80140d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801414:	75 12                	jne    801428 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	6a 01                	push   $0x1
  80141b:	e8 d8 08 00 00       	call   801cf8 <ipc_find_env>
  801420:	a3 04 40 80 00       	mov    %eax,0x804004
  801425:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801428:	6a 07                	push   $0x7
  80142a:	68 00 50 80 00       	push   $0x805000
  80142f:	56                   	push   %esi
  801430:	ff 35 04 40 80 00    	pushl  0x804004
  801436:	e8 69 08 00 00       	call   801ca4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80143b:	83 c4 0c             	add    $0xc,%esp
  80143e:	6a 00                	push   $0x0
  801440:	53                   	push   %ebx
  801441:	6a 00                	push   $0x0
  801443:	e8 07 08 00 00       	call   801c4f <ipc_recv>
}
  801448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	8b 40 0c             	mov    0xc(%eax),%eax
  80145b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801460:	8b 45 0c             	mov    0xc(%ebp),%eax
  801463:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	b8 02 00 00 00       	mov    $0x2,%eax
  801472:	e8 8d ff ff ff       	call   801404 <fsipc>
}
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	8b 40 0c             	mov    0xc(%eax),%eax
  801485:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80148a:	ba 00 00 00 00       	mov    $0x0,%edx
  80148f:	b8 06 00 00 00       	mov    $0x6,%eax
  801494:	e8 6b ff ff ff       	call   801404 <fsipc>
}
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ba:	e8 45 ff ff ff       	call   801404 <fsipc>
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 2c                	js     8014ef <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	68 00 50 80 00       	push   $0x805000
  8014cb:	53                   	push   %ebx
  8014cc:	e8 90 f3 ff ff       	call   800861 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8014d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801500:	8b 52 0c             	mov    0xc(%edx),%edx
  801503:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  801509:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150e:	ba 00 10 00 00       	mov    $0x1000,%edx
  801513:	0f 47 c2             	cmova  %edx,%eax
  801516:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80151b:	50                   	push   %eax
  80151c:	ff 75 0c             	pushl  0xc(%ebp)
  80151f:	68 08 50 80 00       	push   $0x805008
  801524:	e8 ca f4 ff ff       	call   8009f3 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  801529:	ba 00 00 00 00       	mov    $0x0,%edx
  80152e:	b8 04 00 00 00       	mov    $0x4,%eax
  801533:	e8 cc fe ff ff       	call   801404 <fsipc>
    return r;
}
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801542:	8b 45 08             	mov    0x8(%ebp),%eax
  801545:	8b 40 0c             	mov    0xc(%eax),%eax
  801548:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80154d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	b8 03 00 00 00       	mov    $0x3,%eax
  80155d:	e8 a2 fe ff ff       	call   801404 <fsipc>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 4b                	js     8015b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801568:	39 c6                	cmp    %eax,%esi
  80156a:	73 16                	jae    801582 <devfile_read+0x48>
  80156c:	68 3c 24 80 00       	push   $0x80243c
  801571:	68 43 24 80 00       	push   $0x802443
  801576:	6a 7c                	push   $0x7c
  801578:	68 58 24 80 00       	push   $0x802458
  80157d:	e8 63 ec ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  801582:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801587:	7e 16                	jle    80159f <devfile_read+0x65>
  801589:	68 63 24 80 00       	push   $0x802463
  80158e:	68 43 24 80 00       	push   $0x802443
  801593:	6a 7d                	push   $0x7d
  801595:	68 58 24 80 00       	push   $0x802458
  80159a:	e8 46 ec ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	50                   	push   %eax
  8015a3:	68 00 50 80 00       	push   $0x805000
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	e8 43 f4 ff ff       	call   8009f3 <memmove>
	return r;
  8015b0:	83 c4 10             	add    $0x10,%esp
}
  8015b3:	89 d8                	mov    %ebx,%eax
  8015b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 20             	sub    $0x20,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c6:	53                   	push   %ebx
  8015c7:	e8 5c f2 ff ff       	call   800828 <strlen>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d4:	7f 67                	jg     80163d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	e8 9a f8 ff ff       	call   800e7c <fd_alloc>
  8015e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 57                	js     801642 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	68 00 50 80 00       	push   $0x805000
  8015f4:	e8 68 f2 ff ff       	call   800861 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801601:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801604:	b8 01 00 00 00       	mov    $0x1,%eax
  801609:	e8 f6 fd ff ff       	call   801404 <fsipc>
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	79 14                	jns    80162b <open+0x6f>
		fd_close(fd, 0);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	6a 00                	push   $0x0
  80161c:	ff 75 f4             	pushl  -0xc(%ebp)
  80161f:	e8 50 f9 ff ff       	call   800f74 <fd_close>
		return r;
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	89 da                	mov    %ebx,%edx
  801629:	eb 17                	jmp    801642 <open+0x86>
	}

	return fd2num(fd);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	ff 75 f4             	pushl  -0xc(%ebp)
  801631:	e8 1f f8 ff ff       	call   800e55 <fd2num>
  801636:	89 c2                	mov    %eax,%edx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	eb 05                	jmp    801642 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801642:	89 d0                	mov    %edx,%eax
  801644:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164f:	ba 00 00 00 00       	mov    $0x0,%edx
  801654:	b8 08 00 00 00       	mov    $0x8,%eax
  801659:	e8 a6 fd ff ff       	call   801404 <fsipc>
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801660:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801664:	7e 37                	jle    80169d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80166f:	ff 70 04             	pushl  0x4(%eax)
  801672:	8d 40 10             	lea    0x10(%eax),%eax
  801675:	50                   	push   %eax
  801676:	ff 33                	pushl  (%ebx)
  801678:	e8 8e fb ff ff       	call   80120b <write>
		if (result > 0)
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	85 c0                	test   %eax,%eax
  801682:	7e 03                	jle    801687 <writebuf+0x27>
			b->result += result;
  801684:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801687:	3b 43 04             	cmp    0x4(%ebx),%eax
  80168a:	74 0d                	je     801699 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80168c:	85 c0                	test   %eax,%eax
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	0f 4f c2             	cmovg  %edx,%eax
  801696:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169c:	c9                   	leave  
  80169d:	f3 c3                	repz ret 

0080169f <putch>:

static void
putch(int ch, void *thunk)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016a9:	8b 53 04             	mov    0x4(%ebx),%edx
  8016ac:	8d 42 01             	lea    0x1(%edx),%eax
  8016af:	89 43 04             	mov    %eax,0x4(%ebx)
  8016b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b5:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016b9:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016be:	75 0e                	jne    8016ce <putch+0x2f>
		writebuf(b);
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	e8 99 ff ff ff       	call   801660 <writebuf>
		b->idx = 0;
  8016c7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016ce:	83 c4 04             	add    $0x4,%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016e6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016ed:	00 00 00 
	b.result = 0;
  8016f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016f7:	00 00 00 
	b.error = 1;
  8016fa:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801701:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801704:	ff 75 10             	pushl  0x10(%ebp)
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	68 9f 16 80 00       	push   $0x80169f
  801716:	e8 da ec ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801725:	7e 0b                	jle    801732 <vfprintf+0x5e>
		writebuf(&b);
  801727:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80172d:	e8 2e ff ff ff       	call   801660 <writebuf>

	return (b.result ? b.result : b.error);
  801732:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801738:	85 c0                	test   %eax,%eax
  80173a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801749:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80174c:	50                   	push   %eax
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	ff 75 08             	pushl  0x8(%ebp)
  801753:	e8 7c ff ff ff       	call   8016d4 <vfprintf>
	va_end(ap);

	return cnt;
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <printf>:

int
printf(const char *fmt, ...)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801760:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801763:	50                   	push   %eax
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	6a 01                	push   $0x1
  801769:	e8 66 ff ff ff       	call   8016d4 <vfprintf>
	va_end(ap);

	return cnt;
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	56                   	push   %esi
  801774:	53                   	push   %ebx
  801775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801778:	83 ec 0c             	sub    $0xc,%esp
  80177b:	ff 75 08             	pushl  0x8(%ebp)
  80177e:	e8 e2 f6 ff ff       	call   800e65 <fd2data>
  801783:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801785:	83 c4 08             	add    $0x8,%esp
  801788:	68 6f 24 80 00       	push   $0x80246f
  80178d:	53                   	push   %ebx
  80178e:	e8 ce f0 ff ff       	call   800861 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801793:	8b 46 04             	mov    0x4(%esi),%eax
  801796:	2b 06                	sub    (%esi),%eax
  801798:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80179e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a5:	00 00 00 
	stat->st_dev = &devpipe;
  8017a8:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017af:	30 80 00 
	return 0;
}
  8017b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5e                   	pop    %esi
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 0c             	sub    $0xc,%esp
  8017c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017c8:	53                   	push   %ebx
  8017c9:	6a 00                	push   $0x0
  8017cb:	e8 19 f5 ff ff       	call   800ce9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017d0:	89 1c 24             	mov    %ebx,(%esp)
  8017d3:	e8 8d f6 ff ff       	call   800e65 <fd2data>
  8017d8:	83 c4 08             	add    $0x8,%esp
  8017db:	50                   	push   %eax
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 06 f5 ff ff       	call   800ce9 <sys_page_unmap>
}
  8017e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	57                   	push   %edi
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 1c             	sub    $0x1c,%esp
  8017f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8017fb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	ff 75 e0             	pushl  -0x20(%ebp)
  801804:	e8 28 05 00 00       	call   801d31 <pageref>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	89 3c 24             	mov    %edi,(%esp)
  80180e:	e8 1e 05 00 00       	call   801d31 <pageref>
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	39 c3                	cmp    %eax,%ebx
  801818:	0f 94 c1             	sete   %cl
  80181b:	0f b6 c9             	movzbl %cl,%ecx
  80181e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801821:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801827:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80182a:	39 ce                	cmp    %ecx,%esi
  80182c:	74 1b                	je     801849 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80182e:	39 c3                	cmp    %eax,%ebx
  801830:	75 c4                	jne    8017f6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801832:	8b 42 58             	mov    0x58(%edx),%eax
  801835:	ff 75 e4             	pushl  -0x1c(%ebp)
  801838:	50                   	push   %eax
  801839:	56                   	push   %esi
  80183a:	68 76 24 80 00       	push   $0x802476
  80183f:	e8 7a ea ff ff       	call   8002be <cprintf>
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	eb ad                	jmp    8017f6 <_pipeisclosed+0xe>
	}
}
  801849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80184c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80184f:	5b                   	pop    %ebx
  801850:	5e                   	pop    %esi
  801851:	5f                   	pop    %edi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	57                   	push   %edi
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	83 ec 28             	sub    $0x28,%esp
  80185d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801860:	56                   	push   %esi
  801861:	e8 ff f5 ff ff       	call   800e65 <fd2data>
  801866:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	bf 00 00 00 00       	mov    $0x0,%edi
  801870:	eb 4b                	jmp    8018bd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801872:	89 da                	mov    %ebx,%edx
  801874:	89 f0                	mov    %esi,%eax
  801876:	e8 6d ff ff ff       	call   8017e8 <_pipeisclosed>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	75 48                	jne    8018c7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80187f:	e8 c1 f3 ff ff       	call   800c45 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801884:	8b 43 04             	mov    0x4(%ebx),%eax
  801887:	8b 0b                	mov    (%ebx),%ecx
  801889:	8d 51 20             	lea    0x20(%ecx),%edx
  80188c:	39 d0                	cmp    %edx,%eax
  80188e:	73 e2                	jae    801872 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801893:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801897:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80189a:	89 c2                	mov    %eax,%edx
  80189c:	c1 fa 1f             	sar    $0x1f,%edx
  80189f:	89 d1                	mov    %edx,%ecx
  8018a1:	c1 e9 1b             	shr    $0x1b,%ecx
  8018a4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018a7:	83 e2 1f             	and    $0x1f,%edx
  8018aa:	29 ca                	sub    %ecx,%edx
  8018ac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018b0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018b4:	83 c0 01             	add    $0x1,%eax
  8018b7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ba:	83 c7 01             	add    $0x1,%edi
  8018bd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018c0:	75 c2                	jne    801884 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c5:	eb 05                	jmp    8018cc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5e                   	pop    %esi
  8018d1:	5f                   	pop    %edi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	57                   	push   %edi
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 18             	sub    $0x18,%esp
  8018dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018e0:	57                   	push   %edi
  8018e1:	e8 7f f5 ff ff       	call   800e65 <fd2data>
  8018e6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018f0:	eb 3d                	jmp    80192f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018f2:	85 db                	test   %ebx,%ebx
  8018f4:	74 04                	je     8018fa <devpipe_read+0x26>
				return i;
  8018f6:	89 d8                	mov    %ebx,%eax
  8018f8:	eb 44                	jmp    80193e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018fa:	89 f2                	mov    %esi,%edx
  8018fc:	89 f8                	mov    %edi,%eax
  8018fe:	e8 e5 fe ff ff       	call   8017e8 <_pipeisclosed>
  801903:	85 c0                	test   %eax,%eax
  801905:	75 32                	jne    801939 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801907:	e8 39 f3 ff ff       	call   800c45 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80190c:	8b 06                	mov    (%esi),%eax
  80190e:	3b 46 04             	cmp    0x4(%esi),%eax
  801911:	74 df                	je     8018f2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801913:	99                   	cltd   
  801914:	c1 ea 1b             	shr    $0x1b,%edx
  801917:	01 d0                	add    %edx,%eax
  801919:	83 e0 1f             	and    $0x1f,%eax
  80191c:	29 d0                	sub    %edx,%eax
  80191e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801926:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801929:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192c:	83 c3 01             	add    $0x1,%ebx
  80192f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801932:	75 d8                	jne    80190c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801934:	8b 45 10             	mov    0x10(%ebp),%eax
  801937:	eb 05                	jmp    80193e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80193e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801941:	5b                   	pop    %ebx
  801942:	5e                   	pop    %esi
  801943:	5f                   	pop    %edi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80194e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801951:	50                   	push   %eax
  801952:	e8 25 f5 ff ff       	call   800e7c <fd_alloc>
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	85 c0                	test   %eax,%eax
  80195e:	0f 88 2c 01 00 00    	js     801a90 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	68 07 04 00 00       	push   $0x407
  80196c:	ff 75 f4             	pushl  -0xc(%ebp)
  80196f:	6a 00                	push   $0x0
  801971:	e8 ee f2 ff ff       	call   800c64 <sys_page_alloc>
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	89 c2                	mov    %eax,%edx
  80197b:	85 c0                	test   %eax,%eax
  80197d:	0f 88 0d 01 00 00    	js     801a90 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	e8 ed f4 ff ff       	call   800e7c <fd_alloc>
  80198f:	89 c3                	mov    %eax,%ebx
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	0f 88 e2 00 00 00    	js     801a7e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199c:	83 ec 04             	sub    $0x4,%esp
  80199f:	68 07 04 00 00       	push   $0x407
  8019a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a7:	6a 00                	push   $0x0
  8019a9:	e8 b6 f2 ff ff       	call   800c64 <sys_page_alloc>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	0f 88 c3 00 00 00    	js     801a7e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c1:	e8 9f f4 ff ff       	call   800e65 <fd2data>
  8019c6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c8:	83 c4 0c             	add    $0xc,%esp
  8019cb:	68 07 04 00 00       	push   $0x407
  8019d0:	50                   	push   %eax
  8019d1:	6a 00                	push   $0x0
  8019d3:	e8 8c f2 ff ff       	call   800c64 <sys_page_alloc>
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	0f 88 89 00 00 00    	js     801a6e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019eb:	e8 75 f4 ff ff       	call   800e65 <fd2data>
  8019f0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019f7:	50                   	push   %eax
  8019f8:	6a 00                	push   $0x0
  8019fa:	56                   	push   %esi
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 a5 f2 ff ff       	call   800ca7 <sys_page_map>
  801a02:	89 c3                	mov    %eax,%ebx
  801a04:	83 c4 20             	add    $0x20,%esp
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 55                	js     801a60 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a0b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a14:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a19:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a20:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a29:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3b:	e8 15 f4 ff ff       	call   800e55 <fd2num>
  801a40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a43:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a45:	83 c4 04             	add    $0x4,%esp
  801a48:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4b:	e8 05 f4 ff ff       	call   800e55 <fd2num>
  801a50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a53:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5e:	eb 30                	jmp    801a90 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a60:	83 ec 08             	sub    $0x8,%esp
  801a63:	56                   	push   %esi
  801a64:	6a 00                	push   $0x0
  801a66:	e8 7e f2 ff ff       	call   800ce9 <sys_page_unmap>
  801a6b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	ff 75 f0             	pushl  -0x10(%ebp)
  801a74:	6a 00                	push   $0x0
  801a76:	e8 6e f2 ff ff       	call   800ce9 <sys_page_unmap>
  801a7b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	ff 75 f4             	pushl  -0xc(%ebp)
  801a84:	6a 00                	push   $0x0
  801a86:	e8 5e f2 ff ff       	call   800ce9 <sys_page_unmap>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a90:	89 d0                	mov    %edx,%eax
  801a92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	ff 75 08             	pushl  0x8(%ebp)
  801aa6:	e8 20 f4 ff ff       	call   800ecb <fd_lookup>
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 18                	js     801aca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab8:	e8 a8 f3 ff ff       	call   800e65 <fd2data>
	return _pipeisclosed(fd, p);
  801abd:	89 c2                	mov    %eax,%edx
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	e8 21 fd ff ff       	call   8017e8 <_pipeisclosed>
  801ac7:	83 c4 10             	add    $0x10,%esp
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801adc:	68 8e 24 80 00       	push   $0x80248e
  801ae1:	ff 75 0c             	pushl  0xc(%ebp)
  801ae4:	e8 78 ed ff ff       	call   800861 <strcpy>
	return 0;
}
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	57                   	push   %edi
  801af4:	56                   	push   %esi
  801af5:	53                   	push   %ebx
  801af6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801afc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b01:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b07:	eb 2d                	jmp    801b36 <devcons_write+0x46>
		m = n - tot;
  801b09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b0c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b0e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b11:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b16:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b19:	83 ec 04             	sub    $0x4,%esp
  801b1c:	53                   	push   %ebx
  801b1d:	03 45 0c             	add    0xc(%ebp),%eax
  801b20:	50                   	push   %eax
  801b21:	57                   	push   %edi
  801b22:	e8 cc ee ff ff       	call   8009f3 <memmove>
		sys_cputs(buf, m);
  801b27:	83 c4 08             	add    $0x8,%esp
  801b2a:	53                   	push   %ebx
  801b2b:	57                   	push   %edi
  801b2c:	e8 77 f0 ff ff       	call   800ba8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b31:	01 de                	add    %ebx,%esi
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	89 f0                	mov    %esi,%eax
  801b38:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b3b:	72 cc                	jb     801b09 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b54:	74 2a                	je     801b80 <devcons_read+0x3b>
  801b56:	eb 05                	jmp    801b5d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b58:	e8 e8 f0 ff ff       	call   800c45 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b5d:	e8 64 f0 ff ff       	call   800bc6 <sys_cgetc>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	74 f2                	je     801b58 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 16                	js     801b80 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b6a:	83 f8 04             	cmp    $0x4,%eax
  801b6d:	74 0c                	je     801b7b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b72:	88 02                	mov    %al,(%edx)
	return 1;
  801b74:	b8 01 00 00 00       	mov    $0x1,%eax
  801b79:	eb 05                	jmp    801b80 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b7b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b88:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b8e:	6a 01                	push   $0x1
  801b90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b93:	50                   	push   %eax
  801b94:	e8 0f f0 ff ff       	call   800ba8 <sys_cputs>
}
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <getchar>:

int
getchar(void)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ba4:	6a 01                	push   $0x1
  801ba6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba9:	50                   	push   %eax
  801baa:	6a 00                	push   $0x0
  801bac:	e8 80 f5 ff ff       	call   801131 <read>
	if (r < 0)
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 0f                	js     801bc7 <getchar+0x29>
		return r;
	if (r < 1)
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	7e 06                	jle    801bc2 <getchar+0x24>
		return -E_EOF;
	return c;
  801bbc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bc0:	eb 05                	jmp    801bc7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bc2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd2:	50                   	push   %eax
  801bd3:	ff 75 08             	pushl  0x8(%ebp)
  801bd6:	e8 f0 f2 ff ff       	call   800ecb <fd_lookup>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 11                	js     801bf3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801beb:	39 10                	cmp    %edx,(%eax)
  801bed:	0f 94 c0             	sete   %al
  801bf0:	0f b6 c0             	movzbl %al,%eax
}
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <opencons>:

int
opencons(void)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfe:	50                   	push   %eax
  801bff:	e8 78 f2 ff ff       	call   800e7c <fd_alloc>
  801c04:	83 c4 10             	add    $0x10,%esp
		return r;
  801c07:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 3e                	js     801c4b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c0d:	83 ec 04             	sub    $0x4,%esp
  801c10:	68 07 04 00 00       	push   $0x407
  801c15:	ff 75 f4             	pushl  -0xc(%ebp)
  801c18:	6a 00                	push   $0x0
  801c1a:	e8 45 f0 ff ff       	call   800c64 <sys_page_alloc>
  801c1f:	83 c4 10             	add    $0x10,%esp
		return r;
  801c22:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 23                	js     801c4b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c28:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c31:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c36:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	50                   	push   %eax
  801c41:	e8 0f f2 ff ff       	call   800e55 <fd2num>
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	83 c4 10             	add    $0x10,%esp
}
  801c4b:	89 d0                	mov    %edx,%eax
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	8b 75 08             	mov    0x8(%ebp),%esi
  801c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c64:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	50                   	push   %eax
  801c6b:	e8 a4 f1 ff ff       	call   800e14 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	75 10                	jne    801c87 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801c77:	a1 08 40 80 00       	mov    0x804008,%eax
  801c7c:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801c7f:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801c82:	8b 40 70             	mov    0x70(%eax),%eax
  801c85:	eb 0a                	jmp    801c91 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801c87:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801c8c:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801c91:	85 f6                	test   %esi,%esi
  801c93:	74 02                	je     801c97 <ipc_recv+0x48>
  801c95:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801c97:	85 db                	test   %ebx,%ebx
  801c99:	74 02                	je     801c9d <ipc_recv+0x4e>
  801c9b:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801c9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	57                   	push   %edi
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801cb6:	85 db                	test   %ebx,%ebx
  801cb8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cbd:	0f 44 d8             	cmove  %eax,%ebx
  801cc0:	eb 1c                	jmp    801cde <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801cc2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cc5:	74 12                	je     801cd9 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801cc7:	50                   	push   %eax
  801cc8:	68 9a 24 80 00       	push   $0x80249a
  801ccd:	6a 40                	push   $0x40
  801ccf:	68 ac 24 80 00       	push   $0x8024ac
  801cd4:	e8 0c e5 ff ff       	call   8001e5 <_panic>
        sys_yield();
  801cd9:	e8 67 ef ff ff       	call   800c45 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801cde:	ff 75 14             	pushl  0x14(%ebp)
  801ce1:	53                   	push   %ebx
  801ce2:	56                   	push   %esi
  801ce3:	57                   	push   %edi
  801ce4:	e8 08 f1 ff ff       	call   800df1 <sys_ipc_try_send>
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	85 c0                	test   %eax,%eax
  801cee:	75 d2                	jne    801cc2 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cfe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d03:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d06:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d0c:	8b 52 50             	mov    0x50(%edx),%edx
  801d0f:	39 ca                	cmp    %ecx,%edx
  801d11:	75 0d                	jne    801d20 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d13:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d16:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d1b:	8b 40 48             	mov    0x48(%eax),%eax
  801d1e:	eb 0f                	jmp    801d2f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d20:	83 c0 01             	add    $0x1,%eax
  801d23:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d28:	75 d9                	jne    801d03 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d2f:	5d                   	pop    %ebp
  801d30:	c3                   	ret    

00801d31 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d37:	89 d0                	mov    %edx,%eax
  801d39:	c1 e8 16             	shr    $0x16,%eax
  801d3c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d48:	f6 c1 01             	test   $0x1,%cl
  801d4b:	74 1d                	je     801d6a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d4d:	c1 ea 0c             	shr    $0xc,%edx
  801d50:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d57:	f6 c2 01             	test   $0x1,%dl
  801d5a:	74 0e                	je     801d6a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d5c:	c1 ea 0c             	shr    $0xc,%edx
  801d5f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d66:	ef 
  801d67:	0f b7 c0             	movzwl %ax,%eax
}
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__udivdi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 f6                	test   %esi,%esi
  801d89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d8d:	89 ca                	mov    %ecx,%edx
  801d8f:	89 f8                	mov    %edi,%eax
  801d91:	75 3d                	jne    801dd0 <__udivdi3+0x60>
  801d93:	39 cf                	cmp    %ecx,%edi
  801d95:	0f 87 c5 00 00 00    	ja     801e60 <__udivdi3+0xf0>
  801d9b:	85 ff                	test   %edi,%edi
  801d9d:	89 fd                	mov    %edi,%ebp
  801d9f:	75 0b                	jne    801dac <__udivdi3+0x3c>
  801da1:	b8 01 00 00 00       	mov    $0x1,%eax
  801da6:	31 d2                	xor    %edx,%edx
  801da8:	f7 f7                	div    %edi
  801daa:	89 c5                	mov    %eax,%ebp
  801dac:	89 c8                	mov    %ecx,%eax
  801dae:	31 d2                	xor    %edx,%edx
  801db0:	f7 f5                	div    %ebp
  801db2:	89 c1                	mov    %eax,%ecx
  801db4:	89 d8                	mov    %ebx,%eax
  801db6:	89 cf                	mov    %ecx,%edi
  801db8:	f7 f5                	div    %ebp
  801dba:	89 c3                	mov    %eax,%ebx
  801dbc:	89 d8                	mov    %ebx,%eax
  801dbe:	89 fa                	mov    %edi,%edx
  801dc0:	83 c4 1c             	add    $0x1c,%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    
  801dc8:	90                   	nop
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	39 ce                	cmp    %ecx,%esi
  801dd2:	77 74                	ja     801e48 <__udivdi3+0xd8>
  801dd4:	0f bd fe             	bsr    %esi,%edi
  801dd7:	83 f7 1f             	xor    $0x1f,%edi
  801dda:	0f 84 98 00 00 00    	je     801e78 <__udivdi3+0x108>
  801de0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	89 c5                	mov    %eax,%ebp
  801de9:	29 fb                	sub    %edi,%ebx
  801deb:	d3 e6                	shl    %cl,%esi
  801ded:	89 d9                	mov    %ebx,%ecx
  801def:	d3 ed                	shr    %cl,%ebp
  801df1:	89 f9                	mov    %edi,%ecx
  801df3:	d3 e0                	shl    %cl,%eax
  801df5:	09 ee                	or     %ebp,%esi
  801df7:	89 d9                	mov    %ebx,%ecx
  801df9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dfd:	89 d5                	mov    %edx,%ebp
  801dff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e03:	d3 ed                	shr    %cl,%ebp
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	d3 e2                	shl    %cl,%edx
  801e09:	89 d9                	mov    %ebx,%ecx
  801e0b:	d3 e8                	shr    %cl,%eax
  801e0d:	09 c2                	or     %eax,%edx
  801e0f:	89 d0                	mov    %edx,%eax
  801e11:	89 ea                	mov    %ebp,%edx
  801e13:	f7 f6                	div    %esi
  801e15:	89 d5                	mov    %edx,%ebp
  801e17:	89 c3                	mov    %eax,%ebx
  801e19:	f7 64 24 0c          	mull   0xc(%esp)
  801e1d:	39 d5                	cmp    %edx,%ebp
  801e1f:	72 10                	jb     801e31 <__udivdi3+0xc1>
  801e21:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e25:	89 f9                	mov    %edi,%ecx
  801e27:	d3 e6                	shl    %cl,%esi
  801e29:	39 c6                	cmp    %eax,%esi
  801e2b:	73 07                	jae    801e34 <__udivdi3+0xc4>
  801e2d:	39 d5                	cmp    %edx,%ebp
  801e2f:	75 03                	jne    801e34 <__udivdi3+0xc4>
  801e31:	83 eb 01             	sub    $0x1,%ebx
  801e34:	31 ff                	xor    %edi,%edi
  801e36:	89 d8                	mov    %ebx,%eax
  801e38:	89 fa                	mov    %edi,%edx
  801e3a:	83 c4 1c             	add    $0x1c,%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5f                   	pop    %edi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    
  801e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e48:	31 ff                	xor    %edi,%edi
  801e4a:	31 db                	xor    %ebx,%ebx
  801e4c:	89 d8                	mov    %ebx,%eax
  801e4e:	89 fa                	mov    %edi,%edx
  801e50:	83 c4 1c             	add    $0x1c,%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    
  801e58:	90                   	nop
  801e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e60:	89 d8                	mov    %ebx,%eax
  801e62:	f7 f7                	div    %edi
  801e64:	31 ff                	xor    %edi,%edi
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	89 d8                	mov    %ebx,%eax
  801e6a:	89 fa                	mov    %edi,%edx
  801e6c:	83 c4 1c             	add    $0x1c,%esp
  801e6f:	5b                   	pop    %ebx
  801e70:	5e                   	pop    %esi
  801e71:	5f                   	pop    %edi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    
  801e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e78:	39 ce                	cmp    %ecx,%esi
  801e7a:	72 0c                	jb     801e88 <__udivdi3+0x118>
  801e7c:	31 db                	xor    %ebx,%ebx
  801e7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e82:	0f 87 34 ff ff ff    	ja     801dbc <__udivdi3+0x4c>
  801e88:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e8d:	e9 2a ff ff ff       	jmp    801dbc <__udivdi3+0x4c>
  801e92:	66 90                	xchg   %ax,%ax
  801e94:	66 90                	xchg   %ax,%ax
  801e96:	66 90                	xchg   %ax,%ax
  801e98:	66 90                	xchg   %ax,%ax
  801e9a:	66 90                	xchg   %ax,%ax
  801e9c:	66 90                	xchg   %ax,%ax
  801e9e:	66 90                	xchg   %ax,%ax

00801ea0 <__umoddi3>:
  801ea0:	55                   	push   %ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 1c             	sub    $0x1c,%esp
  801ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801eab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801eaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801eb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eb7:	85 d2                	test   %edx,%edx
  801eb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ec1:	89 f3                	mov    %esi,%ebx
  801ec3:	89 3c 24             	mov    %edi,(%esp)
  801ec6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eca:	75 1c                	jne    801ee8 <__umoddi3+0x48>
  801ecc:	39 f7                	cmp    %esi,%edi
  801ece:	76 50                	jbe    801f20 <__umoddi3+0x80>
  801ed0:	89 c8                	mov    %ecx,%eax
  801ed2:	89 f2                	mov    %esi,%edx
  801ed4:	f7 f7                	div    %edi
  801ed6:	89 d0                	mov    %edx,%eax
  801ed8:	31 d2                	xor    %edx,%edx
  801eda:	83 c4 1c             	add    $0x1c,%esp
  801edd:	5b                   	pop    %ebx
  801ede:	5e                   	pop    %esi
  801edf:	5f                   	pop    %edi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    
  801ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee8:	39 f2                	cmp    %esi,%edx
  801eea:	89 d0                	mov    %edx,%eax
  801eec:	77 52                	ja     801f40 <__umoddi3+0xa0>
  801eee:	0f bd ea             	bsr    %edx,%ebp
  801ef1:	83 f5 1f             	xor    $0x1f,%ebp
  801ef4:	75 5a                	jne    801f50 <__umoddi3+0xb0>
  801ef6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801efa:	0f 82 e0 00 00 00    	jb     801fe0 <__umoddi3+0x140>
  801f00:	39 0c 24             	cmp    %ecx,(%esp)
  801f03:	0f 86 d7 00 00 00    	jbe    801fe0 <__umoddi3+0x140>
  801f09:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f11:	83 c4 1c             	add    $0x1c,%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5f                   	pop    %edi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    
  801f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f20:	85 ff                	test   %edi,%edi
  801f22:	89 fd                	mov    %edi,%ebp
  801f24:	75 0b                	jne    801f31 <__umoddi3+0x91>
  801f26:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	f7 f7                	div    %edi
  801f2f:	89 c5                	mov    %eax,%ebp
  801f31:	89 f0                	mov    %esi,%eax
  801f33:	31 d2                	xor    %edx,%edx
  801f35:	f7 f5                	div    %ebp
  801f37:	89 c8                	mov    %ecx,%eax
  801f39:	f7 f5                	div    %ebp
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	eb 99                	jmp    801ed8 <__umoddi3+0x38>
  801f3f:	90                   	nop
  801f40:	89 c8                	mov    %ecx,%eax
  801f42:	89 f2                	mov    %esi,%edx
  801f44:	83 c4 1c             	add    $0x1c,%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    
  801f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f50:	8b 34 24             	mov    (%esp),%esi
  801f53:	bf 20 00 00 00       	mov    $0x20,%edi
  801f58:	89 e9                	mov    %ebp,%ecx
  801f5a:	29 ef                	sub    %ebp,%edi
  801f5c:	d3 e0                	shl    %cl,%eax
  801f5e:	89 f9                	mov    %edi,%ecx
  801f60:	89 f2                	mov    %esi,%edx
  801f62:	d3 ea                	shr    %cl,%edx
  801f64:	89 e9                	mov    %ebp,%ecx
  801f66:	09 c2                	or     %eax,%edx
  801f68:	89 d8                	mov    %ebx,%eax
  801f6a:	89 14 24             	mov    %edx,(%esp)
  801f6d:	89 f2                	mov    %esi,%edx
  801f6f:	d3 e2                	shl    %cl,%edx
  801f71:	89 f9                	mov    %edi,%ecx
  801f73:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f7b:	d3 e8                	shr    %cl,%eax
  801f7d:	89 e9                	mov    %ebp,%ecx
  801f7f:	89 c6                	mov    %eax,%esi
  801f81:	d3 e3                	shl    %cl,%ebx
  801f83:	89 f9                	mov    %edi,%ecx
  801f85:	89 d0                	mov    %edx,%eax
  801f87:	d3 e8                	shr    %cl,%eax
  801f89:	89 e9                	mov    %ebp,%ecx
  801f8b:	09 d8                	or     %ebx,%eax
  801f8d:	89 d3                	mov    %edx,%ebx
  801f8f:	89 f2                	mov    %esi,%edx
  801f91:	f7 34 24             	divl   (%esp)
  801f94:	89 d6                	mov    %edx,%esi
  801f96:	d3 e3                	shl    %cl,%ebx
  801f98:	f7 64 24 04          	mull   0x4(%esp)
  801f9c:	39 d6                	cmp    %edx,%esi
  801f9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa2:	89 d1                	mov    %edx,%ecx
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	72 08                	jb     801fb0 <__umoddi3+0x110>
  801fa8:	75 11                	jne    801fbb <__umoddi3+0x11b>
  801faa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fae:	73 0b                	jae    801fbb <__umoddi3+0x11b>
  801fb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801fb4:	1b 14 24             	sbb    (%esp),%edx
  801fb7:	89 d1                	mov    %edx,%ecx
  801fb9:	89 c3                	mov    %eax,%ebx
  801fbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fbf:	29 da                	sub    %ebx,%edx
  801fc1:	19 ce                	sbb    %ecx,%esi
  801fc3:	89 f9                	mov    %edi,%ecx
  801fc5:	89 f0                	mov    %esi,%eax
  801fc7:	d3 e0                	shl    %cl,%eax
  801fc9:	89 e9                	mov    %ebp,%ecx
  801fcb:	d3 ea                	shr    %cl,%edx
  801fcd:	89 e9                	mov    %ebp,%ecx
  801fcf:	d3 ee                	shr    %cl,%esi
  801fd1:	09 d0                	or     %edx,%eax
  801fd3:	89 f2                	mov    %esi,%edx
  801fd5:	83 c4 1c             	add    $0x1c,%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    
  801fdd:	8d 76 00             	lea    0x0(%esi),%esi
  801fe0:	29 f9                	sub    %edi,%ecx
  801fe2:	19 d6                	sbb    %edx,%esi
  801fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fec:	e9 18 ff ff ff       	jmp    801f09 <__umoddi3+0x69>
