
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 20 1e 80 00       	push   $0x801e20
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 ba 0a 00 00       	call   800b14 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 40 1e 80 00       	push   $0x801e40
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 6c 1e 80 00       	push   $0x801e6c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 4b 0a 00 00       	call   800af5 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 04 0e 00 00       	call   800eef <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 bf 09 00 00       	call   800ab4 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 4d 09 00 00       	call   800a77 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 f2 08 00 00       	call   800a77 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 8b 19 00 00       	call   801b80 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 78 1a 00 00       	call   801cb0 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 95 1e 80 00 	movsbl 0x801e95(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 a7 03 00 00    	je     800687 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800316:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 d0             	movzbl %al,%edx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 31 03 00 00    	ja     80066c <vprintfmt+0x3a8>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800363:	8d 72 d0             	lea    -0x30(%edx),%esi
  800366:	83 fe 09             	cmp    $0x9,%esi
  800369:	77 34                	ja     80039f <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 50 04             	lea    0x4(%eax),%edx
  800376:	89 55 14             	mov    %edx,0x14(%ebp)
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 22                	jmp    8003a5 <vprintfmt+0xe1>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	0f 48 c1             	cmovs  %ecx,%eax
  80038b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	eb 91                	jmp    800324 <vprintfmt+0x60>
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800396:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039d:	eb 85                	jmp    800324 <vprintfmt+0x60>
  80039f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a2:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8003a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a9:	0f 89 75 ff ff ff    	jns    800324 <vprintfmt+0x60>
				width = precision, precision = -1;
  8003af:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003bc:	e9 63 ff ff ff       	jmp    800324 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c8:	e9 57 ff ff ff       	jmp    800324 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 50 04             	lea    0x4(%eax),%edx
  8003d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d6:	83 ec 08             	sub    $0x8,%esp
  8003d9:	53                   	push   %ebx
  8003da:	ff 30                	pushl  (%eax)
  8003dc:	ff d6                	call   *%esi
			break;
  8003de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e4:	e9 01 ff ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 50 04             	lea    0x4(%eax),%edx
  8003ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	99                   	cltd   
  8003f5:	31 d0                	xor    %edx,%eax
  8003f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f9:	83 f8 0f             	cmp    $0xf,%eax
  8003fc:	7f 0b                	jg     800409 <vprintfmt+0x145>
  8003fe:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800405:	85 d2                	test   %edx,%edx
  800407:	75 18                	jne    800421 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  800409:	50                   	push   %eax
  80040a:	68 ad 1e 80 00       	push   $0x801ead
  80040f:	53                   	push   %ebx
  800410:	56                   	push   %esi
  800411:	e8 91 fe ff ff       	call   8002a7 <printfmt>
  800416:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80041c:	e9 c9 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800421:	52                   	push   %edx
  800422:	68 71 22 80 00       	push   $0x802271
  800427:	53                   	push   %ebx
  800428:	56                   	push   %esi
  800429:	e8 79 fe ff ff       	call   8002a7 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	e9 b1 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800444:	85 ff                	test   %edi,%edi
  800446:	b8 a6 1e 80 00       	mov    $0x801ea6,%eax
  80044b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800452:	0f 8e 94 00 00 00    	jle    8004ec <vprintfmt+0x228>
  800458:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80045c:	0f 84 98 00 00 00    	je     8004fa <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	ff 75 cc             	pushl  -0x34(%ebp)
  800468:	57                   	push   %edi
  800469:	e8 a1 02 00 00       	call   80070f <strnlen>
  80046e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800471:	29 c1                	sub    %eax,%ecx
  800473:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800476:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800479:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800480:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800483:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	eb 0f                	jmp    800496 <vprintfmt+0x1d2>
					putch(padc, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	53                   	push   %ebx
  80048b:	ff 75 e0             	pushl  -0x20(%ebp)
  80048e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	83 ef 01             	sub    $0x1,%edi
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	85 ff                	test   %edi,%edi
  800498:	7f ed                	jg     800487 <vprintfmt+0x1c3>
  80049a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a0:	85 c9                	test   %ecx,%ecx
  8004a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a7:	0f 49 c1             	cmovns %ecx,%eax
  8004aa:	29 c1                	sub    %eax,%ecx
  8004ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8004af:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b5:	89 cb                	mov    %ecx,%ebx
  8004b7:	eb 4d                	jmp    800506 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bd:	74 1b                	je     8004da <vprintfmt+0x216>
  8004bf:	0f be c0             	movsbl %al,%eax
  8004c2:	83 e8 20             	sub    $0x20,%eax
  8004c5:	83 f8 5e             	cmp    $0x5e,%eax
  8004c8:	76 10                	jbe    8004da <vprintfmt+0x216>
					putch('?', putdat);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 0c             	pushl  0xc(%ebp)
  8004d0:	6a 3f                	push   $0x3f
  8004d2:	ff 55 08             	call   *0x8(%ebp)
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	eb 0d                	jmp    8004e7 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	52                   	push   %edx
  8004e1:	ff 55 08             	call   *0x8(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e7:	83 eb 01             	sub    $0x1,%ebx
  8004ea:	eb 1a                	jmp    800506 <vprintfmt+0x242>
  8004ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ef:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f8:	eb 0c                	jmp    800506 <vprintfmt+0x242>
  8004fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800500:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800503:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800506:	83 c7 01             	add    $0x1,%edi
  800509:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050d:	0f be d0             	movsbl %al,%edx
  800510:	85 d2                	test   %edx,%edx
  800512:	74 23                	je     800537 <vprintfmt+0x273>
  800514:	85 f6                	test   %esi,%esi
  800516:	78 a1                	js     8004b9 <vprintfmt+0x1f5>
  800518:	83 ee 01             	sub    $0x1,%esi
  80051b:	79 9c                	jns    8004b9 <vprintfmt+0x1f5>
  80051d:	89 df                	mov    %ebx,%edi
  80051f:	8b 75 08             	mov    0x8(%ebp),%esi
  800522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800525:	eb 18                	jmp    80053f <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	53                   	push   %ebx
  80052b:	6a 20                	push   $0x20
  80052d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052f:	83 ef 01             	sub    $0x1,%edi
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb 08                	jmp    80053f <vprintfmt+0x27b>
  800537:	89 df                	mov    %ebx,%edi
  800539:	8b 75 08             	mov    0x8(%ebp),%esi
  80053c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053f:	85 ff                	test   %edi,%edi
  800541:	7f e4                	jg     800527 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800546:	e9 9f fd ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054b:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80054f:	7e 16                	jle    800567 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 08             	lea    0x8(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 50 04             	mov    0x4(%eax),%edx
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800562:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800565:	eb 34                	jmp    80059b <vprintfmt+0x2d7>
	else if (lflag)
  800567:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80056b:	74 18                	je     800585 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	89 c1                	mov    %eax,%ecx
  80057d:	c1 f9 1f             	sar    $0x1f,%ecx
  800580:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800583:	eb 16                	jmp    80059b <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 04             	lea    0x4(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800593:	89 c1                	mov    %eax,%ecx
  800595:	c1 f9 1f             	sar    $0x1f,%ecx
  800598:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005aa:	0f 89 88 00 00 00    	jns    800638 <vprintfmt+0x374>
				putch('-', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 2d                	push   $0x2d
  8005b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005be:	f7 d8                	neg    %eax
  8005c0:	83 d2 00             	adc    $0x0,%edx
  8005c3:	f7 da                	neg    %edx
  8005c5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cd:	eb 69                	jmp    800638 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 76 fc ff ff       	call   800250 <getuint>
			base = 10;
  8005da:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005df:	eb 57                	jmp    800638 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	6a 30                	push   $0x30
  8005e7:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8005e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 5c fc ff ff       	call   800250 <getuint>
			base = 8;
			goto number;
  8005f4:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8005f7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fc:	eb 3a                	jmp    800638 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 30                	push   $0x30
  800604:	ff d6                	call   *%esi
			putch('x', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 78                	push   $0x78
  80060c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800621:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800626:	eb 10                	jmp    800638 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800628:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 1d fc ff ff       	call   800250 <getuint>
			base = 16;
  800633:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063f:	57                   	push   %edi
  800640:	ff 75 e0             	pushl  -0x20(%ebp)
  800643:	51                   	push   %ecx
  800644:	52                   	push   %edx
  800645:	50                   	push   %eax
  800646:	89 da                	mov    %ebx,%edx
  800648:	89 f0                	mov    %esi,%eax
  80064a:	e8 52 fb ff ff       	call   8001a1 <printnum>
			break;
  80064f:	83 c4 20             	add    $0x20,%esp
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800655:	e9 90 fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	52                   	push   %edx
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800667:	e9 7e fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 25                	push   $0x25
  800672:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	eb 03                	jmp    80067c <vprintfmt+0x3b8>
  800679:	83 ef 01             	sub    $0x1,%edi
  80067c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800680:	75 f7                	jne    800679 <vprintfmt+0x3b5>
  800682:	e9 63 fc ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068a:	5b                   	pop    %ebx
  80068b:	5e                   	pop    %esi
  80068c:	5f                   	pop    %edi
  80068d:	5d                   	pop    %ebp
  80068e:	c3                   	ret    

0080068f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	83 ec 18             	sub    $0x18,%esp
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	74 26                	je     8006d6 <vsnprintf+0x47>
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	7e 22                	jle    8006d6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b4:	ff 75 14             	pushl  0x14(%ebp)
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bd:	50                   	push   %eax
  8006be:	68 8a 02 80 00       	push   $0x80028a
  8006c3:	e8 fc fb ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	eb 05                	jmp    8006db <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e6:	50                   	push   %eax
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	ff 75 08             	pushl  0x8(%ebp)
  8006f0:	e8 9a ff ff ff       	call   80068f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	eb 03                	jmp    800707 <strlen+0x10>
		n++;
  800704:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800707:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070b:	75 f7                	jne    800704 <strlen+0xd>
		n++;
	return n;
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800715:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800718:	ba 00 00 00 00       	mov    $0x0,%edx
  80071d:	eb 03                	jmp    800722 <strnlen+0x13>
		n++;
  80071f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800722:	39 c2                	cmp    %eax,%edx
  800724:	74 08                	je     80072e <strnlen+0x1f>
  800726:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80072a:	75 f3                	jne    80071f <strnlen+0x10>
  80072c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073a:	89 c2                	mov    %eax,%edx
  80073c:	83 c2 01             	add    $0x1,%edx
  80073f:	83 c1 01             	add    $0x1,%ecx
  800742:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800746:	88 5a ff             	mov    %bl,-0x1(%edx)
  800749:	84 db                	test   %bl,%bl
  80074b:	75 ef                	jne    80073c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074d:	5b                   	pop    %ebx
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800757:	53                   	push   %ebx
  800758:	e8 9a ff ff ff       	call   8006f7 <strlen>
  80075d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800760:	ff 75 0c             	pushl  0xc(%ebp)
  800763:	01 d8                	add    %ebx,%eax
  800765:	50                   	push   %eax
  800766:	e8 c5 ff ff ff       	call   800730 <strcpy>
	return dst;
}
  80076b:	89 d8                	mov    %ebx,%eax
  80076d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	56                   	push   %esi
  800776:	53                   	push   %ebx
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077d:	89 f3                	mov    %esi,%ebx
  80077f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800782:	89 f2                	mov    %esi,%edx
  800784:	eb 0f                	jmp    800795 <strncpy+0x23>
		*dst++ = *src;
  800786:	83 c2 01             	add    $0x1,%edx
  800789:	0f b6 01             	movzbl (%ecx),%eax
  80078c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078f:	80 39 01             	cmpb   $0x1,(%ecx)
  800792:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800795:	39 da                	cmp    %ebx,%edx
  800797:	75 ed                	jne    800786 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800799:	89 f0                	mov    %esi,%eax
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ad:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	74 21                	je     8007d4 <strlcpy+0x35>
  8007b3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b7:	89 f2                	mov    %esi,%edx
  8007b9:	eb 09                	jmp    8007c4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007bb:	83 c2 01             	add    $0x1,%edx
  8007be:	83 c1 01             	add    $0x1,%ecx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c4:	39 c2                	cmp    %eax,%edx
  8007c6:	74 09                	je     8007d1 <strlcpy+0x32>
  8007c8:	0f b6 19             	movzbl (%ecx),%ebx
  8007cb:	84 db                	test   %bl,%bl
  8007cd:	75 ec                	jne    8007bb <strlcpy+0x1c>
  8007cf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d4:	29 f0                	sub    %esi,%eax
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e3:	eb 06                	jmp    8007eb <strcmp+0x11>
		p++, q++;
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007eb:	0f b6 01             	movzbl (%ecx),%eax
  8007ee:	84 c0                	test   %al,%al
  8007f0:	74 04                	je     8007f6 <strcmp+0x1c>
  8007f2:	3a 02                	cmp    (%edx),%al
  8007f4:	74 ef                	je     8007e5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f6:	0f b6 c0             	movzbl %al,%eax
  8007f9:	0f b6 12             	movzbl (%edx),%edx
  8007fc:	29 d0                	sub    %edx,%eax
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080a:	89 c3                	mov    %eax,%ebx
  80080c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080f:	eb 06                	jmp    800817 <strncmp+0x17>
		n--, p++, q++;
  800811:	83 c0 01             	add    $0x1,%eax
  800814:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800817:	39 d8                	cmp    %ebx,%eax
  800819:	74 15                	je     800830 <strncmp+0x30>
  80081b:	0f b6 08             	movzbl (%eax),%ecx
  80081e:	84 c9                	test   %cl,%cl
  800820:	74 04                	je     800826 <strncmp+0x26>
  800822:	3a 0a                	cmp    (%edx),%cl
  800824:	74 eb                	je     800811 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800826:	0f b6 00             	movzbl (%eax),%eax
  800829:	0f b6 12             	movzbl (%edx),%edx
  80082c:	29 d0                	sub    %edx,%eax
  80082e:	eb 05                	jmp    800835 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800842:	eb 07                	jmp    80084b <strchr+0x13>
		if (*s == c)
  800844:	38 ca                	cmp    %cl,%dl
  800846:	74 0f                	je     800857 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800848:	83 c0 01             	add    $0x1,%eax
  80084b:	0f b6 10             	movzbl (%eax),%edx
  80084e:	84 d2                	test   %dl,%dl
  800850:	75 f2                	jne    800844 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800863:	eb 03                	jmp    800868 <strfind+0xf>
  800865:	83 c0 01             	add    $0x1,%eax
  800868:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80086b:	38 ca                	cmp    %cl,%dl
  80086d:	74 04                	je     800873 <strfind+0x1a>
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f2                	jne    800865 <strfind+0xc>
			break;
	return (char *) s;
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	57                   	push   %edi
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	74 36                	je     8008bb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800885:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088b:	75 28                	jne    8008b5 <memset+0x40>
  80088d:	f6 c1 03             	test   $0x3,%cl
  800890:	75 23                	jne    8008b5 <memset+0x40>
		c &= 0xFF;
  800892:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800896:	89 d3                	mov    %edx,%ebx
  800898:	c1 e3 08             	shl    $0x8,%ebx
  80089b:	89 d6                	mov    %edx,%esi
  80089d:	c1 e6 18             	shl    $0x18,%esi
  8008a0:	89 d0                	mov    %edx,%eax
  8008a2:	c1 e0 10             	shl    $0x10,%eax
  8008a5:	09 f0                	or     %esi,%eax
  8008a7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a9:	89 d8                	mov    %ebx,%eax
  8008ab:	09 d0                	or     %edx,%eax
  8008ad:	c1 e9 02             	shr    $0x2,%ecx
  8008b0:	fc                   	cld    
  8008b1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b3:	eb 06                	jmp    8008bb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b8:	fc                   	cld    
  8008b9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008bb:	89 f8                	mov    %edi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5f                   	pop    %edi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d0:	39 c6                	cmp    %eax,%esi
  8008d2:	73 35                	jae    800909 <memmove+0x47>
  8008d4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d7:	39 d0                	cmp    %edx,%eax
  8008d9:	73 2e                	jae    800909 <memmove+0x47>
		s += n;
		d += n;
  8008db:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	09 fe                	or     %edi,%esi
  8008e2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e8:	75 13                	jne    8008fd <memmove+0x3b>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 0e                	jne    8008fd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ef:	83 ef 04             	sub    $0x4,%edi
  8008f2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f5:	c1 e9 02             	shr    $0x2,%ecx
  8008f8:	fd                   	std    
  8008f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fb:	eb 09                	jmp    800906 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fd:	83 ef 01             	sub    $0x1,%edi
  800900:	8d 72 ff             	lea    -0x1(%edx),%esi
  800903:	fd                   	std    
  800904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800906:	fc                   	cld    
  800907:	eb 1d                	jmp    800926 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800909:	89 f2                	mov    %esi,%edx
  80090b:	09 c2                	or     %eax,%edx
  80090d:	f6 c2 03             	test   $0x3,%dl
  800910:	75 0f                	jne    800921 <memmove+0x5f>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 0a                	jne    800921 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800917:	c1 e9 02             	shr    $0x2,%ecx
  80091a:	89 c7                	mov    %eax,%edi
  80091c:	fc                   	cld    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 05                	jmp    800926 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092d:	ff 75 10             	pushl  0x10(%ebp)
  800930:	ff 75 0c             	pushl  0xc(%ebp)
  800933:	ff 75 08             	pushl  0x8(%ebp)
  800936:	e8 87 ff ff ff       	call   8008c2 <memmove>
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 55 0c             	mov    0xc(%ebp),%edx
  800948:	89 c6                	mov    %eax,%esi
  80094a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094d:	eb 1a                	jmp    800969 <memcmp+0x2c>
		if (*s1 != *s2)
  80094f:	0f b6 08             	movzbl (%eax),%ecx
  800952:	0f b6 1a             	movzbl (%edx),%ebx
  800955:	38 d9                	cmp    %bl,%cl
  800957:	74 0a                	je     800963 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800959:	0f b6 c1             	movzbl %cl,%eax
  80095c:	0f b6 db             	movzbl %bl,%ebx
  80095f:	29 d8                	sub    %ebx,%eax
  800961:	eb 0f                	jmp    800972 <memcmp+0x35>
		s1++, s2++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800969:	39 f0                	cmp    %esi,%eax
  80096b:	75 e2                	jne    80094f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097d:	89 c1                	mov    %eax,%ecx
  80097f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800982:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800986:	eb 0a                	jmp    800992 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800988:	0f b6 10             	movzbl (%eax),%edx
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	74 07                	je     800996 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	39 c8                	cmp    %ecx,%eax
  800994:	72 f2                	jb     800988 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800996:	5b                   	pop    %ebx
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a5:	eb 03                	jmp    8009aa <strtol+0x11>
		s++;
  8009a7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009aa:	0f b6 01             	movzbl (%ecx),%eax
  8009ad:	3c 20                	cmp    $0x20,%al
  8009af:	74 f6                	je     8009a7 <strtol+0xe>
  8009b1:	3c 09                	cmp    $0x9,%al
  8009b3:	74 f2                	je     8009a7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b5:	3c 2b                	cmp    $0x2b,%al
  8009b7:	75 0a                	jne    8009c3 <strtol+0x2a>
		s++;
  8009b9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c1:	eb 11                	jmp    8009d4 <strtol+0x3b>
  8009c3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c8:	3c 2d                	cmp    $0x2d,%al
  8009ca:	75 08                	jne    8009d4 <strtol+0x3b>
		s++, neg = 1;
  8009cc:	83 c1 01             	add    $0x1,%ecx
  8009cf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009da:	75 15                	jne    8009f1 <strtol+0x58>
  8009dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009df:	75 10                	jne    8009f1 <strtol+0x58>
  8009e1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e5:	75 7c                	jne    800a63 <strtol+0xca>
		s += 2, base = 16;
  8009e7:	83 c1 02             	add    $0x2,%ecx
  8009ea:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ef:	eb 16                	jmp    800a07 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f1:	85 db                	test   %ebx,%ebx
  8009f3:	75 12                	jne    800a07 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fa:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fd:	75 08                	jne    800a07 <strtol+0x6e>
		s++, base = 8;
  8009ff:	83 c1 01             	add    $0x1,%ecx
  800a02:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0f:	0f b6 11             	movzbl (%ecx),%edx
  800a12:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a15:	89 f3                	mov    %esi,%ebx
  800a17:	80 fb 09             	cmp    $0x9,%bl
  800a1a:	77 08                	ja     800a24 <strtol+0x8b>
			dig = *s - '0';
  800a1c:	0f be d2             	movsbl %dl,%edx
  800a1f:	83 ea 30             	sub    $0x30,%edx
  800a22:	eb 22                	jmp    800a46 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a24:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a27:	89 f3                	mov    %esi,%ebx
  800a29:	80 fb 19             	cmp    $0x19,%bl
  800a2c:	77 08                	ja     800a36 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2e:	0f be d2             	movsbl %dl,%edx
  800a31:	83 ea 57             	sub    $0x57,%edx
  800a34:	eb 10                	jmp    800a46 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a36:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a39:	89 f3                	mov    %esi,%ebx
  800a3b:	80 fb 19             	cmp    $0x19,%bl
  800a3e:	77 16                	ja     800a56 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a40:	0f be d2             	movsbl %dl,%edx
  800a43:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a46:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a49:	7d 0b                	jge    800a56 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a4b:	83 c1 01             	add    $0x1,%ecx
  800a4e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a52:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a54:	eb b9                	jmp    800a0f <strtol+0x76>

	if (endptr)
  800a56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5a:	74 0d                	je     800a69 <strtol+0xd0>
		*endptr = (char *) s;
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	89 0e                	mov    %ecx,(%esi)
  800a61:	eb 06                	jmp    800a69 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a63:	85 db                	test   %ebx,%ebx
  800a65:	74 98                	je     8009ff <strtol+0x66>
  800a67:	eb 9e                	jmp    800a07 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a69:	89 c2                	mov    %eax,%edx
  800a6b:	f7 da                	neg    %edx
  800a6d:	85 ff                	test   %edi,%edi
  800a6f:	0f 45 c2             	cmovne %edx,%eax
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a85:	8b 55 08             	mov    0x8(%ebp),%edx
  800a88:	89 c3                	mov    %eax,%ebx
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	89 c6                	mov    %eax,%esi
  800a8e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa5:	89 d1                	mov    %edx,%ecx
  800aa7:	89 d3                	mov    %edx,%ebx
  800aa9:	89 d7                	mov    %edx,%edi
  800aab:	89 d6                	mov    %edx,%esi
  800aad:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aca:	89 cb                	mov    %ecx,%ebx
  800acc:	89 cf                	mov    %ecx,%edi
  800ace:	89 ce                	mov    %ecx,%esi
  800ad0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	7e 17                	jle    800aed <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	50                   	push   %eax
  800ada:	6a 03                	push   $0x3
  800adc:	68 9f 21 80 00       	push   $0x80219f
  800ae1:	6a 23                	push   $0x23
  800ae3:	68 bc 21 80 00       	push   $0x8021bc
  800ae8:	e8 21 0f 00 00       	call   801a0e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	b8 02 00 00 00       	mov    $0x2,%eax
  800b05:	89 d1                	mov    %edx,%ecx
  800b07:	89 d3                	mov    %edx,%ebx
  800b09:	89 d7                	mov    %edx,%edi
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_yield>:

void
sys_yield(void)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b24:	89 d1                	mov    %edx,%ecx
  800b26:	89 d3                	mov    %edx,%ebx
  800b28:	89 d7                	mov    %edx,%edi
  800b2a:	89 d6                	mov    %edx,%esi
  800b2c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	be 00 00 00 00       	mov    $0x0,%esi
  800b41:	b8 04 00 00 00       	mov    $0x4,%eax
  800b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4f:	89 f7                	mov    %esi,%edi
  800b51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b53:	85 c0                	test   %eax,%eax
  800b55:	7e 17                	jle    800b6e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	50                   	push   %eax
  800b5b:	6a 04                	push   $0x4
  800b5d:	68 9f 21 80 00       	push   $0x80219f
  800b62:	6a 23                	push   $0x23
  800b64:	68 bc 21 80 00       	push   $0x8021bc
  800b69:	e8 a0 0e 00 00       	call   801a0e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b90:	8b 75 18             	mov    0x18(%ebp),%esi
  800b93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b95:	85 c0                	test   %eax,%eax
  800b97:	7e 17                	jle    800bb0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	50                   	push   %eax
  800b9d:	6a 05                	push   $0x5
  800b9f:	68 9f 21 80 00       	push   $0x80219f
  800ba4:	6a 23                	push   $0x23
  800ba6:	68 bc 21 80 00       	push   $0x8021bc
  800bab:	e8 5e 0e 00 00       	call   801a0e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	89 df                	mov    %ebx,%edi
  800bd3:	89 de                	mov    %ebx,%esi
  800bd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 17                	jle    800bf2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 06                	push   $0x6
  800be1:	68 9f 21 80 00       	push   $0x80219f
  800be6:	6a 23                	push   $0x23
  800be8:	68 bc 21 80 00       	push   $0x8021bc
  800bed:	e8 1c 0e 00 00       	call   801a0e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c08:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	89 df                	mov    %ebx,%edi
  800c15:	89 de                	mov    %ebx,%esi
  800c17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	7e 17                	jle    800c34 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 08                	push   $0x8
  800c23:	68 9f 21 80 00       	push   $0x80219f
  800c28:	6a 23                	push   $0x23
  800c2a:	68 bc 21 80 00       	push   $0x8021bc
  800c2f:	e8 da 0d 00 00       	call   801a0e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	89 df                	mov    %ebx,%edi
  800c57:	89 de                	mov    %ebx,%esi
  800c59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7e 17                	jle    800c76 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 09                	push   $0x9
  800c65:	68 9f 21 80 00       	push   $0x80219f
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 bc 21 80 00       	push   $0x8021bc
  800c71:	e8 98 0d 00 00       	call   801a0e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 df                	mov    %ebx,%edi
  800c99:	89 de                	mov    %ebx,%esi
  800c9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7e 17                	jle    800cb8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 0a                	push   $0xa
  800ca7:	68 9f 21 80 00       	push   $0x80219f
  800cac:	6a 23                	push   $0x23
  800cae:	68 bc 21 80 00       	push   $0x8021bc
  800cb3:	e8 56 0d 00 00       	call   801a0e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	be 00 00 00 00       	mov    $0x0,%esi
  800ccb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 cb                	mov    %ecx,%ebx
  800cfb:	89 cf                	mov    %ecx,%edi
  800cfd:	89 ce                	mov    %ecx,%esi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 0d                	push   $0xd
  800d0b:	68 9f 21 80 00       	push   $0x80219f
  800d10:	6a 23                	push   $0x23
  800d12:	68 bc 21 80 00       	push   $0x8021bc
  800d17:	e8 f2 0c 00 00       	call   801a0e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d2f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d44:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d51:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d56:	89 c2                	mov    %eax,%edx
  800d58:	c1 ea 16             	shr    $0x16,%edx
  800d5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d62:	f6 c2 01             	test   $0x1,%dl
  800d65:	74 11                	je     800d78 <fd_alloc+0x2d>
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	c1 ea 0c             	shr    $0xc,%edx
  800d6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d73:	f6 c2 01             	test   $0x1,%dl
  800d76:	75 09                	jne    800d81 <fd_alloc+0x36>
			*fd_store = fd;
  800d78:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7f:	eb 17                	jmp    800d98 <fd_alloc+0x4d>
  800d81:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d86:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d8b:	75 c9                	jne    800d56 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d8d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d93:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da0:	83 f8 1f             	cmp    $0x1f,%eax
  800da3:	77 36                	ja     800ddb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800da5:	c1 e0 0c             	shl    $0xc,%eax
  800da8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	c1 ea 16             	shr    $0x16,%edx
  800db2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db9:	f6 c2 01             	test   $0x1,%dl
  800dbc:	74 24                	je     800de2 <fd_lookup+0x48>
  800dbe:	89 c2                	mov    %eax,%edx
  800dc0:	c1 ea 0c             	shr    $0xc,%edx
  800dc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dca:	f6 c2 01             	test   $0x1,%dl
  800dcd:	74 1a                	je     800de9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd2:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd9:	eb 13                	jmp    800dee <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ddb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de0:	eb 0c                	jmp    800dee <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de7:	eb 05                	jmp    800dee <fd_lookup+0x54>
  800de9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
  800df6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df9:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dfe:	eb 13                	jmp    800e13 <dev_lookup+0x23>
  800e00:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e03:	39 08                	cmp    %ecx,(%eax)
  800e05:	75 0c                	jne    800e13 <dev_lookup+0x23>
			*dev = devtab[i];
  800e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e11:	eb 2e                	jmp    800e41 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e13:	8b 02                	mov    (%edx),%eax
  800e15:	85 c0                	test   %eax,%eax
  800e17:	75 e7                	jne    800e00 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e19:	a1 04 40 80 00       	mov    0x804004,%eax
  800e1e:	8b 40 48             	mov    0x48(%eax),%eax
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	51                   	push   %ecx
  800e25:	50                   	push   %eax
  800e26:	68 cc 21 80 00       	push   $0x8021cc
  800e2b:	e8 5d f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 10             	sub    $0x10,%esp
  800e4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e54:	50                   	push   %eax
  800e55:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e5b:	c1 e8 0c             	shr    $0xc,%eax
  800e5e:	50                   	push   %eax
  800e5f:	e8 36 ff ff ff       	call   800d9a <fd_lookup>
  800e64:	83 c4 08             	add    $0x8,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 05                	js     800e70 <fd_close+0x2d>
	    || fd != fd2)
  800e6b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e6e:	74 0c                	je     800e7c <fd_close+0x39>
		return (must_exist ? r : 0);
  800e70:	84 db                	test   %bl,%bl
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	0f 44 c2             	cmove  %edx,%eax
  800e7a:	eb 41                	jmp    800ebd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e7c:	83 ec 08             	sub    $0x8,%esp
  800e7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e82:	50                   	push   %eax
  800e83:	ff 36                	pushl  (%esi)
  800e85:	e8 66 ff ff ff       	call   800df0 <dev_lookup>
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 1a                	js     800ead <fd_close+0x6a>
		if (dev->dev_close)
  800e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e96:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e99:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	74 0b                	je     800ead <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	56                   	push   %esi
  800ea6:	ff d0                	call   *%eax
  800ea8:	89 c3                	mov    %eax,%ebx
  800eaa:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ead:	83 ec 08             	sub    $0x8,%esp
  800eb0:	56                   	push   %esi
  800eb1:	6a 00                	push   $0x0
  800eb3:	e8 00 fd ff ff       	call   800bb8 <sys_page_unmap>
	return r;
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	89 d8                	mov    %ebx,%eax
}
  800ebd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecd:	50                   	push   %eax
  800ece:	ff 75 08             	pushl  0x8(%ebp)
  800ed1:	e8 c4 fe ff ff       	call   800d9a <fd_lookup>
  800ed6:	83 c4 08             	add    $0x8,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	78 10                	js     800eed <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	6a 01                	push   $0x1
  800ee2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee5:	e8 59 ff ff ff       	call   800e43 <fd_close>
  800eea:	83 c4 10             	add    $0x10,%esp
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <close_all>:

void
close_all(void)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	53                   	push   %ebx
  800eff:	e8 c0 ff ff ff       	call   800ec4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f04:	83 c3 01             	add    $0x1,%ebx
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	83 fb 20             	cmp    $0x20,%ebx
  800f0d:	75 ec                	jne    800efb <close_all+0xc>
		close(i);
}
  800f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 2c             	sub    $0x2c,%esp
  800f1d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f20:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f23:	50                   	push   %eax
  800f24:	ff 75 08             	pushl  0x8(%ebp)
  800f27:	e8 6e fe ff ff       	call   800d9a <fd_lookup>
  800f2c:	83 c4 08             	add    $0x8,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	0f 88 c1 00 00 00    	js     800ff8 <dup+0xe4>
		return r;
	close(newfdnum);
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	56                   	push   %esi
  800f3b:	e8 84 ff ff ff       	call   800ec4 <close>

	newfd = INDEX2FD(newfdnum);
  800f40:	89 f3                	mov    %esi,%ebx
  800f42:	c1 e3 0c             	shl    $0xc,%ebx
  800f45:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f4b:	83 c4 04             	add    $0x4,%esp
  800f4e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f51:	e8 de fd ff ff       	call   800d34 <fd2data>
  800f56:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f58:	89 1c 24             	mov    %ebx,(%esp)
  800f5b:	e8 d4 fd ff ff       	call   800d34 <fd2data>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f66:	89 f8                	mov    %edi,%eax
  800f68:	c1 e8 16             	shr    $0x16,%eax
  800f6b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f72:	a8 01                	test   $0x1,%al
  800f74:	74 37                	je     800fad <dup+0x99>
  800f76:	89 f8                	mov    %edi,%eax
  800f78:	c1 e8 0c             	shr    $0xc,%eax
  800f7b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f82:	f6 c2 01             	test   $0x1,%dl
  800f85:	74 26                	je     800fad <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f87:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	25 07 0e 00 00       	and    $0xe07,%eax
  800f96:	50                   	push   %eax
  800f97:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f9a:	6a 00                	push   $0x0
  800f9c:	57                   	push   %edi
  800f9d:	6a 00                	push   $0x0
  800f9f:	e8 d2 fb ff ff       	call   800b76 <sys_page_map>
  800fa4:	89 c7                	mov    %eax,%edi
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 2e                	js     800fdb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb0:	89 d0                	mov    %edx,%eax
  800fb2:	c1 e8 0c             	shr    $0xc,%eax
  800fb5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc4:	50                   	push   %eax
  800fc5:	53                   	push   %ebx
  800fc6:	6a 00                	push   $0x0
  800fc8:	52                   	push   %edx
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 a6 fb ff ff       	call   800b76 <sys_page_map>
  800fd0:	89 c7                	mov    %eax,%edi
  800fd2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fd5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd7:	85 ff                	test   %edi,%edi
  800fd9:	79 1d                	jns    800ff8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	53                   	push   %ebx
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 d2 fb ff ff       	call   800bb8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fe6:	83 c4 08             	add    $0x8,%esp
  800fe9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fec:	6a 00                	push   $0x0
  800fee:	e8 c5 fb ff ff       	call   800bb8 <sys_page_unmap>
	return r;
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	89 f8                	mov    %edi,%eax
}
  800ff8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	53                   	push   %ebx
  801004:	83 ec 14             	sub    $0x14,%esp
  801007:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80100a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100d:	50                   	push   %eax
  80100e:	53                   	push   %ebx
  80100f:	e8 86 fd ff ff       	call   800d9a <fd_lookup>
  801014:	83 c4 08             	add    $0x8,%esp
  801017:	89 c2                	mov    %eax,%edx
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 6d                	js     80108a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80101d:	83 ec 08             	sub    $0x8,%esp
  801020:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801023:	50                   	push   %eax
  801024:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801027:	ff 30                	pushl  (%eax)
  801029:	e8 c2 fd ff ff       	call   800df0 <dev_lookup>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	78 4c                	js     801081 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801035:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801038:	8b 42 08             	mov    0x8(%edx),%eax
  80103b:	83 e0 03             	and    $0x3,%eax
  80103e:	83 f8 01             	cmp    $0x1,%eax
  801041:	75 21                	jne    801064 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801043:	a1 04 40 80 00       	mov    0x804004,%eax
  801048:	8b 40 48             	mov    0x48(%eax),%eax
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	53                   	push   %ebx
  80104f:	50                   	push   %eax
  801050:	68 0d 22 80 00       	push   $0x80220d
  801055:	e8 33 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801062:	eb 26                	jmp    80108a <read+0x8a>
	}
	if (!dev->dev_read)
  801064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801067:	8b 40 08             	mov    0x8(%eax),%eax
  80106a:	85 c0                	test   %eax,%eax
  80106c:	74 17                	je     801085 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	ff 75 10             	pushl  0x10(%ebp)
  801074:	ff 75 0c             	pushl  0xc(%ebp)
  801077:	52                   	push   %edx
  801078:	ff d0                	call   *%eax
  80107a:	89 c2                	mov    %eax,%edx
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	eb 09                	jmp    80108a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801081:	89 c2                	mov    %eax,%edx
  801083:	eb 05                	jmp    80108a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801085:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80108a:	89 d0                	mov    %edx,%eax
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80109d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a5:	eb 21                	jmp    8010c8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	89 f0                	mov    %esi,%eax
  8010ac:	29 d8                	sub    %ebx,%eax
  8010ae:	50                   	push   %eax
  8010af:	89 d8                	mov    %ebx,%eax
  8010b1:	03 45 0c             	add    0xc(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	57                   	push   %edi
  8010b6:	e8 45 ff ff ff       	call   801000 <read>
		if (m < 0)
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 10                	js     8010d2 <readn+0x41>
			return m;
		if (m == 0)
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	74 0a                	je     8010d0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c6:	01 c3                	add    %eax,%ebx
  8010c8:	39 f3                	cmp    %esi,%ebx
  8010ca:	72 db                	jb     8010a7 <readn+0x16>
  8010cc:	89 d8                	mov    %ebx,%eax
  8010ce:	eb 02                	jmp    8010d2 <readn+0x41>
  8010d0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 14             	sub    $0x14,%esp
  8010e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e7:	50                   	push   %eax
  8010e8:	53                   	push   %ebx
  8010e9:	e8 ac fc ff ff       	call   800d9a <fd_lookup>
  8010ee:	83 c4 08             	add    $0x8,%esp
  8010f1:	89 c2                	mov    %eax,%edx
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 68                	js     80115f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fd:	50                   	push   %eax
  8010fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801101:	ff 30                	pushl  (%eax)
  801103:	e8 e8 fc ff ff       	call   800df0 <dev_lookup>
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 47                	js     801156 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80110f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801112:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801116:	75 21                	jne    801139 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801118:	a1 04 40 80 00       	mov    0x804004,%eax
  80111d:	8b 40 48             	mov    0x48(%eax),%eax
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	53                   	push   %ebx
  801124:	50                   	push   %eax
  801125:	68 29 22 80 00       	push   $0x802229
  80112a:	e8 5e f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801137:	eb 26                	jmp    80115f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80113c:	8b 52 0c             	mov    0xc(%edx),%edx
  80113f:	85 d2                	test   %edx,%edx
  801141:	74 17                	je     80115a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801143:	83 ec 04             	sub    $0x4,%esp
  801146:	ff 75 10             	pushl  0x10(%ebp)
  801149:	ff 75 0c             	pushl  0xc(%ebp)
  80114c:	50                   	push   %eax
  80114d:	ff d2                	call   *%edx
  80114f:	89 c2                	mov    %eax,%edx
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	eb 09                	jmp    80115f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801156:	89 c2                	mov    %eax,%edx
  801158:	eb 05                	jmp    80115f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80115a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80115f:	89 d0                	mov    %edx,%eax
  801161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <seek>:

int
seek(int fdnum, off_t offset)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80116c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	e8 22 fc ff ff       	call   800d9a <fd_lookup>
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 0e                	js     80118d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80117f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801182:	8b 55 0c             	mov    0xc(%ebp),%edx
  801185:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	53                   	push   %ebx
  801193:	83 ec 14             	sub    $0x14,%esp
  801196:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801199:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	53                   	push   %ebx
  80119e:	e8 f7 fb ff ff       	call   800d9a <fd_lookup>
  8011a3:	83 c4 08             	add    $0x8,%esp
  8011a6:	89 c2                	mov    %eax,%edx
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 65                	js     801211 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b6:	ff 30                	pushl  (%eax)
  8011b8:	e8 33 fc ff ff       	call   800df0 <dev_lookup>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 44                	js     801208 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cb:	75 21                	jne    8011ee <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011cd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d2:	8b 40 48             	mov    0x48(%eax),%eax
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	53                   	push   %ebx
  8011d9:	50                   	push   %eax
  8011da:	68 ec 21 80 00       	push   $0x8021ec
  8011df:	e8 a9 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ec:	eb 23                	jmp    801211 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f1:	8b 52 18             	mov    0x18(%edx),%edx
  8011f4:	85 d2                	test   %edx,%edx
  8011f6:	74 14                	je     80120c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	ff 75 0c             	pushl  0xc(%ebp)
  8011fe:	50                   	push   %eax
  8011ff:	ff d2                	call   *%edx
  801201:	89 c2                	mov    %eax,%edx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	eb 09                	jmp    801211 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801208:	89 c2                	mov    %eax,%edx
  80120a:	eb 05                	jmp    801211 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80120c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801211:	89 d0                	mov    %edx,%eax
  801213:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	53                   	push   %ebx
  80121c:	83 ec 14             	sub    $0x14,%esp
  80121f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	ff 75 08             	pushl  0x8(%ebp)
  801229:	e8 6c fb ff ff       	call   800d9a <fd_lookup>
  80122e:	83 c4 08             	add    $0x8,%esp
  801231:	89 c2                	mov    %eax,%edx
  801233:	85 c0                	test   %eax,%eax
  801235:	78 58                	js     80128f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	ff 30                	pushl  (%eax)
  801243:	e8 a8 fb ff ff       	call   800df0 <dev_lookup>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 37                	js     801286 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80124f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801252:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801256:	74 32                	je     80128a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801258:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80125b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801262:	00 00 00 
	stat->st_isdir = 0;
  801265:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80126c:	00 00 00 
	stat->st_dev = dev;
  80126f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801275:	83 ec 08             	sub    $0x8,%esp
  801278:	53                   	push   %ebx
  801279:	ff 75 f0             	pushl  -0x10(%ebp)
  80127c:	ff 50 14             	call   *0x14(%eax)
  80127f:	89 c2                	mov    %eax,%edx
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	eb 09                	jmp    80128f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801286:	89 c2                	mov    %eax,%edx
  801288:	eb 05                	jmp    80128f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80128a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80128f:	89 d0                	mov    %edx,%eax
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	56                   	push   %esi
  80129a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	6a 00                	push   $0x0
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 e3 01 00 00       	call   80148b <open>
  8012a8:	89 c3                	mov    %eax,%ebx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 1b                	js     8012cc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	ff 75 0c             	pushl  0xc(%ebp)
  8012b7:	50                   	push   %eax
  8012b8:	e8 5b ff ff ff       	call   801218 <fstat>
  8012bd:	89 c6                	mov    %eax,%esi
	close(fd);
  8012bf:	89 1c 24             	mov    %ebx,(%esp)
  8012c2:	e8 fd fb ff ff       	call   800ec4 <close>
	return r;
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	89 f0                	mov    %esi,%eax
}
  8012cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	89 c6                	mov    %eax,%esi
  8012da:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e3:	75 12                	jne    8012f7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	6a 01                	push   $0x1
  8012ea:	e8 0e 08 00 00       	call   801afd <ipc_find_env>
  8012ef:	a3 00 40 80 00       	mov    %eax,0x804000
  8012f4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012f7:	6a 07                	push   $0x7
  8012f9:	68 00 50 80 00       	push   $0x805000
  8012fe:	56                   	push   %esi
  8012ff:	ff 35 00 40 80 00    	pushl  0x804000
  801305:	e8 9f 07 00 00       	call   801aa9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80130a:	83 c4 0c             	add    $0xc,%esp
  80130d:	6a 00                	push   $0x0
  80130f:	53                   	push   %ebx
  801310:	6a 00                	push   $0x0
  801312:	e8 3d 07 00 00       	call   801a54 <ipc_recv>
}
  801317:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5e                   	pop    %esi
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801324:	8b 45 08             	mov    0x8(%ebp),%eax
  801327:	8b 40 0c             	mov    0xc(%eax),%eax
  80132a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80132f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801332:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801337:	ba 00 00 00 00       	mov    $0x0,%edx
  80133c:	b8 02 00 00 00       	mov    $0x2,%eax
  801341:	e8 8d ff ff ff       	call   8012d3 <fsipc>
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
  801351:	8b 40 0c             	mov    0xc(%eax),%eax
  801354:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801359:	ba 00 00 00 00       	mov    $0x0,%edx
  80135e:	b8 06 00 00 00       	mov    $0x6,%eax
  801363:	e8 6b ff ff ff       	call   8012d3 <fsipc>
}
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	53                   	push   %ebx
  80136e:	83 ec 04             	sub    $0x4,%esp
  801371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801374:	8b 45 08             	mov    0x8(%ebp),%eax
  801377:	8b 40 0c             	mov    0xc(%eax),%eax
  80137a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80137f:	ba 00 00 00 00       	mov    $0x0,%edx
  801384:	b8 05 00 00 00       	mov    $0x5,%eax
  801389:	e8 45 ff ff ff       	call   8012d3 <fsipc>
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 2c                	js     8013be <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	68 00 50 80 00       	push   $0x805000
  80139a:	53                   	push   %ebx
  80139b:	e8 90 f3 ff ff       	call   800730 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a0:	a1 80 50 80 00       	mov    0x805080,%eax
  8013a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ab:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8013cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d2:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8013d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013dd:	ba 00 10 00 00       	mov    $0x1000,%edx
  8013e2:	0f 47 c2             	cmova  %edx,%eax
  8013e5:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013ea:	50                   	push   %eax
  8013eb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ee:	68 08 50 80 00       	push   $0x805008
  8013f3:	e8 ca f4 ff ff       	call   8008c2 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8013f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801402:	e8 cc fe ff ff       	call   8012d3 <fsipc>
    return r;
}
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	56                   	push   %esi
  80140d:	53                   	push   %ebx
  80140e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80141c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801422:	ba 00 00 00 00       	mov    $0x0,%edx
  801427:	b8 03 00 00 00       	mov    $0x3,%eax
  80142c:	e8 a2 fe ff ff       	call   8012d3 <fsipc>
  801431:	89 c3                	mov    %eax,%ebx
  801433:	85 c0                	test   %eax,%eax
  801435:	78 4b                	js     801482 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801437:	39 c6                	cmp    %eax,%esi
  801439:	73 16                	jae    801451 <devfile_read+0x48>
  80143b:	68 58 22 80 00       	push   $0x802258
  801440:	68 5f 22 80 00       	push   $0x80225f
  801445:	6a 7c                	push   $0x7c
  801447:	68 74 22 80 00       	push   $0x802274
  80144c:	e8 bd 05 00 00       	call   801a0e <_panic>
	assert(r <= PGSIZE);
  801451:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801456:	7e 16                	jle    80146e <devfile_read+0x65>
  801458:	68 7f 22 80 00       	push   $0x80227f
  80145d:	68 5f 22 80 00       	push   $0x80225f
  801462:	6a 7d                	push   $0x7d
  801464:	68 74 22 80 00       	push   $0x802274
  801469:	e8 a0 05 00 00       	call   801a0e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	50                   	push   %eax
  801472:	68 00 50 80 00       	push   $0x805000
  801477:	ff 75 0c             	pushl  0xc(%ebp)
  80147a:	e8 43 f4 ff ff       	call   8008c2 <memmove>
	return r;
  80147f:	83 c4 10             	add    $0x10,%esp
}
  801482:	89 d8                	mov    %ebx,%eax
  801484:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801487:	5b                   	pop    %ebx
  801488:	5e                   	pop    %esi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	83 ec 20             	sub    $0x20,%esp
  801492:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801495:	53                   	push   %ebx
  801496:	e8 5c f2 ff ff       	call   8006f7 <strlen>
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014a3:	7f 67                	jg     80150c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	e8 9a f8 ff ff       	call   800d4b <fd_alloc>
  8014b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 57                	js     801511 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	53                   	push   %ebx
  8014be:	68 00 50 80 00       	push   $0x805000
  8014c3:	e8 68 f2 ff ff       	call   800730 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d8:	e8 f6 fd ff ff       	call   8012d3 <fsipc>
  8014dd:	89 c3                	mov    %eax,%ebx
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	79 14                	jns    8014fa <open+0x6f>
		fd_close(fd, 0);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	6a 00                	push   $0x0
  8014eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ee:	e8 50 f9 ff ff       	call   800e43 <fd_close>
		return r;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	89 da                	mov    %ebx,%edx
  8014f8:	eb 17                	jmp    801511 <open+0x86>
	}

	return fd2num(fd);
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801500:	e8 1f f8 ff ff       	call   800d24 <fd2num>
  801505:	89 c2                	mov    %eax,%edx
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	eb 05                	jmp    801511 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80150c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801511:	89 d0                	mov    %edx,%eax
  801513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80151e:	ba 00 00 00 00       	mov    $0x0,%edx
  801523:	b8 08 00 00 00       	mov    $0x8,%eax
  801528:	e8 a6 fd ff ff       	call   8012d3 <fsipc>
}
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	56                   	push   %esi
  801533:	53                   	push   %ebx
  801534:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	ff 75 08             	pushl  0x8(%ebp)
  80153d:	e8 f2 f7 ff ff       	call   800d34 <fd2data>
  801542:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	68 8b 22 80 00       	push   $0x80228b
  80154c:	53                   	push   %ebx
  80154d:	e8 de f1 ff ff       	call   800730 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801552:	8b 46 04             	mov    0x4(%esi),%eax
  801555:	2b 06                	sub    (%esi),%eax
  801557:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80155d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801564:	00 00 00 
	stat->st_dev = &devpipe;
  801567:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80156e:	30 80 00 
	return 0;
}
  801571:	b8 00 00 00 00       	mov    $0x0,%eax
  801576:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801579:	5b                   	pop    %ebx
  80157a:	5e                   	pop    %esi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    

0080157d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 0c             	sub    $0xc,%esp
  801584:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801587:	53                   	push   %ebx
  801588:	6a 00                	push   $0x0
  80158a:	e8 29 f6 ff ff       	call   800bb8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80158f:	89 1c 24             	mov    %ebx,(%esp)
  801592:	e8 9d f7 ff ff       	call   800d34 <fd2data>
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	50                   	push   %eax
  80159b:	6a 00                	push   $0x0
  80159d:	e8 16 f6 ff ff       	call   800bb8 <sys_page_unmap>
}
  8015a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 1c             	sub    $0x1c,%esp
  8015b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015b3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ba:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c3:	e8 6e 05 00 00       	call   801b36 <pageref>
  8015c8:	89 c3                	mov    %eax,%ebx
  8015ca:	89 3c 24             	mov    %edi,(%esp)
  8015cd:	e8 64 05 00 00       	call   801b36 <pageref>
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	39 c3                	cmp    %eax,%ebx
  8015d7:	0f 94 c1             	sete   %cl
  8015da:	0f b6 c9             	movzbl %cl,%ecx
  8015dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015e0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015e6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015e9:	39 ce                	cmp    %ecx,%esi
  8015eb:	74 1b                	je     801608 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015ed:	39 c3                	cmp    %eax,%ebx
  8015ef:	75 c4                	jne    8015b5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f1:	8b 42 58             	mov    0x58(%edx),%eax
  8015f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f7:	50                   	push   %eax
  8015f8:	56                   	push   %esi
  8015f9:	68 92 22 80 00       	push   $0x802292
  8015fe:	e8 8a eb ff ff       	call   80018d <cprintf>
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	eb ad                	jmp    8015b5 <_pipeisclosed+0xe>
	}
}
  801608:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5f                   	pop    %edi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	57                   	push   %edi
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	83 ec 28             	sub    $0x28,%esp
  80161c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80161f:	56                   	push   %esi
  801620:	e8 0f f7 ff ff       	call   800d34 <fd2data>
  801625:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	bf 00 00 00 00       	mov    $0x0,%edi
  80162f:	eb 4b                	jmp    80167c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801631:	89 da                	mov    %ebx,%edx
  801633:	89 f0                	mov    %esi,%eax
  801635:	e8 6d ff ff ff       	call   8015a7 <_pipeisclosed>
  80163a:	85 c0                	test   %eax,%eax
  80163c:	75 48                	jne    801686 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80163e:	e8 d1 f4 ff ff       	call   800b14 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801643:	8b 43 04             	mov    0x4(%ebx),%eax
  801646:	8b 0b                	mov    (%ebx),%ecx
  801648:	8d 51 20             	lea    0x20(%ecx),%edx
  80164b:	39 d0                	cmp    %edx,%eax
  80164d:	73 e2                	jae    801631 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80164f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801652:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801656:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801659:	89 c2                	mov    %eax,%edx
  80165b:	c1 fa 1f             	sar    $0x1f,%edx
  80165e:	89 d1                	mov    %edx,%ecx
  801660:	c1 e9 1b             	shr    $0x1b,%ecx
  801663:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801666:	83 e2 1f             	and    $0x1f,%edx
  801669:	29 ca                	sub    %ecx,%edx
  80166b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80166f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801673:	83 c0 01             	add    $0x1,%eax
  801676:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801679:	83 c7 01             	add    $0x1,%edi
  80167c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80167f:	75 c2                	jne    801643 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801681:	8b 45 10             	mov    0x10(%ebp),%eax
  801684:	eb 05                	jmp    80168b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801686:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80168b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	57                   	push   %edi
  801697:	56                   	push   %esi
  801698:	53                   	push   %ebx
  801699:	83 ec 18             	sub    $0x18,%esp
  80169c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80169f:	57                   	push   %edi
  8016a0:	e8 8f f6 ff ff       	call   800d34 <fd2data>
  8016a5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016af:	eb 3d                	jmp    8016ee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016b1:	85 db                	test   %ebx,%ebx
  8016b3:	74 04                	je     8016b9 <devpipe_read+0x26>
				return i;
  8016b5:	89 d8                	mov    %ebx,%eax
  8016b7:	eb 44                	jmp    8016fd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016b9:	89 f2                	mov    %esi,%edx
  8016bb:	89 f8                	mov    %edi,%eax
  8016bd:	e8 e5 fe ff ff       	call   8015a7 <_pipeisclosed>
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	75 32                	jne    8016f8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016c6:	e8 49 f4 ff ff       	call   800b14 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016cb:	8b 06                	mov    (%esi),%eax
  8016cd:	3b 46 04             	cmp    0x4(%esi),%eax
  8016d0:	74 df                	je     8016b1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d2:	99                   	cltd   
  8016d3:	c1 ea 1b             	shr    $0x1b,%edx
  8016d6:	01 d0                	add    %edx,%eax
  8016d8:	83 e0 1f             	and    $0x1f,%eax
  8016db:	29 d0                	sub    %edx,%eax
  8016dd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016e8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016eb:	83 c3 01             	add    $0x1,%ebx
  8016ee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016f1:	75 d8                	jne    8016cb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f6:	eb 05                	jmp    8016fd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5f                   	pop    %edi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
  80170a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80170d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	e8 35 f6 ff ff       	call   800d4b <fd_alloc>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	89 c2                	mov    %eax,%edx
  80171b:	85 c0                	test   %eax,%eax
  80171d:	0f 88 2c 01 00 00    	js     80184f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801723:	83 ec 04             	sub    $0x4,%esp
  801726:	68 07 04 00 00       	push   $0x407
  80172b:	ff 75 f4             	pushl  -0xc(%ebp)
  80172e:	6a 00                	push   $0x0
  801730:	e8 fe f3 ff ff       	call   800b33 <sys_page_alloc>
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	89 c2                	mov    %eax,%edx
  80173a:	85 c0                	test   %eax,%eax
  80173c:	0f 88 0d 01 00 00    	js     80184f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801748:	50                   	push   %eax
  801749:	e8 fd f5 ff ff       	call   800d4b <fd_alloc>
  80174e:	89 c3                	mov    %eax,%ebx
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	0f 88 e2 00 00 00    	js     80183d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	68 07 04 00 00       	push   $0x407
  801763:	ff 75 f0             	pushl  -0x10(%ebp)
  801766:	6a 00                	push   $0x0
  801768:	e8 c6 f3 ff ff       	call   800b33 <sys_page_alloc>
  80176d:	89 c3                	mov    %eax,%ebx
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	0f 88 c3 00 00 00    	js     80183d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	ff 75 f4             	pushl  -0xc(%ebp)
  801780:	e8 af f5 ff ff       	call   800d34 <fd2data>
  801785:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801787:	83 c4 0c             	add    $0xc,%esp
  80178a:	68 07 04 00 00       	push   $0x407
  80178f:	50                   	push   %eax
  801790:	6a 00                	push   $0x0
  801792:	e8 9c f3 ff ff       	call   800b33 <sys_page_alloc>
  801797:	89 c3                	mov    %eax,%ebx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	0f 88 89 00 00 00    	js     80182d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017aa:	e8 85 f5 ff ff       	call   800d34 <fd2data>
  8017af:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017b6:	50                   	push   %eax
  8017b7:	6a 00                	push   $0x0
  8017b9:	56                   	push   %esi
  8017ba:	6a 00                	push   $0x0
  8017bc:	e8 b5 f3 ff ff       	call   800b76 <sys_page_map>
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	83 c4 20             	add    $0x20,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 55                	js     80181f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017ca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017df:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017f4:	83 ec 0c             	sub    $0xc,%esp
  8017f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fa:	e8 25 f5 ff ff       	call   800d24 <fd2num>
  8017ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801802:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801804:	83 c4 04             	add    $0x4,%esp
  801807:	ff 75 f0             	pushl  -0x10(%ebp)
  80180a:	e8 15 f5 ff ff       	call   800d24 <fd2num>
  80180f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801812:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	eb 30                	jmp    80184f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	56                   	push   %esi
  801823:	6a 00                	push   $0x0
  801825:	e8 8e f3 ff ff       	call   800bb8 <sys_page_unmap>
  80182a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	ff 75 f0             	pushl  -0x10(%ebp)
  801833:	6a 00                	push   $0x0
  801835:	e8 7e f3 ff ff       	call   800bb8 <sys_page_unmap>
  80183a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	ff 75 f4             	pushl  -0xc(%ebp)
  801843:	6a 00                	push   $0x0
  801845:	e8 6e f3 ff ff       	call   800bb8 <sys_page_unmap>
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80184f:	89 d0                	mov    %edx,%eax
  801851:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801854:	5b                   	pop    %ebx
  801855:	5e                   	pop    %esi
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801861:	50                   	push   %eax
  801862:	ff 75 08             	pushl  0x8(%ebp)
  801865:	e8 30 f5 ff ff       	call   800d9a <fd_lookup>
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 18                	js     801889 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	ff 75 f4             	pushl  -0xc(%ebp)
  801877:	e8 b8 f4 ff ff       	call   800d34 <fd2data>
	return _pipeisclosed(fd, p);
  80187c:	89 c2                	mov    %eax,%edx
  80187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801881:	e8 21 fd ff ff       	call   8015a7 <_pipeisclosed>
  801886:	83 c4 10             	add    $0x10,%esp
}
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80188e:	b8 00 00 00 00       	mov    $0x0,%eax
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80189b:	68 aa 22 80 00       	push   $0x8022aa
  8018a0:	ff 75 0c             	pushl  0xc(%ebp)
  8018a3:	e8 88 ee ff ff       	call   800730 <strcpy>
	return 0;
}
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	57                   	push   %edi
  8018b3:	56                   	push   %esi
  8018b4:	53                   	push   %ebx
  8018b5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018bb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c6:	eb 2d                	jmp    8018f5 <devcons_write+0x46>
		m = n - tot;
  8018c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018cb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018cd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018d0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018d5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d8:	83 ec 04             	sub    $0x4,%esp
  8018db:	53                   	push   %ebx
  8018dc:	03 45 0c             	add    0xc(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	57                   	push   %edi
  8018e1:	e8 dc ef ff ff       	call   8008c2 <memmove>
		sys_cputs(buf, m);
  8018e6:	83 c4 08             	add    $0x8,%esp
  8018e9:	53                   	push   %ebx
  8018ea:	57                   	push   %edi
  8018eb:	e8 87 f1 ff ff       	call   800a77 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f0:	01 de                	add    %ebx,%esi
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	89 f0                	mov    %esi,%eax
  8018f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018fa:	72 cc                	jb     8018c8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5f                   	pop    %edi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80190f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801913:	74 2a                	je     80193f <devcons_read+0x3b>
  801915:	eb 05                	jmp    80191c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801917:	e8 f8 f1 ff ff       	call   800b14 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80191c:	e8 74 f1 ff ff       	call   800a95 <sys_cgetc>
  801921:	85 c0                	test   %eax,%eax
  801923:	74 f2                	je     801917 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801925:	85 c0                	test   %eax,%eax
  801927:	78 16                	js     80193f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801929:	83 f8 04             	cmp    $0x4,%eax
  80192c:	74 0c                	je     80193a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80192e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801931:	88 02                	mov    %al,(%edx)
	return 1;
  801933:	b8 01 00 00 00       	mov    $0x1,%eax
  801938:	eb 05                	jmp    80193f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80194d:	6a 01                	push   $0x1
  80194f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801952:	50                   	push   %eax
  801953:	e8 1f f1 ff ff       	call   800a77 <sys_cputs>
}
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <getchar>:

int
getchar(void)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801963:	6a 01                	push   $0x1
  801965:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801968:	50                   	push   %eax
  801969:	6a 00                	push   $0x0
  80196b:	e8 90 f6 ff ff       	call   801000 <read>
	if (r < 0)
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	85 c0                	test   %eax,%eax
  801975:	78 0f                	js     801986 <getchar+0x29>
		return r;
	if (r < 1)
  801977:	85 c0                	test   %eax,%eax
  801979:	7e 06                	jle    801981 <getchar+0x24>
		return -E_EOF;
	return c;
  80197b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80197f:	eb 05                	jmp    801986 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801981:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801991:	50                   	push   %eax
  801992:	ff 75 08             	pushl  0x8(%ebp)
  801995:	e8 00 f4 ff ff       	call   800d9a <fd_lookup>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	78 11                	js     8019b2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019aa:	39 10                	cmp    %edx,(%eax)
  8019ac:	0f 94 c0             	sete   %al
  8019af:	0f b6 c0             	movzbl %al,%eax
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <opencons>:

int
opencons(void)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	e8 88 f3 ff ff       	call   800d4b <fd_alloc>
  8019c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 3e                	js     801a0a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	68 07 04 00 00       	push   $0x407
  8019d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d7:	6a 00                	push   $0x0
  8019d9:	e8 55 f1 ff ff       	call   800b33 <sys_page_alloc>
  8019de:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 23                	js     801a0a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019e7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	50                   	push   %eax
  801a00:	e8 1f f3 ff ff       	call   800d24 <fd2num>
  801a05:	89 c2                	mov    %eax,%edx
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	89 d0                	mov    %edx,%eax
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a13:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a16:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a1c:	e8 d4 f0 ff ff       	call   800af5 <sys_getenvid>
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	ff 75 0c             	pushl  0xc(%ebp)
  801a27:	ff 75 08             	pushl  0x8(%ebp)
  801a2a:	56                   	push   %esi
  801a2b:	50                   	push   %eax
  801a2c:	68 b8 22 80 00       	push   $0x8022b8
  801a31:	e8 57 e7 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a36:	83 c4 18             	add    $0x18,%esp
  801a39:	53                   	push   %ebx
  801a3a:	ff 75 10             	pushl  0x10(%ebp)
  801a3d:	e8 fa e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801a42:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a49:	e8 3f e7 ff ff       	call   80018d <cprintf>
  801a4e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a51:	cc                   	int3   
  801a52:	eb fd                	jmp    801a51 <_panic+0x43>

00801a54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801a62:	85 c0                	test   %eax,%eax
  801a64:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a69:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	50                   	push   %eax
  801a70:	e8 6e f2 ff ff       	call   800ce3 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	75 10                	jne    801a8c <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801a7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a81:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801a84:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801a87:	8b 40 70             	mov    0x70(%eax),%eax
  801a8a:	eb 0a                	jmp    801a96 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801a8c:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801a91:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801a96:	85 f6                	test   %esi,%esi
  801a98:	74 02                	je     801a9c <ipc_recv+0x48>
  801a9a:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801a9c:	85 db                	test   %ebx,%ebx
  801a9e:	74 02                	je     801aa2 <ipc_recv+0x4e>
  801aa0:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	57                   	push   %edi
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801abb:	85 db                	test   %ebx,%ebx
  801abd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ac2:	0f 44 d8             	cmove  %eax,%ebx
  801ac5:	eb 1c                	jmp    801ae3 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801ac7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aca:	74 12                	je     801ade <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801acc:	50                   	push   %eax
  801acd:	68 dc 22 80 00       	push   $0x8022dc
  801ad2:	6a 40                	push   $0x40
  801ad4:	68 ee 22 80 00       	push   $0x8022ee
  801ad9:	e8 30 ff ff ff       	call   801a0e <_panic>
        sys_yield();
  801ade:	e8 31 f0 ff ff       	call   800b14 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ae3:	ff 75 14             	pushl  0x14(%ebp)
  801ae6:	53                   	push   %ebx
  801ae7:	56                   	push   %esi
  801ae8:	57                   	push   %edi
  801ae9:	e8 d2 f1 ff ff       	call   800cc0 <sys_ipc_try_send>
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	85 c0                	test   %eax,%eax
  801af3:	75 d2                	jne    801ac7 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5f                   	pop    %edi
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b08:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b0b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b11:	8b 52 50             	mov    0x50(%edx),%edx
  801b14:	39 ca                	cmp    %ecx,%edx
  801b16:	75 0d                	jne    801b25 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b18:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b20:	8b 40 48             	mov    0x48(%eax),%eax
  801b23:	eb 0f                	jmp    801b34 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b25:	83 c0 01             	add    $0x1,%eax
  801b28:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2d:	75 d9                	jne    801b08 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3c:	89 d0                	mov    %edx,%eax
  801b3e:	c1 e8 16             	shr    $0x16,%eax
  801b41:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4d:	f6 c1 01             	test   $0x1,%cl
  801b50:	74 1d                	je     801b6f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b52:	c1 ea 0c             	shr    $0xc,%edx
  801b55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b5c:	f6 c2 01             	test   $0x1,%dl
  801b5f:	74 0e                	je     801b6f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b61:	c1 ea 0c             	shr    $0xc,%edx
  801b64:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b6b:	ef 
  801b6c:	0f b7 c0             	movzwl %ax,%eax
}
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    
  801b71:	66 90                	xchg   %ax,%ax
  801b73:	66 90                	xchg   %ax,%ax
  801b75:	66 90                	xchg   %ax,%ax
  801b77:	66 90                	xchg   %ax,%ax
  801b79:	66 90                	xchg   %ax,%ax
  801b7b:	66 90                	xchg   %ax,%ax
  801b7d:	66 90                	xchg   %ax,%ax
  801b7f:	90                   	nop

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
