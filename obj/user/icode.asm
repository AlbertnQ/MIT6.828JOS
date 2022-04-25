
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
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
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 60 	movl   $0x802460,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 66 24 80 00       	push   $0x802466
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 75 24 80 00 	movl   $0x802475,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 88 24 80 00       	push   $0x802488
  800068:	e8 fe 14 00 00       	call   80156b <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 8e 24 80 00       	push   $0x80248e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 a4 24 80 00       	push   $0x8024a4
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 b1 24 80 00       	push   $0x8024b1
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 ad 0a 00 00       	call   800b57 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 24 10 00 00       	call   8010e0 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 c4 24 80 00       	push   $0x8024c4
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 cc 0e 00 00       	call   800fa4 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 ec 24 80 00       	push   $0x8024ec
  8000f0:	68 f5 24 80 00       	push   $0x8024f5
  8000f5:	68 ff 24 80 00       	push   $0x8024ff
  8000fa:	68 fe 24 80 00       	push   $0x8024fe
  8000ff:	e8 4c 1a 00 00       	call   801b50 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 04 25 80 00       	push   $0x802504
  800111:	6a 1a                	push   $0x1a
  800113:	68 a4 24 80 00       	push   $0x8024a4
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 1b 25 80 00       	push   $0x80251b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 91 0a 00 00       	call   800bd5 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 4a 0e 00 00       	call   800fcf <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 05 0a 00 00       	call   800b94 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 2e 0a 00 00       	call   800bd5 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 38 25 80 00       	push   $0x802538
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 4d 09 00 00       	call   800b57 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 54 01 00 00       	call   8003a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 f2 08 00 00       	call   800b57 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 eb 1e 00 00       	call   8021c0 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 d8 1f 00 00       	call   8022f0 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 5b 25 80 00 	movsbl 0x80255b(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 22                	jmp    800368 <getuint+0x38>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 10                	je     80035a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
  800358:	eb 0e                	jmp    800368 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	50                   	push   %eax
  800391:	ff 75 10             	pushl  0x10(%ebp)
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 05 00 00 00       	call   8003a4 <vprintfmt>
	va_end(ap);
}
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 2c             	sub    $0x2c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	eb 12                	jmp    8003ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 a7 03 00 00    	je     800767 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e2                	jne    8003b8 <vprintfmt+0x14>
  8003d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	eb 07                	jmp    800404 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800400:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8d 47 01             	lea    0x1(%edi),%eax
  800407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040a:	0f b6 07             	movzbl (%edi),%eax
  80040d:	0f b6 d0             	movzbl %al,%edx
  800410:	83 e8 23             	sub    $0x23,%eax
  800413:	3c 55                	cmp    $0x55,%al
  800415:	0f 87 31 03 00 00    	ja     80074c <vprintfmt+0x3a8>
  80041b:	0f b6 c0             	movzbl %al,%eax
  80041e:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800428:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042c:	eb d6                	jmp    800404 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	b8 00 00 00 00       	mov    $0x0,%eax
  800436:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800439:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800440:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800443:	8d 72 d0             	lea    -0x30(%edx),%esi
  800446:	83 fe 09             	cmp    $0x9,%esi
  800449:	77 34                	ja     80047f <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80044e:	eb e9                	jmp    800439 <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800461:	eb 22                	jmp    800485 <vprintfmt+0xe1>
  800463:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800466:	85 c0                	test   %eax,%eax
  800468:	0f 48 c1             	cmovs  %ecx,%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800471:	eb 91                	jmp    800404 <vprintfmt+0x60>
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800476:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047d:	eb 85                	jmp    800404 <vprintfmt+0x60>
  80047f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800482:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800485:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800489:	0f 89 75 ff ff ff    	jns    800404 <vprintfmt+0x60>
				width = precision, precision = -1;
  80048f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800492:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800495:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80049c:	e9 63 ff ff ff       	jmp    800404 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a8:	e9 57 ff ff ff       	jmp    800404 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	53                   	push   %ebx
  8004ba:	ff 30                	pushl  (%eax)
  8004bc:	ff d6                	call   *%esi
			break;
  8004be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c4:	e9 01 ff ff ff       	jmp    8003ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	8b 00                	mov    (%eax),%eax
  8004d4:	99                   	cltd   
  8004d5:	31 d0                	xor    %edx,%eax
  8004d7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 0f             	cmp    $0xf,%eax
  8004dc:	7f 0b                	jg     8004e9 <vprintfmt+0x145>
  8004de:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  8004e5:	85 d2                	test   %edx,%edx
  8004e7:	75 18                	jne    800501 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  8004e9:	50                   	push   %eax
  8004ea:	68 73 25 80 00       	push   $0x802573
  8004ef:	53                   	push   %ebx
  8004f0:	56                   	push   %esi
  8004f1:	e8 91 fe ff ff       	call   800387 <printfmt>
  8004f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004fc:	e9 c9 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800501:	52                   	push   %edx
  800502:	68 31 29 80 00       	push   $0x802931
  800507:	53                   	push   %ebx
  800508:	56                   	push   %esi
  800509:	e8 79 fe ff ff       	call   800387 <printfmt>
  80050e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800514:	e9 b1 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 50 04             	lea    0x4(%eax),%edx
  80051f:	89 55 14             	mov    %edx,0x14(%ebp)
  800522:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800524:	85 ff                	test   %edi,%edi
  800526:	b8 6c 25 80 00       	mov    $0x80256c,%eax
  80052b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800532:	0f 8e 94 00 00 00    	jle    8005cc <vprintfmt+0x228>
  800538:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80053c:	0f 84 98 00 00 00    	je     8005da <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 cc             	pushl  -0x34(%ebp)
  800548:	57                   	push   %edi
  800549:	e8 a1 02 00 00       	call   8007ef <strnlen>
  80054e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800551:	29 c1                	sub    %eax,%ecx
  800553:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800559:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800560:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800563:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	eb 0f                	jmp    800576 <vprintfmt+0x1d2>
					putch(padc, putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	ff 75 e0             	pushl  -0x20(%ebp)
  80056e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800570:	83 ef 01             	sub    $0x1,%edi
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	85 ff                	test   %edi,%edi
  800578:	7f ed                	jg     800567 <vprintfmt+0x1c3>
  80057a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800580:	85 c9                	test   %ecx,%ecx
  800582:	b8 00 00 00 00       	mov    $0x0,%eax
  800587:	0f 49 c1             	cmovns %ecx,%eax
  80058a:	29 c1                	sub    %eax,%ecx
  80058c:	89 75 08             	mov    %esi,0x8(%ebp)
  80058f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800592:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800595:	89 cb                	mov    %ecx,%ebx
  800597:	eb 4d                	jmp    8005e6 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800599:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059d:	74 1b                	je     8005ba <vprintfmt+0x216>
  80059f:	0f be c0             	movsbl %al,%eax
  8005a2:	83 e8 20             	sub    $0x20,%eax
  8005a5:	83 f8 5e             	cmp    $0x5e,%eax
  8005a8:	76 10                	jbe    8005ba <vprintfmt+0x216>
					putch('?', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	ff 75 0c             	pushl  0xc(%ebp)
  8005b0:	6a 3f                	push   $0x3f
  8005b2:	ff 55 08             	call   *0x8(%ebp)
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	eb 0d                	jmp    8005c7 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	ff 75 0c             	pushl  0xc(%ebp)
  8005c0:	52                   	push   %edx
  8005c1:	ff 55 08             	call   *0x8(%ebp)
  8005c4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c7:	83 eb 01             	sub    $0x1,%ebx
  8005ca:	eb 1a                	jmp    8005e6 <vprintfmt+0x242>
  8005cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cf:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d8:	eb 0c                	jmp    8005e6 <vprintfmt+0x242>
  8005da:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e6:	83 c7 01             	add    $0x1,%edi
  8005e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ed:	0f be d0             	movsbl %al,%edx
  8005f0:	85 d2                	test   %edx,%edx
  8005f2:	74 23                	je     800617 <vprintfmt+0x273>
  8005f4:	85 f6                	test   %esi,%esi
  8005f6:	78 a1                	js     800599 <vprintfmt+0x1f5>
  8005f8:	83 ee 01             	sub    $0x1,%esi
  8005fb:	79 9c                	jns    800599 <vprintfmt+0x1f5>
  8005fd:	89 df                	mov    %ebx,%edi
  8005ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800605:	eb 18                	jmp    80061f <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 20                	push   $0x20
  80060d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	eb 08                	jmp    80061f <vprintfmt+0x27b>
  800617:	89 df                	mov    %ebx,%edi
  800619:	8b 75 08             	mov    0x8(%ebp),%esi
  80061c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061f:	85 ff                	test   %edi,%edi
  800621:	7f e4                	jg     800607 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800626:	e9 9f fd ff ff       	jmp    8003ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062b:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  80062f:	7e 16                	jle    800647 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 08             	lea    0x8(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 50 04             	mov    0x4(%eax),%edx
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800642:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800645:	eb 34                	jmp    80067b <vprintfmt+0x2d7>
	else if (lflag)
  800647:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80064b:	74 18                	je     800665 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 50 04             	lea    0x4(%eax),%edx
  800653:	89 55 14             	mov    %edx,0x14(%ebp)
  800656:	8b 00                	mov    (%eax),%eax
  800658:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065b:	89 c1                	mov    %eax,%ecx
  80065d:	c1 f9 1f             	sar    $0x1f,%ecx
  800660:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800663:	eb 16                	jmp    80067b <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800673:	89 c1                	mov    %eax,%ecx
  800675:	c1 f9 1f             	sar    $0x1f,%ecx
  800678:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80067e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800681:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800686:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068a:	0f 89 88 00 00 00    	jns    800718 <vprintfmt+0x374>
				putch('-', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 2d                	push   $0x2d
  800696:	ff d6                	call   *%esi
				num = -(long long) num;
  800698:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069e:	f7 d8                	neg    %eax
  8006a0:	83 d2 00             	adc    $0x0,%edx
  8006a3:	f7 da                	neg    %edx
  8006a5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ad:	eb 69                	jmp    800718 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006af:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	e8 76 fc ff ff       	call   800330 <getuint>
			base = 10;
  8006ba:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006bf:	eb 57                	jmp    800718 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 30                	push   $0x30
  8006c7:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  8006c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cf:	e8 5c fc ff ff       	call   800330 <getuint>
			base = 8;
			goto number;
  8006d4:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8006d7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006dc:	eb 3a                	jmp    800718 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 30                	push   $0x30
  8006e4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e6:	83 c4 08             	add    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 78                	push   $0x78
  8006ec:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006fe:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800701:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800706:	eb 10                	jmp    800718 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800708:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 1d fc ff ff       	call   800330 <getuint>
			base = 16;
  800713:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800718:	83 ec 0c             	sub    $0xc,%esp
  80071b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80071f:	57                   	push   %edi
  800720:	ff 75 e0             	pushl  -0x20(%ebp)
  800723:	51                   	push   %ecx
  800724:	52                   	push   %edx
  800725:	50                   	push   %eax
  800726:	89 da                	mov    %ebx,%edx
  800728:	89 f0                	mov    %esi,%eax
  80072a:	e8 52 fb ff ff       	call   800281 <printnum>
			break;
  80072f:	83 c4 20             	add    $0x20,%esp
  800732:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800735:	e9 90 fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	52                   	push   %edx
  80073f:	ff d6                	call   *%esi
			break;
  800741:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800747:	e9 7e fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	6a 25                	push   $0x25
  800752:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <vprintfmt+0x3b8>
  800759:	83 ef 01             	sub    $0x1,%edi
  80075c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800760:	75 f7                	jne    800759 <vprintfmt+0x3b5>
  800762:	e9 63 fc ff ff       	jmp    8003ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800767:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076a:	5b                   	pop    %ebx
  80076b:	5e                   	pop    %esi
  80076c:	5f                   	pop    %edi
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	83 ec 18             	sub    $0x18,%esp
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800782:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800785:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078c:	85 c0                	test   %eax,%eax
  80078e:	74 26                	je     8007b6 <vsnprintf+0x47>
  800790:	85 d2                	test   %edx,%edx
  800792:	7e 22                	jle    8007b6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800794:	ff 75 14             	pushl  0x14(%ebp)
  800797:	ff 75 10             	pushl  0x10(%ebp)
  80079a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079d:	50                   	push   %eax
  80079e:	68 6a 03 80 00       	push   $0x80036a
  8007a3:	e8 fc fb ff ff       	call   8003a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	eb 05                	jmp    8007bb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c6:	50                   	push   %eax
  8007c7:	ff 75 10             	pushl  0x10(%ebp)
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	ff 75 08             	pushl  0x8(%ebp)
  8007d0:	e8 9a ff ff ff       	call   80076f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e2:	eb 03                	jmp    8007e7 <strlen+0x10>
		n++;
  8007e4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007eb:	75 f7                	jne    8007e4 <strlen+0xd>
		n++;
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fd:	eb 03                	jmp    800802 <strnlen+0x13>
		n++;
  8007ff:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800802:	39 c2                	cmp    %eax,%edx
  800804:	74 08                	je     80080e <strnlen+0x1f>
  800806:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080a:	75 f3                	jne    8007ff <strnlen+0x10>
  80080c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081a:	89 c2                	mov    %eax,%edx
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	83 c1 01             	add    $0x1,%ecx
  800822:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800826:	88 5a ff             	mov    %bl,-0x1(%edx)
  800829:	84 db                	test   %bl,%bl
  80082b:	75 ef                	jne    80081c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800837:	53                   	push   %ebx
  800838:	e8 9a ff ff ff       	call   8007d7 <strlen>
  80083d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800840:	ff 75 0c             	pushl  0xc(%ebp)
  800843:	01 d8                	add    %ebx,%eax
  800845:	50                   	push   %eax
  800846:	e8 c5 ff ff ff       	call   800810 <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	89 f3                	mov    %esi,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	89 f2                	mov    %esi,%edx
  800864:	eb 0f                	jmp    800875 <strncpy+0x23>
		*dst++ = *src;
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	0f b6 01             	movzbl (%ecx),%eax
  80086c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086f:	80 39 01             	cmpb   $0x1,(%ecx)
  800872:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800875:	39 da                	cmp    %ebx,%edx
  800877:	75 ed                	jne    800866 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088a:	8b 55 10             	mov    0x10(%ebp),%edx
  80088d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088f:	85 d2                	test   %edx,%edx
  800891:	74 21                	je     8008b4 <strlcpy+0x35>
  800893:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800897:	89 f2                	mov    %esi,%edx
  800899:	eb 09                	jmp    8008a4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089b:	83 c2 01             	add    $0x1,%edx
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a4:	39 c2                	cmp    %eax,%edx
  8008a6:	74 09                	je     8008b1 <strlcpy+0x32>
  8008a8:	0f b6 19             	movzbl (%ecx),%ebx
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	75 ec                	jne    80089b <strlcpy+0x1c>
  8008af:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b4:	29 f0                	sub    %esi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c3:	eb 06                	jmp    8008cb <strcmp+0x11>
		p++, q++;
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 04                	je     8008d6 <strcmp+0x1c>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	74 ef                	je     8008c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 c0             	movzbl %al,%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	89 c3                	mov    %eax,%ebx
  8008ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ef:	eb 06                	jmp    8008f7 <strncmp+0x17>
		n--, p++, q++;
  8008f1:	83 c0 01             	add    $0x1,%eax
  8008f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f7:	39 d8                	cmp    %ebx,%eax
  8008f9:	74 15                	je     800910 <strncmp+0x30>
  8008fb:	0f b6 08             	movzbl (%eax),%ecx
  8008fe:	84 c9                	test   %cl,%cl
  800900:	74 04                	je     800906 <strncmp+0x26>
  800902:	3a 0a                	cmp    (%edx),%cl
  800904:	74 eb                	je     8008f1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 00             	movzbl (%eax),%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
  80090e:	eb 05                	jmp    800915 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800915:	5b                   	pop    %ebx
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800922:	eb 07                	jmp    80092b <strchr+0x13>
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 0f                	je     800937 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	0f b6 10             	movzbl (%eax),%edx
  80092e:	84 d2                	test   %dl,%dl
  800930:	75 f2                	jne    800924 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800943:	eb 03                	jmp    800948 <strfind+0xf>
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094b:	38 ca                	cmp    %cl,%dl
  80094d:	74 04                	je     800953 <strfind+0x1a>
  80094f:	84 d2                	test   %dl,%dl
  800951:	75 f2                	jne    800945 <strfind+0xc>
			break;
	return (char *) s;
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800961:	85 c9                	test   %ecx,%ecx
  800963:	74 36                	je     80099b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800965:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096b:	75 28                	jne    800995 <memset+0x40>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	75 23                	jne    800995 <memset+0x40>
		c &= 0xFF;
  800972:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800976:	89 d3                	mov    %edx,%ebx
  800978:	c1 e3 08             	shl    $0x8,%ebx
  80097b:	89 d6                	mov    %edx,%esi
  80097d:	c1 e6 18             	shl    $0x18,%esi
  800980:	89 d0                	mov    %edx,%eax
  800982:	c1 e0 10             	shl    $0x10,%eax
  800985:	09 f0                	or     %esi,%eax
  800987:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800989:	89 d8                	mov    %ebx,%eax
  80098b:	09 d0                	or     %edx,%eax
  80098d:	c1 e9 02             	shr    $0x2,%ecx
  800990:	fc                   	cld    
  800991:	f3 ab                	rep stos %eax,%es:(%edi)
  800993:	eb 06                	jmp    80099b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	fc                   	cld    
  800999:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099b:	89 f8                	mov    %edi,%eax
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b0:	39 c6                	cmp    %eax,%esi
  8009b2:	73 35                	jae    8009e9 <memmove+0x47>
  8009b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b7:	39 d0                	cmp    %edx,%eax
  8009b9:	73 2e                	jae    8009e9 <memmove+0x47>
		s += n;
		d += n;
  8009bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	09 fe                	or     %edi,%esi
  8009c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c8:	75 13                	jne    8009dd <memmove+0x3b>
  8009ca:	f6 c1 03             	test   $0x3,%cl
  8009cd:	75 0e                	jne    8009dd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009cf:	83 ef 04             	sub    $0x4,%edi
  8009d2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d5:	c1 e9 02             	shr    $0x2,%ecx
  8009d8:	fd                   	std    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 09                	jmp    8009e6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009dd:	83 ef 01             	sub    $0x1,%edi
  8009e0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e3:	fd                   	std    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e6:	fc                   	cld    
  8009e7:	eb 1d                	jmp    800a06 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e9:	89 f2                	mov    %esi,%edx
  8009eb:	09 c2                	or     %eax,%edx
  8009ed:	f6 c2 03             	test   $0x3,%dl
  8009f0:	75 0f                	jne    800a01 <memmove+0x5f>
  8009f2:	f6 c1 03             	test   $0x3,%cl
  8009f5:	75 0a                	jne    800a01 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
  8009fa:	89 c7                	mov    %eax,%edi
  8009fc:	fc                   	cld    
  8009fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ff:	eb 05                	jmp    800a06 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a06:	5e                   	pop    %esi
  800a07:	5f                   	pop    %edi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0d:	ff 75 10             	pushl  0x10(%ebp)
  800a10:	ff 75 0c             	pushl  0xc(%ebp)
  800a13:	ff 75 08             	pushl  0x8(%ebp)
  800a16:	e8 87 ff ff ff       	call   8009a2 <memmove>
}
  800a1b:	c9                   	leave  
  800a1c:	c3                   	ret    

00800a1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a28:	89 c6                	mov    %eax,%esi
  800a2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2d:	eb 1a                	jmp    800a49 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2f:	0f b6 08             	movzbl (%eax),%ecx
  800a32:	0f b6 1a             	movzbl (%edx),%ebx
  800a35:	38 d9                	cmp    %bl,%cl
  800a37:	74 0a                	je     800a43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a39:	0f b6 c1             	movzbl %cl,%eax
  800a3c:	0f b6 db             	movzbl %bl,%ebx
  800a3f:	29 d8                	sub    %ebx,%eax
  800a41:	eb 0f                	jmp    800a52 <memcmp+0x35>
		s1++, s2++;
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a49:	39 f0                	cmp    %esi,%eax
  800a4b:	75 e2                	jne    800a2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5d:	89 c1                	mov    %eax,%ecx
  800a5f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a62:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a66:	eb 0a                	jmp    800a72 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a68:	0f b6 10             	movzbl (%eax),%edx
  800a6b:	39 da                	cmp    %ebx,%edx
  800a6d:	74 07                	je     800a76 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	39 c8                	cmp    %ecx,%eax
  800a74:	72 f2                	jb     800a68 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a76:	5b                   	pop    %ebx
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a85:	eb 03                	jmp    800a8a <strtol+0x11>
		s++;
  800a87:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8a:	0f b6 01             	movzbl (%ecx),%eax
  800a8d:	3c 20                	cmp    $0x20,%al
  800a8f:	74 f6                	je     800a87 <strtol+0xe>
  800a91:	3c 09                	cmp    $0x9,%al
  800a93:	74 f2                	je     800a87 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a95:	3c 2b                	cmp    $0x2b,%al
  800a97:	75 0a                	jne    800aa3 <strtol+0x2a>
		s++;
  800a99:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa1:	eb 11                	jmp    800ab4 <strtol+0x3b>
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa8:	3c 2d                	cmp    $0x2d,%al
  800aaa:	75 08                	jne    800ab4 <strtol+0x3b>
		s++, neg = 1;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aba:	75 15                	jne    800ad1 <strtol+0x58>
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 10                	jne    800ad1 <strtol+0x58>
  800ac1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac5:	75 7c                	jne    800b43 <strtol+0xca>
		s += 2, base = 16;
  800ac7:	83 c1 02             	add    $0x2,%ecx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb 16                	jmp    800ae7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	75 12                	jne    800ae7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ada:	80 39 30             	cmpb   $0x30,(%ecx)
  800add:	75 08                	jne    800ae7 <strtol+0x6e>
		s++, base = 8;
  800adf:	83 c1 01             	add    $0x1,%ecx
  800ae2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aef:	0f b6 11             	movzbl (%ecx),%edx
  800af2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 09             	cmp    $0x9,%bl
  800afa:	77 08                	ja     800b04 <strtol+0x8b>
			dig = *s - '0';
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 30             	sub    $0x30,%edx
  800b02:	eb 22                	jmp    800b26 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b04:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 57             	sub    $0x57,%edx
  800b14:	eb 10                	jmp    800b26 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b16:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 16                	ja     800b36 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b20:	0f be d2             	movsbl %dl,%edx
  800b23:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b26:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b29:	7d 0b                	jge    800b36 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2b:	83 c1 01             	add    $0x1,%ecx
  800b2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b32:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b34:	eb b9                	jmp    800aef <strtol+0x76>

	if (endptr)
  800b36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3a:	74 0d                	je     800b49 <strtol+0xd0>
		*endptr = (char *) s;
  800b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3f:	89 0e                	mov    %ecx,(%esi)
  800b41:	eb 06                	jmp    800b49 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b43:	85 db                	test   %ebx,%ebx
  800b45:	74 98                	je     800adf <strtol+0x66>
  800b47:	eb 9e                	jmp    800ae7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b49:	89 c2                	mov    %eax,%edx
  800b4b:	f7 da                	neg    %edx
  800b4d:	85 ff                	test   %edi,%edi
  800b4f:	0f 45 c2             	cmovne %edx,%eax
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	89 c3                	mov    %eax,%ebx
  800b6a:	89 c7                	mov    %eax,%edi
  800b6c:	89 c6                	mov    %eax,%esi
  800b6e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 01 00 00 00       	mov    $0x1,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	89 cb                	mov    %ecx,%ebx
  800bac:	89 cf                	mov    %ecx,%edi
  800bae:	89 ce                	mov    %ecx,%esi
  800bb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	7e 17                	jle    800bcd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	50                   	push   %eax
  800bba:	6a 03                	push   $0x3
  800bbc:	68 5f 28 80 00       	push   $0x80285f
  800bc1:	6a 23                	push   $0x23
  800bc3:	68 7c 28 80 00       	push   $0x80287c
  800bc8:	e8 c7 f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 02 00 00 00       	mov    $0x2,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_yield>:

void
sys_yield(void)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	be 00 00 00 00       	mov    $0x0,%esi
  800c21:	b8 04 00 00 00       	mov    $0x4,%eax
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2f:	89 f7                	mov    %esi,%edi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 04                	push   $0x4
  800c3d:	68 5f 28 80 00       	push   $0x80285f
  800c42:	6a 23                	push   $0x23
  800c44:	68 7c 28 80 00       	push   $0x80287c
  800c49:	e8 46 f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c70:	8b 75 18             	mov    0x18(%ebp),%esi
  800c73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 17                	jle    800c90 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	50                   	push   %eax
  800c7d:	6a 05                	push   $0x5
  800c7f:	68 5f 28 80 00       	push   $0x80285f
  800c84:	6a 23                	push   $0x23
  800c86:	68 7c 28 80 00       	push   $0x80287c
  800c8b:	e8 04 f5 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	89 df                	mov    %ebx,%edi
  800cb3:	89 de                	mov    %ebx,%esi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 06                	push   $0x6
  800cc1:	68 5f 28 80 00       	push   $0x80285f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 7c 28 80 00       	push   $0x80287c
  800ccd:	e8 c2 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 08                	push   $0x8
  800d03:	68 5f 28 80 00       	push   $0x80285f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 7c 28 80 00       	push   $0x80287c
  800d0f:	e8 80 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 09                	push   $0x9
  800d45:	68 5f 28 80 00       	push   $0x80285f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 7c 28 80 00       	push   $0x80287c
  800d51:	e8 3e f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 0a                	push   $0xa
  800d87:	68 5f 28 80 00       	push   $0x80285f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 7c 28 80 00       	push   $0x80287c
  800d93:	e8 fc f3 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	be 00 00 00 00       	mov    $0x0,%esi
  800dab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 cb                	mov    %ecx,%ebx
  800ddb:	89 cf                	mov    %ecx,%edi
  800ddd:	89 ce                	mov    %ecx,%esi
  800ddf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de1:	85 c0                	test   %eax,%eax
  800de3:	7e 17                	jle    800dfc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	50                   	push   %eax
  800de9:	6a 0d                	push   $0xd
  800deb:	68 5f 28 80 00       	push   $0x80285f
  800df0:	6a 23                	push   $0x23
  800df2:	68 7c 28 80 00       	push   $0x80287c
  800df7:	e8 98 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e24:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e31:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	c1 ea 16             	shr    $0x16,%edx
  800e3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e42:	f6 c2 01             	test   $0x1,%dl
  800e45:	74 11                	je     800e58 <fd_alloc+0x2d>
  800e47:	89 c2                	mov    %eax,%edx
  800e49:	c1 ea 0c             	shr    $0xc,%edx
  800e4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e53:	f6 c2 01             	test   $0x1,%dl
  800e56:	75 09                	jne    800e61 <fd_alloc+0x36>
			*fd_store = fd;
  800e58:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	eb 17                	jmp    800e78 <fd_alloc+0x4d>
  800e61:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e66:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e6b:	75 c9                	jne    800e36 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e73:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e80:	83 f8 1f             	cmp    $0x1f,%eax
  800e83:	77 36                	ja     800ebb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e85:	c1 e0 0c             	shl    $0xc,%eax
  800e88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8d:	89 c2                	mov    %eax,%edx
  800e8f:	c1 ea 16             	shr    $0x16,%edx
  800e92:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e99:	f6 c2 01             	test   $0x1,%dl
  800e9c:	74 24                	je     800ec2 <fd_lookup+0x48>
  800e9e:	89 c2                	mov    %eax,%edx
  800ea0:	c1 ea 0c             	shr    $0xc,%edx
  800ea3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eaa:	f6 c2 01             	test   $0x1,%dl
  800ead:	74 1a                	je     800ec9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb2:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	eb 13                	jmp    800ece <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec0:	eb 0c                	jmp    800ece <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec7:	eb 05                	jmp    800ece <fd_lookup+0x54>
  800ec9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed9:	ba 08 29 80 00       	mov    $0x802908,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ede:	eb 13                	jmp    800ef3 <dev_lookup+0x23>
  800ee0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee3:	39 08                	cmp    %ecx,(%eax)
  800ee5:	75 0c                	jne    800ef3 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	eb 2e                	jmp    800f21 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef3:	8b 02                	mov    (%edx),%eax
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 e7                	jne    800ee0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef9:	a1 04 40 80 00       	mov    0x804004,%eax
  800efe:	8b 40 48             	mov    0x48(%eax),%eax
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	51                   	push   %ecx
  800f05:	50                   	push   %eax
  800f06:	68 8c 28 80 00       	push   $0x80288c
  800f0b:	e8 5d f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 10             	sub    $0x10,%esp
  800f2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f34:	50                   	push   %eax
  800f35:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f3b:	c1 e8 0c             	shr    $0xc,%eax
  800f3e:	50                   	push   %eax
  800f3f:	e8 36 ff ff ff       	call   800e7a <fd_lookup>
  800f44:	83 c4 08             	add    $0x8,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 05                	js     800f50 <fd_close+0x2d>
	    || fd != fd2)
  800f4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4e:	74 0c                	je     800f5c <fd_close+0x39>
		return (must_exist ? r : 0);
  800f50:	84 db                	test   %bl,%bl
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	0f 44 c2             	cmove  %edx,%eax
  800f5a:	eb 41                	jmp    800f9d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f62:	50                   	push   %eax
  800f63:	ff 36                	pushl  (%esi)
  800f65:	e8 66 ff ff ff       	call   800ed0 <dev_lookup>
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 1a                	js     800f8d <fd_close+0x6a>
		if (dev->dev_close)
  800f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f76:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	74 0b                	je     800f8d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	56                   	push   %esi
  800f86:	ff d0                	call   *%eax
  800f88:	89 c3                	mov    %eax,%ebx
  800f8a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	56                   	push   %esi
  800f91:	6a 00                	push   $0x0
  800f93:	e8 00 fd ff ff       	call   800c98 <sys_page_unmap>
	return r;
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	89 d8                	mov    %ebx,%eax
}
  800f9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fad:	50                   	push   %eax
  800fae:	ff 75 08             	pushl  0x8(%ebp)
  800fb1:	e8 c4 fe ff ff       	call   800e7a <fd_lookup>
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 10                	js     800fcd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	6a 01                	push   $0x1
  800fc2:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc5:	e8 59 ff ff ff       	call   800f23 <fd_close>
  800fca:	83 c4 10             	add    $0x10,%esp
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <close_all>:

void
close_all(void)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	53                   	push   %ebx
  800fdf:	e8 c0 ff ff ff       	call   800fa4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe4:	83 c3 01             	add    $0x1,%ebx
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	83 fb 20             	cmp    $0x20,%ebx
  800fed:	75 ec                	jne    800fdb <close_all+0xc>
		close(i);
}
  800fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 2c             	sub    $0x2c,%esp
  800ffd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801000:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	ff 75 08             	pushl  0x8(%ebp)
  801007:	e8 6e fe ff ff       	call   800e7a <fd_lookup>
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	0f 88 c1 00 00 00    	js     8010d8 <dup+0xe4>
		return r;
	close(newfdnum);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	56                   	push   %esi
  80101b:	e8 84 ff ff ff       	call   800fa4 <close>

	newfd = INDEX2FD(newfdnum);
  801020:	89 f3                	mov    %esi,%ebx
  801022:	c1 e3 0c             	shl    $0xc,%ebx
  801025:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80102b:	83 c4 04             	add    $0x4,%esp
  80102e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801031:	e8 de fd ff ff       	call   800e14 <fd2data>
  801036:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801038:	89 1c 24             	mov    %ebx,(%esp)
  80103b:	e8 d4 fd ff ff       	call   800e14 <fd2data>
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801046:	89 f8                	mov    %edi,%eax
  801048:	c1 e8 16             	shr    $0x16,%eax
  80104b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801052:	a8 01                	test   $0x1,%al
  801054:	74 37                	je     80108d <dup+0x99>
  801056:	89 f8                	mov    %edi,%eax
  801058:	c1 e8 0c             	shr    $0xc,%eax
  80105b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801062:	f6 c2 01             	test   $0x1,%dl
  801065:	74 26                	je     80108d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801067:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	25 07 0e 00 00       	and    $0xe07,%eax
  801076:	50                   	push   %eax
  801077:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107a:	6a 00                	push   $0x0
  80107c:	57                   	push   %edi
  80107d:	6a 00                	push   $0x0
  80107f:	e8 d2 fb ff ff       	call   800c56 <sys_page_map>
  801084:	89 c7                	mov    %eax,%edi
  801086:	83 c4 20             	add    $0x20,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 2e                	js     8010bb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801090:	89 d0                	mov    %edx,%eax
  801092:	c1 e8 0c             	shr    $0xc,%eax
  801095:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a4:	50                   	push   %eax
  8010a5:	53                   	push   %ebx
  8010a6:	6a 00                	push   $0x0
  8010a8:	52                   	push   %edx
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 a6 fb ff ff       	call   800c56 <sys_page_map>
  8010b0:	89 c7                	mov    %eax,%edi
  8010b2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b7:	85 ff                	test   %edi,%edi
  8010b9:	79 1d                	jns    8010d8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	53                   	push   %ebx
  8010bf:	6a 00                	push   $0x0
  8010c1:	e8 d2 fb ff ff       	call   800c98 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c6:	83 c4 08             	add    $0x8,%esp
  8010c9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 c5 fb ff ff       	call   800c98 <sys_page_unmap>
	return r;
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	89 f8                	mov    %edi,%eax
}
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 14             	sub    $0x14,%esp
  8010e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	53                   	push   %ebx
  8010ef:	e8 86 fd ff ff       	call   800e7a <fd_lookup>
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 6d                	js     80116a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801107:	ff 30                	pushl  (%eax)
  801109:	e8 c2 fd ff ff       	call   800ed0 <dev_lookup>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 4c                	js     801161 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801115:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801118:	8b 42 08             	mov    0x8(%edx),%eax
  80111b:	83 e0 03             	and    $0x3,%eax
  80111e:	83 f8 01             	cmp    $0x1,%eax
  801121:	75 21                	jne    801144 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801123:	a1 04 40 80 00       	mov    0x804004,%eax
  801128:	8b 40 48             	mov    0x48(%eax),%eax
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	53                   	push   %ebx
  80112f:	50                   	push   %eax
  801130:	68 cd 28 80 00       	push   $0x8028cd
  801135:	e8 33 f1 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801142:	eb 26                	jmp    80116a <read+0x8a>
	}
	if (!dev->dev_read)
  801144:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801147:	8b 40 08             	mov    0x8(%eax),%eax
  80114a:	85 c0                	test   %eax,%eax
  80114c:	74 17                	je     801165 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	ff 75 10             	pushl  0x10(%ebp)
  801154:	ff 75 0c             	pushl  0xc(%ebp)
  801157:	52                   	push   %edx
  801158:	ff d0                	call   *%eax
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	eb 09                	jmp    80116a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801161:	89 c2                	mov    %eax,%edx
  801163:	eb 05                	jmp    80116a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801165:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80116a:	89 d0                	mov    %edx,%eax
  80116c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	eb 21                	jmp    8011a8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801187:	83 ec 04             	sub    $0x4,%esp
  80118a:	89 f0                	mov    %esi,%eax
  80118c:	29 d8                	sub    %ebx,%eax
  80118e:	50                   	push   %eax
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	03 45 0c             	add    0xc(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	57                   	push   %edi
  801196:	e8 45 ff ff ff       	call   8010e0 <read>
		if (m < 0)
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 10                	js     8011b2 <readn+0x41>
			return m;
		if (m == 0)
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	74 0a                	je     8011b0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a6:	01 c3                	add    %eax,%ebx
  8011a8:	39 f3                	cmp    %esi,%ebx
  8011aa:	72 db                	jb     801187 <readn+0x16>
  8011ac:	89 d8                	mov    %ebx,%eax
  8011ae:	eb 02                	jmp    8011b2 <readn+0x41>
  8011b0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 14             	sub    $0x14,%esp
  8011c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	53                   	push   %ebx
  8011c9:	e8 ac fc ff ff       	call   800e7a <fd_lookup>
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 68                	js     80123f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dd:	50                   	push   %eax
  8011de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e1:	ff 30                	pushl  (%eax)
  8011e3:	e8 e8 fc ff ff       	call   800ed0 <dev_lookup>
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 47                	js     801236 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f6:	75 21                	jne    801219 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fd:	8b 40 48             	mov    0x48(%eax),%eax
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	53                   	push   %ebx
  801204:	50                   	push   %eax
  801205:	68 e9 28 80 00       	push   $0x8028e9
  80120a:	e8 5e f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801217:	eb 26                	jmp    80123f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801219:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121c:	8b 52 0c             	mov    0xc(%edx),%edx
  80121f:	85 d2                	test   %edx,%edx
  801221:	74 17                	je     80123a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	ff 75 10             	pushl  0x10(%ebp)
  801229:	ff 75 0c             	pushl  0xc(%ebp)
  80122c:	50                   	push   %eax
  80122d:	ff d2                	call   *%edx
  80122f:	89 c2                	mov    %eax,%edx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	eb 09                	jmp    80123f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801236:	89 c2                	mov    %eax,%edx
  801238:	eb 05                	jmp    80123f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80123a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123f:	89 d0                	mov    %edx,%eax
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <seek>:

int
seek(int fdnum, off_t offset)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 22 fc ff ff       	call   800e7a <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 0e                	js     80126d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801262:	8b 55 0c             	mov    0xc(%ebp),%edx
  801265:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801268:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	83 ec 14             	sub    $0x14,%esp
  801276:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801279:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	53                   	push   %ebx
  80127e:	e8 f7 fb ff ff       	call   800e7a <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	89 c2                	mov    %eax,%edx
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 65                	js     8012f1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801292:	50                   	push   %eax
  801293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801296:	ff 30                	pushl  (%eax)
  801298:	e8 33 fc ff ff       	call   800ed0 <dev_lookup>
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 44                	js     8012e8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ab:	75 21                	jne    8012ce <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ad:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b2:	8b 40 48             	mov    0x48(%eax),%eax
  8012b5:	83 ec 04             	sub    $0x4,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	50                   	push   %eax
  8012ba:	68 ac 28 80 00       	push   $0x8028ac
  8012bf:	e8 a9 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012cc:	eb 23                	jmp    8012f1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d1:	8b 52 18             	mov    0x18(%edx),%edx
  8012d4:	85 d2                	test   %edx,%edx
  8012d6:	74 14                	je     8012ec <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	ff 75 0c             	pushl  0xc(%ebp)
  8012de:	50                   	push   %eax
  8012df:	ff d2                	call   *%edx
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	eb 09                	jmp    8012f1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	eb 05                	jmp    8012f1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f1:	89 d0                	mov    %edx,%eax
  8012f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 14             	sub    $0x14,%esp
  8012ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	ff 75 08             	pushl  0x8(%ebp)
  801309:	e8 6c fb ff ff       	call   800e7a <fd_lookup>
  80130e:	83 c4 08             	add    $0x8,%esp
  801311:	89 c2                	mov    %eax,%edx
  801313:	85 c0                	test   %eax,%eax
  801315:	78 58                	js     80136f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131d:	50                   	push   %eax
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	ff 30                	pushl  (%eax)
  801323:	e8 a8 fb ff ff       	call   800ed0 <dev_lookup>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 37                	js     801366 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801332:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801336:	74 32                	je     80136a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801338:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801342:	00 00 00 
	stat->st_isdir = 0;
  801345:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134c:	00 00 00 
	stat->st_dev = dev;
  80134f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	53                   	push   %ebx
  801359:	ff 75 f0             	pushl  -0x10(%ebp)
  80135c:	ff 50 14             	call   *0x14(%eax)
  80135f:	89 c2                	mov    %eax,%edx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	eb 09                	jmp    80136f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	89 c2                	mov    %eax,%edx
  801368:	eb 05                	jmp    80136f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80136a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	56                   	push   %esi
  80137a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	6a 00                	push   $0x0
  801380:	ff 75 08             	pushl  0x8(%ebp)
  801383:	e8 e3 01 00 00       	call   80156b <open>
  801388:	89 c3                	mov    %eax,%ebx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 1b                	js     8013ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	ff 75 0c             	pushl  0xc(%ebp)
  801397:	50                   	push   %eax
  801398:	e8 5b ff ff ff       	call   8012f8 <fstat>
  80139d:	89 c6                	mov    %eax,%esi
	close(fd);
  80139f:	89 1c 24             	mov    %ebx,(%esp)
  8013a2:	e8 fd fb ff ff       	call   800fa4 <close>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	89 f0                	mov    %esi,%eax
}
  8013ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	56                   	push   %esi
  8013b7:	53                   	push   %ebx
  8013b8:	89 c6                	mov    %eax,%esi
  8013ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c3:	75 12                	jne    8013d7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	6a 01                	push   $0x1
  8013ca:	e8 7c 0d 00 00       	call   80214b <ipc_find_env>
  8013cf:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d7:	6a 07                	push   $0x7
  8013d9:	68 00 50 80 00       	push   $0x805000
  8013de:	56                   	push   %esi
  8013df:	ff 35 00 40 80 00    	pushl  0x804000
  8013e5:	e8 0d 0d 00 00       	call   8020f7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ea:	83 c4 0c             	add    $0xc,%esp
  8013ed:	6a 00                	push   $0x0
  8013ef:	53                   	push   %ebx
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 ab 0c 00 00       	call   8020a2 <ipc_recv>
}
  8013f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fa:	5b                   	pop    %ebx
  8013fb:	5e                   	pop    %esi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	8b 40 0c             	mov    0xc(%eax),%eax
  80140a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801412:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801417:	ba 00 00 00 00       	mov    $0x0,%edx
  80141c:	b8 02 00 00 00       	mov    $0x2,%eax
  801421:	e8 8d ff ff ff       	call   8013b3 <fsipc>
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142e:	8b 45 08             	mov    0x8(%ebp),%eax
  801431:	8b 40 0c             	mov    0xc(%eax),%eax
  801434:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801439:	ba 00 00 00 00       	mov    $0x0,%edx
  80143e:	b8 06 00 00 00       	mov    $0x6,%eax
  801443:	e8 6b ff ff ff       	call   8013b3 <fsipc>
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	53                   	push   %ebx
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801454:	8b 45 08             	mov    0x8(%ebp),%eax
  801457:	8b 40 0c             	mov    0xc(%eax),%eax
  80145a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145f:	ba 00 00 00 00       	mov    $0x0,%edx
  801464:	b8 05 00 00 00       	mov    $0x5,%eax
  801469:	e8 45 ff ff ff       	call   8013b3 <fsipc>
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 2c                	js     80149e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	68 00 50 80 00       	push   $0x805000
  80147a:	53                   	push   %ebx
  80147b:	e8 90 f3 ff ff       	call   800810 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801480:	a1 80 50 80 00       	mov    0x805080,%eax
  801485:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148b:	a1 84 50 80 00       	mov    0x805084,%eax
  801490:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8014af:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b2:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  8014b8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014bd:	ba 00 10 00 00       	mov    $0x1000,%edx
  8014c2:	0f 47 c2             	cmova  %edx,%eax
  8014c5:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014ca:	50                   	push   %eax
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	68 08 50 80 00       	push   $0x805008
  8014d3:	e8 ca f4 ff ff       	call   8009a2 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  8014d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dd:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e2:	e8 cc fe ff ff       	call   8013b3 <fsipc>
    return r;
}
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	56                   	push   %esi
  8014ed:	53                   	push   %ebx
  8014ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014fc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801502:	ba 00 00 00 00       	mov    $0x0,%edx
  801507:	b8 03 00 00 00       	mov    $0x3,%eax
  80150c:	e8 a2 fe ff ff       	call   8013b3 <fsipc>
  801511:	89 c3                	mov    %eax,%ebx
  801513:	85 c0                	test   %eax,%eax
  801515:	78 4b                	js     801562 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801517:	39 c6                	cmp    %eax,%esi
  801519:	73 16                	jae    801531 <devfile_read+0x48>
  80151b:	68 18 29 80 00       	push   $0x802918
  801520:	68 1f 29 80 00       	push   $0x80291f
  801525:	6a 7c                	push   $0x7c
  801527:	68 34 29 80 00       	push   $0x802934
  80152c:	e8 63 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801531:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801536:	7e 16                	jle    80154e <devfile_read+0x65>
  801538:	68 3f 29 80 00       	push   $0x80293f
  80153d:	68 1f 29 80 00       	push   $0x80291f
  801542:	6a 7d                	push   $0x7d
  801544:	68 34 29 80 00       	push   $0x802934
  801549:	e8 46 ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	50                   	push   %eax
  801552:	68 00 50 80 00       	push   $0x805000
  801557:	ff 75 0c             	pushl  0xc(%ebp)
  80155a:	e8 43 f4 ff ff       	call   8009a2 <memmove>
	return r;
  80155f:	83 c4 10             	add    $0x10,%esp
}
  801562:	89 d8                	mov    %ebx,%eax
  801564:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 20             	sub    $0x20,%esp
  801572:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801575:	53                   	push   %ebx
  801576:	e8 5c f2 ff ff       	call   8007d7 <strlen>
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801583:	7f 67                	jg     8015ec <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	e8 9a f8 ff ff       	call   800e2b <fd_alloc>
  801591:	83 c4 10             	add    $0x10,%esp
		return r;
  801594:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801596:	85 c0                	test   %eax,%eax
  801598:	78 57                	js     8015f1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	53                   	push   %ebx
  80159e:	68 00 50 80 00       	push   $0x805000
  8015a3:	e8 68 f2 ff ff       	call   800810 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ab:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b8:	e8 f6 fd ff ff       	call   8013b3 <fsipc>
  8015bd:	89 c3                	mov    %eax,%ebx
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	79 14                	jns    8015da <open+0x6f>
		fd_close(fd, 0);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	6a 00                	push   $0x0
  8015cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ce:	e8 50 f9 ff ff       	call   800f23 <fd_close>
		return r;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	89 da                	mov    %ebx,%edx
  8015d8:	eb 17                	jmp    8015f1 <open+0x86>
	}

	return fd2num(fd);
  8015da:	83 ec 0c             	sub    $0xc,%esp
  8015dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e0:	e8 1f f8 ff ff       	call   800e04 <fd2num>
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	eb 05                	jmp    8015f1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ec:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015f1:	89 d0                	mov    %edx,%eax
  8015f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801603:	b8 08 00 00 00       	mov    $0x8,%eax
  801608:	e8 a6 fd ff ff       	call   8013b3 <fsipc>
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	57                   	push   %edi
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80161b:	6a 00                	push   $0x0
  80161d:	ff 75 08             	pushl  0x8(%ebp)
  801620:	e8 46 ff ff ff       	call   80156b <open>
  801625:	89 c7                	mov    %eax,%edi
  801627:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	0f 88 ae 04 00 00    	js     801ae6 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801638:	83 ec 04             	sub    $0x4,%esp
  80163b:	68 00 02 00 00       	push   $0x200
  801640:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	57                   	push   %edi
  801648:	e8 24 fb ff ff       	call   801171 <readn>
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	3d 00 02 00 00       	cmp    $0x200,%eax
  801655:	75 0c                	jne    801663 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801657:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80165e:	45 4c 46 
  801661:	74 33                	je     801696 <spawn+0x87>
		close(fd);
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80166c:	e8 33 f9 ff ff       	call   800fa4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801671:	83 c4 0c             	add    $0xc,%esp
  801674:	68 7f 45 4c 46       	push   $0x464c457f
  801679:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80167f:	68 4b 29 80 00       	push   $0x80294b
  801684:	e8 e4 eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801691:	e9 b0 04 00 00       	jmp    801b46 <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801696:	b8 07 00 00 00       	mov    $0x7,%eax
  80169b:	cd 30                	int    $0x30
  80169d:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016a3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	0f 88 3d 04 00 00    	js     801aee <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016b1:	89 c6                	mov    %eax,%esi
  8016b3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016b9:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016bc:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016c2:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016c8:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016cf:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016d5:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016db:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016e0:	be 00 00 00 00       	mov    $0x0,%esi
  8016e5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016e8:	eb 13                	jmp    8016fd <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016ea:	83 ec 0c             	sub    $0xc,%esp
  8016ed:	50                   	push   %eax
  8016ee:	e8 e4 f0 ff ff       	call   8007d7 <strlen>
  8016f3:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016f7:	83 c3 01             	add    $0x1,%ebx
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801704:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801707:	85 c0                	test   %eax,%eax
  801709:	75 df                	jne    8016ea <spawn+0xdb>
  80170b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801711:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801717:	bf 00 10 40 00       	mov    $0x401000,%edi
  80171c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80171e:	89 fa                	mov    %edi,%edx
  801720:	83 e2 fc             	and    $0xfffffffc,%edx
  801723:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80172a:	29 c2                	sub    %eax,%edx
  80172c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801732:	8d 42 f8             	lea    -0x8(%edx),%eax
  801735:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80173a:	0f 86 be 03 00 00    	jbe    801afe <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801740:	83 ec 04             	sub    $0x4,%esp
  801743:	6a 07                	push   $0x7
  801745:	68 00 00 40 00       	push   $0x400000
  80174a:	6a 00                	push   $0x0
  80174c:	e8 c2 f4 ff ff       	call   800c13 <sys_page_alloc>
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	0f 88 a9 03 00 00    	js     801b05 <spawn+0x4f6>
  80175c:	be 00 00 00 00       	mov    $0x0,%esi
  801761:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801767:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80176a:	eb 30                	jmp    80179c <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80176c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801772:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801778:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801781:	57                   	push   %edi
  801782:	e8 89 f0 ff ff       	call   800810 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801787:	83 c4 04             	add    $0x4,%esp
  80178a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80178d:	e8 45 f0 ff ff       	call   8007d7 <strlen>
  801792:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801796:	83 c6 01             	add    $0x1,%esi
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017a2:	7f c8                	jg     80176c <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017a4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017aa:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017b0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017b7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017bd:	74 19                	je     8017d8 <spawn+0x1c9>
  8017bf:	68 c0 29 80 00       	push   $0x8029c0
  8017c4:	68 1f 29 80 00       	push   $0x80291f
  8017c9:	68 f2 00 00 00       	push   $0xf2
  8017ce:	68 65 29 80 00       	push   $0x802965
  8017d3:	e8 bc e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017d8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8017de:	89 f8                	mov    %edi,%eax
  8017e0:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017e5:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8017e8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017ee:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017f1:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8017f7:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	6a 07                	push   $0x7
  801802:	68 00 d0 bf ee       	push   $0xeebfd000
  801807:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80180d:	68 00 00 40 00       	push   $0x400000
  801812:	6a 00                	push   $0x0
  801814:	e8 3d f4 ff ff       	call   800c56 <sys_page_map>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	83 c4 20             	add    $0x20,%esp
  80181e:	85 c0                	test   %eax,%eax
  801820:	0f 88 0e 03 00 00    	js     801b34 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	68 00 00 40 00       	push   $0x400000
  80182e:	6a 00                	push   $0x0
  801830:	e8 63 f4 ff ff       	call   800c98 <sys_page_unmap>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	0f 88 f2 02 00 00    	js     801b34 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801842:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801848:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80184f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801855:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80185c:	00 00 00 
  80185f:	e9 88 01 00 00       	jmp    8019ec <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801864:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80186a:	83 38 01             	cmpl   $0x1,(%eax)
  80186d:	0f 85 6b 01 00 00    	jne    8019de <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801873:	89 c7                	mov    %eax,%edi
  801875:	8b 40 18             	mov    0x18(%eax),%eax
  801878:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80187e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801881:	83 f8 01             	cmp    $0x1,%eax
  801884:	19 c0                	sbb    %eax,%eax
  801886:	83 e0 fe             	and    $0xfffffffe,%eax
  801889:	83 c0 07             	add    $0x7,%eax
  80188c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801892:	89 f8                	mov    %edi,%eax
  801894:	8b 7f 04             	mov    0x4(%edi),%edi
  801897:	89 f9                	mov    %edi,%ecx
  801899:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80189f:	8b 78 10             	mov    0x10(%eax),%edi
  8018a2:	8b 50 14             	mov    0x14(%eax),%edx
  8018a5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8018ab:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018ae:	89 f0                	mov    %esi,%eax
  8018b0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018b5:	74 14                	je     8018cb <spawn+0x2bc>
		va -= i;
  8018b7:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018b9:	01 c2                	add    %eax,%edx
  8018bb:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018c1:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018c3:	29 c1                	sub    %eax,%ecx
  8018c5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d0:	e9 f7 00 00 00       	jmp    8019cc <spawn+0x3bd>
		if (i >= filesz) {
  8018d5:	39 df                	cmp    %ebx,%edi
  8018d7:	77 27                	ja     801900 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018d9:	83 ec 04             	sub    $0x4,%esp
  8018dc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018e2:	56                   	push   %esi
  8018e3:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018e9:	e8 25 f3 ff ff       	call   800c13 <sys_page_alloc>
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	0f 89 c7 00 00 00    	jns    8019c0 <spawn+0x3b1>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	e9 13 02 00 00       	jmp    801b13 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	6a 07                	push   $0x7
  801905:	68 00 00 40 00       	push   $0x400000
  80190a:	6a 00                	push   $0x0
  80190c:	e8 02 f3 ff ff       	call   800c13 <sys_page_alloc>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	0f 88 ed 01 00 00    	js     801b09 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801925:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80192b:	50                   	push   %eax
  80192c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801932:	e8 0f f9 ff ff       	call   801246 <seek>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	0f 88 cb 01 00 00    	js     801b0d <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801942:	83 ec 04             	sub    $0x4,%esp
  801945:	89 f8                	mov    %edi,%eax
  801947:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80194d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801952:	ba 00 10 00 00       	mov    $0x1000,%edx
  801957:	0f 47 c2             	cmova  %edx,%eax
  80195a:	50                   	push   %eax
  80195b:	68 00 00 40 00       	push   $0x400000
  801960:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801966:	e8 06 f8 ff ff       	call   801171 <readn>
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	0f 88 9b 01 00 00    	js     801b11 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80197f:	56                   	push   %esi
  801980:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801986:	68 00 00 40 00       	push   $0x400000
  80198b:	6a 00                	push   $0x0
  80198d:	e8 c4 f2 ff ff       	call   800c56 <sys_page_map>
  801992:	83 c4 20             	add    $0x20,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	79 15                	jns    8019ae <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801999:	50                   	push   %eax
  80199a:	68 71 29 80 00       	push   $0x802971
  80199f:	68 25 01 00 00       	push   $0x125
  8019a4:	68 65 29 80 00       	push   $0x802965
  8019a9:	e8 e6 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	68 00 00 40 00       	push   $0x400000
  8019b6:	6a 00                	push   $0x0
  8019b8:	e8 db f2 ff ff       	call   800c98 <sys_page_unmap>
  8019bd:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019c6:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019cc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019d2:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8019d8:	0f 87 f7 fe ff ff    	ja     8018d5 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019de:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8019e5:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019ec:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019f3:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019f9:	0f 8c 65 fe ff ff    	jl     801864 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a08:	e8 97 f5 ff ff       	call   800fa4 <close>
  801a0d:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801a10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a15:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801a1b:	89 d8                	mov    %ebx,%eax
  801a1d:	c1 e8 16             	shr    $0x16,%eax
  801a20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a27:	a8 01                	test   $0x1,%al
  801a29:	74 46                	je     801a71 <spawn+0x462>
  801a2b:	89 d8                	mov    %ebx,%eax
  801a2d:	c1 e8 0c             	shr    $0xc,%eax
  801a30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a37:	f6 c2 01             	test   $0x1,%dl
  801a3a:	74 35                	je     801a71 <spawn+0x462>
  801a3c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a43:	f6 c2 04             	test   $0x4,%dl
  801a46:	74 29                	je     801a71 <spawn+0x462>
  801a48:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a4f:	f6 c6 04             	test   $0x4,%dh
  801a52:	74 1d                	je     801a71 <spawn+0x462>
			// cprintf("copy shared page %d to env:%x\n", PGNUM(addr), child);
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801a54:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	25 07 0e 00 00       	and    $0xe07,%eax
  801a63:	50                   	push   %eax
  801a64:	53                   	push   %ebx
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	6a 00                	push   $0x0
  801a69:	e8 e8 f1 ff ff       	call   800c56 <sys_page_map>
  801a6e:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
   	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801a71:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a77:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a7d:	75 9c                	jne    801a1b <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801a7f:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801a86:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a89:	83 ec 08             	sub    $0x8,%esp
  801a8c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a99:	e8 7e f2 ff ff       	call   800d1c <sys_env_set_trapframe>
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	79 15                	jns    801aba <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801aa5:	50                   	push   %eax
  801aa6:	68 8e 29 80 00       	push   $0x80298e
  801aab:	68 86 00 00 00       	push   $0x86
  801ab0:	68 65 29 80 00       	push   $0x802965
  801ab5:	e8 da e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	6a 02                	push   $0x2
  801abf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ac5:	e8 10 f2 ff ff       	call   800cda <sys_env_set_status>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	79 25                	jns    801af6 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801ad1:	50                   	push   %eax
  801ad2:	68 a8 29 80 00       	push   $0x8029a8
  801ad7:	68 89 00 00 00       	push   $0x89
  801adc:	68 65 29 80 00       	push   $0x802965
  801ae1:	e8 ae e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ae6:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801aec:	eb 58                	jmp    801b46 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801aee:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801af4:	eb 50                	jmp    801b46 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801af6:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801afc:	eb 48                	jmp    801b46 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801afe:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b03:	eb 41                	jmp    801b46 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	eb 3d                	jmp    801b46 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	eb 06                	jmp    801b13 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b0d:	89 c3                	mov    %eax,%ebx
  801b0f:	eb 02                	jmp    801b13 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b11:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b1c:	e8 73 f0 ff ff       	call   800b94 <sys_env_destroy>
	close(fd);
  801b21:	83 c4 04             	add    $0x4,%esp
  801b24:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b2a:	e8 75 f4 ff ff       	call   800fa4 <close>
	return r;
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	eb 12                	jmp    801b46 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b34:	83 ec 08             	sub    $0x8,%esp
  801b37:	68 00 00 40 00       	push   $0x400000
  801b3c:	6a 00                	push   $0x0
  801b3e:	e8 55 f1 ff ff       	call   800c98 <sys_page_unmap>
  801b43:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b46:	89 d8                	mov    %ebx,%eax
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b55:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b5d:	eb 03                	jmp    801b62 <spawnl+0x12>
		argc++;
  801b5f:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b62:	83 c2 04             	add    $0x4,%edx
  801b65:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b69:	75 f4                	jne    801b5f <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b6b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b72:	83 e2 f0             	and    $0xfffffff0,%edx
  801b75:	29 d4                	sub    %edx,%esp
  801b77:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b7b:	c1 ea 02             	shr    $0x2,%edx
  801b7e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b85:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b91:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b98:	00 
  801b99:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba0:	eb 0a                	jmp    801bac <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ba2:	83 c0 01             	add    $0x1,%eax
  801ba5:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ba9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bac:	39 d0                	cmp    %edx,%eax
  801bae:	75 f2                	jne    801ba2 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bb0:	83 ec 08             	sub    $0x8,%esp
  801bb3:	56                   	push   %esi
  801bb4:	ff 75 08             	pushl  0x8(%ebp)
  801bb7:	e8 53 fa ff ff       	call   80160f <spawn>
}
  801bbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	ff 75 08             	pushl  0x8(%ebp)
  801bd1:	e8 3e f2 ff ff       	call   800e14 <fd2data>
  801bd6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bd8:	83 c4 08             	add    $0x8,%esp
  801bdb:	68 e8 29 80 00       	push   $0x8029e8
  801be0:	53                   	push   %ebx
  801be1:	e8 2a ec ff ff       	call   800810 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801be6:	8b 46 04             	mov    0x4(%esi),%eax
  801be9:	2b 06                	sub    (%esi),%eax
  801beb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bf1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bf8:	00 00 00 
	stat->st_dev = &devpipe;
  801bfb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c02:	30 80 00 
	return 0;
}
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c1b:	53                   	push   %ebx
  801c1c:	6a 00                	push   $0x0
  801c1e:	e8 75 f0 ff ff       	call   800c98 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c23:	89 1c 24             	mov    %ebx,(%esp)
  801c26:	e8 e9 f1 ff ff       	call   800e14 <fd2data>
  801c2b:	83 c4 08             	add    $0x8,%esp
  801c2e:	50                   	push   %eax
  801c2f:	6a 00                	push   $0x0
  801c31:	e8 62 f0 ff ff       	call   800c98 <sys_page_unmap>
}
  801c36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	57                   	push   %edi
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 1c             	sub    $0x1c,%esp
  801c44:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c47:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c49:	a1 04 40 80 00       	mov    0x804004,%eax
  801c4e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	ff 75 e0             	pushl  -0x20(%ebp)
  801c57:	e8 28 05 00 00       	call   802184 <pageref>
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	89 3c 24             	mov    %edi,(%esp)
  801c61:	e8 1e 05 00 00       	call   802184 <pageref>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	39 c3                	cmp    %eax,%ebx
  801c6b:	0f 94 c1             	sete   %cl
  801c6e:	0f b6 c9             	movzbl %cl,%ecx
  801c71:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c74:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c7a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c7d:	39 ce                	cmp    %ecx,%esi
  801c7f:	74 1b                	je     801c9c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c81:	39 c3                	cmp    %eax,%ebx
  801c83:	75 c4                	jne    801c49 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c85:	8b 42 58             	mov    0x58(%edx),%eax
  801c88:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c8b:	50                   	push   %eax
  801c8c:	56                   	push   %esi
  801c8d:	68 ef 29 80 00       	push   $0x8029ef
  801c92:	e8 d6 e5 ff ff       	call   80026d <cprintf>
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	eb ad                	jmp    801c49 <_pipeisclosed+0xe>
	}
}
  801c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	57                   	push   %edi
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	83 ec 28             	sub    $0x28,%esp
  801cb0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cb3:	56                   	push   %esi
  801cb4:	e8 5b f1 ff ff       	call   800e14 <fd2data>
  801cb9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbb:	83 c4 10             	add    $0x10,%esp
  801cbe:	bf 00 00 00 00       	mov    $0x0,%edi
  801cc3:	eb 4b                	jmp    801d10 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cc5:	89 da                	mov    %ebx,%edx
  801cc7:	89 f0                	mov    %esi,%eax
  801cc9:	e8 6d ff ff ff       	call   801c3b <_pipeisclosed>
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	75 48                	jne    801d1a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cd2:	e8 1d ef ff ff       	call   800bf4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd7:	8b 43 04             	mov    0x4(%ebx),%eax
  801cda:	8b 0b                	mov    (%ebx),%ecx
  801cdc:	8d 51 20             	lea    0x20(%ecx),%edx
  801cdf:	39 d0                	cmp    %edx,%eax
  801ce1:	73 e2                	jae    801cc5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cea:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ced:	89 c2                	mov    %eax,%edx
  801cef:	c1 fa 1f             	sar    $0x1f,%edx
  801cf2:	89 d1                	mov    %edx,%ecx
  801cf4:	c1 e9 1b             	shr    $0x1b,%ecx
  801cf7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cfa:	83 e2 1f             	and    $0x1f,%edx
  801cfd:	29 ca                	sub    %ecx,%edx
  801cff:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d03:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d07:	83 c0 01             	add    $0x1,%eax
  801d0a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0d:	83 c7 01             	add    $0x1,%edi
  801d10:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d13:	75 c2                	jne    801cd7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d15:	8b 45 10             	mov    0x10(%ebp),%eax
  801d18:	eb 05                	jmp    801d1f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5f                   	pop    %edi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	57                   	push   %edi
  801d2b:	56                   	push   %esi
  801d2c:	53                   	push   %ebx
  801d2d:	83 ec 18             	sub    $0x18,%esp
  801d30:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d33:	57                   	push   %edi
  801d34:	e8 db f0 ff ff       	call   800e14 <fd2data>
  801d39:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d43:	eb 3d                	jmp    801d82 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d45:	85 db                	test   %ebx,%ebx
  801d47:	74 04                	je     801d4d <devpipe_read+0x26>
				return i;
  801d49:	89 d8                	mov    %ebx,%eax
  801d4b:	eb 44                	jmp    801d91 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	89 f8                	mov    %edi,%eax
  801d51:	e8 e5 fe ff ff       	call   801c3b <_pipeisclosed>
  801d56:	85 c0                	test   %eax,%eax
  801d58:	75 32                	jne    801d8c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d5a:	e8 95 ee ff ff       	call   800bf4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d5f:	8b 06                	mov    (%esi),%eax
  801d61:	3b 46 04             	cmp    0x4(%esi),%eax
  801d64:	74 df                	je     801d45 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d66:	99                   	cltd   
  801d67:	c1 ea 1b             	shr    $0x1b,%edx
  801d6a:	01 d0                	add    %edx,%eax
  801d6c:	83 e0 1f             	and    $0x1f,%eax
  801d6f:	29 d0                	sub    %edx,%eax
  801d71:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d79:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d7c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7f:	83 c3 01             	add    $0x1,%ebx
  801d82:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d85:	75 d8                	jne    801d5f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d87:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8a:	eb 05                	jmp    801d91 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d8c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    

00801d99 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801da1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da4:	50                   	push   %eax
  801da5:	e8 81 f0 ff ff       	call   800e2b <fd_alloc>
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	89 c2                	mov    %eax,%edx
  801daf:	85 c0                	test   %eax,%eax
  801db1:	0f 88 2c 01 00 00    	js     801ee3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db7:	83 ec 04             	sub    $0x4,%esp
  801dba:	68 07 04 00 00       	push   $0x407
  801dbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc2:	6a 00                	push   $0x0
  801dc4:	e8 4a ee ff ff       	call   800c13 <sys_page_alloc>
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	89 c2                	mov    %eax,%edx
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	0f 88 0d 01 00 00    	js     801ee3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dd6:	83 ec 0c             	sub    $0xc,%esp
  801dd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	e8 49 f0 ff ff       	call   800e2b <fd_alloc>
  801de2:	89 c3                	mov    %eax,%ebx
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	85 c0                	test   %eax,%eax
  801de9:	0f 88 e2 00 00 00    	js     801ed1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	68 07 04 00 00       	push   $0x407
  801df7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfa:	6a 00                	push   $0x0
  801dfc:	e8 12 ee ff ff       	call   800c13 <sys_page_alloc>
  801e01:	89 c3                	mov    %eax,%ebx
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	0f 88 c3 00 00 00    	js     801ed1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	ff 75 f4             	pushl  -0xc(%ebp)
  801e14:	e8 fb ef ff ff       	call   800e14 <fd2data>
  801e19:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1b:	83 c4 0c             	add    $0xc,%esp
  801e1e:	68 07 04 00 00       	push   $0x407
  801e23:	50                   	push   %eax
  801e24:	6a 00                	push   $0x0
  801e26:	e8 e8 ed ff ff       	call   800c13 <sys_page_alloc>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	0f 88 89 00 00 00    	js     801ec1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3e:	e8 d1 ef ff ff       	call   800e14 <fd2data>
  801e43:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e4a:	50                   	push   %eax
  801e4b:	6a 00                	push   $0x0
  801e4d:	56                   	push   %esi
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 01 ee ff ff       	call   800c56 <sys_page_map>
  801e55:	89 c3                	mov    %eax,%ebx
  801e57:	83 c4 20             	add    $0x20,%esp
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 55                	js     801eb3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e5e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e67:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e7c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e81:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e88:	83 ec 0c             	sub    $0xc,%esp
  801e8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8e:	e8 71 ef ff ff       	call   800e04 <fd2num>
  801e93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e96:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e98:	83 c4 04             	add    $0x4,%esp
  801e9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9e:	e8 61 ef ff ff       	call   800e04 <fd2num>
  801ea3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb1:	eb 30                	jmp    801ee3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801eb3:	83 ec 08             	sub    $0x8,%esp
  801eb6:	56                   	push   %esi
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 da ed ff ff       	call   800c98 <sys_page_unmap>
  801ebe:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ec1:	83 ec 08             	sub    $0x8,%esp
  801ec4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec7:	6a 00                	push   $0x0
  801ec9:	e8 ca ed ff ff       	call   800c98 <sys_page_unmap>
  801ece:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ed1:	83 ec 08             	sub    $0x8,%esp
  801ed4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 ba ed ff ff       	call   800c98 <sys_page_unmap>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ee3:	89 d0                	mov    %edx,%eax
  801ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef5:	50                   	push   %eax
  801ef6:	ff 75 08             	pushl  0x8(%ebp)
  801ef9:	e8 7c ef ff ff       	call   800e7a <fd_lookup>
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	85 c0                	test   %eax,%eax
  801f03:	78 18                	js     801f1d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f05:	83 ec 0c             	sub    $0xc,%esp
  801f08:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0b:	e8 04 ef ff ff       	call   800e14 <fd2data>
	return _pipeisclosed(fd, p);
  801f10:	89 c2                	mov    %eax,%edx
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	e8 21 fd ff ff       	call   801c3b <_pipeisclosed>
  801f1a:	83 c4 10             	add    $0x10,%esp
}
  801f1d:	c9                   	leave  
  801f1e:	c3                   	ret    

00801f1f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f22:	b8 00 00 00 00       	mov    $0x0,%eax
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f2f:	68 07 2a 80 00       	push   $0x802a07
  801f34:	ff 75 0c             	pushl  0xc(%ebp)
  801f37:	e8 d4 e8 ff ff       	call   800810 <strcpy>
	return 0;
}
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    

00801f43 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	57                   	push   %edi
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f4f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f54:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5a:	eb 2d                	jmp    801f89 <devcons_write+0x46>
		m = n - tot;
  801f5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f5f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f61:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f64:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f69:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f6c:	83 ec 04             	sub    $0x4,%esp
  801f6f:	53                   	push   %ebx
  801f70:	03 45 0c             	add    0xc(%ebp),%eax
  801f73:	50                   	push   %eax
  801f74:	57                   	push   %edi
  801f75:	e8 28 ea ff ff       	call   8009a2 <memmove>
		sys_cputs(buf, m);
  801f7a:	83 c4 08             	add    $0x8,%esp
  801f7d:	53                   	push   %ebx
  801f7e:	57                   	push   %edi
  801f7f:	e8 d3 eb ff ff       	call   800b57 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f84:	01 de                	add    %ebx,%esi
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	89 f0                	mov    %esi,%eax
  801f8b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f8e:	72 cc                	jb     801f5c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    

00801f98 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 08             	sub    $0x8,%esp
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fa3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fa7:	74 2a                	je     801fd3 <devcons_read+0x3b>
  801fa9:	eb 05                	jmp    801fb0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fab:	e8 44 ec ff ff       	call   800bf4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fb0:	e8 c0 eb ff ff       	call   800b75 <sys_cgetc>
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	74 f2                	je     801fab <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 16                	js     801fd3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fbd:	83 f8 04             	cmp    $0x4,%eax
  801fc0:	74 0c                	je     801fce <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fc5:	88 02                	mov    %al,(%edx)
	return 1;
  801fc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcc:	eb 05                	jmp    801fd3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fce:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fe1:	6a 01                	push   $0x1
  801fe3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe6:	50                   	push   %eax
  801fe7:	e8 6b eb ff ff       	call   800b57 <sys_cputs>
}
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	c9                   	leave  
  801ff0:	c3                   	ret    

00801ff1 <getchar>:

int
getchar(void)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ff7:	6a 01                	push   $0x1
  801ff9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	6a 00                	push   $0x0
  801fff:	e8 dc f0 ff ff       	call   8010e0 <read>
	if (r < 0)
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	78 0f                	js     80201a <getchar+0x29>
		return r;
	if (r < 1)
  80200b:	85 c0                	test   %eax,%eax
  80200d:	7e 06                	jle    802015 <getchar+0x24>
		return -E_EOF;
	return c;
  80200f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802013:	eb 05                	jmp    80201a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802015:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	50                   	push   %eax
  802026:	ff 75 08             	pushl  0x8(%ebp)
  802029:	e8 4c ee ff ff       	call   800e7a <fd_lookup>
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	78 11                	js     802046 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802035:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802038:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80203e:	39 10                	cmp    %edx,(%eax)
  802040:	0f 94 c0             	sete   %al
  802043:	0f b6 c0             	movzbl %al,%eax
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <opencons>:

int
opencons(void)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80204e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802051:	50                   	push   %eax
  802052:	e8 d4 ed ff ff       	call   800e2b <fd_alloc>
  802057:	83 c4 10             	add    $0x10,%esp
		return r;
  80205a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80205c:	85 c0                	test   %eax,%eax
  80205e:	78 3e                	js     80209e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802060:	83 ec 04             	sub    $0x4,%esp
  802063:	68 07 04 00 00       	push   $0x407
  802068:	ff 75 f4             	pushl  -0xc(%ebp)
  80206b:	6a 00                	push   $0x0
  80206d:	e8 a1 eb ff ff       	call   800c13 <sys_page_alloc>
  802072:	83 c4 10             	add    $0x10,%esp
		return r;
  802075:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802077:	85 c0                	test   %eax,%eax
  802079:	78 23                	js     80209e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80207b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802081:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802084:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802086:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802089:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802090:	83 ec 0c             	sub    $0xc,%esp
  802093:	50                   	push   %eax
  802094:	e8 6b ed ff ff       	call   800e04 <fd2num>
  802099:	89 c2                	mov    %eax,%edx
  80209b:	83 c4 10             	add    $0x10,%esp
}
  80209e:	89 d0                	mov    %edx,%eax
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	56                   	push   %esi
  8020a6:	53                   	push   %ebx
  8020a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8020aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020b7:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  8020ba:	83 ec 0c             	sub    $0xc,%esp
  8020bd:	50                   	push   %eax
  8020be:	e8 00 ed ff ff       	call   800dc3 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  8020c3:	83 c4 10             	add    $0x10,%esp
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	75 10                	jne    8020da <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  8020ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8020cf:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  8020d2:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  8020d5:	8b 40 70             	mov    0x70(%eax),%eax
  8020d8:	eb 0a                	jmp    8020e4 <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  8020da:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  8020df:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  8020e4:	85 f6                	test   %esi,%esi
  8020e6:	74 02                	je     8020ea <ipc_recv+0x48>
  8020e8:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  8020ea:	85 db                	test   %ebx,%ebx
  8020ec:	74 02                	je     8020f0 <ipc_recv+0x4e>
  8020ee:	89 13                	mov    %edx,(%ebx)

    return r;
}
  8020f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5d                   	pop    %ebp
  8020f6:	c3                   	ret    

008020f7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	57                   	push   %edi
  8020fb:	56                   	push   %esi
  8020fc:	53                   	push   %ebx
  8020fd:	83 ec 0c             	sub    $0xc,%esp
  802100:	8b 7d 08             	mov    0x8(%ebp),%edi
  802103:	8b 75 0c             	mov    0xc(%ebp),%esi
  802106:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  802109:	85 db                	test   %ebx,%ebx
  80210b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802110:	0f 44 d8             	cmove  %eax,%ebx
  802113:	eb 1c                	jmp    802131 <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  802115:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802118:	74 12                	je     80212c <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  80211a:	50                   	push   %eax
  80211b:	68 13 2a 80 00       	push   $0x802a13
  802120:	6a 40                	push   $0x40
  802122:	68 25 2a 80 00       	push   $0x802a25
  802127:	e8 68 e0 ff ff       	call   800194 <_panic>
        sys_yield();
  80212c:	e8 c3 ea ff ff       	call   800bf4 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802131:	ff 75 14             	pushl  0x14(%ebp)
  802134:	53                   	push   %ebx
  802135:	56                   	push   %esi
  802136:	57                   	push   %edi
  802137:	e8 64 ec ff ff       	call   800da0 <sys_ipc_try_send>
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 c0                	test   %eax,%eax
  802141:	75 d2                	jne    802115 <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  802143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802146:	5b                   	pop    %ebx
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    

0080214b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802151:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802156:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802159:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80215f:	8b 52 50             	mov    0x50(%edx),%edx
  802162:	39 ca                	cmp    %ecx,%edx
  802164:	75 0d                	jne    802173 <ipc_find_env+0x28>
			return envs[i].env_id;
  802166:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802169:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80216e:	8b 40 48             	mov    0x48(%eax),%eax
  802171:	eb 0f                	jmp    802182 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802173:	83 c0 01             	add    $0x1,%eax
  802176:	3d 00 04 00 00       	cmp    $0x400,%eax
  80217b:	75 d9                	jne    802156 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80217d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	c1 e8 16             	shr    $0x16,%eax
  80218f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802196:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219b:	f6 c1 01             	test   $0x1,%cl
  80219e:	74 1d                	je     8021bd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021a0:	c1 ea 0c             	shr    $0xc,%edx
  8021a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021aa:	f6 c2 01             	test   $0x1,%dl
  8021ad:	74 0e                	je     8021bd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021af:	c1 ea 0c             	shr    $0xc,%edx
  8021b2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021b9:	ef 
  8021ba:	0f b7 c0             	movzwl %ax,%eax
}
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    
  8021bf:	90                   	nop

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 f6                	test   %esi,%esi
  8021d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021dd:	89 ca                	mov    %ecx,%edx
  8021df:	89 f8                	mov    %edi,%eax
  8021e1:	75 3d                	jne    802220 <__udivdi3+0x60>
  8021e3:	39 cf                	cmp    %ecx,%edi
  8021e5:	0f 87 c5 00 00 00    	ja     8022b0 <__udivdi3+0xf0>
  8021eb:	85 ff                	test   %edi,%edi
  8021ed:	89 fd                	mov    %edi,%ebp
  8021ef:	75 0b                	jne    8021fc <__udivdi3+0x3c>
  8021f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f6:	31 d2                	xor    %edx,%edx
  8021f8:	f7 f7                	div    %edi
  8021fa:	89 c5                	mov    %eax,%ebp
  8021fc:	89 c8                	mov    %ecx,%eax
  8021fe:	31 d2                	xor    %edx,%edx
  802200:	f7 f5                	div    %ebp
  802202:	89 c1                	mov    %eax,%ecx
  802204:	89 d8                	mov    %ebx,%eax
  802206:	89 cf                	mov    %ecx,%edi
  802208:	f7 f5                	div    %ebp
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	39 ce                	cmp    %ecx,%esi
  802222:	77 74                	ja     802298 <__udivdi3+0xd8>
  802224:	0f bd fe             	bsr    %esi,%edi
  802227:	83 f7 1f             	xor    $0x1f,%edi
  80222a:	0f 84 98 00 00 00    	je     8022c8 <__udivdi3+0x108>
  802230:	bb 20 00 00 00       	mov    $0x20,%ebx
  802235:	89 f9                	mov    %edi,%ecx
  802237:	89 c5                	mov    %eax,%ebp
  802239:	29 fb                	sub    %edi,%ebx
  80223b:	d3 e6                	shl    %cl,%esi
  80223d:	89 d9                	mov    %ebx,%ecx
  80223f:	d3 ed                	shr    %cl,%ebp
  802241:	89 f9                	mov    %edi,%ecx
  802243:	d3 e0                	shl    %cl,%eax
  802245:	09 ee                	or     %ebp,%esi
  802247:	89 d9                	mov    %ebx,%ecx
  802249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224d:	89 d5                	mov    %edx,%ebp
  80224f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802253:	d3 ed                	shr    %cl,%ebp
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e2                	shl    %cl,%edx
  802259:	89 d9                	mov    %ebx,%ecx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	09 c2                	or     %eax,%edx
  80225f:	89 d0                	mov    %edx,%eax
  802261:	89 ea                	mov    %ebp,%edx
  802263:	f7 f6                	div    %esi
  802265:	89 d5                	mov    %edx,%ebp
  802267:	89 c3                	mov    %eax,%ebx
  802269:	f7 64 24 0c          	mull   0xc(%esp)
  80226d:	39 d5                	cmp    %edx,%ebp
  80226f:	72 10                	jb     802281 <__udivdi3+0xc1>
  802271:	8b 74 24 08          	mov    0x8(%esp),%esi
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e6                	shl    %cl,%esi
  802279:	39 c6                	cmp    %eax,%esi
  80227b:	73 07                	jae    802284 <__udivdi3+0xc4>
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	75 03                	jne    802284 <__udivdi3+0xc4>
  802281:	83 eb 01             	sub    $0x1,%ebx
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 d8                	mov    %ebx,%eax
  802288:	89 fa                	mov    %edi,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	31 ff                	xor    %edi,%edi
  80229a:	31 db                	xor    %ebx,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 d8                	mov    %ebx,%eax
  8022b2:	f7 f7                	div    %edi
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 c3                	mov    %eax,%ebx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 fa                	mov    %edi,%edx
  8022bc:	83 c4 1c             	add    $0x1c,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	39 ce                	cmp    %ecx,%esi
  8022ca:	72 0c                	jb     8022d8 <__udivdi3+0x118>
  8022cc:	31 db                	xor    %ebx,%ebx
  8022ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022d2:	0f 87 34 ff ff ff    	ja     80220c <__udivdi3+0x4c>
  8022d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022dd:	e9 2a ff ff ff       	jmp    80220c <__udivdi3+0x4c>
  8022e2:	66 90                	xchg   %ax,%ax
  8022e4:	66 90                	xchg   %ax,%ax
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 d2                	test   %edx,%edx
  802309:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80230d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802311:	89 f3                	mov    %esi,%ebx
  802313:	89 3c 24             	mov    %edi,(%esp)
  802316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80231a:	75 1c                	jne    802338 <__umoddi3+0x48>
  80231c:	39 f7                	cmp    %esi,%edi
  80231e:	76 50                	jbe    802370 <__umoddi3+0x80>
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	f7 f7                	div    %edi
  802326:	89 d0                	mov    %edx,%eax
  802328:	31 d2                	xor    %edx,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	89 d0                	mov    %edx,%eax
  80233c:	77 52                	ja     802390 <__umoddi3+0xa0>
  80233e:	0f bd ea             	bsr    %edx,%ebp
  802341:	83 f5 1f             	xor    $0x1f,%ebp
  802344:	75 5a                	jne    8023a0 <__umoddi3+0xb0>
  802346:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80234a:	0f 82 e0 00 00 00    	jb     802430 <__umoddi3+0x140>
  802350:	39 0c 24             	cmp    %ecx,(%esp)
  802353:	0f 86 d7 00 00 00    	jbe    802430 <__umoddi3+0x140>
  802359:	8b 44 24 08          	mov    0x8(%esp),%eax
  80235d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802361:	83 c4 1c             	add    $0x1c,%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	85 ff                	test   %edi,%edi
  802372:	89 fd                	mov    %edi,%ebp
  802374:	75 0b                	jne    802381 <__umoddi3+0x91>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f7                	div    %edi
  80237f:	89 c5                	mov    %eax,%ebp
  802381:	89 f0                	mov    %esi,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f5                	div    %ebp
  802387:	89 c8                	mov    %ecx,%eax
  802389:	f7 f5                	div    %ebp
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	eb 99                	jmp    802328 <__umoddi3+0x38>
  80238f:	90                   	nop
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	83 c4 1c             	add    $0x1c,%esp
  802397:	5b                   	pop    %ebx
  802398:	5e                   	pop    %esi
  802399:	5f                   	pop    %edi
  80239a:	5d                   	pop    %ebp
  80239b:	c3                   	ret    
  80239c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	8b 34 24             	mov    (%esp),%esi
  8023a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	29 ef                	sub    %ebp,%edi
  8023ac:	d3 e0                	shl    %cl,%eax
  8023ae:	89 f9                	mov    %edi,%ecx
  8023b0:	89 f2                	mov    %esi,%edx
  8023b2:	d3 ea                	shr    %cl,%edx
  8023b4:	89 e9                	mov    %ebp,%ecx
  8023b6:	09 c2                	or     %eax,%edx
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	89 14 24             	mov    %edx,(%esp)
  8023bd:	89 f2                	mov    %esi,%edx
  8023bf:	d3 e2                	shl    %cl,%edx
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	d3 e3                	shl    %cl,%ebx
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 d0                	mov    %edx,%eax
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	09 d8                	or     %ebx,%eax
  8023dd:	89 d3                	mov    %edx,%ebx
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	f7 34 24             	divl   (%esp)
  8023e4:	89 d6                	mov    %edx,%esi
  8023e6:	d3 e3                	shl    %cl,%ebx
  8023e8:	f7 64 24 04          	mull   0x4(%esp)
  8023ec:	39 d6                	cmp    %edx,%esi
  8023ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f2:	89 d1                	mov    %edx,%ecx
  8023f4:	89 c3                	mov    %eax,%ebx
  8023f6:	72 08                	jb     802400 <__umoddi3+0x110>
  8023f8:	75 11                	jne    80240b <__umoddi3+0x11b>
  8023fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023fe:	73 0b                	jae    80240b <__umoddi3+0x11b>
  802400:	2b 44 24 04          	sub    0x4(%esp),%eax
  802404:	1b 14 24             	sbb    (%esp),%edx
  802407:	89 d1                	mov    %edx,%ecx
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80240f:	29 da                	sub    %ebx,%edx
  802411:	19 ce                	sbb    %ecx,%esi
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 f0                	mov    %esi,%eax
  802417:	d3 e0                	shl    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	d3 ea                	shr    %cl,%edx
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	d3 ee                	shr    %cl,%esi
  802421:	09 d0                	or     %edx,%eax
  802423:	89 f2                	mov    %esi,%edx
  802425:	83 c4 1c             	add    $0x1c,%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	29 f9                	sub    %edi,%ecx
  802432:	19 d6                	sbb    %edx,%esi
  802434:	89 74 24 04          	mov    %esi,0x4(%esp)
  802438:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80243c:	e9 18 ff ff ff       	jmp    802359 <__umoddi3+0x69>
