
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 6c 11 00 00       	call   8011b9 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 c0 1f 80 00       	push   $0x801fc0
  800060:	6a 0d                	push   $0xd
  800062:	68 db 1f 80 00       	push   $0x801fdb
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 60 10 00 00       	call   8010df <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 e6 1f 80 00       	push   $0x801fe6
  800098:	6a 0f                	push   $0xf
  80009a:	68 db 1f 80 00       	push   $0x801fdb
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 fb 	movl   $0x801ffb,0x803000
  8000be:	1f 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 ff 1f 80 00       	push   $0x801fff
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 7d 14 00 00       	call   80156a <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 07 20 80 00       	push   $0x802007
  800102:	e8 01 16 00 00       	call   801708 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 83 0e 00 00       	call   800fa3 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 91 0a 00 00       	call   800bd4 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 4a 0e 00 00       	call   800fce <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 05 0a 00 00       	call   800b93 <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 2e 0a 00 00       	call   800bd4 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 24 20 80 00       	push   $0x802024
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 47 24 80 00 	movl   $0x802447,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 4d 09 00 00       	call   800b56 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 54 01 00 00       	call   8003a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 f2 08 00 00       	call   800b56 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 4c 1a 00 00       	call   801d20 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 39 1b 00 00       	call   801e50 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 47 20 80 00 	movsbl 0x802047(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800332:	83 fa 01             	cmp    $0x1,%edx
  800335:	7e 0e                	jle    800345 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	8b 52 04             	mov    0x4(%edx),%edx
  800343:	eb 22                	jmp    800367 <getuint+0x38>
	else if (lflag)
  800345:	85 d2                	test   %edx,%edx
  800347:	74 10                	je     800359 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 0e                	jmp    800367 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 0a                	jae    800384 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	88 02                	mov    %al,(%edx)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 05 00 00 00       	call   8003a3 <vprintfmt>
	va_end(ap);
}
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 a7 03 00 00    	je     800766 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	50                   	push   %eax
  8003c4:	ff d6                	call   *%esi
  8003c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	83 c7 01             	add    $0x1,%edi
  8003cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d0:	83 f8 25             	cmp    $0x25,%eax
  8003d3:	75 e2                	jne    8003b7 <vprintfmt+0x14>
  8003d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ee:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	eb 07                	jmp    800403 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8d 47 01             	lea    0x1(%edi),%eax
  800406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800409:	0f b6 07             	movzbl (%edi),%eax
  80040c:	0f b6 d0             	movzbl %al,%edx
  80040f:	83 e8 23             	sub    $0x23,%eax
  800412:	3c 55                	cmp    $0x55,%al
  800414:	0f 87 31 03 00 00    	ja     80074b <vprintfmt+0x3a8>
  80041a:	0f b6 c0             	movzbl %al,%eax
  80041d:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800427:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042b:	eb d6                	jmp    800403 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800430:	b8 00 00 00 00       	mov    $0x0,%eax
  800435:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800438:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80043f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800442:	8d 72 d0             	lea    -0x30(%edx),%esi
  800445:	83 fe 09             	cmp    $0x9,%esi
  800448:	77 34                	ja     80047e <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80044d:	eb e9                	jmp    800438 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800460:	eb 22                	jmp    800484 <vprintfmt+0xe1>
  800462:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800465:	85 c0                	test   %eax,%eax
  800467:	0f 48 c1             	cmovs  %ecx,%eax
  80046a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800470:	eb 91                	jmp    800403 <vprintfmt+0x60>
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800475:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047c:	eb 85                	jmp    800403 <vprintfmt+0x60>
  80047e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800481:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800484:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800488:	0f 89 75 ff ff ff    	jns    800403 <vprintfmt+0x60>
				width = precision, precision = -1;
  80048e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800491:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800494:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80049b:	e9 63 ff ff ff       	jmp    800403 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a0:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a7:	e9 57 ff ff ff       	jmp    800403 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	53                   	push   %ebx
  8004b9:	ff 30                	pushl  (%eax)
  8004bb:	ff d6                	call   *%esi
			break;
  8004bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c3:	e9 01 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	99                   	cltd   
  8004d4:	31 d0                	xor    %edx,%eax
  8004d6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d8:	83 f8 0f             	cmp    $0xf,%eax
  8004db:	7f 0b                	jg     8004e8 <vprintfmt+0x145>
  8004dd:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	75 18                	jne    800500 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8004e8:	50                   	push   %eax
  8004e9:	68 5f 20 80 00       	push   $0x80205f
  8004ee:	53                   	push   %ebx
  8004ef:	56                   	push   %esi
  8004f0:	e8 91 fe ff ff       	call   800386 <printfmt>
  8004f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004fb:	e9 c9 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800500:	52                   	push   %edx
  800501:	68 15 24 80 00       	push   $0x802415
  800506:	53                   	push   %ebx
  800507:	56                   	push   %esi
  800508:	e8 79 fe ff ff       	call   800386 <printfmt>
  80050d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800513:	e9 b1 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 04             	lea    0x4(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800523:	85 ff                	test   %edi,%edi
  800525:	b8 58 20 80 00       	mov    $0x802058,%eax
  80052a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800531:	0f 8e 94 00 00 00    	jle    8005cb <vprintfmt+0x228>
  800537:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80053b:	0f 84 98 00 00 00    	je     8005d9 <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	ff 75 cc             	pushl  -0x34(%ebp)
  800547:	57                   	push   %edi
  800548:	e8 a1 02 00 00       	call   8007ee <strnlen>
  80054d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800550:	29 c1                	sub    %eax,%ecx
  800552:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800555:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800558:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800562:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	eb 0f                	jmp    800575 <vprintfmt+0x1d2>
					putch(padc, putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	ff 75 e0             	pushl  -0x20(%ebp)
  80056d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	83 ef 01             	sub    $0x1,%edi
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 ff                	test   %edi,%edi
  800577:	7f ed                	jg     800566 <vprintfmt+0x1c3>
  800579:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80057f:	85 c9                	test   %ecx,%ecx
  800581:	b8 00 00 00 00       	mov    $0x0,%eax
  800586:	0f 49 c1             	cmovns %ecx,%eax
  800589:	29 c1                	sub    %eax,%ecx
  80058b:	89 75 08             	mov    %esi,0x8(%ebp)
  80058e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800591:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800594:	89 cb                	mov    %ecx,%ebx
  800596:	eb 4d                	jmp    8005e5 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800598:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059c:	74 1b                	je     8005b9 <vprintfmt+0x216>
  80059e:	0f be c0             	movsbl %al,%eax
  8005a1:	83 e8 20             	sub    $0x20,%eax
  8005a4:	83 f8 5e             	cmp    $0x5e,%eax
  8005a7:	76 10                	jbe    8005b9 <vprintfmt+0x216>
					putch('?', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	ff 75 0c             	pushl  0xc(%ebp)
  8005af:	6a 3f                	push   $0x3f
  8005b1:	ff 55 08             	call   *0x8(%ebp)
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb 0d                	jmp    8005c6 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	ff 75 0c             	pushl  0xc(%ebp)
  8005bf:	52                   	push   %edx
  8005c0:	ff 55 08             	call   *0x8(%ebp)
  8005c3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c6:	83 eb 01             	sub    $0x1,%ebx
  8005c9:	eb 1a                	jmp    8005e5 <vprintfmt+0x242>
  8005cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ce:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d7:	eb 0c                	jmp    8005e5 <vprintfmt+0x242>
  8005d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dc:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e5:	83 c7 01             	add    $0x1,%edi
  8005e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ec:	0f be d0             	movsbl %al,%edx
  8005ef:	85 d2                	test   %edx,%edx
  8005f1:	74 23                	je     800616 <vprintfmt+0x273>
  8005f3:	85 f6                	test   %esi,%esi
  8005f5:	78 a1                	js     800598 <vprintfmt+0x1f5>
  8005f7:	83 ee 01             	sub    $0x1,%esi
  8005fa:	79 9c                	jns    800598 <vprintfmt+0x1f5>
  8005fc:	89 df                	mov    %ebx,%edi
  8005fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800604:	eb 18                	jmp    80061e <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 20                	push   $0x20
  80060c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	83 ef 01             	sub    $0x1,%edi
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	eb 08                	jmp    80061e <vprintfmt+0x27b>
  800616:	89 df                	mov    %ebx,%edi
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	85 ff                	test   %edi,%edi
  800620:	7f e4                	jg     800606 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800625:	e9 9f fd ff ff       	jmp    8003c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062a:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80062e:	7e 16                	jle    800646 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 08             	lea    0x8(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	8b 50 04             	mov    0x4(%eax),%edx
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800644:	eb 34                	jmp    80067a <vprintfmt+0x2d7>
	else if (lflag)
  800646:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80064a:	74 18                	je     800664 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065a:	89 c1                	mov    %eax,%ecx
  80065c:	c1 f9 1f             	sar    $0x1f,%ecx
  80065f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800662:	eb 16                	jmp    80067a <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	89 c1                	mov    %eax,%ecx
  800674:	c1 f9 1f             	sar    $0x1f,%ecx
  800677:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80067d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800680:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800685:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800689:	0f 89 88 00 00 00    	jns    800717 <vprintfmt+0x374>
				putch('-', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 2d                	push   $0x2d
  800695:	ff d6                	call   *%esi
				num = -(long long) num;
  800697:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069d:	f7 d8                	neg    %eax
  80069f:	83 d2 00             	adc    $0x0,%edx
  8006a2:	f7 da                	neg    %edx
  8006a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ac:	eb 69                	jmp    800717 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ae:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 76 fc ff ff       	call   80032f <getuint>
			base = 10;
  8006b9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006be:	eb 57                	jmp    800717 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	6a 30                	push   $0x30
  8006c6:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8006c8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 5c fc ff ff       	call   80032f <getuint>
			base = 8;
			goto number;
  8006d3:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8006d6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006db:	eb 3a                	jmp    800717 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 30                	push   $0x30
  8006e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e5:	83 c4 08             	add    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	6a 78                	push   $0x78
  8006eb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 50 04             	lea    0x4(%eax),%edx
  8006f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f6:	8b 00                	mov    (%eax),%eax
  8006f8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006fd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800700:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800705:	eb 10                	jmp    800717 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800707:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
  80070d:	e8 1d fc ff ff       	call   80032f <getuint>
			base = 16;
  800712:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800717:	83 ec 0c             	sub    $0xc,%esp
  80071a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80071e:	57                   	push   %edi
  80071f:	ff 75 e0             	pushl  -0x20(%ebp)
  800722:	51                   	push   %ecx
  800723:	52                   	push   %edx
  800724:	50                   	push   %eax
  800725:	89 da                	mov    %ebx,%edx
  800727:	89 f0                	mov    %esi,%eax
  800729:	e8 52 fb ff ff       	call   800280 <printnum>
			break;
  80072e:	83 c4 20             	add    $0x20,%esp
  800731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800734:	e9 90 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	52                   	push   %edx
  80073e:	ff d6                	call   *%esi
			break;
  800740:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800746:	e9 7e fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 25                	push   $0x25
  800751:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 03                	jmp    80075b <vprintfmt+0x3b8>
  800758:	83 ef 01             	sub    $0x1,%edi
  80075b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80075f:	75 f7                	jne    800758 <vprintfmt+0x3b5>
  800761:	e9 63 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 18             	sub    $0x18,%esp
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800781:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078b:	85 c0                	test   %eax,%eax
  80078d:	74 26                	je     8007b5 <vsnprintf+0x47>
  80078f:	85 d2                	test   %edx,%edx
  800791:	7e 22                	jle    8007b5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800793:	ff 75 14             	pushl  0x14(%ebp)
  800796:	ff 75 10             	pushl  0x10(%ebp)
  800799:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079c:	50                   	push   %eax
  80079d:	68 69 03 80 00       	push   $0x800369
  8007a2:	e8 fc fb ff ff       	call   8003a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	eb 05                	jmp    8007ba <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c5:	50                   	push   %eax
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	ff 75 08             	pushl  0x8(%ebp)
  8007cf:	e8 9a ff ff ff       	call   80076e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 03                	jmp    8007e6 <strlen+0x10>
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ea:	75 f7                	jne    8007e3 <strlen+0xd>
		n++;
	return n;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fc:	eb 03                	jmp    800801 <strnlen+0x13>
		n++;
  8007fe:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	39 c2                	cmp    %eax,%edx
  800803:	74 08                	je     80080d <strnlen+0x1f>
  800805:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800809:	75 f3                	jne    8007fe <strnlen+0x10>
  80080b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	89 c2                	mov    %eax,%edx
  80081b:	83 c2 01             	add    $0x1,%edx
  80081e:	83 c1 01             	add    $0x1,%ecx
  800821:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
  800828:	84 db                	test   %bl,%bl
  80082a:	75 ef                	jne    80081b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	53                   	push   %ebx
  800837:	e8 9a ff ff ff       	call   8007d6 <strlen>
  80083c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	01 d8                	add    %ebx,%eax
  800844:	50                   	push   %eax
  800845:	e8 c5 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084a:	89 d8                	mov    %ebx,%eax
  80084c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	89 f3                	mov    %esi,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	89 f2                	mov    %esi,%edx
  800863:	eb 0f                	jmp    800874 <strncpy+0x23>
		*dst++ = *src;
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	0f b6 01             	movzbl (%ecx),%eax
  80086b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086e:	80 39 01             	cmpb   $0x1,(%ecx)
  800871:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	39 da                	cmp    %ebx,%edx
  800876:	75 ed                	jne    800865 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800878:	89 f0                	mov    %esi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	8b 55 10             	mov    0x10(%ebp),%edx
  80088c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	74 21                	je     8008b3 <strlcpy+0x35>
  800892:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800896:	89 f2                	mov    %esi,%edx
  800898:	eb 09                	jmp    8008a3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089a:	83 c2 01             	add    $0x1,%edx
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a3:	39 c2                	cmp    %eax,%edx
  8008a5:	74 09                	je     8008b0 <strlcpy+0x32>
  8008a7:	0f b6 19             	movzbl (%ecx),%ebx
  8008aa:	84 db                	test   %bl,%bl
  8008ac:	75 ec                	jne    80089a <strlcpy+0x1c>
  8008ae:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b3:	29 f0                	sub    %esi,%eax
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c2:	eb 06                	jmp    8008ca <strcmp+0x11>
		p++, q++;
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 04                	je     8008d5 <strcmp+0x1c>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	74 ef                	je     8008c4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d5:	0f b6 c0             	movzbl %al,%eax
  8008d8:	0f b6 12             	movzbl (%edx),%edx
  8008db:	29 d0                	sub    %edx,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ee:	eb 06                	jmp    8008f6 <strncmp+0x17>
		n--, p++, q++;
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 15                	je     80090f <strncmp+0x30>
  8008fa:	0f b6 08             	movzbl (%eax),%ecx
  8008fd:	84 c9                	test   %cl,%cl
  8008ff:	74 04                	je     800905 <strncmp+0x26>
  800901:	3a 0a                	cmp    (%edx),%cl
  800903:	74 eb                	je     8008f0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800905:	0f b6 00             	movzbl (%eax),%eax
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	29 d0                	sub    %edx,%eax
  80090d:	eb 05                	jmp    800914 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800921:	eb 07                	jmp    80092a <strchr+0x13>
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 0f                	je     800936 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
  80092d:	84 d2                	test   %dl,%dl
  80092f:	75 f2                	jne    800923 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800942:	eb 03                	jmp    800947 <strfind+0xf>
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 04                	je     800952 <strfind+0x1a>
  80094e:	84 d2                	test   %dl,%dl
  800950:	75 f2                	jne    800944 <strfind+0xc>
			break;
	return (char *) s;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800960:	85 c9                	test   %ecx,%ecx
  800962:	74 36                	je     80099a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800964:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096a:	75 28                	jne    800994 <memset+0x40>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 23                	jne    800994 <memset+0x40>
		c &= 0xFF;
  800971:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d3                	mov    %edx,%ebx
  800977:	c1 e3 08             	shl    $0x8,%ebx
  80097a:	89 d6                	mov    %edx,%esi
  80097c:	c1 e6 18             	shl    $0x18,%esi
  80097f:	89 d0                	mov    %edx,%eax
  800981:	c1 e0 10             	shl    $0x10,%eax
  800984:	09 f0                	or     %esi,%eax
  800986:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800988:	89 d8                	mov    %ebx,%eax
  80098a:	09 d0                	or     %edx,%eax
  80098c:	c1 e9 02             	shr    $0x2,%ecx
  80098f:	fc                   	cld    
  800990:	f3 ab                	rep stos %eax,%es:(%edi)
  800992:	eb 06                	jmp    80099a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	fc                   	cld    
  800998:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099a:	89 f8                	mov    %edi,%eax
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009af:	39 c6                	cmp    %eax,%esi
  8009b1:	73 35                	jae    8009e8 <memmove+0x47>
  8009b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	73 2e                	jae    8009e8 <memmove+0x47>
		s += n;
		d += n;
  8009ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	09 fe                	or     %edi,%esi
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 13                	jne    8009dc <memmove+0x3b>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 0e                	jne    8009dc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 09                	jmp    8009e5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009dc:	83 ef 01             	sub    $0x1,%edi
  8009df:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e2:	fd                   	std    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e5:	fc                   	cld    
  8009e6:	eb 1d                	jmp    800a05 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	89 f2                	mov    %esi,%edx
  8009ea:	09 c2                	or     %eax,%edx
  8009ec:	f6 c2 03             	test   $0x3,%dl
  8009ef:	75 0f                	jne    800a00 <memmove+0x5f>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 0a                	jne    800a00 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f6:	c1 e9 02             	shr    $0x2,%ecx
  8009f9:	89 c7                	mov    %eax,%edi
  8009fb:	fc                   	cld    
  8009fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fe:	eb 05                	jmp    800a05 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a00:	89 c7                	mov    %eax,%edi
  800a02:	fc                   	cld    
  800a03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a05:	5e                   	pop    %esi
  800a06:	5f                   	pop    %edi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0c:	ff 75 10             	pushl  0x10(%ebp)
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	ff 75 08             	pushl  0x8(%ebp)
  800a15:	e8 87 ff ff ff       	call   8009a1 <memmove>
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a27:	89 c6                	mov    %eax,%esi
  800a29:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	eb 1a                	jmp    800a48 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2e:	0f b6 08             	movzbl (%eax),%ecx
  800a31:	0f b6 1a             	movzbl (%edx),%ebx
  800a34:	38 d9                	cmp    %bl,%cl
  800a36:	74 0a                	je     800a42 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a38:	0f b6 c1             	movzbl %cl,%eax
  800a3b:	0f b6 db             	movzbl %bl,%ebx
  800a3e:	29 d8                	sub    %ebx,%eax
  800a40:	eb 0f                	jmp    800a51 <memcmp+0x35>
		s1++, s2++;
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a48:	39 f0                	cmp    %esi,%eax
  800a4a:	75 e2                	jne    800a2e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	53                   	push   %ebx
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5c:	89 c1                	mov    %eax,%ecx
  800a5e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	eb 0a                	jmp    800a71 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	0f b6 10             	movzbl (%eax),%edx
  800a6a:	39 da                	cmp    %ebx,%edx
  800a6c:	74 07                	je     800a75 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	39 c8                	cmp    %ecx,%eax
  800a73:	72 f2                	jb     800a67 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a84:	eb 03                	jmp    800a89 <strtol+0x11>
		s++;
  800a86:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	3c 20                	cmp    $0x20,%al
  800a8e:	74 f6                	je     800a86 <strtol+0xe>
  800a90:	3c 09                	cmp    $0x9,%al
  800a92:	74 f2                	je     800a86 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a94:	3c 2b                	cmp    $0x2b,%al
  800a96:	75 0a                	jne    800aa2 <strtol+0x2a>
		s++;
  800a98:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa0:	eb 11                	jmp    800ab3 <strtol+0x3b>
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa7:	3c 2d                	cmp    $0x2d,%al
  800aa9:	75 08                	jne    800ab3 <strtol+0x3b>
		s++, neg = 1;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab9:	75 15                	jne    800ad0 <strtol+0x58>
  800abb:	80 39 30             	cmpb   $0x30,(%ecx)
  800abe:	75 10                	jne    800ad0 <strtol+0x58>
  800ac0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac4:	75 7c                	jne    800b42 <strtol+0xca>
		s += 2, base = 16;
  800ac6:	83 c1 02             	add    $0x2,%ecx
  800ac9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ace:	eb 16                	jmp    800ae6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	75 12                	jne    800ae6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad9:	80 39 30             	cmpb   $0x30,(%ecx)
  800adc:	75 08                	jne    800ae6 <strtol+0x6e>
		s++, base = 8;
  800ade:	83 c1 01             	add    $0x1,%ecx
  800ae1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aee:	0f b6 11             	movzbl (%ecx),%edx
  800af1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 09             	cmp    $0x9,%bl
  800af9:	77 08                	ja     800b03 <strtol+0x8b>
			dig = *s - '0';
  800afb:	0f be d2             	movsbl %dl,%edx
  800afe:	83 ea 30             	sub    $0x30,%edx
  800b01:	eb 22                	jmp    800b25 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 08                	ja     800b15 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 57             	sub    $0x57,%edx
  800b13:	eb 10                	jmp    800b25 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b15:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 16                	ja     800b35 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b1f:	0f be d2             	movsbl %dl,%edx
  800b22:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b25:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b28:	7d 0b                	jge    800b35 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b31:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b33:	eb b9                	jmp    800aee <strtol+0x76>

	if (endptr)
  800b35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b39:	74 0d                	je     800b48 <strtol+0xd0>
		*endptr = (char *) s;
  800b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3e:	89 0e                	mov    %ecx,(%esi)
  800b40:	eb 06                	jmp    800b48 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b42:	85 db                	test   %ebx,%ebx
  800b44:	74 98                	je     800ade <strtol+0x66>
  800b46:	eb 9e                	jmp    800ae6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b48:	89 c2                	mov    %eax,%edx
  800b4a:	f7 da                	neg    %edx
  800b4c:	85 ff                	test   %edi,%edi
  800b4e:	0f 45 c2             	cmovne %edx,%eax
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 c3                	mov    %eax,%ebx
  800b69:	89 c7                	mov    %eax,%edi
  800b6b:	89 c6                	mov    %eax,%esi
  800b6d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 cb                	mov    %ecx,%ebx
  800bab:	89 cf                	mov    %ecx,%edi
  800bad:	89 ce                	mov    %ecx,%esi
  800baf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 17                	jle    800bcc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 03                	push   $0x3
  800bbb:	68 3f 23 80 00       	push   $0x80233f
  800bc0:	6a 23                	push   $0x23
  800bc2:	68 5c 23 80 00       	push   $0x80235c
  800bc7:	e8 c7 f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 02 00 00 00       	mov    $0x2,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_yield>:

void
sys_yield(void)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c03:	89 d1                	mov    %edx,%ecx
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	89 d7                	mov    %edx,%edi
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	be 00 00 00 00       	mov    $0x0,%esi
  800c20:	b8 04 00 00 00       	mov    $0x4,%eax
  800c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2e:	89 f7                	mov    %esi,%edi
  800c30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 04                	push   $0x4
  800c3c:	68 3f 23 80 00       	push   $0x80233f
  800c41:	6a 23                	push   $0x23
  800c43:	68 5c 23 80 00       	push   $0x80235c
  800c48:	e8 46 f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 05                	push   $0x5
  800c7e:	68 3f 23 80 00       	push   $0x80233f
  800c83:	6a 23                	push   $0x23
  800c85:	68 5c 23 80 00       	push   $0x80235c
  800c8a:	e8 04 f5 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	b8 06 00 00 00       	mov    $0x6,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 06                	push   $0x6
  800cc0:	68 3f 23 80 00       	push   $0x80233f
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 5c 23 80 00       	push   $0x80235c
  800ccc:	e8 c2 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 17                	jle    800d13 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 08                	push   $0x8
  800d02:	68 3f 23 80 00       	push   $0x80233f
  800d07:	6a 23                	push   $0x23
  800d09:	68 5c 23 80 00       	push   $0x80235c
  800d0e:	e8 80 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d29:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 df                	mov    %ebx,%edi
  800d36:	89 de                	mov    %ebx,%esi
  800d38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 17                	jle    800d55 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 09                	push   $0x9
  800d44:	68 3f 23 80 00       	push   $0x80233f
  800d49:	6a 23                	push   $0x23
  800d4b:	68 5c 23 80 00       	push   $0x80235c
  800d50:	e8 3e f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 df                	mov    %ebx,%edi
  800d78:	89 de                	mov    %ebx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0a                	push   $0xa
  800d86:	68 3f 23 80 00       	push   $0x80233f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 5c 23 80 00       	push   $0x80235c
  800d92:	e8 fc f3 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	be 00 00 00 00       	mov    $0x0,%esi
  800daa:	b8 0c 00 00 00       	mov    $0xc,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 cb                	mov    %ecx,%ebx
  800dda:	89 cf                	mov    %ecx,%edi
  800ddc:	89 ce                	mov    %ecx,%esi
  800dde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 17                	jle    800dfb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	50                   	push   %eax
  800de8:	6a 0d                	push   $0xd
  800dea:	68 3f 23 80 00       	push   $0x80233f
  800def:	6a 23                	push   $0x23
  800df1:	68 5c 23 80 00       	push   $0x80235c
  800df6:	e8 98 f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e23:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e30:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	c1 ea 16             	shr    $0x16,%edx
  800e3a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e41:	f6 c2 01             	test   $0x1,%dl
  800e44:	74 11                	je     800e57 <fd_alloc+0x2d>
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	c1 ea 0c             	shr    $0xc,%edx
  800e4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e52:	f6 c2 01             	test   $0x1,%dl
  800e55:	75 09                	jne    800e60 <fd_alloc+0x36>
			*fd_store = fd;
  800e57:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5e:	eb 17                	jmp    800e77 <fd_alloc+0x4d>
  800e60:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e65:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e6a:	75 c9                	jne    800e35 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e72:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e7f:	83 f8 1f             	cmp    $0x1f,%eax
  800e82:	77 36                	ja     800eba <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e84:	c1 e0 0c             	shl    $0xc,%eax
  800e87:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8c:	89 c2                	mov    %eax,%edx
  800e8e:	c1 ea 16             	shr    $0x16,%edx
  800e91:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e98:	f6 c2 01             	test   $0x1,%dl
  800e9b:	74 24                	je     800ec1 <fd_lookup+0x48>
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	c1 ea 0c             	shr    $0xc,%edx
  800ea2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea9:	f6 c2 01             	test   $0x1,%dl
  800eac:	74 1a                	je     800ec8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb1:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	eb 13                	jmp    800ecd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebf:	eb 0c                	jmp    800ecd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec6:	eb 05                	jmp    800ecd <fd_lookup+0x54>
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed8:	ba ec 23 80 00       	mov    $0x8023ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edd:	eb 13                	jmp    800ef2 <dev_lookup+0x23>
  800edf:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee2:	39 08                	cmp    %ecx,(%eax)
  800ee4:	75 0c                	jne    800ef2 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef0:	eb 2e                	jmp    800f20 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef2:	8b 02                	mov    (%edx),%eax
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	75 e7                	jne    800edf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef8:	a1 20 60 80 00       	mov    0x806020,%eax
  800efd:	8b 40 48             	mov    0x48(%eax),%eax
  800f00:	83 ec 04             	sub    $0x4,%esp
  800f03:	51                   	push   %ecx
  800f04:	50                   	push   %eax
  800f05:	68 6c 23 80 00       	push   $0x80236c
  800f0a:	e8 5d f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	83 ec 10             	sub    $0x10,%esp
  800f2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f33:	50                   	push   %eax
  800f34:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f3a:	c1 e8 0c             	shr    $0xc,%eax
  800f3d:	50                   	push   %eax
  800f3e:	e8 36 ff ff ff       	call   800e79 <fd_lookup>
  800f43:	83 c4 08             	add    $0x8,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 05                	js     800f4f <fd_close+0x2d>
	    || fd != fd2)
  800f4a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4d:	74 0c                	je     800f5b <fd_close+0x39>
		return (must_exist ? r : 0);
  800f4f:	84 db                	test   %bl,%bl
  800f51:	ba 00 00 00 00       	mov    $0x0,%edx
  800f56:	0f 44 c2             	cmove  %edx,%eax
  800f59:	eb 41                	jmp    800f9c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	ff 36                	pushl  (%esi)
  800f64:	e8 66 ff ff ff       	call   800ecf <dev_lookup>
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 1a                	js     800f8c <fd_close+0x6a>
		if (dev->dev_close)
  800f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f75:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f78:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	74 0b                	je     800f8c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	56                   	push   %esi
  800f85:	ff d0                	call   *%eax
  800f87:	89 c3                	mov    %eax,%ebx
  800f89:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8c:	83 ec 08             	sub    $0x8,%esp
  800f8f:	56                   	push   %esi
  800f90:	6a 00                	push   $0x0
  800f92:	e8 00 fd ff ff       	call   800c97 <sys_page_unmap>
	return r;
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	89 d8                	mov    %ebx,%eax
}
  800f9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	ff 75 08             	pushl  0x8(%ebp)
  800fb0:	e8 c4 fe ff ff       	call   800e79 <fd_lookup>
  800fb5:	83 c4 08             	add    $0x8,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 10                	js     800fcc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	6a 01                	push   $0x1
  800fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc4:	e8 59 ff ff ff       	call   800f22 <fd_close>
  800fc9:	83 c4 10             	add    $0x10,%esp
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <close_all>:

void
close_all(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	53                   	push   %ebx
  800fde:	e8 c0 ff ff ff       	call   800fa3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe3:	83 c3 01             	add    $0x1,%ebx
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	83 fb 20             	cmp    $0x20,%ebx
  800fec:	75 ec                	jne    800fda <close_all+0xc>
		close(i);
}
  800fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 2c             	sub    $0x2c,%esp
  800ffc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 75 08             	pushl  0x8(%ebp)
  801006:	e8 6e fe ff ff       	call   800e79 <fd_lookup>
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	0f 88 c1 00 00 00    	js     8010d7 <dup+0xe4>
		return r;
	close(newfdnum);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	56                   	push   %esi
  80101a:	e8 84 ff ff ff       	call   800fa3 <close>

	newfd = INDEX2FD(newfdnum);
  80101f:	89 f3                	mov    %esi,%ebx
  801021:	c1 e3 0c             	shl    $0xc,%ebx
  801024:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80102a:	83 c4 04             	add    $0x4,%esp
  80102d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801030:	e8 de fd ff ff       	call   800e13 <fd2data>
  801035:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801037:	89 1c 24             	mov    %ebx,(%esp)
  80103a:	e8 d4 fd ff ff       	call   800e13 <fd2data>
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801045:	89 f8                	mov    %edi,%eax
  801047:	c1 e8 16             	shr    $0x16,%eax
  80104a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801051:	a8 01                	test   $0x1,%al
  801053:	74 37                	je     80108c <dup+0x99>
  801055:	89 f8                	mov    %edi,%eax
  801057:	c1 e8 0c             	shr    $0xc,%eax
  80105a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801061:	f6 c2 01             	test   $0x1,%dl
  801064:	74 26                	je     80108c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801066:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	25 07 0e 00 00       	and    $0xe07,%eax
  801075:	50                   	push   %eax
  801076:	ff 75 d4             	pushl  -0x2c(%ebp)
  801079:	6a 00                	push   $0x0
  80107b:	57                   	push   %edi
  80107c:	6a 00                	push   $0x0
  80107e:	e8 d2 fb ff ff       	call   800c55 <sys_page_map>
  801083:	89 c7                	mov    %eax,%edi
  801085:	83 c4 20             	add    $0x20,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 2e                	js     8010ba <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80108f:	89 d0                	mov    %edx,%eax
  801091:	c1 e8 0c             	shr    $0xc,%eax
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	53                   	push   %ebx
  8010a5:	6a 00                	push   $0x0
  8010a7:	52                   	push   %edx
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 a6 fb ff ff       	call   800c55 <sys_page_map>
  8010af:	89 c7                	mov    %eax,%edi
  8010b1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b6:	85 ff                	test   %edi,%edi
  8010b8:	79 1d                	jns    8010d7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	53                   	push   %ebx
  8010be:	6a 00                	push   $0x0
  8010c0:	e8 d2 fb ff ff       	call   800c97 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c5:	83 c4 08             	add    $0x8,%esp
  8010c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 c5 fb ff ff       	call   800c97 <sys_page_unmap>
	return r;
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	89 f8                	mov    %edi,%eax
}
  8010d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 14             	sub    $0x14,%esp
  8010e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	53                   	push   %ebx
  8010ee:	e8 86 fd ff ff       	call   800e79 <fd_lookup>
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 6d                	js     801169 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801102:	50                   	push   %eax
  801103:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801106:	ff 30                	pushl  (%eax)
  801108:	e8 c2 fd ff ff       	call   800ecf <dev_lookup>
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	78 4c                	js     801160 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801114:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801117:	8b 42 08             	mov    0x8(%edx),%eax
  80111a:	83 e0 03             	and    $0x3,%eax
  80111d:	83 f8 01             	cmp    $0x1,%eax
  801120:	75 21                	jne    801143 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801122:	a1 20 60 80 00       	mov    0x806020,%eax
  801127:	8b 40 48             	mov    0x48(%eax),%eax
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	53                   	push   %ebx
  80112e:	50                   	push   %eax
  80112f:	68 b0 23 80 00       	push   $0x8023b0
  801134:	e8 33 f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801141:	eb 26                	jmp    801169 <read+0x8a>
	}
	if (!dev->dev_read)
  801143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801146:	8b 40 08             	mov    0x8(%eax),%eax
  801149:	85 c0                	test   %eax,%eax
  80114b:	74 17                	je     801164 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	ff 75 10             	pushl  0x10(%ebp)
  801153:	ff 75 0c             	pushl  0xc(%ebp)
  801156:	52                   	push   %edx
  801157:	ff d0                	call   *%eax
  801159:	89 c2                	mov    %eax,%edx
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	eb 09                	jmp    801169 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801160:	89 c2                	mov    %eax,%edx
  801162:	eb 05                	jmp    801169 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801164:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801169:	89 d0                	mov    %edx,%eax
  80116b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801184:	eb 21                	jmp    8011a7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	89 f0                	mov    %esi,%eax
  80118b:	29 d8                	sub    %ebx,%eax
  80118d:	50                   	push   %eax
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	03 45 0c             	add    0xc(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	57                   	push   %edi
  801195:	e8 45 ff ff ff       	call   8010df <read>
		if (m < 0)
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 10                	js     8011b1 <readn+0x41>
			return m;
		if (m == 0)
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	74 0a                	je     8011af <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a5:	01 c3                	add    %eax,%ebx
  8011a7:	39 f3                	cmp    %esi,%ebx
  8011a9:	72 db                	jb     801186 <readn+0x16>
  8011ab:	89 d8                	mov    %ebx,%eax
  8011ad:	eb 02                	jmp    8011b1 <readn+0x41>
  8011af:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 14             	sub    $0x14,%esp
  8011c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c6:	50                   	push   %eax
  8011c7:	53                   	push   %ebx
  8011c8:	e8 ac fc ff ff       	call   800e79 <fd_lookup>
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 68                	js     80123e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	ff 30                	pushl  (%eax)
  8011e2:	e8 e8 fc ff ff       	call   800ecf <dev_lookup>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 47                	js     801235 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f5:	75 21                	jne    801218 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f7:	a1 20 60 80 00       	mov    0x806020,%eax
  8011fc:	8b 40 48             	mov    0x48(%eax),%eax
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	53                   	push   %ebx
  801203:	50                   	push   %eax
  801204:	68 cc 23 80 00       	push   $0x8023cc
  801209:	e8 5e f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801216:	eb 26                	jmp    80123e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801218:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121b:	8b 52 0c             	mov    0xc(%edx),%edx
  80121e:	85 d2                	test   %edx,%edx
  801220:	74 17                	je     801239 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	ff 75 10             	pushl  0x10(%ebp)
  801228:	ff 75 0c             	pushl  0xc(%ebp)
  80122b:	50                   	push   %eax
  80122c:	ff d2                	call   *%edx
  80122e:	89 c2                	mov    %eax,%edx
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	eb 09                	jmp    80123e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	89 c2                	mov    %eax,%edx
  801237:	eb 05                	jmp    80123e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801239:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123e:	89 d0                	mov    %edx,%eax
  801240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <seek>:

int
seek(int fdnum, off_t offset)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	ff 75 08             	pushl  0x8(%ebp)
  801252:	e8 22 fc ff ff       	call   800e79 <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 0e                	js     80126c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801261:	8b 55 0c             	mov    0xc(%ebp),%edx
  801264:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	53                   	push   %ebx
  801272:	83 ec 14             	sub    $0x14,%esp
  801275:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801278:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	53                   	push   %ebx
  80127d:	e8 f7 fb ff ff       	call   800e79 <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	89 c2                	mov    %eax,%edx
  801287:	85 c0                	test   %eax,%eax
  801289:	78 65                	js     8012f0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	ff 30                	pushl  (%eax)
  801297:	e8 33 fc ff ff       	call   800ecf <dev_lookup>
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 44                	js     8012e7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012aa:	75 21                	jne    8012cd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ac:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b1:	8b 40 48             	mov    0x48(%eax),%eax
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	53                   	push   %ebx
  8012b8:	50                   	push   %eax
  8012b9:	68 8c 23 80 00       	push   $0x80238c
  8012be:	e8 a9 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012cb:	eb 23                	jmp    8012f0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d0:	8b 52 18             	mov    0x18(%edx),%edx
  8012d3:	85 d2                	test   %edx,%edx
  8012d5:	74 14                	je     8012eb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	ff 75 0c             	pushl  0xc(%ebp)
  8012dd:	50                   	push   %eax
  8012de:	ff d2                	call   *%edx
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	eb 09                	jmp    8012f0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	eb 05                	jmp    8012f0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f0:	89 d0                	mov    %edx,%eax
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 14             	sub    $0x14,%esp
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801301:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	ff 75 08             	pushl  0x8(%ebp)
  801308:	e8 6c fb ff ff       	call   800e79 <fd_lookup>
  80130d:	83 c4 08             	add    $0x8,%esp
  801310:	89 c2                	mov    %eax,%edx
  801312:	85 c0                	test   %eax,%eax
  801314:	78 58                	js     80136e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801320:	ff 30                	pushl  (%eax)
  801322:	e8 a8 fb ff ff       	call   800ecf <dev_lookup>
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 37                	js     801365 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801331:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801335:	74 32                	je     801369 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801337:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801341:	00 00 00 
	stat->st_isdir = 0;
  801344:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134b:	00 00 00 
	stat->st_dev = dev;
  80134e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	53                   	push   %ebx
  801358:	ff 75 f0             	pushl  -0x10(%ebp)
  80135b:	ff 50 14             	call   *0x14(%eax)
  80135e:	89 c2                	mov    %eax,%edx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	eb 09                	jmp    80136e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801365:	89 c2                	mov    %eax,%edx
  801367:	eb 05                	jmp    80136e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801369:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136e:	89 d0                	mov    %edx,%eax
  801370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	56                   	push   %esi
  801379:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	6a 00                	push   $0x0
  80137f:	ff 75 08             	pushl  0x8(%ebp)
  801382:	e8 e3 01 00 00       	call   80156a <open>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 1b                	js     8013ab <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	ff 75 0c             	pushl  0xc(%ebp)
  801396:	50                   	push   %eax
  801397:	e8 5b ff ff ff       	call   8012f7 <fstat>
  80139c:	89 c6                	mov    %eax,%esi
	close(fd);
  80139e:	89 1c 24             	mov    %ebx,(%esp)
  8013a1:	e8 fd fb ff ff       	call   800fa3 <close>
	return r;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	89 f0                	mov    %esi,%eax
}
  8013ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
  8013b7:	89 c6                	mov    %eax,%esi
  8013b9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c2:	75 12                	jne    8013d6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c4:	83 ec 0c             	sub    $0xc,%esp
  8013c7:	6a 01                	push   $0x1
  8013c9:	e8 d8 08 00 00       	call   801ca6 <ipc_find_env>
  8013ce:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d6:	6a 07                	push   $0x7
  8013d8:	68 00 70 80 00       	push   $0x807000
  8013dd:	56                   	push   %esi
  8013de:	ff 35 00 40 80 00    	pushl  0x804000
  8013e4:	e8 69 08 00 00       	call   801c52 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e9:	83 c4 0c             	add    $0xc,%esp
  8013ec:	6a 00                	push   $0x0
  8013ee:	53                   	push   %ebx
  8013ef:	6a 00                	push   $0x0
  8013f1:	e8 07 08 00 00       	call   801bfd <ipc_recv>
}
  8013f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	8b 40 0c             	mov    0xc(%eax),%eax
  801409:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80140e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801411:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801416:	ba 00 00 00 00       	mov    $0x0,%edx
  80141b:	b8 02 00 00 00       	mov    $0x2,%eax
  801420:	e8 8d ff ff ff       	call   8013b2 <fsipc>
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	8b 40 0c             	mov    0xc(%eax),%eax
  801433:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 06 00 00 00       	mov    $0x6,%eax
  801442:	e8 6b ff ff ff       	call   8013b2 <fsipc>
}
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	53                   	push   %ebx
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	8b 40 0c             	mov    0xc(%eax),%eax
  801459:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145e:	ba 00 00 00 00       	mov    $0x0,%edx
  801463:	b8 05 00 00 00       	mov    $0x5,%eax
  801468:	e8 45 ff ff ff       	call   8013b2 <fsipc>
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 2c                	js     80149d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	68 00 70 80 00       	push   $0x807000
  801479:	53                   	push   %ebx
  80147a:	e8 90 f3 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80147f:	a1 80 70 80 00       	mov    0x807080,%eax
  801484:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148a:	a1 84 70 80 00       	mov    0x807084,%eax
  80148f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b1:	89 15 00 70 80 00    	mov    %edx,0x807000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8014b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014bc:	ba 00 10 00 00       	mov    $0x1000,%edx
  8014c1:	0f 47 c2             	cmova  %edx,%eax
  8014c4:	a3 04 70 80 00       	mov    %eax,0x807004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014c9:	50                   	push   %eax
  8014ca:	ff 75 0c             	pushl  0xc(%ebp)
  8014cd:	68 08 70 80 00       	push   $0x807008
  8014d2:	e8 ca f4 ff ff       	call   8009a1 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8014d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e1:	e8 cc fe ff ff       	call   8013b2 <fsipc>
    return r;
}
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f6:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014fb:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801501:	ba 00 00 00 00       	mov    $0x0,%edx
  801506:	b8 03 00 00 00       	mov    $0x3,%eax
  80150b:	e8 a2 fe ff ff       	call   8013b2 <fsipc>
  801510:	89 c3                	mov    %eax,%ebx
  801512:	85 c0                	test   %eax,%eax
  801514:	78 4b                	js     801561 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801516:	39 c6                	cmp    %eax,%esi
  801518:	73 16                	jae    801530 <devfile_read+0x48>
  80151a:	68 fc 23 80 00       	push   $0x8023fc
  80151f:	68 03 24 80 00       	push   $0x802403
  801524:	6a 7c                	push   $0x7c
  801526:	68 18 24 80 00       	push   $0x802418
  80152b:	e8 63 ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  801530:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801535:	7e 16                	jle    80154d <devfile_read+0x65>
  801537:	68 23 24 80 00       	push   $0x802423
  80153c:	68 03 24 80 00       	push   $0x802403
  801541:	6a 7d                	push   $0x7d
  801543:	68 18 24 80 00       	push   $0x802418
  801548:	e8 46 ec ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80154d:	83 ec 04             	sub    $0x4,%esp
  801550:	50                   	push   %eax
  801551:	68 00 70 80 00       	push   $0x807000
  801556:	ff 75 0c             	pushl  0xc(%ebp)
  801559:	e8 43 f4 ff ff       	call   8009a1 <memmove>
	return r;
  80155e:	83 c4 10             	add    $0x10,%esp
}
  801561:	89 d8                	mov    %ebx,%eax
  801563:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 20             	sub    $0x20,%esp
  801571:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801574:	53                   	push   %ebx
  801575:	e8 5c f2 ff ff       	call   8007d6 <strlen>
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801582:	7f 67                	jg     8015eb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801584:	83 ec 0c             	sub    $0xc,%esp
  801587:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	e8 9a f8 ff ff       	call   800e2a <fd_alloc>
  801590:	83 c4 10             	add    $0x10,%esp
		return r;
  801593:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801595:	85 c0                	test   %eax,%eax
  801597:	78 57                	js     8015f0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	68 00 70 80 00       	push   $0x807000
  8015a2:	e8 68 f2 ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015aa:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b7:	e8 f6 fd ff ff       	call   8013b2 <fsipc>
  8015bc:	89 c3                	mov    %eax,%ebx
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	79 14                	jns    8015d9 <open+0x6f>
		fd_close(fd, 0);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	6a 00                	push   $0x0
  8015ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8015cd:	e8 50 f9 ff ff       	call   800f22 <fd_close>
		return r;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	89 da                	mov    %ebx,%edx
  8015d7:	eb 17                	jmp    8015f0 <open+0x86>
	}

	return fd2num(fd);
  8015d9:	83 ec 0c             	sub    $0xc,%esp
  8015dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8015df:	e8 1f f8 ff ff       	call   800e03 <fd2num>
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	eb 05                	jmp    8015f0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015eb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015f0:	89 d0                	mov    %edx,%eax
  8015f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801602:	b8 08 00 00 00       	mov    $0x8,%eax
  801607:	e8 a6 fd ff ff       	call   8013b2 <fsipc>
}
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80160e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801612:	7e 37                	jle    80164b <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80161d:	ff 70 04             	pushl  0x4(%eax)
  801620:	8d 40 10             	lea    0x10(%eax),%eax
  801623:	50                   	push   %eax
  801624:	ff 33                	pushl  (%ebx)
  801626:	e8 8e fb ff ff       	call   8011b9 <write>
		if (result > 0)
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	7e 03                	jle    801635 <writebuf+0x27>
			b->result += result;
  801632:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801635:	3b 43 04             	cmp    0x4(%ebx),%eax
  801638:	74 0d                	je     801647 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80163a:	85 c0                	test   %eax,%eax
  80163c:	ba 00 00 00 00       	mov    $0x0,%edx
  801641:	0f 4f c2             	cmovg  %edx,%eax
  801644:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801647:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164a:	c9                   	leave  
  80164b:	f3 c3                	repz ret 

0080164d <putch>:

static void
putch(int ch, void *thunk)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	53                   	push   %ebx
  801651:	83 ec 04             	sub    $0x4,%esp
  801654:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801657:	8b 53 04             	mov    0x4(%ebx),%edx
  80165a:	8d 42 01             	lea    0x1(%edx),%eax
  80165d:	89 43 04             	mov    %eax,0x4(%ebx)
  801660:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801663:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801667:	3d 00 01 00 00       	cmp    $0x100,%eax
  80166c:	75 0e                	jne    80167c <putch+0x2f>
		writebuf(b);
  80166e:	89 d8                	mov    %ebx,%eax
  801670:	e8 99 ff ff ff       	call   80160e <writebuf>
		b->idx = 0;
  801675:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80167c:	83 c4 04             	add    $0x4,%esp
  80167f:	5b                   	pop    %ebx
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801694:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80169b:	00 00 00 
	b.result = 0;
  80169e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016a5:	00 00 00 
	b.error = 1;
  8016a8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016af:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016b2:	ff 75 10             	pushl  0x10(%ebp)
  8016b5:	ff 75 0c             	pushl  0xc(%ebp)
  8016b8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	68 4d 16 80 00       	push   $0x80164d
  8016c4:	e8 da ec ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016d3:	7e 0b                	jle    8016e0 <vfprintf+0x5e>
		writebuf(&b);
  8016d5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016db:	e8 2e ff ff ff       	call   80160e <writebuf>

	return (b.result ? b.result : b.error);
  8016e0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016f7:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8016fa:	50                   	push   %eax
  8016fb:	ff 75 0c             	pushl  0xc(%ebp)
  8016fe:	ff 75 08             	pushl  0x8(%ebp)
  801701:	e8 7c ff ff ff       	call   801682 <vfprintf>
	va_end(ap);

	return cnt;
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <printf>:

int
printf(const char *fmt, ...)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80170e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801711:	50                   	push   %eax
  801712:	ff 75 08             	pushl  0x8(%ebp)
  801715:	6a 01                	push   $0x1
  801717:	e8 66 ff ff ff       	call   801682 <vfprintf>
	va_end(ap);

	return cnt;
}
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	ff 75 08             	pushl  0x8(%ebp)
  80172c:	e8 e2 f6 ff ff       	call   800e13 <fd2data>
  801731:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801733:	83 c4 08             	add    $0x8,%esp
  801736:	68 2f 24 80 00       	push   $0x80242f
  80173b:	53                   	push   %ebx
  80173c:	e8 ce f0 ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801741:	8b 46 04             	mov    0x4(%esi),%eax
  801744:	2b 06                	sub    (%esi),%eax
  801746:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80174c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801753:	00 00 00 
	stat->st_dev = &devpipe;
  801756:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80175d:	30 80 00 
	return 0;
}
  801760:	b8 00 00 00 00       	mov    $0x0,%eax
  801765:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 0c             	sub    $0xc,%esp
  801773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801776:	53                   	push   %ebx
  801777:	6a 00                	push   $0x0
  801779:	e8 19 f5 ff ff       	call   800c97 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80177e:	89 1c 24             	mov    %ebx,(%esp)
  801781:	e8 8d f6 ff ff       	call   800e13 <fd2data>
  801786:	83 c4 08             	add    $0x8,%esp
  801789:	50                   	push   %eax
  80178a:	6a 00                	push   $0x0
  80178c:	e8 06 f5 ff ff       	call   800c97 <sys_page_unmap>
}
  801791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	57                   	push   %edi
  80179a:	56                   	push   %esi
  80179b:	53                   	push   %ebx
  80179c:	83 ec 1c             	sub    $0x1c,%esp
  80179f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017a4:	a1 20 60 80 00       	mov    0x806020,%eax
  8017a9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017ac:	83 ec 0c             	sub    $0xc,%esp
  8017af:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b2:	e8 28 05 00 00       	call   801cdf <pageref>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	89 3c 24             	mov    %edi,(%esp)
  8017bc:	e8 1e 05 00 00       	call   801cdf <pageref>
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	39 c3                	cmp    %eax,%ebx
  8017c6:	0f 94 c1             	sete   %cl
  8017c9:	0f b6 c9             	movzbl %cl,%ecx
  8017cc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017cf:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8017d5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017d8:	39 ce                	cmp    %ecx,%esi
  8017da:	74 1b                	je     8017f7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017dc:	39 c3                	cmp    %eax,%ebx
  8017de:	75 c4                	jne    8017a4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017e0:	8b 42 58             	mov    0x58(%edx),%eax
  8017e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e6:	50                   	push   %eax
  8017e7:	56                   	push   %esi
  8017e8:	68 36 24 80 00       	push   $0x802436
  8017ed:	e8 7a ea ff ff       	call   80026c <cprintf>
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	eb ad                	jmp    8017a4 <_pipeisclosed+0xe>
	}
}
  8017f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5f                   	pop    %edi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	57                   	push   %edi
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	83 ec 28             	sub    $0x28,%esp
  80180b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80180e:	56                   	push   %esi
  80180f:	e8 ff f5 ff ff       	call   800e13 <fd2data>
  801814:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	bf 00 00 00 00       	mov    $0x0,%edi
  80181e:	eb 4b                	jmp    80186b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801820:	89 da                	mov    %ebx,%edx
  801822:	89 f0                	mov    %esi,%eax
  801824:	e8 6d ff ff ff       	call   801796 <_pipeisclosed>
  801829:	85 c0                	test   %eax,%eax
  80182b:	75 48                	jne    801875 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80182d:	e8 c1 f3 ff ff       	call   800bf3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801832:	8b 43 04             	mov    0x4(%ebx),%eax
  801835:	8b 0b                	mov    (%ebx),%ecx
  801837:	8d 51 20             	lea    0x20(%ecx),%edx
  80183a:	39 d0                	cmp    %edx,%eax
  80183c:	73 e2                	jae    801820 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80183e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801841:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801845:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801848:	89 c2                	mov    %eax,%edx
  80184a:	c1 fa 1f             	sar    $0x1f,%edx
  80184d:	89 d1                	mov    %edx,%ecx
  80184f:	c1 e9 1b             	shr    $0x1b,%ecx
  801852:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801855:	83 e2 1f             	and    $0x1f,%edx
  801858:	29 ca                	sub    %ecx,%edx
  80185a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80185e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801862:	83 c0 01             	add    $0x1,%eax
  801865:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801868:	83 c7 01             	add    $0x1,%edi
  80186b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80186e:	75 c2                	jne    801832 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801870:	8b 45 10             	mov    0x10(%ebp),%eax
  801873:	eb 05                	jmp    80187a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801875:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80187a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5f                   	pop    %edi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	57                   	push   %edi
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	83 ec 18             	sub    $0x18,%esp
  80188b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80188e:	57                   	push   %edi
  80188f:	e8 7f f5 ff ff       	call   800e13 <fd2data>
  801894:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189e:	eb 3d                	jmp    8018dd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018a0:	85 db                	test   %ebx,%ebx
  8018a2:	74 04                	je     8018a8 <devpipe_read+0x26>
				return i;
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	eb 44                	jmp    8018ec <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018a8:	89 f2                	mov    %esi,%edx
  8018aa:	89 f8                	mov    %edi,%eax
  8018ac:	e8 e5 fe ff ff       	call   801796 <_pipeisclosed>
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	75 32                	jne    8018e7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018b5:	e8 39 f3 ff ff       	call   800bf3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018ba:	8b 06                	mov    (%esi),%eax
  8018bc:	3b 46 04             	cmp    0x4(%esi),%eax
  8018bf:	74 df                	je     8018a0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018c1:	99                   	cltd   
  8018c2:	c1 ea 1b             	shr    $0x1b,%edx
  8018c5:	01 d0                	add    %edx,%eax
  8018c7:	83 e0 1f             	and    $0x1f,%eax
  8018ca:	29 d0                	sub    %edx,%eax
  8018cc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018d7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018da:	83 c3 01             	add    $0x1,%ebx
  8018dd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018e0:	75 d8                	jne    8018ba <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e5:	eb 05                	jmp    8018ec <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5f                   	pop    %edi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	e8 25 f5 ff ff       	call   800e2a <fd_alloc>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	89 c2                	mov    %eax,%edx
  80190a:	85 c0                	test   %eax,%eax
  80190c:	0f 88 2c 01 00 00    	js     801a3e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801912:	83 ec 04             	sub    $0x4,%esp
  801915:	68 07 04 00 00       	push   $0x407
  80191a:	ff 75 f4             	pushl  -0xc(%ebp)
  80191d:	6a 00                	push   $0x0
  80191f:	e8 ee f2 ff ff       	call   800c12 <sys_page_alloc>
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	89 c2                	mov    %eax,%edx
  801929:	85 c0                	test   %eax,%eax
  80192b:	0f 88 0d 01 00 00    	js     801a3e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801937:	50                   	push   %eax
  801938:	e8 ed f4 ff ff       	call   800e2a <fd_alloc>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	85 c0                	test   %eax,%eax
  801944:	0f 88 e2 00 00 00    	js     801a2c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194a:	83 ec 04             	sub    $0x4,%esp
  80194d:	68 07 04 00 00       	push   $0x407
  801952:	ff 75 f0             	pushl  -0x10(%ebp)
  801955:	6a 00                	push   $0x0
  801957:	e8 b6 f2 ff ff       	call   800c12 <sys_page_alloc>
  80195c:	89 c3                	mov    %eax,%ebx
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	85 c0                	test   %eax,%eax
  801963:	0f 88 c3 00 00 00    	js     801a2c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	ff 75 f4             	pushl  -0xc(%ebp)
  80196f:	e8 9f f4 ff ff       	call   800e13 <fd2data>
  801974:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801976:	83 c4 0c             	add    $0xc,%esp
  801979:	68 07 04 00 00       	push   $0x407
  80197e:	50                   	push   %eax
  80197f:	6a 00                	push   $0x0
  801981:	e8 8c f2 ff ff       	call   800c12 <sys_page_alloc>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	0f 88 89 00 00 00    	js     801a1c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	ff 75 f0             	pushl  -0x10(%ebp)
  801999:	e8 75 f4 ff ff       	call   800e13 <fd2data>
  80199e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019a5:	50                   	push   %eax
  8019a6:	6a 00                	push   $0x0
  8019a8:	56                   	push   %esi
  8019a9:	6a 00                	push   $0x0
  8019ab:	e8 a5 f2 ff ff       	call   800c55 <sys_page_map>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	83 c4 20             	add    $0x20,%esp
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 55                	js     801a0e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019b9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019ce:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019dc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019e3:	83 ec 0c             	sub    $0xc,%esp
  8019e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e9:	e8 15 f4 ff ff       	call   800e03 <fd2num>
  8019ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019f3:	83 c4 04             	add    $0x4,%esp
  8019f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f9:	e8 05 f4 ff ff       	call   800e03 <fd2num>
  8019fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a01:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0c:	eb 30                	jmp    801a3e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	56                   	push   %esi
  801a12:	6a 00                	push   $0x0
  801a14:	e8 7e f2 ff ff       	call   800c97 <sys_page_unmap>
  801a19:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a22:	6a 00                	push   $0x0
  801a24:	e8 6e f2 ff ff       	call   800c97 <sys_page_unmap>
  801a29:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a2c:	83 ec 08             	sub    $0x8,%esp
  801a2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a32:	6a 00                	push   $0x0
  801a34:	e8 5e f2 ff ff       	call   800c97 <sys_page_unmap>
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a3e:	89 d0                	mov    %edx,%eax
  801a40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a43:	5b                   	pop    %ebx
  801a44:	5e                   	pop    %esi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a50:	50                   	push   %eax
  801a51:	ff 75 08             	pushl  0x8(%ebp)
  801a54:	e8 20 f4 ff ff       	call   800e79 <fd_lookup>
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 18                	js     801a78 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	ff 75 f4             	pushl  -0xc(%ebp)
  801a66:	e8 a8 f3 ff ff       	call   800e13 <fd2data>
	return _pipeisclosed(fd, p);
  801a6b:	89 c2                	mov    %eax,%edx
  801a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a70:	e8 21 fd ff ff       	call   801796 <_pipeisclosed>
  801a75:	83 c4 10             	add    $0x10,%esp
}
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a8a:	68 4e 24 80 00       	push   $0x80244e
  801a8f:	ff 75 0c             	pushl  0xc(%ebp)
  801a92:	e8 78 ed ff ff       	call   80080f <strcpy>
	return 0;
}
  801a97:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	57                   	push   %edi
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aaa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801aaf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab5:	eb 2d                	jmp    801ae4 <devcons_write+0x46>
		m = n - tot;
  801ab7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aba:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801abc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801abf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ac4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	53                   	push   %ebx
  801acb:	03 45 0c             	add    0xc(%ebp),%eax
  801ace:	50                   	push   %eax
  801acf:	57                   	push   %edi
  801ad0:	e8 cc ee ff ff       	call   8009a1 <memmove>
		sys_cputs(buf, m);
  801ad5:	83 c4 08             	add    $0x8,%esp
  801ad8:	53                   	push   %ebx
  801ad9:	57                   	push   %edi
  801ada:	e8 77 f0 ff ff       	call   800b56 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801adf:	01 de                	add    %ebx,%esi
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	89 f0                	mov    %esi,%eax
  801ae6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ae9:	72 cc                	jb     801ab7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5f                   	pop    %edi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801afe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b02:	74 2a                	je     801b2e <devcons_read+0x3b>
  801b04:	eb 05                	jmp    801b0b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b06:	e8 e8 f0 ff ff       	call   800bf3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b0b:	e8 64 f0 ff ff       	call   800b74 <sys_cgetc>
  801b10:	85 c0                	test   %eax,%eax
  801b12:	74 f2                	je     801b06 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b14:	85 c0                	test   %eax,%eax
  801b16:	78 16                	js     801b2e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b18:	83 f8 04             	cmp    $0x4,%eax
  801b1b:	74 0c                	je     801b29 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b20:	88 02                	mov    %al,(%edx)
	return 1;
  801b22:	b8 01 00 00 00       	mov    $0x1,%eax
  801b27:	eb 05                	jmp    801b2e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
  801b39:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b3c:	6a 01                	push   $0x1
  801b3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b41:	50                   	push   %eax
  801b42:	e8 0f f0 ff ff       	call   800b56 <sys_cputs>
}
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <getchar>:

int
getchar(void)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b52:	6a 01                	push   $0x1
  801b54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 80 f5 ff ff       	call   8010df <read>
	if (r < 0)
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 0f                	js     801b75 <getchar+0x29>
		return r;
	if (r < 1)
  801b66:	85 c0                	test   %eax,%eax
  801b68:	7e 06                	jle    801b70 <getchar+0x24>
		return -E_EOF;
	return c;
  801b6a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b6e:	eb 05                	jmp    801b75 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b70:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b80:	50                   	push   %eax
  801b81:	ff 75 08             	pushl  0x8(%ebp)
  801b84:	e8 f0 f2 ff ff       	call   800e79 <fd_lookup>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 11                	js     801ba1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b99:	39 10                	cmp    %edx,(%eax)
  801b9b:	0f 94 c0             	sete   %al
  801b9e:	0f b6 c0             	movzbl %al,%eax
}
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <opencons>:

int
opencons(void)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ba9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bac:	50                   	push   %eax
  801bad:	e8 78 f2 ff ff       	call   800e2a <fd_alloc>
  801bb2:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	78 3e                	js     801bf9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bbb:	83 ec 04             	sub    $0x4,%esp
  801bbe:	68 07 04 00 00       	push   $0x407
  801bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc6:	6a 00                	push   $0x0
  801bc8:	e8 45 f0 ff ff       	call   800c12 <sys_page_alloc>
  801bcd:	83 c4 10             	add    $0x10,%esp
		return r;
  801bd0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	78 23                	js     801bf9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bd6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	50                   	push   %eax
  801bef:	e8 0f f2 ff ff       	call   800e03 <fd2num>
  801bf4:	89 c2                	mov    %eax,%edx
  801bf6:	83 c4 10             	add    $0x10,%esp
}
  801bf9:	89 d0                	mov    %edx,%eax
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    

00801bfd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	8b 75 08             	mov    0x8(%ebp),%esi
  801c05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c12:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	50                   	push   %eax
  801c19:	e8 a4 f1 ff ff       	call   800dc2 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	85 c0                	test   %eax,%eax
  801c23:	75 10                	jne    801c35 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801c25:	a1 20 60 80 00       	mov    0x806020,%eax
  801c2a:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801c2d:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801c30:	8b 40 70             	mov    0x70(%eax),%eax
  801c33:	eb 0a                	jmp    801c3f <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801c35:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801c3a:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801c3f:	85 f6                	test   %esi,%esi
  801c41:	74 02                	je     801c45 <ipc_recv+0x48>
  801c43:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801c45:	85 db                	test   %ebx,%ebx
  801c47:	74 02                	je     801c4b <ipc_recv+0x4e>
  801c49:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801c4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4e:	5b                   	pop    %ebx
  801c4f:	5e                   	pop    %esi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801c64:	85 db                	test   %ebx,%ebx
  801c66:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c6b:	0f 44 d8             	cmove  %eax,%ebx
  801c6e:	eb 1c                	jmp    801c8c <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801c70:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c73:	74 12                	je     801c87 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801c75:	50                   	push   %eax
  801c76:	68 5a 24 80 00       	push   $0x80245a
  801c7b:	6a 40                	push   $0x40
  801c7d:	68 6c 24 80 00       	push   $0x80246c
  801c82:	e8 0c e5 ff ff       	call   800193 <_panic>
        sys_yield();
  801c87:	e8 67 ef ff ff       	call   800bf3 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801c8c:	ff 75 14             	pushl  0x14(%ebp)
  801c8f:	53                   	push   %ebx
  801c90:	56                   	push   %esi
  801c91:	57                   	push   %edi
  801c92:	e8 08 f1 ff ff       	call   800d9f <sys_ipc_try_send>
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	75 d2                	jne    801c70 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca1:	5b                   	pop    %ebx
  801ca2:	5e                   	pop    %esi
  801ca3:	5f                   	pop    %edi
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    

00801ca6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cb4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cba:	8b 52 50             	mov    0x50(%edx),%edx
  801cbd:	39 ca                	cmp    %ecx,%edx
  801cbf:	75 0d                	jne    801cce <ipc_find_env+0x28>
			return envs[i].env_id;
  801cc1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cc4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cc9:	8b 40 48             	mov    0x48(%eax),%eax
  801ccc:	eb 0f                	jmp    801cdd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cce:	83 c0 01             	add    $0x1,%eax
  801cd1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cd6:	75 d9                	jne    801cb1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ce5:	89 d0                	mov    %edx,%eax
  801ce7:	c1 e8 16             	shr    $0x16,%eax
  801cea:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cf6:	f6 c1 01             	test   $0x1,%cl
  801cf9:	74 1d                	je     801d18 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cfb:	c1 ea 0c             	shr    $0xc,%edx
  801cfe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d05:	f6 c2 01             	test   $0x1,%dl
  801d08:	74 0e                	je     801d18 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d0a:	c1 ea 0c             	shr    $0xc,%edx
  801d0d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d14:	ef 
  801d15:	0f b7 c0             	movzwl %ax,%eax
}
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 f6                	test   %esi,%esi
  801d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3d:	89 ca                	mov    %ecx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	75 3d                	jne    801d80 <__udivdi3+0x60>
  801d43:	39 cf                	cmp    %ecx,%edi
  801d45:	0f 87 c5 00 00 00    	ja     801e10 <__udivdi3+0xf0>
  801d4b:	85 ff                	test   %edi,%edi
  801d4d:	89 fd                	mov    %edi,%ebp
  801d4f:	75 0b                	jne    801d5c <__udivdi3+0x3c>
  801d51:	b8 01 00 00 00       	mov    $0x1,%eax
  801d56:	31 d2                	xor    %edx,%edx
  801d58:	f7 f7                	div    %edi
  801d5a:	89 c5                	mov    %eax,%ebp
  801d5c:	89 c8                	mov    %ecx,%eax
  801d5e:	31 d2                	xor    %edx,%edx
  801d60:	f7 f5                	div    %ebp
  801d62:	89 c1                	mov    %eax,%ecx
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	89 cf                	mov    %ecx,%edi
  801d68:	f7 f5                	div    %ebp
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	39 ce                	cmp    %ecx,%esi
  801d82:	77 74                	ja     801df8 <__udivdi3+0xd8>
  801d84:	0f bd fe             	bsr    %esi,%edi
  801d87:	83 f7 1f             	xor    $0x1f,%edi
  801d8a:	0f 84 98 00 00 00    	je     801e28 <__udivdi3+0x108>
  801d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	89 c5                	mov    %eax,%ebp
  801d99:	29 fb                	sub    %edi,%ebx
  801d9b:	d3 e6                	shl    %cl,%esi
  801d9d:	89 d9                	mov    %ebx,%ecx
  801d9f:	d3 ed                	shr    %cl,%ebp
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e0                	shl    %cl,%eax
  801da5:	09 ee                	or     %ebp,%esi
  801da7:	89 d9                	mov    %ebx,%ecx
  801da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dad:	89 d5                	mov    %edx,%ebp
  801daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801db3:	d3 ed                	shr    %cl,%ebp
  801db5:	89 f9                	mov    %edi,%ecx
  801db7:	d3 e2                	shl    %cl,%edx
  801db9:	89 d9                	mov    %ebx,%ecx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	09 c2                	or     %eax,%edx
  801dbf:	89 d0                	mov    %edx,%eax
  801dc1:	89 ea                	mov    %ebp,%edx
  801dc3:	f7 f6                	div    %esi
  801dc5:	89 d5                	mov    %edx,%ebp
  801dc7:	89 c3                	mov    %eax,%ebx
  801dc9:	f7 64 24 0c          	mull   0xc(%esp)
  801dcd:	39 d5                	cmp    %edx,%ebp
  801dcf:	72 10                	jb     801de1 <__udivdi3+0xc1>
  801dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e6                	shl    %cl,%esi
  801dd9:	39 c6                	cmp    %eax,%esi
  801ddb:	73 07                	jae    801de4 <__udivdi3+0xc4>
  801ddd:	39 d5                	cmp    %edx,%ebp
  801ddf:	75 03                	jne    801de4 <__udivdi3+0xc4>
  801de1:	83 eb 01             	sub    $0x1,%ebx
  801de4:	31 ff                	xor    %edi,%edi
  801de6:	89 d8                	mov    %ebx,%eax
  801de8:	89 fa                	mov    %edi,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	31 ff                	xor    %edi,%edi
  801dfa:	31 db                	xor    %ebx,%ebx
  801dfc:	89 d8                	mov    %ebx,%eax
  801dfe:	89 fa                	mov    %edi,%edx
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	f7 f7                	div    %edi
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 fa                	mov    %edi,%edx
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	39 ce                	cmp    %ecx,%esi
  801e2a:	72 0c                	jb     801e38 <__udivdi3+0x118>
  801e2c:	31 db                	xor    %ebx,%ebx
  801e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e32:	0f 87 34 ff ff ff    	ja     801d6c <__udivdi3+0x4c>
  801e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e3d:	e9 2a ff ff ff       	jmp    801d6c <__udivdi3+0x4c>
  801e42:	66 90                	xchg   %ax,%ax
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e67:	85 d2                	test   %edx,%edx
  801e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 f3                	mov    %esi,%ebx
  801e73:	89 3c 24             	mov    %edi,(%esp)
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	75 1c                	jne    801e98 <__umoddi3+0x48>
  801e7c:	39 f7                	cmp    %esi,%edi
  801e7e:	76 50                	jbe    801ed0 <__umoddi3+0x80>
  801e80:	89 c8                	mov    %ecx,%eax
  801e82:	89 f2                	mov    %esi,%edx
  801e84:	f7 f7                	div    %edi
  801e86:	89 d0                	mov    %edx,%eax
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	83 c4 1c             	add    $0x1c,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	39 f2                	cmp    %esi,%edx
  801e9a:	89 d0                	mov    %edx,%eax
  801e9c:	77 52                	ja     801ef0 <__umoddi3+0xa0>
  801e9e:	0f bd ea             	bsr    %edx,%ebp
  801ea1:	83 f5 1f             	xor    $0x1f,%ebp
  801ea4:	75 5a                	jne    801f00 <__umoddi3+0xb0>
  801ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eaa:	0f 82 e0 00 00 00    	jb     801f90 <__umoddi3+0x140>
  801eb0:	39 0c 24             	cmp    %ecx,(%esp)
  801eb3:	0f 86 d7 00 00 00    	jbe    801f90 <__umoddi3+0x140>
  801eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
  801ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	85 ff                	test   %edi,%edi
  801ed2:	89 fd                	mov    %edi,%ebp
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f7                	div    %edi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	89 f0                	mov    %esi,%eax
  801ee3:	31 d2                	xor    %edx,%edx
  801ee5:	f7 f5                	div    %ebp
  801ee7:	89 c8                	mov    %ecx,%eax
  801ee9:	f7 f5                	div    %ebp
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	eb 99                	jmp    801e88 <__umoddi3+0x38>
  801eef:	90                   	nop
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  801ef4:	83 c4 1c             	add    $0x1c,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	8b 34 24             	mov    (%esp),%esi
  801f03:	bf 20 00 00 00       	mov    $0x20,%edi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	29 ef                	sub    %ebp,%edi
  801f0c:	d3 e0                	shl    %cl,%eax
  801f0e:	89 f9                	mov    %edi,%ecx
  801f10:	89 f2                	mov    %esi,%edx
  801f12:	d3 ea                	shr    %cl,%edx
  801f14:	89 e9                	mov    %ebp,%ecx
  801f16:	09 c2                	or     %eax,%edx
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	89 14 24             	mov    %edx,(%esp)
  801f1d:	89 f2                	mov    %esi,%edx
  801f1f:	d3 e2                	shl    %cl,%edx
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f2b:	d3 e8                	shr    %cl,%eax
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	89 c6                	mov    %eax,%esi
  801f31:	d3 e3                	shl    %cl,%ebx
  801f33:	89 f9                	mov    %edi,%ecx
  801f35:	89 d0                	mov    %edx,%eax
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	09 d8                	or     %ebx,%eax
  801f3d:	89 d3                	mov    %edx,%ebx
  801f3f:	89 f2                	mov    %esi,%edx
  801f41:	f7 34 24             	divl   (%esp)
  801f44:	89 d6                	mov    %edx,%esi
  801f46:	d3 e3                	shl    %cl,%ebx
  801f48:	f7 64 24 04          	mull   0x4(%esp)
  801f4c:	39 d6                	cmp    %edx,%esi
  801f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f52:	89 d1                	mov    %edx,%ecx
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	72 08                	jb     801f60 <__umoddi3+0x110>
  801f58:	75 11                	jne    801f6b <__umoddi3+0x11b>
  801f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f5e:	73 0b                	jae    801f6b <__umoddi3+0x11b>
  801f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f64:	1b 14 24             	sbb    (%esp),%edx
  801f67:	89 d1                	mov    %edx,%ecx
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f6f:	29 da                	sub    %ebx,%edx
  801f71:	19 ce                	sbb    %ecx,%esi
  801f73:	89 f9                	mov    %edi,%ecx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	d3 e0                	shl    %cl,%eax
  801f79:	89 e9                	mov    %ebp,%ecx
  801f7b:	d3 ea                	shr    %cl,%edx
  801f7d:	89 e9                	mov    %ebp,%ecx
  801f7f:	d3 ee                	shr    %cl,%esi
  801f81:	09 d0                	or     %edx,%eax
  801f83:	89 f2                	mov    %esi,%edx
  801f85:	83 c4 1c             	add    $0x1c,%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	8d 76 00             	lea    0x0(%esi),%esi
  801f90:	29 f9                	sub    %edi,%ecx
  801f92:	19 d6                	sbb    %edx,%esi
  801f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f9c:	e9 18 ff ff ff       	jmp    801eb9 <__umoddi3+0x69>
