
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
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
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 e0 22 80 00       	push   $0x8022e0
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 46 1b 00 00       	call   801b97 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 2e 23 80 00       	push   $0x80232e
  80005e:	6a 0d                	push   $0xd
  800060:	68 37 23 80 00       	push   $0x802337
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 0b 10 00 00       	call   80107a <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 4c 23 80 00       	push   $0x80234c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 37 23 80 00       	push   $0x802337
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 c0 12 00 00       	call   801356 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 55 23 80 00       	push   $0x802355
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 ce 12 00 00       	call   8013a6 <dup>
			sys_yield();
  8000d8:	e8 b9 0b 00 00       	call   800c96 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 6d 12 00 00       	call   801356 <close>
			sys_yield();
  8000e9:	e8 a8 0b 00 00       	call   800c96 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 c8 1b 00 00       	call   801cea <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 59 23 80 00       	push   $0x802359
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 f8 0a 00 00       	call   800c36 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 75 23 80 00       	push   $0x802375
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 79 1b 00 00       	call   801cea <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 04 23 80 00       	push   $0x802304
  800180:	6a 40                	push   $0x40
  800182:	68 37 23 80 00       	push   $0x802337
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 91 10 00 00       	call   80122c <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 8b 23 80 00       	push   $0x80238b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 37 23 80 00       	push   $0x802337
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 07 10 00 00       	call   8011c6 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 a3 23 80 00 	movl   $0x8023a3,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 91 0a 00 00       	call   800c77 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 5a 11 00 00       	call   801381 <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 05 0a 00 00       	call   800c36 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 2e 0a 00 00       	call   800c77 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 c4 23 80 00       	push   $0x8023c4
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 0b 29 80 00 	movl   $0x80290b,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 4d 09 00 00       	call   800bf9 <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 f2 08 00 00       	call   800bf9 <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 d9 1c 00 00       	call   802050 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 c6 1d 00 00       	call   802180 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 e7 23 80 00 	movsbl 0x8023e7(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 a7 03 00 00    	je     800809 <vprintfmt+0x3c3>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800498:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049d:	eb 07                	jmp    8004a6 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8d 47 01             	lea    0x1(%edi),%eax
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	0f b6 07             	movzbl (%edi),%eax
  8004af:	0f b6 d0             	movzbl %al,%edx
  8004b2:	83 e8 23             	sub    $0x23,%eax
  8004b5:	3c 55                	cmp    $0x55,%al
  8004b7:	0f 87 31 03 00 00    	ja     8007ee <vprintfmt+0x3a8>
  8004bd:	0f b6 c0             	movzbl %al,%eax
  8004c0:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ca:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ce:	eb d6                	jmp    8004a6 <vprintfmt+0x60>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	89 75 08             	mov    %esi,0x8(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004de:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004e2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004e5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8004e8:	83 fe 09             	cmp    $0x9,%esi
  8004eb:	77 34                	ja     800521 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f0:	eb e9                	jmp    8004db <vprintfmt+0x95>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800503:	eb 22                	jmp    800527 <vprintfmt+0xe1>
  800505:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800508:	85 c0                	test   %eax,%eax
  80050a:	0f 48 c1             	cmovs  %ecx,%eax
  80050d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800513:	eb 91                	jmp    8004a6 <vprintfmt+0x60>
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800518:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051f:	eb 85                	jmp    8004a6 <vprintfmt+0x60>
  800521:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800524:	8b 75 08             	mov    0x8(%ebp),%esi

		process_precision:
			if (width < 0)
  800527:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052b:	0f 89 75 ff ff ff    	jns    8004a6 <vprintfmt+0x60>
				width = precision, precision = -1;
  800531:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800534:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800537:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80053e:	e9 63 ff ff ff       	jmp    8004a6 <vprintfmt+0x60>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800543:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054a:	e9 57 ff ff ff       	jmp    8004a6 <vprintfmt+0x60>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	53                   	push   %ebx
  80055c:	ff 30                	pushl  (%eax)
  80055e:	ff d6                	call   *%esi
			break;
  800560:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800566:	e9 01 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 04             	lea    0x4(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 00                	mov    (%eax),%eax
  800576:	99                   	cltd   
  800577:	31 d0                	xor    %edx,%eax
  800579:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057b:	83 f8 0f             	cmp    $0xf,%eax
  80057e:	7f 0b                	jg     80058b <vprintfmt+0x145>
  800580:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800587:	85 d2                	test   %edx,%edx
  800589:	75 18                	jne    8005a3 <vprintfmt+0x15d>
				printfmt(putch, putdat, "error %d", err);
  80058b:	50                   	push   %eax
  80058c:	68 ff 23 80 00       	push   $0x8023ff
  800591:	53                   	push   %ebx
  800592:	56                   	push   %esi
  800593:	e8 91 fe ff ff       	call   800429 <printfmt>
  800598:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059e:	e9 c9 fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a3:	52                   	push   %edx
  8005a4:	68 d9 28 80 00       	push   $0x8028d9
  8005a9:	53                   	push   %ebx
  8005aa:	56                   	push   %esi
  8005ab:	e8 79 fe ff ff       	call   800429 <printfmt>
  8005b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	e9 b1 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	b8 f8 23 80 00       	mov    $0x8023f8,%eax
  8005cd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d4:	0f 8e 94 00 00 00    	jle    80066e <vprintfmt+0x228>
  8005da:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005de:	0f 84 98 00 00 00    	je     80067c <vprintfmt+0x236>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	ff 75 cc             	pushl  -0x34(%ebp)
  8005ea:	57                   	push   %edi
  8005eb:	e8 a1 02 00 00       	call   800891 <strnlen>
  8005f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f3:	29 c1                	sub    %eax,%ecx
  8005f5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005f8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800602:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800605:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800607:	eb 0f                	jmp    800618 <vprintfmt+0x1d2>
					putch(padc, putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	ff 75 e0             	pushl  -0x20(%ebp)
  800610:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	83 ef 01             	sub    $0x1,%edi
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	85 ff                	test   %edi,%edi
  80061a:	7f ed                	jg     800609 <vprintfmt+0x1c3>
  80061c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800622:	85 c9                	test   %ecx,%ecx
  800624:	b8 00 00 00 00       	mov    $0x0,%eax
  800629:	0f 49 c1             	cmovns %ecx,%eax
  80062c:	29 c1                	sub    %eax,%ecx
  80062e:	89 75 08             	mov    %esi,0x8(%ebp)
  800631:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800634:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800637:	89 cb                	mov    %ecx,%ebx
  800639:	eb 4d                	jmp    800688 <vprintfmt+0x242>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063f:	74 1b                	je     80065c <vprintfmt+0x216>
  800641:	0f be c0             	movsbl %al,%eax
  800644:	83 e8 20             	sub    $0x20,%eax
  800647:	83 f8 5e             	cmp    $0x5e,%eax
  80064a:	76 10                	jbe    80065c <vprintfmt+0x216>
					putch('?', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	ff 75 0c             	pushl  0xc(%ebp)
  800652:	6a 3f                	push   $0x3f
  800654:	ff 55 08             	call   *0x8(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	eb 0d                	jmp    800669 <vprintfmt+0x223>
				else
					putch(ch, putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	ff 75 0c             	pushl  0xc(%ebp)
  800662:	52                   	push   %edx
  800663:	ff 55 08             	call   *0x8(%ebp)
  800666:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800669:	83 eb 01             	sub    $0x1,%ebx
  80066c:	eb 1a                	jmp    800688 <vprintfmt+0x242>
  80066e:	89 75 08             	mov    %esi,0x8(%ebp)
  800671:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800674:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800677:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067a:	eb 0c                	jmp    800688 <vprintfmt+0x242>
  80067c:	89 75 08             	mov    %esi,0x8(%ebp)
  80067f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800682:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800685:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800688:	83 c7 01             	add    $0x1,%edi
  80068b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068f:	0f be d0             	movsbl %al,%edx
  800692:	85 d2                	test   %edx,%edx
  800694:	74 23                	je     8006b9 <vprintfmt+0x273>
  800696:	85 f6                	test   %esi,%esi
  800698:	78 a1                	js     80063b <vprintfmt+0x1f5>
  80069a:	83 ee 01             	sub    $0x1,%esi
  80069d:	79 9c                	jns    80063b <vprintfmt+0x1f5>
  80069f:	89 df                	mov    %ebx,%edi
  8006a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a7:	eb 18                	jmp    8006c1 <vprintfmt+0x27b>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 20                	push   $0x20
  8006af:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b1:	83 ef 01             	sub    $0x1,%edi
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	eb 08                	jmp    8006c1 <vprintfmt+0x27b>
  8006b9:	89 df                	mov    %ebx,%edi
  8006bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c1:	85 ff                	test   %edi,%edi
  8006c3:	7f e4                	jg     8006a9 <vprintfmt+0x263>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c8:	e9 9f fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cd:	83 7d d0 01          	cmpl   $0x1,-0x30(%ebp)
  8006d1:	7e 16                	jle    8006e9 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 08             	lea    0x8(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 50 04             	mov    0x4(%eax),%edx
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e7:	eb 34                	jmp    80071d <vprintfmt+0x2d7>
	else if (lflag)
  8006e9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006ed:	74 18                	je     800707 <vprintfmt+0x2c1>
		return va_arg(*ap, long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fd:	89 c1                	mov    %eax,%ecx
  8006ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800702:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800705:	eb 16                	jmp    80071d <vprintfmt+0x2d7>
	else
		return va_arg(*ap, int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800715:	89 c1                	mov    %eax,%ecx
  800717:	c1 f9 1f             	sar    $0x1f,%ecx
  80071a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800720:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800723:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800728:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072c:	0f 89 88 00 00 00    	jns    8007ba <vprintfmt+0x374>
				putch('-', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 2d                	push   $0x2d
  800738:	ff d6                	call   *%esi
				num = -(long long) num;
  80073a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80073d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800740:	f7 d8                	neg    %eax
  800742:	83 d2 00             	adc    $0x0,%edx
  800745:	f7 da                	neg    %edx
  800747:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074f:	eb 69                	jmp    8007ba <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800751:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
  800757:	e8 76 fc ff ff       	call   8003d2 <getuint>
			base = 10;
  80075c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800761:	eb 57                	jmp    8007ba <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 30                	push   $0x30
  800769:	ff d6                	call   *%esi
			num = getuint(&ap, lflag);
  80076b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	e8 5c fc ff ff       	call   8003d2 <getuint>
			base = 8;
			goto number;
  800776:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800779:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80077e:	eb 3a                	jmp    8007ba <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	53                   	push   %ebx
  800784:	6a 30                	push   $0x30
  800786:	ff d6                	call   *%esi
			putch('x', putdat);
  800788:	83 c4 08             	add    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 78                	push   $0x78
  80078e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 50 04             	lea    0x4(%eax),%edx
  800796:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800799:	8b 00                	mov    (%eax),%eax
  80079b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007a8:	eb 10                	jmp    8007ba <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b0:	e8 1d fc ff ff       	call   8003d2 <getuint>
			base = 16;
  8007b5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ba:	83 ec 0c             	sub    $0xc,%esp
  8007bd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c1:	57                   	push   %edi
  8007c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c5:	51                   	push   %ecx
  8007c6:	52                   	push   %edx
  8007c7:	50                   	push   %eax
  8007c8:	89 da                	mov    %ebx,%edx
  8007ca:	89 f0                	mov    %esi,%eax
  8007cc:	e8 52 fb ff ff       	call   800323 <printnum>
			break;
  8007d1:	83 c4 20             	add    $0x20,%esp
  8007d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d7:	e9 90 fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	52                   	push   %edx
  8007e1:	ff d6                	call   *%esi
			break;
  8007e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e9:	e9 7e fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 25                	push   $0x25
  8007f4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	eb 03                	jmp    8007fe <vprintfmt+0x3b8>
  8007fb:	83 ef 01             	sub    $0x1,%edi
  8007fe:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800802:	75 f7                	jne    8007fb <vprintfmt+0x3b5>
  800804:	e9 63 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800809:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5f                   	pop    %edi
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	83 ec 18             	sub    $0x18,%esp
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800820:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800824:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800827:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082e:	85 c0                	test   %eax,%eax
  800830:	74 26                	je     800858 <vsnprintf+0x47>
  800832:	85 d2                	test   %edx,%edx
  800834:	7e 22                	jle    800858 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800836:	ff 75 14             	pushl  0x14(%ebp)
  800839:	ff 75 10             	pushl  0x10(%ebp)
  80083c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083f:	50                   	push   %eax
  800840:	68 0c 04 80 00       	push   $0x80040c
  800845:	e8 fc fb ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800850:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	eb 05                	jmp    80085d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800858:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800868:	50                   	push   %eax
  800869:	ff 75 10             	pushl  0x10(%ebp)
  80086c:	ff 75 0c             	pushl  0xc(%ebp)
  80086f:	ff 75 08             	pushl  0x8(%ebp)
  800872:	e8 9a ff ff ff       	call   800811 <vsnprintf>
	va_end(ap);

	return rc;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 03                	jmp    800889 <strlen+0x10>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800889:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088d:	75 f7                	jne    800886 <strlen+0xd>
		n++;
	return n;
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800897:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089a:	ba 00 00 00 00       	mov    $0x0,%edx
  80089f:	eb 03                	jmp    8008a4 <strnlen+0x13>
		n++;
  8008a1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a4:	39 c2                	cmp    %eax,%edx
  8008a6:	74 08                	je     8008b0 <strnlen+0x1f>
  8008a8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ac:	75 f3                	jne    8008a1 <strnlen+0x10>
  8008ae:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bc:	89 c2                	mov    %eax,%edx
  8008be:	83 c2 01             	add    $0x1,%edx
  8008c1:	83 c1 01             	add    $0x1,%ecx
  8008c4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008cb:	84 db                	test   %bl,%bl
  8008cd:	75 ef                	jne    8008be <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d9:	53                   	push   %ebx
  8008da:	e8 9a ff ff ff       	call   800879 <strlen>
  8008df:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e2:	ff 75 0c             	pushl  0xc(%ebp)
  8008e5:	01 d8                	add    %ebx,%eax
  8008e7:	50                   	push   %eax
  8008e8:	e8 c5 ff ff ff       	call   8008b2 <strcpy>
	return dst;
}
  8008ed:	89 d8                	mov    %ebx,%eax
  8008ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ff:	89 f3                	mov    %esi,%ebx
  800901:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800904:	89 f2                	mov    %esi,%edx
  800906:	eb 0f                	jmp    800917 <strncpy+0x23>
		*dst++ = *src;
  800908:	83 c2 01             	add    $0x1,%edx
  80090b:	0f b6 01             	movzbl (%ecx),%eax
  80090e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800911:	80 39 01             	cmpb   $0x1,(%ecx)
  800914:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800917:	39 da                	cmp    %ebx,%edx
  800919:	75 ed                	jne    800908 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091b:	89 f0                	mov    %esi,%eax
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	8b 75 08             	mov    0x8(%ebp),%esi
  800929:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092c:	8b 55 10             	mov    0x10(%ebp),%edx
  80092f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800931:	85 d2                	test   %edx,%edx
  800933:	74 21                	je     800956 <strlcpy+0x35>
  800935:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800939:	89 f2                	mov    %esi,%edx
  80093b:	eb 09                	jmp    800946 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093d:	83 c2 01             	add    $0x1,%edx
  800940:	83 c1 01             	add    $0x1,%ecx
  800943:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800946:	39 c2                	cmp    %eax,%edx
  800948:	74 09                	je     800953 <strlcpy+0x32>
  80094a:	0f b6 19             	movzbl (%ecx),%ebx
  80094d:	84 db                	test   %bl,%bl
  80094f:	75 ec                	jne    80093d <strlcpy+0x1c>
  800951:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800953:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800956:	29 f0                	sub    %esi,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800965:	eb 06                	jmp    80096d <strcmp+0x11>
		p++, q++;
  800967:	83 c1 01             	add    $0x1,%ecx
  80096a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096d:	0f b6 01             	movzbl (%ecx),%eax
  800970:	84 c0                	test   %al,%al
  800972:	74 04                	je     800978 <strcmp+0x1c>
  800974:	3a 02                	cmp    (%edx),%al
  800976:	74 ef                	je     800967 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 c0             	movzbl %al,%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 c3                	mov    %eax,%ebx
  80098e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800991:	eb 06                	jmp    800999 <strncmp+0x17>
		n--, p++, q++;
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	39 d8                	cmp    %ebx,%eax
  80099b:	74 15                	je     8009b2 <strncmp+0x30>
  80099d:	0f b6 08             	movzbl (%eax),%ecx
  8009a0:	84 c9                	test   %cl,%cl
  8009a2:	74 04                	je     8009a8 <strncmp+0x26>
  8009a4:	3a 0a                	cmp    (%edx),%cl
  8009a6:	74 eb                	je     800993 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 00             	movzbl (%eax),%eax
  8009ab:	0f b6 12             	movzbl (%edx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
  8009b0:	eb 05                	jmp    8009b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	eb 07                	jmp    8009cd <strchr+0x13>
		if (*s == c)
  8009c6:	38 ca                	cmp    %cl,%dl
  8009c8:	74 0f                	je     8009d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 f2                	jne    8009c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	eb 03                	jmp    8009ea <strfind+0xf>
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ed:	38 ca                	cmp    %cl,%dl
  8009ef:	74 04                	je     8009f5 <strfind+0x1a>
  8009f1:	84 d2                	test   %dl,%dl
  8009f3:	75 f2                	jne    8009e7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	74 36                	je     800a3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0d:	75 28                	jne    800a37 <memset+0x40>
  800a0f:	f6 c1 03             	test   $0x3,%cl
  800a12:	75 23                	jne    800a37 <memset+0x40>
		c &= 0xFF;
  800a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d3                	mov    %edx,%ebx
  800a1a:	c1 e3 08             	shl    $0x8,%ebx
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	c1 e6 18             	shl    $0x18,%esi
  800a22:	89 d0                	mov    %edx,%eax
  800a24:	c1 e0 10             	shl    $0x10,%eax
  800a27:	09 f0                	or     %esi,%eax
  800a29:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a2b:	89 d8                	mov    %ebx,%eax
  800a2d:	09 d0                	or     %edx,%eax
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
  800a32:	fc                   	cld    
  800a33:	f3 ab                	rep stos %eax,%es:(%edi)
  800a35:	eb 06                	jmp    800a3d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3a:	fc                   	cld    
  800a3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3d:	89 f8                	mov    %edi,%eax
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a52:	39 c6                	cmp    %eax,%esi
  800a54:	73 35                	jae    800a8b <memmove+0x47>
  800a56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a59:	39 d0                	cmp    %edx,%eax
  800a5b:	73 2e                	jae    800a8b <memmove+0x47>
		s += n;
		d += n;
  800a5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	09 fe                	or     %edi,%esi
  800a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6a:	75 13                	jne    800a7f <memmove+0x3b>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0e                	jne    800a7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a71:	83 ef 04             	sub    $0x4,%edi
  800a74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a77:	c1 e9 02             	shr    $0x2,%ecx
  800a7a:	fd                   	std    
  800a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7d:	eb 09                	jmp    800a88 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7f:	83 ef 01             	sub    $0x1,%edi
  800a82:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a85:	fd                   	std    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a88:	fc                   	cld    
  800a89:	eb 1d                	jmp    800aa8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8b:	89 f2                	mov    %esi,%edx
  800a8d:	09 c2                	or     %eax,%edx
  800a8f:	f6 c2 03             	test   $0x3,%dl
  800a92:	75 0f                	jne    800aa3 <memmove+0x5f>
  800a94:	f6 c1 03             	test   $0x3,%cl
  800a97:	75 0a                	jne    800aa3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a99:	c1 e9 02             	shr    $0x2,%ecx
  800a9c:	89 c7                	mov    %eax,%edi
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 05                	jmp    800aa8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aaf:	ff 75 10             	pushl  0x10(%ebp)
  800ab2:	ff 75 0c             	pushl  0xc(%ebp)
  800ab5:	ff 75 08             	pushl  0x8(%ebp)
  800ab8:	e8 87 ff ff ff       	call   800a44 <memmove>
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	89 c6                	mov    %eax,%esi
  800acc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	eb 1a                	jmp    800aeb <memcmp+0x2c>
		if (*s1 != *s2)
  800ad1:	0f b6 08             	movzbl (%eax),%ecx
  800ad4:	0f b6 1a             	movzbl (%edx),%ebx
  800ad7:	38 d9                	cmp    %bl,%cl
  800ad9:	74 0a                	je     800ae5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800adb:	0f b6 c1             	movzbl %cl,%eax
  800ade:	0f b6 db             	movzbl %bl,%ebx
  800ae1:	29 d8                	sub    %ebx,%eax
  800ae3:	eb 0f                	jmp    800af4 <memcmp+0x35>
		s1++, s2++;
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aeb:	39 f0                	cmp    %esi,%eax
  800aed:	75 e2                	jne    800ad1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	53                   	push   %ebx
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aff:	89 c1                	mov    %eax,%ecx
  800b01:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b04:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b08:	eb 0a                	jmp    800b14 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0a:	0f b6 10             	movzbl (%eax),%edx
  800b0d:	39 da                	cmp    %ebx,%edx
  800b0f:	74 07                	je     800b18 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b11:	83 c0 01             	add    $0x1,%eax
  800b14:	39 c8                	cmp    %ecx,%eax
  800b16:	72 f2                	jb     800b0a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b18:	5b                   	pop    %ebx
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b27:	eb 03                	jmp    800b2c <strtol+0x11>
		s++;
  800b29:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2c:	0f b6 01             	movzbl (%ecx),%eax
  800b2f:	3c 20                	cmp    $0x20,%al
  800b31:	74 f6                	je     800b29 <strtol+0xe>
  800b33:	3c 09                	cmp    $0x9,%al
  800b35:	74 f2                	je     800b29 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b37:	3c 2b                	cmp    $0x2b,%al
  800b39:	75 0a                	jne    800b45 <strtol+0x2a>
		s++;
  800b3b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b43:	eb 11                	jmp    800b56 <strtol+0x3b>
  800b45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4a:	3c 2d                	cmp    $0x2d,%al
  800b4c:	75 08                	jne    800b56 <strtol+0x3b>
		s++, neg = 1;
  800b4e:	83 c1 01             	add    $0x1,%ecx
  800b51:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5c:	75 15                	jne    800b73 <strtol+0x58>
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 10                	jne    800b73 <strtol+0x58>
  800b63:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b67:	75 7c                	jne    800be5 <strtol+0xca>
		s += 2, base = 16;
  800b69:	83 c1 02             	add    $0x2,%ecx
  800b6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b71:	eb 16                	jmp    800b89 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b73:	85 db                	test   %ebx,%ebx
  800b75:	75 12                	jne    800b89 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b77:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7f:	75 08                	jne    800b89 <strtol+0x6e>
		s++, base = 8;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b91:	0f b6 11             	movzbl (%ecx),%edx
  800b94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b97:	89 f3                	mov    %esi,%ebx
  800b99:	80 fb 09             	cmp    $0x9,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0x8b>
			dig = *s - '0';
  800b9e:	0f be d2             	movsbl %dl,%edx
  800ba1:	83 ea 30             	sub    $0x30,%edx
  800ba4:	eb 22                	jmp    800bc8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ba6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba9:	89 f3                	mov    %esi,%ebx
  800bab:	80 fb 19             	cmp    $0x19,%bl
  800bae:	77 08                	ja     800bb8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb0:	0f be d2             	movsbl %dl,%edx
  800bb3:	83 ea 57             	sub    $0x57,%edx
  800bb6:	eb 10                	jmp    800bc8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bb8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbb:	89 f3                	mov    %esi,%ebx
  800bbd:	80 fb 19             	cmp    $0x19,%bl
  800bc0:	77 16                	ja     800bd8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc2:	0f be d2             	movsbl %dl,%edx
  800bc5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bc8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bcb:	7d 0b                	jge    800bd8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bcd:	83 c1 01             	add    $0x1,%ecx
  800bd0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd6:	eb b9                	jmp    800b91 <strtol+0x76>

	if (endptr)
  800bd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdc:	74 0d                	je     800beb <strtol+0xd0>
		*endptr = (char *) s;
  800bde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be1:	89 0e                	mov    %ecx,(%esi)
  800be3:	eb 06                	jmp    800beb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be5:	85 db                	test   %ebx,%ebx
  800be7:	74 98                	je     800b81 <strtol+0x66>
  800be9:	eb 9e                	jmp    800b89 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800beb:	89 c2                	mov    %eax,%edx
  800bed:	f7 da                	neg    %edx
  800bef:	85 ff                	test   %edi,%edi
  800bf1:	0f 45 c2             	cmovne %edx,%eax
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	89 c3                	mov    %eax,%ebx
  800c0c:	89 c7                	mov    %eax,%edi
  800c0e:	89 c6                	mov    %eax,%esi
  800c10:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 01 00 00 00       	mov    $0x1,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c44:	b8 03 00 00 00       	mov    $0x3,%eax
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 cb                	mov    %ecx,%ebx
  800c4e:	89 cf                	mov    %ecx,%edi
  800c50:	89 ce                	mov    %ecx,%esi
  800c52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 17                	jle    800c6f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 03                	push   $0x3
  800c5e:	68 df 26 80 00       	push   $0x8026df
  800c63:	6a 23                	push   $0x23
  800c65:	68 fc 26 80 00       	push   $0x8026fc
  800c6a:	e8 c7 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c82:	b8 02 00 00 00       	mov    $0x2,%eax
  800c87:	89 d1                	mov    %edx,%ecx
  800c89:	89 d3                	mov    %edx,%ebx
  800c8b:	89 d7                	mov    %edx,%edi
  800c8d:	89 d6                	mov    %edx,%esi
  800c8f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_yield>:

void
sys_yield(void)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca6:	89 d1                	mov    %edx,%ecx
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	89 d7                	mov    %edx,%edi
  800cac:	89 d6                	mov    %edx,%esi
  800cae:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	be 00 00 00 00       	mov    $0x0,%esi
  800cc3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd1:	89 f7                	mov    %esi,%edi
  800cd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 04                	push   $0x4
  800cdf:	68 df 26 80 00       	push   $0x8026df
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 fc 26 80 00       	push   $0x8026fc
  800ceb:	e8 46 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	b8 05 00 00 00       	mov    $0x5,%eax
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d12:	8b 75 18             	mov    0x18(%ebp),%esi
  800d15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 05                	push   $0x5
  800d21:	68 df 26 80 00       	push   $0x8026df
  800d26:	6a 23                	push   $0x23
  800d28:	68 fc 26 80 00       	push   $0x8026fc
  800d2d:	e8 04 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 06                	push   $0x6
  800d63:	68 df 26 80 00       	push   $0x8026df
  800d68:	6a 23                	push   $0x23
  800d6a:	68 fc 26 80 00       	push   $0x8026fc
  800d6f:	e8 c2 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	89 df                	mov    %ebx,%edi
  800d97:	89 de                	mov    %ebx,%esi
  800d99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7e 17                	jle    800db6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	50                   	push   %eax
  800da3:	6a 08                	push   $0x8
  800da5:	68 df 26 80 00       	push   $0x8026df
  800daa:	6a 23                	push   $0x23
  800dac:	68 fc 26 80 00       	push   $0x8026fc
  800db1:	e8 80 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	89 de                	mov    %ebx,%esi
  800ddb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 09                	push   $0x9
  800de7:	68 df 26 80 00       	push   $0x8026df
  800dec:	6a 23                	push   $0x23
  800dee:	68 fc 26 80 00       	push   $0x8026fc
  800df3:	e8 3e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 0a                	push   $0xa
  800e29:	68 df 26 80 00       	push   $0x8026df
  800e2e:	6a 23                	push   $0x23
  800e30:	68 fc 26 80 00       	push   $0x8026fc
  800e35:	e8 fc f3 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	be 00 00 00 00       	mov    $0x0,%esi
  800e4d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e73:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	89 cb                	mov    %ecx,%ebx
  800e7d:	89 cf                	mov    %ecx,%edi
  800e7f:	89 ce                	mov    %ecx,%esi
  800e81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	7e 17                	jle    800e9e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	50                   	push   %eax
  800e8b:	6a 0d                	push   $0xd
  800e8d:	68 df 26 80 00       	push   $0x8026df
  800e92:	6a 23                	push   $0x23
  800e94:	68 fc 26 80 00       	push   $0x8026fc
  800e99:	e8 98 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
    	pte_t *pte;
	int ret;
	// 用户空间的地址较低
	void *addr = (void *)(pn * PGSIZE);
  800ead:	89 d3                	mov    %edx,%ebx
  800eaf:	c1 e3 0c             	shl    $0xc,%ebx
	if (uvpt[pn] & PTE_SHARE) {
  800eb2:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800eb9:	f6 c5 04             	test   $0x4,%ch
  800ebc:	74 2f                	je     800eed <duppage+0x47>
		// cprintf("dup share page :%d\n", pn);
		if ((r = sys_page_map(0, addr, envid, addr, PTE_SYSCALL)) < 0)
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	68 07 0e 00 00       	push   $0xe07
  800ec6:	53                   	push   %ebx
  800ec7:	50                   	push   %eax
  800ec8:	53                   	push   %ebx
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 28 fe ff ff       	call   800cf8 <sys_page_map>
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	0f 89 a0 00 00 00    	jns    800f7b <duppage+0xd5>
			panic("duppage sys_page_map:%e", r);
  800edb:	50                   	push   %eax
  800edc:	68 0a 27 80 00       	push   $0x80270a
  800ee1:	6a 4d                	push   $0x4d
  800ee3:	68 22 27 80 00       	push   $0x802722
  800ee8:	e8 49 f3 ff ff       	call   800236 <_panic>
	} else if (uvpt[pn] & (PTE_W|PTE_COW)) {
  800eed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef4:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800efa:	74 57                	je     800f53 <duppage+0xad>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	68 05 08 00 00       	push   $0x805
  800f04:	53                   	push   %ebx
  800f05:	50                   	push   %eax
  800f06:	53                   	push   %ebx
  800f07:	6a 00                	push   $0x0
  800f09:	e8 ea fd ff ff       	call   800cf8 <sys_page_map>
  800f0e:	83 c4 20             	add    $0x20,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	79 12                	jns    800f27 <duppage+0x81>
			panic("sys_page_map COW:%e", r);
  800f15:	50                   	push   %eax
  800f16:	68 2d 27 80 00       	push   $0x80272d
  800f1b:	6a 50                	push   $0x50
  800f1d:	68 22 27 80 00       	push   $0x802722
  800f22:	e8 0f f3 ff ff       	call   800236 <_panic>

		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	68 05 08 00 00       	push   $0x805
  800f2f:	53                   	push   %ebx
  800f30:	6a 00                	push   $0x0
  800f32:	53                   	push   %ebx
  800f33:	6a 00                	push   $0x0
  800f35:	e8 be fd ff ff       	call   800cf8 <sys_page_map>
  800f3a:	83 c4 20             	add    $0x20,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 3a                	jns    800f7b <duppage+0xd5>
			panic("sys_page_map COW:%e", r);
  800f41:	50                   	push   %eax
  800f42:	68 2d 27 80 00       	push   $0x80272d
  800f47:	6a 53                	push   $0x53
  800f49:	68 22 27 80 00       	push   $0x802722
  800f4e:	e8 e3 f2 ff ff       	call   800236 <_panic>
	} else {
		if ((r = sys_page_map(0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	6a 05                	push   $0x5
  800f58:	53                   	push   %ebx
  800f59:	50                   	push   %eax
  800f5a:	53                   	push   %ebx
  800f5b:	6a 00                	push   $0x0
  800f5d:	e8 96 fd ff ff       	call   800cf8 <sys_page_map>
  800f62:	83 c4 20             	add    $0x20,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	79 12                	jns    800f7b <duppage+0xd5>
			panic("sys_page_map UP:%e", r);
  800f69:	50                   	push   %eax
  800f6a:	68 41 27 80 00       	push   $0x802741
  800f6f:	6a 56                	push   $0x56
  800f71:	68 22 27 80 00       	push   $0x802722
  800f76:	e8 bb f2 ff ff       	call   800236 <_panic>
	}
	return 0;
}
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f8d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (! ( (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f8f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f93:	74 2d                	je     800fc2 <pgfault+0x3d>
  800f95:	89 d8                	mov    %ebx,%eax
  800f97:	c1 e8 16             	shr    $0x16,%eax
  800f9a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa1:	a8 01                	test   $0x1,%al
  800fa3:	74 1d                	je     800fc2 <pgfault+0x3d>
  800fa5:	89 d8                	mov    %ebx,%eax
  800fa7:	c1 e8 0c             	shr    $0xc,%eax
  800faa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb1:	f6 c2 01             	test   $0x1,%dl
  800fb4:	74 0c                	je     800fc2 <pgfault+0x3d>
  800fb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbd:	f6 c4 08             	test   $0x8,%ah
  800fc0:	75 14                	jne    800fd6 <pgfault+0x51>
        	panic("Neither the fault is a write nor COW page. \n");
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	68 c0 27 80 00       	push   $0x8027c0
  800fca:	6a 1d                	push   $0x1d
  800fcc:	68 22 27 80 00       	push   $0x802722
  800fd1:	e8 60 f2 ff ff       	call   800236 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	

    	envid_t envid = sys_getenvid();
  800fd6:	e8 9c fc ff ff       	call   800c77 <sys_getenvid>
  800fdb:	89 c6                	mov    %eax,%esi
    	// cprintf("pgfault: envid: %d\n", ENVX(envid));
    	// 临时页暂存
    	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P| PTE_W|PTE_U)) < 0)
  800fdd:	83 ec 04             	sub    $0x4,%esp
  800fe0:	6a 07                	push   $0x7
  800fe2:	68 00 f0 7f 00       	push   $0x7ff000
  800fe7:	50                   	push   %eax
  800fe8:	e8 c8 fc ff ff       	call   800cb5 <sys_page_alloc>
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	79 12                	jns    801006 <pgfault+0x81>
        	panic("pgfault: page allocation fault:%e\n", r);
  800ff4:	50                   	push   %eax
  800ff5:	68 f0 27 80 00       	push   $0x8027f0
  800ffa:	6a 2b                	push   $0x2b
  800ffc:	68 22 27 80 00       	push   $0x802722
  801001:	e8 30 f2 ff ff       	call   800236 <_panic>
    	addr = ROUNDDOWN(addr, PGSIZE);
  801006:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  80100c:	83 ec 04             	sub    $0x4,%esp
  80100f:	68 00 10 00 00       	push   $0x1000
  801014:	53                   	push   %ebx
  801015:	68 00 f0 7f 00       	push   $0x7ff000
  80101a:	e8 8d fa ff ff       	call   800aac <memcpy>
    	if ((r = sys_page_map(envid, (void *) PFTEMP, envid, addr , PTE_P|PTE_W|PTE_U)) < 0 )
  80101f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801026:	53                   	push   %ebx
  801027:	56                   	push   %esi
  801028:	68 00 f0 7f 00       	push   $0x7ff000
  80102d:	56                   	push   %esi
  80102e:	e8 c5 fc ff ff       	call   800cf8 <sys_page_map>
  801033:	83 c4 20             	add    $0x20,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	79 12                	jns    80104c <pgfault+0xc7>
        	panic("pgfault: page map failed %e\n", r);
  80103a:	50                   	push   %eax
  80103b:	68 54 27 80 00       	push   $0x802754
  801040:	6a 2f                	push   $0x2f
  801042:	68 22 27 80 00       	push   $0x802722
  801047:	e8 ea f1 ff ff       	call   800236 <_panic>
    
    	if ((r = sys_page_unmap(envid, (void *) PFTEMP)) < 0)
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	68 00 f0 7f 00       	push   $0x7ff000
  801054:	56                   	push   %esi
  801055:	e8 e0 fc ff ff       	call   800d3a <sys_page_unmap>
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	79 12                	jns    801073 <pgfault+0xee>
        	panic("pgfault: page unmap failed %e\n", r);
  801061:	50                   	push   %eax
  801062:	68 14 28 80 00       	push   $0x802814
  801067:	6a 32                	push   $0x32
  801069:	68 22 27 80 00       	push   $0x802722
  80106e:	e8 c3 f1 ff ff       	call   800236 <_panic>
	//panic("pgfault not implemented");
}
  801073:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801082:	68 85 0f 80 00       	push   $0x800f85
  801087:	e8 14 0e 00 00       	call   801ea0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80108c:	b8 07 00 00 00       	mov    $0x7,%eax
  801091:	cd 30                	int    $0x30
  801093:	89 c3                	mov    %eax,%ebx

	envid_t envid = sys_exofork();
	uint8_t *addr;
	if (envid < 0)
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	79 12                	jns    8010ae <fork+0x34>
		panic("sys_exofork:%e", envid);
  80109c:	50                   	push   %eax
  80109d:	68 71 27 80 00       	push   $0x802771
  8010a2:	6a 75                	push   $0x75
  8010a4:	68 22 27 80 00       	push   $0x802722
  8010a9:	e8 88 f1 ff ff       	call   800236 <_panic>
  8010ae:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	75 21                	jne    8010d5 <fork+0x5b>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010b4:	e8 be fb ff ff       	call   800c77 <sys_getenvid>
  8010b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c6:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d0:	e9 c0 00 00 00       	jmp    801195 <fork+0x11b>
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  8010d5:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8010dc:	ba 00 00 80 00       	mov    $0x800000,%edx
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8010e1:	89 d0                	mov    %edx,%eax
  8010e3:	c1 e8 16             	shr    $0x16,%eax
  8010e6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ed:	a8 01                	test   $0x1,%al
  8010ef:	74 20                	je     801111 <fork+0x97>
  8010f1:	c1 ea 0c             	shr    $0xc,%edx
  8010f4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010fb:	a8 01                	test   $0x1,%al
  8010fd:	74 12                	je     801111 <fork+0x97>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8010ff:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801106:	a8 04                	test   $0x4,%al
  801108:	74 07                	je     801111 <fork+0x97>
			duppage(envid, PGNUM(addr));
  80110a:	89 f0                	mov    %esi,%eax
  80110c:	e8 95 fd ff ff       	call   800ea6 <duppage>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (addr = (uint8_t *)UTEXT; addr < (uint8_t *)USTACKTOP-PGSIZE; addr += PGSIZE) {
  801111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801114:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  80111a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80111d:	81 fa ff cf bf ee    	cmp    $0xeebfcfff,%edx
  801123:	76 bc                	jbe    8010e1 <fork+0x67>
				&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}

	duppage(envid, PGNUM(ROUNDDOWN(&addr, PGSIZE)));
  801125:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801128:	c1 ea 0c             	shr    $0xc,%edx
  80112b:	89 d8                	mov    %ebx,%eax
  80112d:	e8 74 fd ff ff       	call   800ea6 <duppage>

	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)))
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	6a 07                	push   $0x7
  801137:	68 00 f0 bf ee       	push   $0xeebff000
  80113c:	53                   	push   %ebx
  80113d:	e8 73 fb ff ff       	call   800cb5 <sys_page_alloc>
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	74 15                	je     80115e <fork+0xe4>
		panic("sys_page_alloc:%e", r);
  801149:	50                   	push   %eax
  80114a:	68 80 27 80 00       	push   $0x802780
  80114f:	68 86 00 00 00       	push   $0x86
  801154:	68 22 27 80 00       	push   $0x802722
  801159:	e8 d8 f0 ff ff       	call   800236 <_panic>

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	68 08 1f 80 00       	push   $0x801f08
  801166:	53                   	push   %ebx
  801167:	e8 94 fc ff ff       	call   800e00 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)))
  80116c:	83 c4 08             	add    $0x8,%esp
  80116f:	6a 02                	push   $0x2
  801171:	53                   	push   %ebx
  801172:	e8 05 fc ff ff       	call   800d7c <sys_env_set_status>
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	74 15                	je     801193 <fork+0x119>
		panic("sys_env_set_status:%e", r);
  80117e:	50                   	push   %eax
  80117f:	68 92 27 80 00       	push   $0x802792
  801184:	68 8c 00 00 00       	push   $0x8c
  801189:	68 22 27 80 00       	push   $0x802722
  80118e:	e8 a3 f0 ff ff       	call   800236 <_panic>

	return envid;
  801193:	89 d8                	mov    %ebx,%eax
	    
}
  801195:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sfork>:

// Challenge!
int
sfork(void)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a2:	68 a8 27 80 00       	push   $0x8027a8
  8011a7:	68 96 00 00 00       	push   $0x96
  8011ac:	68 22 27 80 00       	push   $0x802722
  8011b1:	e8 80 f0 ff ff       	call   800236 <_panic>

008011b6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c1:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cc:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	c1 ea 16             	shr    $0x16,%edx
  8011ed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f4:	f6 c2 01             	test   $0x1,%dl
  8011f7:	74 11                	je     80120a <fd_alloc+0x2d>
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 0c             	shr    $0xc,%edx
  8011fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	75 09                	jne    801213 <fd_alloc+0x36>
			*fd_store = fd;
  80120a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  801211:	eb 17                	jmp    80122a <fd_alloc+0x4d>
  801213:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801218:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80121d:	75 c9                	jne    8011e8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80121f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801225:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801232:	83 f8 1f             	cmp    $0x1f,%eax
  801235:	77 36                	ja     80126d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801237:	c1 e0 0c             	shl    $0xc,%eax
  80123a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80123f:	89 c2                	mov    %eax,%edx
  801241:	c1 ea 16             	shr    $0x16,%edx
  801244:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124b:	f6 c2 01             	test   $0x1,%dl
  80124e:	74 24                	je     801274 <fd_lookup+0x48>
  801250:	89 c2                	mov    %eax,%edx
  801252:	c1 ea 0c             	shr    $0xc,%edx
  801255:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125c:	f6 c2 01             	test   $0x1,%dl
  80125f:	74 1a                	je     80127b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801261:	8b 55 0c             	mov    0xc(%ebp),%edx
  801264:	89 02                	mov    %eax,(%edx)
	return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
  80126b:	eb 13                	jmp    801280 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801272:	eb 0c                	jmp    801280 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801279:	eb 05                	jmp    801280 <fd_lookup+0x54>
  80127b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128b:	ba b0 28 80 00       	mov    $0x8028b0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801290:	eb 13                	jmp    8012a5 <dev_lookup+0x23>
  801292:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801295:	39 08                	cmp    %ecx,(%eax)
  801297:	75 0c                	jne    8012a5 <dev_lookup+0x23>
			*dev = devtab[i];
  801299:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a3:	eb 2e                	jmp    8012d3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a5:	8b 02                	mov    (%edx),%eax
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	75 e7                	jne    801292 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b0:	8b 40 48             	mov    0x48(%eax),%eax
  8012b3:	83 ec 04             	sub    $0x4,%esp
  8012b6:	51                   	push   %ecx
  8012b7:	50                   	push   %eax
  8012b8:	68 34 28 80 00       	push   $0x802834
  8012bd:	e8 4d f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  8012c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 10             	sub    $0x10,%esp
  8012dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ed:	c1 e8 0c             	shr    $0xc,%eax
  8012f0:	50                   	push   %eax
  8012f1:	e8 36 ff ff ff       	call   80122c <fd_lookup>
  8012f6:	83 c4 08             	add    $0x8,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 05                	js     801302 <fd_close+0x2d>
	    || fd != fd2)
  8012fd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801300:	74 0c                	je     80130e <fd_close+0x39>
		return (must_exist ? r : 0);
  801302:	84 db                	test   %bl,%bl
  801304:	ba 00 00 00 00       	mov    $0x0,%edx
  801309:	0f 44 c2             	cmove  %edx,%eax
  80130c:	eb 41                	jmp    80134f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 36                	pushl  (%esi)
  801317:	e8 66 ff ff ff       	call   801282 <dev_lookup>
  80131c:	89 c3                	mov    %eax,%ebx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	78 1a                	js     80133f <fd_close+0x6a>
		if (dev->dev_close)
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80132b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801330:	85 c0                	test   %eax,%eax
  801332:	74 0b                	je     80133f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	56                   	push   %esi
  801338:	ff d0                	call   *%eax
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	56                   	push   %esi
  801343:	6a 00                	push   $0x0
  801345:	e8 f0 f9 ff ff       	call   800d3a <sys_page_unmap>
	return r;
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	89 d8                	mov    %ebx,%eax
}
  80134f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 c4 fe ff ff       	call   80122c <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 10                	js     80137f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	6a 01                	push   $0x1
  801374:	ff 75 f4             	pushl  -0xc(%ebp)
  801377:	e8 59 ff ff ff       	call   8012d5 <fd_close>
  80137c:	83 c4 10             	add    $0x10,%esp
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <close_all>:

void
close_all(void)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	53                   	push   %ebx
  801385:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801388:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	53                   	push   %ebx
  801391:	e8 c0 ff ff ff       	call   801356 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801396:	83 c3 01             	add    $0x1,%ebx
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	83 fb 20             	cmp    $0x20,%ebx
  80139f:	75 ec                	jne    80138d <close_all+0xc>
		close(i);
}
  8013a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a4:	c9                   	leave  
  8013a5:	c3                   	ret    

008013a6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 2c             	sub    $0x2c,%esp
  8013af:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	ff 75 08             	pushl  0x8(%ebp)
  8013b9:	e8 6e fe ff ff       	call   80122c <fd_lookup>
  8013be:	83 c4 08             	add    $0x8,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	0f 88 c1 00 00 00    	js     80148a <dup+0xe4>
		return r;
	close(newfdnum);
  8013c9:	83 ec 0c             	sub    $0xc,%esp
  8013cc:	56                   	push   %esi
  8013cd:	e8 84 ff ff ff       	call   801356 <close>

	newfd = INDEX2FD(newfdnum);
  8013d2:	89 f3                	mov    %esi,%ebx
  8013d4:	c1 e3 0c             	shl    $0xc,%ebx
  8013d7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013dd:	83 c4 04             	add    $0x4,%esp
  8013e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e3:	e8 de fd ff ff       	call   8011c6 <fd2data>
  8013e8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ea:	89 1c 24             	mov    %ebx,(%esp)
  8013ed:	e8 d4 fd ff ff       	call   8011c6 <fd2data>
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f8:	89 f8                	mov    %edi,%eax
  8013fa:	c1 e8 16             	shr    $0x16,%eax
  8013fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801404:	a8 01                	test   $0x1,%al
  801406:	74 37                	je     80143f <dup+0x99>
  801408:	89 f8                	mov    %edi,%eax
  80140a:	c1 e8 0c             	shr    $0xc,%eax
  80140d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801414:	f6 c2 01             	test   $0x1,%dl
  801417:	74 26                	je     80143f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801419:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801420:	83 ec 0c             	sub    $0xc,%esp
  801423:	25 07 0e 00 00       	and    $0xe07,%eax
  801428:	50                   	push   %eax
  801429:	ff 75 d4             	pushl  -0x2c(%ebp)
  80142c:	6a 00                	push   $0x0
  80142e:	57                   	push   %edi
  80142f:	6a 00                	push   $0x0
  801431:	e8 c2 f8 ff ff       	call   800cf8 <sys_page_map>
  801436:	89 c7                	mov    %eax,%edi
  801438:	83 c4 20             	add    $0x20,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 2e                	js     80146d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801442:	89 d0                	mov    %edx,%eax
  801444:	c1 e8 0c             	shr    $0xc,%eax
  801447:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	25 07 0e 00 00       	and    $0xe07,%eax
  801456:	50                   	push   %eax
  801457:	53                   	push   %ebx
  801458:	6a 00                	push   $0x0
  80145a:	52                   	push   %edx
  80145b:	6a 00                	push   $0x0
  80145d:	e8 96 f8 ff ff       	call   800cf8 <sys_page_map>
  801462:	89 c7                	mov    %eax,%edi
  801464:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801467:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801469:	85 ff                	test   %edi,%edi
  80146b:	79 1d                	jns    80148a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	53                   	push   %ebx
  801471:	6a 00                	push   $0x0
  801473:	e8 c2 f8 ff ff       	call   800d3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801478:	83 c4 08             	add    $0x8,%esp
  80147b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80147e:	6a 00                	push   $0x0
  801480:	e8 b5 f8 ff ff       	call   800d3a <sys_page_unmap>
	return r;
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	89 f8                	mov    %edi,%eax
}
  80148a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5f                   	pop    %edi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 14             	sub    $0x14,%esp
  801499:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	53                   	push   %ebx
  8014a1:	e8 86 fd ff ff       	call   80122c <fd_lookup>
  8014a6:	83 c4 08             	add    $0x8,%esp
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 6d                	js     80151c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b9:	ff 30                	pushl  (%eax)
  8014bb:	e8 c2 fd ff ff       	call   801282 <dev_lookup>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 4c                	js     801513 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ca:	8b 42 08             	mov    0x8(%edx),%eax
  8014cd:	83 e0 03             	and    $0x3,%eax
  8014d0:	83 f8 01             	cmp    $0x1,%eax
  8014d3:	75 21                	jne    8014f6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014da:	8b 40 48             	mov    0x48(%eax),%eax
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	50                   	push   %eax
  8014e2:	68 75 28 80 00       	push   $0x802875
  8014e7:	e8 23 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f4:	eb 26                	jmp    80151c <read+0x8a>
	}
	if (!dev->dev_read)
  8014f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f9:	8b 40 08             	mov    0x8(%eax),%eax
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	74 17                	je     801517 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	ff 75 10             	pushl  0x10(%ebp)
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	52                   	push   %edx
  80150a:	ff d0                	call   *%eax
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	eb 09                	jmp    80151c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	89 c2                	mov    %eax,%edx
  801515:	eb 05                	jmp    80151c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801517:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80151c:	89 d0                	mov    %edx,%eax
  80151e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	57                   	push   %edi
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801532:	bb 00 00 00 00       	mov    $0x0,%ebx
  801537:	eb 21                	jmp    80155a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	29 d8                	sub    %ebx,%eax
  801540:	50                   	push   %eax
  801541:	89 d8                	mov    %ebx,%eax
  801543:	03 45 0c             	add    0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	57                   	push   %edi
  801548:	e8 45 ff ff ff       	call   801492 <read>
		if (m < 0)
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 10                	js     801564 <readn+0x41>
			return m;
		if (m == 0)
  801554:	85 c0                	test   %eax,%eax
  801556:	74 0a                	je     801562 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801558:	01 c3                	add    %eax,%ebx
  80155a:	39 f3                	cmp    %esi,%ebx
  80155c:	72 db                	jb     801539 <readn+0x16>
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	eb 02                	jmp    801564 <readn+0x41>
  801562:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801564:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5f                   	pop    %edi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 14             	sub    $0x14,%esp
  801573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	53                   	push   %ebx
  80157b:	e8 ac fc ff ff       	call   80122c <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	89 c2                	mov    %eax,%edx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 68                	js     8015f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	ff 30                	pushl  (%eax)
  801595:	e8 e8 fc ff ff       	call   801282 <dev_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 47                	js     8015e8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a8:	75 21                	jne    8015cb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8015af:	8b 40 48             	mov    0x48(%eax),%eax
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	50                   	push   %eax
  8015b7:	68 91 28 80 00       	push   $0x802891
  8015bc:	e8 4e ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c9:	eb 26                	jmp    8015f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d1:	85 d2                	test   %edx,%edx
  8015d3:	74 17                	je     8015ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	ff 75 10             	pushl  0x10(%ebp)
  8015db:	ff 75 0c             	pushl  0xc(%ebp)
  8015de:	50                   	push   %eax
  8015df:	ff d2                	call   *%edx
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	eb 09                	jmp    8015f1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	eb 05                	jmp    8015f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f1:	89 d0                	mov    %edx,%eax
  8015f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	ff 75 08             	pushl  0x8(%ebp)
  801605:	e8 22 fc ff ff       	call   80122c <fd_lookup>
  80160a:	83 c4 08             	add    $0x8,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 0e                	js     80161f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801611:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
  801617:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80161a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	53                   	push   %ebx
  801625:	83 ec 14             	sub    $0x14,%esp
  801628:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	53                   	push   %ebx
  801630:	e8 f7 fb ff ff       	call   80122c <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	89 c2                	mov    %eax,%edx
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 65                	js     8016a3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801648:	ff 30                	pushl  (%eax)
  80164a:	e8 33 fc ff ff       	call   801282 <dev_lookup>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 44                	js     80169a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801659:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165d:	75 21                	jne    801680 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80165f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801664:	8b 40 48             	mov    0x48(%eax),%eax
  801667:	83 ec 04             	sub    $0x4,%esp
  80166a:	53                   	push   %ebx
  80166b:	50                   	push   %eax
  80166c:	68 54 28 80 00       	push   $0x802854
  801671:	e8 99 ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167e:	eb 23                	jmp    8016a3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801680:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801683:	8b 52 18             	mov    0x18(%edx),%edx
  801686:	85 d2                	test   %edx,%edx
  801688:	74 14                	je     80169e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	ff 75 0c             	pushl  0xc(%ebp)
  801690:	50                   	push   %eax
  801691:	ff d2                	call   *%edx
  801693:	89 c2                	mov    %eax,%edx
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	eb 09                	jmp    8016a3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	eb 05                	jmp    8016a3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80169e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a3:	89 d0                	mov    %edx,%eax
  8016a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 14             	sub    $0x14,%esp
  8016b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	ff 75 08             	pushl  0x8(%ebp)
  8016bb:	e8 6c fb ff ff       	call   80122c <fd_lookup>
  8016c0:	83 c4 08             	add    $0x8,%esp
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 58                	js     801721 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d3:	ff 30                	pushl  (%eax)
  8016d5:	e8 a8 fb ff ff       	call   801282 <dev_lookup>
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 37                	js     801718 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e8:	74 32                	je     80171c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f4:	00 00 00 
	stat->st_isdir = 0;
  8016f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016fe:	00 00 00 
	stat->st_dev = dev;
  801701:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	53                   	push   %ebx
  80170b:	ff 75 f0             	pushl  -0x10(%ebp)
  80170e:	ff 50 14             	call   *0x14(%eax)
  801711:	89 c2                	mov    %eax,%edx
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	eb 09                	jmp    801721 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801718:	89 c2                	mov    %eax,%edx
  80171a:	eb 05                	jmp    801721 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80171c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801721:	89 d0                	mov    %edx,%eax
  801723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	6a 00                	push   $0x0
  801732:	ff 75 08             	pushl  0x8(%ebp)
  801735:	e8 e3 01 00 00       	call   80191d <open>
  80173a:	89 c3                	mov    %eax,%ebx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 1b                	js     80175e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	ff 75 0c             	pushl  0xc(%ebp)
  801749:	50                   	push   %eax
  80174a:	e8 5b ff ff ff       	call   8016aa <fstat>
  80174f:	89 c6                	mov    %eax,%esi
	close(fd);
  801751:	89 1c 24             	mov    %ebx,(%esp)
  801754:	e8 fd fb ff ff       	call   801356 <close>
	return r;
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	89 f0                	mov    %esi,%eax
}
  80175e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	89 c6                	mov    %eax,%esi
  80176c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80176e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801775:	75 12                	jne    801789 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	6a 01                	push   $0x1
  80177c:	e8 54 08 00 00       	call   801fd5 <ipc_find_env>
  801781:	a3 00 40 80 00       	mov    %eax,0x804000
  801786:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801789:	6a 07                	push   $0x7
  80178b:	68 00 50 80 00       	push   $0x805000
  801790:	56                   	push   %esi
  801791:	ff 35 00 40 80 00    	pushl  0x804000
  801797:	e8 e5 07 00 00       	call   801f81 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179c:	83 c4 0c             	add    $0xc,%esp
  80179f:	6a 00                	push   $0x0
  8017a1:	53                   	push   %ebx
  8017a2:	6a 00                	push   $0x0
  8017a4:	e8 83 07 00 00       	call   801f2c <ipc_recv>
}
  8017a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d3:	e8 8d ff ff ff       	call   801765 <fsipc>
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f5:	e8 6b ff ff ff       	call   801765 <fsipc>
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	53                   	push   %ebx
  801800:	83 ec 04             	sub    $0x4,%esp
  801803:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	8b 40 0c             	mov    0xc(%eax),%eax
  80180c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 05 00 00 00       	mov    $0x5,%eax
  80181b:	e8 45 ff ff ff       	call   801765 <fsipc>
  801820:	85 c0                	test   %eax,%eax
  801822:	78 2c                	js     801850 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	68 00 50 80 00       	push   $0x805000
  80182c:	53                   	push   %ebx
  80182d:	e8 80 f0 ff ff       	call   8008b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801832:	a1 80 50 80 00       	mov    0x805080,%eax
  801837:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80183d:	a1 84 50 80 00       	mov    0x805084,%eax
  801842:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
    
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185e:	8b 55 08             	mov    0x8(%ebp),%edx
  801861:	8b 52 0c             	mov    0xc(%edx),%edx
  801864:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = MIN(n, PGSIZE);
  80186a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186f:	ba 00 10 00 00       	mov    $0x1000,%edx
  801874:	0f 47 c2             	cmova  %edx,%eax
  801877:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80187c:	50                   	push   %eax
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	68 08 50 80 00       	push   $0x805008
  801885:	e8 ba f1 ff ff       	call   800a44 <memmove>
    int r = fsipc(FSREQ_WRITE, NULL);
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	b8 04 00 00 00       	mov    $0x4,%eax
  801894:	e8 cc fe ff ff       	call   801765 <fsipc>
    return r;
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	56                   	push   %esi
  80189f:	53                   	push   %ebx
  8018a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018ae:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018be:	e8 a2 fe ff ff       	call   801765 <fsipc>
  8018c3:	89 c3                	mov    %eax,%ebx
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	78 4b                	js     801914 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018c9:	39 c6                	cmp    %eax,%esi
  8018cb:	73 16                	jae    8018e3 <devfile_read+0x48>
  8018cd:	68 c0 28 80 00       	push   $0x8028c0
  8018d2:	68 c7 28 80 00       	push   $0x8028c7
  8018d7:	6a 7c                	push   $0x7c
  8018d9:	68 dc 28 80 00       	push   $0x8028dc
  8018de:	e8 53 e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8018e3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e8:	7e 16                	jle    801900 <devfile_read+0x65>
  8018ea:	68 e7 28 80 00       	push   $0x8028e7
  8018ef:	68 c7 28 80 00       	push   $0x8028c7
  8018f4:	6a 7d                	push   $0x7d
  8018f6:	68 dc 28 80 00       	push   $0x8028dc
  8018fb:	e8 36 e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	50                   	push   %eax
  801904:	68 00 50 80 00       	push   $0x805000
  801909:	ff 75 0c             	pushl  0xc(%ebp)
  80190c:	e8 33 f1 ff ff       	call   800a44 <memmove>
	return r;
  801911:	83 c4 10             	add    $0x10,%esp
}
  801914:	89 d8                	mov    %ebx,%eax
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 20             	sub    $0x20,%esp
  801924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801927:	53                   	push   %ebx
  801928:	e8 4c ef ff ff       	call   800879 <strlen>
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801935:	7f 67                	jg     80199e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193d:	50                   	push   %eax
  80193e:	e8 9a f8 ff ff       	call   8011dd <fd_alloc>
  801943:	83 c4 10             	add    $0x10,%esp
		return r;
  801946:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 57                	js     8019a3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	53                   	push   %ebx
  801950:	68 00 50 80 00       	push   $0x805000
  801955:	e8 58 ef ff ff       	call   8008b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801962:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801965:	b8 01 00 00 00       	mov    $0x1,%eax
  80196a:	e8 f6 fd ff ff       	call   801765 <fsipc>
  80196f:	89 c3                	mov    %eax,%ebx
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	79 14                	jns    80198c <open+0x6f>
		fd_close(fd, 0);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	6a 00                	push   $0x0
  80197d:	ff 75 f4             	pushl  -0xc(%ebp)
  801980:	e8 50 f9 ff ff       	call   8012d5 <fd_close>
		return r;
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	89 da                	mov    %ebx,%edx
  80198a:	eb 17                	jmp    8019a3 <open+0x86>
	}

	return fd2num(fd);
  80198c:	83 ec 0c             	sub    $0xc,%esp
  80198f:	ff 75 f4             	pushl  -0xc(%ebp)
  801992:	e8 1f f8 ff ff       	call   8011b6 <fd2num>
  801997:	89 c2                	mov    %eax,%edx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	eb 05                	jmp    8019a3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80199e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019a3:	89 d0                	mov    %edx,%eax
  8019a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ba:	e8 a6 fd ff ff       	call   801765 <fsipc>
}
  8019bf:	c9                   	leave  
  8019c0:	c3                   	ret    

008019c1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	ff 75 08             	pushl  0x8(%ebp)
  8019cf:	e8 f2 f7 ff ff       	call   8011c6 <fd2data>
  8019d4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d6:	83 c4 08             	add    $0x8,%esp
  8019d9:	68 f3 28 80 00       	push   $0x8028f3
  8019de:	53                   	push   %ebx
  8019df:	e8 ce ee ff ff       	call   8008b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e4:	8b 46 04             	mov    0x4(%esi),%eax
  8019e7:	2b 06                	sub    (%esi),%eax
  8019e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f6:	00 00 00 
	stat->st_dev = &devpipe;
  8019f9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a00:	30 80 00 
	return 0;
}
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
  801a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	53                   	push   %ebx
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a19:	53                   	push   %ebx
  801a1a:	6a 00                	push   $0x0
  801a1c:	e8 19 f3 ff ff       	call   800d3a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a21:	89 1c 24             	mov    %ebx,(%esp)
  801a24:	e8 9d f7 ff ff       	call   8011c6 <fd2data>
  801a29:	83 c4 08             	add    $0x8,%esp
  801a2c:	50                   	push   %eax
  801a2d:	6a 00                	push   $0x0
  801a2f:	e8 06 f3 ff ff       	call   800d3a <sys_page_unmap>
}
  801a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	57                   	push   %edi
  801a3d:	56                   	push   %esi
  801a3e:	53                   	push   %ebx
  801a3f:	83 ec 1c             	sub    $0x1c,%esp
  801a42:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a45:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a47:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	ff 75 e0             	pushl  -0x20(%ebp)
  801a55:	e8 b4 05 00 00       	call   80200e <pageref>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	89 3c 24             	mov    %edi,(%esp)
  801a5f:	e8 aa 05 00 00       	call   80200e <pageref>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	39 c3                	cmp    %eax,%ebx
  801a69:	0f 94 c1             	sete   %cl
  801a6c:	0f b6 c9             	movzbl %cl,%ecx
  801a6f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a72:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a78:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a7b:	39 ce                	cmp    %ecx,%esi
  801a7d:	74 1b                	je     801a9a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a7f:	39 c3                	cmp    %eax,%ebx
  801a81:	75 c4                	jne    801a47 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a83:	8b 42 58             	mov    0x58(%edx),%eax
  801a86:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a89:	50                   	push   %eax
  801a8a:	56                   	push   %esi
  801a8b:	68 fa 28 80 00       	push   $0x8028fa
  801a90:	e8 7a e8 ff ff       	call   80030f <cprintf>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	eb ad                	jmp    801a47 <_pipeisclosed+0xe>
	}
}
  801a9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	57                   	push   %edi
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
  801aab:	83 ec 28             	sub    $0x28,%esp
  801aae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab1:	56                   	push   %esi
  801ab2:	e8 0f f7 ff ff       	call   8011c6 <fd2data>
  801ab7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac1:	eb 4b                	jmp    801b0e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac3:	89 da                	mov    %ebx,%edx
  801ac5:	89 f0                	mov    %esi,%eax
  801ac7:	e8 6d ff ff ff       	call   801a39 <_pipeisclosed>
  801acc:	85 c0                	test   %eax,%eax
  801ace:	75 48                	jne    801b18 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad0:	e8 c1 f1 ff ff       	call   800c96 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad8:	8b 0b                	mov    (%ebx),%ecx
  801ada:	8d 51 20             	lea    0x20(%ecx),%edx
  801add:	39 d0                	cmp    %edx,%eax
  801adf:	73 e2                	jae    801ac3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aeb:	89 c2                	mov    %eax,%edx
  801aed:	c1 fa 1f             	sar    $0x1f,%edx
  801af0:	89 d1                	mov    %edx,%ecx
  801af2:	c1 e9 1b             	shr    $0x1b,%ecx
  801af5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af8:	83 e2 1f             	and    $0x1f,%edx
  801afb:	29 ca                	sub    %ecx,%edx
  801afd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b05:	83 c0 01             	add    $0x1,%eax
  801b08:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0b:	83 c7 01             	add    $0x1,%edi
  801b0e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b11:	75 c2                	jne    801ad5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b13:	8b 45 10             	mov    0x10(%ebp),%eax
  801b16:	eb 05                	jmp    801b1d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 18             	sub    $0x18,%esp
  801b2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b31:	57                   	push   %edi
  801b32:	e8 8f f6 ff ff       	call   8011c6 <fd2data>
  801b37:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b41:	eb 3d                	jmp    801b80 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b43:	85 db                	test   %ebx,%ebx
  801b45:	74 04                	je     801b4b <devpipe_read+0x26>
				return i;
  801b47:	89 d8                	mov    %ebx,%eax
  801b49:	eb 44                	jmp    801b8f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4b:	89 f2                	mov    %esi,%edx
  801b4d:	89 f8                	mov    %edi,%eax
  801b4f:	e8 e5 fe ff ff       	call   801a39 <_pipeisclosed>
  801b54:	85 c0                	test   %eax,%eax
  801b56:	75 32                	jne    801b8a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b58:	e8 39 f1 ff ff       	call   800c96 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b5d:	8b 06                	mov    (%esi),%eax
  801b5f:	3b 46 04             	cmp    0x4(%esi),%eax
  801b62:	74 df                	je     801b43 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b64:	99                   	cltd   
  801b65:	c1 ea 1b             	shr    $0x1b,%edx
  801b68:	01 d0                	add    %edx,%eax
  801b6a:	83 e0 1f             	and    $0x1f,%eax
  801b6d:	29 d0                	sub    %edx,%eax
  801b6f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b77:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b7a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7d:	83 c3 01             	add    $0x1,%ebx
  801b80:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b83:	75 d8                	jne    801b5d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b85:	8b 45 10             	mov    0x10(%ebp),%eax
  801b88:	eb 05                	jmp    801b8f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba2:	50                   	push   %eax
  801ba3:	e8 35 f6 ff ff       	call   8011dd <fd_alloc>
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	89 c2                	mov    %eax,%edx
  801bad:	85 c0                	test   %eax,%eax
  801baf:	0f 88 2c 01 00 00    	js     801ce1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	68 07 04 00 00       	push   $0x407
  801bbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 ee f0 ff ff       	call   800cb5 <sys_page_alloc>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	89 c2                	mov    %eax,%edx
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	0f 88 0d 01 00 00    	js     801ce1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bda:	50                   	push   %eax
  801bdb:	e8 fd f5 ff ff       	call   8011dd <fd_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	0f 88 e2 00 00 00    	js     801ccf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	68 07 04 00 00       	push   $0x407
  801bf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 b6 f0 ff ff       	call   800cb5 <sys_page_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 c3 00 00 00    	js     801ccf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c12:	e8 af f5 ff ff       	call   8011c6 <fd2data>
  801c17:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c19:	83 c4 0c             	add    $0xc,%esp
  801c1c:	68 07 04 00 00       	push   $0x407
  801c21:	50                   	push   %eax
  801c22:	6a 00                	push   $0x0
  801c24:	e8 8c f0 ff ff       	call   800cb5 <sys_page_alloc>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	0f 88 89 00 00 00    	js     801cbf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c36:	83 ec 0c             	sub    $0xc,%esp
  801c39:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3c:	e8 85 f5 ff ff       	call   8011c6 <fd2data>
  801c41:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c48:	50                   	push   %eax
  801c49:	6a 00                	push   $0x0
  801c4b:	56                   	push   %esi
  801c4c:	6a 00                	push   $0x0
  801c4e:	e8 a5 f0 ff ff       	call   800cf8 <sys_page_map>
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	83 c4 20             	add    $0x20,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	78 55                	js     801cb1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c65:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c71:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8c:	e8 25 f5 ff ff       	call   8011b6 <fd2num>
  801c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c94:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c96:	83 c4 04             	add    $0x4,%esp
  801c99:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9c:	e8 15 f5 ff ff       	call   8011b6 <fd2num>
  801ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	ba 00 00 00 00       	mov    $0x0,%edx
  801caf:	eb 30                	jmp    801ce1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb1:	83 ec 08             	sub    $0x8,%esp
  801cb4:	56                   	push   %esi
  801cb5:	6a 00                	push   $0x0
  801cb7:	e8 7e f0 ff ff       	call   800d3a <sys_page_unmap>
  801cbc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 6e f0 ff ff       	call   800d3a <sys_page_unmap>
  801ccc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 5e f0 ff ff       	call   800d3a <sys_page_unmap>
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce1:	89 d0                	mov    %edx,%eax
  801ce3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf3:	50                   	push   %eax
  801cf4:	ff 75 08             	pushl  0x8(%ebp)
  801cf7:	e8 30 f5 ff ff       	call   80122c <fd_lookup>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 18                	js     801d1b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d03:	83 ec 0c             	sub    $0xc,%esp
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	e8 b8 f4 ff ff       	call   8011c6 <fd2data>
	return _pipeisclosed(fd, p);
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	e8 21 fd ff ff       	call   801a39 <_pipeisclosed>
  801d18:	83 c4 10             	add    $0x10,%esp
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2d:	68 12 29 80 00       	push   $0x802912
  801d32:	ff 75 0c             	pushl  0xc(%ebp)
  801d35:	e8 78 eb ff ff       	call   8008b2 <strcpy>
	return 0;
}
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	57                   	push   %edi
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
  801d47:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d52:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d58:	eb 2d                	jmp    801d87 <devcons_write+0x46>
		m = n - tot;
  801d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d5f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d62:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d67:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6a:	83 ec 04             	sub    $0x4,%esp
  801d6d:	53                   	push   %ebx
  801d6e:	03 45 0c             	add    0xc(%ebp),%eax
  801d71:	50                   	push   %eax
  801d72:	57                   	push   %edi
  801d73:	e8 cc ec ff ff       	call   800a44 <memmove>
		sys_cputs(buf, m);
  801d78:	83 c4 08             	add    $0x8,%esp
  801d7b:	53                   	push   %ebx
  801d7c:	57                   	push   %edi
  801d7d:	e8 77 ee ff ff       	call   800bf9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d82:	01 de                	add    %ebx,%esi
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	89 f0                	mov    %esi,%eax
  801d89:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8c:	72 cc                	jb     801d5a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d91:	5b                   	pop    %ebx
  801d92:	5e                   	pop    %esi
  801d93:	5f                   	pop    %edi
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da5:	74 2a                	je     801dd1 <devcons_read+0x3b>
  801da7:	eb 05                	jmp    801dae <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801da9:	e8 e8 ee ff ff       	call   800c96 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dae:	e8 64 ee ff ff       	call   800c17 <sys_cgetc>
  801db3:	85 c0                	test   %eax,%eax
  801db5:	74 f2                	je     801da9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 16                	js     801dd1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbb:	83 f8 04             	cmp    $0x4,%eax
  801dbe:	74 0c                	je     801dcc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc3:	88 02                	mov    %al,(%edx)
	return 1;
  801dc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dca:	eb 05                	jmp    801dd1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dcc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ddf:	6a 01                	push   $0x1
  801de1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	e8 0f ee ff ff       	call   800bf9 <sys_cputs>
}
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <getchar>:

int
getchar(void)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df5:	6a 01                	push   $0x1
  801df7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfa:	50                   	push   %eax
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 90 f6 ff ff       	call   801492 <read>
	if (r < 0)
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 0f                	js     801e18 <getchar+0x29>
		return r;
	if (r < 1)
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	7e 06                	jle    801e13 <getchar+0x24>
		return -E_EOF;
	return c;
  801e0d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e11:	eb 05                	jmp    801e18 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e13:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e23:	50                   	push   %eax
  801e24:	ff 75 08             	pushl  0x8(%ebp)
  801e27:	e8 00 f4 ff ff       	call   80122c <fd_lookup>
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 11                	js     801e44 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e36:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3c:	39 10                	cmp    %edx,(%eax)
  801e3e:	0f 94 c0             	sete   %al
  801e41:	0f b6 c0             	movzbl %al,%eax
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <opencons>:

int
opencons(void)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4f:	50                   	push   %eax
  801e50:	e8 88 f3 ff ff       	call   8011dd <fd_alloc>
  801e55:	83 c4 10             	add    $0x10,%esp
		return r;
  801e58:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 3e                	js     801e9c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e5e:	83 ec 04             	sub    $0x4,%esp
  801e61:	68 07 04 00 00       	push   $0x407
  801e66:	ff 75 f4             	pushl  -0xc(%ebp)
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 45 ee ff ff       	call   800cb5 <sys_page_alloc>
  801e70:	83 c4 10             	add    $0x10,%esp
		return r;
  801e73:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e75:	85 c0                	test   %eax,%eax
  801e77:	78 23                	js     801e9c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e82:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e87:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	50                   	push   %eax
  801e92:	e8 1f f3 ff ff       	call   8011b6 <fd2num>
  801e97:	89 c2                	mov    %eax,%edx
  801e99:	83 c4 10             	add    $0x10,%esp
}
  801e9c:	89 d0                	mov    %edx,%eax
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	83 ec 08             	sub    $0x8,%esp
	int r;
	int ret;
	if (_pgfault_handler == 0) {
  801ea6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ead:	75 36                	jne    801ee5 <set_pgfault_handler+0x45>
		// First time through!
		// LAB 4: Your code here.
        
        	ret = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801eaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb4:	8b 40 48             	mov    0x48(%eax),%eax
  801eb7:	83 ec 04             	sub    $0x4,%esp
  801eba:	68 07 0e 00 00       	push   $0xe07
  801ebf:	68 00 f0 bf ee       	push   $0xeebff000
  801ec4:	50                   	push   %eax
  801ec5:	e8 eb ed ff ff       	call   800cb5 <sys_page_alloc>
		if (ret < 0) {
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	79 14                	jns    801ee5 <set_pgfault_handler+0x45>
		    panic("Allocate user exception stack failed!\n");
  801ed1:	83 ec 04             	sub    $0x4,%esp
  801ed4:	68 20 29 80 00       	push   $0x802920
  801ed9:	6a 23                	push   $0x23
  801edb:	68 48 29 80 00       	push   $0x802948
  801ee0:	e8 51 e3 ff ff       	call   800236 <_panic>
		}
	}
	sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ee5:	a1 04 40 80 00       	mov    0x804004,%eax
  801eea:	8b 40 48             	mov    0x48(%eax),%eax
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	68 08 1f 80 00       	push   $0x801f08
  801ef5:	50                   	push   %eax
  801ef6:	e8 05 ef ff ff       	call   800e00 <sys_env_set_pgfault_upcall>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
  801efe:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f08:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f09:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f0e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f10:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp), %ebx  # trap-time eip
  801f13:	8b 5c 24 28          	mov    0x28(%esp),%ebx
        subl $0x4, 0x30(%esp)  # trap-time esp minus 4
  801f17:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax 
  801f1c:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl %ebx, (%eax)      # trap-time esp store trap-time eip
  801f20:	89 18                	mov    %ebx,(%eax)
        addl $0x8, %esp
  801f22:	83 c4 08             	add    $0x8,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f25:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801f26:	83 c4 04             	add    $0x4,%esp
        popfl
  801f29:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f2a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f2b:	c3                   	ret    

00801f2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	56                   	push   %esi
  801f30:	53                   	push   %ebx
  801f31:	8b 75 08             	mov    0x8(%ebp),%esi
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_recv not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f41:	0f 44 c2             	cmove  %edx,%eax

    int r = sys_ipc_recv(pg);
  801f44:	83 ec 0c             	sub    $0xc,%esp
  801f47:	50                   	push   %eax
  801f48:	e8 18 ef ff ff       	call   800e65 <sys_ipc_recv>
    int from_env = 0, perm = 0;
    if (r == 0) {
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	75 10                	jne    801f64 <ipc_recv+0x38>
        from_env = thisenv->env_ipc_from;
  801f54:	a1 04 40 80 00       	mov    0x804004,%eax
  801f59:	8b 48 74             	mov    0x74(%eax),%ecx
        perm = thisenv->env_ipc_perm;
  801f5c:	8b 50 78             	mov    0x78(%eax),%edx
        r = thisenv->env_ipc_value;
  801f5f:	8b 40 70             	mov    0x70(%eax),%eax
  801f62:	eb 0a                	jmp    801f6e <ipc_recv+0x42>
    } else {
        from_env = 0;
        perm = 0;
  801f64:	ba 00 00 00 00       	mov    $0x0,%edx
    if (r == 0) {
        from_env = thisenv->env_ipc_from;
        perm = thisenv->env_ipc_perm;
        r = thisenv->env_ipc_value;
    } else {
        from_env = 0;
  801f69:	b9 00 00 00 00       	mov    $0x0,%ecx
        perm = 0;
    }

    if (from_env_store) *from_env_store = from_env;
  801f6e:	85 f6                	test   %esi,%esi
  801f70:	74 02                	je     801f74 <ipc_recv+0x48>
  801f72:	89 0e                	mov    %ecx,(%esi)
    if (perm_store) *perm_store = perm;
  801f74:	85 db                	test   %ebx,%ebx
  801f76:	74 02                	je     801f7a <ipc_recv+0x4e>
  801f78:	89 13                	mov    %edx,(%ebx)

    return r;
}
  801f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f90:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;
  801f93:	85 db                	test   %ebx,%ebx
  801f95:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f9a:	0f 44 d8             	cmove  %eax,%ebx
  801f9d:	eb 1c                	jmp    801fbb <ipc_send+0x3a>

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        if (ret != -E_IPC_NOT_RECV)
  801f9f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa2:	74 12                	je     801fb6 <ipc_send+0x35>
            panic("ipc_send error %e", ret);
  801fa4:	50                   	push   %eax
  801fa5:	68 56 29 80 00       	push   $0x802956
  801faa:	6a 40                	push   $0x40
  801fac:	68 68 29 80 00       	push   $0x802968
  801fb1:	e8 80 e2 ff ff       	call   800236 <_panic>
        sys_yield();
  801fb6:	e8 db ec ff ff       	call   800c96 <sys_yield>
    // LAB 4: Your code here.
    //panic("ipc_send not implemented");
    if (pg == NULL) pg = (void *)UTOP;

    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fbb:	ff 75 14             	pushl  0x14(%ebp)
  801fbe:	53                   	push   %ebx
  801fbf:	56                   	push   %esi
  801fc0:	57                   	push   %edi
  801fc1:	e8 7c ee ff ff       	call   800e42 <sys_ipc_try_send>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	75 d2                	jne    801f9f <ipc_send+0x1e>
        if (ret != -E_IPC_NOT_RECV)
            panic("ipc_send error %e", ret);
        sys_yield();
    }
}
  801fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fe3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe9:	8b 52 50             	mov    0x50(%edx),%edx
  801fec:	39 ca                	cmp    %ecx,%edx
  801fee:	75 0d                	jne    801ffd <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ff8:	8b 40 48             	mov    0x48(%eax),%eax
  801ffb:	eb 0f                	jmp    80200c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ffd:	83 c0 01             	add    $0x1,%eax
  802000:	3d 00 04 00 00       	cmp    $0x400,%eax
  802005:	75 d9                	jne    801fe0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802014:	89 d0                	mov    %edx,%eax
  802016:	c1 e8 16             	shr    $0x16,%eax
  802019:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802025:	f6 c1 01             	test   $0x1,%cl
  802028:	74 1d                	je     802047 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80202a:	c1 ea 0c             	shr    $0xc,%edx
  80202d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802034:	f6 c2 01             	test   $0x1,%dl
  802037:	74 0e                	je     802047 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802039:	c1 ea 0c             	shr    $0xc,%edx
  80203c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802043:	ef 
  802044:	0f b7 c0             	movzwl %ax,%eax
}
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    
  802049:	66 90                	xchg   %ax,%ax
  80204b:	66 90                	xchg   %ax,%ax
  80204d:	66 90                	xchg   %ax,%ax
  80204f:	90                   	nop

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80205b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80205f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 f6                	test   %esi,%esi
  802069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206d:	89 ca                	mov    %ecx,%edx
  80206f:	89 f8                	mov    %edi,%eax
  802071:	75 3d                	jne    8020b0 <__udivdi3+0x60>
  802073:	39 cf                	cmp    %ecx,%edi
  802075:	0f 87 c5 00 00 00    	ja     802140 <__udivdi3+0xf0>
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 fd                	mov    %edi,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f7                	div    %edi
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 c8                	mov    %ecx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c1                	mov    %eax,%ecx
  802094:	89 d8                	mov    %ebx,%eax
  802096:	89 cf                	mov    %ecx,%edi
  802098:	f7 f5                	div    %ebp
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	39 ce                	cmp    %ecx,%esi
  8020b2:	77 74                	ja     802128 <__udivdi3+0xd8>
  8020b4:	0f bd fe             	bsr    %esi,%edi
  8020b7:	83 f7 1f             	xor    $0x1f,%edi
  8020ba:	0f 84 98 00 00 00    	je     802158 <__udivdi3+0x108>
  8020c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	89 c5                	mov    %eax,%ebp
  8020c9:	29 fb                	sub    %edi,%ebx
  8020cb:	d3 e6                	shl    %cl,%esi
  8020cd:	89 d9                	mov    %ebx,%ecx
  8020cf:	d3 ed                	shr    %cl,%ebp
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	09 ee                	or     %ebp,%esi
  8020d7:	89 d9                	mov    %ebx,%ecx
  8020d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020dd:	89 d5                	mov    %edx,%ebp
  8020df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e3:	d3 ed                	shr    %cl,%ebp
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e2                	shl    %cl,%edx
  8020e9:	89 d9                	mov    %ebx,%ecx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	09 c2                	or     %eax,%edx
  8020ef:	89 d0                	mov    %edx,%eax
  8020f1:	89 ea                	mov    %ebp,%edx
  8020f3:	f7 f6                	div    %esi
  8020f5:	89 d5                	mov    %edx,%ebp
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	f7 64 24 0c          	mull   0xc(%esp)
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	72 10                	jb     802111 <__udivdi3+0xc1>
  802101:	8b 74 24 08          	mov    0x8(%esp),%esi
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e6                	shl    %cl,%esi
  802109:	39 c6                	cmp    %eax,%esi
  80210b:	73 07                	jae    802114 <__udivdi3+0xc4>
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	75 03                	jne    802114 <__udivdi3+0xc4>
  802111:	83 eb 01             	sub    $0x1,%ebx
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 d8                	mov    %ebx,%eax
  802118:	89 fa                	mov    %edi,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	31 db                	xor    %ebx,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 d8                	mov    %ebx,%eax
  802142:	f7 f7                	div    %edi
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 c3                	mov    %eax,%ebx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 fa                	mov    %edi,%edx
  80214c:	83 c4 1c             	add    $0x1c,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 ce                	cmp    %ecx,%esi
  80215a:	72 0c                	jb     802168 <__udivdi3+0x118>
  80215c:	31 db                	xor    %ebx,%ebx
  80215e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802162:	0f 87 34 ff ff ff    	ja     80209c <__udivdi3+0x4c>
  802168:	bb 01 00 00 00       	mov    $0x1,%ebx
  80216d:	e9 2a ff ff ff       	jmp    80209c <__udivdi3+0x4c>
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 d2                	test   %edx,%edx
  802199:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 f3                	mov    %esi,%ebx
  8021a3:	89 3c 24             	mov    %edi,(%esp)
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	75 1c                	jne    8021c8 <__umoddi3+0x48>
  8021ac:	39 f7                	cmp    %esi,%edi
  8021ae:	76 50                	jbe    802200 <__umoddi3+0x80>
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	f7 f7                	div    %edi
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	31 d2                	xor    %edx,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	89 d0                	mov    %edx,%eax
  8021cc:	77 52                	ja     802220 <__umoddi3+0xa0>
  8021ce:	0f bd ea             	bsr    %edx,%ebp
  8021d1:	83 f5 1f             	xor    $0x1f,%ebp
  8021d4:	75 5a                	jne    802230 <__umoddi3+0xb0>
  8021d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021da:	0f 82 e0 00 00 00    	jb     8022c0 <__umoddi3+0x140>
  8021e0:	39 0c 24             	cmp    %ecx,(%esp)
  8021e3:	0f 86 d7 00 00 00    	jbe    8022c0 <__umoddi3+0x140>
  8021e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	85 ff                	test   %edi,%edi
  802202:	89 fd                	mov    %edi,%ebp
  802204:	75 0b                	jne    802211 <__umoddi3+0x91>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f7                	div    %edi
  80220f:	89 c5                	mov    %eax,%ebp
  802211:	89 f0                	mov    %esi,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f5                	div    %ebp
  802217:	89 c8                	mov    %ecx,%eax
  802219:	f7 f5                	div    %ebp
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	eb 99                	jmp    8021b8 <__umoddi3+0x38>
  80221f:	90                   	nop
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 1c             	add    $0x1c,%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	8b 34 24             	mov    (%esp),%esi
  802233:	bf 20 00 00 00       	mov    $0x20,%edi
  802238:	89 e9                	mov    %ebp,%ecx
  80223a:	29 ef                	sub    %ebp,%edi
  80223c:	d3 e0                	shl    %cl,%eax
  80223e:	89 f9                	mov    %edi,%ecx
  802240:	89 f2                	mov    %esi,%edx
  802242:	d3 ea                	shr    %cl,%edx
  802244:	89 e9                	mov    %ebp,%ecx
  802246:	09 c2                	or     %eax,%edx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 14 24             	mov    %edx,(%esp)
  80224d:	89 f2                	mov    %esi,%edx
  80224f:	d3 e2                	shl    %cl,%edx
  802251:	89 f9                	mov    %edi,%ecx
  802253:	89 54 24 04          	mov    %edx,0x4(%esp)
  802257:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	89 c6                	mov    %eax,%esi
  802261:	d3 e3                	shl    %cl,%ebx
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 d0                	mov    %edx,%eax
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	09 d8                	or     %ebx,%eax
  80226d:	89 d3                	mov    %edx,%ebx
  80226f:	89 f2                	mov    %esi,%edx
  802271:	f7 34 24             	divl   (%esp)
  802274:	89 d6                	mov    %edx,%esi
  802276:	d3 e3                	shl    %cl,%ebx
  802278:	f7 64 24 04          	mull   0x4(%esp)
  80227c:	39 d6                	cmp    %edx,%esi
  80227e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802282:	89 d1                	mov    %edx,%ecx
  802284:	89 c3                	mov    %eax,%ebx
  802286:	72 08                	jb     802290 <__umoddi3+0x110>
  802288:	75 11                	jne    80229b <__umoddi3+0x11b>
  80228a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80228e:	73 0b                	jae    80229b <__umoddi3+0x11b>
  802290:	2b 44 24 04          	sub    0x4(%esp),%eax
  802294:	1b 14 24             	sbb    (%esp),%edx
  802297:	89 d1                	mov    %edx,%ecx
  802299:	89 c3                	mov    %eax,%ebx
  80229b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80229f:	29 da                	sub    %ebx,%edx
  8022a1:	19 ce                	sbb    %ecx,%esi
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	d3 ea                	shr    %cl,%edx
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	d3 ee                	shr    %cl,%esi
  8022b1:	09 d0                	or     %edx,%eax
  8022b3:	89 f2                	mov    %esi,%edx
  8022b5:	83 c4 1c             	add    $0x1c,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	29 f9                	sub    %edi,%ecx
  8022c2:	19 d6                	sbb    %edx,%esi
  8022c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cc:	e9 18 ff ff ff       	jmp    8021e9 <__umoddi3+0x69>
