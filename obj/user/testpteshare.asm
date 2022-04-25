
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 0b 08 00 00       	call   800854 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 de 0b 00 00       	call   800c57 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 8c 28 80 00       	push   $0x80288c
  800086:	6a 13                	push   $0x13
  800088:	68 9f 28 80 00       	push   $0x80289f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 85 0f 00 00       	call   80101c <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 b3 28 80 00       	push   $0x8028b3
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 9f 28 80 00       	push   $0x80289f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 8e 07 00 00       	call   800854 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 9c 21 00 00       	call   802273 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 14 08 00 00       	call   8008fe <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 86 28 80 00       	mov    $0x802886,%edx
  8000f4:	b8 80 28 80 00       	mov    $0x802880,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 bc 28 80 00       	push   $0x8028bc
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 d7 28 80 00       	push   $0x8028d7
  80010e:	68 dc 28 80 00       	push   $0x8028dc
  800113:	68 db 28 80 00       	push   $0x8028db
  800118:	e8 87 1d 00 00       	call   801ea4 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 e9 28 80 00       	push   $0x8028e9
  80012a:	6a 21                	push   $0x21
  80012c:	68 9f 28 80 00       	push   $0x80289f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 34 21 00 00       	call   802273 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 ac 07 00 00       	call   8008fe <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 86 28 80 00       	mov    $0x802886,%edx
  80015c:	b8 80 28 80 00       	mov    $0x802880,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 f3 28 80 00       	push   $0x8028f3
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 91 0a 00 00       	call   800c19 <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 5a 11 00 00       	call   801323 <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 05 0a 00 00       	call   800bd8 <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001e6:	e8 2e 0a 00 00       	call   800c19 <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 38 29 80 00       	push   $0x802938
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 26 2f 80 00 	movl   $0x802f26,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 4d 09 00 00       	call   800b9b <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 54 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 f2 08 00 00       	call   800b9b <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 d7 22 00 00       	call   8025f0 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 c4 23 00 00       	call   802720 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 5b 29 80 00 	movsbl 0x80295b(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 22                	jmp    8003ac <getuint+0x38>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 10                	je     80039e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 0e                	jmp    8003ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	50                   	push   %eax
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 05 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 2c             	sub    $0x2c,%esp
  8003f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fa:	eb 12                	jmp    80040e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 84 a7 03 00 00    	je     8007ab <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	50                   	push   %eax
  800409:	ff d6                	call   *%esi
  80040b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e2                	jne    8003fc <vprintfmt+0x14>
  80041a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800425:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80042c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800433:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80043a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043f:	eb 07                	jmp    800448 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800444:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8d 47 01             	lea    0x1(%edi),%eax
  80044b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044e:	0f b6 07             	movzbl (%edi),%eax
  800451:	0f b6 d0             	movzbl %al,%edx
  800454:	83 e8 23             	sub    $0x23,%eax
  800457:	3c 55                	cmp    $0x55,%al
  800459:	0f 87 31 03 00 00    	ja     800790 <vprintfmt+0x3a8>
  80045f:	0f b6 c0             	movzbl %al,%eax
  800462:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800470:	eb d6                	jmp    800448 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800480:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800484:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800487:	8d 72 d0             	lea    -0x30(%edx),%esi
  80048a:	83 fe 09             	cmp    $0x9,%esi
  80048d:	77 34                	ja     8004c3 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800492:	eb e9                	jmp    80047d <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a5:	eb 22                	jmp    8004c9 <vprintfmt+0xe1>
  8004a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004aa:	85 c0                	test   %eax,%eax
  8004ac:	0f 48 c1             	cmovs  %ecx,%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b5:	eb 91                	jmp    800448 <vprintfmt+0x60>
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c1:	eb 85                	jmp    800448 <vprintfmt+0x60>
  8004c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004c6:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  8004c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cd:	0f 89 75 ff ff ff    	jns    800448 <vprintfmt+0x60>
				width = precision, precision = -1;
  8004d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004e0:	e9 63 ff ff ff       	jmp    800448 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e5:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ec:	e9 57 ff ff ff       	jmp    800448 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 30                	pushl  (%eax)
  800500:	ff d6                	call   *%esi
			break;
  800502:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800508:	e9 01 ff ff ff       	jmp    80040e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	99                   	cltd   
  800519:	31 d0                	xor    %edx,%eax
  80051b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051d:	83 f8 0f             	cmp    $0xf,%eax
  800520:	7f 0b                	jg     80052d <vprintfmt+0x145>
  800522:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	75 18                	jne    800545 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80052d:	50                   	push   %eax
  80052e:	68 73 29 80 00       	push   $0x802973
  800533:	53                   	push   %ebx
  800534:	56                   	push   %esi
  800535:	e8 91 fe ff ff       	call   8003cb <printfmt>
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800540:	e9 c9 fe ff ff       	jmp    80040e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800545:	52                   	push   %edx
  800546:	68 59 2e 80 00       	push   $0x802e59
  80054b:	53                   	push   %ebx
  80054c:	56                   	push   %esi
  80054d:	e8 79 fe ff ff       	call   8003cb <printfmt>
  800552:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800558:	e9 b1 fe ff ff       	jmp    80040e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800568:	85 ff                	test   %edi,%edi
  80056a:	b8 6c 29 80 00       	mov    $0x80296c,%eax
  80056f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800572:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800576:	0f 8e 94 00 00 00    	jle    800610 <vprintfmt+0x228>
  80057c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800580:	0f 84 98 00 00 00    	je     80061e <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	ff 75 cc             	pushl  -0x34(%ebp)
  80058c:	57                   	push   %edi
  80058d:	e8 a1 02 00 00       	call   800833 <strnlen>
  800592:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800595:	29 c1                	sub    %eax,%ecx
  800597:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a9:	eb 0f                	jmp    8005ba <vprintfmt+0x1d2>
					putch(padc, putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	85 ff                	test   %edi,%edi
  8005bc:	7f ed                	jg     8005ab <vprintfmt+0x1c3>
  8005be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cb:	0f 49 c1             	cmovns %ecx,%eax
  8005ce:	29 c1                	sub    %eax,%ecx
  8005d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d9:	89 cb                	mov    %ecx,%ebx
  8005db:	eb 4d                	jmp    80062a <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	74 1b                	je     8005fe <vprintfmt+0x216>
  8005e3:	0f be c0             	movsbl %al,%eax
  8005e6:	83 e8 20             	sub    $0x20,%eax
  8005e9:	83 f8 5e             	cmp    $0x5e,%eax
  8005ec:	76 10                	jbe    8005fe <vprintfmt+0x216>
					putch('?', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	6a 3f                	push   $0x3f
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	eb 0d                	jmp    80060b <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	52                   	push   %edx
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060b:	83 eb 01             	sub    $0x1,%ebx
  80060e:	eb 1a                	jmp    80062a <vprintfmt+0x242>
  800610:	89 75 08             	mov    %esi,0x8(%ebp)
  800613:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800616:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800619:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061c:	eb 0c                	jmp    80062a <vprintfmt+0x242>
  80061e:	89 75 08             	mov    %esi,0x8(%ebp)
  800621:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800624:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800627:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062a:	83 c7 01             	add    $0x1,%edi
  80062d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800631:	0f be d0             	movsbl %al,%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	74 23                	je     80065b <vprintfmt+0x273>
  800638:	85 f6                	test   %esi,%esi
  80063a:	78 a1                	js     8005dd <vprintfmt+0x1f5>
  80063c:	83 ee 01             	sub    $0x1,%esi
  80063f:	79 9c                	jns    8005dd <vprintfmt+0x1f5>
  800641:	89 df                	mov    %ebx,%edi
  800643:	8b 75 08             	mov    0x8(%ebp),%esi
  800646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800649:	eb 18                	jmp    800663 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 20                	push   $0x20
  800651:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 08                	jmp    800663 <vprintfmt+0x27b>
  80065b:	89 df                	mov    %ebx,%edi
  80065d:	8b 75 08             	mov    0x8(%ebp),%esi
  800660:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800663:	85 ff                	test   %edi,%edi
  800665:	7f e4                	jg     80064b <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066a:	e9 9f fd ff ff       	jmp    80040e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  800673:	7e 16                	jle    80068b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 08             	lea    0x8(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 50 04             	mov    0x4(%eax),%edx
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800689:	eb 34                	jmp    8006bf <vprintfmt+0x2d7>
	else if (lflag)
  80068b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80068f:	74 18                	je     8006a9 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 c1                	mov    %eax,%ecx
  8006a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a7:	eb 16                	jmp    8006bf <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 04             	lea    0x4(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 c1                	mov    %eax,%ecx
  8006b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ce:	0f 89 88 00 00 00    	jns    80075c <vprintfmt+0x374>
				putch('-', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 2d                	push   $0x2d
  8006da:	ff d6                	call   *%esi
				num = -(long long) num;
  8006dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e2:	f7 d8                	neg    %eax
  8006e4:	83 d2 00             	adc    $0x0,%edx
  8006e7:	f7 da                	neg    %edx
  8006e9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f1:	eb 69                	jmp    80075c <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 76 fc ff ff       	call   800374 <getuint>
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800703:	eb 57                	jmp    80075c <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 30                	push   $0x30
  80070b:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80070d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
  800713:	e8 5c fc ff ff       	call   800374 <getuint>
			base = 8;
			goto number;
  800718:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80071b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800720:	eb 3a                	jmp    80075c <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 30                	push   $0x30
  800728:	ff d6                	call   *%esi
			putch('x', putdat);
  80072a:	83 c4 08             	add    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	6a 78                	push   $0x78
  800730:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 50 04             	lea    0x4(%eax),%edx
  800738:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800742:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800745:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80074a:	eb 10                	jmp    80075c <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	e8 1d fc ff ff       	call   800374 <getuint>
			base = 16;
  800757:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075c:	83 ec 0c             	sub    $0xc,%esp
  80075f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800763:	57                   	push   %edi
  800764:	ff 75 e0             	pushl  -0x20(%ebp)
  800767:	51                   	push   %ecx
  800768:	52                   	push   %edx
  800769:	50                   	push   %eax
  80076a:	89 da                	mov    %ebx,%edx
  80076c:	89 f0                	mov    %esi,%eax
  80076e:	e8 52 fb ff ff       	call   8002c5 <printnum>
			break;
  800773:	83 c4 20             	add    $0x20,%esp
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800779:	e9 90 fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	53                   	push   %ebx
  800782:	52                   	push   %edx
  800783:	ff d6                	call   *%esi
			break;
  800785:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078b:	e9 7e fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	6a 25                	push   $0x25
  800796:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	eb 03                	jmp    8007a0 <vprintfmt+0x3b8>
  80079d:	83 ef 01             	sub    $0x1,%edi
  8007a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a4:	75 f7                	jne    80079d <vprintfmt+0x3b5>
  8007a6:	e9 63 fc ff ff       	jmp    80040e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	83 ec 18             	sub    $0x18,%esp
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	74 26                	je     8007fa <vsnprintf+0x47>
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	7e 22                	jle    8007fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d8:	ff 75 14             	pushl  0x14(%ebp)
  8007db:	ff 75 10             	pushl  0x10(%ebp)
  8007de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	68 ae 03 80 00       	push   $0x8003ae
  8007e7:	e8 fc fb ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	eb 05                	jmp    8007ff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080a:	50                   	push   %eax
  80080b:	ff 75 10             	pushl  0x10(%ebp)
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	ff 75 08             	pushl  0x8(%ebp)
  800814:	e8 9a ff ff ff       	call   8007b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 03                	jmp    80082b <strlen+0x10>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082f:	75 f7                	jne    800828 <strlen+0xd>
		n++;
	return n;
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	ba 00 00 00 00       	mov    $0x0,%edx
  800841:	eb 03                	jmp    800846 <strnlen+0x13>
		n++;
  800843:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	39 c2                	cmp    %eax,%edx
  800848:	74 08                	je     800852 <strnlen+0x1f>
  80084a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80084e:	75 f3                	jne    800843 <strnlen+0x10>
  800850:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	53                   	push   %ebx
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085e:	89 c2                	mov    %eax,%edx
  800860:	83 c2 01             	add    $0x1,%edx
  800863:	83 c1 01             	add    $0x1,%ecx
  800866:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086d:	84 db                	test   %bl,%bl
  80086f:	75 ef                	jne    800860 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800871:	5b                   	pop    %ebx
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	53                   	push   %ebx
  800878:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087b:	53                   	push   %ebx
  80087c:	e8 9a ff ff ff       	call   80081b <strlen>
  800881:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800884:	ff 75 0c             	pushl  0xc(%ebp)
  800887:	01 d8                	add    %ebx,%eax
  800889:	50                   	push   %eax
  80088a:	e8 c5 ff ff ff       	call   800854 <strcpy>
	return dst;
}
  80088f:	89 d8                	mov    %ebx,%eax
  800891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a1:	89 f3                	mov    %esi,%ebx
  8008a3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a6:	89 f2                	mov    %esi,%edx
  8008a8:	eb 0f                	jmp    8008b9 <strncpy+0x23>
		*dst++ = *src;
  8008aa:	83 c2 01             	add    $0x1,%edx
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	39 da                	cmp    %ebx,%edx
  8008bb:	75 ed                	jne    8008aa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ce:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d3:	85 d2                	test   %edx,%edx
  8008d5:	74 21                	je     8008f8 <strlcpy+0x35>
  8008d7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008db:	89 f2                	mov    %esi,%edx
  8008dd:	eb 09                	jmp    8008e8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008df:	83 c2 01             	add    $0x1,%edx
  8008e2:	83 c1 01             	add    $0x1,%ecx
  8008e5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e8:	39 c2                	cmp    %eax,%edx
  8008ea:	74 09                	je     8008f5 <strlcpy+0x32>
  8008ec:	0f b6 19             	movzbl (%ecx),%ebx
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	75 ec                	jne    8008df <strlcpy+0x1c>
  8008f3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f8:	29 f0                	sub    %esi,%eax
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800904:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800907:	eb 06                	jmp    80090f <strcmp+0x11>
		p++, q++;
  800909:	83 c1 01             	add    $0x1,%ecx
  80090c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090f:	0f b6 01             	movzbl (%ecx),%eax
  800912:	84 c0                	test   %al,%al
  800914:	74 04                	je     80091a <strcmp+0x1c>
  800916:	3a 02                	cmp    (%edx),%al
  800918:	74 ef                	je     800909 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091a:	0f b6 c0             	movzbl %al,%eax
  80091d:	0f b6 12             	movzbl (%edx),%edx
  800920:	29 d0                	sub    %edx,%eax
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 c3                	mov    %eax,%ebx
  800930:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800933:	eb 06                	jmp    80093b <strncmp+0x17>
		n--, p++, q++;
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093b:	39 d8                	cmp    %ebx,%eax
  80093d:	74 15                	je     800954 <strncmp+0x30>
  80093f:	0f b6 08             	movzbl (%eax),%ecx
  800942:	84 c9                	test   %cl,%cl
  800944:	74 04                	je     80094a <strncmp+0x26>
  800946:	3a 0a                	cmp    (%edx),%cl
  800948:	74 eb                	je     800935 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094a:	0f b6 00             	movzbl (%eax),%eax
  80094d:	0f b6 12             	movzbl (%edx),%edx
  800950:	29 d0                	sub    %edx,%eax
  800952:	eb 05                	jmp    800959 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800966:	eb 07                	jmp    80096f <strchr+0x13>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 0f                	je     80097b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	0f b6 10             	movzbl (%eax),%edx
  800972:	84 d2                	test   %dl,%dl
  800974:	75 f2                	jne    800968 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800987:	eb 03                	jmp    80098c <strfind+0xf>
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098f:	38 ca                	cmp    %cl,%dl
  800991:	74 04                	je     800997 <strfind+0x1a>
  800993:	84 d2                	test   %dl,%dl
  800995:	75 f2                	jne    800989 <strfind+0xc>
			break;
	return (char *) s;
}
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a5:	85 c9                	test   %ecx,%ecx
  8009a7:	74 36                	je     8009df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 28                	jne    8009d9 <memset+0x40>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 23                	jne    8009d9 <memset+0x40>
		c &= 0xFF;
  8009b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ba:	89 d3                	mov    %edx,%ebx
  8009bc:	c1 e3 08             	shl    $0x8,%ebx
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	c1 e6 18             	shl    $0x18,%esi
  8009c4:	89 d0                	mov    %edx,%eax
  8009c6:	c1 e0 10             	shl    $0x10,%eax
  8009c9:	09 f0                	or     %esi,%eax
  8009cb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009cd:	89 d8                	mov    %ebx,%eax
  8009cf:	09 d0                	or     %edx,%eax
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
  8009d4:	fc                   	cld    
  8009d5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d7:	eb 06                	jmp    8009df <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dc:	fc                   	cld    
  8009dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009df:	89 f8                	mov    %edi,%eax
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f4:	39 c6                	cmp    %eax,%esi
  8009f6:	73 35                	jae    800a2d <memmove+0x47>
  8009f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fb:	39 d0                	cmp    %edx,%eax
  8009fd:	73 2e                	jae    800a2d <memmove+0x47>
		s += n;
		d += n;
  8009ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a02:	89 d6                	mov    %edx,%esi
  800a04:	09 fe                	or     %edi,%esi
  800a06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0c:	75 13                	jne    800a21 <memmove+0x3b>
  800a0e:	f6 c1 03             	test   $0x3,%cl
  800a11:	75 0e                	jne    800a21 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a13:	83 ef 04             	sub    $0x4,%edi
  800a16:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a19:	c1 e9 02             	shr    $0x2,%ecx
  800a1c:	fd                   	std    
  800a1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1f:	eb 09                	jmp    800a2a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a21:	83 ef 01             	sub    $0x1,%edi
  800a24:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a27:	fd                   	std    
  800a28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2a:	fc                   	cld    
  800a2b:	eb 1d                	jmp    800a4a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2d:	89 f2                	mov    %esi,%edx
  800a2f:	09 c2                	or     %eax,%edx
  800a31:	f6 c2 03             	test   $0x3,%dl
  800a34:	75 0f                	jne    800a45 <memmove+0x5f>
  800a36:	f6 c1 03             	test   $0x3,%cl
  800a39:	75 0a                	jne    800a45 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	89 c7                	mov    %eax,%edi
  800a40:	fc                   	cld    
  800a41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a43:	eb 05                	jmp    800a4a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a45:	89 c7                	mov    %eax,%edi
  800a47:	fc                   	cld    
  800a48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a51:	ff 75 10             	pushl  0x10(%ebp)
  800a54:	ff 75 0c             	pushl  0xc(%ebp)
  800a57:	ff 75 08             	pushl  0x8(%ebp)
  800a5a:	e8 87 ff ff ff       	call   8009e6 <memmove>
}
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6c:	89 c6                	mov    %eax,%esi
  800a6e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a71:	eb 1a                	jmp    800a8d <memcmp+0x2c>
		if (*s1 != *s2)
  800a73:	0f b6 08             	movzbl (%eax),%ecx
  800a76:	0f b6 1a             	movzbl (%edx),%ebx
  800a79:	38 d9                	cmp    %bl,%cl
  800a7b:	74 0a                	je     800a87 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a7d:	0f b6 c1             	movzbl %cl,%eax
  800a80:	0f b6 db             	movzbl %bl,%ebx
  800a83:	29 d8                	sub    %ebx,%eax
  800a85:	eb 0f                	jmp    800a96 <memcmp+0x35>
		s1++, s2++;
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8d:	39 f0                	cmp    %esi,%eax
  800a8f:	75 e2                	jne    800a73 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa1:	89 c1                	mov    %eax,%ecx
  800aa3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aaa:	eb 0a                	jmp    800ab6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aac:	0f b6 10             	movzbl (%eax),%edx
  800aaf:	39 da                	cmp    %ebx,%edx
  800ab1:	74 07                	je     800aba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	39 c8                	cmp    %ecx,%eax
  800ab8:	72 f2                	jb     800aac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aba:	5b                   	pop    %ebx
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac9:	eb 03                	jmp    800ace <strtol+0x11>
		s++;
  800acb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ace:	0f b6 01             	movzbl (%ecx),%eax
  800ad1:	3c 20                	cmp    $0x20,%al
  800ad3:	74 f6                	je     800acb <strtol+0xe>
  800ad5:	3c 09                	cmp    $0x9,%al
  800ad7:	74 f2                	je     800acb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad9:	3c 2b                	cmp    $0x2b,%al
  800adb:	75 0a                	jne    800ae7 <strtol+0x2a>
		s++;
  800add:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae5:	eb 11                	jmp    800af8 <strtol+0x3b>
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aec:	3c 2d                	cmp    $0x2d,%al
  800aee:	75 08                	jne    800af8 <strtol+0x3b>
		s++, neg = 1;
  800af0:	83 c1 01             	add    $0x1,%ecx
  800af3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afe:	75 15                	jne    800b15 <strtol+0x58>
  800b00:	80 39 30             	cmpb   $0x30,(%ecx)
  800b03:	75 10                	jne    800b15 <strtol+0x58>
  800b05:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b09:	75 7c                	jne    800b87 <strtol+0xca>
		s += 2, base = 16;
  800b0b:	83 c1 02             	add    $0x2,%ecx
  800b0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b13:	eb 16                	jmp    800b2b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b15:	85 db                	test   %ebx,%ebx
  800b17:	75 12                	jne    800b2b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b19:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b21:	75 08                	jne    800b2b <strtol+0x6e>
		s++, base = 8;
  800b23:	83 c1 01             	add    $0x1,%ecx
  800b26:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b33:	0f b6 11             	movzbl (%ecx),%edx
  800b36:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b39:	89 f3                	mov    %esi,%ebx
  800b3b:	80 fb 09             	cmp    $0x9,%bl
  800b3e:	77 08                	ja     800b48 <strtol+0x8b>
			dig = *s - '0';
  800b40:	0f be d2             	movsbl %dl,%edx
  800b43:	83 ea 30             	sub    $0x30,%edx
  800b46:	eb 22                	jmp    800b6a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4b:	89 f3                	mov    %esi,%ebx
  800b4d:	80 fb 19             	cmp    $0x19,%bl
  800b50:	77 08                	ja     800b5a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b52:	0f be d2             	movsbl %dl,%edx
  800b55:	83 ea 57             	sub    $0x57,%edx
  800b58:	eb 10                	jmp    800b6a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5d:	89 f3                	mov    %esi,%ebx
  800b5f:	80 fb 19             	cmp    $0x19,%bl
  800b62:	77 16                	ja     800b7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b64:	0f be d2             	movsbl %dl,%edx
  800b67:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b6a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6d:	7d 0b                	jge    800b7a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b6f:	83 c1 01             	add    $0x1,%ecx
  800b72:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b76:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b78:	eb b9                	jmp    800b33 <strtol+0x76>

	if (endptr)
  800b7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7e:	74 0d                	je     800b8d <strtol+0xd0>
		*endptr = (char *) s;
  800b80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b83:	89 0e                	mov    %ecx,(%esi)
  800b85:	eb 06                	jmp    800b8d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b87:	85 db                	test   %ebx,%ebx
  800b89:	74 98                	je     800b23 <strtol+0x66>
  800b8b:	eb 9e                	jmp    800b2b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	f7 da                	neg    %edx
  800b91:	85 ff                	test   %edi,%edi
  800b93:	0f 45 c2             	cmovne %edx,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	89 c3                	mov    %eax,%ebx
  800bae:	89 c7                	mov    %eax,%edi
  800bb0:	89 c6                	mov    %eax,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc4:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc9:	89 d1                	mov    %edx,%ecx
  800bcb:	89 d3                	mov    %edx,%ebx
  800bcd:	89 d7                	mov    %edx,%edi
  800bcf:	89 d6                	mov    %edx,%esi
  800bd1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be6:	b8 03 00 00 00       	mov    $0x3,%eax
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	89 cb                	mov    %ecx,%ebx
  800bf0:	89 cf                	mov    %ecx,%edi
  800bf2:	89 ce                	mov    %ecx,%esi
  800bf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7e 17                	jle    800c11 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 03                	push   $0x3
  800c00:	68 5f 2c 80 00       	push   $0x802c5f
  800c05:	6a 23                	push   $0x23
  800c07:	68 7c 2c 80 00       	push   $0x802c7c
  800c0c:	e8 c7 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 02 00 00 00       	mov    $0x2,%eax
  800c29:	89 d1                	mov    %edx,%ecx
  800c2b:	89 d3                	mov    %edx,%ebx
  800c2d:	89 d7                	mov    %edx,%edi
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_yield>:

void
sys_yield(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c48:	89 d1                	mov    %edx,%ecx
  800c4a:	89 d3                	mov    %edx,%ebx
  800c4c:	89 d7                	mov    %edx,%edi
  800c4e:	89 d6                	mov    %edx,%esi
  800c50:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c60:	be 00 00 00 00       	mov    $0x0,%esi
  800c65:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c73:	89 f7                	mov    %esi,%edi
  800c75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 17                	jle    800c92 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	6a 04                	push   $0x4
  800c81:	68 5f 2c 80 00       	push   $0x802c5f
  800c86:	6a 23                	push   $0x23
  800c88:	68 7c 2c 80 00       	push   $0x802c7c
  800c8d:	e8 46 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 05                	push   $0x5
  800cc3:	68 5f 2c 80 00       	push   $0x802c5f
  800cc8:	6a 23                	push   $0x23
  800cca:	68 7c 2c 80 00       	push   $0x802c7c
  800ccf:	e8 04 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	b8 06 00 00 00       	mov    $0x6,%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 06                	push   $0x6
  800d05:	68 5f 2c 80 00       	push   $0x802c5f
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 7c 2c 80 00       	push   $0x802c7c
  800d11:	e8 c2 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 df                	mov    %ebx,%edi
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 08                	push   $0x8
  800d47:	68 5f 2c 80 00       	push   $0x802c5f
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 7c 2c 80 00       	push   $0x802c7c
  800d53:	e8 80 f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 df                	mov    %ebx,%edi
  800d7b:	89 de                	mov    %ebx,%esi
  800d7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7e 17                	jle    800d9a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	50                   	push   %eax
  800d87:	6a 09                	push   $0x9
  800d89:	68 5f 2c 80 00       	push   $0x802c5f
  800d8e:	6a 23                	push   $0x23
  800d90:	68 7c 2c 80 00       	push   $0x802c7c
  800d95:	e8 3e f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 17                	jle    800ddc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 0a                	push   $0xa
  800dcb:	68 5f 2c 80 00       	push   $0x802c5f
  800dd0:	6a 23                	push   $0x23
  800dd2:	68 7c 2c 80 00       	push   $0x802c7c
  800dd7:	e8 fc f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	be 00 00 00 00       	mov    $0x0,%esi
  800def:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e00:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e15:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	89 cb                	mov    %ecx,%ebx
  800e1f:	89 cf                	mov    %ecx,%edi
  800e21:	89 ce                	mov    %ecx,%esi
  800e23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e25:	85 c0                	test   %eax,%eax
  800e27:	7e 17                	jle    800e40 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	50                   	push   %eax
  800e2d:	6a 0d                	push   $0xd
  800e2f:	68 5f 2c 80 00       	push   $0x802c5f
  800e34:	6a 23                	push   $0x23
  800e36:	68 7c 2c 80 00       	push   $0x802c7c
  800e3b:	e8 98 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800e4f:	89 d3                	mov    %edx,%ebx
  800e51:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800e54:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e5b:	f6 c5 04             	test   $0x4,%ch
  800e5e:	74 2f                	je     800e8f <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800e60:	83 ec 0c             	sub    $0xc,%esp
  800e63:	68 07 0e 00 00       	push   $0xe07
  800e68:	53                   	push   %ebx
  800e69:	50                   	push   %eax
  800e6a:	53                   	push   %ebx
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 28 fe ff ff       	call   800c9a <sys_page_map>
  800e72:	83 c4 20             	add    $0x20,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	0f 89 a0 00 00 00    	jns    800f1d <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800e7d:	50                   	push   %eax
  800e7e:	68 8a 2c 80 00       	push   $0x802c8a
  800e83:	6a 4d                	push   $0x4d
  800e85:	68 a2 2c 80 00       	push   $0x802ca2
  800e8a:	e8 49 f3 ff ff       	call   8001d8 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800e8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e96:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e9c:	74 57                	je     800ef5 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	68 05 08 00 00       	push   $0x805
  800ea6:	53                   	push   %ebx
  800ea7:	50                   	push   %eax
  800ea8:	53                   	push   %ebx
  800ea9:	6a 00                	push   $0x0
  800eab:	e8 ea fd ff ff       	call   800c9a <sys_page_map>
  800eb0:	83 c4 20             	add    $0x20,%esp
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	79 12                	jns    800ec9 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800eb7:	50                   	push   %eax
  800eb8:	68 ad 2c 80 00       	push   $0x802cad
  800ebd:	6a 50                	push   $0x50
  800ebf:	68 a2 2c 80 00       	push   $0x802ca2
  800ec4:	e8 0f f3 ff ff       	call   8001d8 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	68 05 08 00 00       	push   $0x805
  800ed1:	53                   	push   %ebx
  800ed2:	6a 00                	push   $0x0
  800ed4:	53                   	push   %ebx
  800ed5:	6a 00                	push   $0x0
  800ed7:	e8 be fd ff ff       	call   800c9a <sys_page_map>
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	79 3a                	jns    800f1d <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800ee3:	50                   	push   %eax
  800ee4:	68 ad 2c 80 00       	push   $0x802cad
  800ee9:	6a 53                	push   $0x53
  800eeb:	68 a2 2c 80 00       	push   $0x802ca2
  800ef0:	e8 e3 f2 ff ff       	call   8001d8 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	6a 05                	push   $0x5
  800efa:	53                   	push   %ebx
  800efb:	50                   	push   %eax
  800efc:	53                   	push   %ebx
  800efd:	6a 00                	push   $0x0
  800eff:	e8 96 fd ff ff       	call   800c9a <sys_page_map>
  800f04:	83 c4 20             	add    $0x20,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	79 12                	jns    800f1d <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800f0b:	50                   	push   %eax
  800f0c:	68 c1 2c 80 00       	push   $0x802cc1
  800f11:	6a 56                	push   $0x56
  800f13:	68 a2 2c 80 00       	push   $0x802ca2
  800f18:	e8 bb f2 ff ff       	call   8001d8 <_panic>
	}
	return 0;
}
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f2f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f31:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f35:	74 2d                	je     800f64 <pgfault+0x3d>
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	c1 e8 16             	shr    $0x16,%eax
  800f3c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f43:	a8 01                	test   $0x1,%al
  800f45:	74 1d                	je     800f64 <pgfault+0x3d>
  800f47:	89 d8                	mov    %ebx,%eax
  800f49:	c1 e8 0c             	shr    $0xc,%eax
  800f4c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f53:	f6 c2 01             	test   $0x1,%dl
  800f56:	74 0c                	je     800f64 <pgfault+0x3d>
  800f58:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5f:	f6 c4 08             	test   $0x8,%ah
  800f62:	75 14                	jne    800f78 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 40 2d 80 00       	push   $0x802d40
  800f6c:	6a 1d                	push   $0x1d
  800f6e:	68 a2 2c 80 00       	push   $0x802ca2
  800f73:	e8 60 f2 ff ff       	call   8001d8 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800f78:	e8 9c fc ff ff       	call   800c19 <sys_getenvid>
  800f7d:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	6a 07                	push   $0x7
  800f84:	68 00 f0 7f 00       	push   $0x7ff000
  800f89:	50                   	push   %eax
  800f8a:	e8 c8 fc ff ff       	call   800c57 <sys_page_alloc>
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	79 12                	jns    800fa8 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800f96:	50                   	push   %eax
  800f97:	68 70 2d 80 00       	push   $0x802d70
  800f9c:	6a 2b                	push   $0x2b
  800f9e:	68 a2 2c 80 00       	push   $0x802ca2
  800fa3:	e8 30 f2 ff ff       	call   8001d8 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  800fa8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 00 10 00 00       	push   $0x1000
  800fb6:	53                   	push   %ebx
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	e8 8d fa ff ff       	call   800a4e <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  800fc1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fc8:	53                   	push   %ebx
  800fc9:	56                   	push   %esi
  800fca:	68 00 f0 7f 00       	push   $0x7ff000
  800fcf:	56                   	push   %esi
  800fd0:	e8 c5 fc ff ff       	call   800c9a <sys_page_map>
  800fd5:	83 c4 20             	add    $0x20,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	79 12                	jns    800fee <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  800fdc:	50                   	push   %eax
  800fdd:	68 d4 2c 80 00       	push   $0x802cd4
  800fe2:	6a 2f                	push   $0x2f
  800fe4:	68 a2 2c 80 00       	push   $0x802ca2
  800fe9:	e8 ea f1 ff ff       	call   8001d8 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	68 00 f0 7f 00       	push   $0x7ff000
  800ff6:	56                   	push   %esi
  800ff7:	e8 e0 fc ff ff       	call   800cdc <sys_page_unmap>
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 12                	jns    801015 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  801003:	50                   	push   %eax
  801004:	68 94 2d 80 00       	push   $0x802d94
  801009:	6a 32                	push   $0x32
  80100b:	68 a2 2c 80 00       	push   $0x802ca2
  801010:	e8 c3 f1 ff ff       	call   8001d8 <_panic>
	//panic("pgfault not implemented");
}
  801015:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801024:	68 27 0f 80 00       	push   $0x800f27
  801029:	e8 17 14 00 00       	call   802445 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80102e:	b8 07 00 00 00       	mov    $0x7,%eax
  801033:	cd 30                	int    $0x30
  801035:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	79 12                	jns    801050 <fork+0x34>
		panic("sys_exofork:%e", envid);
  80103e:	50                   	push   %eax
  80103f:	68 f1 2c 80 00       	push   $0x802cf1
  801044:	6a 75                	push   $0x75
  801046:	68 a2 2c 80 00       	push   $0x802ca2
  80104b:	e8 88 f1 ff ff       	call   8001d8 <_panic>
  801050:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  801052:	85 c0                	test   %eax,%eax
  801054:	75 21                	jne    801077 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  801056:	e8 be fb ff ff       	call   800c19 <sys_getenvid>
  80105b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801060:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801068:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80106d:	b8 00 00 00 00       	mov    $0x0,%eax
  801072:	e9 c0 00 00 00       	jmp    801137 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801077:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80107e:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801083:	89 d0                	mov    %edx,%eax
  801085:	c1 e8 16             	shr    $0x16,%eax
  801088:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108f:	a8 01                	test   $0x1,%al
  801091:	74 20                	je     8010b3 <fork+0x97>
  801093:	c1 ea 0c             	shr    $0xc,%edx
  801096:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80109d:	a8 01                	test   $0x1,%al
  80109f:	74 12                	je     8010b3 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8010a1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010a8:	a8 04                	test   $0x4,%al
  8010aa:	74 07                	je     8010b3 <fork+0x97>
			duppage(envid, PGNUM(addr));
  8010ac:	89 f0                	mov    %esi,%eax
  8010ae:	e8 95 fd ff ff       	call   800e48 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8010b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b6:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  8010bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010bf:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  8010c5:	76 bc                	jbe    801083 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  8010c7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010ca:	c1 ea 0c             	shr    $0xc,%edx
  8010cd:	89 d8                	mov    %ebx,%eax
  8010cf:	e8 74 fd ff ff       	call   800e48 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	6a 07                	push   $0x7
  8010d9:	68 00 f0 bf ee       	push   $0xeebff000
  8010de:	53                   	push   %ebx
  8010df:	e8 73 fb ff ff       	call   800c57 <sys_page_alloc>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	74 15                	je     801100 <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  8010eb:	50                   	push   %eax
  8010ec:	68 00 2d 80 00       	push   $0x802d00
  8010f1:	68 86 00 00 00       	push   $0x86
  8010f6:	68 a2 2c 80 00       	push   $0x802ca2
  8010fb:	e8 d8 f0 ff ff       	call   8001d8 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	68 ad 24 80 00       	push   $0x8024ad
  801108:	53                   	push   %ebx
  801109:	e8 94 fc ff ff       	call   800da2 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80110e:	83 c4 08             	add    $0x8,%esp
  801111:	6a 02                	push   $0x2
  801113:	53                   	push   %ebx
  801114:	e8 05 fc ff ff       	call   800d1e <sys_env_set_status>
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	74 15                	je     801135 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  801120:	50                   	push   %eax
  801121:	68 12 2d 80 00       	push   $0x802d12
  801126:	68 8c 00 00 00       	push   $0x8c
  80112b:	68 a2 2c 80 00       	push   $0x802ca2
  801130:	e8 a3 f0 ff ff       	call   8001d8 <_panic>

	return envid;
  801135:	89 d8                	mov    %ebx,%eax
	    
}
  801137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80113a:	5b                   	pop    %ebx
  80113b:	5e                   	pop    %esi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <sfork>:

// Challenge!
int
sfork(void)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801144:	68 28 2d 80 00       	push   $0x802d28
  801149:	68 96 00 00 00       	push   $0x96
  80114e:	68 a2 2c 80 00       	push   $0x802ca2
  801153:	e8 80 f0 ff ff       	call   8001d8 <_panic>

00801158 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	05 00 00 00 30       	add    $0x30000000,%eax
  801163:	c1 e8 0c             	shr    $0xc,%eax
}
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	05 00 00 00 30       	add    $0x30000000,%eax
  801173:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801178:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801185:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	c1 ea 16             	shr    $0x16,%edx
  80118f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801196:	f6 c2 01             	test   $0x1,%dl
  801199:	74 11                	je     8011ac <fd_alloc+0x2d>
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	c1 ea 0c             	shr    $0xc,%edx
  8011a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	75 09                	jne    8011b5 <fd_alloc+0x36>
			*fd_store = fd;
  8011ac:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b3:	eb 17                	jmp    8011cc <fd_alloc+0x4d>
  8011b5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011bf:	75 c9                	jne    80118a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011c7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d4:	83 f8 1f             	cmp    $0x1f,%eax
  8011d7:	77 36                	ja     80120f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d9:	c1 e0 0c             	shl    $0xc,%eax
  8011dc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	c1 ea 16             	shr    $0x16,%edx
  8011e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ed:	f6 c2 01             	test   $0x1,%dl
  8011f0:	74 24                	je     801216 <fd_lookup+0x48>
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	c1 ea 0c             	shr    $0xc,%edx
  8011f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fe:	f6 c2 01             	test   $0x1,%dl
  801201:	74 1a                	je     80121d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801203:	8b 55 0c             	mov    0xc(%ebp),%edx
  801206:	89 02                	mov    %eax,(%edx)
	return 0;
  801208:	b8 00 00 00 00       	mov    $0x0,%eax
  80120d:	eb 13                	jmp    801222 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801214:	eb 0c                	jmp    801222 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801216:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121b:	eb 05                	jmp    801222 <fd_lookup+0x54>
  80121d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122d:	ba 30 2e 80 00       	mov    $0x802e30,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801232:	eb 13                	jmp    801247 <dev_lookup+0x23>
  801234:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801237:	39 08                	cmp    %ecx,(%eax)
  801239:	75 0c                	jne    801247 <dev_lookup+0x23>
			*dev = devtab[i];
  80123b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	eb 2e                	jmp    801275 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801247:	8b 02                	mov    (%edx),%eax
  801249:	85 c0                	test   %eax,%eax
  80124b:	75 e7                	jne    801234 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80124d:	a1 04 40 80 00       	mov    0x804004,%eax
  801252:	8b 40 48             	mov    0x48(%eax),%eax
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	51                   	push   %ecx
  801259:	50                   	push   %eax
  80125a:	68 b4 2d 80 00       	push   $0x802db4
  80125f:	e8 4d f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801264:	8b 45 0c             	mov    0xc(%ebp),%eax
  801267:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
  80127c:	83 ec 10             	sub    $0x10,%esp
  80127f:	8b 75 08             	mov    0x8(%ebp),%esi
  801282:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801285:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80128f:	c1 e8 0c             	shr    $0xc,%eax
  801292:	50                   	push   %eax
  801293:	e8 36 ff ff ff       	call   8011ce <fd_lookup>
  801298:	83 c4 08             	add    $0x8,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 05                	js     8012a4 <fd_close+0x2d>
	    || fd != fd2)
  80129f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012a2:	74 0c                	je     8012b0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012a4:	84 db                	test   %bl,%bl
  8012a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ab:	0f 44 c2             	cmove  %edx,%eax
  8012ae:	eb 41                	jmp    8012f1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b6:	50                   	push   %eax
  8012b7:	ff 36                	pushl  (%esi)
  8012b9:	e8 66 ff ff ff       	call   801224 <dev_lookup>
  8012be:	89 c3                	mov    %eax,%ebx
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 1a                	js     8012e1 <fd_close+0x6a>
		if (dev->dev_close)
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	74 0b                	je     8012e1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	56                   	push   %esi
  8012da:	ff d0                	call   *%eax
  8012dc:	89 c3                	mov    %eax,%ebx
  8012de:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	56                   	push   %esi
  8012e5:	6a 00                	push   $0x0
  8012e7:	e8 f0 f9 ff ff       	call   800cdc <sys_page_unmap>
	return r;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	89 d8                	mov    %ebx,%eax
}
  8012f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 c4 fe ff ff       	call   8011ce <fd_lookup>
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 10                	js     801321 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	6a 01                	push   $0x1
  801316:	ff 75 f4             	pushl  -0xc(%ebp)
  801319:	e8 59 ff ff ff       	call   801277 <fd_close>
  80131e:	83 c4 10             	add    $0x10,%esp
}
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <close_all>:

void
close_all(void)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	53                   	push   %ebx
  801327:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80132a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132f:	83 ec 0c             	sub    $0xc,%esp
  801332:	53                   	push   %ebx
  801333:	e8 c0 ff ff ff       	call   8012f8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801338:	83 c3 01             	add    $0x1,%ebx
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	83 fb 20             	cmp    $0x20,%ebx
  801341:	75 ec                	jne    80132f <close_all+0xc>
		close(i);
}
  801343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	57                   	push   %edi
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 2c             	sub    $0x2c,%esp
  801351:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801354:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 6e fe ff ff       	call   8011ce <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	0f 88 c1 00 00 00    	js     80142c <dup+0xe4>
		return r;
	close(newfdnum);
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	56                   	push   %esi
  80136f:	e8 84 ff ff ff       	call   8012f8 <close>

	newfd = INDEX2FD(newfdnum);
  801374:	89 f3                	mov    %esi,%ebx
  801376:	c1 e3 0c             	shl    $0xc,%ebx
  801379:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80137f:	83 c4 04             	add    $0x4,%esp
  801382:	ff 75 e4             	pushl  -0x1c(%ebp)
  801385:	e8 de fd ff ff       	call   801168 <fd2data>
  80138a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80138c:	89 1c 24             	mov    %ebx,(%esp)
  80138f:	e8 d4 fd ff ff       	call   801168 <fd2data>
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80139a:	89 f8                	mov    %edi,%eax
  80139c:	c1 e8 16             	shr    $0x16,%eax
  80139f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a6:	a8 01                	test   $0x1,%al
  8013a8:	74 37                	je     8013e1 <dup+0x99>
  8013aa:	89 f8                	mov    %edi,%eax
  8013ac:	c1 e8 0c             	shr    $0xc,%eax
  8013af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b6:	f6 c2 01             	test   $0x1,%dl
  8013b9:	74 26                	je     8013e1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c2:	83 ec 0c             	sub    $0xc,%esp
  8013c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ca:	50                   	push   %eax
  8013cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ce:	6a 00                	push   $0x0
  8013d0:	57                   	push   %edi
  8013d1:	6a 00                	push   $0x0
  8013d3:	e8 c2 f8 ff ff       	call   800c9a <sys_page_map>
  8013d8:	89 c7                	mov    %eax,%edi
  8013da:	83 c4 20             	add    $0x20,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 2e                	js     80140f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013e4:	89 d0                	mov    %edx,%eax
  8013e6:	c1 e8 0c             	shr    $0xc,%eax
  8013e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f8:	50                   	push   %eax
  8013f9:	53                   	push   %ebx
  8013fa:	6a 00                	push   $0x0
  8013fc:	52                   	push   %edx
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 96 f8 ff ff       	call   800c9a <sys_page_map>
  801404:	89 c7                	mov    %eax,%edi
  801406:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801409:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140b:	85 ff                	test   %edi,%edi
  80140d:	79 1d                	jns    80142c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	53                   	push   %ebx
  801413:	6a 00                	push   $0x0
  801415:	e8 c2 f8 ff ff       	call   800cdc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80141a:	83 c4 08             	add    $0x8,%esp
  80141d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801420:	6a 00                	push   $0x0
  801422:	e8 b5 f8 ff ff       	call   800cdc <sys_page_unmap>
	return r;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	89 f8                	mov    %edi,%eax
}
  80142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	53                   	push   %ebx
  801438:	83 ec 14             	sub    $0x14,%esp
  80143b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	53                   	push   %ebx
  801443:	e8 86 fd ff ff       	call   8011ce <fd_lookup>
  801448:	83 c4 08             	add    $0x8,%esp
  80144b:	89 c2                	mov    %eax,%edx
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 6d                	js     8014be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145b:	ff 30                	pushl  (%eax)
  80145d:	e8 c2 fd ff ff       	call   801224 <dev_lookup>
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 4c                	js     8014b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801469:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80146c:	8b 42 08             	mov    0x8(%edx),%eax
  80146f:	83 e0 03             	and    $0x3,%eax
  801472:	83 f8 01             	cmp    $0x1,%eax
  801475:	75 21                	jne    801498 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801477:	a1 04 40 80 00       	mov    0x804004,%eax
  80147c:	8b 40 48             	mov    0x48(%eax),%eax
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	53                   	push   %ebx
  801483:	50                   	push   %eax
  801484:	68 f5 2d 80 00       	push   $0x802df5
  801489:	e8 23 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801496:	eb 26                	jmp    8014be <read+0x8a>
	}
	if (!dev->dev_read)
  801498:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149b:	8b 40 08             	mov    0x8(%eax),%eax
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	74 17                	je     8014b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	ff 75 10             	pushl  0x10(%ebp)
  8014a8:	ff 75 0c             	pushl  0xc(%ebp)
  8014ab:	52                   	push   %edx
  8014ac:	ff d0                	call   *%eax
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	eb 09                	jmp    8014be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	eb 05                	jmp    8014be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014be:	89 d0                	mov    %edx,%eax
  8014c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	57                   	push   %edi
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 0c             	sub    $0xc,%esp
  8014ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d9:	eb 21                	jmp    8014fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014db:	83 ec 04             	sub    $0x4,%esp
  8014de:	89 f0                	mov    %esi,%eax
  8014e0:	29 d8                	sub    %ebx,%eax
  8014e2:	50                   	push   %eax
  8014e3:	89 d8                	mov    %ebx,%eax
  8014e5:	03 45 0c             	add    0xc(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	57                   	push   %edi
  8014ea:	e8 45 ff ff ff       	call   801434 <read>
		if (m < 0)
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 10                	js     801506 <readn+0x41>
			return m;
		if (m == 0)
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	74 0a                	je     801504 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fa:	01 c3                	add    %eax,%ebx
  8014fc:	39 f3                	cmp    %esi,%ebx
  8014fe:	72 db                	jb     8014db <readn+0x16>
  801500:	89 d8                	mov    %ebx,%eax
  801502:	eb 02                	jmp    801506 <readn+0x41>
  801504:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801506:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801509:	5b                   	pop    %ebx
  80150a:	5e                   	pop    %esi
  80150b:	5f                   	pop    %edi
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    

0080150e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	53                   	push   %ebx
  801512:	83 ec 14             	sub    $0x14,%esp
  801515:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801518:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	53                   	push   %ebx
  80151d:	e8 ac fc ff ff       	call   8011ce <fd_lookup>
  801522:	83 c4 08             	add    $0x8,%esp
  801525:	89 c2                	mov    %eax,%edx
  801527:	85 c0                	test   %eax,%eax
  801529:	78 68                	js     801593 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152b:	83 ec 08             	sub    $0x8,%esp
  80152e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	ff 30                	pushl  (%eax)
  801537:	e8 e8 fc ff ff       	call   801224 <dev_lookup>
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 47                	js     80158a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154a:	75 21                	jne    80156d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80154c:	a1 04 40 80 00       	mov    0x804004,%eax
  801551:	8b 40 48             	mov    0x48(%eax),%eax
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	53                   	push   %ebx
  801558:	50                   	push   %eax
  801559:	68 11 2e 80 00       	push   $0x802e11
  80155e:	e8 4e ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156b:	eb 26                	jmp    801593 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80156d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801570:	8b 52 0c             	mov    0xc(%edx),%edx
  801573:	85 d2                	test   %edx,%edx
  801575:	74 17                	je     80158e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	ff 75 10             	pushl  0x10(%ebp)
  80157d:	ff 75 0c             	pushl  0xc(%ebp)
  801580:	50                   	push   %eax
  801581:	ff d2                	call   *%edx
  801583:	89 c2                	mov    %eax,%edx
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	eb 09                	jmp    801593 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	eb 05                	jmp    801593 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80158e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801593:	89 d0                	mov    %edx,%eax
  801595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <seek>:

int
seek(int fdnum, off_t offset)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	e8 22 fc ff ff       	call   8011ce <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 0e                	js     8015c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 14             	sub    $0x14,%esp
  8015ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	53                   	push   %ebx
  8015d2:	e8 f7 fb ff ff       	call   8011ce <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 65                	js     801645 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	ff 30                	pushl  (%eax)
  8015ec:	e8 33 fc ff ff       	call   801224 <dev_lookup>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 44                	js     80163c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ff:	75 21                	jne    801622 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801601:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801606:	8b 40 48             	mov    0x48(%eax),%eax
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	53                   	push   %ebx
  80160d:	50                   	push   %eax
  80160e:	68 d4 2d 80 00       	push   $0x802dd4
  801613:	e8 99 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801620:	eb 23                	jmp    801645 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801622:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801625:	8b 52 18             	mov    0x18(%edx),%edx
  801628:	85 d2                	test   %edx,%edx
  80162a:	74 14                	je     801640 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	ff 75 0c             	pushl  0xc(%ebp)
  801632:	50                   	push   %eax
  801633:	ff d2                	call   *%edx
  801635:	89 c2                	mov    %eax,%edx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	eb 09                	jmp    801645 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	eb 05                	jmp    801645 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801640:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801645:	89 d0                	mov    %edx,%eax
  801647:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	53                   	push   %ebx
  801650:	83 ec 14             	sub    $0x14,%esp
  801653:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801656:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801659:	50                   	push   %eax
  80165a:	ff 75 08             	pushl  0x8(%ebp)
  80165d:	e8 6c fb ff ff       	call   8011ce <fd_lookup>
  801662:	83 c4 08             	add    $0x8,%esp
  801665:	89 c2                	mov    %eax,%edx
  801667:	85 c0                	test   %eax,%eax
  801669:	78 58                	js     8016c3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	ff 30                	pushl  (%eax)
  801677:	e8 a8 fb ff ff       	call   801224 <dev_lookup>
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 37                	js     8016ba <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801686:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80168a:	74 32                	je     8016be <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80168c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801696:	00 00 00 
	stat->st_isdir = 0;
  801699:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a0:	00 00 00 
	stat->st_dev = dev;
  8016a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	53                   	push   %ebx
  8016ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b0:	ff 50 14             	call   *0x14(%eax)
  8016b3:	89 c2                	mov    %eax,%edx
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	eb 09                	jmp    8016c3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	eb 05                	jmp    8016c3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016c3:	89 d0                	mov    %edx,%eax
  8016c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	56                   	push   %esi
  8016ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	6a 00                	push   $0x0
  8016d4:	ff 75 08             	pushl  0x8(%ebp)
  8016d7:	e8 e3 01 00 00       	call   8018bf <open>
  8016dc:	89 c3                	mov    %eax,%ebx
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 1b                	js     801700 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	50                   	push   %eax
  8016ec:	e8 5b ff ff ff       	call   80164c <fstat>
  8016f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f3:	89 1c 24             	mov    %ebx,(%esp)
  8016f6:	e8 fd fb ff ff       	call   8012f8 <close>
	return r;
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	89 f0                	mov    %esi,%eax
}
  801700:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	89 c6                	mov    %eax,%esi
  80170e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801710:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801717:	75 12                	jne    80172b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801719:	83 ec 0c             	sub    $0xc,%esp
  80171c:	6a 01                	push   $0x1
  80171e:	e8 57 0e 00 00       	call   80257a <ipc_find_env>
  801723:	a3 00 40 80 00       	mov    %eax,0x804000
  801728:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80172b:	6a 07                	push   $0x7
  80172d:	68 00 50 80 00       	push   $0x805000
  801732:	56                   	push   %esi
  801733:	ff 35 00 40 80 00    	pushl  0x804000
  801739:	e8 e8 0d 00 00       	call   802526 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80173e:	83 c4 0c             	add    $0xc,%esp
  801741:	6a 00                	push   $0x0
  801743:	53                   	push   %ebx
  801744:	6a 00                	push   $0x0
  801746:	e8 86 0d 00 00       	call   8024d1 <ipc_recv>
}
  80174b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8b 40 0c             	mov    0xc(%eax),%eax
  80175e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801763:	8b 45 0c             	mov    0xc(%ebp),%eax
  801766:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80176b:	ba 00 00 00 00       	mov    $0x0,%edx
  801770:	b8 02 00 00 00       	mov    $0x2,%eax
  801775:	e8 8d ff ff ff       	call   801707 <fsipc>
}
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	8b 40 0c             	mov    0xc(%eax),%eax
  801788:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80178d:	ba 00 00 00 00       	mov    $0x0,%edx
  801792:	b8 06 00 00 00       	mov    $0x6,%eax
  801797:	e8 6b ff ff ff       	call   801707 <fsipc>
}
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017bd:	e8 45 ff ff ff       	call   801707 <fsipc>
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 2c                	js     8017f2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	68 00 50 80 00       	push   $0x805000
  8017ce:	53                   	push   %ebx
  8017cf:	e8 80 f0 ff ff       	call   800854 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017df:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 0c             	sub    $0xc,%esp
  8017fd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801800:	8b 55 08             	mov    0x8(%ebp),%edx
  801803:	8b 52 0c             	mov    0xc(%edx),%edx
  801806:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80180c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801811:	ba 00 10 00 00       	mov    $0x1000,%edx
  801816:	0f 47 c2             	cmova  %edx,%eax
  801819:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80181e:	50                   	push   %eax
  80181f:	ff 75 0c             	pushl  0xc(%ebp)
  801822:	68 08 50 80 00       	push   $0x805008
  801827:	e8 ba f1 ff ff       	call   8009e6 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80182c:	ba 00 00 00 00       	mov    $0x0,%edx
  801831:	b8 04 00 00 00       	mov    $0x4,%eax
  801836:	e8 cc fe ff ff       	call   801707 <fsipc>
    return r;
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	8b 40 0c             	mov    0xc(%eax),%eax
  80184b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801850:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 03 00 00 00       	mov    $0x3,%eax
  801860:	e8 a2 fe ff ff       	call   801707 <fsipc>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	85 c0                	test   %eax,%eax
  801869:	78 4b                	js     8018b6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80186b:	39 c6                	cmp    %eax,%esi
  80186d:	73 16                	jae    801885 <devfile_read+0x48>
  80186f:	68 40 2e 80 00       	push   $0x802e40
  801874:	68 47 2e 80 00       	push   $0x802e47
  801879:	6a 7c                	push   $0x7c
  80187b:	68 5c 2e 80 00       	push   $0x802e5c
  801880:	e8 53 e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801885:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80188a:	7e 16                	jle    8018a2 <devfile_read+0x65>
  80188c:	68 67 2e 80 00       	push   $0x802e67
  801891:	68 47 2e 80 00       	push   $0x802e47
  801896:	6a 7d                	push   $0x7d
  801898:	68 5c 2e 80 00       	push   $0x802e5c
  80189d:	e8 36 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	50                   	push   %eax
  8018a6:	68 00 50 80 00       	push   $0x805000
  8018ab:	ff 75 0c             	pushl  0xc(%ebp)
  8018ae:	e8 33 f1 ff ff       	call   8009e6 <memmove>
	return r;
  8018b3:	83 c4 10             	add    $0x10,%esp
}
  8018b6:	89 d8                	mov    %ebx,%eax
  8018b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 20             	sub    $0x20,%esp
  8018c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c9:	53                   	push   %ebx
  8018ca:	e8 4c ef ff ff       	call   80081b <strlen>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d7:	7f 67                	jg     801940 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	e8 9a f8 ff ff       	call   80117f <fd_alloc>
  8018e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 57                	js     801945 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	53                   	push   %ebx
  8018f2:	68 00 50 80 00       	push   $0x805000
  8018f7:	e8 58 ef ff ff       	call   800854 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801904:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801907:	b8 01 00 00 00       	mov    $0x1,%eax
  80190c:	e8 f6 fd ff ff       	call   801707 <fsipc>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	79 14                	jns    80192e <open+0x6f>
		fd_close(fd, 0);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	6a 00                	push   $0x0
  80191f:	ff 75 f4             	pushl  -0xc(%ebp)
  801922:	e8 50 f9 ff ff       	call   801277 <fd_close>
		return r;
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	89 da                	mov    %ebx,%edx
  80192c:	eb 17                	jmp    801945 <open+0x86>
	}

	return fd2num(fd);
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	ff 75 f4             	pushl  -0xc(%ebp)
  801934:	e8 1f f8 ff ff       	call   801158 <fd2num>
  801939:	89 c2                	mov    %eax,%edx
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	eb 05                	jmp    801945 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801940:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801945:	89 d0                	mov    %edx,%eax
  801947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801952:	ba 00 00 00 00       	mov    $0x0,%edx
  801957:	b8 08 00 00 00       	mov    $0x8,%eax
  80195c:	e8 a6 fd ff ff       	call   801707 <fsipc>
}
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	57                   	push   %edi
  801967:	56                   	push   %esi
  801968:	53                   	push   %ebx
  801969:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80196f:	6a 00                	push   $0x0
  801971:	ff 75 08             	pushl  0x8(%ebp)
  801974:	e8 46 ff ff ff       	call   8018bf <open>
  801979:	89 c7                	mov    %eax,%edi
  80197b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	0f 88 ae 04 00 00    	js     801e3a <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	68 00 02 00 00       	push   $0x200
  801994:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	57                   	push   %edi
  80199c:	e8 24 fb ff ff       	call   8014c5 <readn>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019a9:	75 0c                	jne    8019b7 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019ab:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019b2:	45 4c 46 
  8019b5:	74 33                	je     8019ea <spawn+0x87>
		close(fd);
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c0:	e8 33 f9 ff ff       	call   8012f8 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019c5:	83 c4 0c             	add    $0xc,%esp
  8019c8:	68 7f 45 4c 46       	push   $0x464c457f
  8019cd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019d3:	68 73 2e 80 00       	push   $0x802e73
  8019d8:	e8 d4 e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019e5:	e9 b0 04 00 00       	jmp    801e9a <spawn+0x537>
  8019ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8019ef:	cd 30                	int    $0x30
  8019f1:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019f7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	0f 88 3d 04 00 00    	js     801e42 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a05:	89 c6                	mov    %eax,%esi
  801a07:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a0d:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a10:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a16:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a1c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a23:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a29:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a2f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a34:	be 00 00 00 00       	mov    $0x0,%esi
  801a39:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a3c:	eb 13                	jmp    801a51 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	50                   	push   %eax
  801a42:	e8 d4 ed ff ff       	call   80081b <strlen>
  801a47:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a4b:	83 c3 01             	add    $0x1,%ebx
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a58:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	75 df                	jne    801a3e <spawn+0xdb>
  801a5f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a65:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a6b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a70:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a72:	89 fa                	mov    %edi,%edx
  801a74:	83 e2 fc             	and    $0xfffffffc,%edx
  801a77:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a7e:	29 c2                	sub    %eax,%edx
  801a80:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a86:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a89:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a8e:	0f 86 be 03 00 00    	jbe    801e52 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	6a 07                	push   $0x7
  801a99:	68 00 00 40 00       	push   $0x400000
  801a9e:	6a 00                	push   $0x0
  801aa0:	e8 b2 f1 ff ff       	call   800c57 <sys_page_alloc>
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	0f 88 a9 03 00 00    	js     801e59 <spawn+0x4f6>
  801ab0:	be 00 00 00 00       	mov    $0x0,%esi
  801ab5:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801abb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801abe:	eb 30                	jmp    801af0 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ac0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ac6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801acc:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801acf:	83 ec 08             	sub    $0x8,%esp
  801ad2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ad5:	57                   	push   %edi
  801ad6:	e8 79 ed ff ff       	call   800854 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801adb:	83 c4 04             	add    $0x4,%esp
  801ade:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ae1:	e8 35 ed ff ff       	call   80081b <strlen>
  801ae6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aea:	83 c6 01             	add    $0x1,%esi
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801af6:	7f c8                	jg     801ac0 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801af8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801afe:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b04:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b0b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b11:	74 19                	je     801b2c <spawn+0x1c9>
  801b13:	68 e8 2e 80 00       	push   $0x802ee8
  801b18:	68 47 2e 80 00       	push   $0x802e47
  801b1d:	68 f2 00 00 00       	push   $0xf2
  801b22:	68 8d 2e 80 00       	push   $0x802e8d
  801b27:	e8 ac e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b2c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b32:	89 f8                	mov    %edi,%eax
  801b34:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b39:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b3c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b42:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b45:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b4b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	6a 07                	push   $0x7
  801b56:	68 00 d0 bf ee       	push   $0xeebfd000
  801b5b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b61:	68 00 00 40 00       	push   $0x400000
  801b66:	6a 00                	push   $0x0
  801b68:	e8 2d f1 ff ff       	call   800c9a <sys_page_map>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	83 c4 20             	add    $0x20,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	0f 88 0e 03 00 00    	js     801e88 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	68 00 00 40 00       	push   $0x400000
  801b82:	6a 00                	push   $0x0
  801b84:	e8 53 f1 ff ff       	call   800cdc <sys_page_unmap>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	0f 88 f2 02 00 00    	js     801e88 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b96:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b9c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ba3:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ba9:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bb0:	00 00 00 
  801bb3:	e9 88 01 00 00       	jmp    801d40 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801bb8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bbe:	83 38 01             	cmpl   $0x1,(%eax)
  801bc1:	0f 85 6b 01 00 00    	jne    801d32 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bc7:	89 c7                	mov    %eax,%edi
  801bc9:	8b 40 18             	mov    0x18(%eax),%eax
  801bcc:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bd2:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bd5:	83 f8 01             	cmp    $0x1,%eax
  801bd8:	19 c0                	sbb    %eax,%eax
  801bda:	83 e0 fe             	and    $0xfffffffe,%eax
  801bdd:	83 c0 07             	add    $0x7,%eax
  801be0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801be6:	89 f8                	mov    %edi,%eax
  801be8:	8b 7f 04             	mov    0x4(%edi),%edi
  801beb:	89 f9                	mov    %edi,%ecx
  801bed:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801bf3:	8b 78 10             	mov    0x10(%eax),%edi
  801bf6:	8b 50 14             	mov    0x14(%eax),%edx
  801bf9:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801bff:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c09:	74 14                	je     801c1f <spawn+0x2bc>
		va -= i;
  801c0b:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c0d:	01 c2                	add    %eax,%edx
  801c0f:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c15:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c17:	29 c1                	sub    %eax,%ecx
  801c19:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c24:	e9 f7 00 00 00       	jmp    801d20 <spawn+0x3bd>
		if (i >= filesz) {
  801c29:	39 df                	cmp    %ebx,%edi
  801c2b:	77 27                	ja     801c54 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c36:	56                   	push   %esi
  801c37:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c3d:	e8 15 f0 ff ff       	call   800c57 <sys_page_alloc>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	0f 89 c7 00 00 00    	jns    801d14 <spawn+0x3b1>
  801c4d:	89 c3                	mov    %eax,%ebx
  801c4f:	e9 13 02 00 00       	jmp    801e67 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	6a 07                	push   $0x7
  801c59:	68 00 00 40 00       	push   $0x400000
  801c5e:	6a 00                	push   $0x0
  801c60:	e8 f2 ef ff ff       	call   800c57 <sys_page_alloc>
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	0f 88 ed 01 00 00    	js     801e5d <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c79:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c86:	e8 0f f9 ff ff       	call   80159a <seek>
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	0f 88 cb 01 00 00    	js     801e61 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c96:	83 ec 04             	sub    $0x4,%esp
  801c99:	89 f8                	mov    %edi,%eax
  801c9b:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ca1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca6:	ba 00 10 00 00       	mov    $0x1000,%edx
  801cab:	0f 47 c2             	cmova  %edx,%eax
  801cae:	50                   	push   %eax
  801caf:	68 00 00 40 00       	push   $0x400000
  801cb4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cba:	e8 06 f8 ff ff       	call   8014c5 <readn>
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	0f 88 9b 01 00 00    	js     801e65 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cd3:	56                   	push   %esi
  801cd4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cda:	68 00 00 40 00       	push   $0x400000
  801cdf:	6a 00                	push   $0x0
  801ce1:	e8 b4 ef ff ff       	call   800c9a <sys_page_map>
  801ce6:	83 c4 20             	add    $0x20,%esp
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	79 15                	jns    801d02 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801ced:	50                   	push   %eax
  801cee:	68 99 2e 80 00       	push   $0x802e99
  801cf3:	68 25 01 00 00       	push   $0x125
  801cf8:	68 8d 2e 80 00       	push   $0x802e8d
  801cfd:	e8 d6 e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	68 00 00 40 00       	push   $0x400000
  801d0a:	6a 00                	push   $0x0
  801d0c:	e8 cb ef ff ff       	call   800cdc <sys_page_unmap>
  801d11:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d14:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d1a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d20:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d26:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801d2c:	0f 87 f7 fe ff ff    	ja     801c29 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d32:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d39:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d40:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d47:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d4d:	0f 8c 65 fe ff ff    	jl     801bb8 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d5c:	e8 97 f5 ff ff       	call   8012f8 <close>
  801d61:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d69:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801d6f:	89 d8                	mov    %ebx,%eax
  801d71:	c1 e8 16             	shr    $0x16,%eax
  801d74:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d7b:	a8 01                	test   $0x1,%al
  801d7d:	74 46                	je     801dc5 <spawn+0x462>
  801d7f:	89 d8                	mov    %ebx,%eax
  801d81:	c1 e8 0c             	shr    $0xc,%eax
  801d84:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d8b:	f6 c2 01             	test   $0x1,%dl
  801d8e:	74 35                	je     801dc5 <spawn+0x462>
  801d90:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d97:	f6 c2 04             	test   $0x4,%dl
  801d9a:	74 29                	je     801dc5 <spawn+0x462>
  801d9c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801da3:	f6 c6 04             	test   $0x4,%dh
  801da6:	74 1d                	je     801dc5 <spawn+0x462>
			// cprintf("copy shared page %d to env:%x\n", PGNUM(addr), child);
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801da8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801daf:	83 ec 0c             	sub    $0xc,%esp
  801db2:	25 07 0e 00 00       	and    $0xe07,%eax
  801db7:	50                   	push   %eax
  801db8:	53                   	push   %ebx
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 d8 ee ff ff       	call   800c9a <sys_page_map>
  801dc2:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801dc5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dcb:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801dd1:	75 9c                	jne    801d6f <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801dd3:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801dda:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ddd:	83 ec 08             	sub    $0x8,%esp
  801de0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801de6:	50                   	push   %eax
  801de7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ded:	e8 6e ef ff ff       	call   800d60 <sys_env_set_trapframe>
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	79 15                	jns    801e0e <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801df9:	50                   	push   %eax
  801dfa:	68 b6 2e 80 00       	push   $0x802eb6
  801dff:	68 86 00 00 00       	push   $0x86
  801e04:	68 8d 2e 80 00       	push   $0x802e8d
  801e09:	e8 ca e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e0e:	83 ec 08             	sub    $0x8,%esp
  801e11:	6a 02                	push   $0x2
  801e13:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e19:	e8 00 ef ff ff       	call   800d1e <sys_env_set_status>
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	79 25                	jns    801e4a <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801e25:	50                   	push   %eax
  801e26:	68 d0 2e 80 00       	push   $0x802ed0
  801e2b:	68 89 00 00 00       	push   $0x89
  801e30:	68 8d 2e 80 00       	push   $0x802e8d
  801e35:	e8 9e e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e3a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e40:	eb 58                	jmp    801e9a <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e42:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e48:	eb 50                	jmp    801e9a <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e4a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e50:	eb 48                	jmp    801e9a <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e52:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e57:	eb 41                	jmp    801e9a <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	eb 3d                	jmp    801e9a <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e5d:	89 c3                	mov    %eax,%ebx
  801e5f:	eb 06                	jmp    801e67 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	eb 02                	jmp    801e67 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e65:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e67:	83 ec 0c             	sub    $0xc,%esp
  801e6a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e70:	e8 63 ed ff ff       	call   800bd8 <sys_env_destroy>
	close(fd);
  801e75:	83 c4 04             	add    $0x4,%esp
  801e78:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e7e:	e8 75 f4 ff ff       	call   8012f8 <close>
	return r;
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	eb 12                	jmp    801e9a <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e88:	83 ec 08             	sub    $0x8,%esp
  801e8b:	68 00 00 40 00       	push   $0x400000
  801e90:	6a 00                	push   $0x0
  801e92:	e8 45 ee ff ff       	call   800cdc <sys_page_unmap>
  801e97:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e9a:	89 d8                	mov    %ebx,%eax
  801e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5f                   	pop    %edi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	56                   	push   %esi
  801ea8:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ea9:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801eac:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eb1:	eb 03                	jmp    801eb6 <spawnl+0x12>
		argc++;
  801eb3:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eb6:	83 c2 04             	add    $0x4,%edx
  801eb9:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ebd:	75 f4                	jne    801eb3 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ebf:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ec6:	83 e2 f0             	and    $0xfffffff0,%edx
  801ec9:	29 d4                	sub    %edx,%esp
  801ecb:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ecf:	c1 ea 02             	shr    $0x2,%edx
  801ed2:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ed9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801edb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ede:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ee5:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801eec:	00 
  801eed:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801eef:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef4:	eb 0a                	jmp    801f00 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ef6:	83 c0 01             	add    $0x1,%eax
  801ef9:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801efd:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f00:	39 d0                	cmp    %edx,%eax
  801f02:	75 f2                	jne    801ef6 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f04:	83 ec 08             	sub    $0x8,%esp
  801f07:	56                   	push   %esi
  801f08:	ff 75 08             	pushl  0x8(%ebp)
  801f0b:	e8 53 fa ff ff       	call   801963 <spawn>
}
  801f10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    

00801f17 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f1f:	83 ec 0c             	sub    $0xc,%esp
  801f22:	ff 75 08             	pushl  0x8(%ebp)
  801f25:	e8 3e f2 ff ff       	call   801168 <fd2data>
  801f2a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f2c:	83 c4 08             	add    $0x8,%esp
  801f2f:	68 0e 2f 80 00       	push   $0x802f0e
  801f34:	53                   	push   %ebx
  801f35:	e8 1a e9 ff ff       	call   800854 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f3a:	8b 46 04             	mov    0x4(%esi),%eax
  801f3d:	2b 06                	sub    (%esi),%eax
  801f3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f45:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f4c:	00 00 00 
	stat->st_dev = &devpipe;
  801f4f:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f56:	30 80 00 
	return 0;
}
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    

00801f65 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	53                   	push   %ebx
  801f69:	83 ec 0c             	sub    $0xc,%esp
  801f6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f6f:	53                   	push   %ebx
  801f70:	6a 00                	push   $0x0
  801f72:	e8 65 ed ff ff       	call   800cdc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f77:	89 1c 24             	mov    %ebx,(%esp)
  801f7a:	e8 e9 f1 ff ff       	call   801168 <fd2data>
  801f7f:	83 c4 08             	add    $0x8,%esp
  801f82:	50                   	push   %eax
  801f83:	6a 00                	push   $0x0
  801f85:	e8 52 ed ff ff       	call   800cdc <sys_page_unmap>
}
  801f8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	57                   	push   %edi
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	83 ec 1c             	sub    $0x1c,%esp
  801f98:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f9b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f9d:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fa5:	83 ec 0c             	sub    $0xc,%esp
  801fa8:	ff 75 e0             	pushl  -0x20(%ebp)
  801fab:	e8 03 06 00 00       	call   8025b3 <pageref>
  801fb0:	89 c3                	mov    %eax,%ebx
  801fb2:	89 3c 24             	mov    %edi,(%esp)
  801fb5:	e8 f9 05 00 00       	call   8025b3 <pageref>
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	39 c3                	cmp    %eax,%ebx
  801fbf:	0f 94 c1             	sete   %cl
  801fc2:	0f b6 c9             	movzbl %cl,%ecx
  801fc5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fc8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fce:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fd1:	39 ce                	cmp    %ecx,%esi
  801fd3:	74 1b                	je     801ff0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fd5:	39 c3                	cmp    %eax,%ebx
  801fd7:	75 c4                	jne    801f9d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fd9:	8b 42 58             	mov    0x58(%edx),%eax
  801fdc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fdf:	50                   	push   %eax
  801fe0:	56                   	push   %esi
  801fe1:	68 15 2f 80 00       	push   $0x802f15
  801fe6:	e8 c6 e2 ff ff       	call   8002b1 <cprintf>
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	eb ad                	jmp    801f9d <_pipeisclosed+0xe>
	}
}
  801ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff6:	5b                   	pop    %ebx
  801ff7:	5e                   	pop    %esi
  801ff8:	5f                   	pop    %edi
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    

00801ffb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	57                   	push   %edi
  801fff:	56                   	push   %esi
  802000:	53                   	push   %ebx
  802001:	83 ec 28             	sub    $0x28,%esp
  802004:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802007:	56                   	push   %esi
  802008:	e8 5b f1 ff ff       	call   801168 <fd2data>
  80200d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	bf 00 00 00 00       	mov    $0x0,%edi
  802017:	eb 4b                	jmp    802064 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802019:	89 da                	mov    %ebx,%edx
  80201b:	89 f0                	mov    %esi,%eax
  80201d:	e8 6d ff ff ff       	call   801f8f <_pipeisclosed>
  802022:	85 c0                	test   %eax,%eax
  802024:	75 48                	jne    80206e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802026:	e8 0d ec ff ff       	call   800c38 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80202b:	8b 43 04             	mov    0x4(%ebx),%eax
  80202e:	8b 0b                	mov    (%ebx),%ecx
  802030:	8d 51 20             	lea    0x20(%ecx),%edx
  802033:	39 d0                	cmp    %edx,%eax
  802035:	73 e2                	jae    802019 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802037:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80203a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80203e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802041:	89 c2                	mov    %eax,%edx
  802043:	c1 fa 1f             	sar    $0x1f,%edx
  802046:	89 d1                	mov    %edx,%ecx
  802048:	c1 e9 1b             	shr    $0x1b,%ecx
  80204b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80204e:	83 e2 1f             	and    $0x1f,%edx
  802051:	29 ca                	sub    %ecx,%edx
  802053:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802057:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80205b:	83 c0 01             	add    $0x1,%eax
  80205e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802061:	83 c7 01             	add    $0x1,%edi
  802064:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802067:	75 c2                	jne    80202b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802069:	8b 45 10             	mov    0x10(%ebp),%eax
  80206c:	eb 05                	jmp    802073 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802073:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802076:	5b                   	pop    %ebx
  802077:	5e                   	pop    %esi
  802078:	5f                   	pop    %edi
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    

0080207b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	57                   	push   %edi
  80207f:	56                   	push   %esi
  802080:	53                   	push   %ebx
  802081:	83 ec 18             	sub    $0x18,%esp
  802084:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802087:	57                   	push   %edi
  802088:	e8 db f0 ff ff       	call   801168 <fd2data>
  80208d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	bb 00 00 00 00       	mov    $0x0,%ebx
  802097:	eb 3d                	jmp    8020d6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802099:	85 db                	test   %ebx,%ebx
  80209b:	74 04                	je     8020a1 <devpipe_read+0x26>
				return i;
  80209d:	89 d8                	mov    %ebx,%eax
  80209f:	eb 44                	jmp    8020e5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020a1:	89 f2                	mov    %esi,%edx
  8020a3:	89 f8                	mov    %edi,%eax
  8020a5:	e8 e5 fe ff ff       	call   801f8f <_pipeisclosed>
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	75 32                	jne    8020e0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020ae:	e8 85 eb ff ff       	call   800c38 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020b3:	8b 06                	mov    (%esi),%eax
  8020b5:	3b 46 04             	cmp    0x4(%esi),%eax
  8020b8:	74 df                	je     802099 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020ba:	99                   	cltd   
  8020bb:	c1 ea 1b             	shr    $0x1b,%edx
  8020be:	01 d0                	add    %edx,%eax
  8020c0:	83 e0 1f             	and    $0x1f,%eax
  8020c3:	29 d0                	sub    %edx,%eax
  8020c5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020cd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020d0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d3:	83 c3 01             	add    $0x1,%ebx
  8020d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020d9:	75 d8                	jne    8020b3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020db:	8b 45 10             	mov    0x10(%ebp),%eax
  8020de:	eb 05                	jmp    8020e5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020e0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	56                   	push   %esi
  8020f1:	53                   	push   %ebx
  8020f2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f8:	50                   	push   %eax
  8020f9:	e8 81 f0 ff ff       	call   80117f <fd_alloc>
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	89 c2                	mov    %eax,%edx
  802103:	85 c0                	test   %eax,%eax
  802105:	0f 88 2c 01 00 00    	js     802237 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80210b:	83 ec 04             	sub    $0x4,%esp
  80210e:	68 07 04 00 00       	push   $0x407
  802113:	ff 75 f4             	pushl  -0xc(%ebp)
  802116:	6a 00                	push   $0x0
  802118:	e8 3a eb ff ff       	call   800c57 <sys_page_alloc>
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	89 c2                	mov    %eax,%edx
  802122:	85 c0                	test   %eax,%eax
  802124:	0f 88 0d 01 00 00    	js     802237 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80212a:	83 ec 0c             	sub    $0xc,%esp
  80212d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802130:	50                   	push   %eax
  802131:	e8 49 f0 ff ff       	call   80117f <fd_alloc>
  802136:	89 c3                	mov    %eax,%ebx
  802138:	83 c4 10             	add    $0x10,%esp
  80213b:	85 c0                	test   %eax,%eax
  80213d:	0f 88 e2 00 00 00    	js     802225 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802143:	83 ec 04             	sub    $0x4,%esp
  802146:	68 07 04 00 00       	push   $0x407
  80214b:	ff 75 f0             	pushl  -0x10(%ebp)
  80214e:	6a 00                	push   $0x0
  802150:	e8 02 eb ff ff       	call   800c57 <sys_page_alloc>
  802155:	89 c3                	mov    %eax,%ebx
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	85 c0                	test   %eax,%eax
  80215c:	0f 88 c3 00 00 00    	js     802225 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802162:	83 ec 0c             	sub    $0xc,%esp
  802165:	ff 75 f4             	pushl  -0xc(%ebp)
  802168:	e8 fb ef ff ff       	call   801168 <fd2data>
  80216d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80216f:	83 c4 0c             	add    $0xc,%esp
  802172:	68 07 04 00 00       	push   $0x407
  802177:	50                   	push   %eax
  802178:	6a 00                	push   $0x0
  80217a:	e8 d8 ea ff ff       	call   800c57 <sys_page_alloc>
  80217f:	89 c3                	mov    %eax,%ebx
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	85 c0                	test   %eax,%eax
  802186:	0f 88 89 00 00 00    	js     802215 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218c:	83 ec 0c             	sub    $0xc,%esp
  80218f:	ff 75 f0             	pushl  -0x10(%ebp)
  802192:	e8 d1 ef ff ff       	call   801168 <fd2data>
  802197:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80219e:	50                   	push   %eax
  80219f:	6a 00                	push   $0x0
  8021a1:	56                   	push   %esi
  8021a2:	6a 00                	push   $0x0
  8021a4:	e8 f1 ea ff ff       	call   800c9a <sys_page_map>
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	83 c4 20             	add    $0x20,%esp
  8021ae:	85 c0                	test   %eax,%eax
  8021b0:	78 55                	js     802207 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021b2:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021c7:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021dc:	83 ec 0c             	sub    $0xc,%esp
  8021df:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e2:	e8 71 ef ff ff       	call   801158 <fd2num>
  8021e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ea:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ec:	83 c4 04             	add    $0x4,%esp
  8021ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f2:	e8 61 ef ff ff       	call   801158 <fd2num>
  8021f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021fa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021fd:	83 c4 10             	add    $0x10,%esp
  802200:	ba 00 00 00 00       	mov    $0x0,%edx
  802205:	eb 30                	jmp    802237 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802207:	83 ec 08             	sub    $0x8,%esp
  80220a:	56                   	push   %esi
  80220b:	6a 00                	push   $0x0
  80220d:	e8 ca ea ff ff       	call   800cdc <sys_page_unmap>
  802212:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802215:	83 ec 08             	sub    $0x8,%esp
  802218:	ff 75 f0             	pushl  -0x10(%ebp)
  80221b:	6a 00                	push   $0x0
  80221d:	e8 ba ea ff ff       	call   800cdc <sys_page_unmap>
  802222:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802225:	83 ec 08             	sub    $0x8,%esp
  802228:	ff 75 f4             	pushl  -0xc(%ebp)
  80222b:	6a 00                	push   $0x0
  80222d:	e8 aa ea ff ff       	call   800cdc <sys_page_unmap>
  802232:	83 c4 10             	add    $0x10,%esp
  802235:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802237:	89 d0                	mov    %edx,%eax
  802239:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5d                   	pop    %ebp
  80223f:	c3                   	ret    

00802240 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802246:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802249:	50                   	push   %eax
  80224a:	ff 75 08             	pushl  0x8(%ebp)
  80224d:	e8 7c ef ff ff       	call   8011ce <fd_lookup>
  802252:	83 c4 10             	add    $0x10,%esp
  802255:	85 c0                	test   %eax,%eax
  802257:	78 18                	js     802271 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802259:	83 ec 0c             	sub    $0xc,%esp
  80225c:	ff 75 f4             	pushl  -0xc(%ebp)
  80225f:	e8 04 ef ff ff       	call   801168 <fd2data>
	return _pipeisclosed(fd, p);
  802264:	89 c2                	mov    %eax,%edx
  802266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802269:	e8 21 fd ff ff       	call   801f8f <_pipeisclosed>
  80226e:	83 c4 10             	add    $0x10,%esp
}
  802271:	c9                   	leave  
  802272:	c3                   	ret    

00802273 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802273:	55                   	push   %ebp
  802274:	89 e5                	mov    %esp,%ebp
  802276:	56                   	push   %esi
  802277:	53                   	push   %ebx
  802278:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80227b:	85 f6                	test   %esi,%esi
  80227d:	75 16                	jne    802295 <wait+0x22>
  80227f:	68 2d 2f 80 00       	push   $0x802f2d
  802284:	68 47 2e 80 00       	push   $0x802e47
  802289:	6a 09                	push   $0x9
  80228b:	68 38 2f 80 00       	push   $0x802f38
  802290:	e8 43 df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802295:	89 f3                	mov    %esi,%ebx
  802297:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80229d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022a0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022a6:	eb 05                	jmp    8022ad <wait+0x3a>
		sys_yield();
  8022a8:	e8 8b e9 ff ff       	call   800c38 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022ad:	8b 43 48             	mov    0x48(%ebx),%eax
  8022b0:	39 c6                	cmp    %eax,%esi
  8022b2:	75 07                	jne    8022bb <wait+0x48>
  8022b4:	8b 43 54             	mov    0x54(%ebx),%eax
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	75 ed                	jne    8022a8 <wait+0x35>
		sys_yield();
}
  8022bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022be:	5b                   	pop    %ebx
  8022bf:	5e                   	pop    %esi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    

008022c2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    

008022cc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022d2:	68 43 2f 80 00       	push   $0x802f43
  8022d7:	ff 75 0c             	pushl  0xc(%ebp)
  8022da:	e8 75 e5 ff ff       	call   800854 <strcpy>
	return 0;
}
  8022df:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e4:	c9                   	leave  
  8022e5:	c3                   	ret    

008022e6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	57                   	push   %edi
  8022ea:	56                   	push   %esi
  8022eb:	53                   	push   %ebx
  8022ec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022fd:	eb 2d                	jmp    80232c <devcons_write+0x46>
		m = n - tot;
  8022ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802302:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802304:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802307:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80230c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80230f:	83 ec 04             	sub    $0x4,%esp
  802312:	53                   	push   %ebx
  802313:	03 45 0c             	add    0xc(%ebp),%eax
  802316:	50                   	push   %eax
  802317:	57                   	push   %edi
  802318:	e8 c9 e6 ff ff       	call   8009e6 <memmove>
		sys_cputs(buf, m);
  80231d:	83 c4 08             	add    $0x8,%esp
  802320:	53                   	push   %ebx
  802321:	57                   	push   %edi
  802322:	e8 74 e8 ff ff       	call   800b9b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802327:	01 de                	add    %ebx,%esi
  802329:	83 c4 10             	add    $0x10,%esp
  80232c:	89 f0                	mov    %esi,%eax
  80232e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802331:	72 cc                	jb     8022ff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802336:	5b                   	pop    %ebx
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    

0080233b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	83 ec 08             	sub    $0x8,%esp
  802341:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802346:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80234a:	74 2a                	je     802376 <devcons_read+0x3b>
  80234c:	eb 05                	jmp    802353 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80234e:	e8 e5 e8 ff ff       	call   800c38 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802353:	e8 61 e8 ff ff       	call   800bb9 <sys_cgetc>
  802358:	85 c0                	test   %eax,%eax
  80235a:	74 f2                	je     80234e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80235c:	85 c0                	test   %eax,%eax
  80235e:	78 16                	js     802376 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802360:	83 f8 04             	cmp    $0x4,%eax
  802363:	74 0c                	je     802371 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802365:	8b 55 0c             	mov    0xc(%ebp),%edx
  802368:	88 02                	mov    %al,(%edx)
	return 1;
  80236a:	b8 01 00 00 00       	mov    $0x1,%eax
  80236f:	eb 05                	jmp    802376 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802371:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802376:	c9                   	leave  
  802377:	c3                   	ret    

00802378 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80237e:	8b 45 08             	mov    0x8(%ebp),%eax
  802381:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802384:	6a 01                	push   $0x1
  802386:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802389:	50                   	push   %eax
  80238a:	e8 0c e8 ff ff       	call   800b9b <sys_cputs>
}
  80238f:	83 c4 10             	add    $0x10,%esp
  802392:	c9                   	leave  
  802393:	c3                   	ret    

00802394 <getchar>:

int
getchar(void)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80239a:	6a 01                	push   $0x1
  80239c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80239f:	50                   	push   %eax
  8023a0:	6a 00                	push   $0x0
  8023a2:	e8 8d f0 ff ff       	call   801434 <read>
	if (r < 0)
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	78 0f                	js     8023bd <getchar+0x29>
		return r;
	if (r < 1)
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	7e 06                	jle    8023b8 <getchar+0x24>
		return -E_EOF;
	return c;
  8023b2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023b6:	eb 05                	jmp    8023bd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023b8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023bd:	c9                   	leave  
  8023be:	c3                   	ret    

008023bf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023bf:	55                   	push   %ebp
  8023c0:	89 e5                	mov    %esp,%ebp
  8023c2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c8:	50                   	push   %eax
  8023c9:	ff 75 08             	pushl  0x8(%ebp)
  8023cc:	e8 fd ed ff ff       	call   8011ce <fd_lookup>
  8023d1:	83 c4 10             	add    $0x10,%esp
  8023d4:	85 c0                	test   %eax,%eax
  8023d6:	78 11                	js     8023e9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023db:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023e1:	39 10                	cmp    %edx,(%eax)
  8023e3:	0f 94 c0             	sete   %al
  8023e6:	0f b6 c0             	movzbl %al,%eax
}
  8023e9:	c9                   	leave  
  8023ea:	c3                   	ret    

008023eb <opencons>:

int
opencons(void)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f4:	50                   	push   %eax
  8023f5:	e8 85 ed ff ff       	call   80117f <fd_alloc>
  8023fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8023fd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023ff:	85 c0                	test   %eax,%eax
  802401:	78 3e                	js     802441 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802403:	83 ec 04             	sub    $0x4,%esp
  802406:	68 07 04 00 00       	push   $0x407
  80240b:	ff 75 f4             	pushl  -0xc(%ebp)
  80240e:	6a 00                	push   $0x0
  802410:	e8 42 e8 ff ff       	call   800c57 <sys_page_alloc>
  802415:	83 c4 10             	add    $0x10,%esp
		return r;
  802418:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80241a:	85 c0                	test   %eax,%eax
  80241c:	78 23                	js     802441 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80241e:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802424:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802427:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802433:	83 ec 0c             	sub    $0xc,%esp
  802436:	50                   	push   %eax
  802437:	e8 1c ed ff ff       	call   801158 <fd2num>
  80243c:	89 c2                	mov    %eax,%edx
  80243e:	83 c4 10             	add    $0x10,%esp
}
  802441:	89 d0                	mov    %edx,%eax
  802443:	c9                   	leave  
  802444:	c3                   	ret    

00802445 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802445:	55                   	push   %ebp
  802446:	89 e5                	mov    %esp,%ebp
  802448:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  80244b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802452:	75 36                	jne    80248a <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802454:	a1 04 40 80 00       	mov    0x804004,%eax
  802459:	8b 40 48             	mov    0x48(%eax),%eax
  80245c:	83 ec 04             	sub    $0x4,%esp
  80245f:	68 07 0e 00 00       	push   $0xe07
  802464:	68 00 f0 bf ee       	push   $0xeebff000
  802469:	50                   	push   %eax
  80246a:	e8 e8 e7 ff ff       	call   800c57 <sys_page_alloc>
		if (ret < 0) {
  80246f:	83 c4 10             	add    $0x10,%esp
  802472:	85 c0                	test   %eax,%eax
  802474:	79 14                	jns    80248a <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  802476:	83 ec 04             	sub    $0x4,%esp
  802479:	68 50 2f 80 00       	push   $0x802f50
  80247e:	6a 23                	push   $0x23
  802480:	68 78 2f 80 00       	push   $0x802f78
  802485:	e8 4e dd ff ff       	call   8001d8 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80248a:	a1 04 40 80 00       	mov    0x804004,%eax
  80248f:	8b 40 48             	mov    0x48(%eax),%eax
  802492:	83 ec 08             	sub    $0x8,%esp
  802495:	68 ad 24 80 00       	push   $0x8024ad
  80249a:	50                   	push   %eax
  80249b:	e8 02 e9 ff ff       	call   800da2 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a3:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8024a8:	83 c4 10             	add    $0x10,%esp
  8024ab:	c9                   	leave  
  8024ac:	c3                   	ret    

008024ad <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024ad:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024ae:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8024b3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024b5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  8024b8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  8024bc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  8024c1:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  8024c5:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  8024c7:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8024ca:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  8024cb:	83 c4 04             	add    $0x4,%esp
        popfl
  8024ce:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8024cf:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8024d0:	c3                   	ret    

008024d1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	56                   	push   %esi
  8024d5:	53                   	push   %ebx
  8024d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8024d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8024df:	85 c0                	test   %eax,%eax
  8024e1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024e6:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  8024e9:	83 ec 0c             	sub    $0xc,%esp
  8024ec:	50                   	push   %eax
  8024ed:	e8 15 e9 ff ff       	call   800e07 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  8024f2:	83 c4 10             	add    $0x10,%esp
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	75 10                	jne    802509 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  8024f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8024fe:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  802501:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  802504:	8b 40 70             	mov    0x70(%eax),%eax
  802507:	eb 0a                	jmp    802513 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  802509:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  80250e:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  802513:	85 f6                	test   %esi,%esi
  802515:	74 02                	je     802519 <ipc_recv+0x48>
  802517:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  802519:	85 db                	test   %ebx,%ebx
  80251b:	74 02                	je     80251f <ipc_recv+0x4e>
  80251d:	89 13                	mov    %edx,(%ebx)

    return r;
}
  80251f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802522:	5b                   	pop    %ebx
  802523:	5e                   	pop    %esi
  802524:	5d                   	pop    %ebp
  802525:	c3                   	ret    

00802526 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802526:	55                   	push   %ebp
  802527:	89 e5                	mov    %esp,%ebp
  802529:	57                   	push   %edi
  80252a:	56                   	push   %esi
  80252b:	53                   	push   %ebx
  80252c:	83 ec 0c             	sub    $0xc,%esp
  80252f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802532:	8b 75 0c             	mov    0xc(%ebp),%esi
  802535:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802538:	85 db                	test   %ebx,%ebx
  80253a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80253f:	0f 44 d8             	cmove  %eax,%ebx
  802542:	eb 1c                	jmp    802560 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  802544:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802547:	74 12                	je     80255b <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  802549:	50                   	push   %eax
  80254a:	68 86 2f 80 00       	push   $0x802f86
  80254f:	6a 40                	push   $0x40
  802551:	68 98 2f 80 00       	push   $0x802f98
  802556:	e8 7d dc ff ff       	call   8001d8 <_panic>
        sys_yield();
  80255b:	e8 d8 e6 ff ff       	call   800c38 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802560:	ff 75 14             	pushl  0x14(%ebp)
  802563:	53                   	push   %ebx
  802564:	56                   	push   %esi
  802565:	57                   	push   %edi
  802566:	e8 79 e8 ff ff       	call   800de4 <sys_ipc_try_send>
  80256b:	83 c4 10             	add    $0x10,%esp
  80256e:	85 c0                	test   %eax,%eax
  802570:	75 d2                	jne    802544 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  802572:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802575:	5b                   	pop    %ebx
  802576:	5e                   	pop    %esi
  802577:	5f                   	pop    %edi
  802578:	5d                   	pop    %ebp
  802579:	c3                   	ret    

0080257a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80257a:	55                   	push   %ebp
  80257b:	89 e5                	mov    %esp,%ebp
  80257d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802580:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802585:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802588:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80258e:	8b 52 50             	mov    0x50(%edx),%edx
  802591:	39 ca                	cmp    %ecx,%edx
  802593:	75 0d                	jne    8025a2 <ipc_find_env+0x28>
			return envs[i].env_id;
  802595:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802598:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80259d:	8b 40 48             	mov    0x48(%eax),%eax
  8025a0:	eb 0f                	jmp    8025b1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025a2:	83 c0 01             	add    $0x1,%eax
  8025a5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025aa:	75 d9                	jne    802585 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025b1:	5d                   	pop    %ebp
  8025b2:	c3                   	ret    

008025b3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025b3:	55                   	push   %ebp
  8025b4:	89 e5                	mov    %esp,%ebp
  8025b6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025b9:	89 d0                	mov    %edx,%eax
  8025bb:	c1 e8 16             	shr    $0x16,%eax
  8025be:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025c5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025ca:	f6 c1 01             	test   $0x1,%cl
  8025cd:	74 1d                	je     8025ec <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025cf:	c1 ea 0c             	shr    $0xc,%edx
  8025d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025d9:	f6 c2 01             	test   $0x1,%dl
  8025dc:	74 0e                	je     8025ec <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025de:	c1 ea 0c             	shr    $0xc,%edx
  8025e1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025e8:	ef 
  8025e9:	0f b7 c0             	movzwl %ax,%eax
}
  8025ec:	5d                   	pop    %ebp
  8025ed:	c3                   	ret    
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__udivdi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 1c             	sub    $0x1c,%esp
  8025f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802607:	85 f6                	test   %esi,%esi
  802609:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80260d:	89 ca                	mov    %ecx,%edx
  80260f:	89 f8                	mov    %edi,%eax
  802611:	75 3d                	jne    802650 <__udivdi3+0x60>
  802613:	39 cf                	cmp    %ecx,%edi
  802615:	0f 87 c5 00 00 00    	ja     8026e0 <__udivdi3+0xf0>
  80261b:	85 ff                	test   %edi,%edi
  80261d:	89 fd                	mov    %edi,%ebp
  80261f:	75 0b                	jne    80262c <__udivdi3+0x3c>
  802621:	b8 01 00 00 00       	mov    $0x1,%eax
  802626:	31 d2                	xor    %edx,%edx
  802628:	f7 f7                	div    %edi
  80262a:	89 c5                	mov    %eax,%ebp
  80262c:	89 c8                	mov    %ecx,%eax
  80262e:	31 d2                	xor    %edx,%edx
  802630:	f7 f5                	div    %ebp
  802632:	89 c1                	mov    %eax,%ecx
  802634:	89 d8                	mov    %ebx,%eax
  802636:	89 cf                	mov    %ecx,%edi
  802638:	f7 f5                	div    %ebp
  80263a:	89 c3                	mov    %eax,%ebx
  80263c:	89 d8                	mov    %ebx,%eax
  80263e:	89 fa                	mov    %edi,%edx
  802640:	83 c4 1c             	add    $0x1c,%esp
  802643:	5b                   	pop    %ebx
  802644:	5e                   	pop    %esi
  802645:	5f                   	pop    %edi
  802646:	5d                   	pop    %ebp
  802647:	c3                   	ret    
  802648:	90                   	nop
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	39 ce                	cmp    %ecx,%esi
  802652:	77 74                	ja     8026c8 <__udivdi3+0xd8>
  802654:	0f bd fe             	bsr    %esi,%edi
  802657:	83 f7 1f             	xor    $0x1f,%edi
  80265a:	0f 84 98 00 00 00    	je     8026f8 <__udivdi3+0x108>
  802660:	bb 20 00 00 00       	mov    $0x20,%ebx
  802665:	89 f9                	mov    %edi,%ecx
  802667:	89 c5                	mov    %eax,%ebp
  802669:	29 fb                	sub    %edi,%ebx
  80266b:	d3 e6                	shl    %cl,%esi
  80266d:	89 d9                	mov    %ebx,%ecx
  80266f:	d3 ed                	shr    %cl,%ebp
  802671:	89 f9                	mov    %edi,%ecx
  802673:	d3 e0                	shl    %cl,%eax
  802675:	09 ee                	or     %ebp,%esi
  802677:	89 d9                	mov    %ebx,%ecx
  802679:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80267d:	89 d5                	mov    %edx,%ebp
  80267f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802683:	d3 ed                	shr    %cl,%ebp
  802685:	89 f9                	mov    %edi,%ecx
  802687:	d3 e2                	shl    %cl,%edx
  802689:	89 d9                	mov    %ebx,%ecx
  80268b:	d3 e8                	shr    %cl,%eax
  80268d:	09 c2                	or     %eax,%edx
  80268f:	89 d0                	mov    %edx,%eax
  802691:	89 ea                	mov    %ebp,%edx
  802693:	f7 f6                	div    %esi
  802695:	89 d5                	mov    %edx,%ebp
  802697:	89 c3                	mov    %eax,%ebx
  802699:	f7 64 24 0c          	mull   0xc(%esp)
  80269d:	39 d5                	cmp    %edx,%ebp
  80269f:	72 10                	jb     8026b1 <__udivdi3+0xc1>
  8026a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026a5:	89 f9                	mov    %edi,%ecx
  8026a7:	d3 e6                	shl    %cl,%esi
  8026a9:	39 c6                	cmp    %eax,%esi
  8026ab:	73 07                	jae    8026b4 <__udivdi3+0xc4>
  8026ad:	39 d5                	cmp    %edx,%ebp
  8026af:	75 03                	jne    8026b4 <__udivdi3+0xc4>
  8026b1:	83 eb 01             	sub    $0x1,%ebx
  8026b4:	31 ff                	xor    %edi,%edi
  8026b6:	89 d8                	mov    %ebx,%eax
  8026b8:	89 fa                	mov    %edi,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	31 ff                	xor    %edi,%edi
  8026ca:	31 db                	xor    %ebx,%ebx
  8026cc:	89 d8                	mov    %ebx,%eax
  8026ce:	89 fa                	mov    %edi,%edx
  8026d0:	83 c4 1c             	add    $0x1c,%esp
  8026d3:	5b                   	pop    %ebx
  8026d4:	5e                   	pop    %esi
  8026d5:	5f                   	pop    %edi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    
  8026d8:	90                   	nop
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	89 d8                	mov    %ebx,%eax
  8026e2:	f7 f7                	div    %edi
  8026e4:	31 ff                	xor    %edi,%edi
  8026e6:	89 c3                	mov    %eax,%ebx
  8026e8:	89 d8                	mov    %ebx,%eax
  8026ea:	89 fa                	mov    %edi,%edx
  8026ec:	83 c4 1c             	add    $0x1c,%esp
  8026ef:	5b                   	pop    %ebx
  8026f0:	5e                   	pop    %esi
  8026f1:	5f                   	pop    %edi
  8026f2:	5d                   	pop    %ebp
  8026f3:	c3                   	ret    
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	39 ce                	cmp    %ecx,%esi
  8026fa:	72 0c                	jb     802708 <__udivdi3+0x118>
  8026fc:	31 db                	xor    %ebx,%ebx
  8026fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802702:	0f 87 34 ff ff ff    	ja     80263c <__udivdi3+0x4c>
  802708:	bb 01 00 00 00       	mov    $0x1,%ebx
  80270d:	e9 2a ff ff ff       	jmp    80263c <__udivdi3+0x4c>
  802712:	66 90                	xchg   %ax,%ax
  802714:	66 90                	xchg   %ax,%ax
  802716:	66 90                	xchg   %ax,%ax
  802718:	66 90                	xchg   %ax,%ax
  80271a:	66 90                	xchg   %ax,%ax
  80271c:	66 90                	xchg   %ax,%ax
  80271e:	66 90                	xchg   %ax,%ax

00802720 <__umoddi3>:
  802720:	55                   	push   %ebp
  802721:	57                   	push   %edi
  802722:	56                   	push   %esi
  802723:	53                   	push   %ebx
  802724:	83 ec 1c             	sub    $0x1c,%esp
  802727:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80272b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80272f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802733:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802737:	85 d2                	test   %edx,%edx
  802739:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80273d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802741:	89 f3                	mov    %esi,%ebx
  802743:	89 3c 24             	mov    %edi,(%esp)
  802746:	89 74 24 04          	mov    %esi,0x4(%esp)
  80274a:	75 1c                	jne    802768 <__umoddi3+0x48>
  80274c:	39 f7                	cmp    %esi,%edi
  80274e:	76 50                	jbe    8027a0 <__umoddi3+0x80>
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 f2                	mov    %esi,%edx
  802754:	f7 f7                	div    %edi
  802756:	89 d0                	mov    %edx,%eax
  802758:	31 d2                	xor    %edx,%edx
  80275a:	83 c4 1c             	add    $0x1c,%esp
  80275d:	5b                   	pop    %ebx
  80275e:	5e                   	pop    %esi
  80275f:	5f                   	pop    %edi
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    
  802762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802768:	39 f2                	cmp    %esi,%edx
  80276a:	89 d0                	mov    %edx,%eax
  80276c:	77 52                	ja     8027c0 <__umoddi3+0xa0>
  80276e:	0f bd ea             	bsr    %edx,%ebp
  802771:	83 f5 1f             	xor    $0x1f,%ebp
  802774:	75 5a                	jne    8027d0 <__umoddi3+0xb0>
  802776:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80277a:	0f 82 e0 00 00 00    	jb     802860 <__umoddi3+0x140>
  802780:	39 0c 24             	cmp    %ecx,(%esp)
  802783:	0f 86 d7 00 00 00    	jbe    802860 <__umoddi3+0x140>
  802789:	8b 44 24 08          	mov    0x8(%esp),%eax
  80278d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802791:	83 c4 1c             	add    $0x1c,%esp
  802794:	5b                   	pop    %ebx
  802795:	5e                   	pop    %esi
  802796:	5f                   	pop    %edi
  802797:	5d                   	pop    %ebp
  802798:	c3                   	ret    
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	85 ff                	test   %edi,%edi
  8027a2:	89 fd                	mov    %edi,%ebp
  8027a4:	75 0b                	jne    8027b1 <__umoddi3+0x91>
  8027a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  8027ad:	f7 f7                	div    %edi
  8027af:	89 c5                	mov    %eax,%ebp
  8027b1:	89 f0                	mov    %esi,%eax
  8027b3:	31 d2                	xor    %edx,%edx
  8027b5:	f7 f5                	div    %ebp
  8027b7:	89 c8                	mov    %ecx,%eax
  8027b9:	f7 f5                	div    %ebp
  8027bb:	89 d0                	mov    %edx,%eax
  8027bd:	eb 99                	jmp    802758 <__umoddi3+0x38>
  8027bf:	90                   	nop
  8027c0:	89 c8                	mov    %ecx,%eax
  8027c2:	89 f2                	mov    %esi,%edx
  8027c4:	83 c4 1c             	add    $0x1c,%esp
  8027c7:	5b                   	pop    %ebx
  8027c8:	5e                   	pop    %esi
  8027c9:	5f                   	pop    %edi
  8027ca:	5d                   	pop    %ebp
  8027cb:	c3                   	ret    
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	8b 34 24             	mov    (%esp),%esi
  8027d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027d8:	89 e9                	mov    %ebp,%ecx
  8027da:	29 ef                	sub    %ebp,%edi
  8027dc:	d3 e0                	shl    %cl,%eax
  8027de:	89 f9                	mov    %edi,%ecx
  8027e0:	89 f2                	mov    %esi,%edx
  8027e2:	d3 ea                	shr    %cl,%edx
  8027e4:	89 e9                	mov    %ebp,%ecx
  8027e6:	09 c2                	or     %eax,%edx
  8027e8:	89 d8                	mov    %ebx,%eax
  8027ea:	89 14 24             	mov    %edx,(%esp)
  8027ed:	89 f2                	mov    %esi,%edx
  8027ef:	d3 e2                	shl    %cl,%edx
  8027f1:	89 f9                	mov    %edi,%ecx
  8027f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027fb:	d3 e8                	shr    %cl,%eax
  8027fd:	89 e9                	mov    %ebp,%ecx
  8027ff:	89 c6                	mov    %eax,%esi
  802801:	d3 e3                	shl    %cl,%ebx
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 d0                	mov    %edx,%eax
  802807:	d3 e8                	shr    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	09 d8                	or     %ebx,%eax
  80280d:	89 d3                	mov    %edx,%ebx
  80280f:	89 f2                	mov    %esi,%edx
  802811:	f7 34 24             	divl   (%esp)
  802814:	89 d6                	mov    %edx,%esi
  802816:	d3 e3                	shl    %cl,%ebx
  802818:	f7 64 24 04          	mull   0x4(%esp)
  80281c:	39 d6                	cmp    %edx,%esi
  80281e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802822:	89 d1                	mov    %edx,%ecx
  802824:	89 c3                	mov    %eax,%ebx
  802826:	72 08                	jb     802830 <__umoddi3+0x110>
  802828:	75 11                	jne    80283b <__umoddi3+0x11b>
  80282a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80282e:	73 0b                	jae    80283b <__umoddi3+0x11b>
  802830:	2b 44 24 04          	sub    0x4(%esp),%eax
  802834:	1b 14 24             	sbb    (%esp),%edx
  802837:	89 d1                	mov    %edx,%ecx
  802839:	89 c3                	mov    %eax,%ebx
  80283b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80283f:	29 da                	sub    %ebx,%edx
  802841:	19 ce                	sbb    %ecx,%esi
  802843:	89 f9                	mov    %edi,%ecx
  802845:	89 f0                	mov    %esi,%eax
  802847:	d3 e0                	shl    %cl,%eax
  802849:	89 e9                	mov    %ebp,%ecx
  80284b:	d3 ea                	shr    %cl,%edx
  80284d:	89 e9                	mov    %ebp,%ecx
  80284f:	d3 ee                	shr    %cl,%esi
  802851:	09 d0                	or     %edx,%eax
  802853:	89 f2                	mov    %esi,%edx
  802855:	83 c4 1c             	add    $0x1c,%esp
  802858:	5b                   	pop    %ebx
  802859:	5e                   	pop    %esi
  80285a:	5f                   	pop    %edi
  80285b:	5d                   	pop    %ebp
  80285c:	c3                   	ret    
  80285d:	8d 76 00             	lea    0x0(%esi),%esi
  802860:	29 f9                	sub    %edi,%ecx
  802862:	19 d6                	sbb    %edx,%esi
  802864:	89 74 24 04          	mov    %esi,0x4(%esp)
  802868:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80286c:	e9 18 ff ff ff       	jmp    802789 <__umoddi3+0x69>
